using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Architecture;
using Autodesk.Revit.UI;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeStairLandingCoordinationCommand : IExternalCommand
{
    private static string Hash(string path)
    {
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
        return Convert.ToHexString(SHA256.HashData(stream)).ToLowerInvariant();
    }

    private static void Tag(Element element, string value)
    {
        var p = element.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
        if (p is not null && !p.IsReadOnly) p.Set(value);
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = data.Application.ActiveUIDocument?.Document;
        try
        {
            if (doc is null || !doc.IsValidObject || doc.Title != "FH_Compact_Core_Study")
                throw new InvalidOperationException("Open the verified FH_Compact_Core_Study before running this disposable coordination study.");
            if (string.IsNullOrWhiteSpace(doc.PathName) || !File.Exists(doc.PathName))
                throw new InvalidOperationException("The compact-core source must be saved before creating a derivative.");

            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string output = Path.Combine(root, ".local", "revit-pilot", "stair-landing-coordination", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            string sourcePath = doc.PathName;
            string sourceHash = Hash(sourcePath);
            string studyPath = Path.Combine(output, "FH_Stair_Landing_Coordination_Study.rvt");
            doc.SaveAs(studyPath, new SaveAsOptions());

            var upperFloor = new FilteredElementCollector(doc).OfClass(typeof(Floor)).Cast<Floor>()
                .FirstOrDefault(f => f.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString()?.StartsWith("FH-C-FLOOR-UPPER", StringComparison.Ordinal) == true)
                ?? throw new InvalidOperationException("The source upper floor marker was not found.");
            var stair = new FilteredElementCollector(doc).OfClass(typeof(Stairs)).Cast<Stairs>()
                .FirstOrDefault(s => s.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.AsString()?.StartsWith("FH-C-STAIR-MAIN-UPPER", StringComparison.Ordinal) == true)
                ?? throw new InvalidOperationException("The source upper stair marker was not found.");
            var upperBox = upperFloor.get_BoundingBox(null) ?? throw new InvalidOperationException("Upper floor has no bounding box.");
            var stairBox = stair.get_BoundingBox(null) ?? throw new InvalidOperationException("Upper stair has no bounding box.");
            double gapFt = upperBox.Min.Y - stairBox.Max.Y;
            double widthFt = stairBox.Max.X - stairBox.Min.X;
            if (gapFt <= 0.01 || widthFt <= 0.01) throw new InvalidOperationException($"Expected a positive upper stair/floor gap; measured {gapFt:0.###} ft × {widthFt:0.###} ft.");

            Level upperLevel = (Level)doc.GetElement(upperFloor.LevelId)!;
            ElementId floorTypeId = Floor.GetDefaultFloorType(doc, false);
            if (floorTypeId == ElementId.InvalidElementId) throw new InvalidOperationException("No default floor type is available.");
            Floor landing;
            int routeCurves = 0;
            using (var tx = new Transaction(doc, "Create coordinated stair landing and circulation study"))
            {
                tx.Start();
                var loop = new CurveLoop();
                double z = upperLevel.Elevation;
                XYZ a = new(stairBox.Min.X, stairBox.Max.Y, z);
                XYZ b = new(stairBox.Max.X, stairBox.Max.Y, z);
                XYZ c = new(stairBox.Max.X, upperBox.Min.Y, z);
                XYZ d = new(stairBox.Min.X, upperBox.Min.Y, z);
                loop.Append(Line.CreateBound(a, b)); loop.Append(Line.CreateBound(b, c));
                loop.Append(Line.CreateBound(c, d)); loop.Append(Line.CreateBound(d, a));
                landing = Floor.Create(doc, new[] { loop }, floorTypeId, upperLevel.Id);
                Tag(landing, "FH-C-STAIR-LANDING-BRIDGE | PROVISIONAL | native stair-to-upper-floor connection");

                // A labelled circulation rectangle continues from the landing into the
                // existing upper floor. It is a route proxy, not a code-clearance claim.
                var sketch = SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, new XYZ(0, 0, z)));
                double routeDepthFt = Math.Min(4.0, Math.Max(1.0, upperBox.Max.Y - upperBox.Min.Y));
                XYZ[] route = { new(stairBox.Min.X, upperBox.Min.Y, z), new(stairBox.Max.X, upperBox.Min.Y, z), new(stairBox.Max.X, upperBox.Min.Y + routeDepthFt, z), new(stairBox.Min.X, upperBox.Min.Y + routeDepthFt, z) };
                for (int i = 0; i < route.Length; i++)
                {
                    var curve = doc.Create.NewModelCurve(Line.CreateBound(route[i], route[(i + 1) % route.Length]), sketch);
                    Tag(curve, "FH-C-UPPER-CIRCULATION-ROUTE | PROXY | 4 ft nominal depth; not code clearance");
                    routeCurves++;
                }
                tx.Commit();
            }
            doc.Save();
            string savedHash = Hash(studyPath);
            int stairCount = new FilteredElementCollector(doc).OfClass(typeof(Stairs)).GetElementCount();
            int floorCount = new FilteredElementCollector(doc).OfClass(typeof(Floor)).GetElementCount();
            var manifest = new
            {
                schema = "forever-home.native-stair-landing-coordination-v1",
                status = "disposable native stair/landing/floor/circulation comparison; Selected-D untouched",
                source_model_sha256 = sourceHash,
                saved_rvt = Path.GetFileName(studyPath), saved_rvt_sha256 = savedHash,
                stair = new { marker = "FH-C-STAIR-MAIN-UPPER", native_stair_count = stairCount, stair_element_id = stair.Id.Value },
                landing = new { marker = "FH-C-STAIR-LANDING-BRIDGE", element_id = landing.Id.Value, gap_ft = gapFt, width_ft = widthFt, area_sqft = gapFt * widthFt, level = upperLevel.Name },
                circulation = new { marker = "FH-C-UPPER-CIRCULATION-ROUTE", route_curve_count = routeCurves, nominal_width_ft = widthFt, nominal_depth_ft = Math.Min(4.0, Math.Max(1.0, upperBox.Max.Y - upperBox.Min.Y)), code_clearance_verified = false },
                floors = new { native_floor_count = floorCount, landing_floor_id = landing.Id.Value },
                limitations = new[] { "The source stair and floor assemblies remain provisional comparison geometry.", "The circulation rectangle is a route proxy, not a measured code or accessibility clearance.", "Headroom, guard/rail, structure, MEP, code, professional review and construction readiness remain unresolved." }
            };
            File.WriteAllText(Path.Combine(output, "stair-landing-coordination-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));

            bool ifcOk;
            using (var tx = new Transaction(doc, "Export coordinated stair landing IFC2x3"))
            {
                tx.Start();
                try { ifcOk = doc.Export(output, "FH_Stair_Landing_Coordination_Study", new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }); }
                finally { if (tx.GetStatus() == TransactionStatus.Started) tx.RollBack(); }
            }
            if (!ifcOk) throw new InvalidOperationException("Revit IFC export returned false.");
            TaskDialog.Show("Forever Home stair landing study", $"Disposable coordinated stair/landing study saved:\n{studyPath}");
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); return Result.Failed; }
    }
}
