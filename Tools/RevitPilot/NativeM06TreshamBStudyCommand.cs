using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Structure;
using Autodesk.Revit.UI;
using ForeverHome.Pilot.Core;
using System.IO;
using System.Reflection;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class NativeM06TreshamBStudyCommand : IExternalCommand
{
    private const string SourceRelative = ".local/revit-pilot/family-intake/candidates/kohler-tresham-k-2844-4-0.rfa";
    private const string SourceSha256 = "3b1cbdaa844d35bd462f6e59a828b82f7870fde4ee7397bac09f4ca0c2f9b949";
    private static double Ft(double inches) => inches / 12.0;
    private static void Tag(Element e, string value) => e.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS)?.Set(value);

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? doc = null;
        try
        {
            string root = WorkspaceLocator.Find(Assembly.GetExecutingAssembly());
            string sourcePath = Path.Combine(root, SourceRelative.Replace('/', Path.DirectorySeparatorChar));
            if (!File.Exists(sourcePath)) throw new FileNotFoundException("Pinned Tresham RFA is missing.", sourcePath);
            string before = StudyArtifactContract.Sha256File(sourcePath);
            if (!before.Equals(SourceSha256, StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Tresham source hash mismatch.");
            string output = Path.Combine(root, ".local", "revit-pilot", "m06-tresham-b-study", DateTime.UtcNow.ToString("yyyyMMddTHHmmssfffZ"));
            Directory.CreateDirectory(output);
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            Family family;
            using (var familyDoc = data.Application.Application.OpenDocumentFile(sourcePath))
                family = familyDoc.LoadFamily(doc) ?? throw new InvalidOperationException("Tresham family did not load into the disposable project.");
            var symbol = family.GetFamilySymbolIds().Select(id => doc.GetElement(id)).OfType<FamilySymbol>().OrderBy(x => x.Name, StringComparer.OrdinalIgnoreCase).First();
            int familyInstances = 0;
            using (var tx = new Transaction(doc, "Build disposable M-06 Tresham/B study"))
            {
                tx.Start();
                var level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).First();
                level.Name = "M-06/B disposable study datum - unassigned";
                Tag(level, "FH-M371 | M-06/B gross-pair comparison | not Selected-D");
                var wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().First(x => x.Kind == WallKind.Basic);
                // Run the synthetic host north/south so its side-face normal is X;
                // Revit rejects an insertion direction parallel to the face normal.
                var host = Wall.Create(doc, Line.CreateBound(new XYZ(0, 0, 0), new XYZ(0, 10, 0)), wallType.Id, level.Id, 10, 0, false, false);
                Tag(host, "FH-M372 | synthetic host only | not house geometry");
                if (!symbol.IsActive) { symbol.Activate(); doc.Regenerate(); }
                var faceRef = HostObjectUtils.GetSideFaces(host, ShellLayerType.Interior).First();
                var face = host.GetGeometryObjectFromReference(faceRef) as PlanarFace ?? throw new InvalidOperationException("No synthetic host face.");
                var uv = face.GetBoundingBox();
                var point = face.Evaluate(new UV((uv.Min.U + uv.Max.U) / 2, (uv.Min.V + uv.Max.V) / 2));
                var lav = doc.Create.NewFamilyInstance(faceRef, point, XYZ.BasisY, symbol);
                Tag(lav, "FH-M372 | KOHLER Tresham K-2844-4 | owner-approved lavatory direction | gross-pair proxy | unassigned");
                familyInstances++;

                var toilet = DirectShape.CreateElement(doc, new ElementId(BuiltInCategory.OST_GenericModel));
                var loop = new CurveLoop();
                double x = Ft(15), y = Ft(24), w = Ft(19), d = Ft(30.25), h = Ft(17);
                loop.Append(Line.CreateBound(new XYZ(x - w / 2, y, 0), new XYZ(x + w / 2, y, 0)));
                loop.Append(Line.CreateBound(new XYZ(x + w / 2, y, 0), new XYZ(x + w / 2, y + d, 0)));
                loop.Append(Line.CreateBound(new XYZ(x + w / 2, y + d, 0), new XYZ(x - w / 2, y + d, 0)));
                loop.Append(Line.CreateBound(new XYZ(x - w / 2, y + d, 0), new XYZ(x - w / 2, y, 0)));
                toilet.SetShape(new GeometryObject[] { GeometryCreationUtilities.CreateExtrusionGeometry(new[] { loop }, XYZ.BasisZ, h) });
                Tag(toilet, "FH-M372 | American Standard 610AA001.020 plan proxy 19 x 30.25 in | not exact SKU solid | unassigned");

                void Marker(XYZ a, XYZ b, string text)
                {
                    var curve = doc.Create.NewModelCurve(Line.CreateBound(a, b), SketchPlane.Create(doc, Plane.CreateByNormalAndOrigin(XYZ.BasisZ, XYZ.Zero)));
                    Tag(curve, text);
                }
                Marker(new XYZ(Ft(0), Ft(70), 0), new XYZ(Ft(36), Ft(70), 0), "FH-M372 | 36 in door/approach reservation | unresolved leaf/swing | no room assignment");
                Marker(new XYZ(Ft(0), Ft(78), 0), new XYZ(Ft(60), Ft(78), 0), "FH-M372 | lower-MEP route marker only | no supply/drain/vent network");
                var viewType = new FilteredElementCollector(doc).OfClass(typeof(ViewFamilyType)).Cast<ViewFamilyType>().First(x => x.ViewFamily == ViewFamily.ThreeDimensional);
                var view = View3D.CreateIsometric(doc, viewType.Id); view.Name = "M-06 Tresham/B disposable gross-pair study";
                tx.Commit();
            }
            if (familyInstances != 1) throw new InvalidDataException("Expected one Tresham instance.");
            string rvt = Path.Combine(output, "FH_M06_Tresham_B_Study.rvt");
            string ifc = Path.Combine(output, "FH_M06_Tresham_B_Study.ifc");
            doc.SaveAs(rvt, new SaveAsOptions { OverwriteExistingFile = true });
            bool exported;
            using (var tx = new Transaction(doc, "Export M-06 disposable study IFC2x3"))
            {
                tx.Start();
                try { using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; exported = doc.Export(output, Path.GetFileNameWithoutExtension(ifc), options); }
                finally { if (tx.GetStatus() == TransactionStatus.Started) tx.RollBack(); }
            }
            if (!exported) throw new InvalidOperationException("IFC export returned false.");
            string symbolName = symbol.Name;
            doc.Close(false); doc = null;
            var manifest = new
            {
                schema = "forever-home-m372-m06-tresham-b-study-v1",
                status = "disposable native family/proxy comparison; M-06/B remains unassigned and fit-blocked",
                source = SourceRelative, source_sha256 = before, family = "kohler-tresham-k-2844-4-0", type = symbolName,
                family_instances = familyInstances, toilet_proxy = new { sku = "610AA001.020", width_in = 19.0, projection_in = 30.25 },
                door_approach_supported = false, service_route_supported = false, selected = false,
                saved_rvt = Path.GetFileName(rvt), saved_rvt_sha256 = StudyArtifactContract.Sha256File(rvt), ifc = Path.GetFileName(ifc), ifc_sha256 = StudyArtifactContract.Sha256File(ifc), ifc2x3 = File.ReadAllText(ifc).Contains("FILE_SCHEMA(('IFC2X3'))", StringComparison.Ordinal),
                limitations = new[] { "Tresham is hosted on a synthetic wall for orientation only; host is not house geometry.", "Toilet is a labelled plan proxy, not an exact current-SKU solid.", "Door/approach and lower-MEP markers are reservations only; no clear leaf, swing, rough-in, slope, vent or network is modelled.", "No code, accessibility, structural, professional, permit or construction conclusion follows. Selected-D and the Evolution RFA are untouched." }
            };
            StudyArtifactContract.WriteJson(Path.Combine(output, "m06-tresham-b-study-manifest.json"), manifest);
            TaskDialog.Show("Forever Home M-06 study", $"Disposable Tresham/B study saved:\n{output}");
            return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); if (doc is not null && doc.IsValidObject) doc.Close(false); return Result.Failed; }
    }
}
