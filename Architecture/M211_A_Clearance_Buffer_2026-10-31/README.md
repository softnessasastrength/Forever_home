# M211 protected-A clearance-buffer route sensitivity

**Status:** Reproducible route-search sensitivity; no room or route selected.

## Scope

M210 found routes through the first northward dining/porch positions, but the 36-in route proxy was tangent to owner-protected west window A. M211 holds M210's first and farthest route-passing dining/porch offsets (5.5 and 6.5 ft north) and the eastmost tested five-foot porch door (x=9 ft) fixed. It tests four analytical eastward expansions of the west-A route obstacle: 0, 0.25, 0.5 and 1 ft (0, 3, 6 and 12 in). Expanding the no-go obstacle is a way to test route reserve; it does not modify the M-06 window geometry or assign a bath.

The 11 × 10 ft dining, 12 × 10 ft porch, 5 × 6 ft pantry, 13.5 × 14 ft M178 kitchen proposal, 8 × 4 ft island, owner-preferred fully open kitchen/living connection, furniture/use proxies and east B obstacle are retained. Selected-D and source families are protected.

## Results

The retained run passes 12/12 wrapper checks; all eight embedded M186 route runs pass their complete route checks. Two independent PowerShell 5.1 replays reproduce JSON, checks and CSV byte-for-byte.

All eight cases find a sampled route. At each north offset, path length is 33.5 ft for 5.5 ft north and 34.5 ft for 6.5 ft north, regardless of the added A buffer. The path's vertical leg shifts east by exactly the tested 0, 3, 6 or 12 in. Measured clearance to the original A boundary equals the analytical buffer. The six cases with a 3-in-or-greater buffer meet the study's 3-in reserve screen; the two zero-buffer cases remain tangent to A.

This means the search can route around an analytically reserved strip while preserving A. It does not establish the strip as a required clearance, confirm an M-06 product fit, or validate the route in a physical model.

## Reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m211_a_clearance_buffer.ps1 `
  -OutputDirectory .local/revalidation/M211-replay-1 `
  -ScratchPrefix M211-r1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m211_a_clearance_buffer.ps1 `
  -OutputDirectory .local/revalidation/M211-replay-2 `
  -ScratchPrefix M211-r2
```

The script refuses nonempty destinations, fingerprints input specifications/decisions and selected-D, and emits its retained run under `artifacts/`.

| Artifact | SHA256 |
|---|---|
| `m211-A-clearance-buffer.json` | `D39A1000CD42CE8AA4E1FE96D466956095DE60095CD444000891B56169306314` |
| `m211-checks.json` | `F8E93367917C4DB7D377120F228DCBE6C6623323A2AA1772A77AAF36301E4FCE` |
| `m211-candidates.csv` | `622C792E203691A406473900B494776D1EE6D4FB74957175609C284AEE03B20E` |

## Limits

The added buffer values are explicit test inputs, not code or accessibility dimensions. A 36-in route on a quarter-foot grid is a search proxy, not a measured finished clear width. Walls, actual door leaf/swing and threshold, services, product geometry, occupied use, site fit and construction tolerance remain unmodeled. The kitchen and shell remain proposals. M-06/B remains unassigned; A is protected. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
