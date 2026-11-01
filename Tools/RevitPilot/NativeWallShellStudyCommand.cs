using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeWallShellStudyCommand : IExternalCommand
{
    private const string SourceRelative = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";
    private const string BasisRelative = "Decisions/2026-11-02_Walkthrough_Shell_Study_Basis.md";
    private const string ExpectedSourceHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private const string ExpectedBasisHash = "8961064955BB4036749931119883D00A80BE62706F69F64447F8BC2298A239B8";

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
            string root = File.ReadAllText(Path.Combine(assemblyDir, "workspace.txt")).Trim();
            string sourcePath = Path.Combine(root, SourceRelative.Replace('/', Path.DirectorySeparatorChar));
            string basisPath = Path.Combine(root, BasisRelative.Replace('/', Path.DirectorySeparatorChar));
            byte[] sourceBytes = File.ReadAllBytes(sourcePath);
            string sourceHash = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(sourceBytes));
            string basisHash = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(basisPath)));
            if (sourceHash != ExpectedSourceHash || basisHash != ExpectedBasisHash)
                throw new InvalidDataException("The selected-D source or approved shell-study basis changed; review both before generating walls.");

            using JsonDocument source = JsonDocument.Parse(File.ReadAllText(sourcePath).TrimStart('\uFEFF'));
            JsonElement rootJson = source.RootElement;
            JsonElement offsets = rootJson.GetProperty("plan_frame_offsets_ft");
            double mainWidth = rootJson.GetProperty("shells").GetProperty("main")[0].GetDouble();
            double mainDepth = rootJson.GetProperty("shells").GetProperty("main")[1].GetDouble();
            double wingWidth = rootJson.GetProperty("shells").GetProperty("rear_lower")[0].GetDouble();
            double wingDepth = rootJson.GetProperty("shells").GetProperty("rear_lower")[1].GetDouble();

            string stamp = DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'", CultureInfo.InvariantCulture);
            string output = Path.Combine(root, ".local", "revit-pilot", "native-wall-shell", stamp);
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var records = new List<object>();
            View3D? comparisonView = null;
            WallType? wallType = null;
            string wallTypeName = string.Empty;
            double wallTypeWidthFt = 0;
            int wallCount = 0;

            using (Transaction tx = new(doc, "Build provisional native shell walls"))
            {
                tx.Start();
                Level[] seedLevels = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>()
                    .OrderBy(level => level.Elevation).ToArray();
                if (seedLevels.Length != 1)
                    throw new InvalidOperationException($"Expected one seed level in the disposable imperial template; found {seedLevels.Length}.");

                wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                    .Where(type => type.Kind == WallKind.Basic)
                    .OrderBy(type => type.Name, StringComparer.OrdinalIgnoreCase)
                    .FirstOrDefault() ?? throw new InvalidOperationException("The Revit template contains no basic wall type.");
                wallTypeName = wallType.Name;
                wallTypeWidthFt = wallType.Width;

                foreach (var variant in new[] { (interval: 8.0, offset: 0.0), (interval: 9.0, offset: 50.0), (interval: 10.0, offset: 100.0) })
                {
                    foreach (var spec in new[] { (key: "lower", label: "Lower", width: wingWidth, depth: wingDepth),
                                 (key: "main", label: "Main", width: mainWidth, depth: mainDepth),
                                 (key: "upper", label: "Upper", width: wingWidth, depth: wingDepth) })
                    {
                        double z0 = spec.key switch { "lower" => 0, "main" => variant.interval, _ => variant.interval * 2 };
                        Level level;
                        if (variant.interval == 8.0 && spec.key == "lower")
                        {
                            level = seedLevels[0];
                            level.Elevation = z0;
                            level.Name = "8-ft Lower Wall Study Datum";
                        }
                        else
                        {
                            level = Level.Create(doc, z0);
                            level.Name = $"{variant.interval:0}-ft {spec.label} Wall Study Datum";
                        }

                        double[] frame = offsets.GetProperty(spec.key).EnumerateArray().Select(value => value.GetDouble()).ToArray();
                        double x = variant.offset + frame[0];
                        double y = frame[1];
                        XYZ[] corners = { new(x, y, z0), new(x + spec.width, y, z0), new(x + spec.width, y + spec.depth, z0), new(x, y + spec.depth, z0) };
                        for (int edge = 0; edge < corners.Length; edge++)
                        {
                            XYZ start = corners[edge];
                            XYZ end = corners[(edge + 1) % corners.Length];
                            Wall wall = Wall.Create(doc, Line.CreateBound(start, end), wallType.Id, level.Id, variant.interval, 0, false, false);
                            string marker = $"M299-PROVISIONAL-SHELL-WALL; case={variant.interval:0}ft; shell={spec.key}; edge={edge + 1}; opening=unresolved";
                            Parameter? comments = wall.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
                            if (comments is not null && !comments.IsReadOnly) comments.Set(marker);
                            records.Add(new
                            {
                                case_interval_ft = variant.interval,
                                shell_level = spec.key,
                                level_name = level.Name,
                                base_elevation_ft = z0,
                                top_elevation_ft = z0 + variant.interval,
                                wall_type = wallTypeName,
                                template_wall_type_width_ft = wallTypeWidthFt,
                                centerline_start_ft = new[] { start.X, start.Y, start.Z },
                                centerline_end_ft = new[] { end.X, end.Y, end.Z },
                                element_id = wall.Id.Value,
                                tag = marker
                            });
                            wallCount++;
                        }
                    }
                }

                ElementId viewTypeId = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>()
                    .First(viewType => viewType.ViewFamily == ViewFamily.ThreeDimensional).Id;
                comparisonView = View3D.CreateIsometric(doc, viewTypeId);
                comparisonView.Name = "Native Wall Shell — Provisional 8-10 ft Cases";
                tx.Commit();
            }

            int actualWallCount = new FilteredElementCollector(doc).OfClass(typeof(Wall)).GetElementCount();
            int actualLevelCount = new FilteredElementCollector(doc).OfClass(typeof(Level)).GetElementCount();
            if (wallCount != 36 || actualWallCount != 36 || actualLevelCount != 9)
                throw new InvalidOperationException($"Expected 36 native walls and 9 comparison levels; found {actualWallCount} walls and {actualLevelCount} levels.");

            if (comparisonView is not null && data.Application.ActiveUIDocument is UIDocument activeUiDoc && activeUiDoc.Document.Equals(doc))
                activeUiDoc.ActiveView = comparisonView;

            string rvt = Path.Combine(output, "FH_Native_Wall_Shell_Study.rvt");
            doc.SaveAs(rvt, new SaveAsOptions());
            doc.Close(false);
            doc = null;
            string savedRvtHash = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(rvt)));
            string manifestPath = Path.Combine(output, "native-wall-shell-manifest.json");
            using (FileStream stream = File.Create(manifestPath))
                JsonSerializer.Serialize(stream, new
                {
                    schema = "forever-home-native-wall-shell-study-v1",
                    status = "disposable native-wall massing comparison; wall type is an unselected template placeholder",
                    source = SourceRelative,
                    source_sha256 = sourceHash,
                    basis = BasisRelative,
                    basis_sha256 = basisHash,
                    saved_rvt = Path.GetFileName(rvt),
                    saved_rvt_sha256 = savedRvtHash,
                    shell_envelopes_ft = new { main = new[] { mainWidth, mainDepth }, rear_levels = new[] { wingWidth, wingDepth } },
                    case_intervals_ft = new[] { 8, 9, 10 },
                    plan_offsets_preserved = true,
                    comparison_offsets_ft = new[] { 0, 50, 100 },
                    template_wall_type = wallTypeName,
                    template_wall_type_width_ft = wallTypeWidthFt,
                    template_wall_type_is_project_selection = false,
                    native_wall_count = actualWallCount,
                    levels_count = actualLevelCount,
                    doors = 0,
                    windows = 0,
                    floors = 0,
                    stairs = 0,
                    roofs = 0,
                    wall_centerlines = records,
                    limitations = new[]
                    {
                        "Walls are native Revit Basic Wall elements using the first basic type sorted by name from the blank imperial project template; type and thickness are provisional, not selected construction specifications.",
                        "Only comparative shell perimeter walls are created; there are no internal partitions, doors, windows, floors, stairs, roof, structure, or MEP.",
                        "The shell rectangles and 8/9/10-ft floor intervals are comparison inputs, not final exterior dimensions or a selected ceiling/floor assembly.",
                        "Openings and circulation remain unresolved; this massing study is not a navigable or coordinated building model and establishes no code, structural, accessibility, permit, or construction-readiness result."
                    }
                }, new JsonSerializerOptions { WriteIndented = true });

            TaskDialog.Show("Forever Home", $"Provisional native wall shell study saved.\n\n{rvt}\n\n36 walls; template wall type and dimensions remain unselected placeholders. No doors, internal partitions, floors, stairs or roof.");
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            if (doc is not null && doc.IsValidObject) doc.Close(false);
            TaskDialog.Show("Forever Home native wall shell failed", ex.Message);
            return Result.Failed;
        }
    }
}
