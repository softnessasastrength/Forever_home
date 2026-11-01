# M205 M-04 pantry location sensitivity

**Status:** deterministic route sensitivity; no pantry, dining or M-06 space is selected.

## Scope

The owner authorized relocating the modeled pantry block as a labeled study. M205 holds the 5 × 7 ft (35 sf) route-study block, open kitchen/living start, 36-in swept-route proxy, 8 × 4 ft island, stool-use proxy, M-06/B obstacle and east x=9 ft porch-door sample fixed. It compares the current pantry location with two positions directly north of the hypothetical kitchen. The second north-edge case shifts the dining/table/chair-use package 6 in west while retaining its 11 × 10 ft room target and furniture dimensions.

**Source discrepancy:** `Architecture/Kitchen_Dining_Porch_Specs.md` calls for a 5 × 6 ft (30 sf) pantry, while the bath-first M-04 room block used by the M186 route model is 5 × 7 ft (35 sf). M205 preserves the latter because that is what the approved question authorized; neither size is selected. A separate 5 × 6 ft comparison remains useful.

## Results

Two independent Windows PowerShell runs each pass **6/6** M205 checks. Their three route searches pass **29/29**, **31/31** and **31/31** M186 checks. JSON, checks and CSV match byte-for-byte.

| Case | Pantry local rectangle (ft) | Kitchen north wall in common (ft) | Dining shift | Pantry + route use of west A | Route |
|---|---:|---:|---:|---:|---|
| Current | (11.833, 16.5, 5, 7) | 0 | 0 | 32.67 sf | None; nearest point 9.5 ft away |
| North edge, nominal 30-in share | (11, 14, 5, 7) | 2.5 | 0 | 43.92 sf | 28 ft, four turns |
| North edge, nominal 36-in share | (10.5, 14, 5, 7) | 3 | 6 in west | 43.92 sf | 28 ft, four turns |

The unassigned west-A search window is 58.99 sf, so either passing sensitivity consumes about **74.5%** of that diagnostic area between pantry and route. This is a substantial bath-versus-circulation trade-off, not a pantry fit approval. In the 36-in-share case the shifted dining block has only **2 in** to the edge of the hypothetical shell, before wall thickness or construction tolerance. In the 30-in-share case the nominal 30-in pantry door has no wall-length reserve; in the 36-in-share case the remaining wall segment does not prove the rough opening, jambs, swing or approach fit. Door geometry is not modeled.

M-06/B remains an obstacle and unassigned. Both route-positive cases pass the M186 route contract without proxy intersections and stay inside the test shell. Route paths pass through west A, which remains unassigned; A is not a room assignment. No selected-D, RVT, IFC or RFA source changed.

## Reproduction

From the repository root in Windows PowerShell 5.1, provide new empty output directories and scratch prefixes:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m205_pantry_location_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M205-reproduction-1 `
  -ScratchPrefix M205-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m205_pantry_location_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M205-reproduction-2 `
  -ScratchPrefix M205-reproduction-2
```

The retained artifacts are under `artifacts/`:

| Artifact | SHA256 |
|---|---|
| `m205-pantry-location-sensitivity.json` | `B9DF1DDD9106255398E542D9F91AA7810F45CD20EDBFABC70CFC45D2E169AAE6` |
| `m205-checks.json` | `59E97983AC5E40B38F0CFDBC4CEF6E583621B7A69D2EE49D77F8B879B06E0652` |
| `m205-cases.csv` | `B5B5FDCC6A10C5D9027BDB4F5E4CB4C755A6AB4BE840A90171C04EEFD8B26A1C` |

## Limits and next step

These are three sampled placements in a 40 × 42 ft schematic envelope, not an exhaustive placement search or a selected plan. The 5 × 7 ft test block conflicts with the separate 5 × 6 ft kitchen specification. Kitchen-to-pantry door, wall build-ups, shelves, food-storage capacity, clear working space, room boundaries, occupied furniture movement, services, site, code and accessibility are not coordinated. The result is not a code, structural, permit, professional or construction-readiness conclusion.

Next, compare the documented 5 × 6 ft pantry target under the same fixed social layout, preserving B and reporting any continued use of A. Do not select a location from this search alone.
