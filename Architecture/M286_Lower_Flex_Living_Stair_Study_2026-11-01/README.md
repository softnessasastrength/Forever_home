# M286 — Lower flex-living / stair-envelope study

Date: 2026-11-01

Status: **Analysis only; no L-01 reshaping or stair location selected.**

## Scope and owner inputs

The owner authorized a move/reshape comparison for lower flexible living room L-01 and elected to preserve its current area, **250.5556 sq ft**. The study uses only same-area rectangles generated from that source area, keeps the other lower rooms and circulation block fixed, and carries forward M285's six-riser 43½-in vertical comparison and 38-in / five 10½-in tread / two 36-in landing plan envelope. No source design or Revit file is edited.

L-01 candidate widths are sampled every 3 in across the geometrically feasible shell range; depth is calculated from the preserved source area. Candidate origins use a ¼-ft grid with the M285 ⅔-ft shell margin. Stair-envelope positions use the same grid. Both unassigned main-level M-06 search windows are held clear of stair envelopes, as potential vertical opening reservations. Their plan projection through the lower level is reported for L-01 but is not prohibited; that is a different storey and is not a coordinated section.

## Reproduction

From the repository root in PowerShell; build and output folders must be new or empty:

```powershell
.local\dotnet\dotnet.exe build Tools/M286Generator/M286Generator.csproj --configuration Release --output .local/revalidation/m286-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m286-build/M286Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Decisions/2026-11-01_DD013_Vertical_Section_Study_Basis.md Decisions/2026-11-01_M286_Lower_Flex_Living_Stair_Study_Authorization.md .local/revalidation/m286-run1
.local\dotnet\dotnet.exe .local/revalidation/m286-build/M286Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Decisions/2026-11-01_DD013_Vertical_Section_Study_Basis.md Decisions/2026-11-01_M286_Lower_Flex_Living_Stair_Study_Authorization.md .local/revalidation/m286-run2
```

Replay verification compares all three output hashes between the two directories and parses `m286-plan.svg` as XML. The retained report and checks are in `artifacts/`.

## Results

- The package-free C#/.NET 10.0.403 build completes with **0 warnings and 0 errors**. Two fresh runs pass **13/13 checks each**; JSON, checks, and SVG are byte-identical; the SVG parses as XML.
- The search found **74** same-area L-01 rectangles clear of the six fixed lower rooms and circulation block, **1,393** stair envelopes clear of fixed rooms and both projected M-06 windows, and **24,996** room/stair pairs without positive-area overlap.
- Crucially, **644 pairs already work geometrically with the current L-01 position and shape**. Moving or reshaping L-01 is therefore not needed merely to make the two rectangles disjoint in this screen. Of those 644, 80 stair envelopes avoid positive-area overlap with the circulation block; their maximum measured L-01-to-stair rectangle gap is **13 in**, while the example is **97 in** from the circulation rectangle. This is not a continuous route.
- A source-L-01 option with the smallest positive stair/circulation overlap uses **2.597 sq ft** of the circulation rectangle and leaves only **2 in** between the stair envelope and L-01. It does not establish a workable wall, door, landing, or connection.
- A reshaped same-area L-01 example increases the measured room/stair rectangle gap to **36.144 in** after a combined shape/origin change of **3.4406 ft**; its stair envelope overlaps **27.667 sq ft** of the circulation rectangle. That area could require circulation redesign and is not accepted as a route.
- The six-inch / twelve-inch room-stair gap sensitivities count **17,152 / 9,332** pairs. These are descriptive search results, not clearance requirements. **821** stair samples overlap the circulation rectangle; none merely touches it without positive-area overlap.

The comparison supports the conclusion that L-01 movement alone does not solve stair access. It shows room/stair separation options, but the stair-to-arrival relationship still needs an explicit route/landing study. The owner has now directed that the next analysis prioritize a connection to lower arrival/circulation; see the next milestone in `PLAN.md`.

## Pinned inputs and outputs

| File | SHA256 |
|---|---|
| Selected-D study | `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` |
| M285 report | `66FBF95A7D7AB07A71F0F2F1FAEBCACA67493344290A21DE0CE6E3F9E0C09F6C` |
| DD-013 section basis | `B2073D1B2C7E2B1AEF389B69C9E4121E161452F66A1654358BA2012EDCECF59B` |
| Owner M286 authorization | `A834C5BFD3248E488B94A6D35CE7AEFDCE32BCA00DE075AC2501E582EE17C5EC` |
| `m286-checks.json` | `1A3B30C340936499E40642D7E287423DE10C57DA51587390571ACDC6E3793770` |
| `m286-lower-flex-stair-screen.json` | `BBD5CDC91E9C918D2E93C8AB7F8D9850889B89B234AC5A05EA49E1D6050C2894` |
| `m286-plan.svg` | `8C6669EB174BC33F489D4E0716C285BA61AAD2C0269DA8AC0CFDA1929EDB0703` |

## Limitations

Stair envelopes are plan rectangles, not modeled stair runs or floor openings. Circulation overlap is reported rather than treated as a collision or accepted route. The search omits finished wall thickness, actual door openings/swings, continuous access, approach, furniture, headroom, floor construction, structure, landings at the actual levels, and plumbing/mechanical coordination. No Revit object or IFC was generated. The result does not establish code compliance, accessibility, professional approval, structural safety, or construction readiness.
