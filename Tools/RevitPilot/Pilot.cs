using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Architecture;
using Autodesk.Revit.DB.Structure;
using Autodesk.Revit.UI;
using System.IO;
using System.Globalization;
using System.Reflection;
using System.Text.Json;

namespace ForeverHome.Pilot;

internal sealed record SavedModelFingerprint(string algorithm, string sha256, string file_name, long bytes);

internal static class SavedModelIdentity
{
    internal static SavedModelFingerprint Capture(Document doc)
    {
        if (doc.IsModified)
            throw new InvalidOperationException("The active Revit document has unsaved changes; save it before collecting review evidence.");
        string path = doc.PathName;
        if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
            throw new InvalidOperationException("The active Revit document has no accessible saved RVT file; save it before collecting review evidence.");
        var info = new FileInfo(path);
        long length = info.Length;
        DateTime writeTime = info.LastWriteTimeUtc;
        string digest;
        using (var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete))
            digest = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(stream)).ToLowerInvariant();
        info.Refresh();
        if (info.Length != length || info.LastWriteTimeUtc != writeTime)
            throw new IOException("The saved RVT changed while its content fingerprint was being calculated.");
        return new SavedModelFingerprint("sha256-of-saved-rvt-bytes-v1", digest, Path.GetFileName(path), length);
    }

    internal static void AssertSame(Document doc, SavedModelFingerprint expected)
    {
        var actual = Capture(doc);
        if (actual != expected)
            throw new InvalidOperationException("The active saved RVT changed while review evidence was being collected.");
    }
}

public class App : IExternalApplication
{
    public Result OnStartup(UIControlledApplication app)
    {
        var panel = app.CreateRibbonPanel("Forever Home Pilot");
        panel.AddItem(new PushButtonData("FHCompatibilityPilot", "Run compatibility\npilot",
            Assembly.GetExecutingAssembly().Location, typeof(Command).FullName!));
        panel.AddItem(new PushButtonData("FHCompactCoreStudy", "Build compact core\nstudy",
            Assembly.GetExecutingAssembly().Location, typeof(CompactCoreCommand).FullName!));
        panel.AddItem(new PushButtonData("FHSelectedDStudy", "Build selected D\nspace study",
            Assembly.GetExecutingAssembly().Location, typeof(SelectedDCommand).FullName!));
        panel.AddItem(new PushButtonData("FHUpperSuiteTest", "Build upper-suite\ntest study",
            Assembly.GetExecutingAssembly().Location, typeof(UpperSuiteComparisonCommand).FullName!));
        panel.AddItem(new PushButtonData("FHGableMassing", "Build M83 gable\nmassing options",
            Assembly.GetExecutingAssembly().Location, typeof(GableMassingCommand).FullName!));
        panel.AddItem(new PushButtonData("FHFamilyIntake", "Run family intake\ntest",
            Assembly.GetExecutingAssembly().Location, typeof(FamilyIntakeCommand).FullName!));
        panel.AddItem(new PushButtonData("FHApiAudit", "Audit active\ndocument",
            Assembly.GetExecutingAssembly().Location, typeof(ApiAuditCommand).FullName!));
        panel.AddItem(new PushButtonData("FHGeometryQa", "Run geometry\nQA",
            Assembly.GetExecutingAssembly().Location, typeof(GeometryQaCommand).FullName!));
        panel.AddItem(new PushButtonData("FHManifestExports", "Run manifest\nexports",
            Assembly.GetExecutingAssembly().Location, typeof(ManifestExportCommand).FullName!));
        panel.AddItem(new PushButtonData("FHIslandCountertopTest", "Build M-02\ncountertop test",
            Assembly.GetExecutingAssembly().Location, typeof(IslandCountertopTestCommand).FullName!));
        return Result.Succeeded;
    }
    public Result OnShutdown(UIControlledApplication app) => Result.Succeeded;
}

[Transaction(TransactionMode.Manual)]
public class IslandCountertopTestCommand : IExternalCommand
{
    const string ExpectedTitle = "FH_Selected_D_Furnishing_Study_7216_Fit_Test_3";
    const string FamilyName = "island_cabinet_Generic_7216";
    const string Marker = "FH-M02-COUNTERTOP-TEST-7216";
    const double CounterThicknessInches = 1.25; // Architecture/Kitchen_Dining_Porch_Specs.md §3.2
    const double BaseCabinetHeightInches = 34.5; // same source; independently observed in candidate IFC
    const double ToleranceFt = 0.01; // geometry serialization tolerance only

    static string Text(JsonElement value, string key) => value.GetProperty(key).GetString()!;

    static double[] Numbers(JsonElement value, string key) =>
        value.GetProperty(key).EnumerateArray().Select(item => item.GetDouble()).ToArray();

    static void RequireNear(double actual, double expected, string label)
    {
        if (!double.IsFinite(actual) || Math.Abs(actual - expected) > ToleranceFt)
            throw new InvalidOperationException($"{label}: expected {expected:0.######} ft, found {actual:0.######} ft.");
    }

