# M285 — DD-013 vertical section and lower stair-envelope study

Date: 2026-11-01
Status: **Analysis only; no floor levels or stair location selected.**

## Basis and scope

The owner selected DD-013's preferred six risers at 7¼ in each (43½ in total) as the basis for a separate vertical comparison. The source selected-D design remains at −5/0/+5 ft, or 60 in between adjacent levels. The proposed study datums are −3.625/0/+3.625 ft. This does not change the selected design or authorize native Revit elements.

The plan screen uses DD-013's cited 38-in preferred clear width, five 10½-in treads, and two 36-in landing references. Their combined rectangular envelope is 3 ft 2 in × 10 ft 4½ in (the formula is 3 ft + 5 × 10½ in + 3 ft). It searches a 36 × 32 ft lower shell on a ¼-ft grid with a ⅔-ft perimeter margin. Room rectangles are treated as obstacles; the existing circulation rectangle is separately measured rather than treated as a room.

## Results

- C#/.NET 10 build: **0 warnings, 0 errors**. Two fresh runs: **17/17 checks each**, with report, checks, and both SVGs byte-identical.
- The arithmetic screen yields 6 × 7¼ = 43½ in. The cited CT numerical maximum in the pinned research is 8¼ in, so the nominal difference is 1 in. This is only a comparison of numbers, not a determination of code compliance or a complete stair design.
- The current selected-D comparison remains 8 × 7½ = 60 in. It is not the selected DD-013 alternative.
- The ¼-ft search finds **402** envelopes clear of the seven room rectangles. It separately screens both selected-D M-06 search windows and excludes any positive-area intrusion into west A or pantry-side B from the displayed candidates. **80** of the 402 room-clear envelopes overlap one of those protected zones; **322** preserve both. Among the 322, **40** also avoid positive-area overlap with the source circulation rectangle. The 6-in and 12-in room-block-gap counts are sensitivities, not standards: 130 and 48 candidates respectively. Measured M-06-window-gap sensitivities are 312 at 6 in and 302 at 12 in; all 80 protected-zone overlaps are with B, none with A.
- Closest to the legacy core reference: east-west at `(12.4167, 9.6667)` ft; nearest room-block gap **2 in**, circulation overlap **12.514 sf**.
- Best measured room-block gap among candidates with no overlap with the circulation rectangle or protected M-06 windows: east-west at `(24.9167,13.9167)` ft; **13 in** to the nearest room-block rectangle, but only **1 in** from protected window B. The no-circulation candidate maximizing measured separation from M-06 windows is east-west at `(23.9167,12.1667)` ft; its M-06-window gap is **22 in**, but its room-block gap is **0 in**. The highest room-gap sample overall is 23.5 in, but it overlaps the circulation rectangle by **32.854 sf**.

These examples expose the trade-off between room-block spacing and the source circulation reservation. None is a stair placement. In particular, a measured gap is not a door approach, accessible route, or required clearance.

## Reproduction

Run from the repository root in PowerShell. Both output folders must be new and empty; the generator intentionally refuses to overwrite prior evidence.

```powershell
.local\dotnet\dotnet.exe build Tools/M285Generator/M285Generator.csproj --configuration Release --output .local/revalidation/m285-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m285-build/M285Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Decisions/2026-11-01_DD013_Vertical_Section_Study_Basis.md .local/revalidation/m285-run1
.local\dotnet\dotnet.exe .local/revalidation/m285-build/M285Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Decisions/2026-11-01_DD013_Vertical_Section_Study_Basis.md .local/revalidation/m285-run2
```

PowerShell replay and XML checks used:

```powershell
Get-ChildItem .local/revalidation/m285-run1 | ForEach-Object {
  $a = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
  $b = (Get-FileHash (Join-Path '.local/revalidation/m285-run2' $_.Name) -Algorithm SHA256).Hash
  if ($a -ne $b) { throw "Replay mismatch: $($_.Name)" }
  if ($_.Extension -eq '.svg') { $null = [xml](Get-Content $_.FullName -Raw) }
}
```

## Pinned inputs and outputs

| File | SHA256 |
|---|---|
| Selected-D study source | `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` |
| DD-013 stair specification | `B480E12548612ACB2DBAF98361E5AC1512BE4D8A9F4EEEBF179DD8CDBCBD7C84` |
| CT stair research note | `65250B9F68A8674B2BF361F99B76C35C63A97E85EC75304F1F4E77681CC26EE6` |
| Owner's M285 basis | `EE7383E77C476099FC70BE3DCEA3CDC2853E0810A96322F29C71BB703039C316` |
| `m285-checks.json` | `501F80AA0C8199249015AA4B1DF8AF3E0F9D67E2872E8F655EF4B4AD81E7898F` |
| `m285-level-comparison.svg` | `2CA76A9D054CDC0B98E703122990AAACC7917845061E5EAD597BE5D3E8FB79CE` |
| `m285-lower-stair-search.svg` | `274A48EDC0795CD0269BC6AC7CFA33081BDF12D96ADA8BD82AA65B0B518A8A97` |
| `m285-vertical-section-screen.json` | `66FBF95A7D7AB07A71F0F2F1FAEBCACA67493344290A21DE0CE6E3F9E0C09F6C` |

## Limitations and next decision

The rectangular search does not model wall thickness, door swings, approach, furniture, continuous access, headroom, transitions, floor construction, structural support, or connections to the rest of the house. The level diagram is datum arithmetic only. No Revit object was created; selected-D/RVT/IFC/RFAs were not altered. The result does not establish code compliance, professional approval, or construction readiness.

Next, the owner can authorize an analysis-only lower flex-living move/reshape comparison against the stair-envelope candidates, or hold that block fixed and request a different circulation/stair concept. No location or room move is selected by M285.
