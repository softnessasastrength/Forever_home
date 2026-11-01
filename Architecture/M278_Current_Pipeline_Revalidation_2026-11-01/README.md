# M278 — Current source and IFC pipeline revalidation

**Date:** 2026-11-01`n**Status:** current source-generator and selected-D IFC evidence refreshed; complete architectural model remains outstanding.

## Selected-D source and Revit/IFC2X3 export

The checked-in selected-D study remains SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. Its latest Revit 2027.3 export is `.local/revit-pilot/selected-d/20261101T122301834Z/`:

- RVT SHA256: `6073D5F1174B4009AB7EE17F430E0F788687FDBD64BA755C381E08BD0C58FC05`.
- IFC2X3 SHA256: `E3B3C22C1CC58CEB8A1A7884CD122D90FD2337F372C2E9CD1CF293E4772ED999`.
- The independent `Tools/RevitPilot/validate_selected_d_ifc.py` run passes **26/26** checks, with zero errors and zero schema issues. It verifies matching study/run/source fingerprints, saved RVT/IFC lineage, three storeys, all 21 source-matching spaces/areas/levels/plan bounds/body profiles, and empty physical construction classes.
- The retained validation report is ignored at `.local/revalidation/active-selectedD-ifc/validation.json`, SHA256 `0AC0CDEA6D2589F6145C7F425BC99372C1DDD84C278173A597F6B3F3AE228FA9`.
- The protected Incoming Evolution RFA remains SHA256 `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`.

Reproduce the IFC-only validation from the repository root (this command validates an existing IFC; it does not fit geometry):

```powershell
New-Item -ItemType Directory -Force .local/revalidation/m278-ifc-replay | Out-Null
.\.venv\Scripts\python.exe Tools/RevitPilot/validate_selected_d_ifc.py .local/revit-pilot/selected-d/20261101T122301834Z --report .local/revalidation/m278-ifc-replay/validation.json
```

The previously documented full source-side PowerShell baseline runner was attempted, but this Windows PowerShell session rejects script execution under its default `Restricted` policy. No execution-policy bypass or security-setting change was used. M248 remains the last successful complete dual source-generation + retained IFC baseline run; M266 is the latest Revit-generated selected-D RVT/IFC pair and is revalidated here. This M278 report does not claim the selected-D PowerShell generator was rerun.

## C# roof comparison source

The repository-local .NET 10.0.403 SDK rebuilt `Tools/M83Generator/M83Generator.csproj` with **0 warnings and 0 errors**. Two isolated executions each pass **13/13** checks and produce byte-identical output. Current hashes in both `.local/revalidation/active-m83-a/` and `active-m83-b/`:

| Artifact | SHA256 |
|---|---|
| `roof-options.json` | `06CB5B290BD31D866C5EB45DF0A688C5CD1184A9C1DED6CD6435E5011A7E6248` |
| `checks.json` | `AA933972997934D6005E85651CB08C871B037BF003BFFFD76964BB2AB2F618F8` |
| `roof-options.svg` | `856BEDCA1DEB995E866000D6D668291983EFEB0646DDA93FD23CA69C857C1D05` |
| `manifest.json` | `3483A5C481BCD990CFE134253092A58E68849BF9FC14BFABF72A5DE1D706066A` |

The six 8:12/10:12/12:12 and two ridge-axis comparisons remain zero-thickness ideal roof surfaces on the hypothetical 38.333333 × 40 ft envelope. They contain no absolute eave datum, roof construction or native Revit roof. No pitch or axis is selected or technically approved.

## C# M-06 envelope source

`Tools/M274Generator/M274Generator.csproj` rebuilt with **0 warnings and 0 errors**. Two separate executions pass **15/15** and reproduce identical outputs:

| Artifact | SHA256 |
|---|---|
| `m274-report.json` | `3A29C9CB6F8DB5B523794416330B7EE446763ED91A7D3D60AFC30FFDBCC38B3A` |
| `m274-checks.json` | `F8C16A637AE37CD61F3F08B09FB997E3DE83971BED0AE2A90B94490417ED3A3A` |

This verifies the pinned M230/M269, selected-D and source-RFA inputs and the two measured Tresham bounding-envelope orientations against gross west A. It does not establish finished-face fit, fixture installation, door/swing/approach, service route or code applicability. M-06/A/B remain unassigned; west A remains protected.

## Reproduction commands

Use fresh output paths under ignored `.local/revalidation/` for each execution. The generators constrain M83 output to the repository and bind their inputs by hash; they create/overwrite named report files in the requested output directory, so do not reuse a retained evidence directory. M274 also writes directly into its requested directory. M274 requires the ignored M269 report at the exact path and hash below; a clean checkout without the authorized family-inspection evidence cannot replay it.

```powershell
.local/dotnet/dotnet.exe build Tools/M83Generator/M83Generator.csproj --configuration Release --output .local/revalidation/m278-replay-a/m83-build --ignore-failed-sources
.local/dotnet/dotnet.exe .local/revalidation/m278-replay-a/m83-build/M83Generator.dll .local/revalidation/m278-replay-a/m83-run-a
.local/dotnet/dotnet.exe .local/revalidation/m278-replay-a/m83-build/M83Generator.dll .local/revalidation/m278-replay-a/m83-run-b

.local/dotnet/dotnet.exe build Tools/M274Generator/M274Generator.csproj --configuration Release --output .local/revalidation/m278-replay-a/m274-build
.local/dotnet/dotnet.exe .local/revalidation/m278-replay-a/m274-build/M274Generator.dll Architecture/M230_West_A_Toilet_Lavatory_Envelopes_2026-10-31/artifacts/m230-report.json .local/revit-pilot/family-intake/derivatives/M269-Kohler-Tresham-Connector-Inspection-20261101/candidate-family-geometry.json Architecture/Selected_Design_Iteration_2026-10-27/study.json .local/revalidation/m278-replay-a/m274-run-a
.local/dotnet/dotnet.exe .local/revalidation/m278-replay-a/m274-build/M274Generator.dll Architecture/M230_West_A_Toilet_Lavatory_Envelopes_2026-10-31/artifacts/m230-report.json .local/revit-pilot/family-intake/derivatives/M269-Kohler-Tresham-Connector-Inspection-20261101/candidate-family-geometry.json Architecture/Selected_Design_Iteration_2026-10-27/study.json .local/revalidation/m278-replay-a/m274-run-b
```

Compare each pair's named JSON/SVG artifacts byte-for-byte or by SHA256. For an independent second replay, use a distinct sibling such as `.local/revalidation/m278-replay-b/` for every output path. The M269 Revit family report is ignored local evidence required by M274 and must match its pinned hash. A clean checkout without this disposable report cannot replay M274 until the authorized read-only family inspection is reproduced.

## Remaining model gap

The latest selected-D RVT/IFC remains a 21-space room-boundary study with no native walls, slabs/floors, doors, windows, stairs, roof, plumbing fixtures, MEP or structural elements. The IFC pass validates what the source contains; it does not turn the space study into a coordinated house. M-06 requires exact selected-product geometry, finished-face clearances, a defined door and arrival path, and a plausible service route before assignment. Revit is currently at Home with no project open; the supported UI bridge cannot bind to its window, so no new family inspection or disposable Revit derivative was created in M278.
