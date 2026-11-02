# M309 — Wider-sample integrated stair landing and route screen

**Status:** completed, bounded negative result; replaced as the active shell direction by the owner's Selected-D envelope instruction.

## Scope and method

M309 consumes M308's spatially spread 118 representatives from the 3,850,039 M302 block fits. It screens both lower-flight choices for two inherited 4 × 4 ft landing proxies, fixed blocks, protected M-06 windows, and a 36-in route to fixed C-LOWER. Only then does it screen same-area L-01/L-02 movement. The test shell is 38.333333 × 40 ft, still a hypothetical comparison at this stage; it is **not** the owner's current envelope after the later Selected-D direction below.

The generator pins M308/M215/M295 and this authorization. M06 windows, other rooms, and C-LOWER remain fixed. The L01/L02 candidate movement metrics are search sort proxies, not architectural cost functions.

## Result

- .NET 10 build: **0 warnings, 0 errors**.
- Two independent current-code runs: **6/6 checks each**; report/check/SVG byte-identical; SVG parses.
- 118 spatial samples; 472 landing-end placements; 52 paired landing layouts clear fixed blocks; 29 support the lower route. Three route searches hit the 2,500-node cap.
- 1,546,000 room-pair combinations were tested. Two corridor cases had L-01 placements clear of the stair, both landings and route (507 and 266 respectively), but no tested L-02 pairing produced a joint layout. **No full option passed.**

This is bounded to 118 spatial-cell representatives and movement-spread room samples. It does not prove impossibility. More importantly, the owner has since directed that Selected-D is acceptable as the dimensional basis; the expanded shell is no longer the active design path. No selected-D, Revit, IFC, family or remote state changed.

## Reproduction

Run in PowerShell from the repository root with the existing local .NET 10 SDK and new empty output directories:

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M309Generator/M309Generator.csproj' --configuration Release --output '.local/revalidation/m309-build' --ignore-failed-sources
if ($LASTEXITCODE -ne 0) { throw 'M309 build failed' }
$inputs = @(
  'Architecture/M308_Spatial_Envelope_Sampling_2026-11-02/artifacts/m308-spatial-stair-envelope-study.json',
  'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json',
  'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json',
  'Decisions/2026-11-02_M309_Wide_Sample_Integrated_Stair_Search.md'
)
& '.local/dotnet/dotnet.exe' '.local/revalidation/m309-build/M309Generator.dll' @inputs '.local/revalidation/m309-run-a'
if ($LASTEXITCODE -ne 0) { throw 'M309 replay A failed' }
& '.local/dotnet/dotnet.exe' '.local/revalidation/m309-build/M309Generator.dll' @inputs '.local/revalidation/m309-run-b'
if ($LASTEXITCODE -ne 0) { throw 'M309 replay B failed' }
Get-FileHash '.local/revalidation/m309-run-a/*' -Algorithm SHA256
Get-FileHash '.local/revalidation/m309-run-b/*' -Algorithm SHA256
[xml](Get-Content '.local/revalidation/m309-run-a/m309-integrated-options.svg' -Raw) | Out-Null
```

Verified output hashes:

| Artifact | SHA256 |
| --- | --- |
| `m309-checks.json` | `7F8CDB8505EAC6F61C6E38C23D5CC5F1AD3E4B55F8CDAF944C594108C928B4E1` |
| `m309-wide-integrated-stair-study.json` | `AE8EE7AC7398E416A49FB5CEAA82F5E2BF8814879045D13D78F7B051F40B08D4` |
| `m309-integrated-options.svg` | `F9ACDB82C5C26E981369C7F6B2CA92282423543710B92AAB90719889D41E3510` |

No code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.
