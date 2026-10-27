# Implementation progress

Updated: 2026-10-27
Status: the configuration-driven generator has now produced a fresh Revit study and passed offline manifest, preflight and regression checks. Native audit, geometry QA and IFC export for this exact run remain outstanding. Architectural coordination remains open.

## Goal

Implement `PLAN.md` against `REQUIREMENTS.md`, complete each milestone, run its documented checks, and keep this file current.

## Repository safety and baseline

- Current local ref is `79e74d0` (`Add reproducible compact-core IFC validation`), two commits ahead of `origin/design/vr-tech-bom-roadmap` at `ae3d875`; `main` and `origin/main` remain at `9bec5d3`. Reflog inspection confirmed the two local commits after the tracking tip. No fetch, push, merge, reset, rebase, prune, garbage collection, or history rewrite was performed.
- The prior checkpoint recorded the geometry-config refactor as an existing dirty worktree (10 modified tracked files plus a new test file). This resumed audit's direct index-to-file hash comparison found broader working-file differences, but Git's executable was unavailable to classify staged, unstaged, line-ending and ignored changes reliably. Treat the worktree as dirty and preserve it; no clean-tree claim is made.
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

- M5 now moves the existing level, shell/core, room boundary/seed, door, stair, floor-loop and illustrative overlay inputs into `compact-study-config.json`. `Pilot.cs` reads the file at runtime, preserves a byte-for-byte copy beside each generated run, and writes its SHA256/schema into the study manifest. Manifest validation checks the snapshot hash and matches levels, room/door IDs, shell/lift targets and floor profile targets. The source values were copied unchanged from the prior generator; geometry intent was not revised.
- M5 offline checks pass: preflight validates all room IDs, in-boundary seeds, door host references, stair endpoints, overlay geometry and floor polygon areas. The five configuration tests cover valid input, invalid geometry mutations and config-snapshot/manifest hash consistency. Five additional review-packet tests cover timestamp precision, stale/unparseable/missing-study evidence, and rejection of an older IFC for a newer study. The RevitPilot C# project previously built with 0 errors and the existing 2 reference-resolution warnings.
- The prior IFC run remains compatible with the updated validators: 17 spaces, 0 schema issues, and the same 10 coordination findings. This is a regression check of the prior generator export, not evidence for the refactored Revit output.
- Fresh Revit generation against the configuration-driven build is now confirmed, but the corresponding native audit, Geometry QA and IFC export have not been run. Revit opened the generated study and reported it saved, but the computer-use bridge returned `Accessibility state unavailable for window 331914` during the attempt to invoke read-only host checks. No fresh geometry counts or IFC pass are claimed for M5 until those checks complete.
- The previous host run remains valid evidence for the previous generator revision only: `.local/revit-pilot/compact-core/20261027T021357786Z/` and its linked audit, QA and IFC outputs. It is preserved unchanged.
- C remains a proposed test, not a selected plan. Nine room areas need review against the preliminary room program; M-06 remains an owner decision. No dimension was changed to force a pass.
- The upper stair still does not reach the upper-floor footprint. Landing, headroom, guards, stair opening, floor solids/support, foundations, roof and lift/accessibility route remain unverified.
- DWG binary geometry, PDF visual quality, Revit 2018 import, code, MEP/structure, and professional review remain open. Zero Revit warnings and zero IFC schema errors do not close them.
- The default build script requires Revit to release the loaded assembly before it can replace the default output DLL.

## Configuration-driven run validation update

- The final-source Revit add-in generated `.local/revit-pilot/compact-core/20261027T025740849Z/` as a separate study. Its manifest records schema `forever-home.compact-study-config.v2` and SHA256 `83a76b30223a0b7ab1a51ef71ed34dd075e4fa9b2f9eea6e5673fc2e05673357`; this exactly matches the checked-in `Tools/RevitPilot/compact-study-config.json`. The timestamped folder contains the RVT, nominal door family, floor schedule, manifest and an empty native warning list.
- `validate_compact_manifest.py .local/revit-pilot/compact-core/20261027T025740849Z/study-manifest.json` passes: 17 rooms, three floor plates, with the documented roof and stair issues retained. `preflight_compact_study.py Tools/RevitPilot/compact-study-config.json` passes: three levels, 17 room boundaries, five nominal doors and three polygon-checked floor plates.
- `python -m unittest discover -s Tools/RevitPilot/tests -v` passes all five regression cases: valid config, invalid room seed, invalid door host, floor polygon area drift, and manifest snapshot/hash consistency.
- Independent IFC validation was rerun against `.local/revit-pilot/exports/20261027T021506070Z/` and its matching prior study `.local/revit-pilot/compact-core/20261027T021357786Z/`; it passes IFC2X3/schema/hash, three storeys, 17 spaces, major class counts, floor markers/areas, room CSV and physical geometry checks, with zero schema issues. The report is `.local/revit-pilot/exports/20261027T021506070Z/ifc-validation-rerun.json`. This evidence belongs to the earlier generator run, not `20261027T025740849Z`.
- The earlier study's API audit and geometry QA remain valid evidence for that earlier run: 3 levels, 17 enclosed rooms, 78 walls, 5 openings/doors, 2 stairs, 3 floors and no native warnings or QA errors. The Revit computer-use bridge again stopped exposing accessibility state while a study notice was open, so no fresh native audit, geometry QA or IFC export was completed for the config-driven run. Do not mark M5 complete yet.
- The review-packet compiler previously selected the latest study, audit, QA and export independently, allowing older QA/export evidence to be presented alongside a newer model. It now compares timestamped run directories, marks older evidence `STALE`, refuses to run IFC validation across that stale pair, and records freshness states in the packet. Packet `.local/revit-pilot/review-packets/20261027T033022749434Z/` confirms the 02:57 study manifest passes while the 02:14 audit, 02:14 QA and 02:15 IFC are correctly marked stale. This is a timestamp guard, not proof that later reports belong to that RVT; reports still omit document paths.

## Commands for the recorded validation flow

```powershell
./.venv/Scripts/python.exe Tools/RevitPilot/preflight_compact_study.py
./.venv/Scripts/python.exe Tools/RevitPilot/validate_compact_manifest.py .local/revit-pilot/compact-core/<study-run>/study-manifest.json
./.venv/Scripts/python.exe Tools/RevitPilot/validate_compact_ifc.py .local/revit-pilot/exports/<export-run> .local/revit-pilot/compact-core/<study-run> --report .local/revit-pilot/exports/<export-run>/ifc-validation.json
./.venv/Scripts/python.exe Tools/RevitPilot/compile_review_packet.py
```

Run generation, audit, Geometry QA and manifest exports in Revit 2027. The offline commands do not open or modify Revit models. This is a BIM pipeline acceptance record, not a permit, engineering, code or construction approval.
