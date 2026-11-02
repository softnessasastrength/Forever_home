using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeFinishCueStudyCommand : IExternalCommand
{
    private const string MaterialName = "FH-F-01-EngHardwood-OakWarm - DISPLAY ONLY - owner-selected finish direction";
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    private static void Tag(Element e, string value) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(value);

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string output = Path.Combine(root, ".local", "revit-pilot", "finish-cue-study", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            int floorCount = 0;
            using (var tx = new Transaction(doc, "Build F-01 engineered oak finish cue"))
            {
                tx.Start();
                var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(l => l.Elevation).First();
                level.Name = "F-01 finish cue local datum - unselected comparison";
                Tag(level, "FH-F-01-DATUM | DISPLAY ONLY | not a building elevation");
                var materialId = Material.Create(doc, MaterialName);
                var material = (Material)doc.GetElement(materialId)!;
                material.Color = new Color(181, 145, 91);
                var floorType = new FilteredElementCollector(doc).OfClass(typeof(FloorType)).Cast<FloorType>().First();
                var cueType = floorType.Duplicate("FH-F-01 Engineered Oak Display Floor") as FloorType ?? throw new InvalidOperationException("Could not duplicate a floor type.");
                var structure = cueType.GetCompoundStructure();
                if (structure is null || structure.LayerCount == 0) throw new InvalidOperationException("Template floor type has no editable compound layer.");
                structure.SetMaterialId(0, materialId);
                cueType.SetCompoundStructure(structure);
                var loop = new CurveLoop();
                XYZ[] p = { new(0, 0, 0), new(40, 0, 0), new(40, 42, 0), new(0, 42, 0) };
                for (int i = 0; i < p.Length; i++) loop.Append(Line.CreateBound(p[i], p[(i + 1) % p.Length]));
                var floor = Floor.Create(doc, new List<CurveLoop> { loop }, cueType.Id, level.Id);
                Tag(floor, "FH-F-01 | ENGINEERED OAK | DISPLAY CUE ONLY | owner-selected finish direction; assembly unresolved");
                floorCount++;
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id);
                view.Name = "F-01 engineered oak finish cue - unselected comparison";
                tx.Commit();
            }
            if (floorCount != 1) throw new InvalidDataException("Expected one F-01 display floor.");
            string rvtName = "FH_F01_Engineered_Oak_Finish_Cue.rvt", ifcName = "FH_F01_Engineered_Oak_Finish_Cue.ifc";
            string rvtPath = Path.Combine(output, rvtName), ifcPath = Path.Combine(output, ifcName);
            doc.SaveAs(rvtPath, new SaveAsOptions { OverwriteExistingFile = true });
            bool ifcOk;
            using (var tx = new Transaction(doc, "Export F-01 finish cue IFC2x3"))
            {
                tx.Start();
                try { using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; ifcOk = doc.Export(output, Path.GetFileNameWithoutExtension(ifcName), options); }
                finally { if (tx.GetStatus() == TransactionStatus.Started) tx.RollBack(); }
            }
            if (!ifcOk) throw new InvalidOperationException("Revit IFC export returned false.");
            doc.Close(false); doc = null;
            var manifest = new { schema = "forever-home-f01-finish-cue-v1", status = "disposable finish cue; not a selected floor assembly", material = MaterialName, floor_count = floorCount, material_selected = true, assembly_selected = false, saved_rvt = rvtName, saved_rvt_sha256 = Hash(rvtPath), ifc = ifcName, ifc_sha256 = Hash(ifcPath), ifc2x3 = File.ReadAllText(ifcPath).Contains("FILE_SCHEMA(('IFC2X3'))", StringComparison.Ordinal), limitations = new[] { "F-01 engineered oak is an owner-approved finish direction only.", "Product, plank, wear layer, substrate, thickness, installation, structure, acoustics, moisture and code performance are unresolved.", "Selected-D is untouched; this derivative is not a construction or compliance model." } };
            File.WriteAllText(Path.Combine(output, "f01-finish-cue-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home F-01 finish cue", $"Disposable engineered-oak finish cue saved:\n{output}");
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); if (doc is not null && doc.IsValidObject) doc.Close(false); return Result.Failed; }
    }
}
