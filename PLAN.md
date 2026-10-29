# Architectural BIM pipeline plan

Updated: 2026-10-28
Status: selected-D source remains unchanged at SHA256 `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`. Re-audit of the fresh Revit 2027.3 run at `.local/revit-pilot/selected-d/20261028T182748169Z/` found the package's primary-named RVT SHA256 `8743A9FE5C36DC8888FF0709A6BB0367F2E330F7F40A17106EF035879F6FC842` differs from the study/export fingerprint `83675C7229087E1C8D812DDFE31C0A46C0F9229AC9F9240DE28F12906AFE2D9E`. That export/audit fingerprint matches the retained `.0001.rvt` backup; a separate validation copy using that exact backup passes **26/26**. The original run remains preserved and its in-folder pass report is stale relative to the current primary-named RVT bytes; see M48 in `PROGRESS.md`. The exact source and IFC still validate as a coherent pair when bound to the matching backup, but the primary-named file must not be presented as matching. M49 independently recalculates the M46 hall grid and passes **111 checks** on both retained and replay evidence; U-02's only reachable sampled edge is north. M50 confirms LIXIL's predecessor-linked Revit file is a seat-only family, while predecessor assembly dimensions remain unverified for current 610AA001.020. The M46 candidate remains an unapproved 40×42 ft envelope comparison. The study has 3 levels, 21 spaces, 0 native walls/openings, and 0 Revit warnings. The owner-follow-up proposal retains the 14×12 ft kitchen and 11×10 ft dining targets, Connecticut research jurisdiction and conceptual steep traditional gable; pitch and roof geometry remain unselected. U-03 is private-route-only, with guest hall access and both Jack-and-Jill links retained. Upper-suite geometry remains a room-block proposal. M-06 B remains unassigned. No construction geometry, code compliance, structural safety, or construction-readiness is claimed.

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

**Public residential toilet model path (2026-10-28):** LIXIL Pro publicly links a Revit RFA for discontinued component 3195A101.020, a Champion PRO elongated bowl without its coordinating tank. Its exact linked RFA is quarantined and hash-pinned (`F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393`) in the incoming test queue. Read-only Revit 2027.3 inspection of the hash-verified source identified category Plumbing Fixtures (host behavior not recorded), a 14-in type width, 16-1/2-in authored height, a 12-in waste rough-in field, and separate 4225-series tank / 5325.010 seat options; no plan-depth type parameter or selected-SKU crosswalk is present. The family confirms only bowl-component geometry, not its assembled installation bounds. The manufacturer lists it with separate 4225-series tanks for predecessor model 211AA104, but has not mapped that component set to selected current SKU 610AA001.020; no tank family was found. Product height fields conflict (16-1/2 vs 17-11/16 in). The RFA was closed without saving and remains byte-identical. Use it only for labelled component research; retain B as unassigned. The Access Board's 2010 ADA dimensions are a documented reference for voluntary comparison, not an established requirement here: project location, accessibility intent and legal scoping remain unknown.

**Additional public M-06 lavatory families (2026-10-28):** Public manufacturer pages link Revit files for American Standard Estate 0900800.020 (classic rectangular fireclay, 24 × 20 × 36-5/8 in), Cadet 0236411.020 (Euro-styled vitreous china, 24-1/2 × 20 × 35 in) and TOTO Dartmouth LPT642 (transitional, 24-1/4 × 18-1/4 × 34 in). Estate/Cadet are discontinued; TOTO reports limited inventory and no online retailer in the page picker, and its spec sheet is dated 2013. Their exact file URLs and SHA256 values are pinned in `Research/M06_Sink_Candidates_2026-10-28.md` and the ignored quarantine provenance record; all remain uninspected/unapproved. The gross sink-body screen now contains six product envelopes; results remain individual body-containment checks with no fixture pair or door/approach/services test. Preliminary model-code and ADA references are documented, but neither is established as applicable because the site, adopted code, amendments and accessibility scope are unknown. M-06 B remains unassigned.

**Third-party Tresham model-source check (2026-10-28):** a public index advertises a 415.65 KB “Kohler Tresham Augusta 2844” RFA, but its download is gated by a site account; a separate Revit 2011 RFA listing is for K-2979-4, not selected comparison K-2844-4-0, and also requires registration. No account or download was attempted. These do not provide verified product geometry or change the M-06 candidate status; details are recorded in `Research/M06_Sink_Candidates_2026-10-28.md`.

**Connecticut M-06 code basis (2026-10-28):** DAS currently lists the 2022 CSBC, which adopts the 2021 IRC, IPC and 2017 ICC A117.1; DAS also says its planned 2026 codes remain delayed pending Legislative Regulation Review Committee approval. Assuming this is a detached one-family dwelling, 2021 IRC §§R307.1/P2705.1 are the provisional plan-screen reference: 15 in toilet centerline-to-side obstruction and 21 in front clearance, with door/window operation preserved. This is a labelled screen basis only; verify project classification, the complete adopted code and amendments, jurisdiction and permit date. It is not a code-compliance or accessibility finding. Details and primary links are in `Research/M06_Toilet_Options_2026-10-27.md`.

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

Current status: Revit 2027.3 visual/type inspection is complete for the quarantined, hash-verified TOTO Nexus MS442124CEFG alternative and Champion PRO 3195A101.020 predecessor bowl component. Disposable intake run `.local/revit-pilot/family-intake/20261028T210959251Z/` loaded all five incoming families and measured 14 types; the Champion bowl-only type has 13.9997 × 29.0628 × 17.0953 in positive-solid bounds in family-symbol coordinates. This is not an assembled, placed or oriented toilet envelope. The independent PowerShell gate reports 95/96 checks: its only failure is the Evolution disposable-wall host/orientation probe, which returned no referenceable wall face. A focused RevitPilot patch now requests side-face references through Autodesk's `HostObjectUtils.GetSideFaces`; it compiles in isolated build `.local/revit-pilot/build-evolution-host-v4/` (DLL SHA256 `0278CF2EABF981367DF679538DEDE1D3CB412E960AA1537F80046FC7A3ADC0E4`) but has not yet been loaded or host-tested because the active Revit process holds the registered DLL. Autodesk API reference: [HostObjectUtils.GetSideFaces](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/589b9363-c2cc-52d9-6ba1-fc8e8f912b27.htm). TOTO appears tank-and-bowl form, face-hosted, Plumbing Fixtures category, with authored bounds 18 1/2 × 28 5/8 × 28 177/256 in; its displayed 1.00 GPF conflicts with the official product's 1.28 GPF. The Champion predecessor type reports 14-in width and 16 1/2-in height, names separate 4225-series tank and 5325.010 seat options, and exposes no plan-depth type parameter; its authored height matches manufacturer feature copy but conflicts with the 17 11/16-in nominal dimension. Neither family is the selected complete Champion PRO 610AA001.020; keep both research-only and M-06 B unassigned pending exact selected-product geometry, applicable clearance basis, door/approach and service route. See `Research/M06_Toilet_Options_2026-10-27.md` and `Revit/Family_Intake/RevitCity_Family_Intake.md`.

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

Current status: the historical `Tools/audit_m30_upper_suite_adjacency.ps1` remains valid for the old selected-D topology. The owner directed a private primary → boutique → hybrid sequence and later superseded the earlier U-03 shared-hall confirmation with **private route only**. The follow-up proposal adds U-02 → U-03, excludes a direct U-03 → C-UPPER edge, and retains guest hall access plus both Jack-and-Jill links. No upper room-block rearrangement, corridor, wall or door is yet validated. The old selected-D matrix remains unchanged; no door is verified as a clear opening, leaf or swing.

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

### M35 — Coordinate kitchen casework, occupied dining chairs and a porch route

Acceptance criteria:

