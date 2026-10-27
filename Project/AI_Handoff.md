# Forever Home — cross-agent handoff

Updated: 2026-10-27
Repository: `softnessasastrength/Forever_home`
Working branch: `design/vr-tech-bom-roadmap`
Default branch: `main` (protected by **owner approval requirement** for merges)

## Purpose
Design a cozy, traditional New England home faithful within reason to the original shared vision. The project is personally meaningful; preserve warmth, character, comfort and intent while rigorously addressing engineering, safety, accessibility and buildability. A complete digital twin is a legitimate final product even if construction never occurs.

## Current status
RevitPilot evidence hardening is verified in Revit 2027: native API audit, Geometry QA and IFC exports use SHA256 of the exact saved RVT bytes, refuse unsaved documents and verify the RVT remains unchanged while collecting evidence. The offline packet and IFC validator enforce this fingerprint rather than trusting timestamps. Fresh run `20261027T134407752Z` and its audit, QA and IFC export share SHA256 `9292968088c9fe29c628a94991628e778fd6910c72350721283cc093f1b4ea1c`; independent IFC2X3 validation passes with ten coordination findings retained. The add-in build and all 22 offline regression tests pass. Older pre-fingerprint reports remain historical. See the Saved-model evidence identity section in `PLAN.md` and `PROGRESS.md`.

The owner selected schematic direction D on 2026-10-27. Its reproducible room-block iteration is documented in [Selected Design Iteration D](../Architecture/Selected_Design_Iteration_2026-10-27/README.md); the current owner-selected layout passes 40 geometry/provenance checks and retains a generated room-program area comparison plus proposed connected stair/landing blocks and upper-floor connector. Main living, kitchen and dining block areas exceed preliminary room-program ranges and remain explicit design tradeoffs. Latest Revit 2027.3 run `.local/revit-pilot/selected-d/20261027T164221478Z/` regenerated 21 D rooms/circulation blocks and IFC2X3 from source SHA256 `00792b81ef66b9d23c69c17e49ba5528340014a4fd2540d4bba8410df5a207f6`; all 23 exact-source, saved-RVT, export, level, space-area/level and IFC-schema checks pass with zero schema issues. Matching read-only audit `.local/revit-pilot/audits/20261027T164310404Z/` confirms 3 levels, 21 rooms, 0 walls/openings and 0 warnings. A separate, unapproved main-floor adjacency candidate preserves the five room areas and passes 46 schematic checks, but blocks 79.33 sf of the owner-selected pantry-side M-06 search window B; it has not been exported to Revit/IFC or adopted. Review both packages before placing an unassigned bath. The Revit plan-frame offsets are derived from comparison stair/wing relationships; rear-edge alignment remains a comparison assumption. This is still a native space study, not coordinated walls, floors, stairs, lift or roof. A pyRevit/Python.NET assessment recommends retaining the PowerShell/C# geometry pipeline; pyRevit agent-runtime Revit 2027 maturity and model-data handling need review before enablement. No permit set, finished VR walkthrough, engineering, or code compliance should be assumed to exist.

Revit automation milestone: a separate compatibility fixture has now executed in Revit 2027, with IFC2x3/DWG/PDF/CSV exports, independent IFC inspection, PDF visual review and native source/backup reopening. This is **not a house model**. Revit 2018 import remains pending on the owner's other computer. See [pilot verification](Revit_Pilot_Verification_2026-10-25.md); CO-013 remains open.

API tooling milestone: RevitPilot includes read-only **Audit active document** and **Run geometry QA** commands, plus an offline review-packet compiler. The latest Revit 2027 audit at `.local/revit-pilot/audits/20261026T232201806Z/` confirms the compact-core study has 3 levels, 3 Floors, 17 enclosed rooms, 78 walls, 5 openings and 0 warnings. Floor-aware Geometry QA was subsequently host-verified at `.local/revit-pilot/geometry-qa/20261027T004729569Z/`: 17 rooms, 78 walls, 2 stairs, 5 doors, 3 floors, 0 warnings, 0 heuristic issues and 0 errors. The compiled packet at `.local/revit-pilot/review-packets/20261027T004753549365Z/` passes all four recorded checks. See [API tooling roadmap](Revit_API_Tooling_Roadmap_2026-10-26.md).

