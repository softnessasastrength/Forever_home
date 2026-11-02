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
public sealed class NativeDocumentedOpeningAssemblyCommand : IExternalCommand
{
    private sealed record DoorCase(string Id, double PantryWidthFt, string PantryBasis, double OffsetX);
    private static string HashFile(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    private static void Tag(Element e, string value) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(value);

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string output = Path.Combine(root, ".local", "revit-pilot", "documented-opening-assembly", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            string schedulePath = Path.Combine(root, "Architecture", "Material_Schedule.md");
            string schematicPath = Path.Combine(root, "Architecture", "Main_Floor_Schematic.md");
            var cases = new[]
            {
                new DoorCase("documented-baseline", 2.5, "D-03 documented nominal 2'-6\" pantry door", 0),
                new DoorCase("pantry-wider-comparison", 3.0, "owner-authorized wider pantry comparison; D-04 preferred range", 60)
            };
            Document doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var french = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_ASM_D01_French_5ft", 5.0, 0.15, 6.6666666667);
            var exterior = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_ASM_D02_Exterior_3ft", 3.0, 0.15, 6.6666666667);
            var interior = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_ASM_D03_D04_Pantry", 3.0, 0.15, 6.6666666667);
            var rows = new List<Dictionary<string, object?>>();
            using (var tx = new Transaction(doc, "Create documented opening assembly comparison"))
            {
                tx.Start();
                var level = Level.Create(doc, 0);
                level.Name = "Documented opening assembly datum - walls and floors remain provisional";
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().First(w => w.Kind == WallKind.Basic);
                foreach (var symbol in new[] { french, exterior, interior }) if (!symbol.IsActive) symbol.Activate();
                doc.Regenerate();
                foreach (var c in cases)
                {
                    var walls = new List<Wall>();
                    Wall AddWall(double x1, double y1, double x2, double y2, string marker)
                    {
                        var wall = Wall.Create(doc, Line.CreateBound(new XYZ(c.OffsetX + x1, y1, 0), new XYZ(c.OffsetX + x2, y2, 0)), wallType.Id, level.Id, 10.0, 0, false, false);
                        Tag(wall, $"PROPOSAL; documented opening assembly; {c.Id}; {marker}; wall type provisional");
                        walls.Add(wall);
                        return wall;
                    }
                    // The documented nominal widths are represented as real wall gaps; door families are hosted at those gaps.
                    AddWall(0, 0, 18, 0, "D-04 front 36-in opening jamb"); AddWall(22, 0, 40, 0, "D-04 front 36-in opening jamb");
                    var frontHost = AddWall(18, 0, 22, 0, "D-04 front 36-in host segment");
                    AddWall(0, 42, 17, 42, "D-01 rear French 5-ft opening jamb"); AddWall(23, 42, 40, 42, "D-01 rear French 5-ft opening jamb");
                    var rearHost = AddWall(17, 42, 23, 42, "D-01 rear French 5-ft host segment");
                    AddWall(0, 42, 0, 44, "D-02 porch 3-ft opening jamb"); AddWall(0, 49, 0, 52, "D-02 porch 3-ft opening jamb");
                    var porchHost = AddWall(0, 44, 0, 49, "D-02 porch 3-ft host segment");
                    AddWall(40, 0, 40, 42, "side shell"); AddWall(0, 0, 0, 42, "side shell");
                    double half = c.PantryWidthFt / 2.0;
                    double hostHalf = half + 0.5;
                    AddWall(24, 10, 24, 13.5 - hostHalf, "pantry jamb"); AddWall(24, 13.5 + hostHalf, 24, 30, "pantry jamb");
                    var pantryHost = AddWall(24, 13.5 - hostHalf, 24, 13.5 + hostHalf, "pantry host segment");
                    AddWall(24, 10, 30, 10, "pantry return"); AddWall(30, 10, 30, 17, "pantry return");
                    var records = new List<Dictionary<string, object?>>();
                    var entry = doc.Create.NewFamilyInstance(new XYZ(c.OffsetX + 20, 0, 0), exterior, frontHost, level, StructuralType.NonStructural);
                    Tag(entry, "D-04; documented nominal 36-in opening assembly; clear opening and frame unresolved");
                    records.Add(new() { ["id"] = "D-04", ["nominal_width_ft"] = 3.0, ["selected"] = false, ["opening_modeled"] = true });
                    var rear = doc.Create.NewFamilyInstance(new XYZ(c.OffsetX + 20, 42, 0), french, rearHost, level, StructuralType.NonStructural);
                    Tag(rear, "D-01; documented nominal 5-ft French pair opening assembly; 6-ft option not selected");
                    records.Add(new() { ["id"] = "D-01", ["nominal_width_ft"] = 5.0, ["selected"] = false, ["opening_modeled"] = true });
                    var porch = doc.Create.NewFamilyInstance(new XYZ(c.OffsetX, 46.5, 0), exterior, porchHost, level, StructuralType.NonStructural);
                    Tag(porch, "D-02; documented nominal 3-ft porch exterior opening assembly; threshold unresolved");
                    records.Add(new() { ["id"] = "D-02", ["nominal_width_ft"] = 3.0, ["selected"] = false, ["opening_modeled"] = true });
                    var pantry = doc.Create.NewFamilyInstance(new XYZ(c.OffsetX + 24, 13.5, 0), interior, pantryHost, level, StructuralType.NonStructural);
                    Tag(pantry, c.PantryWidthFt == 2.5 ? "D-03; documented nominal 30-in pantry opening assembly" : "D-04 comparison; documented nominal 36-in pantry opening assembly");
                    records.Add(new() { ["id"] = c.PantryWidthFt == 2.5 ? "D-03" : "D-04-comparison", ["nominal_width_ft"] = c.PantryWidthFt, ["selected"] = false, ["opening_modeled"] = true });
                    rows.Add(new() { ["case_id"] = c.Id, ["pantry_width_ft"] = c.PantryWidthFt, ["pantry_basis"] = c.PantryBasis, ["wall_count"] = walls.Count, ["door_count"] = records.Count, ["opening_count"] = records.Count, ["door_records"] = records, ["selected"] = false });
                }
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id); view.Name = "Documented opening assembly comparison - proposal only";
                tx.Commit();
            }
            string rvtName = "FH_Documented_Opening_Assembly_Comparison.rvt";
            string ifcName = "FH_Documented_Opening_Assembly_Comparison.ifc";
            string rvtPath = Path.Combine(output, rvtName); string ifcPath = Path.Combine(output, ifcName);
            doc.SaveAs(rvtPath, new SaveAsOptions { OverwriteExistingFile = true });
            bool ifcOk;
            using (var exportTx = new Transaction(doc, "Export documented opening assembly IFC2x3"))
            {
                exportTx.Start();
                try { using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; options.AddOption("ExportInternalRevitPropertySets", "true"); ifcOk = doc.Export(output, Path.GetFileNameWithoutExtension(ifcName), options); }
                finally { if (exportTx.GetStatus() == TransactionStatus.Started) exportTx.RollBack(); }
            }
            if (!ifcOk) throw new InvalidOperationException("Revit IFC export returned false.");
            doc.Close(false);
            var manifest = new
            {
                schema = "forever-home-documented-opening-assembly-v1",
                status = "disposable documented opening assembly comparison; not selected-D",
                source_files = new[] { new { path = "Architecture/Material_Schedule.md", sha256 = HashFile(schedulePath) }, new { path = "Architecture/Main_Floor_Schematic.md", sha256 = HashFile(schematicPath) } },
                cases = rows.Select(row => { row["saved_rvt"] = rvtName; row["saved_rvt_sha256"] = HashFile(rvtPath); row["ifc"] = ifcName; row["ifc_sha256"] = HashFile(ifcPath); row["ifc2x3"] = File.ReadAllText(ifcPath).Contains("FILE_SCHEMA(('IFC2X3'))", StringComparison.Ordinal); row["status"] = "disposable documented opening assembly comparison; not selected-D"; return row; }).ToArray(),
                limitations = new[] { "Nominal door families and real wall gaps are source-backed comparison geometry, not selected products or assemblies.", "Wall type and floor remain provisional; actual frame, swing, threshold, clear width, weathering, structure, MEP, code, accessibility, professional, permit and construction conclusions remain unresolved." }
            };
            File.WriteAllText(Path.Combine(output, "documented-opening-assembly-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home documented opening assembly", $"Disposable opening assembly comparison saved:\n{output}");
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); return Result.Failed; }
    }
}
