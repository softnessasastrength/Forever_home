# Architectural BIM pipeline plan

Updated: 2026-10-31
Status: Selected-D study SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`; two fresh PowerShell 5.1 runs pass 43/43 with seven byte-identical outputs. The retained matched selected-D Revit 2027.3 / IFC2X3 package passes 26/26 with zero errors, three storeys, 21 source-matching spaces and clean schema. M192 tests one rotated dining arrangement with four 36-in pull-out proxies; its 36-in route does not reach the porch (7/7 checks; 5,423 reachable grid nodes; nearest point 9 ft). M193 derives 7 x 3 ft and 6 x 3 ft island candidates that fit the 14 x 12 ft clear kitchen rectangle arithmetically with the documented 24-in base, 12-in overhang and 42-in aisle proxies (9/9 checks; byte-identical replay). Neither is an integrated kitchen/dining/porch layout; route, wall/opening placement, appliance operation, stool geometry and tolerance remain open. A non-scaled patio concept follows the specified porch exit without inventing site dimensions. User's end state is a coherent, native Revit house model and architect-review packet; today's IFC remains a 21-space room study with empty construction categories. Upper-suite layouts and steep-gable roof cases remain exploratory; M-06/B remains unassigned; Revit family host inspection is pending. No code-compliance, structural-safety, certification, permit or construction-readiness claim is made.

## Owner outcome — architect-reviewable native Revit model

The intended end state is a coherent, documented **native Revit house model** and review packet that an architect can assess without reconstructing the design intent from disconnected sketches. It is a design-review handoff, not a claim of professional approval or permit readiness.

Acceptance gates:

1. **Resolved program and room blocks:** all owner-approved spaces are coordinated across lower, main and upper levels; area schedules expose variances; selected choices are separated from proposals and unresolved decisions.
2. **Architectural geometry:** the RVT contains coordinated native levels, room-bounding walls, floor edges/openings, stairs/landings, doors, windows, roof mass/planes and exterior connections as each is designed. No major house element is represented only by a room-boundary box at handoff.
3. **Fit and circulation:** product-backed kitchen, bath, furniture and door geometry is checked in context; the principal routes, approaches, thresholds and door swings are shown; unresolved dimensions remain explicitly labeled.
4. **Review presentation:** reproducible plans, elevations, sections and 3D views; room/door/window/finish schedules where specified; a concise issue/trade-off register; clear views of lower/main/upper relationships and roof form.
5. **BIM exchange and reproducibility:** cleanly saved RVT derivatives and backups, validated IFC export(s), source fingerprints, commands, logs and independent geometry checks reproduce from documented inputs.
6. **Professional boundary:** structural design, site-specific code applicability, energy/HVAC, drainage, utilities, life-safety and permit decisions are identified for the appropriate licensed reviewers. The handoff makes no claim that those reviews are complete.

The current selected-D RVT/IFC satisfies only the room/space schedule gate: its IFC has 21 spaces on three storeys but no authored construction categories. It is a validated baseline, not the architect-reviewable end state. The next step is to finish source-bound kitchen/open-plan candidates before authoring disposable native Revit wall/opening geometry.

Upper-suite work remains exploratory. M157's exact command replays against current M37 source with identical package hashes; M158 retains two bounded joint-bedroom-outline room-block candidates, one meeting the sampled public/private route proxy. M159 shows at least two bedroom-capable room blocks at an ideal eave in every tested roof case. No upper-shell dimension, room layout, wall, opening, pitch, ridge, eave or house design is selected. M-06/B remains unassigned. M165 executed the six-option M83 Revit/IFC comparison twice with the exact manifest-bound local DLL; both IFC2X3 exports pass 21/21, and their normalized geometric bounds and areas match. Revit is currently at Home with no model open; the current add-in load is unverified. No code-compliance, structural-safety, certification, permit or construction-readiness claim is made.
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

Status: **M-02 geometry and IFC fit gate complete for an isolated study; downloaded family/product approval remains open.** RevitCity 19967's preserved trial fails its fit gate: its 8 x 4 ft surface sits about 1 in east/north of the source origin and exports at z=1.1401–1.1811 ft. RevitCity 21015 conflicts with the appliance-free concept (fixed 1000 mm width, integrated cooktop/oven and stools). The RevitCity 7216 modules fit the source-derived 8 x 4 ft plan, and the current Revit derivative contains four 4 x 2 ft casework modules plus a generic unassigned-finish 8 x 4 ft top. The host command report records a 34.5 in physical casework body and 1.25 in top (35.75 in actual, nominally 36 in). Revit audit `20261027T204528345Z` and IFC export `20261027T204553821Z` share saved-RVT SHA256 `01a38eb274b5170d75834d0fce29e2da31e0e45f764d9ed2fac71670a4f0ef1f`; independent validation passes 15/15 checks, including IFC2X3 schema, 21 spaces/three storeys, physical geometry, module bounds, top bounds and overall assembly. The exact tested DLL build and command report are recorded in `PROGRESS.md`. Finish split, seam, supports, overhang, finish and fabrication remain unresolved; 42 in circulation cannot be claimed until perimeter counters and obstacles are modeled. The family and placeholder remain study geometry, not an approved product or shop drawing. No structural, code-compliance or construction-readiness claim is made.

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

Current status: Complete as a cross-check of the separate schematic proposal. `Tools/screen_m06_pairs_against_followup_window.ps1` confirms the selected-D source hash matches both the follow-up proposal and M54 input, then tests all 16 inherited rectangles against the proposal's 124 by 84 in gross B. Two Windows PowerShell 5.1 runs are byte-identical (SHA256 `49CBB3B77C7FB8AF8D75230F48F77D00ED8D16E7BD6C5B62FEC039C3D756E53B`); all 16 fit with at least 65-1/2 in gross wall-direction margin and 32-3/4 in gross depth margin. Exact current toilet geometry is still unverified, the geometry is a bounding proxy, and M-06 B remains unassigned. See `Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json` and the owner-follow-up README.

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

Current status: Complete as a gross-envelope recheck. The 124 by 84 in pantry-side B search rectangle contains all 16 inherited 211AA-predecessor / lavatory rectangular pairs under the report's hypothetical same-wall centerline and front-strip assumptions. Two PowerShell 5.1 runs match byte-for-byte (SHA256 `B3B813DBC80448E36279BF675970F87C61C139F73175C4237DE281D0BB181640`). The report carries the 2022 CSBC / 2021 IRC source basis and identifies the 2026 code cycle as delayed. It does not establish room interior clear dimensions, current 610AA geometry, product selection, door swing, user approach, service route or code compliance. B remains unassigned; see `Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json`.

### M67 — Screen retailer-reported current-SKU plan envelope

Acceptance criteria:

- Record public dimensions tied to the selected 610AA001.020 SKU with source quality and discrepancies explicit.
- Compare plan dimensions against the predecessor proxy; stop if the plan envelope differs rather than carrying forward stale pair results.
- Recalculate existing toilet/lavatory rectangles against the follow-up B gross window from the current-SKU seller-reported plan envelope, preserving the dated Connecticut code-screen assumption.
- Reproduce both reports byte-for-byte in independent Windows PowerShell 5.1 runs and keep B unassigned.

Current status: Complete as a secondary-source plan-envelope screen. The Wayfair listing names 610AA001.020 and reports 19 × 30.25 in plan dimensions, which match the 211AA predecessor proxy; it reports 31 in overall height and 16.5 in seat height, while American Standard reports 17 in seat height and links only predecessor-series dimensional literature. The independent PowerShell runs match byte-for-byte: retail-envelope report SHA256 `B208A125F906C50345F9C7C2EE939C852D48941D402C39EF1F576EDFBD3ADB9F`; recalculated pair report SHA256 `3EA13EDB4DD75EECA3AD07057141F468D57B7FD91B39572BD2DCE55738399422`. All 16 inherited lavatory rectangles remain contained within the 124 by 84 in gross search window under hypothetical same-wall assumptions. Retailer dimensions are not manufacturer-verified product geometry; vertical conflict remains unresolved. No room walls, door/approach or service route are represented. B remains unassigned and no compliance or accessibility conclusion follows. See `Research/M06_Toilet_Options_2026-10-27.md` and `Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json`.

### M68 — Repeat selected-D geometry and exact-lineage IFC checks (2026-10-29)

Acceptance criteria:

- Regenerate the unchanged owner-selected D source twice into ignored scratch directories; require all 43 geometry checks, valid SVG XML and byte-identical seven-file outputs.
- Re-run the selected-D IFC2X3 validator against the preserved isolated copy only, requiring its named RVT fingerprint to match the export evidence and every check to pass.
- Run the RevitPilot offline regression suite; keep selected-D source, Revit projects, exports and Incoming RFAs unchanged.
- Report Revit host/UI limitations without treating the space-planning package as a physically coordinated house.

Current status: Complete for this offline verification pass. The selected-D PowerShell generator passed 43/43 in `.local/revalidation/M68-selected-d-a/` and `.../M68-selected-d-b/`; all seven outputs matched byte-for-byte and all three plan SVGs passed the generator's XML gate. The checked-in `study.json` remains SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. The independent IFC validator passed 26/26 with zero errors against `.local/revalidation/M48-selected-d-exact-fingerprint/`; both the isolated named RVT and `.0001.rvt` hash to `83675C7229087E1C8D812DDFE31C0A46C0F9229AC9F9240DE28F12906AFE2D9E`, and the IFC hash is `5B65FAACBF596ADAF6E7B2B00A47397B965E1F9507C67CEFED13729BEA520425`. The offline RevitPilot suite passed 37/37. No RVT, IFC, source study or RFA was changed. Revit was not exposed as a targetable window on 2026-10-29; no host operation or Load Once choice was made. This verifies the preserved isolated export only; a separate retained run still has the previously documented named-RVT mismatch. The model remains a 21-space room-boundary study without walls, floors, stairs, doors, roof, structure or coordinated MEP.

### M69 - Bound M-06 approach-depth sensitivity to current Connecticut code status

Acceptance criteria:

- Recheck the Connecticut published code edition and pending 2026 cycle on official DAS pages.
- Compare the seller-reported selected-SKU projection against B's 84 in gross depth under a conditional 21 in front-clearance screen and a separate optional 48 in usability sensitivity.
- Preserve the bathroom specification's explicit instruction not to borrow full-bath clearances as M-06 criteria; label the 48 in case optional and unadopted.
- Hash every controlling local input, reproduce the report in two independent PowerShell 5.1 runs, and keep M-06 B unassigned with no fit conclusion.

Current status: Complete as a sensitivity screen only. The official DAS status was rechecked on 2026-10-29 and recorded in `Research/2026-10-28_Connecticut_M06_Clearance_Screen.md`. For the 124 by 84 in gross search window, retailer-reported 30.25 in toilet projection plus the conditional 21 in preliminary IRC screen totals 51.25 in, leaving 32.75 in gross depth. The optional 48 in comparison totals 78.25 in, leaving 5.75 in gross; that comparison is not an M-06 requirement and is not adopted. Two independent PowerShell runs match byte-for-byte (report SHA256 `EAAB72E2D28ECCF0476FD582715FE628F0B3CA6444980993EC94556E9370F533`). This arithmetic excludes wall build-up, lavatory geometry, doors, approach, and service routes; current product geometry and site-specific code applicability remain unresolved. B remains unassigned. See `Research/M06_Approach_Depth_Sensitivity_2026-10-29.json`.

### M70 - Refresh and replay steep-gable study against current Connecticut status

Acceptance criteria:

- Recheck official Connecticut DAS pages for the currently published code edition and delayed next code cycle; preserve municipality/site/permit uncertainty and the IRC/IBC distinction.
- Make the M36 report's `checked_date` derive from the latest dated recheck in its source note instead of a stale hard-coded date.
- Regenerate M36 and M38 in two separate scratch directories; compare JSON, checks, SVG, and manifest byte-for-byte and validate the checked-in SVG/JSON artifacts.
- Keep all pitch ratios illustrative, the 40 x 42 ft envelope a test envelope, and all roof/eave/ridge/site/load/assembly inputs unassigned.

Current status: Complete for source refresh and reproducible massing comparisons. Connecticut DAS was rechecked on 2026-10-29: its pages still identify the 2022 CSBC for permit applications filed from 2022-10-01 and say the planned 2026 effective date is delayed pending Legislative Regulation Review Committee approval. M36 now reads the latest status-recheck date from its research note. Two independent PowerShell 5.1 runs regenerated eight M36/M38 artifacts byte-for-byte; M36 passed 11/11 checks and M38 passed 12/12. The M36 report records `checked_date` 2026-10-29. M38 still compares six illustrative combinations: 8:12, 10:12 and 12:12 across 20 ft and 21 ft half-runs. The 12:12 case implies 20 ft / 21 ft rise above hypothetical eaves; pitch, orientation, eave/ridge elevations and roof geometry remain unselected. No loads, structure, code compliance, permit or construction-readiness conclusion is made.

### M71 - Show roof-area consequence alongside illustrative pitch rise

Acceptance criteria:

- Extend the M38 comparison drawing so each unselected pitch/orientation case shows both ridge rise above the hypothetical eave and the two-plane geometric surface area.
- Keep the 40 x 42 ft source-derived envelope and 8:12, 10:12, and 12:12 ratios explicitly illustrative; preserve zero overhangs and omitted intersections/assemblies as limitations.
- Regenerate the four M38 artifacts in two independent PowerShell 5.1 runs; require byte-identical outputs, 12/12 existing checks, parseable SVG, and visible limitation that area is not a takeoff or cost estimate.
- Do not select pitch, roof orientation, roof geometry, material quantity, or cost.

Current status: Complete as a design-comparison graphic. The M38 SVG now shows rise plus theoretical two-plane area and percent above projected footprint for all six comparisons. At 8:12 the plane-area proxy is about 2,019 sf (+20%); at 10:12 about 2,187 sf (+30%); at 12:12 about 2,376 sf (+41%), across a 1,680 sf test footprint. Two independent PowerShell 5.1 runs reproduce all four generated artifacts byte-for-byte; the generator passes 12/12, SVG parses, and the illustration labels area as a non-takeoff comparison. No pitch or orientation is selected. See `Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/README.md` and `steep-gable-options.svg`.

### M72 — Screen island seating depth against owner inputs and NKBA guidance

Acceptance criteria:

- Read stool count/seat-height range, seating overhang, island size, and accepted counter-height arithmetic from the repository's kitchen specification and island decision.
- Compare those inputs with the published NKBA guideline for a nominal 36 in counter; identify it as a design recommendation, not code or an owner-approved change.
- Compute two-seat frontage and conditional knee-depth difference; keep actual stool, support section, seating pull-back and room route explicitly unresolved.
- Produce source-fingerprinted PowerShell JSON/SVG, pass all named checks, reject external output paths, and reproduce outputs byte-for-byte twice.

Current status: Complete as a source-bound design screen. Owner inputs specify a 96 in seating edge, two stools and 12 in seating-side overhang; the selected counter build-up is 35.75 in and accepted as nominal 36 in. NKBA Kitchen Planning Guideline 9 recommends 24 in frontage and 15 in knee-space depth per diner at a 36 in counter. Two frontage allowances total 48 in, leaving 48 in of the edge. The overhang is conditionally 3 in below the knee-space recommendation only if the overhang equals the unobstructed knee depth; the island section/support is not documented. Two PowerShell 5.1 runs reproduced the JSON byte-for-byte (SHA256 `79235A1455370DF3CCDC08387CE0FE0648FF0B61102FAB531A62F034E78C9E30`); all 9/9 checks pass and the SVG parses. The report changes no owner dimension and establishes no product fit, code compliance, accessibility or fabrication adequacy. See `Research/Kitchen_Island_Seating_Clearance_2026-10-29.md`.

### M73-M76 - Upper-suite access search and shell sensitivity

Acceptance criteria:

- Apply the owner-directed access graph: U-02 has direct hall arrival; U-03 is private through U-02 only; U-04 retains guest hall access; both Jack-and-Jill links through U-06 remain.
- Search the selected-D 36 x 32 ft upper test wing without changing that source, and distinguish incomplete search results from proof of infeasibility.
- Test search-strategy variations and preserve their limits; independently validate the retained M46 room arrangement against explicitly hypothetical envelope variants.
- Fingerprint the M46 candidate and selected-D sources, reproduce the sensitivity report twice, and keep selected dimensions unassigned/unmodified.

Current status: Complete as bounded exploratory analysis, not as an upper-floor design. The selected-wing M37 search and balanced-root search both reach their 4,000-node limits without a complete candidate satisfying U-01, U-02 and U-04 public reachability. The deferred early-route-prune strategy produces zero layouts; this is a failed search heuristic, not evidence that the plan is impossible. The existing M46 candidate in an unapproved 40 x 42 ft shell passes the independent route validator in six of ten sampled shell tests. The smallest passing case sampled is 38.333333 x 40 ft (1,533.333 sf), 381.333 sf or 33.1% above the selected-D 36 x 32 ft upper test wing. The sample is not exhaustive and does not authorize a shell expansion or dimension change. No tested proxy represents actual doors, wall assemblies, privacy, egress, stair geometry, structure, MEP or code. See `Tools/screen_m76_upper_suite_candidate_envelope.ps1` and `Research/M76_Upper_Suite_Envelope_Sensitivity_2026-10-29.json`.

### M77 - Preserve reproducibility across Revit IFC export sessions

Acceptance criteria:

- Record current Autodesk guidance on saved versus in-session IFC export setups and current Revit 2027 IFC4 Reference View availability.
- Preserve the verified IFC2X3 lineage; do not change export setup, install/update an add-in, or replace the baseline without an isolated derivative and exact-lineage validation.
- When Revit is controllable, inspect the installed exporter/add-in and available setup in a disposable project copy; use a named saved setup for any repeat export and keep optional IFC4 Reference View comparative.
- Re-run the independent IFC validator against the exact saved RVT paired with each export; record export logs and hashes.

Current status: Autodesk documentation recheck complete; host-dependent execution pending. The 2026 Revit help says custom named setups are saved with their project, whereas `<In-Session Setup>` changes are not saved between sessions. Autodesk support states that IFC4 Reference View Exchange Requirement selection is available in Revit 2025-2027 after the latest updates and IFC add-in. This workstation's availability has not been verified, and the project baseline remains IFC2X3. Revit 2027 is currently minimized and not targetable through this session's computer-use bridge. See `Research/Revit_IFC_2027_Exporter_Notes_2026-10-28.md`.

### M78 - Search the owner-authorized 38.333333 x 40 ft upper-shell test

Acceptance criteria:

- Accept only the owner-authorized M76-derived test rectangle as an additional M37 shell override; keep other override values rejected and label this case hypothetical/unselected in the report and drawing.
- Preserve all selected-D room dimensions, owner access links, lift/landing reservations and documented room-area ranges.
- Run the bounded search twice in isolated directories; compare all four artifacts byte-for-byte; require generator integrity checks and independent candidate validation against the stated test envelope.
- Retain limitations for route sampling, doors, walls, privacy, egress, stairs, structure, services, code and Revit/IFC validation.

Current status: Complete as an exploratory upper-suite room-block study. Two PowerShell 5.1 runs found the same candidate, passed 28/28 generator checks, and reproduced all four artifacts byte-for-byte. The candidate preserves selected-D room sizes and the owner-directed access graph, and the independent validator passes 112/112 checks against the 38.333333 x 40 ft hypothetical test rectangle. The search remains incomplete at its 4,000-node limit; this result is a candidate, not an exhaustive minimum or approved shell. See `Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/README.md`.

### M79 - Review U-02 hall arrival against the source stair approach

Acceptance criteria:

- Fingerprint the M78 winner and selected-D source; derive a north-edge nominal reservation from the source 3.5 ft door-matrix value and the M78 route/landing-approach centerline.
- Verify the test segment lies on the U-02 north edge and retains private-only U-03 access.
- Generate deterministic JSON and SVG with exact limits; never describe the nominal interval as a real opening or door specification.
- Record disposable Revit review, actual door/wall geometry, swing, privacy and code assessment as outstanding.

Current status: Complete as a schematic alignment check. The 3.5 ft nominal test interval on U-02's north edge is x=17.416667..20.916667 ft at y=27.5 ft, centered over the selected-D 4 x 4 ft stair-approach proxy at (19.166667,30) ft. Ten checks pass; two PowerShell 5.1 runs reproduce JSON and SVG byte-for-byte. No wall or door is modeled, and M78's 38.333333 x 40 ft test envelope is still unselected. See `Tools/screen_m79_u02_hall_approach_slot.ps1` and `Architecture/M79_U02_Hall_Approach_Slot_2026-10-29/README.md`.

### M80 - Validate the incoming toilet-family host probe in Revit 2027

Acceptance criteria:

- Preserve the three owner-supplied Incoming RFA files and their source hashes; load and inspect them only in a new disposable Revit project.
- Use a basic temporary wall for the documented Evolution hosted-placement probe; report family/type identity, local solid bounds, transformed hosted extents and host identity separately.
- Pass the PowerShell host-output gate and family-intake provenance validator; do not infer fixture pairing, clearance, room fit, service routing or product approval.

Current status: Complete as a disposable family-geometry and host-orientation probe. Revit 2027 run `20261030T195404237Z` records five family results and 14 measured types. The output gate passes **101/101** checks, including the Evolution 0467.400 temporary basic-wall placement at 17.5052 in projection x 22 in width x 34.25 in height; source-family geometry reports 3 positive-volume solids. Family-intake provenance and the full offline suite pass. The three Incoming RFAs remain untouched and unapproved. These measurements do not establish an assembled toilet, room fit, clearance, service path, code compliance or product selection.

### M81 - Generate and validate the hypothetical M78 upper-suite Revit/IFC study

Acceptance criteria:

- Consume only the archived M78 search and selected-D source with matching source fingerprints; preserve the selected-D source and all Incoming RFAs.
- In a separate Revit project, create the selected source-level datum, seven room-boundary spaces and a plan-only hypothetical shell outline; create no construction geometry or assign M-06.
- Save the RVT before exporting IFC2X3, tie both files to an exact saved-model fingerprint, and independently validate schema, storey, space identity, area, bounds, shell containment and absent physical construction entities.
- Document the reproducible build and validator commands, evidence hashes, manual-review limits and outstanding next steps.

Current status: Complete as a room-boundary and IFC2X3 pipeline milestone. The Revit 2027.3.0.28 host command created `.local/revit-pilot/upper-suite/20261030T200906834Z/`; the derivative was reopened and visually reviewed in Revit. Independent `validate_upper_suite_ifc.py` passes **32/32** checks, including the clean IFC2X3 schema, one upper storey at 5 ft, seven source-matching spaces, areas and world-coordinate plan bounds, room-block containment inside the local hypothetical envelope, and zero walls, slabs, stairs, doors or windows. Two validation runs produce byte-identical reports (SHA256 `90A86A2C56B8C2197DD5AD98BB86C416A7926980564FFE01AF209D61581164DF`). Saved RVT SHA256 is `28BC319633C2EE96711896203355163D49469A64CC265F3540E449D1E6844995`; IFC SHA256 is `87478B8D794C88904AA4532BA5B96025F488AB9EFFED54E23B3F39B01A82C96`. RevitPilot builds with **0 errors** and two pre-existing `MSB3277` Revit API reference warnings; its per-user manifest retained the authorized AddInId and its previous copy is backed up in ignored `.local/revit-pilot/registration-backups/20261030T160652/`. The IFC file is a space-study export, not an architectural building model, compliance finding or construction document. See the M78 README and `Tools/RevitPilot/README.md` for reproduction.

### M82 - Advance the unresolved M-06 fit gate without assigning room B

Acceptance criteria:

- Independently pair any proposed toilet bowl/tank/seat only from verified family types and manufacturer product documentation; preserve source RFA files.
- Compare measured assembled geometry with a clearly cited Connecticut code/clearance basis, door and approach geometry, and a plausible service route before considering a room location.
- Keep room B unassigned when any required product geometry, applicable clearance basis, door/approach or service evidence remains unresolved.
- Make no M-06 baseline or selected-D edits unless later explicitly authorized by the owner.

Current status: Partially complete. The official public LIXIL 211AA104.020 Revit link resolves to the exact SHA256 of the existing Incoming predecessor RFA. Revit 2027.3 read-only inspection and the matching family-intake manifest identify that file as the `5325.010` elongated toilet-seat family only (14.2591 x 17.0527 x 1.4658 in; two solids); the public product page lists the bowl and tank as separate components. ATS's anonymous US-catalog product search for exact current SKU `610AA001.020` returned zero products on 2026-10-30; no sign-in or account workflow was used. These sources do not supply the complete predecessor assembly or exact selected-product geometry. The 101/101 M80 intake gate passes. Connecticut DAS status was rechecked 2026-10-30; the 2022 CSBC / 2021 model-code basis remains the published current state reference while the next cycle is delayed, but project permit/site applicability is unknown. M82 remains open: no full toilet pairing, room-B assignment, door/approach fit, or service path is supported. See the dated M82 entry in `PROGRESS.md` and `Research/M06_Toilet_Options_2026-10-27.md`.

### M83 - Compare steep-gable roof massing on the hypothetical upper-shell study

Acceptance criteria:

- Preserve selected D and the validated M78 source study; use the 38.333333 x 40 ft envelope only as an explicitly hypothetical test outline.
- Create a separate Revit 2027 derivative containing labelled 8:12, 10:12 and 12:12 gable massing variants, each with ridge parallel to either test-shell axis; use a local relative eave datum, zero overhang, and no invented wall height or structural assembly.
- Independently check the six roof spans, ridge rises, projected extents and idealized two-plane surface areas against the PowerShell source calculations; record any tessellation/geometric tolerance.
- Export IFC2X3 from the saved derivative, tie the export to the exact RVT fingerprint, and validate schema, roof option identities, extents and intended entity classification.
- Keep pitch, orientation, eave/ridge elevation, roof build-up, structure, loads, snow/drift analysis, site/code applicability and construction details unselected or explicitly open. Do not claim code compliance or structural adequacy.

Current status: Complete for source generation and the tested Revit/IFC comparison workflow. After the Connecticut research note changed, the PowerShell 5.1 generator was replayed in two isolated folders and at its documented destination; all three runs pass 13/13 and reproduce all four artifacts byte-for-byte (roof JSON `DB8BD3EB591CB936B8811332F34EE1FA86745D3F167CA4480E44A871DA803ED2`; checks `1E23B0C7C7AD0B2300BAE21034BB29CE628153C920AA42C98875BC7D18384976`; manifest `1A877A2823FB07805B15A3AA8DE3C247C211FE0A87CE781C52BF5A64FC0A5BFB`; SVG `9C5EA4DBBB297A530463774C610CE8D1C81E18E7FA1135A414BCDBC632981219`). Revit 2027.3 loaded project-local DLL SHA256 `042BD6A602B6E970A2E7FBFA9C1DC08C22580AD2015A9227DEA85F13B30D5EC3` by the authorized one-time choice. Host runs `.local/revit-pilot/roof-massing/20261031T104347203Z/` and `20261031T104806592Z/` each created six open-mesh DirectShapes and exported IFC2X3. The independent validator passes 21/21 on both, with clean IFC2X3 schema, zero schema issues, six proxy meshes, zero native roofs/walls/slabs/doors/windows/stairs, and matching world bounds and triangulated areas; normalized geometry records match across runs. Report hashes: `F0EAAC76625EAA898BA6E22FCFAF693C91D6BE4BB8169C31D4E82CF584938F59` and `B4A3239F653DC0FD2F220453E87B6977436D265D4C28981BD3EA21EC10E2743F`. The validator was corrected to request project units from IfcOpenShell and associate Revit IFC tags with source DirectShape IDs; tests cover both. No roof pitch, ridge, datum, thickness, assembly or building dimension is selected.

### M84 - Reproduce and revalidate the checked-in selected-D model

Acceptance criteria:

- Generate selected-D source artifacts twice into isolated ignored directories; require all source geometry checks to pass and all seven output files to match byte-for-byte.
- Compare regenerated and checked-in selected-D study content; report any drift without copying over or editing the selected-D baseline.
- Validate a fresh Revit 2027.3 RVT/IFC2X3 pair against the current selected-D source, exact saved-model fingerprint, 3 levels, 21 spaces, room identities/areas/levels/plan bounds and empty physical-construction classes.
- Preserve existing historical mismatch evidence, Incoming RFAs and all remote state.

Current status: Complete for source reproduction and the current room-study export. Runs in `.local/revalidation/selectedD-source-a/` and `selectedD-source-b/` each pass **43/43** checks, parse all three SVGs, and match all seven artifacts byte-for-byte. A recursive JSON comparison finds no geometry or other study-content drift; only the fingerprint values for `Requirements/Room_Program.md` and `Decisions/2026-10-27_Selected_Architectural_Direction_D.md` differ in the regenerated output. No selected-D source file was changed. The fresh host package `.local/revit-pilot/selected-d/20261030T002652845Z/` binds source SHA256 `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`, saved RVT SHA256 `c6ced6acd0e59e49ea0e9821153204fc81ed6cede2fcd4f4d7e387c0acefd6d0`, and IFC2X3 SHA256 `56251f4754567c78ebb657ec2b99894958c15ef73663f737742f3f36a8472f6f`. Two validator reports match byte-for-byte (SHA256 `449B98D7720BB10DCD53BA999A99AA6DD207950783C43EB3CFCA0800085C079B`); **26/26** checks pass with zero errors. The IFC contains the expected three storeys and 21 spaces with matching identities, areas, levels and profile/plan bounds; native walls, slabs, stairs, doors and windows remain intentionally absent. This is a validated space-study model, not a complete building model.

### M85 - Audit the current 610AA manufacturer specification link without assigning room B

Acceptance criteria:

- Resolve the exact specification link exposed by the current manufacturer page for owner-selected SKU 610AA001.020; record the linked document's own model designation and revision rather than attributing predecessor data to the current SKU.
- Compare manufacturer dimensions only at their documented scope and precision; do not synthesize a current product envelope from predecessor parts, generic families, or retailer data.
- Preserve Incoming RFAs and selected-D/M-06 baselines. Keep room B unassigned until actual selected-product geometry, applicable clearance basis, door/approach and plausible service routing are supported together.
- Record exact URLs, the evidence boundary and remaining retrieval needs in `Research/M06_Toilet_Options_2026-10-27.md` and `PROGRESS.md`.

Current status: Complete as a manufacturer-document provenance check; the M-06 fit gate remains open. The current 610AA product page identifies the selected SKU but its live Spec Sheet link resolves to a 211AA.104 predecessor sheet (revised 9/13), which specifies predecessor components and nominal dimensions only. The linked drawing cannot establish exact 610AA geometry. No family, model, or room assignment was changed. See M85 in `PROGRESS.md` and the dated research entry.

### M86 - Cross-check current M-06 manufacturer links and stock signal

Acceptance criteria:

- Inspect only public documents linked directly from the current 610AA product page; identify their model series, date/revision, and any component/supply statements.
- Record page-displayed availability as a dated observation, not as proof of discontinuation or universal availability.
- Preserve selected-D, owner-supplied Incoming RFAs and B's unassigned status; do not infer current geometry or services from predecessor instructions.

Current status: Complete as a public-source cross-check. The linked installation manual is dated 2019 and covers 211AA/211BA/211CA series; the current 610AA page displayed “Out of stock” on 2026-10-30. Neither observation resolves exact current SKU geometry, verified purchasing availability, or a service route. See M86 in `PROGRESS.md` and the dated M-06 research entry.

### M87 - Retrieve the public KOHLER Tresham family candidate into quarantine

Acceptance criteria:

- Retrieve an exact or explicitly candidate public Revit-family URL without sign-in, account creation, payment, or access-control bypass.
- Preserve the downloaded bytes in ignored quarantine with source page, direct URL, retrieval time, byte count and SHA256 sidecar; record the container signature, and leave incoming owner RFAs untouched. Confirm that Revit can open it as an RFA only during read-only Family Editor inspection.
- Keep the sink unselected and do not include its geometry in the toilet/lavatory fit study until read-only Revit inspection confirms model version, family category/host, type identity, parameters and measured solids.
- Keep room B unassigned until selected product geometry, applicable clearance, door/approach and plausible service routing pass together.

Current status: Complete for public retrieval and provenance only. An anonymous direct request through the KOHLER dealer's public BIM link returned a 659,456-byte RFA served from KOHLER's technical-content host. It is quarantined under ignored `.local/revit-pilot/family-intake/candidates/` with SHA256 recorded in a sidecar. The Family Editor inspection is pending because Revit remains stopped at a mismatched unsigned-add-in prompt. This candidate is not selected, placed, or used to revise the existing gross-body screen. See M87 in `PROGRESS.md` and `Research/M06_Sink_Candidates_2026-10-28.md`.

### M88 - Recheck selected-D source replay and saved IFC lineage

Acceptance criteria:

- Run two isolated Windows PowerShell 5.1 generations of the checked-in selected-D source and require 43/43 checks, valid SVG XML, and byte-identical seven-file outputs.
- Independently validate the fresh selected-D Revit run's exact saved RVT/IFC2X3 pair; require source, saved-model/export fingerprints, levels, all 21 rooms and areas/bounds, schema checks and intended absence of construction classes to pass.
- Run the repository's offline RevitPilot unit suite and record the exact command and result; this is validator/unit testing, not geometry fitting.
- Confirm the tracked source fingerprint is unchanged and do not overwrite the selected-D baseline or any retained Revit evidence.

Current status: Complete. Both M88 replays pass **43/43**, all three plan SVGs parse, and all seven files match byte-for-byte. A fresh IFC validation returns **26/26** passing checks and the same deterministic report hash as M84. The offline RevitPilot unit suite passes **40/40**. The saved source, RVT and IFC remain at their recorded hashes; see the M88 evidence in `PROGRESS.md`.

### M89 - Recheck reproducibility of the hypothetical M83 gable comparisons

Acceptance criteria:

- Re-run the documented gable comparison generator twice into separate ignored directories; require all 13 source checks and byte-identical `roof-options.json`, `checks.json`, SVG and manifest outputs.
- Parse the generated diagram and confirm the checked-in selected-D source remains unchanged.
- Keep the options labelled hypothetical and unselected; do not claim host-side Revit/IFC validation from source calculations.

Current status: Complete for source-side option reproducibility. Two fresh PowerShell 5.1 runs pass **13/13** and reproduce all four artifacts byte-for-byte. Selected-D remains unchanged. M83's separate Revit derivative, IFC2X3 export and IFC geometry validation remain outstanding; no roof pitch or ridge direction is selected. See M89 in `PROGRESS.md`.

### M90 - Recheck exact-SKU public family and dimension sources for M-06

Acceptance criteria:

- Search public manufacturer-indexed sources and exact-SKU Revit/RFA/BIM queries without signing in or bypassing access gates.
- Distinguish returned manufacturer evidence from retailer claims and from search-engine non-results; do not infer that the absence of an indexed result proves nonexistence.
- Keep B unassigned and preserve selected-D, source RFAs and the current product selection pending confirmed geometry, clearance, door/approach and service evidence.

Current status: Complete as a date-stamped public index recheck. Exact-SKU queries returned retail listings but no current 610AA manufacturer family or dimensional drawing; the manufacturer's live linked files remain predecessor-series documents. This does not establish global nonexistence. M-06 remains open, and B remains unassigned. See M90 in `PROGRESS.md` and the M-06 research note.

### M91 - Make the M83 Revit host study tolerant of template levels

Acceptance criteria:

- The disposable roof-comparison command must not delete template-owned levels to establish its relative datum.
- Reuse the lowest existing level, label it as a local relative reference, and preserve any additional template levels; create one only if the new document contains none.
- Build the revised add-in into a separate ignored directory, verify its local manifest identity and DLL hash, and run the offline regression suite.
- Do not claim Revit-host or IFC completion until the exact matching DLL is loaded and the disposable export passes the M83 IFC validator.

Current status: The source repair and isolated build are now host-verified under M165. The current per-user registration still resolves inside this checkout to `.local/revit-pilot/build-m83-regenerate-bounds-v1/Release/net10.0-windows/RevitPilot.dll`, SHA256 `042BD6A602B6E970A2E7FBFA9C1DC08C22580AD2015A9227DEA85F13B30D5EC3`; the M83 six-option derivative and paired IFC2X3 were independently validated twice. The earlier M91 attempt and its preserved registration backup remain historical evidence. See M165 in `PROGRESS.md`.

### M92 - Establish a current Connecticut residential fixture-clearance screen

Acceptance criteria:

- Recheck official Connecticut code-adoption status and the adopted residential model-code edition.
- Identify the preliminary residential water-closet clearance references and values, clearly distinguishing minimum fixture spacing from accessibility, door/approach, and full-room compliance.
- Preserve site/permit applicability as unresolved and keep M-06 B unassigned until product geometry, finished-face clearance, door/approach, and service route are evaluated together.
- Record primary-source URLs and date the research.

Current status: Complete for a preliminary planning screen. Connecticut DAS lists the 2022 CSBC, based on the 2021 IRC, as current and says the planned 2026 effective date is delayed. The cited IRC basis supports 15 in from the water-closet center to side obstruction and 21 in clear in front for early screening only. Municipality, permit path, accessibility scope, exact fixture geometry, door/approach and service routing remain open. See `Research/M06_Clearance_Basis_2026-10-30.md` and M92 in `PROGRESS.md`.

The M78 room-packing search remains the current upper-suite candidate. Larger experimental budgets and pruning combinations did not yield reproducible output before the available run windows ended; no partial search result has been promoted. Any further search work should profile and optimize the generator before raising its limits.

### M93 - Revalidate the retained selected-D IFC pair after M83 restart work

Acceptance criteria:

- Re-run the independent validator against the retained fresh selected-D Revit 2027 run without overwriting its RVT or IFC.
- Require source/RVT/IFC fingerprints, IFC2X3 schema, all levels and 21 spaces with identities, areas and plan/body bounds to pass.
- Confirm the selected-D source hash remains unchanged and document the scope limitation that this is a validated space study, not a complete building model.

Current status: Complete. The retained pair passes 26/26 checks with zero errors; the new report is byte-identical to the previous M88 report. Selected-D source SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. The model still contains no native walls, slabs, stairs, doors or windows. See M93 in `PROGRESS.md`.

### M94 - Refresh the public KOHLER Tresham sink evidence and gross-envelope screen

Acceptance criteria:

- Recheck the current KOHLER product page and manufacturer-hosted specification for K-2844-4-0; use the latest dated nominal overall dimensions surfaced by that source.
- Bind the quarantined public RFA's URL and SHA256 in the generated report, while explicitly leaving type-to-SKU mapping and Revit solid measurements unverified until read-only inspection.
- Generate the existing M-06 gross-body comparison twice into ignored directories and require byte-identical output; preserve B as a gross unassigned search window and make no fixture or room assignment.

Current status: Manufacturer evidence refreshed and the source report now identifies the 2025-02-08 KOHLER specification (nominal 24 x 19.5 x 34.625 in) and quarantined RFA SHA256. Both fresh PowerShell 5.1 runs pass 22/22 checks and produce byte-identical output. The RFA remains uninspected; no complete M-06 fit, door/approach, service route, code applicability, or room assignment is established. See M94 in `PROGRESS.md` and the M-06 sink research note.

### M95 - Pin the selected toilet's current-SKU manufacturer infographic

Acceptance criteria:

- Retrieve the public product-page infographic identified as 610AA001.020, preserve its URL, byte count and SHA256, and distinguish image annotations from the older predecessor-linked spec sheet and from measured Revit geometry.
- Add a PowerShell validator that confirms the image and selected-D source hashes, retains M-06 B as an unassigned gross gap, and checks only the annotated toilet plan rectangle in both orientations.
- Run the validator twice and require 8/8 checks and byte-identical output; do not claim toilet/lavatory fit, door/approach, service route, code applicability, or assignment.

Current status: Complete for a hash-pinned product-page infographic screen. The current SKU image annotates 30-1/4 x 19 x 30-7/8 in overall dimensions, 12-in rough-in and 17-in seat height (with a seat-height variation note). Two replays pass 8/8 and match SHA256 `E42AA40EBD1E121532EFEE15DF0EAA8CDBF4B7333F1D0A0C2A4A9977C26ECFC8`. Detailed Revit family geometry and all whole-room gates remain open; B remains unassigned. See M95 in `PROGRESS.md` and the current-SKU note in `Research/M06_Toilet_Options_2026-10-27.md`.

### M96 - Pair the current selected toilet envelope with documented lavatory candidates

Acceptance criteria:

- Screen the exact-SKU annotated toilet plan envelope with every dimensioned lavatory research candidate, in both sink plan orientations, against pantry-side B.
- Apply only the documented preliminary 15-in WC centerline-to-side-obstruction and 21-in front-clearance depth screens; label the shared-wall arrangement and 30-in fixture centerline spacing as assumptions.
- Pin upstream report/source hashes, require source D and B to remain unchanged/unassigned, and replay twice to byte-identical reports.
- Preserve all products as research candidates; do not infer walls, doors, approach, service routing, permit applicability, or actual room fit from the rectangular screen.

Current status: The script passes 15/15 checks and screens 16 combinations (eight sink candidates, two plan orientations each); both runs match SHA256 `7F133044E9F0B4BB78756A1267F4C9144B0064E76808F0D55BDB4D8077EE3DC8`. KOHLER Tresham's assumed pair envelope is 57 x 51.25 in at 0-degree sink rotation and 54.75 x 51.25 in at 90 degrees; the measured centerline-to-nearest-sink-body distances in the two screens are 18 and 20.25 in. This is a gross-body minimum-strip study only. M-06 B remains unassigned. See M96 in `PROGRESS.md`.

### M97 - Reconfirm selected-D source reproducibility and retained IFC lineage

Acceptance criteria:

- Run the documented selected-D PowerShell generator twice into separate ignored scratch folders; require 43/43 checks per run, all three SVGs parse, and all seven generated files match byte-for-byte.
- Independently revalidate the retained Revit 2027 IFC2X3 package; require source/RVT/IFC fingerprints, 3 storeys, all 21 spaces and documented geometry data to pass.
- Confirm selected-D source and the three owner-supplied untracked RFAs retain their recorded hashes; do not change the baseline or host project files.

Current status: Complete. Both fresh source generations pass 43/43, all three SVGs parse, and all seven outputs match. The retained IFC validator passes 26/26 with zero errors and reproduces the prior report hash `449B98D7720BB10DCD53BA999A99AA6DD207950783C43EB3CFCA0800085C079B`. Selected-D source is unchanged. This validates its 21-space IFC study, not missing native building elements or host-side M-83 roof geometry. See M97 in `PROGRESS.md`.

### M98 - Re-run the offline RevitPilot regression suite

Acceptance criteria:

- Run the repository's RevitPilot unit suite without launching Revit or modifying a model.
- Record the exact command, count, result, and scope limitation.

Current status: Complete. `.venv/Scripts/python.exe -m unittest discover -s Tools/RevitPilot/tests -v` passes **41/41** tests. This verifies offline command/validator contracts; it does not replace Revit-host geometry checks or IFC export validation. See M98 in `PROGRESS.md`.

### M99 - Audit Revit 2027 add-in startup manifests without changing registrations

Acceptance criteria:

- Confirm the authorized per-user RevitPilot manifest still has AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`, resolves to a DLL inside this checkout, and matches the recorded SHA256.
- Identify the source and exact contents of Revit's “Empty addin file” startup warning, while preserving any manifest outside the explicitly authorized RevitPilot registration.
- Do not choose a trust option or run a host command unless the visible prompt identifies the exact verified project-local RevitPilot build.

