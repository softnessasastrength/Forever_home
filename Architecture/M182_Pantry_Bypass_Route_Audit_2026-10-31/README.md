# M182 - Compare a pantry-side bypass route to the kitchen-side dogleg

**Status:** source-bound geometric alternative only. No south opening, hallway, bath position or layout is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m182_pantry_bypass_route.ps1 -OutputDirectory .local\revalidation\M182-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m182_pantry_bypass_route.ps1 -OutputDirectory .local\revalidation\M182-replay-b
```

Both independent runs pass **13/13** checks and match byte-for-byte: `m182-study.json` SHA256 `53E39B921763316D0313A6CB1777A6295F724D3FA3EFFFC2430C297C073580EE`, `m182-checks.json` `0FDE106272ECFD87B558448FA6146AD4D0562BA5F1794DCA55281B5319A3228F`, `m182-checks.csv` `2252119575992B1EFDB0C8D6503487B3FC3018BF811E294AD86101E153A14288`.

## Candidate path and trade-off

The local centerline is `(19.5,10) -> (18.667,10) -> (18.667,27.5) -> (8.5,27.5) -> (8.5,30.5)` ft, with a 36-in axis-aligned corridor proxy. It begins inside M-01, turns south through an **unassigned 44-in throat** between the source pantry and east/pantry-side M-06/B search window, then crosses the dining room's south band to the nominal 5-ft porch door and extends 3 ft into the porch test rectangle. It avoids the assumed kitchen stools and dining table and has no positive-area intersection with the modeled assigned blocks, selected-first B window, furniture or walls.

The centered route leaves only **4 in each side** to the pantry and M-06/B search-window boundaries. Its corridor edge also intrudes **2 in** into the larger bath-first M-02 source block outside the reduced 13.5-ft kitchen test block. It overlaps **4.736 sf** of the already-blocked west M-06 search-window diagnostic rectangle. The path therefore needs a room-program decision and a new opening through the south edge of M-01; neither exists in the source model. It could also constrain the bath door, approach and service path if B is later fitted.

M181's kitchen-side dogleg has only 0.60 in residual at assumed stool occupancy and 2 in at the dining table. M182 avoids those furniture pinch points but spends an unassigned strip immediately beside the proposed bath zone and requires a new living-room opening. Neither route is ready to be selected.

## Limits

Room blocks, wall/door reservations and furniture are schematic proxies. The 4-in gaps do not include wall finish, tolerance, door operation, people or furniture movement. No M-06 product, applicable clearance basis, door approach, service route, Revit/IFC geometry, code review, accessibility, structural review or professional approval is established. M-06/B stays unassigned and selected-D remains unchanged.
