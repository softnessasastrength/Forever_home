# Direction D main-floor design gates — 2026-10-27

Status: design coordination brief. It records the selected D test layout and decision gates; it does not assign new dimensions or authorize construction geometry.

## Existing D main-floor blocks

The selected D study uses the B-derived 40 × 42 ft main-shell test envelope. Its current main-level blocks are copied from the machine-readable D study:

| ID | Current block | Block area | Room-program reference | Review note |
|---|---:|---:|---:|---|
| M-01 Living | 16 × 15 ft | 240 sf | 180–220 sf | 20 sf above the upper study reference |
| M-02 Kitchen | 17 ft 4 in × 16 ft | 277.33 sf | 150–185 sf; older 14 × 12 ft study | 92.33 sf above the upper reference; keep as a fit-test envelope only |
| M-03 Dining | 11 ft 4 in × 14 ft | 158.67 sf | 90–120 sf | 38.67 sf above the upper study reference |
| M-04 Pantry | 5 × 7 ft | 35 sf | 25–45 sf | Inside the study reference |
| M-05 Arrival / hall | 4 ft 4 in × 12 ft | 52 sf | TBD | Must retain a usable public route and core access |

These are room-boundary blocks, not clear interior dimensions: no wall thickness, finish faces, door swings, cabinetry, furniture or actual circulation widths are represented. The variance calculations compare those block areas with preliminary room-program ranges; they do not decide which rooms should be reduced. The current five blocks total 763 sf; the remainder of the 1,680 sf shell test plate is not a verified circulation or gross-area allowance.

## Kitchen fit screen

The selected kitchen direction is perimeter induction range, sink and dishwasher, with an appliance-free 8 × 4 ft island and approximately 6 ft quartz plus 2 ft butcher-block worktop. The older kitchen specification lists 24 in deep base cabinets, 42 in minimum island clearances to perimeter counters and the half wall, and a 6 in half wall. Those inputs remain schematic and require confirmation against the selected room layout.

For a simple section across one island-to-perimeter-counter / island-to-half-wall axis, those listed dimensions require:

`24 in base cabinet + 42 in aisle + 48 in island + 42 in aisle + 6 in half wall = 162 in (13 ft 6 in)`

That is 18 in more than the older 12 ft clear-room depth note. Therefore a 12 ft axis cannot contain that particular opposing-counter/half-wall chain. A 16 ft axis leaves 30 in beyond that chain, but this remainder is not a verified route or seating allowance.

The inherited D island coordinates provide a separate, more specific depth check: the 2 ft deep perimeter-counter test strip ends at local y=2 ft; the 8 × 4 ft island starts at y=6 ft and ends at y=10 ft; the room block ends at y=16 ft. This yields a 4 ft counter-to-island work aisle, followed by exactly 2 ft for the documented seat allowance and 4 ft for the separate route. That chain consumes all 16 ft. It does not include half-wall thickness, finish build-up, appliance-open projections or tolerance. The location and orientation of the half wall have not been fixed in D, so the inherited coordinates do not prove the half-wall condition. The older 14 × 12 ft rectangle also misses the 13 ft 6 in opposing-counter/half-wall chain on its 12 ft axis, while its 14 ft axis would leave only 6 in beyond that chain.

Conclusion: keep the 17 ft 4 in × 16 ft M-02 block as a fit-test envelope, not an approved room size. Before freezing a kitchen layout, place the half wall relative to both axes and test cabinet runs, appliance doors, stool occupation and the independent dining route in the same plan. No dimension has been changed.

## M-06 public half-bath zone options

The owner selected the arrival / hall edge as the first public zone to test for M-06. Its exact position, footprint and service route remain unassigned. Options B and C are deferred unless the arrival/hall test proves unworkable:

| Option | Zone to test | Advantages | Main tradeoff / check |
|---|---|---|---|
| A — Arrival / hall edge | Off the public arrival route near M-05 | Guests can reach it without crossing private rooms; makes the public/private boundary legible | **Owner-selected test zone.** Preserve the approach to the stair core and resolve door maneuvering before locating a room |
| B — Pantry / kitchen edge | Near M-04 and M-02 | Convenient from the social area and could reduce travel through the house | May consume pantry or kitchen test area; no plumbing stack or service path is established |
| C — Living / dining perimeter | At the edge of the main social rooms | Can avoid placing the door directly in the arrival hall | Risks interrupting the open social axis and may put the door in a prominent sightline; service route still unknown |

The selected zone has two dimensionless-with-respect-to-the-bath, but coordinate-bounded, search windows in the existing D block study. Coordinates are local feet from the study frame; these are empty room-block gaps, not proposed rooms or clear interior dimensions:

| Search window | Bounds from existing blocks | Gross envelope | Tradeoff to test |
|---|---|---:|---|
| A — West of the core approach | x = 12 ft to 17 ft 2 in; y = 16 ft 2 in to 27 ft 7 in | 5 ft 2 in × 11 ft 5 in; 58.99 sf | Dining-side alternate. It terminates at the lower-to-main landing; protects the kitchen/pantry side but may compromise dining-side openness |
| B — East of the core approach | x = 21 ft 2 in to 34 ft 4 in; y = 17 ft 2 in to 24 ft 2 in | 13 ft 2 in × 7 ft; 92.17 sf | **Owner-selected first fit-study candidate.** Beside the pantry and public core approach; larger search window, but changes kitchen/pantry organization and has no established service connection |

The generator checks each window against the placed room blocks and the stair/lift comparison rectangles. Passing those checks only confirms that the search windows occupy currently unassigned schematic space. Neither is a bath fit: circulation width, door swing, fixture clearances, wall thickness, plumbing, ventilation and actual entry are not included. The main-plan SVG highlights B as the selected first search area and shows A as the alternate; both remain search extents only.

In the shared plan frame, pantry-side B has a 9 ft × 7 ft (63 sf) horizontal projection overlap with upper U-06. This is a derived stacking opportunity worth testing against actual fixture and wet-wall locations; it does not establish a drain, vent, wet-wall alignment, or service route. No bathroom fixture geometry is modeled in either room block.

## Next design sequence

1. Test M-06 in search window B using documented half-bath fixture/clearance requirements; if those inputs are absent, keep the footprint TBD and request only the missing design choice or reference. Retain A as fallback if B conflicts with the plan.
2. Retain the current 17 ft 4 in × 16 ft M-02 block as the working test envelope for one kitchen layout iteration; compare the resulting area honestly with the room-program range and revisit the block if the owner prefers a smaller kitchen.
3. Place only the documented kitchen components as schematic layout geometry, testing the 8 × 4 ft island, perimeter work zone, 42 in minimum clearances, stool side and dining path. Sink orientation, exact appliance models and window/hood routing remain choices or product/site checks.
4. Keep walls, doors/openings, floor assemblies and native stairs out of the model until their dimensions and interfaces are documented. The D Revit room-space model and IFC remain the stable comparison base.

The D space study is not structural, accessible, code compliant, permit ready or construction ready. Those claims remain outside the evidence collected here.
