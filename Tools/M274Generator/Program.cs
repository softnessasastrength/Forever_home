using System.Globalization;
using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Nodes;

static void Require(bool condition, string message)
{
    if (!condition) throw new InvalidDataException(message);
}

static string Sha256(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
static double Number(JsonNode? node) => double.Parse(node?.ToString() ?? throw new InvalidDataException("Missing number."), CultureInfo.InvariantCulture);
static bool Bool(JsonNode? node) => bool.Parse(node?.ToString() ?? throw new InvalidDataException("Missing boolean."));

if (args.Length != 4)
{
    Console.Error.WriteLine("Usage: M274Generator <m230-report.json> <m269-candidate-family-geometry.json> <selected-d-study.json> <output-directory>");
    return 2;
}

var m230Path = Path.GetFullPath(args[0]);
var m269Path = Path.GetFullPath(args[1]);
var selectedDPath = Path.GetFullPath(args[2]);
var outputDirectory = Path.GetFullPath(args[3]);
var m230Hash = Sha256(m230Path);
var m269Hash = Sha256(m269Path);
var selectedDHash = Sha256(selectedDPath);
Require(m230Hash == "1859CED601E1982D41BAEE58A191F2766771729921FBCD8AC3A59DC590B0E686", "M230 source report hash changed.");
Require(m269Hash == "A9B396221B90FF54DE773CCB80C02E6D9B6B26CA81EEEFFA0A504F33DF60F3C2", "M269 family inspection report hash changed.");
Require(selectedDHash.Equals("516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB", StringComparison.OrdinalIgnoreCase), "Selected-D study source hash changed.");

var m230 = JsonNode.Parse(File.ReadAllText(m230Path)) ?? throw new InvalidDataException("Invalid M230 JSON.");
var m269 = JsonNode.Parse(File.ReadAllText(m269Path)) ?? throw new InvalidDataException("Invalid M269 JSON.");
Require(m230["schema"]?.ToString() == "forever-home.m06-west-a-toilet-lavatory-pair-envelopes.v1", "Unexpected M230 schema.");
Require(m269["schema"]?.ToString() == "forever-home-candidate-family-geometry-v1", "Unexpected M269 schema.");
Require(m230["source_hashes_sha256"]?["selected_d"]?.ToString() == "516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb", "Selected-D fingerprint mismatch.");
Require(selectedDHash.Equals(m230["source_hashes_sha256"]?["selected_d"]?.ToString(), StringComparison.OrdinalIgnoreCase), "M230 selected-D source fingerprint differs from the current study.");
Require(m269["source"]?["sha256_before"]?.ToString() == "3b1cbdaa844d35bd462f6e59a828b82f7870fde4ee7397bac09f4ca0c2f9b949", "Unexpected source family fingerprint.");
Require(m269["source"]?["sha256_after"]?.ToString() == "3b1cbdaa844d35bd462f6e59a828b82f7870fde4ee7397bac09f4ca0c2f9b949", "Family source changed during inspection.");
var sourceFamilyPath = Path.GetFullPath(m269["source"]?["path"]?.ToString() ?? throw new InvalidDataException("Missing source family path."));
var currentFamilyHash = Sha256(sourceFamilyPath);
Require(currentFamilyHash.Equals(m269["source"]?["sha256_before"]?.ToString(), StringComparison.OrdinalIgnoreCase), "Current source RFA hash differs from the inspected source.");
Require(m269["project_scope"]?["selected_d_opened"]?.ToString() == "false", "M269 opened selected-D.");
Require(Number(m269["project_scope"]?["family_instances_placed"]) == 0, "M269 placed a family instance.");
Require(m230["west_a"]?["remains_unassigned"]?.ToString() == "true", "West A must remain unassigned.");
Require(m230["owner_protection_scope"]?.ToString().Contains("B remains unassigned", StringComparison.Ordinal) == true, "East B must remain unassigned.");
Require(m230["assumed_same_wall_screen"]?["code_compliance"]?.ToString() == "false", "M230 must not claim code compliance.");
Require(m269["project_scope"]?["derivative_type"]?.ToString() == "new_imperial_project", "M269 is not a separate derivative.");

var boundsByType = (m269["types"]?.AsArray() ?? throw new InvalidDataException("Missing types."))
    .Select(t => new
    {
        Name = t?["type"]?.ToString() ?? "",
        Width = Number(t?["bounds"]?["width_x"]),
        Depth = Number(t?["bounds"]?["depth_y"]),
        Height = Number(t?["bounds"]?["height_z"]),
        Solids = Number(t?["solid_metrics"]?["positive_volume_solid_count"])
    }).ToArray();
Require(boundsByType.Length == 10, "Expected all ten inspected Tresham types.");
Require(boundsByType.All(t => t.Width > 0 && t.Depth > 0 && t.Height > 0 && t.Solids > 0), "Invalid type geometry.");
var width = boundsByType[0].Width;
var depth = boundsByType[0].Depth;
Require(boundsByType.All(t => Math.Abs(t.Width - width) < 1e-9 && Math.Abs(t.Depth - depth) < 1e-9), "Tresham type bounds differ.");
Require(Math.Abs(width - 24.1319) < 1e-9 && Math.Abs(depth - 19.5626) < 1e-9, "Tresham bounds differ from reviewed evidence.");

var m230Cases = m230["cases"]?.AsArray() ?? throw new InvalidDataException("Missing M230 cases.");
var priorCases = m230Cases.Where(c => c?["sink_id"]?.ToString() == "kohler-tresham-k-2844-4-0")
    .OrderBy(c => Number(c?["sink_rotation_deg"])).ToArray();
Require(priorCases.Length == 2, "Expected two prior Tresham orientation cases.");
var grossWidth = Number(m230["west_a"]?["gross_width_in"]);
var grossDepth = Number(m230["west_a"]?["gross_depth_in"]);
var wcWidth = Number(m230["toilet"]?["plan_width_in"]);
var wcProjection = Number(m230["toilet"]?["plan_projection_in"]);
var side = Number(m230["assumed_same_wall_screen"]?["wc_centerline_to_side_boundary_in"]);
var spacing = Number(m230["assumed_same_wall_screen"]?["wc_centerline_to_adjacent_fixture_centerline_in"]);
var front = Number(m230["assumed_same_wall_screen"]?["front_clear_strip_in"]);
Require(grossWidth == 62 && grossDepth == 137 && wcWidth == 19 && wcProjection == 30.25, "M230 dimensions changed.");
Require(side == 15 && spacing == 30 && front == 21, "M230 residential screening values changed.");

var cases = new[] { 0, 90 }.Select(rotation =>
{
    var bodyWidth = rotation == 0 ? width : depth;
    var bodyDepth = rotation == 0 ? depth : width;
    var sinkCenter = side + spacing;
    var sinkLeft = sinkCenter - bodyWidth / 2;
    var sinkRight = sinkCenter + bodyWidth / 2;
    var wcRight = side + wcWidth / 2;
    var requiredWidth = Math.Max(wcRight, sinkRight);
    var requiredDepth = Math.Max(wcProjection, bodyDepth) + front;
    return new
    {
        rotation_deg = rotation,
        measured_symbol_bounds_plan_width_in = width,
        measured_symbol_bounds_plan_depth_in = depth,
        assumed_plan_body_width_along_shared_wall_in = bodyWidth,
        assumed_plan_body_depth_from_shared_line_in = bodyDepth,
        toilet_centerline_from_left_reference_in = side,
        lavatory_centerline_from_left_reference_in = sinkCenter,
        sink_centerline_to_left_boundary_in = sinkCenter,
        sink_centerline_to_right_boundary_in = grossWidth - sinkCenter,
        wc_centerline_to_nearest_lav_body_edge_in = sinkLeft - side,
        body_rectangles_nonoverlap = sinkLeft >= wcRight,
        required_gross_width_in = Math.Round(requiredWidth, 4),
        required_gross_depth_in_including_front_strip = Math.Round(requiredDepth, 4),
        remaining_gross_width_in = Math.Round(grossWidth - requiredWidth, 4),
        remaining_gross_depth_in = Math.Round(grossDepth - requiredDepth, 4),
        contained_in_gross_west_a = requiredWidth <= grossWidth && requiredDepth <= grossDepth,
        sink_centerline_clear_of_both_gross_side_boundaries = sinkCenter >= 15 && grossWidth - sinkCenter >= 15,
        wc_side_centerline_screen_pass = sinkLeft - side >= 15,
        centerline_spacing_screen_pass = spacing >= 30,
        front_strip_added_in = front,
        room_assignment = "unassigned",
        assumption = "Axis-aligned family-symbol bounds are treated as a rectangular plan envelope, their bounding-box midpoint is used as a provisional lavatory centerline, and the envelope is rotated 0/90 degrees; installed orientation and origin-to-product-center relationship are not verified."
    };
}).ToArray();

var checks = new SortedDictionary<string, bool>(StringComparer.Ordinal)
{
    ["all_ten_family_types_have_positive_solids_and_equal_plan_bounds"] = boundsByType.Length == 10 && boundsByType.All(t => t.Solids > 0 && Math.Abs(t.Width - width) < 1e-9 && Math.Abs(t.Depth - depth) < 1e-9),
    ["both_orientations_add_front_clearance_strip"] = cases.All(c => c.front_strip_added_in == 21),
    ["both_orientations_keep_centerline_spacing_screen"] = cases.All(c => c.centerline_spacing_screen_pass),
    ["both_orientations_keep_side_centerline_screens"] = cases.All(c => c.wc_side_centerline_screen_pass && c.sink_centerline_clear_of_both_gross_side_boundaries),
    ["both_orientations_remain_gross_contained"] = cases.All(c => c.contained_in_gross_west_a),
    ["both_orientations_keep_nonoverlapping_body_envelopes"] = cases.All(c => c.body_rectangles_nonoverlap),
    ["east_b_remains_unassigned"] = m230["owner_protection_scope"]?.ToString().Contains("B remains unassigned", StringComparison.Ordinal) == true,
    ["family_was_inspected_in_separate_derivative"] = m269["project_scope"]?["derivative_type"]?.ToString() == "new_imperial_project",
    ["family_source_hash_before_and_after_matches"] = m269["source"]?["sha256_before"]?.ToString() == m269["source"]?["sha256_after"]?.ToString(),
    ["m230_and_m269_input_hashes_match_pinned_evidence"] = m230Hash == "1859CED601E1982D41BAEE58A191F2766771729921FBCD8AC3A59DC590B0E686" && m269Hash == "A9B396221B90FF54DE773CCB80C02E6D9B6B26CA81EEEFFA0A504F33DF60F3C2",
    ["selected_d_fingerprint_matches_pinned_baseline"] = selectedDHash.Equals("516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB", StringComparison.OrdinalIgnoreCase) && selectedDHash.Equals(m230["source_hashes_sha256"]?["selected_d"]?.ToString(), StringComparison.OrdinalIgnoreCase),
    ["source_rfa_current_hash_matches_revit_inspection"] = currentFamilyHash.Equals(m269["source"]?["sha256_before"]?.ToString(), StringComparison.OrdinalIgnoreCase),
    ["selected_d_was_not_opened_or_modified"] = Bool(m269["project_scope"]?["selected_d_opened"]) == false && m230["selected_d_modified"]?.ToString() == "false",
    ["west_a_remains_unassigned"] = m230["west_a"]?["remains_unassigned"]?.ToString() == "true",
    ["no_access_service_or_project_compliance_claim"] = m230["assumed_same_wall_screen"]?["door_approach_or_service_route_modeled"]?.ToString() == "false" && m230["assumed_same_wall_screen"]?["code_compliance"]?.ToString() == "false"
};
Require(checks.Values.All(v => v), "One or more M274 checks failed.");

var report = new
{
    schema = "forever-home.m274-measured-tresham-envelope-screen.v1",
    status = "bounded gross-room-block sensitivity; Tresham unselected; no bathroom assignment or installed fit established",
    inputs_sha256 = new { m230_report = m230Hash, m269_family_report = m269Hash, selected_d_study = selectedDHash },
    source_family_sha256 = currentFamilyHash,
    selected_d_sha256 = m230["source_hashes_sha256"]?["selected_d"]?.ToString(),
    room = new { label = "west A", gross_width_in = grossWidth, gross_depth_in = grossDepth, gross_area_sf = Number(m230["west_a"]?["gross_area_sf"]), remains_unassigned = true },
    toilet = new { sku = m230["toilet"]?["selected_sku"]?.ToString(), plan_width_in = wcWidth, plan_projection_in = wcProjection, exact_sku_rfa_cad_verified = false },
    lavatory_candidate = new { family = m269["family"]?.ToString(), category = m269["category"]?.ToString(), selected = false, type_count = boundsByType.Length, measured_symbol_bounds_plan_width_in = width, measured_symbol_bounds_plan_depth_in = depth, coordinate_frame = "unplaced axis-aligned family-symbol bounds; not installed orientation" },
    screening_basis = new { source = "2022 CSBC / adopted 2021 IRC R307.1 and P2705.1; project applicability undetermined", wc_centerline_to_side_boundary_in = side, wc_to_adjacent_fixture_centerline_in = spacing, front_clear_strip_in = front, code_compliance = false },
    cases,
    findings = new[]
    {
        "Both measured-bound orientations fit the 62 x 137 in gross west-A comparison rectangle under the inherited same-wall assumptions.",
        "Measured 0-degree width leaves 4.9341 in of gross width, versus 5.0000 in in M230's nominal 24-in Tresham plan proxy; this 0.0659-in change does not establish a finished-face reserve.",
        "The 90-degree case leaves 7.2187 in of gross width under the same bounding-box abstraction.",
        "These values do not include finished wall assemblies, a verified family origin-to-product-center relationship, installed orientation, faucet/use zone, door leaf/swing, hall approach, or a plumbing route."
    },
    evaluated = new { actual_room_fit = false, fixture_selection = false, door_and_approach = false, water_waste_vent_service = false, project_code_applicability = false, room_assignment = false, selected_d_modified = false },
    check_count = checks.Count,
    passed_check_count = checks.Count
};

var options = new JsonSerializerOptions { WriteIndented = true };
Directory.CreateDirectory(outputDirectory);
File.WriteAllText(Path.Combine(outputDirectory, "m274-report.json"), JsonSerializer.Serialize(report, options) + "\n", new System.Text.UTF8Encoding(false));
File.WriteAllText(Path.Combine(outputDirectory, "m274-checks.json"), JsonSerializer.Serialize(new { schema = "forever-home.m274-checks.v1", status = "pass", check_count = checks.Count, checks }, options) + "\n", new System.Text.UTF8Encoding(false));
Console.WriteLine($"PASS: M274 {checks.Count}/{checks.Count}; two measured-bound orientations fit gross west A; no assignment or installed fit established.");
return 0;
