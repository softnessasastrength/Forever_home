# Architectural BIM pipeline plan

Updated: 2026-10-27
Status: the reproducible Compact-Core C pipeline remains a verified compatibility fixture. Owner-selected direction D has completed a fresh Revit 2027 room-space generation and IFC2X3 round trip (run `20261027T170840989Z`); 21 room areas/levels, three storeys, exact source/RVT/IFC fingerprints and clean IFC schema pass independent validation. A matching read-only Revit audit is recorded at `20261027T170859197Z`. D remains a room-boundary study, not a coordinated building model. The unapproved main-floor adjacency candidate passes its separate schematic checks; owner selection and M-06 fit remain unresolved.

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
| M6 — Owner-selected schematic direction D | Turn the owner's six selections into a reproducible main/upper/lower room-block design; preserve A/B source studies; document deliberate geometry changes, area schedule, checks and unresolved decisions. | PowerShell generator deterministically derives D from A/B source geometry; room blocks fit the test shells without same-level overlaps; room IDs are joined to the program; all program-area variances are listed; selected half bath has no invented size; comparison stair/landing blocks align in plan; review drawings and open findings are emitted. | Complete as an initial schematic iteration. Current generator passes 40/40 geometry, provenance and M-06 search-window checks; all three plan SVGs parse. The main plan highlights pantry-side window B, the owner's first fit-study candidate, while retaining dining-side A as alternate. B projects onto upper U-06 by 63 sf in the shared frame, a potential stack coordination opportunity only; neither search window is bath geometry. Room-area report flags main living/kitchen/dining above their study ranges; lower L-02 and upper U-06 have no projected overlap. Lower/upper wing-local plate offsets are +10 ft/+6 ft in Y from documented stair relationships. Stair geometry remains a plan comparison only; native wall openings, section, headroom, structure and actual half-bath fit remain open. See `Architecture/Selected_Design_Iteration_2026-10-27/README.md`. |
| M7 — Native Revit space study D | Create a separate D-specific native Revit room-block study and IFC2x3 export from the selected schematic; do not overwrite Compact-Core C or prior evidence. Avoid assigning wall heights, door sizes, floor assemblies or stair solids that have not been selected. | Revit creates the three documented levels and all 21 room/circulation blocks from the exact D `study.json`; actual Revit room areas match the schematic schedule within 0.1 sf; shell/core comparison outlines are marked as 2D placeholders; the separate RVT and IFC2x3 export are saved with exact source SHA; independent IFC parsing/schema/space inventory checks pass; no C artifact is overwritten. | Complete. All prior D runs remain preserved. Latest source-matched run `.local/revit-pilot/selected-d/20261027T170840989Z/` contains a separate RVT (520,192 bytes), IFC2X3 (80,281 bytes), exact `study.json`, 21-room inventory and successful export record. Source SHA256 `669312ea7f0df0c22909364ff79bf4a5bcef2bb576c0777609158fcfa38c4145`; RVT SHA256 `65860e24ba97f3ead1b6d9c2c5ee3ec5456139c05b29aa9acb8141a2d5b9c048`; IFC SHA256 `cacdc2ddcaa35155de0e040d1b1401f6cd01830a81cfb2631fab312e0dbd4f78`. Independent IFC2X3 validation passes all 23 checks: exact 3 storeys (-5/0/+5 ft), 21 unique spaces/IDs/areas/levels, matching fingerprints, successful export and 0 schema issues. Read-only Revit audit `.local/revit-pilot/audits/20261027T170859197Z/` matches the exact RVT fingerprint and confirms 3 levels, 21 enclosed rooms, 0 walls/openings and 0 Revit warnings. The prior 28-test RevitPilot suite and isolated C# build remain as recorded above; no C artifact was overwritten. |
| M8 — Coordinated building geometry D | Develop the selected D design into native building elements only after their geometry and assembly inputs are documented; preserve the validated room-space study as the comparison base. | Approved project sources support wall dimensions/assemblies, openings, floor edges/assemblies and stair/landing geometry; native Revit audit and valid D-specific geometry checks plus IFC2X3 checks pass for the same source; all variances and safety-critical findings remain visible. | Design input gate prepared in [Direction D main-floor design gates](Architecture/Direction_D_Main_Floor_Design_Gates_2026-10-27.md). Owner selected the M-06 arrival/hall test zone and pantry-side search window B as the first fit-study candidate. No bath footprint, door, fixture clearance or service route is assigned. Two separate **unapproved** alternatives now test the room-placement tradeoff: the connected [adjacency candidate](Architecture/Direction_D_Adjacency_Study_2026-10-27/README.md) preserves room areas and passes 46/46 checks but blocks 79.33 sf of B; the [B-first adjacency candidate](Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/README.md) passes 50/50 checks, keeps B clear, fits source-referenced full-bath vanity/toilet clearance rectangles in its gross envelope, and blocks 35.25 sf of A. The latter moves M-05 to the east exterior wall; entrance orientation, porch connection and exterior approach remain unverified. The fixture-clearance rectangles are not an M-06 room/fixture fit because the bathroom spec excludes powder rooms. The owner-selected D placement remains the validated Revit/IFC baseline. Main-room area variances and M-02 appliance-open fit remain unresolved. No physical building geometry has been added; wall heights, floor assemblies/edge conditions, shared-wall openings and native stair/landing section remain open. |

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

Status: read-only research complete in `Research/Revit_Python_Tooling_2026-10-27.md`. Keep the existing PowerShell/JSON and C# RevitPilot pipeline for this milestone; Python remains appropriate for independent IFC parsing. pyRevit 7.0 is a plausible later host, but its agent runtime's Revit 2027 support is not established by the reviewed official sources. Installation/enablement is not included in M11.

## M12 — Complete a live selected-D Revit and IFC round trip

Acceptance criteria:

- Run the selected-D command against the ignored workspace template, never the Compact-Core C evidence model.
- Validate all 21 positive-area spaces and three levels against `study.json`; retain documented room-area variances.
- Save a separate RVT, export IFC2X3, and pass `validate_selected_d_ifc.py` against that exact run.
- Diagnose Revit room-boundary warnings and leave physical walls, floors, stairs, lift, and safety-critical review items explicitly unresolved.

Status: complete. Live endpoint diagnostics found and repaired vertical-edge omission and Revit boundary-tolerance issues; an earlier IFC attempt established that `Document.Export` must run inside an open transaction. Fresh Revit 2027.3 run `20261027T154924018Z` exercised the corrected generator and rolled-back IFC2X3 export. `.local/revit-pilot/selected-d/20261027T154924018Z/ifc-validation.json` passes all 23 checks; IFC2X3 schema issue count is 0, all 21 expected spaces have source-matched areas/levels, and exactly three expected storeys are present. The extra `Level 1` was removed by reusing the template datum at 0 ft; protected-level deletion is not attempted. Offline tests: 28 passed. All earlier failed runs remain preserved.
