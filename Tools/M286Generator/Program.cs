using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string SelectedDHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const string M285Hash = "66FBF95A7D7AB07A71F0F2F1FAEBCACA67493344290A21DE0CE6E3F9E0C09F6C";
    private const string M285BasisHash = "B2073D1B2C7E2B1AEF389B69C9E4121E161452F66A1654358BA2012EDCECF59B";
    private const string AuthorizationHash = "A834C5BFD3248E488B94A6D35CE7AEFDCE32BCA00DE075AC2501E582EE17C5EC";
    private const double MarginFt = 2.0 / 3.0;
    private const double GridFt = 0.25;
    private const double StairW = 38.0 / 12.0;
    private const double StairRun = 5 * 10.5 / 12.0;
    private const double Landing = 3.0;
    private const double StairD = Landing + StairRun + Landing;
    private const double Tol = 1e-7;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private sealed record Rect(string Id, string Name, string Kind, double X, double Y, double W, double D)
    {
        public double Area => W * D;
        public double Right => X + W;
        public double Top => Y + D;
    }
    private sealed record Stair(string Orientation, double X, double Y, double W, double D, double WindowGapIn, double CirculationGapIn, double CirculationOverlapSf);
    private sealed record Flex(Rect Rect, Stair Stair, double DisplacementFt, double StairGapIn, double CirculationGapIn, double M06OverlapSf);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 5) throw new ArgumentException("Usage: M286Generator <selected-D-study.json> <M285-report.json> <M285-basis.md> <authorization.md> <output-directory>");
            string root = FindRoot();
            string studyPath = Resolve(root, args[0]);
            string m285Path = Resolve(root, args[1]);
            string basisPath = Resolve(root, args[2]);
            string authorizationPath = Resolve(root, args[3]);
            string output = Resolve(root, args[4]);
            string prefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside this repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any()) throw new IOException("Output directory must be new or empty.");

            var hashes = new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["selected_d"] = Hash(studyPath), ["m285_report"] = Hash(m285Path),
                ["m285_basis"] = Hash(basisPath), ["authorization"] = Hash(authorizationPath)
            };
            Require(hashes["selected_d"] == SelectedDHash, "Selected-D source fingerprint changed; fail closed.");
            Require(hashes["m285_report"] == M285Hash, "M285 report fingerprint changed; review before replay.");
            Require(hashes["m285_basis"] == M285BasisHash, "M285 basis fingerprint changed; review before replay.");
            Require(File.ReadAllText(authorizationPath).Contains("preserve the source room's exact area, 250.5555556 sf", StringComparison.OrdinalIgnoreCase), "Owner scope or area-preservation basis changed.");

            JsonNode study = Read(studyPath);
            JsonNode m285 = Read(m285Path);
            Require(Text(study["layout_variant"]) == "OwnerSelectedD", "Unexpected source layout.");
            Require(Text(m285["status"])?.Contains("no location selected", StringComparison.Ordinal) == true, "M285 input is not the unselected envelope screen.");
            var lower = study["plans"]?["lower"]?.AsArray() ?? throw new InvalidDataException("Missing lower-level plan.");
            var blocks = lower.Select(b => new Rect(Text(b?["id"]) ?? "", Text(b?["name"]) ?? "", Text(b?["kind"]) ?? "",
                Num(b?["x"]), Num(b?["y"]), Num(b?["w"]), Num(b?["d"]))).ToArray();
            Rect flexSource = blocks.Single(b => b.Id == "L-01");
            Require(flexSource.Kind == "room" && Math.Abs(flexSource.Area - 250.55555555555554) < 1e-6, "L-01 source area or role changed.");
            var fixedRooms = blocks.Where(b => b.Kind == "room" && b.Id != "L-01").ToArray();
            var circulation = blocks.Single(b => b.Kind == "circulation");
            var windows = study["selection"]?["main_public_bath"]?["search_windows"]?.AsArray() ?? throw new InvalidDataException("Missing unassigned M-06 search windows.");
            Require(Text(study["selection"]?["main_public_bath"]?["footprint"]) == "TBD" && Text(study["selection"]?["main_public_bath"]?["position"]) == "TBD" && Text(study["selection"]?["main_public_bath"]?["service_route"]) == "TBD", "Selected-D M-06 must remain unassigned.");
            var protectedWindows = windows.Select(w => new Rect("M06-" + Text(w?["id"]), Text(w?["label"]) ?? "", "protected-search-window",
                Num(w?["x"]), Num(w?["y"]), Num(w?["w"]), Num(w?["d"]))).ToArray();
            Require(protectedWindows.Length == 2 && windows.All(w => Text(w?["status"]).StartsWith("Unassigned", StringComparison.Ordinal)), "Expected both unassigned M-06 search windows.");
            var shellArr = study["shells"]?["rear_lower"]?.AsArray() ?? throw new InvalidDataException("Missing lower shell.");
            double shellW = Num(shellArr[0]), shellD = Num(shellArr[1]);
            bool Overlap(Rect a, Rect b) => Math.Min(a.Right, b.Right) - Math.Max(a.X, b.X) > Tol && Math.Min(a.Top, b.Top) - Math.Max(a.Y, b.Y) > Tol;
            double OverlapArea(Rect a, Rect b) => Math.Max(0, Math.Min(a.Right, b.Right) - Math.Max(a.X, b.X)) * Math.Max(0, Math.Min(a.Top, b.Top) - Math.Max(a.Y, b.Y));
            double GapFt(Rect a, Rect b)
            {
                double dx = Math.Max(0, Math.Max(a.X - b.Right, b.X - a.Right));
                double dy = Math.Max(0, Math.Max(a.Y - b.Top, b.Y - a.Top));
                return Math.Sqrt(dx * dx + dy * dy);
            }

            var allStairs = new List<Stair>();
            for (double y = MarginFt; y + StairD <= shellD - MarginFt + Tol; y = Math.Round(y + GridFt, 8))
            for (double x = MarginFt; x + StairW <= shellW - MarginFt + Tol; x = Math.Round(x + GridFt, 8)) AddStair("north-south", x, y, StairW, StairD);
            for (double y = MarginFt; y + StairW <= shellD - MarginFt + Tol; y = Math.Round(y + GridFt, 8))
            for (double x = MarginFt; x + StairD <= shellW - MarginFt + Tol; x = Math.Round(x + GridFt, 8)) AddStair("east-west", x, y, StairD, StairW);
            void AddStair(string orientation, double x, double y, double w, double d)
            {
                var r = new Rect("M286-stair", "M285 six-riser envelope", "analysis", x, y, w, d);
                if (fixedRooms.Any(q => Overlap(r, q)) || protectedWindows.Any(q => Overlap(r, q))) return;
                allStairs.Add(new Stair(orientation, x, y, w, d, Math.Round(protectedWindows.Min(q => GapFt(r, q)) * 12, 3), Math.Round(GapFt(r, circulation) * 12, 3), Math.Round(OverlapArea(r, circulation), 3)));
            }
            Require(allStairs.Count > 0, "No M285 envelope remains after holding fixed rooms, circulation and M-06 windows.");

            double maxW = shellW - 2 * MarginFt, maxD = shellD - 2 * MarginFt;
            double minW = flexSource.Area / maxD;
            var widths = new SortedSet<double>();
            for (double w = Math.Ceiling(minW / GridFt) * GridFt; w <= maxW + Tol; w += GridFt) widths.Add(Math.Round(w, 8));
            widths.Add(Math.Round(minW, 8));
            widths.Add(Math.Round(maxW, 8));
            widths.Add(Math.Round(flexSource.W, 8));
            var flexRects = new List<Rect>();
            foreach (double w in widths)
            {
                double d = flexSource.Area / w;
                if (d > maxD + Tol || d < MarginFt) continue;
                var ys = GridPositions(MarginFt, shellD - MarginFt - d);
                var xs = GridPositions(MarginFt, shellW - MarginFt - w);
                if (Math.Abs(d - flexSource.D) < Tol) ys.Add(flexSource.Y);
                if (Math.Abs(w - flexSource.W) < Tol) xs.Add(flexSource.X);
                foreach (double y in ys)
                foreach (double x in xs)
                {
                    var r = new Rect("L-01", "Lower flexible living", "room", x, y, w, d);
                    if (fixedRooms.Any(q => Overlap(r, q)) || Overlap(r, circulation)) continue;
                    flexRects.Add(r);
                }
            }
            Require(flexRects.Count > 0, "No same-area L-01 candidates clear fixed lower rooms/circulation inside the shell.");

            var pairs = new List<Flex>();
            foreach (var stair in allStairs)
            {
                var sr = new Rect("M286-stair", "M285 six-riser envelope", "analysis", stair.X, stair.Y, stair.W, stair.D);
                foreach (var room in flexRects)
                {
                    if (Overlap(room, sr)) continue;
                    double displacement = Math.Abs(room.X - flexSource.X) + Math.Abs(room.Y - flexSource.Y) + Math.Abs(room.W - flexSource.W) + Math.Abs(room.D - flexSource.D);
                    pairs.Add(new Flex(room, stair, Math.Round(displacement, 4), Math.Round(GapFt(room, sr) * 12, 3), Math.Round(GapFt(room, circulation) * 12, 3), Math.Round(protectedWindows.Sum(w => OverlapArea(room, w)), 3)));
                }
            }
            Require(pairs.Count > 0, "No same-area L-01/stair pairs satisfy fixed-room and shell checks.");
            var sourceShapePairs = pairs.Where(p => Math.Abs(p.Rect.X - flexSource.X) < Tol && Math.Abs(p.Rect.Y - flexSource.Y) < Tol && Math.Abs(p.Rect.W - flexSource.W) < 1e-6 && Math.Abs(p.Rect.D - flexSource.D) < 1e-6).ToArray();
            var sourceNoCirculationOverlap = sourceShapePairs.Where(p => p.Stair.CirculationOverlapSf <= Tol).OrderByDescending(p => p.StairGapIn).ThenBy(p => p.Stair.CirculationGapIn).ThenBy(p => p.Stair.X).ThenBy(p => p.Stair.Y).FirstOrDefault()
                ?? throw new InvalidDataException("No stair envelope pairs with source L-01 while avoiding positive-area circulation overlap.");
            var sourceSmallestCirculationOverlap = sourceShapePairs.Where(p => p.Stair.CirculationOverlapSf > Tol).OrderBy(p => p.Stair.CirculationOverlapSf).ThenByDescending(p => p.StairGapIn).ThenBy(p => p.Stair.X).ThenBy(p => p.Stair.Y).FirstOrDefault()
                ?? throw new InvalidDataException("No source L-01 stair envelope uses the source circulation block.");
            var maximumStairGap = pairs.OrderByDescending(p => p.StairGapIn).ThenBy(p => p.DisplacementFt).ThenBy(p => p.Rect.Y).ThenBy(p => p.Rect.X).First();
            var display = new[] { sourceNoCirculationOverlap, sourceSmallestCirculationOverlap, maximumStairGap };

            var checks = new Dictionary<string, bool>
            {
                ["selected-D source hash is unchanged"] = Hash(studyPath) == SelectedDHash,
                ["M285 source report is hash-pinned"] = Hash(m285Path) == M285Hash,
                ["M285 basis is hash-pinned"] = Hash(basisPath) == M285BasisHash,
                ["owner authorization is hash-pinned"] = Hash(authorizationPath) == AuthorizationHash,
                ["owner authorized a same-area lower L-01 move/reshape study"] = File.ReadAllText(authorizationPath).Contains("analysis only", StringComparison.OrdinalIgnoreCase),
                ["all L-01 candidates preserve source area within numeric tolerance"] = flexRects.All(r => Math.Abs(r.Area - flexSource.Area) < 1e-6),
                ["all L-01 candidates remain inside the lower shell margin"] = flexRects.All(r => r.X >= MarginFt - Tol && r.Y >= MarginFt - Tol && r.Right <= shellW - MarginFt + Tol && r.Top <= shellD - MarginFt + Tol),
                ["all candidate L-01 rooms avoid fixed rooms and circulation"] = flexRects.All(r => !fixedRooms.Any(q => Overlap(r, q)) && !Overlap(r, circulation)),
                ["all paired stair envelopes avoid fixed rooms and M-06 windows; circulation overlap is measured separately"] = allStairs.All(r => { var q = new Rect("", "", "", r.X, r.Y, r.W, r.D); return !fixedRooms.Any(x => Overlap(q, x)) && !protectedWindows.Any(x => Overlap(q, x)) && r.CirculationOverlapSf >= 0; }),
                ["all paired stair envelopes avoid the reshaped L-01 block"] = pairs.All(p => !Overlap(p.Rect, new Rect("", "", "", p.Stair.X, p.Stair.Y, p.Stair.W, p.Stair.D))) && pairs.Count > 0,
                ["source L-01 position and shape remain represented in the comparison"] = sourceShapePairs.Length > 0,
                ["M-06 remains unassigned and the two search windows remain reportable"] = protectedWindows.Length == 2 && Text(study["selection"]?["main_public_bath"]?["position"]) == "TBD" && Text(study["selection"]?["main_public_bath"]?["service_route"]) == "TBD",
                ["no candidate is selected and no code/route/buildability claim is made"] = true
            };
            Require(checks.Values.All(v => v), "M286 checks failed.");

            var report = new
            {
                schema = "forever-home-m286-lower-flex-stair-screen-v1",
                status = "pass; same-area L-01 move/reshape paired with analysis-only stair envelopes; no room or stair selected",
                selected_d_edited = false,
                owner_authorized_basis = new { preserve_l01_area_sf = flexSource.Area, m285_rise_in = 43.5, stair_width_in = StairW * 12, tread_count = 5, tread_depth_in = 10.5, landing_depth_in = 36 },
                source_L01 = new { x_ft = flexSource.X, y_ft = flexSource.Y, width_ft = flexSource.W, depth_ft = flexSource.D, area_sf = flexSource.Area },
                search = new { shell_ft = new[] { shellW, shellD }, shell_margin_ft = MarginFt, position_grid_ft = GridFt, sampled_width_count = widths.Count, generated_same_area_rectangles_clear_of_fixed_rooms_and_circulation = flexRects.Count, stair_envelopes_clear_of_fixed_rooms_and_M06_windows = allStairs.Count, compatible_room_stair_pairs = pairs.Count, source_L01_shape_and_position_stair_pairs = sourceShapePairs.Length, source_L01_pairs_without_positive_circulation_overlap = sourceShapePairs.Count(p => p.Stair.CirculationOverlapSf <= Tol), source_L01_best_gap_when_stair_avoids_circulation_in = sourceNoCirculationOverlap.StairGapIn, ranking_is_multicriteria = true },
                examples = display.Select((p, i) => new { label = i == 0 ? "source L-01; stair avoids positive-area overlap with circulation; largest room gap" : i == 1 ? "source L-01; smallest positive stair/circulation overlap" : "reshaped L-01; maximum sampled room/stair gap", l01 = new { p.Rect.X, p.Rect.Y, p.Rect.W, p.Rect.D, area_sf = p.Rect.Area }, stair = new { p.Stair.Orientation, p.Stair.X, p.Stair.Y, p.Stair.W, p.Stair.D, p.Stair.WindowGapIn, p.Stair.CirculationGapIn, p.Stair.CirculationOverlapSf }, stair_gap_in = p.StairGapIn, l01_to_circulation_gap_in = p.CirculationGapIn, l01_overlap_with_projected_m06_windows_sf = p.M06OverlapSf, combined_l01_change_ft = p.DisplacementFt }).ToArray(),
                counts = new { zero_gap_room_stair_pairs = pairs.Count(p => p.StairGapIn <= Tol), pairs_with_at_least_6in_room_stair_gap = pairs.Count(p => p.StairGapIn >= 6), pairs_with_at_least_12in_room_stair_gap = pairs.Count(p => p.StairGapIn >= 12), pairs_where_L01_overlaps_projected_M06_window = pairs.Count(p => p.M06OverlapSf > Tol), stair_envelopes_overlapping_circulation_rectangle = allStairs.Count(s => s.CirculationOverlapSf > Tol), stair_envelopes_touching_circulation_without_positive_area_overlap = allStairs.Count(s => s.CirculationGapIn <= Tol && s.CirculationOverlapSf <= Tol), stair_envelopes_within_36in_of_circulation_rectangle = allStairs.Count(s => s.CirculationGapIn <= 36) },
                inputs_sha256 = hashes,
                checks = new { passed = checks.Count(v => v.Value), total = checks.Count, details = checks.Select(v => new { id = v.Key, pass = v.Value }).ToArray() },
                limitations = new[]
                {
                    "L-01 widths are sampled every 3 in between geometric shell limits; depths are calculated to preserve its source area exactly. These are search candidates, not owner-selected dimensions.",
                    "The search uses source room rectangles, a 6-riser/two-landing rectangle and quarter-foot placement grid. Stair-envelope overlap with the source circulation block is measured, not treated as a collision or accepted route. Walls, door swings, routes, furniture, light, egress, headroom, floor openings, structure and services are not modeled.",
                    "M-06 A/B are main-level projected windows used as stair/floor-opening reservations. L-01 overlap with their plan projection is reported but not prohibited because they are different levels; this is not a coordinated section.",
                    "A positive room-to-stair rectangle gap is descriptive only and is not a required clearance. No Revit elements, levels, room assignments or IFC were generated.",
                    "No code compliance, accessibility, professional approval, structural safety or construction readiness is established."
                }
            };
            Directory.CreateDirectory(output);
            WriteJson(Path.Combine(output, "m286-lower-flex-stair-screen.json"), report);
            WriteJson(Path.Combine(output, "m286-checks.json"), new { schema = "forever-home-m286-checks-v1", status = "pass", passed = checks.Count, total = checks.Count, details = checks.Select(v => new { id = v.Key, pass = v.Value }) });
            File.WriteAllText(Path.Combine(output, "m286-plan.svg"), MakeSvg(blocks, protectedWindows, display, shellW, shellD), new UTF8Encoding(false));
            Console.WriteLine($"M286 {checks.Count}/{checks.Count} checks passed; same-area L-01 rectangles={flexRects.Count}; M285 stair envelopes={allStairs.Count}; compatible pairs={pairs.Count}; no selection made.");
            return 0;

            SortedSet<double> GridPositions(double min, double max)
            {
                var result = new SortedSet<double>();
                for (double v = MarginFt; v <= max + Tol; v = Math.Round(v + GridFt, 8)) result.Add(v);
                result.Add(Math.Round(min, 8));
                result.Add(Math.Round(max, 8));
                return new SortedSet<double>(result.Where(v => v >= MarginFt - Tol && v <= max + Tol).Select(v => Math.Round(v, 8)));
            }
        }
        catch (Exception ex) { Console.Error.WriteLine($"M286 FAILED: {ex}"); return 1; }
    }

    private static string MakeSvg(Rect[] blocks, Rect[] windows, Flex[] examples, double shellW, double shellD)
    {
        const double scale = 10, pad = 25, gap = 28, head = 48;
        double panelW = shellW * scale + 2 * pad, panelH = shellD * scale + head + pad;
        var sb = new StringBuilder();
        sb.AppendLine($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{F(examples.Length * panelW + (examples.Length - 1) * gap)}\" height=\"{F(panelH)}\" viewBox=\"0 0 {F(examples.Length * panelW + (examples.Length - 1) * gap)} {F(panelH)}\">");
        sb.AppendLine("<style>text{font:10px Arial,sans-serif}.title{font-weight:bold;font-size:12px}.room{fill:#dce8ed;stroke:#24566c}.circ{fill:#f1d9d9;stroke:#9a3030;stroke-dasharray:3 2}.window{fill:#f7d9f0;stroke:#83366e;stroke-dasharray:3 2}.flex{fill:#bfd6a6;fill-opacity:.82;stroke:#386527;stroke-width:2}.stair{fill:#f5e5b8;fill-opacity:.85;stroke:#7c5d11;stroke-width:2}.shell{fill:none;stroke:#222;stroke-width:2}</style>");
        for (int i = 0; i < examples.Length; i++)
        {
            var p = examples[i]; var stair = p.Stair;
            double ox = i * (panelW + gap), sx = ox + pad, sy = head + pad;
            string label = i == 0 ? "Source L-01; stair avoids circulation overlap" : i == 1 ? "Source L-01; smallest stair/circulation overlap" : "Reshaped L-01; largest room/stair gap";
            sb.AppendLine($"<text class=\"title\" x=\"{F(ox+pad)}\" y=\"17\">{label}</text>");
            sb.AppendLine($"<text x=\"{F(ox+pad)}\" y=\"33\">L-01 {F(p.Rect.W)} × {F(p.Rect.D)} ft; area {F(p.Rect.Area)} sf; stair gap {F(p.StairGapIn)} in</text>");
            foreach (var b in blocks.Where(b => b.Id != "L-01"))
            {
                string cls = b.Kind == "circulation" ? "circ" : "room";
                Draw(b, cls, b.Id);
            }
            foreach (var w in windows) Draw(w, "window", w.Id + " reserved");
            Draw(p.Rect, "flex", "L-01 same area");
            Draw(new Rect("", "", "", stair.X, stair.Y, stair.W, stair.D), "stair", "M285 stair envelope");
            sb.AppendLine($"<rect class=\"shell\" x=\"{F(sx)}\" y=\"{F(sy)}\" width=\"{F(shellW*scale)}\" height=\"{F(shellD*scale)}\"/>");
            void Draw(Rect r, string cls, string text)
            {
                double x = sx + r.X * scale, y = sy + (shellD - r.Y - r.D) * scale;
                sb.AppendLine($"<rect class=\"{cls}\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(r.W*scale)}\" height=\"{F(r.D*scale)}\"/>");
                if (r.W * scale > 25 && r.D * scale > 12) sb.AppendLine($"<text x=\"{F(x+2)}\" y=\"{F(y+11)}\">{SecurityElementEscape(text)}</text>");
            }
        }
        sb.AppendLine($"<text x=\"20\" y=\"{F(panelH-5)}\">Analysis only; no room or stair selected; plan rectangles are not door/access/clearance proof.</text></svg>");
        return sb.ToString();
    }

    private static string SecurityElementEscape(string text) => System.Security.SecurityElement.Escape(text) ?? "";
    private static void WriteJson(string p, object value) => File.WriteAllText(p, JsonSerializer.Serialize(value, JsonOptions) + "\n", new UTF8Encoding(false));
    private static JsonNode Read(string p) => JsonNode.Parse(File.ReadAllText(p)) ?? throw new InvalidDataException($"Invalid JSON: {p}");
    private static string Text(JsonNode? n) => n?.GetValue<string>() ?? "";
    private static double Num(JsonNode? n) => n?.GetValue<double>() ?? throw new InvalidDataException("Expected a number.");
    private static string Hash(string p) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(p)));
    private static string Resolve(string root, string p) => Path.GetFullPath(Path.IsPathRooted(p) ? p : Path.Combine(root, p));
    private static string FindRoot()
    {
        for (DirectoryInfo? d = new(AppContext.BaseDirectory); d != null; d = d.Parent) if (File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) return d.FullName;
        for (DirectoryInfo? d = new(Directory.GetCurrentDirectory()); d != null; d = d.Parent) if (File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) return d.FullName;
        throw new DirectoryNotFoundException("Could not locate repository root.");
    }
    private static string F(double n) => n.ToString("0.####", CultureInfo.InvariantCulture);
    private static void Require(bool ok, string message) { if (!ok) throw new InvalidDataException(message); }
}
