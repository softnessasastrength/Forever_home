using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class MainFloorCandidateFloorPlateCommand : IExternalCommand
{
    const string RelativeRoot = ".local/revit-pilot/main-floor-candidate";

    static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string sourceRoot = Path.Combine(root, RelativeRoot);
            string run = Directory.GetDirectories(sourceRoot).OrderByDescending(Path.GetFileName, StringComparer.Ordinal).First();
            string sourceFile = Directory.GetFiles(run, "*.rvt", SearchOption.TopDirectoryOnly).Single();
            string sourceHash = Hash(sourceFile);
            using (JsonDocument manifest = JsonDocument.Parse(File.ReadAllText(Path.Combine(run, "manifest.json"))))
            {
                string expected = manifest.RootElement.GetProperty("saved_rvt_sha256").GetString()!;
                if (!sourceHash.Equals(expected, StringComparison.OrdinalIgnoreCase))
                    throw new InvalidDataException("Main-floor candidate source RVT hash mismatch.");
                if (manifest.RootElement.GetProperty("wall_count").GetInt32() != 42)
                    throw new InvalidDataException("Expected the 42-wall main-floor candidate before adding plates.");
            }

            string output = Path.Combine(root, ".local", "revit-pilot", "main-floor-floor-plate", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.OpenDocumentFile(sourceFile);
            var levels = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().ToArray();
            if (levels.Length != 1) throw new InvalidDataException("Expected one local-zero level.");
            Level level = levels[0];
            ElementId floorTypeId = Floor.GetDefaultFloorType(doc, false);
            if (floorTypeId == ElementId.InvalidElementId) throw new InvalidOperationException("The template has no default floor type.");
            FloorType floorType = (FloorType)doc.GetElement(floorTypeId)!;
            var floors = new List<object>();
            using (Transaction tx = new Transaction(doc, "Add provisional main-floor comparison plates"))
            {
                tx.Start();
                foreach (double offset in new[] { 0.0, 60.0, 120.0 })
                {
                    var loop = new CurveLoop();
                    XYZ[] points = { new(offset, 0, 0), new(offset + 40, 0, 0), new(offset + 40, 42, 0), new(offset, 42, 0) };
                    for (int i = 0; i < points.Length; i++) loop.Append(Line.CreateBound(points[i], points[(i + 1) % points.Length]));
                    Floor floor = Floor.Create(doc, new List<CurveLoop> { loop }, floorTypeId, level.Id);
                    floor.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set("PROPOSAL; provisional main-floor plate; template type only; assembly unselected");
                    floors.Add(new { element_id = floor.Id.Value, offset_ft = offset, profile_width_ft = 40.0, profile_depth_ft = 42.0, profile_area_sqft = 1680.0, floor_type = floorType.Name });
                }
                tx.Commit();
            }
            string file = Path.Combine(output, "FH_Main_Floor_Candidate_21_with_provisional_plates.rvt");
            doc.SaveAs(file, new SaveAsOptions());
            doc.Close(false); doc = null;
            File.WriteAllText(Path.Combine(output, "floor-plate-manifest.json"), JsonSerializer.Serialize(new
            {
                schema = "forever-home-main-floor-floor-plate-v1",
                status = "disposable unselected native floor-plate comparison; template floor type only",
                source_run = run,
                source_rvt = Path.GetFileName(sourceFile),
                source_rvt_sha256 = sourceHash,
                saved_rvt = Path.GetFileName(file),
                saved_rvt_sha256 = Hash(file),
                floor_count = floors.Count,
                floors,
                wall_count = 42,
                limitations = new[]
                {
                    "Floor plates are 40 x 42 ft comparison profiles translated beside one another; they are not selected building elevations.",
                    "The Revit template floor type is a placeholder; no layered structural or finish assembly is selected.",
                    "No openings, doors, stairs, roof, structure, MEP, code, professional or construction conclusion follows."
                }
            }, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home", "Disposable provisional floor plates saved:\n" + file);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            if (doc is not null && doc.IsValidObject) doc.Close(false);
            TaskDialog.Show("Main-floor floor plate failed", ex.Message);
            return Result.Failed;
        }
    }
}