Current status: Read-only audit complete. The RevitPilot registration still resolves inside the checkout to `build-m83-level-safe/.../RevitPilot.dll`, SHA256 `660BF4511E1DC51BE4CA3C74C8E386DC948438025B36DFA96551F18F4D3D59DF`. A separate `ForeverHome.SelectedD.addin` is 20 bytes and contains only `<RevitAddIns />`, with no AddInId or assembly. The journal warning about an empty add-in manifest is consistent with this stub, but it does not establish that the stub caused the unsigned trust prompt. The stub was not modified because it is outside the authorized RevitPilot registration. No trust choice or host command was made; see M99 in `PROGRESS.md`.

### M100 - Harden selected-D generator output-path handling

Acceptance criteria:

- Accept either absolute or repository-relative `OutputDirectory` values for the selected-D generator.
- Resolve and reject output paths outside the current checkout before creating directories or files.
- Replay into separate absolute and relative disposable locations; require 43/43 checks per run, all seven generated files byte-identical, and three valid SVGs.
- Confirm the checked-in selected-D source fingerprint remains unchanged and document the default overwrite behavior.

Current status: Complete. Both invocation forms pass 43/43 and yield byte-identical seven-file output; all three SVGs parse. Absolute external and repository-relative traversal paths are rejected before creation. Selected-D source remains SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. See M100 in `PROGRESS.md` and the selected-D package README.

### M101 - Screen upper-suite room blocks against hypothetical gable planes

Acceptance criteria:

- Bind the M78 room-block search and manifest plus M83 roof options and current selected-D source by SHA256; refuse stale or mismatched inputs.
- Calculate the minimum and maximum ideal roof-plane rise above a relative eave across all seven room blocks for the three existing pitches and two ridge axes (42 combinations).
- Keep eave/floor datum, roof build-up and clear headroom explicitly unassigned; do not add a code threshold or select a roof.
- Run two independent PowerShell 5.1 replays and require all checks to pass and JSON/CSV outputs to match byte-for-byte; reject an output path outside the checkout.
- Record the design implication and limits without editing selected-D or source M78/M83 artifacts.

Current status: Complete. The source-bound screen passes **9/9 checks** and produces 42 room/case rows. Two replays match (JSON SHA256 `143DACB30BD4F40793B47BE225B70F5490DAF39987C4AF9F67B489CE274C6457`; CSV SHA256 `FA0E1FB05ADA716759841ABDCC008E0DCC6C12A377C9701A48874D4DE24C0DE2`). On the M78 blocks, ridge-X options put U-05's minimum ideal plane 1.333/1.667/2.000 ft above relative eave for 8:12/10:12/12:12; ridge-Y options leave U-01/U-04/U-05 touching the eave plane. This is not interior headroom. The 38⅓ × 40 ft shell remains an exploration case; no pitch/ridge choice is made. See `Architecture/M101_Upper_Suite_Roof_Height_Ranges_2026-10-30/README.md`.

### M102 - Record the current Connecticut sloped-ceiling screening basis

Acceptance criteria:

- Recheck Connecticut DAS's current code edition and delayed 2026 adoption status from official sources.
- Record the official Connecticut 2022 CSBC amended IRC R305.1 sloped-ceiling and bathroom-fixture provisions, with direct citations and scope caveats.
- Explicitly explain why M101's relative roof-to-eave values cannot establish finished-ceiling compliance; do not invent datums, room classifications or fixture positions.
- Update the research note, project handoff and progress log; preserve all geometry sources and selected-D.

Current status: Complete as statewide preliminary research. Connecticut DAS still lists 2022 CSBC/2021 IRC as current and reports the anticipated 2026 code effective date delayed pending legislative review. Amended IRC R305.1 provides baseline heights of 7 ft for habitable space/halls and 6 ft 8 in for baths/toilets/laundry, with a sloped-ceiling exception based on 5 ft and 7 ft bands and a separate showerhead-area provision. M101 cannot test this without the finished floor/eave relationship, wall/eave location, roof/ceiling build-down, classification and fixture location. No pass/fail code result is claimed. See `Research/Connecticut_Roof_Code_Research_2026-10-28.md`.

