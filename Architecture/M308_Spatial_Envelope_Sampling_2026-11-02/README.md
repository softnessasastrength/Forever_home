# M308 — Spatially spread stair-envelope sample

**Status:** completed; analysis-only sample generator, no option selected.

## Purpose

M302 evaluated 303,801,450 block placements and found 3,850,039 clear L-turn/L-01 envelopes, but retained only 24 low-movement examples. M308 reruns the same source-bound geometry search and keeps one lowest-L-01-movement fit per 2-ft stair-origin cell and rotation, capped at 500. The 2-ft cell is a sampling bin only; it is not a proposed house dimension.

The source geometry, hypothetical 38.333333 × 40 ft shell, 60-in transition proxy, 8 aggregate risers, 7 aggregate tread runs, 3+4 run split, 4 × 4 ft internal turn-platform proxy, 8-in margin, fixed rooms except same-area L-01, and protected M-06 windows follow M302. Selected-D remains unchanged.

## Result

- .NET 10 build: **0 warnings, 0 errors**.
- Full search: **5,025** same-area L-01 candidates; **303,801,450** stair/L-01 placements; **3,850,039** spatial fits.
- Spatial grouping retained **118** candidates, one per occupied 2-ft origin cell and orientation (cap 500).
- Internal checks: **7/7**; two independent runs reproduce report/check/SVG byte-for-byte and SVG parses as XML.

This expands M302's spatial coverage from its first 24 low-movement options but still samples only 118 of 3.85 million envelope fits. It provides no landing, route, door, upper-floor access, section/headroom, code, accessibility, structure, professional, permit or construction-readiness finding. No Revit, IFC, family or remote state changed.

## Reproduction

Run from the repository root in PowerShell with the already-present local .NET 10 SDK. Use two new empty output directories:

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M308Generator/M308Generator.csproj' --configuration Release --output '.local/revalidation/m308-build' --ignore-failed-sources
if ($LASTEXITCODE -ne 0) { throw 'M308 build failed' }
$inputs = @(
  'Architecture/Selected_Design_Iteration_2026-10-27/study.json',
  'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json',
  'Decisions/2026-11-02_M308_Spatial_Envelope_Sampling.md'
)
& '.local/dotnet/dotnet.exe' '.local/revalidation/m308-build/M308Generator.dll' @inputs '.local/revalidation/m308-run-a'
if ($LASTEXITCODE -ne 0) { throw 'M308 replay A failed' }
& '.local/dotnet/dotnet.exe' '.local/revalidation/m308-build/M308Generator.dll' @inputs '.local/revalidation/m308-run-b'
if ($LASTEXITCODE -ne 0) { throw 'M308 replay B failed' }
Get-FileHash '.local/revalidation/m308-run-a/*' -Algorithm SHA256
Get-FileHash '.local/revalidation/m308-run-b/*' -Algorithm SHA256
[xml](Get-Content '.local/revalidation/m308-run-a/m308-options.svg' -Raw) | Out-Null
```

The retained canonical outputs are in `artifacts/`. M309 uses the spatially spread M308 report as its stair sample input.

Verified artifact hashes:

| Artifact | SHA256 |
| --- | --- |
| `m308-spatial-stair-envelope-study.json` | `1D02B1319AE7980EC7DCB4847B513F883836D26D717D3DA1A6B132F19EDB1590` |
| `m308-checks.json` | `D6B57DB0993F13941CBCF0C3FA4A53ED138AD08ED3D7C1DC364BF2A010798C3B` |
| `m308-options.svg` | `5112C992F048E5DF912140D18076D808A1DC70E632CE4FB08BBBD0A9BF2136D4` |
