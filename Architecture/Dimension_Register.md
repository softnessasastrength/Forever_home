# Forever Home architectural dimension register

Updated 2026-11-01 from the Selected-D study and current owner directions. This is a design-coordination register, not a permit or construction schedule.

## Current geometry basis

| Item | Working dimension / rule | Status and source |
|---|---:|---|
| Main plan envelope | 40 × 42 ft | Owner now confirms Selected-D is acceptable as the current dimensional basis. Schematic/test envelope in `Architecture/Selected_Design_Iteration_2026-10-27/study.json`; not surveyed or site-verified. |
| Lower plan envelope | 36 × 32 ft | Same Selected-D study basis; no expansion to M302's hypothetical 38⅓ × 40 ft shell in the active design. |
| Upper plan envelope | 36 × 32 ft | Same Selected-D study basis. |
| Main interior ceiling | 8 / 9 / 10 ft alternatives | Owner selected a clearly labeled 8–10 ft ceiling study range. These are clear-ceiling alternatives, not floor-to-floor datums. |
| Standalone wall-height comparison | 8 / 9 / 10 ft wall-top reference alternatives | Proposed isolated comparison only. Each case is one storey at a local zero datum; no floor, ceiling, or finish assemblies are modeled. Its top reference is a clear-height proxy, not a coordinated building section. |
| Floor-to-floor heights and elevations | TBD | Owner confirms the stair/level relationship stays unresolved while ceiling cases are modeled. Do not reuse Selected-D's 5-ft level spacing as an actual datum. |
| Exterior/partition wall thickness | TBD | M299's template `Wall 1`, 8 in, is only a disposable visualization placeholder; not selected. |
| Floor and roof assemblies | TBD | No assembly thickness or structural build-up is approved. |
| Garage | 576 sf allowance (24 × 24 arithmetic only) | Schematic area allowance in Selected-D README; shape, connection and site fit unresolved. |
| Porch | 12 × 10 ft study footprint | Prior patio/porch study input. Its exact attachment/location may move; it is not the full patio or a site-fit result. |

## Inherited Selected-D room-block dimensions

These values are copied from `Architecture/Selected_Design_Iteration_2026-10-27/room-area.csv`. They describe schematic clear rectangles before wall thickness and do not constitute approved final room sizes. Circulation rectangles are listed separately from rooms.

### Main level

| ID | Space | Width × depth (ft) | Area (sf) | Status |
|---|---|---:|---:|---|
| M-01 | Living room | 16 × 15 | 240.00 | Inherited; above 180–220 sf program range. |
| M-02 | Kitchen | 17⅓ × 16 | 277.33 | Inherited; above 150–185 sf program range; minimum route-passing envelope remains a priority. |
| M-03 | Dining | 11⅓ × 14 | 158.67 | Inherited; above 90–120 sf program range. |
| M-04 | Pantry | 5 × 7 | 35.00 | Inherited block; within the 25–45 sf program range. |
| M-05 | Entry / hall | 4⅓ × 12 | 52.00 | Inherited block; coat/mudroom allocation and topology remain unresolved. |
| M-06 | Half bath | — | — | No footprint placed; keep A protected, B unassigned. |

### Upper level

| ID | Space | Width × depth (ft) | Area (sf) | Status |
|---|---|---:|---:|---|
| U-01 | Primary bedroom | 16 × 10 | 160.00 | Inherited; within 150–170 sf program range. |
| U-05 | Primary bath | 9 × 10 | 90.00 | Inherited block; separate tub plus tiled rain shower direction is newer; fixture fit unresolved. |
| C-PRIVATE | Private connector | 6½ × 10 | 65.00 | Circulation rectangle, not room area. |
| U-02 | Boutique | 16 × 9⅔ | 154.67 | Inherited; within 110–160 sf range; direct shared-hall arrival required. |
| C-UPPER | Upper hall | 4 × 30⅔ | 122.67 | Circulation rectangle, not room area. |
| U-04 | Guest bedroom | 13⅔ × 8 | 109.33 | Inherited; within 100–120 sf program range. |
| U-06 | Jack-and-Jill bath | 10 × 12 | 120.00 | Inherited block; clearances/doors/services unresolved. |
| U-03 | Hybrid bedroom / office | 13⅔ × 9⅙ | 125.28 | Inherited; within 120–150 sf program range; private route only. |

