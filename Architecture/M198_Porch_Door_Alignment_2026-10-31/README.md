# M198 porch-door alignment sensitivity

**Status:** reproducible bounded sensitivity; no tested opening center reaches the porch.

## Method

The owner authorized varying porch-door alignment independently of dining. M198 tests **15** centers at 0.5-ft intervals from 2 to 9 ft on the documented 12-ft porch face. This range keeps a five-foot opening fully inside the face. The opening size, porch footprint, dining/table/chair-use geometry and 189-sf M178 kitchen remain fixed; every center reruns the M186 quarter-foot 36-in route search. Door-center samples are not design selections.

Pantry-side M-06/B remains an unassigned obstacle. The porch footprint overlaps the alternate west M-06/A diagnostic window by **0.402778 sf** in every sample; A remains unassigned, not a room. Any route using A would require a separate trade-off study.

## Reproduction and results

From the repository root in Windows PowerShell 5.1, use two fresh output and scratch directories:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m198_porch_door_alignment.ps1 `
  -OutputDirectory .local/revalidation/M198-reproduction-1 `
  -ScratchPrefix M198-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m198_porch_door_alignment.ps1 `
  -OutputDirectory .local/revalidation/M198-reproduction-2 `
  -ScratchPrefix M198-reproduction-2
```

The script refuses to overwrite nonempty outputs or scratch directories. Two independent PowerShell 5.1 runs pass **7/7** M198 checks, and all 30 embedded M186 searches pass **29/29**. JSON, checks and CSV match byte-for-byte:

| Artifact | SHA256 |
|---|---|
| `m198-porch-door-alignment.json` | `E9C5967E8FD22CAC98E0726154D6F73815DF7086D4DF860A32FA659CE4B7900C` |
| `m198-checks.json` | `28CAE185F069DBE0CD885738970418F5E8B9BC3C3AAE949903C6F32671992C21` |
| `m198-door-samples.csv` | `B2FF06DAD73262C79366D0748F1009CDB6EFF84252BCE8EB9305513F626DAC32` |

**0/15** door centers find a route. The closest grid point is 9.5 ft from the door at the eastmost tested center, x=9 ft; the centered x=5.5-ft sample remains 12 ft away. Every search reaches the same 5,296 nodes. Moving the opening east improves the Manhattan gap but does not make a continuous path.

## Inputs, limits and safeguards

The report binds M186, M178, M195, the room/porch specification, selected-D, bath-window sources and the owner kitchen-area decision by SHA256. Selected-D remains `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`.

The six-foot alternative opening is not tested. Rectangular proxies do not model actual walls, door leaves/swing, thresholds, furniture movement, appliance-open states, site geometry or tolerances. A sampled route is not a code, accessibility, structural, professional, permit or construction-readiness result. Revit, IFC and Incoming RFAs are unchanged; M-06/B remains unassigned.

## Next

Compare the owner's preferred fully open kitchen/living connection in an isolated route sensitivity, keeping the half-wall case as a comparison. M187 found that removing only the half-wall did not restore its sampled route; the combined layout still needs testing.
