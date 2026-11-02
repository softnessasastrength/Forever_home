using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.IO;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

[Transaction(TransactionMode.Manual)]
public sealed class MainFloorCandidateIfcCommand : IExternalCommand
{
    const string RelativeRoot = ".local/revit-pilot/main-floor-candidate";
    const string ManifestName = "manifest.json";

    static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        Document? opened = null;
        string? openedCopy = null;
        bool ownsOpenedDocument = false;
        try
        {
            string root = File.ReadAllText(Path.Combine(Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location)!, "workspace.txt")).Trim();
            string baseDir = Path.Combine(root, RelativeRoot);
            string run = Directory.EnumerateDirectories(baseDir)
                .OrderByDescending(Directory.GetLastWriteTimeUtc)
                .FirstOrDefault() ?? throw new InvalidOperationException("No main-floor candidate run exists.");
            string manifestPath = Path.Combine(run, ManifestName);
            using var manifest = JsonDocument.Parse(File.ReadAllText(manifestPath));
            var m = manifest.RootElement;
            string rvt = Path.Combine(run, m.GetProperty("saved_rvt").GetString()!);
            if (!File.Exists(rvt) || !Hash(rvt).Equals(m.GetProperty("saved_rvt_sha256").GetString(), StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Candidate RVT is missing or its manifest hash does not match.");

            // Always export from a byte-identical derivative. This avoids Revit's
            // application-level lock on the generated source RVT while preserving it.
            openedCopy = Path.Combine(run, Path.GetFileNameWithoutExtension(rvt) + "_ifc-export.rvt");
            File.Copy(rvt, openedCopy, true);
            opened = data.Application.Application.OpenDocumentFile(openedCopy);
            ownsOpenedDocument = true;
            string exportDir = Path.Combine(run, "ifc2x3");
            Directory.CreateDirectory(exportDir);
            string name = Path.GetFileNameWithoutExtension(rvt);
            var options = new IFCExportOptions
            {
                FileVersion = IFCVersion.IFC2x3CV2,
                ExportBaseQuantities = true
            };
            options.AddOption("ExportInternalRevitPropertySets", "true");
            bool ok;
            using (var exportTransaction = new Transaction(opened, "Export isolated main-floor candidate IFC2x3"))
            {
                exportTransaction.Start();
                ok = opened.Export(exportDir, name, options);
                exportTransaction.Commit();
            }
            string ifc = Path.Combine(exportDir, name + ".ifc");
            if (!ok || !File.Exists(ifc) || new FileInfo(ifc).Length == 0)
                throw new InvalidOperationException("Revit IFC export did not produce a non-empty IFC2x3 file.");

            var result = new
            {
                schema = "forever-home-main-floor-candidate-ifc-v1",
                status = "isolated disposable export; no selected-D or construction approval",
                source_run = Path.GetRelativePath(root, run).Replace('\\', '/'),
                saved_rvt = Path.GetFileName(rvt),
                saved_rvt_sha256 = Hash(rvt),
                ifc = Path.GetRelativePath(root, ifc).Replace('\\', '/'),
                ifc_sha256 = Hash(ifc),
                ifc_bytes = new FileInfo(ifc).Length,
                ifc_version = "IFC2x3CV2",
                limitations = new[]
                {
                    "Export validates API/file creation only; physical wall assemblies, doors, floors, stairs, roof, structure, MEP and code review remain unresolved.",
                    "The source run is an unselected comparison derivative; it is not the selected-D baseline."
                }
            };
            File.WriteAllText(Path.Combine(run, "ifc-manifest.json"), JsonSerializer.Serialize(result, new JsonSerializerOptions { WriteIndented = true }));
            if (ownsOpenedDocument) opened.Close(false);
            opened = null;
            if (openedCopy is not null && File.Exists(openedCopy)) File.Delete(openedCopy);
            TaskDialog.Show("Forever Home", "Disposable main-floor IFC2x3 exported:\n" + ifc);
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            if (ownsOpenedDocument && opened is not null && opened.IsValidObject) opened.Close(false);
            if (openedCopy is not null && File.Exists(openedCopy)) File.Delete(openedCopy);
            TaskDialog.Show("Main-floor IFC export failed", ex.Message);
            return Result.Failed;
        }
    }
}
