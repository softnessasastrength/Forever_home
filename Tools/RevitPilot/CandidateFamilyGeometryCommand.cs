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
    private sealed record Request(
        string family_path,
        string expected_sha256,
        string output_directory,
        bool vertical_wall_host_probe = false,
        string? symbol_name = null);
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

    private static double? Inches(Func<double> read)
    {
        try { return Math.Round(read() * 12, 4); }
        catch { return null; }
    }

    private static double[] PointInches(XYZ point) => new[]
    {
        Math.Round(point.X * 12, 4), Math.Round(point.Y * 12, 4), Math.Round(point.Z * 12, 4)
    };

    private static object PlaceOnVerticalTestWall(Document target, FamilySymbol symbol)
    {
        var wallType = new FilteredElementCollector(target).OfClass(typeof(WallType)).Cast<WallType>()
            .Where(type => type.Kind == WallKind.Basic)
            .OrderBy(type => type.Name, StringComparer.OrdinalIgnoreCase).FirstOrDefault()
            ?? throw new InvalidOperationException("The disposable project has no basic wall type for the orientation probe.");
        var level = new FilteredElementCollector(target).OfClass(typeof(Level)).Cast<Level>()
            .OrderBy(item => item.Elevation).FirstOrDefault()
            ?? throw new InvalidOperationException("The disposable project has no level for the orientation probe.");

        Wall wall;
        using (var createWall = new Transaction(target, "Create synthetic M-06 fixture host"))
        {
            createWall.Start();
            // This 10-ft wall is a test harness only; it is not a house dimension.
            wall = Wall.Create(target, Line.CreateBound(new XYZ(0, 0, 0), new XYZ(0, 10, 0)),
                wallType.Id, level.Id, 10.0, 0.0, false, false);
            createWall.Commit();
        }

        var sideFaces = new List<(Reference Reference, PlanarFace Face)>();
        foreach (var side in new[] { ShellLayerType.Interior, ShellLayerType.Exterior })
        {
            foreach (var reference in HostObjectUtils.GetSideFaces(wall, side))
            {
                if (wall.GetGeometryObjectFromReference(reference) is PlanarFace face &&
                    Math.Abs(face.FaceNormal.X) > 0.999)
                    sideFaces.Add((reference, face));
            }
        }
        var hostFace = sideFaces.FirstOrDefault();
        if (hostFace.Reference is null || hostFace.Face is null)
            throw new InvalidOperationException("No referenceable vertical side face was available on the synthetic wall.");

        var uv = hostFace.Face.GetBoundingBox();
        var point = hostFace.Face.Evaluate(new UV((uv.Min.U + uv.Max.U) / 2.0, (uv.Min.V + uv.Max.V) / 2.0));
        FamilyInstance instance;
        using (var place = new Transaction(target, "Place M-06 candidate on synthetic vertical host"))
        {
            place.Start();
            instance = target.Create.NewFamilyInstance(hostFace.Reference, point, XYZ.BasisY, symbol);
            place.Commit();
        }

        var host = instance.Host;
        var hostFaceReference = instance.HostFace;
        if (host?.Id.Value != wall.Id.Value || hostFaceReference?.ElementId.Value != wall.Id.Value)
            throw new InvalidOperationException("The candidate instance did not retain the synthetic wall as its face host.");

        var geometry = Measure(instance.get_Geometry(new Options
        {
            DetailLevel = ViewDetailLevel.Fine,
            IncludeNonVisibleObjects = false
        }) ?? throw new InvalidOperationException("The placed candidate returned no instance geometry."));
        if (geometry.Min is null || geometry.Max is null || geometry.SolidCount == 0)
            throw new InvalidOperationException("The placed candidate produced no measurable positive-volume solids.");

        object connectorReport;
        try
        {
            var connectors = new List<object>();
            var connectedConnectorCount = 0;
            var connectorSet = instance.MEPModel?.ConnectorManager?.Connectors;
            if (connectorSet is not null)
            {
                foreach (Connector connector in connectorSet)
                {
                    var isConnected = connector.IsConnected;
                    if (isConnected) connectedConnectorCount++;
                    XYZ? basisZ = null;
                    try { basisZ = connector.CoordinateSystem.BasisZ; } catch { }
                    connectors.Add(new
                    {
                        domain = connector.Domain.ToString(),
                        connector_type = connector.ConnectorType.ToString(),
                        shape = connector.Shape.ToString(),
                        is_connected = isConnected,
                        origin_project_in = PointInches(connector.Origin),
                        basis_z_project = basisZ is null ? null : new[]
                        {
                            Math.Round(basisZ.X, 6), Math.Round(basisZ.Y, 6), Math.Round(basisZ.Z, 6)
                        },
                        radius_in = connector.Shape == ConnectorProfileType.Round ? Inches(() => connector.Radius) : null,
                        width_in = connector.Shape == ConnectorProfileType.Rectangular ? Inches(() => connector.Width) : null,
                        height_in = connector.Shape == ConnectorProfileType.Rectangular ? Inches(() => connector.Height) : null
                    });
                }
            }
            connectorReport = new
            {
                status = connectorSet is null ? "no_mep_connector_manager" : "read_only_connector_inventory",
                count = connectors.Count,
                connectors,
                connected_connector_count = connectedConnectorCount,
                any_connectors_connected = connectedConnectorCount > 0,
                external_service_network_modelled = false
            };
        }
        catch (Exception ex)
        {
            connectorReport = new { status = "connector_inventory_failed", error = ex.ToString(), count = 0, connectors = Array.Empty<object>() };
        }

        var transform = instance.GetTransform();
        return new
        {
            status = "placed on synthetic wall in disposable project; no house room or service network",
            family_type = symbol.Name,
            wall_type = wallType.Name,
            wall_test_dimensions_ft = new { length = 10, height = 10, test_harness_only = true },
            placement_point_project_in = PointInches(point),
            reference_direction_project = new[] { 0, 1, 0 },
            host_face_normal_project = new[]
            {
                Math.Round(hostFace.Face.FaceNormal.X, 6), Math.Round(hostFace.Face.FaceNormal.Y, 6), Math.Round(hostFace.Face.FaceNormal.Z, 6)
            },
            host_element_id = wall.Id.Value,
            instance_host_element_id = host.Id.Value,
            host_face_element_id = hostFaceReference.ElementId.Value,
            instance_element_id = instance.Id.Value,
            instance_axes_project = new
            {
                x = new[] { Math.Round(transform.BasisX.X, 6), Math.Round(transform.BasisX.Y, 6), Math.Round(transform.BasisX.Z, 6) },
                y = new[] { Math.Round(transform.BasisY.X, 6), Math.Round(transform.BasisY.Y, 6), Math.Round(transform.BasisY.Z, 6) },
                z = new[] { Math.Round(transform.BasisZ.X, 6), Math.Round(transform.BasisZ.Y, 6), Math.Round(transform.BasisZ.Z, 6) }
            },
            positive_volume_solid_count = geometry.SolidCount,
            total_volume_ft3 = Math.Round(geometry.VolumeFt3, 6),
            instance_bounds_project_in = new
            {
                min = PointInches(geometry.Min), max = PointInches(geometry.Max),
                width_x = Math.Round((geometry.Max.X - geometry.Min.X) * 12, 4),
                depth_y = Math.Round((geometry.Max.Y - geometry.Min.Y) * 12, 4),
                height_z = Math.Round((geometry.Max.Z - geometry.Min.Z) * 12, 4)
            },
            connectors = connectorReport,
            limitations = new[]
            {
                "The synthetic wall-face center is an orientation probe, not an installation height or room placement.",
                "The project contains no door, approach, finished-room boundaries, plumbing network, or service route.",
                "A family connector inventory does not establish connector alignment, constructible piping, code applicability, or fixture fit."
            }
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
            object? hostProbe = null;
            if (request.vertical_wall_host_probe)
            {
                if (string.IsNullOrWhiteSpace(request.symbol_name))
                    throw new InvalidOperationException("A vertical host probe requires an exact family symbol_name.");
                if (!StringComparer.Ordinal.Equals(placementType, FamilyPlacementType.WorkPlaneBased.ToString()))
                    throw new InvalidOperationException($"Vertical face probing is limited to WorkPlaneBased candidates; source type is {placementType}.");
                var symbol = symbols.SingleOrDefault(item => StringComparer.Ordinal.Equals(item.Name, request.symbol_name))
                    ?? throw new InvalidOperationException($"Exact requested family type '{request.symbol_name}' was not found.");
                hostProbe = PlaceOnVerticalTestWall(target, symbol);
            }
            var studyPath = Path.Combine(outputDirectory, "FH_Candidate_Family_Geometry.rvt");
            if (File.Exists(studyPath)) throw new System.IO.IOException($"Refusing to overwrite existing derivative: {studyPath}");
            target.SaveAs(studyPath, new SaveAsOptions());
            var sourceHashAfter = Sha256(familyPath);
            if (!StringComparer.OrdinalIgnoreCase.Equals(sourceHashAfter, sourceHashBefore))
                throw new System.IO.IOException("Quarantined source changed during read-only inspection.");
            var placedFamilyInstanceCount = new FilteredElementCollector(target)
                .OfClass(typeof(FamilyInstance))
                .GetElementCount();
            var expectedInstanceCount = request.vertical_wall_host_probe ? 1 : 0;
            if (placedFamilyInstanceCount != expectedInstanceCount)
                throw new InvalidOperationException($"Expected {expectedInstanceCount} isolated family instance(s); found {placedFamilyInstanceCount}.");

            var report = new
            {
                schema = request.vertical_wall_host_probe
                    ? "forever-home-candidate-family-host-probe-v1"
                    : "forever-home-candidate-family-geometry-v1",
                status = request.vertical_wall_host_probe
                    ? "pass; source measured and one exact type placed on a synthetic wall in disposable RVT; not placed in the house model"
                    : "pass; family loaded into disposable RVT and measured from positive-volume symbol solids; not placed in the house model",
                utc = DateTime.UtcNow,
                revit_version = app.VersionNumber,
                revit_build = app.VersionBuild,
                project_scope = new { derivative_type = "new_imperial_project", selected_d_opened = false, family_instances_placed = placedFamilyInstanceCount, synthetic_host_probe_only = request.vertical_wall_host_probe },
                source = new { path = familyPath, sha256_before = sourceHashBefore, sha256_after = sourceHashAfter },
                derivative = new { path = studyPath, sha256 = Sha256(studyPath) },
                family = familyName,
                category = familyCategory,
                placement_type = placementType,
                type_count = types.Count,
                types,
                host_probe = hostProbe,
                limitations = new[]
                {
                    "The family-symbol bounds are a product envelope only; per-solid bounding boxes may overstate the exact projected outline.",
                    "A synthetic-host probe uses a test wall and provides no bathroom, door, approach, or service-route fit.",
                    "Family type parameters, connector objects, and geometric bounds do not establish product selection or code compliance."
                }
            };
            data.Application.OpenAndActivateDocument(studyPath);
            File.WriteAllText(Path.Combine(outputDirectory, "candidate-family-geometry.json"), JsonSerializer.Serialize(report, JsonOptions));
            TaskDialog.Show("Forever Home family geometry", request.vertical_wall_host_probe
                ? $"Quarantined candidate measured and placed on a synthetic wall in a disposable project. Results: {outputDirectory}"
                : $"Quarantined candidate measured in a disposable project. No family instance was placed. Results: {outputDirectory}");
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
