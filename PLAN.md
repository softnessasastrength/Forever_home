# Architectural BIM pipeline plan

Updated: 2026-10-28
Status: the reproducible Compact-Core C pipeline remains a verified compatibility fixture. Owner-selected D's current-source Revit run `.local/revit-pilot/selected-d/20261028T021345099Z/` contains a parseable IFC2X3 with 21 spaces on three storeys and no schema issues. The current named RVT no longer matches the export fingerprint; the exact backup/RVT/IFC pair passes 26/26 in isolated validation, while the original named RVT remains stale. At 05:56 EDT, the selected-D PowerShell generator passed 43/43 in two fresh scratch runs with identical outputs; the M30 adjacency audit reproduced 11/11; family provenance passed; the offline unittest suite passed 37/37; and the preserved matching RVT/IFC pair passed 26/26 twice with identical reports. At 07:53 EDT, a separate owner-follow-up proposal passed 16/16 room-block/topology/fit-contract checks twice deterministically. It applies the 14×12 ft kitchen and 11×10 ft dining targets, adds the owner-directed private upper-suite sequence as an unplaced topology target, sketches a steep gable without invented pitch, and keeps M-06 B unassigned. The kitchen test shows that the 8×4 ft island cannot fit entirely within the 14×12 ft M-02 block with 42 in clearance at both ends of its 8 ft axis; extension into adjacent open dining/living space remains untested. The exact 610AA001.020 manufacturer page still links a 211AA-series dimension sheet, so exact selected-SKU body dimensions and Revit family remain unresolved. Revit host interaction is still blocked by an Autodesk trial WebView intercepting input; no trust choice was made. D remains a room-boundary study, not coordinated building geometry; M-06 B remains unassigned.

## Repository safety baseline

**Current sandbox audit — 2026-10-28 02:56 EDT:** active branch `codex/house-design-sandbox`, HEAD `fc4effe` (`Correct selected D IFC validation evidence`). Local refs show 31 commits ahead and none behind `origin/design/vr-tech-bom-roadmap`, and 25 ahead and none behind `origin/main`; this is a comparison to existing local remote-tracking refs, not a fresh remote fetch. The recent reflog contains the sandbox commits in order and no indication of missing local work. The worktree has in-progress documentation, family-intake and validation edits plus three untracked Incoming RFAs; the three RFAs' SHA256 values match their ignored quarantined copies, including unchanged Evolution. The separate `main` worktree was not touched. No remote operation, history rewrite, reset, prune, or garbage collection was performed. Do not push these local commits without owner approval.

**Continuation audit — 2026-10-28:** active sandbox branch remains `codex/house-design-sandbox`, now at `ec717fd` (`Document IFC revalidation and M-06 family intake`). The reflog shows the two subsequent focused commits in order; existing local remote-tracking refs show 0 behind / 33 ahead of `origin/design/vr-tech-bom-roadmap` and 0 behind / 27 ahead of `origin/main`. No fetch or remote write was performed. The three Incoming RFAs remain the only untracked project files; the Evolution source is still hash-pinned and Revit-locked. This continuation changes only the family-intake gate and evidence documentation. No recovery condition or missing commit is indicated.

**Current continuation verification — 2026-10-28:** `validate_family_intake.py` passes with exact source hashes and manifest dispositions for both queued Champion bowl and measured Evolution research family; all 36 RevitPilot offline tests pass. Two fresh selected-D PowerShell generations each pass 43/43 checks and emit seven byte-identical artifacts (`.local/revalidation/evolution-provenance-ec717fd/`). The retained IFC2X3 passes 25/25 only in the isolated copy paired with its exact manifest-matching `.0001.rvt`; the original named RVT remains mismatched. Revit host interaction remains blocked by the separate trial webview, so the corrected fixture/family host probe is still outstanding.

**Current continuation verification — 2026-10-28 03:35 EDT:** re-audited sandbox branch `codex/house-design-sandbox` at `34193f3`; the reflog retains the recent commits in order, locally recorded refs show 0 behind / 38 ahead of `origin/design/vr-tech-bom-roadmap` and 0 behind / 32 ahead of `origin/main`, and no remote fetch or write was made. The three pre-existing untracked Champion/Evolution Incoming RFAs remain unmodified; Evolution still hashes to `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`. The repository-documented unittest command passes 36/36. The public-family intake validator passes for two Incoming manufacturer families and three quarantined public M-06 sink families. Two fresh selected-D PowerShell generations pass 43/43, parse all SVGs, and produce seven byte-identical outputs. The exact-manifest-matching `.0001.rvt`/IFC pair passes 25/25 in an isolated revalidation copy; the 18-check sink screen still tests single source-dimension bodies against gross B only. Autodesk's current face-placement API documentation supports the probe's `WorkPlaneBased` requirement and nonparallel reference direction; its IFC API guide documents `Document.Export` options and custom exporter registration. Revit's unsigned-add-in prompt identifies the exact manifest-matching v2 DLL, but the trial welcome WebView consumes both accessibility and screenshot-coordinate input. No trust selection, manifest change, or model change was made. Host inspection remains the active M20 blocker; B and the selected-D baseline remain unchanged.