    static (XYZ Min, XYZ Max) PhysicalSolidBounds(FamilyInstance instance)
    {
        double minX = double.PositiveInfinity, minY = double.PositiveInfinity, minZ = double.PositiveInfinity;
        double maxX = double.NegativeInfinity, maxY = double.NegativeInfinity, maxZ = double.NegativeInfinity;
        int vertexCount = 0;
        var options = new Options { DetailLevel = ViewDetailLevel.Fine, IncludeNonVisibleObjects = false };

        void Include(XYZ point)
        {
            if (!double.IsFinite(point.X) || !double.IsFinite(point.Y) || !double.IsFinite(point.Z))
                return; // Revit may emit a non-finite tessellation vertex for a degenerate face.
            minX = Math.Min(minX, point.X); minY = Math.Min(minY, point.Y); minZ = Math.Min(minZ, point.Z);
            maxX = Math.Max(maxX, point.X); maxY = Math.Max(maxY, point.Y); maxZ = Math.Max(maxZ, point.Z);
            vertexCount++;
        }

        void Visit(GeometryElement geometry, Transform parentTransform)
        {
            foreach (GeometryObject item in geometry)
            {
                if (item is Solid solid && solid.Volume > 1e-9)
                {
                    foreach (Face face in solid.Faces)
                    {
                        var mesh = face.Triangulate();
                        foreach (XYZ vertex in mesh.Vertices)
                        {
                            if (!double.IsFinite(vertex.X) || !double.IsFinite(vertex.Y) || !double.IsFinite(vertex.Z))
                                continue;
                            var point = parentTransform.OfPoint(vertex);
                            Include(point);
                        }
                    }
                }
                else if (item is GeometryInstance nested)
                {
                    Visit(nested.GetSymbolGeometry(), parentTransform.Multiply(nested.Transform));
                }
            }
        }

        var rootGeometry = instance.get_Geometry(options)
            ?? throw new InvalidOperationException($"Casework module {instance.Id.Value} returned no physical geometry.");
        Visit(rootGeometry, Transform.Identity);
        if (vertexCount == 0 || !double.IsFinite(minZ) || !double.IsFinite(maxZ))
            throw new InvalidOperationException($"Casework module {instance.Id.Value} contains no measurable positive-volume solid geometry.");
        return (new XYZ(minX, minY, minZ), new XYZ(maxX, maxY, maxZ));
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        var doc = data.Application.ActiveUIDocument?.Document;
        if (doc is null)
        {
            message = "No active Revit document is available.";
            return Result.Failed;
        }

        try
        {
            if (!string.Equals(doc.Title, ExpectedTitle, StringComparison.Ordinal))
                throw new InvalidOperationException($"This test is restricted to '{ExpectedTitle}', not '{doc.Title}'. No elements were changed.");
            var before = SavedModelIdentity.Capture(doc);
            string root = File.ReadAllText(Path.Combine(
                Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string studyPath = Path.Combine(root, "Architecture", "Selected_Design_Iteration_2026-10-27", "study.json");
            using var studyDoc = JsonDocument.Parse(File.ReadAllText(studyPath).TrimStart('\uFEFF'));
            var study = studyDoc.RootElement;
            if (Text(study, "schema") != "forever-home.selected-house-schematic.v1")
                throw new InvalidDataException("Unsupported selected-D study schema.");

            var main = study.GetProperty("plans").GetProperty("main").EnumerateArray()
                .Single(block => Text(block, "id") == "M-02");
            double[] frame = Numbers(study.GetProperty("plan_frame_offsets_ft"), "main");
            double[] localOrigin = Numbers(study.GetProperty("selection").GetProperty("kitchen"), "island_origin_local_ft");
            double[] island = Numbers(study.GetProperty("selection").GetProperty("kitchen"), "island_ft");
            if (frame.Length != 2 || localOrigin.Length != 2 || island.Length != 2
                || Math.Abs(island[0] - 8) > 1e-8 || Math.Abs(island[1] - 4) > 1e-8)
                throw new InvalidDataException("The selected-D source does not describe the expected 8 x 4 ft island frame.");

            double x0 = main.GetProperty("x").GetDouble() + frame[0] + localOrigin[0];
            double y0 = main.GetProperty("y").GetDouble() + frame[1] + localOrigin[1];
            double x1 = x0 + island[0], y1 = y0 + island[1];
            var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>()
                .Single(item => item.Name == "D Main FF");
            var modules = new FilteredElementCollector(doc).OfClass(typeof(FamilyInstance))
                .WhereElementIsNotElementType().Cast<FamilyInstance>()
                .Where(item => string.Equals(item.Symbol?.FamilyName, FamilyName, StringComparison.OrdinalIgnoreCase))
                .ToList();
            if (modules.Count != 4)
                throw new InvalidOperationException($"Expected four '{FamilyName}' modules; found {modules.Count}. No elements were changed.");

            double moduleX0 = double.PositiveInfinity, moduleY0 = double.PositiveInfinity;
            double moduleX1 = double.NegativeInfinity, moduleY1 = double.NegativeInfinity;
            double moduleTop = double.NegativeInfinity;
            var expectedCells = (from cellX in new[] { (x0, (x0 + x1) / 2), ((x0 + x1) / 2, x1) }
                                 from cellY in new[] { (y0, (y0 + y1) / 2), ((y0 + y1) / 2, y1) }
                                 select (xMin: cellX.Item1, xMax: cellX.Item2, yMin: cellY.Item1, yMax: cellY.Item2)).ToList();
            foreach (var module in modules)
            {
                var bounds = PhysicalSolidBounds(module);
                int cell = expectedCells.FindIndex(expected =>
                    Math.Abs(bounds.Min.X - expected.xMin) <= ToleranceFt
                    && Math.Abs(bounds.Max.X - expected.xMax) <= ToleranceFt
                    && Math.Abs(bounds.Min.Y - expected.yMin) <= ToleranceFt
                    && Math.Abs(bounds.Max.Y - expected.yMax) <= ToleranceFt);
                if (cell < 0)
                    throw new InvalidOperationException("Each casework module must occupy one distinct source-derived 4 x 2 ft island quadrant.");
                expectedCells.RemoveAt(cell);
                RequireNear(bounds.Max.Z, level.Elevation + BaseCabinetHeightInches / 12.0, "Casework physical-solid top");
                moduleX0 = Math.Min(moduleX0, bounds.Min.X); moduleY0 = Math.Min(moduleY0, bounds.Min.Y);
                moduleX1 = Math.Max(moduleX1, bounds.Max.X); moduleY1 = Math.Max(moduleY1, bounds.Max.Y);
                moduleTop = Math.Max(moduleTop, bounds.Max.Z);
                RequireNear(bounds.Min.Z, level.Elevation, "Casework physical-solid bottom elevation");
            }
            if (expectedCells.Count != 0)
                throw new InvalidOperationException("One or more source-derived island quadrants are missing.");
            RequireNear(moduleX0, x0, "Casework island X minimum");
            RequireNear(moduleX1, x1, "Casework island X maximum");
            RequireNear(moduleY0, y0, "Casework island Y minimum");
            RequireNear(moduleY1, y1, "Casework island Y maximum");
            RequireNear(moduleTop, level.Elevation + BaseCabinetHeightInches / 12.0, "Observed casework top");

            bool alreadyExists = new FilteredElementCollector(doc).OfClass(typeof(DirectShape))
                .WhereElementIsNotElementType().Cast<DirectShape>()
                .Any(shape => string.Equals(shape.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString(), Marker, StringComparison.Ordinal));
            if (alreadyExists)
                throw new InvalidOperationException("The tagged M-02 countertop test already exists. No duplicate was created.");

            var corners = new[]
            {
                new XYZ(x0, y0, moduleTop), new XYZ(x1, y0, moduleTop),
                new XYZ(x1, y1, moduleTop), new XYZ(x0, y1, moduleTop)
            };
            var profile = CurveLoop.Create(Enumerable.Range(0, corners.Length)
                .Select(index => (Curve)Line.CreateBound(corners[index], corners[(index + 1) % corners.Length])).ToList());
            double thicknessFt = CounterThicknessInches / 12.0;
            var solid = GeometryCreationUtilities.CreateExtrusionGeometry(
                new List<CurveLoop> { profile }, XYZ.BasisZ, thicknessFt);

            using (var transaction = new Transaction(doc, "M-02 1.25 in countertop massing test"))
            {
                transaction.Start();
                var top = DirectShape.CreateElement(doc, new ElementId(BuiltInCategory.OST_GenericModel));
                top.ApplicationId = "ForeverHome.Pilot";
                top.ApplicationDataId = Marker;
                top.Name = "M-02 countertop thickness test - finish unassigned";
                top.SetShape(new List<GeometryObject> { solid });
                var comments = top.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
                if (comments is not null && !comments.IsReadOnly) comments.Set(Marker);
                doc.Regenerate();
                transaction.Commit();
            }

            doc.Save();
            var after = SavedModelIdentity.Capture(doc);
            string output = Path.Combine(root, ".local", "revit-pilot", "kitchen-island-countertop-tests",
                DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            var report = new
            {
                schema = "forever-home.m02-countertop-test.v1",
                status = "saved isolated generic countertop massing placeholder; finish split and fabrication detail unassigned",
                document_title = doc.Title,
                model_fingerprint_before = before,
                model_fingerprint_after = after,
                source_study_sha256 = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(studyPath))).ToLowerInvariant(),
                category = "Generic Models",
                marker = Marker,
                base_cabinet_height_inches = BaseCabinetHeightInches,
                countertop_thickness_inches = CounterThicknessInches,
                total_nominal_height_inches = BaseCabinetHeightInches + CounterThicknessInches,
                nominal_standard_height_inches = 36.0,
                accepted_nominal_variance_inches = 0.25,
                bounds_ft = new { x_min = x0, x_max = x1, y_min = y0, y_max = y1, z_min = moduleTop, z_max = moduleTop + thicknessFt },
                limitations = new[] { "No quartz/butcher-block material split, seam, support, overhang detail, electrical work or finish is represented." }
            };
            File.WriteAllText(Path.Combine(output, "countertop-test.json"), JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home M-02 test", $"Saved a generic, unassigned-finish countertop massing placeholder in the isolated study.\n\nResulting height: {BaseCabinetHeightInches + CounterThicknessInches:0.##} in (nominally 36 in).\nReport: {output}");
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            return Result.Failed;
        }
    }
}

public class CompactApp : IExternalApplication
{
    public Result OnStartup(UIControlledApplication app)
    {
        var panel = app.CreateRibbonPanel("Forever Home Compact Study");
        panel.AddItem(new PushButtonData("FHCompactCoreStudyStandalone", "Build compact core\nstudy",
            Assembly.GetExecutingAssembly().Location, typeof(CompactCoreCommand).FullName!));
        panel.AddItem(new PushButtonData("FHFamilyIntakeStandalone", "Run family intake\ntest",
            Assembly.GetExecutingAssembly().Location, typeof(FamilyIntakeCommand).FullName!));
        panel.AddItem(new PushButtonData("FHApiAuditStandalone", "Audit active\ndocument",
            Assembly.GetExecutingAssembly().Location, typeof(ApiAuditCommand).FullName!));
        panel.AddItem(new PushButtonData("FHGeometryQaStandalone", "Run geometry\nQA",
            Assembly.GetExecutingAssembly().Location, typeof(GeometryQaCommand).FullName!));
        panel.AddItem(new PushButtonData("FHManifestExportsStandalone", "Run manifest\nexports",
            Assembly.GetExecutingAssembly().Location, typeof(ManifestExportCommand).FullName!));
        return Result.Succeeded;
    }
    public Result OnShutdown(UIControlledApplication app) => Result.Succeeded;
}

[Transaction(TransactionMode.ReadOnly)]
public class ApiAuditCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        var doc = data.Application.ActiveUIDocument?.Document;
        if (doc is null)
        {
            message = "No active Revit document is available.";
            return Result.Failed;
        }

        try
        {
            var modelFingerprint = SavedModelIdentity.Capture(doc);
            string root = File.ReadAllText(Path.Combine(
                Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string output = Path.Combine(root, ".local", "revit-pilot", "audits",
                DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);

            var allElements = new FilteredElementCollector(doc)
                .WhereElementIsNotElementType()
                .ToElements();
            var categoryCounts = allElements
                .Where(e => e.Category is not null)
                .GroupBy(e => e.Category!.Name, StringComparer.OrdinalIgnoreCase)
                .OrderByDescending(g => g.Count())
                .Select(g => new { category = g.Key, count = g.Count() })
                .ToList();

            var levels = new FilteredElementCollector(doc).OfClass(typeof(Level))
                .Cast<Level>()
                .OrderBy(l => l.Elevation)
                .Select(l => new { id = l.Id.Value, name = l.Name, elevation_ft = l.Elevation })
                .ToList();
            var rooms = new FilteredElementCollector(doc)
                .OfClass(typeof(SpatialElement))
                .WhereElementIsNotElementType()
                .OfType<Autodesk.Revit.DB.Architecture.Room>()
                .Where(r => r.Area > 0)
                .OrderBy(r => r.Number, StringComparer.OrdinalIgnoreCase)
                .Select(r => new
                {
                    id = r.Id.Value,
                    unique_id = r.UniqueId,
                    number = r.Number,
                    name = r.Name,
                    area_sf = r.Area,
                    level_id = r.LevelId.Value,
                    level = r.Level?.Name
                })
                .ToList();
            var walls = new FilteredElementCollector(doc).OfClass(typeof(Wall))
                .Cast<Wall>()
                .Select(w => new
                {
                    id = w.Id.Value,
                    unique_id = w.UniqueId,
                    name = w.Name,
                    level = w.LevelId.Value,
                    length_ft = w.Location is LocationCurve curve ? curve.Curve.Length : 0,
                    marker = w.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString()
                })
                .ToList();
            var openings = new FilteredElementCollector(doc)
                .OfClass(typeof(FamilyInstance))
                .Cast<FamilyInstance>()
                .Where(i => i.Category?.Id.Value == (long)BuiltInCategory.OST_Doors ||
                            i.Category?.Id.Value == (long)BuiltInCategory.OST_Windows)
                .Select(i => new
                {
                    id = i.Id.Value,
                    unique_id = i.UniqueId,
                    category = i.Category?.Name,
                    family = i.Symbol?.Family?.Name,
                    type = i.Symbol?.Name,
                    host_id = i.Host?.Id.Value,
                    marker = i.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString()
                })
                .ToList();
            var warnings = doc.GetWarnings()
                .Select(w => new
                {
                    severity = w.GetSeverity().ToString(),
                    description = w.GetDescriptionText(),
                    failing_element_ids = w.GetFailingElements().Select(id => id.Value).ToList()
                })
                .ToList();

            SavedModelIdentity.AssertSame(doc, modelFingerprint);

            static string Csv(string? value) => "\"" + (value ?? "").Replace("\"", "\"\"") + "\"";
            File.WriteAllLines(Path.Combine(output, "rooms.csv"),
                new[] { "id,unique_id,number,name,area_sf,level_id,level" }
                    .Concat(rooms.Select(r => string.Join(",", Csv(r.id.ToString()), Csv(r.unique_id),
                        Csv(r.number), Csv(r.name), Csv(r.area_sf.ToString(CultureInfo.InvariantCulture)),
                        Csv(r.level_id.ToString()), Csv(r.level)))));
            File.WriteAllLines(Path.Combine(output, "openings.csv"),
                new[] { "id,unique_id,category,family,type,host_id,marker" }
                    .Concat(openings.Select(i => string.Join(",", Csv(i.id.ToString()), Csv(i.unique_id),
                        Csv(i.category), Csv(i.family), Csv(i.type), Csv(i.host_id?.ToString()), Csv(i.marker)))));

            var report = new
            {
                schema = "forever-home.revit-api-audit.v2",
                status = "executed; read-only active-document audit",
                utc = DateTime.UtcNow,
                revit_version = data.Application.Application.VersionNumber,
                revit_build = data.Application.Application.VersionBuild,
                document_title = doc.Title,
                document_path_recorded = false,
                model_fingerprint = modelFingerprint,
                document_is_workshared = doc.IsWorkshared,
                summary = new
                {
                    total_instance_elements = allElements.Count,
                    category_count = categoryCounts.Count,
                    level_count = levels.Count,
                    enclosed_room_count = rooms.Count,
                    wall_count = walls.Count,
                    opening_count = openings.Count,
                    warning_count = warnings.Count
                },
                levels,
                category_counts = categoryCounts,
                rooms,
                walls,
                openings,
                warnings,
                limitations = new[]
                {
                    "Read-only inventory; no geometry, code, accessibility, structural or engineering approval.",
                    "The saved RVT is identified by SHA256 of its exact file bytes; local path is intentionally omitted.",
                    "Room area and warning results are native Revit observations and require design-context review."
                }
            };
            File.WriteAllText(Path.Combine(output, "audit.json"),
                JsonSerializer.Serialize(report, JsonOptions));
            File.WriteAllText(Path.Combine(output, "README.txt"),
                "Read-only Revit API audit. Review audit.json, rooms.csv and openings.csv; no model edits were made.\n");
            TaskDialog.Show("Forever Home API audit", "Read-only audit written to:\n" + output);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            return Result.Failed;
        }
    }

    static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
}

[Transaction(TransactionMode.Manual)]
public class ManifestExportCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        var doc = data.Application.ActiveUIDocument?.Document;
        if (doc is null)
        {
            message = "No active Revit document is available.";
            return Result.Failed;
        }

        try
        {
            string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
            string root = File.ReadAllText(Path.Combine(assemblyDir, "workspace.txt")).Trim();
            string manifestDirectory = Path.Combine(root, "Tools", "RevitPilot");
            var matchingManifests = Directory.GetFiles(manifestDirectory, "export-manifest*.json")
                .OrderBy(path => path, StringComparer.OrdinalIgnoreCase)
                .Where(path =>
                {
                    using var candidate = JsonDocument.Parse(File.ReadAllText(path));
                    var candidateConfig = candidate.RootElement;
                    if (candidateConfig.GetProperty("schema").GetString() != "forever-home.revit-export-manifest.v1")
                        throw new InvalidDataException("Unsupported export manifest schema: " + Path.GetFileName(path));
                    string candidateTitle = candidateConfig.GetProperty("expected_document_title").GetString() ?? "";
                    return string.Equals(doc.Title, candidateTitle, StringComparison.Ordinal);
                }).ToList();
            if (matchingManifests.Count != 1)
            {
                var availableTitles = Directory.GetFiles(manifestDirectory, "export-manifest*.json")
                    .OrderBy(path => path, StringComparer.OrdinalIgnoreCase)
                    .Select(path =>
                    {
                        using var candidate = JsonDocument.Parse(File.ReadAllText(path));
                        return Path.GetFileName(path) + " => " +
                            candidate.RootElement.GetProperty("expected_document_title").GetString();
                    });
                throw new InvalidOperationException(
                    $"Expected exactly one export manifest for active document '{doc.Title}', found {matchingManifests.Count}. Available manifests: {string.Join("; ", availableTitles)}");
            }
            string manifestPath = matchingManifests[0];
            using var manifest = JsonDocument.Parse(File.ReadAllText(manifestPath));
            var config = manifest.RootElement;
            string expectedTitle = config.GetProperty("expected_document_title").GetString() ?? "";
            if (!string.Equals(doc.Title, expectedTitle, StringComparison.Ordinal))
                throw new InvalidOperationException($"Manifest expects active document '{expectedTitle}', but the active document is '{doc.Title}'. No exports were run.");
            var modelFingerprint = SavedModelIdentity.Capture(doc);

            string output = Path.Combine(root, ".local", "revit-pilot", "exports",
                DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            if (Directory.Exists(output)) throw new IOException("The timestamped export folder already exists: " + output);
            Directory.CreateDirectory(output);

            View FindView(string name, Func<View, bool> predicate)
            {
                var matches = new FilteredElementCollector(doc).OfClass(typeof(View)).Cast<View>()
                    .Where(v => !v.IsTemplate && string.Equals(v.Name, name, StringComparison.Ordinal) && predicate(v)).ToList();
                if (matches.Count != 1) throw new InvalidOperationException($"Expected one view named '{name}', found {matches.Count}.");
                return matches[0];
            }

            static string FileBase(JsonElement item, string key)
            {
                string name = item.GetProperty(key).GetString() ?? "";
                if (string.IsNullOrWhiteSpace(name) || !string.Equals(name, Path.GetFileName(name), StringComparison.Ordinal) ||
                    name.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
                    throw new InvalidDataException($"Invalid export file name '{name}'.");
                return name;
            }

            var results = new Dictionary<string, object>();
            void RunExport(string key, Func<bool> action, Func<string?, string?>? review = null)
            {
                var before = Directory.GetFiles(output).ToHashSet(StringComparer.OrdinalIgnoreCase);
                try
                {
                    bool apiResult = action();
                    var generated = Directory.GetFiles(output).Where(path => !before.Contains(path)).OrderBy(path => path).ToList();
                    var files = generated.Select(path => new
                    {
                        file = Path.GetFileName(path),
                        bytes = new FileInfo(path).Length,
                        sha256 = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(path))).ToLowerInvariant()
                    }).ToList();
                    string? reviewIssue = review?.Invoke(generated.FirstOrDefault());
                    bool success = apiResult && files.Count > 0 && files.All(f => f.bytes > 0) && reviewIssue is null;
                    results[key] = new { success, api_result = apiResult, files, error = success ? null : reviewIssue ?? "Export call returned false or produced no nonempty file." };
                }
                catch (Exception ex)
                {
                    results[key] = new { success = false, api_result = false, files = Array.Empty<object>(), error = ex.Message };
                }
            }

            var ifc = config.GetProperty("ifc");
            if (ifc.GetProperty("enabled").GetBoolean())
            {
                string name = FileBase(ifc, "file_name");
                RunExport("ifc2x3", () =>
                {
                    using var options = new IFCExportOptions
                    {
                        FileVersion = IFCVersion.IFC2x3CV2,
                        ExportBaseQuantities = ifc.GetProperty("export_base_quantities").GetBoolean()
                    };
                    options.AddOption("ExportInternalRevitPropertySets",
                        ifc.GetProperty("export_internal_property_sets").GetBoolean() ? "true" : "false");
                    var viewName = ifc.GetProperty("filter_view_name");
                    if (viewName.ValueKind == JsonValueKind.String)
                        options.FilterViewId = FindView(viewName.GetString()!, _ => true).Id;
                    using var transaction = new Transaction(doc, "Manifest IFC export");
                    transaction.Start();
                    try { return doc.Export(output, name, options); }
                    finally { transaction.RollBack(); }
                });
            }

            var dwg = config.GetProperty("dwg");
            if (dwg.GetProperty("enabled").GetBoolean())
            {
                string name = FileBase(dwg, "file_name");
                RunExport("dwg", () =>
                {
                    var ids = dwg.GetProperty("view_names").EnumerateArray()
                        .Select(v => FindView(v.GetString() ?? "", view => view is ViewPlan).Id).ToList();
                    var options = new DWGExportOptions
                    {
                        FileVersion = ACADVersion.R2010,
                        MergedViews = dwg.GetProperty("merged_views").GetBoolean()
                    };
                    return doc.Export(output, name, ids, options);
                });
            }

            var pdf = config.GetProperty("pdf");
            if (pdf.GetProperty("enabled").GetBoolean())
            {
                string name = FileBase(pdf, "file_name");
                RunExport("pdf", () =>
                {
                    var ids = pdf.GetProperty("view_names").EnumerateArray()
                        .Select(v => FindView(v.GetString() ?? "", _ => true).Id).ToList();
                    return doc.Export(output, ids, new PDFExportOptions
                    {
                        Combine = pdf.GetProperty("combine").GetBoolean(),
                        FileName = name
                    });
                });
            }

            var csv = config.GetProperty("csv");
            if (csv.GetProperty("enabled").GetBoolean())
            {
                string name = FileBase(csv, "file_name");
                RunExport("csv:" + name, () =>
                {
                    if (!string.Equals(csv.GetProperty("category").GetString(), "rooms", StringComparison.OrdinalIgnoreCase))
                        throw new InvalidDataException("CSV category must be 'rooms'.");
                    var rooms = new FilteredElementCollector(doc).OfClass(typeof(SpatialElement))
                        .WhereElementIsNotElementType().OfType<Room>().Where(room => room.Area > 0)
                        .OrderBy(room => room.Number, StringComparer.OrdinalIgnoreCase).ToList();
                    var fields = csv.GetProperty("fields").EnumerateArray().Select(field => field.GetString() ?? "").ToList();
                    var allowedFields = new HashSet<string>(new[] { "number", "name", "area_sqft", "level", "element_id", "unique_id" }, StringComparer.Ordinal);
                    if (fields.Count == 0 || fields.Any(field => !allowedFields.Contains(field)))
                        throw new InvalidDataException("CSV fields must be a nonempty subset of the supported room inventory fields.");
                    string Field(Room room, string field) => field switch
                    {
                        "number" => room.Number,
                        "name" => room.Name,
                        "area_sqft" => room.Area.ToString("0.##", CultureInfo.InvariantCulture),
                        "level" => room.Level?.Name ?? "",
                        "element_id" => room.Id.Value.ToString(CultureInfo.InvariantCulture),
                        "unique_id" => room.UniqueId,
                        _ => throw new InvalidDataException("Unsupported CSV field: " + field)
                    };
                    string csvPath = Path.Combine(output, name + ".csv");
                    static string Quote(string? value) => "\"" + (value ?? "").Replace("\"", "\"\"") + "\"";
                    File.WriteAllLines(csvPath, new[] { string.Join(",", fields.Select(Quote)) }
                        .Concat(rooms.Select(room => string.Join(",", fields.Select(field => Quote(Field(room, field)))))));
                    return File.Exists(csvPath) && new FileInfo(csvPath).Length > 0;
                }, path =>
                {
                    int dataRows = path is not null ? Math.Max(0, File.ReadLines(path).Count() - 1) : 0;
                    int minimumRows = csv.GetProperty("minimum_data_rows").GetInt32();
                    return dataRows >= minimumRows ? null :
                        $"Room inventory CSV has {dataRows} data row(s); manifest requires {minimumRows}.";
                });
            }

            bool allPassed = results.Count > 0 && results.Values.All(value =>
                (bool)value.GetType().GetProperty("success")!.GetValue(value)!);
            SavedModelIdentity.AssertSame(doc, modelFingerprint);
            var report = new
            {
                schema = "forever-home.revit-export-results.v2",
                status = allPassed ? "executed; all configured exports produced nonempty files" : "executed; one or more exports failed",
                utc = DateTime.UtcNow,
                revit_version = data.Application.Application.VersionNumber,
                revit_build = data.Application.Application.VersionBuild,
                document_title = doc.Title,
                document_path_recorded = false,
                model_fingerprint = modelFingerprint,
                manifest = Path.GetRelativePath(root, manifestPath).Replace('\\', '/'),
                exports = results,
                limitations = new[]
                {
                    "Export success confirms API output creation only; it does not establish geometry, metadata, visual fidelity, code or design correctness.",
                    "The configured room CSV is a native inventory extract, not a complete room, door, window or equipment schedule.",
                    "Revit 2018 import and independent DWG/PDF review remain separate checks."
                }
            };
            File.WriteAllText(Path.Combine(output, "export-results.json"), JsonSerializer.Serialize(report, JsonOptions));
            TaskDialog.Show("Forever Home manifest exports", (allPassed ? "Configured exports completed." : "Some configured exports failed; review export-results.json.") + "\n" + output);
            return allPassed ? Result.Succeeded : Result.Failed;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            return Result.Failed;
        }
    }

    static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
}

[Transaction(TransactionMode.ReadOnly)]
public class GeometryQaCommand : IExternalCommand
{
    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        var doc = data.Application.ActiveUIDocument?.Document;
        if (doc is null)
        {
            message = "No active Revit document is available.";
            return Result.Failed;
        }

