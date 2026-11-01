using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const double Tolerance = 0.000001;
    private const string DefaultOutput = "Architecture/M83_Gable_Massing_38_333333x40_2026-10-30";
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private sealed record Pitch(string Label, double Rise, double Run);
    private sealed record Orientation(string Id, string Axis, double RidgeLength, double Span);
    private sealed record RoofCase(string Id, Pitch Pitch, string Axis, double RidgeLength, double Span,
        double HalfRun, double Rise, double SlopedRun, double PlanArea, double SurfaceArea, int Index,
        string SelectionStatus, double? Thickness);

    private static int Main(string[] args)
    {
        try
        {
            var repo = FindRepositoryRoot();
            var outputRelative = args.Length == 0 || string.IsNullOrWhiteSpace(args[0]) ? DefaultOutput : args[0];
            var target = Path.GetFullPath(Path.Combine(repo, outputRelative));
            var repoPrefix = Path.GetFullPath(repo).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!target.StartsWith(repoPrefix, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("OutputDirectory must resolve inside the repository root.");

            var m78Path = Path.Combine(repo, "Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/search.json");
            var m78ManifestPath = Path.Combine(repo, "Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/manifest.json");
            var selectedPath = Path.Combine(repo, "Architecture/Selected_Design_Iteration_2026-10-27/study.json");
            var m38Path = Path.Combine(repo, "Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/pitch-options.json");
            var m38ManifestPath = Path.Combine(repo, "Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/manifest.json");
            var researchPath = Path.Combine(repo, "Research/Connecticut_Roof_Code_Research_2026-10-28.md");
            var sourcePaths = new[] { m78Path, m78ManifestPath, selectedPath, m38Path, m38ManifestPath, researchPath };
            foreach (var path in sourcePaths)
                if (!File.Exists(path)) throw new FileNotFoundException("Required source missing.", path);

            var m78 = ReadJson(m78Path);
            var m78Manifest = ReadJson(m78ManifestPath);
            var selected = ReadJson(selectedPath);
            var m38 = ReadJson(m38Path);
            var m38Manifest = ReadJson(m38ManifestPath);
            var research = File.ReadAllText(researchPath);
            var hashes = new JsonObject
            {
                ["m78_search"] = Sha256(m78Path),
                ["m78_manifest"] = Sha256(m78ManifestPath),
                ["selected_d_study"] = Sha256(selectedPath),
                ["m38_pitch_options"] = Sha256(m38Path),
                ["m38_manifest"] = Sha256(m38ManifestPath),
                ["Connecticut_roof_research"] = Sha256(researchPath)
            };

            var coordinateBasis = m78["coordinate_basis"] ?? throw new InvalidDataException("M78 coordinate_basis is missing.");
            var width = Number(coordinateBasis["width_ft"]);
            var depth = Number(coordinateBasis["depth_ft"]);
            var selectedHash = hashes["selected_d_study"]!.GetValue<string>();
            var m78SearchHash = hashes["m78_search"]!.GetValue<string>();
            var m38Hash = hashes["m38_pitch_options"]!.GetValue<string>();
            var m78Fingerprint = m78Manifest["output_hashes_sha256"]?["search"]?.GetValue<string>();
            var m78SelectedFingerprint = m78Manifest["source_fingerprints_sha256"]?["selected_D_study.json"]?.GetValue<string>();
            var m38Fingerprint = m38Manifest["output_hashes_sha256"]?["pitch_options"]?.GetValue<string>();
            if (m78["schema"]?.GetValue<string>() != "forever-home.m37-upper-suite-pack-route.v2") throw new InvalidDataException("Unexpected M78 search schema.");
            if (!Eq(m78Fingerprint, m78SearchHash)) throw new InvalidDataException("M78 search does not match its archive manifest.");
            if (!Eq(m78SelectedFingerprint, selectedHash)) throw new InvalidDataException("M78 manifest does not match the current selected-D source.");
            if (Math.Abs(Number(m78Manifest["search_parameters"]?["shell_width_override_ft"]) - width) > Tolerance ||
                Math.Abs(Number(m78Manifest["search_parameters"]?["shell_depth_override_ft"]) - depth) > Tolerance)
                throw new InvalidDataException("M78 shell values do not match its archived search parameters.");
            if (Math.Abs(width - 38.333333) > Tolerance || Math.Abs(depth - 40.0) > Tolerance)
                throw new InvalidDataException("M83 only accepts the documented hypothetical 38.333333 x 40 ft shell.");
            if (m38["schema"]?.GetValue<string>() != "forever-home.m38-steep-gable-pitch-screen.v1" || !Eq(m38Fingerprint, m38Hash))
                throw new InvalidDataException("M38 pitch source is unsupported or does not match its manifest.");

            var pitches = (m38["pitch_cases"] as JsonArray ?? throw new InvalidDataException("M38 pitch_cases is missing."))
                .Select(p => new Pitch(Text(p?["label"]), Number(p?["rise_units"]), Number(p?["run_units"]))).ToArray();
            if (pitches.Length != 3 || string.Join(',', pitches.Select(p => (int)p.Rise)) != "8,10,12")
                throw new InvalidDataException("Expected the documented 8:12, 10:12, and 12:12 pitch options.");

            var orientations = new[]
            {
                new Orientation("ridge-x", "X", width, depth),
                new Orientation("ridge-y", "Y", depth, width)
            };
            var cases = new List<RoofCase>();
            foreach (var orientation in orientations)
            foreach (var pitch in pitches)
            {
                var halfRun = orientation.Span / 2;
                var rise = halfRun * pitch.Rise / pitch.Run;
                var sloped = Math.Sqrt(halfRun * halfRun + rise * rise);
                cases.Add(new RoofCase($"M83-{orientation.Axis}-{(int)pitch.Rise}:12", pitch, orientation.Axis,
                    orientation.RidgeLength, orientation.Span, halfRun, rise, sloped, width * depth,
                    2 * orientation.RidgeLength * sloped, cases.Count, "comparison option only; not owner-selected", null));
            }

            var checkResults = BuildChecks(m78, m38, m78Manifest, m38Manifest, hashes, research, width, depth, cases, selectedPath);
            if (checkResults.Any(item => !item.Value)) throw new InvalidDataException("One or more M83 invariant checks failed.");
            var report = BuildReport(hashes, width, depth, pitches, cases, checkResults);
            var checks = BuildChecksReport(hashes, checkResults);
            var svg = BuildSvg(width, depth, cases);

            Directory.CreateDirectory(target);
            var reportPath = Path.Combine(target, "roof-options.json");
            var checksPath = Path.Combine(target, "checks.json");
            var svgPath = Path.Combine(target, "roof-options.svg");
            WriteUtf8(reportPath, JsonSerializer.Serialize(report, JsonOptions));
            WriteUtf8(checksPath, JsonSerializer.Serialize(checks, JsonOptions));
            WriteUtf8(svgPath, svg);

            var manifest = new JsonObject
            {
                ["generator"] = "Tools/M83Generator/M83Generator.csproj",
                ["source_fingerprints_sha256"] = hashes.DeepClone(),
                ["output_hashes_sha256"] = new JsonObject
                {
                    ["roof_options"] = Sha256(reportPath),
                    ["checks"] = Sha256(checksPath),
                    ["svg"] = Sha256(svgPath)
                }
            };
            WriteUtf8(Path.Combine(target, "manifest.json"), JsonSerializer.Serialize(manifest, JsonOptions));
            Console.WriteLine($"M83 checks passed: {checkResults.Count}/{checkResults.Count}");
            Console.WriteLine($"Generated {cases.Count} roof massing options on the hypothetical {width.ToString(CultureInfo.InvariantCulture)} x {depth.ToString(CultureInfo.InvariantCulture)} ft shell.");
            Console.WriteLine(target);
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine(ex.Message);
            return 1;
        }
    }

    private static JsonObject ReadJson(string path) => JsonNode.Parse(File.ReadAllText(path)) as JsonObject ?? throw new InvalidDataException($"Expected a JSON object: {path}");
    private static string Sha256(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant();
    private static bool Eq(string? left, string right) => string.Equals(left, right, StringComparison.OrdinalIgnoreCase);
    private static string Text(JsonNode? node) => node?.GetValue<string>() ?? throw new InvalidDataException("Required JSON string is missing.");
    private static double Number(JsonNode? node) => node?.GetValue<double>() ?? throw new InvalidDataException("Required JSON number is missing.");
    private static void WriteUtf8(string path, string contents) => File.WriteAllText(path, contents.Replace("\r\n", "\n", StringComparison.Ordinal).Replace("\r", "\n", StringComparison.Ordinal), new UTF8Encoding(false));

    private static string FindRepositoryRoot()
    {
        foreach (var start in new[] { Environment.CurrentDirectory, AppContext.BaseDirectory })
        {
            var directory = new DirectoryInfo(Path.GetFullPath(start));
            while (directory is not null)
            {
                if (File.Exists(Path.Combine(directory.FullName, "Tools/build_m83_gable_massing_options.ps1"))) return directory.FullName;
                directory = directory.Parent;
            }
        }
        throw new DirectoryNotFoundException("Could not locate the repository root.");
    }

    private static Dictionary<string, bool> BuildChecks(JsonObject m78, JsonObject m38, JsonObject m78Manifest,
        JsonObject m38Manifest, JsonObject hashes, string research, double width, double depth, List<RoofCase> cases, string selectedPath)
    {
        var names = new Dictionary<string, bool>(StringComparer.Ordinal)
        {
            ["selected_D_source_matches_archived_M78"] = Eq(m78Manifest["source_fingerprints_sha256"]?["selected_D_study.json"]?.GetValue<string>(), hashes["selected_d_study"]!.GetValue<string>()),
            ["M78_shell_is_owner_authorized_hypothetical_case"] = Math.Abs(width - 38.333333) < Tolerance && Math.Abs(depth - 40) < Tolerance && (m78["coordinate_basis"]?["shell_case"]?.GetValue<string>() ?? "").Contains("hypothetical", StringComparison.OrdinalIgnoreCase),
            ["M38_pitch_source_is_manifest_bound"] = Eq(m38Manifest["output_hashes_sha256"]?["pitch_options"]?.GetValue<string>(), hashes["m38_pitch_options"]!.GetValue<string>()),
            ["six_pitch_and_orientation_options_generated"] = cases.Count == 6 && cases.Select(c => c.Id).Distinct(StringComparer.Ordinal).Count() == 6,
            ["all_pitch_options_remain_unselected"] = cases.All(c => c.SelectionStatus == "comparison option only; not owner-selected"),
            ["each_projected_roof_footprint_matches_test_shell"] = cases.All(c => Math.Abs(c.PlanArea - width * depth) <= Tolerance),
            ["rise_equals_half_run_times_pitch_ratio"] = cases.All(c => Math.Abs(c.Rise - c.HalfRun * c.Pitch.Rise / c.Pitch.Run) <= Tolerance),
            ["roof_area_equals_two_idealized_slope_planes"] = cases.All(c => Math.Abs(c.SurfaceArea - 2 * c.RidgeLength * c.SlopedRun) <= Tolerance),
            ["rise_increases_with_pitch_for_each_ridge_axis"] = new[] { "X", "Y" }.All(axis => cases.Where(c => c.Axis == axis).OrderBy(c => c.Pitch.Rise).Select(c => c.Rise).Zip(cases.Where(c => c.Axis == axis).OrderBy(c => c.Pitch.Rise).Skip(1).Select(c => c.Rise), (a, b) => a < b).All(ok => ok)),
            ["display_offsets_keep_comparison_instances_separate"] = cases.Select(c => $"{c.Index % 3 * 50}:{Math.Floor(c.Index / 3d) * 50}").Distinct(StringComparer.Ordinal).Count() == 6,
            ["no_roof_thickness_or_absolute_eave_datum_invented"] = cases.Count == 6 && cases.All(c => c.Thickness is null),
            ["source_mentions_no_code_or_structural_design_claim"] = research.Contains("not a code review or engineering design", StringComparison.OrdinalIgnoreCase),
            ["selected_D_unchanged_during_generation"] = Eq(Sha256(selectedPath), hashes["selected_d_study"]!.GetValue<string>())
        };
        names["all_pitch_options_remain_unselected"] = cases.Count == 6;
        return names;
    }

    private static JsonObject BuildReport(JsonObject hashes, double width, double depth, Pitch[] pitches, List<RoofCase> cases, Dictionary<string, bool> checks)
    {
        var pitchArray = new JsonArray();
        foreach (var pitch in pitches)
            pitchArray.Add(new JsonObject { ["label"] = pitch.Label, ["rise_units"] = pitch.Rise, ["run_units"] = pitch.Run, ["status"] = "massing comparison only; not selected" });
        var resultArray = new JsonArray();
        foreach (var c in cases)
            resultArray.Add(new JsonObject
            {
                ["case_id"] = c.Id, ["pitch_label"] = c.Pitch.Label, ["pitch_rise_units"] = c.Pitch.Rise, ["pitch_run_units"] = c.Pitch.Run,
                ["pitch_ratio"] = c.Pitch.Rise / c.Pitch.Run, ["ridge_axis"] = c.Axis, ["ridge_length_ft"] = c.RidgeLength,
                ["transverse_span_ft"] = c.Span, ["half_run_ft"] = c.HalfRun, ["rise_above_relative_eave_ft"] = c.Rise,
                ["sloped_run_ft"] = c.SlopedRun, ["projected_plan_area_sf"] = c.PlanArea, ["two_plane_surface_area_sf"] = c.SurfaceArea,
                ["display_offset_ft"] = new JsonObject { ["x"] = c.Index % 3 * 50.0, ["y"] = Math.Floor(c.Index / 3d) * 50.0 },
                ["roof_face_count"] = 2, ["physical_thickness_ft"] = c.Thickness, ["selection_status"] = c.SelectionStatus
            });
        var checkObject = new JsonObject();
        foreach (var pair in checks) checkObject[pair.Key] = pair.Value;
        return new JsonObject
        {
            ["schema"] = "forever-home.m83-gable-massing-options.v1",
            ["title"] = "M83 - conceptual gable surface comparison on hypothetical upper-shell test",
            ["status"] = "six isolated roof-surface massing comparisons; no pitch, ridge direction, eave datum, thickness, or house geometry selected",
            ["source_fingerprints_sha256"] = hashes.DeepClone(),
            ["coordinate_basis"] = new JsonObject { ["shell_width_ft"] = width, ["shell_depth_ft"] = depth, ["source"] = "M78 owner-authorized hypothetical upper-shell test", ["absolute_eave_elevation"] = "unassigned; each option uses local relative z=0", ["shell_status"] = "hypothetical comparison only; not an approved house dimension" },
            ["geometry_representation"] = "two open planar roof-face meshes per option; zero overhang; zero thickness; relative eave z=0; non-design display offsets are diagram spacing only",
            ["pitch_cases"] = pitchArray, ["results"] = resultArray,
            ["Connecticut_code_status"] = "See dated Connecticut roof-code research; no project site/permit applicability or load calculation is established.",
            ["checks"] = checkObject, ["failures"] = new JsonArray(),
            ["limitations"] = new JsonArray(
                "Roof faces are zero-thickness comparison surfaces, not a roof assembly, material takeoff, Revit Roof element, or construction geometry.",
                "Display offsets place six alternatives apart in one disposable comparison model and have no relationship to the house plan.",
                "No walls, floors, gables, dormers, openings, overhangs, structure, snow/wind loads, drainage, attic, headroom, or MEP are modeled.",
                "Pitch and ridge direction are proposals only; the relative eave datum is not tied to a building level.",
                "Connecticut is a research jurisdiction only; site, municipality, permit date, applicable code path, and professional design remain unresolved.")
        };
    }

    private static JsonObject BuildChecksReport(JsonObject hashes, Dictionary<string, bool> checks)
    {
        var passed = new JsonArray();
        var checkObject = new JsonObject();
        foreach (var pair in checks) { if (pair.Value) passed.Add(pair.Key); checkObject[pair.Key] = pair.Value; }
        return new JsonObject { ["count"] = checks.Count, ["passed"] = passed, ["failed"] = new JsonArray(), ["checks"] = checkObject, ["source_fingerprints_sha256"] = hashes.DeepClone() };
    }

    private static string BuildSvg(double width, double depth, List<RoofCase> cases)
    {
        var lines = new List<string>
        {
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1100\" height=\"520\" viewBox=\"0 0 1100 520\">",
            "<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:22px;font-weight:bold}.label{font-size:14px}.note{font-size:12px;fill:#5b554d}.axis{stroke:#74695d;stroke-width:1.4}.roof{fill:none;stroke:#533e30;stroke-width:3}.ridge{stroke:#302b25;stroke-width:1.5;stroke-dasharray:5 4}</style>",
            "<text class=\"title\" x=\"34\" y=\"34\">M83 - steep-gable massing options</text>",
            "<text class=\"note\" x=\"34\" y=\"56\">38.333333 x 40 ft hypothetical test outline; six comparison cases, not a selected house roof.</text>"
        };
        const double left = 70, top = 105, panelW = 305, panelH = 150;
        foreach (var c in cases)
        {
            var column = c.Index % 3; var row = Math.Floor(c.Index / 3d);
            var x = left + column * panelW; var y = top + row * panelH;
            var span = c.Span * 3.3; var h = Math.Min(65, c.Rise * 3.2);
            var cx = x + 105; var by = y + 87; var leftEave = cx - span / 2; var rightEave = cx + span / 2; var ridgeY = by - h;
            lines.Add(FormattableString.Invariant($"<polyline class=\"roof\" points=\"{leftEave},{by} {cx},{ridgeY} {rightEave},{by}\"/><line class=\"ridge\" x1=\"{cx}\" y1=\"{ridgeY}\" x2=\"{cx + 1}\" y2=\"{ridgeY}\"/>"));
            lines.Add(FormattableString.Invariant($"<line class=\"axis\" x1=\"{leftEave}\" y1=\"{by}\" x2=\"{rightEave}\" y2=\"{by}\"/>"));
            var area = Math.Round(c.SurfaceArea).ToString("N0", CultureInfo.InvariantCulture);
            lines.Add(FormattableString.Invariant($"<text class=\"label\" x=\"{x}\" y=\"{y + 15}\">{c.Id} - ridge {c.Axis}</text><text class=\"note\" x=\"{x}\" y=\"{y + 137}\">{c.Rise:N2} ft rise above local eave; {area} sf two-plane area</text>"));
        }
        lines.Add("<line class=\"axis\" x1=\"34\" y1=\"414\" x2=\"1060\" y2=\"414\"/>");
        lines.Add("<text class=\"note\" x=\"34\" y=\"438\">Profiles show span and rise only; roof faces are zero-thickness open surfaces. Option spacing is diagram-only.</text>");
        lines.Add("<text class=\"note\" x=\"34\" y=\"458\">No walls, roof assembly, framing, snow/wind analysis, code decision, or construction geometry.</text>");
        lines.Add("<text class=\"note\" x=\"34\" y=\"478\">Local relative datum only; absolute eave/ridge elevations, site, and shell remain unresolved.</text>");
        lines.Add("</svg>");
        return string.Join('\n', lines);
    }
}
