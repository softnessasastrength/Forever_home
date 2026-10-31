# M212 kitchen-depth and social-proxy containment sweep

**Status:** Bounded area/route sensitivity; no kitchen size selected.

## Scope

The owner asked to find the smallest kitchen area that accommodates the larger island and a route. M212 holds the 13.5-ft M178 cross-section, 8 × 4 ft island, 12.5-ft casework run, 5.5-ft north dining/porch shift, x=9-ft porch door, fully open kitchen/living connection, and M211's analytical 3-in reserve at protected A. It compares kitchen depths derived from current geometry: 12.5 ft (casework-run boundary), 13 ft (end of the existing stool-use proxy), 13.5 ft (M178 cross-section test value) and 14 ft (M178 baseline depth). The 12.5-ft casework run is centered within each tested depth.

These are envelope tests only. Depth changes are applied to disposable generated M186 scripts and their in-memory M178 geometry; no source specification or selected-D geometry is changed. They are not selected architectural dimensions.

## Results

The retained run passes 13/13 checks; all four embedded M186 runs pass 31/31 route checks and find a path. Two independent PowerShell 5.1 replays reproduce JSON/checks/CSV byte-for-byte.

| Kitchen depth | Test area | Difference from 168-sf program | Casework run | 8 × 4 island | Stool-use proxy | Minimum proxy edge margin | Route |
|---:|---:|---:|---|---|---|---:|---|
| 12.5 ft | 168.75 sf | +0.75 sf | Fits at zero end margin | Fits | Extends 6 in beyond envelope | -6 in | Pass |
| 13 ft | 175.5 sf | +7.5 sf | Fits | Fits | Fits at edge | 0 in | Pass |
| 13.5 ft | 182.25 sf | +14.25 sf | Fits | Fits | Fits | 6 in | Pass |
| 14 ft | 189 sf | +21 sf | Fits | Fits | Fits | 12 in | Pass |

Among these samples, 13 ft / 175.5 sf is the first envelope containing the run, island and stool proxy, but the stool proxy is tangent to the boundary. The next tested size, 13.5 ft / 182.25 sf, leaves 6 in to that assumed proxy. The 12.5-ft envelope nearly matches the 168-sf area target, yet cannot contain the stool-use proxy. The result therefore does not establish a fit-ready or minimum kitchen size; appliance operation, actual stool geometry, finish tolerances and circulation remain untested.

## Reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m212_kitchen_depth_sweep.ps1 `
  -OutputDirectory .local/revalidation/M212-replay-1 `
  -ScratchPrefix M212-r1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m212_kitchen_depth_sweep.ps1 `
  -OutputDirectory .local/revalidation/M212-replay-2 `
  -ScratchPrefix M212-r2
```

The script refuses nonempty destinations and binds its upstream source/decision hashes, including selected-D. Retained outputs are under `artifacts-v2/`.

| Artifact | SHA256 |
|---|---|
| `m212-kitchen-depth-sweep.json` | `7FF9E7CDB3DD180456AE0E8170BB7506033F301733925B8C281A92243418C050` |
| `m212-checks.json` | `203EF0A1D203626F3AE901DA43D4883B8E460A1D2F3EC8FECEF2372870BC05EA` |
| `m212-candidates.csv` | `91197BC0CF0A213BB1C079F04C45636C3A301E47893F488D0C16A780B8743086` |

## Limits

The 24-in stool-use depth is an assumed rectangle, not measured product or occupant geometry. A zero edge margin means only mathematical containment in these proxies. Actual cabinetry, side/end panels, appliance doors and operating envelopes, utilities, wall/opening details, site fit and construction tolerance remain unknown. The M211 3-in A reserve is a search sensitivity, not a clearance standard. M-06/B remains unassigned; A remains protected. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