        try
        {
            var modelFingerprint = SavedModelIdentity.Capture(doc);
            string root = File.ReadAllText(Path.Combine(
                Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string output = Path.Combine(root, ".local", "revit-pilot", "geometry-qa",
                DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);

            var rooms = new FilteredElementCollector(doc)
                .OfClass(typeof(SpatialElement)).WhereElementIsNotElementType()
                .OfType<Room>().ToList();
            var walls = new FilteredElementCollector(doc).OfClass(typeof(Wall))
                .Cast<Wall>().ToList();
            var stairs = new FilteredElementCollector(doc).OfClass(typeof(Stairs))
                .Cast<Stairs>().ToList();
            var doors = new FilteredElementCollector(doc).OfClass(typeof(FamilyInstance))
                .Cast<FamilyInstance>()
                .Where(i => i.Category?.Id.Value == (long)BuiltInCategory.OST_Doors)
                .ToList();
            var floors = new FilteredElementCollector(doc).OfClass(typeof(Floor))
                .Cast<Floor>().ToList();

            var issues = new List<object>();
            int errorCount = 0;
            int warningCount = 0;
            void Issue(string severity, string check, Element? element, string detail)
            {
                if (severity.Equals("error", StringComparison.OrdinalIgnoreCase)) errorCount++;
                if (severity.Equals("warning", StringComparison.OrdinalIgnoreCase)) warningCount++;
                issues.Add(new
                {
                    severity,
                    check,
                    element_id = element?.Id.Value,
                    marker = element?.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString(),
                    detail
                });
            }

            foreach (var room in rooms.Where(r => r.Area <= 0))
                Issue("error", "room-enclosure", room, "Room has no positive native area and may be unbounded.");

            static string WallKey(Wall wall)
            {
                var curve = (wall.Location as LocationCurve)?.Curve;
                if (curve is null) return $"{wall.LevelId.Value}|{wall.Id.Value}";
                var a = curve.GetEndPoint(0); var b = curve.GetEndPoint(1);
                var p1 = $"{Math.Round(a.X, 3):F3},{Math.Round(a.Y, 3):F3},{Math.Round(a.Z, 3):F3}";
                var p2 = $"{Math.Round(b.X, 3):F3},{Math.Round(b.Y, 3):F3},{Math.Round(b.Z, 3):F3}";
                return string.CompareOrdinal(p1, p2) < 0
                    ? $"{wall.LevelId.Value}|{p1}|{p2}"
                    : $"{wall.LevelId.Value}|{p2}|{p1}";
            }
            foreach (var group in walls.GroupBy(WallKey).Where(g => g.Count() > 1))
                foreach (var wall in group.Skip(1))
                    Issue("warning", "duplicate-wall-centerline", wall,
                        $"Wall centerline matches {group.Count() - 1} other wall(s) on the same level; review for unintended overlap.");

            foreach (var stair in stairs)
            {
                if (stair.TopElevation <= stair.BaseElevation)
                    Issue("error", "stair-elevation", stair, "Stair top elevation is not above its base elevation.");
                if (stair.ActualRisersNumber <= 0)
                    Issue("warning", "stair-risers", stair, "Stair has no positive native actual riser count.");
            }

            foreach (var door in doors.Where(d => d.Host is null))
                Issue("warning", "door-host", door, "Door has no host wall; clear opening and room relationship require review.");

            var floorRows = new List<object>();
            var observedFloorMarkers = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var floor in floors)
            {
                string? markerText = floor.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString();
                string? marker = markerText?.Split('|')[0].Trim();
                if (!string.IsNullOrWhiteSpace(marker)) observedFloorMarkers.Add(marker);
                var level = doc.GetElement(floor.LevelId) as Level;
                var type = doc.GetElement(floor.GetTypeId()) as FloorType;
                var compound = type?.GetCompoundStructure();
                double? thicknessFt = compound?.GetWidth();
                var areaParameter = floor.get_Parameter(BuiltInParameter.HOST_AREA_COMPUTED);
                double? areaSqFt = areaParameter is { HasValue: true } ? areaParameter.AsDouble() : null;
                floorRows.Add(new
                {
                    element_id = floor.Id.Value,
                    marker,
                    level = level?.Name,
                    level_elevation_ft = level is null ? (double?)null : UnitUtils.ConvertFromInternalUnits(level.Elevation, UnitTypeId.Feet),
                    native_area_sqft = areaSqFt,
                    floor_type = type?.Name,
                    type_thickness_ft = thicknessFt
                });
                if (string.IsNullOrWhiteSpace(marker))
                    Issue("warning", "floor-marker", floor, "Floor has no stable instance-comment marker.");
                if (areaSqFt is null or <= 0)
                    Issue("warning", "floor-area", floor, "Floor has no positive native computed area.");
            }

            var expectedFloorMarkers = new[] { "FH-C-FLOOR-LOWER", "FH-C-FLOOR-MAIN", "FH-C-FLOOR-UPPER" };
            if (floors.Count != expectedFloorMarkers.Length)
                Issue("warning", "floor-count", null,
                    $"Expected {expectedFloorMarkers.Length} native floor plates; found {floors.Count}.");
            foreach (var required in expectedFloorMarkers)
                if (!observedFloorMarkers.Contains(required))
                    Issue("warning", "required-floor-marker", null, $"Required floor plate marker is missing: {required}.");

            var markerValues = walls.Concat<Element>(stairs).Concat(doors)
                .Select(e => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString())
                .Where(v => !string.IsNullOrWhiteSpace(v)).ToList();
            foreach (var required in new[] { "FH-C-STAIR-LOWER-MAIN", "FH-C-STAIR-MAIN-UPPER", "FH-C-LIFT-RES-01" })
                if (!markerValues.Contains(required, StringComparer.OrdinalIgnoreCase))
                    Issue("warning", "required-marker", null, $"Required study marker is missing: {required}.");

            var nativeWarnings = doc.GetWarnings().Select(w => new
            {
                severity = w.GetSeverity().ToString(),
                description = w.GetDescriptionText(),
                failing_element_ids = w.GetFailingElements().Select(id => id.Value).ToList()
            }).ToList();
            foreach (var warning in nativeWarnings)
            {
                warningCount++;
                issues.Add(new { severity = "warning", check = "revit-warning", element_id = (int?)null, marker = (string?)null, detail = warning.description });
            }

            SavedModelIdentity.AssertSame(doc, modelFingerprint);

            var report = new
            {
                schema = "forever-home.revit-geometry-qa.v2",
                status = "executed; read-only active-document geometry and coordination QA",
                utc = DateTime.UtcNow,
                revit_version = data.Application.Application.VersionNumber,
                revit_build = data.Application.Application.VersionBuild,
                document_title = doc.Title,
                model_fingerprint = modelFingerprint,
                summary = new
                {
                    room_count = rooms.Count,
                    enclosed_room_count = rooms.Count(r => r.Area > 0),
                    wall_count = walls.Count,
                    stair_count = stairs.Count,
                    door_count = doors.Count,
                    floor_count = floors.Count,
                    native_warning_count = nativeWarnings.Count,
                    issue_count = issues.Count,
                    error_count = errorCount,
                    warning_count = warningCount
                },
                floors = floorRows,
                checks = new[]
                {
                    "Room enclosure via native positive room area",
                    "Duplicate wall centerlines by level and rounded endpoints",
                    "Stair elevation and positive actual riser count",
                    "Door host presence",
                    "Native floor inventory, stable floor markers, level assignment, computed area and type thickness",
                    "Required compact-core study markers",
                    "Native Revit warning inventory"
                },
                issues,
                limitations = new[]
                {
                    "Read-only heuristic QA; it does not certify geometry, accessibility, structure, fire/life safety or code compliance.",
                    "Duplicate-wall detection compares level and rounded centerline endpoints; near-miss and solid-intersection cases require visual/geometry review.",
                    "Door host presence does not validate clear width, swing, hardware, egress or accessibility."
                }
            };
            File.WriteAllText(Path.Combine(output, "geometry-qa.json"), JsonSerializer.Serialize(report, JsonOptions));
            File.WriteAllText(Path.Combine(output, "README.txt"),
                "Read-only Geometry QA. Review geometry-qa.json; findings are heuristics and do not constitute code or engineering approval.\n");
            TaskDialog.Show("Forever Home Geometry QA", "Read-only geometry QA written to:\n" + output);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            return Result.Failed;
        }
    }

    static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
}

[Transaction(TransactionMode.Manual)]
public class FamilyIntakeCommand : IExternalCommand
{
    const string EvolutionFamilySha256 = "39715206f24de4b909e37324ce352bba3af348bca259b7a9c0ce335ed2ddc3ea";

    static string? ParameterValue(Parameter parameter) => parameter.StorageType switch
    {
        StorageType.Double => parameter.AsValueString() ?? parameter.AsDouble().ToString("G17", CultureInfo.InvariantCulture),
        StorageType.Integer => parameter.AsValueString() ?? parameter.AsInteger().ToString(CultureInfo.InvariantCulture),
        StorageType.String => parameter.AsString(),
        StorageType.ElementId => parameter.AsValueString() ?? parameter.AsElementId().Value.ToString(CultureInfo.InvariantCulture),
        _ => null
    };

    static (XYZ? Min, XYZ? Max, int Count, double VolumeFt3, int VertexCount) AnalyzePhysicalSolids(GeometryElement geometry)
    {
        int count = 0;
        double volume = 0;
        int vertexCount = 0;
        double minX = double.PositiveInfinity, minY = double.PositiveInfinity, minZ = double.PositiveInfinity;
        double maxX = double.NegativeInfinity, maxY = double.NegativeInfinity, maxZ = double.NegativeInfinity;

        void Include(XYZ point)
        {
            if (!double.IsFinite(point.X) || !double.IsFinite(point.Y) || !double.IsFinite(point.Z)) return;
            minX = Math.Min(minX, point.X); minY = Math.Min(minY, point.Y); minZ = Math.Min(minZ, point.Z);
            maxX = Math.Max(maxX, point.X); maxY = Math.Max(maxY, point.Y); maxZ = Math.Max(maxZ, point.Z);
            vertexCount++;
        }

        void Visit(GeometryElement current, Transform parentTransform)
        {
            foreach (GeometryObject item in current)
            {
                if (item is Solid solid && double.IsFinite(solid.Volume) && solid.Volume > 1e-9)
                {
                    count++;
                    volume += solid.Volume;
                    foreach (Face face in solid.Faces)
                    {
                        var mesh = face.Triangulate();
                        foreach (XYZ vertex in mesh.Vertices) Include(parentTransform.OfPoint(vertex));
                    }
                }
                else if (item is GeometryInstance nested)
                {
                    Visit(nested.GetSymbolGeometry(), parentTransform.Multiply(nested.Transform));
                }
            }
        }

        Visit(geometry, Transform.Identity);
        XYZ? min = vertexCount == 0 ? null : new XYZ(minX, minY, minZ);
        XYZ? max = vertexCount == 0 ? null : new XYZ(maxX, maxY, maxZ);
        return (min, max, count, volume, vertexCount);
    }

    static object InspectSymbol(FamilySymbol symbol)
    {
        var options = new Options
        {
            DetailLevel = ViewDetailLevel.Fine,
            IncludeNonVisibleObjects = false
        };
        var geometry = symbol.get_Geometry(options);
        if (geometry is null)
            return new { type = symbol.Name, geometry_status = "unavailable", geometry_error = "FamilySymbol returned no geometry." };

        var metrics = AnalyzePhysicalSolids(geometry);
        object? boundsIn = null;
        if (metrics.Min is not null && metrics.Max is not null)
        {
            var min = metrics.Min;
            var max = metrics.Max;
            boundsIn = new
            {
                coordinate_frame = "family symbol positive-volume solids; not placed, hosted or oriented in the project",
                min_x = Math.Round(min.X * 12, 4), max_x = Math.Round(max.X * 12, 4),
                min_y = Math.Round(min.Y * 12, 4), max_y = Math.Round(max.Y * 12, 4),
                min_z = Math.Round(min.Z * 12, 4), max_z = Math.Round(max.Z * 12, 4),
                width_x = Math.Round((max.X - min.X) * 12, 4),
                depth_y = Math.Round((max.Y - min.Y) * 12, 4),
                height_z = Math.Round((max.Z - min.Z) * 12, 4),
                triangulated_vertex_count = metrics.VertexCount,
                units = "inches"
            };
        }

        var parameters = symbol.Parameters.Cast<Parameter>()
            .Select(parameter => new
            {
                name = parameter.Definition?.Name ?? "<unnamed>",
                storage_type = parameter.StorageType.ToString(),
                value = ParameterValue(parameter),
                is_read_only = parameter.IsReadOnly
            })
            .OrderBy(parameter => parameter.name, StringComparer.OrdinalIgnoreCase)
            .ThenBy(parameter => parameter.storage_type, StringComparer.Ordinal)
            .ToList();

        return new
        {
            type = symbol.Name,
            geometry_status = boundsIn is null ? "no_measurable_physical_solids" : "measured_from_positive_volume_solids",
            solid_metrics = new { positive_volume_solid_count = metrics.Count, total_volume_ft3 = Math.Round(metrics.VolumeFt3, 6) },
            bounds = boundsIn,
            parameters
        };
    }

    static double[] AxisComponents(XYZ axis) => new[]
    {
        Math.Round(axis.X, 6), Math.Round(axis.Y, 6), Math.Round(axis.Z, 6)
    };

    static object PlaceEvolutionOnVerticalWall(Document target, FamilySymbol symbol)
    {
        var wallType = new FilteredElementCollector(target).OfClass(typeof(WallType)).Cast<WallType>()
            .Where(type => type.Kind == WallKind.Basic)
            .OrderBy(type => type.Name, StringComparer.OrdinalIgnoreCase).FirstOrDefault()
            ?? throw new InvalidOperationException("The disposable intake template has no basic wall type for the vertical host probe.");
        var level = new FilteredElementCollector(target).OfClass(typeof(Level)).Cast<Level>()
            .OrderBy(item => item.Elevation).FirstOrDefault()
            ?? throw new InvalidOperationException("The disposable intake template has no level for the vertical host probe.");

        Wall wall;
        using (var createWall = new Transaction(target, "Create disposable Evolution vertical host"))
        {
            createWall.Start();
            var axis = Line.CreateBound(new XYZ(0, 0, 0), new XYZ(0, 10, 0));
            wall = Wall.Create(target, axis, wallType.Id, level.Id, 10.0, 0.0, false, false);
            createWall.Commit();
        }
        // Committing the wall transaction regenerates the document; Revit forbids
        // Document.Regenerate() outside an open transaction.

        // Obtain stable host-side references through Revit's host-object API.
        // A PlanarFace discovered by traversing wall.get_Geometry() is not
        // guaranteed to carry a usable Reference, even with ComputeReferences.
        var sideReferences = new List<(Reference Reference, PlanarFace Face)>();
        var sideReferenceCounts = new Dictionary<ShellLayerType, int>();
        foreach (var side in new[] { ShellLayerType.Interior, ShellLayerType.Exterior })
        {
            var references = HostObjectUtils.GetSideFaces(wall, side);
            sideReferenceCounts[side] = references.Count;
            sideReferences.AddRange(references
                .Select(reference => (Reference: reference, Face: wall.GetGeometryObjectFromReference(reference) as PlanarFace))
                .Where(candidate => candidate.Face is not null && Math.Abs(candidate.Face.FaceNormal.X) > 0.999)
                .Select(candidate => (candidate.Reference, Face: candidate.Face!)));
        }
        var hostFaceReference = sideReferences.FirstOrDefault();
        if (hostFaceReference.Reference is null || hostFaceReference.Face is null)
            throw new InvalidOperationException($"HostObjectUtils returned no referenceable wall side parallel to project X for the disposable host probe. Wall type: '{wallType.Name}' ({wallType.Kind}); side reference counts: interior={sideReferenceCounts[ShellLayerType.Interior]}, exterior={sideReferenceCounts[ShellLayerType.Exterior]}.");
        var hostFace = hostFaceReference.Face;

        var uv = hostFace.GetBoundingBox();
        var point = hostFace.Evaluate(new UV((uv.Min.U + uv.Max.U) / 2.0, (uv.Min.V + uv.Max.V) / 2.0));
        FamilyInstance instance;
        using (var place = new Transaction(target, "Place Evolution four-inch type on vertical host"))
        {
            place.Start();
            instance = target.Create.NewFamilyInstance(hostFaceReference.Reference, point, XYZ.BasisY, symbol);
            place.Commit();
        }
        // The committed placement transaction regenerates the instance geometry.

        var instanceHost = instance.Host;
        var instanceHostFace = instance.HostFace;
        if (instanceHost?.Id.Value != wall.Id.Value)
            throw new InvalidOperationException("The Evolution instance is not hosted by the disposable wall.");
        if (instanceHostFace is null || instanceHostFace.ElementId.Value != wall.Id.Value)
            throw new InvalidOperationException("The Evolution instance does not retain a reference to the disposable wall face.");
        var instanceTransform = instance.GetTransform();

        var measured = AnalyzePhysicalSolids(instance.get_Geometry(new Options
        {
            DetailLevel = ViewDetailLevel.Fine,
            IncludeNonVisibleObjects = false
        }));
        if (measured.Min is null || measured.Max is null)
            throw new InvalidOperationException("The hosted instance produced no measurable positive-volume solid geometry.");

