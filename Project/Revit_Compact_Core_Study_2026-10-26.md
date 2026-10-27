# Revit compact-core study verification

Date: 2026-10-26
Status: **executed study; not a coordinated house model or compliance review**

The standalone `Forever Home Compact Study` add-in entry point ran in Revit 2027.3 and saved a separate study file under the ignored local run directory:

`.local/revit-pilot/compact-core/20261026T030517168Z/FH_Compact_Core_Study.rvt`

After moving the lift reservation 6 in inward from the rear shell edge, a second run was saved at `.local/revit-pilot/compact-core/20261026T031040832Z/FH_Compact_Core_Study.rvt`. The same wall-overlap warning persisted, so the warning is not closed; the next cleanup should replace the overlapping wall-loop construction with non-overlapping boundary geometry.

The latest run, `.local/revit-pilot/compact-core/20261026T031326866Z/FH_Compact_Core_Study.rvt`, adds five native main-level room-block envelopes: `M-01` living, `M-02` kitchen, `M-03` dining, `M-06` proposed main bath and `L-02` main flex sleeping room. Revit reported **0 errors and 2 wall-overlap warnings**; the command completed and saved the RVT. These are un-door-ed room envelopes, not finished rooms, accessible routes or a preferred plan.

The generator was subsequently revised so the lower/upper study envelope uses one continuous stacked shell wall loop rather than coincident lower and upper shell loops, and normal wall-end joins remain enabled. The change builds with **0 errors** but is **not yet host-verified**; rerun the study after restarting Revit and record the new warning count before treating the cleanup as effective.

The stair study was then adjusted from 8 to 9 desired risers after Revit reported that the 7.5 in nominal riser exceeded the loaded stair type's maximum. Nine risers imply approximately 6⅔ in for the 5 ft level change, subject to host verification and final stair-type/code review.

The upper/lower expansion run, `.local/revit-pilot/compact-core/20261026T031547281Z/FH_Compact_Core_Study.rvt`, adds upper private-room envelopes (`U-01`, `U-02`, `U-03`, `U-04`, `U-05`, `U-06`) and lower bath/laundry/MEP/arrival/flex/relocated-technology envelopes (`L-01`, `L-03`, `L-04`, `L-05`, `L-06`, `L-07`). Revit reported **0 errors and 13 wall-overlap warnings**. The technology room is shown at the lower rear, outside the Jack & Jill plan zone; plumbing, acoustic and service coordination remain unverified.

The next batch revision widens room-loop separations to at least 12 in centerline where practical and moves the lift reservation farther from the shell. It builds successfully but is **not yet executed in Revit**; do not treat its warning count or geometry as verified until the next planned reload.

The following batch also creates native `Room` elements with stable program IDs and dedicated main/upper/lower plan views. It builds successfully but remains **unexecuted** until a planned single Revit reload; expected checks are room area/identity creation plus the existing wall-warning count.

The command now writes `study-manifest.json` beside each generated RVT with intended level IDs, shell/lift targets, program IDs and unresolved-review flags. The manifest code builds successfully; its host-generated contents remain unverified until the next Revit execution.

The batched verification run completed at `.local/revit-pilot/compact-core/20261026T032659086Z/`. Revit created the study with **0 errors and 3 wall-overlap warnings**. The generated `study-manifest.json` passed the offline validator: all three C levels, all 17 stable room IDs, the 40 x 40 ft main target, the 8 x 8 ft lift reservation and unresolved-review flags are present.

The next queued batch adds a generated nominal door family, five tagged door instances, a native room-area schedule and a main-plan route note. It builds successfully but is **not yet host-verified**; door clear openings, swings and accessibility remain explicitly unresolved.

The first host attempt of that batch was stopped by a lookup typo (`FH-C-SHELL-1` versus the generated `FH-C-SHELL-01` tag) before saving a study. The tag was corrected and the add-in rebuild passed; the next planned reload should retry the complete batch once.

The queued batch now fails explicitly if a required door host wall is missing and includes five door IDs in `study-manifest.json`; the offline validator checks those IDs as well. Build and Python syntax checks pass. No additional Revit reload has been performed.

The consolidated door/schedule verification run completed at `.local/revit-pilot/compact-core/20261026T033952779Z/`. Revit saved the RVT with **0 errors and 3 wall-overlap warnings**. The manifest contains all 17 room IDs and all five door IDs, and the offline validator passed. The five doors are nominal test instances; swings, clear openings, hardware, egress and accessibility remain unresolved.

The first main-floor design blitz completed at `.local/revit-pilot/compact-core/20261026T034508256Z/`. It adds native study markers for the 8 x 4 appliance-free island, perimeter counter, dining table/porch-lane target, living TV/hearth/furniture envelopes and main-bath nominal fixtures, plus explanatory notes on the main plan. Revit saved the RVT with **0 errors and 3 warnings**; the manifest validator passed. These markers are spatial study geometry, not selected products, final clearances or code approval.

Created elements are intentionally limited to:

- `C Lower -5 ft`, `C Main 0 ft`, `C Upper +5 ft` levels
- 40 x 40 ft main shell wall reservation
- 8 x 8 ft lift-reservation wall loop tagged `FH-C-LIFT-RES-*`
- two native stair objects tagged `FH-C-STAIR-LOWER-MAIN` and `FH-C-STAIR-MAIN-UPPER`
- a named `C Compact Core 3D` view