- Preserve the owner-confirmed 14×12 ft kitchen and 11×10 ft dining targets and source 8×4 ft island; do not edit selected-D.
- Test the specified perimeter cabinet depth, refrigerator/sink/dishwasher/range width reservations, range landing widths and 6 in half-wall against an explicit island move and its 42 in envelope.
- Place four source-sized dining chair bodies and preserve an independent 36 in route from table to a nominal 5 ft French-door opening and through a candidate porch to a nominal 3 ft exterior opening.
- Compare porch positions against pantry-side M-06 B and the selected-D comparison core without assigning B.
- Emit ordered, source-fingerprinted PowerShell JSON/checks/SVG/manifest; test reproducibility, parseability and the repository-contained output path guard.
- Label product operation, thresholds, doors, site orientation, Revit/IFC and code limitations.

Current status: `Tools/test_m35_social_zone_casework_porch.ps1` passes **29/29** checks. The M33 baseline's island-42/table-preferred-42 clearance envelopes overlap **5.166667 sf**; a proposed 0.5 ft south shift preserves the island body inside M-02, clears both 42 in envelopes and leaves 42 in between the island and proposed south-wall casework. A source-width appliance lineup occupies 150 of 168 in, with 18 in unallocated. Four 18×20 in chairs leave a 36 in east-side route from the dining table to the proposed porch door. The east-side 12×10 ft porch candidate clears B, the island envelope and core reservations, but extends 5.5 ft beyond the main-shell test boundary; the north-side alternative overlaps 70 sf of unassigned B. M-06 B is unchanged and unassigned. No Revit/IFC geometry, product-specific operating envelopes, site orientation, or compliance conclusion is verified. See `Architecture/M35_Social_Zone_Casework_Porch_2026-10-28/README.md`.

### M36 — Screen steep-gable ridge direction and Connecticut roof-code inputs

Acceptance criteria:

- Use only the source-derived 40×42 ft test envelope; compare ridge directions without assigning site northing, pitch, rise, eaves, overhangs or roof assemblies.
- Express ridge rise as a function of half-run and an unassigned pitch ratio; quantify the relative span difference without inventing structural dimensions.
- Refresh Connecticut code-status research from official DAS/CSBC sources, distinguish IRC from IBC provisions, and state municipality/permit/site dependencies.
- Emit a source-fingerprinted PowerShell report, checks, SVG and manifest with repeatable outputs, parsable JSON/SVG and a repository-contained path guard.
- Make no code, structural, certification, permit or construction-readiness claim.

Current status: `Tools/build_m36_roof_orientation_study.ps1` passes **11/11** checks. The 40 ft transverse option has a 20 ft half-run; the 42 ft transverse option has a 21 ft half-run, so the latter would have 5% greater rise at any identical eventual pitch. No pitch or actual rise is assigned. Two fresh PowerShell runs produce byte-identical `roof-study.json` (`C2CC01A7F10CEAC813B49E5F3E745117893DA9F3793623B3D6EECF934D505BD4`), `checks.json` (`82E1EDF8568057AB1E8E0D82B14BD2FDB3D230429E5CBE4E22248C8DFC9FC6B7`), SVG (`A6F2106516C5779FB5E6A281B8BA2A74D27E7ADA0B710249455FF800C2B64889`) and manifest (`B96946C82B2C30E9B14B2215C31533596F1AF98895E1D20A934D6E2126A354F6`). The official Connecticut DAS pages report the 2022 CSBC currently adopted for permit applications from October 1, 2022, with the planned 2026 effective date delayed at the time checked. The research note separates the IRC roof snow-table amendment from the IBC sloped-roof calculation amendments and preserves site/municipality/permit limitations. See `Research/Connecticut_Roof_Code_Research_2026-10-28.md` and `Architecture/M36_Roof_Orientation_Study_2026-10-28/README.md`. This is a ridge-orientation screen, not a roof design or compliance check.

## RevitCity research and candidate disposition (2026-10-27)

- Retired the dimensionally failed 19967 and unsuitable 21015 island alternatives from the incoming/active candidate pool. Their sources and test evidence remain preserved; the duplicate 19967 download was removed after its SHA256 was confirmed identical to the archived original.
- Kept the 7216 source as the current island base-block candidate, with the separate generic-top assembly as the dimensionally passing study. Source reuse permission remains unreviewed, so no public-model or product approval is implied.
- Reopened the authenticated RevitCity session and reviewed the 7216 island listing plus the queued 22366 vanity listing. No additional family was downloaded. Details and limitations are in `Revit/Family_Intake/RevitCity_Family_Intake.md`.

## Selected-D fingerprint checkpoint — 2026-10-28

The current-source export run `.local/revit-pilot/selected-d/20261028T021345099Z/` still contains the documented 21-space IFC2X3 geometry and clean schema, but its named RVT no longer matches the export fingerprint after the owner-saved file update recorded in `PROGRESS.md`. Manifest fingerprint: `7a03f704329e840c938361d06c31329823e3d939c993bbc4e11de67e991af7ff`; current named RVT fingerprint: `7427ffa0eeeb5a2a5a4d46bf3d6876c8f906d3c723a74e2bfac2af644d610299`. Automatic backup `.0001.rvt` retains the manifest-matching bytes; a new isolated scratch revalidation at `.local/revalidation/selected-d-baseline-20261028/recheck-exact-backup/` passes 23/23. Validation of the current named RVT fails only the saved-model fingerprint check. Keep both backup files and the current named RVT unchanged; regenerate a separate current-source study only after the Revit add-in is available and the owner-approved workflow can be resumed.

### M37 — Pack the owner-directed upper suite around the stair, lift and public route

Acceptance criteria:

- Preserve selected-D room dimensions/source and the +6 ft upper-frame transform; keep the selected-D baseline unchanged.
- Carry the current owner direction: U-01 → C-PRIVATE → U-02 → U-03 private route only; no direct U-03 shared-hall door; retain guest hall access, primary-only bath access and both Jack-and-Jill links through U-06.
- Test the source lift projection and a continuous 4 ft public route from the source upper landing; label nominal door reservations and wall gaps as schematic.
- Produce source-fingerprinted PowerShell JSON/check/SVG/manifest output; verify parser, path guard, deterministic replay and route evidence.
- Treat bounded no-candidate results as inconclusive, and keep any candidate outside selected D pending later Revit/IFC validation.

Current status: The corrected M-37 script supports balanced/isolated room roots, landing-aligned seeds, U-02 traversal order, extra room-contact samples, and 1–9 edge-goal samples per room (default centred). The current script passes 27/27 integrity checks. The refreshed 1,500-node default records 285 layouts but no approach-clear routes and reproduces byte-for-byte in two clean runs. The corrected U-02-only expanded-contact screen records 200 layouts/routes; U-02 is hall-reachable in 179 cases, while U-01/U-04 are not. The balanced expanded-contact screen with nine public edge samples records 25 layouts/routes; U-01 is reachable in 19, U-02 in 6, U-04 in 12, but no layout reaches U-01/U-02/U-04 together. All stress screens expand 9,000 nodes across valid seeds and remain incomplete; no infeasibility conclusion follows. M39 reproducibly renders the best observed partial combination, U-01 plus U-04 (2/3 required public rooms), while U-02 remains absent. Next represent selected public doorway/contact relationships during placement or test owner-approved landing-contact alternatives. Door-goal samples are hypotheses, not openings; U-03 remains private-route-only, M-06 B remains unassigned, and physical Revit/IFC coordination remains open. No selected-D dimensions or geometry changed. See `Architecture/M37_Upper_Suite_Pack_Route_2026-10-28/README.md` and `Architecture/M39_Upper_Suite_Partial_Access_Study_2026-10-28/README.md`.

### M38 — Compare illustrative steep-gable pitch options

