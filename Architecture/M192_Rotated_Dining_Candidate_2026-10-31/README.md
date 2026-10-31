# M192 — rotated dining candidate with chair-use proxies

**Status:** one unapproved dining orientation tested; no furniture or room layout selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\search_m192_rotated_dining_candidate.ps1 -OutputDirectory .local\revalidation\M192-replay
```

The script refuses to overwrite a nonempty output directory. It source-binds M186, M188, M191, the kitchen/dining/porch specification, selected-D and the bath-first comparison. Its retained package is in `artifacts/`.

## Result

The test rotates the documented 36 × 60 in table so the 60 in axis runs north/south, seats two 18 × 20 in chair proxies on each long side, and reserves four 36 in-from-table-edge use rectangles. It reuses M186's quarter-foot grid, 36 in route width, test shell, start point and porch-door target.

M192 passes **7/7** checks in the retained run and a fresh replay. All four outputs match byte-for-byte; the layout SVG parses as XML. The route does **not** reach the porch door. The search reaches 5,423 centerline nodes; the nearest reachable point is 9 ft Manhattan distance from the nominal door. This is one table orientation and chair arrangement, not evidence that all dining arrangements fail.

## Limits and next step

The 36 in pull-out zones are a study proxy, not measured chair or occupant geometry. The dining block, kitchen and porch door are comparisons; actual openings, thresholds, walls, occupied movement and the final route are not established. M-06/B stays unassigned. No Revit/IFC or selected-D model changed, and no compliance, accessibility, structural, permit or construction-readiness conclusion follows. M193 begins a separate kitchen-island fit study; the next integrated search must carry a compact island candidate, dining use zones and the porch route together.