        return new
        {
            status = "measured on a disposable vertical wall host; not placed in the selected-D house",
            family_type = symbol.Name,
            wall_type = wallType.Name,
            reference_direction = "global +Y; intended family width axis",
            host_face_normal = new[] { Math.Round(hostFace.FaceNormal.X, 6), Math.Round(hostFace.FaceNormal.Y, 6), Math.Round(hostFace.FaceNormal.Z, 6) },
            host_element_id = wall.Id.Value,
            instance_host_element_id = instanceHost.Id.Value,
            host_face_element_id = instanceHostFace.ElementId.Value,
            instance_element_id = instance.Id.Value,
            local_axes_in_project = new
            {
                x = AxisComponents(instanceTransform.BasisX),
                y = AxisComponents(instanceTransform.BasisY),
                z = AxisComponents(instanceTransform.BasisZ)
            },
            positive_volume_solid_count = measured.Count,
            total_volume_ft3 = Math.Round(measured.VolumeFt3, 6),
            global_bounds_in = new
            {
                x_projection = new[] { Math.Round(measured.Min.X * 12, 4), Math.Round(measured.Max.X * 12, 4) },
                y_width = new[] { Math.Round(measured.Min.Y * 12, 4), Math.Round(measured.Max.Y * 12, 4) },
                z_height = new[] { Math.Round(measured.Min.Z * 12, 4), Math.Round(measured.Max.Z * 12, 4) },
                width = Math.Round((measured.Max.Y - measured.Min.Y) * 12, 4),
                projection = Math.Round((measured.Max.X - measured.Min.X) * 12, 4),
                height = Math.Round((measured.Max.Z - measured.Min.Z) * 12, 4)
            },
            limitations = new[]
            {
                "The probe verifies one disposable wall-host orientation only; it does not confirm installed connections, clearance, door or room fit.",
                "The family type description says 'Basin only' while Pedestal Option is Yes; visual review of the hosted solid assembly remains necessary."
            }
        };
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? target = null;
        try
        {
            var app = data.Application.Application;
            var assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
            var root = File.ReadAllText(Path.Combine(assemblyDir, "workspace.txt")).Trim();
            var incoming = Path.Combine(root, "Revit", "Family_Intake", "Incoming");
            var output = Path.Combine(root, ".local", "revit-pilot", "family-intake", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            target = app.NewProjectDocument(UnitSystem.Imperial);
            var results = new List<object>();
            foreach (var path in Directory.EnumerateFiles(incoming, "*.rfa").OrderBy(p => p, StringComparer.OrdinalIgnoreCase))
            {
                string stage = "open_family";
                try
                {
                    string sourceSha256;
                    using (var sourceStream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete))
                        sourceSha256 = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(sourceStream)).ToLowerInvariant();
                    string familyName;
                    string? familyCategory;
                    string placementType;
                    var symbols = new List<FamilySymbol>();
                    bool anyLoaded = false;
                    using (var familyDocument = app.OpenDocumentFile(path))
                    {
                        var sourceFamily = familyDocument.OwnerFamily
                            ?? throw new InvalidOperationException("The opened RFA has no owner family.");
                        familyName = string.IsNullOrWhiteSpace(sourceFamily.Name)
                            ? Path.GetFileNameWithoutExtension(path)
                            : sourceFamily.Name;
                        familyCategory = sourceFamily.FamilyCategory?.Name;
                        placementType = sourceFamily.FamilyPlacementType.ToString();
                        // Revit's documented document-to-document overload is called on
                        // the open family document. It avoids path-based symbol loading,
                        // which returned false for these upgraded vendor RFAs without a
                        // useful failure reason.
                        stage = "load_family_document_to_target";
                        Family loadedFamily = familyDocument.LoadFamily(target);
                        anyLoaded = loadedFamily is not null;
                        if (loadedFamily is null)
                            throw new InvalidOperationException("FamilyDocument.LoadFamily(target) returned no family.");
                        familyName = string.IsNullOrWhiteSpace(loadedFamily.Name) ? familyName : loadedFamily.Name;
                        symbols.AddRange(loadedFamily.GetFamilySymbolIds()
                            .Select(id => target.GetElement(id)).OfType<FamilySymbol>());
                        if (symbols.Count == 0)
                            throw new InvalidOperationException($"Loaded family '{familyName}' contains no symbols.");
                    }
                    stage = "activate_family_symbols";
                    Family family = symbols[0].Family;
                    if (symbols.Any(symbol => !symbol.IsActive))
                    {
                        using var activate = new Transaction(target, $"Activate intake symbols {familyName}");
                        activate.Start();
                        foreach (var symbol in symbols.Where(symbol => !symbol.IsActive)) symbol.Activate();
                        target.Regenerate();
                        activate.Commit();
                    }
                    var inspected = new List<object>();
                    foreach (var symbol in symbols)
                    {
                        try { inspected.Add(InspectSymbol(symbol)); }
                        catch (Exception ex)
                        {
                            inspected.Add(new { type = symbol.Name, geometry_status = "inspection_failed", geometry_error = ex.Message });
                        }
                    }
                    object? hostOrientationTest = null;
                    if (sourceSha256 == EvolutionFamilySha256)
                    {
                        try
                        {
                            var fourInSymbol = symbols.SingleOrDefault(symbol => symbol.Name == "0467.400")
                                ?? throw new InvalidOperationException("Hash-matched Evolution family has no 0467.400 symbol.");
                            stage = "place_evolution_vertical_host_probe";
                            hostOrientationTest = PlaceEvolutionOnVerticalWall(target, fourInSymbol);
                        }
                        catch (Exception ex)
                        {
                            hostOrientationTest = new { status = "failed", error = ex.ToString() };
                        }
                    }
                    results.Add(new
                    {
                        file = Path.GetFileName(path),
                        source_sha256 = sourceSha256,
                        status = anyLoaded ? "loaded" : "already_present",
                        family = family.Name,
                        category = familyCategory,
                        placement_type = placementType,
                        type_count = inspected.Count,
                        types = inspected,
                        host_orientation_test = hostOrientationTest
                    });
                }
                catch (Exception ex)
                {
                    results.Add(new { file = Path.GetFileName(path), status = "failed", stage, error = ex.ToString() });
                }
                finally { }
            }
            var study = Path.Combine(output, "FH_Family_Intake_Study.rvt");
            target.SaveAs(study, new SaveAsOptions());
            File.WriteAllText(Path.Combine(output, "intake-manifest.json"), JsonSerializer.Serialize(new
            {
                status = "executed; symbol-local bounds and type parameters are screening evidence, not placed-family fit or approval",
                utc = DateTime.UtcNow,
                revit_version = app.VersionNumber,
                revit_build = app.VersionBuild,
                source_folder = incoming,
                results
            }, JsonOptions));
            data.Application.OpenAndActivateDocument(study);
            TaskDialog.Show("Forever Home family intake", $"Family intake study saved separately. Results: {output}");
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            try { if (target?.IsValidObject == true) target.Close(false); } catch { }
            return Result.Failed;
        }
    }

    static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };
}

[Transaction(TransactionMode.Manual)]
public class SelectedDCommand : IExternalCommand
{
    static double Number(JsonElement item, string key) => item.GetProperty(key).GetDouble();
    static string Text(JsonElement item, string key) => item.GetProperty(key).GetString()!;
    static double[] Numbers(JsonElement item, string key) => item.GetProperty(key).EnumerateArray().Select(v => v.GetDouble()).ToArray();
    static void Tag(Element element, string id)
    {
        var parameter = element.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (parameter is not null && !parameter.IsReadOnly) parameter.Set(id);
    }

    static string PointKey(double x, double y) => $"{Math.Round(x,6).ToString("0.000000",CultureInfo.InvariantCulture)},{Math.Round(y,6).ToString("0.000000",CultureInfo.InvariantCulture)}";
    static (double x,double y,double width,double depth) Rectangle(JsonElement rectangle,double offsetX=0,double offsetY=0)
    {
        // Selected-D room blocks use x/y/w/d; core reservations use origin/size fields.
        if(rectangle.TryGetProperty("x",out var x) && rectangle.TryGetProperty("y",out var y)
            && rectangle.TryGetProperty("w",out var width) && rectangle.TryGetProperty("d",out var depth))
            return (x.GetDouble()+offsetX,y.GetDouble()+offsetY,width.GetDouble(),depth.GetDouble());
        if(rectangle.TryGetProperty("origin_ft",out var origin)
            && rectangle.TryGetProperty("width_ft",out width) && rectangle.TryGetProperty("depth_ft",out depth))
        {
            var point=origin.EnumerateArray().Select(v=>v.GetDouble()).ToArray();
            if(point.Length==2) return (point[0]+offsetX,point[1]+offsetY,width.GetDouble(),depth.GetDouble());
        }
        throw new InvalidDataException("Selected-D room block must use x/y/w/d or origin_ft/width_ft/depth_ft.");
    }
    static void AddRectangleEdges(JsonElement rectangle, List<(double x,double y)> xs, List<(double x,double y)> ys,double offsetX,double offsetY)
    {
        var (x,y,width,depth)=Rectangle(rectangle,offsetX,offsetY);
        double x1=x,x2=x+width,y1=y,y2=y+depth;
        xs.Add((x1,y1)); xs.Add((x2,y1)); xs.Add((x1,y2)); xs.Add((x2,y2));
        ys.Add((x1,y1)); ys.Add((x2,y1)); ys.Add((x1,y2)); ys.Add((x2,y2));
    }
    static IEnumerable<(double x1,double y1,double x2,double y2)> RectangleEdges(double x1,double y1,double x2,double y2)
    {
        yield return (x1,y1,x2,y1); yield return (x2,y1,x2,y2); yield return (x2,y2,x1,y2); yield return (x1,y2,x1,y1);
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc=null;
        try
        {
            string root=File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!,"workspace.txt")).Trim();
            string sourcePath=Path.Combine(root,"Architecture","Selected_Design_Iteration_2026-10-27","study.json");
            byte[] sourceBytes=File.ReadAllBytes(sourcePath); using var studyDoc=JsonDocument.Parse(File.ReadAllText(sourcePath).TrimStart('\uFEFF')); var study=studyDoc.RootElement;
            if(Text(study,"schema")!="forever-home.selected-house-schematic.v1") throw new InvalidDataException("Unsupported selected-D schematic schema.");
            string output=Path.Combine(root,".local","revit-pilot","selected-d",DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            File.WriteAllBytes(Path.Combine(output,"study.json"),sourceBytes);
            doc=data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var levels=new Dictionary<string,Level>(StringComparer.Ordinal);
            var plans=new Dictionary<string,ViewPlan>(StringComparer.Ordinal);
            var rows=new List<(string id,string name,string level,string kind,double area)>();
            using(var tx=new Transaction(doc,"D room-block and schematic boundary study"))
            {
                tx.Start();
                // NewProjectDocument seeds an unused Level 1 at 0 ft, which IFC otherwise
                // exports as an extra storey. Reuse seed datums when their elevations match
                // a source level, and refuse to leave any unplanned template datum behind.
                var seedLevels=new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().ToList();
                var usedSeedLevelIds=new HashSet<ElementId>();
                foreach(var spec in study.GetProperty("selection").GetProperty("levels").EnumerateArray())
                {
                    string id=Text(spec,"id"), name="D "+Text(spec,"id"); double elevation=Number(spec,"elevation_ft");
                    var seed=seedLevels.FirstOrDefault(candidate=>!usedSeedLevelIds.Contains(candidate.Id)
                        &&Math.Abs(candidate.Elevation-elevation)<1e-6);
                    var level=seed??Level.Create(doc,elevation);
                    if(seed is not null) usedSeedLevelIds.Add(seed.Id);
                    level.Name=name; Tag(level,id); levels.Add(id,level);
                }
                var unassignedSeedLevels=seedLevels.Where(seed=>!usedSeedLevelIds.Contains(seed.Id)).ToArray();
                if(unassignedSeedLevels.Length>0)
                    throw new InvalidDataException("Fresh selected-D project contains template levels that do not match a documented D level: "+
                        string.Join(", ",unassignedSeedLevels.Select(seed=>$"{seed.Name} ({seed.Elevation:0.###} ft)")));
                var planType=new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v=>v.ViewFamily==ViewFamily.FloorPlan);
                foreach(var pair in levels) { var plan=ViewPlan.Create(doc,planType.Id,pair.Value.Id); plan.Name="D "+pair.Key+" Room Blocks"; plans.Add(pair.Key,plan); }
                doc.Regenerate();
                var planDefs=new[]{(key:"main",level:"Main FF",size:Numbers(study.GetProperty("shells"),"main")),(key:"upper",level:"Upper FF",size:Numbers(study.GetProperty("shells"),"rear_upper")),(key:"lower",level:"Lower FF",size:Numbers(study.GetProperty("shells"),"rear_lower"))};
                foreach(var floor in planDefs)
                {
                    var frame=Numbers(study.GetProperty("plan_frame_offsets_ft"),floor.key);
                    double offsetX=frame[0],offsetY=frame[1];
                    var roomSpecs=study.GetProperty("plans").GetProperty(floor.key).EnumerateArray().ToArray();
                    var horizontal=new List<(double x,double y)>(); var vertical=new List<(double x,double y)>();
                    foreach(var room in roomSpecs) AddRectangleEdges(room,horizontal,vertical,offsetX,offsetY);
                    foreach(var edge in RectangleEdges(offsetX,offsetY,offsetX+floor.size[0],offsetY+floor.size[1]))
                    { horizontal.Add((edge.x1,edge.y1)); horizontal.Add((edge.x2,edge.y2)); vertical.Add((edge.x1,edge.y1)); vertical.Add((edge.x2,edge.y2)); }
                    var coordinates=horizontal.Concat(vertical).SelectMany(p=>new[]{p.x,p.y}).Distinct().ToArray();
                    var segments=new Dictionary<string,(double x1,double y1,double x2,double y2)>(StringComparer.Ordinal);
                    void AddSegment(double ax,double ay,double bx,double by)
                    {
                        string ka=PointKey(ax,ay),kb=PointKey(bx,by); string key=string.CompareOrdinal(ka,kb)<0?ka+"|"+kb:kb+"|"+ka;
                        // Floating-point sums can create adjacent cut values such as 39.3333333333333
                        // and 39.33333333333331. They are the same plan point at the adapter's
                        // six-decimal coordinate precision; never pass their zero-length line to Revit.
                        if(ka==kb) return;
                        if(!segments.ContainsKey(key)) segments.Add(key,(ax,ay,bx,by));
                    }
                    foreach(var edge in RectangleEdges(offsetX,offsetY,offsetX+floor.size[0],offsetY+floor.size[1]).Concat(roomSpecs.SelectMany(room=>{
                        var (x,y,width,depth)=Rectangle(room,offsetX,offsetY); return RectangleEdges(x,y,x+width,y+depth);
                    })))
                    {
                        bool verticalEdge=Math.Abs(edge.x1-edge.x2)<1e-7;
                        double cutStart=verticalEdge?edge.y1:edge.x1,cutEnd=verticalEdge?edge.y2:edge.x2;
                        var cuts=coordinates.Where(c=>c>=Math.Min(cutStart,cutEnd)-1e-7&&c<=Math.Max(cutStart,cutEnd)+1e-7)
                            .Where(c=>verticalEdge ? vertical.Any(p=>Math.Abs(p.x-edge.x1)<1e-7&&Math.Abs(p.y-c)<1e-7) : horizontal.Any(p=>Math.Abs(p.y-edge.y1)<1e-7&&Math.Abs(p.x-c)<1e-7))
                            .Distinct().OrderBy(c=>edge.x1==edge.x2?Math.Sign(edge.y2-edge.y1)*c:Math.Sign(edge.x2-edge.x1)*c).ToArray();
                        for(int i=0;i<cuts.Length-1;i++)
                        {
                            if(verticalEdge) AddSegment(edge.x1,cuts[i],edge.x1,cuts[i+1]);
                            else AddSegment(cuts[i],edge.y1,cuts[i+1],edge.y1);
                        }
                    }
                    var curveArray=new CurveArray(); double z=levels[floor.level].Elevation;
                    foreach(var segment in segments.Values) curveArray.Append(Line.CreateBound(new XYZ(segment.x1,segment.y1,z),new XYZ(segment.x2,segment.y2,z)));
                    var sketch=SketchPlane.Create(doc,Plane.CreateByNormalAndOrigin(XYZ.BasisZ,new XYZ(0,0,z)));
                    doc.Create.NewRoomBoundaryLines(sketch,curveArray,plans[floor.level]);
                    doc.Regenerate();
                    foreach(var roomSpec in roomSpecs)
                    {
                        var (x,y,width,depth)=Rectangle(roomSpec,offsetX,offsetY);
                        string id=Text(roomSpec,"id"); var room=doc.Create.NewRoom(levels[floor.level],new UV(x+width/2,y+depth/2));
                        room.Number=id; room.Name=Text(roomSpec,"name"); Tag(room,id);
                        rows.Add((id,room.Name,floor.level,Text(roomSpec,"kind"),width*depth));
                    }
                    // A separate tagged model-curve outline makes the test envelope visible without implying a wall height or assembly.
                    foreach(var edge in RectangleEdges(offsetX,offsetY,offsetX+floor.size[0],offsetY+floor.size[1]))
                    {
                        var model=doc.Create.NewModelCurve(Line.CreateBound(new XYZ(edge.x1,edge.y1,z),new XYZ(edge.x2,edge.y2,z)),sketch);
                        Tag(model,"D-SHELL-OUTLINE-"+floor.key);
                    }
                }
                doc.Regenerate();
                foreach(var levelPair in new[]{(key:"lower",level:"Lower FF"),(key:"main",level:"Main FF"),(key:"upper",level:"Upper FF")})
                {
                    var core=study.GetProperty("stair_core_test"); var rectangles=new List<(string id,double x,double y,double w,double d)>();
                    if(levelPair.key=="lower") { var r=core.GetProperty("lower_to_main").GetProperty("lower_landing_local_ft").EnumerateArray().Select(v=>v.GetDouble()).ToArray(); var frame=Numbers(study.GetProperty("plan_frame_offsets_ft"),"lower"); rectangles.Add(("D-S1-LOWER-LANDING",r[0]+frame[0],r[1]+frame[1],r[2],r[3])); }
                    if(levelPair.key=="main")
                    {
                        foreach(var name in new[]{"lower_to_main","main_to_upper"}) foreach(var part in new[]{"main_landing_ft","run_ft"})
                        { var r=core.GetProperty(name).GetProperty(part).EnumerateArray().Select(v=>v.GetDouble()).ToArray(); rectangles.Add(("D-"+name+"-"+part,r[0],r[1],r[2],r[3])); }
                        var lift=core.GetProperty("lift"); var o=Numbers(lift,"origin_ft"); rectangles.Add(("D-LIFT-RESERVATION",o[0],o[1],Number(lift,"width_ft"),Number(lift,"depth_ft")));
                    }
                    if(levelPair.key=="upper") { var r=core.GetProperty("main_to_upper").GetProperty("upper_floor_extension_ft").EnumerateArray().Select(v=>v.GetDouble()).ToArray(); rectangles.Add(("D-S2-UPPER-CONNECTOR",r[0],r[1],r[2],r[3])); }
                    var sketch=SketchPlane.Create(doc,Plane.CreateByNormalAndOrigin(XYZ.BasisZ,new XYZ(0,0,levels[levelPair.level].Elevation)));
                    foreach(var r in rectangles) foreach(var edge in RectangleEdges(r.x,r.y,r.x+r.w,r.y+r.d))
                    { var line=doc.Create.NewModelCurve(Line.CreateBound(new XYZ(edge.x1,edge.y1,levels[levelPair.level].Elevation),new XYZ(edge.x2,edge.y2,levels[levelPair.level].Elevation)),sketch); Tag(line,r.id); }
                }
                tx.Commit();
            }
            var actualRooms=new FilteredElementCollector(doc).OfClass(typeof(SpatialElement)).WhereElementIsNotElementType().OfType<Room>()
                .Where(r=>r.Area>0).OrderBy(r=>r.Number,StringComparer.Ordinal).Select(r=>new{id=r.Number,name=r.Name,level=r.Level?.Name,area_sf=Math.Round(r.Area,2),status="room-bounded schematic only; no walls, doors, floors or stair solids authored"}).ToArray();
            var areaMismatches=rows.Where(expected=>{
                var actual=actualRooms.FirstOrDefault(room=>room.id==expected.id);
                return actual is null||Math.Abs(actual.area_sf-Math.Round(expected.area,2))>0.1;
            }).ToArray();
            if(actualRooms.Length!=rows.Count||areaMismatches.Length>0)
            {
                var roomLines=new FilteredElementCollector(doc).OfCategory(BuiltInCategory.OST_RoomSeparationLines).WhereElementIsNotElementType().ToElementIds();
                using(var debug=File.Create(Path.Combine(output,"room-audit-debug.json")))
                    JsonSerializer.Serialize(debug,new{
                        expected_room_count=rows.Count,positive_area_room_count=actualRooms.Length,room_separation_line_count=roomLines.Count,
                        phases=new FilteredElementCollector(doc).OfClass(typeof(Phase)).Cast<Phase>().Select(p=>new{id=p.Id.Value,name=p.Name}).ToArray(),
                        plan_phases=plans.Select(p=>new{view=p.Value.Name,phase_id=p.Value.get_Parameter(BuiltInParameter.VIEW_PHASE)?.AsElementId().Value}),
                        room_areas=new FilteredElementCollector(doc).OfClass(typeof(SpatialElement)).WhereElementIsNotElementType().OfType<Room>().OrderBy(r=>r.Number,StringComparer.Ordinal).Select(r=>new{id=r.Number,name=r.Name,level=r.Level?.Name,area_sf=r.Area,phase_id=r.get_Parameter(BuiltInParameter.ROOM_PHASE)?.AsElementId().Value}).ToArray(),
                        room_separation_lines=new FilteredElementCollector(doc).OfCategory(BuiltInCategory.OST_RoomSeparationLines).WhereElementIsNotElementType().OfType<ModelCurve>().Select(line=>new{
                            id=line.Id.Value,owner_view_id=line.OwnerViewId.Value,created_phase_id=line.CreatedPhaseId.Value,
                            start_x_ft=line.GeometryCurve.GetEndPoint(0).X,start_y_ft=line.GeometryCurve.GetEndPoint(0).Y,start_z_ft=line.GeometryCurve.GetEndPoint(0).Z,
                            end_x_ft=line.GeometryCurve.GetEndPoint(1).X,end_y_ft=line.GeometryCurve.GetEndPoint(1).Y,end_z_ft=line.GeometryCurve.GetEndPoint(1).Z
                        }).ToArray()
                    },new JsonSerializerOptions{WriteIndented=true});
                // Preserve a clearly labelled diagnostic copy so boundary failures can be inspected in Revit.
                doc.SaveAs(Path.Combine(output,"diagnostic-unvalidated.rvt"),new SaveAsOptions());
                throw new InvalidOperationException($"Revit room enclosure/area comparison failed: expected {rows.Count} positive-area rooms, got {actualRooms.Length}; mismatches: {string.Join(",",areaMismatches.Select(r=>r.id))}");
            }
            string rvt=Path.Combine(output,"FH_Selected_D_Space_Study.rvt"); doc.SaveAs(rvt,new SaveAsOptions());
            var modelFingerprint=SavedModelIdentity.Capture(doc);
            using(var stream=File.Create(Path.Combine(output,"study-manifest.json")))
                JsonSerializer.Serialize(stream,new{status="native Revit D room-boundary study; not a coordinated building model",source="study.json",source_sha256=Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(sourceBytes)).ToLowerInvariant(),model_fingerprint=modelFingerprint,levels=study.GetProperty("selection").GetProperty("levels").EnumerateArray().Select(l=>new{id=Text(l,"id"),elevation_ft=Number(l,"elevation_ft")}).ToArray(),rooms=actualRooms,wall_count=0,door_count=0,floor_count=0,stair_count=0,unmodeled=new[]{"walls and wall heights","doors/openings","floor solids and assemblies","native stairs and guards","roof","structure","MEP","lift product"}},new JsonSerializerOptions{WriteIndented=true});
            using(var writer=new StreamWriter(Path.Combine(output,"room-inventory.csv"),false,new System.Text.UTF8Encoding(true)))
            { writer.WriteLine("id,name,level,kind,expected_area_sf,revit_area_sf"); foreach(var row in rows.OrderBy(r=>r.id,StringComparer.Ordinal)){var actual=actualRooms.FirstOrDefault(r=>r.id==row.id); writer.WriteLine(string.Join(",",new[]{row.id,row.name,row.level,row.kind,row.area.ToString("0.##",CultureInfo.InvariantCulture),actual?.area_sf.ToString(CultureInfo.InvariantCulture)??""}.Select(v=>"\""+v.Replace("\"","\"\"")+"\"")));} }
            var activeDocument=data.Application.OpenAndActivateDocument(rvt).Document;
            SavedModelIdentity.AssertSame(activeDocument,modelFingerprint);
            using var ifcOptions=new IFCExportOptions{FileVersion=IFCVersion.IFC2x3CV2,ExportBaseQuantities=true};
            bool ifcOk;
            using(var exportTransaction=new Transaction(activeDocument,"Export selected D IFC2x3"))
            {
                exportTransaction.Start();
                try { ifcOk=activeDocument.Export(output,"FH_Selected_D_Space_Study",ifcOptions); }
                finally { if(exportTransaction.GetStatus()==TransactionStatus.Started) exportTransaction.RollBack(); }
            }
            SavedModelIdentity.AssertSame(activeDocument,modelFingerprint);
            string ifcPath=Path.Combine(output,"FH_Selected_D_Space_Study.ifc");
            File.WriteAllText(Path.Combine(output,"export-result.json"),JsonSerializer.Serialize(new{ifc2x3_api_result=ifcOk,model_fingerprint=modelFingerprint,ifc_file=Path.GetFileName(ifcPath),ifc_bytes=File.Exists(ifcPath)?new FileInfo(ifcPath).Length:0,ifc_sha256=File.Exists(ifcPath)?Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(ifcPath))).ToLowerInvariant():null},new JsonSerializerOptions{WriteIndented=true}));
            TaskDialog.Show("Forever Home direction D",$"Saved separate room-boundary study (no construction geometry implied):\n{output}\n\nIFC2x3 export API: {ifcOk}");
            return ifcOk?Result.Succeeded:Result.Failed;
        }
        catch(Exception ex) { message=ex.ToString(); try{if(doc?.IsValidObject==true)doc.Close(false);}catch{} return Result.Failed; }
    }
}

