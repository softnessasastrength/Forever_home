# M307 — Integrated stair, two-landing and lower-route search

**Status:** completed, bounded negative result; no layout selected.

## Scope

M306 found no paired two-end option among nine retained M304 layouts. M307 revisits the first 24 retained M302 stair/L-01 envelope samples, checking both possible lower-flight ends with an upper landing, lower landing, and route to fixed C-LOWER before trying same-area room placements. It retains the 38.333333 × 40 ft hypothetical shell, 8-in shell margin, 4 × 4 ft inherited landing references, 36-in M215 route-screen precedent, both protected M-06 windows, and source areas for L-01 and L-02.

## Search procedure

The .NET 10 generator pins M302/M215/M295 and this authorization record. It screens both directions per stair sample for a pair of landings that fit the shell and clear fixed rooms, windows and the stair envelope. For each landing pair it searches a quarter-foot 36-in swept path from the lower landing exterior to C-LOWER, with a 2,500-node cap. For each route that survives, it checks the full generated same-area L-01 set against the landings, stair and route, then screens up to 600 movement-spread L-01 candidates with up to 2,000 L-02 candidates.

The search preserves all fixed room blocks. It is more integrated than the M304→M306 sequential sample, but remains bounded to M302's first 24 retained stair envelopes and the stated room-sampling caps.

## Result

- Build: **0 warnings, 0 errors**.
- Two independent runs: **6/6 checks** each; report/check/SVG byte-identical; SVG XML parses.
- M302 generated 3,825 same-area L-01 candidates and 104,659 L-02 candidates for these constraints.
- Across 24 stair samples and both lower-flight choices, 96 end-landing placements were checked. Four paired landing arrangements clear the shell and fixed blocks. One yields a 29.5-ft lower route to C-LOWER with 729 nodes and no cap hit.
- That sole route corridor has **zero** clear positions among all 3,825 generated L-01 candidates after checking the stair, both landings and full route. Consequently no L-02 pairing is attempted and **no joint room/stair option passes**. Within this sample, the obstruction is not solved by merely moving L-02 or sampling more L-01 layouts.

This is bounded, not proof of impossibility: the first 24 M302 retained stair envelopes are not all 3,850,039 M302 block fits, and the room search keeps other spaces fixed. Upper-floor route/approach, exact stair/run/riser allocation, headroom/opening, wall finishes, doors, rails/guards, structure, MEP, site and local requirements are not modeled. The 38⅓ × 40 ft shell remains hypothetical and unselected, +33.1% area. No selected-D, Revit, IFC, family or remote state changed.

## Reproduction

Run from the repository root in PowerShell with the repository-local .NET 10 SDK already present. Each output directory must be new and empty.

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M307Generator/M307Generator.csproj' --configuration Release --output '.local/revalidation/m307-build' --ignore-failed-sources
if ($LASTEXITCODE -ne 0) { throw 'M307 build failed' }

$inputs = @(
  'Architecture/M302_Hypothetical_Lower_Shell_Stair_Sensitivity_2026-11-02/artifacts/m302-l-turn-stair-envelope-study.json',
  'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json',
  'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json',
  'Decisions/2026-11-02_M307_Integrated_Stair_Landing_Search.md'
)
& '.local/dotnet/dotnet.exe' '.local/revalidation/m307-build/M307Generator.dll' @inputs '.local/revalidation/m307-run-a'
if ($LASTEXITCODE -ne 0) { throw 'M307 replay A failed' }
& '.local/dotnet/dotnet.exe' '.local/revalidation/m307-build/M307Generator.dll' @inputs '.local/revalidation/m307-run-b'
if ($LASTEXITCODE -ne 0) { throw 'M307 replay B failed' }
Get-FileHash '.local/revalidation/m307-run-a/*' -Algorithm SHA256
Get-FileHash '.local/revalidation/m307-run-b/*' -Algorithm SHA256
[xml](Get-Content '.local/revalidation/m307-run-a/m307-integrated-options.svg' -Raw) | Out-Null
```

Verified hashes:

| Artifact | SHA256 |
| --- | --- |
| `m307-checks.json` | `2E8A8A590A41D898A933DD1E2814AC9B04067C6F8A6B79D6F4EE469277F587D2` |
| `m307-integrated-stair-landing-study.json` | `B2C945E909CCD48396D042B6391F02B8D8F6076E452AAD17AC734481F2652527` |
| `m307-integrated-options.svg` | `F9ACDB82C5C26E981369C7F6B2CA92282423543710B92AAB90719889D41E3510` |
