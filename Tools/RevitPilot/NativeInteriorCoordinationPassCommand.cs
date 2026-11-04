using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using ForeverHome.Pilot.Core;
using System.IO;
using System.Reflection;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeInteriorCoordinationPassCommand : IExternalCommand
{
    private const string InputRelative = "Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts/main-floor-candidate-input.json";
    private const string SelectedRelative = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";
    private const string SelectedSha256 = "516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb";
    private static double Ft(double inches) => inches / 12.0;
    private static void Tag(Element e, string text) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(text);
    private static double N(JsonElement e, string key) => e.GetProperty(key).GetDouble();

    private static void RectWalls(Document doc, WallType type, Level level, double ox, double oy, double w, double d, double h, string tag, List<Wall> into)
    {
        var p = new[] { new XYZ(ox, oy, 0), new XYZ(ox + w, oy, 0), new XYZ(ox + w, oy + d, 0), new XYZ(ox, oy + d, 0) };
        for (int i = 0; i < 4; i++) { var wall = Wall.Create(doc, Line.CreateBound(p[i], p[(i + 1) % 4]), type.Id, level.Id, h, 0, false, false); WallUtils.DisallowWallJoinAtEnd(wall, 0); WallUtils.DisallowWallJoinAtEnd(wall, 1); Tag(wall, tag); into.Add(wall); }
    }

    private static DirectShape Box(Document doc, double ox, double oy, double w, double d, double h, string tag)
    {
        var ds = DirectShape.CreateElement(doc, new ElementId(BuiltInCategory.OST_GenericModel));
        var loop = new CurveLoop(); var p = new[] { new XYZ(ox, oy, 0), new XYZ(ox + w, oy, 0), new XYZ(ox + w, oy + d, 0), new XYZ(ox, oy + d, 0) };
        for (int i = 0; i < 4; i++) loop.Append(Line.CreateBound(p[i], p[(i + 1) % 4]));
        ds.SetShape(new GeometryObject[] { GeometryCreationUtilities.CreateExtrusionGeometry(new[] { loop }, XYZ.BasisZ, h) }); Tag(ds, tag); return ds;
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string inputPath = Path.Combine(root, InputRelative.Replace('/', Path.DirectorySeparatorChar));
            string selectedPath = Path.Combine(root, SelectedRelative.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(inputPath) || !File.Exists(selectedPath)) throw new FileNotFoundException("M379 source is missing.");
            string selectedHash = StudyArtifactContract.Sha256File(selectedPath);
            if (!selectedHash.Equals(SelectedSha256, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Selected-D changed.");
            using var json = JsonDocument.Parse(File.ReadAllText(inputPath));
            var input = json.RootElement;
            foreach (var pin in input.GetProperty("source_sha256").EnumerateObject()) { string p = Path.Combine(root, pin.Name.Replace('/', Path.DirectorySeparatorChar)); if (!StudyArtifactContract.Sha256File(p).Equals(pin.Value.GetString(), StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("M379 lineage mismatch: " + pin.Name); }
            string output = Path.Combine(root, ".local", "revit-pilot", "interior-coordination-pass", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ")); Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            int walls = 0;
            using (var tx = new Transaction(doc, "Build M379 interior coordination pass"))
            {
                tx.Start();
                var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).First(); level.Name = "M379 interior coordination — 9 ft baseline";
                var wt = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().Where(x => x.Kind == WallKind.Basic).OrderBy(x => x.Name, StringComparer.Ordinal).First();
                var floorType = Floor.GetDefaultFloorType(doc, false); if (floorType == ElementId.InvalidElementId) throw new InvalidOperationException("No default floor type.");
                var rooms = input.GetProperty("room_blocks").EnumerateArray().ToArray();
                var shell = new List<Wall>(); RectWalls(doc, wt, level, 0, 0, 40, 42, 9, "PROPOSAL; M379 9-ft baseline shell; unselected", shell); foreach (var room in rooms) RectWalls(doc, wt, level, N(room, "x"), N(room, "y"), N(room, "w"), N(room, "d"), 9, "PROPOSAL; M379 source room block; unselected", shell); walls = shell.Count;
                var floorLoop = new CurveLoop(); var fp = new[] { new XYZ(0, 0, 0), new XYZ(40, 0, 0), new XYZ(40, 42, 0), new XYZ(0, 42, 0) }; for (int i = 0; i < 4; i++) floorLoop.Append(Line.CreateBound(fp[i], fp[(i + 1) % 4])); var floor = Floor.Create(doc, new List<CurveLoop> { floorLoop }, floorType, level.Id); Tag(floor, "PROPOSAL; M379 F-01 engineered-oak display cue; 9-ft baseline; unselected");
                var kitchen = rooms.Single(r => r.GetProperty("id").GetString() == "M-02"); double kx = N(kitchen, "x"), ky = N(kitchen, "y"); Box(doc, kx + N(kitchen, "w") - 8.0 - 1.5, ky + (N(kitchen, "d") - 4.0) / 2.0, 8, 4, Ft(36), "PROPOSAL; M379 M-02 island biased toward dining/living connection; 8 x 4 ft; appliance-free; unselected");
                Box(doc, 46, 0, 9, 10, Ft(1), "PROPOSAL; M379 U-05 separate tub + tiled rain-shower vignette; not house placement");
                Box(doc, 34, 18, 4, 5, Ft(48), "PROPOSAL; M379 tucked stair reservation in circulation; geometry TBD; unselected");
                var vt = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(x => x.ViewFamily == ViewFamily.ThreeDimensional); var view = View3D.CreateIsometric(doc, vt.Id); view.Name = "M379 interior coordination — unselected"; tx.Commit();
            }
            if (walls != 24) throw new InvalidDataException("M379 wall inventory mismatch: " + walls);
            string rvt = Path.Combine(output, "FH_M379_Interior_Coordination.rvt"), ifc = Path.Combine(output, "FH_M379_Interior_Coordination.ifc"); doc.SaveAs(rvt, new SaveAsOptions { OverwriteExistingFile = true }); bool ifcOk; using (var export = new Transaction(doc, "Export M379 IFC2x3")) { export.Start(); try { using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; ifcOk = doc.Export(output, Path.GetFileNameWithoutExtension(ifc), options); } finally { if (export.GetStatus() == TransactionStatus.Started) export.RollBack(); } }
            doc.Close(false); doc = null;
            var manifest = new { schema = "forever-home-m379-interior-coordination-v1", status = "disposable 9-ft coordination pass; not Selected-D", selected_d_sha256 = selectedHash, input_sha256 = StudyArtifactContract.Sha256File(inputPath), baseline_clear_height_ft = 9, island_bias = "dining/living connection", primary_bath_direction = "separate tub + tiled rain shower", stair_direction = "tucked into circulation; geometry TBD", wall_count = walls, floor_count = 1, kitchen_island_count = 1, bath_vignette_count = 1, stair_reservation_count = 1, saved_rvt = Path.GetFileName(rvt), saved_rvt_sha256 = StudyArtifactContract.Sha256File(rvt), ifc = Path.GetFileName(ifc), ifc_sha256 = StudyArtifactContract.Sha256File(ifc), ifc2x3 = ifcOk, limitations = new[] { "All geometry is disposable coordination geometry.", "Stair is a reservation only; rise, run, headroom and code remain unresolved.", "Island bias is a design preference, not a circulation or accessibility finding.", "Selected-D, M-06/B and Evolution RFA are untouched." } };
            StudyArtifactContract.WriteJson(Path.Combine(output, "m379-interior-coordination-manifest.json"), manifest); TaskDialog.Show("Forever Home M379", $"Disposable coordination pass saved:\n{output}"); return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); if (doc is not null && doc.IsValidObject) doc.Close(false); return Result.Failed; }
    }
}
