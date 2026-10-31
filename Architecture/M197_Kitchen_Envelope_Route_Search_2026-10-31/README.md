# M197 kitchen envelope route search

**Status:** reproducible bounded sensitivity; no route-passing kitchen width found.

## Question

Does widening the M178 kitchen test envelope, while keeping its 14-ft depth, 12.5-ft counter run, 8 × 4 ft island and six-foot half-wall opening, recover a route to the porch under the M186 search contract?

## Method and assumptions

The PowerShell 5.1 script tests 17 kitchen widths from **13.5 ft** through the source M-02 width of **17⅓ ft**, in 0.25-ft analysis increments plus the exact upper endpoint. The kitchen area therefore ranges from **189 sf** to **242⅔ sf**. This is a one-axis sensitivity, not an approved room size or a global minimum-area proof. The kitchen depth remains 14 ft. Width added beyond the 13.5-ft M178 cross-section is unassigned envelope area; the original counter, island, stool-use proxy and opening relationship stay fixed relative to one another while the half-wall shifts east.

Each sample reruns M186's quarter-foot, 36-in route search with the M195 dining/porch axis and rotated table, four chair bodies and four 36-in chair-use rectangles. The pantry, entry, both M-06 diagnostic windows, kitchen proxies and porch door are retained. M-06/B stays an unassigned obstacle; the fixed porch-door target is centered on dining.

## Reproduction and verification

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m197_kitchen_envelope_route.ps1 `
  -OutputDirectory .local/revalidation/M197-reproduction-1 `
  -ScratchPrefix M197-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m197_kitchen_envelope_route.ps1 `
  -OutputDirectory .local/revalidation/M197-reproduction-2 `
  -ScratchPrefix M197-reproduction-2
```

The script refuses to overwrite nonempty output or candidate scratch directories. Use fresh paths for each replay. The checked-in artifacts are copied from the first passing run. Two independent PowerShell 5.1 runs pass **6/6** M197 checks, and all 34 embedded M186 searches pass **29/29** each. Their JSON, checks and CSV match byte-for-byte:

| Artifact | SHA256 |
|---|---|
| `m197-kitchen-envelope-route-search.json` | `055CAB8CF2288748B327236AE595C2064AE1CC5CF83276C9B9E0511084F70764` |
| `m197-checks.json` | `0D0C96C7C8710186C5692A7B5D87B11A41A0E877E8970D6FF0FBDE14B30B0030` |
| `m197-width-samples.csv` | `CAD8855B7C4682E6C9492D84747DC7CB3A6ABC9DBDA95AB0B60704B84AE23D09` |

## Result

**0/17** widths find a route. The nearest reachable point is unchanged at `(4, 14)` ft, 12 ft Manhattan distance from the `(5.5, 24.5)` ft porch-door target. Reachable nodes decrease from 5,296 at 13.5 ft to 5,238 at 17⅓ ft; widening the kitchen did not open a route. The result points toward a downstream dining/porch approach bottleneck, but does not prove that every possible furniture layout fails.

## Limits and safeguards

Only kitchen width varies. The route, chair/stool, room, doorway and wall elements remain simplified rectangular proxies; actual chair movement, appliance-open states, wall thickness, physical door leaves, thresholds, site orientation, service routes and tolerances are not modeled. A sampled route would still require design and professional review.

The report binds M186, M178, M192, room specifications, selected-D, bath-window sources and the owner kitchen-area decision by SHA256. Selected-D remains at `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`. Revit, IFC and Incoming RFAs are unchanged. M-06/B remains unassigned. No code, accessibility, structural, professional, permit or construction-readiness conclusion is established.

## Next

Hold the kitchen at the smallest tested width and sweep dining table/chair-use placement and porch-door alignment within the authorized shell, preserving B and reporting alternate A separately. Prioritize the current 12-ft gap to the porch-door target. Do not call any candidate selected or a global minimum.
