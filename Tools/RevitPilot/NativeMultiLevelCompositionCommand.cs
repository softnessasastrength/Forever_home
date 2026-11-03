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
    private static DirectShape AddBox(Document doc, double x, double y, double z, double width, double depth, double height, string tag)
    {
        var shape = DirectShape.CreateElement(doc, new ElementId(BuiltInCategory.OST_GenericModel));
        var loop = new CurveLoop();
        var points = new[] { new XYZ(x, y, z), new XYZ(x + width, y, z), new XYZ(x + width, y + depth, z), new XYZ(x, y + depth, z) };
        for (int i = 0; i < points.Length; i++) loop.Append(Line.CreateBound(points[i], points[(i + 1) % points.Length]));
        shape.SetShape(new GeometryObject[] { GeometryCreationUtilities.CreateExtrusionGeometry(new[] { loop }, XYZ.BasisZ, height) });
        Tag(shape, tag);
        return shape;
    }

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
            int walls = 0, shellWalls = 0, floors = 0, roomBlocks = 0, rooms = 0, roofs = 0, stairs = 0, stairRuns = 0, kitchenIslands = 0, bathFixtureProxies = 0, skylightReservations = 0, siteMarkers = 0, doorProxies = 0;
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
                // M392: source-derived perimeter shell study. Lower/upper use the
                // documented 36 x 32 ft rear shell candidate; main uses 40 x 42 ft.
                // These walls enclose the comparison only; they do not select a shell,
                // datum, assembly, opening, structure, or code result.
                foreach (var shell in new[]
                {
                    (key: "main", level: defaultLevel, width: 40.0, depth: 42.0),
                    (key: "lower", level: lower, width: 36.0, depth: 32.0),
                    (key: "upper", level: upper, width: 36.0, depth: 32.0)
                })
                {
                    var sp = new[] { new XYZ(0, 0, 0), new XYZ(shell.width, 0, 0), new XYZ(shell.width, shell.depth, 0), new XYZ(0, shell.depth, 0) };
                    for (int i = 0; i < 4; i++)
                    {
                        var wall = Wall.Create(doc, Line.CreateBound(sp[i], sp[(i + 1) % 4]), wallType.Id, shell.level.Id, 9.0, 0, false, false);
                        WallUtils.DisallowWallJoinAtEnd(wall, 0); WallUtils.DisallowWallJoinAtEnd(wall, 1);
                        Tag(wall, $"M392; {shell.key} source-derived perimeter shell {shell.width} x {shell.depth} ft; envelope comparison; unselected");
                        walls++; shellWalls++;
                    }
                }
                var porch = selected.GetProperty("shells").GetProperty("porch_ft");
                var porchLoop = new CurveLoop();
                var pp = new[] { new XYZ(0.3333333, 42, 0), new XYZ(12.3333333, 42, 0), new XYZ(12.3333333, 52, 0), new XYZ(0.3333333, 52, 0) };
                for (int i = 0; i < 4; i++) porchLoop.Append(Line.CreateBound(pp[i], pp[(i + 1) % 4]));
                var porchFloor = Floor.Create(doc, new List<CurveLoop> { porchLoop }, floorType, defaultLevel.Id);
                Tag(porchFloor, "M385; 12 x 10 ft porch/patio reservation; dining/fire-lounge split; brick/pool route and driveway remain site proposals; unselected");
                floors++;
                var siteSketch = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, XYZ.Zero));
                var drivewayMarker = doc.Create.NewModelCurve(Line.CreateBound(new XYZ(0, -0.5, 0), new XYZ(40, -0.5, 0)), siteSketch);
                Tag(drivewayMarker, "M390; brick checkerboard driveway direction marker; width/length/module/grade unassigned; not site geometry");
                var poolMarker = doc.Create.NewModelCurve(Line.CreateBound(new XYZ(40, 0, 0), new XYZ(40, 42, 0)), siteSketch);
                Tag(poolMarker, "M390; future brick pool-route direction marker; width/length/alignment/grade unassigned; not site geometry");
                siteMarkers += 2;
                AddBox(doc, 18.0, 0.0, 0.0, 3.0, 0.15, 6.6667, "M391; nominal front-entry door proxy; 36-in nominal comparison; clear leaf/swing/threshold unresolved; unselected");
                AddBox(doc, 6.3333, 52.0, 0.0, 5.0, 0.15, 6.6667, "M391; nominal porch French-door proxy; 5-ft comparison; clear leaf/swing/threshold unresolved; unselected");
                AddBox(doc, 22.0, 5.6667, 0.0, 2.5, 0.15, 6.6667, "M391; nominal pantry-door proxy; 30-in baseline comparison; swing/approach unresolved; unselected");
                doorProxies += 3;
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
                    foreach (var zone in new[] { (name: "stair", x: 8.0), (name: "kitchen", x: 18.0), (name: "primary-bath", x: 28.0) })
                    {
                        AddBox(doc, zone.x, 18.0, 5.25, 2.5, 1.5, 0.1, $"M389; skylight reservation; zone={zone.name}; pitch={roofCase.label}; opening not cut; unselected");
                        skylightReservations++;
                    }
                }
                var kitchen = selected.GetProperty("plans").GetProperty("main").EnumerateArray().Single(r => r.GetProperty("id").GetString() == "M-02");
                double kx = N(kitchen, "x"), ky = N(kitchen, "y"), kw = N(kitchen, "w"), kd = N(kitchen, "d");
                AddBox(doc, kx + kw - 9.5, ky + (kd - 4.0) / 2.0, 0, 8.0, 4.0, 3.0, "M388; M-02 kitchen island; 8 x 4 ft; dining/living bias; appliance-free; unselected");
                kitchenIslands++;
                var primaryBath = selected.GetProperty("plans").GetProperty("upper").EnumerateArray().Single(r => r.GetProperty("id").GetString() == "U-05");
                double bx = N(primaryBath, "x"), by = N(primaryBath, "y");
                AddBox(doc, bx + 1.0, by + 1.0, 5.0, 5.0, 3.0, 1.5, "M388; U-05 primary bath separate tub proxy; owner-approved direction; unselected");
                AddBox(doc, bx + 5.5, by + 5.0, 5.0, 3.0, 4.0, 1.5, "M388; U-05 tiled rain-shower proxy; visual focal direction; unselected");
                bathFixtureProxies += 2;
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
            if (walls <= 0 || shellWalls != 12 || floors != 22 || rooms != 21 || roomBlocks != 21 || roofs != 3 || stairs != 2 || stairRuns != 2 || kitchenIslands != 1 || bathFixtureProxies != 2 || skylightReservations != 9 || siteMarkers != 2 || doorProxies != 3) throw new InvalidDataException($"Inventory mismatch walls={walls} shellWalls={shellWalls} floors={floors} rooms={rooms} roomBlocks={roomBlocks} roofs={roofs} stairs={stairs} stairRuns={stairRuns} kitchenIslands={kitchenIslands} bathFixtureProxies={bathFixtureProxies} skylights={skylightReservations} siteMarkers={siteMarkers} doorProxies={doorProxies}");
            string rvt = Path.Combine(output, "FH_Multi_Level_Composition.rvt"); string ifc = Path.Combine(output, "FH_Multi_Level_Composition.ifc");
            doc.SaveAs(rvt, new SaveAsOptions()); bool ifcOk;
            using (var tx = new Transaction(doc, "Export multi-level composition IFC2x3"))
            {
                tx.Start(); try { using var opts = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; ifcOk = doc.Export(output, "FH_Multi_Level_Composition", opts); } finally { if (tx.GetStatus() == TransactionStatus.Started) tx.RollBack(); }
            }
            doc.Close(false); doc = null;
            var manifest = new { schema = "forever-home-multi-level-composition-v7", status = "disposable source-derived three-level comparison with native perimeter shell, circulation, interior, skylight, site-direction and door proxies; not selected-D", selected_d_sha256 = selectedHash, levels = new[] { new { id = "Lower FF", elevation_ft = -5.0 }, new { id = "Main FF", elevation_ft = 0.0 }, new { id = "Upper FF", elevation_ft = 5.0 } }, room_block_count = roomBlocks, room_space_count = rooms, wall_count = walls, shell_wall_count = shellWalls, floor_count = floors, roof_count = roofs, stair_count = stairs, stair_run_count = stairRuns, kitchen_island_count = kitchenIslands, primary_bath_fixture_proxy_count = bathFixtureProxies, skylight_reservation_count = skylightReservations, site_direction_marker_count = siteMarkers, door_proxy_count = doorProxies, shell_status = "three source-derived perimeter wall loops: main 40 x 42 ft; lower/upper 36 x 32 ft; envelope comparison only; unselected", stair_study = new { risers_per_flight = 8, riser_in = 7.5, tread_in = 11.0, flight_width_ft = 4.0, status = "documented native comparison input; width/headroom/guards/openings unresolved" }, interior_proxy_status = "owner-approved 8 x 4 ft island and separate tub/tiled rain-shower direction; placement and fixture/clearance gates unresolved", skylight_status = "nine non-cutting reservations across stair, kitchen and primary-bath zones for 8:12/10:12/12:12 comparison; unselected", site_direction_status = "two dimension-neutral direction markers for brick checkerboard driveway and future brick pool route; site geometry intentionally unassigned", door_proxy_status = "three nominal display proxies for front, porch and pantry coordination; no family, opening, swing or clear leaf selected", roof_options = new[] { "8:12", "10:12", "12:12" }, porch_patio_reservation_count = 1, driveway_reservation = "documented brick checkerboard direction; dimensions intentionally unassigned", future_pool_route = "documented brick route reservation; dimensions intentionally unassigned", saved_rvt = Path.GetFileName(rvt), saved_rvt_sha256 = Hash(rvt), ifc = Path.GetFileName(ifc), ifc_sha256 = File.Exists(ifc) ? Hash(ifc) : null, ifc2x3 = ifcOk, limitations = new[] { "Source levels are a 5 ft comparison datum, not an approved floor-to-floor design.", "Perimeter shell walls, room blocks, spaces, roofs, stairs, interior, skylight, site-direction and door proxies are source-derived comparison geometry; actual openings, stair landing integration, assemblies, MEP, fixture placement and clearances remain unresolved.", "Door proxies are display solids, not hosted Revit door families or clear openings; kitchen, bath, skylight and site proxies are likewise unselected and non-construction geometry; M-06/B remains unassigned.", "Porch/patio is a 12 x 10 ft reservation from source data; driveway and future pool route remain directional markers without invented dimensions.", "No code, accessibility, structural, professional, permit or construction claim is made." } };
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
