# M168 - M164 steep-gable ridge orientation screen

**Status:** comparative proposal evidence only. The 38.333333 x 40 ft outline is an owner-authorized exploration case; no upper layout, roof pitch, ridge axis, wall or absolute roof datum is selected.

## Reproduce

First recreate the M164 M37 search and route/perimeter audit using the commands in [M164](../M164_Gable_End_Opportunity_Search_2026-10-31/README.md). Then regenerate M164's current roof-sensitivity report twice against M83's current source options, followed by M168:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m163_expanded_roof_exposure.ps1 `
  -M163RunDirectory .local/revalidation/M164-expanded `
  -M163AuditDirectory .local/revalidation/M164-audit `
  -OutputDirectory .local/revalidation/M168-roof-a `
  -Milestone M164 -OutputFileStem m164-gable-exposure

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m163_expanded_roof_exposure.ps1 `
  -M163RunDirectory .local/revalidation/M164-expanded `
  -M163AuditDirectory .local/revalidation/M164-audit `
  -OutputDirectory .local/revalidation/M168-roof-b `
  -Milestone M164 -OutputFileStem m164-gable-exposure

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m168_m164_ridge_orientation.ps1 `
  -RoofReportPath .local/revalidation/M168-roof-a/m164-gable-exposure.json

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m168_m164_ridge_orientation.ps1 `
  -OutputDirectory .local/revalidation/M168-analysis-repeat `
  -RoofReportPath .local/revalidation/M168-roof-b/m164-gable-exposure.json
```

The first M164 roof replay passes **12/12** and produces JSON SHA256 `F4A79EE7F2A9666D550A274F0579BAD37BD3F23EABB3E8A6CD205E50EFFBB593` and CSV SHA256 `8D62CCF6E9BEEDD412D67AA7DF02A3876A036F5A008CF5FF7831305049E44520`; the second replay matches both files byte-for-byte. M168 then passes **18/18** checks twice. Its JSON SHA256 is `C509D41B8CF69DA5730F85DC0AB06F0C7584F05EDE88573152E19E8A3213F914`; CSV SHA256 is `39AF18A6A700C55307760E103360A0E53B6536D86CEE71D4A9263B6051BCE5A6`. Both M168 outputs match byte-for-byte. The source-bound JSON records each route-qualified candidate/axis row and the current source fingerprints.

## Finding

The count is for U-01, U-03 and U-04, the three bedroom-capable room blocks, across 48 route-qualified M164 layouts at the steepest existing comparison pitch, 12:12:

| Ideal ridge axis | Bedroom-capable blocks touching an ideal eave | Layouts | Contact pattern |
|---|---:|---:|---|
| X | 2 of 3 | 48 / 48 | U-01 at south and U-04 at north; U-03 has no ideal eave contact in this sample |
| Y | 1 of 3 | 24 / 48 | U-03 at west only; U-01 and U-04 have no ideal eave contact |
| Y | 2 of 3 | 24 / 48 | U-03 and U-04 at west |

Every ridge-Y layout keeps U-03 on the west ideal eave edge in this candidate set. In half of those layouts, U-04 also reaches that edge; the other half keep U-04 clear. Ridge Y therefore reduces the *number* of bedroom-capable blocks contacting an ideal eave for 24/48 layouts compared with ridge X, but it transfers the single unavoidable contact to U-03. No 12:12 layout keeps all three bedroom-capable blocks off ideal eave edges. This is an orientation and layout trade-off to discuss, not a selected design.

## Limits

The 12:12 plane is the steepest of the three existing comparisons; the result is not evidence that a 12:12 roof is buildable or preferable. Eave contact is a geometric boundary indicator, not finished ceiling height or a code pass/fail. The Connecticut sloped-ceiling calculation retains the full-block area proxy and unknown floor/eave datum and build-down. This study does not include exterior walls, roof thickness, dormers, windows, framing, loads, EERO, room classification, actual doors, or continuous-plan alternatives. Route qualification refers to M164's sampled grid and does not establish a real door or accessible route. The M83 Revit derivatives remain generic open-surface comparisons. No structural-safety, code-compliance, certification, permit or construction-readiness conclusion follows.

The generator validates the M164 search, audit, M158 inputs, current M83 roof options and selected-D fingerprints before writing. It refuses output paths outside the repository. Full intermediate M164 search, audit and roof outputs remain in ignored `.local/revalidation/` folders.
