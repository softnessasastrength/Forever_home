# Selected architectural direction D — schematic iteration

Updated: 2026-10-27
Status: **owner-selected direction; schematic room blocks with a separately validated Revit space study**. This iteration embodies the owner's choices. It is not a coordinated floor plan or complete native Revit house model, permit document, or approval of dimensions and construction systems.

## Direction confirmed by owner

| Choice | Selected direction | Design consequence |
|---|---|---|
| Daily sleeping arrangement | A strategy: bedroom-capable L-02 remains on the lower level | Preserves the main floor's social rooms; step-free access to lower sleeping/bath remains unresolved. |
| Main shell | B test envelope: 40 x 42 ft | The tested main plate is 1,680 sf before walls, stair/lift voids and area-convention reconciliation. This is not approved gross or conditioned area. |
| Vertical circulation | Keep the future-lift reservation and use B's eight-riser arithmetic as a comparison baseline | 7.5 in nominal riser, 11 in tread and 15 in floor-assembly arithmetic placeholder are study values; final stair count, landing, openings, headroom, guards, structure and lift product remain open. |
| Main public bathroom | M-06 is a half bath; arrival / hall edge selected as the zone; pantry-side search window B selected for the first fit test | Exact position, footprint and service route remain **TBD**; it is intentionally omitted from geometry and area totals. B is an unassigned search envelope, not a bathroom dimension. See the design-gate brief for both windows and comparison limits. |
| Upper suite | Retain the proposed private primary bath, private connector, independent guest hall access, and hybrid/guest Jack-and-Jill | Door swings, privacy boundary, furniture and bedroom qualification remain to be reviewed. |
| Kitchen | Perimeter induction, sink and dishwasher; appliance-free 8 x 4 ft island; approximately 6 ft quartz + 2 ft butcher block | The inherited 17 ft 4 in x 16 ft kitchen test block has arithmetic fit checks, but is not an approved room size or appliance-open layout. |

## Drawings and reproducibility

- [Main floor room-block plan](main-plan.svg)
- [Upper floor room-block plan](upper-plan.svg)
- [Lower floor room-block plan](lower-plan.svg)
- [Machine-readable study](study.json)
- [Room-block area schedule](room-area.csv)
- [Room-program comparison](program-area-review.csv)
- [Geometry checks and open findings](checks.json)

The main-plan SVG shows the owner-selected M-06 arrival/hall test zone as two dashed, coordinate-derived search windows. A translucent overlay marks the 63 sf shared-frame projection with upper U-06. The search extents remain unassigned empty space, not a bathroom footprint or circulation validation; see the [design-gate brief](../Direction_D_Main_Floor_Design_Gates_2026-10-27.md).

A separate, unapproved room-placement comparison tests the main-floor social adjacencies without replacing this owner-selected study: [Direction D adjacency candidate](../Direction_D_Adjacency_Study_2026-10-27/README.md).

A second, unapproved comparison preserves the owner's first-fit priority for M-06 search window B while connecting the kitchen, dining and living blocks; it shifts M-05 to the east exterior wall and blocks window A: [B-first adjacency candidate](../Direction_D_BathFirst_Adjacency_Study_2026-10-27/README.md).

