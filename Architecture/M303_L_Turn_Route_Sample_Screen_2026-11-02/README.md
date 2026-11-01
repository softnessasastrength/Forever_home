# M303 — Route screen for sampled M302 stair envelopes

Date: 2026-11-02

Status: **bounded sampled route screen found no connection to C-LOWER; no stair or route selected.**

## Scope

M303 tests both outer ends of the two M301 L-turn flight proxies from each of the first 24 retained M302 spatial options (ranked by L-01 movement). It uses the committed M302 report, the fixed C-LOWER block, each option's same-area L-01 placement, all remaining source room blocks and both protected M-06 windows. The shell remains the hypothetical 38.333333 × 40 ft sensitivity. West A stays protected; M-06/B remain unassigned.

At each proxy flight end, the route centerline begins 18 in outward from the run edge so a 36-in swept rectangle touches the assumed flight boundary. It searches orthogonal quarter-foot steps for connection to C-LOWER. This is an intentionally optimistic geometric proxy: M302 omits end landings, so the start is not a door or usable stair approach.

## Result and verification

The package-free .NET 10 generator builds with **0 warnings and 0 errors**. Two independent runs pass **6/6 checks**, produce byte-identical route JSON/check/SVG files and parse the SVG. The study tests **48** flight-end attempts and visits **20,907** route nodes; **zero** reaches C-LOWER. This is limited to the first 24 low-L-01-movement M302 options, not all 3,850,039 spatial fits. It does not prove that the expanded shell cannot support a stair route. It does show that shell expansion alone, in the sampled placements, has not solved the route problem.

## Reproduction

From the repository root in PowerShell, use new or empty output folders:

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M303Generator/M303Generator.csproj' --configuration Release --output '.local/revalidation/m303-build' --ignore-failed-sources
& '.local/dotnet/dotnet.exe' '.local/revalidation/m303-build/M303Generator.dll' 'Architecture/M302_Hypothetical_Lower_Shell_Stair_Sensitivity_2026-11-02/artifacts/m302-l-turn-stair-envelope-study.json' 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json' 'Decisions/2026-11-02_M303_L_Turn_Route_Sample_Screen.md' '.local/revalidation/m303-replay1'
& '.local/dotnet/dotnet.exe' '.local/revalidation/m303-build/M303Generator.dll' 'Architecture/M302_Hypothetical_Lower_Shell_Stair_Sensitivity_2026-11-02/artifacts/m302-l-turn-stair-envelope-study.json' 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json' 'Decisions/2026-11-02_M303_L_Turn_Route_Sample_Screen.md' '.local/revalidation/m303-replay2'
$a='.local/revalidation/m303-replay1'; $b='.local/revalidation/m303-replay2'; 'm303-route-screen.json','m303-checks.json','m303-routes.svg' | ForEach-Object { (Get-FileHash (Join-Path $a $_)).Hash -eq (Get-FileHash (Join-Path $b $_)).Hash }
[xml]$svg=Get-Content (Join-Path $a 'm303-routes.svg') -Raw
```

The generator pins all three source hashes and refuses a nonempty output directory. Successful runs: `.local/revalidation/m303-run2/` and `run3/`; canonical outputs are retained in `artifacts/`.

## Artifact hashes

| File | SHA256 |
|---|---|
| `m303-route-screen.json` | `94088884413B66B452C71EB39AB249D8FA0F7E53FCB342E3720F70F934C7D2B7` |
| `m303-checks.json` | `04C51C782A65AE79319B3A38A5E84DDB0F54C4D91360FB705B2EFBDC1FE2D276` |
| `m303-routes.svg` | `A52E14230D1A42FDE1F2BBE1CD76B199C28219ED677F10A7334614DD2781BA86` |

## Next

A larger shell produces spatial candidates but the sampled 36-in route proxies remain blocked. The next useful bounded analysis is a joint same-area L-01/L-02 move around the larger shell, with C-LOWER and both M-06 windows protected, checking for both a stair-envelope fit and route reach. This remains analysis only; the 38⅓ × 40 ft shell is one-third larger and unselected. If joint movement still fails, the owner must choose which fundamental constraint to relax before physical stairs are drafted.

No selected-D, Revit, IFC, family or remote state changed. No compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.