### M103 - Derive effective-eave threshold sensitivities for upper rooms

Acceptance criteria:

- Bind the M78/M83 geometry, selected-D source, room program and dated Connecticut code research note by SHA256.
- For U-01 through U-04, derive the effective finished-ceiling height at the eave datum needed to make the full schematic block at least 5 ft and at least half its area at least 7 ft, using each of the six M83 gable cases.
- Label the room-block area proxy, U-02 classification uncertainty, bathroom/circulation exclusions, unknown floor/eave and roof-to-ceiling offsets, and code applicability; make no pass/fail declaration.
- Replay twice in PowerShell 5.1 to byte-identical JSON/CSV, validate the calculation, and reject output outside the checkout.
- Record the orientation trade-off without selecting a roof or altering selected-D.

Current status: Complete as a parametric screening tool. Two independent runs pass **10/10 checks** and match byte-for-byte (JSON SHA256 `4B74367B5F111271B6B171FFBF3AF8B2F0438024A8EF87C2428F8C0AEDC3391C`; CSV SHA256 `F7D70A521EAD5934B15D85C5B603389014BBF1C2D75FEC79FBEE852E66FB5910`). With the M78 room blocks, the generic 5/7 ft thresholds require an effective eave-ceiling datum of -0.444 to -3.167 ft for ridge-X cases (U-03 controls), versus 5 ft for ridge-Y cases (U-04 controls). These are calculated datum thresholds, not chosen eave heights or compliance findings. U-05/U-06 bath zones and C-PRIVATE are excluded. See `Architecture/M103_Upper_Suite_Sloped_Ceiling_Thresholds_2026-10-30/README.md`.

### M104 - Refresh M83 and downstream hashes after code-note update

Acceptance criteria:

- Re-run the documented M83 PowerShell generator after its source code research note changes; preserve all six roof cases and geometry.
- Require three isolated/repository runs to pass 13/13 and all four M83 artifacts to match byte-for-byte.
- Regenerate M101/M103 derived reports against the refreshed M83 source and verify independent replay hashes match their checked-in artifacts.
- Preserve selected-D and incoming family files; do not launch Revit, change roof decisions or modify remote state.

Current status: Complete. M83 regenerated against the extended M102 research note, with three runs passing 13/13 and all four artifacts identical (roof-options JSON SHA256 `8FAF694BCD4AC229836FF49D7DBC35F482F90008E517EF032C5676709DCEEC16`; checks `3F38BA0E3FCA9BCA3D4982F85EB9A8486017967A09899488FC92C1BC9772E32D`; SVG `9C5EA4DBBB297A530463774C610CE8D1C81E18E7FA1135A414BCDBC632981219`; manifest `D71EC4AC99DD47024F9337A1D695B589F3382EAD663D76AE7BA12AEFCB9B69A0`). M101 and M103 replays each pass their checks and reproduce their checked-in JSON/CSV. Only provenance hashes changed in M83. See its README and M101/M103 packages.

### M105 - Compare the routed M78 bath placements against both roof axes

Acceptance criteria:

- Reuse only the five archived highest-ranked public-access M78 layouts and bind their search/manifest and the current M83 roof options by SHA256.
- Confirm each sampled layout keeps public hall reach to U-01/U-02/U-04, no U-03 public-side access, U-02's north-side sample, seven non-overlapping in-shell rooms and source-matching block areas.
- Compare U-05's ideal roof-plane exposure under all six pitch/axis cases; keep fixture locations, use zones, finished headroom and code conclusions out of scope.
- Generate a two-layout comparative SVG, parse it as XML, and replay twice with all checks and byte-identical JSON/CSV/SVG; reject output outside the checkout.
- Report trade-offs and incomplete-search limits without changing M78, selected-D, room area or roof selection.

Current status: Complete for the archived five-candidate subset. The script passes **13/13 checks** on two replays, parses the plan SVG as XML, and matches checked-in JSON/CSV/SVG (SHA256 JSON `424312A30240E1252A39B0FD1BF567F58BB9B4BEA2B4A04D41B725220AF43D19`; CSV `BF4278BB1DB471CA65EEE9BC8EBBD07D42042C933B25F41D04BDBA104FD90BAA`; SVG `39A55B56E59922E07E2096E0E22AB6AC794C5913536A976A0336CD84465D39F3`). M78-TOP-05 (U-05 at x=1.333, y=1 ft, 9×10 ft) improves the minimum relative-eave rise for ridge Y while retaining the sampled route; it trades against the M78 winner, which does better for ridge X. TOP-05 is only the most balanced of these five archived layouts, not an exhaustive optimum or recommendation. See its README and `routed-bath-roof-alternative.svg`.

### M106 - Screen bedroom-capable room blocks for shell-perimeter opening opportunity

Acceptance criteria:

- Use official Connecticut CSBC amended IRC R310.1 as a conditional design screen; cite the current statewide source and separate it from permit-specific applicability.
- Check U-01/U-03/U-04 perimeter contact in all five archived M78 route-ranked cases, with source fingerprints, room IDs/areas and shell dimensions verified.
- Distinguish a possible shell-edge wall zone from an actual exterior wall or emergency escape opening; leave U-03 sleeping-room classification and roof-opening acceptability unresolved.
- Generate reproducible JSON/CSV/SVG, require 13/13 checks and byte-identical independent runs, parse SVG, and reject output outside checkout.
- Preserve selected-D, RFAs and the routed suite baseline.

Current status: Complete as an important unresolved design gate. Two PowerShell 5.1 replays pass **15/15 checks** and reproduce JSON/CSV/SVG (SHA256 JSON `20F7F98D2FD8A4321AF3BCADAEFD72073A98357920BAA1A58B6BDBC89F1AEC39`; CSV `6B33957F62C3962B32F9555C2BE98EE49AF3BDE2840847F3D92781B03D07F46B`; SVG `D1EE610546D22A162F1539A14D9270305B942E13656FB3CFB64E6B5851B121CE`). Every retained M78 layout places U-01/U-04 on shell edges but U-03 8.166667 ft from its nearest perimeter edge. If U-03 is intended for sleeping, R310.1 opening provision remains unaddressed by the room layout. This is not a compliance finding or proof that a roof opening cannot qualify. See `Research/M106_CT_Sleeping_Room_EERO_Study_2026-10-30.md` and the M106 package.

### M107 - Search all route-tested upper-suite packings for a U-03 perimeter opportunity

Acceptance criteria:

- Preserve M78 and selected-D while adding an opt-in archive of all complete route-tested placements; default M37 artefacts must remain byte-identical.
- Audit all archived rectangles against the hypothetical 38.333333 × 40 ft shell and sampled room-side reachability; retain the bounded-search warning.
- Check whether any required-route candidate with north-side U-02 arrival places U-03 at a shell edge.
- Produce source-bound, reproducible JSON/CSV/SVG and leave U-03's sleeping-room classification and EERO design unresolved.

Current status: Complete as a bounded design screen. The opt-in M37 run archives 457 placements, 5 of which reach sampled hall sides for U-01/U-02/U-04; all five include sampled north-side U-02. No placement puts U-03 on the hypothetical shell perimeter. The search reached its node limit and is incomplete. Three standard M37 artefacts match M78 byte-for-byte; M37 checks pass 28/28. The audit passes 16/16 on two identical runs (JSON `4D3C875BE12B7EE19485B59A5D7257EC55C9935B44E04E176D69AD4AAB9F40F5`; CSV `5694A12290DBA1036CDE66F43A09F0F4D41A58135AA45CCE652412ED382D6D9D`; SVG `33FECC98570429E0D347780199215FEC2A11130523DF3E8DEA368F76A1D5F176`). See `Architecture/M107_U03_Perimeter_Opportunity_2026-10-30/README.md`. If U-03 is intended for sleeping, a different room/shell arrangement or separately evaluated opening strategy remains needed; no alternative is presumed to work.

### M108 - Double the bounded M37 node budget for the U-03 perimeter search

Acceptance criteria:

- Repeat the M107 hypothetical shell and route constraints with a larger bounded node budget and archive all route-tested placements.
- Audit all candidates with source-bound perimeter, containment, overlap and sampled-route checks.
- Re-run the audit independently and record search scope, reproducibility and limitations.
- Preserve selected-D, room program, route topology and source dimensions.

Current status: Complete as an expanded but still incomplete screen. The 8,000-node run reached 7,992 nodes and archived 863 route-tested placements, passing 28/28 M37 checks. Five reach sampled hall sides for U-01/U-02/U-04; all five include sampled north-side U-02. No U-03 perimeter contact appears among 863. Two audits pass 16/16 with identical JSON/CSV/SVG (JSON `DE78C3278A0C1EB15397B3816D81383427B40C3A57DF7FAB0F43EFCCE9F626A4`; CSV `12871C360B72670DFD5F7863647F5FEA0D5A17B862436B878BE276A71A99A8D3`; SVG `3A7E54825F09873B3F1ABB10B8664C42181298899DDEBBB14F081D17BFDE669A`). Search reports incomplete. The larger sample strengthens but does not prove the perimeter limitation. See `Architecture/M108_U03_Perimeter_Opportunity_2026-10-30/README.md`.
## M109 - Reproduce selected-D schematic and revalidate its saved IFC pair

Acceptance criteria: regenerate OwnerSelectedD into scratch twice; require all geometry checks and SVG parsing to pass; compare generated artifacts byte-for-byte; independently validate the preserved saved RVT/IFC2X3 evidence pair; do not edit the tracked selected-D baseline.

Status: Complete for the documented room-boundary study. Three isolated PowerShell 5.1 generations (`.local/revalidation/M109-selected-d-a/`, `-b/`, `-c/`) each pass **43/43** checks, parse all SVG, report 0 sf L-02/U-06 open-stack overlap and leave bath footprint TBD. All seven output artifacts are byte-identical across runs. The exact IFC2X3 pair at `.local/revit-pilot/selected-d/20261030T002652845Z/` passes **26/26** independent checks with zero errors; rerun report SHA256 `449B98D7720BB10DCD53BA999A99AA6DD207950783C43EB3CFCA0800085C079B`. This fresh pair supersedes the older M48 mismatch for this package; the mismatched historical evidence remains preserved. This is a 21-space, three-storey room-boundary model, not a coordinated house or construction model.

## M110 - Resolve Evolution disposable wall-host orientation

Acceptance criteria: use the owner-authorized, hash-verified local RevitPilot on an isolated derivative; independently gate all family measurements and host identity/orientation; preserve Incoming RFAs and selected-D; record what remains unknown and keep M-06 B unassigned.

Status: Complete as a single-orientation geometry probe. Fresh Revit 2027.3 intake `.local/revit-pilot/family-intake/20261030T195404237Z/` reports 5 families/14 types and passes **101/101** PowerShell intake checks. Evolution type `0467.400` hosted bounds are 17.5052 in projection x 22 in width x 34.25 in height, with three positive-volume solids and axes mapped to the disposable wall. DLL SHA256 `922BC70EA456F9F8532C5D5917D637ABA6F08A938F7D3B485D3B242E9D6CBEFB`; Revit journal identifies the authorized AddInId and reports `NoError`. This does not confirm assembly appearance, installed services, clearance, door/approach, or any room fit. Product type description “Basin only” conflicts with its `Pedestal Option = Yes`; the product is discontinued. Exact current toilet geometry and local applicable clearance basis remain unresolved. No M-06 assignment or selected-D placement.

## M111 - Cross-check another public Champion PRO Revit link against the selected fixture

Acceptance criteria: obtain the file only from a publicly linked manufacturer asset without credentials; record provenance and hash; compare it with previously inspected families; distinguish product-series relationships from exact-SKU identity; do not place or assign M-06.

Status: Complete as a public-link/source-identity check. LIXIL Pro's page for 211CA004.020 (standard-height, 1.6 gpf, without seat) links a multi-series Champion RFA. Its 331,776 bytes hash to `37D3E56962B81F4B0ACE3D36D25BAFC03B7DEE1232E7DE7BBF9B95E4B0B75F63`, exactly the preserved Incoming 211AA104 predecessor file. That exact existing source was already inspected read-only in Revit and contains seat type `5325.010` only; the newly linked file contributes no new bowl/tank geometry and is not the selected 610AA001.020. Provenance is recorded at `.local/revit-pilot/family-intake/candidates/champion-pro-revit-bundle-211-series-20261030/source.json`. No additional Revit session was needed for identical bytes. Exact current selected-SKU family geometry, bathroom fit gates and M-06 B assignment remain unresolved.

## M112 - Reconcile selected-D stair-rise arithmetic with Connecticut's published amendment

Acceptance criteria: read only the documented selected-D test datums and owner stair-intent; cite the official Connecticut stair provisions; compute riser-count/tread sensitivities reproducibly; do not select a stair, change datums, create native stair geometry or claim code compliance.

Status: Complete as a source-bound design/section audit. Selected-D test levels -5/0/+5 ft mean 60 in per adjacent transition. Its 8 x 7.5 in riser, 7 x 11 in tread option is arithmetic only and spans 60 in with 77 in run. The separate owner spec prefers 6 x 7.25 in (43.5 in) and a 5-7 count range. Connecticut's current published 2022 CSBC amendment sets maximum riser 8.25 in and minimum tread 9 in. At 60 in, seven equal risers would be 8.5714 in; eight at 7.5 in is the minimum under this single-parameter arithmetic. The former generic 7.75 in reference in `Architecture/Stairs_Half_Story.md` was corrected to identify the Connecticut amendment. Two Windows PowerShell 5.1 runs pass **11/11** and reproduce byte-for-byte; report hashes and limitations are in `Architecture/M112_Stair_Rise_Code_Basis_2026-10-30/README.md`. CO-021 remains open: actual floor-to-floor/assemblies, section, landings, openings, headroom, guards, egress and support have not been verified. No stair alternative is selected.

## M113 - Root U-03 on the hypothetical upper-shell perimeter

Acceptance criteria: add an opt-in U-03 root plan and perimeter seeding without changing the default M37 root set; preserve the private route, required U-02 hall arrival, guest hall access, both Jack-and-Jill links, lift keepout and source dimensions; archive and independently audit every completed route-tested placement; do not select a house shell or claim an opening/code solution.

Status: Complete as a bounded diagnostic. The M37 generator now supports `U-03-only` plus `-U03PerimeterRootSeeds`; default balanced roots remain U-01/U-02/U-04. A 100-node default-mode smoke test passes 28/28. The targeted 1,200-node U-03 run passes 28/28 and archives 45 complete room-block arrangements after 464 nodes; the run is incomplete. All 45 place U-03 against the west test-shell edge; 28 reach one sampled public-room side (U-01 or U-04), zero reach U-02, and zero reach all three required public rooms. A source-bound independent PowerShell audit passes 17/17 and reproduces byte-for-byte; the SVG parses as XML. A full M78 byte-for-byte default regression was stopped after more than five minutes, so complete default-output regression remains open. See `Architecture/M113_U03_Perimeter_Root_Search_2026-10-30/README.md`.

Next: M114 tests alternate seed positions along the west edge and retains the same U-02 direct-hall route requirement. M113's reachable U-03 corridor-side samples are not doors; U-03 stays private-route-only in the topology. The 38 1/3 x 40 ft shell remains exploration-only. No selected-D, Revit, IFC, RFA or remote changes.

## M114 - Offset U-03 along the hypothetical west shell edge

Acceptance criteria:

- Add opt-in edge and along-edge seed controls while preserving M37's default balanced search behavior.
- Test U-03 at west-edge fractions 0, 1/2 and 1 for both source dimensions/orientations, preserving the owner-directed room links and required sampled U-02 hall arrival.
- Archive all route-tested placements, independently verify source fingerprints, shell containment, dimensions, separation, links and reconstructed route counts, and replay the audit deterministically.
- Keep the shell and all generated layouts exploratory; do not place a direct U-03 hall door, select a layout, or alter selected-D, Revit, IFC or Incoming RFAs.

Status: M37 integrity passes 29/29; a second exact M37 run reproduces all five output artifacts byte-for-byte. A 100-node balanced/default-root smoke passes 28/28 with roots U-01/U-02/U-04; the full M78 output replay remains open. On the 38 1/3 x 40 ft exploratory shell, the bounded search expands 810/1,200 nodes and archives 141 complete route-tested arrangements; it remains incomplete. Six edge/orientation seed combinations were attempted; completed layouts occur at the west/northwest corner only. Sixteen reach all three sampled public-route goals, and all 16 include a sampled north-side U-02 arrival. Nine of those 16 have no sampled U-03 hall-side reach; seven do. The independent M114 audit passes 19/19 and repeats byte-for-byte; the general candidate validator passes 113 checks on the ranked candidate. M113's pinned historical audit still passes 17/17 and reproduces its checked-in report. This is a reachability screen, not a room plan, door layout, code result or fit finding. See `Architecture/M114_U03_West_Edge_Offset_Search_2026-10-30/README.md`.

M116/M117 now screen the northeast privacy subset against the dated Connecticut EERO basis and ideal gable planes. M114 did not resolve sleeping-room classification or provide modeled doors, clearances, structure, services, stairs or exterior conditions. The 38 1/3 x 40 ft test shell remains unselected. M118 completes the default M78 output regression. Next design work should model actual candidate wall/opening/eave geometry only after product and exterior assumptions are evidenced.

## M115 - Spread U-03 root seeds across all hypothetical shell edges

Acceptance criteria:

- Extend M114's opt-in spread seed mode to test all four shell edges at 0, 1/2 and 1 positions for both source-preserving U-03 orientations.
- Preserve direct sampled U-02 hall arrival, independent U-04 guest access, U-03 private-only topology, Jack-and-Jill links, lift reservation, stair approach, room dimensions and 1/2 ft separation.
- Archive all complete route-tested placements; independently check all 24 seed coordinates, source hashes, geometry, topology and reconstructed route records; reproduce the generator artifacts and audit outputs.
- Keep this shell and its layouts exploratory; do not modify selected-D or claim a code, opening, accessibility, structural or construction result.

Status: M37 passes 29/29. The bounded run expands 2,830/4,800 nodes, records 331 route-tested room blocks from 877 raw complete layouts, and remains incomplete. A second exact generator run matches all five artifacts byte-for-byte. The independent audit passes 21/21 twice with matching outputs. All 331 U-03 blocks touch the north shell edge: 141 also touch west, 181 also touch east, and 9 occupy only the north edge. Eighty layouts reach all three sampled public-room route goals; all 80 have a sampled north-side U-02 arrival. Sixty-four northeast-corner cases and nine northwest-corner cases avoid sampled U-03 hall-side reach; seven northwest cases have one. No south-edge layout appears. See `Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30/README.md`.

Interpretation: the northeast-corner group is the most promising privacy-screen branch under the existing abstract route proxy. It does not establish an exterior wall, a bedroom emergency opening, door placement, room fit, roof clearance, or applicable Connecticut compliance. U-03 classification, wall/roof details and site/permit applicability remain open. No shell or arrangement is selected.

## M116 - Screen conditional U-03 emergency escape opening wall zones

Acceptance criteria:

- Recheck official Connecticut code-adoption status as of the report date and cite primary state/model-code sources for the conditional sleeping-room opening basis.
- Bind the M115 archive, M115 audit, current selected-D source, room program, owner proposal and code-basis note by SHA256.
- Count route-valid privacy candidates with north/east versus north/west U-03 perimeter contact; calculate source-preserved gross room and perimeter lengths and reproduce threshold arithmetic.
- Clearly separate gross room-block perimeter from a wall, a product opening, a qualifying exterior discharge and a code determination. Do not change the selected-D baseline or assign a room.

Status: Connecticut DAS still lists the 2022 CSBC/2021 IRC as current and says the expected 2026 effective date was delayed pending LRRC approval. If U-03 is used as a sleeping room, the current cited basis conditionally requires an operable EERO; the referenced requirements include 5.7 sf net clear area (5 sf grade-floor/below-grade exception), 20 x 24 in minimum net-clear dimensions and a bottom of opening no higher than 44 in above floor. The grade exception is not presumed. The M115 privacy set has 64 northeast and 9 northwest candidates. **Correction:** the northeast 64 split into 44 north-long U-03 blocks (13.6667 x 9.1667 ft gross; 164/110 in north/east contact) and 20 east-long blocks (9.1667 x 13.6667 ft; 110/164 in). M116's corrected deterministic PowerShell analyzer passes 21/21 twice with matching report/check outputs. A 20 x 24 in clear opening is only 3.33 sf; area alone at minimum width requires 41.04 in clear height, or at minimum height requires 34.2 in clear width. These are threshold arithmetic, not a product selection or fit. See `Research/M116_CT_EERO_and_U03_Exploratory_Wall_Zone_2026-10-30.md` and `Architecture/M116_U03_EERO_Wall_Zone_2026-10-30/README.md`.

The northeast branch now has a plausible perimeter-zone hypothesis, but no actual exterior wall, clear opening, sill, roof/eave, grade, qualifying yard/court or path to public way is modeled. U-03 sleeping use, site, occupancy and permit basis remain unresolved; no compliance finding or room selection follows. M117 now compares the two source-preserved northeast orientations against all six M83 ideal gable cases (8:12, 10:12, 12:12; ridge X/Y), for 12 cases total. Its PowerShell analyzer passes 19/19 and two runs reproduce report, checks and CSV byte-for-byte. In this ideal-plane proxy, orienting the room's longer dimension along the touching gable end yields more roof-plane rise at the assumed opening zone; the result swaps between ridge axes with room orientation. This is a conditional comparison only, not a roof or room recommendation. See `Architecture/M117_U03_Gable_EERO_Height_Screen_2026-10-30/README.md`. No Revit/IFC/selected-D/RFA or remote state changed.

## M117 - Compare U-03 orientation and gable-plane EERO height

Acceptance criteria:

- Bind the comparison to M115 route-tested privacy candidates, corrected M116 code-basis arithmetic, M83 gable options, selected-D, owner proposal and source scripts by SHA256.
- Carry both M115 northeast U-03 orientations through 8:12, 10:12 and 12:12 ideal roof planes with ridge axes X and Y; verify the 12 geometry cases and conditional opening-zone/eave arithmetic.
- Label the EERO opening as a minimum-threshold proxy, not a product; keep pitch, ridge axis, room layout, eave datum, sleeping use, site and code applicability unresolved.
- Reproduce the report, checks and CSV byte-for-byte on repeated Windows PowerShell 5.1 runs; do not alter selected-D, Revit/IFC, RFAs or remote state.

Status: Complete as a conditional geometry comparison. M117 passes 19/19 checks. Two sequential PowerShell runs reproduce report SHA256 `BF2A5598282D4ADDE0A11F851D2222B1152A202ADA4156829C65C2C21FA4EC6B`, checks SHA256 `EEC9FD7CBDDF555E957C23844EB975E04BA0B176093E1B0CA967B5FD78FDC094`, and cases CSV SHA256 `F20E037831B18253A360898C8B3401FEAA8BE78EF4831C669835DCAC0B41660E`. The ideal-plane opening-zone rise is higher when the room's longer side contacts the selected gable end; which ridge axis gives that result swaps with the two room orientations. This does not choose either arrangement, establish actual eave/headroom or verify an EERO. See `Architecture/M117_U03_Gable_EERO_Height_Screen_2026-10-30/README.md`. M118 has since reproduced the M78 default artifacts byte-for-byte and validated the candidate 112/112. Remaining design work includes actual room/wall/roof/opening/site study.

## M118 - Preserve default M78 generator artifact compatibility

Acceptance criteria:

- Replay the documented M78 default parameter set into ignored scratch, leaving the checked-in package and selected-D source untouched.
- Independently validate the scratch candidate and compare all four canonical artifacts to the retained package byte-for-byte.
- If later opt-in search metadata changes default output, serialize it conditionally without changing opt-in search behavior; verify historical M113/M114/M115 audits remain valid.
- Record runtime, results and limitations; make no shell or room selection.

