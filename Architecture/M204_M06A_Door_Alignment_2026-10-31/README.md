# M204 porch-door alignment with alternate-A trade-off

**Status:** reproducible three-position sensitivity; no route found.

## Method

M204 combines the M202 fully open kitchen/living route start with M203's separate west-A circulation trade-off. It samples west, centered and east five-foot porch-door positions at x=**2**, **5.5** and **9** ft. The west diagnostic A window is released only as an unassigned circulation sensitivity. Pantry-side B remains a no-go; pantry, entry, island, stool-use and dining/chair-use proxies remain fixed.

## Reproduction and results

From the repository root in Windows PowerShell 5.1, use two fresh output and scratch directories:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m204_m06a_door_alignment.ps1 `
  -OutputDirectory .local/revalidation/M204-reproduction-1 `
  -ScratchPrefix M204-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m204_m06a_door_alignment.ps1 `
  -OutputDirectory .local/revalidation/M204-reproduction-2 `
  -ScratchPrefix M204-reproduction-2
```

Two independent runs pass **6/6** wrapper checks; all six embedded M186 route searches pass **29/29**. Outputs match byte-for-byte:

| Artifact | SHA256 |
|---|---|
| `m204-m06a-door-alignment.json` | `1DE5A9338C908E3C97C2F3CBDBC5E11B57C5BE4FFA3EA9F5BBE44487B8EFC72B` |
| `m204-checks.json` | `66D19DE08A9637306C235D6EC7354D203DB6CFA483B48D7A1872CB62F640D941` |
| `m204-door-samples.csv` | `B39FC452D5270648DFDF78C37C441E605D04F2967E85AD79C2D0429171910AFD` |

**0/3** door positions find a route. All reach 5,940 nodes. The nearest reachable point is 12 ft from the west and centered door samples and 9.5 ft from the east sample. No route reaches any opening, so the measured route overlap with A is zero. Moving the door east improves the distance but does not solve the pantry-side approach.

## Limits

This does not prove all door placements or dining layouts fail. A remains an unassigned bath search option released only in this sensitivity; B remains unassigned and protected. The pantry, furniture, stool-use and openings remain plan proxies. No physical wall/door/threshold/site geometry is validated, and no code, accessibility, structural, permit or construction-readiness result follows. Revit, IFC, selected-D and Incoming RFAs are unchanged.

## Next

The fixed 5 × 7 ft M-04 pantry is now a consequential design constraint. Ask whether its test footprint may move as a separate sensitivity, or keep it pinned and continue searching furniture placement around it. Do not infer pantry flexibility from this failed route search.
