# Direction D — B-first adjacency candidate

Status: **unapproved schematic alternative**. This comparison gives priority to the owner's selected pantry-side M-06 search window B while reconnecting the kitchen, living, dining and pantry room blocks. It does not replace the owner-selected Direction D layout.

## Candidate room blocks

| Room | Proposed test origin (ft) | Test dimensions (ft) | Area (sf) |
|---|---:|---:|---:|
| M-01 Living | (18.5, 0.667) | 16 × 15 | 240 |
| M-02 Kitchen | (0.667, 0.667) | 17.333 × 16 | 277.33 |
| M-03 Dining | (0.667, 17.167) | 11.333 × 14 | 158.67 |
| M-04 Pantry | (12.5, 17.167) | 5 × 7 | 35 |
| M-05 Entry / hall | (35, 0.667) | 4.333 × 12 | 52 |

The main-floor block dimensions and areas are retained. Coordinates are local schematic feet inside the existing 40 × 42 ft test shell; they are not a site datum or surveyed wall faces.

## What the plan checks support

- Kitchen and living have a 15 ft shared edge across the 6 in nominal wall gap. An 8 ft half-wall segment leaves 7 ft open, exceeding the documented 6 ft opening reference. The wall and opening are not modeled or located.
- Kitchen and dining have an 11 ft 4 in shared edge across the same nominal wall gap.
- Kitchen and pantry have a 5 ft shared edge; this is long enough in plan for the documented 2 ft 6 in pantry-door reservation. Door placement and swing are unresolved.
- Entry / hall and living share a 12 ft edge. M-05 moves to the east exterior wall near the front of the local plan. The actual front orientation, exterior approach, porch connection and entry door remain unverified; this is the candidate's principal tradeoff.
- Owner-selected M-06 search window B remains clear of room and stair/lift comparison rectangles. Its original 13 ft 2 in × 7 ft (92.17 sf) gross search extent still projects over upper U-06 by 63 sf. This is a plan overlay only, not a bath footprint or evidence of plumbing alignment.
- Search window A is blocked by the relocated kitchen and pantry, with 35.25 sf of overlap. B is therefore the only unblocked search window in this arrangement.

## B-window fixture-clearance comparison

The generator places reference clearance rectangles inside B using the bathroom specification's **full-bath** references: a 48 in × 22 in vanity, its preferred 36 in front clearance, and a 30 in wide × 21 in deep toilet-front clearance zone (15 in from the toilet centerline to each side obstruction). They fit within B without the two front-clearance rectangles overlapping.

This is a fixture-clearance arrangement inside an unassigned search window, not an M-06 room or fixture fit. The bathroom specification explicitly excludes a powder-room design. The toilet body, powder-specific fixture choice, wall thickness, actual door and swing, approach route, ventilation, drain and service path remain unresolved. No bathroom area is assigned.

## Remaining tradeoffs

M-01 living (240 sf), M-02 kitchen (277.33 sf) and M-03 dining (158.67 sf) remain above their preliminary program ranges. The 17 ft 4 in × 16 ft kitchen reference still needs appliance-open, island, seating and circulation review. The east-side entry arrangement needs owner review before adoption. No room placement or entrance location has been approved by this candidate.

## Reproduce

From the repository root in Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1 -LayoutVariant BathFirstAdjacencyCandidate
```

The separate study package contains `study.json`, `checks.json`, room schedules and three plan SVGs. The current run passes 50/50 geometry/provenance/clearance-reference checks and all SVGs parse as XML. This candidate has not been exported to Revit or IFC because it is unapproved. The owner-selected D Revit/IFC study remains the validation baseline.

These checks do not establish wall/opening geometry, door swings, full circulation, appliance-open clearances, stairs in section, code compliance, accessibility, structure, MEP coordination, permit readiness or construction readiness.