Acceptance criteria:

- Use only the existing 40×42 ft owner-follow-up **test envelope** and source-derived half-runs for the two ridge directions.
- Compare labelled pitch-ratio proposals without selecting a pitch, eave datum, roof orientation, assembly or structural dimensions.
- Verify rise/roof-plane arithmetic and preserve all options as proposals; do not infer code compliance from roof steepness.
- Reference the current Connecticut roof-code research and keep municipality/site/permit/loads open.
- Produce a source-fingerprinted PowerShell report, checks, SVG and manifest; verify deterministic replay and parsable outputs.

Current status: `Tools/build_m38_steep_roof_pitch_options.ps1` compares illustrative 8:12, 10:12 and 12:12 ratios against both 20 ft and 21 ft half-runs. It passes **12/12** checks and produces identical artifacts in two scratch runs. Rise above a future eave ranges from 13.33 to 20 ft for the 40 ft span and 14 to 21 ft for the 42 ft span. Those are explicit hypothetical massing cases; no pitch, eave or ridge datum is selected. See `Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/README.md` and the official-source context in `Research/Connecticut_Roof_Code_Research_2026-10-28.md`. No roof solid, load/design calculation, code-compliance or permit conclusion is produced.

## Owner-directed upper-suite revision — 2026-10-28

- The latest owner choice supersedes the earlier shared-hall-door decision: U-03 is private-route-only, reached through U-02. Keep guest hall access and both Jack-and-Jill links. Selected-D remains unchanged.
- The reproducible M-37 search contract and checked-in report now match. Current default screen passes 17/17 integrity checks and two fresh 1,500-node replays match byte-for-byte. It found 388 bounded layouts but zero placements clearing the lift plus reserved stair approach; therefore it tested no corridor routes and yields no candidate. Improve how the landing approach is reserved during packing before increasing the search budget.
- Evolution 0467004.020 was inspected in Revit 2027.3 in 3D, Front, Back and Ref. Level views, then closed without saving. Its source hash remains `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`. The visible views do not identify a distinct pedestal leg; the family is face-hosted and the basin/host-plane relationship leaves the assembly unresolved. Keep it quarantined and unplaced.
- Open work: M-37 route-aware packing and disposable Revit review; actual fixture geometry, applicable clearance basis, approach/door and service path before assigning M-06 B; combined kitchen/dining fit; roof/code inputs; and reconciliation of the stale named RVT versus the exact backup/IFC lineage. Native walls/floors/stairs/roof are not yet present in selected D.

## Forward design milestones and acceptance criteria

- **M9 — Upper-suite circulation layout proposal:** make the 4 ft stair-approach reservation part of room placement rather than a post-filter; search only documented envelopes. Pass only when direct U-02 shared-hall arrival, guest access to U-04, private U-01 → C-PRIVATE → U-02 → U-03, both Jack-and-Jill links, lift separation and source-derived stair approach are all represented, with no U-03 public door. Candidates remain proposals until owner review; selected D stays preserved.
- **M10 — M-06 fixture and room-fit gate:** identify a complete available fixture configuration (or label discontinued research), validate actual Revit geometry/hosting, cite applicable Connecticut/local clearance and access basis, and test door/approach and plausible plumbing path in a disposable derivative. Only then propose a room footprint; keep B unassigned until all gates pass.
- **M11 — Consistent current Revit/IFC room-study lineage:** when the Revit host is available, regenerate a separate D room-space derivative from unchanged selected-D source, audit levels/space IDs/areas, export IFC2X3, and independently validate exact source/RVT/IFC hashes together. Do not reuse stale named-RVT lineage or alter selected-D geometry.
- **M12 — Documented physical-building geometry:** defer walls, floors, openings, stairs, roof and assembly-specific elements until project sources or explicit owner choices support their dimensions and construction inputs. Acceptance requires matched native QA and IFC checks, with accessibility, fire/life-safety, structure and code review explicitly open; no professional approval claim.

M-37 expanded-envelope comparison note: the unselected 40×42 ft envelope permits 82 corridor searches, but none connects to the required public-room set U-01/U-02/U-04. The U-03 corridor-side diagnostic is not door access and is not part of the current owner requirement.

### M40 — Regenerate and independently validate current-source selected D in Revit

Acceptance criteria:

- Preserve the selected-D source and create a new timestamped Revit study from the checked-in source using the authorized project-local RevitPilot add-in.
- Run the matching read-only Revit API audit and confirm levels, spaces, wall/opening counts, warnings, and exact saved-RVT fingerprint.
- Independently parse and validate IFC2X3 schema, source-matching storeys/spaces/areas/levels/plan bounds/body profiles, and matching source/RVT/IFC hashes.
- Leave older mismatched RVT/IFC evidence and the three untracked Incoming RFAs untouched; do not push or modify remote state.
- Document that the result is a room-boundary study, not a coordinated building model.

Current status: **complete** for Revit 2027.3 run `.local/revit-pilot/selected-d/20261028T182748169Z/`. Source SHA256 is `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`, RVT SHA256 is `83675c7229087e1c8d812ddfe31c0a46c0f9229ac9f9240de28f12906afe2d9e`, and IFC2X3 SHA256 is `5b65faacbf596adaf6e7b2b00a47397b965e1f9507c67cefed13729bea520425`. Matching native audit `.local/revit-pilot/audits/20261028T182832781Z/` reports Revit 2027.3 build 27.3.0.28, three levels at -5/0/+5 ft, 21 enclosed rooms, zero walls, zero openings, and zero warnings; its saved-RVT fingerprint matches. `validate_selected_d_ifc.py` passes **26/26** checks with no errors, including parseability, IFC2X3 schema, source-linked room inventory and areas/bounds/body profiles. Full command and checksums are in `PROGRESS.md`. This closes current-source room-space regeneration only. Walls, floors, native stairs, doors, roof, structure, MEP, lift product, code review, and the owner-directed upper-suite redesign remain open.

### M41 — Fit the owner-directed private upper-suite route in a bounded room layout

Acceptance criteria:

- Preserve selected-D room dimensions/source, the current 36×32 ft upper-wing test envelope, +6 ft frame convention and lift reservation unless the owner explicitly changes those inputs. Record the source landing coordinate, but assess a continuous route and landing clearance only in the broader co-placement study.
- Represent the latest topology: U-01 → C-PRIVATE → U-02 → U-03; U-03 has no direct shared-hall door; U-04 keeps independent guest-hall access; U-03 ↔ U-06 ↔ U-04 Jack-and-Jill access; U-05 remains primary-only.
- Check actual room-block contact and corridor continuity, rather than treating edge samples as doors. Measure clearances only against documented project inputs and label schematic nominal wall gaps.
- Produce deterministic PowerShell JSON/check/SVG outputs in an isolated proposal, and independently replay/validate them before any disposable Revit test.
- If the fixed lift/core/approach constraints prevent a candidate, document the smallest evidence-backed design choice needed from the owner; do not infer infeasibility from a bounded search or alter selected D.

Current status: **first contact envelope completed; directed public-route screens remain incomplete**. New PowerShell screen Tools/test_m41_upper_suite_private_contact.ps1 enumerates 486 1/6 ft placements of source-sized U-03 against four U-02 sides in two orientations. It preserves the nominal 0.5 ft wall gap, source 3.5 ft shared-edge reservation, 36×32 ft test shell, other source blocks and projected lift. The source landing is only recorded as a boundary marker; no public route or landing clearance is tested. The 12/12 integrity checks pass; two clean replays match. No single-U-03 placement is clear of all fixed room/circulation blocks and the lift reservation. The minimum contained intersection is 49.5 sf east of U-02 (36.6667 sf C-UPPER plus 12.8333 sf U-06), while avoiding the lift projection. This is a trade-off measurement, not a viable layout. M37 already co-places the full private/J&J room topology and tests a 4 ft public-route proxy; earlier balanced M37/M39 searches found only partial room reach. M42's U-02-first guest-branch search reached U-02 in 12/12 layouts but U-01 or U-04 in none. Its U-04-first stress search reached U-02/U-04 in two layouts but U-01 in neither. See the M41 and M42 study READMEs. Next improve route-aware placement pruning. No room dimensions or selected-D geometry changed.