The run completed and displayed its success dialog. Revit issued one wall-overlap warning where the core reservation meets the shell boundary; it was accepted for this study and remains an open cleanup item. No rooms, furniture, lift product, floor assemblies, headroom checks, exports or accessibility claims were created. The study file is not a preferred-plan selection.

The follow-up API-assisted cleanup was host-verified in Revit 2027. The stacked shell was consolidated, the upper-room overlap was replaced with one shared divider, and the latest generated study is `.local/revit-pilot/compact-core/20261026T204202824Z/FH_Compact_Core_Study.rvt`. The warning report contains **0 wall-overlap warnings and 2 stair endpoint warnings**, both on `FH-C-STAIR-LOWER-MAIN`; the stair remains an unresolved study warning, not a code or accessibility determination. A read-only API audit of the same active document completed at `.local/revit-pilot/audits/20261026T204253392Z/`, recording 17 enclosed rooms, 78 walls, 5 openings and 2 warnings.

The final stair-geometry correction was host-verified in Revit 2027 at `.local/revit-pilot/compact-core/20261026T205526500Z/FH_Compact_Core_Study.rvt`. The lower run now uses the lower-level base elevation and an explicit relative top elevation; Revit wrote an empty `study-warnings.json` (**0 warnings**). The read-only API audit completed at `.local/revit-pilot/audits/20261026T205556399Z/` and recorded 17 enclosed rooms, 78 walls, 5 openings and **0 warnings**. This closes the current generator warning loop only; stair geometry, headroom, guards, finish buildup, accessibility and adopted-code review remain open.

## Provisional floor-plate pass

Revit 2027 generated a separate native study at `.local/revit-pilot/compact-core/20261026T223355667Z/FH_Compact_Core_Study.rvt`. It adds lower, main and upper native floor elements with stable IDs `FH-C-FLOOR-LOWER`, `FH-C-FLOOR-MAIN` and `FH-C-FLOOR-UPPER`. The main profile includes schematic openings around the two stair runs and the 8 x 8 ft lift reservation. `study-warnings.json` is empty (**0 native Revit warnings** for this run).

The plates use the template default `Floor 1` type (reported compound width: 1 ft). This is not a selected assembly. The separate 15 in value remains an arithmetic planning placeholder from the compact-core brief, not the modeled thickness. The lower/main/upper gross footprints are 2,752 / 1,600 / 1,152 sq ft; the authored main plate profile area is 1,410 sq ft after its 190 sq ft of schematic openings.

The first run's area field was invalid: a Revit built-in parameter returned 0 for all three plates. `Pilot.cs` now calculates profile area from the authored floor boundaries. The corrected host run reports lower/main/upper areas of 2,752 / 1,410 / 1,152 sq ft, and `validate_compact_manifest.py` passes for its manifest. The read-only API audit at `.local/revit-pilot/audits/20261026T223511518Z/` confirms 3 Floors, 17 enclosed rooms, 78 walls, 5 openings, 4 levels and 0 warnings. Geometry QA at `.local/revit-pilot/geometry-qa/20261026T223454799Z/` reports 0 heuristic issues. The review packet at `.local/revit-pilot/review-packets/20261026T223529514912Z/` passes all four existing checks. The QA heuristics do not inspect floor solids, stair/shaft fit or structure.

The study exposes a major vertical coordination issue: the main-to-upper stair run ends at y=34 ft, but the upper floor plate starts at y=40 ft in the rear wing. The landing and upper circulation footprint remain unresolved. The roof is omitted because no roof form, pitch or site response has been approved. Floor edges, stair/lift openings, support, foundations, clearances, and assemblies still need native-model review; this is not a coordinated house model or code review.

## Corrected three-level floor-plate verification

The duplicate zero-elevation datum was corrected by reusing the template level as `C Main 0 ft`. The regenerated Revit 2027.3 study is `.local/revit-pilot/compact-core/20261026T223829109Z/FH_Compact_Core_Study.rvt`. Its native API audit, `.local/revit-pilot/audits/20261026T223917252Z/audit.json`, confirms exactly **3 levels** (`C Lower -5 ft`, `C Main 0 ft`, `C Upper +5 ft`), **3 Floors**, 17 enclosed rooms, 78 walls, 5 openings and **0 Revit warnings**. The compact manifest validator passes with all three floor markers and calculated profile areas (2,752 / 1,410 / 1,152 sq ft).

## Floor-aware Geometry QA host verification

On 2026-10-27, the updated read-only Geometry QA command was run in Revit 2027.3 against `FH_Compact_Core_Study`. The evidence at `.local/revit-pilot/geometry-qa/20261027T004729569Z/geometry-qa.json` records 17 enclosed rooms, 78 walls, 2 stairs, 5 doors, 3 floors, 0 native Revit warnings, 0 heuristic issues and 0 errors. Stable floor markers and level assignments were found; reported areas are 2,752 / 1,410 / 1,152 sq ft. All three plates still use the template `Floor 1` type with 1 ft compound width, which is not an approved or engineered assembly.

The offline review packet at `.local/revit-pilot/review-packets/20261027T004753549365Z/` reports all four recorded checks passing, including floor-aware Geometry QA. This closes the host-execution gap for the API inventory increment only. It does not validate floor solids/openings, stair landing/headroom, structure, accessibility, code compliance, exports or professional review.

The floor plates remain provisional: the default template `Floor 1` type is 1 ft thick and is not a selected assembly; floor-edge/opening fit, structural support, foundations, the upper stair landing, and roof remain unresolved. The earlier 4-level audit is superseded by this corrected audit.