Status: Complete. The full replay passed M37 integrity 28/28 and expanded 3,996/4,000 nodes in about 12 minutes. The independent validator passes 112/112. The first replay exposed only an extra `u03_perimeter_root_seeds:false` metadata field; after changing serialization so this opt-in flag appears only when enabled, a second full replay exactly matched M78's search, checks, SVG and manifest hashes. Historical M113/M114/M115 audits pass 17/17, 19/19 and 21/21. This establishes reproducibility of an incomplete bounded room-block search, not design feasibility or code compliance. Scratch evidence is `.local/revalidation/M117-M78Replay/`; see `Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/README.md`.

## M119 - Inspect the quarantined KOHLER Tresham family

Acceptance criteria:

- Verify and preserve the exact quarantined RFA by SHA256 before and after opening it in Revit 2027.3.
- Record Family Editor category, displayed type count/parameters/formulas, visual assembly and any host behavior that can actually be established.
- Close without saving; do not load into a project, place, assign, or modify selected-D.
- Update the intake record and manifest, and state which later fit evidence is still required.

Status: Complete as a manual, read-only family inspection. The 659,456-byte Revit 2011 RFA was identified by Revit 2027.3 and upgraded in memory; it was closed without saving. SHA256 before/after is `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`. The Family Editor shows a combined basin/pedestal, category Plumbing Fixtures, and ten finish/color types. Type `Fireclay-C-White` displays report parameters 24.0078125 x 19.5 x 34.625 in, closely matching the published nominal size; Waste Connection is enabled and sanitary diameter is 1-1/4 in by a 5/8-in-radius formula. These are type parameters, not solid-bound measurements. Host behavior, actual connector objects, a cited applicable clearance basis, door/approach, service route and whole-room fit remain open. KOHLER's specification says this model is not ADA compliant; no applicability finding is made. Keep M-06 unselected and B unassigned. Full inspection record and reproduction steps: `Architecture/M119_Tresham_Family_Inspection_2026-10-30/README.md`.

## M120 - Refresh M-06 current-product envelope evidence

Acceptance criteria:

- Record the current manufacturer infographic dimensions for the owner-selected 610AA001.020 toilet with its public source URL and observed content hash; distinguish bowl height from seat height and preserve the remaining predecessor-document limitation.
- In an isolated Revit 2027.3 family-intake study, measure the exact quarantined Tresham RFA by positive-volume solids, category, type count and placement type; preserve the exact source hash and do not place it in selected-D.
- Recompute all inherited research lavatory pair rectangles against the separate owner-follow-up 124 x 84 in M-06-B gross search window and dated preliminary Connecticut spacing basis.
- Bind inputs to source hashes, reproduce output in a second directory, validate all check results, and keep M-06 unassigned because door/approach and service coordination are absent.

Status: Complete as a source-bound preliminary envelope screen. Revit 2027.3 disposable intake run `.local/revit-pilot/family-intake/20261031T012424079Z/` measured 24 types across six Incoming families; `validate_family_intake_output.ps1` passes **155/155** integrity checks. The quarantined Tresham has three positive-volume solids/type, ten types and `WorkPlaneBased` placement; the `Fireclay-0-White` solid bounds are 24.0063 x 19.4998 x 34.625 in in symbol-local coordinates. The current American Standard product infographic visibly calls out 19 in width, 30.25 in projection, 30.875 in overall height, 16.5 in bowl height, 17 in seat height, and 12 in rough-in for 610AA001.020; its publicly downloaded image hash is recorded in `m120-inputs.json`. The current linked spec download still resolves to predecessor paperwork. `Tools/build_m120_m06_current_envelope_screen.ps1` recalculates 16 research toilet/lavatory rectangles against gross B and passes **14/14** checks twice with byte-identical outputs. Gross containment is not actual fit. Selected-D, fixture assignment, Revit project geometry and IFC remain unchanged. Full evidence and commands: `Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30/README.md`. Next gates: obtain exact-current-SKU installation geometry if public, verify exact sink host/connector representation, then test actual door/approach/privacy and a plausible water/waste/vent route in a disposable model. Do not assign B or claim compliance until those fit gates and local applicability are resolved.

## M121 - Repair M83 DirectShape bounds evaluation

Acceptance criteria:

- Reproduce the prior M83 failure and isolate why the first generated roof mesh returned no Revit bounding box.
- Regenerate the Revit document after each `DirectShape.SetShape` and before querying actual bounds; add a source-contract regression check for this ordering.
- Build an isolated local add-in, verify AddInId, worktree-contained assembly path and SHA256, and preserve the currently registered manifest before replacement.
- On the exact hash-matched new DLL, run all six gable mesh cases in a disposable Revit comparison and validate the saved RVT/IFC2X3 pair independently.
- Preserve all historical failure and run evidence; make no selected-D change or roof selection.

Status: Source fix and isolated build complete; Revit host/IFC verification is pending because the running Revit process opened an unsigned-add-in prompt for the **old** `build-m83-level-safe` path after its manifest had been replaced. The new DLL hash is `32B3AB18B33ECC12704FAE292F704FF4775799485AD34A12F582FADC969D0CD8`; its AddInId is the authorized `096B0D51-8883-4B3D-BD31-E9622201E785`, assembly resolves inside this worktree, and the prior manifest is preserved at `.local/revit-pilot/registration-backups/20261031T013120575Z/ForeverHome.Pilot.addin`. The old-prompt mismatch was not approved; no Always Load or trust-wide setting was used. Revit's UI automation currently cannot interact with that modal because its child security window is not exposed as an actionable window. Continue only after closing the old process and relaunching against the new manifest, then verify that the prompt path/hash match the new build before choosing the authorized one-time load. Offline contract checks pass 2/2 and isolated .NET build has zero errors (two pre-existing Revit-reference version conflict warnings). See dated progress evidence before reporting M83 complete.

Next: M-06 still needs measured positive-solid and hosted orientation evidence for a toilet/lavatory pair, a researched jurisdictional clearance basis, explicit door/arrival geometry and a plausible service route in a disposable study before B can be assigned.

## M122 - Replay source geometry, refresh the retained IFC check, and search public M-06 model sources

Acceptance criteria:

- Run the M83 PowerShell geometry generator twice into separate ignored scratch directories; require 13/13 source checks on each run and byte-identical JSON, checks, SVG and manifest outputs.
- Re-run the independent M109 selected-D IFC2X3 validator against its retained saved-RVT/export pair; require every check true, zero errors and the recorded RVT fingerprint linkage intact.
- Re-run the focused M83 command contract tests, while keeping their source-level scope distinct from a Revit integration result.
- Check the official current-SKU product page and its public linked documents, and search publicly indexed Revit family sources without creating accounts or downloading account-gated files. Record exact-SKU availability as a bounded search result, not a claim that no such model exists anywhere.
- Preserve the owner RFAs, selected-D and remote state; leave M-06 unassigned and room B unassigned.

Status: Complete for these offline replay and public-source checks. The two fresh M83 runs each pass 13/13 and produce matching hashes for all four generated artifacts (JSON `8FAF694BCD4AC229836FF49D7DBC35F482F90008E517EF032C5676709DCEEC16`; checks `3F38BA0E3FCA9BCA3D4982F85EB9A8486017967A09899488FC92C1BC9772E32D`; SVG `9C5EA4DBBB297A530463774C610CE8D1C81E18E7FA1135A414BCDBC632981219`; manifest `D71EC4AC99DD47024F9337A1D695B589F3382EAD663D76AE7BA12AEFCB9B69A0`). The retained M109 selected-D IFC2X3 pair passes 26/26 with zero errors; rerun report SHA256 is `449B98D7720BB10DCD53BA999A99AA6DD207950783C43EB3CFCA0800085C079B`. The focused M83 source contract tests pass 2/2. Public search rechecked the official 610AA001.020 page and identified its linked spec and install guide as predecessor 211AA documents; indexed RevitCity toilet downloads are account-gated. No exact-SKU freely accessible family was found in those sources; this bounded result does not prove none exists. M83 still lacks its actual Revit/IFC host run, and M-06 lacks a measured current toilet family and full fit evidence. Scratch outputs and the IFC report are in ignored `.local/revalidation/M122-M83/` and `.local/revalidation/M122-selected-d-ifc-rerun.json`. No model or remote state changed.

## M123 - Run the complete offline RevitPilot regression suite

Acceptance criteria:

- Run all tests discoverable under `Tools/RevitPilot/tests` using the repository virtual environment.
- Require a zero exit code and report the exact passing test count.
- Describe the result as offline regression evidence only; do not imply a Revit host run or generated IFC validation from unit tests.

Status: Complete. `./.venv/Scripts/python.exe -m unittest discover -s Tools/RevitPilot/tests -v` passes **42/42** tests, including the M83 regeneration-order contract and selected-D IFC validator contracts. The separate M109 retained IFC validation and M83 PowerShell generator replay are recorded under M122. This suite does not launch Revit or produce/export geometry. See M123 in `PROGRESS.md`.

## M124 - Reproduce selected-D geometry against the retained baseline

Acceptance criteria:

