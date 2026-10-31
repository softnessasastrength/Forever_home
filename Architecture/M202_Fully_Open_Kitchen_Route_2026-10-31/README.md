# M202 fully open kitchen/living route sensitivity

**Status:** reproducible bounded sensitivity; no porch route found.

## Method

The owner prefers a fully open kitchen/living connection. M202 removes only the M178 half-wall and return proxies, begins the 36-in route search at the M180 source point inside M-01 living, and retains the 189-sf M178 kitchen, 8 × 4 ft island, stool-use proxy, M195 rotated dining/table/chair-use set, pantry, entry, both M-06 diagnostics and the porch opening.

The porch door is fixed at x=9 ft, the eastmost M198 five-foot sample with the smallest Manhattan distance to the reachable grid. This maximizes the tested approach opportunity; it is not selected door design. M187's earlier half-wall-only sensitivity also found no path.

## Reproduction and results

From the repository root in Windows PowerShell 5.1, use fresh output and scratch directories:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m202_fully_open_kitchen_route.ps1 `
  -OutputDirectory .local/revalidation/M202-reproduction-1 `
  -ScratchPrefix M202-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m202_fully_open_kitchen_route.ps1 `
  -OutputDirectory .local/revalidation/M202-reproduction-2 `
  -ScratchPrefix M202-reproduction-2
```

The script refuses nonempty output/scratch directories. Two independent Windows PowerShell 5.1 runs pass **7/7** M202 checks; both embedded M186 route runs pass **29/29**. JSON, checks and CSV match byte-for-byte:

| Artifact | SHA256 |
|---|---|
| `m202-fully-open-kitchen-route.json` | `67D555F1F392E2E1E12C78A361C65D124CFD365E442490E6A03FA8031E4B3C0A` |
| `m202-checks.json` | `09852F946A7B82C0C1E67E40FF73FC81B86029F95B712F764F192A4B0CA828A9` |
| `m202-route-summary.csv` | `39CE6406FE6F2AB1FBFCD75747E1203A30853A89062EC4221FAB8DF972FA2D33` |

The open-connection case reaches **5,816** quarter-foot grid nodes and finds no route; nearest reachable point remains **9.5 ft** from the tested door. Removing the half-wall and return does not solve the route under the tested dining/use proxies.

## Unassigned band and limitations

The M178 kitchen candidate ends at local x=13.5 ft; source M-01 begins at local x≈17.833 ft. The **4.333-ft band** between them remains unassigned. M202 starts in the source living block and models that band as unobstructed floor; it does not draw a wall removal, assign the band as a room or prove a continuous physical opening. Exact walls, openings, door leaves/swing, thresholds, appliances, furniture movement, site, structure and tolerances remain unmodeled.

Both M-06 diagnostic windows remain blocked obstacles. Pantry-side B is unassigned and protected. The report binds M186, M178, M187, M195, M198, the room/porch specification, selected-D, bath-window inputs and the owner preference by SHA256. Selected-D remains `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`; Revit, IFC and Incoming RFA sources are unchanged.

This is not a route approval, code/accessibility finding, structural assessment, professional review, permit approval or construction-readiness claim.

## Next

Test consuming alternate diagnostic A as a separately reported circulation trade-off while leaving pantry-side B blocked and unassigned. Measure the route against the stool, island and chair-use proxies; do not call A a bath or the route a selected plan.
