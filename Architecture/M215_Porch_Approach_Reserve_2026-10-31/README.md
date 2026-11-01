# M215 — Protected-A porch approach reserve

**Status:** two reproducible route/layout comparisons; no kitchen, dining or porch placement selected.

## Result

M214 showed that the M213 shortest path touched both the protected west-A search boundary and the porch-face wall. M215 keeps M213's 13.25 × 13.5 ft kitchen comparison, 8 × 4 ft island, 12.5-ft casework run, pantry, furniture/use proxies and 36-in route width. It translates the 11 × 10 ft dining block, 12 × 10 ft porch and nominal porch-face wall pieces north together, then tests a separately specified orthogonal path.

The **0.5-ft translation** places dining at y=20 ft, porch at y=30.5 ft, and the nominal 5-ft door center at (9, 30.5) ft. Its route is `(19.5,10) → (18.5,10) → (18.5,28.75) → (9,28.75) → (9,33.5)` and measures **34 ft**. The 36-in swept rectangles clear every M186 obstacle by at least **0.25 ft (3 in)**. The smallest reported gaps are 3 in to the analytically expanded A boundary and east porch-wall segment. The route remains **0.5 ft (6 in)** from the original A boundary because M211 had already expanded the protected-A obstacle by 3 in. Dining and porch do not overlap A or unassigned B, the sampled table/chair-use proxies remain in dining, and the translated blocks remain inside the source-comparison shell limits.

The **1-ft translation** is retained as a comparison: dining y=20.5 ft, porch y=31 ft, route length 34.5 ft, minimum modeled gap 3 in, and original-A gap 6 in. The half-foot case therefore gains 6 in of northern shell margin and shortens the route by 6 in while retaining the same minimum obstacle reserve.

The modeled vertical gap from A's north edge to the nominal porch wall is 3.083333 ft before translation. A 36-in corridor plus 3 in of analytical separation on each side needs 3.5 ft. The resulting continuous minimum north shift is **0.416667 ft**; on the existing quarter-foot analysis grid, the first increment that can satisfy the bound is **0.5 ft**. This is a proxy-derived search bound, not a room dimension, code clearance, or selected design.

## Reproduction and validation

The script first regenerates M213 and its M186 source route, then evaluates the M215 candidate without opening or modifying Revit. The retained 0.5-ft package and two independent PowerShell 5.1 replays each pass **12/12 checks**; JSON, checks and obstacle-clearance CSV reproduce byte-for-byte.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m215_porchtop_clearance.ps1 `
  -NorthTranslationFt 0.5 `
  -OutputDirectory Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts `
  -ScratchPrefix M215-retained
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m215_porchtop_clearance.ps1 `
  -NorthTranslationFt 0.5 `
  -OutputDirectory .local/revalidation/M215-final-replay-1 `
  -ScratchPrefix M215-f1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m215_porchtop_clearance.ps1 `
  -NorthTranslationFt 0.5 `
  -OutputDirectory .local/revalidation/M215-final-replay-2 `
  -ScratchPrefix M215-f2
```

Retained 0.5-ft artifacts:

| Artifact | SHA256 |
|---|---|
| `m215-porch-approach-clearance.json` | `F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1` |
| `m215-checks.json` | `4DB502F480F892C6F8A885469104657F0D6E85A56676E4779A4A54EB04355BC3` |
| `m215-obstacle-clearances.csv` | `308A426C81C90DCF5AC31CAFDF5F22D14E4DE6375F30CAAB2599F70F602C4AF2` |

The one-foot comparison is retained under `artifacts-one-foot/`; pass `-NorthTranslationFt 1.0` to regenerate it.

## Limits and next gate

This is one explicit route through schematic obstacle rectangles, not a full building plan or exhaustive placement search. The shell remains hypothetical, the nominal opening is not a selected door, and no leaf/swing, physical walls, finish tolerances, site/grade, service systems, appliance operation or occupied movement is modeled. The 3-in route-obstacle gap is an analytical sensitivity, not an applicable code, accessibility or product clearance. M-06/A remains protected; M-06/B remains unassigned and clear. No selected-D, RVT, IFC or source RFA changed.

The next Revit gate still requires successful host access and the exact hash-verified project-local RevitPilot. Before that, the kitchen dimension, shell and physical opening are unresolved; this route test alone does not justify authoring the house model. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