### M42 — Directed upper-suite public-route search

Acceptance criteria:

- Reuse the M37 source-derived rooms, owner-approved private-only U-03 topology, U-04 guest access, both U-06 links, primary-only U-05, 36×32 ft test envelope, lift reservation and 4 ft route proxy.
- Compare directed room-packing orders without adopting geometry or changing selected D.
- Record exact search budget, route tests, per-room sampled access, deterministic outputs and bounded-search limits.
- A successful layout must reach U-01, U-02 and U-04 from the stair approach in the same room arrangement, with no U-03 public door.

Current status: **directed branch searches reproduced; no complete public route**. The U-02-first M37 search with 6,000-node limit expands 4,500 nodes, evaluates 12 completed layouts and runs 12 corridor tests. Sampled reach is U-02 12/12, U-01 0/12, U-04 0/12; U-03 corridor-side proximity is diagnostic only. Two independent runs are byte-identical and pass 27/27 checks. The complementary U-04-first 6,000-node screen produces no complete packings; the 12,000-node stress run expands 9,000 nodes and yields two layouts/routes, reaching U-02 and U-04 in both but U-01 in neither. It is a single, unreplayed stress run. Both search families remain incomplete; no infeasibility conclusion follows. Reports and limitations are in Architecture/M42_U02_Anchored_Upper_Suite_Route_Study_2026-10-28/README.md. Next improve route-aware pruning before escalating any room/core trade-off.

### M43 — Prune upper-suite layouts with unreachable public rooms early

Acceptance criteria:

- Add an opt-in route-pruning mode to the existing PowerShell 5.1 M37 search; require the fixed landing-aligned frame and preserve default-mode behavior.
- Prune a partial arrangement only when an already-placed required public room has no reachable sampled corridor goal; explain why adding room obstacles cannot restore such a route.
- Keep final full-route checks, source-derived dimensions, owner-selected private-only U-03 topology and all existing fit limitations.
- Validate bounded outputs and deterministic replay; compare the opt-in run with the byte-identical legacy M42 baseline.
- Do not treat an incomplete pruned search or absent room-block candidates as proof of infeasibility, and do not modify selected D.

Current status: Opt-in pruning is implemented in `Tools/test_m37_upper_suite_pack_and_route.ps1`; the default M42 replay matches the checked-in search, checks, SVG and manifest byte-for-byte. The 6,000-node U-02-first run passes 30/30 integrity checks, checks route reachability at all 4,500 expanded nodes, rejects 2,432 partial states, records no complete packings and remains incomplete. A separate 1,000-node capped run passes 30/30 and reproduces identical JSON/check/SVG/manifest across two clean runs. The 6,000-node artifacts and hashes are retained in `Architecture/M43_Early_Public_Route_Prune_Study_2026-10-28/`. This demonstrates a functioning early-prune path, not a faster or more productive search at this budget: the run yields no corridor tests and cannot be compared as a complete candidate search to M42’s 12 packings/routes. Next improve ordering or reduce the cost of reachability checks, then compare equal-budget route-tested outcomes. Connecticut remains the requested jurisdiction for code research; the town/site and adopted project code path are not established, and no compliance conclusion follows. The owner’s steep traditional gable direction remains conceptual with pitch, eaves, roof assembly and structure unassigned. M-06 B remains unassigned.

### M44 — Defer early public-route checks across non-public placements

Acceptance criteria:

- Preserve M43's every-node pruning as the default when `-EarlyPublicRoutePrune` is used; add a separate opt-in deferred-check mode.
- In deferred mode, check after the root, after each required-public room is placed, and before recording a complete layout; keep the monotone, fixed-frame constraint and final full-route test.
- Require the current owner proposal to explicitly retain direct U-02 shared-hall arrival alongside its private links; report sampled hall-side approach as a proxy, not a door.
- Compare bounded search counts and deterministic capped outputs; preserve all owner requirements and selected-D inputs.

Current status: The deferred mode passes 32/32 integrity checks against the updated owner proposal and is deterministic across two clean 1,000-node runs. The 6,000-node U-02-first run performs 2,226 route checks, defers 2,274, prunes 1,900 states, and finds no complete layouts; the search remains incomplete. It reduces route checks versus M43's 4,500 at equal node budget, but still produces no route-tested candidate. The owner decision and room program now explicitly require direct U-02 arrival from the upper shared hall while retaining U-02's private links to C-PRIVATE and U-03; U-03 remains private-only. The proposal generator passes 18/18 checks and replays byte-for-byte. M-06 B remains unassigned. See `Architecture/M44_Deferred_Public_Route_Check_Study_2026-10-28/README.md`; actual door placement and clearance remain for disposable Revit review.

### M45 — Stress-test the direct-U-02 search at twice M44's node budget

Acceptance criteria:

- Preserve all current upper-suite access decisions, source room dimensions, landing-aligned seeds, lift reservation and bounded route-proxy limitations.
- Double M44's 6,000-node cap to test whether additional tree exploration yields any complete room packing or route-tested candidate.
- Require the full search-integrity checks, unchanged selected-D fingerprint, parseable JSON/SVG, and retained hashes.
- Keep an incomplete search explicitly incomplete; do not infer infeasibility or change selected-D.

Current status: The PowerShell 5.1 run in `Architecture/M45_U02_Upper_Suite_Search_Budget_2026-10-28/` passes **32/32** integrity checks and confirms the selected-D source was unchanged. At a 12,000-node cap it expands 9,000 nodes, checks 3,916 route checkpoints, defers 5,084 and prunes 3,094 states. It yields zero complete room packings and zero final route tests, and hits the cap; the search remains incomplete. The run required approximately 18 minutes and increasing the budget did not improve candidate yield. The M44 1,000-node deterministic replay still provides the reproducibility check; this 12k stress run is retained once, not independently repeated. JSON/SVG validation passes. Next compare an explicitly unapproved full-plate upper-shell expansion already identified in M41, or reduce route-check cost before further larger runs. No owner room sizes, selected-D geometry or M-06 B assignment changed.

### M46 — Compare the documented full-plate upper-shell proposal

Acceptance criteria:

- Use only the existing 40 × 42 ft owner-follow-up test envelope as a clearly unapproved upper-shell comparison; do not change selected-D or claim the larger shell is selected.
- Retain the current source room dimensions, direct U-02 hall-arrival proxy, private-only U-03 topology, guest hall access, both Jack-and-Jill links, lift reservation and stair approach.
- Test complete room packings with final corridor reachability; check generator integrity, independent candidate geometry/topology, source/output hashes and deterministic replay.
- Record actual door, stair, clearance, code, structure, services and Revit/IFC validation as outstanding.

Current status: A 4,000-node no-prune run against the 40 × 42 ft exploratory shell records 180 complete room packings and tests all 180 routes; **10/180** reach sampled goals for U-01/U-02/U-04. The retained route-valid room-block proposal preserves all six nominal contact links and avoids the projected lift and stair approach; the independent PowerShell validator now passes **111 checks**, including a fresh BFS recomputation from the source stair landing. The generator passes **28/28**, and two full runs produce byte-identical JSON, checks, SVG and manifest. A third Windows PowerShell 5.1 replay independently reproduces all four artifact hashes and also passes **111 checks**. The direct U-02 requirement reaches only a north-side 4-ft-grid sample; it does not establish a door. The search reaches its budget and remains incomplete. This is an exploratory comparison only; it neither selects the larger shell nor edits direction D. Its coordinates and limitations are in `Architecture/M46_Full_Plate_Upper_Suite_Comparison_2026-10-28/README.md`. The larger-shell deferred-prune variant was stopped after 20 minutes without a report and is not treated as evidence. Next verify the candidate in a disposable Revit study when a controllable Revit session is available; actual doors/openings, privacy, stair/headroom, code, roof, structure, services and IFC remain open.