[Transaction(TransactionMode.Manual)]
public class UpperSuiteComparisonCommand : IExternalCommand
{
    const string StudyRelativePath = "Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/search.json";
    const string ManifestRelativePath = "Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/manifest.json";
    const string SelectionRelativePath = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";
    const string Marker = "FH-M78-HYPOTHETICAL-UPPER-SUITE";
    const double Tol = 1e-6;

    static string Sha256(byte[] bytes) => Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(bytes)).ToLowerInvariant();
    static JsonDocument ParseJson(byte[] bytes)
    {
        string json = System.Text.Encoding.UTF8.GetString(bytes).TrimStart('\uFEFF', '\r', '\n', ' ', '\t');
        return JsonDocument.Parse(json);
    }
    static string Text(JsonElement item, string key) => item.GetProperty(key).GetString() ?? "";
    static double Number(JsonElement item, string key) => item.GetProperty(key).GetDouble();
    static void Tag(Element element, string value)
    {
        var parameter = element.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (parameter is not null && !parameter.IsReadOnly) parameter.Set(value);
    }
    static string PointKey(double x, double y) =>
        $"{Math.Round(x, 6).ToString("0.000000", CultureInfo.InvariantCulture)},{Math.Round(y, 6).ToString("0.000000", CultureInfo.InvariantCulture)}";

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
            string root = File.ReadAllText(Path.Combine(assemblyDir, "workspace.txt")).Trim();
            string studyPath = Path.Combine(root, StudyRelativePath.Replace('/', Path.DirectorySeparatorChar));
            string manifestPath = Path.Combine(root, ManifestRelativePath.Replace('/', Path.DirectorySeparatorChar));
            string selectionPath = Path.Combine(root, SelectionRelativePath.Replace('/', Path.DirectorySeparatorChar));
            byte[] studyBytes = File.ReadAllBytes(studyPath);
            byte[] manifestBytes = File.ReadAllBytes(manifestPath);
            byte[] selectionBytes = File.ReadAllBytes(selectionPath);
            using var studyDoc = ParseJson(studyBytes);
            using var manifestDoc = ParseJson(manifestBytes);
            using var selectionDoc = ParseJson(selectionBytes);
            var study = studyDoc.RootElement;
            var manifest = manifestDoc.RootElement;
            var selection = selectionDoc.RootElement;

            if (Text(study, "schema") != "forever-home.m37-upper-suite-pack-route.v2")
                throw new InvalidDataException("Unsupported M78 upper-suite study schema.");
            string studyHash = Sha256(studyBytes);
            string selectionHash = Sha256(selectionBytes);
            string manifestStudyHash = Text(manifest.GetProperty("output_hashes_sha256"), "search");
            string manifestSelectionHash = Text(manifest.GetProperty("source_fingerprints_sha256"), "selected_D_study.json");
            if (!string.Equals(studyHash, manifestStudyHash, StringComparison.OrdinalIgnoreCase) ||
                !string.Equals(selectionHash, manifestSelectionHash, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("M78 study or selected-D source fingerprint does not match its archived manifest.");

            var coordinateBasis = study.GetProperty("coordinate_basis");
            double shellWidth = Number(coordinateBasis, "width_ft"), shellDepth = Number(coordinateBasis, "depth_ft");
            if (Math.Abs(shellWidth - 38.333333) > Tol || Math.Abs(shellDepth - 40.0) > Tol ||
                !Text(coordinateBasis, "shell_case").Contains("hypothetical", StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("This command is restricted to the documented hypothetical 38.333333 x 40 ft M78 case.");

            var candidate = study.GetProperty("best_candidate");
            if (!candidate.GetProperty("hall_reachability").GetProperty("required_public_rooms_reached").GetBoolean())
                throw new InvalidDataException("M78 candidate does not pass its retained sampled public-room route check.");
            var reached = candidate.GetProperty("public_rooms_reached").EnumerateArray().Select(v => v.GetString()).ToHashSet(StringComparer.Ordinal);
            if (!new[] { "U-01", "U-02", "U-04" }.All(reached.Contains) || reached.Contains("U-03"))
                throw new InvalidDataException("M78 access graph does not preserve the owner-directed public/private room routes.");

            var roomsById = selection.GetProperty("plans").GetProperty("upper").EnumerateArray()
                .ToDictionary(room => Text(room, "id"), room => new
                {
                    Name = Text(room, "name"),
                    Kind = Text(room, "kind"),
                    Width = Number(room, "w"),
                    Depth = Number(room, "d")
                }, StringComparer.Ordinal);
            var frame = selection.GetProperty("plan_frame_offsets_ft").GetProperty("upper").EnumerateArray().Select(v => v.GetDouble()).ToArray();
            if (frame.Length != 2) throw new InvalidDataException("Selected-D upper frame offset must have two coordinates.");
            var rectangles = new List<(string Id, string Name, string Kind, double X, double Y, double W, double D)>();
            foreach (var property in candidate.GetProperty("rectangles").EnumerateObject())
            {
                string id = property.Name;
                if (!roomsById.TryGetValue(id, out var source)) throw new InvalidDataException($"M78 room '{id}' is absent from the source upper-room program.");
                var rectangle = property.Value;
                double x = Number(rectangle, "x_ft"), y = Number(rectangle, "y_ft");
                double width = Number(rectangle, "width_ft"), depth = Number(rectangle, "depth_ft");
                var sourceDimensions = study.GetProperty("source_dimensions_ft").GetProperty(id);
                double sourceWidth = Number(sourceDimensions, "width_ft"), sourceDepth = Number(sourceDimensions, "depth_ft");
                bool sourceOrientation = Math.Abs(width - sourceWidth) <= Tol && Math.Abs(depth - sourceDepth) <= Tol;
                bool rotatedSourceOrientation = Math.Abs(width - sourceDepth) <= Tol && Math.Abs(depth - sourceWidth) <= Tol;
                bool roomProgramOrientation =
                    (Math.Abs(width - source.Width) <= Tol && Math.Abs(depth - source.Depth) <= Tol) ||
                    (Math.Abs(width - source.Depth) <= Tol && Math.Abs(depth - source.Width) <= Tol);
                if ((!sourceOrientation && !rotatedSourceOrientation) || !roomProgramOrientation)
                    throw new InvalidDataException($"M78 room '{id}' dimensions differ from the documented source room program.");
                if (width <= 0 || depth <= 0 || x < -Tol || y < -Tol || x + width > shellWidth + Tol || y + depth > shellDepth + Tol)
                    throw new InvalidDataException($"M78 room '{id}' is outside the hypothetical shell or has invalid dimensions.");
                rectangles.Add((id, source.Name, source.Kind, x + frame[0], y + frame[1], width, depth));
            }
            if (rectangles.Count != 7 || rectangles.Select(room => room.Id).Distinct(StringComparer.Ordinal).Count() != 7)
                throw new InvalidDataException($"Expected seven unique M78 upper rooms/connectors, found {rectangles.Count}.");
            for (int i = 0; i < rectangles.Count; i++)
            for (int j = i + 1; j < rectangles.Count; j++)
            {
                var a = rectangles[i]; var b = rectangles[j];
                double overlapX = Math.Min(a.X + a.W, b.X + b.W) - Math.Max(a.X, b.X);
                double overlapY = Math.Min(a.Y + a.D, b.Y + b.D) - Math.Max(a.Y, b.Y);
                if (overlapX > Tol && overlapY > Tol) throw new InvalidDataException($"M78 rooms '{a.Id}' and '{b.Id}' overlap in plan.");
            }

            var upperLevel = selection.GetProperty("selection").GetProperty("levels").EnumerateArray()
                .FirstOrDefault(level => Text(level, "id") == "Upper FF");
            if (upperLevel.ValueKind == JsonValueKind.Undefined) throw new InvalidDataException("Selected-D source has no upper-level datum.");
            double elevation = Number(upperLevel, "elevation_ft");
            string output = Path.Combine(root, ".local", "revit-pilot", "upper-suite", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            File.WriteAllBytes(Path.Combine(output, "m78-search.json"), studyBytes);
            File.WriteAllBytes(Path.Combine(output, "selected-d-study.json"), selectionBytes);

            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var roomAreas = new List<(string Id, string Name, double Area, double ExpectedArea)>();
            using (var tx = new Transaction(doc, "Create separate M78 upper-suite room study"))
            {
                tx.Start();
                var seedLevels = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().ToArray();
                Level level;
                if (seedLevels.Length == 1)
                {
                    level = seedLevels[0];
                    level.Name = "M78 Upper FF (Hypothetical Test)";
                    level.Elevation = elevation;
                }
                else
                {
                    foreach (var seed in seedLevels) doc.Delete(seed.Id);
                    level = Level.Create(doc, elevation);
                    level.Name = "M78 Upper FF (Hypothetical Test)";
                }
                Tag(level, Marker);
                var planType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>()
                    .First(v => v.ViewFamily == ViewFamily.FloorPlan);
                var plan = ViewPlan.Create(doc, planType.Id, level.Id);
                plan.Name = "M78 Hypothetical Upper Suite Room Blocks";

                var allRects = rectangles.Select(room => (room.X, room.Y, room.W, room.D)).ToList();
                var xCuts = allRects.SelectMany(r => new[] { r.X, r.X + r.W }).Append(frame[0]).Append(frame[0] + shellWidth)
                    .Distinct().ToArray();
                var yCuts = allRects.SelectMany(r => new[] { r.Y, r.Y + r.D }).Append(frame[1]).Append(frame[1] + shellDepth)
                    .Distinct().ToArray();
                var segments = new Dictionary<string, (double X1, double Y1, double X2, double Y2)>(StringComparer.Ordinal);
                void AddSegment(double x1, double y1, double x2, double y2)
                {
                    string a = PointKey(x1, y1), b = PointKey(x2, y2);
                    if (a == b) return;
                    string key = string.CompareOrdinal(a, b) < 0 ? a + "|" + b : b + "|" + a;
                    if (!segments.ContainsKey(key)) segments.Add(key, (x1, y1, x2, y2));
                }
                var edges = new List<(double X1, double Y1, double X2, double Y2)>();
                foreach (var room in rectangles)
                {
                    edges.Add((room.X, room.Y, room.X + room.W, room.Y));
                    edges.Add((room.X + room.W, room.Y, room.X + room.W, room.Y + room.D));
                    edges.Add((room.X + room.W, room.Y + room.D, room.X, room.Y + room.D));
                    edges.Add((room.X, room.Y + room.D, room.X, room.Y));
                }
                edges.Add((frame[0], frame[1], frame[0] + shellWidth, frame[1]));
                edges.Add((frame[0] + shellWidth, frame[1], frame[0] + shellWidth, frame[1] + shellDepth));
                edges.Add((frame[0] + shellWidth, frame[1] + shellDepth, frame[0], frame[1] + shellDepth));
                edges.Add((frame[0], frame[1] + shellDepth, frame[0], frame[1]));
                foreach (var edge in edges)
                {
                    bool vertical = Math.Abs(edge.X1 - edge.X2) < Tol;
                    var cuts = vertical
                        ? yCuts.Where(c => c >= Math.Min(edge.Y1, edge.Y2) - Tol && c <= Math.Max(edge.Y1, edge.Y2) + Tol).OrderBy(c => edge.Y2 >= edge.Y1 ? c : -c).ToArray()
                        : xCuts.Where(c => c >= Math.Min(edge.X1, edge.X2) - Tol && c <= Math.Max(edge.X1, edge.X2) + Tol).OrderBy(c => edge.X2 >= edge.X1 ? c : -c).ToArray();
                    for (int i = 0; i + 1 < cuts.Length; i++)
                        if (vertical) AddSegment(edge.X1, cuts[i], edge.X1, cuts[i + 1]);
                        else AddSegment(cuts[i], edge.Y1, cuts[i + 1], edge.Y1);
                }
                var curveArray = new CurveArray();
                foreach (var segment in segments.Values)
                    curveArray.Append(Line.CreateBound(new XYZ(segment.X1, segment.Y1, elevation), new XYZ(segment.X2, segment.Y2, elevation)));
                var plane = Plane.CreateByNormalAndOrigin(XYZ.BasisZ, new XYZ(frame[0], frame[1], elevation));
                var sketch = SketchPlane.Create(doc, plane);
                doc.Create.NewRoomBoundaryLines(sketch, curveArray, plan);
                doc.Regenerate();
                foreach (var roomSpec in rectangles)
                {
                    var room = doc.Create.NewRoom(level, new UV(roomSpec.X + roomSpec.W / 2, roomSpec.Y + roomSpec.D / 2));
                    room.Number = roomSpec.Id;
                    room.Name = roomSpec.Name;
                    Tag(room, Marker + ":" + roomSpec.Id);
                }
                foreach (var edge in new[]
                {
                    (frame[0], frame[1], frame[0] + shellWidth, frame[1]),
                    (frame[0] + shellWidth, frame[1], frame[0] + shellWidth, frame[1] + shellDepth),
                    (frame[0] + shellWidth, frame[1] + shellDepth, frame[0], frame[1] + shellDepth),
                    (frame[0], frame[1] + shellDepth, frame[0], frame[1])
                })
                {
                    var modelCurve = doc.Create.NewModelCurve(Line.CreateBound(new XYZ(edge.Item1, edge.Item2, elevation), new XYZ(edge.Item3, edge.Item4, elevation)), sketch);
                    Tag(modelCurve, Marker + ":SHELL-OUTLINE-ONLY");
                }
                doc.Regenerate();
                foreach (var roomSpec in rectangles)
                {
                    var room = new FilteredElementCollector(doc).OfClass(typeof(SpatialElement)).WhereElementIsNotElementType().OfType<Room>()
                        .SingleOrDefault(item => item.Number == roomSpec.Id && item.Area > 0);
                    double expectedArea = roomSpec.W * roomSpec.D;
                    if (room is null || Math.Abs(room.Area - expectedArea) > 0.1)
                        throw new InvalidOperationException($"Revit room '{roomSpec.Id}' area mismatch: expected {expectedArea:0.##} sf, found {room?.Area ?? 0:0.##} sf.");
                    roomAreas.Add((room.Number, room.Name, Math.Round(room.Area, 2), Math.Round(expectedArea, 2)));
                }
                tx.Commit();
            }

            string rvtPath = Path.Combine(output, "FH_M78_Upper_Suite_Test.rvt");
            doc.SaveAs(rvtPath, new SaveAsOptions());
            var fingerprint = SavedModelIdentity.Capture(doc);
            var inventory = new
            {
                schema = "forever-home.m78-upper-suite-revit-study.v1",
                status = "hypothetical upper-suite room-boundary study; not an approved shell or coordinated building model",
                source_sha256 = new { m78_search = studyHash, selected_d_study = selectionHash },
                model_fingerprint = fingerprint,
                shell_test = new { width_ft = shellWidth, depth_ft = shellDepth, frame_offset_ft = frame, status = "owner-authorized comparison only; unselected" },
                level = new { name = "M78 Upper FF (Hypothetical Test)", elevation_ft = elevation },
                rooms = roomAreas.Select(room => new { id = room.Id, name = room.Name, area_sf = room.Area, expected_area_sf = room.ExpectedArea }).ToArray(),
                counts = new { room_count = rectangles.Count, wall_count = 0, door_count = 0, floor_count = 0, stair_count = 0 },
                limitations = new[]
                {
                    "Only room-separation boundaries and a model-line shell outline were authored; the outline is not a wall or envelope assembly.",
                    "No actual openings, door swings, privacy screens, stairs, roof, structure, MEP, or lift product were modeled.",
                    "The source M78 corridor grid is sampled reachability, not a measured clear route or code finding.",
                    "This hypothetical comparison does not amend the selected-D source or approve a building dimension.",
                    "No code-compliance, accessibility, structural-safety, certification or construction-readiness claim is made."
                }
            };
            File.WriteAllText(Path.Combine(output, "study-manifest.json"), JsonSerializer.Serialize(inventory, new JsonSerializerOptions { WriteIndented = true }));
            using (var writer = new StreamWriter(Path.Combine(output, "room-inventory.csv"), false, new System.Text.UTF8Encoding(true)))
            {
                writer.WriteLine("id,name,area_sf,expected_area_sf");
                foreach (var row in roomAreas.OrderBy(item => item.Id, StringComparer.Ordinal))
                {
                    writer.WriteLine($"\"{row.Id}\",\"{row.Name}\",\"{row.Area.ToString(CultureInfo.InvariantCulture)}\",\"{row.ExpectedArea.ToString(CultureInfo.InvariantCulture)}\"");
                }
            }
            using var ifcOptions = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true };
            bool ifcOk;
            using (var export = new Transaction(doc, "Export hypothetical M78 upper-suite IFC2x3"))
            {
                export.Start();
                try { ifcOk = doc.Export(output, "FH_M78_Upper_Suite_Test", ifcOptions); }
                finally { if (export.GetStatus() == TransactionStatus.Started) export.RollBack(); }
            }
            SavedModelIdentity.AssertSame(doc, fingerprint);
            string ifcPath = Path.Combine(output, "FH_M78_Upper_Suite_Test.ifc");
            File.WriteAllText(Path.Combine(output, "export-result.json"), JsonSerializer.Serialize(new
            {
                ifc2x3_api_result = ifcOk,
                model_fingerprint = fingerprint,
                ifc_file = Path.GetFileName(ifcPath),
                ifc_bytes = File.Exists(ifcPath) ? new FileInfo(ifcPath).Length : 0,
                ifc_sha256 = File.Exists(ifcPath) ? Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(ifcPath))).ToLowerInvariant() : null
            }, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home upper-suite test", $"Saved a separate M78 room-boundary study (no construction geometry implied):\n{output}\n\nIFC2x3 export API: {ifcOk}");
            return ifcOk ? Result.Succeeded : Result.Failed;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            try { if (doc?.IsValidObject == true) doc.Close(false); } catch { }
            return Result.Failed;
        }
    }
}

[Transaction(TransactionMode.Manual)]
public class GableMassingCommand : IExternalCommand
{
    const string DataRelativePath = "Architecture/M83_Gable_Massing_38_333333x40_2026-10-30/roof-options.json";
    const string DataManifestRelativePath = "Architecture/M83_Gable_Massing_38_333333x40_2026-10-30/manifest.json";
    const string Marker = "FH-M83-GABLE-MASSING";
    const double TolFt = 0.002;

    static string Sha256(byte[] bytes) => Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(bytes)).ToLowerInvariant();
    static JsonDocument ParseJson(byte[] bytes) => JsonDocument.Parse(System.Text.Encoding.UTF8.GetString(bytes).TrimStart('\uFEFF', '\r', '\n', ' ', '\t'));
    static string Text(JsonElement item, string key) => item.GetProperty(key).GetString() ?? "";
    static double Number(JsonElement item, string key) => item.GetProperty(key).GetDouble();
    static void Tag(Element element, string value)
    {
        var parameter = element.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (parameter is not null && !parameter.IsReadOnly) parameter.Set(value);
    }

    static void AddFace(TessellatedShapeBuilder builder, ElementId materialId, params XYZ[] points) =>
        builder.AddFace(new TessellatedFace(points, materialId));

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
            string root = File.ReadAllText(Path.Combine(assemblyDir, "workspace.txt")).Trim();
            string dataPath = Path.Combine(root, DataRelativePath.Replace('/', Path.DirectorySeparatorChar));
            string dataManifestPath = Path.Combine(root, DataManifestRelativePath.Replace('/', Path.DirectorySeparatorChar));
            byte[] dataBytes = File.ReadAllBytes(dataPath), dataManifestBytes = File.ReadAllBytes(dataManifestPath);
            using var dataJson = ParseJson(dataBytes);
            using var dataManifestJson = ParseJson(dataManifestBytes);
            var model = dataJson.RootElement;
            var modelManifest = dataManifestJson.RootElement;
            if (Text(model, "schema") != "forever-home.m83-gable-massing-options.v1")
                throw new InvalidDataException("Unsupported M83 roof-option data schema.");
            string dataHash = Sha256(dataBytes);
            if (!string.Equals(dataHash, Text(modelManifest.GetProperty("output_hashes_sha256"), "roof_options"), StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("M83 roof-option JSON does not match its generator manifest.");

            var sources = model.GetProperty("source_fingerprints_sha256");
            var requiredSources = new Dictionary<string, string>(StringComparer.Ordinal)
            {
                ["m78_search"] = "Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/search.json",
                ["m78_manifest"] = "Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/manifest.json",
                ["selected_d_study"] = "Architecture/Selected_Design_Iteration_2026-10-27/study.json",
                ["m38_pitch_options"] = "Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/pitch-options.json",
                ["m38_manifest"] = "Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/manifest.json",
                ["Connecticut_roof_research"] = "Research/Connecticut_Roof_Code_Research_2026-10-28.md"
            };
            foreach (var source in requiredSources)
            {
                string sourcePath = Path.Combine(root, source.Value.Replace('/', Path.DirectorySeparatorChar));
                string actual = Sha256(File.ReadAllBytes(sourcePath));
                if (!string.Equals(actual, Text(sources, source.Key), StringComparison.OrdinalIgnoreCase))
                    throw new InvalidDataException($"M83 source fingerprint mismatch for {source.Key}.");
            }

            var basis = model.GetProperty("coordinate_basis");
            double width = Number(basis, "shell_width_ft"), depth = Number(basis, "shell_depth_ft");
            if (Math.Abs(width - 38.333333) > 1e-6 || Math.Abs(depth - 40.0) > 1e-6 ||
                !Text(basis, "shell_status").Contains("hypothetical", StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("M83 is restricted to the 38.333333 x 40 ft hypothetical shell comparison.");

            var options = model.GetProperty("results").EnumerateArray().ToArray();
            if (options.Length != 6 || options.Select(option => Text(option, "case_id")).Distinct(StringComparer.Ordinal).Count() != 6)
                throw new InvalidDataException($"Expected six unique roof massing options; found {options.Length}.");
            foreach (var option in options)
            {
                string axis = Text(option, "ridge_axis");
                double expectedRidgeLength = axis == "X" ? width : axis == "Y" ? depth : -1;
                double expectedSpan = axis == "X" ? depth : axis == "Y" ? width : -1;
                if (expectedRidgeLength < 0 || Math.Abs(Number(option, "ridge_length_ft") - expectedRidgeLength) > 1e-6 ||
                    Math.Abs(Number(option, "transverse_span_ft") - expectedSpan) > 1e-6)
                    throw new InvalidDataException($"Roof option {Text(option, "case_id")} has an inconsistent ridge orientation.");
                if (!Text(option, "selection_status").Contains("not owner-selected", StringComparison.OrdinalIgnoreCase) ||
                    option.GetProperty("physical_thickness_ft").ValueKind != JsonValueKind.Null)
                    throw new InvalidDataException($"Roof option {Text(option, "case_id")} is selected or has an invented thickness.");
            }

            string output = Path.Combine(root, ".local", "revit-pilot", "roof-massing", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            File.WriteAllBytes(Path.Combine(output, "roof-options.json"), dataBytes);
            File.WriteAllBytes(Path.Combine(output, "roof-options-manifest.json"), dataManifestBytes);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var records = new List<object>();
            const string displayMaterialName = "M83 Display Only - Not a Material Specification";
            using (var tx = new Transaction(doc, "Create M83 comparative roof surfaces"))
            {
                tx.Start();
                var seedLevels = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().ToArray();
                Level datum;
                if (seedLevels.Length > 0)
                {
                    // Revit templates may supply several levels with dependent views.
                    // Keep them intact; deleting template-owned levels can fail or
                    // remove view structure for no benefit in this disposable study.
                    datum = seedLevels.OrderBy(level => level.Elevation).First();
                    datum.Name = "M83 Relative Eave Reference (Not a Building Datum)";
                    datum.Elevation = 0;
                }
                else
                {
                    datum = Level.Create(doc, 0);
                    datum.Name = "M83 Relative Eave Reference (Not a Building Datum)";
                }
                Tag(datum, Marker + ":RELATIVE-ZERO-ONLY");

                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>()
                    .First(view => view.ViewFamily == ViewFamily.ThreeDimensional);
                var view3d = View3D.CreateIsometric(doc, viewType.Id);
                view3d.Name = "M83 Gable Massing Comparisons (Study Only)";
                view3d.SetCategoryHidden(new ElementId(BuiltInCategory.OST_Levels), true);
                var displayMaterialId = Material.Create(doc, displayMaterialName);
                var displayMaterial = (Material)doc.GetElement(displayMaterialId);
                displayMaterial.Color = new Color(171, 139, 105);

                var optionsGeometry = new Options { DetailLevel = ViewDetailLevel.Fine, IncludeNonVisibleObjects = false };
                foreach (var option in options)
                {
                    string caseId = Text(option, "case_id");
                    string axis = Text(option, "ridge_axis");
                    double rise = Number(option, "rise_above_relative_eave_ft");
                    var offset = option.GetProperty("display_offset_ft");
                    double ox = Number(offset, "x"), oy = Number(offset, "y");
                    var builder = new TessellatedShapeBuilder();
                    builder.OpenConnectedFaceSet(false);
                    if (axis == "X")
                    {
                        double ym = oy + depth / 2.0;
                        AddFace(builder, displayMaterial.Id,
                            new XYZ(ox, oy, 0), new XYZ(ox + width, oy, 0),
                            new XYZ(ox + width, ym, rise), new XYZ(ox, ym, rise));
                        AddFace(builder, displayMaterial.Id,
                            new XYZ(ox, ym, rise), new XYZ(ox + width, ym, rise),
                            new XYZ(ox + width, oy + depth, 0), new XYZ(ox, oy + depth, 0));
                    }
                    else
                    {
                        double xm = ox + width / 2.0;
                        AddFace(builder, displayMaterial.Id,
                            new XYZ(ox, oy, 0), new XYZ(xm, oy, rise),
                            new XYZ(xm, oy + depth, rise), new XYZ(ox, oy + depth, 0));
                        AddFace(builder, displayMaterial.Id,
                            new XYZ(xm, oy, rise), new XYZ(ox + width, oy, 0),
                            new XYZ(ox + width, oy + depth, 0), new XYZ(xm, oy + depth, rise));
                    }
                    builder.CloseConnectedFaceSet();
                    builder.Target = TessellatedShapeBuilderTarget.Mesh;
                    builder.Fallback = TessellatedShapeBuilderFallback.Salvage;
                    builder.Build();
                    var directShape = DirectShape.CreateElement(doc, new ElementId(BuiltInCategory.OST_GenericModel));
                    directShape.ApplicationId = "ForeverHome.M83";
                    directShape.ApplicationDataId = caseId;
                    directShape.SetName(caseId + " - Conceptual Gable Surfaces");
                    directShape.SetShape(builder.GetBuildResult().GetGeometricalObjects());
                    Tag(directShape, Marker + ":" + caseId + ":OPEN-MESH-ONLY");

                    // DirectShape bounds are not guaranteed to be populated until
                    // Revit regenerates the document after SetShape. This command
                    // verifies the actual Revit geometry before committing the
                    // disposable comparison transaction.
                    doc.Regenerate();
                    BoundingBoxXYZ? bounds = directShape.get_BoundingBox(null);
                    if (bounds is null) throw new InvalidOperationException($"M83 DirectShape has no bounds: {caseId}.");
                    double bx = bounds.Max.X - bounds.Min.X, by = bounds.Max.Y - bounds.Min.Y, bz = bounds.Max.Z - bounds.Min.Z;
                    if (Math.Abs(bx - width) > TolFt || Math.Abs(by - depth) > TolFt ||
                        Math.Abs(bz - rise) > TolFt || Math.Abs(bounds.Min.X - ox) > TolFt || Math.Abs(bounds.Min.Y - oy) > TolFt)
                        throw new InvalidOperationException($"M83 Revit bounds differ from expected local envelope for {caseId}: {bx:0.######} x {by:0.######} x {bz:0.######} ft.");
                    var geometry = directShape.get_Geometry(optionsGeometry);
                    int meshCount = geometry?.OfType<Mesh>().Count() ?? 0;
                    int solidCount = geometry?.OfType<Solid>().Count(solid => solid.Volume > 1e-9) ?? 0;
                    if (meshCount < 1 || solidCount != 0)
                        throw new InvalidOperationException($"M83 {caseId} expected open mesh geometry and no solid; got {meshCount} meshes / {solidCount} solids.");
                    records.Add(new
                    {
                        case_id = caseId,
                        direct_shape_unique_id = directShape.UniqueId,
                        ridge_axis = axis,
                        expected_rise_ft = rise,
                        expected_two_plane_area_sf = Number(option, "two_plane_surface_area_sf"),
                        mesh_count = meshCount,
                        positive_volume_solid_count = solidCount,
                        bounds_ft = new { min_x = bounds.Min.X, min_y = bounds.Min.Y, min_z = bounds.Min.Z,
                            max_x = bounds.Max.X, max_y = bounds.Max.Y, max_z = bounds.Max.Z }
                    });
                }
                tx.Commit();
            }

            string rvtPath = Path.Combine(output, "FH_M83_Gable_Massing_Comparison.rvt");
            doc.SaveAs(rvtPath, new SaveAsOptions());
            var fingerprint = SavedModelIdentity.Capture(doc);
            var inventory = new
            {
                schema = "forever-home.m83-gable-massing-revit.v1",
                status = "disposable hypothetical comparison; open roof-surface meshes only; not a building roof",
                source_fingerprint_sha256 = dataHash,
                model_fingerprint = fingerprint,
                display_material = new { name = displayMaterialName, selected_as_product = false, function = "neutral view-only color for comparison surfaces" },
                counts = new { option_count = records.Count, generic_model_direct_shapes = records.Count,
                    levels = new FilteredElementCollector(doc).OfClass(typeof(Level)).GetElementCount(),
                    roofs = 0, walls = 0, floors = 0, doors = 0, windows = 0, stairs = 0 },
                geometry = records,
                limitations = new[]
                {
                        "Each DirectShape is an open, zero-thickness pair of planar roof faces; it is a display/massing mesh, not a Revit Roof element or assembly. The single neutral display material is not a product or material specification.",
                    "The zero-elevation level is a local relative reference only and is not tied to a project floor or wall plate.",
                    "Option display offsets are solely to separate alternatives in this comparison file; they are not house coordinates.",
                    "No gable wall, overhang, dormer, opening, framing, structure, snow/wind design, drainage, attic, headroom, site, or code determination is represented.",
                    "No code-compliance, structural-safety, professional certification, or construction-readiness claim is made."
                }
            };
            File.WriteAllText(Path.Combine(output, "study-manifest.json"), JsonSerializer.Serialize(inventory, new JsonSerializerOptions { WriteIndented = true }));

            using var ifcOptions = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true };
            bool ifcOk;
            using (var export = new Transaction(doc, "Export M83 roof-surface comparison IFC2x3"))
            {
                export.Start();
                try { ifcOk = doc.Export(output, "FH_M83_Gable_Massing_Comparison", ifcOptions); }
                finally { if (export.GetStatus() == TransactionStatus.Started) export.RollBack(); }
            }
            SavedModelIdentity.AssertSame(doc, fingerprint);
            string ifcPath = Path.Combine(output, "FH_M83_Gable_Massing_Comparison.ifc");
            File.WriteAllText(Path.Combine(output, "export-result.json"), JsonSerializer.Serialize(new
            {
                ifc2x3_api_result = ifcOk,
                model_fingerprint = fingerprint,
                ifc_file = Path.GetFileName(ifcPath),
                ifc_bytes = File.Exists(ifcPath) ? new FileInfo(ifcPath).Length : 0,
                ifc_sha256 = File.Exists(ifcPath) ? Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(ifcPath))).ToLowerInvariant() : null
            }, new JsonSerializerOptions { WriteIndented = true }));
            doc.Close(false);
            doc = null;
            data.Application.OpenAndActivateDocument(rvtPath);
            TaskDialog.Show("Forever Home roof study", $"Created a separate M83 Revit/IFC comparison with six conceptual open-surface options (no roof assembly or house datum):\n{output}\n\nIFC2x3 export API: {ifcOk}");
            return ifcOk ? Result.Succeeded : Result.Failed;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            try { if (doc?.IsValidObject == true) doc.Close(false); } catch { }
            return Result.Failed;
        }
    }
}

