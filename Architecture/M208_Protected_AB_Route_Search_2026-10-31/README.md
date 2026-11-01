# M208 protected-A route and porch-door screen

**Status:** reproducible six-case sensitivity; no door, pantry or layout selected.

## Scope

After the owner chose to protect west window A for M-06, M208 tests the east/south and east/middle placements of the specified 5 × 6 ft pantry against west, center and east five-foot porch-door samples (x=2, 5.5 and 9 ft). Both A and B are retained as route obstacles. The study holds the M178 13.5 × 14 ft kitchen, 8 × 4 ft island, 36-in route, assumed stool proxy, dining/chair-use rectangles and living start fixed. The test shell and room blocks are schematic.

This is a door/pantry sensitivity only. It does not move dining or the porch, which M209 tests separately. It does not assign M-06 or select any layout.

## Results

The retained PowerShell 5.1 run passes **6/6** wrapper checks. Both independent replays also pass 6/6 and reproduce JSON, checks and CSV byte-for-byte.

| Pantry position | Door center | Route | Nearest reachable sample | Explanation |
|---|---:|---|---:|---|
| East/south (13.5, 0, 5, 6 ft) | 2 ft | None | 12 ft | 5,086 grid nodes reached |
| East/south | 5.5 ft | None | 12 ft | 5,086 grid nodes reached |
| East/south | 9 ft | None | 9 ft | 5,086 grid nodes reached |
| East/middle (13.5, 4, 5, 6 ft) | 2, 5.5, 9 ft | Rejected before grid expansion | — | Pantry blocks the fixed route-start node |

All six cases keep pantry and route geometry clear of A, and keep B blocked and unassigned. The east/south pantry fits this proxy test, but none of its three porch-door samples restores a route while dining and porch remain in place. The east/middle cases are explicitly rejected because they block the fixed living/opening node; the validator accepts only this specific single-gate failure with zero expanded nodes.

## Reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m208_protected_ab_route_search.ps1 `
  -OutputDirectory .local/revalidation/M208-reproduction-1 `
  -ScratchPrefix M208-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m208_protected_ab_route_search.ps1 `
  -OutputDirectory .local/revalidation/M208-reproduction-2 `
  -ScratchPrefix M208-reproduction-2
```

The script refuses nonempty destinations. Retained results are under `artifacts-v2/`:

| Artifact | SHA256 |
|---|---|
| `m208-pantry-location-sensitivity.json` | `17C430F1B6176A27304C6B38A753488E76D4332D834F54B093C2E5B66A049248` |
| `m208-checks.json` | `019850B7333294DEE6BC73C82BDCBA46F0044F215DCCB62E483FA34A51D01882` |
| `m208-cases.csv` | `1739599781E215D89C0AE6249ACD9C4441E3607F300F08CF22A67579E25FBAE8` |

## Limits and next work

The M-04 5 × 7 ft route-model versus 5 × 6 ft kitchen-spec discrepancy remains disclosed; this screen uses 5 × 6 ft. A/B and all room/furniture blocks remain diagnostic proxies. Physical walls, rough openings, door leaf and swing, approach, services, site fit and construction tolerances are absent. Selected-D remains SHA256 `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`; Revit, IFC, RFAs and remote state are unchanged.

M209 continues the search by translating dining and porch north while preserving A, B and the owner-preferred fully open kitchen/living connection. No route result here establishes code, accessibility, structural, permit, professional or construction readiness.
