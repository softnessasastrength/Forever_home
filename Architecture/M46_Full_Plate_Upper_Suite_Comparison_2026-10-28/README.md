# M46 — full-plate upper-suite comparison

**Status: one reproducible room-block candidate found in an unapproved shell expansion.** The 40 × 42 ft comparison reuses the owner's existing main-floor test envelope as an exploratory upper-shell size. It is larger than the selected-D upper-wing source and is not an adopted house dimension. The selected-D source remains unchanged.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope U-02-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -ShellWidthOverrideFt 40 -ShellDepthOverrideFt 42 -NodeLimit 4000 -LayoutLimit 5000 -OutputDirectory 'Architecture/M46_Full_Plate_Upper_Suite_Comparison_2026-10-28'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_upper_suite_candidate.ps1 'Architecture/M46_Full_Plate_Upper_Suite_Comparison_2026-10-28'
```

Two full runs with these inputs produced byte-identical search, checks, SVG and manifest files. The generator's integrity gate passes **28/28**; the independent candidate validator passes **105 checks**. The retained SVG is `upper-suite-search.svg`.

## Candidate room blocks

Coordinates use the selected-D upper local frame (feet), with the documented 6 ft frame offset retained as source context. The candidate contains the source-sized rooms, with allowed rotations:

| Block | x | y | width | depth |
|---|---:|---:|---:|---:|
| U-01 | 0.000 | 11.500 | 10.000 | 16.000 |
| C-PRIVATE | 4.667 | 28.000 | 10.000 | 6.500 |
| U-02 | 11.167 | 17.833 | 16.000 | 9.667 |
| U-03 | 11.167 | 8.167 | 13.667 | 9.167 |
| U-04 | 30.333 | 17.833 | 8.000 | 13.667 |
| U-05 | 0.000 | 2.000 | 10.000 | 9.000 |
| U-06 | 25.333 | 5.333 | 10.000 | 12.000 |

The tested block bounds are 38.333 × 32.500 ft within the unapproved 40 × 42 ft shell. Independent checks confirm the source dimensions in either allowed orientation, no room-block overlap, every required nominal contact edge, and no overlap with the projected lift reservation or reserved stair approach. Contacts use the existing 0.5 ft nominal wall-gap and 3.5 ft source reservation; neither represents a selected clear door opening.

## Route result and trade-off

The run examines **180** complete room packings and tests the 4 ft hall-route proxy for all 180, each retaining the stair-approach keepout. **10/180** reach sampled hall-side goals for all three required public rooms U-01, U-02 and U-04. The retained candidate is the first such result in the generator's layout ranking. U-02 has sampled direct hall-side reach; U-03 has no sampled hall-side reach in this candidate. The topology retains U-01 → C-PRIVATE → U-02 → U-03 as a private sequence, U-04 guest hall access, both U-03/U-04 Jack-and-Jill contacts through U-06, and U-05 primary-only access.

This is a room-block and corridor-grid proposal only. The route samples are not doors or clear-opening checks. Actual doors, swings, privacy treatment, stair geometry, headroom, walls, floors, structure, MEP, roof, code requirements and Revit/IFC geometry have not been tested here. The search reaches its 4,000-node cap and remains incomplete; the 10 passing route cases are not an exhaustive feasibility result. Nothing in this comparison selects the 40 × 42 ft shell or authorizes editing selected D.

The early-prune variant for this larger shell exceeded a 20-minute local runtime limit and was stopped without a report; it is not counted as a result. The no-prune run tested route reachability only on complete packings and returned the retained candidate in about seven minutes.

## Reproducibility

Two no-prune runs matched byte-for-byte:

| File | SHA256 |
|---|---|
| `search.json` | `8674DE961D882D8FDDF74D0B49A5852BCB9878A9C2369319DC8A0FE4F241E39E` |
| `checks.json` | `361E3B89639BF08B9B18FD49BBA0DB2F285F42E867166A4E4D7D53DAB264E61C` |
| `upper-suite-search.svg` | `45C1ED280A46FC3598D81F990E9E82779803D0D7755FE43B8FF6F1A862CDA12B` |
| `manifest.json` | `42E532E2B72C85E1F977FC82A9D685807CDFD377E4E66059CA84C4898D626997` |
