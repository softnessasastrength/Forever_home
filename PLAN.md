# Architectural BIM pipeline plan

Updated: 2026-10-27
Status: the reproducible Compact-Core C pipeline remains a verified compatibility fixture. Owner-selected direction D has completed a fresh Revit 2027 room-space generation and IFC2X3 round trip (run `20261027T170840989Z`); 21 room areas/levels, three storeys, exact source/RVT/IFC fingerprints and clean IFC schema pass independent validation. The isolated M-02 furnishing derivative now also passes the 13-check kitchen/IFC gate at `.local/revit-pilot/exports/20261027T204553821Z/`, matched to read-only Revit audit `.local/revit-pilot/audits/20261027T204528345Z/`. D remains a room-boundary study, not a coordinated building model. The selected half-bath search zone/window remains a gross fit study, not assigned bath geometry.

## Repository safety baseline

- Working branch: `design/vr-tech-bom-roadmap`; default branch: `main`.
- Fresh read-only Git audit before this design change: branch `design/vr-tech-bom-roadmap` at `4366e41`, tracking `origin/design/vr-tech-bom-roadmap` at the same commit; `main` and `origin/main` at `9bec5d3`; no pre-existing worktree changes. Remote is `origin` (`softnessasastrength/Forever_home`). Recent history is `4366e41`, `b330adc`, `054fabb`, `79e74d0`. No missing local commit was indicated by branch tracking. Existing recovery/history evidence remains untouched.
- Earlier in-progress geometry-config edits and validation notes are historical checkpoints. The clean baseline for this design task is the `4366e41` audit above; the current D package and documentation changes are local and must be reviewed before commit.
- The earlier repository audit recorded unreachable blobs/trees but no unreachable commits. Those objects contain stale intermediate file snapshots, including merge-conflict markers; they remain intact and are not needed to recover the current branch.
- No `PLAN.md` or `REQUIREMENTS.md` existed in HEAD or the worktree at audit time. These acceptance documents are now derived from the approved project brief and current proposed C study. No architectural dimensions have been invented.

## Milestones

