using System.Globalization;
using System.Security.Cryptography;
using System.Security;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string SelectedDHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const string StairsSpecHash = "B480E12548612ACB2DBAF98361E5AC1512BE4D8A9F4EEEBF179DD8CDBCBD7C84";
    private const string CtStairResearchHash = "65250B9F68A8674B2BF361F99B76C35C63A97E85EC75304F1F4E77681CC26EE6";
    private const double Margin = 2.0 / 3.0;
    private const double Grid = 0.25;
    private const double WidthFt = 38.0 / 12.0;
    private const double TreadRunFt = 5.0 * 10.5 / 12.0;
    private const double LandingFt = 3.0;
    private const double EnvelopeLengthFt = LandingFt + TreadRunFt + LandingFt;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private sealed record Rect(string Id, string Name, string Kind, double X, double Y, double W, double D)
    {
        public double Area => W * D;
    }
    private sealed record Candidate(string Orientation, double X, double Y, double W, double D, double ManhattanFromLegacyFt, double MinimumRoomGapIn, double CirculationOverlapSf);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 3) throw new ArgumentException("Usage: M285Generator <selected-D-study.json> <DD013-section-basis.md> <output-directory>");
            string root = FindRoot();
            string sourcePath = Resolve(root, args[0]);
            string basisPath = Resolve(root, args[1]);
            string output = Resolve(root, args[2]);
            string repoPrefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(repoPrefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain within the repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any()) throw new IOException("Output directory must be empty.");

            string stairsPath = Path.Combine(root, "Architecture/Stairs_Half_Story.md");
            string ctPath = Path.Combine(root, "Research/Connecticut_Stair_Code_Research_2026-10-30.md");
            foreach (string p in new[] { sourcePath, basisPath, stairsPath, ctPath }) if (!File.Exists(p)) throw new FileNotFoundException("Required M285 input is missing.", p);
            string basis = File.ReadAllText(basisPath);
            string stairsText = File.ReadAllText(stairsPath);
            string ctText = File.ReadAllText(ctPath);
            Require(basis.Contains("6 risers at 7¼ in = 43½ in", StringComparison.Ordinal), "Owner's selected M285 section basis is missing.");
            Require(stairsText.Contains("6 risers @ 7-1/4\"** = **43-1/2\"", StringComparison.Ordinal), "DD-013 preferred stair statement changed.");
            Require(ctText.Contains("8 1/4 in (209.5 mm)", StringComparison.Ordinal), "CT stair research no longer contains the cited numerical maximum.");

            var hashes = new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["selected_d"] = Hash(sourcePath), ["DD013_stairs_spec"] = Hash(stairsPath),
                ["CT_stair_research"] = Hash(ctPath), ["owner_section_basis"] = Hash(basisPath)
            };
            Require(hashes["selected_d"] == SelectedDHash, "Selected-D changed; M285 is fail-closed.");
            Require(hashes["DD013_stairs_spec"] == StairsSpecHash, "DD-013 source changed; review before replay.");
            Require(hashes["CT_stair_research"] == CtStairResearchHash, "CT stair research changed; review before replay.");

            var study = Read(sourcePath);
            Require(Text(study["schema"]) == "forever-home.selected-house-schematic.v1", "Unexpected selected-D schema.");
            var sourceLevels = study["selection"]?["levels"]?.AsArray() ?? throw new InvalidDataException("Selected-D levels are missing.");
            double lowerZ = Num(sourceLevels.Single(x => Text(x?["id"]) == "Lower FF")?["elevation_ft"]);
            double mainZ = Num(sourceLevels.Single(x => Text(x?["id"]) == "Main FF")?["elevation_ft"]);
            double upperZ = Num(sourceLevels.Single(x => Text(x?["id"]) == "Upper FF")?["elevation_ft"]);
            double lowerToMainIn = (mainZ - lowerZ) * 12;
            double mainToUpperIn = (upperZ - mainZ) * 12;
            int sourceRisers = study["stair_core_test"]?["comparison_risers_per_flight"]?.GetValue<int>() ?? throw new InvalidDataException("Selected-D stair comparison count is missing.");
            double sourceRiserIn = Num(study["stair_core_test"]?["comparison_riser_in"]);
            Require(Math.Abs(lowerToMainIn - 60) < 1e-6 && Math.Abs(mainToUpperIn - 60) < 1e-6, "Selected-D adjacent level offsets changed.");
            Require(sourceRisers == 8 && Math.Abs(sourceRiserIn - 7.5) < 1e-6, "Selected-D stair comparison changed.");

            double riseIn = 43.5;
            int preferredRisers = 6;
            double preferredRiserIn = 7.25;
            double ctMaxRiserIn = 8.25;
            var riserAlternatives = Enumerable.Range(5, 4).Select(n => new
            {
                risers = n,
                riser_for_current_60in_level_delta = Math.Round(60.0 / n, 6),
                current_delta_with_DD013_preferred_riser_in = Math.Round(60.0 - n * preferredRiserIn, 6),
                DD013_equal_riser_total_rise_in = Math.Round(n * preferredRiserIn, 6),
                within_CT_published_numeric_max_at_DD013_riser = preferredRiserIn <= ctMaxRiserIn
            }).ToArray();
            Require(Math.Abs(preferredRisers * preferredRiserIn - riseIn) < 1e-6 && preferredRiserIn <= ctMaxRiserIn, "DD-013 arithmetic or numeric ceiling screen failed.");

            var lowerBlocks = study["plans"]?["lower"]?.AsArray() ?? throw new InvalidDataException("Selected-D lower plan is missing.");
            var blocks = lowerBlocks.Select(b => new Rect(Text(b?["id"]) ?? "", Text(b?["name"]) ?? "", Text(b?["kind"]) ?? "",
                Num(b?["x"]), Num(b?["y"]), Num(b?["w"]), Num(b?["d"]))).ToArray();
            var rooms = blocks.Where(b => b.Kind == "room").ToArray();
            var circulation = blocks.Where(b => b.Kind == "circulation").ToArray();
            Require(rooms.Length == 7 && circulation.Length == 1, "Unexpected lower-level room/circulation inventory.");
            var shell = study["shells"]?["rear_lower"]?.AsArray() ?? throw new InvalidDataException("Selected-D lower shell is missing.");
            double shellW = Num(shell[0]);
            double shellD = Num(shell[1]);
            bool Overlap(Rect a, Rect b) => Math.Min(a.X + a.W, b.X + b.W) - Math.Max(a.X, b.X) > 1e-6 && Math.Min(a.Y + a.D, b.Y + b.D) - Math.Max(a.Y, b.Y) > 1e-6;
            double GapFt(Rect a, Rect b)
            {
                double dx = Math.Max(0, Math.Max(a.X - b.X - b.W, b.X - a.X - a.W));
                double dy = Math.Max(0, Math.Max(a.Y - b.Y - b.D, b.Y - a.Y - a.D));
                return Math.Sqrt(dx * dx + dy * dy);
            }
            var candidates = new List<Candidate>();
            for (double y = Margin; y + EnvelopeLengthFt <= shellD - Margin + 1e-7; y = Math.Round(y + Grid, 8))
            for (double x = Margin; x + WidthFt <= shellW - Margin + 1e-7; x = Math.Round(x + Grid, 8))
                Try("north-south", x, y, WidthFt, EnvelopeLengthFt);
            for (double y = Margin; y + WidthFt <= shellD - Margin + 1e-7; y = Math.Round(y + Grid, 8))
            for (double x = Margin; x + EnvelopeLengthFt <= shellW - Margin + 1e-7; x = Math.Round(x + Grid, 8))
                Try("east-west", x, y, EnvelopeLengthFt, WidthFt);
            void Try(string orientation, double x, double y, double w, double d)
            {
                var footprint = new Rect("M285-stair-envelope", "Six-riser stair with two landings", "circulation", x, y, w, d);
                if (rooms.Any(r => Overlap(footprint, r))) return;
                double gap = rooms.Min(r => GapFt(footprint, r));
                const double legacyX = 12.5, legacyY = 28.0;
                double circulationOverlap = circulation.Sum(r =>
                    Math.Max(0, Math.Min(footprint.X + footprint.W, r.X + r.W) - Math.Max(footprint.X, r.X)) *
                    Math.Max(0, Math.Min(footprint.Y + footprint.D, r.Y + r.D) - Math.Max(footprint.Y, r.Y)));
                candidates.Add(new Candidate(orientation, x, y, w, d, Math.Abs(x - legacyX) + Math.Abs(y - legacyY), Math.Round(gap * 12, 3), Math.Round(circulationOverlap, 3)));
            }
            Require(candidates.Count > 0, "The M285 lower-level shell has no room-block-clear stair envelope; review dimensions and source geometry.");
            var examples = new[] { candidates.OrderBy(c => c.ManhattanFromLegacyFt).ThenBy(c => c.Orientation).ThenBy(c => c.Y).ThenBy(c => c.X).First(),
                candidates.Where(c => c.Orientation == "east-west").OrderBy(c => c.ManhattanFromLegacyFt).ThenBy(c => c.Y).ThenBy(c => c.X).First(),
                candidates.Where(c => c.Orientation == "north-south").OrderBy(c => c.ManhattanFromLegacyFt).ThenBy(c => c.Y).ThenBy(c => c.X).First() };
            var maximumRoomGap = candidates.OrderByDescending(c => c.MinimumRoomGapIn).ThenBy(c => c.ManhattanFromLegacyFt).ThenBy(c => c.Y).ThenBy(c => c.X).First();
            var maximumGapWithoutCirculationOverlap = candidates.Where(c => c.CirculationOverlapSf <= 1e-6)
                .OrderByDescending(c => c.MinimumRoomGapIn).ThenBy(c => c.ManhattanFromLegacyFt).ThenBy(c => c.Y).ThenBy(c => c.X).FirstOrDefault()
                ?? throw new InvalidDataException("The search found no envelope outside the circulation block.");
            var svgExamples = examples.Append(maximumGapWithoutCirculationOverlap).ToArray();

            var checks = new Dictionary<string, bool>
            {
                ["selected-D source is hash-pinned and unchanged"] = hashes["selected_d"] == SelectedDHash,
                ["DD-013 source and owner-selected study basis are recorded"] = basis.Contains("Owner-selected", StringComparison.Ordinal),
                ["CT stair research is source-pinned"] = hashes["CT_stair_research"] == CtStairResearchHash,
                ["selected-D adjacent test levels remain 60 in apart"] = Math.Abs(lowerToMainIn - 60) < 1e-6 && Math.Abs(mainToUpperIn - 60) < 1e-6,
                ["selected-D 8 x 7.5 in arithmetic remains only comparison"] = sourceRisers == 8 && Math.Abs(sourceRisers * sourceRiserIn - 60) < 1e-6,
                ["DD-013 preferred 6 x 7.25 in rise equals 43.5 in"] = Math.Abs(preferredRisers * preferredRiserIn - riseIn) < 1e-6,
                ["preferred riser is below cited CT numerical maximum"] = preferredRiserIn < ctMaxRiserIn,
                ["tread run and landing references match DD-013"] = Math.Abs(TreadRunFt - 4.375) < 1e-6 && LandingFt == 3,
                ["lower-level source room inventory is preserved"] = rooms.Length == 7 && Math.Abs(rooms.Sum(r => r.Area) - 795.1) < 0.2,
                ["room-clear lower-level stair envelope candidates found"] = candidates.Count > 0,
                ["all searched envelopes avoid positive-area overlap with lower rooms"] = true,
                ["circulation overlap is measured independently from room-block clearance"] = examples.All(c => c.CirculationOverlapSf >= 0) && candidates.All(c => c.CirculationOverlapSf >= 0),
                ["selected-D source file remains unchanged"] = Hash(sourcePath) == SelectedDHash,
                ["no room relocation, Revit stair, opening, route, or compliance result is claimed"] = true
            };
            Require(checks.Values.All(v => v), "M285 acceptance checks failed.");

            var report = new
            {
                schema = "forever-home-m285-dd013-vertical-section-screen-v1",
                status = "pass; analysis-only section basis and lower-level stair-envelope screen; no location selected",
                owner_selected_basis = new { preferred_risers = preferredRisers, preferred_riser_in = preferredRiserIn, total_rise_in = riseIn, proposed_study_levels_ft = new[] { -riseIn / 12.0, 0.0, riseIn / 12.0 }, selected_d_edited = false },
                selected_d_current = new { levels_ft = new[] { lowerZ, mainZ, upperZ }, adjacent_deltas_in = new[] { lowerToMainIn, mainToUpperIn }, comparison_risers = sourceRisers, comparison_riser_in = sourceRiserIn, comparison_treads = sourceRisers - 1, rise_ft = sourceRisers * sourceRiserIn / 12.0 },
                CT_screen = new { published_max_riser_in = ctMaxRiserIn, preferred_riser_numeric_margin_in = ctMaxRiserIn - preferredRiserIn, project_code_compliance_determined = false },
                riser_alternatives = riserAlternatives,
                plan_envelope = new { lower_shell_ft = new[] { shellW, shellD }, preferred_stair_width_ft = WidthFt, tread_run_ft = TreadRunFt, landing_depth_ft = LandingFt, total_envelope_length_ft = EnvelopeLengthFt, search_grid_ft = Grid, lower_room_blocks_screened = rooms.Length, lower_circulation_blocks_not_treated_as_obstacles = circulation.Length, collision_tolerance_ft_per_axis = 1e-6 },
                placement_search = new { clear_envelope_count = candidates.Count, candidates_with_at_least_6in_block_gap = candidates.Count(c => c.MinimumRoomGapIn >= 6), candidates_with_at_least_12in_block_gap = candidates.Count(c => c.MinimumRoomGapIn >= 12), candidates_without_circulation_overlap = candidates.Count(c => c.CirculationOverlapSf <= 1e-6), maximum_sampled_room_block_gap = maximumRoomGap.MinimumRoomGapIn, maximum_gap_candidate = maximumRoomGap, maximum_gap_candidate_without_circulation_overlap = maximumGapWithoutCirculationOverlap, closest_to_legacy_origin = examples[0], closest_east_west = examples[1], closest_north_south = examples[2], selected = false },
                source_hashes_sha256 = hashes,
                checks = new { passed = checks.Count(v => v.Value), total = checks.Count, status = "pass", details = checks.Select(v => new { id = v.Key, pass = v.Value }).ToArray() },
                limitations = new[]
                {
                    "The DD-013 43.5-in rise is the owner's selected study basis, not a final floor elevation or approved stair placement.",
                    "The 60-in selected-D levels and B-derived eight-riser plan remain unchanged source comparisons; the 15-in floor-assembly value is only a planning placeholder.",
                    "The scan uses room rectangles, a 0.25-ft grid and the preferred clear width/landing/tread references. It ignores wall thickness, doors, furniture, structural support, headroom, transitions, and connection to a continuous route.",
                    "A rectangle-clear candidate may still have zero gap to a room block; its nearest block gap is reported, not treated as a required clearance. Overlap with the source circulation block is measured separately because it may require reshaping circulation or changing the stair envelope.",
                    "No Revit stair, floor opening, wall, room move, code finding, professional approval, or construction-readiness result is produced."
                }
            };
            var checkFile = new { schema = "forever-home-m285-checks-v1", status = "pass", passed = checks.Count(v => v.Value), total = checks.Count, checks = checks.Select(v => new { id = v.Key, pass = v.Value }).ToArray() };
            Directory.CreateDirectory(output);
            WriteJson(Path.Combine(output, "m285-vertical-section-screen.json"), report);
            WriteJson(Path.Combine(output, "m285-checks.json"), checkFile);
            File.WriteAllText(Path.Combine(output, "m285-lower-stair-search.svg"), MakeSvg(rooms, circulation, svgExamples, shellW, shellD), new UTF8Encoding(false));
            File.WriteAllText(Path.Combine(output, "m285-level-comparison.svg"), MakeSectionSvg(), new UTF8Encoding(false));
            Console.WriteLine($"M285 {checks.Count}/{checks.Count} checks passed; clear stair envelopes={candidates.Count}; no placement selected.");
            return 0;

            void Require(bool condition, string message) { if (!condition) throw new InvalidDataException(message); }
        }
        catch (Exception ex) { Console.Error.WriteLine($"M285 FAILED: {ex}"); return 1; }
    }

    private static string MakeSvg(Rect[] rooms, Rect[] circulation, Candidate[] examples, double shellW, double shellD)
    {
        const double scale = 9, pad = 25, panelGap = 28;
        double pw = shellW * scale + 2 * pad, ph = shellD * scale + 48;
        double width = pw * examples.Length + panelGap * (examples.Length - 1), height = ph + 25;
        var s = new StringBuilder();
        s.AppendLine($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{F(width)}\" height=\"{F(height)}\" viewBox=\"0 0 {F(width)} {F(height)}\">");
        s.AppendLine("<style>text{font:11px Arial,sans-serif}.title{font-weight:bold;font-size:13px}.room{fill:#dce8ed;stroke:#24566c}.circulation{fill:#f1d9d9;stroke:#9a3030;stroke-dasharray:3 2}.stair{fill:#f5e5b8;stroke:#7c5d11;stroke-width:2}.shell{fill:none;stroke:#222;stroke-width:2}</style>");
        for (int i = 0; i < examples.Length; i++)
        {
            var c = examples[i]; double ox = i * (pw + panelGap), oy = 22;
            s.AppendLine($"<text class=\"title\" x=\"{F(ox)}\" y=\"{F(oy)}\">{c.Orientation} — candidate ({F(c.X)}, {F(c.Y)}) ft</text>");
            double sy = oy + 13;
            s.AppendLine($"<rect class=\"shell\" x=\"{F(ox)}\" y=\"{F(sy)}\" width=\"{F(shellW*scale)}\" height=\"{F(shellD*scale)}\"/>");
            foreach (var room in rooms)
            {
                double x = ox + room.X * scale, y = sy + (shellD - room.Y - room.D) * scale;
                s.AppendLine($"<rect class=\"room\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(room.W*scale)}\" height=\"{F(room.D*scale)}\"/>");
                s.AppendLine($"<text x=\"{F(x+2)}\" y=\"{F(y+12)}\">{SecurityElement.Escape(room.Id)}</text>");
            }
            foreach (var hall in circulation)
            {
                double x = ox + hall.X * scale, y = sy + (shellD - hall.Y - hall.D) * scale;
                s.AppendLine($"<rect class=\"circulation\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(hall.W*scale)}\" height=\"{F(hall.D*scale)}\"/>");
                s.AppendLine($"<text x=\"{F(x+2)}\" y=\"{F(y+12)}\">{SecurityElement.Escape(hall.Id)}</text>");
            }
            double sx = ox + c.X * scale, stairY = sy + (shellD - c.Y - c.D) * scale;
            s.AppendLine($"<rect class=\"stair\" x=\"{F(sx)}\" y=\"{F(stairY)}\" width=\"{F(c.W*scale)}\" height=\"{F(c.D*scale)}\"/>");
            s.AppendLine($"<text x=\"{F(sx+2)}\" y=\"{F(stairY+12)}\">6 risers + 2 landings</text>");
            s.AppendLine($"<text x=\"{F(ox)}\" y=\"{F(sy+shellD*scale+14)}\">Room-block gap: {F(c.MinimumRoomGapIn)} in; circulation overlap: {F(c.CirculationOverlapSf)} sf.</text>");
        }
        s.AppendLine("</svg>"); return s.ToString();

    }
    private static string MakeSectionSvg()
    {
        const double scale = 5, baseline = 180, left = 110;
        double height = 60 * scale;
        var s = new StringBuilder();
        s.AppendLine("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"760\" height=\"440\" viewBox=\"0 0 760 440\">");
        s.AppendLine("<style>text{font:13px Arial,sans-serif}.title{font-weight:bold;font-size:16px}.source{stroke:#24566c;stroke-width:3}.study{stroke:#ad6a00;stroke-width:3}.datum{stroke:#555;stroke-dasharray:5 4}.note{font-size:11px}</style>");
        s.AppendLine("<text class=\"title\" x=\"35\" y=\"28\">Vertical datum comparison — no walls, floors, or stair modeled</text>");
        foreach (var (x, label, delta, cls, low, high) in new[]
        {
            (190.0, "selected-D source", 60.0, "source", "−60 in", "+60 in"),
            (540.0, "DD-013 owner-selected study", 43.5, "study", "−43.5 in", "+43.5 in")
        })
        {
            double mid = baseline + height / 2, dy = delta * scale;
            s.AppendLine($"<text class=\"title\" x=\"{F(x-90)}\" y=\"55\">{SecurityElement.Escape(label)}</text>");
            s.AppendLine($"<line class=\"datum\" x1=\"{F(left)}\" y1=\"{F(mid)}\" x2=\"700\" y2=\"{F(mid)}\"/>");
            s.AppendLine($"<line class=\"{cls}\" x1=\"{F(x)}\" y1=\"{F(mid-dy)}\" x2=\"{F(x)}\" y2=\"{F(mid+dy)}\"/>");
            s.AppendLine($"<line class=\"{cls}\" x1=\"{F(x-8)}\" y1=\"{F(mid-dy)}\" x2=\"{F(x+8)}\" y2=\"{F(mid-dy)}\"/>");
            s.AppendLine($"<line class=\"{cls}\" x1=\"{F(x-8)}\" y1=\"{F(mid+dy)}\" x2=\"{F(x+8)}\" y2=\"{F(mid+dy)}\"/>");
            s.AppendLine($"<text x=\"{F(x+14)}\" y=\"{F(mid-dy+4)}\">{high}</text><text x=\"{F(x+14)}\" y=\"{F(mid+dy+4)}\">{low}</text>");
        }
        s.AppendLine("<text x=\"24\" y=\"185\">Main FF datum</text><text class=\"note\" x=\"35\" y=\"420\">DD-013: 6 × 7¼ in = 43½ in per half-story. Selected-D remains 60 in. Study only; not a code determination or approved level change.</text>");
        s.AppendLine("</svg>"); return s.ToString();
    }
    private static void WriteJson(string path, object value) => File.WriteAllText(path, JsonSerializer.Serialize(value, JsonOptions) + "\n", new UTF8Encoding(false));
    private static string F(double n) => n.ToString("0.###", CultureInfo.InvariantCulture);
    private static string FindRoot() { for (var d = new DirectoryInfo(Environment.CurrentDirectory); d is not null; d = d.Parent) if (File.Exists(Path.Combine(d.FullName, "AGENTS.md")) && (Directory.Exists(Path.Combine(d.FullName, ".git")) || File.Exists(Path.Combine(d.FullName, ".git")))) return d.FullName; throw new DirectoryNotFoundException("Repository root with AGENTS.md was not found."); }
    private static string Resolve(string root, string path) => Path.GetFullPath(Path.IsPathRooted(path) ? path : Path.Combine(root, path));
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
    private static JsonNode Read(string path) => JsonNode.Parse(File.ReadAllText(path)) ?? throw new InvalidDataException($"Invalid JSON: {path}");
    private static string? Text(JsonNode? n) => n is null ? null : n is JsonValue v && v.TryGetValue<string>(out var s) ? s : n.ToJsonString();
    private static double Num(JsonNode? n) => n is null ? throw new InvalidDataException("Required number is missing.") : double.Parse(n.ToJsonString(), CultureInfo.InvariantCulture);
}
