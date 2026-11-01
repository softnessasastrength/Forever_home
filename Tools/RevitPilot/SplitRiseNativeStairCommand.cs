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
    static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string output = Path.Combine(root, ".local", "revit-pilot", "split-rise-native-stair", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var seed = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).FirstOrDefault();
            if (seed is null) throw new InvalidOperationException("Template did not provide a seed level.");
            seed.Name = "M324 Lower Reference (Study Only)";
            seed.Elevation = 0;
            Level mid, top;
            using (var tx = new Transaction(doc, "Create M324 split-rise levels"))
            {
                tx.Start();
                mid = Level.Create(doc, 2.5);
                mid.Name = "M324 Intermediate Landing Datum (Study Only)";
                top = Level.Create(doc, 5.0);
                top.Name = "M324 Upper Reference (Study Only)";
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
                    tx.Commit();
                    stairs.Add(new { flight = "lower", element_id = id.Value, run_id = run.Id.Value, actual_risers = run.ActualRisersNumber, base_level = seed.Name, top_level = mid.Name });
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
                    tx.Commit();
                    stairs.Add(new { flight = "upper", element_id = id.Value, run_id = run.Id.Value, actual_risers = run.ActualRisersNumber, base_level = mid.Name, top_level = top.Name });
                }
                scope.Commit(new M324FailureRecorder());
            }
            doc.Regenerate();
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
                native_stair_count = stairs.Count,
                saved_rvt = Path.GetFileName(file),
                saved_rvt_sha256 = Hash(file),
                ifc = Path.Combine("ifc2x3", "FH_M324_Split_Rise_Native_Stair_Study.ifc").Replace('\\', '/'),
                limitations = new[] { "Two native stair elements are a disposable split-rise API test; no landing slab, opening, wall, route, headroom or assembly is selected.", "This does not edit Selected-D or establish code, structural, professional or construction approval." }
            };
            File.WriteAllText(Path.Combine(output, "study-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            doc.Close(false); doc = null;
            TaskDialog.Show("Forever Home", "M324 native split-rise stair study saved:\n" + file);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            if (doc is not null && doc.IsValidObject) doc.Close(false);
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
