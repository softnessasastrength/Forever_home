# M217 — Pantry and porch-route integration

**Status:** reproducible bounded pantry sensitivity; no pantry, kitchen, or room placement selected.

## Owner direction and scope

The owner directed the next integrated search to protect west A for M-06 and separately authorized movement of the hypothetical M-04 block while preserving its 5 × 7 ft (35 sf) study footprint and use. East B remains unassigned. M217 tests that pantry block against the reproduced M215 36-in porch route, retaining M215's 3-in additional geometric reserve as an analysis threshold.

The run regenerates the M213/M186 route source and M215's 0.5-ft north-shift social/porch candidate, then tests 58 pantry placements: three current/north named samples, three east-edge named samples, and a deduplicated quarter-foot sweep along x=13.5 ft from y=0 to the inherited 13.5-ft kitchen cross-section limit. That east-edge alignment is a study proxy, not verified adjacency or a selected coordinate. All blocks remain rectangles in a hypothetical 40 × 42 ft envelope.

## Result

The retained package and two independent Windows PowerShell 5.1 replays each pass **7/7** integrity checks and reproduce JSON, checks and CSV byte-for-byte. **6 of 58** sampled positions pass the modeled shell, obstacle, protected-A, unassigned-B and 36-in-route-plus-3-in-reserve screens. All six lie on the east-edge sample at y=0 through y=1.25 ft in 0.25-ft increments; x=13.5 ft and the 5 × 7 ft block remain fixed.

The furthest north passing position is `(13.5, 1.25)` ft. It retains exactly 3 in between the pantry block and the route's 36-in swept rectangle. At y=1.5 ft the reserve falls to zero, and the next sample overlaps the route. The y=1.25-ft test is therefore a useful candidate for further coordination, not a robust construction allowance or room assignment. The y=0 sample also lies on the hypothetical shell's outer coordinate boundary; wall thickness and inside-face location are unresolved.

The named current pantry sample overlaps **34.4167 sf** of the expanded west-A reservation. The two north samples overlap **25.6667 sf** and **22.9167 sf** of A. The east-edge y=4 and y=8 ft samples overlap **5.25 sf** and **12 sf** of the route corridor. B remains clear and unassigned in all cases. These tests keep the owner-directed A protection in force; no A-consuming alternative is being advanced.

## Reproduction

From the repository root in Windows PowerShell 5.1, use a fresh empty output directory and scratch prefix for each run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m217_pantry_route_integration.ps1 `
  -OutputDirectory Architecture/M217_Pantry_Route_Integration_2026-10-31/artifacts `
  -ScratchPrefix M217verified

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m217_pantry_route_integration.ps1 `
  -OutputDirectory .local/revalidation/M217-verified-replay-1 `
  -ScratchPrefix M217verr1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m217_pantry_route_integration.ps1 `
  -OutputDirectory .local/revalidation/M217-verified-replay-2 `
  -ScratchPrefix M217verr2
```

| Retained artifact | SHA256 |
|---|---|
| `m217-pantry-route-integration.json` | `7E436B9A7D805E2803A1148FBD2BDACAD017F86B7D444F7CBE77CBDE30226853` |
| `m217-checks.json` | `7967E3C8FCF076F047E518FE4C8C4CEF224142741EE32B7F58F03D24D120EA2F` |
| `m217-placement-cases.csv` | `D4D7F3FE5328B51BCF4B2C3A3C7C553E12279C966C9319E7BB18CBAE8B9E1E0A` |

## Limits and next gate

This bounded placement study does not define a pantry room boundary, shelving, door/opening, approach, kitchen workflow, or plumbing/service route. A 3-in gap beyond the 36-in route is inherited from M215's analysis threshold, not a code, accessibility, product, or construction requirement. The shell is only an outer coordinate envelope; wall build-ups, fit tolerances and other room boundaries are absent. The east-edge search does not exhaust other x positions or orientations. Before carrying the y=1.25-ft sample into a disposable Revit derivative, coordinate it with a real pantry opening/approach and the kitchen casework, then add physical walls and door geometry. M-06 B remains unassigned. Selected-D, RVT, IFC, RFAs, Revit registration and remote state are unchanged. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
