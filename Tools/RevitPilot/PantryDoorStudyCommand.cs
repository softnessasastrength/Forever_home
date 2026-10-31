using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class PantryDoorStudyCommand : IExternalCommand
{
    private const string SelectedDHash = "516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb";
    private const string M215Hash = "f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1";
    private const string M217Hash = "7e436b9a7d805e2803a1148fbd2bdacad017f86b7d444f7cbe77cbde30226853";
    private const string M218Hash = "946aaf98fc44fa67cd5546168fecd896d4c36543bc097553c75c7389385a3d43";
    private const double TestWallHeightFt = 10.0; // disposable harness height; not a house specification
    private const double PantryXFt = 13.5;
    private const double PantryYFt = 1.25;
    private const double PantryWidthFt = 5.0;
    private const double PantryDepthFt = 7.0;
    private const double KitchenWidthFt = 13.5;
    private const double KitchenDepthFt = 13.25;
    private const double DoorWidthFt = 2.5;
    private const double ApproachSizeFt = 3.0;
    private const double RouteWidthFt = 3.0;
    private const double LineZFt = 0.05;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    private sealed record DoorPosition(string Id, double StartY);
    private sealed record StudyFile(string swing_into, string file_name, string sha256, long bytes,
        int wall_count, int model_curve_count, string status);

    private static string Sha256(string path)
    {
        using var stream = File.OpenRead(path);
        return Convert.ToHexString(SHA256.HashData(stream)).ToLowerInvariant();
    }

    private static string RootFromAssembly()
    {
        var assemblyDirectory = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)
            ?? throw new InvalidOperationException("The RevitPilot assembly has no directory.");
        var marker = Path.Combine(assemblyDirectory, "workspace.txt");
        if (!File.Exists(marker)) throw new FileNotFoundException("Project-local workspace marker is missing.", marker);
        var root = Path.GetFullPath(File.ReadAllText(marker).Trim());
        if (!Directory.Exists(Path.Combine(root, "Tools", "RevitPilot")))
            throw new InvalidOperationException("The workspace marker does not resolve to a Forever Home checkout.");
        return root;
    }

    private static JsonDocument ReadPinnedJson(string root, string relativePath, string expectedHash)
    {
        var path = Path.GetFullPath(Path.Combine(root, relativePath));
        var expectedPrefix = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        if (!path.StartsWith(expectedPrefix, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("A pinned study input resolved outside the repository.");
        if (!File.Exists(path)) throw new FileNotFoundException("A pinned study input is missing.", path);
        var actualHash = Sha256(path);
        if (!StringComparer.OrdinalIgnoreCase.Equals(actualHash, expectedHash))
            throw new InvalidOperationException($"Study input fingerprint mismatch for {relativePath}: expected {expectedHash}; actual {actualHash}.");
        return JsonDocument.Parse(File.ReadAllBytes(path));
    }

    private static double Number(JsonElement item, string key) => item.GetProperty(key).GetDouble();
    private static string Text(JsonElement item, string key) => item.GetProperty(key).GetString() ?? "";

    private static void Tag(Element element, string marker)
    {
        var parameter = element.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (parameter is null || parameter.IsReadOnly)
            throw new InvalidOperationException($"Cannot tag disposable study element {marker}.");
        parameter.Set(marker);
    }

    private static List<DoorPosition> ReadDoorPositions(JsonElement m218)
    {
        var unique = new Dictionary<string, DoorPosition>(StringComparer.OrdinalIgnoreCase);
        foreach (var row in m218.GetProperty("results").EnumerateArray())
        {
            var id = Text(row, "position");
            var opening = row.GetProperty("door_opening");
            var position = new DoorPosition(id, Number(opening, "start_y_ft"));
            if (unique.TryGetValue(id, out var prior) && Math.Abs(prior.StartY - position.StartY) > 1e-8)
                throw new InvalidDataException($"M218 contains conflicting coordinates for {id}.");
            unique[id] = position;
        }
        var expected = new[] { "lower", "center", "upper" };
        if (!expected.All(unique.ContainsKey))
            throw new InvalidDataException("M218 must provide lower, center and upper door positions.");
        return expected.Select(id => unique[id]).ToList();
    }

    private static List<XYZ> ReadRoute(JsonElement m215)
    {
        var points = m215.GetProperty("route_waypoints_ft").EnumerateArray()
            .Select(point => new XYZ(Number(point, "x"), Number(point, "y"), LineZFt)).ToList();
        if (points.Count != 5) throw new InvalidDataException("M215 route must have the verified five waypoints.");
        return points;
    }

    private static Wall AddWall(Document doc, WallType wallType, Level level, XYZ a, XYZ b, string marker)
    {
        if (a.DistanceTo(b) < 1e-6) throw new ArgumentException("Refusing to create a zero-length test wall.");
        var wall = Wall.Create(doc, Line.CreateBound(a, b), wallType.Id, level.Id, TestWallHeightFt, 0, false, false);
        Tag(wall, marker);
        return wall;
    }

    private static void AddLine(Document doc, SketchPlane plane, ViewPlan plan, XYZ a, XYZ b,
        string marker, Color? color, IList<ElementId> created)
    {
        if (a.DistanceTo(b) < 1e-6) return;
        var curve = doc.Create.NewModelCurve(Line.CreateBound(a, b), plane);
        Tag(curve, marker);
        if (color is not null)
        {
            var overrides = new OverrideGraphicSettings();
            overrides.SetProjectionLineColor(color);
            overrides.SetProjectionLineWeight(4);
            plan.SetElementOverrides(curve.Id, overrides);
        }
        created.Add(curve.Id);
    }

    private static void AddRect(Document doc, SketchPlane plane, ViewPlan plan,
        double x, double y, double width, double depth, string marker, Color color, IList<ElementId> created)
    {
        if (width <= 0 || depth <= 0) throw new ArgumentOutOfRangeException(nameof(width), "Study rectangles must be positive.");
        var p = new[]
        {
            new XYZ(x, y, LineZFt), new XYZ(x + width, y, LineZFt),
            new XYZ(x + width, y + depth, LineZFt), new XYZ(x, y + depth, LineZFt)
        };
        for (var i = 0; i < p.Length; i++) AddLine(doc, plane, plan, p[i], p[(i + 1) % p.Length], $"{marker}-{i + 1:00}", color, created);
    }

    private static void AddText(Document doc, ViewPlan plan, TextNoteType textType, double x, double y, string text)
        => TextNote.Create(doc, plan.Id, new XYZ(x, y, LineZFt), text, textType.Id);

    private static List<XYZ> Offset(IReadOnlyList<XYZ> points, double offsetX)
        => points.Select(point => new XYZ(point.X + offsetX, point.Y, LineZFt)).ToList();

    private static int BuildStudyFile(UIApplication ui, string path, string swingInto,
        IReadOnlyList<DoorPosition> positions, IReadOnlyList<XYZ> routePoints, out int wallCount, out int curveCount)
    {
        var app = ui.Application;
        var doc = app.NewProjectDocument(UnitSystem.Imperial);
        wallCount = 0;
        curveCount = 0;
        try
        {
            using (var transaction = new Transaction(doc, "Build isolated M218 pantry door comparison"))
            {
                transaction.Start();
                var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>()
                    .OrderBy(item => item.Elevation).FirstOrDefault(item => Math.Abs(item.Elevation) < 1e-6)
                    ?? Level.Create(doc, 0.0);
                level.Name = "M218 test level — 0 ft";
                Tag(level, "M218-TEST-LEVEL-NOT-HOUSE-DATUM");
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>()
                    .Where(item => item.Kind == WallKind.Basic).OrderBy(item => item.Name, StringComparer.OrdinalIgnoreCase).First();
                var floorPlanType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>()
                    .First(item => item.ViewFamily == ViewFamily.FloorPlan);
                var plan = new FilteredElementCollector(doc).OfClass(typeof(ViewPlan)).Cast<ViewPlan>()
                    .FirstOrDefault(item => !item.IsTemplate && item.GenLevel?.Id == level.Id)
                    ?? ViewPlan.Create(doc, floorPlanType.Id, level.Id);
                plan.Name = swingInto == "kitchen" ? "M218 Swing Into Kitchen — compare positions" : "M218 Swing Into Pantry — compare positions";
                plan.Scale = 96;
                var textType = new FilteredElementCollector(doc).OfClass(typeof(TextNoteType)).Cast<TextNoteType>().First();
                var plane = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, new XYZ(0, 0, LineZFt)));
                var lineIds = new List<ElementId>();
                var black = new Color(35, 35, 35);
                var green = new Color(0, 125, 65);
                var orange = new Color(180, 75, 0);
                var blue = new Color(0, 80, 170);
                var gray = new Color(90, 90, 90);
                var basicWallCount = 0;

                for (var column = 0; column < positions.Count; column++)
                {
                    var position = positions[column];
                    var offsetX = column * 30.0;
                    var pantryX = offsetX + PantryXFt;
                    var pantryY = PantryYFt;
                    var pantryTop = pantryY + PantryDepthFt;
                    var doorStart = position.StartY;
                    var doorEnd = doorStart + DoorWidthFt;
                    if (doorStart < pantryY - 1e-6 || doorEnd > pantryTop + 1e-6)
                        throw new InvalidDataException($"M218 {position.Id} opening does not fit the pantry shared edge.");

                    // The kitchen is a proxy extent only: three sides remain visually open to represent the owner's open-plan direction.
                    AddRect(doc, plane, plan, offsetX, 0, KitchenWidthFt, KitchenDepthFt,
                        $"M218-{position.Id}-M02-envelope-not-walls", gray, lineIds);
                    AddText(doc, plan, textType, offsetX, KitchenDepthFt + 1.0,
                        $"{position.Id.ToUpperInvariant()} — M-02 13.5 × 13.25 ft proxy; M-04 5 × 7 ft proxy");

                    // Three pantry walls plus split shared wall segments leave a literal opening in the test wall line.
                    AddWall(doc, wallType, level, new XYZ(pantryX, pantryY, 0), new XYZ(pantryX + PantryWidthFt, pantryY, 0), $"M218-{position.Id}-PANTRY-SOUTH"); basicWallCount++;
                    AddWall(doc, wallType, level, new XYZ(pantryX + PantryWidthFt, pantryY, 0), new XYZ(pantryX + PantryWidthFt, pantryTop, 0), $"M218-{position.Id}-PANTRY-EAST"); basicWallCount++;
                    AddWall(doc, wallType, level, new XYZ(pantryX + PantryWidthFt, pantryTop, 0), new XYZ(pantryX, pantryTop, 0), $"M218-{position.Id}-PANTRY-NORTH"); basicWallCount++;
                    if (doorStart > pantryY + 1e-6)
                    {
                        AddWall(doc, wallType, level, new XYZ(pantryX, pantryY, 0), new XYZ(pantryX, doorStart, 0), $"M218-{position.Id}-PANTRY-WEST-SOUTH"); basicWallCount++;
                    }
                    if (doorEnd < pantryTop - 1e-6)
                    {
                        AddWall(doc, wallType, level, new XYZ(pantryX, doorEnd, 0), new XYZ(pantryX, pantryTop, 0), $"M218-{position.Id}-PANTRY-WEST-NORTH"); basicWallCount++;
                    }

                    var centerY = doorStart + DoorWidthFt / 2.0;
                    AddRect(doc, plane, plan, pantryX - ApproachSizeFt, centerY - ApproachSizeFt / 2.0,
                        ApproachSizeFt, ApproachSizeFt, $"M218-{position.Id}-36in-approach-proxy", blue, lineIds);
                    var swingX = swingInto == "kitchen" ? pantryX - DoorWidthFt : pantryX;
                    AddRect(doc, plane, plan, swingX, doorStart, DoorWidthFt, DoorWidthFt,
                        $"M218-{position.Id}-{swingInto}-swing-bounds-not-door-leaf", swingInto == "kitchen" ? orange : green, lineIds);

                    var shiftedRoute = Offset(routePoints, offsetX);
                    for (var segment = 0; segment < shiftedRoute.Count - 1; segment++)
                        AddLine(doc, plane, plan, shiftedRoute[segment], shiftedRoute[segment + 1],
                            $"M218-{position.Id}-M215-route-centerline-{segment + 1:00}", blue, lineIds);
                    AddText(doc, plan, textType, pantryX - 0.25, pantryTop + 1.25,
                        $"30 in nominal opening; assumed swing into {swingInto}; test walls 10 ft high");
                }

                // No fixture or room is assigned to either M-06 search window.
                AddText(doc, plan, textType, 0, -2.0,
                    "Study only — west A protected for M-06; east B unassigned; not a selected house plan");
                AddText(doc, plan, textType, 0, -3.0,
                    "Door leaf is not modeled; colored 30 × 30 in boxes are swing bounds; blue boxes are 36 × 36 in approach proxies");
                AddText(doc, plan, textType, 0, -4.0,
                    "Wall height/type are disposable test geometry, not architectural or structural specifications");
                transaction.Commit();
                wallCount = basicWallCount;
                curveCount = lineIds.Count;
            }

            using (var save = new Transaction(doc, "Name isolated M218 pantry door study"))
            {
                save.Start();
                var view3dType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>()
                    .First(item => item.ViewFamily == ViewFamily.ThreeDimensional);
                var view3d = View3D.CreateIsometric(doc, view3dType.Id);
                view3d.Name = swingInto == "kitchen" ? "M218 Swing Into Kitchen — 3D test" : "M218 Swing Into Pantry — 3D test";
                view3d.SetSectionBox(new BoundingBoxXYZ
                {
                    Min = new XYZ(-1, -5, -1),
                    Max = new XYZ(82, 36, TestWallHeightFt + 1)
                });
                view3d.IsSectionBoxActive = true;
                view3d.SetCategoryHidden(new ElementId(BuiltInCategory.OST_Levels), true);
                view3d.SetCategoryHidden(new ElementId(BuiltInCategory.OST_SectionBox), true);
                save.Commit();
            }

            doc.SaveAs(path, new SaveAsOptions());
            doc.Close(false);
            return wallCount;
        }
        catch
        {
            try { if (doc.IsValidObject) doc.Close(false); } catch { }
            throw;
        }
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        try
        {
            var root = RootFromAssembly();
            using var selected = ReadPinnedJson(root, "Architecture/Selected_Design_Iteration_2026-10-27/study.json", SelectedDHash);
            using var m215 = ReadPinnedJson(root, "Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json", M215Hash);
            using var m217 = ReadPinnedJson(root, "Architecture/M217_Pantry_Route_Integration_2026-10-31/artifacts/m217-pantry-route-integration.json", M217Hash);
            using var m218 = ReadPinnedJson(root, "Architecture/M218_Pantry_Door_Approach_2026-10-31/artifacts/m218-pantry-door-approach.json", M218Hash);
            if (Text(m217.RootElement, "status") != "pass" || m217.RootElement.GetProperty("checks").GetProperty("passed").GetInt32() != 7)
                throw new InvalidDataException("M217 pantry-route source report has not passed.");
            if (Text(m218.RootElement, "status") != "pass" || m218.RootElement.GetProperty("checks").GetProperty("passed").GetInt32() != 6)
                throw new InvalidDataException("M218 door/approach source report has not passed.");
            if (Text(m215.RootElement, "status") != "pass" || m215.RootElement.GetProperty("checks").GetProperty("passed").GetInt32() != 12)
                throw new InvalidDataException("M215 route source report has not passed.");
            var route = ReadRoute(m215.RootElement);
            var positions = ReadDoorPositions(m218.RootElement);

            var timestamp = DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ", CultureInfo.InvariantCulture);
            var output = Path.Combine(root, ".local", "revit-pilot", "m218-pantry-door-study", timestamp);
            if (Directory.Exists(output) || File.Exists(output))
                throw new IOException("Refusing to overwrite an existing disposable-study output directory.");
            Directory.CreateDirectory(output);

            var files = new List<StudyFile>();
            foreach (var swingInto in new[] { "kitchen", "pantry" })
            {
                var fileName = $"FH_M218_Pantry_Swing_Into_{(swingInto == "kitchen" ? "Kitchen" : "Pantry")}.rvt";
                var path = Path.Combine(output, fileName);
                BuildStudyFile(data.Application, path, swingInto, positions, route, out var wallCount, out var curveCount);
                var info = new FileInfo(path);
                files.Add(new StudyFile(swingInto, fileName, Sha256(path), info.Length, wallCount, curveCount,
                    "saved as isolated disposable comparison; not the selected house model"));
            }

            var manifest = new
            {
                schema = "forever-home-m218-revit-pantry-door-study-v1",
                status = "pass; two separate disposable Revit comparison files generated",
                utc = DateTime.UtcNow,
                revit_version = data.Application.Application.VersionNumber,
                revit_build = data.Application.Application.VersionBuild,
                project_scope = new { derivative_type = "fresh imperial project per swing", selected_d_opened = false, selected_d_modified = false },
                source_sha256 = new { selected_d = SelectedDHash, m215 = M215Hash, m217 = M217Hash, m218 = M218Hash },
                inputs = new { pantry_ft = new[] { PantryXFt, PantryYFt, PantryWidthFt, PantryDepthFt }, kitchen_proxy_ft = new[] { 0.0, 0.0, KitchenWidthFt, KitchenDepthFt }, nominal_opening_ft = DoorWidthFt, approach_proxy_ft = new[] { ApproachSizeFt, ApproachSizeFt }, wall_height_test_ft = TestWallHeightFt },
                files,
                limitations = new[]
                {
                    "These comparison files use new projects and contain only a kitchen extent proxy, pantry test walls, model-curve approach/swing envelopes and the sampled route centerline.",
                    "No room, shelf, stocked pantry, door leaf/family, rough opening, jamb, threshold, finish build-up, MEP service or site is modeled.",
                    "The 10-ft test wall height and Revit template wall type are harness properties, not house specifications.",
                    "West A remains protected and east B remains unassigned. No selected-D/RVT/IFC or source family is opened or changed.",
                    "This is not a code, accessibility, structural, professional, permit or construction-readiness determination."
                }
            };
            File.WriteAllText(Path.Combine(output, "m218-revit-study-manifest.json"), JsonSerializer.Serialize(manifest, JsonOptions));
            var first = Path.Combine(output, files[0].file_name);
            data.Application.OpenAndActivateDocument(first);
            TaskDialog.Show("Forever Home pantry door study",
                "Two isolated Revit studies were saved: three opening positions with the swing bound into the kitchen, and three with it into the pantry. No selected model was opened.\n\n" + output);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            TaskDialog.Show("Forever Home pantry door study failed", ex.Message);
            return Result.Failed;
        }
    }
}
