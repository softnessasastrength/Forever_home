# Compact-Core C execution checklist

Date: 2026-10-26  
Status: proposed work packet; completion requires observed evidence

## Acceptance criteria

The C study is ready for review only when each item has an evidence reference or is explicitly marked open.

| ID | Check | Evidence required | Status |
|---|---|---|---|
| C-01 | Native Revit source opens and is saved as a distinct study | RVT path, version, backup note | Verified for 2027 study; backup/export handoff remains separate |
| C-02 | Levels and shell/core reservations are present | Level names/elevations and plan screenshot | Partially verified; native levels, 40 x 40 ft shell and 8 x 8 ft reservation evidenced |
| C-03 | Stairs are native objects and geometry is recorded | Riser/tread/run/headroom observations | Partially verified; IFC bounds quantify a 5.62 ft plan gap from the main-to-upper stair flight to the upper slab; landing, headroom and finish buildup remain open |
| C-04 | Future lift route is spatially reserved | Route plan/section with turns and clearances | Partially verified; reservation exists, product/route/clearances open |
| C-05 | Kitchen, dining and living envelopes fit together | Dimensioned plan with island, aisles and seating | Partially verified; study markers exist, furnished clearance test open |
| C-06 | Primary and Jack & Jill bath privacy is workable | Door matrix and furnished clearance check | Open |
| C-07 | Main-bath proposal is identified separately from approved intent | Updated plan plus owner-review note | Partially verified; proposal is labelled and remains owner decision |
| C-08 | Technology area and wet routes are separated | Service-chase/stack diagram | Open |
| C-09 | Furniture, delivery and maintenance routes are tested | Annotated route plan | Open |
| C-10 | Warnings are recorded without being silently dismissed | Warning list and disposition | Verified for the latest study run: 0 native Revit warnings; geometric coordination issues remain open |
| C-11 | Room/door/window schedules export and can be inspected | CSV/PDF or equivalent evidence | Open |
| C-12 | Study limitations and unresolved safety issues are handed back | Verification note and coordination-register updates | Partially verified; verification note exists, register updates remain |
| C-13 | Native floor inventory is stable and reported | Floor markers, levels, computed profile areas and type widths in host QA | Verified for inventory at `.local/revit-pilot/geometry-qa/20261027T004729569Z/`; floor solids/openings, assembly, support and stair landing remain open |

## Execution order

1. Open the Compact-Core study and confirm the file is a separate study, not the authoritative house model.
2. Confirm units, levels, shell and core reservation; verify floor inventory and keep floor assembly/support review open.
3. Inspect stairs, headroom and lift reservation in plan and section.
4. Place room boundaries and test the kitchen/dining/living and bath envelopes.
5. Check door swings, privacy boundaries, furniture and service paths.
6. Record warnings and unresolved issues before making any geometry changes.
7. Save a versioned study, generate the available schedules/exports, and visually inspect them.
8. Update the verification note and coordination register only with observed evidence.

## Stop conditions

Stop and record an open issue if:

- a route depends on an unverified lift product or unverified code interpretation;
- a stair lacks a complete section/headroom check;
- a room boundary, wet route or service clearance requires silently deleting approved program intent;
- a warning affects geometry, access, structure, fire/life safety or equipment maintenance;
- an export is generated but not independently inspected; or
- Revit is unavailable and execution would otherwise be claimed without observation.

## Handoff format

- Scope and files touched
- Decisions preserved and new proposals
- Evidence and tests performed
- Assumptions and safety/code concerns
- Outstanding issues and recommended next task
- Commit reference, if committed

