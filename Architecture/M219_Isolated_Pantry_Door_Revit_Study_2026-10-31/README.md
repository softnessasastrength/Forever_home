# M219 — Isolated pantry-door Revit comparison

## Purpose and owner direction

Prepare a disposable native Revit comparison of the two pantry-door swing directions after the M218 schematic screen. The owner directed that **both** alternatives remain in the study. This is not a selection of swing, pantry location, pantry size, door product, or house geometry.

The generator creates two fresh Imperial projects from hash-pinned inputs: one with the nominal swing envelope into the kitchen, one into the pantry. Each contains lower, centered, and upper opening positions. West A remains protected for the unresolved M-06 half bath; east B remains unassigned.

## Source and scope gates

`Tools/RevitPilot/PantryDoorStudyCommand.cs` pins selected-D `study.json`, M215, M217, and M218 JSON hashes before generation. It refuses changed source files. It does not open or modify selected-D or any RFA. Outputs are written to a unique, ignored `.local/revit-pilot/m218-pantry-door-study/<UTC timestamp>/` directory.

The generated test projects contain 5 × 7 ft pantry test walls, a literal 2 ft 6 in shared-wall opening at three positions, the M-02 outline proxy, 36 × 36 in approach proxy, M215 route centerline, and 30 × 30 in swing-bound proxy. The nominal swing box is not a door leaf. The 10 ft test wall height and template wall type are harness-only values.

## Build and host run

Build the exact local RevitPilot assembly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/build.ps1 `
  -Dotnet .local/dotnet/dotnet.exe `
  -BuildDirectory build-m219-pantry-study
```

The verified build SHA256 is `643964517CFC4E87D1DCEC75C0050BFF40B1BD4C5D26403DB165F6848CA98B1A`. Its build-local manifest carries the authorised AddInId `096B0D51-8883-4B3D-BD31-E9622201E785` and resolves to this worktree. On 31 October, the existing per-user registration's exact AddInId was verified and its bytes preserved at `.local/revit-pilot/registration-backups/20261031T193038052Z/ForeverHome.Pilot.addin` (backup SHA256 `7F7FECAE3E70972EBF561602E2EF8393414AE3E26D77D81512C4887E74865CB7`). The matching registration now points to this exact DLL and the path/hash were rechecked. Revit remained open, so its current session has not loaded this changed registration; do not claim M219 loaded until a later launch and exact **Load Once** prompt verification.

When the supported Windows computer-use surface is available and the owner document state can be observed, restart Revit without closing unsaved owner work. Choose **Load Once** only if the prompt identifies this exact path and SHA. Run **Build M-218 pantry-door swing comparison** from the Forever Home ribbon. The command creates both RVTs, writes `m218-revit-study-manifest.json`, then opens the kitchen-swing derivative for inspection.

## Independent manifest/file-integrity gate

After Revit reports both files saved, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools/RevitPilot/validate_m218_revit_study.ps1 `
  -StudyDirectory .local/revit-pilot/m218-pantry-door-study/<UTC timestamp>
```

The PowerShell 5.1 fixture suite is:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File Tools/RevitPilot/test_validate_m218_revit_study.ps1
```

Current offline result: **5/5 validator fixtures pass**, including valid pair/hash acceptance and rejection of a changed RVT fingerprint, missing swing alternative, selected-D scope claim, and unexpected model-curve count. Fixture files are synthetic byte arrays, not Revit files. This only tests the manifest/file-identity gate; it is not evidence that Revit has generated either model.

M222 extends the production validator beyond this original file/hash/count gate. When the updated M222 command is run, it records each native tagged `Wall` and `ModelCurve` endpoint, wall height, and marker in the manifest; the PowerShell gate checks inventory shape, numeric bounds, marker uniqueness and per-opening-position distribution. This is a command-side audit, not an independent reopen of the RVT. See [M222](../M222_Native_Pantry_Study_Geometry_Audit_2026-10-31/README.md). Until the updated DLL is safely loaded and both models generated, no native geometry is verified.

## Current status and limitations

### 2026-11-01 runtime repair checkpoint

The current-source command was repaired after disposable Revit exposed API differences in Revit 2027: Levels do not expose the expected instance-comments marker, `ModelCurve` is not accepted as a direct native collector class, and model curves do not expose a writable ordinary marker parameter. The repaired v6 build narrows from `CurveElement` and records curve markers in a command-side in-memory map for the generated manifest audit. Build: 0 errors, 2 existing MSB3277 reference-conflict warning groups; DLL SHA256 `12FEB8CC6CEFB1E9970F480E30457C9E787A729D32DFF62E012EE707861F5495`. The exact AddInId/path were verified and prior registration bytes preserved under `.local/revit-pilot/registration-backups/`.

Revit displayed the exact project-local unsigned-add-in prompt and the owner-authorized **Load Once** action was used. The v6 run has not yet produced the two RVTs or `m218-revit-study-manifest.json`; this remains a runtime checkpoint, not native geometry verification. Signing the DLL would not by itself suppress the prompt without a trusted publisher certificate, and installing trust material is outside current authorization.

The original M219 build succeeded with 0 errors and 2 MSB3277 reference-resolution warning groups (`Microsoft.VisualBasic`, `System.Drawing`); DLL SHA256 was `643964517CFC4E87D1DCEC75C0050BFF40B1BD4C5D26403DB165F6848CA98B1A`. The exact manifest/AddInId/path/hash and preserved registration backup were verified. Revit displayed a Load Once prompt for that precise project-local DLL, and the owner-authorized one-time load was used. The command then failed before creating output because selected-D `study.json` has a UTF-8 BOM and `ReadPinnedJson` passed the marker directly to `System.Text.Json`.

M234 repairs the parser while keeping the SHA256 check over the original bytes. The rebuilt current-source DLL is `.local/revit-pilot/build-m232-bom-fix/Release/net10.0-windows/RevitPilot.dll`, SHA256 `FF5578C1CB386114260FBF08F59A421A7B04A24F3E2DFF3CF81CD6C4BE2B01BF`; its per-user manifest retains the authorized AddInId and exact in-repository path. Prior registration bytes are preserved at `.local/revit-pilot/registration-backups/20261031T203854666Z/ForeverHome.Pilot.addin` (SHA256 `FF9881DF0A46DCA759E5DF8A8D7977A513E5ECF112E06C5C6ACE8FC4A57BBAA8`). Build: 0 errors, 2 MSB3277 warning groups. Existing validator fixture suite passes 7/7.

After restarting Revit, the supported UI surface displays the trial introductory overlay, but its close target belongs to nested `msedgewebview2.exe` rather than the Revit window. The authorized close attempt and one fresh-target retry were rejected by the computer-use bridge. No M234 DLL Load Once prompt has been reached; no pantry comparison RVTs or manifest were generated. Do not target the nested process or change trust/security settings. Resume only when the supported Revit surface can dismiss the overlay; then verify the exact M234 path/hash prompt, choose Load Once, run the command, validate both RVTs, and independently inspect them.

No wall assembly, finish build-up, rough opening, jamb, threshold, hardware, exact hinge/leaf behavior, shelving, stocked contents, occupant maneuvering, MEP service route, or site is modeled. The proxies do not establish code compliance, accessibility, product fit, serviceability, structural adequacy, professional review, permit approval, or construction readiness. M-06/B remains unassigned.
