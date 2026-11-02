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
public sealed class NativeIntegratedMainFloorAssemblyCommand : IExternalCommand
{
    private const string Input = "Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts/main-floor-candidate-input.json";
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    private static double N(JsonElement e, string key) => e.GetProperty(key).GetDouble();
    private static void Tag(Element e, string value) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(value);

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string source = Path.Combine(root, Input);
            using var json = JsonDocument.Parse(File.ReadAllText(source));
            var input = json.RootElement;
            foreach (var pin in input.GetProperty("source_sha256").EnumerateObject())
            {
                string path = Path.GetFullPath(Path.Combine(root, pin.Name));
                if (!path.StartsWith(root + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase) || !Hash(path).Equals(pin.Value.GetString(), StringComparison.OrdinalIgnoreCase))
                    throw new InvalidDataException("Candidate source fingerprint mismatch: " + pin.Name);
            }
            if (input.GetProperty("candidate").GetInt32() != 21) throw new InvalidDataException("Unreviewed candidate");
            var rooms = input.GetProperty("room_blocks").EnumerateArray().ToArray();
            var entry = rooms.Single(r => r.GetProperty("id").GetString() == "M-05");
            var pantry = rooms.Single(r => r.GetProperty("id").GetString() == "M-04");
            var porch = input.GetProperty("porch");
            double routeWidth = N(input, "route_width_ft");
            double front = N(entry, "x") + N(entry, "w") / 2.0;
            double half = routeWidth / 2.0;
            var rearDoor = input.GetProperty("porch_nominal_door_reservation_ft");
            double rearLeft = rearDoor[0].GetDouble(), rearRight = rearDoor[1].GetDouble();
            double pantryCentre = input.GetProperty("pantry_spur").GetProperty("to_pantry_ft")[1].GetDouble();
            string output = Path.Combine(root, ".local", "revit-pilot", "integrated-main-floor-assembly", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var d01 = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_INT_D01_French_5ft", 5.0, 0.15, 6.6666667);
            var d02 = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_INT_D02_Exterior_3ft", 3.0, 0.15, 6.6666667);
            var d03 = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_INT_D03_Pantry_30in", 2.5, 0.15, 6.6666667);
            var records = new List<Dictionary<string, object?>>();
            int wallCount = 0, doorCount = 0;
            using (var tx = new Transaction(doc, "Build integrated main-floor assembly comparison"))
            {
                tx.Start();
                var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().First();
                level.Name = "Integrated main-floor local datum - unselected comparison";
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().Where(w => w.Kind == WallKind.Basic).OrderBy(w => w.Name, StringComparer.Ordinal).First();
                foreach (var symbol in new[] { d01, d02, d03 }) if (!symbol.IsActive) symbol.Activate();
                doc.Regenerate();
                for (int caseIndex = 0; caseIndex < 3; caseIndex++)
                {
                    double height = 8.0 + caseIndex, offset = caseIndex * 60.0;
                    var caseDoors = new List<Dictionary<string, object?>>();
                    Wall AddWall(double x1, double y1, double x2, double y2, string label)
                    {
                        var wall = Wall.Create(doc, Line.CreateBound(new XYZ(offset + x1, y1, 0), new XYZ(offset + x2, y2, 0)), wallType.Id, level.Id, height, 0, false, false);
                        WallUtils.DisallowWallJoinAtEnd(wall, 0); WallUtils.DisallowWallJoinAtEnd(wall, 1);
                        Tag(wall, $"PROPOSAL; integrated main-floor assembly; height={height:0.#}ft; {label}; unselected"); wallCount++; return wall;
                    }
                    void AddDoor(string id, FamilySymbol symbol, double x, double y, Wall host, double width)
                    {
                        var instance = doc.Create.NewFamilyInstance(new XYZ(offset + x, y, 0), symbol, host, level, StructuralType.NonStructural);
                        Tag(instance, $"{id}; documented nominal opening; integrated comparison only; unselected");
                        caseDoors.Add(new() { ["id"] = id, ["nominal_width_ft"] = width, ["selected"] = false, ["opening_modeled"] = true, ["element_id"] = instance.Id.Value }); doorCount++;
                    }
                    AddWall(0, 0, front - half - 0.5, 0, "front route west jamb");
                    var frontHost = AddWall(front - half - 0.5, 0, front + half + 0.5, 0, "D-04 front host");
                    AddWall(front + half + 0.5, 0, 40, 0, "front route east jamb");
                    AddDoor("D-04", d02, front, 0, frontHost, 3.0);
                    AddWall(40, 0, 40, 42, "main east");
                    AddWall(0, 42, rearLeft - 0.5, 42, "rear French west jamb");
                    var rearHost = AddWall(rearLeft - 0.5, 42, rearRight + 0.5, 42, "D-01 French host");
                    AddWall(rearRight + 0.5, 42, 40, 42, "rear French east jamb");
                    AddDoor("D-01", d01, (rearLeft + rearRight) / 2.0, 42, rearHost, 5.0);
                    AddWall(0, 0, 0, 42, "main west");
                    double px = N(porch, "X"), py = N(porch, "Y"), pw = N(porch, "W"), pd = N(porch, "D");
                    AddWall(px, py, px, py + pd, "porch west"); AddWall(px + pw, py + pd, px + pw, py, "porch east");
                    var porchWest = AddWall(px, py + pd, px + 5.5, py + pd, "porch north west jamb");
                    var porchHost = AddWall(px + 5.5, py + pd, px + 8.5, py + pd, "D-02 porch host");
                    AddWall(px + 8.5, py + pd, px + pw, py + pd, "porch north east jamb");
                    AddDoor("D-02", d02, px + 7.0, py + pd, porchHost, 3.0);
                    double x = N(pantry, "x"), y = N(pantry, "y"), w = N(pantry, "w"), d = N(pantry, "d"), pantryHalf = 1.25, hostHalf = pantryHalf + 0.5;
                    AddWall(x, y, x + w, y, "pantry south"); AddWall(x + w, y, x + w, y + d, "pantry east"); AddWall(x + w, y + d, x, y + d, "pantry north");
                    AddWall(x, y + d, x, pantryCentre - hostHalf, "pantry west lower jamb"); var pantryHost = AddWall(x, pantryCentre - hostHalf, x, pantryCentre + hostHalf, "D-03 pantry host"); AddWall(x, pantryCentre + hostHalf, x, y + d, "pantry west upper jamb");
                    AddDoor("D-03", d03, x, pantryCentre, pantryHost, 2.5);
                    records.Add(new() { ["height_ft"] = height, ["offset_ft"] = offset, ["wall_count"] = 19, ["door_count"] = caseDoors.Count, ["door_records"] = caseDoors, ["selected"] = false });
                }
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id); view.Name = "Integrated main-floor assembly comparison - unselected";
                tx.Commit();
            }
            if (wallCount != 57 || doorCount != 12) throw new InvalidDataException($"Integrated inventory mismatch: walls={wallCount}, doors={doorCount}");
            string rvtName = "FH_Integrated_Main_Floor_Assembly.rvt", ifcName = "FH_Integrated_Main_Floor_Assembly.ifc";
            string rvtPath = Path.Combine(output, rvtName), ifcPath = Path.Combine(output, ifcName);
            doc.SaveAs(rvtPath, new SaveAsOptions { OverwriteExistingFile = true });
            bool ifcOk;
            using (var exportTx = new Transaction(doc, "Export integrated main-floor assembly IFC2x3"))
            {
                exportTx.Start(); try { using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; options.AddOption("ExportInternalRevitPropertySets", "true"); ifcOk = doc.Export(output, Path.GetFileNameWithoutExtension(ifcName), options); } finally { if (exportTx.GetStatus() == TransactionStatus.Started) exportTx.RollBack(); }
            }
            if (!ifcOk) throw new InvalidOperationException("Revit IFC export returned false.");
            doc.Close(false); doc = null;
            var manifest = new { schema = "forever-home-integrated-main-floor-assembly-v1", status = "disposable integrated assembly comparison; not selected-D", input = Input, input_sha256 = Hash(source), cases = records, wall_count = wallCount, door_count = doorCount, saved_rvt = rvtName, saved_rvt_sha256 = Hash(rvtPath), ifc = ifcName, ifc_sha256 = Hash(ifcPath), ifc2x3 = File.ReadAllText(ifcPath).Contains("FILE_SCHEMA(('IFC2X3'))", StringComparison.Ordinal), limitations = new[] { "Candidate-21 shell and nominal D-01/D-02/D-03/D-04 openings are comparison geometry only.", "Wall type, floor, ceiling, frame, swing, threshold, clear width, route, structure, MEP, code, accessibility, professional, permit and construction conclusions remain unresolved." } };
            File.WriteAllText(Path.Combine(output, "integrated-main-floor-assembly-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home integrated assembly", $"Disposable integrated assembly saved:\n{output}"); return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); if (doc is not null && doc.IsValidObject) doc.Close(false); return Result.Failed; }
    }
}
