# M287 — Lower stair landing to arrival/circulation

Date: 2026-11-01

Status: **Analysis only; no stair, room, route, or design selected.**

## Scope

The owner directed the lower stair screen to connect to source C-LOWER while preserving the exact L-01 source area (250.5556 sf), all other room rectangles, both unassigned M-06 windows, and the source shell. M285's six-riser/two-landing envelope is used as a plan proxy. The route screen uses 36 in from M215 as an existing project precedent only; it is not a code or accessibility finding. The authorization is pinned in `Decisions/2026-11-01_M287_Lower_Stair_Circulation_Study_Authorization.md`.

## Result

The package-free C#/.NET 10 build completes with **0 warnings and 0 errors**. Two fresh runs pass **10/10 checks**; JSON, checks, and SVG are byte-identical, and the SVG parses as XML.

The quarter-foot search considers 74 same-area L-01 rectangles and 1,393 stair envelopes (103,082 room/stair pairs). It found 33,754 compatible pairs where one candidate lower landing directly intersects C-LOWER. The **landing interface consumes part of the reserved circulation rectangle**. The best-ranked unchanged-L-01 example is east-west at `(15.9167, 9.6667)` ft; its 3-ft-deep west landing overlaps C-LOWER by **2.597 sf**, and the whole envelope overlaps by the same amount. Its nearest separation from L-01 is only **⅙ in** in the block model. This is a geometric adjacency example, not an available landing, door, or usable route.

The independent explicit-path count is **zero**: no 36-in straight swept rectangle connects a non-overlapping lower landing to C-LOWER while clearing L-01, the other rooms, and both M-06 windows in this bounded model. Thus the screen has not found a route with the circulation block and other rooms fixed. The apparent landing-interface options achieve adjacency by occupying the C-LOWER reserve; their remaining circulation has not been checked. The result demonstrates a constrained-plan conflict, not that an actual stair is impossible.

## Reproduction

Run from the repository root in PowerShell. Build and output folders must be new or empty:

```powershell
.local\dotnet\dotnet.exe build Tools/M287Generator/M287Generator.csproj --configuration Release --output .local/revalidation/m287-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m287-build/M287Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M287_Lower_Stair_Circulation_Study_Authorization.md .local/revalidation/m287-run1
.local\dotnet\dotnet.exe .local/revalidation/m287-build/M287Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M287_Lower_Stair_Circulation_Study_Authorization.md .local/revalidation/m287-run2
```

Compare all three output hashes between runs and parse `m287-plan.svg` as XML. The retained outputs are in `artifacts/`.

## Pinned inputs and outputs

| File | SHA256 |
|---|---|
| Selected-D study | `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` |
| M285 section report | `66FBF95A7D7AB07A71F0F2F1FAEBCACA67493344290A21DE0CE6E3F9E0C09F6C` |
| M215 route precedent | `F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1` |
| M287 authorization | `785285433F789EFD58DF9DFE96C97650D78409C752607D7426EFECCF5192DF05` |
| `m287-checks.json` | `19FE3CEC0F10BC593FA3F5589A8EC9F661D7308A61FA415DCDB371AC98CB6AA1` |
| `m287-lower-stair-arrival-screen.json` | `4F7C592FE2E927BB6BA699FC5DA328F60BE836B281F9335F55B554EC4470BEA3` |
| `m287-plan.svg` | `8C1923B1CAC7CF3B76BAA0CECD4A3C5972087D6EB61D4074893525F30251F83D` |

## Limits and next gate

The search uses axis-aligned rectangles, an abstract stair envelope, straight axial route segments, and no wall thickness, doors, floor opening, transitions, headroom, furnishings, or services. The M06 search windows remain protected and unassigned. No Revit model or IFC was generated. This does not establish code compliance, accessibility, professional approval, structural safety, or construction readiness.

To continue toward an actual stair connection, an owner-authorized comparison must relax one or more fixed constraints (for example, move/reshape C-LOWER, test a dogleg route through the arrival block, or move another room). The present result does not authorize those changes. A useful decision is whether to study circulation-block alternatives next while keeping all other room areas and M-06 windows protected.
