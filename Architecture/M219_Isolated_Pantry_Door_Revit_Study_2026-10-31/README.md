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

The verified build SHA256 is `643964517CFC4E87D1DCEC75C0050BFF40B1BD4C5D26403DB165F6848CA98B1A`. Its build-local manifest carries the authorised AddInId `096B0D51-8883-4B3D-BD31-E9622201E785` and resolves to this worktree. The per-user Revit manifest currently points to an older M-189 build. No manifest replacement or add-in load has been performed for M219.

When the supported Windows computer-use surface is available, install the verified build-local manifest under the repository's exact AddInId/back-up procedure in `AGENTS.md`, restart Revit, and choose **Load Once** only if the prompt identifies this exact path and SHA. Run **Build M-218 pantry-door swing comparison** from the Forever Home ribbon. Do not close unsaved owner documents. The command creates both RVTs, writes `m218-revit-study-manifest.json`, then opens the kitchen-swing derivative for inspection.

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

The production validator checks schema/status, all four pinned source hashes, isolated scope flags, both unique swing alternatives, each RVT's size and SHA256, reported counts (13 walls and 48 model curves per file), and preservation of A/B status. It explicitly does **not** inspect native RVT geometry. After a host run, inspect both files in Revit and capture native read-only audits or equivalent element inventory before treating the geometry as verified.

## Current status and limitations

The M219 build succeeded with 0 errors and 2 MSB3277 reference-resolution warnings (`Microsoft.VisualBasic`, `System.Drawing`). The required `node_repl`/`@oai/sky` computer-use pipe was unavailable, including after the prescribed reconnect attempt. Consequently, no M219 DLL was loaded, no per-user manifest was replaced, and no RVTs were generated. This is the present execution blocker.

No wall assembly, finish build-up, rough opening, jamb, threshold, hardware, exact hinge/leaf behavior, shelving, stocked contents, occupant maneuvering, MEP service route, or site is modeled. The proxies do not establish code compliance, accessibility, product fit, serviceability, structural adequacy, professional review, permit approval, or construction readiness. M-06/B remains unassigned.