- Regenerate owner-selected D twice using the documented Windows PowerShell command into separate ignored output folders; each run must pass 43/43 and produce all seven documented artifacts.
- Require both outputs to match each other and the retained M109 generation byte-for-byte; parse the plan SVGs and preserve the reported zero L-02/U-06 stacked overlap and TBD bath footprint.
- Confirm the owner-selected source-study SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` and rerun independent IFC2X3 validation against the exact retained saved-RVT/export pair.
- Keep the room-boundary model's limits explicit; do not imply coordinated building geometry, permit compliance or construction readiness.

Status: Complete for the selected-D room-boundary baseline. Two fresh runs in `.local/revalidation/M124-selected-d/a/` and `/b/` each pass 43/43 and produce seven files byte-identical across both runs and to `.local/revalidation/M109-selected-d-a/`. SVG checks pass; L-02/U-06 open stacked overlap is 0 sf and bath footprint remains TBD. The source-study hash is unchanged. Independent validation of `.local/revit-pilot/selected-d/20261030T002652845Z/` passes 26/26, zero errors, IFC2X3 schema clean, three storeys and 21 spaces with exact source IDs, names, areas, levels and plan bounds. Report SHA256 `449B98D7720BB10DCD53BA999A99AA6DD207950783C43EB3CFCA0800085C079B`. This confirms reproducibility and export consistency for the documented room-boundary study only; it does not add physical walls, floors, stairs, openings, roof, framing or coordinated services. See M124 in `PROGRESS.md`.

## M125 - Bind the M83 regeneration and IFC route to current Autodesk API documentation

Acceptance criteria:

- Cite Autodesk API documentation for when `Document.Regenerate` refreshes changed elements and for the Revit IFC export API used by M83.
- Cross-check the documented behavior against M83's `SetShape`/regenerate/bounds order and its `IFC2x3CV2` export option.
- Keep documentation research distinct from runtime verification; do not mark M83 host/IFC completion based on references alone.

Status: Complete as a documentation cross-check. Autodesk's API reference describes `Document.Regenerate` as updating document elements after changes and demonstrates reading modified element state only after regeneration. Autodesk's Revit 2027 IFC guide documents API export through `Document.Export(String, String, IFCExportOptions)`; `GableMassingCommand` sets `IFCVersion.IFC2x3CV2`. These sources support the documented API route, but M83 still requires the six-case Revit run and independent IFC validation. See M125 in `PROGRESS.md` and the M83 README.

## M126 - Test and repair M83 IFC validator failure reporting

Acceptance criteria:

- Add focused tests for M83 expected bounds, IFC mesh unit conversion/triangle area, invalid geometry, and missing host artifacts.
- Ensure the missing-artifact path emits the same machine-readable count fields consumed by the command-line summary.
- Run the validator against an empty disposable folder; require a clear failed report and exit code 1 rather than a traceback.
- Run the complete offline RevitPilot test suite and keep its result distinct from Revit runtime/IFC-export validation.

Status: Complete. New M83 validator tests cover the geometric helper functions and missing-input path. The test exposed an early-return bug: missing required artifacts produced no `passed_count` or `check_count`, while the CLI summary indexed both fields and raised `KeyError`. The failure result now includes both counts. The focused M83 IFC validator tests pass 5/5; the empty-run CLI prints `FAIL: 0/6 checks passed`, writes a parseable report and exits 1 without traceback. The entire offline suite passes **47/47**. No successful M83 host IFC has yet been produced or validated. See M126 in `PROGRESS.md`.

## M127 - Refresh the reproducible BIM baseline and M-06 source gate

Acceptance criteria:

- Regenerate OwnerSelectedD twice in separate ignored scratch folders; require 43/43 geometry checks, valid SVG, seven artifacts matching one another and the retained M109 generation, and the source-study hash to remain unchanged.
- Independently rerun the exact retained saved-RVT/IFC2X3 validator and require all 26 checks to pass with no errors; describe the scope as a room-boundary study.
- Regenerate the six M83 gable comparison options twice and require all four artifacts to match the retained M122 output; do not represent this source-generation check as Revit host validation.
- Rerun the full offline RevitPilot test suite.
- Recheck the public exact-SKU manufacturer resources and RevitCity download gate; do not use credentials or gated downloads, and keep M-06/B unassigned.
- Inspect the live Revit add-in prompt against the exact project-local manifest/DLL. Do not accept a mismatched or stale DLL; record the outstanding host gate.

Status: Complete as a fresh offline/source and export-baseline revalidation. Host execution of M83 remains an explicit open gate under M121/M127.

## M128 - Verify availability of the Champion PRO predecessor tank family

Acceptance criteria:

- Inspect the public manufacturer record for tank SKU 4225A104.020 and capture its product role, stated status/dimensions, and design-file availability.
- Compare the tank SKU only with the documented predecessor 211AA.104 component pair; do not infer that it is the 610AA001.020 current assembly.
- Do not invent tank solid geometry, download gated content, or assign M-06/B on this evidence.
- Record the public-source finding, its limits, and the remaining exact-SKU model/fit gates.

Status: Complete as a source-availability check. LIXIL Pro identifies 4225A104.020 as a discontinued 1.28 gpf tank-only item with nominal 19 x 9-1/16 x 13-3/16 in dimensions and explicitly reports that no design files or 3D objects are currently available. This closes the public manufacturer-family path for that predecessor tank, not the current selected 610AA assembly. M-06 and B remain unassigned.

## M129 - Check the manufacturer-linked ATS model-library route without authentication

Acceptance criteria:

- Follow public links from the manufacturer product resources to ATS and search public indexing for the selected 610AA001.020 and documented predecessor component SKUs.
- Record whether an exact model is directly exposed without sign-in; distinguish a JavaScript shell, search non-results, and documented account-dependent Spec Tool behavior.
- Do not create an account, enter credentials, contact support, generate a product project/spec, or download through a gated workflow.
- Preserve the exact-SKU model as unresolved and keep M-06/B unassigned.

Status: Complete as an unauthenticated source check. The visible anonymous US-catalog Products search displayed **0 products** for exact SKU 610AA001.020. A separate anonymous Champion PRO Series search exposed three family records; inspected 211CA1XX is standard-height with a different bowl model and is not the selected 610AA chair-height product. The Revit format download requires an email address. No account, credentials, or email submission was used; see M131 and the dated evidence in `Research/M06_Toilet_Options_2026-10-27.md`. Exact 610AA geometry remains unresolved.

## M130 - Compare primary-bath roof exposure across U-03 privacy layouts

Acceptance criteria:

- Reuse the owner-authorized 38 1/3 x 40 ft shell solely as an exploration envelope; do not change selected-D.
- Select only the 64 M115 northeast-corner room-block cases that retain sampled U-01/U-02/U-04 public reach, north-side U-02 arrival, and no sampled U-03 public-hall reach.
- Check source room areas, shell containment and pairwise non-overlap for all seven room blocks in every candidate.
- Evaluate the complete U-05 rectangle against all six M83 ideal roof planes; label outputs as relative roof exposure, not fixture headroom or code review.
- Run twice under Windows PowerShell 5.1 and require identical output artifacts.

Status: Complete. The new source-bound analyzer passes 15/15 checks for 64 layouts and 384 room-roof cases; two runs reproduce all four outputs byte-for-byte. Candidate position changes the relative roof-plane exposure over U-05. At 12:12, the sampled maximum minimum-rise case is 10 ft for M130-NE-24/ridge X and 8.166666 ft for M130-NE-19/ridge Y. Both are descriptive room-block comparisons; the eave/floor datum and actual fixtures are absent. See the M130 README and PROGRESS.md.

## M131 - Resolve the public ATS Champion PRO RFA lead

Acceptance criteria:

- Compare the exact `610AA001.020` product record against every public Champion PRO family result without inferring model equivalence from a shared collection name.
- Record the public family metadata, product type, rough-in, bowl identity, plan dimensions and access/download requirements.
- Do not submit an email address, sign in, create an account, or download via an email-gated workflow without specific owner authorization for the address and destination.
- If specifically authorized, preserve source URL and SHA256 in ignored intake quarantine before read-only Revit inspection; never place an unverified alternate in selected-D.
- Keep M-06 B unassigned pending exact product geometry, applicable clearance, door/approach and plausible service route.

Status: Complete as a bounded anonymous public-library check. The exact 610AA SKU was not returned; the inspected 211CA1XX is a standard-height 3195C101 family record and is not a selected-SKU match. The Revit download path requests an email address; no address was submitted. The comparative family would not resolve the exact selected fixture, so no owner input is required to close this public-search milestone. See M131 and the research note; M-06/B remain unassigned.

## M132 - Furnish the upper-suite bath and test real circulation interfaces

Acceptance criteria:

- Start from M130's two ridge-axis comparison leaders only as study seeds; retain alternates and do not declare a preferred plan.
- Use only product-backed fixture dimensions from public sources already available or obtained without gated access; mark missing dimensions instead of fabricating them.
- Test a primary-only U-01/U-05 shared-wall interface, then show door location/leaf/swing, approach area, fixture use envelopes and plausible service zones as explicit proposals when the required dimensions are available.
- Screen documented fixture spacing; recheck sampled U-02 arrival, U-03 private-only topology and Connecticut conditional ceiling/EERO screens after any proposed placement. Separate arithmetic screens from real doorway, route and finished-headroom validation.
- Do not assign M-06 or any bathroom footprint until applicable clearance basis, door/approach and service routing have support.
- Keep this as source-bound 2D study geometry until an isolated Revit derivative can be safely validated; no selected-D baseline edits.

Status: In progress. M132's analyzer passes 25/25 checks with the M37 route report attached; both unchanged M130 layouts pass 4/4 route checks and all seven generated artifacts replay byte-for-byte. Their 0.5 ft U-01/U-05 separation is the wall-band convention used by M37 topology; the source upper-door matrix records a 3.5 ft nominal reservation along their 9 ft/10 ft contact bands. No room coordinates are changed, and the reservation is not a door design. The current 610AA infographic envelope and two research-only lavatory candidates pass 8/8 body-plus-21-in-strip cases under the stated 15-in WC-centerline and 30-in WC-spacing assumptions. The six ideal roof cases were recomputed over each unchanged U-05 block. M37 grid samples reach public edges at U-01/U-02/U-04 and do not reach a public edge at U-03; this is not physical door geometry or proof of U-03's private door route. Finished-face clearance, selected bath fixtures, service routing, headroom, code applicability, Revit placement and IFC remain open. See the M132 package and PROGRESS.md.

## M133 - Fit a dimensioned primary-bath product comparison

Acceptance criteria:

- Use manufacturer-documented nominal plan dimensions for a toilet comparison envelope, lavatory and alcove bathtub; preserve an exact-source hash for any downloaded family and do not treat an uninspected family as verified geometry.
- Place the proposal against both unchanged M130 U-05 block alternatives; check containment, fixture-body overlap, the preliminary 15-in WC centerline side screen, 21-in WC frontal strip, explicit 30-in WC-to-sink centerline assumption, and the source 3.5-ft nominal primary-bath interface reservation.
- Keep the 38 1/3 x 40 ft shell and all room/product/door choices proposal-only. Do not change selected-D or assign M-06/B.
- Generate source-bound JSON, CSV and SVG with a Windows PowerShell 5.1 replay whose outputs match byte-for-byte.
- Record inaccessible physical details and defer a selected door, wall assembly, tub access, fixture use, rough-in and service route until supported by exact product/Revit geometry and applicable criteria.

Status: Complete as a proposal-only envelope test. `Tools/analyze_m133_primary_bath_candidate.ps1` passes 12/12 checks on both unchanged M130 room-block alternatives; the current tracked package and `.local/revalidation/M142-M133-repeat/` replay match all four output artifacts byte-for-byte, and the SVG parses as XML. The analyzer hashes the source note for the M-06 610AA product comparison. The test fits a manufacturer-dimensioned KOHLER Entity 60 x 32 in bath envelope, KOHLER Tresham 24 x 19 1/2 in sink envelope, and the M-06 610AA toilet comparison envelope while preserving the source nominal entry band and stated preliminary fixture screens. Both KOHLER family files are quarantined under M134 with their hashes recorded, but neither has been inspected in Revit; physical family solids, bathroom entry/swing, use clearances, wall build-up, plumbing and code applicability are unresolved. No fixture/room selection, Revit/IFC validation or compliance result is made. See the M133 package, product-source note and PROGRESS.md.

## M134 - Inspect public KOHLER fixture families read-only

Acceptance criteria:

- Quarantine only direct, public manufacturer family files with source URL, retrieval time, byte count and SHA256; do not create an account or submit a form.
- Inspect the exact Tresham K-2844-4 and Entity K-26108 source families in Revit 2027 read-only; record category, hosting, type names, displayed parameters and geometry bounds/solid metrics, then close without saving.
- Compare measured family geometry to the manufacturer's published nominal product bounds and identify any SKU/hand ambiguity.
- Re-run M133 only with verified source measurements; keep owner-selected room blocks, selected-D and all family source files unchanged.
- Do not use the families to claim suitability, code compliance, service feasibility or construction readiness.

Status: In progress. Both public Kohler RFA files are retrieved and quarantined under ignored `.local/revit-pilot/family-intake/candidates/` with exact hashes in their manifests and this progress record. Revit inspection is still outstanding: the Windows computer-use host failed twice before exposing a screenshot (`foreground window did not report a process id`), and no Revit UI action was taken. Continue with read-only family inspection only when the host can be safely observed; no source-family save is permitted.

## M135 - Select a lead steep-roof case for upper-suite section study

Acceptance criteria:

- Reconfirm the M78 38 1/3 x 40 ft room-pack proposal, M79 nominal U-02 direct-hall approach reservation, M83 six gable comparisons, M103 Connecticut sloped-ceiling arithmetic and M133 bath-envelope proposal without changing their inputs.
- Replay outputs under ignored scratch paths and require byte-identical generated artifacts; parse generated SVG files as XML.
- Use only documented source geometry to compare roof-plane heights. Label any lead as a study priority, not an approved roof or shell dimension.
- Recheck Connecticut's currently published code-adoption status using the official DAS source; do not infer future permit applicability.
- Keep U-03 private-only, U-02 direct hall arrival and M-06/B unassigned. Do not modify selected-D, RVT, IFC or source RFAs.
- Record missing floor/eave datum, roof build-down, ceiling and verified fixture geometry before any code-facing section claim.

Status: Complete as a reproducibility and direction screen. M79 (10/10), M83 (13/13), M103 (10/10) and M133 (12/12) passed fresh Windows PowerShell 5.1 runs; M79, M83 and M133 outputs match checked-in artifacts, M103's 24-row JSON/CSV hashes match the retained outputs, and all three SVGs parse. The 12:12 ridge-X case has the strongest idealized sleeping-room ceiling envelope among the tested cases, so it is the lead for an explicitly parametric section study only. No roof or shell is selected. M136 is that next study; see `Architecture/M135_Upper_Suite_Steep_Gable_Direction_2026-10-30/README.md`.

## M136 - Parametric upper-suite section sensitivity

Acceptance criteria:

- Compare 12:12/ridge X, 12:12/ridge Y and 10:12/ridge X against the unchanged M78 room blocks; keep the 38 1/3 x 40 ft shell explicitly hypothetical.
- Treat finished eave-ceiling height, roof/ceiling build-down and datum offsets as named unknown variables; report threshold relationships without selecting numerical design values. Label any optional illustrative sweep as analyst-selected, not owner-approved.
- Preserve direct U-02 hall arrival and U-03 private-only topology. Keep M-06/B and fixture locations unassigned.
- Do not screen bath/shower headroom until exact family geometry and location are verified.
- Generate reproducible source-bound evidence, identify what input would resolve the largest uncertainty, and make no selected-D, Revit, IFC or source-family changes.

Status: Complete as a symbolic section sensitivity. `Tools/analyze_m136_upper_suite_datum_builddown_sensitivity.ps1` passes 8/8 checks and produces 12 source-bound room/case inequalities for the three requested roof comparisons; two isolated runs match byte-for-byte. The required finished-floor/eave separation is expressed as `z_eave - z_finished_floor >= threshold + b_eave`; all variables remain unassigned. The most useful resolving inputs are the floor-to-geometric-eave elevation difference and defined roof/eave-to-finished-ceiling build-up. A spatially varying ceiling requires a defined surface before area fractions can be calculated. No roof, datum, M-06/B assignment or code outcome is selected. See M136 in `PROGRESS.md` and its README.

## M137 - Refresh selected-D source and retained IFC evidence

Acceptance criteria:

- Run the documented `OwnerSelectedD` generator twice into ignored scratch directories; require 43/43 checks per run, valid plan SVG XML and byte-identical outputs between runs.
- Compare generated room geometry/check results with the checked-in derived package using semantic JSON comparison that ignores object key ordering; report source-fingerprint drift separately.
- Rerun `Tools/RevitPilot/validate_selected_d_ifc.py` against the retained Revit/IFC pair; require all checks to pass, IFC2X3 schema validation clean, three expected storeys and source-matching spaces.
- Keep the selected-D source and checked-in derived package unchanged. If their provenance fingerprints have drifted, document the cause and seek a separate design-baseline decision before refreshing tracked artifacts.
- Record that room-space IFC validation is not a complete physical architectural model or construction/code approval.

Status: Complete as a scratch regeneration and retained-export validation. The current source regenerated consistently in two isolated runs (43/43 each; all seven outputs byte-identical between runs), and selected-D checks/geometry are semantically equivalent to the checked-in derived package. Embedded fingerprints for `Requirements/Room_Program.md` and `Decisions/2026-10-27_Selected_Architectural_Direction_D.md` differ from the currently regenerated output; no tracked selected-D package was refreshed. The retained Revit/IFC2X3 pair passes 26/26 independent checks with zero errors. See M137 in `PROGRESS.md`.

## M138 - Revalidate the hypothetical upper-suite IFC derivative

Acceptance criteria:

- Run the independent upper-suite IFC validator twice against the retained isolated M78 Revit 2027 derivative, writing reports under ignored scratch paths.
- Require all 32 checks to pass, zero IFC schema issues and byte-identical validation reports.
- Confirm that room identities, areas, levels and plan boxes match the source study, and that the IFC remains the explicitly limited room-space test described in the source README.
- Preserve the RVT, IFC, selected-D source, incoming RFA files and remote state.

Status: Complete. Both fresh reports pass 32/32 and are byte-identical (SHA256 `90A86A2C56B8C2197DD5AD98BB86C416A7926980564FFE01AF209D61581164DF`). The host derivative remains one level and seven room-space blocks with no modeled walls, floors, stairs, doors, windows, roof, structure, MEP or fixtures; see M138 in `PROGRESS.md`.

## M139 - Prepare the M83 Revit host retry safely

Acceptance criteria:

- Rerun the complete offline RevitPilot suite and compile the M83 gable command using the existing repository-local .NET SDK; install no software.
- Verify the current build's SHA256, its project-local manifest path/AddInId, and the per-user manifest path/AddInId. Do not replace registration or trust settings as part of this readiness check.
- Inspect the live Revit prompt. Load Once is permitted only if the prompt identifies the current hash-verified project-local build; if it names a different build, leave it untouched and request owner direction.
- Separate build readiness from actual Revit/IFC host validation and retain the host check as open until a matching prompt is accepted and the export validator passes.

Status: Build readiness complete; host run remains open. The full offline suite passes 47/47. Rebuild completes with zero errors and two MSB3277 reference-version warnings. The current DLL SHA256 is `042BD6A602B6E970A2E7FBFA9C1DC08C22580AD2015A9227DEA85F13B30D5EC3`; its local manifest and the registered per-user manifest have the authorized AddInId and matching project-local assembly path. Revit still displays the older `build-m83-level-safe` DLL prompt (SHA256 `660BF4511E1DC51BE4CA3C74C8E386DC948438025B36DFA96551F18F4D3D59DF`), so no trust choice was made. See M139 in `PROGRESS.md`.

## M141 - Verify the exact 610AA public product resources

Acceptance criteria:

- Inspect only the selected SKU's public manufacturer product page, its directly linked technical resources and the distinctly labelled exact-SKU infographic; do not use authentication, create an account, contact sales or purchase anything.
- Record which dimensions are directly labelled for 610AA001.020 and distinguish them from a predecessor-series technical sheet linked from the current page.
- Do not infer a 610AA assembly from 211AA/3195A/4225A component numbers, or treat a generic/older RFA as the selected fixture.
- Preserve the current nominal plan-envelope basis only to the strength of the exact-SKU image; retain exact current-family/physical-solids, applicable-clearance, door/approach and service-route gates.
- Keep M-06/B unassigned and record any volatile availability display as dated and provisional.

Status: Complete as a public source-provenance check. The exact 610AA infographic continues to support its 19 x 30 1/4 in plan envelope, 30 7/8 in overall height, 17 in height with seat and 12 in rough-in. The current product page's linked spec and installation PDFs describe the predecessor 211AA series, so their component mapping is not evidence for the current SKU. The manufacturer page displayed Out of stock when checked; this is not treated as discontinuation. No RFA is linked. M133 was refreshed to hash-bind the M-06 toilet research note and its two fresh runs pass 12/12 with identical artifacts. See M141 in `Research/M06_Toilet_Options_2026-10-27.md`, the M133 package and `PROGRESS.md`.

## M142 - Recheck RevitCity for an exact Champion PRO family

Acceptance criteria:

- Search anonymous public RevitCity results for exact 610AA001.020 and listed 211AA/3195A predecessor SKUs; inspect public metadata for product identity, Revit version and dimensions.
- Do not enter credentials, create an account, or download from a result that states Login or Join to download.
- Reject generic toilet geometry as a 610AA substitute unless exact manufacturer/model identity and dimensions are documented.
- Keep M-06/B unassigned; record the public-source gate and any browser-session login assumption correction.

Status: Complete as an anonymous source check. No exact 610AA listing was exposed. The broad search returned only an unidentified, Revit Architecture 2011 `Standard Toilet / American Standard Toilet` record with no model dimensions, while its page requires Login or Join to download. The active Edge profile was visibly logged out, and no sign-in or download occurred. The family is not a fit candidate. M133 was replayed twice after this research-note update and still passes 12/12; see its current source hash and outputs. See M142 in `Research/M06_Toilet_Options_2026-10-27.md` and `PROGRESS.md`.

## M143 - Replay the pantry-side M-06 gross-envelope screen

Acceptance criteria:

- Replay `Tools/build_m120_m06_current_envelope_screen.ps1` twice to ignored scratch directories; require all checks and same-wall envelope calculations to pass and generated reports to match the checked-in M120 package byte-for-byte.
- Confirm the study remains tied to the exact 610AA infographic, hash-recorded Tresham family-symbol evidence and named research sink candidates.
- Report the 124 x 84 in/72.33 sf rectangle only as the owner-selected pantry-side gross search window, and keep its unassigned state explicit.
- Preserve the distinction between clearance arithmetic and actual wall/finish, installed geometry, door/approach, privacy, plumbing connections and service routing. Do not assign M-06/B.

Status: Complete as a gross-envelope sensitivity replay. Both PowerShell runs pass 14/14 checks and recalculate 16/16 research toilet/lavatory bounding-box pairs; each report/check file matches the checked-in M120 artifacts byte-for-byte. The result preserves the pantry-side first-search window at 124 x 84 in (72.33 sf), assignment false. No physical room fit or route is established. See M143 in `PROGRESS.md` and the M120 README.

## M145 - Screen owner-directed upper-suite interface opportunities

Acceptance criteria:

- Use only the unchanged M132 M130-NE-19 and M130-NE-24 room-block comparisons; verify M132's 25 checks and exact M37 route-report binding.
- Check shared-boundary lengths for U-01/C-PRIVATE, C-PRIVATE/U-02, U-02/U-03, U-03/U-06, U-06/U-04, and primary-only U-01/U-05 in both layouts.
- Compare each contact against the source 3.5 ft nominal upper-door reservation. Explicitly label U-02/U-03 as a new owner-directed adjacency using only a source-derived comparison proxy; do not edit the selected-D matrix.
- Preserve hall reach to U-01/U-02/U-04, U-03 private-route-only, both Jack-and-Jill links, and exclude the superseded U-03/C-UPPER door.
- Generate source-hash-bound JSON/CSV; replay twice into isolated paths and require identical outputs.
- Describe results as boundary opportunity arithmetic only; do not claim actual openings, door swing, approach, code, accessibility, service routing, Revit/IFC validation, or a selected plan.

Status: Complete as a schematic interface screen. M132 passes 25/25, M37 route validation passes 4/4, and M145 passes 15/15; two isolated runs match all outputs. All six boundaries fit the source 3.5 ft reservation arithmetic in both layouts, but M130-NE-24 has exactly 3.5 ft U-01/C-PRIVATE contact and zero end margin; NE-19 leaves 1.5 ft per end there. NE-24 gains 1 ft at the U-01/U-05 bath interface. M37 sampled routes reach U-02 north and U-04 west in both, with no public-side U-03 sample. The 3.5 ft value is a reservation proxy, not a clear opening or door design. See M145 in `PROGRESS.md`.

## M146 - Reconfirm selected-D source generation and retained IFC pair

Acceptance criteria:

- Run the documented `OwnerSelectedD` PowerShell generator twice into separate ignored scratch folders; require 43/43 geometry checks, valid SVG XML, and all seven artifacts byte-identical across runs.
- Confirm the selected-D source SHA256 remains unchanged.
- Independently rerun the retained Revit 2027 IFC2X3 validator without overwriting its RVT or IFC; require all 26 checks true, no errors, clean schema validation, three storeys, and 21 source-bound spaces.
- Record that this verifies a room-boundary/space study, not authored construction geometry or code compliance.

Status: Complete. Both generation runs pass 43/43 and their seven output hashes match; all SVGs parse. The retained IFC report passes 26/26, with IFC2X3 schema clean and zero errors. Source SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. The IFC still has no walls, floors, stairs, doors, windows, roof, structure, services or fixtures. See M146 in `PROGRESS.md`.

## M147 - Compare route-compatible M115 suite interfaces

Acceptance criteria:

- Bind the complete M115 archive to its independent audit and verify all audit checks and source fingerprints before analysis.
- Filter the route-tested candidate set by direct sampled arrival at U-01/U-02/U-04 and no sampled U-03 public reach, then independently reconstruct all six owner-directed room-link contacts.
- Compare contact lengths with the selected-D 3.5 ft nominal reservation as a clearly labeled proxy; separate northeast and northwest U-03 shell-edge groups and report zero-margin cases without ranking a layout.
- Generate hash-bound JSON/CSV and replay into two isolated scratch paths with byte-identical artifacts.
- Preserve the hypothetical 38 1/3 x 40 ft shell and incomplete-search limitation. Do not change selected-D or claim actual doors, code, clearance, accessibility, Revit/IFC, service routing or a selected plan.

Status: Complete as a comparison-only boundary screen. M147 passes 15/15 checks and reproduces byte-for-byte across isolated runs. It finds 73 route-compatible candidates (64 east+north, nine north+west), with all six contact reservations fitting arithmetically. Forty-four of 64 east+north layouts and three of nine north+west layouts have zero centered end margin at one or more contacts. No layout is selected; see the M147 report and README.

## M150 - Revalidate retained M-06 family-intake evidence by source hash

Acceptance criteria:

- Validate manufacturer intake provenance and each recorded Revit 2027 family source against its SHA256 without moving or rewriting source RFAs.
- Revalidate the retained family-intake measurements against an isolated byte-matched snapshot so a historical six-file run is not confused with today's five-file Incoming folder.
- Replay the M-06 gross-envelope screen twice and confirm its 16 research pairs remain unassigned and clearances remain a labelled preliminary screen.
- Document exact-family, toilet assembly, door/approach, code applicability, service-route and Revit trust-prompt limitations.

Status: Complete as evidence revalidation. Two snapshot runs verify all six source hashes and pass 155/155 integrity checks across 24 family types; the manufacturer-source validator passes. The M120 envelope screen passes 14/14 twice and keeps M-06/B unassigned. The exact 610AA family and full current-SKU assembly remain unavailable. See M150 in `PROGRESS.md` and its README.

## M151 - Check pantry-side M-06 window against arrival/hall adjacency

Acceptance criteria:

- Bind the current owner-follow-up study, selected-D study, room program, owner direction and M120 report by SHA256.
- Reconstruct schematic adjacency without converting block contact into a claimed door or route.
- Check direct M-05 entry/hall contact, the M-06 B links to pantry/dining, and the shortest room-block adjacency chain.
- Replay in separate PowerShell 5.1 output directories; require all checks, XML-parse the SVG and compare JSON/CSV/SVG hashes.
- Keep M-06 unassigned and preserve the owner-selected pantry-side window as the first research window; any alternative remains a separate sensitivity case.

Status: Complete as an adjacency-only finding. M151 passes 11/11 checks in two runs with byte-identical JSON, CSV and SVG. The 124 × 84 in B window contacts the pantry block and is 0.5 ft from dining; it has no direct contact with M-05 entry/hall. Its shortest block chain crosses living and dining and is not a walkable route. See `Architecture/M151_M06_Hall_Adjacency_Screen_2026-10-30/README.md`. M-06 remains unassigned.

## M152 - Revalidate owner-selected 38⅓ × 40 ft upper-suite exploration

Acceptance criteria:

- Reproduce the documented M78 bounded M37 search using the owner's selected exploration direction, without changing selected-D or treating the shell as an approved footprint.
- Validate the regenerated search independently and compare candidate room areas, route topology and search completeness with the retained M78 evidence.
- Confirm direct sampled hall arrival for U-01/U-02/U-04, private-only U-03 and both Jack-and-Jill links remain represented.
- Record what the larger test shell resolves and what remains unmodeled: actual walls/openings, stair/headroom, egress, privacy, floor/roof geometry, services and site-specific code review.
- Keep all generated artifacts in ignored scratch paths until exact replay and independent validation finish; do not alter the retained M78 package or selected-D.

Status: Complete as a fresh revalidation of the already documented hypothetical test. The replay passes 28/28 and reproduces all four M78 artifacts byte-for-byte; the independent candidate validator passes 112/112 and the retained Revit IFC2X3 export passes 32/32. The selected candidate reaches U-01/U-02/U-04 hall samples and retains private-only U-03, while six alternate search layouts show sampled U-03 hall-side reach and must not be confused with the retained candidate. Search remains capped/incomplete, and no shell dimension is approved. See `Architecture/M152_Upper_Suite_Larger_Shell_Revalidation_2026-10-30/README.md`.

## M153 - Measure a separate hall-edge M-06 search-window sensitivity

Acceptance criteria:

- Preserve the owner-selected pantry-side M06-B rectangle, its dimensions and unassigned status.
- Derive an alternative rectangle of the exact same gross size from the current M-05 hall edge and M-01 block edge using only the existing 0.5 ft schematic separation.
- Check shell containment, direct schematic hall adjacency, overlap against all existing room blocks and the inherited stair/lift comparison rectangles, and source bindings to selected D, owner direction and M120.
- Replay twice into ignored paths, compare JSON/CSV/SVG hashes and parse the diagram XML.
- Label the alternative as unassigned and identify the tradeoff: it satisfies hall-edge adjacency arithmetic while leaving the owner-selected pantry-side first-search window untouched.

Status: Complete as a gross-block sensitivity. Two PowerShell 5.1 runs pass 12/12 checks and match JSON/CSV/SVG byte-for-byte. The derived M06-H rectangle is x=5.5 ft, y=16.1667 ft, 10.3333 × 7 ft; it has 6.5 ft projected contact with M-05 across the nominal 0.5 ft gap, 10.3333 ft projected contact with living across the same gap, and zero overlap with current room and core rectangles. These are adjacency proxies, not walls, openings, fit, route or assigned room geometry. The owner-selected pantry-side B remains first in research priority and M-06 remains unassigned. See M153 report README.
## M154 - Recheck Connecticut M-06 clearance basis and current envelope replay

Acceptance criteria:

- Recheck Connecticut DAS's current-code and adoption-status pages and distinguish adopted requirements from draft or delayed future codes.
- Record the provisional 2021 IRC basis and exact fixture-spacing values only under a stated detached one-family assumption, with applicable amendment sources.
- Replay the current M120 source-bound gross-envelope screen twice; require 14/14 checks, 16/16 pair containment and byte identity with the retained package.
- Keep product geometry, actual wall faces, door/approach, accessibility scope, plumbing route and M-06 assignment explicitly unresolved.

Status: Complete as a current research-basis snapshot plus screen replay. Connecticut DAS still lists the 2022 CSBC based on 2021 model codes as current; its 2026 code effective date is delayed pending legislative approval. Both M120 replays pass 14/14 and match the checked-in report/checks hashes. The preliminary 15/30/21 in screen remains a reference only; no local applicability or compliance determination is made. See Architecture/M154_CT_M06_Code_Basis_Recheck_2026-10-30/README.md and Research/M06_Toilet_Options_2026-10-27.md.
## M155 - Search public sources for exact Champion PRO family and current assembly drawing

Acceptance criteria:

- Search the manufacturer page, current linked technical documents, RevitCity and BIMobject for the exact 610AA001.020 RFA or complete current-SKU plan/installation evidence.
- Inspect public metadata only; do not enter credentials, create accounts, buy or download gated files, or bypass access controls.
- Distinguish current-SKU evidence from predecessor (211AA) records and generic families.
- Record what was checked, exact public findings, and the remaining product-geometry gate without treating search absence as proof that no file exists anywhere.
- Keep M-06/B and any hall-edge alternative unassigned.

Status: Complete as a bounded public-source search. The manufacturer page still links a 2013 211AA.104 predecessor spec and a 2019 211AA-series installation guide. RevitCity lists a generic “American Standard Toilet” entry from Revit 2011 with no model number and requires login to download. Exact-SKU searches found no public indexed RFA. No gated file was fetched or account used. See Architecture/M155_Champion_Pro_RFA_Public_Source_Check_2026-10-30/README.md; the current 610AA assembly remains unresolved.

## M156 - Audit bedroom-candidate perimeter contact across M115 routes

Acceptance criteria:

- Bind the M115 candidate archive and search to its independent audit and manifest, plus the selected-D source, room program and existing Connecticut R310 research note.
- Reconstruct the 73 M147-compatible room-block candidates and measure U-01/U-03/U-04 contact with the owner-authorized hypothetical shell outline.
- Record edge and candidate counts without calling shell contact a wall or opening; preserve bedroom classification and code applicability as unresolved.
- Run twice in isolated scratch directories under Windows PowerShell 5.1 and require 16/16 checks plus byte-identical JSON/CSV artifacts.
- Leave selected-D, Revit/IFC, source RFAs and shell/layout selections untouched.

Status: Complete as a bounded geometry screen. Two PowerShell 5.1 runs pass 16/16 and match all outputs. Across 73 route-compatible M115 candidates, U-01 has zero test-shell perimeter contacts, U-03 has 73, and U-04 has 28. This identifies a primary-bedroom edge-access gap in the U-03-seeded candidate set; it does not establish an exterior wall, EERO, sleeping-room classification or compliance. See `Architecture/M156_M115_Sleeping_Room_Perimeter_2026-10-30/README.md`. M157 will test primary-bedroom perimeter-rooted search seeds without changing default search behavior.

## M157 - Search M37 from U-01 perimeter roots

Acceptance criteria:

- Add an opt-in U-01 perimeter-root mode covering all four hypothetical shell edges and reproducible along-edge seed fractions; reject incompatible flag combinations.
- Reproduce current M37 default artifacts with both the pre-change generator and the updated generator to prove byte-for-byte default compatibility.
- Search the owner-authorized 38 1/3 x 40 ft exploration shell with direct U-02 hall arrival, private-only U-03 public access, both Jack-and-Jill links and five sampled hall points per side.
- Repeat the bounded search and require identical generator artifacts; independently verify every route archive row for source room inventory/orientation, shell containment, non-overlap and six nominal room contacts.
- Quantify exterior-outline contact for U-01/U-03/U-04 and keep shell outline distinct from an authored exterior wall or EERO.
- Preserve selected-D, source RFAs, Revit model, IFC and remote state.

Status: Complete as a reproducible bounded search diagnostic. The default M37 pre-change and post-change outputs match byte-for-byte on current inputs. Two U-01 perimeter-root runs match all five generator artifacts; M37 passes 29/29. The independent archive audit passes 20/20 across 766 route-tested layouts. U-01 touches the hypothetical outline in 766/766, U-03 in 0/766, and U-04 in 20/766; zero layouts meet all required sampled public routes while preserving private-only U-03. The bounded search is incomplete, and no layout is selected. See `Architecture/M157_U01_Perimeter_Root_Search_2026-10-30/README.md`.

## M158 - Require joint perimeter contact for bedroom-capable blocks

Acceptance criteria:

- Add a separately opt-in M37 room-placement constraint requiring shell-outline contact for U-01, U-03 and U-04 while retaining U-01 perimeter-root seeds and leaving default search output unchanged.
- Validate that every retained complete layout meets the three requested outline contacts, all source dimensions, six topology contacts, containment, non-overlap and stair/lift proxy constraints.
- Evaluate sampled U-01/U-02/U-04 hall reach and no sampled U-03 public-side reach; describe the search as bounded/incomplete if its cap is reached.
- Replay the joint-contact search and independently audit its artifacts; make no candidate, shell, EERO, window, roof or code applicability selection.
- Leave selected-D, RFAs, Revit/IFC and remote state unchanged.

Status: Complete as a bounded search diagnostic. The opt-in M37 constraint preserves all default artifacts: the modified default replay passes 28/28 and exactly matches the pre-M157 search/check/SVG/manifest hashes. Two joint-contact runs pass 31/31, match all five artifacts, and record two complete packings after 2,865/4,800 nodes. The independent archive audit passes 16/16 twice with byte-identical JSON/CSV outputs; the independent candidate validator passes 115/115 for the best record. Both archived candidates have U-01/U-03/U-04 outline contact, valid source dimensions and six source topology links, shell containment, non-overlap and clear lift/approach proxy rectangles. One meets the sampled U-01/U-02/U-04 route goals while keeping U-03 away from sampled public sides; the other does not. The search remains bounded/incomplete; no layout is selected and outline contact is not an exterior wall, opening or EERO. See `Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31/README.md`.

## M159 - Compare the M158 joint-contact candidates against ideal gable planes

Acceptance criteria:

- Bind both M158 archived room-block arrangements and their source hashes; do not promote either candidate or shell.
- Re-evaluate room-block footprint positions against the existing idealized 8:12, 10:12 and 12:12 gable comparison set on both ridge axes, using only documented block dimensions and source coordinates.
- Report relative roof-plane rise at perimeter-contact edges and compare candidate exposure without inventing floor/eave datum, ceiling build-down, structural depth or window dimensions.
- Re-run the arithmetic/report generation twice and require byte-identical outputs plus source-bound validation checks.
- State explicitly that the result is a geometry sensitivity, not finished headroom, an opening/EERO test, code compliance or a roof selection.
- Preserve selected-D, M-06/B, incoming RFAs, Revit/IFC and remote state.

Status: Complete as relative geometry sensitivity. The new source-bound PowerShell analyzer passes 15/15 checks on both candidates and all six M83 gable planes. Two Windows PowerShell 5.1 runs reproduce the 84-row JSON/CSV outputs byte-for-byte. The M158 candidates have identical U-01/U-03/U-04 blocks and differ only in U-05. Ridge X puts U-01/U-04 at ideal opposite eaves; ridge Y puts U-03/U-04 at the ideal west eave. At least two bedroom-capable blocks therefore have zero relative plane rise at an ideal eave for every tested axis/pitch case. This is an eave/wall/ceiling coordination sensitivity, not finished headroom, a room suitability result, an EERO finding or a design rejection. No roof, layout, datum or dimension is selected. See `Architecture/M159_M158_Gable_Exposure_2026-10-31/README.md`.

## M160 - Find public product and installation evidence for exact M-06 fixtures

Acceptance criteria:

- Recheck manufacturer-published current 610AA001.020 product, specification, installation and public BIM/RFA sources; capture direct source links, access date and exact SKU identity.
- Distinguish current-product evidence from 211AA predecessor documents and generic third-party families; do not infer missing assembly or plan dimensions.
- Inspect public metadata without account creation, credentials, purchase or gated-download bypass.
- Compare source findings with the preserved Incoming RFA inventory and M120's provisional geometry sources; keep all originals hash-stable.
- Keep M-06/B unassigned until exact installed fixture and lavatory geometry, applicable clearance basis, real door/approach, and plausible service routing can be checked together.
- Preserve selected-D, Revit/IFC and remote state; record the Revit trust-prompt mismatch without loading any unverified DLL.

Status: Complete as a dated public-source recheck. On 2026-10-31, the current American Standard page reconfirmed 610AA001.020 and its listed included seat/installation kit, 12-in rough-in and 17-in seat height. Its live technical links still resolve to the 2013 211AA.104 predecessor specification and 2019 211AA/211BA/211CA installation guide. Public exact-SKU RFA/Revit/BIM/CAD/3D searches produced no indexed exact-current family or current assembly drawing. No account, form, credential, paid source or gated download was used. Search absence is not proof that none exists in a registered/unindexed source. Keep M-06/B unassigned; see `Architecture/M160_610AA_Public_Model_Source_Recheck_2026-10-31/README.md`.

## M161 - Read-only inspect the exact-source M-06 families in Revit

Acceptance criteria:

- Before relying on Revit host evidence, verify the authorized per-user AddInId, manifest path and project-local DLL SHA256. If a security prompt appears, choose **Load Once** only when its path matches that exact verified build.
- Use existing source-hash-bound Family Intake reports for previously inspected M-06 candidates; inspect the quarantined KOHLER Tresham K-2844-4-0 RFA in Family Editor read-only, without saving, editing or overwriting its source.
- Record category, displayed type dimensions/formulas, visible assembly and the limits of symbol-local or unhosted evidence; do not infer installed bounds or connections from nominal type parameters.
- Make a disposable derivative only if placement testing is needed; preserve the selected-D baseline and all Incoming source RFAs.
- Keep M-06/B unassigned until exact selected toilet and lavatory geometry, applicable clearance basis, real door/approach and plausible service route support a combined fit.
- Preserve Revit/IFC compatibility; report prompt mismatch, unavailable sources or inspection failures without bypassing trust/access controls.

Status: Complete as a read-only source review and host-state revalidation. On 2026-10-31, a fresh Revit 2027.3 process loaded the exact manifest DLL from the current worktree (SHA256 `042BD6A602B6E970A2E7FBFA9C1DC08C22580AD2015A9227DEA85F13B30D5EC3`); no startup trust prompt appeared and no trust setting was changed. The exact hash-pinned KOHLER Tresham source was opened, visually checked in Preview and Reference Level, and closed without saving; its SHA256 remained unchanged. This confirms existing M119 Family Editor findings for this source, not new host-placement or fit evidence. The existing Revit family-intake run `20261030T195404237Z` was independently replay-validated at 101/101 checks, covering five family results and 14 measured types, including bowl-only `3195A101.020` geometry and the legacy Evolution host probe. It does not provide the current 610AA full-toilet assembly. Existing hash-bound intake evidence for other M-06 candidate RFAs remains in M110/M120/M150. No exact-current 610AA full-toilet RFA/assembly geometry is available from reviewed public sources, so M-06/B remains unassigned. Door/approach, applicable clearance and plausible service routing are still unverified.

## M162 - Translate Connecticut sloped-ceiling thresholds to M158 gable cases

Acceptance criteria:

- Bind both M158 route-tested room-block candidates, their independent audit, the M83 six-case 8:12/10:12/12:12 gable options, the CT code research note, Room Program and selected-D source by SHA256.
- For U-01 through U-04, compute minimum and median ideal roof-plane rise over each candidate room rectangle for all six ridge/pitch cases; independently validate the median against rectangle-area proportions.
- Express the conditional eave-height inequalities for an entire modeled block at 5 ft and at least half the modeled block at 7 ft. Keep floor/eave separation and ceiling build-down symbolic; do not evaluate pass/fail.
- State that the Connecticut 2022 CSBC amended 2021 IRC R305.1 is a preliminary basis subject to room/use classification, municipality, permit cycle and required-floor-area interpretation. The full schematic rectangle is only an explicit proxy.
- Generate deterministic PowerShell JSON/CSV outputs twice and require byte-identical results and passing source/arithmetic checks.
- Preserve both M158 candidates, selected-D, Revit/IFC, source RFAs, and all owner design choices; do not select a roof or claim code compliance.

Status: Complete as a conditional geometric sensitivity. `Tools/analyze_m162_m158_ct_ceiling_thresholds.ps1` passes 16/16 source and arithmetic checks and computes 48 room/candidate/roof rows across the two M158 arrangements, four upper rooms and six M83 gable cases. An independent median-area bisection check passes for every row; two PowerShell 5.1 runs reproduce JSON SHA256 `F16921DA3F2BEA533D705D9AE8B7236B29000D644CE4EE5E8B1ACFD6EC60A09D` and CSV SHA256 `CF487F1FB539E6A0AB605F58F07E4C3F8B47761669C7DC278B89FC5F0749D903` byte-for-byte. Assuming the entire modeled block represents required floor area, the 5 ft full-block proxy controls the worst bedroom-capable block in every pitch/ridge case because a bedroom-capable block touches an ideal eave. Steeper planes improve relative interior rise but do not remove that boundary constraint. No floor/eave datum, ceiling build-down, formal code classification, legal required area, code applicability, roof selection, or pass/fail result is assigned. See `Architecture/M162_M158_CT_Sloped_Ceiling_Thresholds_2026-10-31/README.md`.

## M163 - Extend the bounded M158 route/perimeter search

Acceptance criteria:

- Preserve the checked-in M158 search, candidates, selected-D, Revit/IFC, and source RFAs; perform each higher-budget generator replay in ignored scratch outputs and retain only the independent audit summary in the M163 report package.
- Repeat the exact owner-authorized 38 1/3 x 40 ft exploration case, direct U-02 hall arrival, private-only U-03 public access, required U-01/U-03/U-04 outline contact, and the existing M158 search settings, increasing only the node budget from 4,800 to 9,600.
- Independently audit every retained route-tested layout for source room inventory/orientation, dimensions, containment, non-overlap, required outline contacts, nominal topology links and sampled hall reach/privacy constraints.
- Report expanded nodes, cap/incomplete state, complete candidate count and whether any new candidates meet sampled route goals; compare candidates against the retained M158 set by normalized source-room coordinates and orientation.
- Compare any route-qualified alternatives against the existing M83 ideal gable cases using documented room-block coordinates only; keep eave/floor datum symbolic and do not derive a headroom pass/fail.
- Keep all layouts as unselected schematic room-block proposals; do not infer exterior walls, doors, windows, EERO, code compliance, structural adequacy or a selected roof.

Status: Complete as a bounded geometry diagnostic. Two PowerShell 5.1 M37 runs pass 31/31 and reproduce all five search artifacts byte-for-byte at NodeLimit 9,600. Each expands 3,065 nodes before per-seed caps, records 102 distinct complete route-tested layouts and remains explicitly incomplete. The independent M163 audit passes 16/16 on both runs; all 102 preserve the required U-01/U-03/U-04 outline contacts and keep U-03 off sampled public hall sides, while 41 reach every sampled side for U-01/U-02/U-04. Both retained M158 candidates reappear in the expanded set. The independently checked best candidate passes 115/115. A separate roof sensitivity passes 12/12 in two runs across 41 route-qualified layouts, three bedroom-capable blocks, six M83 ideal gables and one retained M158 baseline (756 rows). In every case, the lowest worst-bedroom conditional effective-eave threshold among expanded candidates equals the M158 route-qualified baseline at 5 ft under the full-block required-area proxy; higher pitch does not reduce that controlling threshold. No candidate or roof is selected, and no authored wall, door, window, EERO or code conclusion follows. The audit and roof JSON/CSV plus reproduction instructions are in `Architecture/M163_Expanded_Upper_Suite_Search_2026-10-31/README.md`; full generator archives remain in ignored `.local/revalidation/M163-expanded*` folders.

## M164 - Search upper-suite blocks for gable-end-only perimeter contacts

Acceptance criteria:

- Repeat the exact M163 route/privacy and room-block setup with the deterministic M37 node budget increased to 19,200 and layout cap raised to 20,000 so the larger search is not truncated by candidate count; write generator output to ignored scratch paths.
- Independently audit all complete route-tested records and compare normalized room-coordinate keys against M163; do not overwrite either retained candidate package.
- For ridge-X and ridge-Y alternatives, count route-qualified layouts where U-01, U-03 and U-04 each contact only a gable-end shell edge and none contacts an ideal eave edge; identify the side contacts explicitly.
- Recompute the same conditional ideal roof exposure for any such candidates against the six M83 gable options, using only M162's full-block-area proxy and leaving absolute floor/eave datum and build-down symbolic.
- Report when no qualifying candidate is found without implying infeasibility; keep every layout and roof unselected and preserve selected-D, Revit/IFC, source RFAs and remote state.

Status: Complete as a finite-grid diagnostic. Two M37 runs pass 31/31 and reproduce all five artifacts at NodeLimit 19,200 and LayoutLimit 20,000. The configured seed/contact search exhausts in 3,122 nodes and records 120 unique route-tested layouts; it does not reach the node cap, though it remains limited to the fixed root seeds, contact samples and grid. The reused independent route/perimeter verifier passes 16/16 twice and the M37 best candidate passes 115/115. Forty-eight layouts meet every sampled U-01/U-02/U-04 public-side goal while keeping U-03 private; all 102 M163 candidates recur, alongside 18 new candidates. The roof analyzer passes 12/12 twice across 882 room/candidate/roof rows. None of the 48 route-qualified options places all three bedroom-capable blocks on gable ends without an ideal-eave contact in either ridge axis; the best worst-bedroom conditional threshold remains 5 ft for all six pitches/axes and ties M158 under the full-block required-area proxy. This does not prove geometric impossibility or code compliance. No room, roof or physical model is selected. See `Architecture/M164_Gable_End_Opportunity_Search_2026-10-31/README.md`.

## M165 - Repeat host validation of M83 gable-massing IFC

Acceptance criteria:

- Verify the current worktree, exact per-user RevitPilot registration and project-local DLL hash before host execution; use only the matching trust prompt's **Load Once** choice.
- Regenerate the source-bound M83 comparison inputs after research-source updates and require passing checks plus byte-identical outputs across isolated and documented runs.
- Run the six-case M83 comparison twice in separate disposable Revit projects; preserve selected-D source, Incoming RFAs and remote state.
- Independently validate both IFC2X3 exports, including schema, proxy-case identity, geometry units/bounds/area and expected representation limits; compare normalized geometry across runs.
- Repair the independent IFC gate where observed exporter/library behavior falsifies an assumption, and cover the repaired behavior with offline tests.
- Record any incidental disposable host study and its independent validation; do not imply M83 is a selected roof, native roof assembly or complete house.

Status: Complete for the reproducible comparison workflow. Three PowerShell 5.1 runs (two scratch outputs and the documented destination) pass 13/13 and reproduce all four M83 artifacts byte-for-byte. Two exact-DLL Revit 2027.3 runs produced separate RVT/IFC2X3 derivatives; the independent validator passes 21/21 for each with zero schema issues, six expected proxy meshes, and matching normalized case bounds and triangulated areas. The validator now requests IfcOpenShell project-unit geometry and binds each Revit-exported proxy Tag to the DirectShape identity in the saved manifest. The full offline suite passes 49/49, including unit coverage for both corrections. A separate M78 upper-suite derivative was created while navigating Revit's compact add-in menu and independently passes 32/32 checks; it is isolated and documented in `PROGRESS.md`. Revit is open on the second disposable M83 derivative. M83 remains six zero-thickness/open-surface pitch/ridge comparisons on a hypothetical 38.333333 x 40 ft test outline. No selected roof, physical construction geometry, structural specification or code conclusion follows. See `Architecture/M83_Gable_Massing_38_333333x40_2026-10-30/README.md`.

## M166 - Recheck current Connecticut code adoption status and refresh roof studies

Acceptance criteria:

- Recheck Connecticut statewide adoption status against current official DAS pages and the adopted-code text; preserve municipality, occupancy classification and permit date as unresolved.
- Record the source-check date and official direct links without making a project-specific compliance conclusion.
- Refresh the M83 roof options, M159 room exposure and M162 conditional sloped-ceiling outputs after the bound research-note fingerprint changes.
- Require repeated PowerShell 5.1 checks and byte-identical artifacts; independently rerun the retained M83 IFC validators to ensure the source-note update did not invalidate host evidence.
- Preserve selected-D, owner RFAs, all design selections and remote state; keep roof geometry comparative and unselected.

Status: Complete as a dated statewide source recheck and dependent-artifact refresh. DAS's adoption-process page, code-history page and official 2022 CSBC text were checked on 2026-10-31. The 2026 code effective date remains delayed pending Legislative Regulation Review Committee approval; the 2022 CSBC remains identified by DAS as currently in effect. This does not establish the future project's municipality, occupancy or applicable permit cycle. The updated research note drives three M83 generator runs (13/13 each, all four artifacts byte-identical), three M159 runs (15/15 each, JSON/CSV byte-identical), and two M162 runs (16/16, JSON/CSV byte-identical). Both existing M83 host IFC2X3 derivatives were revalidated at 21/21 after the source refresh. No model geometry, selected-D source, Incoming RFA, roof choice or remote state changed. See `Research/Connecticut_Roof_Code_Research_2026-10-28.md` and the linked M83/M159/M162 reports.

## M167 - Reverify the public Champion PRO bowl family and its boundary

Acceptance criteria:

- Locate the source product page and direct file without account creation, sign-in, payment or gated-access bypass; record the product SKU, family scope, source URL, retrieval hash and date.
- Compare the retrieved RFA byte-for-byte with any preserved Incoming source before treating it as new intake evidence.
- If it is hash-identical to a preserved source, use its existing Revit intake report and perform any requested Revit inspection read-only; close without saving and confirm the hash remains unchanged.
- Distinguish bowl geometry from the selected 610AA complete toilet; do not infer a current tank/seat crosswalk from predecessor-series parameters or dimensions.
- Preserve the selected-D baseline, Incoming RFAs, Revit host derivative, and unassigned M-06 room; record remaining fit gates.

Status: Complete as a public-source and read-only family recheck. The LIXIL Pro page lists white bowl SKU `3195A101.020` and a direct public Revit download, explicitly describing a bowl-only product with tank sold separately. The downloaded RFA (487,424 bytes; SHA256 `F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393`) exactly matches the already preserved Incoming file. The source-bound Revit 2027.3 intake report independently passes 101/101 and records three types; `3195A101.020` measures 13.9997 x 29.0628 x 17.0953 in from six positive-volume solids in symbol coordinates. A new read-only Family Editor 3D-view inspection was closed without saving; source hash remains unchanged. The complete 610AA assembly mapping, actual fit, applicable clearance, door/approach, lavatory and services remain open. M-06/B stays unassigned. See `Research/M06_Toilet_Options_2026-10-27.md` and M160.

## M168 - Compare steep-gable ridge orientation by bedroom eave contacts

Acceptance criteria:

- Refresh M164's repeated roof-sensitivity report against current M83, M158, M164 audit/archive and selected-D fingerprints; require identical report artifacts across two runs.
- For the 48 M164 route-qualified room-block proposals, count U-01, U-03 and U-04 ideal eave contacts for the steepest existing 12:12 case under both ridge axes.
- Bind every candidate/ridge result to M164's independent route/perimeter audit and require exactly one row per bedroom-capable block.
- Produce deterministic PowerShell JSON/CSV outputs twice and report distribution by number of bedroom-capable blocks at an ideal eave.
- Label all candidates unselected; do not infer finished headroom, code outcome, wall/window/door design, or physical roof construction.

Status: Complete as a comparative geometry diagnostic. Two current-source M164 roof replays pass 12/12 and reproduce identical 882-row JSON/CSV output; JSON SHA256 `F4A79EE7F2A9666D550A274F0579BAD37BD3F23EABB3E8A6CD205E50EFFBB593`, CSV `8D62CCF6E9BEEDD412D67AA7DF02A3876A036F5A008CF5FF7831305049E44520`. The new M168 PowerShell analyzer validates the current source fingerprints, M164's 120-layout audit, exact route-qualified candidate set, and per-room coverage; two runs pass 18/18 and match JSON/CSV byte-for-byte (`C509D41B8CF69DA5730F85DC0AB06F0C7584F05EDE88573152E19E8A3213F914` / `39AF18A6A700C55307760E103360A0E53B6536D86CEE71D4A9263B6051BCE5A6`). At 12:12, ridge X has two of three bedroom-capable blocks at an ideal eave in 48/48 layouts. Ridge Y has one in 24/48 (always U-03 at west) and two in 24/48 (U-03 and U-04 west). No case keeps all three off ideal eaves. No ridge, layout, roof, code result or headroom condition is selected. See `Architecture/M168_M164_Ridge_Orientation_Screen_2026-10-31/README.md`.

## M169 - Rank conditional steep-gable eave thresholds by ridge axis

Acceptance criteria:

- Join current M164 12:12 room-threshold rows to M168's 48 route-qualified candidates on both ridge axes, checking current M83 and selected-D source hashes.
- Independently compare each bedroom block's ideal eave edge labels and aggregate contact count between M164 and M168; reject missing, duplicate or incomplete candidate/axis records.
- Report how many blocks in each candidate reach the full-block 5 ft threshold proxy, and retain room-specific conditional thresholds without evaluating code pass/fail.
- Produce JSON/CSV twice in ignored scratch outputs and require 17/17 source/geometry checks and byte-identical artifacts before retaining the package.
- Keep the test envelope, all layouts, ridges and pitches unselected; preserve selected-D, host exports, source RFAs and remote refs.

Status: Complete as a conditional arithmetic comparison. `Tools/analyze_m169_m168_ceiling_thresholds.ps1` checks source fingerprints, unique keys, 288 room rows, 96 candidate/axis groups, exact eave-edge labels and counts, and the observed threshold distributions. Two PowerShell 5.1 scratch runs and the retained-package run each pass 17/17 and reproduce JSON SHA256 `016FF1360B8FF025055E1FBC5E1743CC13B35BE49E587D1A4A57AE4086302F2D` and CSV SHA256 `A3207822586BF2FE5D774961D1C548DD8BB2C4C81CD040C49D4D179C004A9373`. At 12:12, ridge X has two blocks at the conditional full-block 5 ft threshold in all 48 candidates; ridge Y has one in 24 and two in 24. In the one-block ridge-Y group, U-03 is the limiter; U-04's threshold is 4.166667 ft in 16 cases and 3.333334 ft in 8. These remain full-room-rectangle area proxies with symbolic datum/build-down, not headroom or code results. The same verification also reproduced selected-D geometry and revalidated its IFC; see M169 in `PROGRESS.md` and the package README. Revit's fresh process is currently obstructed by the trial overlay; its saved disposable M83 primary/backup mismatch is documented and preserved.

## M170 - Revalidate the BIM baseline after the Revit refresh

Acceptance criteria:

- Confirm the sandbox branch and preserve the three pre-existing untracked Incoming RFAs; do not change history or remote refs.
- Regenerate selected-D into two ignored scratch directories using the documented PowerShell 5.1 workflow; require 43/43 geometry checks, valid SVG, and byte-identical seven-file outputs.
- Re-run the exact saved-RVT/IFC-bound selected-D IFC2X3 validator and the available M78/M83 host IFC validators, including M83-B only from the preserved RVT whose fingerprint matches its IFC export.
- Re-run the existing offline RevitPilot regression suite; record all current outputs and hashes without rewriting retained host exports.
- Check Revit's post-refresh state and exact project-local add-in registration. Do not bypass the trial overlay or load an unverified DLL.
- Keep selected-D, all RFAs, the mismatched M83-B primary, its original `.0001.rvt`, `.0002.rvt`, and IFC intact; make no roof/layout selection or code claim.

Status: Complete as a source/export regression check. On 2026-10-31 the sandbox branch was `codex/house-design-sandbox`; the three pre-existing untracked Incoming RFAs remained unmodified. Two fresh Windows PowerShell 5.1 selected-D generator runs each pass 43/43, parse all three plan SVGs, and produce identical seven-file artifact sets. The selected-D study source SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. The retained selected-D Revit/IFC2X3 run `20261030T002652845Z` passes 26/26 with zero errors and a clean schema; the independent report SHA256 is `449B98D7720BB10DCD53BA999A99AA6DD207950783C43EB3CFCA0800085C079B`. M78 passes 32/32 (report SHA256 `90A86A2C56B8C2197DD5AD98BB86C416A7926980564FFE01AF209D61581164DF`). M83-A passes 21/21 (report SHA256 `F0EAAC76625EAA898BA6E22FCFAF693C91D6BE4BB8169C31D4E82CF584938F59`). M83-B passes 21/21 from the preserved exact `.0001.rvt`/IFC pair (RVT SHA256 `DEE49362175AA94B63E67C08A227C0F2DD269FD1B7957F87AE7BEB6718562204`; IFC SHA256 `AD4F468FBCC9DCB5D969FAF41499CA05DE94B020C08AF41B2EF83788BFAF9373`; report SHA256 `B4A3239F653DC0FD2F220453E87B6977436D265D4C28981BD3EA21EC10E2743F`). The offline RevitPilot suite passes 49/49. Revit 2027 remains running at its trial-introduction overlay, no model is open, and the new process's RevitPilot load is unverified. No retained RVT/IFC, selected-D source, Incoming RFA, remote ref or Git history changed. See the M170 revalidation reports under ignored `.local/revalidation/`.

## M171 - Map upper-suite wall/door interface opportunities

Acceptance criteria:

- Consume M164's route-tested candidate archive and independent audit; verify their hashes, current selected-D/owner-follow-up inputs, and the M37 generator fingerprint.
- Retain only the 48 proposals that reach sampled public goals for U-01/U-02/U-04 while keeping U-03 off sampled public hall sides.
- For all six required internal room links, independently derive the projected face-overlap interval, orientation, and interstitial gap from source room rectangles; check that the source-defined 0.5 ft nominal wall allowance is preserved.
- Report the U-01/U-02/U-04 public-hall-reachable room sides and rank only descriptive block geometry; do not infer a door, clear width, privacy, egress, or accessible route.
- Run the analysis twice against separate matching M164 archive/audit outputs and require 17/17 checks plus byte-identical JSON/CSV. Preserve selected-D, Revit/IFC, Incoming RFAs, all design decisions, and unselected status.

Status: Complete as a deterministic room-interface diagnostic. `Tools/analyze_m171_upper_suite_interface_options.ps1` passes 17/17 against two independent M164 archive/audit pairs and the retained output; JSON SHA256 `E2569D7F77EF699C85EDA4376D1C9FF4056001AAF86CB1553CE9133B75D6ECDF` and CSV SHA256 `86AEB8D19704E584A3CC8A7D79390F7B79D7CDE9434FF950568E798794F1D91A` match byte-for-byte. All 48 route-qualified room-block proposals contain six interfaces separated by M37's documented nominal 0.5 ft wall allowance. Face-overlap spans are 10 ft for U-01/C-PRIVATE and C-PRIVATE/U-02, 3.5 ft for U-02/U-03, 12 ft for both U-06 Jack-and-Jill links, and 9 or 10 ft for U-01/U-05. U-02 has sampled hall-reachable east/north sides in all candidates and a south side in 24; U-01 and U-04 each have east reach in all; U-03 remains private. These are room-block interfaces and four-foot route-grid results, not openings or clear routes. No candidate, door, wall or shell is selected. No Revit, IFC, selected-D or Incoming RFA changed. See `Architecture/M171_Upper_Suite_Interface_Options_2026-10-31/README.md`.

## M172 - Couple compact kitchen and dining target constraints - 2026-10-31

Acceptance criteria:

- Bind the owner-directed M-02 14 x 12 ft and M-03 11 x 10 ft study targets, current island decision, kitchen/dining spec, and verified selected-D source hash.
- Derive the documented 12 ft 6 in perimeter module run and 13 ft 6 in counter/island/half-wall section; evaluate both orthogonal arrangements instead of treating each axis independently.
- Check the documented 8 ft island with 42 in end-clearance arithmetic and the dining table/chair envelopes at minimum and preferred clearances; compare the larger selected-D test blocks only as a numeric control.
- Emit source-hashed JSON, CSV, SVG and checks from a PowerShell 5.1 script; require 22/22 checks, valid SVG XML, and identical artifacts across two scratch replays and the retained package.
- Preserve selected-D, Revit/IFC, incoming RFAs and remote state; report the integrated open-plan route as unresolved and make no dimension, placement, or compliance selection.

Status: Complete as a coupled dimensional screen. Three PowerShell 5.1 runs (retained package plus two isolated scratch directories) pass 22/22, and all four generated artifacts match byte-for-byte; SVG XML parses in all three. In the 14 x 12 ft M-02 target, aligning the 13 ft 6 in section to the 14 ft axis leaves 6 in but the perpendicular 12 ft 6 in run misses by 6 in. Rotating it lets the run fit along 14 ft but leaves the 12 ft axis 18 in short of the section. The 15 ft island/end-clearance span exceeds the 14 ft and 12 ft axes by 12 in and 36 in, respectively. M-03's 11 x 10 ft target contains the minimum 9 x 11 ft table envelope in one orientation with 12 in remaining on the 10 ft axis; the preferred 10 x 12 ft envelope misses the 11 ft axis by 12 in. The larger selected-D room blocks numerically contain the individual envelopes, but they are not clear-interior or placement evidence. This does not test the integrated kitchen/dining/living layout, occupied route, actual porch opening, appliance door envelopes or half-wall placement; no plan or input is selected. See `Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/README.md`.

M173 has since repaired the larger-block living-to-porch route screen and exposed an assumed stool-occupancy shortfall at the selected-D island/counter spacing. The compact 14 x 12 ft kitchen target, its occupied seating geometry and a connected island-work route remain unsolved.

## M173 - Repair the social route and bind downstream kitchen studies - 2026-10-31

Acceptance criteria:

- Reproduce the prior M18 script from the current branch parent in an ignored scratch directory and independently intersect its documented route corridor with the perimeter fixture modules; record the false-negative collision evidence without altering the selected-D source.
- Replace the invalid route proposal with axis-aligned 36 in living-to-porch corridor options that cross the proposed living opening, go around modeled fixtures/furniture, cross the nominal porch-door reservation and extend into the porch test rectangle.
- Check both route variants against every modeled perimeter module, island, explicitly assumed stool-occupancy proxy, dining table/chairs and proposed half-wall; check centerline orthogonality, 36 in corridor cross-section and SVG validity.
- Correct the island-to-counter/post-stool clearance calculation to use the modeled counter front. Label the 24 in stool plan-depth as an assumption because the source specifies two stools and a 12 in overhang but not occupied-use depth; do not claim an island-to-porch route.
- Regenerate the B-first candidate and downstream M19/M21 screens; replay in two ignored scratch directories, require matching output bytes, source fingerprints and existing check gates.
- Preserve selected-D, existing RVT/IFC and untracked Incoming RFAs; do not author walls/openings or select a layout.

Status: Complete as a repaired, unapproved plan-coordinate study. Replaying the exact prior M18 script passes its 22/22 checks but independent rectangle intersection finds 6.0 sf of cabinet overlap (dishwasher 0.5 sf, west range landing 2.0 sf, induction range 3.5 sf). The prior 48 in post-stool measure ended at the room-block edge and ignored the 24 in-deep perimeter run. With the west-aligned current test run, the island-to-counter-front aisle is 48 in; subtracting the explicitly assumed 24 in occupied-stool zone leaves 24 in, 12 in short of the study's 36 in route target. The repaired living-to-porch options pass 29/29 with no positive-area overlap against modeled modules, island, assumed stool proxy, table/chairs or half-wall; table proxy separation is 8 in. Rounded-polyline chair proxy clearances are 10 in and 15 in; the more conservative square-corner corridor rectangles retain at least 10 in in both door cases. Three runs (retained and two scratch) reproduce the five route artifacts byte-for-byte; all SVGs parse as XML. The B-first generator passes 53/53 in three runs with seven byte-identical generated artifacts. M19 refrigerator validation passes 16/16 in three runs and updates the refrigerator module to the west-aligned coordinate. M21 entry study passes 18/18 in three runs after rebinding its candidate fingerprint. The route begins in living, reaches the nominal porch opening and extends 3 ft into the porch test rectangle; it does not prove island-work access, door clear width, accessibility, wall/threshold fit or a selected design. Selected-D SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`; the three Incoming RFAs are preserved. No Revit or IFC file changed. M-06/B remains unassigned.

