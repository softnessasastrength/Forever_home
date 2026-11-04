using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Structure;
using Autodesk.Revit.UI;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeCoordinatedPlaceholderStudyCommand : IExternalCommand
{
    private const string InputRelative = "Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts/main-floor-candidate-input.json";
    private const double WallPlaceholderWidthFt = 5.5 / 12.0;
    private const double FloorBuildUpFt = 1.5 / 12.0;
    private const double NominalOpeningFt = 3.0;

    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    private static void Tag(Element e, string value) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(value);

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string inputPath = Path.Combine(root, InputRelative.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(inputPath)) throw new FileNotFoundException("Pinned candidate input is missing.", inputPath);
            string inputHash = Hash(inputPath);
            using var source = JsonDocument.Parse(File.ReadAllText(inputPath));
            if (source.RootElement.GetProperty("candidate").GetInt32() != 21) throw new InvalidDataException("Unexpected candidate id.");

            string output = Path.Combine(root, ".local", "revit-pilot", "coordinated-placeholder-study", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var door = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_COORD_Door_36in", NominalOpeningFt, 0.15, 6.6666667);
            int wallCount = 0, floorCount = 0, doorCount = 0;
            using (var tx = new Transaction(doc, "Build coordinated documented placeholders"))
            {
                tx.Start();
                var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).First();
                level.Name = "Coordinated placeholder datum - unselected comparison";
                Tag(level, "FH-C-DATUM | coordination placeholder only | not a selected elevation");

                var baseWall = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().First(x => x.Kind == WallKind.Basic);
                var wallType = baseWall.Duplicate("FH-C-Wall-5.5in-NonStructural-Placeholder") as WallType ?? throw new InvalidOperationException("Could not duplicate wall type.");

                var baseFloor = new FilteredElementCollector(doc).OfClass(typeof(FloorType)).Cast<FloorType>().First();
                var floorType = baseFloor.Duplicate("FH-C-Floor-1.5in-Generic-Placeholder") as FloorType ?? throw new InvalidOperationException("Could not duplicate floor type.");

                Wall AddWall(double x1, double y1, double x2, double y2, string label)
                {
                    var wall = Wall.Create(doc, Line.CreateBound(new XYZ(x1, y1, 0), new XYZ(x2, y2, 0)), wallType.Id, level.Id, 10.0, 0, false, false);
                    Tag(wall, $"FH-C-WALL | {WallPlaceholderWidthFt * 12:0.0} in non-structural placeholder | {label} | unselected");
                    wallCount++;
                    return wall;
                }

                var floorLoop = new CurveLoop();
                XYZ[] floorPoints = { new(0, 0, 0), new(40, 0, 0), new(40, 42, 0), new(0, 42, 0) };
                for (int i = 0; i < floorPoints.Length; i++) floorLoop.Append(Line.CreateBound(floorPoints[i], floorPoints[(i + 1) % floorPoints.Length]));
                var floor = Floor.Create(doc, new[] { floorLoop }, floorType.Id, level.Id);
                Tag(floor, "FH-C-FLOOR | 1.5 in generic non-structural build-up placeholder | engineered oak finish cue separate | unselected");
                floorCount++;

                AddWall(0, 0, 18.5, 0, "front west jamb");
                var frontHost = AddWall(18.5, 0, 21.5, 0, "front 36-in nominal entry opening host");
                AddWall(21.5, 0, 40, 0, "front east jamb");
                AddWall(40, 0, 40, 42, "east perimeter");
                AddWall(0, 42, 6, 42, "rear west jamb");
                var porchHost = AddWall(6, 42, 9, 42, "rear 36-in nominal porch opening host");
                AddWall(9, 42, 40, 42, "rear east jamb");
                AddWall(0, 42, 0, 0, "west perimeter");
                AddWall(12, 10, 12, 17, "pantry lower jamb");
                var pantryHost = AddWall(12, 17, 12, 23, "pantry 36-in nominal opening host");
                AddWall(12, 23, 12, 30, "pantry upper jamb");
                if (!door.IsActive) door.Activate();
                doc.Regenerate();
                void AddDoor(FamilySymbol symbol, XYZ point, Wall host, string marker)
                {
                    var instance = doc.Create.NewFamilyInstance(point, symbol, host, level, StructuralType.NonStructural);
                    Tag(instance, $"FH-C-DOOR | 36 in nominal opening | {marker} | clear leaf unresolved | unselected");
                    doorCount++;
                }
                AddDoor(door, new XYZ(20, 0, 0), frontHost, "front entry");
                AddDoor(door, new XYZ(7.5, 42, 0), porchHost, "rear porch");
                AddDoor(door, new XYZ(12, 20, 0), pantryHost, "pantry");
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(x => x.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id);
                view.Name = "Coordinated documented placeholders - unselected comparison";
                tx.Commit();
            }
            if (wallCount != 11 || floorCount != 1 || doorCount != 3) throw new InvalidDataException($"Coordination inventory mismatch: walls={wallCount}, floors={floorCount}, doors={doorCount}");
            string rvtName = "FH_Coordinated_Documented_Placeholders.rvt", ifcName = "FH_Coordinated_Documented_Placeholders.ifc";
            string rvtPath = Path.Combine(output, rvtName), ifcPath = Path.Combine(output, ifcName);
            doc.SaveAs(rvtPath, new SaveAsOptions { OverwriteExistingFile = true });
            bool ifcOk;
            using (var exportTx = new Transaction(doc, "Export coordinated placeholders IFC2x3"))
            {
                exportTx.Start();
                try { using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; ifcOk = doc.Export(output, Path.GetFileNameWithoutExtension(ifcName), options); }
                finally { if (exportTx.GetStatus() == TransactionStatus.Started) exportTx.RollBack(); }
            }
            if (!ifcOk) throw new InvalidOperationException("Revit IFC export returned false.");
            doc.Close(false); doc = null;
            var manifest = new
            {
                schema = "forever-home-coordinated-placeholder-study-v1",
                status = "disposable documented coordination placeholders; not selected-D",
                input = InputRelative,
                input_sha256 = inputHash,
                wall_placeholder_width_in = 5.5,
                floor_build_up_in = 1.5,
                nominal_opening_width_in = NominalOpeningFt * 12.0,
                wall_count = wallCount,
                floor_count = floorCount,
                door_count = doorCount,
                selected = false,
                saved_rvt = rvtName,
                saved_rvt_sha256 = Hash(rvtPath),
                ifc = ifcName,
                ifc_sha256 = Hash(ifcPath),
                ifc2x3 = File.ReadAllText(ifcPath).Contains("FILE_SCHEMA(('IFC2X3'))", StringComparison.Ordinal),
                limitations = new[] { "5.5-in wall and 1.5-in floor build-up are recorded coordination dimensions; this disposable study retains template-native host type layer geometry rather than asserting a construction assembly.", "36-in openings are owner-approved nominal coordination placeholders only; no clear-leaf or threshold conclusion follows.", "No structural, finish, code, accessibility, MEP, professional, permit or construction conclusion follows.", "Selected-D and the Evolution RFA are untouched; M-06/B remain unassigned." }
            };
            File.WriteAllText(Path.Combine(output, "coordinated-placeholder-study-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home coordinated placeholders", $"Disposable coordination study saved:\n{output}");
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); if (doc is not null && doc.IsValidObject) doc.Close(false); return Result.Failed; }
    }
}
