# M172 — Compact kitchen / dining coupled constraint screen

Status: **source-verified dimensional screen; no layout selected**. This analysis tests the owner-directed 14 × 12 ft kitchen and 11 × 10 ft dining study targets against the current kitchen and furniture specifications. It does not change the selected-D source, assign room geometry, or claim the open-plan fit is resolved.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m172_compact_social_space_constraints.ps1
```

Use a separate output directory for a disposable replay:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m172_compact_social_space_constraints.ps1 -OutputDirectory .local/revalidation/M172-a
```

The script checks its transcribed dimensions against `Requirements/Room_Program.md`, `Architecture/Kitchen_Dining_Porch_Specs.md`, `Decisions/2026-10-28_House_Design_Direction_Followup.md`, and `Decisions/Kitchen_Island_Finish.md`. It binds the read-only selected-D study and fails if its previously verified SHA256 changes. It produces the JSON report, axis comparison CSV, SVG overview, and a machine-readable 22-check result file.

## Findings

The owner-directed M-02 block is 14 × 12 ft. The source-documented perimeter run is 12 ft 6 in: 36 in sink base + 24 in dishwasher + 12 in landing + 30 in induction range + 12 in landing + 36 in refrigerator. The specified opposing section is 13 ft 6 in: 24 in base depth + 42 in aisle + 48 in island depth + 42 in aisle + 6 in half wall.

Those dimensions compete for perpendicular axes. On the 14 ft axis, the 13 ft 6 in section leaves 6 in, while the 12 ft axis is 6 in short of the 12 ft 6 in run. Rotating the arrangement lets the run fit along 14 ft with 18 in remaining, but leaves the 12 ft axis 18 in short of the 13 ft 6 in section. Neither strict orthogonal orientation fits both coupled requirements wholly inside 14 × 12 ft.

The 8 ft island plus two 42 in end-clearance allowances spans 15 ft; that exceeds the 14 ft target axis by 12 in and the 12 ft axis by 36 in. The dining target can contain the documented 9 × 11 ft table-plus-minimum-clearance rectangle in one orientation, with 12 in spare along its 10 ft axis and no reserve along its 11 ft axis. The preferred 10 × 12 ft envelope does not fit: it exceeds the 11 ft target axis by 12 in.

As a purely numeric control, the larger selected-D test blocks (M-02 17 ft 4 in × 16 ft; M-03 11 ft 4 in × 14 ft) contain these individual envelopes. That comparison explains why the older target is constrained; it does not make the larger blocks an approved replacement or prove their interior fit after walls and finishes.

## What this does not decide

The owner's stated next test is the combined open kitchen/dining/living arrangement. M172 has not yet placed the island, perimeter work zone, occupied stool proxies, table/chairs, half wall, porch opening, and a connected 36 in route in one shared coordinate plan. In particular, the dining rectangle test is not a circulation path, and adjacent open space may change the kitchen result. The current analysis therefore identifies the coupled deficits but does not prove that the combined social space fails.

Room adjacency and boundary orientation, half-wall location, island orientation and position, seating occupation, specific appliance door envelopes, actual porch-door clear opening/swing, finish build-up, tolerance, and living-room interface are not resolved. No Revit elements or IFC were produced. No room size, kitchen layout, code result, accessibility finding, structural conclusion, or construction decision is approved.

## Verification

Three PowerShell 5.1 runs were made: the retained package and two independent `.local/revalidation/` outputs. Each passes **22/22** checks. JSON, CSV, SVG, and checks files match byte-for-byte across all three directories; all three SVG copies parse as XML. Selected-D input SHA256: `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`.

The next useful design milestone is a 2D integrated open-plan placement and route search over documented M-02/M-03 and living-zone interfaces, with all room boundaries explicitly identified as proposed and no change to the selected-D baseline. The owner already authorized this as the next test in the 2026-10-28 follow-up; route and door dimensions must remain assumptions until supported by source dimensions.