**Fresh validation follow-up — 2026-10-28 03:40 EDT:** on current HEAD `01b5e56`, locally recorded refs still show 0 behind / 39 ahead of `origin/design/vr-tech-bom-roadmap` and 0 behind / 33 ahead of `origin/main`; this does not include a fresh remote fetch. A new isolated copy of the selected-D export with its exact manifest-matching `.0001.rvt` passes **25/25** at `.local/revalidation/goal-audit-20261028-0340/ifc-exact-backup/fresh-validation.json`. The unchanged original run was independently checked to preserve all 24 other passes and fail only `saved_rvt_fingerprint_matches` at `.local/revalidation/goal-audit-20261028-0340/current-named-rvt.json`. The repository's unittest suite passes 36/36; current selected-D generator reruns pass 43/43 twice with seven identical artifacts; family provenance passes; the M-06 report contract confirms six individually screened research candidates and `unassigned; no room footprint or position`. None of these checks adds physical house geometry or cures the source RVT/IFC lineage mismatch. Revit remains blocked by the trial WebView; its state and the protected family hashes were freshly rechecked.

- Repository project branch of record: `design/vr-tech-bom-roadmap`; default branch: `main`. This overnight work is isolated on `codex/house-design-sandbox`.
- Historical fresh read-only Git audit before the earlier design change: branch `design/vr-tech-bom-roadmap` at `4366e41`, tracking `origin/design/vr-tech-bom-roadmap` at the same commit; `main` and `origin/main` at `9bec5d3`; no pre-existing worktree changes. Remote is `origin` (`softnessasastrength/Forever_home`). Recent history at that time is `4366e41`, `b330adc`, `054fabb`, `79e74d0`. No missing local commit was indicated by branch tracking. Existing recovery/history evidence remains untouched.
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
| M7 — Native Revit space study D | Create a separate D-specific native Revit room-block study and IFC2X3 export from the selected schematic; do not overwrite Compact-Core C or prior evidence. Avoid assigning wall heights, door sizes, floor assemblies or stair solids that have not been selected. | Revit creates the three documented levels and all 21 room/circulation blocks from the exact D `study.json`; actual Revit room areas match the schematic schedule within 0.1 sf; shell/core comparison outlines are marked as 2D placeholders; the separate RVT and IFC2X3 export are saved with exact source SHA; independent IFC parsing/schema/space inventory checks pass; no C artifact is overwritten. | Current-source Revit 2027.3 export exists at `.local/revit-pilot/selected-d/20261028T021345099Z/`; it contains the current `study.json` fingerprint `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`, 21 spaces on 3 storeys (-5/0/+5 ft), IFC2X3 and a clean schema. The named RVT has since changed from manifest SHA256 `7a03f704329e840c938361d06c31329823e3d939c993bbc4e11de67e991af7ff` to `7427ffa0eeeb5a2a5a4d46bf3d6876c8f906d3c723a74e2bfac2af644d610299`; current exact-lineage validation fails only this fingerprint (24/25 checks pass). Preserved `.0001.rvt` matches the manifest; the enhanced isolated scratch validation passes 25/25, including all 21 space footprints and rectangular body-profile areas. Thus the IFC is fully validated against the byte-matching backup only, not the current named RVT. Preserve both; rerun a separate Revit export when the host workflow is available. No physical walls, floors, stairs or other construction geometry are present; no C artifact was overwritten. |
| M8 — Coordinated building geometry D | Develop the selected D design into native building elements only after their geometry and assembly inputs are documented; preserve the validated room-space study as the comparison base. | Approved project sources support wall dimensions/assemblies, openings, floor edges/assemblies and stair/landing geometry; native Revit audit and valid D-specific geometry checks plus IFC2X3 checks pass for the same source; all variances and safety-critical findings remain visible. | **Input gate open; no D building elements authorized yet.** The [design-gate brief](Architecture/Direction_D_Main_Floor_Design_Gates_2026-10-27.md) preserves owner-selected room-block geometry and M-06 search area without treating either as building geometry. Current sources conflict on social-room sizes: DD-012 and the kitchen specification say kitchen 14 x 12 ft / dining 11 x 10 ft, while selected-D carries kitchen 17 ft 4 in x 16 ft / dining 11 ft 4 in x 14 ft; no later owner decision reconciles the variances. The selected 40 x 42 ft plate is explicitly a test envelope, not an approved shell. D's -5/0/+5 ft level datums and eight-riser arrangement are study/comparison values; stairs guidance prefers 5–7 risers and requires actual floor-to-floor/assembly coordination. M-06 is now separately scoped as an owner-selected half bath, but still has no assigned footprint, fixture products, door, specific clearance basis or service route. No approved exterior/interior wall construction assembly, floor edge/build-up, D-specific opening locations/sizes, roof geometry/site orientation, or coordinated stair section was found in the reviewed project sources. The B-first and adjacency alternatives remain unapproved comparisons. M-02's isolated kitchen fit study now passes 13/13 IFC checks but does not resolve these house-level inputs. See the new source-by-source gate record in `PROGRESS.md`; preserve room-space D as comparison base until the owner resolves the room-area strategy and schematic section. |

### M7 validation strengthening — IFC space footprints and exporter identity

