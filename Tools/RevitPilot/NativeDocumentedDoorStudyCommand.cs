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
public sealed class NativeDocumentedDoorStudyCommand : IExternalCommand
{
    private sealed record DoorCase(string Id, double PantryWidthFt, string PantryBasis, double OffsetX);
    private static string HashFile(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    private static void Tag(Element e, string value) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(value);

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        try
        {
            var workspace = new DirectoryInfo(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!);
            while (workspace is not null && !(Directory.Exists(Path.Combine(workspace.FullName, "Project")) && Directory.Exists(Path.Combine(workspace.FullName, "Tools")))) workspace = workspace.Parent;
            if (workspace is null) throw new DirectoryNotFoundException("Forever_home workspace not found from the loaded project-local assembly.");
            string root = workspace.FullName;
            string output = Path.Combine(root, ".local", "revit-pilot", "documented-door-study", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            string schedulePath = Path.Combine(root, "Architecture", "Material_Schedule.md");
            string schematicPath = Path.Combine(root, "Architecture", "Main_Floor_Schematic.md");
            var cases = new[] { new DoorCase("documented-baseline", 2.5, "D-03 documented nominal 2'-6\" pantry door", 0), new DoorCase("pantry-wider-comparison", 3.0, "owner-authorized wider pantry comparison; D-04 preferred range", 60) };
            Document doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var fiveFoot = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_D01_Nominal_French_5ft", 5.0, 0.15, 6.6666666667);
            var threeFoot = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_D02_Nominal_Exterior_3ft", 3.0, 0.15, 6.6666666667);
            var pantryDoor = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_D03_D04_Nominal_Pantry", 3.0, 0.15, 6.6666666667);
            var rows = new List<object>();
            using (var tx = new Transaction(doc, "Create documented nominal door comparison study"))
            {
                tx.Start();
                var level = Level.Create(doc, 0);
                level.Name = "Door study datum - vertical assemblies unresolved";
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().First(w => w.Kind == WallKind.Basic);
                if (!fiveFoot.IsActive) fiveFoot.Activate();
                if (!threeFoot.IsActive) threeFoot.Activate();
                if (!pantryDoor.IsActive) pantryDoor.Activate();
                doc.Regenerate();
                foreach (var c in cases)
                {
                    var walls = new List<Wall>();
                    Wall AddWall(double x1, double y1, double x2, double y2, string marker)
                    {
                        var wall = Wall.Create(doc, Line.CreateBound(new XYZ(c.OffsetX + x1, y1, 0), new XYZ(c.OffsetX + x2, y2, 0)), wallType.Id, level.Id, 10.0, 0, false, false);
                        Tag(wall, $"PROPOSAL; host wall only; {c.Id}; {marker}; wall assembly unselected");
                        walls.Add(wall);
                        return wall;
                    }
                    AddWall(0, 0, 40, 0, "front-entry D-04 36-in preferred proxy");
                    AddWall(0, 42, 40, 42, "rear dining D-01 French pair nominal 5-ft");
                    AddWall(0, 42, 0, 52, "porch D-02 exterior nominal 3-ft");
                    AddWall(40, 0, 40, 42, "side shell");
                    AddWall(0, 0, 0, 42, "side shell");
                    AddWall(24, 10, 24, 30, "pantry host D-03/D-04 comparison");
                    AddWall(24, 10, 30, 10, "pantry host return");
                    AddWall(30, 10, 30, 17, "pantry host return");
                    var entry = doc.Create.NewFamilyInstance(new XYZ(c.OffsetX + 18.5, 0, 0), threeFoot, walls[0], level, StructuralType.NonStructural);
                    Tag(entry, "D-04; nominal 36-in preferred critical interior/front route proxy; clear opening unresolved");
                    var french = doc.Create.NewFamilyInstance(new XYZ(c.OffsetX + 20, 42, 0), fiveFoot, walls[1], level, StructuralType.NonStructural);
                    Tag(french, "D-01; nominal 5-ft French pair; 6-ft option not selected; clear leaf unresolved");
                    var exterior = doc.Create.NewFamilyInstance(new XYZ(c.OffsetX, 47, 0), threeFoot, walls[2], level, StructuralType.NonStructural);
                    Tag(exterior, "D-02; nominal 3-ft porch exterior door; screen/threshold unresolved");
                    var pantry = doc.Create.NewFamilyInstance(new XYZ(c.OffsetX + 24, 13.5, 0), pantryDoor, walls[5], level, StructuralType.NonStructural);
                    Tag(pantry, c.PantryWidthFt == 2.5 ? "D-03; nominal 30-in pantry comparison; family proxy is 36-in envelope; clear opening unresolved" : "D-04 comparison; nominal 36-in pantry option; clear opening unresolved");
                    rows.Add(new
                    {
                        case_id = c.Id,
                        pantry_width_ft = c.PantryWidthFt,
                        pantry_basis = c.PantryBasis,
                        wall_count = walls.Count,
                        door_count = 4,
                        selected = false,
                        door_records = new[]
                        {
                            new { id = "D-04", nominal_width_ft = 3.0, selected = false, basis = "36-in preferred critical interior/front route proxy" },
                            new { id = "D-01", nominal_width_ft = 5.0, selected = false, basis = "5-ft French pair nominal" },
                            new { id = "D-02", nominal_width_ft = 3.0, selected = false, basis = "3-ft porch exterior nominal" },
                            new { id = c.PantryWidthFt == 2.5 ? "D-03" : "D-04-comparison", nominal_width_ft = c.PantryWidthFt, selected = false, basis = c.PantryBasis }
                        }
                    });
                }
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id);
                view.Name = "Documented doors comparison - proposal only";
                tx.Commit();
            }
            string rvtName = "FH_Documented_Door_Study_comparison.rvt";
            string ifcName = "FH_Documented_Door_Study_comparison.ifc";
            string rvtPath = Path.Combine(output, rvtName);
            string ifcPath = Path.Combine(output, ifcName);
            doc.SaveAs(rvtPath, new SaveAsOptions { OverwriteExistingFile = true });
            bool ifcOk;
            using (var exportTx = new Transaction(doc, "Export documented nominal door comparison IFC2x3"))
            {
                exportTx.Start();
                try
                {
                    using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true };
                    options.AddOption("ExportInternalRevitPropertySets", "true");
                    ifcOk = doc.Export(output, Path.GetFileNameWithoutExtension(ifcName), options);
                }
                finally { if (exportTx.GetStatus() == TransactionStatus.Started) exportTx.RollBack(); }
            }
            if (!ifcOk) throw new InvalidOperationException("Revit IFC export returned false.");
            // Release Revit's document handles before hashing the saved artifacts. Revit quite reasonably
            // refuses to let us read a file it still has open; software that locks its own evidence is a
            // particularly uninspiring form of quality assurance.
            doc.Close(false);
            var manifest = new
            {
                schema = "forever-home-documented-door-study-v1",
                status = "disposable nominal door-family comparison; not selected-D",
                source_files = new[] { new { path = "Architecture/Material_Schedule.md", sha256 = HashFile(schedulePath) }, new { path = "Architecture/Main_Floor_Schematic.md", sha256 = HashFile(schematicPath) } },
                cases = rows.Select(row => {
                    var props = row.GetType().GetProperties().ToDictionary(p => p.Name, p => p.GetValue(row));
                    props["saved_rvt"] = rvtName;
                    props["saved_rvt_sha256"] = HashFile(rvtPath);
                    props["ifc"] = ifcName;
                    props["ifc_sha256"] = HashFile(ifcPath);
                    props["ifc2x3"] = File.ReadAllText(ifcPath).Contains("FILE_SCHEMA(('IFC2X3'))", StringComparison.Ordinal);
                    props["status"] = "disposable nominal door-family comparison; not selected-D";
                    return props;
                }).ToArray(),
                limitations = new[] { "Door families are generic nominal solids created in a disposable document; they are not product selections.", "The comparison uses one disposable RVT with two spatially separated cases; host walls remain continuous for family hosting; actual wall openings, frame, swing, threshold and clear width are unresolved.", "No floor-to-floor, wall assembly, code, accessibility, structural, professional, permit or construction conclusion follows." }
            };
            File.WriteAllText(Path.Combine(output, "documented-door-study-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home documented door study", $"Disposable nominal door comparison saved:\n{output}");
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); return Result.Failed; }
    }
}
