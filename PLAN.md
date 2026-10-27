# Architectural BIM pipeline plan

Updated: 2026-10-27
Status: the reproducible v3 BIM pipeline acceptance criteria are complete. Revit 2027 generated, audited, geometry-checked, exported and independently validated a fresh schema-v3 study. The review packet passes the native, manifest and current-source checks; IFC validation passes with ten open coordination findings. Compact-Core C remains a test study and is not geometry-frozen.

## Repository safety baseline

- Working branch: `design/vr-tech-bom-roadmap`; default branch: `main`.
- The previous full CLI history audit recorded local ref `79e74d0` and tracking ref `ae3d875`. On resuming this task, GitHub Desktop showed branch `design/vr-tech-bom-roadmap`, latest commit `b330adc`, no local changes, and a push from `054fabb` to `b330adc` in progress. This was an observed operation in the user's environment; we did not initiate or alter it. The Git executable is unavailable in the current shell, so fresh reflog/remote-ref details could not be obtained. No cleanup or history operation was performed.
- The earlier dirty geometry-config snapshot (10 modified tracked files plus a regression test) is historical; it was no longer listed as local changes in GitHub Desktop at this resumed checkpoint. The current validation notes in `PLAN.md`, `PROGRESS.md`, `Project/AI_Handoff.md` and the Compact-Core study report were added afterward and require a fresh status check before any commit.
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

## Execution sequence

1. Run the no-Revit preflight and build RevitPilot from the checked-in source.
2. In Revit 2027, run **Build compact core study**. The command creates a new timestamped RVT; never overwrite a previous run.
3. Run manifest validation, **Audit active document**, and **Run geometry QA** against the generated study; preserve all reports.
4. Run **Run manifest exports** for the active C study. Inspect the result manifest and do not infer success from file existence alone.
5. Run the independent Compact-Core IFC validator against that exact export directory and the corresponding generated study manifest.
6. Compile the review packet, confirm it references the same relevant run evidence, then update progress and the coordination record only with observed facts.

## Stop and hold conditions

- Any expected room ID, level, floor marker, geometry class, export, or physical-product geometry fails validation.
- An undocumented geometry exception appears; document it and diagnose before changing the acceptance baseline.
- A model edit would silently change room intent, a proposed owner decision, site assumptions, or a safety-critical condition.
- Geometry QA passes while a known geometric coordination issue remains open. A successful pipeline run is not a design-review-complete claim.

## Out of scope for this milestone

Selecting C over A/B; approving the proposed main bath; selecting a floor assembly, lift, roof, foundation, equipment, or structural system; declaring accessible routes or code compliance; changing remote branches; and Revit 2018 import, DWG/PDF visual review, and professional review. These remain documented follow-up work.