### M47 — Establish a Connecticut residential fixture-clearance screening basis

Acceptance criteria:

- Research current Connecticut code-adoption status from official state sources and the adopted 2021 IRC provisions relevant to the owner-requested one-family-house study.
- State only a preliminary M-06 fixture-clearance screen; distinguish it from accessibility, door/approach checks, product installation requirements and a compliance review.
- Preserve the unresolved site, municipality, permit timing and occupancy classification, and keep M-06 B unassigned.

Current status: Official Connecticut DAS sources identify the 2022 CSBC (including the 2021 IRC) as current and report the 2026 cycle's effective date delayed pending legislative review. The 2021 IRC § R307.1 points to Figure R307.1 and § P2705.1; the baseline screen recorded for a dwelling-scope study is 15 in center-to-side obstruction, 30 in between adjacent fixture centerlines, and 21 in front of WC/lavatory/bidet. See `Research/2026-10-28_Connecticut_M06_Clearance_Screen.md`. Recheck the adopted text and local applicability when the site/permit path is known; this is not a code determination or accessibility finding. Next apply the screening geometry to measured product extents, a door/approach layout and service-route candidate in an isolated study only.

### M49 — Independently recalculate the M46 sampled hall route

Acceptance criteria:

- Rebuild the four-foot-clearance occupancy grid from the source upper landing, lift reservation and retained room-block candidate rather than trusting reachability fields in `search.json`.
- Recompute sampled edge access for U-01, U-02 and U-04 and compare the result with the generator's recorded sides.
- Run against both the retained M46 output and the byte-identical Windows PowerShell 5.1 replay; preserve selected D and all Incoming RFAs.
- State that this is a grid proxy, not actual door, egress, accessibility, code or Revit validation.

Current status: Complete. `Tools/validate_upper_suite_candidate.ps1` now independently BFS-recomputes the four-foot grid from source landing coordinates and room/lift bounds. The retained candidate and `.local/revalidation/M46-ps51-replay/` each pass **111/111** checks under Windows PowerShell 5.1. For U-02, only the north-side sampled goal is reachable. Its nearest sampled wall-edge point is `(19.1667, 27.5) ft` in the candidate's local frame; the 4-ft-grid outside-goal sample `(19.1667, 30) ft` coincides with the reserved landing-approach grid start. This is a search sample, not a proposed approved door location or a measured walking path. The actual opening, wall, landing interface, privacy and finished clearances remain unresolved; the 40×42 ft shell is still an unapproved comparison. Selected D and the three Incoming RFAs remain unchanged. Next: perform the route/door check in a disposable Revit derivative when the trial WebView no longer blocks the owner-authorized add-in prompt.

### M50 — Reconcile the public Champion PRO RFA link with actual family contents

Acceptance criteria:

- Check the public LIXIL Pro product record and its linked Revit file without account creation or access-control bypass.
- Compare the downloaded file's bytes against the preserved Incoming predecessor RFA and inspect its existing Revit-family evidence before drawing conclusions about content.
- Distinguish predecessor dimensions/components from current selected 610AA001.020; retain M-06 B as unassigned.

Current status: Complete. LIXIL Pro's discontinued 211AA104.020 record lists a 30-1/4 × 19 × 31 in nominal predecessor assembly and components 3195A101.020 / 4225A104.020. Its public Revit link resolves to the exact hash of the existing Incoming predecessor RFA (`37D3E569…B0B75F63`), whose prior read-only Revit inspection shows only seat type 5325.010, not the assembly. Current 610AA001.020 still has no verified full-product family or confirmed assembled envelope; its retail page points to predecessor documentation. Evidence and URLs are in `Research/M06_Toilet_Options_2026-10-27.md` and `Revit/Family_Intake/RevitCity_Family_Intake.md`. Do not combine separate predecessor components into a presumed current-product assembly. Next: if the exact current family cannot be obtained publicly, keep the measured alternatives as explicitly identified proxies until a product crosswalk or owner-approved fixture is available, then test one in a disposable derivative with clearance, door/approach and service route together.

### M51 — Regenerate the predecessor-only gross-window screen from the current manufacturer record

Acceptance criteria:

- Preserve the earlier M-06 screen output and selected-D study; use a new versioned report for the LIXIL Pro 211AA104.020 page's 30-1/4 × 19 × 31 in nominal predecessor dimensions.
- Check both plan orientations against source-derived M-06 A/B gross gaps and verify the selected 610AA001.020 geometry flag stays false.
- State that clearances, lavatory, walls, door/approach, services and fit inside usable clear dimensions are not tested; B remains unassigned.

Current status: Complete. `Tools/screen_m06_predecessor_product_envelope.ps1` writes `Research/M06_Champion_PRO_Predecessor_Envelope_Screen_2026-10-28.json`. Windows PowerShell 5.1 generation and a separate JSON contract check pass: selected-D hash matches, B is 158 × 84 in gross, and the 19 × 30-1/4 in predecessor body rectangle is contained in both orientations. The report explicitly says exact 610AA geometry is unverified and makes no room assignment. The 2026-10-27 screen remains preserved as historical evidence. Next: obtain an exact current product dimension drawing or an owner-approved proxy, then combine fixture, lavatory, clearance, entry and service-route geometry in an isolated model before considering B.

### M52 — Combine preliminary WC side/front spacing with predecessor body envelope

Acceptance criteria:

- Derive the pantry-side B gross bounds from the unchanged selected-D study and use only predecessor dimensions in the M51 report; do not state they represent current 610AA001.020.
- Screen both orientations with 15 in from a centered WC centerline to hypothetical opposing side boundaries and 21 in in front, citing the provisional 2021 IRC basis documented in M47.
- Reproduce the JSON report byte-for-byte under Windows PowerShell 5.1 and assert that B, exact-current-product verification, and fixture assignment remain unchanged.
- Explicitly leave the 30-in adjacent-fixture spacing, lavatory, walls, door/swing, user approach and plumbing route unresolved.

Current status: Complete as a predecessor-only gross bounding exercise. `Tools/screen_m06_predecessor_clearance_proxy.ps1` passes its source/assignment preconditions and produces byte-identical scratch outputs (`.local/revalidation/M52-run-a.json` and `M52-run-b.json`, SHA256 `6CBC6EE2ADCC56C066B1B294850260E3FE41CA73BF278D4DA2DA52215B195071`). Both tested screen envelopes fit the 158 × 84 in gross B rectangle: 30 × 51-1/4 in and 30-1/4 × 40 in. The report says current 610AA geometry is unverified and M-06 remains unassigned. The side result assumes opposing boundaries and centered placement; no door, sink, wall build-up, rough-in or service route is shown. See `Research/M06_Champion_PRO_Predecessor_Clearance_Proxy_2026-10-28.json`; not a code, accessibility or room-fit determination.

### M53 — Audit the selected 610AA manufacturer's linked documents

Acceptance criteria:

- Open the selected SKU's public manufacturer page and inspect the linked specification and installation documents.
- Record document identifiers, dates, predecessor/current SKU status and dimension datums with direct source URLs.
- Keep predecessor dimensions out of current-SKU geometry, preserve B as unassigned, and do not use seller listings as the dimensional source of truth.

