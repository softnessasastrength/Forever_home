using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Xml.Linq;

internal static class Program
{
    private const string M302Hash = "73D8ACDC85DF307ADF9782444281C3C7144A30C67DDF7D2F8CACD46F715BF03A";
    private const string M215Hash = "F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1";
    private const string M295Hash = "65A84006158D4352D282D3FA32EDBA3E93F327D31584F19B6C1C9C5BD081CE04";
    private const string AuthorizationHash = "9D695B9E05204514D76974E230E90AAEEE6A4A901A1281D2E54C572ADDEF2C3C";
    private const double Grid = .25, RouteWidth = 3, Margin = 2.0 / 3.0, Tolerance = 1e-7;
    private const int StairSampleLimit = 24, L01SampleLimit = 600, L02SampleLimit = 2000, RouteNodeLimit = 2500;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private sealed record Rect(string Id, double X, double Y, double W, double D)
    {
        public double Right => X + W;
        public double Top => Y + D;
        public double Area => W * D;
    }

    private sealed record End(string Flight, double X, double Y, int Dx, int Dy);
    private readonly record struct Node(int X, int Y);

    private sealed record Corridor(
        int Sample, string RoutedFlight, Rect[] Pieces, Rect LowerLanding, Rect UpperLanding,
        List<(double X, double Y)> Path, int Nodes, bool NodeLimitHit, Rect[] FixedObstacles);

