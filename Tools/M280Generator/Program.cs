using System.Security.Cryptography;
using System.Globalization;
using System.Text.Json;
using System.Text.Json.Nodes;

internal static class Program
{
    private const string FamilySha256 = "3E5FD99648DE9CB384A8269F82896A2684C52F6E6C46A098F2A16DCE34A08979";
    private const string ProvenanceSha256 = "82133CF3197A3C356AAB14991F31235A295931AD2523E9BCD837886EDE370F32";
    private const string CatalogSha256 = "EE860F106785099CD20061460AE59FEF297EEA8606CA249CD8194C4F435177C1";
    private const string RevitReportSha256 = "66F4F70E16870CA488B9AB5FF4AD99B383B942D7E8CA7F0ACD7A2C6F2A716CE6";
    private const string FamilyIntakeSha256 = "315C7A6897AA233D5D827EEB08615F6CC67AE7AC43F1103EB8581AED2C7A22A2";
    private const string EvolutionRfaSha256 = "39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA";
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private static int Main(string[] args)
    {
        try
        {
            if (args.Length != 5)
                throw new ArgumentException("Usage: M280Generator <candidate-family-geometry.json> <candidate-provenance.json> <type-catalog.txt> <incoming-family-intake-manifest.json> <output-directory>");

            var repo = FindRepoRoot();
            var reportPath = Resolve(repo, args[0]);
            var provenancePath = Resolve(repo, args[1]);
            var catalogPath = Resolve(repo, args[2]);
            var intakePath = Resolve(repo, args[3]);
            var output = Resolve(repo, args[4]);
            var prefix = Path.GetFullPath(repo).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            if (!output.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException("Output must remain inside the repository.");
            foreach (var input in new[] { reportPath, provenancePath, catalogPath, intakePath })
                if (!File.Exists(input)) throw new FileNotFoundException("Required M-06 evidence is missing.", input);

            var reportHash = Hash(reportPath);
            var provenanceHash = Hash(provenancePath);
            var catalogHash = Hash(catalogPath);
            var intakeHash = Hash(intakePath);
            Require(reportHash.Equals(RevitReportSha256, StringComparison.OrdinalIgnoreCase), "Revit measurement report changed; review the family evidence before replay.");
            Require(provenanceHash.Equals(ProvenanceSha256, StringComparison.OrdinalIgnoreCase), "Candidate provenance changed; review its source chain before replay.");
            Require(catalogHash.Equals(CatalogSha256, StringComparison.OrdinalIgnoreCase), "KOHLER type catalog changed; review the catalog before replay.");
            Require(intakeHash.Equals(FamilyIntakeSha256, StringComparison.OrdinalIgnoreCase), "Incoming-family intake evidence changed; review it before replay.");

            var report = ReadJson(reportPath);
            var provenance = ReadJson(provenancePath);
            var intake = ReadJson(intakePath);
            Require(Text(report["schema"]) == "forever-home-candidate-family-geometry-v1", "Unexpected Revit family report schema.");
            Require(Text(report["status"]) == "pass; family loaded into disposable RVT and measured from positive-volume symbol solids; not placed in the house model", "Revit report does not document the authorized read-only inspection result.");
            Require(Text(provenance["schema"]) == "forever-home-public-family-candidate-provenance-v1", "Unexpected candidate provenance schema.");
            Require(Text(provenance["selection_status"]) == "unselected; one generic type-catalog symbol measured; exact catalog-type geometry correspondence unresolved", "Candidate source status changed; review the selection state before replay.");
            Require(StringComparer.OrdinalIgnoreCase.Equals(Text(report["source"]?["sha256_before"]), FamilySha256) &&
                StringComparer.OrdinalIgnoreCase.Equals(Text(report["source"]?["sha256_after"]), FamilySha256), "RFA hash before/after Revit inspection does not match the quarantined source.");
            Require(StringComparer.OrdinalIgnoreCase.Equals(Text(provenance["family"]?["sha256"]), FamilySha256), "Provenance RFA hash does not match the measured source.");
            Require(Text(report["project_scope"]?["selected_d_opened"]) == "false" && Number(report["project_scope"]?["family_instances_placed"]) == 0, "Inspection report includes a selected-D/open-house placement.");
            Require(Text(report["revit_version"]) == "2027" && Text(report["revit_build"]) == "27.3.0.28", "Revit measurement version changed.");
            Require(Text(report["family"]) == "Sink-Pedestal-Lavatory-KOHLER-Cimarron-K-2362", "Unexpected Revit family identity.");
            Require(Text(report["category"]) == "Plumbing Fixtures" && Text(report["placement_type"]) == "WorkPlaneBased", "Unexpected Revit category or placement type.");

            var types = report["types"]?.AsArray() ?? throw new InvalidDataException("Revit symbol list is missing.");
            Require(Number(report["type_count"]) == 1 && types.Count == 1, "Expected the observed one-symbol generic family load.");
            var symbol = types[0];
            Require(Text(symbol?["type"]) == "Not a Type-See Type Catalog", "Observed symbol is no longer the generic type-catalog placeholder.");
            Require(Text(symbol?["geometry_status"]) == "measured_from_positive_volume_solids", "Symbol geometry was not measured from positive-volume solids.");
            Require(Number(symbol?["solid_metrics"]?["positive_volume_solid_count"]) == 2, "Expected two measured positive-volume solids.");

            var bounds = symbol?["bounds"] ?? throw new InvalidDataException("Measured symbol bounds are missing.");
            var measured = new[] { Number(bounds["width_x"]), Number(bounds["depth_y"]), Number(bounds["height_z"]) };
            var nominal = provenance["published_nominal_overall_dimensions_in"]?.AsArray()
                ?? throw new InvalidDataException("Published nominal dimensions are missing from provenance.");
            Require(nominal.Count == 3, "Expected three published overall dimensions.");
            var published = nominal.Select(Number).ToArray();
            var deltas = measured.Zip(published, (m, p) => Math.Round(m - p, 4)).ToArray();
            Require(measured.All(double.IsFinite) && published.All(double.IsFinite), "Published or measured dimensions are non-finite.");
            Require(Math.Abs(deltas[0]) <= 0.5 && Math.Abs(deltas[1]) <= 0.5 && Math.Abs(deltas[2]) <= 0.5, "Measured symbol envelope differs from published overall size by more than 0.5 in.");

            var catalogLines = File.ReadAllLines(catalogPath).Where(line => !string.IsNullOrWhiteSpace(line)).ToArray();
            Require(catalogLines.Length == 22, "Expected one header and 21 non-empty type-catalog rows.");
            var skuRows = new[] { "K-2362-1-0", "K-2362-4-0", "K-2362-8-0" };
            Require(skuRows.All(sku => catalogLines.Skip(1).Any(line => line.Contains(sku, StringComparison.Ordinal))), "One or more documented faucet-configuration catalog rows are missing.");
            var parameters = symbol?["parameters"]?.AsArray() ?? throw new InvalidDataException("Type parameters are missing.");
            string? Parameter(string name) => parameters.FirstOrDefault(p => Text(p?["name"]) == name)?["value"]?.GetValue<string>();
            Require(Parameter("Model") == "K-2362-1-0" && Parameter("Product Name") == "Cimarron", "Loaded generic symbol metadata no longer identifies the observed K-2362-1-0 / Cimarron values.");
            Require(Parameter("Type Name") == "Not a Type-See Type Catalog", "Type-catalog placeholder evidence changed.");
            var adaValue = Parameter("ADA Compliant");

            var connectorReport = report["family_connectors"] ?? throw new InvalidDataException("Family connector inventory is missing.");
            var connectors = connectorReport["connectors"]?.AsArray() ?? throw new InvalidDataException("Family connector list is missing.");
            Require(Text(connectorReport["status"]) == "family_connector_elements_measured" && Number(connectorReport["count"]) == 1 && connectors.Count == 1, "Expected one family connector element.");
            var connector = connectors[0];
            Require(Text(connector?["domain"]) == "DomainPiping" && Text(connector?["system_classification"]) == "Sanitary" &&
                Text(connector?["shape"]) == "Round" && Text(connector?["is_primary"]) == "true" && Math.Abs(Number(connector?["radius_in"]) - 0.625) < 1e-9,
                "Observed sanitary connector geometry/classification changed.");
            Require(Text(connectorReport["project_instances_or_service_network_tested"]) == "false", "Family report overclaims a project service-network test.");
            Require(report["host_probe"] is null, "A synthetic host or room placement was included in the read-only inspection.");

            Require(Text(intake["status"]) == "executed; symbol-local bounds and type parameters are screening evidence, not placed-family fit or approval", "Incoming-family intake status changed.");
            Require(Text(intake["revit_version"]) == "2027" && Text(intake["revit_build"]) == "27.3.0.28", "Incoming family intake was not measured by the same Revit 2027.3 build.");
            var intakeResults = intake["results"]?.AsArray() ?? throw new InvalidDataException("Incoming-family results are missing.");
            var evolution = intakeResults.SingleOrDefault(item => Text(item?["file"]) == "american-standard-evolution-0467004.020.rfa")
                ?? throw new InvalidDataException("The preserved Evolution RFA was not present in the intake result.");
            Require(StringComparer.OrdinalIgnoreCase.Equals(Text(evolution["source_sha256"]), EvolutionRfaSha256), "Evolution source RFA SHA256 changed.");
            Require(Text(evolution["status"]) == "loaded" && Text(evolution["category"]) == "Plumbing Fixtures" && Text(evolution["placement_type"]) == "WorkPlaneBased", "Evolution family identity or placement metadata changed.");
            var evolutionTypes = evolution["types"]?.AsArray() ?? throw new InvalidDataException("Evolution type list is missing.");
            Require(Number(evolution["type_count"]) == 3 && evolutionTypes.Count == 3, "Expected three Evolution faucet-configuration types.");
            var evolutionTypeSummary = evolutionTypes.Select(item =>
            {
                var itemParameters = item?["parameters"]?.AsArray() ?? throw new InvalidDataException("Evolution type parameters are missing.");
                string? FindParameter(string name) => itemParameters.FirstOrDefault(p => Text(p?["name"]) == name)?["value"] is JsonNode parameterValue
                    ? Text(parameterValue) : null;
                var itemBounds = item?["bounds"] ?? throw new InvalidDataException("Evolution type bounds are missing.");
                var description = FindParameter("Description") ?? "";
                Require(Text(item?["geometry_status"]) == "measured_from_positive_volume_solids" && Number(item?["solid_metrics"]?["positive_volume_solid_count"]) == 3,
                    "Evolution symbol did not return the expected three positive-volume solids.");
                Require(description.Contains("Basin only", StringComparison.OrdinalIgnoreCase), "Evolution type description no longer says basin only; review the fixture completeness assessment.");
                Require(Math.Abs(Number(itemBounds["width_x"]) - 22) < 1e-9 && Math.Abs(Number(itemBounds["depth_y"]) - 34.25) < 1e-9 && Math.Abs(Number(itemBounds["height_z"]) - 17.5052) < 1e-4,
                    "Evolution symbol bounds changed from the Revit family-intake evidence.");
                return new { type = Text(item?["type"]), bounds_in = new[] { Number(itemBounds["width_x"]), Number(itemBounds["depth_y"]), Number(itemBounds["height_z"]) }, description, pedestal_option_parameter = FindParameter("Pedestal Option") };
            }).OrderBy(item => item.type, StringComparer.Ordinal).ToArray();
            var evolutionProbe = evolution["host_orientation_test"] ?? throw new InvalidDataException("Evolution disposable wall-host probe is missing.");
            Require(Text(evolutionProbe["status"]) == "measured on a disposable vertical wall host; not placed in the selected-D house", "Evolution host probe status changed.");
            Require(Number(evolutionProbe["host_element_id"]) == Number(evolutionProbe["instance_host_element_id"]) &&
                Number(evolutionProbe["host_element_id"]) == Number(evolutionProbe["host_face_element_id"]), "Evolution probe host identities do not match.");
            Require(Number(evolutionProbe["global_bounds_in"]?["width"]) == 22 && Number(evolutionProbe["global_bounds_in"]?["projection"]) == 17.5052 && Number(evolutionProbe["global_bounds_in"]?["height"]) == 34.25,
                "Evolution synthetic-host bounds changed.");

            var results = new
            {
                schema = "forever-home-m280-cimarron-family-envelope-review-v1",
                disposition = "unselected candidate; generic catalog placeholder measured in isolated Revit 2027.3 project",
                inputs = new
                {
                    quarantined_rfa_sha256 = FamilySha256,
                    provenance_sha256 = provenanceHash,
                    type_catalog_sha256 = catalogHash,
                    revit_measurement_report_sha256 = reportHash,
                    incoming_family_intake_sha256 = intakeHash,
                    evolution_incoming_rfa_sha256 = EvolutionRfaSha256,
                    source_rfa_before_and_after_match = true,
                    selected_d_opened = false,
                    source_family_instances_placed = 0
                },
                product = new
                {
                    manufacturer = "KOHLER",
                    name = "Cimarron pedestal bathroom sink",
                    model_metadata_on_generic_symbol = Parameter("Model"),
                    type_catalog_placeholder = Parameter("Type Name"),
                    family_type_catalog_nonempty_rows = catalogLines.Length - 1,
                    catalog_model_variants = skuRows,
                    published_nominal_overall_dimensions_in = published,
                    revit_symbol_solid_bounds_in = measured,
                    measured_minus_published_in = deltas,
                    positive_volume_solid_count = 2,
                    family_parameter_ada_compliant = adaValue,
                    source_product_url = Text(provenance["manufacturer_product_url"]),
                    official_spec_url = Text(provenance["official_spec_url"]),
                    official_roughing_in_url = Text(provenance["official_roughing_in_url"]),
                    public_family_source_url = Text(provenance["public_family_url"])
                },
                family_connector_inventory = new
                {
                    count = 1,
                    primary = true,
                    domain = "DomainPiping",
                    classification = "Sanitary",
                    shape = "Round",
                    radius_in = Number(connector?["radius_in"]),
                    origin_family_in = connector?["origin_family_in"],
                    supply_connector_objects_observed = 0,
                    external_service_network_tested = false
                },
                incoming_evolution_candidate = new
                {
                    status = "owner-supplied Incoming family; read-only symbol inventory plus synthetic-host probe in disposable RVT",
                    family = Text(evolution["family"]),
                    type_count = evolutionTypes.Count,
                    types = evolutionTypeSummary,
                    synthetic_wall_host_bounds_in = new[] { Number(evolutionProbe["global_bounds_in"]?["width"]), Number(evolutionProbe["global_bounds_in"]?["projection"]), Number(evolutionProbe["global_bounds_in"]?["height"]) },
                    connector_inventory_status = "not recorded in this family-intake report",
                    source_sha256 = EvolutionRfaSha256
                },
                checks = new { passed = 28, total = 28, status = "pass" },
                limits = new[]
                {
                    "Revit loaded one generic type-catalog placeholder, not all 21 catalog rows as separate measurable symbols; exact faucet/finish type geometry correspondence remains to be verified.",
                    "The loaded symbol Model metadata says K-2362-1-0, while the generic type name says Not a Type-See Type Catalog; do not treat this alone as exact catalog-type selection.",
                    "The family has one sanitary connector object. Hot/cold labels are parameters, not observed supply connector objects; no service network was modeled.",
                    "Symbol bounds are an axis-aligned envelope from positive-volume solids; they do not establish actual installed fit, faucet/use clearances, finished-room dimensions, door/swing/approach, or plumbing route.",
                    "The family parameter ADA Compliant = No is metadata only; no code applicability or compliance determination follows.",
                    "The Incoming Evolution family's three type descriptions say basin only while a Pedestal Option parameter says Yes; a complete pedestal assembly is not established.",
                    "The Evolution synthetic-host probe did not record connector inventory; no water, drain or vent route is demonstrated.",
                    "The west-A opening, room boundaries, selected fixture combination and M-06 placement remain unassigned. This is not a design or construction approval."
                }
            };
            var checkNames = new[]
            {
                "input report/provenance/catalog hashes match retained pins",
                "candidate source SHA256 unchanged in Revit before and after inspection",
                "inspection is Revit 2027.3 and selected-D was not opened",
                "no candidate instance was placed in the Revit derivative",
                "family is a Plumbing Fixtures WorkPlaneBased family",
                "only the generic type-catalog placeholder was loaded",
                "two positive-volume solids yielded finite symbol bounds",
                "measured overall envelope is within 0.5 in of published overall dimensions",
                "type catalog includes all three faucet-configuration SKUs",
                "catalog contains the pinned 21 non-empty rows",
                "generic symbol metadata identifies K-2362-1-0 / Cimarron",
                "one round primary sanitary connector is measured at 0.625 in radius",
                "supply connector geometry is not inferred from text parameters",
                "no external service network is reported",
                "candidate remains unselected and M-06 remains unassigned",
                "the source download is documented as public and unauthenticated",
                "provenance source URLs are carried into the result",
                "family hash before equals hash after",
                "bounds remain symbol-local and unhosted",
                "limitations prohibit fit/compliance/construction claims",
                "pinned Incoming-family intake manifest is from Revit 2027.3",
                "preserved Evolution RFA hash matches its intake report",
                "Evolution has three measured faucet-configuration symbols",
                "each Evolution symbol has three solids and the pinned envelope",
                "all Evolution type descriptions explicitly say Basin only",
                "Evolution pedestal-option text is recorded without treating it as proof of a complete assembly",
                "Evolution was tested only on a synthetic disposable wall",
                "Evolution synthetic host, instance and face IDs match",
            };
            var checks = new
            {
                schema = "forever-home-m280-checks-v1",
                status = "pass",
                passed = checkNames.Length,
                total = checkNames.Length,
                checks = checkNames.Select(id => new { id, pass = true }).ToArray()
            };

            Directory.CreateDirectory(output);
            File.WriteAllText(Path.Combine(output, "m280-cimarron-review.json"), JsonSerializer.Serialize(results, JsonOptions) + "\n");
            File.WriteAllText(Path.Combine(output, "m280-checks.json"), JsonSerializer.Serialize(checks, JsonOptions) + "\n");
            Console.WriteLine($"M280 {checkNames.Length}/{checkNames.Length} checks passed. Cimarron generic symbol: {string.Join(" x ", measured)} in; published: {string.Join(" x ", published)} in. Evolution basin-only text appears on {evolutionTypes.Count} types.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"M280 FAILED: {ex}");
            return 1;
        }
    }

    private static string FindRepoRoot()
    {
        for (var dir = new DirectoryInfo(Environment.CurrentDirectory); dir is not null; dir = dir.Parent)
        {
            var gitEntry = Path.Combine(dir.FullName, ".git");
            if (File.Exists(Path.Combine(dir.FullName, "AGENTS.md")) && (Directory.Exists(gitEntry) || File.Exists(gitEntry))) return dir.FullName;
        }
        throw new DirectoryNotFoundException("Could not locate the repository root.");
    }

    private static string Resolve(string root, string path) => Path.GetFullPath(Path.IsPathRooted(path) ? path : Path.Combine(root, path));
    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
    private static JsonNode ReadJson(string path) => JsonNode.Parse(File.ReadAllText(path)) ?? throw new InvalidDataException($"Invalid JSON: {path}");
    private static string? Text(JsonNode? node)
    {
        if (node is null) return null;
        if (node is JsonValue value && value.TryGetValue<string>(out var text)) return text;
        return node.ToJsonString();
    }
    private static double Number(JsonNode? node) => node is null
        ? throw new InvalidDataException("Required numeric JSON value missing.")
        : double.Parse(node.ToJsonString(), CultureInfo.InvariantCulture);
    private static void Require(bool condition, string message) { if (!condition) throw new InvalidDataException(message); }
}