| Milestone | Work | Acceptance criteria | Status |
|---|---|---|---|
| M0 — Repository safety and baseline | Audit worktree, branches, reflogs, remotes, history, existing outputs and project sources. Preserve any unreachable evidence. | Clean starting worktree; local/remote branch relation recorded; no missing commits identified; requirements cite project sources. | Complete: see this baseline and `PROGRESS.md`. |
| M1 — Reproducible study generation | Run the checked-in Revit 2027 Compact-Core C generator as a separate timestamped study; validate the generated manifest and native inventory against BIM-01 through BIM-05. | Unique RVT and manifest; exact three levels, 17 room IDs, target shells/lift, three floor profiles, native category counts and warnings recorded. Existing studies remain untouched. | Complete for v3 run `20261027T041201025Z`; retained config hash matches source, 3 levels/17 rooms/5 doors/3 floors recorded, and native warnings are empty. Read-only audit and Geometry QA are tied to this study. Earlier runs remain untouched. |
| M2 — Independent IFC validation | Export the generated study as IFC2X3 through the existing manifest command; independently validate schema, validation statements, levels, spaces/IDs, major categories, room areas/CSV, floor markers/areas, and physical-product geometry. | Validator exits 0 only when BIM-02 through BIM-08 checks pass; known annotation exception and area/stair discrepancies are reported separately; report records IFC hash and findings. | Complete for v3 export `20261027T041437145Z`; IFC2X3 parses and validates with 0 schema issues, expected levels/17 spaces/classes/areas and no physical-product geometry decode failures. Ten coordination findings remain open and are carried in the report. |
| M3 — One coherent review packet | Connect export validation to the offline packet and prevent evidence from an earlier study or config revision from appearing current. | Packet names its source run directories, carries IFC findings, compares the retained config hash with the checked-in source, and flags timestamp-stale or unverified audit/QA/IFC evidence. | Complete. Packet `20261027T041608910684Z` links the v3 study, API audit `20261027T041319416Z`, Geometry QA `20261027T041352458Z`, and IFC export `20261027T041437145Z`; all source freshness checks are CURRENT. It carries all ten IFC coordination findings. |
| M4 — Documentation and handoff | Update `PROGRESS.md`, execution instructions and checklists with commands, observed evidence, blockers and limitations. | A second operator can follow the documented commands and distinguish host-only steps from offline steps. | Complete for the v3 run; validation commands, evidence directories, open coordination items and manual checks are recorded in this plan, progress log and RevitPilot instructions. |
| M5 — Configuration-driven geometry | Move documented Compact-Core authoring inputs into `compact-study-config.json`; consume them at runtime, preserve an exact config snapshot, and fingerprint the input in the generated manifest. | Preflight validates levels, room boundary/seed data, shell/lift, nominal door-family geometry, shell topology, door hosts, stair runs, overlays and floor-loop areas; manifest validation matches the snapshot to generated geometry targets; Revit regenerates a new study with matching native audit/QA counts and IFC validation while preserving earlier runs. | Complete for schema v3. The unchanged legacy door-family values and rear-shell skipped edge are config-sourced; the official build, source/snapshot checks, native audit/QA, independent IFC2X3 validation, and current-source review packet all pass. Prior RVT/export runs remain preserved. Ten room-area/stair coordination findings and the manual reviews listed below remain open. |
| M6 — Owner-selected schematic direction D | Turn the owner's six selections into a reproducible main/upper/lower room-block design; preserve A/B source studies; document deliberate geometry changes, area schedule, checks and unresolved decisions. | PowerShell generator deterministically derives D from A/B source geometry; room blocks fit the test shells without same-level overlaps; room IDs are joined to the program; all program-area variances are listed; selected half bath has no invented size; comparison stair/landing blocks align in plan; review drawings and open findings are emitted. | Complete as an initial schematic iteration. Current generator passes **43/43** geometry, provenance and M-06 search-window checks; all three plan SVGs parse. Two isolated repeat generations now produce byte-identical study JSON, check JSON, CSV schedules and plan SVGs under Windows PowerShell 5.1; serialized object ordering is explicit. New explicit upper-stair checks measure 0.000000 ft at the flight/landing, wing/bridge and bridge/shell junctions. This retires the historical C IFC gap as a D plan comparison issue only; native stairs, floor openings/edges, section/headroom, support and structure remain open as CO-021. The main plan highlights pantry-side window B, the owner's first fit-study candidate, while retaining dining-side A as alternate. B projects onto upper U-06 by 63 sf in the shared frame, a potential stack coordination opportunity only; neither search window is bath geometry. Room-area report flags main living/kitchen/dining above their study ranges; lower L-02 and upper U-06 have no projected overlap. Lower/upper wing-local plate offsets are +10 ft/+6 ft in Y from documented stair relationships. Stair geometry remains a plan comparison only; actual half-bath fit remains open. See `Architecture/Selected_Design_Iteration_2026-10-27/README.md`. |
| M7 — Native Revit space study D | Create a separate D-specific native Revit room-block study and IFC2x3 export from the selected schematic; do not overwrite Compact-Core C or prior evidence. Avoid assigning wall heights, door sizes, floor assemblies or stair solids that have not been selected. | Revit creates the three documented levels and all 21 room/circulation blocks from the exact D `study.json`; actual Revit room areas match the schematic schedule within 0.1 sf; shell/core comparison outlines are marked as 2D placeholders; the separate RVT and IFC2x3 export are saved with exact source SHA; independent IFC parsing/schema/space inventory checks pass; no C artifact is overwritten. | Complete for the prior source snapshot, but stale against the newly regenerated current source. Preserved run `.local/revit-pilot/selected-d/20261027T170840989Z/` contains its separate RVT (520,192 bytes), IFC2X3 (80,281 bytes), matching `study.json`, 21-room inventory and successful export record. Snapshot SHA256 `669312ea7f0df0c22909364ff79bf4a5bcef2bb576c0777609158fcfa38c4145`; RVT SHA256 `65860e24ba97f3ead1b6d9c2c5ee3ec5456139c05b29aa9acb8141a2d5b9c048`; IFC SHA256 `cacdc2ddcaa35155de0e040d1b1401f6cd01830a81cfb2631fab312e0dbd4f78`. Exact-snapshot IFC2X3 validation passes 23/23: 3 storeys (-5/0/+5 ft), 21 unique spaces/IDs/areas/levels, matching fingerprints, successful export and 0 schema issues. The current regenerated source SHA256 is `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`; its modeled JSON fields match the preserved snapshot, while two recorded source-document fingerprints have changed. Checking the old export against this current source passes geometry/schema checks but fails both exact-source lineage checks (21/23). Regenerate a separate D RVT/IFC from the current sandbox after its RevitPilot build is loaded; preserve all historical runs and C evidence. No C artifact was overwritten. |
| M8 — Coordinated building geometry D | Develop the selected D design into native building elements only after their geometry and assembly inputs are documented; preserve the validated room-space study as the comparison base. | Approved project sources support wall dimensions/assemblies, openings, floor edges/assemblies and stair/landing geometry; native Revit audit and valid D-specific geometry checks plus IFC2X3 checks pass for the same source; all variances and safety-critical findings remain visible. | **Input gate open; no D building elements authorized yet.** The [design-gate brief](Architecture/Direction_D_Main_Floor_Design_Gates_2026-10-27.md) preserves owner-selected room-block geometry and M-06 search area without treating either as building geometry. Current sources conflict on social-room sizes: DD-012 and the kitchen specification say kitchen 14 x 12 ft / dining 11 x 10 ft, while selected-D carries kitchen 17 ft 4 in x 16 ft / dining 11 ft 4 in x 14 ft; no later owner decision reconciles the variances. The selected 40 x 42 ft plate is explicitly a test envelope, not an approved shell. D's -5/0/+5 ft level datums and eight-riser arrangement are study/comparison values; stairs guidance prefers 5–7 risers and requires actual floor-to-floor/assembly coordination. M-06 is now separately scoped as an owner-selected half bath, but still has no assigned footprint, fixture products, door, specific clearance basis or service route. No approved exterior/interior wall construction assembly, floor edge/build-up, D-specific opening locations/sizes, roof geometry/site orientation, or coordinated stair section was found in the reviewed project sources. The B-first and adjacency alternatives remain unapproved comparisons. M-02's isolated kitchen fit study now passes 13/13 IFC checks but does not resolve these house-level inputs. See the new source-by-source gate record in `PROGRESS.md`; preserve room-space D as comparison base until the owner resolves the room-area strategy and schematic section. |

