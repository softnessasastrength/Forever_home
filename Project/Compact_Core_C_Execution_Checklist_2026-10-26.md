# Compact-Core C execution checklist

Date: 2026-10-26  
Status: proposed work packet; completion requires observed evidence

## Acceptance criteria

The C study is ready for review only when each item has an evidence reference or is explicitly marked open.

| ID | Check | Evidence required | Status |
|---|---|---|---|
| C-01 | Native Revit source opens and is saved as a distinct study | RVT path, version, backup note | Open |
| C-02 | Levels and shell/core reservations are present | Level names/elevations and plan screenshot | Open |
| C-03 | Stairs are native objects and geometry is recorded | Riser/tread/run/headroom observations | Open |
| C-04 | Future lift route is spatially reserved | Route plan/section with turns and clearances | Open |
| C-05 | Kitchen, dining and living envelopes fit together | Dimensioned plan with island, aisles and seating | Open |
| C-06 | Primary and Jack & Jill bath privacy is workable | Door matrix and furnished clearance check | Open |
| C-07 | Main-bath proposal is identified separately from approved intent | Updated plan plus owner-review note | Open |
| C-08 | Technology area and wet routes are separated | Service-chase/stack diagram | Open |
| C-09 | Furniture, delivery and maintenance routes are tested | Annotated route plan | Open |
| C-10 | Warnings are recorded without being silently dismissed | Warning list and disposition | Open |
| C-11 | Room/door/window schedules export and can be inspected | CSV/PDF or equivalent evidence | Open |
| C-12 | Study limitations and unresolved safety issues are handed back | Verification note and coordination-register updates | Open |

## Execution order

1. Open the Compact-Core study and confirm the file is a separate study, not the authoritative house model.
2. Confirm units, levels, shell, core reservation and floor assemblies.
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