Current status: Complete. The current 610AA001.020 product page states 17-in height with seat and 12-in rough-in, but its “Spec Sheet” links a 2013 drawing for predecessor 211AA.104 (16-1/2-in rim, seat sold separately; 30-1/4 × 19 × 30-7/8 in nominal), and its installation guide is for the 211AA series. The selected SKU's plan dimensions remain unverified. See `Research/M06_Toilet_Options_2026-10-27.md`. Next: seek a current-SKU dimension drawing or complete model from a public manufacturer source; until then use only an explicitly labelled proxy in a disposable fit study and leave B unassigned.

### M54 — Pair predecessor toilet and lavatory research bodies in B

Acceptance criteria:

- Read the 8 source-documented lavatory body rectangles and M51 predecessor toilet envelope; preserve selected-D and report hashes.
- Screen both lavatory orientations in one explicitly hypothetical shared-wall arrangement: WC centerline 15 in from a side boundary, WC-to-lavatory centerline spacing 30 in, 15 in from WC centerline to nearest lavatory body edge, and 21 in front of each fixture.
- Check body non-overlap and gross containment for all combinations in pantry-side B; repeat deterministically in Windows PowerShell 5.1.
- Keep all products research-only, exact 610AA geometry unverified, and M-06 unassigned. State actual walls, door/swing, approach, privacy, installation/rough-in and services are not represented.

Current status: Complete as a same-wall lower-bound screen. `Tools/screen_m06_toilet_sink_gross_pair.ps1` checks 16 combinations from the existing source reports. Two Windows PowerShell 5.1 replays are byte-identical (SHA256 `DC8792ECA14CFFEB2FE4589EF6F7A303CCFCA15BE53602FCC70C68AF7E193ADB`). Modeled body-plus-front-strip extents are 53-3/4–58-1/2 in along the wall by 51-1/4 in deep, contained in B's 158 × 84 in gross bounds; minimum WC-centerline-to-sink-body-edge is 16-1/2 in and the smallest body-to-body gap is 7 in. This only shows that the nominal rectangles are not excluded by this assumed arrangement. Current toilet geometry, selected sink, walls, door, approach and service route remain unresolved. See `Research/M06_Sink_Candidates_2026-10-28.md` and the versioned JSON output.

### M55 — Compare steep-gable proportions on the unapproved test envelope

Acceptance criteria:

- Read the owner-follow-up proposal and require its existing 40 × 42 ft test envelope and roof inputs to remain unapproved/TBD.
- Calculate 10:12, 12:12 and 14:12 pitch proposals in both full-span ridge directions from the test-envelope dimensions; label every result unselected and measure rise only above a hypothetical eave datum.
- Emit a source-hashed JSON and common-scale SVG comparison deterministically under Windows PowerShell 5.1.
- State the roof footprint simplification, omitted wing/intersection geometry, loads, assemblies and structure; do not claim code compliance or reduce snow load based on pitch.

Current status: Complete as a conceptual massing comparison. `Tools/build_roof_pitch_massing_study.ps1` writes `roof-pitch-options.json` and `roof-pitch-options.svg` inside the separate owner-follow-up proposal. Two Windows PowerShell 5.1 runs produce byte-identical JSON (SHA256 `1670AD59CF293EB738DBFD275BC01728EF754D76B873B5DD34B6EB6075560A33`) and SVG (`2A780B8144341B39434B89B3C0CCF85C173DC09C2A52EFBDC9EDB1A8398A6C43`); the six rise calculations and SVG XML validate. Across the 40–42 ft full-span options, proposed rise above the hypothetical eave ranges 16 ft 8 in–24 ft 6 in. The source pitch/ridge remain TBD, selected D is unchanged, and no Revit roof or IFC was produced. These options illustrate massing only and do not establish roof dimensions, framing, snow/wind resistance, code compliance or construction readiness. See `Architecture/House_Design_Iteration_2026-10-28/README.md`.

### M56 — Recheck toilet/lavatory pairs in the owner-follow-up M-06 window

Acceptance criteria:

- Reuse the M54 16-pair predecessor-only screen without altering its source; verify the follow-up proposal, selected-D study and pair-report fingerprints agree.
- Read the smaller M-06-B window from the separate owner-follow-up proposal, independently convert its documented 10-1/3 × 7 ft gap to inches, and retest all 16 gross envelopes.
- Reproduce deterministic JSON under Windows PowerShell 5.1; keep current 610AA dimensions unverified, every lavatory unselected, and M-06 unassigned.
- State that room walls, door/swing, hall approach/privacy, installation, and services remain absent.

Current status: Complete as a cross-check of the separate schematic proposal. `Tools/screen_m06_pairs_against_followup_window.ps1` confirms the selected-D source hash matches both the follow-up proposal and M54 input, then tests all 16 inherited rectangles against the proposal's 124 × 84 in gross B. Two Windows PowerShell 5.1 runs are byte-identical (SHA256 `49CBB3B77C7FB8AF8D75230F48F77D00ED8D16E7BD6C5B62FEC039C3D756E53B`); all 16 fit with at least 65-1/2 in gross wall-direction margin and 32-3/4 in gross depth margin. Exact current toilet geometry is still unverified, the geometry is a bounding proxy, and M-06 B remains unassigned. See `Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json` and the owner-follow-up README.

### M57 — Screen porch attachment edges and dining route proxies

Acceptance criteria:

- Read current 12 × 10 ft porch dimensions from Architecture/Kitchen_Dining_Porch_Specs.md; reject stale M33 geometry unless its proposal and selected-D fingerprints match current inputs.
- Compare all four porch attachments to the dining room-block edge against every owner-follow-up room and the separate unassigned M-06-B window; report overlap and shell containment without relocating any room.
- Calculate a 36 in straight table-edge-to-porch threshold proxy for each edge and disclose any intersection with the table pull-back envelope; do not claim chair-independent circulation.
- Reproduce source-bound JSON under Windows PowerShell 5.1, preserve the intermediate M33 input, and leave selected D, M-06 assignment, Revit and IFC unchanged.

Current status: Complete as a schematic conflict screen. The first run correctly rejected the checked-in M33 report because its proposal fingerprint was stale. Two fresh M33 runs each pass 14/14 and match byte-for-byte across fit, checks, manifest and SVG. After correcting the east/west orientation, M57 passes 5/5 on two runs; report SHA256 436D558C28C1C1BA00F1FA06CADC989EFD3D79956FC4A9C689D8D326F21F7ECA. East clears current room blocks but places 50 sf beyond the unapproved shell; north overlaps pantry/M-06-B, south overlaps kitchen, and west overlaps living. Each 36 in route proxy intersects the uniform M33 pull-back envelope by 9 sf. M58 then tested an east-end 36 in passage against a proposed four-chair arrangement; see the next milestone. No location or route is selected. See the M57 README and retained source snapshot/report. No Revit or IFC edit was made.

### M58 — Test east porch route with four stationary dining chairs

Acceptance criteria:

- Consume only the source-fingerprinted, corrected M57 report and current M33 table candidate.
- Derive 60 × 36 in table and 18 × 20 in chair-body dimensions from the project specification; test an explicitly proposed four-chair arrangement with two chairs along each long side and none at table ends.
- Check a 36 in route from the table's east end to the dining boundary against each chair body, dining block, and the nominal 5 ft / 6 ft door intervals.
- Reproduce a source-bound report under Windows PowerShell 5.1. Keep the east porch, door and furniture arrangement unselected; do not claim human-occupied or accessibility clearance.

