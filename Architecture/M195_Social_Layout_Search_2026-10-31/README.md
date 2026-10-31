# M195 social layout search

**Status:** reproducible bounded sensitivity; no passing route candidate.

## Purpose and limits

M195 evaluates four finite dining/table/porch placement variants against the M186 quarter-foot grid route search. The route search retains both M-06 diagnostic windows, the pantry, entry, 8 × 4 ft island, assumed stool-use envelopes, half-wall/return, casework, table, four chairs and four 36-in chair-use rectangles. The 5-ft porch-door reservation is centered on each dining block's axis.

The kitchen remains M178's **13.5 × 14 ft / 189 sf test**, including the 8 × 4 ft island. Although the owner authorized finding the smallest route-passing kitchen, this milestone does **not** vary kitchen area and does **not** prove a minimum. It only tests the stated social-layout adjustments at that fixed kitchen candidate.

## Reproduction

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m195_social_layout_candidates.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m195_social_layout_candidates.ps1 `
  -OutputDirectory .local/revalidation/M195-independent `
  -ScratchPrefix M195-independent
```

The first command writes the retained package below `artifacts/`; the second writes only under ignored `.local/revalidation/`. The script refuses a nonempty output directory. For another replay, choose a fresh output directory and scratch prefix.

## Results

Three Windows PowerShell 5.1 executions (two independent scratch runs and the retained package run) pass **9/9** M195 checks. Each of the four generated M186 runs passes **29/29** checks. All three retained output files match byte-for-byte across all executions:

| Artifact | SHA256 |
|---|---|
| `m195-social-layout-search.json` | `C9C15B8A3523A8B04DC6256186EE147E7CD4865BD22F5C0CD34EA8DA5E4118CC` |
| `m195-checks.json` | `E1139A10BF1DE2D5D83CC3485BF22B63402E887B859E04C176CEFA094D13C92E` |
| `m195-candidates.csv` | `54D1FEFE921FF228F84F3EED00ECFB10DE67203D5B10B7AE2D368D0445250B16` |

**0/4** placement variants find a sampled route. The B window remains unassigned, unobstructed by dining/porch, and clear of route geometry. The porch footprint overlaps alternate diagnostic A by approximately **0.403–1.007 sf** in the tested offsets; A is not an assigned room, and that overlap is a trade-off to keep visible. The nearest reachable sample remains 12–12.5 ft from the candidate door, depending on offset.

## Inputs and safeguards

The report binds SHA256 fingerprints for the M186 search, M178 candidate, M192 orientation study, kitchen/dining/porch specification, selected-D study, bath-window source and owner kitchen-area decision. Selected-D remains at `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`.

No selected-D, RVT, IFC or Incoming RFA was changed. M-06/B remains unassigned. This is a schematic proxy study and establishes no code, accessibility, structural, professional, permit or construction-readiness result.

## Next work

The required minimum-area search still needs to vary kitchen geometry/area and its relationship to the route, rather than spending further effort on these four social-placement variants. Keep the larger island as the owner's comparison priority, preserve B, show any A use as a separate trade-off, and report failure honestly if the route remains infeasible. Replace the assumed stool envelope with measured family geometry when the authorized Revit inspection can be run.
