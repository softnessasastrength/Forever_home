# Revit 2027 compatibility pilot

Status: implementation fixture, not house geometry, an approved floor plan, or engineering.

## Scope and acceptance

Use a native Revit-hosted C# add-in to create a separate disposable project with four walls, one hosted door, one hosted window, one enclosed room, one mechanical-equipment envelope and one stair. Fixture dimensions are arbitrary test inputs. Source documents and any currently open project are not edited.

The command writes a new timestamped run under ignored `.local/revit-pilot/runs/` on every invocation. It attempts IFC2x3 Coordination View 2.0, AutoCAD 2010 DWG, PDF and CSV exports separately, records failures, saves native RVT/RFA, and reopens both source and backup to verify fixture element identities. Comments carry stable fixture IDs; room Number carries its ID too. Native UniqueIds are retained in JSON/CSV. IFC identity retention is measured rather than assumed.

The compact-core command is a separate study entry point. It writes `study-manifest.json` beside each generated RVT. Validate a host-generated manifest without opening Revit:

```powershell
./.venv/Scripts/python.exe Tools/RevitPilot/validate_compact_manifest.py .local/revit-pilot/compact-core/<run>/study-manifest.json
```

The validator checks the three C levels, 17 stable program IDs, five nominal door IDs, the 40 x 40 ft main target, the 8 x 8 ft lift reservation and unresolved-review flags. It does not certify geometry, code, accessibility or product fit.

Success requires actual in-Revit execution, all expected fixture objects, successful export calls, independently parsed IFC geometry, source/backup reopening, visual review of drawings, and a documented Revit 2018 import/loss assessment. Header checks alone do not validate drawings. Partial results must remain explicitly partial.

## Dependencies and build

- Windows x64, licensed/active Revit 2027, installed API DLLs, and English-Imperial family templates.
- .NET 10 SDK. The installed Revit API runtime configuration specifies `net10.0`; a runtime alone cannot compile this project.
- Existing repository Python environment with pinned IfcOpenShell and NumPy for export inspection.
- Revit 2018 for the fallback test; an independent drawing viewer for fidelity checks.

```powershell
./Tools/RevitPilot/build.ps1 -Dotnet './.local/dotnet/dotnet.exe'
```

No NuGet packages are required. `RevitInstallDir` in the project can be overridden for another installation. Build products, workspace marker, manifests with local paths, native models, family files and exports remain ignored. The build uses an isolated CLI home with telemetry disabled. A portable SDK may be extracted under `.local/dotnet`; verify its SHA512 against Microsoft's release metadata before use.

## Load and execute

1. Build and inspect the generated `ForeverHome.Pilot.addin` beside the DLL.
2. With filesystem authorization, copy that manifest to the per-user `%APPDATA%/Autodesk/Revit/Addins/2027/` directory. It points to the repository-local assembly. Do not overwrite a different existing add-in.
3. Restart Revit. Any add-in security/trust prompt requires the owner to handle it; do not bypass security settings.
4. In a project workspace, choose **Add-Ins → Forever Home Pilot → Run compatibility pilot**. A temporary blank workspace may be needed to expose the ribbon. The command creates its own separate document.
5. Inspect `run.json`; an unsuccessful command writes `failure.txt` instead. A finished command can still have failed exports.
6. Run the independent validator against that specific timestamped directory:

```powershell
./.venv/Scripts/python.exe Tools/RevitPilot/validate.py '.local/revit-pilot/runs/<timestamp>'
```

The validator writes SHA256 hashes and relative filenames to `manifest.json`, checks CSV/JSON identity consistency, IFC schema and geometry, expected IFC categories, ID retention, DWG version header and PDF header. Its nonzero exit code means at least one implemented check failed. It does not mark the remaining manual acceptance checks complete.

For another computer, package a validated run with `package.py <run_folder> <output_zip>`. It checks manifest hashes before packaging, adds the [2018 review checklist](2018_REVIEW.md), refuses to overwrite an existing ZIP, and verifies ZIP CRCs. Regenerate the manifest if adding review images before packaging. Keep the package local until the owner transfers it; no automatic upload is performed.

## Revit 2018 and visual review protocol

- Preserve the 2027 RVT/RFA; never attempt to overwrite them with reconstructed 2018 output.
- Open/link IFC2x3 in a separate 2018 project; record exact product/build and open versus link method.
- Inspect four walls, door/window host and openings, stair/run, equipment and room/space data. Compare dimensions, origin/units, IDs, categories, room area, appearance and available editing behavior against JSON/CSV and 2027.
- Inspect the DWG in a compatible viewer or separate 2018 import; compare plan dimensions and visible geometry.
- Render and inspect every PDF page; confirm legibility, bounds, expected geometry and absence of clipping.
- Record each result as pass, discrepancy, failure or not tested, with evidence. Imported geometry does not establish native parametric editability.
- Verify backup recovery independently of export success. Local same-disk duplicate reopening is not off-device disaster recovery.

## Sources

- Installed `RevitAPI.xml`, `RevitAPIUI.xml` and `RevitAPI.runtimeconfig.json` are the API/build references for this machine.
- [Autodesk: Revit 2027 SDK and .NET 10](https://blog.autodesk.io/revit-2027-sdk-net-10-api-changes-and-additions/).
- [Microsoft: Windows .NET installation](https://learn.microsoft.com/en-us/dotnet/core/install/windows).
- [Project version strategy](../../Decisions/Revit_2027_Authoritative_Model_2018_Fallback.md) and [coordination register CO-013](../../Project/Coordination_Register.md).
