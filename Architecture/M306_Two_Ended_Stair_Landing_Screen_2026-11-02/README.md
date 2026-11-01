# M306 — Two-ended landing footprint screen

**Status:** completed, bounded analysis; no house layout or stair selected.

## Question

M305 found six lower landing/route proxies among nine retained M304 room/stair layouts. M306 asks whether those options also fit the inherited 4 × 4 ft landing proxy at the opposite flight end. It checks both ends together across all nine retained layouts.

## Method and constraints

The source-pinned .NET 10 generator reads M302/M304/M295/M305 results plus this scope record. The hypothetical 38.333333 × 40 ft shell, 8-in perimeter margin, two M-06 search windows, fixed rooms, C-LOWER and each M304 L-01/L-02 area are preserved. Each upper landing is placed against the exposed end of flight-B, using M295's 4-ft width/depth references and the same margin used in M305. The upper rectangle is checked against the shell, rooms, windows, the other stair pieces and any passing lower landing.

The lower landing and route result is inherited from M305. M306 tests only the opposite landing footprint; it does not search an upper-floor path.

## Result

- Build: **0 warnings, 0 errors**.
- Two independent runs: **6/6 checks each**; JSON/check/SVG outputs are byte-identical and both SVG parses succeed.
- Across 9 layouts: 6 retain the M305 lower landing and C-LOWER route; 2 have a clear opposite-end landing footprint; **0** combine both outcomes.
- The six lower-route options fail the opposite landing shell-bound screen. Two other layouts fit an upper landing, but do not retain a lower landing/route. The schematic successes therefore do not form a complete two-ended option within these nine samples.

This is a bounded negative result, not proof of impossibility. The stair remains an unverified L-turn footprint proxy with 3+4 aggregate tread-run split, not a stair schedule. Upper-floor access, upper approach, actual risers/run, headroom, opening, rails/guards, doors, finished assembly thickness, structure, MEP, site, and all applicable code/accessibility checks are unresolved. The larger shell is still hypothetical and unselected at +33.1% area. No selected-D geometry, RVT, IFC, family or remote state changed.

## Reproduction

Run from the repository root in PowerShell with the already-present repository-local .NET 10 SDK. Each output directory must be new and empty.

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M306Generator/M306Generator.csproj' --configuration Release --output '.local/revalidation/m306-build' --ignore-failed-sources
if ($LASTEXITCODE -ne 0) { throw 'M306 build failed' }

$inputs = @(
  'Architecture/M304_Joint_L01_L02_Route_Study_2026-11-02/artifacts/m304-joint-room-route-study.json',
  'Architecture/M302_Hypothetical_Lower_Shell_Stair_Sensitivity_2026-11-02/artifacts/m302-l-turn-stair-envelope-study.json',
  'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json',
  'Architecture/M305_Lower_End_Landing_Route_Study_2026-11-02/artifacts/m305-lower-landing-route-study.json',
  'Decisions/2026-11-02_M306_Two_Ended_Stair_Landing_Screen.md'
)
& '.local/dotnet/dotnet.exe' '.local/revalidation/m306-build/M306Generator.dll' @inputs '.local/revalidation/m306-run-a'
if ($LASTEXITCODE -ne 0) { throw 'M306 replay A failed' }
& '.local/dotnet/dotnet.exe' '.local/revalidation/m306-build/M306Generator.dll' @inputs '.local/revalidation/m306-run-b'
if ($LASTEXITCODE -ne 0) { throw 'M306 replay B failed' }
Get-FileHash '.local/revalidation/m306-run-a/*' -Algorithm SHA256
Get-FileHash '.local/revalidation/m306-run-b/*' -Algorithm SHA256
[xml](Get-Content '.local/revalidation/m306-run-a/m306-two-ended-landings.svg' -Raw) | Out-Null
```

Verified artifact hashes:

| Artifact | SHA256 |
| --- | --- |
| `m306-checks.json` | `C3B7DE7B43791A55E6A29473775F5142D3D59139EC53265EC068764D9469A046` |
| `m306-two-ended-landing-study.json` | `A9C28AE7EE9A67A87F0B1F05D4EFE6A4375B7D66E9363017DEE1319927AF31BF` |
| `m306-two-ended-landings.svg` | `6694E09C215BBD3DCE2838679268AE3EEF6A7B5B08F3D2A9611FA69A033AB715` |