The selected-D IFC validator decodes each `IfcSpace` body and compares its world-coordinate XY bounds to the source room rectangle after documented plan-frame offsets (0.02 ft numerical export tolerance). It also requires a single rectangular swept-solid Body profile whose area matches source within 0.1 sf, independently of IFC quantity properties. It records IFC header provenance. On a disposable copy of host run `20261028T021345099Z`, replacing only the copied named RVT with exact manifest-matching `.0001.rvt`, the validator passes **25/25** checks, including all 21 room footprints and profile areas; report `.local/revalidation/ifc-body-profile-20261028T025642/exact-backup-rvt/validation.json`. A paired copy retaining the current named RVT passes 24/25 and fails only saved-model fingerprint identity. The original run files remain unchanged; do not label the current named RVT as matching the export. Two fresh PowerShell schematic generations pass 43/43 and produce seven byte-identical files in `.local/revalidation/geometry-regression-20261028T025651/`. See [Revit IFC exporter research](Research/Revit_IFC_2027_Exporter_Notes_2026-10-28.md). Historical reports remain under `.local/revalidation/`.

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

1. Regenerate and inspect selected schematic D with `powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1`; 43/43 checks and SVG parsing currently pass, with two repeat runs byte-identical across all seven artifacts.
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

**Sandbox research progress (2026-10-27–28):** the owner-selected half-bath scope and first toilet candidate are recorded in `Architecture/Bathrooms_Specs.md` §1.1; the two full-bath specifications remain intact. Added [toilet-options research](Research/M06_Toilet_Options_2026-10-27.md) distinguishing conventional residential tank, pressure-assist and true commercial flushometer choices. The owner selected American Standard Champion PRO 610AA001.020 for first investigation. Its current US product page confirms the SKU, 17-in seat height and 12-in rough-in, but links specification/installation sheets for older 211AA models. A secondary retailer associates the exact SKU with 30-1/4 × 19 × 31 in overall dimensions; manufacturer confirmation remains outstanding, so the predecessor envelope is only a labelled proxy. A reproducible PowerShell screen places that proxy body rectangle in the unassigned A/B gross search windows; both B plan orientations fit. The RevitCity 22366 vanity loaded and was measured in disposable Revit runs; read-only Family Editor inspection confirms both the 3-ft and 4-ft labelled types show the same 2 ft 11 111/256 in default counter width, matching the 35.4331-in solid extent. Treat its type labels as unreliable and keep it unapproved/unplaced. An official American Standard Evolution 0467004.020 family was measured in the isolated Revit intake run `20261028T023252013Z`; three types each contain three positive-volume solids with 22 × 34.25 × 17.5052 in family-local XYZ bounds. The official product page calls 22 × 17.5 × 34.25 in nominal overall dimensions, while the Revit family is work-plane-based and its 34.25-in dimension runs along local Y. The source's type/model mapping and “basin only” description versus the advertised top-and-pedestal assembly remain unresolved; the exact model is discontinued. The [sink-candidate comparison](Research/M06_Sink_Candidates_2026-10-28.md) now includes KOHLER Tresham K-2844-4-0 (24 × 19-1/2 × 34-5/8 in, fireclay, Shaker-inspired), plus American Standard Edgemere 0445400.020 (25 × 19-1/2 × 35-5/8 in, classic rectangular fireclay). The Edgemere storefront displays $252.85, while LIXIL Pro marks the combination discontinued at a $389 list price; current availability conflicts, and LIXIL Pro lists no full-combination Revit family. Studio KOHLER exposes the exact Tresham Revit option, but Download routes to sign-in, so no file was obtained or inspected. A PlumbTile listing displayed $638.40 for Tresham on 2026-10-28 against $851.20 list price; prices are transient, no purchase is authorized or made. `Tools/screen_m06_sink_candidates_gross_body.ps1` screens eight source-dimension body rectangles individually against B's gross gap; this remains containment only. No candidate is selected or room-fitted. A commercial KOHLER Highcliff Ultra comparison lists a 25 psi / 25 gpm supply requirement; it is not being assumed compatible with house services. Exact toilet SKU geometry, selected sink/vanity assembly, M-06-specific clearance basis, door, code location and service route remain unresolved; M-06 remains unassigned.

**Public toilet-model source check (2026-10-28):** Studio KOHLER's public [K-96057-SS-0 listing](https://www.studiokohler.com/products/commercial/commercial-toilets/96057-ss) advertises 3D RFA and BIM/Revit design files, but the page provides no direct file URL in its public rendered content. This antimicrobial SKU is not the standard K-96057-0. Its listed 14-7/8 × 26-3/8 in dimensions also differ from the current standard-product sheet's 14-5/8 × 26-1/8 in, while the page body contains an additional 16-7/8 vs 16-5/8 in rim-height conflict. No file was downloaded, sign-in attempted, or product geometry accepted. Keep the fixture unselected and M-06 unassigned; see the source-by-source note in `Research/M06_Toilet_Options_2026-10-27.md`.

