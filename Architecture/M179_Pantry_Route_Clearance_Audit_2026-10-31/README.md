# M179 - Test the pantry conflict and route dogleg

**Status:** unapproved route comparison against an unapproved bath-first room-block alternative.

M179 overlays M178's local candidate origin on the existing bath-first main-floor block origin, then checks the straight east-aisle route against that alternative's M-04 pantry rectangle. It separately tests a dogleg that moves west before the pantry block begins and continues along the dining target's east edge.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m179_pantry_route_conflict.ps1 -OutputDirectory .local\revalidation\M179-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m179_pantry_route_conflict.ps1 -OutputDirectory .local\revalidation\M179-replay-b
```

The process-scoped execution-policy argument is required on this machine for script-file execution; no persistent Windows or security setting was changed. The report, check JSON and CSV should match across both runs and the retained package.

## Finding

In the bath-first source alternative, M-02 begins at `(0.667, 0.667)` ft and M-04 pantry occupies `(12.5, 17.167)` ft with a 5 x 7 ft block. Relative to the M178 candidate origin, the pantry begins at `x = 11.833 ft`, `y = 16.5 ft`.

The M178 straight route runs up the east kitchen aisle at `x = 11.25 ft`. Two of its corridor rectangles overlap the pantry rectangle; one reports 5.5 sf of positive-area intersection. This invalidates the straight route for this room-block comparison, while leaving the M178 kitchen cross-section result intact.

The dogleg route is:

`(14.5, 10) -> (11.25, 10) -> (11.25, 14.5) -> (9.5, 14.5) -> (9.5, 22.5) -> (8.5, 22.5) -> (8.5, 27.5)` ft.

It shifts west at `y = 14.5 ft`, before the pantry begins at `y = 16.5 ft`, then runs through the unseated east-side dining band. It has zero positive-area intersections with the modeled pantry, island/stools, table/chairs, counter or wall rectangles; it crosses the nominal 5 ft porch-door reservation and reaches 3 ft into the porch. The short dogleg connector extends 21 in east of the dining target, below the pantry's south edge. The long dining leg stays within the 11 ft dining width and is tangent to the table's east edge; that arrangement depends on there being no east-side chair.

The retained report and two scratch replays pass **21/21** checks and match byte-for-byte. Waypoints are stored as `{x, y}` objects so downstream scripts can consume them directly.

## Limits

The bath-first blocks are unapproved, and their kitchen/dining areas exceed the owner program targets. This is a coordinate overlay, not a selected house layout. The 21 in connector spill remains unassigned and could meet another room or shell boundary. Chair movement, occupied route, appliance-open envelopes, actual clear door widths, wall construction, thresholds, site, Revit and IFC remain unverified. M-06/B stays unassigned. No code-compliance, accessibility, structural-safety, professional-certification, permit or construction-readiness claim is made.
