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

public class App : IExternalApplication
{
    public Result OnStartup(UIControlledApplication app)
    {
        var panel = app.CreateRibbonPanel("Forever Home Pilot");
        panel.AddItem(new PushButtonData("FHCompatibilityPilot", "Run compatibility\npilot",
            Assembly.GetExecutingAssembly().Location, typeof(Command).FullName!));
        panel.AddItem(new PushButtonData("FHCompactCoreStudy", "Build compact core\nstudy",
            Assembly.GetExecutingAssembly().Location, typeof(CompactCoreCommand).FullName!));
        panel.AddItem(new PushButtonData("FHFamilyIntake", "Run family intake\ntest",
            Assembly.GetExecutingAssembly().Location, typeof(FamilyIntakeCommand).FullName!));
        panel.AddItem(new PushButtonData("FHApiAudit", "Audit active\ndocument",
            Assembly.GetExecutingAssembly().Location, typeof(ApiAuditCommand).FullName!));
        panel.AddItem(new PushButtonData("FHGeometryQa", "Run geometry\nQA",
            Assembly.GetExecutingAssembly().Location, typeof(GeometryQaCommand).FullName!));
        panel.AddItem(new PushButtonData("FHManifestExports", "Run manifest\nexports",
            Assembly.GetExecutingAssembly().Location, typeof(ManifestExportCommand).FullName!));
        return Result.Succeeded;
    }
    public Result OnShutdown(UIControlledApplication app) => Result.Succeeded;
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
                schema = "forever-home.revit-api-audit.v1",
                status = "executed; read-only active-document audit",
                utc = DateTime.UtcNow,
                revit_version = data.Application.Application.VersionNumber,
                revit_build = data.Application.Application.VersionBuild,
                document_title = doc.Title,
                document_path_recorded = false,
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
                    "Document path is intentionally not written to the report.",
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
            string manifestPath = Path.Combine(root, "Tools", "RevitPilot", "export-manifest.json");
            using var manifest = JsonDocument.Parse(File.ReadAllText(manifestPath));
            var config = manifest.RootElement;
            if (config.GetProperty("schema").GetString() != "forever-home.revit-export-manifest.v1")
                throw new InvalidDataException("Unsupported export manifest schema.");
            string expectedTitle = config.GetProperty("expected_document_title").GetString() ?? "";
            if (!string.Equals(doc.Title, expectedTitle, StringComparison.Ordinal))
                throw new InvalidOperationException($"Manifest expects active document '{expectedTitle}', but the active document is '{doc.Title}'. No exports were run.");

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
            var report = new
            {
                schema = "forever-home.revit-export-results.v1",
                status = allPassed ? "executed; all configured exports produced nonempty files" : "executed; one or more exports failed",
                utc = DateTime.UtcNow,
                revit_version = data.Application.Application.VersionNumber,
                revit_build = data.Application.Application.VersionBuild,
                document_title = doc.Title,
                document_path_recorded = false,
                manifest = "Tools/RevitPilot/export-manifest.json",
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

            var report = new
            {
                schema = "forever-home.revit-geometry-qa.v1",
                status = "executed; read-only active-document geometry and coordination QA",
                utc = DateTime.UtcNow,
                revit_version = data.Application.Application.VersionNumber,
                revit_build = data.Application.Application.VersionBuild,
                document_title = doc.Title,
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
                try
                {
                    var familyName = Path.GetFileNameWithoutExtension(path);
                    Family? family = null;
                    bool loaded;
                    using (var t = new Transaction(target, $"Load intake family {familyName}"))
                    {
                        t.Start();
                        loaded = target.LoadFamily(path, out family);
                        t.Commit();
                    }
                    var symbols = family is null ? new List<string>() : family.GetFamilySymbolIds()
                        .Select(id => target.GetElement(id)?.Name ?? id.Value.ToString()).ToList();
                    results.Add(new { file = Path.GetFileName(path), status = loaded ? "loaded" : "already_present", family = family?.Name, symbols });
                }
                catch (Exception ex)
                {
                    results.Add(new { file = Path.GetFileName(path), status = "failed", error = ex.Message });
                }
                finally { }
            }
            var study = Path.Combine(output, "FH_Family_Intake_Study.rvt");
            target.SaveAs(study, new SaveAsOptions());
            File.WriteAllText(Path.Combine(output, "intake-manifest.json"), JsonSerializer.Serialize(new
            {
                status = "executed; review family load results and placement behavior separately",
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
public class CompactCoreCommand : IExternalCommand
{
    static void Tag(Element e, string id)
    {
        var p = e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (p is not null && !p.IsReadOnly) p.Set(id);
    }

    static CurveLoop ProfileLoop(Level level, params (double X, double Y)[] points)
    {
        var loop = new CurveLoop();
        for (int i = 0; i < points.Length; i++)
        {
            var a = points[i]; var b = points[(i + 1) % points.Length];
            loop.Append(Line.CreateBound(new XYZ(a.X, a.Y, level.Elevation), new XYZ(b.X, b.Y, level.Elevation)));
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
            var door = Command.MakeFamily(data.Application.Application, doc, output, "Door.rft", "FH_C_Nominal_Door", 3, .15, 7);
            Level lower, main, upper;
            using (var t = new Transaction(doc, "C compact core study; proposal only"))
            {
                t.Start();
                lower = Level.Create(doc, -5); lower.Name = "C Lower -5 ft";
                // NewProjectDocument starts from a template that already has a level at
                // 0 ft. Reuse it as the study's main datum instead of creating a duplicate.
                main = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>()
                    .FirstOrDefault(level => Math.Abs(level.Elevation) < 1e-6) ?? Level.Create(doc, 0);
                main.Name = "C Main 0 ft";
                upper = Level.Create(doc, 5); upper.Name = "C Upper +5 ft";
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                    .First(w => w.Kind == WallKind.Basic);
                void WallAtLevel(Level level, XYZ a, XYZ b, string id, double height = 10)
                {
                    var w = Wall.Create(doc, Line.CreateBound(a,b), wallType.Id, level.Id, height, 0, false, false);
                    // Keep normal Revit end joins enabled. Suppressing joins leaves each
                    // wall's half-thickness protruding at loop corners and can create the
                    // exact highlighted-wall overlap warning this study is meant to expose.
                    Tag(w,id);
                }
                void WallAt(XYZ a, XYZ b, string id) => WallAtLevel(main,a,b,id);
                void RoomBoxAt(Level level, string id, double x, double y, double width, double depth, params int[] skippedEdges)
                {
                    var pts = new[] { new XYZ(x,y,0), new XYZ(x+width,y,0), new XYZ(x+width,y+depth,0), new XYZ(x,y+depth,0) };
                    var skip = skippedEdges.ToHashSet();
                    for (int i=0;i<4;i++)
                        if (!skip.Contains(i)) WallAtLevel(level,pts[i],pts[(i+1)%4],$"FH-C-{id}-{i+1:00}");
                }
                var shell = new[] { new XYZ(0,0,0), new XYZ(40,0,0), new XYZ(40,40,0), new XYZ(0,40,0) };
                // Span the main shell from the lower datum so its rear wall can serve as
                // the shared boundary for the stacked rear envelope. This avoids creating
                // a second coincident wall along the y=40 seam.
                for (int i=0;i<4;i++) WallAtLevel(lower, shell[i], shell[(i+1)%4], $"FH-C-SHELL-{i+1:00}", 20);
                var core = new[] { new XYZ(21.5,30.5,0), new XYZ(29.5,30.5,0), new XYZ(29.5,38.5,0), new XYZ(21.5,38.5,0) };
                for (int i=0;i<4;i++) WallAt(core[i],core[(i+1)%4],$"FH-C-LIFT-RES-{i+1:00}");
                void RoomBox(string id, double x, double y, double width, double depth)
                {
                    var pts = new[] { new XYZ(x,y,0), new XYZ(x+width,y,0), new XYZ(x+width,y+depth,0), new XYZ(x,y+depth,0) };
                    for (int i=0;i<4;i++) WallAt(pts[i],pts[(i+1)%4],$"FH-C-{id}-{i+1:00}");
                }
                RoomBox("M-01-LIVING", 1, 1, 16, 15);
                RoomBox("M-02-KITCHEN", 22, 1, 17, 16);
                RoomBox("M-03-DINING", 1, 17, 11, 13.5);
                RoomBox("M-06-MAIN-BATH", 30.5, 27, 8, 10);
                RoomBox("L-02-MAIN-FLEX", 1, 31.5, 11, 7.5);
                var stackedShell = new[] { new XYZ(0,40,0), new XYZ(36,40,0), new XYZ(36,72,0), new XYZ(0,72,0) };
                // The lower and upper study envelopes share the same XY shell. Build one
                // continuous 20 ft wall loop from the lower datum instead of two coincident
                // wall loops meeting at the upper datum; the latter triggers Revit's
                // highlighted-wall overlap warning and can make room-boundary resolution
                // ambiguous.
                // The first stacked edge is the main shell's shared rear wall; do not
                // create a duplicate wall over that same line.
                for (int i=1;i<4;i++)
                    WallAtLevel(lower, stackedShell[i], stackedShell[(i+1)%4], $"FH-C-STACKED-SHELL-{i+1:00}", 20);
                RoomBoxAt(upper,"U-01-PRIMARY", 1,41,16,10);
                RoomBoxAt(upper,"U-05-PRIMARY-BATH", 1,52,9,10);
                RoomBoxAt(upper,"U-02-BOUTIQUE", 1,63,16,8);
                RoomBoxAt(upper,"U-04-GUEST", 18,41,12,8.5);
                // Use one shared divider instead of two near-coincident wall segments.
                // This preserves both room envelopes while avoiding ambiguous room-boundary
                // resolution at the Jack-and-Jill / hybrid-room seam.
                RoomBoxAt(upper,"U-06-JACK-JILL", 25,50.5,10,12, 2);
                RoomBoxAt(upper,"U-03-HYBRID", 18,63.5,13,7.5, 0);
                WallAtLevel(upper, new XYZ(18,62.25,0), new XYZ(35,62.25,0), "FH-C-U-06-U-03-SHARED-DIVIDER");
                RoomBoxAt(lower,"L-03-LOWER-BATH", 1,41,9,10);
                RoomBoxAt(lower,"L-04-LAUNDRY", 1,52,9,8);
                RoomBoxAt(lower,"L-05-MEP", 1,61,9,9);
                RoomBoxAt(lower,"L-07-ARRIVAL", 26,41,9,11.5);
                RoomBoxAt(lower,"L-01-FLEX-LIVING", 11,53,13,18);
                RoomBoxAt(lower,"L-06-TECH-RELOCATED", 26,63,8,8);
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id); view.Name = "C Compact Core 3D";
                var planType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(v => v.ViewFamily == ViewFamily.FloorPlan);
                var mainPlan = ViewPlan.Create(doc, planType.Id, main.Id); mainPlan.Name = "C Main Room Blocks";
                var upperPlan = ViewPlan.Create(doc, planType.Id, upper.Id); upperPlan.Name = "C Upper Room Blocks";
                var lowerPlan = ViewPlan.Create(doc, planType.Id, lower.Id); lowerPlan.Name = "C Lower Room Blocks";
                void RoomAt(Level level, string id, string name, double x, double y)
                {
                    var room = doc.Create.NewRoom(level, new UV(x,y));
                    room.Number = id; room.Name = name; Tag(room,id);
                }
                RoomAt(main,"M-01","Living room",9,8);
                RoomAt(main,"M-02","Kitchen",30,9);
                RoomAt(main,"M-03","Dining",6,23);
                RoomAt(main,"M-06","Proposed main full bath",34,32);
                RoomAt(main,"L-02","Main flex sleeping room",6,35);
                RoomAt(upper,"U-01","Primary bedroom",9,46);
                RoomAt(upper,"U-05","Primary bath",5,57);
                RoomAt(upper,"U-02","Boutique",9,67);
                RoomAt(upper,"U-04","Guest bedroom",24,45);
                RoomAt(upper,"U-06","Jack and Jill bath",30,56);
                RoomAt(upper,"U-03","Hybrid bedroom office",24,67);
                RoomAt(lower,"L-03","Lower full bath",5,46);
                RoomAt(lower,"L-04","Laundry",5,56);
                RoomAt(lower,"L-05","MEP reservation",5,65);
                RoomAt(lower,"L-07","Arrival and dry storage",30,46);
                RoomAt(lower,"L-01","Lower flexible living",17,62);
                RoomAt(lower,"L-06","Relocated technology room",30,67);
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
                PlaceDoor("FH-C-SHELL-01", new XYZ(6,0,0), main, "D-MAIN-ENTRY");
                PlaceDoor("FH-C-M-06-MAIN-BATH-01", new XYZ(34,27,0), main, "D-MAIN-BATH");
                PlaceDoor("FH-C-L-02-MAIN-FLEX-01", new XYZ(6,31.5,0), main, "D-MAIN-FLEX");
                PlaceDoor("FH-C-U-05-PRIMARY-BATH-01", new XYZ(5,52,0), upper, "D-PRIMARY-BATH");
                PlaceDoor("FH-C-L-06-TECH-RELOCATED-01", new XYZ(30,63,0), lower, "D-TECH-SERVICE");
                var schedule = ViewSchedule.CreateSchedule(doc, new ElementId(BuiltInCategory.OST_Rooms)); schedule.Name = "C Room Area Schedule";
                var textType = new FilteredElementCollector(doc).OfClass(typeof(TextNoteType)).FirstElementId();
                TextNote.Create(doc, mainPlan.Id, new XYZ(14,20,0), "C route test: entry > living > kitchen > dining > main bath > main flex\nNominal doors only; clearances, swings and accessibility remain unverified.", textType);
                var sketchPlane = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, XYZ.Zero));
                void StudyLine(double x1, double y1, double x2, double y2)
                { doc.Create.NewModelCurve(Line.CreateBound(new XYZ(x1,y1,0), new XYZ(x2,y2,0)), sketchPlane); }
                void StudyBox(double x, double y, double width, double depth)
                { StudyLine(x,y,x+width,y); StudyLine(x+width,y,x+width,y+depth); StudyLine(x+width,y+depth,x,y+depth); StudyLine(x,y+depth,x,y); }
                StudyBox(26.5,7,8,4);     // appliance-free island
                StudyLine(22,2,39,2);      // perimeter counter run
                StudyBox(4,20,5,3);        // dining table
                StudyBox(2,3,4,7);         // TV/service envelope
                StudyBox(12,2,5,5);        // hearth envelope
                StudyBox(7,10,6,3);        // loveseat envelope
                StudyBox(31,28,5,1.8);     // main-bath vanity
                StudyBox(30.5,35,5,3);     // main-bath shower
                StudyBox(36,35,1.5,2.5);   // main-bath toilet
                TextNote.Create(doc, mainPlan.Id, new XYZ(23,6,0), "8 x 4 island | appliance-free", textType);
                TextNote.Create(doc, mainPlan.Id, new XYZ(2,19,0), "5 x 3 dining table | 4 ft porch lane target", textType);
                TextNote.Create(doc, mainPlan.Id, new XYZ(2,2,0), "TV/service 4 x 7 | hearth 5 x 5 | furniture placeholders", textType);
                TextNote.Create(doc, mainPlan.Id, new XYZ(30,27,0), "M-06 nominal fixtures | turn/approach/door checks pending", textType);
                Tag(lower,"FH-C-LEVEL-LOWER"); Tag(main,"FH-C-LEVEL-MAIN"); Tag(upper,"FH-C-LEVEL-UPPER");
                t.Commit();
            }
            using (var scope = new StairsEditScope(doc, "C compact core native stairs"))
            {
                var stairsId = scope.Start(lower.Id, main.Id);
                using (var t = new Transaction(doc, "C lower-to-main stair run"))
                { t.Start(); var stairs = (Stairs)doc.GetElement(stairsId); var run = StairsRun.CreateStraightRun(doc, stairsId, Line.CreateBound(new XYZ(12.5,27,-5), new XYZ(12.5,36,-5)), StairsRunJustification.Center); stairs.DesiredRisersNumber = 10; run.TopElevation = 5; t.Commit(); }
                scope.Commit(new FailureRecorder());
                using (var t = new Transaction(doc, "Tag C lower stair")) { t.Start(); Tag(doc.GetElement(stairsId),"FH-C-STAIR-LOWER-MAIN"); t.Commit(); }
            }
            using (var scope = new StairsEditScope(doc, "C compact core upper stairs"))
            {
                var stairsId = scope.Start(main.Id, upper.Id);
                using (var t = new Transaction(doc, "C main-to-upper stair run"))
                { t.Start(); var stairs = (Stairs)doc.GetElement(stairsId); stairs.DesiredRisersNumber = 9; StairsRun.CreateStraightRun(doc, stairsId, Line.CreateBound(new XYZ(17,27,0), new XYZ(17,34,0)), StairsRunJustification.Center); t.Commit(); }
                scope.Commit(new FailureRecorder());
                using (var t = new Transaction(doc, "Tag C upper stair")) { t.Start(); Tag(doc.GetElement(stairsId),"FH-C-STAIR-MAIN-UPPER"); t.Commit(); }
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
                AddPlate(lower, "FH-C-FLOOR-LOWER", 2752, 2752,
                    ProfileLoop(lower, (0,0),(40,0),(40,40),(36,40),(36,72),(0,72),(0,40)));
                AddPlate(main, "FH-C-FLOOR-MAIN", 1600, 1410,
                    ProfileLoop(main, (0,0),(40,0),(40,40),(0,40)),
                    ProfileLoop(main, (10.5,24.5),(19.5,24.5),(19.5,38.5),(10.5,38.5)),
                    ProfileLoop(main, (21.5,30.5),(29.5,30.5),(29.5,38.5),(21.5,38.5)));
                AddPlate(upper, "FH-C-FLOOR-UPPER", 1152, 1152,
                    ProfileLoop(upper, (0,40),(36,40),(36,72),(0,72)));
                var noteType = new FilteredElementCollector(doc).OfClass(typeof(TextNoteType)).FirstElementId();
                ViewPlan PlanFor(Level level) => new FilteredElementCollector(doc).OfClass(typeof(ViewPlan)).Cast<ViewPlan>().First(v => v.GenLevel?.Id == level.Id);
                TextNote.Create(doc, PlanFor(lower).Id, new XYZ(2,69,lower.Elevation),
                    "PROVISIONAL FLOOR PLATE | template type only | assembly, foundation and lift pit not selected", noteType);
                TextNote.Create(doc, PlanFor(main).Id, new XYZ(1,39,main.Elevation),
                    "PROVISIONAL FLOOR PLATE | stair and 8 x 8 lift openings are coordination envelopes; verify edges, landings and structure", noteType);
                TextNote.Create(doc, PlanFor(upper).Id, new XYZ(1,69,upper.Elevation),
                    "PROVISIONAL FLOOR PLATE | template type only | upper stair landing does not reach this rear-wing footprint", noteType);
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
            var manifest = new {
                status = "generated by Revit 2027 command; native verification required",
                study = "C compact core",
                levels = new[] { new { id="FH-C-LEVEL-LOWER", elevation_ft=-5 }, new { id="FH-C-LEVEL-MAIN", elevation_ft=0 }, new { id="FH-C-LEVEL-UPPER", elevation_ft=5 } },
                shell = new { main_width_ft=40, main_depth_ft=40, rear_width_ft=36, rear_depth_ft=32 },
                lift_reservation = new { width_ft=8, depth_ft=8, product_selected=false },
                rooms = new[] { "M-01","M-02","M-03","M-06","L-02","U-01","U-02","U-03","U-04","U-05","U-06","L-01","L-03","L-04","L-05","L-06","L-07" },
                doors = new[] { "D-MAIN-ENTRY","D-MAIN-BATH","D-MAIN-FLEX","D-PRIMARY-BATH","D-TECH-SERVICE" },
                floors = floorRows,
                floor_assembly_assumption = new { planning_placeholder_thickness_ft = 1.25, is_selected_assembly = false, source = "15 in arithmetic placeholder in compact-core brief; not the modeled Revit type" },
                roof = new { status = "not modeled", reason = "roof form, pitch, site response and structure have no approved model input" },
                stair_floor_coordination = new { status = "open", issue = "C main-to-upper stair terminates at y=34 ft, while upper floor plate begins at y=40 ft; provide a connected landing and resolve the upper-level circulation footprint" },
                unresolved = new[] { "floor type and layered assemblies unselected", "stair and lift opening dimensions and supporting structure", "upper stair landing disconnected from upper plate", "lower foundation and lift pit", "roof form, pitch and site response", "door clear openings and swings", "stair headroom", "lift product fit", "full accessibility route", "structure and MEP coordination", "code review" },
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
