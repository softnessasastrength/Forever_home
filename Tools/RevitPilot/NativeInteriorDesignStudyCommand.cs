using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Structure;
using Autodesk.Revit.UI;
using ForeverHome.Pilot.Core;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

/// <summary>
/// Builds a disposable interior-design comparison from source room blocks.
/// It is deliberately not a Selected-D edit or a construction assembly.
/// </summary>
[Transaction(TransactionMode.Manual)]
public sealed class NativeInteriorDesignStudyCommand : IExternalCommand
{
    private const string InputRelative = "Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts/main-floor-candidate-input.json";
    private const string SelectedRelative = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";
    private const string SelectedSha256 = "516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb";
    private static double Ft(double inches) => inches / 12.0;
    private static void Tag(Element e, string text) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(text);
    private static double N(JsonElement e, string key) => e.GetProperty(key).GetDouble();

    private static void AddRectWalls(Document doc, WallType type, Level level, double ox, double oy, double w, double d, double h, string tag, List<Wall> walls)
    {
        var pts = new[] { new XYZ(ox, oy, 0), new XYZ(ox + w, oy, 0), new XYZ(ox + w, oy + d, 0), new XYZ(ox, oy + d, 0) };
        for (int i = 0; i < 4; i++)
        {
            var wall = Wall.Create(doc, Line.CreateBound(pts[i], pts[(i + 1) % 4]), type.Id, level.Id, h, 0, false, false);
            WallUtils.DisallowWallJoinAtEnd(wall, 0); WallUtils.DisallowWallJoinAtEnd(wall, 1);
            Tag(wall, tag); walls.Add(wall);
        }
    }

    private static Floor AddFloor(Document doc, ElementId typeId, Level level, double ox, double oy, double w, double d, string tag)
    {
        var loop = new CurveLoop();
        var p = new[] { new XYZ(ox, oy, 0), new XYZ(ox + w, oy, 0), new XYZ(ox + w, oy + d, 0), new XYZ(ox, oy + d, 0) };
        for (int i = 0; i < 4; i++) loop.Append(Line.CreateBound(p[i], p[(i + 1) % 4]));
        var floor = Floor.Create(doc, new List<CurveLoop> { loop }, typeId, level.Id);
        Tag(floor, tag); return floor;
    }

