# Forever Home — cross-agent handoff

Updated: 2026-10-26
Repository: `softnessasastrength/Forever_home`
Working branch: `design/vr-tech-bom-roadmap`
Default branch: `main` (protected by **owner approval requirement** for merges)

## Purpose
Design a cozy, traditional New England home faithful within reason to the original shared vision. The project is personally meaningful; preserve warmth, character, comfort and intent while rigorously addressing engineering, safety, accessibility and buildability. A complete digital twin is a legitimate final product even if construction never occurs.

## Current status
Concepts and research are documented, but no verified coordinated architectural floor plan, built Revit model, permit set, or finished VR walkthrough should be assumed to exist. Treat all untested exports, simulations, engineering and code compliance as pending.

Revit automation milestone: a separate compatibility fixture has now executed in Revit 2027, with IFC2x3/DWG/PDF/CSV exports, independent IFC inspection, PDF visual review and native source/backup reopening. This is **not a house model**. Revit 2018 import remains pending on the owner's other computer. See [pilot verification](Revit_Pilot_Verification_2026-10-25.md); CO-013 remains open.

API tooling milestone: RevitPilot includes read-only **Audit active document** and **Run geometry QA** commands, plus an offline review-packet compiler. The latest Revit 2027 audit at `.local/revit-pilot/audits/20261026T232201806Z/` confirms the compact-core study has 3 levels, 3 Floors, 17 enclosed rooms, 78 walls, 5 openings and 0 warnings. Floor-aware Geometry QA was subsequently host-verified at `.local/revit-pilot/geometry-qa/20261027T004729569Z/`: 17 rooms, 78 walls, 2 stairs, 5 doors, 3 floors, 0 warnings, 0 heuristic issues and 0 errors. The compiled packet at `.local/revit-pilot/review-packets/20261027T004753549365Z/` passes all four recorded checks. See [API tooling roadmap](Revit_API_Tooling_Roadmap_2026-10-26.md).

The manifest-driven export command is implemented and host-verified at `.local/revit-pilot/exports/20261027T011547441Z/`. IFC2x3, three plan DWGs, combined PDF and a direct Room inventory CSV all reported success; the CSV contains 17 unique room rows with nonblank areas. Independent IfcOpenShell inspection found zero IFC validation issues, 17 IfcSpaces across three C levels, and geometry decoded for 120 of 121 represented products; one model-line IfcAnnotation failed geometry decoding. The DWGs have nonempty files and AutoCAD 2010 headers, but no independent binary DWG viewer was available. The PDF has a valid header; visual page review remains open because local rendering was unavailable. Revit 2018 import also remains open. The earlier attempt to export the empty native room schedule is retained as a documented failure. See the [API tooling roadmap](Revit_API_Tooling_Roadmap_2026-10-26.md) and [RevitPilot instructions](../Tools/RevitPilot/README.md).

The first bounded native-house test also executed: [compact-core study verification](Revit_Compact_Core_Study_2026-10-26.md). It is a separate RVT with C levels, a 40 x 40 ft shell/core reservation and two native stair objects. A shell/core wall-overlap warning was accepted for study purposes; no headroom, lift-product, room, accessibility or export verification is claimed.

Schematic milestone: [two measured room-block/volume proposals](../Architecture/Schematic_Study_2026-10-25/README.md), eleven SVG drawings and 37 limited geometric checks now exist. Neither alternative is selected; no native Revit house model, full accessibility route or stair/headroom solution is verified. The first envelopes expose a large area allowance (3,744 / 3,984 sf base shell plates before measurement reconciliation), so the [compact-core Revit brief](Revit_Compact_Core_Brief_2026-10-25.md) defines the next C test before freezing geometry. C retains B's main-level flex sleeping/bathing strategy, moves technology clear of Jack & Jill wet routes, and requires native stair/lift/headroom, privacy and service-route checks. Both A/B add a proposed main full bath; these changes require owner review. Historical island-range/area/equipment conflicts are flagged in the older documents.

## Current high-level decisions
- Modest traditional exterior, comfortable multi-level interior, future accessibility; site and final area TBD.
- Kitchen concept: approximately 8×4 ft island with cream quartz and butcher-block section, sage/olive and warm ivory cabinets, honey oak and aged brass.
- Living room: rustic pellet hearth, large Mitsubishi WS-65815 rear-projection CRT, Kenwood-style component hi-fi; coordinate heat, structure, space and ventilation.
- DIRECTV HR24 legacy satellite preference, provider-neutral coax/conduit, ground-mounted landscaped dish mast.
- Solar target >=50% annual household electricity; essential-load battery backup for prolonged outages; manually started generator with safely listed transfer equipment and theatrical lever aesthetic.
- Cream/ivory wall plates; three-season porch; discreet secure firearms storage closet with properly secured safe and legal/safety review.
- Revit 2027 is the **authoritative** BIM authoring environment. Revit 2018 works but cannot open native 2027 files. Preserve interchange exports and structured specifications.
- Revit 2027 trial activated 2026-10-25; estimated expiry ~2026-11-24, verify Autodesk account. Internal delivery target 2026-11-20. Optional Flex later, only with purchase approval.
- Professional architectural discipline and code review required even for digital-only completion; professional certification and permits are separate.

## Critical next work
1. Write vision-preservation charter identifying original intent, nonnegotiables and allowable adaptations.
2. Finalize room-by-room program, adjacency diagram and coordinated footprint/levels.
3. Design bathrooms, stairs, future lift/accessibility route and kitchen/living room spatial envelopes.
4. Establish disciplined Revit model and early test of IFC2x3/DWG/CSV exports into 2018.
5. Maintain code issue register, MEP reservations, structural assumptions, drawing index and export checklist.
6. Review the IFC model-line annotation exception, inspect DWG/PDF visually in a suitable viewer, and test Revit 2018 import; keep stair/floor/accessibility coordination open.

## Reading order
1. `AGENTS.md` and `Agents/README.md`
2. `Project/Professional_Design_Discipline_And_Digital_Deliverable.md`
3. `Project/Code_Compliance_And_Merge_Gate.md`
4. `Project/Revit_2027_Thirty_Day_Sprint.md`
5. `Decisions/` for approved choices, then `Systems/`, `Research/`, `VR/`, `Budget/` as needed

## Rules for incoming agents
- Inspect current files; don't rely on this summary as the latest word.
- Preserve approved decisions, mark new ideas as proposals and surface conflicts.
- No direct merge to `main`, destructive operations, spending or private-data disclosure.
- No unverified claims of Revit execution, legal compliance, engineering approval or successful export.
- Provide a clear handback: what changed, tests, risks, blockers, and next steps.
