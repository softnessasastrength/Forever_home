# M152 — Owner-directed larger upper-shell revalidation

Status: the owner selected continued exploration of the 38⅓ × 40 ft hypothetical upper shell after the 36 × 32 ft selected-D-derived wing did not support the sampled room packing and route. This revalidates the existing M78 study; it does not adopt a house dimension or revise selected D.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope balanced -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds `
  -NodeLimit 4000 -LayoutLimit 5000 -OutputDirectory .local/revalidation/M152-M78

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_upper_suite_candidate.ps1 `
  .local/revalidation/M152-M78 -TestShellWidthFt 38.333333 -TestShellDepthFt 40

.\.venv\Scripts\python.exe Tools\RevitPilot\validate_upper_suite_ifc.py `
  .local\revit-pilot\upper-suite\20261030T200906834Z `
  --report .local\revalidation\M152-M78-ifc.json
```

The generation command produces four artifacts in ignored scratch storage. Compare their SHA256 values against the retained M78 package under `Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/`.

## Results

- Fresh Windows PowerShell 5.1 replay passes **28/28** integrity checks: 3,996/4,000 nodes expanded, 457 complete room packings recorded, and all 457 route-tested. The bounded search remains incomplete.
- Independent candidate validation passes **112/112**. The owner-directed candidate reaches sampled hall goals at U-01, U-02 and U-04; U-02's sampled edge is north. The candidate retains U-01 → C-PRIVATE → U-02 → U-03, private-only U-03 access, primary-only U-05, and both Jack-and-Jill links through U-06.
- Fresh JSON, checks, SVG and manifest match the retained M78 package byte-for-byte: `f23fae3a197108ee9099cdd8b3a28d58b6f32dee1e4c1f12537888f88c679467`, `43e6ccdfd04f91675063c4a044d3826d2ec12a97d1299216354b62fa61a6c042`, `27c4cc47bdcb0e3e371d1363204aebca1d236bfe29ab61ab1e37bfafe57190e7`, `a7e4dede04d3fd5615546cbb7b6045df40929826bfc5f23e12d0109ffcd08269`.
- The retained disposable Revit 2027.3.0.28 derivative IFC2X3 export independently passes **32/32** checks again. This remains room-space/export validation, not a complete building model.
- Across the search, six alternate room packings have a sampled U-03 hall-side goal. That is a route-grid observation, not a door. The retained candidate has no public-side U-03 sample and preserves the owner's private-route-only requirement; candidate selection must continue to enforce that filter.

## Limits

The shell and rooms remain hypothetical room blocks. Search is deterministic but capped at 4,000 nodes; it is not exhaustive. Samples do not define actual doors or clear widths. Actual walls, openings, stair geometry and headroom, privacy, egress, floor/roof geometry, structure, services, site and applicable code review remain open. The Revit derivative has spaces and an outline, with no construction geometry. No compliance, accessibility, structural-safety, certification, permit or construction-readiness claim follows.
