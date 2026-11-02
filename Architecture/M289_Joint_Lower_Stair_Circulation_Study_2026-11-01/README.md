# M289 — Joint lower flex-room, circulation and stair connection study

Date: 2026-11-01

Status: **Analysis complete; no room, stair, or route selected.**

## Owner-authorized scope

The owner authorized a joint same-area move/reshape study for `L-01` and `C-LOWER` after M288 found no independent dogleg with L-01 fixed. Preserve their selected-D source areas exactly: L-01 **250.5556 sq ft**, C-LOWER **78.8889 sq ft**. Hold every other lower room and the **36 × 32 ft** source shell fixed. The authorization is `Decisions/2026-11-01_M289_Joint_Lower_Stair_Circulation_Authorization.md`.

The search varies block width in 3-in increments, calculates the depth from exact source area, and tests positions on the 3-in grid inside M285's ⅔-ft shell margin. It tests the unchanged source rectangles as well. M285's 38-in / five 10½-in tread / two 36-in landing envelope is unchanged. The 36-in route width is M215's project screening precedent only, not an adopted code or accessibility criterion.

Both main-level M-06 search windows remain clear of C-LOWER, stair and route proxies. L-01 is on the lower level; its horizontal plan-projection overlap with an M-06 window is counted separately and is not treated as a same-level collision. Neither projected window, M-06 room, stair opening, nor service route is selected.

Of the 1,208 L-01 candidates, **268** overlap at least one M-06 window in horizontal plan projection. That is a cross-level overlay count only; the windows remain protected for the stair/route reservation and C-LOWER candidate checks.

## Result

The package-free C#/.NET 10 build succeeds with **0 warnings and 0 errors**. Two independent runs each pass **15/15 checks** and reproduce the report, checks and SVG byte-for-byte. The SVG parses as XML.

The scan generated **1,208** same-area L-01 rectangles and **2,912** same-area C-LOWER rectangles. It tests **6,707** mutually non-overlapping, fixed-room-clear layout pairs and **52,432** M285 stair envelopes across those L-01 alternatives. Of the route results, it records **6,461** lower-landing interfaces, **2** landing-end contacts with no path segment, **2** straight path proxies, and **320** orthogonal dogleg path proxies to a C-LOWER candidate. Nineteen L-01 candidates admit at least one dogleg in this screen. These are alternative geometries, not 320 separately reviewed designs.

The lowest combined absolute block-change score is **1.1193 ft**. It preserves C-LOWER at the source location and reshapes/translates L-01 to `13.5 × 18.5597 ft` at `(9.6667, 12.7737) ft`. Its east-west stair envelope is `10.375 × 3.1667 ft` at `(24.9167, 12.1667) ft`, with the west landing feeding a **9.25-ft** orthogonal path proxy with two turns. The proxy occupies **0.4583 sq ft** of C-LOWER. Its minimum separation from the combined stair/path envelope to L-01 is **0 in**: the rectangles are tangent. The change score is `|Δx| + |Δy| + |Δwidth| + |Δdepth|` for both blocks; it is a ranking metric, not physical travel distance.

A separate option with a positive measured separation places L-01 at `14.5 × 17.2797 ft`, C-LOWER at `6 × 13.1481 ft`, and the M285 stair envelope at `(15.9167, 8.6667) ft`. The route is a **0.25-ft straight connector** from the west landing end to C-LOWER. Its stair/path envelope is **26.644 in** from L-01 and occupies **4.5 sq ft** of C-LOWER, leaving **74.3889 sq ft** outside that screened footprint. The associated combined block-change score is **5.9221 ft**. The measured gap describes rectangular separation only; it is not a required clearance or proof that the remaining C-LOWER area functions as circulation.

These examples expose a trade-off: the minimal-change dogleg is tangent to L-01, while a more substantially reshaped pair has a positive block gap and a near-adjacent straight connector. The current screen does not establish a door, useful landing, entry approach, or route continuing beyond C-LOWER. No room, stair or route is selected.

## Reproduction

Run from the repository root in PowerShell. Each output directory must be new or empty.

```powershell
.local\dotnet\dotnet.exe build Tools/M289Generator/M289Generator.csproj --configuration Release --output .local/revalidation/m289-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m289-build/M289Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M289_Joint_Lower_Stair_Circulation_Authorization.md .local/revalidation/m289-run1
.local\dotnet\dotnet.exe .local/revalidation/m289-build/M289Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M289_Joint_Lower_Stair_Circulation_Authorization.md .local/revalidation/m289-run2
```

Each run reports `M289 15/15`. Compare SHA256 for all three outputs between the directories; parse `m289-plan.svg` as XML. The retained outputs are in `artifacts/`.

## Pinned inputs and outputs

| File | SHA256 |
|---|---|
| Selected-D source study | `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` |
| M285 stair/section report | `66FBF95A7D7AB07A71F0F2F1FAEBCACA67493344290A21DE0CE6E3F9E0C09F6C` |
| M215 route precedent | `F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1` |
| M289 authorization | `54E7AE6FEAF65A24D7B5AF6A43AE21D11AC294F5837D8D50919CF4D615230E0D` |
| `m289-joint-lower-stair-study.json` | `00000094823867028C728501AFA26B88A569376AB920B4AFAF00FC7F4ECCD4D1` |
| `m289-checks.json` | `189F357B7ABB3FFC2FAC0B28DE4C9FFC7BF127FADFEF479F51D0580DAAFA01A5` |
| `m289-plan.svg` | `E86AF1406EACA329FDA36A35154FE0D1066CD12D55830DF950EFBF2A8BC941A6` |

## Limits and next gate

This is a screen of axis-aligned rectangles and orthogonal route centerlines on a finite grid. It omits wall thickness, door openings and swings, finished surfaces, actual stair construction, floor openings, code-defined clearances, headroom, furniture, usable residual circulation, entry and approach, transitions beyond C-LOWER, structure, site/grade, and building services. A positive gap is descriptive geometry only. No Revit or IFC was generated. M-06/A/B remain unassigned; selected-D is unchanged. No code compliance, accessibility, professional approval, structural safety or construction readiness is established.

The next owner review should weigh the tangent minimum-change dogleg against the higher-change positive-gap option. Before any option becomes a design, coordinate an actual landing, door/approach, continuous route, floor opening, applicable Connecticut review, and the affected room's usable layout. A later authorization is required before any geometry is selected or modeled in Revit.
