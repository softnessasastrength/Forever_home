using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string SnapshotHash = "12145EBDF1C065804179242750ABE3D80917F8F23B8DA71B256495B387122910";
    private const string SelectedDHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const double Margin = 2.0 / 3.0;
    private const double Step = 0.25;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private sealed record Rect(string Id, double X, double Y, double W, double D)
    {
        public double Area => W * D;
        public Rect At(double x, double y) => this with { X = x, Y = y };
    }
    private sealed record Layout(string Id, string Description, Rect Living, Rect Kitchen, Rect Entry, bool IsSelected = false);
    private sealed record Candidate(Layout Layout, double TotalTranslationFt, double MaximumTranslationFt, double M04GapIn, double AGapIn, double BGapIn);

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 3) throw new ArgumentException("Usage: M284Generator <M282-source-snapshot.json> <M05-topology-scope.md> <output-directory>");
            var root = FindRoot();
            string snapshotPath = Resolve(root, args[0]);
            string scopePath = Resolve(root, args[1]);
            string output = Resolve(root, args[2]);
            string repoPrefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(repoPrefix, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Output must stay inside the repository.");
            if (Directory.Exists(output) && Directory.EnumerateFileSystemEntries(output).Any()) throw new IOException("Output directory must be empty.");

            string selectedPath = Path.Combine(root, "Architecture/Selected_Design_Iteration_2026-10-27/study.json");
            string m05AuthorizationPath = Path.Combine(root, "Decisions/2026-11-01_M05_Move_Reshape_Study_Authorization.md");
            string m06ProtectionPath = Path.Combine(root, "Decisions/2026-10-31_M06_West_A_Protection.md");
            foreach (var path in new[] { snapshotPath, scopePath, selectedPath, m05AuthorizationPath, m06ProtectionPath })
                if (!File.Exists(path)) throw new FileNotFoundException("Required source or authorization is missing.", path);
            string scope = File.ReadAllText(scopePath);
            Require(scope.Contains("compare all three paths", StringComparison.OrdinalIgnoreCase), "M05 topology scope does not record the owner's three-path direction.");

            var sourceHashes = new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["m282_snapshot"] = Hash(snapshotPath), ["selected_d"] = Hash(selectedPath),
                ["m05_move_authorization"] = Hash(m05AuthorizationPath), ["m05_topology_scope"] = Hash(scopePath),
                ["m06_west_a_protection"] = Hash(m06ProtectionPath)
            };
            Require(sourceHashes["m282_snapshot"] == SnapshotHash, "M282 snapshot fingerprint changed; inspect before replay.");
            Require(sourceHashes["selected_d"] == SelectedDHash, "Selected-D changed; M284 is fail-closed.");
            var snapshot = Read(snapshotPath);
            var selected = Read(selectedPath);
            Require(Text(snapshot["schema"]) == "forever-home-m282-m05-move-source-snapshot-v1", "Unexpected M282 snapshot schema.");
            Require(Text(selected["selection"]?["main_shell"]) == "40 x 42 ft (B test envelope)", "Selected-D main-shell test envelope changed.");

            double shellW = Num(snapshot["shell_ft"]?[0]);
            double shellD = Num(snapshot["shell_ft"]?[1]);
            var rooms = snapshot["rooms"]?.AsArray() ?? throw new InvalidDataException("M282 snapshot has no room blocks.");
            Rect R(string id) { var r = rooms.Single(x => Text(x?["id"]) == id); return new Rect(id, Num(r?["x"]), Num(r?["y"]), Num(r?["w"]), Num(r?["d"])); }
            var living0 = R("M-01-living-M256-east-6in");
            var kitchen0 = R("M-02-kitchen-M256-west-6in");
            var dining = R("M-03-dining-source");
            var pantry = R("M-04-pantry-source-5x7");
            var entry0 = R("M-05-entry-hall-source");
            var protectedA = R("protected-A");
            var unassignedB = R("unassigned-B");
            Require(Math.Abs(entry0.Area - 52.0) < 1e-6, "M-05 source area changed.");
            Require(Math.Abs(living0.Area - 240.0) < 1e-6, "M-01 source area changed.");
            Require(Math.Abs(kitchen0.Area - 277.3333333333333) < 1e-6, "M-02 source area changed.");
            Require(Math.Abs(kitchen0.X - (living0.X + living0.W) - entry0.W) < 1e-6, "Source M01/M02 gap no longer equals M05 width.");

            var blockers = new[] { dining, pantry, protectedA, unassignedB };
            bool Overlap(Rect a, Rect b) => Math.Min(a.X + a.W, b.X + b.W) - Math.Max(a.X, b.X) > 1e-6 &&
                                               Math.Min(a.Y + a.D, b.Y + b.D) - Math.Max(a.Y, b.Y) > 1e-6;
            bool InShell(Rect r, double margin = 0) => r.X >= margin - 1e-7 && r.Y >= margin - 1e-7 && r.X + r.W <= shellW - margin + 1e-7 && r.Y + r.D <= shellD - margin + 1e-7;
            double GapFt(Rect a, Rect b)
            {
                double dx = Math.Max(0, Math.Max(a.X - b.X - b.W, b.X - a.X - a.W));
                double dy = Math.Max(0, Math.Max(a.Y - b.Y - b.D, b.Y - a.Y - a.D));
                return Math.Sqrt(dx * dx + dy * dy);
            }
            double SharedEdgeFt(Rect a, Rect b)
            {
                const double tol = 1e-6;
                if (Math.Abs(a.X + a.W - b.X) < tol || Math.Abs(b.X + b.W - a.X) < tol)
                    return Math.Max(0, Math.Min(a.Y + a.D, b.Y + b.D) - Math.Max(a.Y, b.Y));
                if (Math.Abs(a.Y + a.D - b.Y) < tol || Math.Abs(b.Y + b.D - a.Y) < tol)
                    return Math.Max(0, Math.Min(a.X + a.W, b.X + b.W) - Math.Max(a.X, b.X));
                return 0;
            }
            bool NoStaticOverlap(Layout layout) =>
                !Overlap(layout.Living, layout.Kitchen) && !Overlap(layout.Living, layout.Entry) && !Overlap(layout.Kitchen, layout.Entry) &&
                blockers.All(b => !Overlap(layout.Living, b) && !Overlap(layout.Kitchen, b) && !Overlap(layout.Entry, b));
            double Translation(Rect a, Rect b) => Math.Abs(a.X - b.X) + Math.Abs(a.Y - b.Y);
            Candidate Score(Layout layout) => new(layout,
                Translation(layout.Living, living0) + Translation(layout.Kitchen, kitchen0) + Translation(layout.Entry, entry0),
                Math.Max(Translation(layout.Living, living0), Math.Max(Translation(layout.Kitchen, kitchen0), Translation(layout.Entry, entry0))),
                GapFt(layout.Entry, pantry) * 12, GapFt(layout.Entry, protectedA) * 12, GapFt(layout.Entry, unassignedB) * 12);

            var baseline = new Layout("path-1-source-baseline", "Current M01/M02/M05 blocks; no shared-edge kitchen/living connection", living0, kitchen0, entry0);
            Require(InShell(living0, Margin) && InShell(kitchen0, Margin) && InShell(entry0), "Source blocks exceed the test shell.");
            Require(NoStaticOverlap(baseline), "Source baseline has a positive-area collision under M284's rectangle method.");

            var connectedCandidates = new List<(Rect Living, Rect Kitchen)>();
            for (double x = Margin; x + living0.W + kitchen0.W <= shellW - Margin + 1e-7; x = Math.Round(x + Step, 8))
            {
                var l = living0.At(x, living0.Y);
                var k = kitchen0.At(x + living0.W, kitchen0.Y);
                if (!InShell(l, Margin) || !InShell(k, Margin)) continue;
                if (blockers.Any(b => Overlap(l, b) || Overlap(k, b))) continue;
                connectedCandidates.Add((l, k));
            }
            Require(connectedCandidates.Count > 0, "No same-row M01/M02 shared-edge comparison passes the static blocker screen.");

            Candidate BestFront()
            {
                var candidates = new List<Candidate>();
                foreach (var pair in connectedCandidates)
                {
                    for (double x = Margin; x + entry0.W <= shellW + 1e-7; x = Math.Round(x + Step, 8))
                    {
                        var entry = entry0.At(x, entry0.Y);
                        var layout = new Layout("path-2-south-entry-room-move", "Presumed south/front-side M05 row; M01/M02 translated to share an edge", pair.Living, pair.Kitchen, entry);
                        if (!InShell(entry) || !NoStaticOverlap(layout)) continue;
                        candidates.Add(Score(layout));
                    }
                }
                return candidates.OrderBy(c => c.TotalTranslationFt).ThenBy(c => c.MaximumTranslationFt)
                    .ThenBy(c => c.Layout.Living.X).ThenBy(c => c.Layout.Entry.X).FirstOrDefault()
                    ?? throw new InvalidDataException("No front-row alternative passed the static rectangle screen.");
            }
            Candidate BestEdge(string edge)
            {
                var candidates = new List<Candidate>();
                foreach (var pair in connectedCandidates)
                {
                    if (edge == "north")
                    {
                        double y = shellD - entry0.D;
                        for (double x = 0; x + entry0.W <= shellW + 1e-7; x = Math.Round(x + Step, 8))
                        {
                            var entry = entry0.At(x, y);
                            var layout = new Layout($"path-3-{edge}-edge-entry", $"North/rear test-shell edge; M01/M02 translated to share an edge", pair.Living, pair.Kitchen, entry);
                            if (InShell(entry) && NoStaticOverlap(layout)) candidates.Add(Score(layout));
                        }
                    }
                    else
                    {
                        double x = shellW - entry0.W;
                        for (double y = 0; y + entry0.D <= shellD + 1e-7; y = Math.Round(y + Step, 8))
                        {
                            var entry = entry0.At(x, y);
                            var layout = new Layout($"path-3-{edge}-edge-entry", $"East-side test-shell edge; M01/M02 translated to share an edge", pair.Living, pair.Kitchen, entry);
                            if (InShell(entry) && NoStaticOverlap(layout)) candidates.Add(Score(layout));
                        }
                    }
                }
                return candidates.OrderBy(c => c.TotalTranslationFt).ThenBy(c => c.MaximumTranslationFt)
                    .ThenBy(c => c.Layout.Living.X).ThenBy(c => c.Layout.Entry.X).ThenBy(c => c.Layout.Entry.Y).FirstOrDefault()
                    ?? throw new InvalidDataException($"No {edge}-edge alternative passed the static rectangle screen.");
            }

            var front = BestFront();
            var north = BestEdge("north");
            var east = BestEdge("east");
            var chosenLayouts = new[] { Score(baseline), front, north, east };
            var checks = new Dictionary<string, bool>
            {
                ["source snapshot hash is pinned"] = sourceHashes["m282_snapshot"] == SnapshotHash,
                ["selected-D source hash is pinned and unchanged"] = sourceHashes["selected_d"] == SelectedDHash,
                ["three-path owner scope is recorded"] = scope.Contains("compare all three paths", StringComparison.OrdinalIgnoreCase),
                ["M01 source area and footprint preserved"] = Math.Abs(front.Layout.Living.Area - living0.Area) < 1e-6,
                ["M02 source area and footprint preserved"] = Math.Abs(front.Layout.Kitchen.Area - kitchen0.Area) < 1e-6,
                ["M05 source area and footprint preserved"] = chosenLayouts.All(c => Math.Abs(c.Layout.Entry.Area - entry0.Area) < 1e-6),
                ["source baseline remains separate and non-adjacent"] = SharedEdgeFt(baseline.Living, baseline.Kitchen) < 1e-6,
                ["front candidate creates positive shared-edge opportunity"] = SharedEdgeFt(front.Layout.Living, front.Layout.Kitchen) > 0,
                ["north candidate creates positive shared-edge opportunity"] = SharedEdgeFt(north.Layout.Living, north.Layout.Kitchen) > 0,
                ["east candidate creates positive shared-edge opportunity"] = SharedEdgeFt(east.Layout.Living, east.Layout.Kitchen) > 0,
                ["all candidate blocks remain in test shell"] = chosenLayouts.All(c => InShell(c.Layout.Living, Margin) && InShell(c.Layout.Kitchen, Margin) && InShell(c.Layout.Entry)),
                ["all candidate blocks avoid positive-area overlap with fixed M03/M04/A/B"] = chosenLayouts.All(c => NoStaticOverlap(c.Layout)),
                ["west A and B are not assigned or consumed"] = chosenLayouts.All(c => !Overlap(c.Layout.Entry, protectedA) && !Overlap(c.Layout.Entry, unassignedB)),
                ["no entry door, approach, route, or service fit is claimed"] = true,
                ["selected-D baseline source file remains unchanged"] = Hash(selectedPath) == SelectedDHash
            };
            Require(checks.Values.All(x => x), "One or more M284 acceptance checks failed.");

            var outputReport = new
            {
                schema = "forever-home-m284-entry-topology-screen-v1",
                status = "pass; analysis-only; no layout or entry orientation selected",
                method = "Quarter-foot translations of M01/M02 retain source orientations, dimensions, areas, and Y coordinate; connected candidates share the full M01 east edge with M02 west edge. M03/M04 and protected-A/unassigned-B rectangles stay fixed. Front M05 candidates stay on its source Y row; north/east candidates touch the corresponding test-shell edge. Select minimum sum of block-origin translation, then minimum maximum block translation, with stable coordinate tie-breaks. Positive overlap is tested with a 0.000001-ft per-axis tolerance; this filters the source's approximately 0.000004-sf floating-point edge sliver between M01 and M05.",
                source_hashes_sha256 = sourceHashes,
                shell_ft = new[] { shellW, shellD },
                source_blocks = new { living = living0, kitchen = kitchen0, dining, pantry, M05 = entry0, protected_A = protectedA, unassigned_B = unassignedB },
                outcomes = new
                {
                    baseline = Summarize(chosenLayouts[0], living0, kitchen0, entry0, SharedEdgeFt),
                    front_south = Summarize(front, living0, kitchen0, entry0, SharedEdgeFt),
                    north_rear_edge = Summarize(north, living0, kitchen0, entry0, SharedEdgeFt),
                    east_side_edge = Summarize(east, living0, kitchen0, entry0, SharedEdgeFt),
                    valid_connected_room_pair_positions = connectedCandidates.Count,
                    all_candidates_selected = false
                },
                checks = new { passed = checks.Count(x => x.Value), total = checks.Count, status = "pass", details = checks.Select(x => new { id = x.Key, pass = x.Value }).ToArray() },
                limitations = new[]
                {
                    "South/front/north/east labels refer only to the schematic coordinate axes; no site orientation or exterior façade is verified.",
                    "A zero-width shared boundary is only a room-block adjacency opportunity. No wall, opening span, header, structural support, door, approach, or continuous route is modeled.",
                    "Static rectangles omit wall thickness, furniture, occupant use, porch, site, utilities, and full clearance rules. A positive rectangle gap is not a required clearance standard.",
                    "M05 north/east contact is a shell-edge sensitivity, not an exterior entry design. No weather protection, landing, threshold, door swing, or egress is checked.",
                    "M-06/A/B are not assigned. Protected west A and unassigned B remain reserved rectangles only.",
                    "No dimensions or areas change in source selected-D; these positions are unselected analysis outputs only. No code, accessibility, structural, professional, permit, or construction-readiness conclusion follows."
                }
            };
            var checkFile = new { schema = "forever-home-m284-checks-v1", status = "pass", passed = checks.Count(x => x.Value), total = checks.Count, checks = checks.Select(x => new { id = x.Key, pass = x.Value }).ToArray() };
            Directory.CreateDirectory(output);
            WriteJson(Path.Combine(output, "m284-entry-topology-screen.json"), outputReport);
            WriteJson(Path.Combine(output, "m284-checks.json"), checkFile);
            File.WriteAllText(Path.Combine(output, "m284-entry-topology.svg"), MakeSvg(chosenLayouts, blockers, shellW, shellD), new UTF8Encoding(false));
            Console.WriteLine($"M284 {checks.Count}/{checks.Count} checks passed; connected room-pair positions={connectedCandidates.Count}; front/north/east examples found; no layout selected.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"M284 FAILED: {ex}");
            return 1;
        }
    }

    private static object Summarize(Candidate c, Rect originalLiving, Rect originalKitchen, Rect originalEntry, Func<Rect, Rect, double> shared)
    {
        var l = c.Layout;
        return new
        {
            id = l.Id, description = l.Description, selected = l.IsSelected,
            living = l.Living, kitchen = l.Kitchen, entry = l.Entry,
            living_translation_ft = new[] { Math.Round(l.Living.X - originalLiving.X, 6), Math.Round(l.Living.Y - originalLiving.Y, 6) },
            kitchen_translation_ft = new[] { Math.Round(l.Kitchen.X - originalKitchen.X, 6), Math.Round(l.Kitchen.Y - originalKitchen.Y, 6) },
            entry_translation_ft = new[] { Math.Round(l.Entry.X - originalEntry.X, 6), Math.Round(l.Entry.Y - originalEntry.Y, 6) },
            total_translation_ft = Math.Round(c.TotalTranslationFt, 6),
            living_kitchen_shared_edge_ft = Math.Round(shared(l.Living, l.Kitchen), 6),
            entry_gap_to_M04_in = Math.Round(c.M04GapIn, 3), entry_gap_to_protected_A_in = Math.Round(c.AGapIn, 3), entry_gap_to_unassigned_B_in = Math.Round(c.BGapIn, 3),
            static_positive_area_overlap = false,
            entry_door_approach_and_service_route_verified = false
        };
    }

    private static string MakeSvg(Candidate[] layouts, Rect[] blockers, double shellW, double shellD)
    {
        const double scale = 8.0, padX = 22.0, rowGap = 24.0;
        double panelH = shellD * scale + 48;
        double width = shellW * scale + padX * 2;
        double height = panelH * layouts.Length + rowGap * (layouts.Length - 1) + 30;
        var s = new StringBuilder();
        s.AppendLine("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + F(width) + "\" height=\"" + F(height) + "\" viewBox=\"0 0 " + F(width) + " " + F(height) + "\">");
        s.AppendLine("<style>text{font-family:Arial,sans-serif;font-size:11px}.title{font-weight:bold;font-size:13px}.note{fill:#555}.shell{fill:none;stroke:#222;stroke-width:2}.room{fill:#d8e7ed;stroke:#24566c;stroke-width:1.5}.entry{fill:#efe3c4;stroke:#755b22;stroke-width:1.5}.fixed{fill:#e1d4e9;stroke:#68437c;stroke-width:1}</style>");
        string[] ids = { "BASELINE", "FRONT/SOUTH", "NORTH/REAR", "EAST/SIDE" };
        for (int i = 0; i < layouts.Length; i++)
        {
            var c = layouts[i]; var l = c.Layout; double ox = padX, oy = 28 + i * (panelH + rowGap);
            s.AppendLine($"<text class=\"title\" x=\"{F(ox)}\" y=\"{F(oy)}\">{ids[i]} — {System.Security.SecurityElement.Escape(l.Description)}</text>");
            double sy = oy + 13;
            s.AppendLine($"<rect class=\"shell\" x=\"{F(ox)}\" y=\"{F(sy)}\" width=\"{F(shellW * scale)}\" height=\"{F(shellD * scale)}\"/>");
            Draw(l.Living, "M-01 LIVING", "room", ox, sy, scale);
            Draw(l.Kitchen, "M-02 KITCHEN", "room", ox, sy, scale);
            Draw(l.Entry, "M-05 ENTRY/HALL", "entry", ox, sy, scale);
            foreach (var r in blockers)
                Draw(r, r.Id, "fixed", ox, sy, scale);
            s.AppendLine($"<text class=\"note\" x=\"{F(ox)}\" y=\"{F(sy + shellD * scale + 13)}\">Shared M-01/M-02 edge: {F(shared(l.Living,l.Kitchen))} ft | movement sum: {F(c.TotalTranslationFt)} ft | blocks only; no door or route</text>");
        }
        s.AppendLine("</svg>");
        return s.ToString();
        void Draw(Rect r, string label, string css, double ox, double oy, double sc)
        {
            double x = ox + r.X * sc, y = oy + (shellD - r.Y - r.D) * sc;
            s.AppendLine($"<rect class=\"{css}\" x=\"{F(x)}\" y=\"{F(y)}\" width=\"{F(r.W * sc)}\" height=\"{F(r.D * sc)}\"/>");
            s.AppendLine($"<text x=\"{F(x + 2)}\" y=\"{F(y + 12)}\">{System.Security.SecurityElement.Escape(label)}</text>");
        }
        static double shared(Rect a, Rect b)
        {
            if (Math.Abs(a.X + a.W - b.X) < 1e-6 || Math.Abs(b.X + b.W - a.X) < 1e-6) return Math.Max(0, Math.Min(a.Y+a.D,b.Y+b.D)-Math.Max(a.Y,b.Y));
            if (Math.Abs(a.Y + a.D - b.Y) < 1e-6 || Math.Abs(b.Y + b.D - a.Y) < 1e-6) return Math.Max(0, Math.Min(a.X+a.W,b.X+b.W)-Math.Max(a.X,b.X));
            return 0;
        }
    }

    private static void WriteJson(string path, object value) => File.WriteAllText(path, JsonSerializer.Serialize(value, JsonOptions) + "\n", new UTF8Encoding(false));
    private static string F(double value) => value.ToString("0.###", CultureInfo.InvariantCulture);
    private static string FindRoot() { for (var d = new DirectoryInfo(Environment.CurrentDirectory); d is not null; d = d.Parent) if (File.Exists(Path.Combine(d.FullName, "AGENTS.md")) && (Directory.Exists(Path.Combine(d.FullName, ".git")) || File.Exists(Path.Combine(d.FullName, ".git")))) return d.FullName; throw new DirectoryNotFoundException("Repository root with AGENTS.md was not found."); }
    private static string Resolve(string root, string path) => Path.GetFullPath(Path.IsPathRooted(path) ? path : Path.Combine(root, path));
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
    private static JsonNode Read(string path) => JsonNode.Parse(File.ReadAllText(path)) ?? throw new InvalidDataException($"Invalid JSON: {path}");
    private static string? Text(JsonNode? n) => n is null ? null : n is JsonValue v && v.TryGetValue<string>(out var s) ? s : n.ToJsonString();
    private static double Num(JsonNode? n) => n is null ? throw new InvalidDataException("Required number is missing.") : double.Parse(n.ToJsonString(), CultureInfo.InvariantCulture);
    private static void Require(bool condition, string message) { if (!condition) throw new InvalidDataException(message); }
}