## M9 — Saved-model evidence identity

Bind native API audit, Geometry QA and IFC export reports to the exact saved RVT by content fingerprint, and make the offline packet and IFC validator enforce that identity.

Acceptance criteria:

- Revit commands refuse unsaved or pathless documents.
- SHA256 and byte length are recorded before collection/export and the same saved RVT is verified unchanged afterward.
- The study manifest fingerprint matches the retained RVT bytes; audit, QA and export fingerprints must match that model before the packet calls evidence current or validates IFC.
- Mismatched fingerprints are stale, absent fingerprints are unverified, and timestamps are diagnostic only.
- Regression coverage includes same model with older evidence timestamp, different model with newer evidence timestamp, missing fingerprint and retained RVT mutation.
- No architectural design inputs change.

Status: complete. Fresh Revit 2027 run `20261027T134407752Z`, audit `20261027T134515539Z`, Geometry QA `20261027T134534012Z`, export `20261027T134558841Z` and packet `20261027T134651811293Z` all carry or verify the exact saved model SHA256 `9292968088c9fe29c628a94991628e778fd6910c72350721283cc093f1b4ea1c`. IFC2X3 validation passes with 0 schema issues and 0 represented physical geometry decode failures; ten coordination findings remain open. The build succeeds with 0 errors; all 22 offline regression tests pass. Older reports remain intact as historical evidence.

## M10 — Reconcile legacy Compact-Core IFC findings with selected direction D

Acceptance criteria:

- Keep every C RVT, IFC and export report intact and label its findings as C-study evidence.
- Regenerate direction D from its documented source and verify the plan-level upper connector, room-block schedule and current room-program variances.
- Do not transfer C room-area discrepancies to D, move D rooms to force preliminary ranges, or call a plan-block connector a native stair solution.
- Keep CO-001 open until a D-specific Revit study and IFC are generated and checked; retain landing, floor-edge, headroom, guard, egress and structural review.

Status: complete for the documented schematic triage and now source-matched by M7. The D generator passes 40/40 checks and all three SVGs parse. Its 4 x 4 ft upper connector reaches the rear-wing edge in plan. Current numeric room-program variances are M-01 living (240 sf vs 180–220), M-02 kitchen (277.33 sf vs 150–185), and M-03 dining (158.67 sf vs 90–120); these inherited test blocks remain pending an explicit design tradeoff. The nine Compact-Core C findings remain historical and are not transferred to D. The current Revit/IFC evidence is recorded under M7.

## Execution sequence