### Lower level

| ID | Space | Width × depth (ft) | Area (sf) | Status |
|---|---|---:|---:|---|
| L-03 | Lower full bath | 9 × 10 | 90.00 | Inherited block; accessible route/product fit unresolved. |
| L-04 | Laundry | 9 × 8 | 72.00 | Inherited block; appliance/door/service clearances unresolved. |
| L-05 | MEP reservation | 9 × 11⅔ | 105.00 | Reservation only; equipment and working envelopes unresolved. |
| L-07 | Arrival + dry storage | 9 × 11½ | 103.50 | Inherited block; entry/site relationship unresolved. |
| L-06 | Technology area | 8 × 8 | 64.00 | Inherited block; ventilation, service and separation unresolved. |
| L-01 | Lower flexible living | 13⅔ × 18⅓ | 250.56 | Inherited comparison target for same-area stair/layout studies. |
| C-LOWER | Lower arrival / circulation | 6⅔ × 11⅚ | 78.89 | Circulation rectangle; stair integration unresolved. |
| L-02 | Bedroom-capable flex | 11 × 10 | 110.00 | Inherited comparison target; bedroom qualification and access unresolved. |

## Owner-directed interior controls

| Item | Current direction | Dimension status |
|---|---|---|
| Kitchen island | Keep 8 × 4 ft, appliance-free; preserve the existing roughly 6-ft quartz + 2-ft butcher-block finish direction. | Island footprint fixed for comparison; kitchen envelope is a minimum-area search, not an approved room size. Preserve the 23.75-in stool seat as a recorded exception. |
| Kitchen/dining/porch search | Allow dining and porch to move within the hypothetical study shell while searching for the smallest route-passing kitchen that fits the island. | Current blocks remain study geometry; no exact revised room dimensions selected. |
| Living / kitchen | Prefer a fully open connection. | Opening width and wall/beam condition unresolved. |
| Lower flex rooms L-01 / L-02 | Preserve their source areas in stair/layout comparisons unless a separately labeled alternative is requested. | Source areas are comparison targets, not selected final room sizes. |
| Main half bath M-06 | Half bath at the arrival/hall edge; west A protected for study, east B unassigned. | Footprint, fixtures, door/approach and service route TBD; no bathroom is assigned to either search window. |
| Primary bath | Separate tub plus tiled rain shower, based on the owner-approved MGM Springfield visual reference. | Product, compartment sizes, clearances, door and services TBD. |
| Upper suite | U-02 requires direct hall arrival; U-03 has the private route only. | Existing room blocks remain schematic; door/opening construction details TBD. |
| Exterior finish | Match supported render intent where applicable. | Exterior siding, trim, roof finish and palette remain unspecified; do not infer them from interior renderings. |

## Stair and vertical-circulation references

Selected-D's stored 8-riser × 7.5-in = 60-in, 7-tread × 11-in, 4-ft width and 4-ft landing references are historical comparison inputs only. The owner has now confirmed the 8–10-ft clear-ceiling study range and directed that floor-to-floor spacing and the stair remain TBD until later coordination. M295–M309 stair results are bounded sensitivities, not selected geometry. Do not model a physical stair from those numbers as if the full height were resolved.

## Rules for producing geometry

1. Keep the selected-D envelope fixed at the values above; the 38⅓ × 40 ft lower shell is superseded for active design.
2. Generate 8-, 9- and 10-ft clear-ceiling alternatives as separately labeled disposable single-level cases. Do not convert ceiling height to floor-to-floor height or assign the wall top as a floor datum.
3. Use the source room blocks as initial geometry and apply newer explicit decisions as visible proposals. Do not silently replace room dimensions.
4. Keep rooms, fixtures and routes separate when their fit basis is unresolved. Preserve unassigned status for M-06/A/B.
5. Mark the 8-in Revit template wall only as a placeholder in isolated massing. Do not report it as an approved wall assembly.
6. Keep the selected-D source and existing RVT/IFC files unchanged; test new geometry in disposable derivatives.