The manifest-driven export command is implemented and host-verified at `.local/revit-pilot/exports/20261027T011547441Z/`. IFC2x3, three plan DWGs, combined PDF and a direct Room inventory CSV all reported success; the CSV contains 17 unique room rows with nonblank areas. Independent IfcOpenShell inspection found zero IFC validation issues, 17 IfcSpaces across three C levels, and geometry decoded for 120 of 121 represented products; one model-line IfcAnnotation failed geometry decoding. The DWGs have nonempty files and AutoCAD 2010 headers, but no independent binary DWG viewer was available. The PDF has a valid header; visual page review remains open because local rendering was unavailable. Revit 2018 import also remains open. The earlier attempt to export the empty native room schedule is retained as a documented failure. A live read-only Geometry QA rerun at `.local/revit-pilot/geometry-qa/20261027T020317046Z/` reconfirmed the three-level inventory and 0 heuristic issues; it does not close the upper-stair, floor-solid, headroom or accessibility review. See the [API tooling roadmap](Revit_API_Tooling_Roadmap_2026-10-26.md) and [RevitPilot instructions](../Tools/RevitPilot/README.md).

The first bounded native-house test also executed: [compact-core study verification](Revit_Compact_Core_Study_2026-10-26.md). It is a separate RVT with C levels, a 40 x 40 ft shell/core reservation and two native stair objects. A shell/core wall-overlap warning was accepted for study purposes; no headroom, lift-product, room, accessibility or export verification is claimed.

The 2026-10-27 source increment makes `Tools/RevitPilot/compact-study-config.json` the runtime source for Compact-Core levels, room boundaries/seeds, shell/lift walls, nominal doors, stairs, floor loops and illustrative overlays. Schema v3 additionally records the legacy nominal door-family dimensions (3 x 0.15 x 7 ft, explicitly not a selected clear opening) and rear-shell skipped edge `[0]`; both values moved unchanged from `Pilot.cs`. Fresh v3 study `.local/revit-pilot/compact-core/20261027T041201025Z/` was generated in Revit 2027 with a retained config SHA matching the checked-in source. Its audit `.local/revit-pilot/audits/20261027T041319416Z/` and Geometry QA `.local/revit-pilot/geometry-qa/20261027T041352458Z/` report 3 levels, 17 rooms, 78 walls, 2 stairs, 5 doors, 3 floors and no native warnings or QA issues. Matching IFC2X3 export `.local/revit-pilot/exports/20261027T041437145Z/` passed independent parsing, schema, inventory, area/CSV, floor and physical-geometry checks with 0 schema issues. Review packet `.local/revit-pilot/review-packets/20261027T041608910684Z/` marks the study, audit, QA and export current and carries 10 open coordination findings. The v2 study at `.local/revit-pilot/compact-core/20261027T025740849Z/` remains preserved as historical evidence. Do not claim design freeze, structural safety, code approval or construction readiness; see `PROGRESS.md` for remaining reviews.

Schematic milestone: [two measured room-block/volume proposals](../Architecture/Schematic_Study_2026-10-25/README.md), eleven SVG drawings and 37 limited geometric checks now exist. At the time of that package neither alternative was selected. The owner subsequently selected direction D, but no native Revit house model, full accessibility route or stair/headroom solution is verified. The first envelopes expose a large area allowance (3,744 / 3,984 sf base shell plates before measurement reconciliation), so the [compact-core Revit brief](Revit_Compact_Core_Brief_2026-10-25.md) defined a separate C test envelope before direction D was selected. C remains a test envelope, not selected house geometry. Direction D is the current schematic path; see its decision record and outstanding coordination checks. For D, the owner selected a main half bath and chose the arrival/hall edge as the first zone to test; exact location, footprint and service route remain TBD. The [main-floor design-gate brief](../Architecture/Direction_D_Main_Floor_Design_Gates_2026-10-27.md) records two derived unassigned search windows without treating them as bathroom geometry. Historical island-range/area/equipment conflicts are flagged in the older documents.

## Current high-level decisions
- **Selected schematic direction D:** lower-level bedroom-capable flex room, B's 40 x 42 ft main-shell test, future 8 x 8 ft lift reservation (with B's eight-riser arithmetic as a comparison only), and a main half bath. Arrival/hall is the selected zone; pantry-side search window B is the first fit-study candidate, with exact location/size/service TBD. Lower sleeping and full bathing remain stair-dependent until a suitable lift or site-specific route is proven. See the dated decision record and its open findings before authoring geometry.
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