1. Regenerate and inspect selected schematic D with `powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1`; 40/40 checks and SVG parsing currently pass.
2. For M-06, use the owner-selected pantry-side search window B first; do not assign a bath footprint until fixture/clearance and service-path inputs are documented.
3. Continue the main-floor design study with documented kitchen clearances and explicitly test the half-wall position against the 16 ft room depth; do not call the inherited envelope approved.
4. Once an M-06 fixture layout is supported by a documented source, test it in B and preserve dining-side A as fallback; record conflicts before assigning a room block.
5. Re-run native Revit generation, read-only audit and independent IFC2x3 validation after the next geometry-source change; bind all reports to the exact RVT fingerprint.
6. Advance to walls, openings, floor edges/assemblies and native stair geometry only when their dimensions and interfaces are documented; keep professional and safety-critical review items open.

## Stop and hold conditions

- Any expected room ID, level, floor marker, geometry class, export, or physical-product geometry fails validation.
- An undocumented geometry exception appears; document it and diagnose before changing the acceptance baseline.
- A model edit would silently change room intent, a proposed owner decision, site assumptions, or a safety-critical condition.
- Geometry QA passes while a known geometric coordination issue remains open. A successful pipeline run is not a design-review-complete claim.

## Out of scope for this milestone

Selecting assemblies, a lift product, roof, foundation, equipment or structural system; declaring an accessible route or code compliance; changing remote branches; and Revit 2018 import, DWG/PDF visual review, and professional review. Direction D is selected only as the next schematic design path; its geometry is not frozen.
## M11 — Revit Python tooling assessment

Acceptance criteria:

- Compare pyRevit and Python.NET against the repository's Revit 2027/.NET 10 setup.
- Record supported versions, execution model, integration risks, privacy considerations and a recommended role in the geometry pipeline.
- Do not install or register new Revit extensions or MCP servers as part of research alone.

Status: read-only research complete in `Research/Revit_Python_Tooling_2026-10-27.md`, with Autodesk's Revit 2027 threading/transaction guidance, Revit API 26.4 regeneration reference, and family-hosting documentation added 2026-10-28. Keep the existing PowerShell/JSON and C# RevitPilot pipeline for this milestone; Python remains appropriate for independent IFC parsing. pyRevit 7.0 is a plausible later host, but its agent runtime's Revit 2027 support is not established by the reviewed official sources. Installation/enablement is not included in M11.

## M12 — Complete a live selected-D Revit and IFC round trip

Acceptance criteria:

- Run the selected-D command against the ignored workspace template, never the Compact-Core C evidence model.
- Validate all 21 positive-area spaces and three levels against `study.json`; retain documented room-area variances.
- Save a separate RVT, export IFC2X3, and pass `validate_selected_d_ifc.py` against that exact run.
- Diagnose Revit room-boundary warnings and leave physical walls, floors, stairs, lift, and safety-critical review items explicitly unresolved.

Status: complete. Live endpoint diagnostics found and repaired vertical-edge omission and Revit boundary-tolerance issues; an earlier IFC attempt established that `Document.Export` must run inside an open transaction. Fresh Revit 2027.3 run `20261027T154924018Z` exercised the corrected generator and rolled-back IFC2X3 export. `.local/revit-pilot/selected-d/20261027T154924018Z/ifc-validation.json` passes all 23 checks; IFC2X3 schema issue count is 0, all 21 expected spaces have source-matched areas/levels, and exactly three expected storeys are present. The extra `Level 1` was removed by reusing the template datum at 0 ft; protected-level deletion is not attempted. Offline tests: 28 passed. All earlier failed runs remain preserved.

## M13 — M-01 furnishings and hearth family placement

Acceptance criteria:

- Stage only sourced families with recorded provenance, host/category, version, type parameters, reuse status and test evidence; preserve originals and keep trials in ignored derivative models.
- Place a family in the working D model only where its geometry, hosting, room boundary, selected orientation and documented use are compatible. Mark visual placeholders and unresolved product data clearly.
- Verify the saved derivative by Revit API audit and, once a placement candidate is accepted, export/validate IFC without changing the validated room-space baseline.

Status: M-01 placement remains gated. RevitCity Masonry Fireplace 18782 is in the ignored D derivative, but is an open fireplace rather than the owner-selected pellet stove; there is no coordinated hearth wall or orientation. Do not place it as an operating appliance. See `Revit/Family_Intake/RevitCity_Family_Intake.md`.

## M14 — M-02 kitchen island family fit and IFC gate

Acceptance criteria:

- Use selected-D `study.json` and the kitchen specification for island position, 8 x 4 ft footprint, 34.5 in base and 1.25 in top. The owner accepts their 35.75 in sum as nominally 36 in (2026-10-27); do not add an undocumented 0.25 in shim or infer perimeter-cabinet clearances from the room block alone.
- Preserve the source family and validated D baseline; trial placements remain in the ignored furnishing-study derivative.
- Revit audit and IFC export must share the exact saved-RVT SHA256. IFC2X3 schema validation, all 21 space IDs, three levels and non-annotation product geometry must pass.
- IFC must independently validate four 4 x 2 ft base modules plus one 8 x 4 ft, 1.25 in generic countertop placeholder, with a 35.75 in top documented as nominally 36 in. Material split, seam, support and finish remain unassigned; candidate is still a study placeholder, not an approved family or shop drawing.
- Select a checked-in export manifest for the active study without temporarily overwriting the Compact-Core C configuration.

Status: **M-02 geometry and IFC fit gate complete for an isolated study; downloaded family/product approval remains open.** RevitCity 19967's preserved trial fails its fit gate: its 8 x 4 ft surface sits about 1 in east/north of the source origin and exports at z=1.1401–1.1811 ft. RevitCity 21015 conflicts with the appliance-free concept (fixed 1000 mm width, integrated cooktop/oven and stools). The RevitCity 7216 modules fit the source-derived 8 x 4 ft plan, and the current Revit derivative contains four 4 x 2 ft casework modules plus a generic unassigned-finish 8 x 4 ft top. The host command report records a 34.5 in physical casework body and 1.25 in top (35.75 in actual, nominally 36 in). Revit audit `20261027T204528345Z` and IFC export `20261027T204553821Z` share saved-RVT SHA256 `01a38eb274b5170d75834d0fce29e2da31e0e45f764d9ed2fac71670a4f0ef1f`; independent validation passes 13/13 checks, including IFC2X3 schema, 21 spaces/three storeys, physical geometry, module bounds, top bounds and overall assembly. The exact tested DLL build and command report are recorded in `PROGRESS.md`. Finish split, seam, supports, overhang, finish and fabrication remain unresolved; 42 in circulation cannot be claimed until perimeter counters and obstacles are modeled. The family and placeholder remain study geometry, not an approved product or shop drawing. No structural, code-compliance or construction-readiness claim is made.

Fresh host verification on 2026-10-28 independently reran the patched build against a separate copy of the preserved pre-countertop backup; it did not alter the earlier fit-test model or owner-selected D baseline. Revit 2027.3 loaded build `build-m02-solid-bounds-v2` with SHA-256 `081437DFBBB125115C2F9D15E960D83D26A9B2DAF78C240A370C0BD30BF6DAE2`. The new countertop report, read-only audit and IFC export are `20261028T002706119Z`, `20261028T003043114Z` and `20261028T003116629Z`; the audit/export match RVT SHA-256 `9a196455548286ecffcfa0f851c425654efc4c316c9b40e2f9dd5b5bb7cd1bd1`. IFC SHA-256 `d2ccbad29003b0fcd77f0d6fcb8d22c47c9e63a565066074b9364217ae3b3c56` passes the documented validator **13/13** with zero schema issues, 21 spaces/three storeys, four measured cabinet modules, one separate 1.25 in top, and no non-annotation geometry decode failures. The six known model-line annotation decode exceptions remain separately reported. The repeat command against the already-tagged original test copy refused a duplicate, as intended.

## M15 — Compare selected-D and older kitchen/dining targets

Acceptance criteria:

- Read room dimensions only from the selected-D study and older dimensions/clearances only from the cited room-program, decision and kitchen/dining sources; record input fingerprints.
- Generate separate, explicitly unselected schematic plan studies for both documented room-size schemes without editing owner-selected D geometry or adding house construction elements.
- Check the 8 × 4 ft island, minimum and preferred documented kitchen-clearance chains, half-wall/opening edge arithmetic, dining table/chair envelopes, and status of the independent porch route.
- Run script checks and parse every generated SVG; document evidence, no-claims and the decision that remains open.

