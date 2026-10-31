# M203 alternate-A circulation trade-off

**Status:** reproducible sensitivity; releasing A did not produce a route.

## Method

M203 starts from the M202 fully open kitchen/living case, releases only the west diagnostic M-06/A rectangle from the route obstacle set, and keeps pantry-side M-06/B blocked and unassigned. It preserves the 189-sf M178 kitchen, 8 × 4 ft island, assumed stool-use proxy, M195 rotated four-chair table and four chair-use rectangles, pantry, entry, casework and the M198 best-gap door center at x=9 ft.

This is the explicit alternate-A trade-off sensitivity. A remains an unassigned future option, not a bathroom. If a route were found, the script reports its union overlap with A, centerline length inside A, unassigned travel and minimum gaps to the remaining proxies.

## Reproduction and results

From the repository root in Windows PowerShell 5.1, use two fresh output and scratch directories:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m203_m06a_circulation_tradeoff.ps1 `
  -OutputDirectory .local/revalidation/M203-reproduction-1 `
  -ScratchPrefix M203-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m203_m06a_circulation_tradeoff.ps1 `
  -OutputDirectory .local/revalidation/M203-reproduction-2 `
  -ScratchPrefix M203-reproduction-2
```

The script refuses nonempty destinations. Two independent Windows PowerShell 5.1 runs pass **7/7** M203 checks, and both embedded M186 searches pass **29/29**. JSON, checks and CSV match byte-for-byte:

| Artifact | SHA256 |
|---|---|
| `m203-m06a-circulation-tradeoff.json` | `008F253C86C82C8523300A03F608A01E6E134831D6A34DC0FE9D744150BB2AC1` |
| `m203-checks.json` | `68630335C58A1AAA120614213FFB3A978E2081F58189592DA5DF8CE558CC710E` |
| `m203-route-summary.csv` | `03FEF37A73334CD0839362435C1EE47487B2CE8EA72A9CDE0A42752294C3098F` |

No route appears after reaching **5,940** nodes; the closest reachable point remains **9.5 ft** from the tested porch door. The path therefore consumes **0 sf** of A in this test because it does not reach the door. The strongest reported frontier blockers include B, the pantry and stool-use proxy. Releasing A alone is insufficient under these fixed dining, pantry and use-zone proxies.

## Safeguards and limitations

Pantry-side B remains an obstacle and unassigned. The tested route does not establish whether another door/table placement could pass around the pantry. A, if used by a future route, would be a circulation-versus-future-bath trade-off. This sensitivity does not assign either window or select a layout.

The kitchen/living band remains unassigned and unmodeled. Walls, actual door leaves/swing, thresholds, appliance operation, family geometry, furniture movement, site conditions and tolerances remain absent. A route is not a code/accessibility, structural, professional, permit or construction-readiness finding. Selected-D, RVT, IFC and Incoming RFA sources are unchanged.

## Next

Test west, central and east porch-door positions with A released, keeping B protected and all furniture-use proxies fixed. This will establish whether door alignment changes the pantry-side approach before any pantry or room footprint is reconsidered.
