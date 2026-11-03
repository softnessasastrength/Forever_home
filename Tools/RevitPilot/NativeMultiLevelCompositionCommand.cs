using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Architecture;
using Autodesk.Revit.UI;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeMultiLevelCompositionCommand : IExternalCommand
{
    private const string SelectedD = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";
    private const string ExpectedSelectedHash = "516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb";
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    private static double N(JsonElement e, string key) => e.GetProperty(key).GetDouble();
    private static void Tag(Element e, string text) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(text);

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string source = Path.Combine(root, SelectedD.Replace('/', Path.DirectorySeparatorChar));
            string selectedHash = Hash(source);
            if (!selectedHash.Equals(ExpectedSelectedHash, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Selected-D changed.");
            using var json = JsonDocument.Parse(File.ReadAllText(source));
            var selected = json.RootElement;
            string output = Path.Combine(root, ".local", "revit-pilot", "multi-level-composition", DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'", CultureInfo.InvariantCulture));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            int walls = 0, floors = 0, roomBlocks = 0, rooms = 0, roofs = 0, stairs = 0, stairRuns = 0;
            Level? lowerLevel = null, mainLevel = null, upperLevel = null;
            using (var tx = new Transaction(doc, "Build disposable multi-level composition"))
            {
                tx.Start();
                var defaultLevel = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).First();
                defaultLevel.Name = "Main FF - Selected-D composition comparison";
                var lower = Level.Create(doc, -5.0); lower.Name = "Lower FF - 5 ft source comparison - floor-to-floor unresolved";
                var upper = Level.Create(doc, 5.0); upper.Name = "Upper FF - 5 ft source comparison - floor-to-floor unresolved";
                lowerLevel = lower; mainLevel = defaultLevel; upperLevel = upper;
                var levels = new Dictionary<string, (Level level, JsonElement rooms)> {
                    ["main"] = (defaultLevel, selected.GetProperty("plans").GetProperty("main")),
                    ["upper"] = (upper, selected.GetProperty("plans").GetProperty("upper")),
                    ["lower"] = (lower, selected.GetProperty("plans").GetProperty("lower"))
                };
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().Where(x => x.Kind == WallKind.Basic).OrderBy(x => x.Name, StringComparer.Ordinal).First();
                var floorType = Floor.GetDefaultFloorType(doc, false);
                if (floorType == ElementId.InvalidElementId) throw new InvalidOperationException("No default floor type.");
                var roofType = new FilteredElementCollector(doc).OfClass(typeof(RoofType)).Cast<RoofType>().OrderBy(x => x.Name, StringComparer.OrdinalIgnoreCase).First();
                foreach (var pair in levels)
                {
                    foreach (var room in pair.Value.rooms.EnumerateArray())
                    {
                        double x = N(room, "x"), y = N(room, "y"), w = N(room, "w"), d = N(room, "d");
                        string id = room.GetProperty("id").GetString() ?? "unknown";
                        var p = new[] { new XYZ(x, y, 0), new XYZ(x + w, y, 0), new XYZ(x + w, y + d, 0), new XYZ(x, y + d, 0) };
                        for (int i = 0; i < 4; i++)
                        {
                            var wall = Wall.Create(doc, Line.CreateBound(p[i], p[(i + 1) % 4]), wallType.Id, pair.Value.level.Id, 9.0, 0, false, false);
                            WallUtils.DisallowWallJoinAtEnd(wall, 0); WallUtils.DisallowWallJoinAtEnd(wall, 1);
                            Tag(wall, $"M385; {pair.Key} room-block {id}; source-derived comparison wall; unselected"); walls++;
                        }
                        var loop = new CurveLoop();
                        for (int i = 0; i < 4; i++) loop.Append(Line.CreateBound(new XYZ(p[i].X, p[i].Y, 0), new XYZ(p[(i + 1) % 4].X, p[(i + 1) % 4].Y, 0)));
                        var floor = Floor.Create(doc, new List<CurveLoop> { loop }, floorType, pair.Value.level.Id);
                        Tag(floor, $"M385; {pair.Key} room-block floor proxy; source-derived; assembly unselected"); floors++;
                        var roomElement = doc.Create.NewRoom(pair.Value.level, new UV(x + w / 2.0, y + d / 2.0));
                        roomElement.Name = id; roomElement.Number = $"M385-{pair.Key}-{id}"; Tag(roomElement, $"M385; {pair.Key} source room space; unselected"); rooms++;
                        roomBlocks++;
                    }
                }
                var porch = selected.GetProperty("shells").GetProperty("porch_ft");
                var porchLoop = new CurveLoop();
                var pp = new[] { new XYZ(0.3333333, 42, 0), new XYZ(12.3333333, 42, 0), new XYZ(12.3333333, 52, 0), new XYZ(0.3333333, 52, 0) };
                for (int i = 0; i < 4; i++) porchLoop.Append(Line.CreateBound(pp[i], pp[(i + 1) % 4]));
                var porchFloor = Floor.Create(doc, new List<CurveLoop> { porchLoop }, floorType, defaultLevel.Id);
                Tag(porchFloor, "M385; 12 x 10 ft porch/patio reservation; dining/fire-lounge split; brick/pool route and driveway remain site proposals; unselected");
                floors++;
                foreach (var roofCase in new[] { (label: "8:12", rise: 8.0, run: 12.0), (label: "10:12", rise: 10.0, run: 12.0), (label: "12:12", rise: 12.0, run: 12.0) })
                {
                    var profile = doc.Application.Create.NewCurveArray();
                    var rp = new[] { new XYZ(0, 0, 0), new XYZ(40, 0, 0), new XYZ(40, 42, 0), new XYZ(0, 42, 0) };
                    for (int i = 0; i < 4; i++) profile.Append(Line.CreateBound(rp[i], rp[(i + 1) % 4]));
                    ModelCurveArray mapping = new();
                    var roof = doc.Create.NewFootPrintRoof(profile, defaultLevel, roofType, out mapping);
                    int edge = 0;
                    foreach (ModelCurve curve in mapping)
                    {
                        bool slopes = edge is 0 or 2;
                        roof.set_DefinesSlope(curve, slopes);
                        if (slopes) roof.set_SlopeAngle(curve, Math.Atan(roofCase.rise / roofCase.run));
                        edge++;
                    }
                    Tag(roof, $"M386; roof candidate {roofCase.label}; one-main-gable comparison; unselected"); roofs++;
                }
                var vt = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(x => x.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, vt.Id); view.Name = "M385 multi-level composition — unselected comparison";
                tx.Commit();
            }
            // Native circulation comparison: two 5 ft flights using the documented
            // 8-riser / 7.5-in-riser / 11-in-tread study input. This is intentionally
            // disposable and unselected; it is evidence of API-backed circulation,
            // not a final stair, code, headroom, guard, or structural decision.
            if (lowerLevel is null || mainLevel is null || upperLevel is null) throw new InvalidOperationException("Comparison levels were not created.");
            var stairTypeId = new FilteredElementCollector(doc).OfClass(typeof(StairsType)).Cast<StairsType>().FirstOrDefault()?.Id
                ?? throw new InvalidOperationException("No native Revit stair type is available.");
            foreach (var (baseLevel, topLevel, label, x, y) in new[]
            {
                (lowerLevel, mainLevel, "lower-to-main", 34.0, 18.0),
                (mainLevel, upperLevel, "main-to-upper", 34.0, 26.0)
            })
            {
                using var scope = new StairsEditScope(doc, $"M387 native circulation {label}");
                var stairId = scope.Start(baseLevel.Id, topLevel.Id);
                using (var tx = new Transaction(doc, $"Create M387 {label} native stair"))
                {
                    tx.Start();
                    var stair = (Stairs)doc.GetElement(stairId)!;
                    stair.DesiredRisersNumber = 8;
                    var run = StairsRun.CreateStraightRun(doc, stairId,
                        Line.CreateBound(new XYZ(x, y, baseLevel.Elevation), new XYZ(x, y + 6.4166667, baseLevel.Elevation)),
                        StairsRunJustification.Center);
                    Tag(stair, $"M387; native circulation stair {label}; 8 risers @ 7.5 in / 11 in tread study; unselected");
                    Tag(run, $"M387; native stair run {label}; documented comparison input; not code clearance");
                    tx.Commit();
                    stairs++;
                    stairRuns++;
                }
                scope.Commit(new M387FailureRecorder());
            }
            walls = new FilteredElementCollector(doc).OfClass(typeof(Wall)).GetElementCount();
            floors = new FilteredElementCollector(doc).OfClass(typeof(Floor)).GetElementCount();
            if (walls <= 0 || floors != 22 || rooms != 21 || roomBlocks != 21 || roofs != 3 || stairs != 2 || stairRuns != 2) throw new InvalidDataException($"Inventory mismatch walls={walls} floors={floors} rooms={rooms} roomBlocks={roomBlocks} roofs={roofs} stairs={stairs} stairRuns={stairRuns}");
            string rvt = Path.Combine(output, "FH_Multi_Level_Composition.rvt"); string ifc = Path.Combine(output, "FH_Multi_Level_Composition.ifc");
            doc.SaveAs(rvt, new SaveAsOptions()); bool ifcOk;
            using (var tx = new Transaction(doc, "Export multi-level composition IFC2x3"))
            {
                tx.Start(); try { using var opts = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; ifcOk = doc.Export(output, "FH_Multi_Level_Composition", opts); } finally { if (tx.GetStatus() == TransactionStatus.Started) tx.RollBack(); }
            }
            doc.Close(false); doc = null;
            var manifest = new { schema = "forever-home-multi-level-composition-v2", status = "disposable source-derived three-level comparison with native circulation; not selected-D", selected_d_sha256 = selectedHash, levels = new[] { new { id = "Lower FF", elevation_ft = -5.0 }, new { id = "Main FF", elevation_ft = 0.0 }, new { id = "Upper FF", elevation_ft = 5.0 } }, room_block_count = roomBlocks, room_space_count = rooms, wall_count = walls, floor_count = floors, roof_count = roofs, stair_count = stairs, stair_run_count = stairRuns, stair_study = new { risers_per_flight = 8, riser_in = 7.5, tread_in = 11.0, flight_width_ft = 4.0, status = "documented native comparison input; width/headroom/guards/openings unresolved" }, roof_options = new[] { "8:12", "10:12", "12:12" }, porch_patio_reservation_count = 1, driveway_reservation = "documented brick checkerboard direction; site dimensions intentionally unassigned", future_pool_route = "documented brick route reservation; width and alignment intentionally unassigned", saved_rvt = Path.GetFileName(rvt), saved_rvt_sha256 = Hash(rvt), ifc = Path.GetFileName(ifc), ifc_sha256 = File.Exists(ifc) ? Hash(ifc) : null, ifc2x3 = ifcOk, limitations = new[] { "Source levels are a 5 ft comparison datum, not an approved floor-to-floor design.", "Room blocks, spaces, roofs and stairs are source-derived comparison geometry; openings, stair landing integration, assemblies, MEP, fixture placement and clearances remain unresolved.", "Porch/patio is a 12 x 10 ft reservation from source data; driveway and future pool route remain site proposals without invented dimensions.", "No code, accessibility, structural, professional, permit or construction claim is made." } };
            File.WriteAllText(Path.Combine(output, "multi-level-composition-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home M385", $"Disposable multi-level composition saved:\n{output}"); return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); if (doc is not null && doc.IsValidObject) doc.Close(false); return Result.Failed; }
    }

    private sealed class M387FailureRecorder : IFailuresPreprocessor
    {
        public FailureProcessingResult PreprocessFailures(FailuresAccessor accessor)
        {
            var failures = accessor.GetFailureMessages();
            if (failures.Any(f => f.GetSeverity() == FailureSeverity.Error)) return FailureProcessingResult.ProceedWithRollBack;
            foreach (var failure in failures) accessor.DeleteWarning(failure);
            return FailureProcessingResult.Continue;
        }
    }
}
