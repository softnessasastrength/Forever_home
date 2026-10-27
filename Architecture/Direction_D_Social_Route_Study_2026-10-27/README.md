# Direction D social route and furnishing fit study

Status: **unapproved schematic route/furnishing comparison**. This study extends the existing B-first adjacency candidate that protects the owner's M-06 pantry-side search window. It does not modify selected-D geometry or establish walls, openings, floor assemblies, site orientation, code compliance, accessibility, structure or construction readiness.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1 -LayoutVariant BathFirstAdjacencyCandidate
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_direction_d_social_route_study.ps1
```

The first command regenerates the separately documented B-first room-placement candidate. The second reads that room-block study, selected-D kitchen/island inputs, the kitchen/dining/porch specification and the selected-D decision. It records SHA256 fingerprints and emits `study.json`, `checks.json`, two furnished-route SVGs and a porch-orientation comparison. Run both commands to reproduce the complete chain.

## Scheme tested

The existing candidate keeps the documented D block areas and connects kitchen to living, dining and pantry. It retains M-06 window B as an unassigned search window. The inherited kitchen island is placed from selected-D's local source coordinates; its test rectangle is 8 × 4 ft. The kitchen-to-dining route starts beyond the 2 ft stool allowance and uses the remaining 4 ft to the room-block edge, a 48 in geometric route segment. The prior 24 in counter-depth test band yields a 48 in island aisle. The east-side island-to-kitchen-edge distance is 56 in, above the documented 42 in minimum if the half-wall edge is located there. A 15 ft kitchen/living shared-edge allowance leaves 7 ft after an 8 ft half-wall, above the documented 6 ft opening. The wall itself is not placed.

The dining study uses the documented 36 × 60 in table and 18 × 20 in chair proxies. It reserves a 36 in wide route through the east side of dining and around the unoccupied south end of the table to a **proposed** French-door opening. The porch keeps its documented 12 × 10 ft (120 sf) footprint and aligns directly beyond dining with the inherited 6 in nominal separation zone. A companion drawing compares the documented dimensions in both orientations.

Two door positions use the **same** balanced four-chair arrangement: two chairs on the west long side, and one at each table end. This isolates the door-position trade-off instead of quietly changing the furniture between comparisons.

- **Centered-door option:** the nominal 5 ft pair stays on the dining centerline. The 36 in route corridor has a 10 in minimum plan gap to the nearest 18 × 20 in chair proxy.
- **Offset-door option:** the nominal 5 ft pair moves 1 ft 6 in east of dining centerline. Its route-to-chair-proxy gap increases to 15 in, a 5 in improvement. The pair leaves a nominal 20 in east return on the 11 ft 4 in dining edge. This remains arithmetic only; actual framing/jamb requirements are undocumented.

## Results and trade-offs

The current run passes **16/16** schematic checks. They check source dimensions, island inclusion and clearances, route width, table clearance, the full 36 in route corridor against chair proxies, the measured improvement from the offset option, porch adjacency and both documented orientations, numeric test-outline extents, preservation of the unassigned M-06 search window, half-wall edge arithmetic, documented input presence and recorded fingerprints. Chair clearance is computed from each orthogonal route centerline segment to each chair rectangle, less half the corridor width; the rounded minimum is reported. This avoids treating the corridor's rectangular drawing envelope as though every corner were occupied.

With the 12 ft side along dining, the porch leaves **4 in** between its room-block edge and the 42 ft main-shell test-outline edge. That is not an exterior-wall allowance. Rotating it so the 10 ft side meets dining preserves 120 sf and leaves 8 in on each side of the dining edge, but extends **20 in beyond** the 42 ft test outline. The rotated option is a separate porch projection to investigate, not permission to enlarge the house; site, roof, foundation and exterior-envelope coordination remain necessary. The east-side entry in the inherited B-first candidate also remains a material unresolved trade-off: its approach/front orientation is unknown.

Neither nominal door option verifies a 36 in clear leaf. The source specification permits a 5 ft pair and calls for at least a 32 in clear leaf; actual clear width, swing and threshold must be confirmed against a selected product and site conditions. The proposed route is a plan-coordinate check with furniture proxy rectangles, not an accessible-route determination. The 10 in and 15 in values are geometric separations to those proxies, not prescribed ergonomic or code clearances. Flooring, door swings, appliance use, wall thicknesses and actual service routes are not modeled.

Reproduce and review [the centered-door plan](social-route-plan.svg), [the offset-door plan](social-route-plan-offset-door.svg), [porch-orientation options](porch-orientation-options.svg), and the machine-readable [study report](study.json). No IFC was generated: this is an unapproved 2D comparison, not a Revit authoring update. The validated selected-D and M-02 IFC evidence remains unchanged.

## Owner decision still needed

The current evidence favours retaining the larger D room blocks for a detailed schematic, but it does not select the B-first room arrangement or porch position. The most consequential choices are whether to treat the porch as a separate 10 × 12 ft projection beyond the test shell or revise the room arrangement, whether the dining door should stay centered despite the cramped seating option, and whether the east-side entry trade-off is acceptable. These are surfaced for review before any wall/floor modeling.
