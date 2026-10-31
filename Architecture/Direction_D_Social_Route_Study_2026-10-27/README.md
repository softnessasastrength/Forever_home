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

The existing candidate keeps the documented D block areas and connects kitchen to living, dining and pantry. It retains M-06 window B as an unassigned search window. The inherited kitchen island is placed from selected-D's local source coordinates; its test rectangle is 8 × 4 ft. The perimeter modules are placed west-aligned on the north kitchen edge to leave an east-side route lane. The kitchen/living edge is represented by a proposed 8 ft half-wall, a 6 ft opening and 1 ft of remaining edge; none is an authored wall or opening. M-06/B remains unassigned.

The study uses the documented 36 × 60 in table and 18 × 20 in chair proxies. Two 36 in wide route proposals start on the living-room side of the proposed kitchen/living opening, pass east of the modeled kitchen run and island, continue around the east side and unoccupied south end of the dining table, cross a nominal French-door reservation and reach 3 ft inside the proposed 12 × 10 ft porch rectangle. The corridor rectangles are checked against every perimeter module, the island, an assumed 2 ft stool-occupancy plan-depth proxy, the dining table, chair proxies and proposed half-wall. This route is a living-to-porch path; it does **not** establish a post-seating route from the island work face.

Two door positions use the **same** balanced four-chair arrangement: two chairs on the west long side, and one at each table end. This isolates the door-position trade-off instead of quietly changing the furniture between comparisons.

- **Centered-door option:** the nominal 5 ft pair stays on the dining centerline. The 36 in route corridor has a 10 in minimum plan gap to the nearest 18 × 20 in chair proxy.
- **Offset-door option:** the nominal 5 ft pair moves 1 ft 6 in east of dining centerline. Its route-to-chair-proxy gap increases to 15 in, a 5 in improvement. The pair leaves a nominal 20 in east return on the 11 ft 4 in dining edge. This remains arithmetic only; actual framing/jamb requirements are undocumented.

## Results and trade-offs

The repaired run passes **29/29** schematic checks. Both polylines remain axis-aligned, and their corridor rectangles retain a 36 in cross-section with no positive-area intersections against the modeled kitchen modules, island, assumed stool-occupancy zone, dining table, chair proxies and half-wall. The corridor retains an 8 in minimum geometric separation from the table proxy. Rounded-polyline clearance to chair proxies is 10 in for the centered-door case and 15 in for the shifted-door case; the separate conservative square-corner rectangle screen leaves at least 10 in in both cases. These are plan-coordinate distances, not prescribed clearances. The 5 ft nominal door reservation is still not proof of a 36 in clear leaf, and wall thickness, threshold, swing and finished conditions are absent.

The chair proxy metric is the minimum distance from each orthogonal route centerline segment to each chair rectangle, less the 18 in route half-width. The rendered route uses rounded joins. For obstacle intersections, the script also fills the corners with square boxes, making the collision check conservative relative to the rendered rounded corners.

### M173 route correction and island-access limitation

The prior checked-in path passed its **22/22** checks because it was never tested against its own perimeter run. Replaying that exact prior script and independently intersecting its recorded route corridor with its centered cabinet modules finds **6.0 sf** of overlap: 0.5 sf with the dishwasher, 2.0 sf with the west range landing and 3.5 sf with the induction range. Its reported 48 in post-stool clearance also measured to the room-block edge and ignored the 24 in-deep perimeter run. From the island edge to the counter front, the modeled aisle is 48 in; reserving an **assumed 24 in occupied-stool plan-depth proxy** leaves **24 in**, 12 in short of the 36 in route target. The kitchen specification defines the dining-facing seating side, two stools and a 12 in overhang, but does not define this occupied-use depth; the study now labels the 24 in as an assumption. It does not claim a continuous route from the island.

The corrected living-to-porch path is checked as axis-aligned corridor rectangles, including the proposed living opening and half-wall positions. Three PowerShell 5.1 runs (retained plus two scratch outputs) pass **29/29** and reproduce `study.json`, `checks.json` and both route SVGs plus the porch comparison SVG byte-for-byte; all three SVG files parse as XML. The report omits run timestamps so downstream M19 fingerprints remain reproducible. The candidate source generator passes **53/53** on its retained package and both scratch runs, with seven generated artifacts matching byte-for-byte. M19 refrigerator checks pass **16/16** in the retained output and two scratch runs; the fridge module is now at the west-aligned run's actual X coordinate. M21 east-entry checks pass **18/18** after rebinding to the refreshed source. See M173 in `PLAN.md` and `PROGRESS.md` for hashes and commands.

### M19 kitchen fit option

The combined plan and `study.json` include one source-dimensioned perimeter-run option in the inherited 17 ft 4 in × 16 ft M-02 room block. The test run is west-aligned on the north room-block edge and is **12 ft 6 in long** by arithmetic from the documented modules: 36 in sink base, adjacent 24 in dishwasher, 12 in landing, 30 in induction range, 12 in landing, and 36 in refrigerator. The documented 24 in base depth is used. With the selected-D 8 × 4 ft island at its existing source coordinates, the plan leaves **48 in** between the island edge and counter front. After the assumed 24 in stool-occupancy proxy, only **24 in** remains in that aisle; the 36 in post-seating route target is short by 12 in. The source does not define the proxy's plan depth. The range's minimum side landings are explicit.

