# M181 - Check the social route against all room interfaces

**Status:** the revised 36-in route clears the modeled, assigned static proxies, but the sub-inch margins make it a fragile proposal. No room or layout is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m181_all_room_interfaces.ps1 -OutputDirectory .local\revalidation\M181-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m181_all_room_interfaces.ps1 -OutputDirectory .local\revalidation\M181-replay-b
```

The retained run and both replays pass **13/13** checks. The three artifacts match byte-for-byte across the two scratch runs: `m181-study.json` SHA256 `3DE30CFB477B1678E06B2A8AB1466FBEEE36D174602DF12DA713159AD4FF3F57`, `m181-checks.json` `60A79B320A13B34B204C7966DF5B0F63DA5D20FDC5FE99F99AC4635C55D42AF9`, and `m181-checks.csv` `B3822C01EACE9D26EF6CC155E4538EE7440DEAA4D70851C9BFE3C08A0716AA16`.

## Finding

The exact Euclidean swept-path check treats the route as an 18-in-radius buffer around its centerline and measures it against axis-aligned static proxy rectangles. M180's orthogonal elbow has a minimum clearance of **-5.96 in** against the west M-06 search-window rectangle. M181 tests a diagonal transition through `(10.4167, 14.25)` local ft, retaining the rest of the route. It clears the modeled assigned blocks and furnishings. The tightest residual separations are **0.60 in** at the assumed stool proxy, **2.00 in** at the table edge, and **0.38 in** at the west search-window boundary. The candidate kitchen block is inside source M-02 but leaves part of that source block outside its reduced test envelope; the candidate/source gaps to M-01 and M-03 are separately recorded.

## Limits and design implication

Positive static-proxy clearance does not establish a usable route. Sub-inch seat/search-window margins do not allow for movement, build tolerance or uncertain proxy geometry; the table, stools and door approach need further coordination. The west search window is already marked blocked as a bath candidate; its rectangle is only a diagnostic overlay. The east/pantry-side M-06/B window remains unassigned. No fixture placement, applicable clearance basis, service route, physical wall/opening, door leaf/swing/clear width, threshold, code/accessibility review, Revit/IFC edit or layout selection is included.

A subsequent candidate can test documented seat orientation alternatives using the same explicitly assumed proxy size, while keeping the selected-D model and M-06/B unassigned. This is a design exploration, not a recommendation or approval.
