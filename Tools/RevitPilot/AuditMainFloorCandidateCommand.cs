using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.IO;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class AuditMainFloorCandidateCommand : IExternalCommand
{
    const string RelativeRoot = ".local/revit-pilot/main-floor-candidate";
    static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? opened = null;
        string? copy = null;
        try
        {
            string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string baseDir = Path.Combine(root, RelativeRoot);
            string run = Directory.EnumerateDirectories(baseDir).OrderByDescending(Directory.GetLastWriteTimeUtc).First();
            using var manifest = JsonDocument.Parse(File.ReadAllText(Path.Combine(run, "manifest.json")));
            string source = Path.Combine(run, manifest.RootElement.GetProperty("saved_rvt").GetString()!);
            string sourceHash = Hash(source);
            copy = Path.Combine(run, Path.GetFileNameWithoutExtension(source) + "_reopened-audit.rvt");
            File.Copy(source, copy, true);
            opened = data.Application.Application.OpenDocumentFile(copy);

            int Count(Type type) => new FilteredElementCollector(opened).OfClass(type).GetElementCount();
            int CountCategory(BuiltInCategory category) => new FilteredElementCollector(opened).OfCategory(category).WhereElementIsNotElementType().GetElementCount();
            var levels = new FilteredElementCollector(opened).OfClass(typeof(Level)).Cast<Level>()
                .Select(l => new { id = l.Id.Value, name = l.Name, elevation_ft = l.Elevation }).ToArray();
            var walls = new FilteredElementCollector(opened).OfClass(typeof(Wall)).Cast<Wall>()
                .Select(w => new { id = w.Id.Value, type = w.WallType.Name, height_ft = w.get_Parameter(BuiltInParameter.WALL_USER_HEIGHT_PARAM)?.AsDouble() ?? 0.0 }).ToArray();
            var result = new
            {
                schema = "forever-home-main-floor-candidate-reopened-inventory-v1",
                status = "read-only reopened disposable candidate audit",
                source_run = Path.GetRelativePath(root, run).Replace('\\', '/'),
                source_rvt = Path.GetFileName(source),
                source_rvt_sha256 = sourceHash,
                reopened_copy = Path.GetFileName(copy),
                counts = new { levels = levels.Length, walls = Count(typeof(Wall)), model_curves = Count(typeof(CurveElement)), floors = CountCategory(BuiltInCategory.OST_Floors), doors = CountCategory(BuiltInCategory.OST_Doors), roofs = CountCategory(BuiltInCategory.OST_Roofs), stairs = CountCategory(BuiltInCategory.OST_Stairs) },
                levels,
                wall_sample = walls.Take(5),
                assertions = new[]
                {
                    new { name = "source_hash_recorded", pass = sourceHash.Equals(manifest.RootElement.GetProperty("saved_rvt_sha256").GetString(), StringComparison.OrdinalIgnoreCase) },
                    new { name = "expected_wall_count", pass = Count(typeof(Wall)) == 42 },
                    new { name = "expected_curve_count", pass = Count(typeof(CurveElement)) == 252 },
                    new { name = "no_unapproved_building_categories", pass = CountCategory(BuiltInCategory.OST_Floors) == 0 && CountCategory(BuiltInCategory.OST_Doors) == 0 && CountCategory(BuiltInCategory.OST_Roofs) == 0 && CountCategory(BuiltInCategory.OST_Stairs) == 0 }
                },
                limitations = new[] { "Read-only inventory only; no selected-D edit, M-06 assignment, door/clear-width, code, structural or construction approval." }
            };
            string output = Path.Combine(root, ".local/revalidation/main-floor-candidate-reopened-inventory.json");
            Directory.CreateDirectory(Path.GetDirectoryName(output)!);
            File.WriteAllText(output, JsonSerializer.Serialize(result, new JsonSerializerOptions { WriteIndented = true }));
            opened.Close(false); opened = null;
            File.Delete(copy); copy = null;
            TaskDialog.Show("Forever Home", "Read-only candidate inventory written:\n" + output);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            if (opened is not null && opened.IsValidObject) opened.Close(false);
            if (copy is not null && File.Exists(copy)) File.Delete(copy);
            TaskDialog.Show("Candidate audit failed", ex.Message);
            return Result.Failed;
        }
    }
}
