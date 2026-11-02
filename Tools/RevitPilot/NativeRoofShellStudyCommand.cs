using Autodesk.Revit.Attributes;
using Autodesk.Revit.DB;
using Autodesk.Revit.UI;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Security.Cryptography;
using System.Text.Json;

namespace ForeverHome.Pilot;

/// <summary>
/// Builds a disposable native FootPrintRoof comparison from the documented
/// steep-gable options.  It deliberately does not select a pitch, datum,
/// assembly, structure, or code path.
/// </summary>
[Transaction(TransactionMode.Manual)]
public sealed class NativeRoofShellStudyCommand : IExternalCommand
{
    private const string SourceRelative = "Architecture/Selected_Design_Iteration_2026-10-27/study.json";
    private const string RoofBasisRelative = "Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/README.md";
    private const string ExpectedSourceHash = "516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB";
    private static readonly (string Label, double Rise, double Run)[] Cases =
    [
        ("8:12", 8, 12),
        ("10:12", 10, 12),
        ("12:12", 12, 12)
    ];

    public Result Execute(ExternalCommandData data, ref string message, ElementSet elements)
    {
        string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
        string root = File.ReadAllText(Path.Combine(assemblyDir, "workspace.txt")).Trim();
        string sourcePath = Path.Combine(root, SourceRelative.Replace('/', Path.DirectorySeparatorChar));
        string basisPath = Path.Combine(root, RoofBasisRelative.Replace('/', Path.DirectorySeparatorChar));
        string output = Path.Combine(root, ".local", "revit-pilot", "native-roof-shell",
            DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'", CultureInfo.InvariantCulture));
        Directory.CreateDirectory(output);

        try
        {
            byte[] sourceBytes = File.ReadAllBytes(sourcePath);
            string sourceHash = Convert.ToHexString(SHA256.HashData(sourceBytes));
            string basisHash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(basisPath)));
            if (sourceHash != ExpectedSourceHash)
                throw new InvalidDataException("The selected-D source changed; review it before generating the roof-shell study.");

            var records = new List<object>();
            using Document doc = data.Application.Application.NewProjectDocument(UnitSystem.Imperial);
            Level level = new FilteredElementCollector(doc).OfClass(typeof(Level)).Cast<Level>()
                .OrderBy(item => item.Elevation).FirstOrDefault()
                ?? throw new InvalidOperationException("The imperial template has no seed level.");
            string? activePath = null;
            using (Transaction tx = new(doc, "Build native roof-shell comparison"))
            {
                tx.Start();
                level.Name = "Local Eave Datum — Comparative Only";
                RoofType roofType = new FilteredElementCollector(doc).OfClass(typeof(RoofType)).Cast<RoofType>()
                    .OrderBy(item => item.Name, StringComparer.OrdinalIgnoreCase).FirstOrDefault()
                    ?? throw new InvalidOperationException("The Revit template contains no roof type.");

                const double width = 40.0;
                const double depth = 42.0;
                const double spacing = 52.0;
                foreach (var (label, rise, run) in Cases)
                {
                    double offset = records.Count * spacing;
                    var footprint = new CurveArray();
                    XYZ a = new(offset, 0, level.Elevation);
                    XYZ b = new(offset + width, 0, level.Elevation);
                    XYZ c = new(offset + width, depth, level.Elevation);
                    XYZ d = new(offset, depth, level.Elevation);
                    footprint.Append(Line.CreateBound(a, b));
                    footprint.Append(Line.CreateBound(b, c));
                    footprint.Append(Line.CreateBound(c, d));
                    footprint.Append(Line.CreateBound(d, a));

                    ModelCurveArray? modelCurves;
                    FootPrintRoof roof = doc.Create.NewFootPrintRoof(footprint, level, roofType, out modelCurves);
                    doc.Regenerate();
                    int curveIndex = 0;
                    foreach (ModelCurve curve in modelCurves)
                    {
                        // The two long edges are the gable eaves; the short
                        // edges remain horizontal.  The ratio is a comparison
                        // label only, not a structural or code calculation.
                        bool definesSlope = curveIndex is 0 or 2;
                        roof.set_DefinesSlope(curve, definesSlope);
                        if (definesSlope)
                            roof.set_SlopeAngle(curve, Math.Atan(rise / run));
                        curveIndex++;
                    }
                    roof.Name = $"FH-NATIVE-ROOF-SHELL; option={label}; ridge=long-axis; datum=relative";
                    Parameter? comments = roof.get_Parameter(BuiltInParameter.ALL_MODEL_INSTANCE_COMMENTS);
                    if (comments is not null && !comments.IsReadOnly)
                        comments.Set($"M333 native roof shell comparison; option={label}; rise={rise}; run={run}; no selection");
                    records.Add(new
                    {
                        option = label,
                        rise_ratio = rise,
                        run_ratio = run,
                        footprint_ft = new[] { width, depth },
                        display_offset_ft = offset,
                        element_id = roof.Id.Value,
                        native_category = "Roofs",
                        selected = false
                    });
                }
                tx.Commit();
            }

            int roofCount = new FilteredElementCollector(doc).OfCategory(BuiltInCategory.OST_Roofs).GetElementCount();
            if (roofCount != Cases.Length)
                throw new InvalidOperationException($"Expected {Cases.Length} native roofs; found {roofCount}.");
            activePath = Path.Combine(output, "FH_Native_Roof_Shell_Comparison.rvt");
            doc.SaveAs(activePath, new SaveAsOptions());
            string savedHash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(activePath)));

            string ifcPath = Path.Combine(output, "FH_Native_Roof_Shell_Comparison.ifc");
            bool ifcOk = false;
            using (Transaction exportTx = new(doc, "Export native roof IFC2x3"))
            {
                exportTx.Start();
                try
                {
                    using var options = new IFCExportOptions { FileVersion = IFCVersion.IFC2x3CV2, ExportBaseQuantities = true };
                    ifcOk = doc.Export(output, Path.GetFileNameWithoutExtension(ifcPath), options);
                }
                finally
                {
                    if (exportTx.GetStatus() == TransactionStatus.Started) exportTx.RollBack();
                }
            }
            string? ifcHash = File.Exists(ifcPath) ? Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(ifcPath))) : null;
            using (FileStream stream = File.Create(Path.Combine(output, "native-roof-shell-manifest.json")))
                JsonSerializer.Serialize(stream, new
                {
                    schema = "forever-home.native-roof-shell-v1",
                    status = "disposable native roof comparison; no pitch or roof assembly selected",
                    source = SourceRelative,
                    source_sha256 = sourceHash,
                    documented_roof_basis = RoofBasisRelative,
                    documented_roof_basis_sha256 = basisHash,
                    shell_ft = new[] { 40.0, 42.0 },
                    level = level.Name,
                    native_roof_count = roofCount,
                    roofs = records,
                    saved_rvt = Path.GetFileName(activePath),
                    saved_rvt_sha256 = savedHash,
                    ifc = new { file = Path.GetFileName(ifcPath), api_result = ifcOk, sha256 = ifcHash },
                    limitations = new[]
                    {
                        "The three roofs are side-by-side comparison options on a relative eave datum.",
                        "No option is selected; no wall height, floor-to-floor, assembly, framing, loading, overhang, opening, drainage or site datum is assigned.",
                        "This disposable study does not establish code compliance, structural safety, accessibility, professional approval, permit approval or construction readiness."
                    }
                }, new JsonSerializerOptions { WriteIndented = true });

            TaskDialog.Show("Forever Home", $"Disposable native roof-shell comparison saved to:\n\n{output}\n\nThree native FootPrintRoof options; no pitch selected.");
            return Result.Succeeded;
        }
        catch (Exception ex)
        {
            message = ex.ToString();
            TaskDialog.Show("Forever Home native roof-shell study failed", ex.Message);
            return Result.Failed;
        }
    }
}
