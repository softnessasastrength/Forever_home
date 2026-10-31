# M222 — Record native geometry for the pantry-door Revit comparison

**Status:** implementation and offline validator fixtures pass; host generation remains pending.

M219's two-project disposable generator now audits the saved model's tagged `Wall` and `ModelCurve` elements inside Revit before saving. The manifest records each element's marker and `LocationCurve` endpoints in Revit internal feet; walls also record their test height. The generator stops if the native inventory is not 13 walls and 48 model curves, or if markers are missing or duplicated.

The PowerShell 5.1 gate now checks each file's hash and byte count, inventory record counts, unique marker names, endpoint ranges, expected base/elevation and the 10-ft test wall height, plus per-position inventory distribution (4/5/4 walls and 16 model curves each). It still does not independently reopen the RVT; the inventory is produced by the exact Revit API command that generated it. This provides a command-side native geometry record and an independent manifest/geometry sanity gate, not a second independent Revit measurement.

## Reproduction and evidence

- Build: `.local/dotnet/dotnet.exe build Tools/RevitPilot/RevitPilot.csproj -c Release -o .local/revit-pilot/build-m222-native-audit/Release/net10.0-windows /p:BaseOutputPath=.local/revit-pilot/build-m222-native-audit/obj/`
- Result: **0 errors, 2 MSB3277 Revit reference-resolution warning groups** (Microsoft.VisualBasic and System.Drawing).
- DLL SHA256: `765E8749BCAF75F4855FC2F45711C0B0EFBDE17B89147F13D5049D8D576F1F01`.
- Fixture command: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/test_validate_m218_revit_study.ps1 -ResultPath .local/revalidation/M222-m218-native-geometry-audit.json`
- Result: **7/7** fixtures pass, including rejection of an out-of-envelope wall endpoint and a missing native geometry position. Fixture RVTs are synthetic bytes; this does not demonstrate Revit generation.

## Limits and next step

The Revit computer-use module import resolves, but the documented `@oai/sky` API exposes no `list_apps` method in this session, so no UI operation was attempted. Revit's current open-document state cannot be observed; no DLL was loaded, no Revit session was restarted, and no `.rvt` was generated. The M219 per-user registration still points at its prior DLL. When Revit can be safely controlled, prepare a backed-up registration for this exact M222 build, verify its path and SHA256, load only once, generate both alternatives, run the validator, and independently inspect both saved files.

Both swing directions remain in the study by owner choice. West A remains protected, east B remains unassigned, and the selected-D baseline is unchanged. The 5 × 7 ft pantry block, 10-ft test wall height and line/approach bounds are disposable harness values, not house dimensions, product geometry, a code determination, or construction specifications.
