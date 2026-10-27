# Implementation progress

Updated: 2026-10-27
Status: reproducible Compact-Core C generation/export/validation milestone verified; architectural coordination remains open.

## Goal

Implement `PLAN.md` against `REQUIREMENTS.md`, complete each milestone, run its documented checks, and keep this file current.

## Repository safety and baseline

- Starting worktree was clean on `design/vr-tech-bom-roadmap` at `9a0b9f6` (`Record compact-core QA rerun`), one commit ahead of `origin/design/vr-tech-bom-roadmap`.
- Live `ls-remote` tips matched the local tracking refs: working branch `ae3d875`, `main` `9bec5d3`. No missing commits or remote-only changes were found. No fetch, push, merge, reset, rebase, prune, garbage collection, or history rewrite was performed.
- Full reflogs and `git fsck --full --no-reflogs --unreachable` found no unreachable commits. Unreachable trees/blobs contain stale snapshots, including old merge-conflict markers; they remain untouched. No recovery was needed.
- `PLAN.md` and `REQUIREMENTS.md` were absent from HEAD and the worktree. They are now mapped from approved project briefs; unresolved C targets remain labelled proposals.

## Verified pipeline milestone

- RevitPilot generated a new native study without editing older runs: `.local/revit-pilot/compact-core/20261027T021357786Z/`. Manifest validation passes with three levels, 17 stable room IDs, five nominal door IDs, the documented shell/lift targets and three provisional floor profiles; native warning report is empty.
- Host API audit at `.local/revit-pilot/audits/20261027T021437402Z/`: 3 levels, 17 enclosed rooms, 78 walls, 5 openings, 0 warnings.
- Host Geometry QA at `.local/revit-pilot/geometry-qa/20261027T021454801Z/`: 17 rooms, 78 walls, 2 stairs, 5 doors, 3 floors, 0 warnings, 0 heuristic issues, 0 errors. Floors remain the unselected template `Floor 1`, 1 ft thick.
- Manifest-driven Revit export at `.local/revit-pilot/exports/20261027T021506070Z/` produced IFC2X3, three plan DWGs, combined PDF and Room inventory CSV.
- New independent checker `Tools/RevitPilot/validate_compact_ifc.py` passes IFC hash/status, IFC2X3 parse/schema, expected levels/elevations, 17 `IfcSpace` identities and positive areas, regression counts (78 walls, 3 slabs, 2 stairs, 5 doors), floor markers/areas, CSV IDs/areas, and all represented physical-product geometry. IFC schema issue count is 0. Geometry decoded for 120/121 represented products; the sole exception is the known model-line `IfcAnnotation`.
- The checker measures the main-to-upper stair/upper-slab plan gap at 5.625 ft and reports CO-001 open. It also compares 11 room area references; nine are outside their preliminary allowance or proposed C target (U-01, U-03, U-04, U-05, U-06, L-02, M-02, M-03 and proposed M-06). These remain visible review findings, not silent geometry edits. CO-018 records the variance.
- The integrated packet `.local/revit-pilot/review-packets/20261027T022256699507Z/` reports four native/manifest checks passing and IFC validation passing with ten open coordination findings (CO-001 plus nine room-area variances).
- Final offline rerun used the checked-in `.venv`: `validate_compact_ifc.py` returned `passed: true`, `all_documented_room_areas_compared: true`, and 0 IFC schema issues; Python compilation, preflight, manifest validation and packet compilation also passed.
- The standard build script first failed when it tried to overwrite the add-in DLL loaded by the open Revit process. A separate-output build using `.local/revit-pilot/build-next/` succeeded with 0 errors and 2 MSBuild reference-resolution warnings. Do not rebuild to the live add-in output while Revit holds the DLL.

## Remaining limitations and next work

- The Compact-Core generator still authors room coordinates and fixture geometry explicitly in `Pilot.cs`; `compact-study-config.json` currently serves as a preflight inventory, not the generator's source of geometry. Unifying those inputs is a suitable next pipeline increment, provided current geometry is preserved and the result is host-verified.
- C remains a proposed test, not a selected plan. Nine room areas need review against the preliminary room program; M-06 remains an owner decision. No dimension was changed to force a pass.
- The upper stair still does not reach the upper-floor footprint. Landing, headroom, guards, stair opening, floor solids/support, foundations, roof and lift/accessibility route remain unverified.
- DWG binary geometry, PDF visual quality, Revit 2018 import, code, MEP/structure, and professional review remain open. Zero Revit warnings and zero IFC schema errors do not close them.
- The default build script requires Revit to release the loaded assembly before it can replace the default output DLL.

## Commands for the recorded validation flow

```powershell
./.venv/Scripts/python.exe Tools/RevitPilot/preflight_compact_study.py
./.venv/Scripts/python.exe Tools/RevitPilot/validate_compact_manifest.py .local/revit-pilot/compact-core/<study-run>/study-manifest.json
./.venv/Scripts/python.exe Tools/RevitPilot/validate_compact_ifc.py .local/revit-pilot/exports/<export-run> .local/revit-pilot/compact-core/<study-run> --report .local/revit-pilot/exports/<export-run>/ifc-validation.json
./.venv/Scripts/python.exe Tools/RevitPilot/compile_review_packet.py
```

Run generation, audit, Geometry QA and manifest exports in Revit 2027. The offline commands do not open or modify Revit models. This is a BIM pipeline acceptance record, not a permit, engineering, code or construction approval.
