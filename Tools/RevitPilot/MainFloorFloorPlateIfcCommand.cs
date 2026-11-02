using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class MainFloorFloorPlateIfcCommand : IExternalCommand
{
    const string RelativeRoot = ".local/revit-pilot/main-floor-floor-plate";
    static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? opened = null; string? copy = null;
        try
        {
            string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string baseDir = Path.Combine(root, RelativeRoot);
            string run = Directory.EnumerateDirectories(baseDir).OrderByDescending(Directory.GetLastWriteTimeUtc).First();
            using var mdoc = JsonDocument.Parse(File.ReadAllText(Path.Combine(run, "floor-plate-manifest.json")));
            var m = mdoc.RootElement;
            string rvt = Path.Combine(run, m.GetProperty("saved_rvt").GetString()!);
            if (!Hash(rvt).Equals(m.GetProperty("saved_rvt_sha256").GetString(), StringComparison.OrdinalIgnoreCase)) throw new InvalidDataException("Floor-plate RVT hash mismatch.");
            copy = Path.Combine(run, Path.GetFileNameWithoutExtension(rvt) + "_ifc-export.rvt"); File.Copy(rvt, copy, true);
            opened = data.Application.Application.OpenDocumentFile(copy);
            string dir = Path.Combine(run, "ifc2x3"); Directory.CreateDirectory(dir); string name = Path.GetFileNameWithoutExtension(rvt);
            var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true }; options.AddOption("ExportInternalRevitPropertySets", "true");
            bool ok; using (var tx = new Transaction(opened, "Export provisional floor plate IFC2x3")) { tx.Start(); ok = opened.Export(dir, name, options); tx.Commit(); }
            string ifc = Path.Combine(dir, name + ".ifc"); if (!ok || !File.Exists(ifc) || new FileInfo(ifc).Length == 0) throw new InvalidOperationException("IFC export produced no non-empty file.");
            var result = new { schema = "forever-home-main-floor-floor-plate-ifc-v1", status = "isolated disposable export; provisional floor type only", source_run = Path.GetRelativePath(root, run).Replace('\\','/'), saved_rvt = Path.GetFileName(rvt), saved_rvt_sha256 = Hash(rvt), ifc = Path.GetRelativePath(root, ifc).Replace('\\','/'), ifc_sha256 = Hash(ifc), ifc_bytes = new FileInfo(ifc).Length, ifc_version = "IFC2x3CV2", limitations = new[] { "IFC export integrity only; floor assembly is not selected.", "No code, structural, professional or construction approval." } };
            File.WriteAllText(Path.Combine(run, "ifc-manifest.json"), JsonSerializer.Serialize(result, new JsonSerializerOptions { WriteIndented = true }));
            opened.Close(false); opened = null; if (File.Exists(copy)) File.Delete(copy); copy = null; TaskDialog.Show("Forever Home", "Disposable floor-plate IFC2x3 exported:\n" + ifc); return Result.Succeeded;
        }
        catch (Exception ex) { message = ex.ToString(); if (opened is not null && opened.IsValidObject) opened.Close(false); if (copy is not null && File.Exists(copy)) File.Delete(copy); TaskDialog.Show("Floor-plate IFC export failed", ex.Message); return Result.Failed; }
    }
}