Regenerate the package from the unchanged A/B study source with Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1
```

The generator derives its initial room blocks from A/B and the existing kitchen test. `study.json` records SHA256 fingerprints of the source study, source checks, room program, kitchen decision and selected direction decision. It preserves the old studies and writes only this iteration package. Re-running it overwrites this iteration's derived files; do not edit generated files by hand. `checks.json` includes explicit upper-flight/landing, wing/bridge and bridge/shell-edge continuity checks plus their measured plan gaps; these certify only the comparison rectangles.

## Plan organization

The main plan uses the B test arrangement for living, kitchen, dining, pantry and entry/hall. The SVG shows the 8 x 4 ft appliance-free island at the location from the documented kitchen fit test; perimeter appliance locations still need development. L-02 is removed from the main level and retained in the lower plan using the existing A 11 x 10 ft study block. M-06 is removed from the former full-bath block; the arrival/hall edge is the selected test zone, but no bath rectangle is drawn. The shell and rear wings use the existing A/B test envelopes.

This choice leaves the lower bedroom and lower full bath dependent on stairs unless a selected lift or site-designed route provides access. The main half bath has no shower and does not solve that accessibility need on its own.

The upper plan keeps the existing primary and hybrid suite relationships. To keep the 11 x 10 ft lower flex block outside the projected Jack-and-Jill bath footprint, the guest room is shortened by six inches to 13 ft 8 in x 8 ft (109.3 sf), still within the room program's 100–120 sf study range. The 10 x 12 ft Jack-and-Jill block moves six inches toward the front. The two nominal door reservations to that bath move with the room. This resolves the plan-block overlap only; plumbing, acoustic, structure and floor assemblies have not been coordinated.

The 8 x 8 ft lower technology-room test block moves to the front/middle service area, outside the upper Jack-and-Jill projection. Its access, ventilation, equipment replacement route and acoustic separation are not demonstrated. Secure storage remains unlocated.

## Proposed stair and lift plan coordination

The latest D iteration lays out two comparison flights using B's inherited 8-riser arithmetic, 7 treads at 11 in and 4 ft landings. In plan, the lower-to-main route uses a lower landing at local y=28–32 ft, a 6 ft 5 in run and a main landing at y=27 ft 7 in–31 ft 7 in. For this comparison, rear edges of the 32 ft rear wing and 42 ft main shell are aligned; this maps the lower landing to main-plan y=38–42 ft. The main-to-upper run uses the same run length, with its upper landing extended 4 x 4 ft beyond the 36 x 32 ft upper wing to meet the main-shell rear edge and hall. The reproducible generator now checks that the upper flight meets the landing and the bridge meets both the rear wing and main-shell edge; all three plan gaps report 0.000000 ft. This closes the historical C-IFC plan-gap finding for the selected-D schematic only. These are schematic placements, not selected stair specifications or a verified section. Shared-wall openings, clearances, floor-edge support, headroom, guards, egress and structure remain unresolved under CO-021.

The 8 x 8 ft lift reservation is shifted 4 in west to align its west face with the upper core hall. Its door side, product dimensions, maneuvering clearances, pit, overrun and lower-level connection are unresolved. The shift and stair blocks are comparison geometry only.

The generated plan_frame_offsets_ft records how wing-local room blocks map into the shared Revit plan frame: main (0, 0), lower (0, +10 ft) so local y=28–32 ft maps to main y=38–42 ft, and upper (0, +6 ft) so its 32 ft plate ends at the upper connector start y=38 ft. The connector then reaches y=42 ft, the main-shell rear edge. These offsets derive from the current comparison geometry and are not a site datum or georeference.

## Measured block schedule

The current placed room-block totals are:

| Level | Placed blocks | Net room blocks | Test shell plate |
|---|---:|---:|---:|
| Main | 5 | 763.0 sf | 1,680 sf |
| Upper | 6 | 759.3 sf | 1,168 sf including the proposed 4 x 4 ft connector |
| Lower | 7 | 795.1 sf | 1,152 sf |

Circulation blocks are not included in net room blocks. M-06, secure storage, coat/mudroom fit and the garage-to-house transition are unplaced. Stair/lift reservations are drawn separately from room blocks; the main floor test profile after two 4 ft wide stair-run openings and the 8 x 8 ft lift opening is 1,564.7 sf, while the upper floor test profile includes the 16 sf connector. These profiles are not approved gross or conditioned areas. The totals do not imply that the remaining shell area is adequate or well used. Garage (576 sf) and porch (120 sf) remain separate schematic allowances.

The generator parses numeric allowances from `Requirements/Room_Program.md` and writes one row per placed room to `program-area-review.csv`. Current B-derived D blocks are above the study ranges for M-01 living (240 sf versus 180–220), M-02 kitchen (277.3 sf versus 150–185) and M-03 dining (158.7 sf versus 90–120). Those inherited test blocks remain unchanged pending a design tradeoff; the comparison is not an approval or automatic pass/fail rule. The area basis itself remains preliminary. M-06 is unplaced and has no numeric reference to compare.

## Verification

`checks.json` records 40 passing geometry/provenance checks: room-block containment in the test shells; positive dimensions; no same-floor room-block overlaps; no projected overlap of lower L-02 or L-06 with upper U-06; U-04 inside its documented study range; no fabricated half-bath footprint; kitchen fit-reference checks; every placed room joined to the published room schedule; stair landing/run adjacency and hall/wing alignment; lift/hall alignment; two-endpoint wall-opening intervals; floor-profile arithmetic; lower/upper frame-to-landing/connector alignment; and containment/non-overlap of the two unassigned M-06 search windows. Pantry-side B is the first test candidate; dining-side A remains the alternate. Neither window is bath geometry. Pantry-side B overlaps the upper U-06 block in plan projection by 63 sf; a plumbing route or fixture alignment is not established. The program comparison separately reports area variances rather than disguising them as passing geometry. All three SVG plans parse as XML.

These checks validate rectangles, level-frame relationships, plan-level landing/run adjacency and arithmetic only. They do not validate doors, continuous furnished routes, actual stair geometry or section, an accessible path, floor/roof assemblies, structure, MEP, site, code, or construction readiness. A separate Revit 2027.3 space-boundary study for D was regenerated at `.local/revit-pilot/selected-d/20261027T170840989Z/` from source SHA256 `669312ea7f0df0c22909364ff79bf4a5bcef2bb576c0777609158fcfa38c4145`; its IFC2X3 export passed all 23 checks in `validate_selected_d_ifc.py` with zero schema issues (source SHA256 `669312ea7f0df0c22909364ff79bf4a5bcef2bb576c0777609158fcfa38c4145`; RVT SHA256 `65860e24ba97f3ead1b6d9c2c5ee3ec5456139c05b29aa9acb8141a2d5b9c048`; IFC SHA256 `cacdc2ddcaa35155de0e040d1b1401f6cd01830a81cfb2631fab312e0dbd4f78`). The read-only Revit audit `.local/revit-pilot/audits/20261027T170859197Z/` matches saved RVT SHA256 `65860e24ba97f3ead1b6d9c2c5ee3ec5456139c05b29aa9acb8141a2d5b9c048` and reports 3 levels, 21 enclosed rooms, 0 walls/openings and 0 warnings. That native file contains rooms and 2D comparison outlines only; it is not coordinated building geometry. Compact-Core C remains a separate test model.

## Open design work

1. Reconcile the plan comparison with actual native Revit wall openings, stair runs, landings, floor edges and sections; then review headroom, guards, egress and structure. The 8-riser arithmetic remains unselected.
2. Fit and locate M-06 half bath without assuming an area; resolve drain/service routing.
3. Test M-02 appliances open, perimeter work zones, island seating and routes; revisit its 277.3 sf test block against the room program.
4. Fit coat storage, garage arrival, secure storage, porch thresholds, lower-level exterior entry and the complete future-access route.
5. Coordinate lower L-06 access/ventilation and the J&J plumbing stack; confirm no damaging service/noise conditions.
6. Reconcile room net, gross, conditioned, above-grade, below-grade, garage and porch areas.

No code-compliance, structural-safety, professional-review or construction-readiness claim is made.
