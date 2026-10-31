# M207 pantry edge sensitivity

**Status:** reproducible six-position study; no pantry location or room layout selected.

## Scope

The owner authorized a relocation sensitivity for the documented 5 × 6 ft (30 sf) pantry. M207 preserves that area and use, keeps the east-side M-06/B window as an obstacle, and tests the current placement, two north-edge placements, and three placements along the kitchen's east edge. It reuses the bounded M186 quarter-foot route search, 36-in swept-route proxy, east x=9 ft porch-door sample, M178 13.5 × 14 ft kitchen test, 8 × 4 ft island, stool-use proxy, dining/chair-use proxies and fully open living start. The north-edge 36-in-share case shifts dining 6 in west.

These remain schematic rectangles in the hypothetical 40 × 42 ft test shell. They do not establish wall construction, a door, pantry storage fit, fixture fit, service routing or approval of the kitchen/dining/porch arrangement. The source discrepancy remains: M-04 is 5 × 7 ft in the bath-first route study, while the kitchen specification says 5 × 6 ft. M207 uses the latter and changes neither source.

## Results

The retained Windows PowerShell 5.1 run passes **6/6** wrapper checks. Two independent runs pass 6/6 and produce JSON, checks and CSV byte-for-byte identical to one another and to the retained report.

| Test position | Pantry rectangle (local ft) | Route result | Route length / turns | West A overlap: pantry + route | Search note |
|---|---:|---|---:|---:|---|
| Current | (11.833, 16.5, 5, 6) | No route; 6,006 nodes reached | — | 28.00 sf | Closest point remains 4 ft from door |
| North edge, 30-in shared segment | (11, 14, 5, 6) | Route found | 28 ft / 4 | 38.75 sf | Dining unchanged |
| North edge, 36-in shared segment | (10.5, 14, 5, 6) | Route found | 28 ft / 4 | 38.75 sf | Dining shifts 6 in west; only 2 in to hypothetical shell edge |
| East edge, south | (13.5, 0, 5, 6) | Route found | 28 ft / 4 | 8.75 sf | Lowest measured A use, but route still traverses A |
| East edge, middle | (13.5, 4, 5, 6) | Rejected before grid expansion | — | 0 sf | Pantry blocks the fixed kitchen-opening route node |
| East edge, north | (13.5, 8, 5, 6) | Rejected before grid expansion | — | 0 sf | Pantry blocks the fixed kitchen-opening route node |

The east-south pantry placement is the most promising of these six samples with respect to preserving A, but its 28-ft route still uses **8.75 sf** of A. If A must be reserved for M-06, that route fails the current proxy screen. B remains unassigned and route-free in all six cases. The two east placements that reach too close to the opening are explicitly classified as rejected placements; the validator allows only the single known `start_and_goal_nodes_clear` failure with zero expanded nodes, rather than treating it as a valid search.

## Reproduction

Run from the repository root in Windows PowerShell 5.1, using fresh empty destinations:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m207_pantry_edge_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M207-reproduction-1 `
  -ScratchPrefix M207-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m207_pantry_edge_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M207-reproduction-2 `
  -ScratchPrefix M207-reproduction-2
```

The script refuses to overwrite nonempty destinations. Retained evidence is under `artifacts-v4/`:

| Artifact | SHA256 |
|---|---|
| `m207-pantry-location-sensitivity.json` | `A5FD9A9207DE25E6CA65E22257A99D90533D43528070C8540C03C0A261E9B8B6` |
| `m207-checks.json` | `CE8F1416150E6788AF1598C7A59940D28BB56ACBE9DCCEB247B18C6F07122632` |
| `m207-cases.csv` | `BAD64E00A16A7E60465F54D99478114E14A1A0400B3EBD25F853D03BD830A503` |

## Boundaries and next work

M207 does not establish an exhaustive location search, door size/swing, shelving, clearances, room walls, code applicability, accessibility, structural coordination, professional review, permit approval or construction readiness. Selected-D remains at SHA256 `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`. Revit, IFC, RFAs and remote state are unchanged.

Next, retain A as a protected condition in one search branch and show any A-consuming route only as a separate trade-off. Integrate pantry placement with the still-pending kitchen-area / dining / porch search and require actual product geometry and a plausible opening before carrying anything into a disposable Revit derivative. M-06/B remains unassigned.
