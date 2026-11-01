# M295 — Full 60-in stair fit against same-area lower layout study

Date: 2026-11-01

Status: **bounded analysis complete; no physical room, stair, route, floor level, or Revit geometry selected.**

## Owner direction and inputs

The owner asked for a full 60-in stair comparison. The analysis uses the existing selected-D `stair_core_test` comparison as written: **8 × 7.5-in risers**, **7 × 11-in treads**, **4-ft flight/landing width**, and **4-ft landing depth**. Its rectangular plan envelope is **4 × 14.4167 ft** (7 × 11 in plus two 4-ft landing-depth references). The equal riser is numerically below the cited CT maximum of 8¼ in; this arithmetic does not establish a complete or compliant stair.

The comparison holds the 36 × 32 ft shell and all lower rooms other than L-01/C-LOWER fixed. L-01 and C-LOWER candidates preserve each selected-D source area exactly; both unassigned M-06 windows remain protected for stair/path proxies. It incorporates the owner's M294 preference as an input reference, but does not force the six-riser reference's different physical/plan envelope into this full 60-in case. Route screening uses M215's 36-in project precedent only.

## Result

Package-free .NET 10 build: **0 warnings, 0 errors**. Two independent runs each pass **19/19 checks**, reproduce all three output files byte-for-byte and parse the SVG as XML. The source-bound search tests:

- 1,208 same-area L-01 and 2,912 same-area C-LOWER rectangles;
- 6,707 non-overlapping L-01/C-LOWER pairs;
- 1,640 full-size stair envelopes after fixed-room, shell-margin and protected-window screens;
- 5,065 lower-landing interfaces;
- **zero** independent 36-in straight or orthogonal dogleg swept routes to C-LOWER.

The minimum block-change result keeps both L-01 and C-LOWER at source geometry (zero change). Its 4 × 14.4167-ft stair envelope intersects **15.3333 sq ft** of the 78.8889-sq-ft C-LOWER block; the computed area outside the stair/route proxy union is 55.5417 sq ft. This is a landing interface that consumes the reserved circulation rectangle, not a separate route. A ranking score of zero does not establish that this is a workable layout.

The full-rise plan envelope is **48.5 in longer** than M285's 38-in / five 10.5-in-tread / two 36-in-depth envelope. That comparison combines different documented stair directions and is dimensional arithmetic only. The owner's 5–7-riser half-story preference, wall/finish build-ups, actual clear width, landing width, doors, headroom, railings, guards, floor opening, structure and route beyond C-LOWER remain unresolved.

## Reproduction

From the repository root in PowerShell, use new or empty output folders:

```powershell
.local\dotnet\dotnet.exe build Tools/M295Generator/M295Generator.csproj --configuration Release --output .local/revalidation/m295-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m295-build/M295Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M295_Full_Rise_Stair_Comparison_Authorization.md .local/revalidation/m295-replay1
.local\dotnet\dotnet.exe .local/revalidation/m295-build/M295Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M295_Full_Rise_Stair_Comparison_Authorization.md .local/revalidation/m295-replay2
```

Compare each same-named output by SHA256 and parse `m295-plan.svg` as XML. The generator verifies selected-D, M285, M215, M289, M294 and M295 authorization hashes; it refuses any non-empty output folder.

## Pinned results

| File | SHA256 |
|---|---|
| `m295-checks.json` | `A11582B4EFF1212F5EB9F31BAE333D84D21D753B47CC43D28C85EED6F1EDCBF6` |
| `m295-full-rise-stair-study.json` | `65A84006158D4352D282D3FA32EDBA3E93F327D31584F19B6C1C9C5BD081CE04` |
| `m295-plan.svg` | `276F42FD84D8FC0FC717E4862B5EC4E952342F08058CC321874F0DD08AE21EDA` |

## Limits and next design gate

This only establishes that the bounded screen found landing interfaces but no independent 36-in path under its fixed-room constraints. It does not prove that an actual stair or route is impossible. A landing could potentially be coordinated with circulation, or another room/layout/section constraint could move, but neither option is selected. Ask the owner before relaxing additional room constraints or treating the C-LOWER block as landing/route space.

No Revit/IFC was produced. M-06/A/B remain unassigned; west A stays protected. No code compliance, accessibility, structural safety, professional approval, permit approval or construction readiness is established.