[Transaction(TransactionMode.Manual)]
public class CompactCoreCommand : IExternalCommand
{
    static double Number(JsonElement item, string key) => item.GetProperty(key).GetDouble();
    static string Text(JsonElement item, string key) => item.GetProperty(key).GetString()!;
    static double[] Numbers(JsonElement item, string key) => item.GetProperty(key).EnumerateArray().Select(value => value.GetDouble()).ToArray();
    static XYZ Point3(JsonElement item, string key)
    {
        var values = Numbers(item, key);
        if (values.Length != 3) throw new InvalidDataException($"{key} must contain exactly three coordinates.");
        return new XYZ(values[0], values[1], values[2]);
    }

    static void Tag(Element e, string id)
    {
        var p = e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (p is not null && !p.IsReadOnly) p.Set(id);
    }

    static CurveLoop ProfileLoop(Level level, JsonElement points)
    {
        var loop = new CurveLoop();
        var vertices = points.EnumerateArray().Select(point => point.EnumerateArray().Select(value => value.GetDouble()).ToArray()).ToArray();
        if (vertices.Length < 3 || vertices.Any(point => point.Length != 2))
            throw new InvalidDataException("A floor polygon must contain at least three XY vertices.");
        for (int i = 0; i < vertices.Length; i++)
        {
            var a = vertices[i]; var b = vertices[(i + 1) % vertices.Length];
            loop.Append(Line.CreateBound(new XYZ(a[0], a[1], level.Elevation), new XYZ(b[0], b[1], level.Elevation)));
        }
        return loop;
    }

