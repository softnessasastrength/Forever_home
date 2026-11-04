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
public sealed class IntegratedStairSectionStudyCommand : IExternalCommand
{
    static string Hash(string path)
    {
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
        return Convert.ToHexString(SHA256.HashData(stream)).ToLowerInvariant();
    }

    static string FindWorkspaceRoot()
    {
        var directory = new DirectoryInfo(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!);
        while (directory is not null)
        {
            if (Directory.Exists(Path.Combine(directory.FullName, "Project")) && Directory.Exists(Path.Combine(directory.FullName, "Tools"))) return directory.FullName;
            directory = directory.Parent!;
        }
        throw new DirectoryNotFoundException("Could not locate the Forever_home workspace.");
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = FindWorkspaceRoot();
            string output = Path.Combine(root, ".local", "revit-pilot", "integrated-stair-section-study", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var seed = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).FirstOrDefault() ?? throw new InvalidOperationException("Template has no seed level.");
            Level mid, top;
            using (var tx = new Transaction(doc, "Create integrated 60 in study levels"))
            {
                tx.Start(); seed.Name = "Integrated Study Lower (0 ft; disposable)"; seed.Elevation = 0;
                mid = Level.Create(doc, 2.5); mid.Name = "Integrated Study Main (2.5 ft; disposable)";
                top = Level.Create(doc, 5.0); top.Name = "Integrated Study Upper (5 ft; disposable)";
                tx.Commit();
            }
            var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().FirstOrDefault(x => x.Kind == WallKind.Basic) ?? throw new InvalidOperationException("Template has no basic wall type.");
            var floorType = Floor.GetDefaultFloorType(doc, false) ?? throw new InvalidOperationException("Template has no floor type.");
            int wallCount = 0, floorCount = 0;
            using (var tx = new Transaction(doc, "Create shell and floor context"))
            {
                tx.Start();
                foreach (var level in new[] { seed, mid, top })
                {
                    var points = new[] { new XYZ(0, 0, 0), new XYZ(40, 0, 0), new XYZ(40, 42, 0), new XYZ(0, 42, 0) };
                    for (int i = 0; i < 4; i++) { Wall.Create(doc, Line.CreateBound(points[i], points[(i + 1) % 4]), wallType.Id, level.Id, 9.0, 0, false, false); wallCount++; }
                    var loop = new CurveLoop(); for (int i = 0; i < 4; i++) loop.Append(Line.CreateBound(points[i], points[(i + 1) % 4]));
                    Floor.Create(doc, new List<CurveLoop> { loop }, floorType, level.Id); floorCount++;
                }
                tx.Commit();
            }
            var stairTypeId = new FilteredElementCollector(doc).OfClass(typeof(StairsType)).Cast<StairsType>().FirstOrDefault()?.Id ?? throw new InvalidOperationException("Template has no stair type.");
            var stairRuns = new List<object>();
            using (var scope = new StairsEditScope(doc, "Integrated 60 in lower stair"))
            {
                var id = scope.Start(seed.Id, mid.Id); using var tx = new Transaction(doc, "Create integrated lower stair"); tx.Start(); var stair = (Stairs)doc.GetElement(id)!; stair.DesiredRisersNumber = 4; var run = StairsRun.CreateStraightRun(doc, id, Line.CreateBound(new XYZ(8, 8, 0), new XYZ(8, 11, 0)), StairsRunJustification.Center); stairRuns.Add(new { flight = "lower", stair_id = id.Value, run_id = run.Id.Value, actual_risers = run.ActualRisersNumber }); tx.Commit(); scope.Commit(new IntegratedFailureRecorder());
            }
            using (var scope = new StairsEditScope(doc, "Integrated 60 in upper stair"))
            {
                var id = scope.Start(mid.Id, top.Id); using var tx = new Transaction(doc, "Create integrated upper stair"); tx.Start(); var stair = (Stairs)doc.GetElement(id)!; stair.DesiredRisersNumber = 4; var run = StairsRun.CreateStraightRun(doc, id, Line.CreateBound(new XYZ(12, 8, 2.5), new XYZ(12, 11, 2.5)), StairsRunJustification.Center); stairRuns.Add(new { flight = "upper", stair_id = id.Value, run_id = run.Id.Value, actual_risers = run.ActualRisersNumber }); tx.Commit(); scope.Commit(new IntegratedFailureRecorder());
            }
            int sectionCount = 0;
            using (var tx = new Transaction(doc, "Create integrated section view"))
            {
                tx.Start();
                var type = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().FirstOrDefault(x => x.ViewFamily == ViewFamily.Section) ?? throw new InvalidOperationException("Template has no section view type.");
                var box = new BoundingBoxXYZ { Min = new XYZ(-2, -2, -1), Max = new XYZ(42, 44, 6) };
                var section = ViewSection.CreateSection(doc, type.Id, box); section.Name = "Integrated 60 in stair section — disposable"; sectionCount = 1; tx.Commit();
            }
            if (stairRuns.Count != 2 || stairRuns.Any(x => (int)x.GetType().GetProperty("actual_risers")!.GetValue(x)! <= 0)) throw new InvalidOperationException("Integrated stair runs did not report positive risers.");
            string rvt = Path.Combine(output, "FH_Integrated_Stair_Section_Study.rvt"); doc.SaveAs(rvt, new SaveAsOptions());
            string ifcDir = Path.Combine(output, "ifc2x3"); Directory.CreateDirectory(ifcDir); bool ifcOk;
            using (var tx = new Transaction(doc, "Export integrated stair section IFC2x3")) { tx.Start(); var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; options.AddOption("ExportInternalRevitPropertySets", "true"); ifcOk = doc.Export(ifcDir, "FH_Integrated_Stair_Section_Study", options); tx.RollBack(); }
            if (!ifcOk) throw new InvalidOperationException("Integrated stair section IFC export returned false.");
            var manifest = new { schema = "forever-home-integrated-stair-section-v1", status = "disposable integrated stair/section study; basis B; not Selected-D", basis = "B", total_rise_in = 60.0, levels = 3, wall_count = wallCount, floor_count = floorCount, native_stair_count = 2, section_count = sectionCount, saved_rvt = Path.GetFileName(rvt), saved_rvt_sha256 = Hash(rvt), ifc = "ifc2x3/FH_Integrated_Stair_Section_Study.ifc", ifc2x3 = ifcOk, limitations = new[] { "The 60 in rise is an owner-authorized disposable comparison basis, not a final floor-to-floor datum.", "Landing, headroom, opening, route, assemblies, MEP, accessibility, code and construction conclusions remain unresolved.", "Selected-D and protected source files are untouched." } };
            File.WriteAllText(Path.Combine(output, "integrated-stair-section-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home", "Integrated stair/section study saved:\n" + rvt);
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); TaskDialog.Show("Integrated stair/section failed", ex.Message); return Result.Failed; }
    }

    sealed class IntegratedFailureRecorder : IFailuresPreprocessor
    {
        public FailureProcessingResult PreprocessFailures(FailuresAccessor accessor) { var failures = accessor.GetFailureMessages(); if (failures.Any(f => f.GetSeverity() == FailureSeverity.Error)) return FailureProcessingResult.ProceedWithRollBack; foreach (var failure in failures) accessor.DeleteWarning(failure); return FailureProcessingResult.Continue; }
    }
}