Status: complete as an arithmetic and room-envelope comparison. `Tools/compare_direction_d_social_room_sizes.ps1` generates two schematic study SVGs plus a fingerprinted comparison report; **8/8** checks pass. The older kitchen's 12 ft axis is 18 in short of the minimum 13 ft 6 in chain, while its 14 ft axis leaves 6 in; the preferred 14 ft 6 in chain does not fit either axis. The older dining envelope fits the documented minimum 9 × 11 ft table/chair rectangle but not the preferred 10 × 12 ft rectangle. Its 14 ft kitchen edge meets the 8 ft half-wall + 6 ft opening arithmetic exactly; no living adjacency is shown. Neither study validates the independent 36 in dining-to-porch route. See `Architecture/Room_Size_Comparison_2026-10-27/README.md`. No option has been adopted; an owner decision remains the gate before resizing selected D or developing walls/floors.

## M16 — Social-room furnishing and porch-route fit screen

Acceptance criteria:

- Start from the separate B-first adjacency candidate, keep owner-selected D and M-06 window B unchanged, and record exact source fingerprints.
- Place only source-derived schematic furniture and the selected-D island coordinates; evaluate the 36 in route to a 5 ft nominal porch-door reservation in two dining arrangements.
- Check route rectangle clearance against table/chair proxies, island aisles, shared-edge/half-wall arithmetic, porch block adjacency and test-outline extents.
- Record trade-offs, unresolved product/site conditions and validation commands; do not export an unapproved 2D alternative as IFC.

Status: **complete as a schematic fit comparison; no layout adopted.** The PowerShell generator passes 14/14 checks and emits three XML-valid plan SVGs. Both route variants clear the modeled chair/table rectangles. The dining option with centered doors needs three 18 in chairs along one 60 in table edge (54 in aggregate, before spacing); the more evenly seated alternative moves the nominal 5 ft door pair 18 in east of dining centerline. The 12 × 10 ft porch block fits inside the 40 × 42 ft numeric outline with only 4 in to its edge, which is not a construction-wall allowance. The inherited east-side entry remains unresolved. Door clear width, swing, accessibility, site, walls/floors and structural coordination are not verified. See `Architecture/Direction_D_Social_Route_Study_2026-10-27/README.md`.

## M17 — Compare porch orientation against the main-shell test outline

Acceptance criteria:

- Preserve the documented 12 × 10 ft porch area and test both orientations against the dining edge without changing the room-block baseline.
- Report exact extents relative to the 40 × 42 ft shell test outline, center the nominal door reservation for this isolated comparison, and identify clearance/site/envelope limitations.
- Generate a reproducible comparison drawing and machine-readable result; keep both options unselected.

Status: complete as an envelope comparison. The 12 ft dining-edge orientation leaves 4 in to the test outline; rotating to a 10 ft dining edge preserves 120 sf, centers the porch on dining and projects 20 in past the test outline. This makes the porch projection visible rather than silently counting four inches as exterior construction space. No foundation, roof, wall thickness, site orientation or exterior assembly is modeled or approved. See `porch-orientation-options.svg` and `study.json` in `Architecture/Direction_D_Social_Route_Study_2026-10-27/`.

## M18 — Compare balanced dining seating with an 18-in door offset

Acceptance criteria:

- Compare centered and east-offset nominal 5 ft porch doors using the same four-chair arrangement and the inherited B-first schematic inputs.
- Measure the 36 in route corridor against chair proxy rectangles using orthogonal route centerlines, so corridor width is included without over-counting square bounding-box corners.
- Check that the offset keeps its nominal door and route inside the dining block, improves measured chair-proxy clearance, and reports the nominal east return.
- Regenerate the evidence twice, compare stable outputs, parse all three SVGs, and preserve selected-D/Revit/IFC source artifacts.
- Document the trade-off and explicitly retain unverified clear leaf width, door swing, code/accessibility and construction coordination.

Status: **complete as an unapproved schematic comparison; no layout adopted.** The corrected generator passes 16/16 checks and reports 10 in minimum route-to-chair-proxy clearance for the centered opening versus 15 in at an 18 in east offset. The nominal east return is 20 in. These are geometric proxy measurements, not prescribed clearances or product verification. Reproducibility evidence and limitations are recorded in `Architecture/Direction_D_Social_Route_Study_2026-10-27/README.md` and the dated progress entry. This does not authorize a Revit/IFC house update.

## Proposed forward-design sequence (M19–M23)

These are **proposals for momentum**, not new owner-approved layout decisions. Keep the owner-selected D room-space/Revit/IFC study as the comparison baseline. Promote geometry only into disposable derivatives until the gates below pass.

### M19 — Integrate the accepted M-02 island assembly into a kitchen fit plan

