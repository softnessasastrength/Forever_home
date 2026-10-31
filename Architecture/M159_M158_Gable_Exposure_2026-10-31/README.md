# M159 - M158 room-block exposure under ideal gable planes

**Status:** source-bound relative geometry sensitivity. The M158 layouts and 38 1/3 x 40 ft shell remain unselected exploration artifacts. No roof pitch or ridge axis is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m159_m158_roof_exposure.ps1 `
  -OutputDirectory Architecture/M159_M158_Gable_Exposure_2026-10-31
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m159_m158_roof_exposure.ps1 `
  -OutputDirectory .local/revalidation/M159-replay
```

The analyzer binds the M158 search, manifest, candidate archive and independent audit, the M83 roof-option source, and the selected-D source. It computes each room rectangle's minimum and maximum rise under the six zero-thickness 8:12, 10:12 and 12:12 ideal gable planes. It records whether the block touches a plane's ideal eave edge. The candidate blocks are read from the archived route-tested rows; neither is promoted to a selected plan.

## Result

Both runs pass **15/15** source, inventory and arithmetic checks and produce the same 84 candidate/room/roof rows. Checks include that the two candidates differ only in U-05 and that at least two bedroom-capable blocks reach an ideal eave in every candidate/roof case:

| Artifact | SHA256 |
|---|---|
| `m159-relative-gable-exposure.json` | `129AF2DEDE5FC4012496537B62B68169A29E5EE75667B91ADAEBA481DFBB7A59` |
| `m159-room-gable-exposure.csv` | `62D9E137B68BB2508AA0FE4ED183F68BE8D80632ADF2536D4DDBF2E6F8143595` |

The two M158 candidates have identical U-01/U-03/U-04 rectangles; they differ in the alternate U-05 block, so their bedroom-capable-block roof exposure is identical. With a ridge along X, U-01 and U-04 touch ideal south/north eave edges and have 0 ft relative rise at those edges. With a ridge along Y, U-03 and U-04 touch ideal west eave edges and have 0 ft relative rise there. Thus, at least two of the three bedroom-capable blocks meet an ideal eave for either ridge direction across all three pitch cases. This is a coordination sensitivity for wall/eave/ceiling placement; it does not mean finished headroom is zero or insufficient.

## Limits

The output is relative roof-plane rise over schematic rectangles, not finished headroom, a sleeping-room suitability result, or an EERO check. Absolute eave and floor elevations, wall locations and thicknesses, roof framing/build-up, ceiling build-down, overhangs, dormers, openings, grade, site conditions and bedroom classifications remain unknown. No code applicability, structural design, load, drainage, accessibility, permit, Revit placement or IFC export is evaluated. No compliance, safety, certification or construction-readiness claim is made.

Source hashes and all check results are retained in `m159-relative-gable-exposure.json`.
