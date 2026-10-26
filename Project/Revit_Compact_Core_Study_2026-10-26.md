# Revit compact-core study verification

Date: 2026-10-26
Status: **executed study; not a coordinated house model or compliance review**

The standalone `Forever Home Compact Study` add-in entry point ran in Revit 2027.3 and saved a separate study file under the ignored local run directory:

`.local/revit-pilot/compact-core/20261026T030517168Z/FH_Compact_Core_Study.rvt`

After moving the lift reservation 6 in inward from the rear shell edge, a second run was saved at `.local/revit-pilot/compact-core/20261026T031040832Z/FH_Compact_Core_Study.rvt`. The same wall-overlap warning persisted, so the warning is not closed; the next cleanup should replace the overlapping wall-loop construction with non-overlapping boundary geometry.

The latest run, `.local/revit-pilot/compact-core/20261026T031326866Z/FH_Compact_Core_Study.rvt`, adds five native main-level room-block envelopes: `M-01` living, `M-02` kitchen, `M-03` dining, `M-06` proposed main bath and `L-02` main flex sleeping room. Revit reported **0 errors and 2 wall-overlap warnings**; the command completed and saved the RVT. These are un-door-ed room envelopes, not finished rooms, accessible routes or a preferred plan.

The upper/lower expansion run, `.local/revit-pilot/compact-core/20261026T031547281Z/FH_Compact_Core_Study.rvt`, adds upper private-room envelopes (`U-01`, `U-02`, `U-03`, `U-04`, `U-05`, `U-06`) and lower bath/laundry/MEP/arrival/flex/relocated-technology envelopes (`L-01`, `L-03`, `L-04`, `L-05`, `L-06`, `L-07`). Revit reported **0 errors and 13 wall-overlap warnings**. The technology room is shown at the lower rear, outside the Jack & Jill plan zone; plumbing, acoustic and service coordination remain unverified.

The next batch revision widens room-loop separations to at least 12 in centerline where practical and moves the lift reservation farther from the shell. It builds successfully but is **not yet executed in Revit**; do not treat its warning count or geometry as verified until the next planned reload.

The following batch also creates native `Room` elements with stable program IDs and dedicated main/upper/lower plan views. It builds successfully but remains **unexecuted** until a planned single Revit reload; expected checks are room area/identity creation plus the existing wall-warning count.

The command now writes `study-manifest.json` beside each generated RVT with intended level IDs, shell/lift targets, program IDs and unresolved-review flags. The manifest code builds successfully; its host-generated contents remain unverified until the next Revit execution.

The batched verification run completed at `.local/revit-pilot/compact-core/20261026T032659086Z/`. Revit created the study with **0 errors and 3 wall-overlap warnings**. The generated `study-manifest.json` passed the offline validator: all three C levels, all 17 stable room IDs, the 40 x 40 ft main target, the 8 x 8 ft lift reservation and unresolved-review flags are present.

The next queued batch adds a generated nominal door family, five tagged door instances, a native room-area schedule and a main-plan route note. It builds successfully but is **not yet host-verified**; door clear openings, swings and accessibility remain explicitly unresolved.

The first host attempt of that batch was stopped by a lookup typo (`FH-C-SHELL-1` versus the generated `FH-C-SHELL-01` tag) before saving a study. The tag was corrected and the add-in rebuild passed; the next planned reload should retry the complete batch once.

The queued batch now fails explicitly if a required door host wall is missing and includes five door IDs in `study-manifest.json`; the offline validator checks those IDs as well. Build and Python syntax checks pass. No additional Revit reload has been performed.

Created elements are intentionally limited to:

- `C Lower -5 ft`, `C Main 0 ft`, `C Upper +5 ft` levels
- 40 x 40 ft main shell wall reservation
- 8 x 8 ft lift-reservation wall loop tagged `FH-C-LIFT-RES-*`
- two native stair objects tagged `FH-C-STAIR-LOWER-MAIN` and `FH-C-STAIR-MAIN-UPPER`
- a named `C Compact Core 3D` view

The run completed and displayed its success dialog. Revit issued one wall-overlap warning where the core reservation meets the shell boundary; it was accepted for this study and remains an open cleanup item. No rooms, furniture, lift product, floor assemblies, headroom checks, exports or accessibility claims were created. The study file is not a preferred-plan selection.
