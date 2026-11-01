# M210 porch-door alignment after dining/porch shift

**Status:** Bounded route sensitivity; no door position or layout selected.

## Scope

M209 found sampled routes after translating the dining and porch north, but every route was tangent to protected A. M210 tests whether moving the porch-door opening changes that bottleneck. It compares seven five-foot door centers (x=6.0 to 9.0 ft in 0.5-ft steps) at the first and farthest north offsets that passed M209: 5.5 and 6.5 ft. Dining and porch move together; the 11 × 10 ft and 12 × 10 ft blocks, 5 × 6 ft pantry, 13.5 × 14 ft M178 kitchen proposal, 8 × 4 ft island, owner-preferred open kitchen/living connection and all route proxies remain fixed at each offset. A and B stay route obstacles; B remains unassigned.

For each case, the two porch-wall segments are regenerated around that case's door opening. Each five-foot opening is checked to fit within the translated porch face. The first preliminary run exposed a mismatch in an inherited fixed wall segment and failed M186's goal gate, so it was stopped before acceptance. Its scratch output remains under `.local/revalidation/M210-first-north5_5_door6/`; it is not accepted evidence. The final scripted cases move both wall segments with the tested opening and gate both route checks and opening fit.

## Results

The retained 14-case run and two independent replays each pass 11/11 wrapper checks; every embedded M186 route run passes its complete route contract. JSON, checks and CSV reproduce byte-for-byte. All fourteen samples find a route, with path lengths ranging from 33.5 to 37.5 ft. Every case reports a **0 ft route-edge gap to protected A** and fails the 3-in proxy-reserve threshold. The path keeps the same x=18 ft bottleneck regardless of door center or north offset. Door alignment changes route length but does not resolve clearance at A.

This is reachability evidence only. None of the cases is fit-ready, and no door or room layout is selected.

## Reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m210_porch_door_alignment.ps1 `
  -OutputDirectory .local/revalidation/M210-final-replay-1 `
  -ScratchPrefix M210-r1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m210_porch_door_alignment.ps1 `
  -OutputDirectory .local/revalidation/M210-final-replay-2 `
  -ScratchPrefix M210-r2
```

The script refuses nonempty destinations, fingerprints all source requirements and decisions, and preserves selected-D. The final retained results are under `artifacts-v3/`. Earlier `artifacts/` and `artifacts-v2/` output directories are preserved as prior script iterations; the abandoned preliminary run and its failed wall/opening alignment gate remain in ignored `.local` scratch.

| Artifact | SHA256 |
|---|---|
| `m210-porch-door-alignment.json` | `0E1253A2FCBFC8F23A398F6F700AC8DCC890BF29F85B48CDBEA59F18838051BF` |
| `m210-checks.json` | `2192A9EDEB391FF301B99924DA349D3CB52A0877AC8B3D3744F5740A69E1D1E1` |
| `m210-candidates.csv` | `C4D458570087307747D03A20E3C70388E40A5FBBFF2B7DF535164264F04B0E5E` |

## Limits

The route is a 36-in grid-centerline proxy, not a verified clear width. Wall thickness, rough opening, door leaf and swing, threshold, weather enclosure, site fit, physical services, appliance operation and tolerance are not modeled. Stool and chair-use dimensions remain assumptions. The kitchen and shell are proposals only. M-06/B remains unassigned; A is protected for future M-06 consideration. Selected-D, Revit, IFC, Incoming RFAs and remote state are unchanged. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
