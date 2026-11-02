# M300 — L-01 same-area stair-route study

Date: 2026-11-02

Status: **validated bounded negative result; no room or stair geometry selected.**

## Owner direction and scope

The owner directed: “Move/reshape L-01, keep the 60-in stair.” The study preserves L-01's previously selected source area (250.5556 sq ft), keeps L-02, C-LOWER and all other lower rooms fixed, and holds the 36 × 32 ft comparison shell. It uses M295's 8 × 7.5-in riser / 7 × 11-in tread / 4-ft width / 4-ft landing references and M215's 36-in project route screen. Both M-06 search windows remain protected, west A protected, B unassigned. The scoped authorization is `Decisions/2026-11-02_M300_L01_Move_Stair_Route_Study_Authorization.md`.

## Result

The package-free .NET 10 generator builds with **0 warnings and 0 errors**. Two independent runs each pass **14/14 checks**, produce byte-identical JSON/check/SVG artifacts, and the SVG parses as XML.

The generator enumerates **1,098** same-area L-01 rectangles on the quarter-foot study grid and tests all 1,098. In the maximum-free stair screen, L-01 is omitted entirely. Of 16,892 full-size stair envelopes, 13,764 intersect another fixed lower room, 2,769 intersect a protected M-06 window, and 228 cross C-LOWER outside an end landing. **131 envelopes survive** that screen. After pairing those envelopes with all L-01 candidates, only **10** non-overlapping candidate/stair pairs remain. Both ends of each pair were searched (20 route searches); each search was stopped immediately by a blocked adjacent cell (20 total nodes visited). No direct landing interface or separate 36-in path was found.

This means moving L-01 alone also fails to make the inherited full-rise stair/route screen pass while L-02, C-LOWER, other rooms and M-06 windows remain fixed. Together, M297 and M300 show that moving either flex room alone does not resolve this particular bounded layout. They do not prove a stair or house layout is impossible.

## Reproduction

From the repository root in PowerShell:

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M300Generator/M300Generator.csproj' --configuration Release --output '.local/revalidation/m300-build' --ignore-failed-sources
& '.local/dotnet/dotnet.exe' '.local/revalidation/m300-build/M300Generator.dll' 'Architecture/Selected_Design_Iteration_2026-10-27/study.json' 'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json' 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json' 'Decisions/2026-11-02_M300_L01_Move_Stair_Route_Study_Authorization.md' '.local/revalidation/m300-replay1'
& '.local/dotnet/dotnet.exe' '.local/revalidation/m300-build/M300Generator.dll' 'Architecture/Selected_Design_Iteration_2026-10-27/study.json' 'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json' 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json' 'Decisions/2026-11-02_M300_L01_Move_Stair_Route_Study_Authorization.md' '.local/revalidation/m300-replay2'
$a='.local/revalidation/m300-replay1'; $b='.local/revalidation/m300-replay2'; 'm300-l01-stair-route-study.json','m300-checks.json','m300-options.svg' | ForEach-Object { (Get-FileHash (Join-Path $a $_)).Hash -eq (Get-FileHash (Join-Path $b $_)).Hash }
[xml]$svg=Get-Content (Join-Path $a 'm300-options.svg') -Raw
```

Input hashes for selected-D, M295, M215 and M300 authorization are pinned in the generator. The generator refuses non-empty output folders and writes only inside the repository. Successful ignored runs: `.local/revalidation/m300-run2/` and `run3/`.

## Reproduced artifact hashes

| File | SHA256 |
|---|---|
| `m300-l01-stair-route-study.json` | `E6FF89A66D735F98CBB777ED8198F53F9C577A5FA4D72D4BA8E3D68ED4C82D17` |
| `m300-checks.json` | `D28DE3CED1181C784B0BC0A85793B98ECC1DDAC79F6D5C63886FDA981B30B408` |
| `m300-options.svg` | `D7634622D11EFF34AFE8C4EFB5ABBAB9C84E8188CCC894578322F41174247AA0` |

## Limits and next design gate

This is a bounded 0.25-ft-grid rectangle study. It does not model physical doors/openings, landings beyond the inherited rectangles, wall/finish thickness, stair headroom/opening, rails/guards, structure, services, tolerances, actual approach geometry, site/grade or route continuity beyond C-LOWER. The 36-in route width is a project screen, not a code or accessibility determination. No Revit or IFC was created, and selected-D/RVT/IFC/family files were not changed.

The next useful comparison is a stair/level arrangement study that preserves the 60-in transition and the current room blocks, or a broader joint room/stair search with additional freedom explicitly labeled. Keep M-06/A/B unassigned and west A protected. No compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows.
