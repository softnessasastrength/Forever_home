# M297 — L-02 same-area stair-route study

Date: 2026-11-02

Status: **validated bounded negative result; no room/stair geometry selected.**

## Owner-authorized scope

The owner permitted L-02 to move or reshape while preserving its selected-D source area (110 sq ft). L-01, C-LOWER, other lower rooms and the 36 × 32 ft study shell stay fixed. The M295 full 60-in transition comparison remains in force: 8 risers at 7.5 in, 7 treads at 11 in, 4-ft flight/landing width and 4-ft landing depth. Route comparison uses the 36-in M215 project precedent only. Both M-06 search windows remain protected, west A stays protected and B remains unassigned. Authorization: `Decisions/2026-11-02_M297_L02_Same_Area_Stair_Route_Study_Authorization.md`.

## Result

The package-free .NET 10 generator builds with **0 warnings and 0 errors**. Two independent runs each pass **14/14 checks**; JSON, checks and SVG are byte-identical, and the SVG parses as XML.

The decisive screen removes L-02 from the plan entirely, giving the full-size 4 × 14.4167-ft stair envelope the maximum possible free area while retaining fixed rooms, C-LOWER and both protected M-06 windows. Across **16,892** quarter-foot-grid envelope placements:

- 16,272 overlap a fixed lower room;
- 600 overlap a protected M-06 window;
- 20 intersect C-LOWER outside either end landing;
- **0 survive** to a stair envelope or route search.

There are 4,761 possible same-area L-02 rectangles on the study grid. They were not individually route-searched because none can help: the stair-placement screen already gives L-02 no footprint at all and still finds no permissible stair envelope. Thus moving L-02 alone cannot produce the authorized full-rise stair fit while the remaining constraints stay fixed. This is a result for this bounded rectangle/grid model and input set, not proof that a real stair or house layout is impossible.

## Reproduction

From the repository root in PowerShell, using the repository-local .NET SDK:

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M297Generator/M297Generator.csproj' --configuration Release --output '.local/revalidation/m297-build' --ignore-failed-sources
& '.local/dotnet/dotnet.exe' '.local/revalidation/m297-build/M297Generator.dll' 'Architecture/Selected_Design_Iteration_2026-10-27/study.json' 'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json' 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json' 'Decisions/2026-11-02_M297_L02_Same_Area_Stair_Route_Study_Authorization.md' '.local/revalidation/m297-replay1'
& '.local/dotnet/dotnet.exe' '.local/revalidation/m297-build/M297Generator.dll' 'Architecture/Selected_Design_Iteration_2026-10-27/study.json' 'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json' 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json' 'Decisions/2026-11-02_M297_L02_Same_Area_Stair_Route_Study_Authorization.md' '.local/revalidation/m297-replay2'
$a='.local/revalidation/m297-replay1'; $b='.local/revalidation/m297-replay2'; 'm297-l02-stair-route-study.json','m297-checks.json','m297-options.svg' | ForEach-Object { (Get-FileHash (Join-Path $a $_)).Hash -eq (Get-FileHash (Join-Path $b $_)).Hash }
[xml]$svg=Get-Content (Join-Path $a 'm297-options.svg') -Raw
```

The generator pins hashes for selected-D, M295, M215 and the owner authorization, rejects output folders that already contain files, and writes only to repository-local output paths. Successful ignored evidence from this run is in `.local/revalidation/m297-run5/` and `.local/revalidation/m297-run6/`.

## Reproduced artifact hashes

| File | SHA256 |
|---|---|
| `m297-l02-stair-route-study.json` | `B7BEF6CCE8CB6541AD10112D2A0F04C5050DBF5C48F7A186CFCD4E932FEC6749` |
| `m297-checks.json` | `218DFD154603936262F88D0173815E105AA410BAE2D92E119BEB4C937D1E74B5` |
| `m297-options.svg` | `FC6C1B97C2382138A98695AEF5C58B8E849F07163B8BCA61C2333E8F179BF2D0` |

## Limits and next design gate

The screen models rectangular room blocks, stair envelope and protected-window footprints. It omits actual landings beyond their nominal 4-ft rectangles, wall/finish thicknesses, doors/openings/leaf swings, headroom, stair opening, rails/guards, structure, services, transitions, site/grade and route continuity beyond C-LOWER. The 36-in route input is a project screening precedent, not code or accessibility approval. No Revit or IFC was generated; selected-D, its RVT/IFC and family files were not changed.

Progress now requires relaxing at least one constraint beyond L-02: for example, authorize a separate same-area L-01 move/reshape study, or compare a different stair/vertical arrangement while preserving current room geometry as a parallel case. Keep M-06/A/B unassigned and west A protected until new evidence and owner choices support a change. No compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows.