Next: run an integrated, source-bound kitchen/dining candidate search within the documented 14 x 12 ft and 11 x 10 ft targets, carrying the 8 x 4 ft island, the 12 in seating overhang and explicitly parameterized stool envelopes, sourced fixture modules, occupied dining furniture and a continuous route. Report feasible/infeasible candidates without replacing selected-D or inventing required dimensions. Keep M-06/B and services unassigned.

## M174 - Inspect a public Tauri counter-stool family for the kitchen seating study - 2026-10-31

Acceptance criteria:

- Preserve the official product-page and Revit-library URLs, downloaded bundle provenance, and exact SHA256 of each extracted RFA in the ignored quarantine; do not sign in, create an account, or change the source family.
- Inspect the closest counter-height candidate in Revit 2027 from the exact hash-pinned RFA and record family category, placement type, all type parameters, and positive-volume solid bounds in family coordinates.
- Save only a new disposable Imperial RVT under `.local/revit-pilot/family-intake/derivatives/`; place no instance and do not open or modify selected-D.
- Independently validate source before/after hash, derivative fingerprint, type count, finite positive solid bounds, units, and the explicit no-placement/non-compliance limitations with a PowerShell 5.1 gate.
- Compare the product's verified seat height against the project’s documented 24–26 in target. Label any mismatch; do not select the product or substitute its static bounds for an occupied/pulled-back seating envelope.
- Preserve selected-D, its Revit/IFC pair, all Incoming RFAs, and unresolved M-06/B status.

