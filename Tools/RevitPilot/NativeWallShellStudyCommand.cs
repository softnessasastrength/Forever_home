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
public sealed class NativeWallShellStudyCommand : IExternalCommand
{
    private const string SourceRelative = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";
    private const string RegisterRelative = "Architecture/Dimension_Register.md";
    private const string BasisRelative = "Decisions/2026-11-02_Clear_Ceiling_Height_Study_Basis.md";
    private const string ExpectedSourceHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const int ExpectedWallCountPerModel = 12;
    private static readonly double[] ClearHeightCasesFt = [8.0, 9.0, 10.0];

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
        string root = File.ReadAllText(Path.Combine(assemblyDir, "workspace.txt")).Trim();
        string sourcePath = Path.Combine(root, SourceRelative.Replace('/', Path.DirectorySeparatorChar));
        string registerPath = Path.Combine(root, RegisterRelative.Replace('/', Path.DirectorySeparatorChar));
        string basisPath = Path.Combine(root, BasisRelative.Replace('/', Path.DirectorySeparatorChar));
        string output = Path.Combine(root, ".local", "revit-pilot", "clear-ceiling-wall-height",
            DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'", CultureInfo.InvariantCulture));
        Directory.CreateDirectory(output);

        try
        {
            byte[] sourceBytes = File.ReadAllBytes(sourcePath);
            string sourceHash = Convert.ToHexString(SHA256.HashData(sourceBytes));
            string registerHash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(registerPath)));
            string basisHash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(basisPath)));
            if (sourceHash != ExpectedSourceHash)
                throw new InvalidDataException("The selected-D source changed; review it before generating geometry.");

            using JsonDocument source = JsonDocument.Parse(File.ReadAllText(sourcePath).TrimStart('\uFEFF'));
            JsonElement shellData = source.RootElement.GetProperty("shells");
            double[][] extents =
            [
                shellData.GetProperty("main").EnumerateArray().Select(v => v.GetDouble()).ToArray(),
                shellData.GetProperty("rear_lower").EnumerateArray().Select(v => v.GetDouble()).ToArray(),
                shellData.GetProperty("rear_upper").EnumerateArray().Select(v => v.GetDouble()).ToArray()
            ];
            string[] shellKeys = ["main", "rear_lower", "rear_upper"];
            string[] shellLabels = ["Main_40x42", "Lower_36x32", "Upper_36x32"];
            var modelRecords = new List<object>();

            for (int shellIndex = 0; shellIndex < shellKeys.Length; shellIndex++)
            {
                string? activePath = null;
                Document? doc = null;
                try
                {
                    doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
                    Level[] seedLevels = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>()
                        .OrderBy(level => level.Elevation).ToArray();
                    if (seedLevels.Length != 1)
                        throw new InvalidOperationException($"Expected one seed level in the disposable imperial template; found {seedLevels.Length}.");

                    WallType wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                        .Where(type => type.Kind == WallKind.Basic)
                        .OrderBy(type => type.Name, StringComparer.OrdinalIgnoreCase)
                        .FirstOrDefault() ?? throw new InvalidOperationException("The Revit template contains no basic wall type.");
                    string wallTypeName = wallType.Name;
                    double wallTypeWidthFt = wallType.Width;
                    Level baseLevel = seedLevels[0];
                    var wallRecords = new List<object>();
                    View3D? comparisonView = null;

                    using (Transaction tx = new(doc, "Build clear-ceiling wall-height proxies"))
                    {
                        tx.Start();
                        baseLevel.Name = "Local Zero — No Building Elevation Assigned";
                        double width = extents[shellIndex][0];
                        double depth = extents[shellIndex][1];
                        for (int caseIndex = 0; caseIndex < ClearHeightCasesFt.Length; caseIndex++)
                        {
                            double clearHeightFt = ClearHeightCasesFt[caseIndex];
                            double displayOffsetFt = caseIndex * (width + 10.0);
                            XYZ[] corners =
                            [
                                new(displayOffsetFt, 0, baseLevel.Elevation),
                                new(displayOffsetFt + width, 0, baseLevel.Elevation),
                                new(displayOffsetFt + width, depth, baseLevel.Elevation),
                                new(displayOffsetFt, depth, baseLevel.Elevation)
                            ];
                            for (int edge = 0; edge < corners.Length; edge++)
                            {
                                XYZ start = corners[edge];
                                XYZ end = corners[(edge + 1) % corners.Length];
                                Wall wall = Wall.Create(doc, Line.CreateBound(start, end), wallType.Id,
                                    baseLevel.Id, clearHeightFt, 0, false, false);
                                string marker = $"M311-CLEAR-HEIGHT-PROXY; shell={shellKeys[shellIndex]}; " +
                                    $"clear-height={clearHeightFt:0}ft; plan-display-offset={displayOffsetFt:0}ft; " +
                                    "no-floor-ceiling-assembly; no-opening";
                                Parameter? comments = wall.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
                                if (comments is not null && !comments.IsReadOnly) comments.Set(marker);
                                wallRecords.Add(new
                                {
                                    shell = shellKeys[shellIndex],
                                    clear_height_reference_ft = clearHeightFt,
                                    model_space_display_offset_ft = displayOffsetFt,
                                    wall_type = wallTypeName,
                                    template_wall_type_width_ft = wallTypeWidthFt,
                                    centerline_start_ft = new[] { start.X, start.Y, start.Z },
                                    centerline_end_ft = new[] { end.X, end.Y, end.Z },
                                    base_level = baseLevel.Name,
                                    base_elevation_ft = baseLevel.Elevation,
                                    unconnected_height_ft = clearHeightFt,
                                    element_id = wall.Id.Value,
                                    tag = marker
                                });
                            }
                        }

                        ElementId viewTypeId = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType))
                            .Cast<ViewFamilyType>().First(view => view.ViewFamily == ViewFamily.ThreeDimensional).Id;
                        comparisonView = View3D.CreateIsometric(doc, viewTypeId);
                        comparisonView.Name = $"{shellLabels[shellIndex]} — 8-9-10 ft Height Proxies";
                        tx.Commit();
                    }

                    int actualWallCount = new FilteredElementCollector(doc).OfClass(typeof(Wall)).GetElementCount();
                    int actualLevelCount = new FilteredElementCollector(doc).OfClass(typeof(Level)).GetElementCount();
                    if (actualWallCount != ExpectedWallCountPerModel || wallRecords.Count != ExpectedWallCountPerModel || actualLevelCount != 1)
                        throw new InvalidOperationException($"Expected {ExpectedWallCountPerModel} walls and 1 local level; found {actualWallCount} walls and {actualLevelCount} levels.");

                    if (comparisonView is not null && data.Application.ActiveUIDocument is UIDocument activeUiDoc && activeUiDoc.Document.Equals(doc))
                        activeUiDoc.ActiveView = comparisonView;

                    string fileName = $"FH_{shellLabels[shellIndex]}_ClearHeight_Comparison.rvt";
                    activePath = Path.Combine(output, fileName);
                    doc.SaveAs(activePath, new SaveAsOptions());
                    doc.Close(false);
                    doc = null;

                    string savedHash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(activePath)));
                    string manifestPath = Path.Combine(output, Path.GetFileNameWithoutExtension(fileName) + ".json");
                    using (FileStream stream = File.Create(manifestPath))
                        JsonSerializer.Serialize(stream, new
                        {
                            schema = "forever-home-clear-ceiling-wall-height-v1",
                            status = "disposable single-level wall-height comparison; no assembly or building section selected",
                            source = SourceRelative,
                            source_sha256 = sourceHash,
                            dimension_register = RegisterRelative,
                            dimension_register_sha256 = registerHash,
                            basis = BasisRelative,
                            basis_sha256 = basisHash,
                            shell = shellKeys[shellIndex],
                            shell_envelope_ft = new[] { extents[shellIndex][0], extents[shellIndex][1] },
                            local_base_elevation_ft = 0,
                            local_base_is_building_datum = false,
                            saved_rvt = fileName,
                            saved_rvt_sha256 = savedHash,
                            native_wall_count = actualWallCount,
                            level_count = actualLevelCount,
                            case_clear_height_reference_ft = ClearHeightCasesFt,
                            per_case_wall_count = 4,
                            model_space_display_offsets_ft = ClearHeightCasesFt.Select((_, i) => i * (extents[shellIndex][0] + 10)).ToArray(),
                            display_offsets_are_site_coordinates = false,
                            template_wall_type = wallTypeName,
                            template_wall_type_width_ft = wallTypeWidthFt,
                            template_wall_type_is_project_selection = false,
                            floors = 0,
                            ceilings = 0,
                            doors = 0,
                            windows = 0,
                            stairs = 0,
                            roofs = 0,
                            wall_centerlines = wallRecords,
                            limitations = new[]
                            {
                                "The wall top at each labeled height is a clear-height proxy only; no floor, ceiling, finish, or structural assemblies are modeled.",
                                "The 8/9/10 ft alternatives are translated side-by-side solely for comparison; they are not three building storeys or site coordinates.",
                                "The basic wall type and its measured thickness come from a blank Revit template and are unselected placeholders.",
                                "Only envelope walls are modeled; no internal partitions, openings, floors, stairs, roof, structure, MEP, or site context.",
                                "This model does not establish code compliance, accessibility, structural safety, professional approval, permit approval, or construction readiness."
                            }
                        }, new JsonSerializerOptions { WriteIndented = true });

                    modelRecords.Add(new
                    {
                        shell = shellKeys[shellIndex],
                        envelope_ft = new[] { extents[shellIndex][0], extents[shellIndex][1] },
                        model = fileName,
                        model_sha256 = savedHash,
                        manifest = Path.GetFileName(manifestPath),
                        native_walls = actualWallCount,
                        levels = actualLevelCount,
                        clear_height_cases_ft = ClearHeightCasesFt
                    });
                }
                finally
                {
                    if (doc is not null && doc.IsValidObject) doc.Close(false);
                }
            }

            using (FileStream stream = File.Create(Path.Combine(output, "comparison-index.json")))
                JsonSerializer.Serialize(stream, new
                {
                    schema = "forever-home-clear-ceiling-wall-height-index-v1",
                    status = "three isolated disposable single-level envelope comparison models",
                    source = SourceRelative,
                    source_sha256 = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(sourcePath))),
                    dimension_register = RegisterRelative,
                    dimension_register_sha256 = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(registerPath))),
                    basis = BasisRelative,
                    basis_sha256 = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(basisPath))),
                    cases = modelRecords,
                    stair = "unresolved and not modeled",
                    floor_to_floor = "unresolved and not modeled"
                }, new JsonSerializerOptions { WriteIndented = true });

            TaskDialog.Show("Forever Home", $"Disposable clear-height comparison saved to:\n\n{output}\n\nThree single-level RVTs; 8, 9, and 10 ft wall-top references; no floor-to-floor or stair assumption.");
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            TaskDialog.Show("Forever Home clear-height comparison failed", ex.Message);
            return Result.Failed;
        }
    }
}
