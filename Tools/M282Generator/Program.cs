using System.Globalization;
using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string SnapshotHash = "12145EBDF1C065804179242750ABE3D80917F8F23B8DA71B256495B387122910";
    private const string SelectedDHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const string M05AuthorizationHash = "24182CC002ACCD2F661FE2AD14CA7B11B7AFE6770B741572DBDFD8D5FF5417BE";
    private const string M06ProtectionHash = "A5CF98360B75314F4D3486F925E9D860465BB33D1ECFCE9B0CBB39CE0EFF853B";
    private static readonly JsonSerializerOptions Options = new() { WriteIndented = true };
    private sealed record Rect(string Id, double X, double Y, double W, double D);
    private sealed record Position(string Id, double X, double Y, double W, double D, double Area, double MinimumBlockGapToM04In, string EntrySideRelation, string Limitation);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 3) throw new ArgumentException("Usage: M282Generator <source-block-snapshot.json> <authorization-decision.md> <output-directory>");
            var root = FindRoot();
            var snapshotPath = Resolve(root, args[0]);
            var authorizationPath = Resolve(root, args[1]);
            var selectedPath = Path.Combine(root, "Architecture/Selected_Design_Iteration_2026-10-27/study.json");
            var protectionPath = Path.Combine(root, "Decisions/2026-10-31_M06_West_A_Protection.md");
            var output = Resolve(root, args[2]);
            var prefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside the repository.");
            foreach (var path in new[] { snapshotPath, authorizationPath, selectedPath, protectionPath })
                if (!File.Exists(path)) throw new FileNotFoundException("Required M-05 source or authorization is missing.", path);

            var hashes = new Dictionary<string, string>
            {
                ["source_block_snapshot"] = Hash(snapshotPath), ["selected_d"] = Hash(selectedPath),
                ["m05_study_authorization"] = Hash(authorizationPath), ["m06_west_A_protection"] = Hash(protectionPath)
            };
            Require(hashes["source_block_snapshot"] == SnapshotHash, "M282 source-block snapshot changed; review geometry/provenance before replay.");
            Require(hashes["selected_d"] == SelectedDHash, "Selected-D source changed; M282 is fail-closed.");
            Require(hashes["m05_study_authorization"] == M05AuthorizationHash, "M-05 authorization changed; review scope before replay.");
            Require(hashes["m06_west_A_protection"] == M06ProtectionHash, "M-06 A protection decision changed; review exclusions before replay.");

            var snapshot = Read(snapshotPath);
            var selected = Read(selectedPath);
            Require(Text(snapshot["schema"]) == "forever-home-m282-m05-move-source-snapshot-v1", "Unexpected M282 source snapshot.");
            Require(Text(snapshot["source_selected_d_sha256"]) == SelectedDHash && Text(snapshot["source_m256_report_sha256"]) == "8124B2B232B14132D575350EB2A4A6A6AB998583E2B68D24E1099C449EC39AE0", "Snapshot provenance does not match the source M256 checkpoint.");
            Require(Text(selected["selection"]?["main_shell"]) == "40 x 42 ft (B test envelope)", "Selected-D shell test changed.");
            var rooms = snapshot["rooms"]?.AsArray() ?? throw new InvalidDataException("Source room blocks are missing.");
            Rect R(string id)
            {
                var n = rooms.Single(r => Text(r?["id"]) == id);
                return new Rect(id, Num(n?["x"]), Num(n?["y"]), Num(n?["w"]), Num(n?["d"]));
            }
            var living = R("M-01-living-M256-east-6in");
            var kitchen = R("M-02-kitchen-M256-west-6in");
            var dining = R("M-03-dining-source");
            var pantry = R("M-04-pantry-source-5x7");
            var original = R("M-05-entry-hall-source");
            var A = R("protected-A");
            var B = R("unassigned-B");
            var shellW = Num(snapshot["shell_ft"]?[0]);
            var shellD = Num(snapshot["shell_ft"]?[1]);
            Require(Math.Abs(original.W * original.D - 52) < 0.001, "M-05 source area is no longer 52 sf.");
            Require(Math.Abs(kitchen.X - (living.X + living.W) - original.W) < 0.001, "M256 room gap no longer equals the M05 source width.");

            bool Overlap(Rect a, Rect b) => Math.Max(0, Math.Min(a.X + a.W, b.X + b.W) - Math.Max(a.X, b.X)) *
                Math.Max(0, Math.Min(a.Y + a.D, b.Y + b.D) - Math.Max(a.Y, b.Y)) > 1e-5;
            bool InShell(Rect a) => a.X >= -1e-8 && a.Y >= -1e-8 && a.X + a.W <= shellW + 1e-8 && a.Y + a.D <= shellD + 1e-8;
            Rect At(string id, double x, double y) => new(id, x, y, original.W, original.D);
            bool Clear(Rect r) => InShell(r) && new[] { living, kitchen, dining, pantry, A, B }.All(block => !Overlap(r, block));

            var baseline = At("M-05-current", original.X, original.Y);
            var sourceRowPositions = new List<Rect>();
            for (double x = 0; x <= shellW - original.W + 1e-8; x += 0.25)
            {
                var r = At("M-05-source-row-grid", Math.Round(x, 6), original.Y);
                if (Clear(r)) sourceRowPositions.Add(r);
            }
            if (Clear(baseline) && !sourceRowPositions.Any(p => Math.Abs(p.X - baseline.X) < 0.001)) sourceRowPositions.Add(baseline);

            var north = new List<Rect>();
            var northY = shellD - original.D;
            for (double x = 0; x <= shellW - original.W + 1e-8; x += 0.25)
            {
                var r = At("M-05-north-edge-grid", Math.Round(x, 6), northY);
                if (Clear(r)) north.Add(r);
            }
            var east = new List<Rect>();
            var eastX = shellW - original.W;
            for (double y = 0; y <= shellD - original.D + 1e-8; y += 0.25)
            {
                var r = At("M-05-east-edge-grid", eastX, Math.Round(y, 6));
                if (Clear(r)) east.Add(r);
            }
            var northExample = north.FirstOrDefault(r => Math.Abs(r.X - 12) < 0.001) ?? throw new InvalidDataException("Expected source-clear north-edge example was not found.");
            var eastExample = east.FirstOrDefault(r => Math.Abs(r.Y - 24.25) < 0.001) ?? throw new InvalidDataException("Expected source-clear east-edge example was not found.");
            var pantryNorthGap = Math.Max(0, eastExample.Y - (pantry.Y + pantry.D));
            var m04ClearanceIn = pantryNorthGap * 12;
            Require(sourceRowPositions.Count == 1 && Math.Abs(sourceRowPositions[0].X - original.X) < 0.001, "A non-source M05 position unexpectedly passes in the source entry-side row.");
            Require(north.Count > 0 && east.Count > 0, "Expected source-clear north/east shell-edge move alternatives were not found.");
            Require(Math.Abs(m04ClearanceIn - 1) < 0.01, "East-edge example no longer reports the source M04 gap accurately.");
            Require(Math.Abs(kitchen.X - (living.X + living.W) - original.W) < 0.001, "Moving M05 must not be mistaken for closing the room-block gap.");

            var positions = new[]
            {
                ToPosition("current source-row block", baseline, "Source-side relation retained; front orientation is presumed from the room label", "M05 remains in the 4 ft 4 in band between M01 and M02; no direct connection."),
                ToPosition("north-edge envelope example", northExample, "Relocates from the current source-side band to north shell edge", "Exterior contact is not an entry door, approach, or verified preservation of front-entry use."),
                ToPosition("east-edge envelope example", eastExample, "Relocates from the current source-side band to east shell edge", "Only 1 in from source 5 x 7 M04; exterior contact is not an entry door or verified approach.")
            };
            double BoxGapIn(Rect a, Rect b)
            {
                var dx = Math.Max(0, Math.Max(a.X - (b.X + b.W), b.X - (a.X + a.W)));
                var dy = Math.Max(0, Math.Max(a.Y - (b.Y + b.D), b.Y - (a.Y + a.D)));
                return Math.Sqrt(dx * dx + dy * dy) * 12;
            }
            Position ToPosition(string id, Rect r, string side, string limitation) => new(id, r.X, r.Y, r.W, r.D, Math.Round(r.W * r.D, 6), Math.Round(BoxGapIn(r, pantry), 4), side, limitation);

            var checks = new[]
            {
                "source snapshot and M256 checkpoint fingerprints pinned", "selected-D source fingerprint unchanged", "owner authorized separate analysis-only M05 study", "west-A protection instruction pinned",
                "M05 source envelope preserves documented 52-sf area and 4.333 x 12-ft geometry", "40 x 42-ft test shell retained", "M256 living/kitchen blocks retain 4.333-ft gap",
                "only one source-row placement passes fixed room/A/B block screen and it is the source position", "north-edge example remains inside shell and clears fixed room/A/B blocks",
                "east-edge example remains inside shell and clears fixed room/A/B blocks", "north candidate changes presumed entry side", "east candidate is only 1 in from M04 source envelope",
                "M05 move alone does not change 4.333-ft room-block gap", "no door, route, entry approach, or M06 assignment is claimed", "selected-D is not modified"
            };
            var report = new
            {
                schema = "forever-home-m282-m05-move-envelope-screen-v1",
                status = "pass; analysis-only fixed-footprint translation screen; no location selected",
                source_hashes_sha256 = hashes,
                method = "Translate only the source M05 4.333 x 12-ft / 52-sf block on a quarter-foot grid along the south, north, and east edges of the 40 x 42-ft shell; hold M01/M02 at the M256 6-in comparison positions, M03/M04 at selected-D source blocks, and A/B as protected/unassigned rectangles. Do not infer doors, route, or entry function from block contact.",
                geometry = new
                {
                    shell_ft = new[] { shellW, shellD },
                    living_ft = living, kitchen_ft = kitchen, dining_ft = dining, pantry_ft = pantry,
                    M05_source = new { original, area_sf = 52 },
                    protected_A = A, unassigned_B = B,
                    living_to_kitchen_unassigned_band_ft = Math.Round(kitchen.X - (living.X + living.W), 6)
                },
                result = new
                {
                source_row_clear_positions_count = sourceRowPositions.Count,
                source_row_clear_positions = sourceRowPositions.Select(r => new { r.X, r.Y }).ToArray(),
                    north_edge_clear_positions_count = north.Count,
                    north_edge_example = positions[1],
                    east_edge_clear_positions_count = east.Count,
                    east_edge_example = positions[2],
                    examples = positions,
                    direct_room_adjacency_after_move = false,
                    east_example_minimum_block_gap_to_M04_in = m04ClearanceIn,
                    M06_A_or_B_assigned = false,
                    entry_and_route_checked = false
                },
                checks = new { passed = checks.Length, total = checks.Length, status = "pass" },
                limitations = new[]
                {
                    "The north/east examples preserve the source footprint/area and touch a test-shell edge, but they change its presumed front-side relationship; the actual front, exterior door, entry approach and weather/threshold needs are not documented here.",
                    "M05 translation alone does not make M01/M02 share an edge; their 4.333-ft block gap remains unassigned. No large opening or fully open room connection is shown.",
                    "The east example has a 1-in plan-envelope gap to M04; no reserve is established. M04 is 5 x 7 ft from the selected-D source; other studies also use a 5 x 6 ft proxy.",
                    "The screen checks static room/A/B rectangles only. It does not check a circulation route, M-06 fixture/door clearance, site fit, porch, wall assembly, structure, utilities, or actual occupant use.",
                    "Reshaping M05, moving M01/M02, or selecting a new entry location remains a separate design choice. Selected-D/RVT/IFC/source RFAs are unchanged. No compliance, structural, professional, permit, or construction-readiness conclusion follows."
                }
            };
            var checkFile = new { schema = "forever-home-m282-checks-v1", status = "pass", passed = checks.Length, total = checks.Length, checks = checks.Select(id => new { id, pass = true }).ToArray() };
            Directory.CreateDirectory(output);
            File.WriteAllText(Path.Combine(output, "m282-m05-move-screen.json"), JsonSerializer.Serialize(report, Options) + "\n");
            File.WriteAllText(Path.Combine(output, "m282-checks.json"), JsonSerializer.Serialize(checkFile, Options) + "\n");
            Console.WriteLine($"M282 {checks.Length}/{checks.Length} checks passed; source-row positions={sourceRowPositions.Count}, north={north.Count}, east={east.Count}; no entry/route claim.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"M282 FAILED: {ex}");
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
    private static double Num(JsonNode? n) => n is null ? throw new InvalidDataException("Required number is missing.") : double.Parse(n.ToJsonString(), CultureInfo.InvariantCulture);
    private static void Require(bool condition, string message) { if (!condition) throw new InvalidDataException(message); }
}
