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

## Main-floor adjacency candidate — not owner-selected

The owner-selected D room arrangement does not place the kitchen directly beside dining or living. A separate candidate test now repositions the same five main-floor room blocks without changing their dimensions or areas. It derives each shift from the existing 6 in wall allowance; this is a comparison layout, not a replacement decision.

| Relationship | Candidate plan result | Limit |
|---|---|---|
| Kitchen ↔ living | 15 ft shared edge; an 8 ft half-wall segment leaves 7 ft open, above the documented 6 ft minimum | Wall segment location, actual opening and room interfaces remain unmodeled |
| Kitchen ↔ dining | 11 ft 4 in shared edge across a 6 in nominal wall zone | No opening, porch doors, floor continuity or chair clearance tested |
| Kitchen ↔ pantry | 5 ft shared edge across a 6 in nominal wall zone; documented 2 ft 6 in door reservation fits in plan | Door swing and cabinet/appliance conflicts untested |
| Entry / hall ↔ living | 12 ft shared edge across a 6 in nominal wall zone | Entry door and clear opening not modeled |

This placement clears the current room/core rectangles and preserves all five room areas. It also blocks the owner-selected pantry-side M-06 window B: **79.33 sf of the 88.67 sf search window overlaps the proposed dining block**. B still projects over upper U-06 by 59.5 sf, but no fixture alignment or service route is established. The dining-side window A remains clear in this room-block test and is only a fallback candidate; it is 5 ft 2 in × 11 ft 5 in gross and has no demonstrated bath fit. The candidate retains the living, kitchen and dining program-area variances.

Reproduce with `powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1 -LayoutVariant AdjacencyCandidate`. Its separate drawing package passes 46/46 rectangle/provenance checks and XML parsing. It has not been exported to Revit or IFC because it is not the owner-selected room placement. See [the candidate study](Direction_D_Adjacency_Study_2026-10-27/README.md). The owner-selected D arrangement and its validated Revit/IFC evidence remain unchanged.

## B-first adjacency candidate — not owner-selected

A second comparison protects the owner's pantry-side first-fit priority while retaining direct kitchen/living, kitchen/dining and kitchen/pantry edges. It preserves the five room areas and keeps B's 13 ft 2 in × 7 ft (92.17 sf) search extent clear of the proposed room blocks and stair/lift comparison geometry. The search window's 63 sf projection over upper U-06 remains a potential stack coordination clue only.

The candidate moves M-01 east of M-02, places M-03 and M-04 north of M-02, and moves M-05 to the east exterior wall near the front of the local plan. The entry's facade orientation, exterior approach and porch connection are not established. Window A then overlaps the relocated kitchen/pantry by 35.25 sf, so A is unavailable as a fallback in this comparison.

As an additional B-window check, the PowerShell output places the documented 48 in × 22 in full-bath vanity reference, its preferred 36 in approach, and the documented 30 in × 21 in toilet-front clearance reference inside B without overlap. These are source-referenced full-bath clearance rectangles, not half-bath requirements, product bodies, a room boundary or an M-06 fit. M-06 is now scoped as a main-floor half bath in `Architecture/Bathrooms_Specs.md` §1.1; exact area, product-specific clearances, door/swing, approach, vent, drain and service route remain unresolved.

Reproduce with `powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1 -LayoutVariant BathFirstAdjacencyCandidate`. The package passes 50/50 geometry/provenance/clearance-reference checks and all SVGs parse as XML. It has not been exported to Revit or IFC because it remains unapproved. See [the B-first candidate](Direction_D_BathFirst_Adjacency_Study_2026-10-27/README.md).

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
