# M305 — Lower end-landing and route refinement

**Status:** completed, bounded analysis only; no layout selected.

## Question and scope

M304 found nine joint L-01/L-02 room and stair-proxy arrangements with a 36-in swept route to C-LOWER, but omitted end landings. M305 tests both lower flight ends in those nine retained samples using a 4 × 4 ft rectangular landing proxy, then searches for a 36-in swept route from the landing exterior to fixed C-LOWER.

The shell is the unselected 38.333333 × 40 ft sensitivity (+381.33 sf / +33.1% over the 36 × 32 ft comparison). Both flex-room areas are preserved in each sampled M304 pair. C-LOWER, other fixed rooms and both protected M-06 search windows remain fixed. This does not select a house layout or authorize placement into Revit.

## Inputs and method

The .NET 10 C# generator pins SHA256 fingerprints for M304, M302, M295, M215 and this study's authorization record. It screens 18 flight ends across the nine M304 room/stair samples. The 4-ft flight width and 4-ft landing depth are inherited from M295 solely as comparison references. Candidate landing rectangles must fit inside the shell with M302's 8-in perimeter margin and avoid fixed/moved room blocks, protected windows and non-connected stair pieces.

For landing footprints that pass, a quarter-foot A* search tests a 36-in-wide swept rectangular route, starting one half-width beyond the landing edge and terminating at contact with C-LOWER. The per-search node cap is 10,000. All source dimensions and search rules are visible in `Tools/M305Generator/Program.cs` and the JSON report.

## Result

- Build: **0 warnings, 0 errors**.
- Two independent runs: **6/6 checks each**; JSON, checks and SVG are byte-identical.
- 9 sampled room/stair pairs; 18 landing-end attempts; 8 landing footprints pass; 6 landing-to-C-LOWER route proxies pass; 1,890 nodes visited; no node-cap hits.
- Passing cases are all flight-A ends from M304 samples 1–6. Their proxy route lengths range from 23.5 to 26 ft.
- All six passing landing locations occupy the same north-west band, roughly x=10.17–11.42 ft and y=31.42 ft. This is a narrow family of related samples, not six independent layout solutions.

This positive result improves on M304 by including one lower landing footprint and route to C-LOWER. It does **not** establish a workable stair: the L-turn remains an unverified 3+4 aggregate tread-run block proxy; actual riser distribution, stair run, landings at the other end, headroom, opening, rails/guards, door swings, approach, wall/finish tolerances, construction assemblies, structure, MEP, route beyond C-LOWER and site conditions remain unresolved. The 36-in route is an internal screening precedent, not a code or accessibility finding. The larger shell remains unselected and carries the stated 33.1% area premium.

No selected-D geometry, RVT, IFC, family or remote state changed. The incoming Evolution RFA was left intact and its SHA256 remained `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`.

## Reproduction

Run from the repository root in PowerShell. The repository-local .NET 10 SDK/runtime must already be present; this procedure installs nothing. Choose two new, empty, ignored output directories for replay.

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M305Generator/M305Generator.csproj' --configuration Release --output '.local/revalidation/m305-build' --ignore-failed-sources
if ($LASTEXITCODE -ne 0) { throw 'M305 build failed' }

$args = @(
  'Architecture/M304_Joint_L01_L02_Route_Study_2026-11-02/artifacts/m304-joint-room-route-study.json',
  'Architecture/M302_Hypothetical_Lower_Shell_Stair_Sensitivity_2026-11-02/artifacts/m302-l-turn-stair-envelope-study.json',
  'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json',
  'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json',
  'Decisions/2026-11-02_M305_Lower_End_Landing_Route_Study.md'
)
& '.local/dotnet/dotnet.exe' '.local/revalidation/m305-build/M305Generator.dll' @args '.local/revalidation/m305-run-a'
if ($LASTEXITCODE -ne 0) { throw 'M305 replay A failed' }
& '.local/dotnet/dotnet.exe' '.local/revalidation/m305-build/M305Generator.dll' @args '.local/revalidation/m305-run-b'
if ($LASTEXITCODE -ne 0) { throw 'M305 replay B failed' }

Get-FileHash '.local/revalidation/m305-run-a/*' -Algorithm SHA256
Get-FileHash '.local/revalidation/m305-run-b/*' -Algorithm SHA256
[xml](Get-Content '.local/revalidation/m305-run-a/m305-landing-routes.svg' -Raw) | Out-Null
```

Final verified run hashes:

| Artifact | SHA256 |
| --- | --- |
| `m305-checks.json` | `0ED974C79410711D0236CF33140AF1950E17109058FC8197C5C8175E0573E628` |
| `m305-lower-landing-route-study.json` | `795FA1E4991785B409A92CD4A697AC719610B577166602D9E8D7FD3306BECCF8` |
| `m305-landing-routes.svg` | `E2A0D14A8F6E7D281BFB01076CF617A2AE8951C5A1609CD7C5C982AED1B86545` |

The checked-in `artifacts/` directory contains the canonical replay output. These checks do not certify code compliance, accessibility, structural safety, professional review, permit approval or construction readiness.