    static string Csv(string value) => "\"" + value.Replace("\"", "\"\"") + "\"";

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        try
        {
            var doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string output = Path.Combine(root, ".local", "revit-pilot", "compact-core", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            var configPath = Path.Combine(root, "Tools", "RevitPilot", "compact-study-config.json");
            byte[] configBytes = File.ReadAllBytes(configPath);
            File.WriteAllBytes(Path.Combine(output, "compact-study-config.json"), configBytes);
            using var configDocument = JsonDocument.Parse(configBytes);
            var config = configDocument.RootElement;
            var studyName = Text(config, "study");
            var doorFamilySpec = config.GetProperty("nominal_door_family");
            var door = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_C_Nominal_Door",
                Number(doorFamilySpec, "width_ft"), Number(doorFamilySpec, "depth_ft"), Number(doorFamilySpec, "height_ft"));
            var levels = new Dictionary<string, Level>();
            Level lower = null!, main = null!, upper = null!;
            var shellSpec = config.GetProperty("shell");
            var liftSpec = config.GetProperty("lift_reservation");
            double liftWidth = Number(liftSpec, "width_ft"), liftDepth = Number(liftSpec, "depth_ft");
            using (var t = new Transaction(doc, "C compact core study; proposal only"))
            {
                t.Start();
                foreach (var levelSpec in config.GetProperty("levels").EnumerateArray())
                {
                    double elevation = Number(levelSpec, "elevation_ft");
                    var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>()
                        .FirstOrDefault(candidate => Math.Abs(candidate.Elevation - elevation) < 1e-6) ?? Level.Create(doc, elevation);
                    level.Name = Text(levelSpec, "name");
                    Tag(level, Text(levelSpec, "id"));
                    levels.Add(Text(levelSpec, "id"), level);
                }
                lower = levels["FH-C-LEVEL-LOWER"];
                main = levels["FH-C-LEVEL-MAIN"];
                upper = levels["FH-C-LEVEL-UPPER"];
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                    .First(w => w.Kind == WallKind.Basic);
                void WallAtLevel(Level level, XYZ a, XYZ b, string id, double height)
                {
                    var w = Wall.Create(doc, Line.CreateBound(a,b), wallType.Id, level.Id, height, 0, false, false);
                    // Keep normal Revit end joins enabled. Suppressing joins leaves each
                    // wall's half-thickness protruding at loop corners and can create the
                    // exact highlighted-wall overlap warning this study is meant to expose.
                    Tag(w,id);
                }
                void WallPolygon(Level level, string markerPrefix, IReadOnlyList<XYZ> points, double height, IEnumerable<int>? skippedEdges = null, int markerOffset = 1)
                {
                    var skip = (skippedEdges ?? Array.Empty<int>()).ToHashSet();
                    for (int i=0;i<points.Count;i++)
                        if (!skip.Contains(i)) WallAtLevel(level, points[i], points[(i+1)%points.Count], $"{markerPrefix}-{i+markerOffset:00}", height);
                }
                var shellOrigin = Numbers(shellSpec, "main_origin_ft");
                double shellWidth = Number(shellSpec, "main_width_ft"), shellDepth = Number(shellSpec, "main_depth_ft");
                WallPolygon(levels[Text(shellSpec, "wall_level_id")], "FH-C-SHELL", new[] {
                    new XYZ(shellOrigin[0],shellOrigin[1],0), new XYZ(shellOrigin[0]+shellWidth,shellOrigin[1],0),
                    new XYZ(shellOrigin[0]+shellWidth,shellOrigin[1]+shellDepth,0), new XYZ(shellOrigin[0],shellOrigin[1]+shellDepth,0)
                }, Number(shellSpec, "wall_height_ft"));
                var liftOrigin = Numbers(liftSpec, "origin_ft");
                WallPolygon(levels[Text(liftSpec, "wall_level_id")], "FH-C-LIFT-RES", new[] {
                    new XYZ(liftOrigin[0],liftOrigin[1],0), new XYZ(liftOrigin[0]+liftWidth,liftOrigin[1],0),
                    new XYZ(liftOrigin[0]+liftWidth,liftOrigin[1]+liftDepth,0), new XYZ(liftOrigin[0],liftOrigin[1]+liftDepth,0)
                }, Number(liftSpec, "wall_height_ft"));
                var roomSpecs = config.GetProperty("room_specs").EnumerateArray().ToArray();
                foreach (var roomSpec in roomSpecs.Where(item => Text(item, "level_id") == "FH-C-LEVEL-MAIN"))
                {
                    var origin = Numbers(roomSpec, "origin_ft");
                    double width = Number(roomSpec, "width_ft"), depth = Number(roomSpec, "depth_ft");
                    var points = new[] { new XYZ(origin[0],origin[1],0), new XYZ(origin[0]+width,origin[1],0),
                        new XYZ(origin[0]+width,origin[1]+depth,0), new XYZ(origin[0],origin[1]+depth,0) };
                    var skipped = roomSpec.GetProperty("skipped_edges").EnumerateArray().Select(value => value.GetInt32());
                    WallPolygon(levels[Text(roomSpec, "level_id")], Text(roomSpec, "wall_marker"), points,
                        Number(roomSpec, "wall_height_ft"), skipped);
                }
                var rearOrigin = Numbers(shellSpec, "rear_origin_ft");
                double rearWidth = Number(shellSpec, "rear_width_ft"), rearDepth = Number(shellSpec, "rear_depth_ft");
                WallPolygon(levels[Text(shellSpec, "wall_level_id")], "FH-C-STACKED-SHELL", new[] {
                    new XYZ(rearOrigin[0],rearOrigin[1],0), new XYZ(rearOrigin[0]+rearWidth,rearOrigin[1],0),
                    new XYZ(rearOrigin[0]+rearWidth,rearOrigin[1]+rearDepth,0), new XYZ(rearOrigin[0],rearOrigin[1]+rearDepth,0)
                }, Number(shellSpec, "wall_height_ft"),
                    shellSpec.GetProperty("rear_skipped_edges").EnumerateArray().Select(value => value.GetInt32()));
                foreach (var roomSpec in roomSpecs.Where(item => Text(item, "level_id") != "FH-C-LEVEL-MAIN"))
                {
                    var origin = Numbers(roomSpec, "origin_ft");
                    double width = Number(roomSpec, "width_ft"), depth = Number(roomSpec, "depth_ft");
                    var points = new[] { new XYZ(origin[0],origin[1],0), new XYZ(origin[0]+width,origin[1],0),
                        new XYZ(origin[0]+width,origin[1]+depth,0), new XYZ(origin[0],origin[1]+depth,0) };
                    var skipped = roomSpec.GetProperty("skipped_edges").EnumerateArray().Select(value => value.GetInt32());
                    WallPolygon(levels[Text(roomSpec, "level_id")], Text(roomSpec, "wall_marker"), points,
                        Number(roomSpec, "wall_height_ft"), skipped);
                }
                foreach (var sharedWall in config.GetProperty("shared_walls").EnumerateArray())
                    WallAtLevel(levels[Text(sharedWall, "level_id")], Point3(sharedWall, "start_ft"), Point3(sharedWall, "end_ft"),
                        Text(sharedWall, "marker"), Number(sharedWall, "height_ft"));
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id); view.Name = "C Compact Core 3D";
                var planType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.FloorPlan);
                var mainPlan = ViewPlan.Create(doc, planType.Id, main.Id); mainPlan.Name = "C Main Room Blocks";
                var upperPlan = ViewPlan.Create(doc, planType.Id, upper.Id); upperPlan.Name = "C Upper Room Blocks";
                var lowerPlan = ViewPlan.Create(doc, planType.Id, lower.Id); lowerPlan.Name = "C Lower Room Blocks";
                foreach (var roomSpec in roomSpecs)
                {
                    var seed = Numbers(roomSpec, "room_seed_ft");
                    string id = Text(roomSpec, "id");
                    var room = doc.Create.NewRoom(levels[Text(roomSpec, "level_id")], new UV(seed[0],seed[1]));
                    room.Number = id; room.Name = Text(roomSpec, "name"); Tag(room,id);
                }
                door.Activate(); doc.Regenerate();
                Wall FindWall(string marker)
                {
                    var wall = new FilteredElementCollector(doc).OfClass(typeof(Wall)).Cast<Wall>()
                        .FirstOrDefault(w => w.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString() == marker);
                    if (wall is null) throw new InvalidOperationException("Door host wall not found: " + marker);
                    return wall;
                }
                void PlaceDoor(string marker, XYZ point, Level level, string id)
                {
                    var instance = doc.Create.NewFamilyInstance(point, door, FindWall(marker), level, StructuralType.NonStructural);
                    Tag(instance,id);
                }
                foreach (var doorSpec in config.GetProperty("doors").EnumerateArray())
                    PlaceDoor(Text(doorSpec, "wall_marker"), Point3(doorSpec, "point_ft"),
                        levels[Text(doorSpec, "level_id")], Text(doorSpec, "id"));
                var schedule = ViewSchedule.CreateSchedule(doc, new ElementId(BuiltInCategory.OST_Rooms)); schedule.Name = "C Room Area Schedule";
                var textType = new FilteredElementCollector(doc).OfClass(typeof(TextNoteType)).FirstElementId();
                ViewPlan PlanForLevel(Level level) => level.Id == lower.Id ? lowerPlan : level.Id == main.Id ? mainPlan : upperPlan;
                var overlays = config.GetProperty("overlays");
                var routeNote = overlays.GetProperty("route_note");
                TextNote.Create(doc, PlanForLevel(levels[Text(routeNote, "level_id")]).Id, Point3(routeNote, "point_ft"), Text(routeNote, "text"), textType);
                var sketchPlane = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, XYZ.Zero));
                void StudyLine(JsonElement spec)
                    => doc.Create.NewModelCurve(Line.CreateBound(Point3(spec, "start_ft"), Point3(spec, "end_ft")), sketchPlane);
                void StudyBox(JsonElement spec)
                {
                    var origin = Numbers(spec, "origin_ft");
                    double width = Number(spec, "width_ft"), depth = Number(spec, "depth_ft");
                    var points = new[] { new XYZ(origin[0],origin[1],0), new XYZ(origin[0]+width,origin[1],0),
                        new XYZ(origin[0]+width,origin[1]+depth,0), new XYZ(origin[0],origin[1]+depth,0) };
                    for (int i=0;i<points.Length;i++)
                        doc.Create.NewModelCurve(Line.CreateBound(points[i], points[(i+1)%points.Length]), sketchPlane);
                }
                foreach (var box in overlays.GetProperty("boxes").EnumerateArray()) StudyBox(box);
                foreach (var line in overlays.GetProperty("lines").EnumerateArray()) StudyLine(line);
                foreach (var note in overlays.GetProperty("plan_notes").EnumerateArray())
                    TextNote.Create(doc, PlanForLevel(levels[Text(note, "level_id")]).Id, Point3(note, "point_ft"), Text(note, "text"), textType);
                t.Commit();
            }
            foreach (var stairSpec in config.GetProperty("stairs").EnumerateArray())
            {
                using var scope = new StairsEditScope(doc, Text(stairSpec, "name"));
                var stairsId = scope.Start(levels[Text(stairSpec, "from_level_id")].Id, levels[Text(stairSpec, "to_level_id")].Id);
                using (var t = new Transaction(doc, Text(stairSpec, "transaction_name")))
                {
                    t.Start();
                    var stairs = (Stairs)doc.GetElement(stairsId);
                    stairs.DesiredRisersNumber = stairSpec.GetProperty("desired_risers").GetInt32();
                    var run = StairsRun.CreateStraightRun(doc, stairsId,
                        Line.CreateBound(Point3(stairSpec, "start_ft"), Point3(stairSpec, "end_ft")), StairsRunJustification.Center);
                    if (stairSpec.TryGetProperty("run_top_elevation_ft", out var topElevation))
                        run.TopElevation = topElevation.GetDouble();
                    t.Commit();
                }
                scope.Commit(new FailureRecorder());
                using (var t = new Transaction(doc, "Tag " + Text(stairSpec, "marker")))
                { t.Start(); Tag(doc.GetElement(stairsId), Text(stairSpec, "marker")); t.Commit(); }
            }
            var floorRows = new List<object>();
            using (var t = new Transaction(doc, "C provisional native floor plates"))
            {
                t.Start();
                var floorTypeId = Floor.GetDefaultFloorType(doc, false);
                if (floorTypeId == ElementId.InvalidElementId)
                    throw new InvalidOperationException("The Revit template has no default floor type.");
                var floorType = (FloorType)doc.GetElement(floorTypeId);
                var compound = floorType.GetCompoundStructure();
                double? typeThicknessFt = compound?.GetWidth();
                Floor AddPlate(Level level, string marker, double grossArea, double profileArea, params CurveLoop[] loops)
                {
                    var plate = Floor.Create(doc, loops, floorTypeId, level.Id);
                    Tag(plate, marker + " | PROVISIONAL | template floor type; no assembly selected");
                    floorRows.Add(new {
                        marker, level = level.Name, level_elevation_ft = level.Elevation,
                        gross_footprint_sqft = grossArea,
                        profile_area_sqft = profileArea,
                        floor_type = floorType.Name, template_type_thickness_ft = typeThicknessFt,
                        selected_assembly = false, finish_material_selected = false,
                        status = "schematic placeholder; verify profile and coordinate openings"
                    });
                    return plate;
                }
                foreach (var floorSpec in config.GetProperty("floors").EnumerateArray())
                {
                    var level = levels[Text(floorSpec, "level_id")];
                    var loops = floorSpec.GetProperty("loops").EnumerateArray()
                        .Select(points => ProfileLoop(level, points)).ToArray();
                    AddPlate(level, Text(floorSpec, "marker"), Number(floorSpec, "gross_footprint_sqft"),
                        Number(floorSpec, "profile_area_sqft"), loops);
                }
                var noteType = new FilteredElementCollector(doc).OfClass(typeof(TextNoteType)).FirstElementId();
                ViewPlan PlanFor(Level level) => new FilteredElementCollector(doc).OfClass(typeof(ViewPlan)).Cast<ViewPlan>().First(v => v.GenLevel?.Id == level.Id);
                foreach (var note in config.GetProperty("overlays").GetProperty("floor_notes").EnumerateArray())
                {
                    var level = levels[Text(note, "level_id")];
                    var point = Point3(note, "point_ft");
                    TextNote.Create(doc, PlanFor(level).Id, new XYZ(point.X, point.Y, level.Elevation), Text(note, "text"), noteType);
                }
                t.Commit();
            }
            string path = Path.Combine(output, "FH_Compact_Core_Study.rvt");
            var warningRecords = doc.GetWarnings().Select(w => new
            {
                severity = w.GetSeverity().ToString(),
                description = w.GetDescriptionText(),
                elements = w.GetFailingElements().Select(id =>
                {
                    var element = doc.GetElement(id);
                    return new
                    {
                        id = id.Value,
                        unique_id = element?.UniqueId,
                        category = element?.Category?.Name,
                        name = element?.Name,
                        marker = element?.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString()
                    };
                }).ToList()
            }).ToList();
            File.WriteAllText(Path.Combine(output, "study-warnings.json"),
                JsonSerializer.Serialize(warningRecords, new JsonSerializerOptions { WriteIndented = true }));
            doc.SaveAs(path, new SaveAsOptions());
            var modelFingerprint = SavedModelIdentity.Capture(doc);
            var manifest = new {
                status = "generated by Revit 2027 command; native verification required",
                study = studyName,
                config_schema = Text(config, "schema"),
                config_file = "compact-study-config.json",
                config_sha256 = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(configBytes)).ToLowerInvariant(),
                nominal_door_family = new {
                    width_ft = Number(doorFamilySpec, "width_ft"), depth_ft = Number(doorFamilySpec, "depth_ft"),
                    height_ft = Number(doorFamilySpec, "height_ft"),
                    clear_opening_selected = doorFamilySpec.GetProperty("clear_opening_selected").GetBoolean(),
                    status = Text(doorFamilySpec, "status")
                },
                rear_shell_skipped_edges = shellSpec.GetProperty("rear_skipped_edges").EnumerateArray().Select(value => value.GetInt32()).ToArray(),
                levels = config.GetProperty("levels").EnumerateArray().Select(item => new { id = Text(item,"id"), name = Text(item,"name"), elevation_ft = Number(item,"elevation_ft") }).ToArray(),
                shell = new { main_width_ft=Number(shellSpec,"main_width_ft"), main_depth_ft=Number(shellSpec,"main_depth_ft"), rear_width_ft=Number(shellSpec,"rear_width_ft"), rear_depth_ft=Number(shellSpec,"rear_depth_ft") },
                lift_reservation = new { width_ft=liftWidth, depth_ft=liftDepth, product_selected=false },
                rooms = config.GetProperty("rooms").EnumerateArray().Select(item => item.GetString()).ToArray(),
                doors = config.GetProperty("doors").EnumerateArray().Select(item => Text(item,"id")).ToArray(),
                floors = floorRows,
                floor_assembly_assumption = config.GetProperty("floor_assembly_assumption"),
                roof = config.GetProperty("roof"),
                stair_floor_coordination = config.GetProperty("stair_floor_coordination"),
                unresolved = config.GetProperty("unresolved"),
                model_fingerprint = modelFingerprint,
                source_rvt = path
            };
            File.WriteAllText(Path.Combine(output, "study-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented=true }));
            var floorCsv = new List<string> { "marker,level,level_elevation_ft,gross_footprint_sqft,profile_area_sqft,template_floor_type,template_type_thickness_ft,selected_assembly,finish_material_selected,status" };
            foreach (dynamic row in floorRows)
                floorCsv.Add(string.Join(",", new[] {
                    Csv((string)row.marker), Csv((string)row.level), ((double)row.level_elevation_ft).ToString("0.###", CultureInfo.InvariantCulture),
                    ((double)row.gross_footprint_sqft).ToString("0.##", CultureInfo.InvariantCulture),
                    ((double)row.profile_area_sqft).ToString("0.##", CultureInfo.InvariantCulture),
                    Csv((string)row.floor_type), ((double?)row.template_type_thickness_ft)?.ToString("0.###", CultureInfo.InvariantCulture) ?? "",
                    "false", "false", Csv((string)row.status)
                }));
            File.WriteAllLines(Path.Combine(output, "floor-assembly-schedule.csv"), floorCsv);
            doc.Close(false);
            data.Application.OpenAndActivateDocument(path);
            TaskDialog.Show("Forever Home compact core", "C study saved separately with three provisional native floor plates. Assembly selection and stair/upper landing coordination remain open.\n" + path);
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.Message; return Result.Failed; }
    }
}

