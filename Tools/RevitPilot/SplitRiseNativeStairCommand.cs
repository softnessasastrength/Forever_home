using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Architecture;
using Autodesk.Revit.UI;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class SplitRiseNativeStairCommand : IExternalCommand
{
    static string Hash(string path)
    {
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
        return Convert.ToHexString(SHA256.HashData(stream));
    }

    static string FindWorkspaceRoot()
    {
        var directory = new DirectoryInfo(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!);
        while (directory is not null)
        {
            if (Directory.Exists(Path.Combine(directory.FullName, "Project")) &&
                Directory.Exists(Path.Combine(directory.FullName, "Tools")))
                return directory.FullName;
            directory = directory.Parent!;
        }
        throw new DirectoryNotFoundException("Could not locate the Forever_home workspace from the loaded project-local RevitPilot assembly.");
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = FindWorkspaceRoot();
            string output = Path.Combine(root, ".local", "revit-pilot", "split-rise-native-stair", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var seed = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).FirstOrDefault();
            if (seed is null) throw new InvalidOperationException("Template did not provide a seed level.");
            Level mid, top;
            using (var tx = new Transaction(doc, "Create M324 split-rise levels"))
            {
                tx.Start();
                seed.Name = "M324 Lower Reference (Study Only)";
                seed.Elevation = 0;
                mid = Level.Create(doc, 2.5);
                mid.Name = "M324 Intermediate Landing Datum (Study Only)";
                top = Level.Create(doc, 5.0);
                top.Name = "M324 Upper Reference (Study Only)";
                tx.Commit();
            }
            var stairTypeId = new FilteredElementCollector(doc).OfClass(typeof(StairsType)).Cast<StairsType>().FirstOrDefault()?.Id
                ?? throw new InvalidOperationException("Template did not provide a stair type.");
            using (var tx = new Transaction(doc, "Configure disposable M324 stair type"))
            {
                tx.Start();
                var stairType = (StairsType)doc.GetElement(stairTypeId)!;
                stairType.MaxRiserHeight = (2.5 / 4.0) + 0.000001;
                tx.Commit();
            }
            var stairs = new List<object>();
            using (var scope = new StairsEditScope(doc, "M324 native split-rise comparison"))
            {
                var id = scope.Start(seed.Id, mid.Id);
                using (var tx = new Transaction(doc, "Create M324 lower native flight"))
                {
                    tx.Start();
                    var stair = (Stairs)doc.GetElement(id)!;
                    stair.DesiredRisersNumber = 4;
                    var run = StairsRun.CreateStraightRun(doc, id, Line.CreateBound(new XYZ(6, 3, 0), new XYZ(6, 6, 0)), StairsRunJustification.Center);
                    var flight = new { flight = "lower", element_id = id.Value, run_id = run.Id.Value, actual_risers = run.ActualRisersNumber, base_level = seed.Name, top_level = mid.Name };
                    tx.Commit();
                    stairs.Add(flight);
                }
                scope.Commit(new M324FailureRecorder());
            }
            using (var scope = new StairsEditScope(doc, "M324 native split-rise comparison"))
            {
                var id = scope.Start(mid.Id, top.Id);
                using (var tx = new Transaction(doc, "Create M324 upper native flight"))
                {
                    tx.Start();
                    var stair = (Stairs)doc.GetElement(id)!;
                    stair.DesiredRisersNumber = 4;
                    var run = StairsRun.CreateStraightRun(doc, id, Line.CreateBound(new XYZ(10, 6, 2.5), new XYZ(10, 9, 2.5)), StairsRunJustification.Center);
                    var flight = new { flight = "upper", element_id = id.Value, run_id = run.Id.Value, actual_risers = run.ActualRisersNumber, base_level = mid.Name, top_level = top.Name };
                    tx.Commit();
                    stairs.Add(flight);
                }
                scope.Commit(new M324FailureRecorder());
            }
            if (stairs.Count != 2 || stairs.Any(item => (int)item.GetType().GetProperty("actual_risers")!.GetValue(item)! <= 0))
                throw new InvalidOperationException("Native split-rise stair run did not report positive actual risers.");
            string file = Path.Combine(output, "FH_M324_Split_Rise_Native_Stair_Study.rvt");
            doc.SaveAs(file, new SaveAsOptions());
            string ifcDir = Path.Combine(output, "ifc2x3"); Directory.CreateDirectory(ifcDir);
            bool ifcOk;
            using (var tx = new Transaction(doc, "Export M324 native stair IFC2x3"))
            {
                tx.Start();
                var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true };
                options.AddOption("ExportInternalRevitPropertySets", "true");
                ifcOk = doc.Export(ifcDir, "FH_M324_Split_Rise_Native_Stair_Study", options);
                tx.RollBack();
            }
            if (!ifcOk) throw new InvalidOperationException("Native stair IFC export returned false.");
            var manifest = new
            {
                schema = "forever-home-m324-native-split-rise-stair-v1",
                status = "disposable native Revit stair comparison; no selected-D promotion",
                levels = new[] { new { name = seed.Name, elevation_ft = 0.0 }, new { name = mid.Name, elevation_ft = 2.5 }, new { name = top.Name, elevation_ft = 5.0 } },
                flights = stairs,
                total_rise_in = 60.0,
                risers_per_flight = 4,
                disposable_stair_type_max_riser_in = 7.500011999999999,
                native_stair_count = stairs.Count,
                saved_rvt = Path.GetFileName(file),
                saved_rvt_sha256 = Hash(file),
                ifc = Path.Combine("ifc2x3", "FH_M324_Split_Rise_Native_Stair_Study.ifc").Replace('\\', '/'),
                limitations = new[] { "Two native stair elements are a disposable split-rise API test; no landing slab, opening, wall, route, headroom or assembly is selected.", "This does not edit Selected-D or establish code, structural, professional or construction approval." }
            };
            File.WriteAllText(Path.Combine(output, "study-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home", "M324 native split-rise stair study saved:\n" + file);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            TaskDialog.Show("M324 native stair failed", ex.Message);
            return Result.Failed;
        }
    }

    sealed class M324FailureRecorder : IFailuresPreprocessor
    {
        public FailureProcessingResult PreprocessFailures(FailuresAccessor accessor)
        {
            var failures = accessor.GetFailureMessages();
            if (failures.Any(f => f.GetSeverity() == FailureSeverity.Error)) return FailureProcessingResult.ProceedWithRollBack;
            foreach (var failure in failures) accessor.DeleteWarning(failure);
            return FailureProcessingResult.Continue;
        }
    }
}
