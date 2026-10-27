# Direction D — main-floor adjacency candidate

Status: **unapproved schematic alternative**. This study preserves the owner-selected room types, test-shell dimensions and room areas while moving five main-floor room blocks to test the documented kitchen, dining, living and pantry relationships. It does not replace the owner-selected Direction D package.

## Candidate placement

| Room | Proposed test origin (ft) | Test dimensions (ft) | Area (sf) |
|---|---:|---:|---:|
| M-01 Living | (5.5, 0.667) | 16 × 15 | 240 |
| M-02 Kitchen | (22, 0.667) | 17.333 × 16 | 277.33 |
| M-03 Dining | (22, 17.167) | 11.333 × 14 | 158.67 |
| M-04 Pantry | (33.833, 17.167) | 5 × 7 | 35 |
| M-05 Entry / hall | (0.667, 0.667) | 4.333 × 12 | 52 |

The offsets are derived from the retained room dimensions and the existing 6 in wall allowance. No room area or test dimension was added. Coordinates are schematic local feet; they are not a site orientation or wall-face survey.

## What the geometry supports

- All five room blocks remain inside the 40 × 42 ft test shell, keep their existing areas, avoid one another and clear the stair/lift comparison blocks.
- M-01 and M-02 have a 15 ft shared edge across a 6 in nominal wall zone. An 8 ft half-wall segment would leave 7 ft of open edge, which exceeds the documented 6 ft minimum. The half-wall position is not selected or modeled.
- M-02 and M-03 have an 11 ft 4 in shared edge across a 6 in nominal wall zone. This makes a direct kitchen-to-dining opening possible in plan; the opening and porch connection are not modeled.
- M-02 and M-04 have a 5 ft shared edge across a 6 in nominal wall zone, enough in plan for the documented 2 ft 6 in pantry-door reservation. Door placement and swing remain open.
- M-05 and M-01 have a 12 ft shared edge across a 6 in nominal wall zone. No entry door or hall opening is modeled.
- The owner-selected pantry-side M-06 window B conflicts with the relocated dining block by **79.33 sf** of its 88.67 sf search extent. B also retains a 59.5 sf projection over upper U-06, but that does not compensate for the room conflict or establish plumbing. Dining-side window A is clear in this room-block test and is shown as a fallback only.

These are adjacency and rectangle checks, not wall, door, circulation, appliance-open, stair-section, porch-threshold, accessibility, code, structure, MEP or construction validation. M-06 remains unplaced with no assumed footprint, fixtures, door or service route. Room-program variances remain explicit: living 240 sf, kitchen 277.33 sf and dining 158.67 sf are above their preliminary ranges.

## Reproduce

From the repository root in Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1 -LayoutVariant AdjacencyCandidate
```

The command regenerates `study.json`, `checks.json`, schedules and all three SVGs in this directory. The current candidate passes 46/46 geometry/provenance checks; all SVGs parse as XML. Its IFC/Revit export has not been run because this alternative is not owner-selected. The separately validated owner-selected D export remains preserved.

No permit, code-compliance, accessibility, structural-safety, professional-review or construction-readiness claim is made.
