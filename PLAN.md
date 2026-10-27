# Architectural BIM pipeline plan

Updated: 2026-10-27  
Status: active; M0–M4 are complete for the recorded pipeline run. M5 implements config-driven geometry but awaits a new Revit host run. Compact-Core C remains a test study and is not geometry-frozen.

## Repository safety baseline

- Working branch: `design/vr-tech-bom-roadmap`; default branch: `main`.
- Last audited local commit: `9a0b9f6` (`Record compact-core QA rerun`); it is one commit ahead of `origin/design/vr-tech-bom-roadmap`.
- The live remote tip for the working branch matches its tracking ref at `ae3d875`; `main` matches `9bec5d3`. No fetch, push, merge, reset, rebase, prune, garbage collection, or history rewrite was performed for this baseline.
- The worktree was clean at the audit. Reflogs show the existing sync merges and commits. `git fsck --full --no-reflogs --unreachable` reported unreachable blobs/trees but no unreachable commits. Those objects contain stale intermediate file snapshots, including merge-conflict markers; they are left intact and are not needed to recover the current branch.
- No `PLAN.md` or `REQUIREMENTS.md` existed in HEAD or the worktree at audit time. These acceptance documents are now derived from the approved project brief and current proposed C study. No architectural dimensions have been invented.

## Milestones

| Milestone | Work | Acceptance criteria | Status |
|---|---|---|---|
| M0 — Repository safety and baseline | Audit worktree, branches, reflogs, remotes, history, existing outputs and project sources. Preserve any unreachable evidence. | Clean starting worktree; local/remote branch relation recorded; no missing commits identified; requirements cite project sources. | Complete: see this baseline and `PROGRESS.md`. |
| M1 — Reproducible study generation | Run the checked-in Revit 2027 Compact-Core C generator as a separate timestamped study; validate the generated manifest and native inventory against BIM-01 through BIM-05. | Unique RVT and manifest; exact three levels, 17 room IDs, target shells/lift, three floor profiles, native category counts and warnings recorded. Existing studies remain untouched. | Complete for the prior host run. The configuration-source refactor is tracked separately in M5 and does not yet have fresh host evidence. |
| M2 — Independent IFC validation | Export the generated study as IFC2X3 through the existing manifest command; independently validate schema, validation statements, levels, spaces/IDs, major categories, room areas/CSV, floor markers/areas, and physical-product geometry. | Validator exits 0 only when BIM-02 through BIM-08 checks pass; known annotation exception and area/stair discrepancies are reported separately; report records IFC hash and findings. | Complete for the recorded host run; validation passes with open coordination findings. |
| M3 — One coherent review packet | Connect the export validation to the offline packet and prevent a packet from representing an IFC as passing when its validation artifact is absent or stale. | Packet names its exact source run directories and displays IFC validation status plus open findings. | Complete; latest packet carries the IFC validation and coordination findings. |
| M4 — Documentation and handoff | Update `PROGRESS.md`, execution instructions and checklists with commands, observed evidence, blockers and limitations. | A second operator can follow the documented commands and distinguish host-only steps from offline steps. | Complete for this milestone; commands were rerun from the repository venv and the packet refreshed. |
| M5 — Configuration-driven geometry | Move current Compact-Core authoring inputs into `compact-study-config.json`; consume them at runtime, preserve an exact config snapshot, and fingerprint the input in the generated manifest. | Preflight validates levels, all room boundary/seed data, shell/lift, door hosts, stair runs, overlay extents and floor-loop areas; manifest validation matches the preserved input snapshot to generated levels, IDs and floor targets; Revit regenerates a new study with matching native audit/QA counts and IFC validation, while all previous runs remain intact. | Implementation and offline checks pass; fresh Revit host generation/audit/QA/export remains pending. |

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