A separate manufacturer-dimension stress test is documented in [M19 refrigerator envelope research](../../Research/M19_Refrigerator_Envelope_Research_2026-10-28.md) and generated by `Tools/test_m19_refrigerator_envelope.ps1`. It reads this report without editing it. As of 2026-10-28, the script passes 16/16 provenance/arithmetic/non-claim checks and regenerates its JSON, checks and comparison SVG byte-identically. Two discontinued GE reference models yield only 39 / 39.25 in closed aisle and 28 / 23.5 in with doors at 90 degrees, using the explicit 2 in rear-clearance screening allowance. Both fall short of the source-documented 42 in island/counter minimum when closed. The model data are dimensional comparisons, not live product choices. The run's nominal 48 in cabinet-face aisle must not be represented as a product-clear refrigerator aisle.

This is a fit option, not a selected arrangement. The north-wall location, west alignment and appliance order are test assumptions. The remaining wall length is not assigned to cabinetry. Appliance door-open and user-operating envelopes, vendor rough openings, sink choice, ventilation, service routes, wall thickness and Revit family extents are not tested here. The **29/29** script checks establish rectangle fit, route-to-proxy intersections and source dimensions only. No IFC was generated: the candidate remains a 2D schematic and the validated selected-D / M-02 IFC evidence is unchanged.

With the 12 ft side along dining, the porch leaves **4 in** between its room-block edge and the 42 ft main-shell test-outline edge. That is not an exterior-wall allowance. Rotating it so the 10 ft side meets dining preserves 120 sf and leaves 8 in on each side of the dining edge, but extends **20 in beyond** the 42 ft test outline. The rotated option is a separate porch projection to investigate, not permission to enlarge the house; site, roof, foundation and exterior-envelope coordination remain necessary. The east-side entry in the inherited B-first candidate also remains a material unresolved trade-off: its approach/front orientation is unknown.

Neither nominal door option verifies a 36 in clear leaf. The source specification permits a 5 ft pair and calls for at least a 32 in clear leaf; actual clear width, swing and threshold must be confirmed against a selected product and site conditions. The proposed route is a plan-coordinate check with furniture proxy rectangles, not an accessible-route determination. The 8 in table gap and 10 in / 15 in chair gaps are geometric separations to the modeled proxies, not prescribed ergonomic or code clearances. Flooring, door swings, appliance use, finished wall thickness and actual service routes are not modeled. The route begins at the living-room side and bypasses the island work face; a connected kitchen-work route remains unresolved.

Reproduce and review [the centered-door plan](social-route-plan.svg), [the offset-door plan](social-route-plan-offset-door.svg), [porch-orientation options](porch-orientation-options.svg), and the machine-readable [study report](study.json). No IFC was generated: this is an unapproved 2D comparison, not a Revit authoring update. The validated selected-D and M-02 IFC evidence remains unchanged.

## M21 east-side arrival path test

The companion [M21 plan-coordinate access comparison](m21-main-floor-access-study.svg) carries the east-side M-05 entry block and the existing M18 dining/porch alternatives onto one schematic. Reproduce it after the B-first candidate and M18 chain with:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/test_m21_main_floor_access_study.ps1
```

The input fingerprints and **18/18** arithmetic/data-guard checks are recorded in [the M21 report](m21-main-floor-access-study.json) and [check results](m21-main-floor-access-checks.json). The B-first source places M-05 8 in inside the east edge of the 40 × 42 ft test shell; its 4 ft 4 in room-block width contains a centered 36 in route proxy in plan. M-05 sits 6 in from M-01 over a 12 ft shared-edge span. The dashed line therefore tests a plausible east-to-west arrival path through M-05 toward the public living space.

That is a route proposal, not a resolved entrance design: the 6 in gap is a room-block datum, no wall/opening/door is modeled, and the actual entry location, swing, garage route, grade, front orientation and site remain unknown. The inherited M18 route and porch arithmetic is carried forward unchanged: 10 in and 15 in chair-proxy gaps for the two nominal 5 ft dining-door positions; 4 in test-outline reserve for the 12 × 10 ft porch; 20 in projection for the rotated 10 × 12 ft option. Both porch options remain 120 sf. No M-06, wall, door or IFC geometry is assigned or generated.

## Owner decision still needed

The current evidence favours retaining the larger D room blocks for a detailed schematic, but it does not select the B-first room arrangement or porch position. The most consequential choices are whether to treat the porch as a separate 10 × 12 ft projection beyond the test shell or revise the room arrangement, whether the dining door should stay centered despite the cramped seating option, and whether the east-side entry trade-off is acceptable. These are surfaced for review before any wall/floor modeling.

## M176 scope correction: route pass uses larger room blocks

The M173 route result is bound to the unapproved bath-first comparison's **17 ft 4 in x 16 ft M-02 (277.33 sf)** and **11 ft 4 in x 14 ft M-03 (158.67 sf)** blocks. The owner-directed program targets remain **14 x 12 ft / 168 sf** for kitchen and **11 x 10 ft / 110 sf** for dining. M173's 29/29 route checks therefore apply only to the larger alternative and do not establish fit at the smaller program areas. The source-bound comparison and repeated audit are in [M176](../M176_Social_Route_Target_Scope_Audit_2026-10-31/README.md). The compact integrated layout remains unresolved.