Current status: Complete as one furniture-route candidate. Tools/screen_m58_east_porch_chair_route.ps1 passes 9/9 on two runs, with byte-identical output SHA256 7F3589AB80021FBA736A2736937E9BA142A01C9340775D41D5554D93A573B42E. The 36 in wide × 36 in long route from the table's east edge to the room-block boundary lies within the 5 ft and 6 ft nominal opening intervals and has zero modeled overlap with four stationary 18 × 20 in chair-body rectangles. This explains how a path may pass through the broad 36 in pull-back buffer while avoiding chairs placed along the table's long sides. It does not account for seated people, moving chairs, actual door clear width/swing, wall build-up, threshold or porch furniture. The east porch still extends 50 sf beyond the unapproved shell. No Revit/IFC or selected-D change was made. See Architecture/M58_East_Porch_Chair_Route_2026-10-28/README.md.

M57 geometry correction (supersedes the preliminary M57 option results above): review found the initial east/west orientation incorrectly ran the 12 ft porch side along the dining edge. The corrected model matches the 10 ft porch side to the 10 ft east/west dining edge and projects 12 ft outward. Corrected report SHA256 is 436D558C28C1C1BA00F1FA06CADC989EFD3D79956FC4A9C689D8D326F21F7ECA. East clears the current room blocks but places 50 sf beyond the unapproved comparison shell; west overlaps living by 28.75 sf and clears M-06-B. North and south results are unchanged. All route proxies still intersect the dining table pull-back envelope by 9 sf. See the corrected M57 README and JSON; those files supersede the preliminary values above.

### M59 — Screen porch furniture and garden-door route

Acceptance criteria:

- Read porch furniture, chair, path, and door dimensions from the current project specifications and require the reviewed M58 report and proposal fingerprints.
- Place one documented 30 × 48 in table option and two explicitly assumed 18 × 20 in chair-body proxies inside the 12 × 10 ft porch, without overlap.
- Test a continuous 30 in path between centered dining-side and garden-side openings against the furniture, nominal French-door intervals, and the 3 ft exterior-door interval.
- Reproduce the JSON under Windows PowerShell 5.1. Keep all locations and furniture unselected; do not imply human, accessibility, code, or door-clearance verification.

Current status: Complete as one porch-furniture candidate. Tools/screen_m59_porch_furniture_route.ps1 passes 9/9 on two runs with identical JSON SHA256 FA29D73EAA7274B524D3CA4AED7AA7EB499E1644646B10A363F3AA4AA927BD27. The 30 in path comprises a west doorway connector, a north-side cross-porch lane, and an east exterior-door connector; it is clear of the 30 × 48 in table and two stationary 18 × 20 in chair-body rectangles. It fits the nominal 5 ft / 6 ft French-door intervals and nominal 3 ft exterior door. The proposal uses two right-angle turns and omits seated people, moving chairs, actual door swing/clear width, thresholds, site, grade and maneuvering. East porch still puts 50 sf outside the unapproved shell. No Revit, IFC, selected-D or M-06 change was made. See Architecture/M59_Porch_Furniture_Route_2026-10-28/README.md.

### M60 — Reproduce selected-D generator and revalidate preserved IFC evidence

Acceptance criteria:

- Verify the current branch and preserve the three known untracked Incoming RFAs; make no changes to selected-D source or Revit files.
- Run the documented selected-D PowerShell generator twice into ignored scratch directories; require 43/43 geometry checks, valid SVG XML, and byte-identical output artifacts.
- Independently rerun the selected-D IFC2X3 validator only against the preserved isolated copy whose named RVT matches the export fingerprint; require all checks to pass.
- Run the offline RevitPilot regression suite and record exact commands, evidence hashes, and remaining host/UI limitations.
- Record the owner's U-02/U-03 access clarification without implying that door geometry, code, egress, or privacy performance has been verified.

Current status: Complete for deterministic room-block generation and the preserved IFC/RVT pair. Both PowerShell runs pass 43/43 and produce identical hashes for all seven artifacts; all three SVGs parse. The isolated exact-backup copy passes 26/26 IFC checks, and the offline suite passes 37/37. The primary retained run's RVT mismatch remains documented and untouched. No Revit geometry or selected-D source changed. This evidence does not close native architectural geometry, door/egress coordination, M-06 fit/service routing, or manual Revit review.

### M61 — Recheck upper-suite comparison against latest owner access graph

Acceptance criteria:

- Confirm the retained M46 candidate is fingerprinted to the current selected-D study, owner-follow-up study, and room program.
- Independently rerun `Tools/validate_upper_suite_candidate.ps1` and verify both the required direct U-02 public route and private U-02/U-03 sequence, guest hall route, and two Jack-and-Jill links.
- Report the shell-size tradeoff and sampled route limits without promoting the proposal to selected geometry or a door/code finding.
- Preserve selected D, Revit files, IFC exports, and Incoming RFAs.

Current status: Complete as an independent recheck of an unapproved upper-suite comparison. The current source fingerprints match; the validator passes 111/111 checks and identifies a candidate with sampled shared-hall routes to U-01, U-02 and U-04 while retaining the owner-directed private link graph. The search candidate fits only within a 40 × 42 ft exploratory upper shell, larger than the selected-D 36 × 32 ft upper wing; the bounded search is not exhaustive. Door locations/swings, privacy, egress, structure, code and actual Revit geometry remain unresolved. No geometry was changed or adopted.

### M62 — Verify manufacturer-supported M-06 RFA retrieval path

Acceptance criteria:

- Check public manufacturer/partner documentation for a supported source of the owner-selected Champion PRO model's Revit family.
- Distinguish current 610AA001.020 evidence from predecessor 211AA documentation and RFAs.
- Do not sign in, create an account, submit a support request, or substitute a predecessor model for the selected fixture.
- Record the retrieval blocker and the source/hash steps required if an owner-supplied current family becomes available.

Current status: Complete as public-source research. American Standard material identifies ATS as its Revit/BIM partner; ATS documents that Revit downloads require an account and configured Spec or Project. No public evidence found that ATS currently offers 610AA001.020, so exact family availability remains unverified. No RFA or account action occurred. M-06 B remains unassigned pending verified current-product geometry and coordinated clearances/route.

### M63 — Restore M-06 family-intake validator agreement with manifest

Acceptance criteria:

- Run the family-intake validator against current Incoming files, quarantined sources, source URLs/hashes, and manifest dispositions.
- Diagnose any disagreement against the actual family intake record and latest Revit evidence; update the validator without changing family or manifest state.
- Rerun the validator and offline regression suite; preserve the untracked Incoming RFAs and all Revit files.

Current status: Complete. The validator's hard-coded Champion bowl disposition was stale (`received`/`queued`) while the manifest records the completed read-only inspection as `inspected-unapproved` with the corresponding intake evidence. The validator now expects the current state and passes for both manufacturer sources, four quarantined research candidates, the two RevitCity candidates, and the archived rejection. Offline RevitPilot suite passes 37/37. No family bytes, manifest data, Revit project, or selected-D source changed.

### M64 — Reconcile stale Evolution host-probe failure with current registered build

Acceptance criteria:

- Verify the current sandbox branch and preserve the three known untracked Incoming RFAs.
- Compare the failing intake report's diagnostic to the checked-out C# source and identify whether the report tests the current implementation.
- Verify the exact registered AddInId, repository-contained assembly path and SHA256 before any host-run attempt.
- Update operator documentation so stale evidence and the current host-validation blocker are unmistakable.
- Do not change family bytes, selected-D source, or Revit model state; do not claim Revit runtime success until a fresh report passes.

