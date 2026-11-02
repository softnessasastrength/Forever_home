using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeMainFloorOpeningStudyCommand : IExternalCommand
{
    private const string InputRelative = "Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts/main-floor-candidate-input.json";
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private sealed record Aperture(string id, double nominal_width_ft, string basis, bool selected);
    private sealed record CaseResult(string case_id, string saved_rvt, string saved_rvt_sha256, string ifc, string ifc_sha256,
        int wall_count, IReadOnlyList<Aperture> apertures, string status);

    private static string Root()
    {
        var assembly = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
            ?? throw new InvalidOperationException("RevitPilot assembly has no location.");
        var marker = Path.Combine(assembly, "workspace.txt");
        if (!File.Exists(marker)) throw new FileNotFoundException("Project-local workspace marker is missing.", marker);
        var root = Path.GetFullPath(File.ReadAllText(marker).Trim());
        if (!Directory.Exists(Path.Combine(root, "Project")) || !Directory.Exists(Path.Combine(root, "Tools")))
            throw new InvalidOperationException("Workspace marker does not resolve to Forever_home.");
        return root;
    }

    private static string Hash(string path)
    {
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
        return Convert.ToHexString(SHA256.HashData(stream));
    }

    private static double Number(JsonElement item, string key) => item.GetProperty(key).GetDouble();

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            var root = Root();
            var inputPath = Path.Combine(root, InputRelative.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(inputPath)) throw new FileNotFoundException("Pinned main-floor candidate input is missing.", inputPath);
            var inputHash = Hash(inputPath);
            using var source = JsonDocument.Parse(File.ReadAllText(inputPath));
            var input = source.RootElement;
            if (input.GetProperty("candidate").GetInt32() != 21) throw new InvalidDataException("Unexpected candidate id.");
            var roomBlocks = input.GetProperty("room_blocks").EnumerateArray().ToArray();
            var entry = roomBlocks.Single(x => x.GetProperty("id").GetString() == "M-05");
            var pantry = roomBlocks.Single(x => x.GetProperty("id").GetString() == "M-04");
            var porchDoor = input.GetProperty("porch_nominal_door_reservation_ft").EnumerateArray().Select(x => x.GetDouble()).ToArray();
            var routeHalf = input.GetProperty("route_width_ft").GetDouble() / 2.0;
            var output = Path.Combine(root, ".local", "revit-pilot", "main-floor-openings", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            var results = new List<CaseResult>();

            foreach (var (caseId, pantryWidth) in new[] { ("pantry-30in", 2.5), ("pantry-36in", 3.0) })
            {
                var caseDir = Path.Combine(output, caseId);
                Directory.CreateDirectory(caseDir);
                doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
                var apertures = new List<Aperture>
                {
                    new("front-entry-route", input.GetProperty("route_width_ft").GetDouble(), "documented 36-in route proxy; not a selected door", false),
                    new("rear-porch-french-door", porchDoor[1] - porchDoor[0], "documented nominal 5-ft French-door reservation; clear leaf unresolved", false),
                    new("pantry-door", pantryWidth, caseId == "pantry-30in" ? "documented nominal 30-in pantry door baseline" : "documented proposed 36-in wider pantry comparison", false)
                };

                using (var tx = new Transaction(doc, "Build disposable native opening reservation comparison"))
                {
                    tx.Start();
                    var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).First();
                    level.Name = "Local zero opening study datum - elevations unresolved";
                    var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                        .Where(x => x.Kind == WallKind.Basic).OrderBy(x => x.Name, StringComparer.Ordinal).First();

                    void Wall(double x1, double y1, double x2, double y2, string label)
                    {
                        if (Math.Abs(x1 - x2) + Math.Abs(y1 - y2) < 1e-8) return;
                        var wall = Autodesk.Revit.DB.Wall.Create(doc, Line.CreateBound(new XYZ(x1, y1, 0), new XYZ(x2, y2, 0)), wallType.Id, level.Id, 10.0, 0, false, false);
                        wall.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set("PROPOSAL; " + label + "; wall assembly unselected");
                    }

                    // Main 40 x 42 shell with documented front and rear nominal reservations.
                    var entryCenter = Number(entry, "x") + Number(entry, "w") / 2.0;
                    Wall(0, 0, entryCenter - routeHalf, 0, "front wall; 36-in route reservation");
                    Wall(entryCenter + routeHalf, 0, 40, 0, "front wall; 36-in route reservation");
                    Wall(40, 0, 40, 42, "east exterior wall proposal");
                    Wall(40, 42, porchDoor[1], 42, "rear wall; 5-ft porch reservation");
                    Wall(porchDoor[0], 42, 0, 42, "rear wall; 5-ft porch reservation");
                    Wall(0, 42, 0, 0, "west exterior wall proposal");
                    // Pantry rectangle; the west side is split to leave the 30/36-in native gap.
                    var px = Number(pantry, "x"); var py = Number(pantry, "y"); var pw = Number(pantry, "w"); var pd = Number(pantry, "d");
                    var pantryCenter = py + pd / 2.0;
                    var gapHalf = pantryWidth / 2.0;
                    Wall(px, py, px + pw, py, "pantry south wall proposal");
                    Wall(px + pw, py, px + pw, py + pd, "pantry east wall proposal");
                    Wall(px + pw, py + pd, px, py + pd, "pantry north wall proposal");
                    Wall(px, py, px, pantryCenter - gapHalf, "pantry west jamb; nominal door gap");
                    Wall(px, pantryCenter + gapHalf, px, py + pd, "pantry west jamb; nominal door gap");
                    tx.Commit();
                }

                var walls = new FilteredElementCollector(doc).OfClass(typeof(Wall)).GetElementCount();
                if (walls != 11) throw new InvalidDataException($"Expected 11 native wall segments, found {walls}.");
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(x => x.ViewFamily == ViewFamily.ThreeDimensional);
                using (var viewTx = new Transaction(doc, "Create disposable opening-study view"))
                {
                    viewTx.Start();
                    var view = View3D.CreateIsometric(doc, viewType.Id);
                    view.Name = $"Opening comparison {caseId} proposal only";
                    viewTx.Commit();
                }
                var rvt = Path.Combine(caseDir, $"FH_Main_Floor_Openings_{caseId}.rvt");
                doc.SaveAs(rvt, new SaveAsOptions());
                var ifcName = $"FH_Main_Floor_Openings_{caseId}";
                bool ifcOk;
                using (var exportTx = new Transaction(doc, "Export disposable opening study IFC2x3"))
                {
                    exportTx.Start();
                    try
                    {
                        using var options = new IFCExportOptions
                        {
                            FileVersion = IFCVersion.IFC2x3CV2,
                            ExportBaseQuantities = true
                        };
                        options.AddOption("ExportInternalRevitPropertySets", "true");
                        ifcOk = doc.Export(caseDir, ifcName, options);
                    }
                    finally
                    {
                        if (exportTx.GetStatus() == TransactionStatus.Started) exportTx.RollBack();
                    }
                }
                if (!ifcOk) throw new InvalidOperationException("Revit IFC export returned false.");
                var ifcPath = Path.Combine(caseDir, ifcName + ".ifc");
                doc.Close(false); doc = null;
                results.Add(new CaseResult(caseId, Path.GetFileName(rvt), Hash(rvt), Path.GetFileName(ifcPath), Hash(ifcPath), walls, apertures, "disposable native opening comparison; not selected"));
            }

            var manifest = new
            {
                schema = "forever-home-main-floor-opening-study-v1",
                status = "disposable native opening comparison; not selected-D",
                input = InputRelative,
                input_sha256 = inputHash,
                cases = results,
                limitations = new[] { "Wall segments are native Revit geometry around documented nominal gaps; no door family, frame, threshold or clear opening is selected.", "Template wall type and 10-ft harness height are comparison scaffolding, not house specifications.", "No code, accessibility, structural, professional, permit or construction conclusion follows." }
            };
            File.WriteAllText(Path.Combine(output, "opening-study-manifest.json"), JsonSerializer.Serialize(manifest, JsonOptions));
            TaskDialog.Show("Forever Home", "Disposable native opening comparison saved: " + output);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            if (doc is not null && doc.IsValidObject) doc.Close(false);
            TaskDialog.Show("Native opening study failed", ex.Message);
            return Result.Failed;
        }
    }
}
