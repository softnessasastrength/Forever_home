using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string M289Hash = "00000094823867028C728501AFA26B88A569376AB920B4AFAF00FC7F4ECCD4D1";
    private const double Width = 3.0, Tol = 1e-7;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
    private sealed record Rect(double X, double Y, double W, double D)
    {
        public double Right => X + W;
        public double Top => Y + D;
        public double Area => W * D;
    }
    private sealed record Cell(int X, int Y, double Area);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 2) throw new ArgumentException("Usage: M290Generator <m289-joint-lower-stair-study.json> <output-directory>");
            var root = FindRoot();
            var input = Resolve(root, args[0]);
            var output = Resolve(root, args[1]);
            var prefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside this repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any()) throw new IOException("Output directory must be new or empty.");
            var inputHash = Hash(input);
            if (inputHash != M289Hash) throw new InvalidDataException($"Pinned M289 source changed: {inputHash}");
            var doc = JsonNode.Parse(File.ReadAllText(input)) ?? throw new InvalidDataException("M289 JSON is empty.");
            var search = doc["joint_same_area_search"] ?? throw new InvalidDataException("Missing M289 search result.");
            var best = search["best_options"]?.AsArray() ?? throw new InvalidDataException("Missing M289 options.");
            var positive = search["best_positive_gap_route_options"]?.AsArray() ?? throw new InvalidDataException("Missing positive-gap options.");
            var options = new[]
            {
                best.Select(Parse).Where(x => x.Length > Tol).OrderBy(x => x.Change).ThenByDescending(x => x.Gap).FirstOrDefault() ?? throw new InvalidDataException("No positive-length minimum-change route."),
                positive.Select(Parse).Where(x => x.Length > Tol && x.Gap > Tol).OrderByDescending(x => x.Gap).ThenBy(x => x.Change).ThenBy(x => x.Length).FirstOrDefault() ?? throw new InvalidDataException("No positive-gap route.")
            };
            var results = options.Select(Analyze).ToArray();
            var checks = new Dictionary<string, bool>
            {
                ["input report matches committed M289 SHA256"] = inputHash == M289Hash,
                ["both representative routes are positive-length and connect to C-LOWER"] = options.All(o => o.Length > Tol && o.Route.Any(r => Touches(r, o.C))),
                ["minimum-change reference has zero measured L-01 separation"] = Math.Abs(options[0].Gap) < Tol,
                ["positive-gap reference has positive measured L-01 separation"] = options[1].Gap > Tol,
                ["all stair and swept-route proxy pieces remain clipped to C-LOWER for residual analysis"] = results.All(r => r.BlockedArea >= -Tol && r.BlockedArea <= r.C.Area + Tol),
                ["occupied union plus free-space components conserves C-LOWER area"] = results.All(r => Math.Abs(r.BlockedArea + r.FreeArea - r.C.Area) < 1e-6),
                ["free-space partition has no zero-area tiles or overlapping component membership"] = results.All(r => r.Cells.All(c => c.Area > Tol) && r.Components.Sum(c => c.CellCount) == r.Cells.Count),
                ["component flood fill accounts for every unoccupied tile"] = results.All(r => Math.Abs(r.Components.Sum(c => c.Area) - r.FreeArea) < 1e-6),
                ["selected-D and M-06 remain unchanged/unassigned"] = doc["selected_d_edited"]?.GetValue<bool>() == false && doc["status"]?.GetValue<string>()?.Contains("no room", StringComparison.OrdinalIgnoreCase) == true
            };
            if (checks.Values.Any(v => !v)) throw new InvalidDataException("M290 check failed: " + string.Join("; ", checks.Where(kv => !kv.Value).Select(kv => kv.Key)));
            Directory.CreateDirectory(output);
            var report = new
            {
                schema = "forever-home-m290-circulation-residual-partition-v1",
                status = "pass; exact residual rectangle partition; no C-LOWER layout, route, or stair selected",
                input_sha256 = inputHash,
                analysis_basis = new { route_width_ft = Width, source = "M289 36-in swept-route proxy", partition = "coordinate-compressed axis-aligned cells; edge-adjacent unoccupied cells form components", dimensions_are_not_clearance_or_usability_standards = true },
                cases = results.Select((r, i) => new { case_id = i == 0 ? "minimum-change dogleg" : "maximum-gap straight connector", source_M289_option = OptionJson(r), C_LOWER_blocked_union_sf = r.BlockedArea, C_LOWER_residual_sf = r.FreeArea, component_count = r.Components.Count, residual_components = r.Components.OrderByDescending(c => c.Area).ThenBy(c => c.MinY).Select(c => new { area_sf = c.Area, bounding_box_ft = new[] { c.MinX, c.MinY, c.MaxX - c.MinX, c.MaxY - c.MinY }, rectangular_tile_count = c.CellCount }).ToArray(), residual_partition = new { tile_count = r.Cells.Count, component_area_sum_sf = r.Components.Sum(c => c.Area) } }).ToArray(),
                checks = new { passed = checks.Count, total = checks.Count, details = checks.Select(kv => new { id = kv.Key, pass = kv.Value }) },
                limitations = new[] { "This partitions the M289 axis-aligned stair and 36-in swept-route rectangles only. It does not evaluate circulation use, doors, approaches, walls, finished faces, landings, actual stair geometry, code, accessibility, headroom, structure, MEP, or furniture.", "Component bounding boxes can contain notches and are not solid usable rectangles. Component count/area and descriptive bounds do not establish a usable room or required clearance.", "The M289 route-width basis is a project screen precedent only, not an adopted code or accessibility criterion. Both comparisons remain hypothetical; no design or model objects are selected." }
            };
            WriteJson(Path.Combine(output, "m290-circulation-residual-study.json"), report);
            WriteJson(Path.Combine(output, "m290-checks.json"), new { schema = "forever-home-m290-checks-v1", status = "pass", passed = checks.Count, total = checks.Count, details = checks.Select(kv => new { id = kv.Key, pass = kv.Value }) });
            File.WriteAllText(Path.Combine(output, "m290-residual-components.svg"), Svg(results), new UTF8Encoding(false));
            Console.WriteLine($"M290 {checks.Count}/{checks.Count}; minimum-change residual={results[0].FreeArea:F4} sf in {results[0].Components.Count} connected component(s); positive-gap residual={results[1].FreeArea:F4} sf in {results[1].Components.Count} connected component(s); no selection.");
            return 0;
        }
        catch (Exception ex) { Console.Error.WriteLine("M290 FAILED: " + ex); return 1; }
    }

    private sealed record Option(Rect C, Rect Stair, List<Rect> Route, double Change, double Gap, double Length, int Turns, JsonNode Source);
    private sealed record Component(double Area, double MinX, double MinY, double MaxX, double MaxY, int CellCount);
    private sealed record Result(Option Option, Rect C, List<Cell> Cells, List<Component> Components, double BlockedArea, double FreeArea, double[] Xs, double[] Ys);
    private static Option Parse(JsonNode? n)
    {
        if (n is null) throw new InvalidDataException("Null route option.");
        var c = ReadRect(n["circulation"]); var stair = ReadRect(n["stair"]); var route = n["route"] ?? throw new InvalidDataException("Missing route.");
        var points = route["centerline_points_ft"]?.AsArray() ?? throw new InvalidDataException("Missing route centerline.");
        var xy = points.Select(p => (X: V(p?[0]), Y: V(p?[1]))).ToArray();
        var rectangles = new List<Rect>();
        foreach (var p in xy) rectangles.Add(new Rect(p.X - Width / 2, p.Y - Width / 2, Width, Width));
        for (var i = 0; i + 1 < xy.Length; i++)
        {
            var a = xy[i]; var b = xy[i + 1];
            if (Math.Abs(a.Y - b.Y) < Tol) rectangles.Add(new Rect(Math.Min(a.X, b.X), a.Y - Width / 2, Math.Abs(a.X - b.X), Width));
            else if (Math.Abs(a.X - b.X) < Tol) rectangles.Add(new Rect(a.X - Width / 2, Math.Min(a.Y, b.Y), Width, Math.Abs(a.Y - b.Y)));
            else throw new InvalidDataException("M289 route is not orthogonal.");
        }
        var length = route["length_ft"]?.GetValue<double>() ?? throw new InvalidDataException("Missing route length.");
        return new Option(c, stair, rectangles, V(n["circulation"]?["combined_change_metric_ft"]), V(route["min_gap_stair_and_path_to_L01_in"]), length, route["turns"]?.GetValue<int>() ?? 0, n.DeepClone());
    }
    private static Result Analyze(Option option)
    {
        var c = option.C;
        var blockers = option.Route.Append(option.Stair).Select(r => Clip(r, c)).Where(r => r is not null).Cast<Rect>().ToArray();
        var xs = Axis(blockers.SelectMany(r => new[] { r.X, r.Right }).Append(c.X).Append(c.Right));
        var ys = Axis(blockers.SelectMany(r => new[] { r.Y, r.Top }).Append(c.Y).Append(c.Top));
        var cells = new List<Cell>(); var occupied = new bool[xs.Length - 1, ys.Length - 1];
        for (var i = 0; i < xs.Length - 1; i++) for (var j = 0; j < ys.Length - 1; j++)
        {
            var x = (xs[i] + xs[i + 1]) / 2; var y = (ys[j] + ys[j + 1]) / 2;
            occupied[i, j] = blockers.Any(b => x > b.X - Tol && x < b.Right + Tol && y > b.Y - Tol && y < b.Top + Tol);
            if (!occupied[i, j]) cells.Add(new Cell(i, j, (xs[i + 1] - xs[i]) * (ys[j + 1] - ys[j])));
        }
        var visited = new HashSet<(int, int)>(); var components = new List<Component>();
        foreach (var cell in cells)
        {
            if (!visited.Add((cell.X, cell.Y))) continue;
            var queue = new Queue<(int X, int Y)>(); queue.Enqueue((cell.X, cell.Y));
            double area = 0, minX = double.PositiveInfinity, minY = double.PositiveInfinity, maxX = double.NegativeInfinity, maxY = double.NegativeInfinity; int count = 0;
            while (queue.Count > 0)
            {
                var (x, y) = queue.Dequeue(); var tile = cells.First(t => t.X == x && t.Y == y); count++; area += tile.Area;
                minX = Math.Min(minX, xs[x]); maxX = Math.Max(maxX, xs[x + 1]); minY = Math.Min(minY, ys[y]); maxY = Math.Max(maxY, ys[y + 1]);
                foreach (var next in new[] { (x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1) })
                    if (next.Item1 >= 0 && next.Item1 < xs.Length - 1 && next.Item2 >= 0 && next.Item2 < ys.Length - 1 && !occupied[next.Item1, next.Item2] && visited.Add(next)) queue.Enqueue(next);
            }
            components.Add(new Component(area, minX, minY, maxX, maxY, count));
        }
        var free = cells.Sum(c0 => c0.Area); var blocked = c.Area - free;
        return new Result(option, c, cells, components, blocked, free, xs, ys);
    }
    private static Rect? Clip(Rect r, Rect c)
    {
        var x = Math.Max(r.X, c.X); var y = Math.Max(r.Y, c.Y); var right = Math.Min(r.Right, c.Right); var top = Math.Min(r.Top, c.Top);
        return right - x > Tol && top - y > Tol ? new Rect(x, y, right - x, top - y) : null;
    }
    private static double[] Axis(IEnumerable<double> values)
    {
        var result = new List<double>();
        foreach (var value in values.Order()) if (result.Count == 0 || value - result[^1] > Tol) result.Add(value);
        return result.ToArray();
    }
    private static bool Touches(Rect a, Rect b) => Math.Abs(a.Right - b.X) < Tol || Math.Abs(b.Right - a.X) < Tol || Math.Abs(a.Top - b.Y) < Tol || Math.Abs(b.Top - a.Y) < Tol || (a.X < b.Right && a.Right > b.X && a.Y < b.Top && a.Top > b.Y);
    private static Rect ReadRect(JsonNode? n) => new(V(n?["x_ft"]), V(n?["y_ft"]), V(n?["width_ft"]), V(n?["depth_ft"]));
    private static object OptionJson(Result r) => new { C_LOWER_ft = new[] { r.C.X, r.C.Y, r.C.W, r.C.D }, change_metric_ft = r.Option.Change, route_length_ft = r.Option.Length, route_turns = r.Option.Turns, stair_path_gap_to_L01_in = r.Option.Gap };
    private static double V(JsonNode? n) => n?.GetValue<double>() ?? throw new InvalidDataException("Missing numeric value.");
    private static string Svg(Result[] results)
    {
        const double scale = 48, pad = 48, gap = 68, top = 58, bottom = 36;
        var panelW = results.Max(r => r.C.W) * scale + 2 * pad; var panelH = results.Max(r => r.C.D) * scale + top + bottom;
        var sb = new StringBuilder(); sb.Append($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{F(panelW * results.Length + gap)}\" height=\"{F(panelH)}\" viewBox=\"0 0 {F(panelW * results.Length + gap)} {F(panelH)}\"><style>text{{font:12px Arial}}.c{{fill:#f6e1e1;stroke:#803737;stroke-width:2}}.free{{fill:#c8e6cc;stroke:#377542;stroke-width:1}}.path{{fill:#8ebce8;fill-opacity:.62;stroke:#245786}}.stair{{fill:#f1d282;fill-opacity:.8;stroke:#8a6513;stroke-width:2}}</style>");
        for (var k = 0; k < results.Length; k++)
        {
            var r = results[k]; var ox = k * (panelW + gap); var x0 = ox + pad; var y0 = top;
            sb.Append($"<text x=\"{F(ox + 4)}\" y=\"20\">{(k == 0 ? "Minimum-change dogleg" : "Positive-gap straight connector")}</text><text x=\"{F(ox + 4)}\" y=\"38\">Residual {F(r.FreeArea)} sf; {r.Components.Count} connected component(s)</text>");
            R(r.C, "c");
            foreach (var cell in r.Cells)
                sb.Append($"<rect class=\"free\" x=\"{F(x0 + (r.Xs[cell.X] - r.C.X) * scale)}\" y=\"{F(y0 + (r.C.Top - r.Ys[cell.Y + 1]) * scale)}\" width=\"{F((r.Xs[cell.X + 1] - r.Xs[cell.X]) * scale)}\" height=\"{F((r.Ys[cell.Y + 1] - r.Ys[cell.Y]) * scale)}\"/>");
            R(r.Option.Stair, "stair"); foreach (var q in r.Option.Route) R(q, "path");
            sb.Append($"<text x=\"{F(x0)}\" y=\"{F(y0 + r.C.D * scale + 18)}\">Green is residual geometry; bounds may be notched, not usable-area claims.</text>");
            void R(Rect b, string cls) { var c = Clip(b, r.C); if (c is null) return; sb.Append($"<rect class=\"{cls}\" x=\"{F(x0 + (c.X - r.C.X) * scale)}\" y=\"{F(y0 + (r.C.Top - c.Top) * scale)}\" width=\"{F(c.W * scale)}\" height=\"{F(c.D * scale)}\"/>"); }
        }
        sb.Append("</svg>"); return sb.ToString();
    }
    private static string F(double d) => d.ToString("0.####", System.Globalization.CultureInfo.InvariantCulture);
    private static string Hash(string p) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(p)));
    private static void WriteJson(string p, object value) => File.WriteAllText(p, JsonSerializer.Serialize(value, JsonOptions) + "\n", new UTF8Encoding(false));
    private static string Resolve(string root, string p) => Path.GetFullPath(Path.IsPathRooted(p) ? p : Path.Combine(root, p));
    private static string FindRoot() { var d = new DirectoryInfo(Environment.CurrentDirectory); while (d is not null && !File.Exists(Path.Combine(d.FullName, "PLAN.md"))) d = d.Parent; return d?.FullName ?? throw new DirectoryNotFoundException("Repository root not found."); }
}
