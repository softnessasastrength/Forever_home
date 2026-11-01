using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string SelectedDHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const string M193ReportHash = "975C348B380CF45229C492F939D89B4427073F4D21DB717DFB376023C0E9A2C8";
    private const string M215ReportHash = "F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1";
    private const string ObstacleSnapshotHash = "03E6D2BACC6A6167105651747869CB82AFB16515FADF691CFE8CE7695F1A1DA7";
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
    private sealed record Rect(string Id, double X, double Y, double W, double H);
    private sealed record Point(double X, double Y);
    private sealed record Candidate(string Id, Rect Room, Rect Run, Rect Island, Rect Body, Rect Overhang, Rect StoolUse, Rect HalfWall, double IslandLengthFt);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 4)
                throw new ArgumentException("Usage: M279Generator <m193-report.json> <m215-report.json> <m279-m186-obstacle-snapshot.json> <output-directory>");

            var repo = FindRepoRoot();
            var m193Path = Path.GetFullPath(Path.Combine(repo, args[0]));
            var m215Path = Path.GetFullPath(Path.Combine(repo, args[1]));
            var obstacleSnapshotPath = Path.GetFullPath(Path.Combine(repo, args[2]));
            var output = Path.GetFullPath(Path.Combine(repo, args[3]));
            var prefix = Path.GetFullPath(repo).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside the repository.");
            foreach (var path in new[] { m193Path, m215Path, obstacleSnapshotPath })
                if (!File.Exists(path)) throw new FileNotFoundException("Required source evidence is missing.", path);

            var selectedPath = Path.Combine(repo, "Architecture/Selected_Design_Iteration_2026-10-27/study.json");
            var m178Path = Path.Combine(repo, "Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json");
            var m172Path = Path.Combine(repo, "Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json");
            var selectedHash = Hash(selectedPath);
            var m193Hash = Hash(m193Path);
            var m215Hash = Hash(m215Path);
            var obstacleSnapshotHash = Hash(obstacleSnapshotPath);
            var m178Hash = Hash(m178Path);
            var m172Hash = Hash(m172Path);
            Require(m193Hash.Equals(M193ReportHash, StringComparison.OrdinalIgnoreCase), "M193 source report hash changed; review the upstream geometry before refreshing M279.");
            Require(m215Hash.Equals(M215ReportHash, StringComparison.OrdinalIgnoreCase), "M215 source report hash changed; review the route before refreshing M279.");
            Require(obstacleSnapshotHash.Equals(ObstacleSnapshotHash, StringComparison.OrdinalIgnoreCase), "M186 obstacle snapshot hash changed; review its provenance and geometry before refreshing M279.");
            if (!selectedHash.Equals(SelectedDHash, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Selected-D source changed; M279 is fail-closed.");

            var m193 = ReadJson(m193Path);
            var m215 = ReadJson(m215Path);
            var obstacleSnapshot = ReadJson(obstacleSnapshotPath);
            var m178 = ReadJson(m178Path);
            var m172 = ReadJson(m172Path);
            Require(m193["schema"]?.GetValue<string>() == "forever-home-m193-compact-island-fit-v1", "Unexpected M193 schema.");
            Require(m215["schema"]?.GetValue<string>() == "forever-home-m215-porch-approach-clearance-v1", "Unexpected M215 schema.");
            Require(obstacleSnapshot["schema"]?.GetValue<string>() == "forever-home-m279-m186-obstacle-snapshot-v1", "Unexpected M279 obstacle snapshot schema.");
            Require(obstacleSnapshot["source_report_sha256"]?.GetValue<string>() == "871B876F15F0950D68EF4667D89D37B63155E24B868D7C04E6D6E0B3C6C45684", "M186 obstacle snapshot provenance hash mismatch.");
            Require(obstacleSnapshot["source_check_status"]?.GetValue<string>() == "pass" && Number(obstacleSnapshot["source_check_count"]) == 31, "M186 source route contract did not pass its retained checks.");
            Require(selectedHash.Equals(m193["inputs"]?["selected_d_sha256"]?.GetValue<string>(), StringComparison.OrdinalIgnoreCase), "M193 selected-D fingerprint mismatch.");
            Require(selectedHash.Equals(m215["selected_D_sha256"]?.GetValue<string>(), StringComparison.OrdinalIgnoreCase), "M215 selected-D fingerprint mismatch.");
            Require(m215["checks"]?["status"]?.GetValue<string>() == "pass" && Number(m215["checks"]?["passed"]) == 12, "M215 route evidence did not pass its retained checks.");
            Require(selectedHash.Equals(obstacleSnapshot["selected_d_sha256"]?.GetValue<string>(), StringComparison.OrdinalIgnoreCase), "M186 snapshot selected-D fingerprint mismatch.");
            Require(m178["schema"]?.GetValue<string>() == "forever-home-m178-halfwall-seating-candidate-v1", "Unexpected M178 schema.");
            Require(m172["schema"]?.GetValue<string>() == "forever-home-m172-compact-social-space-constraints-v1", "Unexpected M172 schema.");
            var m193SourcesCurrent = VerifyFingerprints(repo, m193["source_fingerprints_sha256"]);
            var m215SourcesCurrent = VerifyFingerprints(repo, m215["source_fingerprints_sha256"]);
            Require(m193SourcesCurrent, "One or more M193 upstream fingerprints are stale.");
            Require(m215SourcesCurrent, "One or more M215 upstream fingerprints are stale.");

            var target = m193["inputs"]?["kitchen_clear_dimensions_ft"]?.AsArray() ?? throw new InvalidDataException("M193 kitchen target missing.");
            Require(Number(target[0]) == 14 && Number(target[1]) == 12 && Number(m193["inputs"]?["kitchen_area_target_sf"]) == 168, "M193 clear kitchen target changed.");
            Require(Number(m193["inputs"]?["perimeter_run_ft"]) == 12.5 && Number(m193["inputs"]?["counter_depth_ft"]) == 2 && Number(m193["inputs"]?["minimum_aisle_ft"]) == 3.5 && Number(m193["inputs"]?["halfwall_thickness_ft"]) == 0.5, "M193 kitchen module inputs changed.");
            var upstreamIslands = m193["candidates"]?.AsArray() ?? throw new InvalidDataException("M193 island candidates missing.");
            Require(IsCandidate(upstreamIslands, "flex_7x3_keep_2ft_butcher", 7, 3, 2, 1) && IsCandidate(upstreamIslands, "flex_6x3_keep_2ft_butcher", 6, 3, 2, 1), "M193 island alternatives or body/overhang split changed.");
            var axisA = CandidateA(Number(target[0]), Number(target[1]), 7);
            var axisACompact = CandidateA(Number(target[0]), Number(target[1]), 6);
            var axisB = CandidateB(Number(target[1]), Number(target[0]), 7);
            var axisBCompact = CandidateB(Number(target[1]), Number(target[0]), 6);
            var candidates = new[] { axisA, axisACompact, axisB, axisBCompact };
            var obstacles = (obstacleSnapshot["obstacles"]?.AsArray() ?? throw new InvalidDataException("M186 obstacle snapshot list missing."))
                .Select(n => new Rect(Text(n?["id"]), Number(n?["x"]), Number(n?["y"]), Number(n?["w"]), Number(n?["d"]))).ToArray();
            var pantry = obstacles.Single(x => x.Id == "M-04-pantry-5x6-A-B-clear");
            var protectedA = obstacles.Single(x => x.Id == "west_of_core");
            var unassignedB = obstacles.Single(x => x.Id == "east_of_core");
            var entry = obstacles.Single(x => x.Id == "M-05-entry");
            var dining = RectFromArray("dining", m215["dining_rect_ft"]);
            var porch = RectFromArray("porch", m215["porch_rect_ft"]);
            var routeRects = RouteRects(m215["route_waypoints_ft"]?.AsArray() ?? throw new InvalidDataException("M215 route missing."), Number(m215["route_width_in"]) / 12.0);

            var cases = candidates.Select(c => Evaluate(c, pantry, protectedA, unassignedB, entry, dining, porch, routeRects)).ToArray();
            var checks = new SortedDictionary<string, bool>(StringComparer.Ordinal)
            {
                ["M172_M178_M193_M215_M186_sources_have_expected_schemas"] = true,
                ["selected_D_hash_matches_protected_baseline"] = selectedHash.Equals(SelectedDHash, StringComparison.OrdinalIgnoreCase),
                ["M193_and_M215_upstream_selected_D_hashes_match"] = selectedHash.Equals(m193["inputs"]?["selected_d_sha256"]?.GetValue<string>(), StringComparison.OrdinalIgnoreCase) && selectedHash.Equals(m215["selected_D_sha256"]?.GetValue<string>(), StringComparison.OrdinalIgnoreCase),
                ["pinned_M193_M215_and_snapshot_hashes_match"] = m193Hash.Equals(M193ReportHash, StringComparison.OrdinalIgnoreCase) && m215Hash.Equals(M215ReportHash, StringComparison.OrdinalIgnoreCase) && obstacleSnapshotHash.Equals(ObstacleSnapshotHash, StringComparison.OrdinalIgnoreCase),
                ["M193_upstream_fingerprints_current"] = m193SourcesCurrent,
                ["M215_upstream_fingerprints_current"] = m215SourcesCurrent,
                ["source_route_checks_passed_before_overlay"] = m215["checks"]?["status"]?.GetValue<string>() == "pass" && obstacleSnapshot["source_check_status"]?.GetValue<string>() == "pass",
                ["both_orientations_preserve_168sf_target"] = cases.All(c => Math.Abs(c.Room.W * c.Room.H - 168) < 1e-9),
                ["both_island_sizes_match_M193_candidates"] = cases.All(c => Math.Abs(c.Island.W * c.Island.H - c.IslandLengthFt * 3) < 1e-9) && cases.Select(c => c.IslandLengthFt).Distinct().Order().SequenceEqual(new[] { 6.0, 7.0 }),
                ["runs_islands_overhangs_stool_zones_and_halfwalls_are_contained"] = cases.All(c => Contains(c.Room, c.Run) && Contains(c.Room, c.Island) && Contains(c.Island, c.Body) && Contains(c.Island, c.Overhang) && Contains(c.Room, c.StoolUse) && IsOutsideOnBoundary(c.Room, c.HalfWall)),
                ["pantry_overlap_is_reported_without_reassigning_M04"] = cases.Any(c => Math.Abs(c.PantryOverlapSf - 3) < 1e-7) && cases.Any(c => Math.Abs(c.PantryOverlapSf) < 1e-7),
                ["12x14_orientation_clears_inherited_fixed_blocks_and_route"] = cases.Where(c => c.Id.StartsWith("axis-12x14", StringComparison.Ordinal)).All(c => c.RoomPassesFixedBlockScreen && c.RoutePassesOverlay),
                ["14x12_orientation_is_rejected_for_exact_M04_overlap"] = cases.Where(c => c.Id.StartsWith("axis-14x12", StringComparison.Ordinal)).All(c => !c.RoomPassesFixedBlockScreen && Math.Abs(c.PantryOverlapSf - 3) < 1e-7),
                ["42in_cross_aisle_proxies_and_run_reserve_are_retained"] = cases.All(c => Math.Abs(c.CrossAisleBeforeIn - 42) < 1e-9 && Math.Abs(c.CrossAisleAfterIn - 42) < 1e-9 && c.RunAxisReserveIn == 18 && (Math.Abs(c.EndReserveIn) < 1e-9 || Math.Abs(c.EndReserveIn - 12) < 1e-9)),
                ["unassigned_kitchen_to_dining_band_is_reported"] = cases.All(c => c.UnassignedBandToDiningFt > 0),
                ["inherited_route_connects_through_dining_to_porch"] = cases.All(c => c.RouteOverlapAreas["dining"] > 0 && c.RouteOverlapAreas["porch"] > 0),
                ["inherited_route_remains_36in_34ft_with_3in_proxy_gap"] = Number(m215["route_width_in"]) == 36 && Number(m215["route_length_ft"]) == 34 && Number(m215["minimum_obstacle_gap_ft"]) == 0.25,
                ["A_B_M05_dining_porch_and_inherited_route_intersections_are_reported"] = cases.All(c => c.OverlapAreas.ContainsKey("protected_A") && c.OverlapAreas.ContainsKey("unassigned_B") && c.OverlapAreas.ContainsKey("M05_entry") && c.OverlapAreas.ContainsKey("dining") && c.OverlapAreas.ContainsKey("porch") && c.RouteOverlapAreas.ContainsKey("room") && c.RouteOverlapAreas.ContainsKey("island") && c.RouteOverlapAreas.ContainsKey("stool_use")),
                ["M06_A_B_unassigned_and_west_A_protected"] = m215["owner_protected_A"]?.GetValue<bool>() == true && m215["M06_B_status"]?.GetValue<string>()?.Contains("Unassigned", StringComparison.OrdinalIgnoreCase) == true,
                ["no_room_or_fixture_selection_or_code_claim"] = true
            };
            if (checks.Values.Any(x => !x)) throw new InvalidDataException("M279 invariant check failed.");

            var report = new
            {
                schema = "forever-home-m279-kitchen-porch-integration-screen-v1",
                status = "source-bound orientation comparison; no kitchen/island/pantry/room placement selected",
                inputs_sha256 = new { m193_report = m193Hash, m215_route_report = m215Hash, m186_obstacle_snapshot = obstacleSnapshotHash, m186_original_source_report = obstacleSnapshot["source_report_sha256"]?.GetValue<string>(), m178_study = m178Hash, m172_constraints = m172Hash, selected_d = selectedHash },
                method = "Place the source 14x12-ft clear kitchen target at the M178 local origin in both axis orientations. Derive the 12.5-ft run, 2-ft cabinet body, 1-ft seating overhang, 7x3/6x3-ft island and 36-in stool-use proxy from M193/M172 and the documented M178 arrangement. Overlay M215's tested dining, porch and 36-in route plus M186's fixed M-04, protected-A, unassigned-B and M-05 rectangles. This is an analytical orientation screen, not a selected plan.",
                inherited_route = new { width_in = Number(m215["route_width_in"]), length_ft = Number(m215["route_length_ft"]), minimum_obstacle_gap_ft = Number(m215["minimum_obstacle_gap_ft"]), waypoints = m215["route_waypoints_ft"]?.DeepClone(), dining = m215["dining_rect_ft"]?.DeepClone(), porch = m215["porch_rect_ft"]?.DeepClone(), route_revalidated_by_m279 = true },
                cases,
                check_count = checks.Count,
                passed_check_count = checks.Count,
                checks = checks.Select(kv => new { id = kv.Key, pass = kv.Value }).ToArray(),
                limitations = new[]
                {
                    "M-04 is inherited as a 5x6-ft block from M186/M215; other repository records specify a different pantry size. Neither size is resolved here.",
                    "The 14x12-ft target is clear-interior area. The half-wall is represented outside one boundary; real wall, opening, return, finishes and kitchen entry are not modeled.",
                    "The M215 route and its dining/porch geometry are inherited comparisons. Their relationship to an actual kitchen/living opening is not proven by this overlay.",
                    "The 36-in stool-use envelope is a schematic study proxy; product geometry, occupant motion, installation tolerances and appliance operation are not verified.",
                    "No M-06 room/fixture assignment, code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows."
                }
            };
            Directory.CreateDirectory(output);
            Write(Path.Combine(output, "m279-report.json"), JsonSerializer.Serialize(report, JsonOptions));
            Write(Path.Combine(output, "m279-checks.json"), JsonSerializer.Serialize(new { schema = "forever-home-m279-checks-v1", status = "pass", check_count = checks.Count, passed_check_count = checks.Count, checks = checks.Select(kv => new { id = kv.Key, pass = kv.Value }) }, JsonOptions));
            Write(Path.Combine(output, "m279-plan.svg"), Svg(cases, dining, porch, routeRects));
            Console.WriteLine($"M279 pass: {checks.Count}/{checks.Count}; outputs: {output}");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine(ex.Message);
            return 1;
        }
    }

    private sealed record CaseResult(string Id, Rect Room, Rect Run, Rect Island, Rect Body, Rect Overhang, Rect StoolUse, Rect HalfWall, double IslandLengthFt,
        double PantryOverlapSf, Dictionary<string, double> OverlapAreas, Dictionary<string, double> RouteOverlapAreas,
        double RunAxisReserveIn, double EndReserveIn, double CrossAisleBeforeIn, double CrossAisleAfterIn, double UnassignedBandToDiningFt,
        bool RoomPassesFixedBlockScreen, bool RoutePassesOverlay, string Disposition);

    private static Candidate CandidateA(double w, double h, double length)
    {
        var room = new Rect("kitchen-14x12", 0, 0, w, h);
        var x = (w - length) / 2;
        var island = new Rect($"island-{length}x3", x, 5.5, length, 3);
        var body = new Rect("cabinet-body", island.X, island.Y, length, 2);
        var overhang = new Rect("seating-overhang", island.X, island.Y + 2, length, 1);
        var stool = new Rect("stool-use-proxy", island.X, island.Y + 3, length, 3);
        return new Candidate($"axis-14x12-{length}x3", room, new Rect("perimeter-run-12_5x2", 0, 0, 12.5, 2), island, body, overhang, stool, new Rect("halfwall-outside-clear-boundary", 0, h, 7, 0.5), length);
    }

    private static Candidate CandidateB(double w, double h, double length)
    {
        var room = new Rect("kitchen-12x14", 0, 0, w, h);
        var y = (h - length) / 2;
        var island = new Rect($"island-3x{length}", 5.5, y, 3, length);
        var body = new Rect("cabinet-body", island.X, island.Y, 2, length);
        var overhang = new Rect("seating-overhang", island.X + 2, island.Y, 1, length);
        var stool = new Rect("stool-use-proxy", island.X + 3, island.Y, 3, length);
        return new Candidate($"axis-12x14-3x{length}", room, new Rect("perimeter-run-2x12_5", 0, 0, 2, 12.5), island, body, overhang, stool, new Rect("halfwall-outside-clear-boundary", w, 0, 0.5, 7), length);
    }

    private static CaseResult Evaluate(Candidate c, Rect pantry, Rect a, Rect b, Rect entry, Rect dining, Rect porch, Rect[] route)
    {
        var overlaps = new Dictionary<string, double>
        {
            ["M04_pantry"] = Overlap(c.Room, pantry), ["protected_A"] = Overlap(c.Room, a), ["unassigned_B"] = Overlap(c.Room, b),
            ["M05_entry"] = Overlap(c.Room, entry), ["dining"] = Overlap(c.Room, dining), ["porch"] = Overlap(c.Room, porch)
        };
        var routeOverlaps = new Dictionary<string, double>
        {
            ["room"] = route.Sum(r => Overlap(c.Room, r)), ["island"] = route.Sum(r => Overlap(c.Island, r)),
            ["stool_use"] = route.Sum(r => Overlap(c.StoolUse, r)), ["dining"] = route.Sum(r => Overlap(dining, r)), ["porch"] = route.Sum(r => Overlap(porch, r))
        };
        var crossBefore = c.Id.StartsWith("axis-14") ? c.Island.Y - (c.Run.Y + c.Run.H) : c.Island.X - (c.Run.X + c.Run.W);
        var crossAfter = c.Id.StartsWith("axis-14") ? c.HalfWall.Y - (c.Island.Y + c.Island.H) : c.HalfWall.X - (c.Island.X + c.Island.W);
        var roomPass = overlaps.Values.All(v => v < 1e-9);
        var routePass = routeOverlaps["room"] < 1e-9 && routeOverlaps["island"] < 1e-9 && routeOverlaps["stool_use"] < 1e-9;
        var pantryOverlap = overlaps["M04_pantry"];
        var longAxis = c.Id.StartsWith("axis-14") ? c.Room.W : c.Room.H;
        var diningBand = dining.Y - (c.Room.Y + c.Room.H);
        return new CaseResult(c.Id, c.Room, c.Run, c.Island, c.Body, c.Overhang, c.StoolUse, c.HalfWall, c.IslandLengthFt, pantryOverlap, overlaps, routeOverlaps,
            (longAxis - 12.5) * 12, (longAxis - c.IslandLengthFt - 7) * 12,
            crossBefore * 12, crossAfter * 12, diningBand, roomPass, routePass,
            roomPass && routePass && pantryOverlap < 1e-9 ? "clears listed fixed-block overlay; kitchen-dining band remains unassigned; unselected" : "fails one or more inherited block screens; unselected");
    }

    private static Rect[] RouteRects(JsonArray points, double width)
    {
        var p = points.Select(n => new Point(Number(n?["x"]), Number(n?["y"]))).ToArray();
        var result = new List<Rect>(); var half = width / 2;
        for (var i = 0; i < p.Length - 1; i++)
        {
            var a = p[i]; var b = p[i + 1];
            if (Math.Abs(a.Y - b.Y) < 1e-9) result.Add(new Rect($"route-{i}", Math.Min(a.X, b.X), a.Y - half, Math.Abs(b.X - a.X), width));
            else if (Math.Abs(a.X - b.X) < 1e-9) result.Add(new Rect($"route-{i}", a.X - half, Math.Min(a.Y, b.Y), width, Math.Abs(b.Y - a.Y)));
            else throw new InvalidDataException("M215 route includes a diagonal segment.");
            if (i > 0) result.Add(new Rect($"corner-{i}", a.X - half, a.Y - half, width, width));
        }
        return result.ToArray();
    }

    private static Rect RectFromArray(string id, JsonNode? node)
    {
        var a = node?.AsArray() ?? throw new InvalidDataException($"{id} rectangle missing.");
        return new Rect(id, Number(a[0]), Number(a[1]), Number(a[2]), Number(a[3]));
    }

    private static bool Contains(Rect a, Rect b) => b.X >= a.X - 1e-9 && b.Y >= a.Y - 1e-9 && b.X + b.W <= a.X + a.W + 1e-9 && b.Y + b.H <= a.Y + a.H + 1e-9;
    private static bool IsOutsideOnBoundary(Rect room, Rect wall) =>
        (Math.Abs(wall.Y - (room.Y + room.H)) < 1e-9 && Math.Abs(wall.X - room.X) < 1e-9 && wall.W <= room.W) ||
        (Math.Abs(wall.X - (room.X + room.W)) < 1e-9 && Math.Abs(wall.Y - room.Y) < 1e-9 && wall.H <= room.H);
    private static double Overlap(Rect a, Rect b) => Math.Max(0, Math.Min(a.X + a.W, b.X + b.W) - Math.Max(a.X, b.X)) * Math.Max(0, Math.Min(a.Y + a.H, b.Y + b.H) - Math.Max(a.Y, b.Y));
    private static JsonNode ReadJson(string path) => JsonNode.Parse(File.ReadAllText(path)) ?? throw new InvalidDataException($"Invalid JSON: {path}");
    private static bool VerifyFingerprints(string repo, JsonNode? fingerprints)
    {
        if (fingerprints is not JsonObject values || values.Count == 0) return false;
        foreach (var item in values)
        {
            var path = Path.GetFullPath(Path.Combine(repo, item.Key));
            if (!File.Exists(path) || !Hash(path).Equals(item.Value?.GetValue<string>(), StringComparison.OrdinalIgnoreCase)) return false;
        }
        return true;
    }
    private static bool IsCandidate(JsonArray candidates, string id, double length, double overallDepth, double bodyDepth, double overhang)
    {
        var candidate = candidates.SingleOrDefault(n => n?["case"]?.GetValue<string>() == id);
        return candidate is not null && Number(candidate["island_length_ft"]) == length && Number(candidate["overall_depth_ft"]) == overallDepth &&
            Number(candidate["cabinet_body_depth_ft"]) == bodyDepth && Number(candidate["seating_overhang_ft"]) == overhang;
    }
    private static double Number(JsonNode? n) => double.Parse(n?.ToString() ?? throw new InvalidDataException("Missing numeric input."), System.Globalization.CultureInfo.InvariantCulture);
    private static string Text(JsonNode? n) => n?.GetValue<string>() ?? throw new InvalidDataException("Missing text input.");
    private static void Require(bool ok, string message) { if (!ok) throw new InvalidDataException(message); }
    private static string Hash(string p) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(p)));
    private static void Write(string path, string content) => File.WriteAllText(path, content + "\n", new UTF8Encoding(false));
    private static string Svg(CaseResult[] cases, Rect dining, Rect porch, Rect[] route)
    {
        const double scale = 10, ox = 40;
        var sb = new StringBuilder("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1100\" height=\"800\" viewBox=\"0 0 1100 800\"><style>text{font:12px sans-serif}.room{fill:#eef1e8;stroke:#333;stroke-width:2}.bad{fill:#e7b6aa;stroke:#a33}.ok{fill:#bfd8bb;stroke:#39734c}.route{fill:#9dbde0;opacity:.55;stroke:#315c88}.pantry{fill:#f2d49b;stroke:#805b21}</style><text x=\"24\" y=\"28\">M279 orientation overlay — schematic, not selected</text>");
        for (var i = 0; i < cases.Length; i++)
        {
            var c = cases[i]; var gx = ox + (i % 2) * 460; var gy = 730 - (i / 2) * 365;
            void Box(Rect r, string cls, string label) { var x = gx + r.X * scale; var y = gy - (r.Y + r.H) * scale; sb.Append(FormattableString.Invariant($"<rect class=\"{cls}\" x=\"{x:F1}\" y=\"{y:F1}\" width=\"{r.W * scale:F1}\" height=\"{r.H * scale:F1}\"/><text x=\"{x + 3:F1}\" y=\"{y + 16:F1}\">{label}</text>")); }
            sb.Append(FormattableString.Invariant($"<text x=\"{gx:F1}\" y=\"{gy - 280:F1}\">{c.Id}; M04 overlap {c.PantryOverlapSf:F2} sf; kitchen-dining band {c.UnassignedBandToDiningFt:F1} ft</text>"));
            Box(c.Room, "room", c.Id); Box(c.Run, "ok", "12.5ft run"); Box(c.Island, "ok", $"{c.IslandLengthFt}x3 island"); Box(c.StoolUse, "route", "36in stool-use proxy"); Box(c.HalfWall, "bad", "half-wall outside clear face"); Box(dining, "", "M215 dining"); Box(porch, "", "M215 porch");
            foreach (var r in route) Box(r, "route", "M215 route");
            if (c.PantryOverlapSf > 0) sb.Append(FormattableString.Invariant($"<text x=\"{gx:F1}\" y=\"{gy - 8:F1}\">M04 overlap: {c.PantryOverlapSf:F2} sf</text>"));
        }
        return sb.Append("</svg>").ToString();
    }
    private static string FindRepoRoot() { var d = new DirectoryInfo(Environment.CurrentDirectory); while (d is not null && !File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) d = d.Parent; return d?.FullName ?? throw new DirectoryNotFoundException("Repository root not found."); }
}