**Broad Champion PRO RFA index recheck (2026-10-28):** public RevitCity and Archade results contain generic “Standard Toilet” families (RevitCity's result says Revit Architecture 2011; Archade leaves the Revit version unstated). Neither listing identifies SKU 610AA001.020; Archade download requires a free account. Neither family was downloaded or inspected. These are excluded from fit evidence; exact selected-SKU geometry remains unresolved.

**M-06 Evolution source correction (2026-10-28):** the full sink-top-and-leg combo is **0467400.020**; **0467004.020** is its separate sink-top component. The exact combo page links the same measured official series RFA, and its `0467.400` type metadata matches 4-in centers and the combo specification. The family's “Basin only” description still conflicts with its pedestal option and measured overall envelope, so hosted assembly geometry remains unresolved. Corrected candidate records and regenerated screens supersede the earlier SKU wording; no product or room placement is approved.

**Public residential toilet model path (2026-10-28):** LIXIL Pro publicly links a Revit RFA for discontinued component 3195A101.020, a Champion PRO elongated bowl without its coordinating tank. Its exact linked RFA is quarantined and hash-pinned (`F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393`) in the incoming test queue. The manufacturer lists it with separate 4225-series tanks for predecessor model 211AA104, but has not mapped that component set to selected current SKU 610AA001.020; no tank family was found. Product height fields also conflict (16-1/2 vs 17-11/16 in). Isolated Revit inspection is queued but blocked by the untargetable Autodesk trial overlay. Use measured bowl geometry only as a labelled component comparison; retain B as unassigned. The Access Board's 2010 ADA dimensions are a documented reference for voluntary comparison, not an established requirement here: project location, accessibility intent and legal scoping remain unknown.

**Additional public M-06 lavatory families (2026-10-28):** Public manufacturer pages link Revit files for American Standard Estate 0900800.020 (classic rectangular fireclay, 24 × 20 × 36-5/8 in), Cadet 0236411.020 (Euro-styled vitreous china, 24-1/2 × 20 × 35 in) and TOTO Dartmouth LPT642 (transitional, 24-1/4 × 18-1/4 × 34 in). Estate/Cadet are discontinued; TOTO reports limited inventory and no online retailer in the page picker, and its spec sheet is dated 2013. Their exact file URLs and SHA256 values are pinned in `Research/M06_Sink_Candidates_2026-10-28.md` and the ignored quarantine provenance record; all remain uninspected/unapproved. The gross sink-body screen now contains six product envelopes; results remain individual body-containment checks with no fixture pair or door/approach/services test. Preliminary model-code and ADA references are documented, but neither is established as applicable because the site, adopted code, amendments and accessibility scope are unknown. M-06 B remains unassigned.

**Third-party Tresham model-source check (2026-10-28):** a public index advertises a 415.65 KB “Kohler Tresham Augusta 2844” RFA, but its download is gated by a site account; a separate Revit 2011 RFA listing is for K-2979-4, not selected comparison K-2844-4-0, and also requires registration. No account or download was attempted. These do not provide verified product geometry or change the M-06 candidate status; details are recorded in `Research/M06_Sink_Candidates_2026-10-28.md`.

Acceptance criteria:

- Keep the arrival/hall edge as the owner-selected public zone and test pantry-side search window B first; preserve B as unassigned until its fit is demonstrated.
- Establish a cited half-bath fixture/clearance basis and service-path assumptions before assigning a room footprint. Do not borrow full-bath references as though they define a half bath.
- Inspect queued RevitCity 22366 only as a vanity/counter candidate. Its [listing](https://www.revitcity.com/downloads.php?action=view&object_id=22366) describes parameterized basin/counter/faucet geometry, Revit Architecture 2020, and no casework below. Revit 2027.3 geometry and type values are measured; read-only Family Editor review confirms the 3-ft and 4-ft labels both show a 2 ft 11 111/256 in default counter width, so the label cannot be used as the actual dimension. Keep the family unapproved/unplaced until its formulas/constraints are explained or a better documented vanity is selected. The toilet proxy screen does not establish a room fit or clearance basis.
- Check the entry-to-core approach, door/swing, fixture clearances and potential upper U-06 stack relationship without implying a drain/vent/service route exists.

**Evolution host-orientation subtask (in progress):** the probe is pinned to the exact Evolution RFA SHA256 `39715206f24de4b909e37324ce352bba3af348bca259b7a9c0ce335ed2ddc3ea` and runs only in a disposable intake model. Revit 2027.3 loaded four queued families in `.local/revit-pilot/family-intake/20261028T060040906Z/`; however, the Evolution placement test failed when the pilot called `Document.Regenerate()` after committing its transaction. The intake report has 76/76 checks under the previous validator, which failed to require a successful host test; that gate is now corrected, and the same run correctly failed 1/77 against the four-family Incoming set in place at that time, before the 3195A component was queued. The C# source removes the two invalid post-commit regeneration calls. Corrected isolated build SHA256 is `25C89E269F4BE7EFFDABC3FAA1E140F020C352D420CFD84B526E8FCC122FB534`. The authorized per-user manifest points to that build and its prior manifest is backed up under ignored `.local/revit-pilot/registration-backups/20261028T060506983Z/`. Revit is now running and the Security - Unsigned Add-In dialog identifies the exact verified repo-local DLL (SHA256 `25C89E269F4BE7EFFDABC3FAA1E140F020C352D420CFD84B526E8FCC122FB534`), so the approved action would be Load Once. The Autodesk trial webview is visually above that dialog; both the close control and Load Once click are routed to the child `msedgewebview2.exe` window and rejected by computer control. No trust decision was accepted; rerun the exact-DLL check after the owner dismisses the trial card. After the overlay is dismissed, use **Load Once** only for the verified exact DLL. The test cannot resolve the family’s “Basin only” versus pedestal discrepancy, product suitability, M-06 assignment, or fixture-pair fit.

The separate v3 probe build adds explicit checks that the placed instance and its retained host-face reference resolve to the disposable wall, and records the family-local axes in project coordinates. The updated PowerShell gate also requires local X/Y/Z to align with project Y/Z/X and measured project extents to match the already-measured 22 × 34.25 × 17.5052 in family geometry within 0.05 in. Autodesk's face-placement API reference describes the WorkPlaneBased requirement and the nonparallel reference-direction rule; the code's +Y rotation vector on an X-normal face meets those documented preconditions. Build `build-evolution-host-test-v3` compiles with 0 errors (two existing reference-version conflict warnings), SHA256 `10128E7AC99EDE3769E8AAE72D50F81040D3F1CC9D763D4796D61803356058F1`. Windows PowerShell syntax and synthetic positive/negative report fixtures pass: the valid mapped orientation is accepted, while mismatched projection and host-face identity are rejected. This does not count as Revit runtime evidence. The v3 build is not registered or loaded; retain the known v2 prompt until the Revit UI is controllable and the manifest backup/hash checks can be performed for the selected build.

The owner also asked for a commercial-duty toilet comparison. The latest KOHLER K-96057 sheet (2026-10-27) lists a 26-1/8 × 14-5/8 in bowl body, 10/12 in rough-in, and 25 psi flowing pressure at 25 gpm; the matching flushometer is a separate product. This is research only. Current bowl height conflicts by 1/4 in between sheet and product page, and no project water-service capacity, product selection, or M-06 fit has been established. See `Research/M06_Toilet_Options_2026-10-27.md`.

**M-06 public-source update (2026-10-28):** added TOTO Clayton LPT780 as a traditional-style research candidate. Its 2009 manufacturer sheet lists 27 × 19-5/8 × 34 in overall dimensions and a complete vitreous-china pedestal/lavatory assembly; TOTO currently flags limited inventory. Its public Revit file is hash-pinned in the ignored quarantine but has not been inspected. The eight-candidate gross-body script remains only an individual envelope screen; the exact toilet, clearance basis, door/approach, services and B assignment are still open.

Follow-up comparison adds TOTO Supreme LPT241G, a 22-7/8 × 19-5/8 in manufacturer-dimensioned pedestal assembly. Its spec gives 34-1/2 in floor-to-rim while feature copy says 34 in universal height. A Canadian reseller listing exposes a TOTO-hosted RFA URL, but the manufacturer endpoint returned 403; no alternate route was attempted, no family was obtained, and local availability is unknown. The eight-candidate screen remains individual product-body rectangles only.

**Selected toilet family access check (2026-10-28):** the exact American Standard 610AA001.020 page still exposes only predecessor 211AA specification/installation resources in its visible download section. Manufacturer literature points Revit distribution to ATS; ATS's FAQ requires a login plus a Project or Spec to download. No account was created. A public Revit link for the distinct 211CA standard-height predecessor is not a match for the owner's chair-height 610AA SKU. Exact current dimensions and family remain an evidence gate before toilet-and-sink layout or room assignment.

### M21 — Coordinate the main-floor public route and porch envelope

Status: **completed as a reproducible, unapproved plan-coordinate comparison**; entry and porch choices remain open.

Acceptance criteria:

- Carry the 36 in plan-route proxy, balanced dining seats and both nominal door positions into one main-floor comparison; keep the M18 10 in/15 in proxy gaps and the 20 in east return labeled as schematic measurements.
- Test a plan-coordinate arrival path from the east test-shell edge through M-05 toward M-01; keep geographic orientation, actual entry opening and hall connection unselected until documented.
- Compare the 12 × 10 ft porch orientation's 4 in test-outline reserve with the 10 × 12 ft orientation's 20 in projection beyond the 40 × 42 ft outline. Do not call either result a wall/foundation/site fit.
- Keep walls, door swings, floor transitions and accessible route claims gated on documented assemblies, site and product dimensions.

Evidence: `Tools/test_m21_main_floor_access_study.ps1` regenerates the combined entry/route/porch sketch, source-fingerprinted JSON and checks. Its 18 arithmetic/data-guard checks pass; the M-05 approach remains explicitly a proposal because the block data contain no modeled walls, openings, door or site approach.

### M22 — Resolve the M-01 hearth and viewing wall before family placement

Status: **in progress**. Manufacturer source research and two unselected wall-relationship options are documented. Exact stove, TV size/viewing wall, hearth construction, and vent/site route remain unresolved; no Revit derivative placement is authorized by this study.

Acceptance criteria:

- Locate a pellet-stove-compatible source and manufacturer clearance envelope matching the approved appliance direction; the RevitCity open-fireplace object 18782 is not the stove.
- Define a documented hearth wall/orientation and room relationship before placing either stove or surround in a Revit derivative.
- Test the queued TV visual placeholder only against an owner-approved viewing wall and size; preserve the selected legacy CRT requirement if it remains current.
- Keep all appliance, hearth and egress clearances explicitly unverified until the product, wall assembly and qualified review are available.

Current evidence: `Research/M22_Pellet_Stove_Envelope_2026-10-28.md` records the manufacturer-source P43-C candidate and open recess/mantel gate; `Architecture/M22_Living_Room_Hearth_Study_2026-10-28/` contains the reproducible two-option plan comparison and 20/20 arithmetic/provenance/non-claim checks. The candidate is not a product selection.

### M23 — Develop the exterior gathering area and furnishings

Status: **waiting on the owner to identify the existing chair selection**. The repository records the carry-forward requirement but no brand, model, URL or asset path. Do not substitute or restart the product choice.

Acceptance criteria:

- Carry forward the owner's **already-selected Adirondack chair model** recorded in `Architecture/Building_Program.md`; retrieve that exact source/asset before modeling and do not substitute a RevitCity result.
- Coordinate chairs with the eventual pool, patio and outdoor-fireplace choices only after site, grade, circulation and fire-feature locations are defined.
- Keep count, spacing, paving, guard/edge conditions and exterior fireplace/pool geometry unassigned until supported by owner/site information.

### M24 — Audit the Revit 2027 IFC export and property-mapping setup

Acceptance criteria:

- Record the API-level IFC options explicitly supplied by each RevitPilot export path, and fingerprint the source, manifests, and matching export evidence.
- Preserve IFC2x3 output compatibility already used by the project and independently verify exported inventory/schema after any settings change.
- On a controllable Revit 2027 host, record the active saved or in-session parameter-mapping template and export a local, hashed copy when the API permits. Do not alter the selected-D model to obtain this evidence.
- Keep absent or inaccessible host-side settings marked unverified; do not infer them from an IFC file alone.

Current status: static source/configuration audit passes 16/16 checks (`Research/M24_Revit_2027_IFC_Settings_Audit.json`). The retained exact-backup IFC validator passes 26/26, including source-matching `IfcSpace.LongName` values. Its report observes zero property-set or quantity-set relationships on all 21 spaces; this absence is a documented data-coverage gap, not a schema failure. Host parameter-template capture remains pending a trustworthy local .NET SDK build and a controllable Revit session.

### M25 — Reconcile selected-D social-room areas before coordinated layout

Acceptance criteria:

- Read the selected-D room blocks and compare M-01/M-02/M-03 areas with ranges in the checked-in room program.
- Verify the review CSV matches the study block arithmetic and the room-program source ranges.
- Present bounded retain-or-retarget proposals without changing selected D or inventing replacement dimensions.

Current status: `Tools/audit_m25_social_room_area_reconciliation.ps1` passes 16/16 checks. Two fresh PowerShell 5.1 runs produced byte-identical JSON (SHA256 `72547E8C15C09C9476193DBCF045897B93EC93C036FA3A0DA336CCB1E1DE60C6`). The report compares 676 sf of selected-D living/kitchen/dining room blocks with a combined preliminary range of 420–525 sf, and adds the earlier documented 14 × 12 ft kitchen / 11 × 10 ft dining option (518 sf with current D living). That option has known preferred-fit shortfalls in the existing comparison. No room sizes or layouts have been selected. See `Architecture/M25_Social_Room_Area_Reconciliation_2026-10-28/README.md`.

### M26 — Inspect public exact-SKU M-06 toilet family alternative

Acceptance criteria:

- Preserve the owner-selected Champion PRO 610AA001.020 as the first investigation target; clearly label any alternate as a proposal.
- Retain any public candidate only with its official product/model URL, exact source hash and an unmodified quarantined copy.
- Inspect candidate family category, type metadata, host behavior and geometry in Revit 2027 without saving the source; measure only in a disposable derivative.
- Do not assign B unless the selected product geometry, applicable clearance basis, door/approach and plausible service route are all supported.

Current status: TOTO's official page exposes a public Nexus MS442124CEFG Revit file; an unauthenticated byte-identical source is quarantined with SHA256 `ACA931BF657DB567B4A45DC47F6CB526C6F701969ABDCF99EEE29FAF38BE72A0`. The manufacturer marks the product limited inventory. Family inspection remains pending while Revit's trial overlay prevents reliable UI interaction. This is a research alternative only; Champion remains the owner-selected first candidate and M-06 remains unassigned. See `Research/M06_Toilet_Options_2026-10-27.md`.

### M27 — Revalidate owner-selected D schematic regeneration

Acceptance criteria:

- Regenerate the owner-selected D schematic twice into fresh ignored scratch directories, leaving checked-in source outputs untouched.
- Require all documented geometry/provenance checks to pass and all generated artifacts to match byte-for-byte.
- Keep the output explicitly classified as schematic room-block geometry, not coordinated building geometry.

Current status: Windows PowerShell 5.1 regeneration passed **43/43** checks twice; all seven artifacts (study, checks, CSV schedules and three plan SVGs) are byte-identical across runs. Both generated SVG sets parse as XML. The tracked selected-D output and Revit/IFC baseline were not modified. This verifies repeatable schematic regeneration only.

### M28 — Revalidate the preserved selected-D IFC package

Acceptance criteria:

- Run the independent IFC validator against the exact-backup derivative whose RVT bytes match the export manifest; do not replace the stale named source RVT or historical IFC.
- Require IFC2X3 schema validation, source-matching names/areas/levels/bounds and expected absence of physical construction categories.
- Regenerate the JSON report twice from unchanged inputs and compare the reports byte-for-byte.

Current status: `Tools/RevitPilot/validate_selected_d_ifc.py` passes **26/26** twice against `.local/revit-pilot/selected-d/exact-backup-validation-m22-20261028/`; both reports match byte-for-byte (SHA256 `F3DE33E36318B0C050218B2D73056B046338DB130EE991A3FEA91E2B05A28389`). IFC2X3 has zero schema issues, 21 named spaces on three storeys match source, and the intended physical construction categories are empty. It reports zero property-set and quantity-set relationships for all 21 spaces. These are results from the preserved derivative; the currently named RVT remains stale versus the export record.

### M29 — Compare previously documented kitchen/dining dimensions against current area and fit checks

Acceptance criteria:

- Derive the earlier kitchen/dining option only from the checked-in room specifications, and test its areas against current room-program ranges.
- Preserve the current selected-D living area in the comparison and label the resulting total as a partial social-room subtotal.
- Carry forward the existing kitchen-chain and dining-table fit findings so an area reduction is not presented as a fit improvement.
- Do not alter selected D, replace the source dimensions, or infer a new layout.

Current status: the M25 PowerShell audit now includes a third documented option and passes 16/16 checks. Reusing the historical kitchen/dining sizes yields 168 sf + 110 sf while keeping current 240 sf living = **518 sf**; M-02 and M-03 are within their current program ranges, M-01 remains 20 sf over its range maximum, and the subtotal is seven sf below the combined maximum. The separate existing `Tools/compare_direction_d_social_room_sizes.ps1` fit-arithmetic audit passes 8/8 and records that this kitchen misses the preferred chain by 6 in on the long axis and 30 in on the short axis, while dining fails the preferred table envelope. No revised layout has been generated or selected.

### M30 — Reconcile upper-suite privacy and door adjacency

Acceptance criteria:

- Derive the nominal room-to-room connectivity graph only from selected-D `upper_door_matrix`; fingerprint the study, current room program and selected-direction decision.
- Check the documented primary/boutique/hybrid relationship, private-bath access, guest hall access and hybrid/guest Jack-and-Jill links.
- Distinguish an open topology question from a failed software/data-integrity check; state the interpretation used for “suite connection.”
- Do not change selected-D room blocks, door reservations or Revit/IFC baseline; present only bounded next-step choices.

Current status: the historical `Tools/audit_m30_upper_suite_adjacency.ps1` remains valid for the old selected-D topology. The owner resolved its principal design question on 2026-10-28 by directing a private primary → boutique → hybrid sequence. The follow-up proposal adds U-02 → U-03 as a topology target and provisionally carries forward the current U-03 shared-hall edge; whether that edge should remain after private continuity is established was not part of the owner's answer. Guest hall access and the Jack-and-Jill pair remain carried forward. No upper room-block rearrangement, corridor, wall or door has yet been tested. The old selected-D matrix remains unchanged; no door is verified as a clear opening, leaf or swing.

### M31 — Reassess pyRevit and Python.NET for the Revit 2027 toolchain

Acceptance criteria:

- Compare Autodesk's Revit 2027 .NET/API requirements with current pyRevit release claims, its agent-runtime validation status and Python.NET's documented role.
- Record interpreter lifecycle, security/data-flow limitations and the distinction between model-read-only behavior and process sandboxing.
- Recommend a compatible division of labor without replacing the currently reproducible PowerShell/C#/IFC-validation pipeline.
- Do not install software, register an MCP server, change Revit attachments or transmit model data.

Current status: research is recorded in `Research/Revit_Python_Tooling_2026-10-27.md`. Autodesk and pyRevit project sources both point Revit 2027 toward .NET 10; pyRevit v7.0 advertises the agent runtime, but its live documentation still calls it experimental and only names Revit 2024/2025 as host-validated. Its documented model-provider data flow and plaintext run retention are material for this home model; its `readonly` mode does not sandbox file/network/process side effects. Keep PowerShell/JSON + C# RevitPilot as the production path and Python offline for IFC inspection. Any pyRevit agent-runtime test requires a separately approved install/MCP registration, a sanitized disposable model and review of data retention first. No software or registration was changed.

### M32 — Convert owner follow-up into a reproducible house-design proposal

Acceptance criteria:

- Record the owner's private-suite sequence, earlier kitchen/dining target sizes, steep-roof exploration and Connecticut jurisdiction without changing selected-D source geometry.
- Generate a separate PowerShell room-block proposal with source fingerprint, exact kitchen/dining target areas, containment/non-overlap/adjacency checks, an M-06 B search window that remains unassigned, and a qualitative roof concept with no invented pitch or structural inputs.
- Expose the kitchen/island/clearance conflict rather than silently changing a design input.
- Record current Connecticut code-adoption research from primary sources and identify municipality/site/permit-date limitations.
- Re-run into fresh scratch directories; require all checks, JSON parsing, SVG parsing and byte-identical artifacts; reject output paths outside the repository.

Current status: `Tools/build_owner_followup_design.ps1` produces `Architecture/House_Design_Iteration_2026-10-28/`. It passes **16/16** named checks in two fresh Windows PowerShell runs with byte-identical `study.json`, `checks.json`, both SVGs and `manifest.json`; it rejects output paths outside the repository. M-02/M-03 are 168/110 sf; proposed main room blocks fit the 40×42 ft test envelope without mutual or comparison-core overlap and retain pantry-side B as an unassigned 72.33 sf gross gap. The 8×4 ft island's 8 ft axis needs 15 ft with two 42 in clearances, so neither target-room axis accommodates it. Upper private-suite intent is represented as a graph target only; geometry remains untested. The steep gable is a not-to-scale concept. Connecticut DAS lists the 2022 code; its adoption page reports the planned 2026 update delayed pending legislative approval. See the proposal README and follow-up decision for sources and remaining gates. This does not validate code compliance, structure, site fit or a complete house.

### M33 — Screen open kitchen/dining furniture fit

Acceptance criteria:

- Reuse the selected-D 8×4 ft island source and documented 36×60 in dining table/clearances; do not change owner-selected room targets or source geometry.
- Test the island and table together across the proposed 14×12 ft kitchen and 11×10 ft dining blocks, including the 42 in island test envelope, 36 in minimum table pull-back and 42 in preferred table wall/door clearance.
- Check the candidate against the comparison core and keep M-06 B unassigned.
- Emit a source-fingerprinted PowerShell report and drawing; require deterministic outputs, parseable JSON/SVG, and repository-contained output paths.
- State clearly whether an independent dining-to-porch route, cabinets, appliances, walls and actual openings have been verified.

Current status: `Tools/test_m33_open_social_zone_fit.ps1` passes **14/14** checks. In two fresh Windows PowerShell 5.1 runs, `fit.json`, `checks.json`, `open-social-zone.svg` and `manifest.json` are byte-identical; both JSON reports and the SVG parse, and the output-path traversal guard rejects an outside path. One candidate places the source-derived island across M-02/M-03 and a source-derived table within M-03. The 36 in table envelope fits the dining block exactly; the 42 in preferred envelope spills 0.5 ft beyond it. The island's 42 in envelope extends 2.167 ft east and 1.5 ft north beyond M-02 into unassigned test-shell area. These rectangles do not establish clear circulation: their unlike envelopes meet at a boundary, and the dining-to-porch route, cabinets, half wall, appliances, doors, wall faces and occupied-chair extents remain unmodeled. No Revit or IFC work was performed. See `Architecture/M33_Open_Social_Zone_Fit_2026-10-28/README.md`; resolve a full furnished route before calling the social zone coordinated.

### M34 — Test upper-suite private-link geometry

Acceptance criteria:

- Preserve the selected-D source and owner-directed room sizes; use the documented upper-frame offset when comparing wing rooms with shared-frame core reservations.
- Quantify the existing U-02/U-03 separation and screen a direct-adjacency move with the inherited nominal wall allowance.
- Check candidate collisions with current public circulation and the lift reservation; report any existing projected room/core overlap without silently changing the D baseline.
- Emit a reproducible PowerShell report and diagram; repeat into clean scratch directories, parse JSON/SVG and guard output paths.
- Keep guest hall access and the U-03/U-04 Jack-and-Jill relationship as explicit design requirements; do not claim a viable full-suite route until circulation and core geometry connect.

Current status: `Tools/test_m34_upper_suite_private_link.ps1` passes **7/7** source/arithmetic checks. It confirms a 5 ft current gap between U-02 and U-03, comprising the 4 ft shared corridor plus nominal side allowances. A single westward U-03 move preserves its source size and creates a 0.5 ft wall allowance to U-02, but it overlaps 36.667 sf of C-UPPER and 26.667 sf of the lift reservation after applying the documented +6 ft upper-frame translation. The current U-03 itself has a 25 sf projected lift-reservation overlap, an existing coordination issue not covered by the selected-D room-overlap checks. These are plan-screen findings; verify shaft/floor geometry in Revit before treating the reservation as definitive. No alternate full-suite packing, door, corridor-to-stair connection, Revit model or IFC is asserted. Two fresh PowerShell runs produce byte-identical outputs; JSON/SVG parsing, intersection arithmetic and path guard pass. See `Architecture/M34_Upper_Suite_Private_Link_2026-10-28/README.md` for the owner design gate.

## RevitCity research and candidate disposition (2026-10-27)

- Retired the dimensionally failed 19967 and unsuitable 21015 island alternatives from the incoming/active candidate pool. Their sources and test evidence remain preserved; the duplicate 19967 download was removed after its SHA256 was confirmed identical to the archived original.
- Kept the 7216 source as the current island base-block candidate, with the separate generic-top assembly as the dimensionally passing study. Source reuse permission remains unreviewed, so no public-model or product approval is implied.
- Reopened the authenticated RevitCity session and reviewed the 7216 island listing plus the queued 22366 vanity listing. No additional family was downloaded. Details and limitations are in `Revit/Family_Intake/RevitCity_Family_Intake.md`.

## Selected-D fingerprint checkpoint — 2026-10-28

The current-source export run `.local/revit-pilot/selected-d/20261028T021345099Z/` still contains the documented 21-space IFC2X3 geometry and clean schema, but its named RVT no longer matches the export fingerprint after the owner-saved file update recorded in `PROGRESS.md`. Manifest fingerprint: `7a03f704329e840c938361d06c31329823e3d939c993bbc4e11de67e991af7ff`; current named RVT fingerprint: `7427ffa0eeeb5a2a5a4d46bf3d6876c8f906d3c723a74e2bfac2af644d610299`. Automatic backup `.0001.rvt` retains the manifest-matching bytes; a new isolated scratch revalidation at `.local/revalidation/selected-d-baseline-20261028/recheck-exact-backup/` passes 23/23. Validation of the current named RVT fails only the saved-model fingerprint check. Keep both backup files and the current named RVT unchanged; regenerate a separate current-source study only after the Revit add-in is available and the owner-approved workflow can be resumed.