    private sealed record Layout(
        int Sample, int M302Sample, string RoutedFlight, Rect L01, Rect L02, Rect[] Pieces,
        Rect LowerLanding, Rect UpperLanding, List<(double X, double Y)> Path,
        double L01Move, double L02Move, int RouteNodes, Rect[] FixedObstacles);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 5)
                throw new ArgumentException("Usage: M307Generator <M302.json> <M215.json> <M295.json> <authorization.md> <output-dir>");
            string root = FindRoot();
            string m302Path = Resolve(root, args[0]);
            string m215Path = Resolve(root, args[1]);
            string m295Path = Resolve(root, args[2]);
            string authorizationPath = Resolve(root, args[3]);
            string output = Resolve(root, args[4]);
            string rootPrefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(rootPrefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside the repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any()) throw new IOException("Output directory must be empty.");

            var hashes = new { m302 = Hash(m302Path), m215 = Hash(m215Path), m295 = Hash(m295Path), authorization = Hash(authorizationPath) };
            Need(hashes.m302 == M302Hash && hashes.m215 == M215Hash && hashes.m295 == M295Hash && hashes.authorization == AuthorizationHash,
                "A pinned source changed; review before replay.");

            JsonNode m302 = JsonNode.Parse(File.ReadAllText(m302Path))!;
            JsonNode m215 = JsonNode.Parse(File.ReadAllText(m215Path))!;
            JsonNode m295 = JsonNode.Parse(File.ReadAllText(m295Path))!;
            JsonNode source = m302["source"]!;
            double shellW = Number(source["shell_ft"]?[0]), shellD = Number(source["shell_ft"]?[1]);
            double flightWidth = Number(m295["full_rise_stair_basis"]?["width_ft"]);
            double landingDepth = Number(m295["full_rise_stair_basis"]?["landing_depth_ft"]);
            Need(shellW == 38.333333 && shellD == 40 && flightWidth == 4 && landingDepth == 4 && Number(m215["route_width_in"]) == 36,
                "A pinned shell, landing or route reference changed.");

            Rect cLower = ReadRect(source["C_LOWER"]!);
            Rect l01Source = ReadRect(source["movable_L01"]!);
            Rect l02Source = ReadRect(source["fixed_rooms"]!.AsArray().Single(n => Text(n?["id"]) == "L-02")!);
            Rect[] fixedRooms = source["fixed_rooms"]!.AsArray().Select(n => ReadRect(n!))
                .Where(r => r.Id != "L-02" && r.Id != cLower.Id).ToArray();
            Rect[] windows = source["protected_M06_windows"]!.AsArray().Select(n => ReadRect(n!)).ToArray();
            JsonArray samples = m302["search"]!["retained_options"]!.AsArray();
            Need(samples.Count == StairSampleLimit && windows.Length == 2, "Expected 24 inherited stair samples and two protected M-06 windows.");

            Rect[] l01Candidates = BuildRoomCandidates(l01Source, fixedRooms.Append(cLower).Concat(windows).ToArray(), shellW, shellD);
            Rect[] l02Candidates = BuildRoomCandidates(l02Source, fixedRooms.Append(cLower).Concat(windows).ToArray(), shellW, shellD);
            Need(l01Candidates.Length > 0 && l02Candidates.Length > 0, "No same-area room candidates survive the fixed-block screen.");
            Rect[] sampledL02 = SampleSpread(l02Candidates, L02SampleLimit, r => Movement(l02Source, r));

            var corridors = new List<Corridor>();
            int landingAttempts = 0, landingPairsPass = 0, routeAttempts = 0, routePasses = 0, capHits = 0;
            long nodesVisited = 0;
            for (int i = 0; i < samples.Count; i++)
            {
                JsonNode sample = samples[i]!;
                Rect[] pieces = sample["pieces"]!.AsArray().Select(n => ReadRect(n!)).ToArray();
                Rect platform = pieces.Single(p => p.Id == "turn-platform");
                Rect[] flights = pieces.Where(p => p.Id.StartsWith("flight-", StringComparison.Ordinal)).ToArray();
                Need(flights.Length == 2, "Expected two proxy flights around the turn platform.");
                End[] ends = flights.Select(f => OutsideEnd(f, platform)).ToArray();
                Rect[] lands = ends.Select(e => MakeLanding(e, flightWidth, landingDepth)).ToArray();

                foreach (int lowerIndex in new[] { 0, 1 })
                {
                    landingAttempts += 2;
                    Rect lowerLanding = lands[lowerIndex], upperLanding = lands[1 - lowerIndex];
                    Rect[] landingBlockers = fixedRooms.Concat(windows).Concat(pieces).ToArray();
                    bool landingsFit = Inside(lowerLanding, shellW, shellD, Margin) &&
                        Inside(upperLanding, shellW, shellD, Margin) &&
                        !Overlap(lowerLanding, upperLanding) &&
                        !landingBlockers.Any(b => Overlap(lowerLanding, b) || Overlap(upperLanding, b));
                    if (!landingsFit) continue;
                    landingPairsPass++;
                    Rect[] obstacles = fixedRooms.Concat(windows).Concat(pieces).Append(lowerLanding).Append(upperLanding).ToArray();
                    End routeStart = BeyondLanding(ends[lowerIndex], lowerLanding);
                    int visited = 0;
                    routeAttempts++;
                    List<(double X, double Y)>? path = FindRoute(routeStart, cLower, obstacles, shellW, shellD, RouteNodeLimit, ref visited, out bool capped);
                    nodesVisited += visited;
                    if (capped) capHits++;
                    if (path is null) continue;
                    routePasses++;
                    Need(path.All(p => Inside(Buffer(p), shellW, shellD, 0) && !obstacles.Any(o => Overlap(Buffer(p), o))) && Touches(Buffer(path[^1]), cLower),
                        "A retained landing route collides with a screened block.");
                    corridors.Add(new Corridor(i + 1, ends[lowerIndex].Flight, pieces, lowerLanding, upperLanding, path, visited, capped, obstacles));
                }
            }

            var layouts = new List<Layout>();
            long roomPairs = 0;
            var corridorDiagnostics = new List<object>();
            foreach (Corridor corridor in corridors)
            {
                Rect[] routeRects = RouteRects(corridor.Path);
                Rect[] l01Clear = l01Candidates.Where(l01 =>
                    !corridor.Pieces.Any(p => Overlap(l01, p)) && !Overlap(l01, corridor.LowerLanding) &&
                    !Overlap(l01, corridor.UpperLanding) && !routeRects.Any(r => Overlap(l01, r))).ToArray();
                corridorDiagnostics.Add(new { sample = corridor.Sample, routed_flight = corridor.RoutedFlight,
                    lower_landing = J(corridor.LowerLanding), upper_landing = J(corridor.UpperLanding),
                    route_length_ft = Length(corridor.Path), L01_candidates_clear = l01Clear.Length });
                Rect[] l01ForCorridor = SampleSpread(l01Clear,
                    L01SampleLimit, r => Movement(l01Source, r));
                foreach (Rect l01 in l01ForCorridor)
                {
                    foreach (Rect l02 in sampledL02)
                    {
                        roomPairs++;
                        if (Overlap(l01, l02) || corridor.Pieces.Any(p => Overlap(l02, p)) ||
                            Overlap(l02, corridor.LowerLanding) || Overlap(l02, corridor.UpperLanding) ||
                            routeRects.Any(r => Overlap(l02, r))) continue;
                        var obstacles = corridor.FixedObstacles.Append(l01).Append(l02).Concat(routeRects).ToArray();
                        if (!corridor.Path.All(p => Inside(Buffer(p), shellW, shellD, 0) && !obstacles.Any(o => Overlap(Buffer(p), o)))) continue;
                        layouts.Add(new Layout(corridor.Sample, corridor.Sample, corridor.RoutedFlight,
                            l01, l02, corridor.Pieces, corridor.LowerLanding, corridor.UpperLanding, corridor.Path,
                            Movement(l01Source, l01), Movement(l02Source, l02), corridor.Nodes, corridor.FixedObstacles));
                        break;
                    }
                }
            }

            Layout[] ranked = layouts.OrderBy(x => x.L01Move + x.L02Move).ThenBy(x => x.Sample).ThenBy(x => x.RoutedFlight)
                .GroupBy(x => $"{x.Sample}|{x.RoutedFlight}|{x.L01.X:F5}|{x.L01.Y:F5}|{x.L02.X:F5}|{x.L02.Y:F5}")
                .Select(g => g.First()).Take(18).ToArray();
            var checks = new Dictionary<string, bool>
            {
                ["M302/M215/M295/M307 source fingerprints match"] = true,
                ["24 stair samples, both protected M-06 windows, and inherited dimensions are retained"] = samples.Count == 24 && windows.Length == 2 && flightWidth == 4 && landingDepth == 4,
                ["all screened landings fit the shell and clear fixed rooms, windows and stair pieces"] = corridors.All(c => Inside(c.LowerLanding, shellW, shellD, Margin) && Inside(c.UpperLanding, shellW, shellD, Margin)),
                ["all reported room pairs preserve source room areas"] = ranked.All(x => Math.Abs(x.L01.Area - l01Source.Area) < 1e-6 && Math.Abs(x.L02.Area - l02Source.Area) < 1e-6),
                ["every reported 36-in route clears both landings, rooms, stair pieces and fixed obstacles"] = ranked.All(x => x.Path.All(p => Inside(Buffer(p), shellW, shellD, 0) && !x.FixedObstacles.Append(x.L01).Append(x.L02).Any(o => Overlap(Buffer(p), o)))),
                ["no selected-D, Revit, IFC, family, or compliance result is emitted"] = true
            };
            Need(checks.Values.All(v => v), "M307 checks failed.");

            Directory.CreateDirectory(output);
            var report = new
            {
                schema = "forever-home-m307-integrated-two-ended-stair-screen-v1",
                status = ranked.Length > 0 ? "bounded joint room/stair option(s) include both end landing proxies and a lower route; no design selected" : "no joint option found within inherited sample and candidate caps; not proof of impossibility",
                selected_d_edited = false,
                rvt_or_ifc_created = false,
                basis = new
                {
                    shell_ft = new[] { shellW, shellD }, shell_status = "hypothetical/unselected", route_width_in = 36,
                    landing_ft = new[] { landingDepth, flightWidth }, perimeter_margin_in = Margin * 12,
                    L01_area_sf = l01Source.Area, L02_area_sf = l02Source.Area,
                    stair_sample_limit = StairSampleLimit, L01_sample_limit = L01SampleLimit, L02_sample_limit = L02SampleLimit,
                    route_node_limit = RouteNodeLimit, not_a_code_finding = true
                },
                search = new
                {
                    stair_samples = samples.Count, L01_candidates_generated = l01Candidates.Length, L02_candidates_generated = l02Candidates.Length,
                    L01_candidate_cap_per_corridor = L01SampleLimit, L02_candidates_sampled_per_corridor = sampledL02.Length,
                    landing_end_tests = landingAttempts, both_landing_pairs_passing = landingPairsPass,
                    lower_route_attempts = routeAttempts, lower_routes_passing = routePasses,
                    route_node_cap_hits = capHits, route_nodes_visited = nodesVisited, room_pairs_tested = roomPairs,
                    corridors = corridorDiagnostics,
                    joint_layouts_found = layouts.Count, ranked_options = ranked.Select(Describe).ToArray()
                },
                inputs_sha256 = hashes,
                checks = new { passed = checks.Count(c => c.Value), total = checks.Count, details = checks.Select(c => new { id = c.Key, pass = c.Value }) },
                limitations = new[]
                {
                    "The search is bounded to the first 24 retained M302 stair/L-01 samples, 600 movement-spread L-01 candidates, 2,000 movement-spread L-02 candidates per corridor, and the stated route-node cap.",
                    "Only the first compatible L-02 is retained for each sampled L-01/corridor; the result is not an exhaustive layout ranking.",
                    "Each end landing is an inherited 4x4-ft rectangle proxy; the L-turn is a 3+4 aggregate tread-run envelope, not a stair schedule.",
                    "The lower route is a 36-in swept plan proxy to C-LOWER only; no upper-floor route, door/approach, headroom, opening or code basis is checked.",
                    "Wall/finish thickness, tolerance, rails/guards, structure, MEP, site and beyond-C-LOWER circulation are not modeled.",
                    "The larger shell is hypothetical/unselected; no selected-D, Revit, IFC, family or remote state changed.",
                    "No code, accessibility, structural, professional, permit or construction-readiness conclusion follows."
                }
            };
            Write(Path.Combine(output, "m307-integrated-stair-landing-study.json"), report);
            Write(Path.Combine(output, "m307-checks.json"), new { passed = checks.Count(c => c.Value), total = checks.Count, details = checks.Select(c => new { id = c.Key, pass = c.Value }) });
            File.WriteAllText(Path.Combine(output, "m307-integrated-options.svg"), MakeSvg(ranked, fixedRooms.Append(cLower).ToArray(), windows, cLower, shellW, shellD), new UTF8Encoding(false));
            Console.WriteLine($"M307 {checks.Count}/{checks.Count}; stair samples={samples.Count}; landing pairs={landingPairsPass}; lower routes={routePasses}; room pairs={roomPairs}; joint options={layouts.Count}; node caps={capHits}; analysis-only.");
            return 0;
        }
        catch (Exception e)
        {
            Console.Error.WriteLine("M307 FAILED: " + e);
            return 1;
        }
    }

    private static object Describe(Layout x) => new
    {
        stair_sample = x.Sample, M302_sample = x.M302Sample, routed_flight = x.RoutedFlight,
        L01 = J(x.L01), L02 = J(x.L02), lower_landing = J(x.LowerLanding), upper_landing = J(x.UpperLanding),
        stair_pieces = x.Pieces.Select(J).ToArray(), route_length_ft = Length(x.Path), route_nodes_visited = x.RouteNodes,
        L01_move_metric_ft = x.L01Move, L02_move_metric_ft = x.L02Move
    };

    private static End OutsideEnd(Rect f, Rect p)
    {
        if (Math.Abs(f.Right - p.X) < Tolerance) return new End(f.Id, f.X, f.Y + f.D / 2, -1, 0);
        if (Math.Abs(f.X - p.Right) < Tolerance) return new End(f.Id, f.Right, f.Y + f.D / 2, 1, 0);
        if (Math.Abs(f.Top - p.Y) < Tolerance) return new End(f.Id, f.X + f.W / 2, f.Y, 0, -1);
        if (Math.Abs(f.Y - p.Top) < Tolerance) return new End(f.Id, f.X + f.W / 2, f.Top, 0, 1);
        throw new InvalidDataException("Flight is not adjacent to turn platform.");
    }

    private static Rect MakeLanding(End e, double width, double depth)
    {
        if (Math.Abs(width - depth) > Tolerance) throw new InvalidDataException("This comparison uses square end landings.");
        if (e.Dx > 0) return new Rect("landing", e.X, e.Y - width / 2, depth, width);
        if (e.Dx < 0) return new Rect("landing", e.X - depth, e.Y - width / 2, depth, width);
        if (e.Dy > 0) return new Rect("landing", e.X - width / 2, e.Y, width, depth);
        return new Rect("landing", e.X - width / 2, e.Y - depth, width, depth);
    }

    private static End BeyondLanding(End end, Rect landing)
    {
        if (end.Dx > 0) return end with { X = landing.Right, Y = landing.Y + landing.D / 2 };
        if (end.Dx < 0) return end with { X = landing.X, Y = landing.Y + landing.D / 2 };
        if (end.Dy > 0) return end with { X = landing.X + landing.W / 2, Y = landing.Top };
        return end with { X = landing.X + landing.W / 2, Y = landing.Y };
    }

    private static Rect[] BuildRoomCandidates(Rect source, Rect[] fixedBlocks, double shellW, double shellD)
    {
        var candidates = new List<Rect>();
        double maxW = shellW - 2 * Margin, maxD = shellD - 2 * Margin;
        var widths = new SortedSet<double>();
        for (double w = Math.Ceiling((source.Area / maxD) / Grid) * Grid; w <= maxW + Tolerance; w = Math.Round(w + Grid, 8)) widths.Add(w);
        widths.Add(source.W); widths.Add(maxW);
        foreach (double w in widths)
        {
            double d = Math.Abs(w - source.W) < Tolerance ? source.D : source.Area / w;
            if (d <= 0 || d > maxD + Tolerance) continue;
            foreach (double y in Positions(Margin, shellD - Margin - d))
                foreach (double x in Positions(Margin, shellW - Margin - w))
                {
                    var candidate = new Rect(source.Id, x, y, w, d);
                    if (Inside(candidate, shellW, shellD, Margin) && !fixedBlocks.Any(b => Overlap(candidate, b))) candidates.Add(candidate);
                }
        }
        return candidates.GroupBy(r => Key(r)).Select(g => g.First()).OrderBy(r => Movement(source, r)).ThenBy(r => r.Y).ThenBy(r => r.X).ToArray();
    }

    private static Rect[] SampleSpread(Rect[] sorted, int limit, Func<Rect, double> movement)
    {
        if (sorted.Length <= limit) return sorted;
        int near = limit / 2, spread = limit - near;
        var chosen = sorted.Take(near).ToList();
        for (int i = 1; i <= spread; i++)
        {
            int index = near + (int)Math.Floor((double)i * (sorted.Length - near) / (spread + 1));
            chosen.Add(sorted[Math.Min(index, sorted.Length - 1)]);
        }
        return chosen.GroupBy(Key).Select(g => g.First()).OrderBy(movement).ToArray();
    }

    private static IEnumerable<double> Positions(double lo, double hi)
    {
        var values = new SortedSet<double>();
        for (double x = lo; x <= hi + Tolerance; x = Math.Round(x + Grid, 8)) values.Add(x);
        values.Add(hi);
        return values.Where(x => x >= lo - Tolerance && x <= hi + Tolerance).Select(x => Math.Round(x, 8));
    }

    private static string Key(Rect r) => $"{r.X:F6}|{r.Y:F6}|{r.W:F6}|{r.D:F6}";

    private static List<(double X, double Y)>? FindRoute(End e, Rect target, Rect[] obstacles, double shellW, double shellD, int cap, ref int visited, out bool limited)
    {
        var start = new Node(0, 0);
        var queue = new PriorityQueue<Node, (int F, int H, int Order)>();
        var previous = new Dictionary<Node, Node?> { [start] = null };
        int order = 0, h0 = Heuristic(e, start, target);
        queue.Enqueue(start, (h0, h0, order));
        limited = false;
        while (queue.Count > 0)
        {
            if (visited >= cap) { limited = true; return null; }
            Node node = queue.Dequeue(); visited++;
            var point = (X: e.X + e.Dx * RouteWidth / 2 + node.X * Grid, Y: e.Y + e.Dy * RouteWidth / 2 + node.Y * Grid);
            Rect box = Buffer(point);
            if (node != start && Touches(box, target)) return Rebuild(e, node, previous);
            if (node != start && (!Inside(box, shellW, shellD, 0) || obstacles.Any(o => Overlap(box, o)))) continue;
            foreach ((int dx, int dy) in new[] { (0, 1), (1, 0), (0, -1), (-1, 0) })
            {
                if (node == start && (dx != e.Dx || dy != e.Dy)) continue;
                var next = new Node(node.X + dx, node.Y + dy);
                if (previous.ContainsKey(next)) continue;
                var np = (X: e.X + e.Dx * RouteWidth / 2 + next.X * Grid, Y: e.Y + e.Dy * RouteWidth / 2 + next.Y * Grid);
                Rect nb = Buffer(np);
                if (!Inside(nb, shellW, shellD, 0) || obstacles.Any(o => Overlap(nb, o))) continue;
                previous[next] = node;
                int h = Heuristic(e, next, target), g = Math.Abs(next.X) + Math.Abs(next.Y);
                queue.Enqueue(next, (g + h, h, ++order));
            }
        }
        return null;
    }

    private static int Heuristic(End e, Node n, Rect target)
    {
        double x = e.X + e.Dx * RouteWidth / 2 + n.X * Grid, y = e.Y + e.Dy * RouteWidth / 2 + n.Y * Grid, half = RouteWidth / 2;
        double dx = Math.Max(0, Math.Max(target.X - half - x, x - (target.Right + half)));
        double dy = Math.Max(0, Math.Max(target.Y - half - y, y - (target.Top + half)));
        return (int)Math.Floor((dx + dy) / Grid + Tolerance);
    }

    private static List<(double X, double Y)> Rebuild(End e, Node n, Dictionary<Node, Node?> previous)
    {
        var chain = new List<Node>(); Node? current = n;
        while (current.HasValue) { chain.Add(current.Value); current = previous[current.Value]; }
        chain.Reverse();
        return chain.Select(v => (e.X + e.Dx * RouteWidth / 2 + v.X * Grid, e.Y + e.Dy * RouteWidth / 2 + v.Y * Grid)).ToList();
    }

    private static Rect[] RouteRects(List<(double X, double Y)> path)
    {
        var rectangles = path.Select(Buffer).ToList();
        for (int i = 0; i < path.Count - 1; i++)
        {
            var a = path[i]; var b = path[i + 1];
            rectangles.Add(Math.Abs(a.Y - b.Y) < Tolerance
                ? new Rect("route", Math.Min(a.X, b.X), a.Y - RouteWidth / 2, Math.Abs(a.X - b.X), RouteWidth)
                : new Rect("route", a.X - RouteWidth / 2, Math.Min(a.Y, b.Y), RouteWidth, Math.Abs(a.Y - b.Y)));
        }
        return rectangles.ToArray();
    }

    private static Rect Buffer((double X, double Y) p) => new("route", p.X - RouteWidth / 2, p.Y - RouteWidth / 2, RouteWidth, RouteWidth);
    private static bool Inside(Rect r, double w, double d, double m) => r.X >= m - Tolerance && r.Y >= m - Tolerance && r.Right <= w - m + Tolerance && r.Top <= d - m + Tolerance;
    private static bool Overlap(Rect a, Rect b) => Math.Min(a.Right, b.Right) - Math.Max(a.X, b.X) > Tolerance && Math.Min(a.Top, b.Top) - Math.Max(a.Y, b.Y) > Tolerance;
    private static bool Touches(Rect a, Rect b) => Overlap(a, b) ||
        ((Math.Abs(a.Right - b.X) < Tolerance || Math.Abs(b.Right - a.X) < Tolerance) && Math.Min(a.Top, b.Top) - Math.Max(a.Y, b.Y) > Tolerance) ||
        ((Math.Abs(a.Top - b.Y) < Tolerance || Math.Abs(b.Top - a.Y) < Tolerance) && Math.Min(a.Right, b.Right) - Math.Max(a.X, b.X) > Tolerance);
    private static double Length(List<(double X, double Y)> p) { double total = 0; for (int i = 0; i < p.Count - 1; i++) total += Math.Abs(p[i].X - p[i + 1].X) + Math.Abs(p[i].Y - p[i + 1].Y); return total; }
    private static double Movement(Rect a, Rect b) => Math.Abs(a.X - b.X) + Math.Abs(a.Y - b.Y) + Math.Abs(a.W - b.W) + Math.Abs(a.D - b.D);
    private static Rect ReadRect(JsonNode n) => new(Text(n["id"]), Number(n["x_ft"]), Number(n["y_ft"]), Number(n["width_ft"]), Number(n["depth_ft"]));
    private static object J(Rect r) => new { id = r.Id, x_ft = r.X, y_ft = r.Y, width_ft = r.W, depth_ft = r.D, area_sf = r.Area };
    private static double Number(JsonNode? n) => n?.GetValue<double>() ?? throw new InvalidDataException("Expected number input.");
    private static string Text(JsonNode? n) => n?.GetValue<string>() ?? string.Empty;
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
    private static string Resolve(string root, string path) => Path.GetFullPath(Path.IsPathRooted(path) ? path : Path.Combine(root, path));
    private static string FindRoot() { for (DirectoryInfo? d = new(AppContext.BaseDirectory); d is not null; d = d.Parent) if (File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) return d.FullName; for (DirectoryInfo? d = new(Directory.GetCurrentDirectory()); d is not null; d = d.Parent) if (File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) return d.FullName; throw new DirectoryNotFoundException("Repository AGENTS.md not found."); }
    private static void Write(string path, object value) => File.WriteAllText(path, JsonSerializer.Serialize(value, JsonOptions) + "\n", new UTF8Encoding(false));
    private static void Need(bool condition, string message) { if (!condition) throw new InvalidDataException(message); }

    private static string MakeSvg(Layout[] options, Rect[] fixedRooms, Rect[] windows, Rect c, double shellW, double shellD)
    {
        const double scale = 8, pad = 22, gap = 22, header = 30;
        Layout[] show = options.Take(6).ToArray();
        int cols = 2, rows = Math.Max(1, (show.Length + cols - 1) / cols);
        double panelW = shellW * scale + 2 * pad, panelH = shellD * scale + header + pad;
        double width = cols * panelW + (cols - 1) * gap, height = rows * panelH + (rows - 1) * gap;
        var svg = new StringBuilder($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{F(width)}\" height=\"{F(height)}\" viewBox=\"0 0 {F(width)} {F(height)}\">");
        svg.Append("<style>text{font:9px Arial}.shell{fill:none;stroke:#222;stroke-width:2}.room{fill:#dce8ed;stroke:#24566c}.l01{fill:#c9e4d0;stroke:#276c3c}.l02{fill:#e6dbf1;stroke:#654d80}.c{fill:#f1d9d9;stroke:#9a3030}.win{fill:#f7d9f0;stroke:#83366e;stroke-dasharray:4 2}.stair{fill:#f5e5b8;stroke:#7c5d11}.land{fill:#f8d995;stroke:#996515;stroke-width:2}.route{fill:none;stroke:#1670ad;stroke-width:36;stroke-opacity:.28;stroke-linecap:round;stroke-linejoin:round}</style>");
        if (show.Length == 0) svg.Append($"<text x=\"{F(pad)}\" y=\"{F(header + 22)}\">No integrated candidate passed the bounded screen.</text>");
        for (int i = 0; i < show.Length; i++)
        {
            Layout option = show[i]; double ox = (i % cols) * (panelW + gap), oy = (i / cols) * (panelH + gap), sx = ox + pad, sy = oy + header;
            svg.Append($"<text x=\"{F(ox + pad)}\" y=\"{F(oy + 15)}\">Sample {option.Sample}: movement proxy {F(option.L01Move + option.L02Move)} ft; route {F(Length(option.Path))} ft</text>");
            void Draw(Rect r, string cls, string label) { double x = sx + r.X * scale, y = sy + (shellD - r.Y - r.D) * scale; svg.Append($"<rect class=\"{cls}\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(r.W * scale)}\" height=\"{F(r.D * scale)}\"/><text x=\"{F(x + 2)}\" y=\"{F(y + 10)}\">{System.Security.SecurityElement.Escape(label)}</text>"); }
            foreach (Rect r in fixedRooms) Draw(r, r.Id == c.Id ? "c" : "room", r.Id);
            foreach (Rect r in windows) Draw(r, "win", r.Id);
            Draw(option.L01, "l01", "L-01"); Draw(option.L02, "l02", "L-02");
            foreach (Rect r in option.Pieces) Draw(r, "stair", r.Id);
            Draw(option.LowerLanding, "land", "lower landing"); Draw(option.UpperLanding, "land", "upper landing");
            string points = string.Join(" ", option.Path.Select(p => $"{F(sx + p.X * scale)},{F(sy + (shellD - p.Y) * scale)}"));
            svg.Append($"<polyline class=\"route\" points=\"{points}\"/><rect class=\"shell\" x=\"{F(sx)}\" y=\"{F(sy)}\" width=\"{F(shellW * scale)}\" height=\"{F(shellD * scale)}\"/>");
        }
        svg.Append("<text x=\"8\" y=\"14\">Study proxies only: shell unselected; no stair schedule, upper route, or code finding.</text></svg>");
        return XDocument.Parse(svg.ToString()).ToString(SaveOptions.DisableFormatting);
    }

    private static string F(double value) => value.ToString("0.####", CultureInfo.InvariantCulture);
}
