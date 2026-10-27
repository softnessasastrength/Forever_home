# Architectural BIM pipeline plan

Updated: 2026-10-27
Status: the reproducible v3 BIM pipeline is accepted for Compact-Core C, which remains a test model. Owner-selected architectural direction D now has a reproducible, checked schematic room-block package; it is not yet a native Revit house model or coordinated plan. Native authoring and IFC validation for D remain next.

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
| M6 — Owner-selected schematic direction D | Turn the owner's six selections into a reproducible main/upper/lower room-block design; preserve A/B source studies; document deliberate geometry changes, area schedule, checks and unresolved decisions. | PowerShell generator deterministically derives D from A/B source geometry; room blocks fit the test shells without same-level overlaps; kitchen checks and program area references are checked; selected half bath has no invented size; comparison stair/landing blocks align in plan; review drawings and open findings are emitted. | Complete as an initial schematic iteration. 27/27 geometry checks pass; three plan SVGs parse; lower L-02 and upper U-06 have no projected overlap after a six-inch guest/bath adjustment. Stair geometry remains a plan comparison only; native wall openings, section, headroom, structure and half-bath fit remain open. See `Architecture/Selected_Design_Iteration_2026-10-27/README.md`. |
| M7 — Native Revit house iteration D | Create a separate D-specific Revit source/run from the selected schematic; do not overwrite Compact-Core C or previous RVT/export evidence. | Runtime inputs match the reviewed D schedule; Revit produces an independently saved study; native room/level/category audit and Geometry QA pass their stated checks; stair/landing gaps and unmodeled half-bath are reported honestly; exact D IFC2x3 passes available parsing/schema/inventory/geometry checks; packet links the same D source/run. | Next. Native C generator is still a test and does not represent D. Requires a D-specific Revit authoring configuration and host run. |

## Execution sequence

1. Regenerate and inspect selected schematic D with `powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_selected_house_schematic.ps1`.
2. Build D-specific Revit inputs as a separate configuration and add-in path; preserve C as a compatibility fixture and historical study.
3. In Revit 2027, create a new timestamped D RVT; never overwrite a prior study. Record the exact source config and its hash.
4. Run manifest validation, **Audit active document**, and **Run geometry QA** on D; compare levels, IDs, blocks, stair/core and explicit unplaced items to the schematic.
5. Export D as IFC2x3, independently validate that exact export against D's manifest and schedule, and compile a packet linking the same run.
6. Update progress and the coordination register from observed results; keep unresolved architecture and professional reviews open.

## Stop and hold conditions

- Any expected room ID, level, floor marker, geometry class, export, or physical-product geometry fails validation.
- An undocumented geometry exception appears; document it and diagnose before changing the acceptance baseline.
- A model edit would silently change room intent, a proposed owner decision, site assumptions, or a safety-critical condition.
- Geometry QA passes while a known geometric coordination issue remains open. A successful pipeline run is not a design-review-complete claim.

## Out of scope for this milestone

Selecting assemblies, a lift product, roof, foundation, equipment or structural system; declaring an accessible route or code compliance; changing remote branches; and Revit 2018 import, DWG/PDF visual review, and professional review. Direction D is selected only as the next schematic design path; its geometry is not frozen.