**Sandbox progress (2026-10-27/28):** the 2D social-route derivative includes a reproducible source-sized perimeter-run fit option; its Windows PowerShell generator passes 22/22 checks. A separate PowerShell stress test now reads that output and compares the placeholder refrigerator slot with two manufacturer-documented, discontinued GE refrigerator envelopes; it passes 16/16 source/arithmetic/non-claim checks. In the current north-run position, both examples reduce the nominal 48 in counter-face aisle to less than the documented 42 in minimum even when closed, and to 28 in / 23.5 in at 90 degrees open. The respective door-open widths also project 4.5 in / 6.25 in beyond the nominal 36 in slot. These are discontinued product comparisons, not current product selections or code findings. Appliance positions/order remain provisional; range/DW operating envelopes and service routes remain unmodeled. Do not promote the candidate to Revit/IFC or select it as the design until a current refrigerator SKU, location and clearances are coordinated.

Acceptance criteria:

- Retire RevitCity 19967 and 21015 from the active island candidate pool; preserve their source bytes and failed evidence under `Revit/Family_Intake/Rejected/` or the ignored local rejection archive.
- Retain RevitCity 7216 as the base-module source for the current isolated fit assembly. Four 4 × 2 ft bases plus a separate 8 × 4 ft generic top pass the documented fit checks; the actual total is 35.75 in, owner-accepted as nominally 36 in. Do not describe the RFA alone as a completed 36 in island or approved product.
- Add only source-documented perimeter counter/appliance placeholders to a separate schematic or Revit derivative; test documented island aisles, stool occupation, room edges, table and porch route in one plan. Do not change the selected-D room block to conceal its variance against older 14 × 12 ft kitchen guidance.
- Record family source, parameters, measured solid extents, exact saved-RVT identity and IFC result if the derivative is exported.
- Before product-sized Revit placement, test a current selected refrigerator's exact installation dimensions, rear/side clearances, closed depth, door-open depth/width and hinge-side swing against the island aisle and adjacent returns. The 2026-10-28 discontinued reference-model screen is a hold signal, not a substitute for that product choice or a reason to silently move the room blocks.