[Transaction(TransactionMode.Manual)]
public class Command : IExternalCommand
{
    // The adjacent marker is generated by build.ps1; no machine path is committed.
    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(
            Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
        string output = Path.Combine(root, ".local", "revit-pilot", "runs",
            DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
        Directory.CreateDirectory(output);
        try
        {
            Run(data.Application, output);
            TaskDialog.Show("Forever Home pilot", "Pilot finished. See run.json and exports under:\n" + output);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            File.WriteAllText(Path.Combine(output, "failure.txt"), ex.ToString());
            message = "Pilot failed; diagnostic saved under " + output + "\n" + ex.Message;
            return Result.Failed;
        }
    }

    static void Tag(Element e, string id)
    {
        var p = e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (p is null || p.IsReadOnly) throw new InvalidOperationException("Cannot tag " + id);
        p.Set(id);
    }

    internal static FamilySymbol MakeFamily(Autodesk.Revit.ApplicationServices.Application app,
        Document project, string output, string template, string name, double w, double d, double h)
    {
        string templates = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData),
            "Autodesk", "RVT 2027", "Family Templates", "English-Imperial");
        var familyDoc = app.NewFamilyDocument(Path.Combine(templates, template));
        try
        {
            using (var t = new Transaction(familyDoc, "Pilot fixture geometry"))
            {
                t.Start();
                familyDoc.FamilyManager.NewType("Pilot fixture only");
                var profile = new CurveArray();
                var pts = new[] {new XYZ(-w/2, -d/2, 0), new XYZ(w/2, -d/2, 0),
                    new XYZ(w/2, d/2, 0), new XYZ(-w/2, d/2, 0)};
                for (int i = 0; i < 4; i++) profile.Append(Line.CreateBound(pts[i], pts[(i+1)%4]));
                var loops = new CurveArrArray(); loops.Append(profile);
                var plane = SketchPlane.Create(familyDoc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, XYZ.Zero));
                familyDoc.FamilyCreate.NewExtrusion(true, loops, plane, h);
                t.Commit();
            }
            familyDoc.SaveAs(Path.Combine(output, name + ".rfa"), new SaveAsOptions());
            Family family = familyDoc.LoadFamily(project);
            return (FamilySymbol)project.GetElement(family.GetFamilySymbolIds().First());
        }
        finally { familyDoc.Close(false); }
    }

    static void Run(UIApplication ui, string output)
    {
        var app = ui.Application;
        var doc = app.NewProjectDocument(UnitSystem.Imperial);
        var exportResults = new Dictionary<string, object>();
        var tagged = new List<(string id, Element element)>();
        Level lower, upper;
        ViewPlan plan;
        View3D view3d;
        try
        {
            var door = MakeFamily(app, doc, output, "Door.rft", "FH_Pilot_Door", 3, .15, 7);
            var window = MakeFamily(app, doc, output, "Window.rft", "FH_Pilot_Window", 3, .15, 3);
            var equipment = MakeFamily(app, doc, output, "Mechanical Equipment.rft", "FH_Pilot_Equipment", 2, 2, 3);
            using (var t = new Transaction(doc, "Build compatibility fixture; not house design"))
            {
                t.Start();
                lower = Level.Create(doc, 0); lower.Name = "PILOT Lower 0 ft";
                upper = Level.Create(doc, 10); upper.Name = "PILOT Upper 10 ft";
                var floorPlanType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType))
                    .Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.FloorPlan);
                plan = ViewPlan.Create(doc, floorPlanType.Id, lower.Id); plan.Name = "PILOT Fixture Plan";
                plan.Scale = 48;
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType))
                    .Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                view3d = View3D.CreateIsometric(doc, viewType.Id); view3d.Name = "PILOT Fixture 3D";
                // Default level datums otherwise dominate the uncropped PDF extents.
                view3d.SetCategoryHidden(new ElementId(BuiltInCategory.OST_Levels), true);
                view3d.SetSectionBox(new BoundingBoxXYZ { Min=new XYZ(-1,-1,-1),Max=new XYZ(34,20,14) });
                view3d.IsSectionBoxActive=true;
                view3d.SetCategoryHidden(new ElementId(BuiltInCategory.OST_SectionBox), true);
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                    .First(w => w.Kind == WallKind.Basic);
                var pts = new[] {XYZ.Zero, new XYZ(24,0,0),new XYZ(24,18,0),new XYZ(0,18,0)};
                var walls = new List<Wall>();
                for (int i=0;i<4;i++)
                {
                    var wall = Wall.Create(doc,Line.CreateBound(pts[i],pts[(i+1)%4]),wallType.Id,lower.Id,10,0,false,false);
                    string id = $"FH-PILOT-WALL-{i+1:00}"; Tag(wall,id); tagged.Add((id,wall)); walls.Add(wall);
                }
                door.Activate(); window.Activate(); equipment.Activate(); doc.Regenerate();
                var doorInstance = doc.Create.NewFamilyInstance(new XYZ(6,0,0),door,walls[0],lower,StructuralType.NonStructural);
                var windowInstance = doc.Create.NewFamilyInstance(new XYZ(16,0,3),window,walls[0],lower,StructuralType.NonStructural);
                var equipInstance = doc.Create.NewFamilyInstance(new XYZ(4,5,0),equipment,lower,StructuralType.NonStructural);
                foreach (var item in new[] {("FH-PILOT-DOOR-01",doorInstance), ("FH-PILOT-WINDOW-01",windowInstance),
                    ("FH-PILOT-EQUIPMENT-01",equipInstance)})
                { Tag(item.Item2,item.Item1); tagged.Add((item.Item1,item.Item2)); }
                doc.Regenerate();
                var room = doc.Create.NewRoom(lower,new UV(12,9)); room.Number="FH-PILOT-ROOM-01"; room.Name="Compatibility fixture";
                Tag(room,room.Number); tagged.Add((room.Number,room));
                var textType = new FilteredElementCollector(doc).OfClass(typeof(TextNoteType)).FirstElementId();
                TextNote.Create(doc,plan.Id,new XYZ(0,21,0),
                    "COMPATIBILITY FIXTURE ONLY - NOT HOUSE DESIGN\n24 x 18 ft wall centerlines; 10 ft level rise; separate stair\nDoor, window, room and equipment are test objects",textType);
                doc.Regenerate();
                if (room.Area <= 0) throw new InvalidOperationException("Pilot room not enclosed");
                if (doorInstance.Host.Id != walls[0].Id || windowInstance.Host.Id != walls[0].Id)
                    throw new InvalidOperationException("Opening fixtures lost host");
                t.Commit();
            }
            var warnings = new FailureRecorder();
            using (var scope = new StairsEditScope(doc,"Pilot stair"))
            {
                var stairsId = scope.Start(lower.Id,upper.Id);
                using(var t = new Transaction(doc,"Pilot stair run"))
                {
                    t.Start();
                    StairsRun.CreateStraightRun(doc,stairsId,
                        Line.CreateBound(new XYZ(30,0,0),new XYZ(30,16,0)),StairsRunJustification.Center);
                    t.Commit();
                }
                scope.Commit(warnings);
                using(var t = new Transaction(doc,"Tag pilot stair"))
                {
                    t.Start(); var stair = doc.GetElement(stairsId); Tag(stair,"FH-PILOT-STAIR-01");
                    tagged.Add(("FH-PILOT-STAIR-01",stair)); t.Commit();
                }
            }
            var records = tagged.Select(x => new {
                id=x.id, unique_id=x.element.UniqueId, category=x.element.Category?.Name,
                name=x.element.Name, host_unique_id=(x.element as FamilyInstance)?.Host?.UniqueId,
                room_area_sf=(x.element as Room)?.Area
            }).ToList();
            string source = Path.Combine(output,"FH_Compatibility_Pilot.rvt");
            doc.SaveAs(source,new SaveAsOptions());
            // Export failures are independent and explicit; a partial run never means all exports passed.
            void Export(string name, Func<bool> action)
            {
                try { exportResults[name] = new { success=action() }; }
                catch(Exception ex) { exportResults[name] = new { success=false,error=ex.Message }; }
            }
            Export("ifc2x3", () => {
                using var t = new Transaction(doc,"IFC export"); t.Start();
                var options = new IFCExportOptions { FileVersion=IFCVersion.IFC2x3CV2,ExportBaseQuantities=true };
                options.AddOption("ExportInternalRevitPropertySets","true");
                bool ok=doc.Export(output,"FH_Compatibility_Pilot",options); t.RollBack(); return ok;
            });
            Export("dwg", () => doc.Export(output,"FH_Compatibility_Pilot",new List<ElementId>{plan.Id},
                new DWGExportOptions { FileVersion=ACADVersion.R2010,MergedViews=true }));
            Export("pdf", () => doc.Export(output,new List<ElementId>{plan.Id,view3d.Id},
                new PDFExportOptions { Combine=true,FileName="FH_Compatibility_Pilot" }));
            File.WriteAllText(Path.Combine(output,"elements.json"),JsonSerializer.Serialize(records,JsonOptions));
            static string Csv(string? value) => "\""+(value??"").Replace("\"","\"\"")+"\"";
            File.WriteAllLines(Path.Combine(output,"elements.csv"),new[]{"id,unique_id,category,name,host_unique_id,room_area_sf"}
                .Concat(records.Select(r=>string.Join(",",Csv(r.id),Csv(r.unique_id),Csv(r.category),Csv(r.name),
                    Csv(r.host_unique_id),Csv(r.room_area_sf?.ToString(System.Globalization.CultureInfo.InvariantCulture))))));
            exportResults["csv"] = new {success=true};
            string backup = Path.Combine(output,"backup","FH_Compatibility_Pilot.rvt");
            Directory.CreateDirectory(Path.GetDirectoryName(backup)!);
            doc.SaveAs(backup,new SaveAsOptions());
            doc.Close(false);
            // Reopen both archives and confirm every fixture's stable identity survived.
            var reopen = new Dictionary<string,bool>();
            foreach(var path in new[]{source,backup})
            {
                var check=app.OpenDocumentFile(path);
                try { reopen[path==source?"source":"backup"] = records.All(r=>check.GetElement(r.unique_id)!=null); }
                finally { check.Close(false); }
            }
            File.WriteAllText(Path.Combine(output,"run.json"),JsonSerializer.Serialize(new {
                status="executed; review per-export results", utc=DateTime.UtcNow,
                revit_version=app.VersionNumber,revit_build=app.VersionBuild,
                fixture_only=true, element_count=records.Count, exports=exportResults,
                reopen_checks=reopen, warnings=warnings.Messages,
                compatibility_2018="not tested", design_or_code_validation="not performed"
            },JsonOptions));
            ui.OpenAndActivateDocument(source);
        }
        catch { if(doc.IsValidObject && !doc.IsLinked) { try { doc.Close(false); } catch { } } throw; }
    }
    static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented=true };
}

class FailureRecorder : IFailuresPreprocessor
{
    public List<string> Messages {get;} = new();
    public FailureProcessingResult PreprocessFailures(FailuresAccessor failures)
    {
        foreach(var failure in failures.GetFailureMessages())
        {
            Messages.Add(failure.GetDescriptionText());
            if(failure.GetSeverity()==FailureSeverity.Warning) failures.DeleteWarning(failure);
        }
        return FailureProcessingResult.Continue;
    }
}
