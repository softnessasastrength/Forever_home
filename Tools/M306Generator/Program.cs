using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Xml.Linq;

internal static class Program
{
    private const string M304Hash = "007F7959EF9900F944236C509989CC267DD5C4D08DFF191E712CC9D0679880F9";
    private const string M302Hash = "73D8ACDC85DF307ADF9782444281C3C7144A30C67DDF7D2F8CACD46F715BF03A";
    private const string M295Hash = "65A84006158D4352D282D3FA32EDBA3E93F327D31584F19B6C1C9C5BD081CE04";
    private const string M305Hash = "795FA1E4991785B409A92CD4A697AC719610B577166602D9E8D7FD3306BECCF8";
    private const string AuthorizationHash = "7342A8D93EC91622398DBEAEE2439B031E8C5AE25E1364478A7DC861CDAC38B3";
    private const double Epsilon = 1e-7;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private sealed record Rect(string Id, double X, double Y, double W, double D)
    {
        public double Right => X + W;
        public double Top => Y + D;
    }

    private sealed record End(double X, double Y, int Dx, int Dy);

    private sealed record Option(
        int M304Sample,
        int M302Sample,
        Rect L01,
        Rect L02,
        Rect[] Pieces,
        Rect? LowerLanding,
        bool LowerLandingFits,
        bool LowerRouteFound,
        Rect UpperLanding,
        bool UpperLandingFits,
        string UpperLandingStatus,
        string[] UpperLandingBlockers);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 6)
                throw new ArgumentException("Usage: M306Generator <M304.json> <M302.json> <M295.json> <M305.json> <authorization.md> <output-dir>");

            string root = FindRoot();
            string m304Path = Resolve(root, args[0]);
            string m302Path = Resolve(root, args[1]);
            string m295Path = Resolve(root, args[2]);
            string m305Path = Resolve(root, args[3]);
            string authorizationPath = Resolve(root, args[4]);
            string output = Resolve(root, args[5]);
            string rootPrefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(rootPrefix, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Output must remain inside the repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any())
                throw new IOException("Output directory must be empty.");

            var hashes = new
            {
                m304 = Hash(m304Path),
                m302 = Hash(m302Path),
                m295 = Hash(m295Path),
                m305 = Hash(m305Path),
                authorization = Hash(authorizationPath)
            };
            Need(hashes.m304 == M304Hash && hashes.m302 == M302Hash && hashes.m295 == M295Hash &&
                 hashes.m305 == M305Hash && hashes.authorization == AuthorizationHash,
                "A pinned source changed; review before replay.");

            JsonNode m304 = JsonNode.Parse(File.ReadAllText(m304Path))!;
            JsonNode m302 = JsonNode.Parse(File.ReadAllText(m302Path))!;
            JsonNode m295 = JsonNode.Parse(File.ReadAllText(m295Path))!;
            JsonNode m305 = JsonNode.Parse(File.ReadAllText(m305Path))!;
            JsonNode source = m302["source"]!;
            double shellW = Number(source["shell_ft"]?[0]);
            double shellD = Number(source["shell_ft"]?[1]);
            double landingW = Number(m295["full_rise_stair_basis"]?["width_ft"]);
            double landingD = Number(m295["full_rise_stair_basis"]?["landing_depth_ft"]);
            const double margin = 2.0 / 3.0;
            Need(shellW == 38.333333 && shellD == 40 && landingW == 4 && landingD == 4,
                "Pinned shell or M295 landing references changed.");
            Need(m305["selected_d_edited"]?.GetValue<bool>() == false &&
                 m305["rvt_or_ifc_created"]?.GetValue<bool>() == false,
                "M305 must remain an analysis-only input.");

            Rect cLower = ReadRect(source["C_LOWER"]!);
            Rect[] fixedRooms = source["fixed_rooms"]!.AsArray().Select(n => ReadRect(n!))
                .Where(r => r.Id != "L-02" && r.Id != cLower.Id).ToArray();
            Rect[] windows = source["protected_M06_windows"]!.AsArray().Select(n => ReadRect(n!)).ToArray();
            JsonArray m304Options = m304["search"]!["ranked_options"]!.AsArray();
            JsonArray m305Options = m305["search"]!["options"]!.AsArray();
            Need(m304Options.Count == 9 && m305Options.Count == 18 && windows.Length == 2,
                "Expected the nine M304 layouts, both M305 ends, and two protected M-06 windows.");

            var options = new List<Option>();
            for (int i = 0; i < m304Options.Count; i++)
            {
                JsonNode room = m304Options[i]!;
                JsonNode lower = m305Options.First(n => n!["M304_sample"]!.GetValue<int>() == i + 1 &&
                    S(n["flight_end"]) == "flight-A")!;
                Rect[] pieces = room["stair_pieces"]!.AsArray().Select(n => ReadRect(n!)).ToArray();
                Rect flightB = pieces.Single(p => p.Id == "flight-B");
                Rect platform = pieces.Single(p => p.Id == "turn-platform");
                End upperEdge = OutsideEnd(flightB, platform);
                Rect upperLanding = MakeLanding(upperEdge, landingW, landingD);
                Rect? lowerLanding = lower["landing_status"]!.GetValue<string>()
                    .StartsWith("4x4 end-landing proxy clears", StringComparison.Ordinal)
                    ? ReadRect(lower["landing"]!) : null;
                bool lowerFits = lowerLanding is not null;
                bool lowerRoute = lower["lower_route_found"]!.GetValue<bool>();
                Rect l01 = ReadRect(room["L01"]!);
                Rect l02 = ReadRect(room["L02"]!);

                Rect[] blockers = fixedRooms.Append(l01).Append(l02).Concat(windows)
                    .Concat(pieces.Where(p => p.Id != flightB.Id))
                    .Concat(lowerLanding is null ? Array.Empty<Rect>() : new[] { lowerLanding })
                    .ToArray();
                string[] hits = blockers.Where(x => Overlap(upperLanding, x)).Select(x => x.Id).Distinct().ToArray();
                bool inBounds = Inside(upperLanding, shellW, shellD, margin);
                bool upperFits = inBounds && hits.Length == 0;
                string status = !inBounds ? "4x4 upper end-landing proxy exceeds shell or perimeter margin" :
                    hits.Length > 0 ? "4x4 upper end-landing proxy overlaps screened block(s)" :
                    "4x4 upper end-landing proxy clears sampled room/window/stair blocks";

                options.Add(new Option(i + 1, room["M302_sample"]!.GetValue<int>(), l01, l02, pieces,
                    lowerLanding, lowerFits, lowerRoute, upperLanding, upperFits, status, hits));
            }

            int lowerRoutes = options.Count(o => o.LowerLandingFits && o.LowerRouteFound);
            int upperFitsCount = options.Count(o => o.UpperLandingFits);
            int paired = options.Count(o => o.LowerLandingFits && o.LowerRouteFound && o.UpperLandingFits);
            var checks = new Dictionary<string, bool>
            {
                ["M302/M304/M295/M305/M306 fingerprints match"] = true,
                ["hypothetical shell and inherited 4x4-ft landing references are retained"] = shellW == 38.333333 && shellD == 40 && landingW == 4 && landingD == 4,
                ["all nine M304 room/stair layouts are paired with their M305 flight-A result"] = options.Count == 9 && options.Select(o => o.M304Sample).Distinct().Count() == 9,
                ["upper landing checks include shell margin, rooms, windows, stair pieces and lower landing"] = options.All(o => o.UpperLandingFits == (Inside(o.UpperLanding, shellW, shellD, margin) && o.UpperLandingBlockers.Length == 0)),
                ["joint result is exactly the intersection of the lower-route and upper-landing predicates"] = paired == options.Count(o => o.LowerLandingFits && o.LowerRouteFound && o.UpperLandingFits),
                ["no selected-D, RVT, IFC, family, or compliance result is emitted"] = true
            };
            Need(checks.Values.All(v => v), "M306 validation failed.");

            Directory.CreateDirectory(output);
            var result = new
            {
                schema = "forever-home-m306-two-ended-stair-landing-screen-v1",
                status = paired > 0 ? "bounded paired lower-route and upper-landing option(s) found; no design selected" :
                    "no sampled layout combines the M305 lower route with a clear opposite-end landing; not proof of impossibility",
                selected_d_edited = false,
                rvt_or_ifc_created = false,
                basis = new
                {
                    shell_ft = new[] { shellW, shellD },
                    shell_status = "hypothetical/unselected",
                    inherited_landing_ft = new[] { landingW, landingD },
                    perimeter_margin_in = margin * 12,
                    C_LOWER_fixed = true,
                    M06_windows_protected = windows.Length
                },
                search = new
                {
                    M304_layouts = options.Count,
                    M305_lower_landing_and_route_passes = lowerRoutes,
                    opposite_end_landings_clear = upperFitsCount,
                    layouts_passing_both_ends = paired,
                    options = options.Select(o => new
                    {
                        M304_sample = o.M304Sample,
                        M302_sample = o.M302Sample,
                        L01 = JsonRect(o.L01),
                        L02 = JsonRect(o.L02),
                        lower_landing = o.LowerLanding is null ? null : JsonRect(o.LowerLanding),
                        lower_landing_fits = o.LowerLandingFits,
                        lower_route_found = o.LowerRouteFound,
                        upper_landing = JsonRect(o.UpperLanding),
                        upper_landing_fits = o.UpperLandingFits,
                        upper_landing_status = o.UpperLandingStatus,
                        upper_landing_blockers = o.UpperLandingBlockers,
                        both_ends_pass = o.LowerLandingFits && o.LowerRouteFound && o.UpperLandingFits
                    }).ToArray()
                },
                inputs_sha256 = hashes,
                checks = new { passed = checks.Count(p => p.Value), total = checks.Count, details = checks.Select(p => new { id = p.Key, pass = p.Value }) },
                limitations = new[]
                {
                    "Only the nine retained M304 room/stair samples are checked; this does not expand the joint candidate search.",
                    "Both ends use the inherited 4x4-ft rectangle as a spatial proxy, not a designed or code-checked landing.",
                    "The lower-route result is inherited from M305; M306 checks the opposite landing footprint only and no upstairs path.",
                    "The L-turn remains an unverified 3+4 aggregate tread-run proxy; actual risers, run, stair type, headroom, opening, rails/guards and structure remain unresolved.",
                    "Doors, finished walls, approach, circulation beyond C-LOWER, upper room access, services and site conditions are not modeled.",
                    "The 38.333333x40-ft shell and all room moves remain hypothetical/unselected; no selected-D, RVT, IFC, family or remote state changed.",
                    "No code, accessibility, structural safety, professional, permit or construction-readiness conclusion follows."
                }
            };
            Write(Path.Combine(output, "m306-two-ended-landing-study.json"), result);
            Write(Path.Combine(output, "m306-checks.json"), new { passed = checks.Count(p => p.Value), total = checks.Count, details = checks.Select(p => new { id = p.Key, pass = p.Value }) });
            File.WriteAllText(Path.Combine(output, "m306-two-ended-landings.svg"), MakeSvg(options, shellW, shellD), new UTF8Encoding(false));
            Console.WriteLine($"M306 {checks.Count}/{checks.Count}; layouts={options.Count}; lower routes={lowerRoutes}; upper landing fits={upperFitsCount}; both ends={paired}; analysis-only.");
            return 0;
        }
        catch (Exception e)
        {
            Console.Error.WriteLine("M306 FAILED: " + e);
            return 1;
        }
    }

    private static End OutsideEnd(Rect flight, Rect platform)
    {
        if (Math.Abs(flight.Right - platform.X) < Epsilon) return new End(flight.X, flight.Y + flight.D / 2, -1, 0);
        if (Math.Abs(flight.X - platform.Right) < Epsilon) return new End(flight.Right, flight.Y + flight.D / 2, 1, 0);
        if (Math.Abs(flight.Top - platform.Y) < Epsilon) return new End(flight.X + flight.W / 2, flight.Y, 0, -1);
        if (Math.Abs(flight.Y - platform.Top) < Epsilon) return new End(flight.X + flight.W / 2, flight.Top, 0, 1);
        throw new InvalidDataException("Flight-B is not adjacent to the turn platform.");
    }

    private static Rect MakeLanding(End e, double width, double depth)
    {
        if (Math.Abs(width - depth) > Epsilon) throw new InvalidDataException("This study assumes a square landing proxy.");
        if (e.Dx > 0) return new Rect("upper-landing", e.X, e.Y - width / 2, depth, width);
        if (e.Dx < 0) return new Rect("upper-landing", e.X - depth, e.Y - width / 2, depth, width);
        if (e.Dy > 0) return new Rect("upper-landing", e.X - width / 2, e.Y, width, depth);
        return new Rect("upper-landing", e.X - width / 2, e.Y - depth, width, depth);
    }

    private static bool Inside(Rect r, double w, double d, double margin) =>
        r.X >= margin - Epsilon && r.Y >= margin - Epsilon && r.Right <= w - margin + Epsilon && r.Top <= d - margin + Epsilon;

    private static bool Overlap(Rect a, Rect b) =>
        Math.Min(a.Right, b.Right) - Math.Max(a.X, b.X) > Epsilon &&
        Math.Min(a.Top, b.Top) - Math.Max(a.Y, b.Y) > Epsilon;

    private static Rect ReadRect(JsonNode node) => new(
        node["id"]!.GetValue<string>(), Number(node["x_ft"]), Number(node["y_ft"]), Number(node["width_ft"]), Number(node["depth_ft"]));

    private static object JsonRect(Rect r) => new { id = r.Id, x_ft = r.X, y_ft = r.Y, width_ft = r.W, depth_ft = r.D };
    private static double Number(JsonNode? node) => node?.GetValue<double>() ?? throw new InvalidDataException("Expected numeric input.");
    private static string S(JsonNode? node) => node?.GetValue<string>() ?? string.Empty;
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
    private static string Resolve(string root, string path) => Path.GetFullPath(Path.IsPathRooted(path) ? path : Path.Combine(root, path));

    private static string FindRoot()
    {
        for (DirectoryInfo? d = new(AppContext.BaseDirectory); d is not null; d = d.Parent)
            if (File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) return d.FullName;
        for (DirectoryInfo? d = new(Directory.GetCurrentDirectory()); d is not null; d = d.Parent)
            if (File.Exists(Path.Combine(d.FullName, "AGENTS.md"))) return d.FullName;
        throw new DirectoryNotFoundException("Could not locate repository AGENTS.md.");
    }

    private static void Write(string path, object value) =>
        File.WriteAllText(path, JsonSerializer.Serialize(value, JsonOptions) + "\n", new UTF8Encoding(false));

    private static string MakeSvg(IReadOnlyList<Option> options, double shellW, double shellD)
    {
        const double scale = 5, pad = 16, gap = 18, panelHeader = 26;
        int columns = 3, rows = (options.Count + columns - 1) / columns;
        double panelW = shellW * scale + 2 * pad, panelH = shellD * scale + panelHeader + pad;
        var svg = new StringBuilder($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{F(columns * panelW + (columns - 1) * gap)}\" height=\"{F(rows * panelH + (rows - 1) * gap)}\" viewBox=\"0 0 {F(columns * panelW + (columns - 1) * gap)} {F(rows * panelH + (rows - 1) * gap)}\">");
        svg.Append("<style>text{font:9px Arial}.shell{fill:none;stroke:#222;stroke-width:2}.room{fill:#dce8ed;stroke:#24566c}.c{fill:#f1d9d9;stroke:#9a3030}.win{fill:#f7d9f0;stroke:#83366e;stroke-dasharray:4 2}.stair{fill:#f5e5b8;stroke:#7c5d11}.lower{fill:#f8d995;stroke:#996515;stroke-width:2}.upper{fill:#c6e4d2;stroke:#21633b;stroke-width:2}.miss{fill:#f4cccc;stroke:#9d2525;stroke-width:2}</style>");
        for (int i = 0; i < options.Count; i++)
        {
            Option o = options[i];
            double ox = (i % columns) * (panelW + gap), oy = (i / columns) * (panelH + gap);
            double sx = ox + pad, sy = oy + panelHeader;
            svg.Append($"<text x=\"{F(ox + pad)}\" y=\"{F(oy + 13)}\">M304 {o.M304Sample} / M302 {o.M302Sample}: lower-route {(o.LowerRouteFound ? "pass" : "fail")}, upper landing {(o.UpperLandingFits ? "pass" : "fail")}</text>");
            void Draw(Rect r, string cls, string label)
            {
                double x = sx + r.X * scale, y = sy + (shellD - r.Y - r.D) * scale;
                svg.Append($"<rect class=\"{cls}\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(r.W * scale)}\" height=\"{F(r.D * scale)}\"/><text x=\"{F(x + 2)}\" y=\"{F(y + 10)}\">{System.Security.SecurityElement.Escape(label)}</text>");
            }
            Draw(o.L01, "room", "L-01"); Draw(o.L02, "room", "L-02");
            foreach (Rect piece in o.Pieces) Draw(piece, "stair", piece.Id);
            if (o.LowerLanding is not null) Draw(o.LowerLanding, "lower", "lower");
            Draw(o.UpperLanding, o.UpperLandingFits ? "upper" : "miss", "upper");
            svg.Append($"<rect class=\"shell\" x=\"{F(sx)}\" y=\"{F(sy)}\" width=\"{F(shellW * scale)}\" height=\"{F(shellD * scale)}\"/>");
        }
        svg.Append("<text x=\"8\" y=\"12\">Hypothetical shell and landing proxies; no upper route, actual stair, or code finding.</text></svg>");
        return XDocument.Parse(svg.ToString()).ToString(SaveOptions.DisableFormatting);
    }

    private static string F(double value) => value.ToString("0.####", CultureInfo.InvariantCulture);
    private static void Need(bool condition, string message) { if (!condition) throw new InvalidDataException(message); }
}
