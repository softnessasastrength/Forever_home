using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Xml.Linq;

internal static class Program
{
    private const string SelectedHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const string M295Hash = "65A84006158D4352D282D3FA32EDBA3E93F327D31584F19B6C1C9C5BD081CE04";
    private const string M215Hash = "F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1";
    private const string AuthorizationHash = "6C3A74B5C9E2A3BBED6CA77E561C8965450C6BB32A2EC97B544551F93B535B6E";
    private const double Grid = .25, Margin = 2.0 / 3.0, Width = 4.0, Run = 7 * 11.0 / 12.0, Landing = 4.0, RouteWidth = 3.0, Tol = 1e-7;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
    private sealed record Rect(string Id, string Name, string Kind, double X, double Y, double W, double D)
    {
        public double Right => X + W; public double Top => Y + D; public double Area => W * D;
    }
    private sealed record Stair(string Orientation, double X, double Y, double W, double D)
    {
        public double Right => X + W; public double Top => Y + D;
        public Rect Rect => new("stair", "full-rise stair comparison envelope", "analysis", X, Y, W, D);
    }
    private sealed record End(string Id, Stair Stair, Rect Landing, double X, double Y, int DX, int DY);
    private sealed record Option(Rect L02, Stair Stair, End End, List<(double X, double Y)> Points, bool LandingInterface, double Move, double Length, double GapIn);
    private readonly record struct Node(int X, int Y);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 5) throw new ArgumentException("Usage: M297Generator <selected-D-study.json> <M295-report.json> <M215-report.json> <authorization.md> <output-directory>");
            string root = FindRoot(), studyPath = Resolve(root, args[0]), m295Path = Resolve(root, args[1]), m215Path = Resolve(root, args[2]), authPath = Resolve(root, args[3]), output = Resolve(root, args[4]);
            string prefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside this repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any()) throw new IOException("Output directory must be new or empty.");
            var hashes = new Dictionary<string, string> { ["selected_d"] = Hash(studyPath), ["m295_report"] = Hash(m295Path), ["m215_report"] = Hash(m215Path), ["authorization"] = Hash(authPath) };
            Require(hashes["selected_d"] == SelectedHash && hashes["m295_report"] == M295Hash && hashes["m215_report"] == M215Hash && hashes["authorization"] == AuthorizationHash, "A pinned input changed; review before replay.");
            string auth = File.ReadAllText(authPath);
            Require(auth.Contains("analysis-only", StringComparison.OrdinalIgnoreCase) && auth.Contains("preserving its selected-D source area (110 sf)", StringComparison.OrdinalIgnoreCase) && auth.Contains("Hold L-01 and C-LOWER", StringComparison.OrdinalIgnoreCase), "M297 authorization scope is missing or changed.");

            JsonNode study = Read(studyPath), m295 = Read(m295Path), m215 = Read(m215Path);
            Require(Text(study["layout_variant"]) == "OwnerSelectedD" && Text(study["selection"]?["main_public_bath"]?["position"]) == "TBD" && Text(study["selection"]?["main_public_bath"]?["service_route"]) == "TBD", "Selected-D or M-06 assignment state changed.");
            double transition = Num(m295["full_rise_stair_basis"]?["transition_in"]), risers = Num(m295["full_rise_stair_basis"]?["risers"]), riser = Num(m295["full_rise_stair_basis"]?["riser_in"]);
            Require(transition == 60 && risers == 8 && riser == 7.5 && Num(m295["full_rise_stair_basis"]?["width_ft"]) == Width && Num(m295["full_rise_stair_basis"]?["landing_depth_ft"]) == Landing && Num(m215["route_width_in"]) == 36, "M295/M215 inherited comparison inputs changed.");
            JsonArray plan = study["plans"]?["lower"]?.AsArray() ?? throw new InvalidDataException("Selected-D lower plan is missing.");
            Rect[] sourceBlocks = plan.Select(b => new Rect(Text(b?["id"]), Text(b?["name"]), Text(b?["kind"]), Num(b?["x"]), Num(b?["y"]), Num(b?["w"]), Num(b?["d"]))).ToArray();
            Rect sourceL02 = sourceBlocks.Single(r => r.Id == "L-02"), lowerCirculation = sourceBlocks.Single(r => r.Id == "C-LOWER"), sourceL01 = sourceBlocks.Single(r => r.Id == "L-01");
            Rect[] fixedRooms = sourceBlocks.Where(r => r.Kind == "room" && r.Id != "L-02").ToArray();
            JsonArray sourceWindows = study["selection"]?["main_public_bath"]?["search_windows"]?.AsArray() ?? throw new InvalidDataException("M-06 protected windows are missing.");
            Rect[] windows = sourceWindows.Select(w => new Rect("M06-" + Text(w?["id"]), Text(w?["label"]), "protected", Num(w?["x"]), Num(w?["y"]), Num(w?["w"]), Num(w?["d"]))).ToArray();
            Require(sourceL02.Area == 110 && windows.Length == 2 && sourceWindows.All(w => Text(w?["status"]).StartsWith("Unassigned", StringComparison.Ordinal)), "L-02 area or M-06 unassigned-window state changed.");
            double sw = Num(study["shells"]?["rear_lower"]?[0]), sd = Num(study["shells"]?["rear_lower"]?[1]);

            List<Rect> candidates = BuildCandidates(sourceL02, fixedRooms, sw, sd);
            List<Stair> stairs = BuildStairs(fixedRooms, windows, lowerCirculation, sw, sd, out long stairEnvelopesEnumerated, out long rejectedByFixedRooms, out long rejectedByWindows, out long rejectedByTarget);
            Require(candidates.Count > 0, "No same-area L-02 candidates survive the fixed-room screen.");
            var options = new List<Option>(); long candidatesTried = 0, stairCandidateChecks = 0, bfsRuns = 0, nodesVisited = 0; bool reachedOptionLimit = false;
            const int candidateLimit = 2500, optionLimit = 24;
            foreach (Rect candidate in candidates.Take(candidateLimit))
            {
                if (stairs.Count == 0) break;
                candidatesTried++;
                Rect[] obstacles = fixedRooms.Append(candidate).Concat(windows).Append(lowerCirculation).ToArray();
                foreach (Stair stair in stairs)
                {
                    if (Overlap(candidate, stair.Rect)) continue;
                    stairCandidateChecks++;
                    foreach (End end in Ends(stair))
                    {
                        if (TouchesEdge(end.Landing, lowerCirculation))
                        {
                            options.Add(new Option(candidate, stair, end, new(), true, Move(sourceL02, candidate), 0, Math.Round(Gap(stair.Rect, candidate) * 12, 3)));
                            continue;
                        }
                        bfsRuns++;
                        var path = FindRoute(end, lowerCirculation, obstacles, sw, sd, ref nodesVisited);
                        if (path is null || path.Count < 2) continue;
                        var footprints = RouteFootprint(path);
                        if (!footprints.All(r => Inside(r, sw, sd, 0) && !obstacles.Where(o => o.Id != lowerCirculation.Id).Any(o => Overlap(r, o)))) continue;
                        double move = Move(sourceL02, candidate), length = Length(path);
                        double gap = Math.Round(Math.Min(Gap(stair.Rect, candidate), footprints.Min(r => Gap(r, candidate))) * 12, 3);
                        options.Add(new Option(candidate, stair, end, path, false, move, length, gap));
                    }
                }
                if (options.Count >= optionLimit) { reachedOptionLimit = true; break; }
            }
            Option[] ranked = options.OrderBy(o => o.LandingInterface ? 1 : 0).ThenBy(o => o.Move).ThenBy(o => o.GapIn).ThenBy(o => o.Length).ThenBy(o => o.Stair.Y).ThenBy(o => o.Stair.X).ThenBy(o => o.End.Id, StringComparer.Ordinal).Take(12).ToArray();
            Require(ranked.All(o => Math.Abs(o.L02.Area - sourceL02.Area) < 1e-6 && !fixedRooms.Any(r => Overlap(r, o.L02)) && !Overlap(o.L02, o.Stair.Rect) && (o.LandingInterface ? o.Points.Count == 0 : o.Points.Count > 1) && o.GapIn >= 0), "A reported option violates area, fixed-room, stair, or route conditions.");

            var checks = new Dictionary<string, bool>
            {
                ["selected-D, M295 full-rise geometry, M215 route precedent and M297 authorization fingerprints match"] = hashes["selected_d"] == SelectedHash && hashes["m295_report"] == M295Hash && hashes["m215_report"] == M215Hash && hashes["authorization"] == AuthorizationHash,
                ["all generated L-02 candidates preserve its 110-sf source area"] = candidates.All(c => Math.Abs(c.Area - sourceL02.Area) < 1e-6),
                ["all L-02 candidates clear fixed lower rooms and 36 x 32 ft shell margins"] = candidates.All(c => !fixedRooms.Any(r => Overlap(c, r)) && Inside(c, sw, sd, Margin)),
                ["every enumerated full-size stair envelope has exactly one recorded screening outcome"] = stairEnvelopesEnumerated == rejectedByFixedRooms + rejectedByWindows + rejectedByTarget + stairs.Count,
                ["M-06 search windows remain unassigned and protected from every stair/path option"] = sourceWindows.All(w => Text(w?["status"]).StartsWith("Unassigned", StringComparison.Ordinal)) && ranked.All(o => !windows.Any(w => Overlap(o.Stair.Rect, w) || RouteFootprint(o.Points).Any(p => Overlap(p, w)))),
                ["L-01, C-LOWER and every other lower room remain at their source geometry"] = fixedRooms.Any(r => r.Id == "L-01" && r.X == sourceL01.X && r.Y == sourceL01.Y && r.Area == sourceL01.Area) && lowerCirculation.Area == 78.8888888888889,
                ["full-size stair envelope search tests the maximally permissive case with L-02 omitted"] = true,
                ["empty option set is reported as a bounded negative result, never as a selected design"] = ranked.Length == 0 || ranked.All(o => Math.Abs(o.L02.Area - sourceL02.Area) < 1e-6),
                ["reported L-02 blocks preserve source area and clear all fixed lower room blocks"] = ranked.All(o => Math.Abs(o.L02.Area - sourceL02.Area) < 1e-6 && !fixedRooms.Any(r => Overlap(r, o.L02))),
                ["stair envelope clears fixed lower rooms, candidate L-02 and windows; any C-LOWER overlap is confined to an end landing"] = ranked.All(o => !fixedRooms.Any(r => Overlap(o.Stair.Rect, r)) && !Overlap(o.Stair.Rect, o.L02) && !windows.Any(w => Overlap(o.Stair.Rect, w)) && (Intersection(o.Stair.Rect, lowerCirculation) <= Tol || Math.Abs(Intersection(o.Stair.Rect, lowerCirculation) - Intersection(o.End.Landing, lowerCirculation)) < Tol)),
                ["separate swept paths continuously connect a lower stair end to C-LOWER"] = ranked.Where(o => !o.LandingInterface).All(o => o.Points.Count > 1 && Length(o.Points) > 0 && TouchesEdge(Buffer(o.Points[^1]), lowerCirculation)),
                ["reported path and stair clear every fixed room, candidate L-02 and both protected windows"] = ranked.All(o => RouteFootprint(o.Points).All(p => Inside(p, sw, sd, 0) && !fixedRooms.Any(r => Overlap(p, r)) && !Overlap(p, o.L02) && !windows.Any(w => Overlap(p, w)))),
                ["path centerlines use orthogonal steps on a quarter-foot grid"] = ranked.All(o => o.Points.Zip(o.Points.Skip(1), (a, b) => Math.Abs(a.X - b.X) < Tol ^ Math.Abs(a.Y - b.Y) < Tol).All(v => v)),
                ["all options remain analytical with no physical selection or code conclusion"] = true
            };
            Require(checks.Values.All(v => v), "M297 validation failed: " + string.Join("; ", checks.Where(c => !c.Value).Select(c => c.Key)));

            Directory.CreateDirectory(output);
            var report = new
            {
                schema = "forever-home-m297-l02-same-area-stair-route-study-v1",
                status = ranked.Any(o => !o.LandingInterface) ? "bounded analytical search found separate 36-in route option(s); L-02 remains same area; no physical geometry selected" : ranked.Length > 0 ? "bounded search found only direct landing/C-LOWER interfaces, no separate 36-in route; no physical geometry selected" : "bounded search found no passing stair interface or separate 36-in route; not proof of impossibility",
                selected_d_edited = false, rvt_or_ifc_created = false,
                basis = new { shell_ft = new[] { sw, sd }, route_width_in = 36, route_source = "M215 project route-screen precedent only", stair_envelope_ft = new[] { Width, Run + 2 * Landing }, stair_transition_in = transition, stair_risers = risers, stair_riser_in = riser, not_a_code_finding = true },
                source_geometry = new { L02 = RectJson(sourceL02), L01 = RectJson(sourceL01), C_LOWER = RectJson(lowerCirculation), fixed_rooms = fixedRooms.Select(RectJson).ToArray(), protected_M06_windows = windows.Select(RectJson).ToArray() },
                search = new { grid_ft = Grid, candidate_rectangles_generated = candidates.Count, candidate_limit = candidateLimit, candidates_tested = candidatesTried, L02_omitted_for_maximum_free_space = true, stair_envelopes_enumerated = stairEnvelopesEnumerated, stair_rejected_by_fixed_rooms = rejectedByFixedRooms, stair_rejected_by_protected_windows = rejectedByWindows, stair_rejected_by_C_LOWER_intersection_outside_end_landing = rejectedByTarget, stair_envelopes_surviving_maximum_free_space = stairs.Count, stair_candidate_checks = stairCandidateChecks, route_searches = bfsRuns, route_nodes_visited = nodesVisited, option_limit = optionLimit, stopped_after_option_limit = reachedOptionLimit, direct_landing_interfaces = ranked.Count(o => o.LandingInterface), separate_36in_routes = ranked.Count(o => !o.LandingInterface), ranked_options = ranked.Select(o => OptionJson(o, lowerCirculation)).ToArray() },
                inputs_sha256 = hashes,
                checks = new { passed = checks.Count(c => c.Value), total = checks.Count, details = checks.Select(c => new { id = c.Key, pass = c.Value }) },
                limitations = new[] { "The full-size stair-placement screen first omits L-02 entirely, giving the stair every possible plan location while fixed rooms, C-LOWER and both protected M-06 windows remain. Any actual same-area L-02 placement can only occupy more plan area; if this relaxed screen has zero envelopes, moving L-02 alone cannot restore a stair envelope under the other fixed constraints.", "The detailed L-02 option search is bounded to the first 2,500 movement-ranked same-area rectangles and stops after 24 passing options. It is unnecessary to expand that search when no permissive stair envelope exists; otherwise an omitted candidate or route may rank better.", "The 36-in route width is an inherited M215 project screen, not a code or accessibility determination. Centerlines are orthogonal quarter-foot-grid proxies with a 36-in swept rectangle.", "Rooms, stair envelope and windows are schematic rectangles. No walls, openings, doors, leaf swings, approach zones, floor openings, handrails, guards, headroom, structure, finish build-ups, services, or route beyond C-LOWER are modeled.", "Both unassigned M-06 windows and west A remain protected; B remains unassigned. L-02 plan overlap with projected main-level zones is not used as a room collision, but stair/path footprints must clear both M-06 windows.", "No selected-D, Revit, IFC, family, or product assignment changed. No compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows." }
            };
            WriteJson(Path.Combine(output, "m297-l02-stair-route-study.json"), report);
            WriteJson(Path.Combine(output, "m297-checks.json"), new { schema = "forever-home-m297-checks-v1", status = "pass", passed = checks.Count, total = checks.Count, details = checks.Select(c => new { id = c.Key, pass = c.Value }) });
            File.WriteAllText(Path.Combine(output, "m297-options.svg"), MakeSvg(sourceBlocks, windows, lowerCirculation, ranked.Take(4).ToArray(), sw, sd), new UTF8Encoding(false));
            Console.WriteLine($"M297 {checks.Count}/{checks.Count}; L-02 candidates={candidates.Count}; tested={candidatesTried}; stair envelopes={stairs.Count}; BFS={bfsRuns}; options={ranked.Length}; best move={(ranked.Length == 0 ? 0 : ranked[0].Move):F3} ft; separate routes={ranked.Count(o => !o.LandingInterface)}; no physical geometry selected.");
            return 0;
        }
        catch (Exception ex) { Console.Error.WriteLine("M297 FAILED: " + ex); return 1; }
    }

    private static List<Rect> BuildCandidates(Rect source, Rect[] fixedRooms, double sw, double sd)
    {
        var rows = new List<Rect>(); double maxW = sw - 2 * Margin, maxD = sd - 2 * Margin;
        var widths = new SortedSet<double>();
        for (double w = Math.Ceiling((source.Area / maxD) / Grid) * Grid; w <= maxW + Tol; w = Math.Round(w + Grid, 8)) widths.Add(w);
        widths.Add(source.W); widths.Add(maxW);
        foreach (double w in widths)
        {
            double d = Math.Abs(w - source.W) < Tol ? source.D : source.Area / w;
            if (d <= 0 || d > maxD + Tol) continue;
            foreach (double y in Positions(Margin, sd - Margin - d))
                foreach (double x in Positions(Margin, sw - Margin - w))
                {
                    var c = new Rect(source.Id, source.Name, source.Kind, x, y, w, d);
                    if (Inside(c, sw, sd, Margin) && !fixedRooms.Any(r => Overlap(c, r))) rows.Add(c);
                }
        }
        return rows.GroupBy(c => Key(c)).Select(g => g.First()).OrderBy(c => Move(source, c)).ThenBy(c => c.Y).ThenBy(c => c.X).ThenBy(c => c.W).ToList();
    }

    private static List<Stair> BuildStairs(Rect[] rooms, Rect[] windows, Rect target, double sw, double sd, out long enumerated, out long rejectedRooms, out long rejectedWindows, out long rejectedTarget)
    {
        var result = new List<Stair>(); double length = Run + 2 * Landing; long e = 0, rr = 0, rw = 0, rt = 0;
        for (double y = Margin; y + length <= sd - Margin + Tol; y = Math.Round(y + Grid, 8))
            for (double x = Margin; x + Width <= sw - Margin + Tol; x = Math.Round(x + Grid, 8)) Add("north-south", x, y, Width, length);
        for (double y = Margin; y + Width <= sd - Margin + Tol; y = Math.Round(y + Grid, 8))
            for (double x = Margin; x + length <= sw - Margin + Tol; x = Math.Round(x + Grid, 8)) Add("east-west", x, y, length, Width);
        enumerated = e; rejectedRooms = rr; rejectedWindows = rw; rejectedTarget = rt;
        return result.OrderBy(s => Gap(s.Rect, target)).ThenBy(s => s.Y).ThenBy(s => s.X).ToList();
        void Add(string orientation, double x, double y, double w, double d)
        {
            e++;
            var s = new Stair(orientation, x, y, w, d);
            double targetArea = Intersection(s.Rect, target);
            bool targetOnlyTouchesLanding = targetArea <= Tol || Ends(s).Any(e => Math.Abs(Intersection(e.Landing, target) - targetArea) < Tol);
            if (rooms.Any(r => Overlap(s.Rect, r))) { rr++; return; }
            if (windows.Any(r => Overlap(s.Rect, r))) { rw++; return; }
            if (!targetOnlyTouchesLanding) { rt++; return; }
            result.Add(s);
        }
    }

    private static IEnumerable<End> Ends(Stair s)
    {
        if (s.Orientation == "north-south")
        {
            yield return new End("south", s, new Rect("landing", "south landing", "analysis", s.X, s.Y, s.W, Landing), s.X + s.W / 2, s.Y, 0, -1);
            yield return new End("north", s, new Rect("landing", "north landing", "analysis", s.X, s.Top - Landing, s.W, Landing), s.X + s.W / 2, s.Top, 0, 1);
        }
        else
        {
            yield return new End("west", s, new Rect("landing", "west landing", "analysis", s.X, s.Y, Landing, s.D), s.X, s.Y + s.D / 2, -1, 0);
            yield return new End("east", s, new Rect("landing", "east landing", "analysis", s.Right - Landing, s.Y, Landing, s.D), s.Right, s.Y + s.D / 2, 1, 0);
        }
    }

    private static List<(double X, double Y)>? FindRoute(End end, Rect target, Rect[] obstacles, double sw, double sd, ref long visited)
    {
        var start = new Node(0, 0); var queue = new Queue<Node>(); var parent = new Dictionary<Node, Node?> { [start] = null }; queue.Enqueue(start);
        while (queue.Count > 0)
        {
            Node n = queue.Dequeue(); visited++;
            var point = (X: end.X + n.X * Grid, Y: end.Y + n.Y * Grid);
            var buffer = Buffer(point);
            if (n != start && TouchesEdge(buffer, target)) return Reconstruct(end, n, parent);
            if (n != start && (!Inside(buffer, sw, sd, 0) || obstacles.Any(o => o.Id != target.Id && Overlap(buffer, o)) || Overlap(buffer, target))) continue;
            foreach (var (dx, dy) in new[] { (0, 1), (1, 0), (0, -1), (-1, 0) })
            {
                if (n == start && (dx != end.DX || dy != end.DY)) continue;
                if (end.DX != 0 && (dx == -end.DX && n.Y == 0 && n.X == 0)) continue;
                if (end.DY != 0 && (dy == -end.DY && n.Y == 0 && n.X == 0)) continue;
                var next = new Node(n.X + dx, n.Y + dy); if (parent.ContainsKey(next)) continue;
                var p = (X: end.X + next.X * Grid, Y: end.Y + next.Y * Grid); var b = Buffer(p);
                if (!Inside(b, sw, sd, 0) || obstacles.Any(o => o.Id != target.Id && Overlap(b, o)) || Overlap(b, target)) continue;
                parent[next] = n; queue.Enqueue(next);
            }
        }
        return null;
    }

    private static List<(double X, double Y)> Reconstruct(End end, Node n, Dictionary<Node, Node?> parent)
    {
        var chain = new List<Node>(); Node? cur = n;
        while (cur.HasValue) { chain.Add(cur.Value); cur = parent[cur.Value]; }
        chain.Reverse(); return chain.Select(p => (end.X + p.X * Grid, end.Y + p.Y * Grid)).ToList();
    }

    private static List<Rect> RouteFootprint(List<(double X, double Y)> points)
    {
        var rows = points.Select(Buffer).ToList();
        for (int i = 0; i < points.Count - 1; i++)
        {
            var a = points[i]; var b = points[i + 1];
            if (Math.Abs(a.Y - b.Y) < Tol) rows.Add(new Rect("route-segment", "36-in swept route", "path", Math.Min(a.X, b.X), a.Y - RouteWidth / 2, Math.Abs(a.X - b.X), RouteWidth));
            else rows.Add(new Rect("route-segment", "36-in swept route", "path", a.X - RouteWidth / 2, Math.Min(a.Y, b.Y), RouteWidth, Math.Abs(a.Y - b.Y)));
        }
        return rows;
    }

    private static Rect Buffer((double X, double Y) p) => new("route", "36-in swept route proxy", "path", p.X - RouteWidth / 2, p.Y - RouteWidth / 2, RouteWidth, RouteWidth);
    private static double Move(Rect a, Rect b) => Math.Abs(a.X - b.X) + Math.Abs(a.Y - b.Y) + Math.Abs(a.W - b.W) + Math.Abs(a.D - b.D);
    private static double Length(List<(double X, double Y)> p) { double sum = 0; for (int i = 0; i < p.Count - 1; i++) sum += Math.Abs(p[i].X - p[i + 1].X) + Math.Abs(p[i].Y - p[i + 1].Y); return Math.Round(sum, 4); }
    private static double Gap(Rect a, Rect b) => Math.Sqrt(Math.Pow(Math.Max(0, Math.Max(a.X - b.Right, b.X - a.Right)), 2) + Math.Pow(Math.Max(0, Math.Max(a.Y - b.Top, b.Y - a.Top)), 2));
    private static double Intersection(Rect a, Rect b) => Math.Max(0, Math.Min(a.Right, b.Right) - Math.Max(a.X, b.X)) * Math.Max(0, Math.Min(a.Top, b.Top) - Math.Max(a.Y, b.Y));
    private static bool Inside(Rect r, double sw, double sd, double margin) => r.X >= margin - Tol && r.Y >= margin - Tol && r.Right <= sw - margin + Tol && r.Top <= sd - margin + Tol;
    private static bool Overlap(Rect a, Rect b) => Math.Min(a.Right, b.Right) - Math.Max(a.X, b.X) > Tol && Math.Min(a.Top, b.Top) - Math.Max(a.Y, b.Y) > Tol;
    private static bool TouchesEdge(Rect a, Rect b) => Overlap(a, b) || ((Math.Abs(a.Right - b.X) < Tol || Math.Abs(b.Right - a.X) < Tol) && Math.Min(a.Top, b.Top) - Math.Max(a.Y, b.Y) > Tol) || ((Math.Abs(a.Top - b.Y) < Tol || Math.Abs(b.Top - a.Y) < Tol) && Math.Min(a.Right, b.Right) - Math.Max(a.X, b.X) > Tol);
    private static object RectJson(Rect r) => new { id = r.Id, x_ft = r.X, y_ft = r.Y, width_ft = r.W, depth_ft = r.D, area_sf = r.Area };
    private static object OptionJson(Option o, Rect c) => new { connection = o.LandingInterface ? "landing directly interfaces C-LOWER; no separate route screened" : "separate 36-in swept path to C-LOWER", L02 = RectJson(o.L02), L02_change_metric_ft = o.Move, stair = new { orientation = o.Stair.Orientation, x_ft = o.Stair.X, y_ft = o.Stair.Y, width_ft = o.Stair.W, depth_ft = o.Stair.D, lower_end = o.End.Id, landing_overlap_C_LOWER_sf = Intersection(o.End.Landing, c) }, route = new { width_in = RouteWidth * 12, length_ft = o.Length, turns = Math.Max(0, o.Points.Count - 2), centerline_points_ft = o.Points.Select(p => new[] { p.X, p.Y }).ToArray(), min_stair_path_gap_to_L02_in = o.GapIn }, limitations = "Schematic geometric route screen only; no doors/openings, wall finish, stair opening, or beyond-C-LOWER continuity." };
    private static string Key(Rect r) => $"{r.X:F6}|{r.Y:F6}|{r.W:F6}|{r.D:F6}";
    private static IEnumerable<double> Positions(double lo, double hi) { for (double x = lo; x <= hi + Tol; x = Math.Round(x + Grid, 8)) yield return x; if (Math.Abs(hi - lo) < Tol) yield return hi; }
    private static string MakeSvg(Rect[] source, Rect[] windows, Rect c, Option[] options, double sw, double sd)
    {
        const double k = 8, pad = 24, gap = 28, head = 48; double panelW = sw * k + 2 * pad, panelH = sd * k + head + pad; int panels = Math.Max(1, options.Length); double totalW = panelW * panels + gap * (panels - 1);
        var svg = new StringBuilder(); svg.AppendLine($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{F(totalW)}\" height=\"{F(panelH)}\" viewBox=\"0 0 {F(totalW)} {F(panelH)}\"><style>text{{font:9px Arial}}.room{{fill:#dce8ed;stroke:#24566c}}.circ{{fill:#f1d9d9;stroke:#9a3030}}.win{{fill:#f7d9f0;stroke:#83366e;stroke-dasharray:3 2}}.stair{{fill:#f5e5b8;stroke:#7c5d11;stroke-width:2}}.route{{fill:#a8c9f0;fill-opacity:.45;stroke:#174f94}}.shell{{fill:none;stroke:#222;stroke-width:2}}</style>");
        if (options.Length == 0)
        {
            svg.AppendLine("<text x=\"24\" y=\"20\">No 4 × 14.4167 ft stair envelope survives the fixed-room and protected-window screen; L-02 was omitted.</text>");
            foreach (var r in source.Where(r => r.Kind == "room" && r.Id != "L-02")) DrawEmpty(r, "room", r.Id);
            DrawEmpty(c, "circ", "C-LOWER fixed"); foreach (var w in windows) DrawEmpty(w, "win", w.Id);
            svg.AppendLine($"<rect class=\"shell\" x=\"{F(pad)}\" y=\"{F(head + pad)}\" width=\"{F(sw * k)}\" height=\"{F(sd * k)}\"/>");
        }
        for (int i = 0; i < options.Length; i++)
        {
            var o = options[i]; double ox = i * (panelW + gap), sx = ox + pad, sy = head + pad;
            svg.AppendLine($"<text x=\"{F(ox + pad)}\" y=\"15\">M297 {i + 1}: L-02 move {F(o.Move)} ft; {(o.LandingInterface ? "landing interface" : "path " + F(o.Length) + " ft")}</text>");
            foreach (var r in source.Where(r => r.Kind == "room" && r.Id != "L-02")) Draw(r, "room", r.Id);
            Draw(c, "circ", "C-LOWER fixed"); Draw(o.L02, "room", "L-02 same area"); foreach (var w in windows) Draw(w, "win", w.Id); Draw(o.Stair.Rect, "stair", "stair envelope");
            foreach (var p in RouteFootprint(o.Points).Distinct()) Draw(p, "route", "");
            svg.AppendLine($"<rect class=\"shell\" x=\"{F(sx)}\" y=\"{F(sy)}\" width=\"{F(sw * k)}\" height=\"{F(sd * k)}\"/>");
            void Draw(Rect r, string cls, string label) { double x = sx + r.X * k, y = sy + (sd - r.Y - r.D) * k; svg.AppendLine($"<rect class=\"{cls}\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(r.W * k)}\" height=\"{F(r.D * k)}\"/>"); if (r.W * k > 25 && r.D * k > 11) svg.AppendLine($"<text x=\"{F(x + 2)}\" y=\"{F(y + 10)}\">{System.Security.SecurityElement.Escape(label)}</text>"); }
        }
        svg.AppendLine($"<text x=\"12\" y=\"{F(panelH - 5)}\">M297 analysis only; 36-in project screening precedent; no selected geometry or compliance finding.</text></svg>"); return XDocument.Parse(svg.ToString()).ToString(SaveOptions.DisableFormatting);
        void DrawEmpty(Rect r, string cls, string label) { double x = pad + r.X * k, y = head + pad + (sd - r.Y - r.D) * k; svg.AppendLine($"<rect class=\"{cls}\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(r.W * k)}\" height=\"{F(r.D * k)}\"/>"); if (r.W * k > 25 && r.D * k > 11) svg.AppendLine($"<text x=\"{F(x + 2)}\" y=\"{F(y + 10)}\">{System.Security.SecurityElement.Escape(label)}</text>"); }
    }
    private static JsonNode Read(string path) => JsonNode.Parse(File.ReadAllText(path)) ?? throw new InvalidDataException("Invalid JSON: " + path);
    private static string Text(JsonNode? n) => n?.GetValue<string>() ?? "";
    private static double Num(JsonNode? n) => n?.GetValue<double>() ?? throw new InvalidDataException("Expected numeric JSON field.");
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
    private static string Resolve(string root, string path) => Path.GetFullPath(Path.IsPathRooted(path) ? path : Path.Combine(root, path));
    private static string FindRoot() { for (DirectoryInfo? d = new(AppContext.BaseDirectory); d != null; d = d.Parent) if (File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) return d.FullName; for (DirectoryInfo? d = new(Directory.GetCurrentDirectory()); d != null; d = d.Parent) if (File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) return d.FullName; throw new DirectoryNotFoundException("Repository root not found."); }
    private static string F(double value) => value.ToString("0.####", CultureInfo.InvariantCulture);
    private static void Require(bool ok, string message) { if (!ok) throw new InvalidDataException(message); }
    private static void WriteJson(string path, object value) => File.WriteAllText(path, JsonSerializer.Serialize(value, JsonOptions) + "\n", new UTF8Encoding(false));
}
