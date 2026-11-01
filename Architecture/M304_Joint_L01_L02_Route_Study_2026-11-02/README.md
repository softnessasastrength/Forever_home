# M304 — Joint L-01/L-02 route study in the hypothetical larger shell

Date: 2026-11-02

Status: **nine bounded room/stair/route proxy options found; no physical geometry selected.**

## Owner direction and trade-off

The owner chose to keep the larger shell for analysis and move L-01 and L-02 together. The 38.333333 × 40 ft shell remains hypothetical and unselected. At 1,533.33 sq ft it is 381.33 sq ft (33.1%) larger than the 36 × 32 ft comparison. C-LOWER and all other lower rooms remain fixed; both M-06 windows remain protected and unassigned; west A stays protected and B unassigned.

## Search and result

`Tools/M304Generator` builds with repository-local .NET 10: **0 warnings, 0 errors**. Two independent runs pass **7/7 checks**, match the report/check/SVG byte-for-byte and parse the SVG.

The first stage omits both movable rooms as an optimistic upper bound and finds **12** potential 36-in route proxies from **48** tested flight ends. The second stage generates **116,548** same-area L-01 placements and **334,671** same-area L-02 placements. It samples up to 1,000 L-01 and 5,000 L-02 candidates per permissive corridor, combining movement-nearest samples with evenly spaced samples across the movement-ranked lists. Across **32,074** candidate room/stair combinations, it finds **9** options preserving both room areas and a 36-in swept route proxy to fixed C-LOWER. No search hits the 2,500-node route cap.

The lowest combined movement-metric example moves L-01 about 10 ft east while preserving 250.5556 sq ft, and reshapes L-02 to **14.5 × 7.586 ft** at `(21.667, 31.747)` while preserving 110 sq ft. Its route proxy is about **34 ft**. The movement score is a simple coordinate/dimension-difference ranking aid, not a design cost or recommended room shape. These are study candidates only: the L-turn remains an unverified 3+4 aggregate tread-run proxy with one internal 4 × 4 ft platform; end landings, real riser allocation, doors, approach and beyond-C-LOWER circulation are absent. No fit here establishes a usable stair or code-compliant route.

## Reproduction

From the repository root in PowerShell, use new or empty output folders:

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M304Generator/M304Generator.csproj' --configuration Release --output '.local/revalidation/m304-build' --ignore-failed-sources
& '.local/dotnet/dotnet.exe' '.local/revalidation/m304-build/M304Generator.dll' 'Architecture/M302_Hypothetical_Lower_Shell_Stair_Sensitivity_2026-11-02/artifacts/m302-l-turn-stair-envelope-study.json' 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json' 'Decisions/2026-11-02_M304_Joint_L01_L02_Route_Study.md' '.local/revalidation/m304-replay1'
& '.local/dotnet/dotnet.exe' '.local/revalidation/m304-build/M304Generator.dll' 'Architecture/M302_Hypothetical_Lower_Shell_Stair_Sensitivity_2026-11-02/artifacts/m302-l-turn-stair-envelope-study.json' 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json' 'Decisions/2026-11-02_M304_Joint_L01_L02_Route_Study.md' '.local/revalidation/m304-replay2'
$a='.local/revalidation/m304-replay1'; $b='.local/revalidation/m304-replay2'; 'm304-joint-room-route-study.json','m304-checks.json','m304-routes.svg' | ForEach-Object { (Get-FileHash (Join-Path $a $_)).Hash -eq (Get-FileHash (Join-Path $b $_)).Hash }
[xml]$svg=Get-Content (Join-Path $a 'm304-routes.svg') -Raw
```

The generator pins committed M302/M215 inputs and this authorization, and writes only to a new repository-local output folder. Successful runs: `.local/revalidation/m304-run9/` and `run10/`. Canonical outputs are in `artifacts/` below.

## Artifact hashes

| File | SHA256 |
|---|---|
| `m304-joint-room-route-study.json` | `007F7959EF9900F944236C509989CC267DD5C4D08DFF191E712CC9D0679880F9` |
| `m304-checks.json` | `466735D000AE2B6318DE7128A661AD70A4CBE1B50195DE64B61B4A50328FDB57` |
| `m304-routes.svg` | `749E4C67AB28EC5EF95A06D3F23BCD563E41AACF865A72204F4B535D4857D34C` |

## Next

Use the least-movement sample for a separately authorized disposable Revit plan/section derivative only after the owner reviews the 33.1% shell premium and the hypothetical stair-run split. Before any native stair, test a lower-level end landing, door/approach, visible room geometry and route continuation beyond C-LOWER. Do not alter selected-D or the existing M299 shell comparison.

No selected-D, Revit, IFC, family or remote state changed. No code compliance, accessibility, structural safety, professional approval, permit or construction-readiness conclusion follows.