Current status: Complete for diagnosis and documentation; Revit runtime retest remains open. The retained report `.local/revit-pilot/family-intake/20261028T210959251Z/intake-manifest.json` failed at `No referenceable vertical planar face was found`, identifying the older raw-wall-geometry probe. Current `Pilot.cs` obtains a stable face reference using `HostObjectUtils.GetSideFaces`. The per-user manifest uses the authorized AddInId and repository-local `build-evolution-host-v4` DLL, SHA256 `0278CF2EABF981367DF679538DEDE1D3CB412E960AA1537F80046FC7A3ADC0E4`. Revit remains visually blocked by its trial welcome WebView; the close control belongs to a child window that CUA does not expose. The exact prompt cannot be checked, so the fresh intake and any permitted Load Once choice are pending. No registration, model, or RFA was changed.

### M65 — Refresh Connecticut code basis for the M-06 clearance screen

Acceptance criteria:

- Check the current Connecticut code edition and pending code-cycle status on official state sources.
- Keep any code-derived clearance values conditional on a detached one-family/IRC assumption, site and permit applicability.
- Bind the preliminary predecessor-only clearance report to the dated code-status source and reproduce it deterministically.
- Keep current-product geometry, door/approach, lavatory, service routing and M-06 assignment unresolved.

Current status: Complete as a preliminary source and arithmetic screen. Connecticut DAS identifies the 2022 CSBC as current for applications filed from 2022-10-01 and lists the 2021 IRC/IPC among adopted model codes; the planned 2026 code cycle is delayed pending Legislative Regulation Review Committee approval. The M-06 screen now records that dated status and its assumed detached one-family scope alongside the 2021 IRC R307.1 / P2705.1 references. Two PowerShell 5.1 runs match byte-for-byte (report SHA256 `9F03691DA0825E9AE0702D824460108A73AE6B89B7774CEB837350B29233423E`). B remains a gross unassigned search window; the fixture proxy is the 211AA predecessor, exact 610AA001.020 geometry is unverified, and door, route, lavatory, wall build-up and service checks remain open. This is not a compliance determination.

### M66 — Recheck toilet/lavatory research pairs in owner-follow-up B window

Acceptance criteria:

- Recalculate all existing source-screened predecessor-toilet and lavatory combinations against the smaller owner-follow-up pantry-side B rectangle.
- Carry the dated Connecticut code edition, detached one-family assumption and preliminary IRC sections into the generated evidence.
- Verify deterministic PowerShell output and report gross containment only; preserve B as unassigned.
- Keep exact current toilet geometry, lavatory selection, doors/approach, walls and plumbing route as open fit gates.

Current status: Complete as a gross-envelope recheck. The 124 × 84 in pantry-side B search rectangle contains all 16 inherited 211AA-predecessor / lavatory rectangular pairs under the report's hypothetical same-wall centerline and front-strip assumptions. Two PowerShell 5.1 runs match byte-for-byte (SHA256 `B3B813DBC80448E36279BF675970F87C61C139F73175C4237DE281D0BB181640`). The report carries the 2022 CSBC / 2021 IRC source basis and identifies the 2026 code cycle as delayed. It does not establish room interior clear dimensions, current 610AA geometry, product selection, door swing, user approach, service route or code compliance. B remains unassigned; see `Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json`.

### M67 — Screen retailer-reported current-SKU plan envelope

Acceptance criteria:

- Record public dimensions tied to the selected 610AA001.020 SKU with source quality and discrepancies explicit.
- Compare plan dimensions against the predecessor proxy; stop if the plan envelope differs rather than carrying forward stale pair results.
- Recalculate existing toilet/lavatory rectangles against the follow-up B gross window from the current-SKU seller-reported plan envelope, preserving the dated Connecticut code-screen assumption.
- Reproduce both reports byte-for-byte in independent Windows PowerShell 5.1 runs and keep B unassigned.

Current status: Complete as a secondary-source plan-envelope screen. The Wayfair listing names 610AA001.020 and reports 19 × 30.25 in plan dimensions, which match the 211AA predecessor proxy; it reports 31 in overall height and 16.5 in seat height, while American Standard reports 17 in seat height and links only predecessor-series dimensional literature. The independent PowerShell runs match byte-for-byte: retail-envelope report SHA256 `B208A125F906C50345F9C7C2EE939C852D48941D402C39EF1F576EDFBD3ADB9F`; recalculated pair report SHA256 `3EA13EDB4DD75EECA3AD07057141F468D57B7FD91B39572BD2DCE55738399422`. All 16 inherited lavatory rectangles remain contained within the 124 × 84 in gross search window under hypothetical same-wall assumptions. Retailer dimensions are not manufacturer-verified product geometry; vertical conflict remains unresolved. No room walls, door/approach or service route are represented. B remains unassigned and no compliance or accessibility conclusion follows. See `Research/M06_Toilet_Options_2026-10-27.md` and `Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json`.

### M68 — Repeat selected-D geometry and exact-lineage IFC checks (2026-10-29)

Acceptance criteria:

- Regenerate the unchanged owner-selected D source twice into ignored scratch directories; require all 43 geometry checks, valid SVG XML and byte-identical seven-file outputs.
- Re-run the selected-D IFC2X3 validator against the preserved isolated copy only, requiring its named RVT fingerprint to match the export evidence and every check to pass.
- Run the RevitPilot offline regression suite; keep selected-D source, Revit projects, exports and Incoming RFAs unchanged.
- Report Revit host/UI limitations without treating the space-planning package as a physically coordinated house.

Current status: Complete for this offline verification pass. The selected-D PowerShell generator passed 43/43 in `.local/revalidation/M68-selected-d-a/` and `.../M68-selected-d-b/`; all seven outputs matched byte-for-byte and all three plan SVGs passed the generator's XML gate. The checked-in `study.json` remains SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. The independent IFC validator passed 26/26 with zero errors against `.local/revalidation/M48-selected-d-exact-fingerprint/`; both the isolated named RVT and `.0001.rvt` hash to `83675C7229087E1C8D812DDFE31C0A46C0F9229AC9F9240DE28F12906AFE2D9E`, and the IFC hash is `5B65FAACBF596ADAF6E7B2B00A47397B965E1F9507C67CEFED13729BEA520425`. The offline RevitPilot suite passed 37/37. No RVT, IFC, source study or RFA was changed. Revit was not exposed as a targetable window on 2026-10-29; no host operation or Load Once choice was made. This verifies the preserved isolated export only; a separate retained run still has the previously documented named-RVT mismatch. The model remains a 21-space room-boundary study without walls, floors, stairs, doors, roof, structure or coordinated MEP.

### M69 — Bound M-06 approach-depth sensitivity to current Connecticut code status

Acceptance criteria:

- Recheck the Connecticut published code edition and pending 2026 cycle on official DAS pages.
- Compare the seller-reported selected-SKU projection against B's 84 in gross depth under a conditional 21 in front-clearance screen and a separate optional 48 in usability sensitivity.
- Preserve the bathroom specification's explicit instruction not to borrow full-bath clearances as M-06 criteria; label the 48 in case optional and unadopted.
- Hash every controlling local input, reproduce the report in two independent PowerShell 5.1 runs, and keep M-06 B unassigned with no fit conclusion.

Current status: Complete as a sensitivity screen only. The official DAS status was rechecked on 2026-10-29 and recorded in `Research/2026-10-28_Connecticut_M06_Clearance_Screen.md`. For the 124 × 84 in gross search window, retailer-reported 30.25 in toilet projection plus the conditional 21 in preliminary IRC screen totals 51.25 in, leaving 32.75 in gross depth. The optional 48 in comparison totals 78.25 in, leaving 5.75 in gross; that comparison is not an M-06 requirement and is not adopted. Two independent PowerShell runs match byte-for-byte (report SHA256 `EAAB72E2D28ECCF0476FD582715FE628F0B3CA6444980993EC94556E9370F533`). This arithmetic excludes wall build-up, lavatory geometry, doors, approach, and service routes; current product geometry and site-specific code applicability remain unresolved. B remains unassigned. See `Research/M06_Approach_Depth_Sensitivity_2026-10-29.json`.