RevitCity research: [object 7216](https://www.revitcity.com/downloads.php?action=view&object_id=7216) is described as a simple adjustable Revit Architecture 2008 base block with no door/detail geometry. It is useful for blocking and dimension tests, not finish/fabrication documentation. The separate generic top is essential to the passing assembly.

### M20 — Test the owner-selected M-06 half-bath zone B

**Sandbox research progress (2026-10-27–28):** the owner-selected half-bath scope and first toilet candidate are recorded in `Architecture/Bathrooms_Specs.md` §1.1; the two full-bath specifications remain intact. Added [toilet-options research](Research/M06_Toilet_Options_2026-10-27.md) distinguishing conventional residential tank, pressure-assist and true commercial flushometer choices. The owner selected American Standard Champion PRO 610AA001.020 for first investigation. Its current US product page confirms the SKU, 17-in seat height and 12-in rough-in, but links specification/installation sheets for older 211AA models. A secondary retailer associates the exact SKU with 30-1/4 × 19 × 31 in overall dimensions; manufacturer confirmation remains outstanding, so the predecessor envelope is only a labelled proxy. A reproducible PowerShell screen places that proxy body rectangle in the unassigned A/B gross search windows; both B plan orientations fit. The RevitCity 22366 vanity loaded and was measured in disposable Revit runs; read-only Family Editor inspection confirms both the 3-ft and 4-ft labelled types show the same 2 ft 11 111/256 in default counter width, matching the 35.4331-in solid extent. Treat its type labels as unreliable and keep it unapproved/unplaced. An official American Standard Evolution 0467004.020 family was measured in the isolated Revit intake run `20261028T023252013Z`; three types each contain three positive-volume solids with 22 × 34.25 × 17.5052 in family-local XYZ bounds. The official product page calls 22 × 17.5 × 34.25 in nominal overall dimensions, while the Revit family is work-plane-based and its 34.25-in dimension runs along local Y. The source's type/model mapping and “basin only” description versus the advertised top-and-pedestal assembly remain unresolved; the exact model is discontinued. The [sink-candidate comparison](Research/M06_Sink_Candidates_2026-10-28.md) now includes KOHLER Tresham K-2844-4-0 (24 × 19-1/2 × 34-5/8 in, fireclay, Shaker-inspired), plus American Standard Edgemere 0445400.020 (25 × 19-1/2 × 35-5/8 in, classic rectangular fireclay). The Edgemere storefront displays $252.85, while LIXIL Pro marks the combination discontinued at a $389 list price; current availability conflicts, and LIXIL Pro lists no full-combination Revit family. Studio KOHLER exposes the exact Tresham Revit option, but Download routes to sign-in, so no file was obtained or inspected. A PlumbTile listing displayed $638.40 for Tresham on 2026-10-28 against $851.20 list price; prices are transient, no purchase is authorized or made. `Tools/screen_m06_sink_candidates_gross_body.ps1` verifies the three source-dimension body rectangles against B's gross gap in both orientations; this remains containment only. No candidate is selected or room-fitted. A commercial KOHLER Highcliff Ultra comparison lists a 25 psi / 25 gpm supply requirement; it is not being assumed compatible with house services. Exact toilet SKU geometry, selected sink/vanity assembly, M-06-specific clearance basis, door, code location and service route remain unresolved; M-06 remains unassigned.

Acceptance criteria:

- Keep the arrival/hall edge as the owner-selected public zone and test pantry-side search window B first; preserve B as unassigned until its fit is demonstrated.
- Establish a cited half-bath fixture/clearance basis and service-path assumptions before assigning a room footprint. Do not borrow full-bath references as though they define a half bath.
- Inspect queued RevitCity 22366 only as a vanity/counter candidate. Its [listing](https://www.revitcity.com/downloads.php?action=view&object_id=22366) describes parameterized basin/counter/faucet geometry, Revit Architecture 2020, and no casework below. Revit 2027.3 geometry and type values are measured; read-only Family Editor review confirms the 3-ft and 4-ft labels both show a 2 ft 11 111/256 in default counter width, so the label cannot be used as the actual dimension. Keep the family unapproved/unplaced until its formulas/constraints are explained or a better documented vanity is selected. The toilet proxy screen does not establish a room fit or clearance basis.
- Check the entry-to-core approach, door/swing, fixture clearances and potential upper U-06 stack relationship without implying a drain/vent/service route exists.

### M21 — Coordinate the main-floor public route and porch envelope

Acceptance criteria:

- Carry the 36 in plan-route proxy, balanced dining seats and both nominal door positions into one main-floor comparison; keep the M18 10 in/15 in proxy gaps and the 20 in east return labeled as schematic measurements.
- Resolve how the B-first east-side M-05 entry approaches the public hall before assigning exterior orientation.
- Compare the 12 × 10 ft porch orientation's 4 in test-outline reserve with the 10 × 12 ft orientation's 20 in projection beyond the 40 × 42 ft outline. Do not call either result a wall/foundation/site fit.
- Keep walls, door swings, floor transitions and accessible route claims gated on documented assemblies, site and product dimensions.

### M22 — Resolve the M-01 hearth and viewing wall before family placement

Acceptance criteria:

- Locate a pellet-stove-compatible source and manufacturer clearance envelope matching the approved appliance direction; the RevitCity open-fireplace object 18782 is not the stove.
- Define a documented hearth wall/orientation and room relationship before placing either stove or surround in a Revit derivative.
- Test the queued TV visual placeholder only against an owner-approved viewing wall and size; preserve the selected legacy CRT requirement if it remains current.
- Keep all appliance, hearth and egress clearances explicitly unverified until the product, wall assembly and qualified review are available.

### M23 — Develop the exterior gathering area and furnishings

Acceptance criteria:

- Carry forward the owner's **already-selected Adirondack chair model** recorded in `Architecture/Building_Program.md`; retrieve that exact source/asset before modeling and do not substitute a RevitCity result.
- Coordinate chairs with the eventual pool, patio and outdoor-fireplace choices only after site, grade, circulation and fire-feature locations are defined.
- Keep count, spacing, paving, guard/edge conditions and exterior fireplace/pool geometry unassigned until supported by owner/site information.

## RevitCity research and candidate disposition (2026-10-27)

- Retired the dimensionally failed 19967 and unsuitable 21015 island alternatives from the incoming/active candidate pool. Their sources and test evidence remain preserved; the duplicate 19967 download was removed after its SHA256 was confirmed identical to the archived original.
- Kept the 7216 source as the current island base-block candidate, with the separate generic-top assembly as the dimensionally passing study. Source reuse permission remains unreviewed, so no public-model or product approval is implied.
- Reopened the authenticated RevitCity session and reviewed the 7216 island listing plus the queued 22366 vanity listing. No additional family was downloaded. Details and limitations are in `Revit/Family_Intake/RevitCity_Family_Intake.md`.
