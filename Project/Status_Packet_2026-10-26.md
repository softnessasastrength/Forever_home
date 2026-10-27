# Forever Home — current documentation packet

Date: 2026-10-26  
Status: working review packet; no geometry freeze, permit approval, code certification or professional sign-off

## Purpose

This packet is the short path through the current project documentation. It preserves the original home vision, identifies what is currently testable, and keeps the next Revit action bounded and reversible.

## Read in sequence

1. [Vision-preservation charter](Vision_Preservation_Charter.md) — what must survive adaptation.
2. [Coordinated room program](../Requirements/Room_Program.md) — current rooms, relationships and provisional allowances.
3. [Current owner review brief](Current_Owner_Review_Brief_2026-10-26.md) — decisions still required from the owner.
4. [Compact-Core C implementation brief](Revit_Compact_Core_Brief_2026-10-25.md) — bounded native-Revit test target.
5. [Compact-Core C execution checklist](Compact_Core_C_Execution_Checklist_2026-10-26.md) — evidence required before review claims.
6. [Compact-Core study verification](Revit_Compact_Core_Study_2026-10-26.md) — observed Revit evidence and limitations.
7. [Coordination register](Coordination_Register.md) — authoritative open issues and dispositions.

## Current state

- The desired character is established: warm, collected, whimsical traditional New England, with togetherness and privacy.
- The room program is reconciled enough for schematic testing, but dimensions, area totals, level relationships and accessibility remain provisional.
- A and B remain comparison alternatives. C is the next native-Revit test, not a selected plan.
- The latest C study executed in Revit 2027 with 0 errors and 0 recorded Revit warnings; the read-only API audit recorded 17 enclosed rooms, 78 walls, 5 openings and 0 warnings.
- The floor-aware read-only Geometry QA was subsequently host-run on 2026-10-27: 17 rooms, 78 walls, 2 stairs, 5 doors and 3 floors; 0 native warnings, 0 heuristic issues and 0 errors. The updated offline review packet passes all four recorded checks. The floors still use an unselected 1 ft template type.
- The manifest-driven export command completed in Revit 2027.3 at `.local/revit-pilot/exports/20261027T011547441Z/`: IFC2x3, three plan DWGs, combined PDF and direct Room inventory CSV all reported success. The CSV has 17 unique rows and no blank areas. The earlier empty native room-schedule export remains documented. DWG/PDF visual review, IFC semantic review and Revit 2018 import remain open.
- Native levels, the 40 x 40 ft main shell target, an 8 x 8 ft lift reservation, 17 stable room IDs, five nominal door IDs and study markers were evidenced across the verification runs.
- Stairs are native study objects, but riser/tread documentation, headroom, guards, finish buildup and code review are not complete.
- The kitchen island, hearth, television, bath fixtures, lift and furniture markers are spatial studies, not selected products or approved clearances.

## Owner decisions needed

1. Select C for continued development, retain B as the working parent, compare against A, or reopen the alternatives.
2. Accept, revise or reject the proposed main full bath.
3. Choose the preferred future-accessibility strategy and accept that the route remains unverified until modeled in plan and section.
4. Confirm whether the reconciled area allowance is emotionally and financially acceptable.
5. Confirm equipment preferences only after dimensions, loads, service access and replacement routes are documented.

## Blockers before a design-review-complete claim

- Site, grade, jurisdiction and adopted code editions are unknown.
- No continuous accessible route, lift product layout, stair/headroom check or egress review is verified; the generator warning is cleared, but design review is not.
- Structural, MEP, fire/life-safety, equipment-load and service-route coordination remains open.
- Revit 2027-to-2018 import and independent DWG fidelity remain pending.
- Unresolved room/door/service clearances and stair/headroom/egress review remain study limitations.

## Next bounded work

Continue the C review with the unresolved physical geometry: floor profile/opening fit and support, the upper stair landing/headroom, lift-route geometry, wet-stack/technology separation, and furnished kitchen/bath clearances. Record observed results and keep failed targets visible; if C fails a target clearance, return to B/A rather than silently shrinking the program. For RevitPilot, independently inspect the generated IFC/DWG/PDF outputs before extending the exporter.

## Authority and limitations

Approved decisions supersede exploratory research; newer explicit decisions supersede older conflicts. This packet is documentation for design coordination and digital-twin development. It is not an architectural, engineering, accessibility, code, permit or construction approval.
