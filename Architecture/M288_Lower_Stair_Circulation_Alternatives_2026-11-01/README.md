# M288 — Lower-stair circulation alternatives

Date: 2026-11-01

Status: **Analysis complete; no circulation block, stair, or route selected.**

## Owner scope

The owner authorized two analysis-only paths: test orthogonal dogleg routes with all source room blocks fixed, then allow same-area C-LOWER move/reshape candidates while holding L-01 and every other source room block fixed. Both unassigned M-06 search windows remain protected. The owner-selected L-01 area remains **250.5556 sq ft**. Full authorization: `Decisions/2026-11-01_M288_Lower_Stair_Circulation_Alternatives_Authorization.md`.

M285's six-riser stair envelope is unchanged. Route width is 36 in from the M215 project route-screen precedent; it is not a code or accessibility determination. Routes are orthogonal centerline searches on a 3-in grid with a 36-in swept envelope, from either lower-landing end.

## Result

The C#/.NET 10 build succeeds with **0 warnings and 0 errors**. Two independent runs pass **12/12 checks** each; all three artifacts match byte-for-byte, and the SVG parses as XML.

With all rooms fixed, the screen retains 322 stair envelopes and tests 644 lower-landing ends. It finds one direct landing-interface option: the unchanged stair envelope at `(15.9167, 9.6667)` ft with a west lower landing overlaps C-LOWER by **2.597 sq ft**. Its conservative combined stair-plus-36-in endpoint envelope occupies **6.722 sq ft** of C-LOWER, leaving **72.167 sq ft** outside that screening footprint. **No independent dogleg route** reaches C-LOWER while clearing the fixed room blocks and both M-06 windows.

The same-area C-LOWER search produces **67 distinct rectangles**, each preserving the source **78.889 sq ft** area and clearing the fixed rooms, L-01 and M-06 windows. Every candidate has at least one landing-interface option, but **zero** has a separate dogleg route. The least-occupied interface candidate reshapes/moves C-LOWER by a combined **2.648 ft**; the stair-plus-endpoint envelope occupies **4.051 sq ft** and leaves **74.838 sq ft** outside that envelope. A simple 3-in west translation reduces the measured occupation to **6.014 sq ft** and leaves **72.875 sq ft**, but it still provides only a landing interface. These are unsorted layout alternatives, not room or stair selections; the residual rectangle has not been evaluated for actual circulation use.

The requested comparison therefore does not yet establish a continuous circulation route. It demonstrates that both fixed-block routing and same-area C-LOWER adjustments can create a schematic landing interface only by allocating part of C-LOWER to the stair. Door openings, the external arrival, wall/landing details, actual stair construction, clearances, and route continuity beyond C-LOWER remain unresolved.

## Reproduction

Run from the repository root in PowerShell. Build and output folders must be new or empty:

```powershell
.local\dotnet\dotnet.exe build Tools/M288Generator/M288Generator.csproj --configuration Release --output .local/revalidation/m288-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m288-build/M288Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M288_Lower_Stair_Circulation_Alternatives_Authorization.md .local/revalidation/m288-run1
.local\dotnet\dotnet.exe .local/revalidation/m288-build/M288Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M288_Lower_Stair_Circulation_Alternatives_Authorization.md .local/revalidation/m288-run2
```

Compare all three artifact hashes between runs; parse `m288-plan.svg` as XML. The retained outputs are in `artifacts/`.

## Pinned inputs and outputs

| File | SHA256 |
|---|---|
| Selected-D study | `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` |
| M285 section report | `66FBF95A7D7AB07A71F0F2F1FAEBCACA67493344290A21DE0CE6E3F9E0C09F6C` |
| M215 route precedent | `F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1` |
| M288 authorization | `35413BD2F2522BC864D96AEDCB3B5A8EC3B9FF0EB0CD62EFD9FC75956FDF9DDD` |
| `m288-checks.json` | `D011B975C4DC6C2598A15070FAD72D51A3677DDFFA394E8043B89E9FF576D5B2` |
| `m288-plan.svg` | `F2A2945CF0153FE73CF6EF86B9CBF0DDDD3EB35F0B74E673AF1520878B276974` |
| `m288-stair-circulation-alternatives.json` | `F85BD08A47D07EF6E505663CB737FEF4BD22AD79853C4D5C27141F2F72BE7800` |

## Limits and next decision

This tests schematic rectangles and an abstract plan envelope only. The result does not establish that the remaining C-LOWER area works as circulation, nor does it model door swings/openings, route beyond C-LOWER, actual finished walls, floor openings, headroom, structure, MEP, furniture or use. No Revit or IFC was generated. M-06/A/B remain unassigned. No code compliance, accessibility, professional approval, structural safety or construction readiness is established.

To pursue a separate path, a later owner-authorized study must relax another constraint (for example, permit L-01 to move/reshape together with C-LOWER, or allow a different room block to move). M288 does not select or authorize such changes.