    private static DirectShape AddBox(Document doc, double ox, double oy, double w, double d, double h, string tag)
    {
        var box = DirectShape.CreateElement(doc, new ElementId(BuiltInCategory.OST_GenericModel));
        var loop = new CurveLoop();
        var p = new[] { new XYZ(ox, oy, 0), new XYZ(ox + w, oy, 0), new XYZ(ox + w, oy + d, 0), new XYZ(ox, oy + d, 0) };
        for (int i = 0; i < 4; i++) loop.Append(Line.CreateBound(p[i], p[(i + 1) % 4]));
        box.SetShape(new GeometryObject[] { GeometryCreationUtilities.CreateExtrusionGeometry(new[] { loop }, XYZ.BasisZ, h) });
        Tag(box, tag); return box;
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string inputPath = Path.Combine(root, InputRelative.Replace('/', Path.DirectorySeparatorChar));
            string selectedPath = Path.Combine(root, SelectedRelative.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(inputPath) || !File.Exists(selectedPath)) throw new FileNotFoundException("Interior-study source is missing.");
            string selectedHash = StudyArtifactContract.Sha256File(selectedPath);
            if (!selectedHash.Equals(SelectedSha256, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Selected-D changed.");
            using var json = JsonDocument.Parse(File.ReadAllText(inputPath));
            var input = json.RootElement;
            foreach (var pin in input.GetProperty("source_sha256").EnumerateObject())
            {
                string path = Path.Combine(root, pin.Name.Replace('/', Path.DirectorySeparatorChar));
                if (!StudyArtifactContract.Sha256File(path).Equals(pin.Value.GetString(), StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Interior-study lineage mismatch: " + pin.Name);
            }
            string output = Path.Combine(root, ".local", "revit-pilot", "interior-design-study", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            int wallCount = 0, floorCount = 0, islandCount = 0, bathVignettes = 0;
            var cases = new List<object>();
            using (var tx = new Transaction(doc, "Build disposable interior design study"))
            {
                tx.Start();
                var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).First();
                level.Name = "Interior design study — main floor comparison";
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().Where(x => x.Kind == WallKind.Basic).OrderBy(x => x.Name, StringComparer.Ordinal).First();
                var floorTypeId = Floor.GetDefaultFloorType(doc, false);
                if (floorTypeId == ElementId.InvalidElementId) throw new InvalidOperationException("No default floor type.");
                var rooms = input.GetProperty("room_blocks").EnumerateArray().ToArray();
                foreach (var ceiling in new[] { 8.0, 9.0, 10.0 })
                {
                    double offset = (ceiling - 8.0) * 48.0;
                    var walls = new List<Wall>();
                    AddRectWalls(doc, wallType, level, offset, 0, 40, 42, ceiling, $"PROPOSAL; interior shell; {ceiling:0}-ft clear-height case; unselected", walls);
                    foreach (var room in rooms)
                    {
                        string id = room.GetProperty("id").GetString()!;
                        AddRectWalls(doc, wallType, level, offset + N(room, "x"), N(room, "y"), N(room, "w"), N(room, "d"), ceiling, $"PROPOSAL; source room block {id}; interior partition study; unselected", walls);
                    }
                    AddFloor(doc, floorTypeId, level, offset, 0, 40, 42, $"PROPOSAL; F-01 engineered-oak display cue; {ceiling:0}-ft case; assembly unselected");
                    floorCount++;
                    var kitchen = rooms.Single(r => r.GetProperty("id").GetString() == "M-02");
                    double islandX = offset + N(kitchen, "x") + (N(kitchen, "w") - 8.0) / 2.0;
                    double islandY = N(kitchen, "y") + (N(kitchen, "d") - 4.0) / 2.0;
                    AddBox(doc, islandX, islandY, 8.0, 4.0, Ft(36), $"PROPOSAL; M-02 kitchen island; 8 x 4 ft; appliance-free; unselected");
                    islandCount++;
                    AddBox(doc, offset + 46.0, 0, 9.0, 10.0, Ft(1), $"PROPOSAL; U-05 primary-bath vignette; 9 x 10 ft source block; separate tub + tiled rain shower direction; not house placement");
                    bathVignettes++;
                    cases.Add(new { clear_ceiling_ft = ceiling, offset_ft = offset, wall_count = walls.Count, floor_count = 1, kitchen_island_count = 1, primary_bath_vignette_count = 1, selected = false });
                    wallCount += walls.Count;
                }
                var vt = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(x => x.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, vt.Id); view.Name = "Interior design study — unselected comparison";
                tx.Commit();
            }
            if (wallCount != 72 || floorCount != 3 || islandCount != 3 || bathVignettes != 3) throw new InvalidDataException($"Interior-study inventory mismatch walls={wallCount}, floors={floorCount}, islands={islandCount}, baths={bathVignettes}");
            string rvt = Path.Combine(output, "FH_Interior_Design_Study.rvt");
            string ifc = Path.Combine(output, "FH_Interior_Design_Study.ifc");
            doc.SaveAs(rvt, new SaveAsOptions { OverwriteExistingFile = true });
            bool ifcOk;
            using (var export = new Transaction(doc, "Export interior design study IFC2x3"))
            {
                export.Start();
                try { using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; ifcOk = doc.Export(output, Path.GetFileNameWithoutExtension(ifc), options); }
                finally { if (export.GetStatus() == TransactionStatus.Started) export.RollBack(); }
            }
            doc.Close(false); doc = null;
            var manifest = new { schema = "forever-home-interior-design-study-v1", status = "disposable interior coordination comparison; not Selected-D", selected_d_sha256 = selectedHash, input_sha256 = StudyArtifactContract.Sha256File(inputPath), cases, wall_count = wallCount, floor_count = floorCount, kitchen_island_count = islandCount, primary_bath_vignette_count = bathVignettes, saved_rvt = Path.GetFileName(rvt), saved_rvt_sha256 = StudyArtifactContract.Sha256File(rvt), ifc = Path.GetFileName(ifc), ifc_sha256 = StudyArtifactContract.Sha256File(ifc), ifc2x3 = ifcOk, limitations = new[] { "Room-block partitions and island are disposable design coordination geometry.", "U-05 bath is a labelled vignette, not a selected location or fixture layout.", "Wall/floor assemblies, openings, stair, roof, structure, MEP, code, accessibility and construction conclusions remain unresolved.", "Selected-D and M-06/B assignment are untouched." } };
            StudyArtifactContract.WriteJson(Path.Combine(output, "interior-design-study-manifest.json"), manifest);
            TaskDialog.Show("Forever Home interior study", $"Disposable interior study saved:\n{output}");
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); if (doc is not null && doc.IsValidObject) doc.Close(false); return Result.Failed; }
    }
}
