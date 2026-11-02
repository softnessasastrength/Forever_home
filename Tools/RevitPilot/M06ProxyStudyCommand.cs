using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.DB.Structure;
using Autodesk.Revit.UI;
using Autodesk.Revit.ApplicationServices;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

/// <summary>
/// Builds one disposable M-06 comparison using the inspected TOTO Nexus family
/// as a labelled toilet proxy and the measured Evolution family as lavatory
/// evidence. It never opens Selected-D and never assigns room B.
/// </summary>
[Transaction(TransactionMode.Manual)]
public sealed class M06ProxyStudyCommand : IExternalCommand
{
    private const string ToiletRelative = ".local/revit-pilot/family-intake/candidates/toto-nexus-ms442124cefg.rfa";
    private const string SinkRelative = ".local/revit-pilot/family-intake/candidates/american-standard-evolution-0467004.020.rfa";
    private const string ToiletHash = "ACA931BF657DB567B4A45DC47F6CB526C6F701969ABDCF99EEE29FAF38BE72A0";
    private const string SinkHash = "39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA";

    private static string Sha256(string path)
    {
        using var stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete);
        return Convert.ToHexString(SHA256.HashData(stream));
    }

    private static Family LoadFamily(Application app, Document target, string path)
    {
        using Document family = app.OpenDocumentFile(path);
        return family.LoadFamily(target) ?? throw new InvalidOperationException($"Could not load family: {path}");
    }

    private static FamilySymbol PickSymbol(Document doc, Family family, string preferred)
    {
        var symbols = family.GetFamilySymbolIds().Select(id => doc.GetElement(id)).OfType<FamilySymbol>().ToList();
        return symbols.FirstOrDefault(s => string.Equals(s.Name, preferred, StringComparison.OrdinalIgnoreCase))
            ?? symbols.OrderBy(s => s.Name, StringComparer.OrdinalIgnoreCase).FirstOrDefault()
            ?? throw new InvalidOperationException($"Family '{family.Name}' has no symbols.");
    }

    private static FamilyInstance PlaceOnWall(Document doc, Wall wall, FamilySymbol symbol, XYZ point)
    {
        if (!symbol.IsActive) symbol.Activate();
        doc.Regenerate();
        var sideFaces = new List<(Reference Reference, PlanarFace Face)>();
        foreach (var side in new[] { ShellLayerType.Interior, ShellLayerType.Exterior })
        {
            foreach (var reference in HostObjectUtils.GetSideFaces(wall, side))
            {
                if (wall.GetGeometryObjectFromReference(reference) is PlanarFace face &&
                    face.FaceNormal.Z < 0.01 && Math.Abs(face.FaceNormal.X) + Math.Abs(face.FaceNormal.Y) > 0.99)
                    sideFaces.Add((reference, face));
            }
        }
        if (sideFaces.Count > 0)
        {
            var hostFace = sideFaces[0];
            var uv = hostFace.Face.GetBoundingBox();
            var hostPoint = hostFace.Face.Evaluate(new UV(
                Math.Clamp((point.X - hostFace.Face.Origin.X) * 0.5 + (uv.Min.U + uv.Max.U) * 0.25, uv.Min.U, uv.Max.U),
                Math.Clamp((point.Z - hostFace.Face.Origin.Z) * 0.5 + (uv.Min.V + uv.Max.V) * 0.25, uv.Min.V, uv.Max.V)));
            var orientation = Math.Abs(hostFace.Face.FaceNormal.Y) > 0.9 ? XYZ.BasisX : XYZ.BasisY;
            return doc.Create.NewFamilyInstance(hostFace.Reference, hostPoint, orientation, symbol);
        }
        try
        {
            return doc.Create.NewFamilyInstance(point, symbol, wall, StructuralType.NonStructural);
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"No referenceable wall face or wall-host placement for {symbol.Name}.", ex);
        }
    }

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
        string toiletPath = Path.Combine(root, ToiletRelative.Replace('/', Path.DirectorySeparatorChar));
        string sinkPath = Path.Combine(root, SinkRelative.Replace('/', Path.DirectorySeparatorChar));
        if (!StringComparer.OrdinalIgnoreCase.Equals(Sha256(toiletPath), ToiletHash)) throw new InvalidDataException("TOTO proxy hash mismatch.");
        if (!StringComparer.OrdinalIgnoreCase.Equals(Sha256(sinkPath), SinkHash)) throw new InvalidDataException("Evolution source hash mismatch.");

        string output = Path.Combine(root, ".local", "revit-pilot", "m06-proxy-study", DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'", CultureInfo.InvariantCulture));
        Directory.CreateDirectory(output);
        Document? doc = null;
        string? rvt = null;
        string? ifc = null;
        var records = new List<object>();
        try
        {
            doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            Level level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>().OrderBy(x => x.Elevation).First();
            Family toiletFamily = LoadFamily(data.Application.Application, doc, toiletPath);
            Family sinkFamily = LoadFamily(data.Application.Application, doc, sinkPath);
            FamilySymbol toilet = PickSymbol(doc, toiletFamily, "CST442CUFG");
            FamilySymbol sink = PickSymbol(doc, sinkFamily, "0467.400");
            using (Transaction tx = new(doc, "Build disposable M-06 proxy comparison"))
            {
                tx.Start();
                level.Name = "M-06 Proxy Zero — Unassigned";
                WallType wallType = new FilteredElementCollector(doc).OfClass(typeof(WallType)).Cast<WallType>().Where(x => x.Kind == WallKind.Basic).OrderBy(x => x.Name).First();
                double w = 158.0 / 12.0, d = 84.0 / 12.0, h = 10.0;
                Wall west = Wall.Create(doc, Line.CreateBound(new XYZ(0, 0, 0), new XYZ(0, d, 0)), wallType.Id, level.Id, h, 0, false, false);
                Wall north = Wall.Create(doc, Line.CreateBound(new XYZ(0, d, 0), new XYZ(w, d, 0)), wallType.Id, level.Id, h, 0, false, false);
                Wall east = Wall.Create(doc, Line.CreateBound(new XYZ(w, d, 0), new XYZ(w, 0, 0)), wallType.Id, level.Id, h, 0, false, false);
                Wall south = Wall.Create(doc, Line.CreateBound(new XYZ(w, 0, 0), new XYZ(0, 0, 0)), wallType.Id, level.Id, h, 0, false, false);
                var toiletInstance = PlaceOnWall(doc, west, toilet, new XYZ(0, d / 2, 0));
                var sinkInstance = PlaceOnWall(doc, north, sink, new XYZ(w * .65, d, 0));
                foreach (var item in new[] { (kind: "toilet_proxy", sku: "MS442124CEFG", instance: toiletInstance), (kind: "lavatory_evidence", sku: "0467400.020", instance: sinkInstance) })
                    records.Add(new { item.kind, item.sku, element_id = item.instance.Id.Value, family = item.instance.Symbol.FamilyName, selected = false });
                doc.Regenerate();
                tx.Commit();
            }
            rvt = Path.Combine(output, "FH_M06_Proxy_Setup.rvt");
            doc.SaveAs(rvt, new SaveAsOptions());
            ifc = Path.Combine(output, "FH_M06_Proxy_Setup.ifc");
            bool ifcOk;
            using (Transaction tx = new(doc, "Export disposable M-06 proxy IFC2x3"))
            {
                tx.Start();
                try { using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; ifcOk = doc.Export(output, "FH_M06_Proxy_Setup", options); }
                finally { if (tx.GetStatus() == TransactionStatus.Started) tx.RollBack(); }
            }
            doc.Dispose(); doc = null;
            var manifest = new
            {
                schema = "forever-home-m06-proxy-study-v1",
                status = "disposable proxy comparison; not selected and B unassigned",
                owner_intent = "American Standard Champion PRO 610AA001.020",
                toilet_proxy = new { sku = "MS442124CEFG", rfa_sha256 = ToiletHash, product = "TOTO Nexus", measured_plan_in = new[] { 18.5, 28.625 } },
                lavatory_evidence = new { sku = "0467400.020", rfa_sha256 = SinkHash, product = "American Standard Evolution", measured_envelope_in = new[] { 22.0, 17.5052, 34.25 } },
                gross_window_in = new[] { 158.0, 84.0 }, records,
                saved_rvt = Path.GetFileName(rvt), saved_rvt_sha256 = Sha256(rvt),
                ifc = new { file = Path.GetFileName(ifc), api_result = ifcOk, sha256 = File.Exists(ifc) ? Sha256(ifc) : null },
                gates = new { exact_owner_product_geometry = false, finished_face_clearance = false, door_and_approach = false, service_route = false, room_B_assignment = false }
            };
            File.WriteAllText(Path.Combine(output, "m06-proxy-study-manifest.json"), JsonSerializer.Serialize(manifest, new JsonSerializerOptions { WriteIndented = true }));
            TaskDialog.Show("Forever Home M-06 proxy", $"Disposable M-06 proxy study saved. B remains unassigned.\n{output}");
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            try { doc?.Dispose(); } catch { }
            return Result.Failed;
        }
    }
}
