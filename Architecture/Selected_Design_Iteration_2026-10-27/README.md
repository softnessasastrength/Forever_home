# Selected architectural direction D — schematic iteration

Updated: 2026-10-27
Status: **owner-selected direction; schematic room blocks only**. This is the first design iteration embodying the owner's choices. It is not a coordinated floor plan, native Revit house model, permit document, or approval of dimensions and construction systems.

## Direction confirmed by owner

| Choice | Selected direction | Design consequence |
|---|---|---|
| Daily sleeping arrangement | A strategy: bedroom-capable L-02 remains on the lower level | Preserves the main floor's social rooms; step-free access to lower sleeping/bath remains unresolved. |
| Main shell | B test envelope: 40 x 42 ft | The tested main plate is 1,680 sf before walls, stair/lift voids and area-convention reconciliation. This is not approved gross or conditioned area. |
| Vertical circulation | Keep the future-lift reservation and use B's eight-riser arithmetic as a comparison baseline | 7.5 in nominal riser, 11 in tread and 15 in floor-assembly arithmetic placeholder are study values; final stair count, landing, openings, headroom, guards, structure and lift product remain open. |
| Main public bathroom | M-06 is a half bath | Footprint and position are **TBD**; it is intentionally omitted from geometry and area totals. |
| Upper suite | Retain the proposed private primary bath, private connector, independent guest hall access, and hybrid/guest Jack-and-Jill | Door swings, privacy boundary, furniture and bedroom qualification remain to be reviewed. |
| Kitchen | Perimeter induction, sink and dishwasher; appliance-free 8 x 4 ft island; approximately 6 ft quartz + 2 ft butcher block | The inherited 17 ft 4 in x 16 ft kitchen test block has arithmetic fit checks, but is not an approved room size or appliance-open layout. |

## Drawings and reproducibility

- [Main floor room-block plan](main-plan.svg)
- [Upper floor room-block plan](upper-plan.svg)
- [Lower floor room-block plan](lower-plan.svg)
- [Machine-readable study](study.json)
- [Room-block area schedule](room-area.csv)
- [Geometry checks and open findings](checks.json)

Regenerate the package from the unchanged A/B study source with Windows PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1
```

The generator derives its initial room blocks from A/B and the existing kitchen test. `study.json` records SHA256 fingerprints of the source study, source checks, room program, kitchen decision and selected direction decision. It preserves the old studies and writes only this iteration package. Re-running it overwrites this iteration's derived files; do not edit generated files by hand.

## Plan organization

The main plan uses the B test arrangement for living, kitchen, dining, pantry and entry/hall. The SVG shows the 8 x 4 ft appliance-free island at the location from the documented kitchen fit test; perimeter appliance locations still need development. L-02 is removed from the main level and retained in the lower plan using the existing A 11 x 10 ft study block. M-06 is removed from the former full-bath block; the selected half bath has no invented rectangle. The shell and rear wings use the existing A/B test envelopes.

This choice leaves the lower bedroom and lower full bath dependent on stairs unless a selected lift or site-designed route provides access. The main half bath has no shower and does not solve that accessibility need on its own.

The upper plan keeps the existing primary and hybrid suite relationships. To keep the 11 x 10 ft lower flex block outside the projected Jack-and-Jill bath footprint, the guest room is shortened by six inches to 13 ft 8 in x 8 ft (109.3 sf), still within the room program's 100–120 sf study range. The 10 x 12 ft Jack-and-Jill block moves six inches toward the front. The two nominal door reservations to that bath move with the room. This resolves the plan-block overlap only; plumbing, acoustic, structure and floor assemblies have not been coordinated.

The 8 x 8 ft lower technology-room test block moves to the front/middle service area, outside the upper Jack-and-Jill projection. Its access, ventilation, equipment replacement route and acoustic separation are not demonstrated. Secure storage remains unlocated.

## Measured block schedule

The current placed room-block totals are:

| Level | Placed blocks | Net room blocks | Test shell plate |
|---|---:|---:|---:|
| Main | 5 | 763.0 sf | 1,680 sf |
| Upper | 6 | 759.3 sf | 1,152 sf |
| Lower | 7 | 795.1 sf | 1,152 sf |

Circulation blocks are not included in net room blocks. M-06, secure storage, coat/mudroom fit, stair/lift core geometry and the garage-to-house transition are unplaced. The totals therefore do not imply that the remaining shell area is adequate or well used. Garage (576 sf) and porch (120 sf) remain separate schematic allowances.

## Verification

`checks.json` records 16 passing checks: room-block containment in the test shells; positive dimensions; no same-floor room-block overlaps; no projected overlap of lower L-02 or L-06 with upper U-06; U-04 inside its documented study range; no fabricated half-bath footprint; and the existing kitchen fit-reference checks. All three SVG plans parse as XML.

These checks validate rectangles and arithmetic only. They do not validate doors, continuous routes, furnishings, stair geometry, an accessible path, floor/roof assemblies, structure, MEP, site, code, or construction readiness. The currently validated Revit/IFC artifacts are still the separate Compact-Core C test, not this selected design direction.

## Open design work

1. Connect a stair scheme with a real upper landing and coordinated floor opening; choose the riser count and verify headroom, guards and structure in section.
2. Fit and locate M-06 half bath without assuming an area; resolve drain/service routing.
3. Test M-02 appliances open, perimeter work zones, island seating and routes; revisit its 277.3 sf test block against the room program.
4. Fit coat storage, garage arrival, secure storage, porch thresholds, lower-level exterior entry and the complete future-access route.
5. Coordinate lower L-06 access/ventilation and the J&J plumbing stack; confirm no damaging service/noise conditions.
6. Reconcile room net, gross, conditioned, above-grade, below-grade, garage and porch areas.

No code-compliance, structural-safety, professional-review or construction-readiness claim is made.
