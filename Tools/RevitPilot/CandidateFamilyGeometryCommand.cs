using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class CandidateFamilyGeometryCommand : IExternalCommand
{
    private sealed record Request(string family_path, string expected_sha256, string output_directory);
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private static string Sha256(string path)
    {
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
        return Convert.ToHexString(SHA256.HashData(stream)).ToLowerInvariant();
    }

    private static bool IsWithinDirectory(string path, string directory)
    {
        var normalizedDirectory = Path.GetFullPath(directory).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
            + Path.DirectorySeparatorChar;
        return Path.GetFullPath(path).StartsWith(normalizedDirectory, StringComparison.OrdinalIgnoreCase);
    }

    private static string? ParameterValue(Parameter parameter) => parameter.StorageType switch
    {
        StorageType.Double => parameter.AsValueString() ?? parameter.AsDouble().ToString("G17", CultureInfo.InvariantCulture),
        StorageType.Integer => parameter.AsValueString() ?? parameter.AsInteger().ToString(CultureInfo.InvariantCulture),
        StorageType.String => parameter.AsString(),
        StorageType.ElementId => parameter.AsValueString() ?? parameter.AsElementId().Value.ToString(CultureInfo.InvariantCulture),
        _ => null
    };

    private sealed record SolidMetrics(XYZ? Min, XYZ? Max, int SolidCount, double VolumeFt3, int BoundingBoxCornerCount);

    private static SolidMetrics Measure(GeometryElement geometry)
    {
        var solidCount = 0;
        var volume = 0.0;
        var boundingBoxCornerCount = 0;
        var minX = double.PositiveInfinity; var minY = double.PositiveInfinity; var minZ = double.PositiveInfinity;
        var maxX = double.NegativeInfinity; var maxY = double.NegativeInfinity; var maxZ = double.NegativeInfinity;

        void Include(XYZ point)
        {
            if (!double.IsFinite(point.X) || !double.IsFinite(point.Y) || !double.IsFinite(point.Z)) return;
            minX = Math.Min(minX, point.X); minY = Math.Min(minY, point.Y); minZ = Math.Min(minZ, point.Z);
            maxX = Math.Max(maxX, point.X); maxY = Math.Max(maxY, point.Y); maxZ = Math.Max(maxZ, point.Z);
            boundingBoxCornerCount++;
        }

        void Visit(GeometryElement current, Transform parent)
        {
            foreach (GeometryObject item in current)
            {
                if (item is Solid solid && double.IsFinite(solid.Volume) && solid.Volume > 1e-9)
                {
                    solidCount++;
                    volume += solid.Volume;
                    var solidBox = solid.GetBoundingBox();
                    var boxToFamily = parent.Multiply(solidBox.Transform);
                    for (var corner = 0; corner < 8; corner++)
                    {
                        var localPoint = new XYZ(
                            (corner & 1) == 0 ? solidBox.Min.X : solidBox.Max.X,
                            (corner & 2) == 0 ? solidBox.Min.Y : solidBox.Max.Y,
                            (corner & 4) == 0 ? solidBox.Min.Z : solidBox.Max.Z);
                        Include(boxToFamily.OfPoint(localPoint));
                    }
                }
                else if (item is GeometryInstance nested)
                {
                    Visit(nested.GetSymbolGeometry(), parent.Multiply(nested.Transform));
                }
            }
        }

        Visit(geometry, Transform.Identity);
        if (boundingBoxCornerCount == 0) return new SolidMetrics(null, null, solidCount, volume, boundingBoxCornerCount);
        return new SolidMetrics(new XYZ(minX, minY, minZ), new XYZ(maxX, maxY, maxZ), solidCount, volume, boundingBoxCornerCount);
    }

    private static object InspectSymbol(FamilySymbol symbol)
    {
        var metrics = Measure(symbol.get_Geometry(new Options
        {
            DetailLevel = ViewDetailLevel.Fine,
            IncludeNonVisibleObjects = false
        }) ?? throw new InvalidOperationException($"FamilySymbol '{symbol.Name}' returned no geometry."));

        object? boundsIn = null;
        if (metrics.Min is not null && metrics.Max is not null)
        {
            boundsIn = new
            {
                coordinate_frame = "axis-aligned family-symbol bounds of positive-volume Revit solids; nested transforms applied; not placed, hosted or oriented in the project",
                min_x = Math.Round(metrics.Min.X * 12, 4), max_x = Math.Round(metrics.Max.X * 12, 4),
                min_y = Math.Round(metrics.Min.Y * 12, 4), max_y = Math.Round(metrics.Max.Y * 12, 4),
                min_z = Math.Round(metrics.Min.Z * 12, 4), max_z = Math.Round(metrics.Max.Z * 12, 4),
                width_x = Math.Round((metrics.Max.X - metrics.Min.X) * 12, 4),
                depth_y = Math.Round((metrics.Max.Y - metrics.Min.Y) * 12, 4),
                height_z = Math.Round((metrics.Max.Z - metrics.Min.Z) * 12, 4),
                solid_bounding_box_corner_count = metrics.BoundingBoxCornerCount,
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
            solid_metrics = new { positive_volume_solid_count = metrics.SolidCount, total_volume_ft3 = Math.Round(metrics.VolumeFt3, 6) },
            bounds = boundsIn,
            parameters
        };
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? target = null;
        string? inspectedSourcePath = null;
        string? sourceHashBefore = null;
        try
        {
            var assemblyDirectory = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
            var root = Path.GetFullPath(File.ReadAllText(Path.Combine(assemblyDirectory, "workspace.txt")).Trim());
            var localRoot = Path.Combine(root, ".local", "revit-pilot");
            var candidateRoot = Path.Combine(localRoot, "family-intake", "candidates");
            var derivativeRoot = Path.Combine(localRoot, "family-intake", "derivatives");
            var requestPath = Path.Combine(assemblyDirectory, "candidate-family-request.json");
            var request = JsonSerializer.Deserialize<Request>(File.ReadAllText(requestPath))
                ?? throw new InvalidOperationException("Candidate-family request JSON was empty.");
            var familyPath = Path.GetFullPath(request.family_path);
            var outputDirectory = Path.GetFullPath(request.output_directory);
            inspectedSourcePath = familyPath;
            if (!IsWithinDirectory(familyPath, candidateRoot))
                throw new InvalidOperationException("The family source must remain under the repository's ignored quarantine candidates directory.");
            if (!IsWithinDirectory(outputDirectory, derivativeRoot))
                throw new InvalidOperationException("The derivative output must remain under the repository's ignored family-intake/derivatives directory.");
            if (!File.Exists(familyPath)) throw new System.IO.FileNotFoundException("Quarantined family source was not found.", familyPath);
            if (request.expected_sha256.Length != 64 || request.expected_sha256.Any(character => !Uri.IsHexDigit(character)))
                throw new InvalidOperationException("The expected source SHA256 must contain exactly 64 hexadecimal characters.");
            if (Directory.Exists(outputDirectory) && Directory.EnumerateFileSystemEntries(outputDirectory).Any())
                throw new System.IO.IOException($"Refusing to write into a non-empty derivative directory: {outputDirectory}");
            Directory.CreateDirectory(outputDirectory);
            sourceHashBefore = Sha256(familyPath);
            if (!StringComparer.OrdinalIgnoreCase.Equals(sourceHashBefore, request.expected_sha256))
                throw new InvalidOperationException($"Source hash mismatch; expected {request.expected_sha256}, actual {sourceHashBefore}.");

            var app = data.Application.Application;
            target = app.NewProjectDocument(UnitSystem.Imperial);
            string familyName;
            string? familyCategory;
            string placementType;
            Family loadedFamily;
            using (var familyDocument = app.OpenDocumentFile(familyPath))
            {
                var sourceFamily = familyDocument.OwnerFamily
                    ?? throw new InvalidOperationException("The opened RFA has no owner family.");
                familyName = sourceFamily.Name;
                familyCategory = sourceFamily.FamilyCategory?.Name;
                placementType = sourceFamily.FamilyPlacementType.ToString();
                loadedFamily = familyDocument.LoadFamily(target)
                    ?? throw new InvalidOperationException("FamilyDocument.LoadFamily(target) returned no family.");
            }

            var symbols = loadedFamily.GetFamilySymbolIds().Select(id => target.GetElement(id)).OfType<FamilySymbol>().ToList();
            if (symbols.Count == 0) throw new InvalidOperationException("Loaded candidate has no family types.");
            if (symbols.Any(symbol => !symbol.IsActive))
            {
                using var activation = new Transaction(target, "Activate isolated candidate family types for geometry readout");
                activation.Start();
                foreach (var symbol in symbols.Where(symbol => !symbol.IsActive)) symbol.Activate();
                target.Regenerate();
                activation.Commit();
            }
            var types = symbols.OrderBy(symbol => symbol.Name, StringComparer.OrdinalIgnoreCase).Select(InspectSymbol).ToList();
            var studyPath = Path.Combine(outputDirectory, "FH_Candidate_Family_Geometry.rvt");
            if (File.Exists(studyPath)) throw new System.IO.IOException($"Refusing to overwrite existing derivative: {studyPath}");
            target.SaveAs(studyPath, new SaveAsOptions());
            var sourceHashAfter = Sha256(familyPath);
            if (!StringComparer.OrdinalIgnoreCase.Equals(sourceHashAfter, sourceHashBefore))
                throw new System.IO.IOException("Quarantined source changed during read-only inspection.");
            var placedFamilyInstanceCount = new FilteredElementCollector(target)
                .OfClass(typeof(FamilyInstance))
                .GetElementCount();
            if (placedFamilyInstanceCount != 0)
                throw new InvalidOperationException($"The isolated project unexpectedly contains {placedFamilyInstanceCount} family instances.");

            var report = new
            {
                schema = "forever-home-candidate-family-geometry-v1",
                status = "pass; family loaded into disposable RVT and measured from positive-volume symbol solids; not placed in the house model",
                utc = DateTime.UtcNow,
                revit_version = app.VersionNumber,
                revit_build = app.VersionBuild,
                project_scope = new { derivative_type = "new_imperial_project", selected_d_opened = false, family_instances_placed = placedFamilyInstanceCount },
                source = new { path = familyPath, sha256_before = sourceHashBefore, sha256_after = sourceHashAfter },
                derivative = new { path = studyPath, sha256 = Sha256(studyPath) },
                family = familyName,
                category = familyCategory,
                placement_type = placementType,
                type_count = types.Count,
                types,
                limitations = new[]
                {
                    "The family-symbol bounds are a product envelope only; per-solid bounding boxes may overstate the exact projected outline, no instance was placed, and no stool orientation was selected.",
                    "Occupied posture, pulled-back stool position, end clearance and circulation are not represented by a static family symbol.",
                    "Family type parameters and geometric bounds do not establish product selection, comfort or building-code compliance."
                }
            };
            data.Application.OpenAndActivateDocument(studyPath);
            File.WriteAllText(Path.Combine(outputDirectory, "candidate-family-geometry.json"), JsonSerializer.Serialize(report, JsonOptions));
            TaskDialog.Show("Forever Home family geometry", $"Quarantined candidate measured in a disposable project. No family instance was placed. Results: {outputDirectory}");
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            if (inspectedSourcePath is not null && sourceHashBefore is not null)
            {
                try
                {
                    var sourceHashAfterFailure = Sha256(inspectedSourcePath);
                    if (!StringComparer.OrdinalIgnoreCase.Equals(sourceHashAfterFailure, sourceHashBefore))
                        message += $"{Environment.NewLine}WARNING: quarantined source hash changed during failed inspection; before={sourceHashBefore}, after={sourceHashAfterFailure}.";
                }
                catch (Exception hashException)
                {
                    message += $"{Environment.NewLine}WARNING: unable to verify quarantined source after failure: {hashException.Message}";
                }
            }
            TaskDialog.Show("Forever Home family geometry failed", message);
            try { target?.Close(false); } catch { }
            return Result.Failed;
        }
    }
}
