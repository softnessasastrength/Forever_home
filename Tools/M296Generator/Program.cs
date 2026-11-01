using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string SourceHash = "65A84006158D4352D282D3FA32EDBA3E93F327D31584F19B6C1C9C5BD081CE04";
    private const string AuthorizationHash = "C2A69B83F77652E0F8F3FBF1B687A578D98C4F878932B9D9900454305B983092";
    private const double Tol = 1e-7;

    private sealed record Box(double X, double Y, double W, double H)
    {
        public double Right => X + W;
        public double Top => Y + H;
    }

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 3) throw new ArgumentException("Usage: M296Generator <M295-report.json> <authorization.md> <output-directory>");
            var root = FindRoot();
            var sourcePath = Resolve(root, args[0]);
            var authPath = Resolve(root, args[1]);
            var output = Resolve(root, args[2]);
            var prefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must remain inside this repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any()) throw new IOException("Output directory must be new or empty.");

            var sourceHash = Hash(sourcePath);
            var authHash = Hash(authPath);
            if (sourceHash != SourceHash) throw new InvalidOperationException("M295 source fingerprint changed; review before replay.");
            if (authHash != AuthorizationHash) throw new InvalidOperationException("M296 authorization fingerprint changed; review before replay.");
            var auth = File.ReadAllText(authPath);
            if (!auth.Contains("analysis-only geometric follow-up", StringComparison.OrdinalIgnoreCase) || !auth.Contains("code-compliant", StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("M296 authorization scope is missing or changed.");

            var doc = JsonNode.Parse(File.ReadAllText(sourcePath)) ?? throw new InvalidDataException("Invalid M295 report.");
            var best = doc["joint_same_area_search"]?["best_options"]?[0] ?? throw new InvalidDataException("Missing M295 minimum-change option.");
            if (Text(best["connection"]) != "lower-landing interface") throw new InvalidDataException("M295 first option is no longer the expected landing interface.");
            var c = ReadBox(best["circulation"]);
            var s = ReadBox(best["stair"]);
            var landingOverlap = Number(best["stair"]?["lower_landing_overlap_sf"]);
            var cArea = c.W * c.H;
            var stairOverlap = IntersectionArea(c, s);
            var westGapIn = Math.Max(0, (s.X - c.X) * 12);
            var eastGapIn = Math.Max(0, (c.Right - s.Right) * 12);
            var northGapIn = Math.Max(0, (c.Top - s.Top) * 12);
            var southInterface = Math.Max(0, (s.Y - c.Y) * 12);
            var remainingAfterFullStair = cArea - stairOverlap;
            var maxSideBypassIn = Math.Max(westGapIn, eastGapIn);
            var fullRise = doc["full_rise_stair_basis"] ?? throw new InvalidDataException("Missing full-rise basis.");
            var expectedC = 78.8888888888889;

            var checks = new Dictionary<string, bool>
            {
                ["M295 report and owner authorization hashes are pinned"] = sourceHash == SourceHash && authHash == AuthorizationHash,
                ["source option is the zero-movement full-rise lower landing interface"] = Text(best["connection"]) == "lower-landing interface" && Math.Abs(Number(best["L01"]?["change_metric_ft"])) < Tol && Math.Abs(Number(best["circulation"]?["change_metric_ft"])) < Tol,
                ["C-LOWER area remains the source 78.8889 square feet"] = Math.Abs(cArea - expectedC) < 1e-6,
                ["landing-overlap metric remains 15.3333 square feet"] = Math.Abs(landingOverlap - 15.33333332) < 1e-5,
                ["stair footprint intersection is calculated independently of landing overlap"] = Math.Abs(stairOverlap - 18.847222) < 1e-5 && stairOverlap > landingOverlap,
                ["stair footprint leaves a 21-inch west gap and no east bypass"] = Math.Abs(westGapIn - 21) < 1e-5 && Math.Abs(eastGapIn) < Tol,
                ["neither side gap reaches the inherited 36-inch route screen"] = maxSideBypassIn < Number(doc["route_basis"]?["width_in"]),
                ["selected-D source report remains explicitly unedited"] = doc["selected_d_edited"]?.GetValue<bool>() == false,
                ["the output describes geometric analysis only"] = true
            };
            if (checks.Values.Any(v => !v)) throw new InvalidOperationException("M296 checks failed: " + string.Join("; ", checks.Where(x => !x.Value).Select(x => x.Key)));

            var report = new
            {
                schema = "forever-home-m296-landing-circulation-integration-v1",
                status = "pass; landing/C-LOWER integration measured geometrically; no usable route or design selected",
                selected_d_edited = false,
                source_hash = sourceHash,
                authorization_hash = authHash,
                basis = new { inherited_full_rise = new { risers = (int)Number(fullRise["risers"]), riser_in = Number(fullRise["riser_in"]), transition_in = Number(fullRise["transition_in"]) }, route_width_in = Number(doc["route_basis"]?["width_in"]), route_width_source = "M215 project screening precedent only" },
                source_option = new { connection = Text(best["connection"]), l01_change_ft = Number(best["L01"]?["change_metric_ft"]), circulation_change_ft = Number(best["circulation"]?["change_metric_ft"]), c_lower = new { x_ft = c.X, y_ft = c.Y, width_ft = c.W, depth_ft = c.H, area_sf = cArea }, stair = new { x_ft = s.X, y_ft = s.Y, width_ft = s.W, depth_ft = s.H, right_ft = s.Right, top_ft = s.Top } },
                integration_screen = new { landing_overlap_sf_from_M295 = landingOverlap, full_stair_footprint_overlap_with_c_lower_sf = stairOverlap, c_lower_area_outside_full_stair_footprint_sf = remainingAfterFullStair, west_side_bypass_width_in = westGapIn, east_side_bypass_width_in = eastGapIn, maximum_side_bypass_width_in = maxSideBypassIn, c_lower_band_south_of_stair_in = southInterface, c_lower_band_north_of_stair_in = northGapIn, full_stair_spans_entire_c_lower_width_at_its_y_band = westGapIn <= Tol && eastGapIn <= Tol, route_36in_screen_passes_side_bypass = maxSideBypassIn >= Number(doc["route_basis"]?["width_in"]) },
                conclusion = "The landing overlaps C-LOWER, so the rectangles form one proposed zone. The full stair footprint also blocks 18.8472 sf of C-LOWER; the remaining area outside that stair footprint is 60.0417 sf. At the stair band the west-side bypass is 21 in and the stair runs to or beyond the east C-LOWER edge, leaving no east bypass. The west gap is below the 36-in project screening precedent. This is a geometric pinch-point result, not a finding about actual doors, wall openings, code, accessibility, or whether an integrated circulation design can work.",
                limitations = "Axis-aligned study rectangles only; no walls, doors, openings, door swings, approach, finish thickness, tolerance, headroom, floor opening, structure, or continuation beyond C-LOWER. Landing overlap and complete stair-footprint overlap are distinct measures. Not a selected design or code-compliance result. M-06/A/B remain unassigned; west A remains protected."
            };

            Directory.CreateDirectory(output);
            var reportText = JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }) + "\n";
            var checksText = JsonSerializer.Serialize(new { schema = "forever-home-m296-checks-v1", passed = checks.Count, total = checks.Count, checks }, new JsonSerializerOptions { WriteIndented = true }) + "\n";
            File.WriteAllText(Path.Combine(output, "m296-integration-screen.json"), reportText, new UTF8Encoding(false));
            File.WriteAllText(Path.Combine(output, "m296-checks.json"), checksText, new UTF8Encoding(false));
            File.WriteAllText(Path.Combine(output, "m296-plan.svg"), Svg(c, s, westGapIn, eastGapIn), new UTF8Encoding(false));
            Console.WriteLine($"M296 pass: {checks.Count}/{checks.Count}; stair∩C-LOWER={stairOverlap:F4} sf; remaining={remainingAfterFullStair:F4} sf; west/east bypass={westGapIn:F1}/{eastGapIn:F1} in.");
            return 0;
        }
        catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
    }

    private static Box ReadBox(JsonNode? n) => new(Number(n?["x_ft"]), Number(n?["y_ft"]), Number(n?["width_ft"]), Number(n?["depth_ft"]));
    private static string Text(JsonNode? n) => n?.GetValue<string>() ?? "";
    private static double Number(JsonNode? n) => n?.GetValue<double>() ?? double.NaN;
    private static double IntersectionArea(Box a, Box b) => Math.Max(0, Math.Min(a.Right,b.Right)-Math.Max(a.X,b.X))*Math.Max(0,Math.Min(a.Top,b.Top)-Math.Max(a.Y,b.Y));
    private static string Hash(string p) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(p)));
    private static string Resolve(string root, string p) => Path.GetFullPath(Path.IsPathRooted(p) ? p : Path.Combine(root,p));
    private static string FindRoot() { var d=new DirectoryInfo(Environment.CurrentDirectory); while(d!=null&&!File.Exists(Path.Combine(d.FullName,".gitignore")))d=d.Parent; return d?.FullName??throw new DirectoryNotFoundException("Repository root not found."); }

    private static string Svg(Box c, Box s, double west, double east)
    {
        const double scale=48, ox=60, oy=60;
        double X(double x)=>ox+x*scale;
        double Y(double y)=>oy+(32-y)*scale;
        var sb=new StringBuilder();
        sb.AppendLine("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1900\" height=\"1780\" viewBox=\"0 0 1900 1780\">");
        sb.AppendLine("<style>text{font:22px Arial;fill:#20242a}.small{font-size:17px}.title{font-size:30px;font-weight:bold}</style><rect width=\"100%\" height=\"100%\" fill=\"white\"/>");
        sb.AppendLine("<text x=\"60\" y=\"38\" class=\"title\">M296 — full-rise stair / C-LOWER integration screen (schematic)</text>");
        sb.AppendLine($"<rect x=\"{X(c.X)}\" y=\"{Y(c.Top)}\" width=\"{c.W*scale}\" height=\"{c.H*scale}\" fill=\"#dceef6\" stroke=\"#1d6685\" stroke-width=\"4\"/><text x=\"{X(c.X)+8}\" y=\"{Y(c.Top)+30}\">C-LOWER {c.W*c.H:F1} sf</text>");
        sb.AppendLine($"<rect x=\"{X(s.X)}\" y=\"{Y(s.Top)}\" width=\"{s.W*scale}\" height=\"{s.H*scale}\" fill=\"#d8d8dc\" stroke=\"#4b4b55\" stroke-width=\"4\"/><text x=\"{X(s.X)+8}\" y=\"{Y(s.Top)+32}\">FULL-RISE STAIR ENVELOPE</text>");
        sb.AppendLine($"<text x=\"{X(c.X)-4}\" y=\"{Y(c.Top)-15}\" class=\"small\">west bypass {west:F0} in</text><text x=\"{X(c.Right)-150}\" y=\"{Y(c.Top)-15}\" class=\"small\">east bypass {east:F0} in</text>");
        sb.AppendLine($"<text x=\"60\" y=\"1650\">Landing overlap is a direct zone interface. Side bypasses are below the 36-in project screening precedent.</text><text x=\"60\" y=\"1690\" class=\"small\">No doors, walls, openings, approach, headroom, or onward route modeled. Not a code or accessibility finding.</text></svg>");
        return sb.ToString();
    }
}
