# M311 — Clear-ceiling wall-height comparison

Date: 2026-11-01  
Status: **command build verified; Revit runtime pending**

## Selected inputs

The owner selected the Selected-D envelope as the current dimensional basis and chose an 8/9/10-ft clear-ceiling study range, with the stair and floor-to-floor relationship unresolved. The source-linked register is [`../Dimension_Register.md`](../Dimension_Register.md); the geometry rules are [`../../Decisions/2026-11-02_Clear_Ceiling_Height_Study_Basis.md`](../../Decisions/2026-11-02_Clear_Ceiling_Height_Study_Basis.md).

The proposed comparison command creates three separate single-level RVTs: main 40 × 42 ft, lower 36 × 32 ft, and upper 36 × 32 ft. Each has four perimeter walls for each 8/9/10-ft wall-top reference. The three cases are translated in model space only so their heights can be compared. Each file has one local zero level; it does not place the envelopes as connected floors or assign building elevations. No interior partitions, doors, windows, floors, ceilings, stairs, roofs, structure, MEP or site context are included. The template Basic Wall type and its thickness are explicitly unselected placeholders.

## Build

From the repository root in Windows PowerShell:

```powershell
./Tools/RevitPilot/build.ps1 -BuildDirectory 'clear-ceiling-wall-height'
```

Build result on 2026-11-01: **0 errors; 2 MSB3277 reference-version conflict warnings**. Project-local DLL SHA256: `CD6C25394F13C9F42C4E96D563DAA37D22DBB185AEBBF50552B734A6206D4341`.

The per-user registration was checked against the authorized AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`; the assembly path resolves inside this checkout to the hash above. Prior registration was preserved at `.local/revit-pilot/registration-backups/20261101T133836441/`. Revit was restarted. No trust-wide option was changed and no **Always Load** choice was made.

## Runtime and verification — pending

The computer-use bridge repeatedly failed with `foreground window did not report a process id` while opening a blank Revit project. No M311 command execution occurred and no RVT or model manifest exists yet. Do not cite this report as evidence that native geometry has been generated.

After a controllable Revit project window is available, run **Forever Home Pilot → Build clear-height wall comparison**. The command writes a timestamped run under ignored `.local/revit-pilot/clear-ceiling-wall-height/`. Verify `comparison-index.json`, all three per-model JSON files, saved RVT hashes, twelve wall instances and one local level per file, exact 8/9/10-ft case values, and zero floors/ceilings/doors/windows/stairs/roofs. Reopen and inspect each saved isometric view; the saved hashes should remain unchanged after closing Revit.

## Baseline validation

While the native command was pending, the current Selected-D geometry/IFC baseline was rerun without overwriting tracked or retained model outputs:

```powershell
./Tools/validate_architectural_bim_baseline.ps1 `
  -ExportDirectory '.local/revit-pilot/selected-d/20261101T122301834Z' `
  -OutputDirectory '.local/revalidation/selected-d-ceiling-check-20261101T133722663Z'
```

Result: two source regenerations passed **43/43** checks each, seven artifacts matched byte-for-byte, three SVG plans parsed per run, and retained IFC2X3 passed **26/26** checks with zero errors. Selected-D source/RVT/IFC fingerprints remained unchanged. This validates the existing 21-space boundary study; it does not validate M311 because no M311 RVT or IFC was produced.

## Limitations

Even after runtime completion, these models remain footprint-specific shell comparisons, not the coordinated multi-storey house. No assembly is assigned, so a wall-top reference does not define an approved floor-to-floor height or complete ceiling construction. The stair remains unresolved. No code, accessibility, structural, professional, permit or construction-readiness finding follows.

## M311 transaction review follow-up

Moved the base-level rename inside the Revit transaction; the previous build would attempt a document modification outside a transaction. Rebuilt with 0 errors and 2 existing MSB3277 warnings. Corrected DLL: ignored .local/revit-pilot/clear-ceiling-wall-height-transaction-fix/Release/net10.0-windows/RevitPilot.dll; SHA256 DF03D04175FF19A9192A3AF8A18196F629BA09147DEF18FA4BFF3588A5305320. This corrected build is staged, not registered or runtime verified. The per-user manifest still references the preceding build; do not run that preceding build. Next: register the corrected build using AGENTS.md backup/path/hash checks, restart Revit and validate runtime outputs. No model generation occurred in this follow-up.

M311 registration follow-up: the corrected transaction-fix DLL SHA256 DF03D04175FF19A9192A3AF8A18196F629BA09147DEF18FA4BFF3588A5305320 is now registered with the authorized AddInId and a verified in-checkout assembly path. Previous manifest preserved under ignored .local/revit-pilot/registration-backups/20261101T134453327/. Revit remains at Home; fresh computer-use window recovery failed with "id must be an integer >= 0" despite a returned numeric window ID. Restart and runtime execution remain pending; no M311 RVT exists. This supersedes earlier notes saying the corrected DLL is unregistered.

M311 native runtime succeeded after owner invocation, 2026-11-01: run .local/revit-pilot/clear-ceiling-wall-height/20261101T185016177Z contains comparison-index.json, three per-model manifests and three RVTs. Revit journal records successful save and completion dialog. Independent PowerShell checks confirm all input fingerprints and saved RVT hashes, three models, 12 wall records and one local level per model, four walls in each 8/9/10-ft case, zero base elevation, exact selected-D footprint edge lengths, and zero reported floors/ceilings/doors/windows/stairs/roofs. Evidence validation-powershell.json in the run folder. This is manifest/file validation plus in-command runtime counts; independent reopened RVT inventory and visual inspection remain pending. These are three isolated footprint height comparisons, not a coordinated house or a new IFC export. This supersedes earlier statements that no M311 RVT exists.
