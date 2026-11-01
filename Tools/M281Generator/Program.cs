using System.Globalization;
using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string M213Hash = "893EDCC4E0B836E83DE2516EB834F55B5CADF08BD8E8B75B1F737C833BF5F303";
    private const string M279Hash = "5F15A39116AD56C6B53CAC502427460DAC2727853C9334F0096ADBF9B30D1431";
    private const string SnapshotHash = "03E6D2BACC6A6167105651747869CB82AFB16515FADF691CFE8CE7695F1A1DA7";
    private const string SelectedDHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private static readonly JsonSerializerOptions Options = new() { WriteIndented = true };

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 4) throw new ArgumentException("Usage: M281Generator <m213-report.json> <m279-report.json> <m279-obstacle-snapshot.json> <output-directory>");
            var root = FindRoot();
            var m213Path = Resolve(root, args[0]);
            var m279Path = Resolve(root, args[1]);
            var snapshotPath = Resolve(root, args[2]);
            var selectedPath = Path.Combine(root, "Architecture/Selected_Design_Iteration_2026-10-27/study.json");
            var output = Resolve(root, args[3]);
            var prefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside the repository.");
            foreach (var path in new[] { m213Path, m279Path, snapshotPath, selectedPath })
                if (!File.Exists(path)) throw new FileNotFoundException("Required source-bound layout evidence is missing.", path);

            var hashes = new Dictionary<string, string>
            {
                ["m213_report"] = Hash(m213Path), ["m279_report"] = Hash(m279Path),
                ["m279_obstacle_snapshot"] = Hash(snapshotPath), ["selected_d"] = Hash(selectedPath)
            };
            Require(hashes["m213_report"] == M213Hash, "M213 report changed; review its route and owner constraints before refreshing M281.");
            Require(hashes["m279_report"] == M279Hash, "M279 report changed; review its compact-orientation comparison before refreshing M281.");
            Require(hashes["m279_obstacle_snapshot"] == SnapshotHash, "M279 obstacle snapshot changed; re-establish its source contract before refreshing M281.");
            Require(hashes["selected_d"] == SelectedDHash, "Selected-D source changed; M281 is fail-closed.");

            var m213 = Read(m213Path);
            var m279 = Read(m279Path);
            var snapshot = Read(snapshotPath);
            Require(Text(m213["schema"]) == "forever-home-m213-kitchen-margin-sensitivity-v1" && Text(m213["status"]) == "pass", "Unexpected M213 result contract.");
            Require(Text(m279["schema"]) == "forever-home-m279-kitchen-porch-integration-screen-v1" && Text(m279["status"]) == "source-bound orientation comparison; no kitchen/island/pantry/room placement selected", "Unexpected M279 result contract.");
            Require(Text(snapshot["schema"]) == "forever-home-m279-m186-obstacle-snapshot-v1" && Text(snapshot["selected_d_sha256"]) == SelectedDHash, "M279 obstacle-snapshot provenance mismatch.");

            var m213Candidate = m213["candidate_placements"]?.AsArray().SingleOrDefault()
                ?? throw new InvalidDataException("Expected the single M213 intermediate kitchen candidate.");
            var dimensions = m213["kitchen_test"]?["island_dimensions_ft"]?.AsArray() ?? throw new InvalidDataException("M213 island dimensions are missing.");
            var route = m213Candidate["route_waypoints_ft"]?.AsArray() ?? throw new InvalidDataException("M213 route waypoints are missing.");
            Require(Number(m213["kitchen_test"]?["test_area_sf"]) == 178.875, "M213 test area changed.");
            Require(Number(m213["kitchen_test"]?["tested_cross_section_ft"]) == 13.5 && Number(m213["kitchen_test"]?["tested_depth_ft"]) == 13.25, "M213 envelope dimensions changed.");
            Require(dimensions.Count == 2 && Number(dimensions[0]) == 8 && Number(dimensions[1]) == 4, "M213 no longer carries the owner-priority 8 x 4 ft island.");
            Require(Text(m213["route_contract"]?["kitchen_living_connection"]) == "fully_open_owner_preference" && Text(m213["route_contract"]?["M06_B_status"]) == "Unassigned room-block gap only; not a bath footprint.", "M213 owner route/status constraints changed.");
            Require(Text(m213Candidate["route_found"]) == "true" && Number(m213Candidate["route_length_ft"]) == 33.5 && Number(m213Candidate["route_turns"]) == 4 && route.Count == 5, "M213 route evidence changed.");
            Require(Number(m213Candidate["protected_A_original_boundary_gap_ft"]) == 0.25 && Number(m213Candidate["minimum_modeled_obstacle_gap_ft"]) == 0 && Text(m213Candidate["route_nonfragile"]) == "false", "M213 route fragility boundary changed.");

            var compactCases = m279["cases"]?.AsArray() ?? throw new InvalidDataException("M279 candidate list is missing.");
            Require(compactCases.Count == 4, "Expected four bounded M279 orientation/island cases.");
            Require(compactCases.All(c => Number(c?["IslandLengthFt"]) is 6 or 7), "M279 no longer represents only the documented compact-island sensitivities.");
            var pantry = snapshot["obstacles"]?.AsArray()?.FirstOrDefault(o => Text(o?["id"]) == "M-04-pantry-5x6-A-B-clear")
                ?? throw new InvalidDataException("M279 5 x 6 pantry proxy is missing.");
            Require(Number(pantry["w"]) == 5 && Number(pantry["d"]) == 6, "M279 pantry proxy changed.");
            var clearCompact = compactCases.Count(c => Text(c?["RoomPassesFixedBlockScreen"]) == "true" && Text(c?["RoutePassesOverlay"]) == "true");

            var checks = new[]
            {
                "source M213 report SHA256 pinned", "source M279 report SHA256 pinned", "M279 obstacle snapshot SHA256 pinned", "selected-D fingerprint pinned",
                "M213 schema/status valid", "M279 schema/status valid", "M279 obstacle provenance binds selected-D",
                "owner-priority M213 candidate is 13.5 x 13.25 ft / 178.875 sf", "owner-priority 8 x 4 ft island retained",
                "fully-open preference and B-unassigned constraint retained", "33.5-ft four-turn route is source-bound",
                "route records 3-in original-A gap and zero minimum obstacle gap", "M279 alternatives remain compact 6/7 x 3 sensitivities",
                "M279 pantry is a separate 5 x 6 proxy", "comparison does not conflate different screening methods"
            };
            var report = new
            {
                schema = "forever-home-m281-owner-priority-layout-evidence-crosswalk-v1",
                status = "pass; bounded evidence reconciliation only; no layout selected",
                inputs_sha256 = hashes,
                owner_priority_case = new
                {
                    source = "M213 full-shell route search",
                    kitchen_envelope_ft = new[] { 13.5, 13.25 }, area_sf = 178.875, area_over_168sf_target = 10.875,
                    island_ft = new[] { 8, 4 }, route_ft = 33.5, turns = 4,
                    original_A_boundary_gap_ft = 0.25, minimum_obstacle_gap_ft = 0,
                    nonfragile = false, route_check_count = 31,
                    dining_ft = m213Candidate["dining_rect_ft"], porch_ft = m213Candidate["porch_rect_ft"],
                    pantry_5x6_ft = m213Candidate["pantry_rect_ft"], B_status = Text(m213Candidate["M06_B_status"])
                },
                compact_orientation_cases = compactCases.Select(c => new
                {
                    id = Text(c?["Id"]), island_axis_ft = new[] { Number(c?["Island"]?["W"]), Number(c?["Island"]?["H"]) },
                    island_long_axis_ft = Number(c?["IslandLengthFt"]), pantry_overlap_sf = Number(c?["PantryOverlapSf"]),
                    fixed_block_screen_pass = Text(c?["RoomPassesFixedBlockScreen"]) == "true",
                    inherited_route_overlay_pass = Text(c?["RoutePassesOverlay"]) == "true",
                    kitchen_to_dining_band_ft = Number(c?["UnassignedBandToDiningFt"]), disposition = Text(c?["Disposition"])
                }).ToArray(),
                interpretation = new
                {
                    preferred_lead = "M213 is the owner-aligned next study lead because it preserves the 8 x 4 ft island, small-area search, fully-open preference, shifted dining/porch, and protected-A/B route constraints.",
                    separate_methods = "M213 is a full-shell sampled route search; M279 overlays four compact-island rectangles and an inherited route. Their route gaps and pass labels are not interchangeable.",
                    pantry_conflict = "Both screens currently use a 5 x 6 ft pantry proxy while another source records 5 x 7 ft. Recheck both before promotion; M-04 is not assigned by this report.",
                    m05 = "M-05 remains fixed in the M213/M279 source geometry. The owner has since authorized a separate analysis-only move/reshape study; location, entry orientation, and function fit remain unverified.",
                    compact_case_count_passing_bounded_screens = clearCompact
                },
                checks = new { passed = checks.Length, total = checks.Length, status = "pass" },
                limitations = new[]
                {
                    "M213 is one sampled route-qualified case, not a global minimum or a selected kitchen dimension; it has zero minimum modeled obstacle gap and is explicitly flagged fragile.",
                    "The original west-A gap is 3 in only to the M06-A boundary; the route touches another expanded search obstacle. This is proxy geometry, not an M-06 fixture or code clearance.",
                    "M279's compact-island cases do not implement the owner's 8 x 4 ft island priority. The two reports use different coordinate/screening contracts and cannot be combined into one verified plan.",
                    "Pantry size is inconsistent across project records. Door/approach, appliances, exact cabinetry/stool geometry, wall openings, finishes, tolerance, site fit, and services remain unresolved.",
                    "M-05 relocation is not assumed. Selected-D, RVT, IFC, and source RFAs remain untouched. No code-compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows."
                }
            };
            var checkFile = new { schema = "forever-home-m281-checks-v1", status = "pass", passed = checks.Length, total = checks.Length, checks = checks.Select(id => new { id, pass = true }).ToArray() };
            Directory.CreateDirectory(output);
            File.WriteAllText(Path.Combine(output, "m281-layout-crosswalk.json"), JsonSerializer.Serialize(report, Options) + "\n");
            File.WriteAllText(Path.Combine(output, "m281-checks.json"), JsonSerializer.Serialize(checkFile, Options) + "\n");
            Console.WriteLine($"M281 {checks.Length}/{checks.Length} checks passed; preferred lead 178.875 sf with 8 x 4 ft island; sampled route remains fragile at 0 in minimum modeled gap.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"M281 FAILED: {ex}");
            return 1;
        }
    }

    private static string FindRoot()
    {
        for (var d = new DirectoryInfo(Environment.CurrentDirectory); d is not null; d = d.Parent)
            if (File.Exists(Path.Combine(d.FullName, "AGENTS.md")) && (Directory.Exists(Path.Combine(d.FullName, ".git")) || File.Exists(Path.Combine(d.FullName, ".git")))) return d.FullName;
        throw new DirectoryNotFoundException("Repository root with AGENTS.md was not found.");
    }
    private static string Resolve(string root, string path) => Path.GetFullPath(Path.IsPathRooted(path) ? path : Path.Combine(root, path));
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
    private static JsonNode Read(string path) => JsonNode.Parse(File.ReadAllText(path)) ?? throw new InvalidDataException($"Invalid JSON: {path}");
    private static string? Text(JsonNode? n) => n is null ? null : n is JsonValue v && v.TryGetValue<string>(out var s) ? s : n.ToJsonString();
    private static double Number(JsonNode? n) => n is null ? throw new InvalidDataException("Required number is missing.") : double.Parse(n.ToJsonString(), CultureInfo.InvariantCulture);
    private static void Require(bool condition, string message) { if (!condition) throw new InvalidDataException(message); }
}