Status: In progress. MiEN's public product page lists its Tauri counter stool at a 23.75 in seat height, 1/4 in below the project target; the public library lists a downloadable Revit family and supports Revit 2021 or later. The hash-pinned 24-in bundle member is quarantined for comparison only. Revit previously displayed its Furniture category, `Shell_Red` type, and `Height = 23.75 in` in Family Editor, closed without saving. A new RevitPilot command now derives axis-aligned family-symbol bounds from per-solid `Solid.GetBoundingBox()` results and composes nested box/instance transforms; Autodesk's API documentation confirms that the box is local-coordinate data requiring its transform. The independent report validator has been built and synthetically tested, but actual solid bounds have not yet been measured in the fresh disposable project. Revit currently has a startup trust dialog associated with an older scratch build; the UI bridge cannot read it. The current v6 build is compiled and hash-checked but not registered. Continue only after the trust state is resolved and the exact v6 manifest/DLL can be presented for Load Once. The in-progress build/test evidence is recorded in `PROGRESS.md`. No stool, occupied envelope, kitchen arrangement, M-06 fixture, or room assignment is selected.

## M175 - Make historical family-intake validation reproducible without relaxing the current-source gate - 2026-10-31

Acceptance criteria:

- Keep default intake validation bound to the current `Revit/Family_Intake/Incoming` filename set and reject stale manifests.
- Add an explicit historical-snapshot mode that accepts only a manifest tied to the canonical Incoming folder and compares every supplied family filename and SHA256 to the archived run.
- Reject path-bearing manifest filenames and any missing or hash-mismatched family source.
- Replay the preserved six-family M-06 intake from a derived snapshot without changing Incoming or the original intake report; prove default current-source validation still rejects the historical six-file run.
- Record commands, results and limitations. Do not infer room assignment, clearance, service route or approval from an intake screen.

Status: Complete as a validation-integrity repair. The historical M-06 intake snapshot passes 173/173 checks with 24 measured types; default validation rejects its six-file manifest against the present five-file Incoming set, and an altered-copy fixture is rejected for SHA256 mismatch. Incoming, quarantine sources, the original manifest, selected-D and Revit files remain unchanged. M-06/B remains unassigned. See M175 in `PROGRESS.md`.

## M176 - Audit the compact social-route test scope - 2026-10-31

Acceptance criteria:

- Bind M172's current 14 x 12 ft / 168 sf kitchen and 11 x 10 ft / 110 sf dining program-area targets.
- Recompute M173's kitchen and dining test-block areas from its source geometry and quantify differences from the owner targets.
- Verify M172/M173 provenance, the prior M173 29/29 route gate, and selected-D source identity without modifying selected-D.
- Emit deterministic JSON, CSV and check artifacts from a PowerShell 5.1 tool; replay twice into isolated scratch outputs and compare bytes.
- Correct the M173 README so the larger candidate dimensions cannot be mistaken for compact-target fit. Preserve M-06/B as unassigned and make no layout selection.

Status: Complete. `Tools/audit_m176_social_route_target_scope.ps1` passes 13/13 checks in the retained package and two isolated replays; all three artifacts match byte-for-byte. The script verifies all source fingerprints from M172/M173, recomputes M02 at 277.33 sf and M03 at 158.67 sf, and confirms M173's route check passes 29/29 for those larger blocks. They exceed 168 sf and 110 sf by 109.33 sf (65.08%) and 48.67 sf (44.24%); combined overage is 158 sf / 56.83%. This invalidates no M173 calculation; it bounds its applicability. The selected-D source remains SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. See the M176 README and M173 scope note.

## M177 - Test a compact connected social route - 2026-10-31

Status: Complete as a route-focused, unapproved candidate. `Tools/build_m177_compact_social_candidate.ps1` passes 27/27 in the retained package and two isolated replays; all four artifacts match byte-for-byte and the SVG parses. The 14 x 13.5 ft kitchen test envelope is 189 sf (+21 sf), dining remains 11 x 10 ft, and the connected 36 in route has zero positive-area intersection with modeled closed-state obstacles. It spills 9 in east of the dining test zone. This does not establish the documented 42 in island-to-half-wall clearance, appliance-open travel, actual clear door widths, or a selected plan. See `Architecture/M177_Compact_Social_Open_Plan_Candidate_2026-10-31/README.md`.

## M178 - Coordinate the kitchen cross-section, seating end and living opening - 2026-10-31

Status: Complete as an unapproved rotated cross-section and route proposal. The 13.5 x 14 ft envelope carries the 12.5 ft perimeter run, 42 in counter aisle, 8 x 4 ft island, 42 in half-wall clearance, 7 ft half-wall, 6 ft living opening, 36 in route and two assumed 24 in end-seat proxies. It passes 26/26 checks in the retained package and two isolated replays; outputs match byte-for-byte and the SVG parses. The kitchen remains +21 sf above the 168 sf area target, and the route spills 21 in east of the dining target into unassigned space. This is a coherent dimensional candidate, not an approved layout or integrated whole-house fit. See `Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/README.md`.

## M179 - Route around the bath-first pantry block - 2026-10-31

Status: Complete as a route-overlay comparison. M178's straight east-aisle route intersects the M-04 pantry block in the unapproved bath-first alternative. A westward dogleg before the pantry's south edge clears all modeled pantry, furniture, island, cabinet and wall rectangles, passes the nominal porch door and reaches 3 ft into the porch. It passes 21/21 in the retained package and two identical scratch replays. The short connector spills 21 in east of the dining target below the pantry; the long leg uses dining's unseated east band and is tangent to the table edge. This remains an unapproved comparison, not a selected plan or whole-house fit. See `Architecture/M179_Pantry_Route_Clearance_Audit_2026-10-31/README.md`.

Completed by M180 below; the unassigned inter-room band and physical door/furniture operation remain open.

## M180 - Trace the social route into the living block and shell - 2026-10-31

Acceptance criteria:

- Bind M179 and bath-first source fingerprints; establish whether the route actually begins inside source M-01.
- Extend a 36 in coordinate route from within M-01 through the proposed living opening, around modeled blocks and into the nominal porch-door span.
- Check modeled obstacle intersections, pantry separation, route/opening dimensions and route/porch extents against the hypothetical 40 x 42 ft test shell.
- Emit deterministic JSON/CSV checks; replay twice in PowerShell 5.1 and require byte-identical results.
- Preserve selected-D, incoming RFAs and M-06/B unassigned status. Make no room/layout selection or Revit/IFC edit.

Status: Complete as an unapproved coordinate-overlay correction. M179's start `(14.5, 10)` was outside the translated M-01 living rectangle. M180 starts at `(19.5, 10)` inside it, then crosses a 4 ft 4 in unassigned band between candidate M-02 and M-01. The 36 in corridor clears all modeled obstacles with zero positive-area intersections, crosses the nominal 6 ft opening with 18 in margins, leaves a derived 6 in pantry gap, reaches the nominal porch-door span and fits the test-shell extent. It passes 12/12 checks in the retained package and two independent replays; all three artifacts match byte-for-byte. No physical opening, door operation, room assignment, services or whole-house fit is validated. See `Architecture/M180_Living_Shell_Route_Audit_2026-10-31/README.md`.

Next: test the proposed connector against the actual adjoining room-block perimeter and door reservations with candidate-local coordinates, then decide what program occupies the 4 ft 4 in kitchen-to-living band. Keep M-06/B unassigned until fixture geometry, applicable cited clearance, approach and plausible service route all support it.

## M181 - Check the social route against all room interfaces - 2026-10-31

Acceptance criteria:

- Bind the M180 route, bath-first blocks, selected-D fingerprint and M-06 status.
- Compare reduced candidate blocks with all source main-room rectangles and quantify candidate/source gaps to living and dining.
- Evaluate the 36-in path using Euclidean segment-to-rectangle distances with an 18-in route radius, checking all static room/furniture/wall proxies and both M-06 search-window overlays.
- Record the orthogonal-route conflict and test a clearly labeled diagonal transition without assigning a room or fixture.
- Require deterministic PowerShell 5.1 outputs in two independent replays; preserve selected-D and Incoming RFAs.

Status: Complete as a source-bound route refinement, not a plan selection. M180's orthogonal elbow clears the physical pantry proxy but its 36-in swept path conflicts with the west M-06 search-window rectangle by 5.96 in. A diagonal candidate clears assigned static room/furniture/wall rectangles with only 0.60 in at assumed stool occupancy, 2 in at the table, and 0.38 in at the west search-window boundary. Those margins are too small to validate furniture movement or a usable route. It passes 13/13 checks in the retained package and two independent replays; all three generated artifacts match byte-for-byte. M-06/B stays unassigned, selected-D unchanged. See `Architecture/M181_All_Room_Interface_Audit_2026-10-31/README.md`.

M182 below compares a pantry-side bypass against the kitchen-side leg; the 44 in throat and new south opening remain unresolved.

## M182 - Compare a pantry-side bypass route to the kitchen dogleg - 2026-10-31

Acceptance criteria:

- Bind M181 and current bath-first, selected-D and M-06 status sources.
- Test a 36-in route from M-01 south to the porch, passing between the pantry block and east/pantry-side M-06/B search window.
- Check all assigned room/furniture/wall proxies, blocked west search overlay, nominal door span, shell extents and source/candidate block spill.
- Quantify both side margins in the unassigned throat and identify any needed opening or room reservation.
- Emit deterministic PowerShell 5.1 JSON/CSV; replay twice and compare bytes. Keep M-06/B unassigned and selected-D unchanged.

Status: Complete as an unapproved route comparison. A route through the unassigned 44-in strip between pantry and B clears modeled assigned blocks and furniture (13/13 checks, two byte-identical replays), leaving 4 in at each side. It avoids M181's stool/table bottleneck but overlaps the already-blocked west M-06 diagnostic window by 4.736 sf, intrudes 2 in into the source M-02 block outside the reduced kitchen, and requires a new south opening from M-01. This uses unassigned circulation adjacent to B and may constrain bath approach/door/services; it does not establish a usable route or fit. No layout/room selection, Revit/IFC edit or baseline change. See `Architecture/M182_Pantry_Bypass_Route_Audit_2026-10-31/README.md`.

Next: reject or revise the existing M173 route against the M-04 pantry overlay before refining the social circulation and M-01/M-02 interface. Continue to keep M-06/B unassigned until exact fixture assembly geometry, applicable clearance, approach/door and plausible services can be tested together. Confirm actual town and permit timing before treating the Connecticut screening basis as applicable.

## M183 - Consolidate competing social-route constraints - 2026-10-31

Acceptance criteria:

- Consume retained M181/M182 studies and verify their current source fingerprints, selected-D hash and protected Incoming RFA hashes.
- Compare both 36-in route proposals using their actual measured proxy clearances and conflicts; do not promote either to a selected layout.
- Assert that M-06/B remains unassigned and that no selected-D source changes.
- Emit a machine-readable JSON/CSV comparison with explicit unresolved design inputs.
- Run in PowerShell 5.1 from the retained output and two clean scratch directories; require 12/12 checks and byte-identical outputs.

Status: Complete as a route-option gate. M181's diagonal kitchen-side candidate has only 0.60 in at the assumed stool proxy, 2 in at the dining table and 0.38 in at the blocked west search-window diagnostic. M182's pantry-side bypass has a 44-in unassigned throat with 4-in margins on each side, overlaps the blocked west diagnostic, intrudes 2 in into source M-02 and requires a new M-01 south opening. Neither is selected or demonstrated operational. PowerShell 5.1 retained generation and two independent replays pass 12/12 with all three JSON/CSV artifacts byte-identical. Selected-D and the three known Incoming RFA fingerprints remain unchanged; B remains unassigned. See `Architecture/M183_Route_Option_Gate_2026-10-31/README.md`. Connecticut DAS rechecked on 2026-10-31 still lists the 2022 CSBC based on the 2021 IRC as current and says the 2026 code effective date is delayed pending legislative approval. Actual town, permit timing and scope remain unknown.

## M184 - Overlay the retained social route against pantry and M-06 search blocks - 2026-10-31

Acceptance criteria:

- Bind the M173 route to the exact bath-first room-block and selected-D sources from which it was generated.
- Intersect all retained 36-in route rectangles with the pantry and both M-06 search-window rectangles in their shared source coordinate frame.
- Calculate union overlap area to avoid double-counting at adjoining route elbows; also retain raw pair intersections for review.
- Assert zero overlap with east/B and report any pantry/west-diagnostic conflict; preserve B-unassigned and selected-D invariants.
- Emit deterministic JSON/CSV; rerun twice from empty PowerShell 5.1 scratch directories and compare bytes.

Status: Complete as a source-bound overlay audit. M173's previously retained route has 17.750 sf union overlap with the M-04 pantry block and 22.250 sf with the already-blocked west M-06 diagnostic window; it has 0 sf overlap with the east/B search window. M173's own 0-intersection result covered its listed kitchen/dining obstacles, while this overlay exposes room-block conflicts that were not part of that obstacle set. The route must not be treated as complete for the bath-first adjacency arrangement. The study still does not establish physical walls or openings, and B remains unassigned. PowerShell 5.1 retained run plus two scratch replays pass 10/10 with three byte-identical artifacts. No selected-D, Revit/IFC or Incoming RFA changed. See `Architecture/M184_Social_Route_Pantry_Overlay_2026-10-31/README.md`.

## M185 - Test the pantry dogleg against both M-06 search regions - 2026-10-31

Acceptance criteria:

- Bind M179, M178, the bath-first room blocks, M-06 search-window status, and selected-D source by SHA256.
- Compare the original 36-in dogleg with a clearly labelled earlier-turn sensitivity against the pantry, both M-06 windows, and the M178 fixture/furniture proxies.
- Measure the M179 route origin against source M-01 and explicitly report any unassigned kitchen-to-living transition band.
- Sweep the single-elbow turn from 13.00 to 15.00 ft in 0.25-ft increments; compute union overlap area to avoid double-counting corridor elbows.
- Record all five Incoming RFA hashes, preserve selected-D and keep M-06/B unassigned.
- Emit deterministic PowerShell 5.1 JSON, checks, CSV and SVG; require passing source/geometry gates, XML parsing, and byte-identical retained and two scratch outputs.

Status: Complete as a route-conflict study, not a route selection. M179's full-width elbow overlaps the blocked west M-06 diagnostic by 0.708333 sf union area. An earlier turn clears that diagnostic but overlaps the assumed stool-use proxy by 1.5 sf and passes only 4 in from the diagnostic. The 13.00–15.00 ft single-elbow sensitivity sweep at 0.25-ft intervals has no sample clear of both; its lowest combined sampled overlap is 0.708333 sf at the original 14.5-ft turn. M179 starts outside M-01 in the 4 ft 4 in unassigned band between living and kitchen, so neither dogleg is continuous living-to-porch circulation. Pantry and east/B window remain clear in the compared variants; B stays unassigned. Retained and two isolated replays pass 21/21 and produce byte-identical JSON, checks, CSV and SVG; SVG XML parses. Selected-D SHA256 remains `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`. No Revit/IFC, selected-D or source RFA changed. See `Architecture/M185_Dogleg_M06_Overlay_2026-10-31/README.md`.

## M186 - Search multi-turn social-route alternatives against current constraints

Acceptance criteria:

- Use the current M178/M179 geometry and source bath-first blocks; bind the search to selected-D and protected Incoming RFA hashes.
- Search 36-in swept route alternatives with more than one elbow against the pantry, both M-06 windows, kitchen casework/island/stool proxy, dining table/chairs, half-wall and porch opening reservation.
- Report the search bounds, grid resolution, route starts/ends, unassigned-space excursions, closest proxy separations and any unsatisfied constraints; a geometric non-overlap is not called a usable route.
- Preserve the 168-sf owner kitchen target as a target and identify M178's +21-sf proposal without treating it as approved; keep B unassigned.
- Produce deterministic JSON/CSV/SVG and explicit incomplete-search limits; do not change selected-D, Revit/IFC or Incoming RFAs.

