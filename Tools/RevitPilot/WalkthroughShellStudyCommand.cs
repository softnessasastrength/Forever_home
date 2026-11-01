using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class WalkthroughShellStudyCommand : IExternalCommand
{
    private const string SourceRelative = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";

    private sealed record Space(string Id, string Name, string Kind, double X, double Y, double W, double D);

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
            string root = File.ReadAllText(Path.Combine(assemblyDir, "workspace.txt")).Trim();
            string sourcePath = Path.Combine(root, SourceRelative.Replace('/', Path.DirectorySeparatorChar));
            byte[] sourceBytes = File.ReadAllBytes(sourcePath);
            string sourceHash = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(sourceBytes));
            using JsonDocument study = JsonDocument.Parse(sourceBytes);
            JsonElement rootJson = study.RootElement;
            JsonElement offsets = rootJson.GetProperty("plan_frame_offsets_ft");
            JsonElement plans = rootJson.GetProperty("plans");
            double shellMainW = rootJson.GetProperty("shells").GetProperty("main")[0].GetDouble();
            double shellMainD = rootJson.GetProperty("shells").GetProperty("main")[1].GetDouble();
            double shellRearW = rootJson.GetProperty("shells").GetProperty("rear_lower")[0].GetDouble();
            double shellRearD = rootJson.GetProperty("shells").GetProperty("rear_lower")[1].GetDouble();
            if (sourceHash != "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB" ||
                Math.Abs(shellMainW - 40) > 1e-8 || Math.Abs(shellMainD - 42) > 1e-8 ||
                Math.Abs(shellRearW - 36) > 1e-8 || Math.Abs(shellRearD - 32) > 1e-8)
                throw new InvalidDataException("Selected-D source or documented shell test envelopes changed; review before building.");

            string stamp = DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'", CultureInfo.InvariantCulture);
            string output = Path.Combine(root, ".local", "revit-pilot", "walkthrough-shell", stamp);
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            var records = new List<object>();
            int curveCount = 0;
            View3D? comparisonView = null;
            using (Transaction tx = new(doc, "Build labeled walkthrough shell study wireframes"))
            {
                tx.Start();
                ElementId[] templateLevels = new FilteredElementCollector(doc).OfClass(typeof(Level)).ToElementIds().ToArray();
                if (templateLevels.Length > 0) doc.Delete(templateLevels);
                foreach (var variant in new[] { (label: "8 ft proxy", interval: 8.0, offset: 0.0), (label: "9 ft proxy", interval: 9.0, offset: 50.0), (label: "10 ft proxy", interval: 10.0, offset: 100.0) })
                {
                    double xCase = variant.offset;
                    var levels = new Dictionary<string, Level>(StringComparer.Ordinal);
                    foreach (var spec in new[] { (key: "lower", name: "Lower"), (key: "main", name: "Main"), (key: "upper", name: "Upper") })
                    {
                        double elevation = spec.key switch { "lower" => 0, "main" => variant.interval, _ => variant.interval * 2 };
                        Level level = Level.Create(doc, elevation);
                        level.Name = $"{variant.interval:0}-ft {spec.name} Study Datum";
                        levels[spec.key] = level;
                    }

                    foreach (var spec in new[] { (key: "lower", planKey: "lower"), (key: "main", planKey: "main"), (key: "upper", planKey: "upper") })
                    {
                        var frame = offsets.GetProperty(spec.key).EnumerateArray().Select(v => v.GetDouble()).ToArray();
                        double z0 = levels[spec.key].Elevation;
                        double z1 = z0 + variant.interval;
                        var spaces = plans.GetProperty(spec.planKey).EnumerateArray().Select(s => new Space(
                            s.GetProperty("id").GetString()!, s.GetProperty("name").GetString()!, s.GetProperty("kind").GetString()!,
                            s.GetProperty("x").GetDouble() + frame[0] + xCase, s.GetProperty("y").GetDouble() + frame[1],
                            s.GetProperty("w").GetDouble(), s.GetProperty("d").GetDouble())).ToArray();
                        SketchPlane bottom = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, new XYZ(0, 0, z0)));
                        SketchPlane top = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, new XYZ(0, 0, z1)));
                        foreach (Space space in spaces)
                        {
                            AddRect(bottom, space.X, space.Y, space.W, space.D, z0, "SPACE-BASE:" + space.Id);
                            AddRect(top, space.X, space.Y, space.W, space.D, z1, "SPACE-TOP:" + space.Id);
                            foreach (var p in new[] { (space.X, space.Y), (space.X + space.W, space.Y), (space.X + space.W, space.Y + space.D), (space.X, space.Y + space.D) })
                            {
                                SketchPlane verticalPlane = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisX, new XYZ(p.Item1, 0, 0)));
                                ModelCurve vertical = doc.Create.NewModelCurve(Line.CreateBound(new XYZ(p.Item1, p.Item2, z0), new XYZ(p.Item1, p.Item2, z1)), verticalPlane);
                                Tag(vertical, "SPACE-VOLUME:" + space.Id);
                                curveCount++;
                            }
                            records.Add(new { variant_ft = variant.interval, level = spec.key, id = space.Id, name = space.Name, kind = space.Kind,
                                x_ft = space.X, y_ft = space.Y, width_ft = space.W, depth_ft = space.D, base_z_ft = z0, top_z_ft = z1 });
                        }

                        double shellW = spec.key == "main" ? shellMainW : shellRearW;
                        double shellD = spec.key == "main" ? shellMainD : shellRearD;
                        var shell = new Space("SHELL-" + spec.key, "Comparative shell envelope", "outline",
                            xCase + frame[0], frame[1], shellW, shellD);
                        AddRect(bottom, shell.X, shell.Y, shell.W, shell.D, z0, "SHELL-BASE:" + spec.key);
                        AddRect(top, shell.X, shell.Y, shell.W, shell.D, z1, "SHELL-TOP:" + spec.key);
                    }
                }
                ElementId viewTypeId = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>()
                    .First(v => v.ViewFamily == ViewFamily.ThreeDimensional).Id;
                comparisonView = View3D.CreateIsometric(doc, viewTypeId);
                comparisonView.Name = "Walkthrough Shell — 8-10 ft Comparison";
                tx.Commit();
            }

            doc.Regenerate();
            int actualLevelCount = new FilteredElementCollector(doc).OfClass(typeof(Level)).GetElementCount();
            if (actualLevelCount != 9) throw new InvalidOperationException($"Expected exactly nine study levels; found {actualLevelCount}.");
            if (comparisonView is not null) data.Application.ActiveUIDocument.ActiveView = comparisonView;
            string rvt = Path.Combine(output, "FH_Walkthrough_Shell_Study.rvt");
            doc.SaveAs(rvt, new SaveAsOptions());
            string manifest = Path.Combine(output, "walkthrough-shell-manifest.json");
            using (FileStream fs = File.Create(manifest))
                JsonSerializer.Serialize(fs, new
                {
                    schema = "forever-home-walkthrough-shell-wireframe-v1",
                    status = "disposable comparison wireframe; not a coordinated or construction model",
                    source = SourceRelative,
                    source_sha256 = sourceHash,
                    saved_rvt = Path.GetFileName(rvt),
                    saved_rvt_sha256 = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(File.ReadAllBytes(rvt))),
                    floor_interval_cases_ft = new[] { 8, 9, 10 },
                    source_level_datums_replaced_in_this_derivative_only = true,
                    horizontal_case_offsets_ft = new[] { 0, 50, 100 },
                    plan_shells_ft = new { main = new[] { shellMainW, shellMainD }, rear_wings = new[] { shellRearW, shellRearD } },
                    room_volume_wireframes = records,
                    level_count = actualLevelCount,
                    vertical_model_curve_count = curveCount,
                    actual_walls = 0, actual_floors = 0, doors = 0, windows = 0, stairs = 0, roofs = 0,
                    limitations = new[] { "Vertical intervals are owner-authorized 8/9/10-ft comparison values; no level case is selected.",
                        "Each room is shown as bottom/top boundary rectangles and four vertical corner lines; no walls, floor/roof assemblies, thickness, openings, stairs, MEP, or structural elements are created.",
                        "The 40x42-ft main and 36x32-ft rear-wing rectangles are comparative shell envelopes from selected-D inputs, not accepted final exterior dimensions.",
                        "This wireframe supports spatial inspection only; it is not an immersive walk-through or coordinated building model." }
                }, new JsonSerializerOptions { WriteIndented = true });
            TaskDialog.Show("Forever Home", $"Walkthrough shell wireframe saved for the 8, 9 and 10 ft study cases.\n\n{rvt}\n\nThis derivative contains labeled room-volume wireframes only; it is not a physical house model.");
            return Result.Succeeded;

            void AddRect(SketchPlane plane, double x, double y, double w, double d, double z, string tag)
            {
                var points = new[] { new XYZ(x, y, z), new XYZ(x + w, y, z), new XYZ(x + w, y + d, z), new XYZ(x, y + d, z) };
                for (int i = 0; i < points.Length; i++)
                {
                    ModelCurve curve = doc.Create.NewModelCurve(Line.CreateBound(points[i], points[(i + 1) % points.Length]), plane);
                    Tag(curve, tag);
                    curveCount++;
                }
            }
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            if (doc is not null && doc.IsValidObject) doc.Close(false);
            TaskDialog.Show("Forever Home walkthrough shell failed", ex.Message);
            return Result.Failed;
        }
    }

    private static void Tag(Element element, string value)
    {
        Parameter? p = element.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (p is not null && !p.IsReadOnly) p.Set(value);
    }
}