Status: Complete as a bounded schematic search. PowerShell 5.1 retained generation and two independent replays pass 29/29; JSON, checks, CSV and SVG match byte-for-byte, and the SVG parses as XML. No route reaches the nominal porch door: the 5,299-node connected region is exhausted within a 23,088-node grid; nearest reachable point is 10 ft away by Manhattan distance. This rejects only the sampled grid under the listed proxy blocks, not every continuous route. M-06/B remains unassigned and selected-D unchanged. See `Architecture/M186_Multiturn_Route_Search_2026-10-31/README.md`.

Next: M187 isolates one proxy-relaxation at a time to measure which reservation constrains the bounded social route most. Treat relaxations strictly as sensitivities, not layout decisions; preserve the combined-constraint M186 no-route baseline, M-06/B unassigned, and selected-D.

## M194 — Owner kitchen-area priority and revalidation — 2026-10-31

Acceptance criteria:

- Record the owner's choice to prioritize enlarging the kitchen test area over reducing the larger 8 × 4 ft island if the 14 × 12 ft target conflicts with it; do not convert the 13.5 × 14 ft candidate into a final dimension.
- Reproduce M178's 8 × 4 ft island, 12.5 ft perimeter run, and 42-in aisle arithmetic in two empty PowerShell 5.1 scratch directories.
- Reproduce M186's bounded 36-in route result in two empty scratch directories while preserving the 40 × 42 ft shell comparison and unassigned M-06/B region.
- Update `PLAN.md`, `PROGRESS.md`, and `Project/AI_Handoff.md` with the route/spill/stool limits; leave selected-D, Revit, IFC, RFAs, and remote state unchanged.

Status: Complete as an owner-priority record and evidence refresh. The owner selected kitchen-area expansion over reducing the larger island. M178 passes 26/26 on both runs for a 13.5 × 14 ft / 189 sf test kitchen (+21 sf), 8 × 4 ft island and 42-in aisle proxies, but its assumed stool positions consume all 4 ft of the island end and its fixed route spills 21 in beyond dining. M186 passes 29/29 on both runs but finds no route through its bounded 40 × 42 ft arrangement: 5,299/23,088 nodes reached, nearest point 10 ft from the nominal porch door. This does not prove all layouts fail. M-06/B remains unassigned; selected-D remains unchanged. See `Decisions/2026-10-31_Kitchen_Area_Priority.md`.

## M195 — Owner-directed minimum-area social layout search — 2026-10-31

Acceptance criteria:

- Search for the smallest kitchen test area that carries the larger 8 × 4 ft island and a continuous 36-in living-to-porch route; do not treat the existing 189-sf proposal as a limit or final dimension.
- Allow dining and porch test footprints to move within the hypothetical 40 × 42 ft shell, preserving their documented 11 × 10 ft and 12 × 10 ft sizes for the first search.
- Bind all room/furniture/product inputs to source files and SHA256; include half-wall, perimeter casework, island, two stool-use envelopes, dining table/chairs/use zones, porch openings and the adjacent fixed room blocks.
- Keep pantry-side M-06/B unassigned and clear of route geometry. Report use of alternate A separately as a trade-off; do not model either search window as an assigned room.
- Record search bounds/resolution, area ranking, margins, spill, and a fully reproducible path only when the swept route clears every included proxy. Re-run from fresh PowerShell 5.1 scratch directories and compare artifacts byte-for-byte.
- Keep selected-D, source RVT/IFC and Incoming RFAs unchanged; no compliance, accessibility, structural, permit or construction-readiness claim.

Status: In progress. Owner selected the minimum-area search and authorized dining/porch repositioning within the test shell. M187 sensitivities and the four-case M195 dining/porch/table search are reproducible; M195 passes 9/9 checks and all four embedded M186 searches pass 29/29 in three byte-identical PowerShell 5.1 runs. **0/4** M195 placements reach the porch with the 189-sf M178 kitchen and 8 × 4 ft island held fixed. The nearest reachable sample is 12–12.5 ft from the candidate door; B remains clear and unassigned. Some porch variants overlap alternate A by 0.403–1.007 sf. This is not an exhaustive search and has not found the minimum kitchen area. Next: vary the kitchen envelope/area and its opening relationship to circulation while retaining the larger-island priority; measure stool geometry when authorized Revit inspection is available. Keep A as a separately reported trade-off and B protected.

## M196 — Owner roofline massing direction — 2026-10-31

Acceptance criteria:

- Record the owner's direction for one dominant traditional main gable with a simpler, subordinate porch roof.
- Keep pitch, ridge/eave heights and orientation, roof assemblies, structure and site response unselected; identify prior pitch screens as geometric studies only.
- Update the design handoff and plan; do not alter selected-D or roof geometry in Revit.

Status: Complete as a massing-direction record. The owner selected a single main gable with simpler porch roof. No pitch or structural specification is selected. See `Decisions/2026-10-31_Roofline_Concept.md`.

## M197 — Sweep kitchen envelope width against the social route — 2026-10-31

Acceptance criteria:

- Sweep kitchen width from the M178 13.5-ft candidate through the documented source M-02 width, preserving 14-ft depth, the larger 8 × 4 ft island, 12.5-ft counter run, six-foot opening and other fixed proxies.
- Re-run the M186 full-shell 36-in search at each sample while keeping dining/porch geometry and M-06/B protection constant.
- Bind inputs by source hashes; report area ranking, nearest reachable point, path status and explicit limitations.
- Reproduce all artifacts byte-for-byte in an independent PowerShell 5.1 run. Do not modify selected-D, RVT/IFC or Incoming RFAs.

Status: Complete as a bounded one-axis sensitivity. **0/17** width samples from 13.5 to 17⅓ ft find a route; all embedded M186 checks pass 29/29, and M197 passes 6/6 in two byte-identical runs. Nearest reachable point remains `(4,14)` ft, 12 ft from the tested porch door. Kitchen widening alone did not solve the route and does not establish a minimum. Next: sweep dining/chair-use placement and door alignment in the authorized shell, preserve B and report alternate A separately. See `Architecture/M197_Kitchen_Envelope_Route_Search_2026-10-31/README.md`.

## M198 — Sweep porch-door alignment against the dining approach — 2026-10-31

Acceptance criteria:

- Keep the porch test footprint at its documented 12 × 10 ft and the five-foot opening size; vary door center independently of dining within the porch face.
- Keep the M178 13.5 × 14 ft kitchen, 8 × 4 ft island, M195 rotated table/chair/use proxies, 36-in route and M-06 windows fixed for the first door-only sensitivity.
- Re-run M186 for every tested door center; report paths, nearest reachable points and any contact/overlap with alternate A. Keep pantry-side B clear and unassigned.
- Bind inputs by source hash; reproduce JSON/checks/CSV byte-for-byte in independent PowerShell 5.1 runs. No selected-D, RVT/IFC or Incoming RFA changes.
- Treat all door positions as sensitivity samples, not an owner-selected opening or code-compliant design.

Status: Complete as a bounded sensitivity. Two independent PowerShell 5.1 runs pass 7/7 checks and their JSON/checks/CSV match byte-for-byte; all 30 embedded M186 searches pass 29/29. **0/15** door centers find a route. The nearest reachable point is 9.5 ft from the eastmost center (x=9 ft); the centered x=5.5-ft case is 12 ft away. Door locations remain unselected. See `Architecture/M198_Porch_Door_Alignment_2026-10-31/README.md`.

## M202 — Compare fully open kitchen/living connection — 2026-10-31

Acceptance criteria:

- Test the owner's preferred fully open connection against the current half-wall route model while preserving 14-ft kitchen depth, 8 × 4 ft island, 36-in route proxy, chair-use zones and porch-door case.
- Remove only the half-wall/return proxies and correctly begin circulation in the source living room; retain both M-06 diagnostics, entry, pantry and all other fixed obstacles.
- Bind source hashes and report route, closest reach and all changed assumptions. Keep the half-wall as a documented comparison; no opening span or structural detail is selected.
- Preserve selected-D, RVT/IFC and Incoming RFA sources; pass independent deterministic PowerShell validation.

Status: Complete as one fixed-layout sensitivity. Two independent PowerShell 5.1 runs pass 7/7 checks and match byte-for-byte; M186 passes 29/29. Removing the half-wall/return and starting in living reaches 5,816 nodes but finds no route; nearest point is 9.5 ft from the best-gap door. The 4.333-ft band between the test kitchen and source M-01 remains unassigned and physically unmodeled. See `Architecture/M202_Fully_Open_Kitchen_Route_2026-10-31/README.md`.

## M203 — Test alternate-A circulation trade-off with B protected — 2026-10-31

Acceptance criteria:

- Starting from M202's fully open sensitivity, relax only the west diagnostic M-06/A obstacle; preserve pantry-side B as a no-go and unassigned search window.
- Keep the 189-sf kitchen, 8 × 4 ft island, M195 table/chair-use proxies, entry/pantry, 36-in route and best-gap porch door fixed.
- If a route appears, report its overlap with A, unassigned travel, route length/turns and minimum gaps to island, assumed stools and chair-use zones. Explicitly state that A is consumed as circulation, not assigned as a bath.
- Bind source hashes and replay deterministically. Do not modify selected-D, RVT/IFC or Incoming RFAs; do not claim usability or compliance.

Status: Authorized trade-off sensitivity; no layout or room assignment selected.

## M203 — Test alternate-A circulation trade-off — 2026-10-31

Acceptance criteria:

- Starting from M202, release only west diagnostic A; preserve B and all other fixed M-06, pantry, entry, island, stool, dining and chair-use constraints.
- Report any route's area/centerline use of A, unassigned travel, route length/turns and minimum proxy gaps; clearly label A as an unassigned bath option consumed as circulation.
- Bind source hashes and reproduce deterministic PowerShell outputs twice; preserve selected-D, RVT/IFC and Incoming RFA inputs.

Status: Complete. **0** routes found after releasing A; nearest point remains 9.5 ft from the porch door. B, pantry and stool-use proxies remain major frontier constraints. No route consumes A in this case. Next: compare west, central and east door centers under this A trade-off before considering any change to the pantry footprint. See `Architecture/M203_M06A_Circulation_Tradeoff_2026-10-31/README.md`.

## M204 — Compare porch-door alignment with A released — 2026-10-31

Acceptance criteria:

- Test west, centered and east five-foot porch-door centers x=2, 5.5 and 9 ft with the fully open kitchen/living start and A released.
- Preserve B, pantry, entry, island, stool, dining and chair-use proxies; report distance, reachability and any A consumption.
- Bind sources and reproduce outputs independently; do not select door geometry or alter house files.

Status: Complete. **0/3** positions find a route; all reach 5,940 nodes. The east position is 9.5 ft from the nearest reachable node; west/center are 12 ft away. No route consumes A. Further door movement alone is not the evident next lever. See `Architecture/M204_M06A_Door_Alignment_2026-10-31/README.md`.
## M205 — Test M-04 pantry location sensitivity — 2026-10-31

Acceptance criteria:

- Compare the current modeled 5 × 7 ft pantry block with two north-of-kitchen positions; label this footprint as a test proxy because the separate kitchen specification says 5 × 6 ft.
- Preserve pantry area/function, the open kitchen/living start, island, stool, M-06/B protection and east porch door. The 36-in shared-wall case may shift the 11 × 10 ft dining package within the already authorized hypothetical shell; report its boundary margin.
- Report route, door-wall length, pantry and route use of unassigned A, room-block overlap, source fingerprints and deterministic replays. No placement becomes selected.

Status: Complete. Two independent PowerShell runs pass 6/6 wrapper checks; all six embedded M186 searches pass (29/29, 31/31 and 31/31). The current pantry position has no route (nearest point 9.5 ft); both north-edge cases produce a 28-ft, four-turn route. Together, pantry and route use 43.92 sf (74.5%) of the 58.99-sf west-A diagnostic window. The 36-in shared-wall case shifts dining 6 in west and leaves 2 in to the test-shell boundary. A nominal 30-in door has no wall-length reserve in the first north-edge case; the second does not establish rough-opening or swing fit. B remains unassigned. See `Architecture/M205_Pantry_Location_Sensitivity_2026-10-31/README.md`.

## M206 — Compare documented 5 × 6 ft pantry target — 2026-10-31

Acceptance criteria:

- Repeat the current and north-edge pantry cases at the 5 × 6 ft size specified in `Architecture/Kitchen_Dining_Porch_Specs.md`; retain the same kitchen/living, dining, island, stool, door and B constraints.
- Report route reachability, pantry/route overlap with A, dining boundary margin, kitchen shared-wall length and all modeled proxy conflicts.
- Bind sources and reproduce outputs independently. Treat every placement as a sensitivity, not a design selection; do not change selected-D, RVT, IFC or RFAs.

Status: Next authorized geometry sensitivity; no placement selected.
## M199 — Record outdoor patio zone relationships — 2026-10-31

Acceptance criteria:

- Record separate dining and fire/lounge zones connected by a clear walking band.
- Reserve a future fireplace area without selecting product, type, fuel or exact location.
- Preserve a clear route toward a future pool without assigning pool position, dimensions or equipment.
- Update the outdoor concept and handoff; make no site, grading, code or structural assumptions.

Status: Complete as an adjacency decision. Patio sizing and site fit await survey/location information; see `Decisions/2026-10-31_Patio_Outdoor_Zones.md`.

## M200 — Record Tauri stool seat-height exception — 2026-10-31

Acceptance criteria:

- Preserve the general 24–26 in seat-height target while recording the owner's explicit 23.75-in exception for the MiEN Tauri candidate.
- Keep the stool unselected until the exact-hash quarantined family receives the authorized read-only Revit geometry inspection and disposable fit review.
- Do not infer occupied-use clearance, comfort, accessibility, code compliance or product suitability from seat height.

Status: Complete as a product-specific owner decision; no family geometry or house model changed. See `Decisions/2026-10-31_Tauri_Seat_Height_Exception.md` and `Research/M174_MiEN_Tauri_Counter_Stool_Family_Inspection_2026-10-31.md`.

## M201 — Record preferred kitchen/living opening — 2026-10-31

Acceptance criteria:

- Record the owner's preference for a fully open kitchen/living connection, consistent with the existing specification's options.
- Preserve the half-wall variant as a comparison until an integrated route/layout study supports a coordinated plan.
- Do not invent an opening span or structural specification; preserve M-06/B unassigned and selected-D unchanged.

Status: Complete as a layout preference. M187 shows that removing the half-wall alone did not restore a route. Further comparison is required; see `Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md`.

## M187 - Isolate route bottlenecks by one-at-a-time proxy relaxation

Acceptance criteria:

- Reuse the exact M186 search with the same shell, grid, route width, start/opening/goal and source fingerprints; alter only one declared obstacle set per case.
- Test stool-use proxy, west diagnostic, east/B window, pantry, island, half-wall/return, M-05 entry, dining set and perimeter casework independently; do not combine relaxations.
- Report whether a sampled path returns, its length/turn count, reachable nodes, and remaining constraints; explicitly state that paths traverse the removed proxy.
- Keep B unassigned, selected-D and source families unchanged; emit deterministic summary JSON/checks/CSV and pass two independent replays.

Status: Complete. Three of nine single-proxy relaxations restore a sampled path: stool-use proxy (28.5 ft/five turns), west diagnostic (28.5 ft/five turns), and dining set (54.5 ft/five turns). The other six—including M-05 entry—do not. This isolates tradeoff sensitivities; none is a valid route while its omitted proxy remains. See `Architecture/M187_Route_Sensitivity_2026-10-31/README.md`.

Next: replace the assumed stool envelope with measured geometry from the protected incoming families when permitted Revit host evidence is available, then inspect the entry opening/interface and physical walls in an isolated derivative. Do not relocate the M-06 search window or assign B without product/clearance/approach/service evidence.

## M188 - Test dining-set translation against the public route

Acceptance criteria:

- Use only source-documented 36 x 60 in table and 18 x 20 in chair body sizes; translate the set rigidly without resizing it.
- Test baseline and one-foot cardinal translations within the M178 11 x 10 ft dining test block, then rerun the same M186 route grid and constraints.
- Record route length, turns, minimum table-edge gap and unassigned-space use; no path is described as usable without actual openings, door, wall and movement geometry.
- Keep selected-D, Revit/IFC, Incoming RFAs and M-06/B status unchanged; require deterministic PowerShell output and passing checks.

Status: Complete as an unapproved placement sensitivity. Only the one-foot north translation restores a grid route (56.5 ft, seven turns); it has zero additional table-edge gap and traverses 6.5 ft of unassigned space. The result is too fragile to select. See `Architecture/M188_Dining_Set_Placement_2026-10-31/README.md`.

Next: if owner accepts further schematic exploration, search small combined table offsets and alternative four-chair placement while enforcing the full 36-in chair-use envelope and a separate route. Then move to actual Revit wall/opening coordination only in a disposable derivative after exact local DLL verification.

## M189 - Replace assumed counter-stool body with quarantined family geometry

Acceptance criteria:

- Inspect only the source-recorded MiEN Tauri `TAURI-STL-24-N-N.rfa` under quarantine; verify source SHA before and after.
- Run the project-local Revit 2027 inspector into a new empty derivative directory, never opening or modifying selected-D and never placing a family instance.
- Validate finite positive solid bounds, all type records, zero instances, derivative hash and explicit limitations; capture the Revit build and report hash.
- Replace the assumed 24-in body proxy only after measured symbol bounds are available; retain a distinct occupied-use/pull-back assumption.
- Record MiEN's published 23.75-in seat height against the owner's 24–26-in program target; do not round or alter the target silently. Keep M-06/B unassigned until actual fixture geometry, clearance, door/approach and services all pass together.

Status: In progress. The inspector builds with zero errors and two reference-conflict warnings; the reproducible validator fixture runner passes 3/3 cases (valid report 11/11, wrong source hash rejected, incomplete solid bounds rejected). The exact Tauri request and hash-verified project-local DLL are prepared. Revit host execution is pending because the running window is not accessible through the current computer-use surface; no restart or load choice was made.

## M190 — Check the M188 dining route against chair pull-out use — 2026-10-31

Acceptance criteria:

- Reproduce the sole M188 north-shift route from its M186 sources without editing the original route study.
- Interpret the written 36-in chair pull-out as a labeled rectangular proxy extending outward from each table edge; preserve the 36-in route width.
- Reconstruct the swept route from compressed waypoints and compare its union against chair-use zones; bind room specification, M188/M186, selected-D and M-06 inputs by SHA256.
- Emit JSON/checks/CSV/SVG; parse SVG; replay independently and require byte-identical output.
- Preserve selected-D, all Incoming RFAs, Revit/IFC and B-unassigned status.

Status: Complete as a route-conflict audit. M188's 56.5-ft, seven-turn north-shift route has zero extra table-edge gap and 6.5 ft of unassigned travel. The 36-in chair-use interpretation overlaps it by **1.5 sf union area**, so that candidate fails the proxy screen. The audit corrects overlap accounting from M186's 383 serialized subrectangles by using 36-in segment rectangles and caps at endpoints/actual turns; M186 remains unchanged. PowerShell 5.1 passes 8/8 checks in retained and independent runs; four outputs match byte-for-byte and SVG XML parses. This rejects the tested candidate, not every possible arrangement. See `Architecture/M190_Dining_Pullout_Route_Audit_2026-10-31/README.md`.

## M191 — Retest dining placements with pull-out zones reserved — 2026-10-31

Acceptance criteria:

- Retest M188 baseline, one-foot east and one-foot north translations using the documented 36 × 60-in table and four 18 × 20-in chair bodies.
- Reserve one explicitly labeled 36-in-from-table-edge chair-use rectangle per seat and rerun M186's 0.25-ft/36-in route search without other changes.
- Check every furniture/use proxy remains within the 11 × 10-ft dining test block and record path, closest sampled approach, and unsatisfied constraints.
- Bind source hashes; emit deterministic JSON/checks/CSV; require two byte-identical PowerShell 5.1 runs.
- Preserve selected-D, Revit/IFC, Incoming RFAs and M-06/B unassigned status.

Status: Complete as a bounded sensitivity. All three layouts keep the table, chair bodies and pull-out proxies inside the dining target block, but **0/3** recover a route to the nominal porch door. The nearest reachable sampled points remain 10 ft away. This narrows the current table/chair/route arrangement; it does not prove other orientations or layouts impossible. Retained and independent runs pass 7/7 checks and their JSON/checks/CSV match byte-for-byte. See `Architecture/M191_Dining_Pullout_Placement_Search_2026-10-31/README.md`.

## M192 — Rotate dining set while reserving chair-use zones — 2026-10-31

Acceptance criteria:

- Preserve the 36 × 60 in table and 18 × 20 in chair-body envelopes while testing a second table orientation.
- Reserve four explicitly labeled 36-in-from-table-edge chair-use proxies and retain M186's quarter-foot grid and 36-in route width.
- Bind source hashes, selected-D fingerprint and M-06/B status; emit reproducible JSON/checks/CSV/SVG and validate XML.
- Reproduce all artifacts byte-for-byte in an independent PowerShell 5.1 run.

Status: Complete as one bounded comparison. M192 passes 7/7 checks in the retained package and independent replay. Its single rotated arrangement reaches 5,423 route-grid nodes but finds no porch route; nearest reachable sample is 9 ft Manhattan distance from the nominal porch door. This rules out only this tested orientation/placement. M-06/B remains unassigned; selected-D and Revit/IFC are unchanged. See `Architecture/M192_Rotated_Dining_Candidate_2026-10-31/README.md`.

## M193 — Fit flexible island candidates to the clear kitchen target — 2026-10-31

Acceptance criteria:

- Use the owner-directed 14 × 12 ft / 168 sf **clear** kitchen target and 12 ft 6 in perimeter run.
- Keep the documented 24 in counter/body depth, 42 in aisle proxies, 12 in seating overhang and half-wall face relationship explicit; do not count wall thickness inside clear interior dimensions.
- Test island envelopes derived from those constraints, record area/finish trade-offs, and reject any candidate that violates the documented body depth.
- Bind source hashes; preserve selected-D; emit deterministic report, checks, CSV and plan SVG; pass an independent byte-identical PowerShell 5.1 replay and SVG parse.

Status: Complete as arithmetic fit screening, not an integrated plan. Two independent scratch runs and the retained `artifacts-v2/` package pass 10/10; all four outputs match byte-for-byte. M193 also checks each upstream fingerprint recorded by M172. The 8 × 4 ft reference needs a 13 ft clear cross-section and 15 ft end span, so it fails the 14 × 12 ft clear rectangle. A 7 × 3 ft test island (5 ft quartz + 2 ft butcher block) fits exactly with zero reserve at either axis; a 6 × 3 ft test (4 ft quartz + 2 ft butcher block) adds 12 in total end reserve but still has zero cross-section reserve. Both retain 24 in body + 12 in overhang and the 42 in clearances. They are proposals; no stool, dining/porch route, appliance-open, wall placement or tolerance is checked. See `Architecture/M193_Compact_Island_Fit_2026-10-31/README.md`.

Next measurable gate: integrate the 14 × 12 ft kitchen candidate, the documented 11 × 10 ft dining target, all four 36 in chair-use proxies, the full 36 in living-to-porch route, half-wall/opening geometry and 12 × 10 ft porch in one source-bound coordinate study. Compare at least the 7 × 3 and 6 × 3 island options. A candidate qualifies only if all required rectangles fit and the swept route reaches the porch without proxy intersections; record exact reserve/gaps and reject fragile zero-margin routes. The site-fitted patio remains a later exterior gate. Then carry a route-qualified candidate into disposable Revit wall/opening geometry. In parallel, complete the pending read-only Tauri family host inspection when Revit is safely accessible. Keep selected-D unchanged and M-06/B unassigned.
