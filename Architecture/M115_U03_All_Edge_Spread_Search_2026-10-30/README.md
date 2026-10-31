# M115 - Spread U-03 seed positions across all hypothetical shell edges

Status: bounded room-block exploration only. No shell, room arrangement, exterior opening or code solution is selected.

## Scope and preserved direction

M115 expands M114's west-edge test to all four edges of the owner-authorized **38 1/3 x 40 ft exploration-only upper-shell case**. For each of U-03's two source-preserving orientations, the search seeds positions at the 0, 1/2 and 1 fractions of each edge (24 root/orientation runs total). It retains direct sampled public arrival at U-02, U-04 guest access, private U-01 -> C-PRIVATE -> U-02 -> U-03 topology, both Jack-and-Jill links through U-06, the lift keepout, stair-approach proxy and the 4 ft sampled hall grid. No direct U-03 shared-hall topology link is added.

Selected-D remains unchanged at its separate 36 x 32 ft test wing. The exploratory shell is not an approved house dimension.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-03-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U03PerimeterRootSeeds `
  -U03PerimeterSeedEdge all -U03PerimeterSpreadSeeds `
  -NodeLimit 4800 -LayoutLimit 10000 -ExportAllRouteTestedCandidates `
  -OutputDirectory Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m115_u03_all_edge_search.ps1 `
  -PackageDirectory Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30
```

The M37 generator passes **29/29** integrity checks. It expands **2,830/4,800** nodes, considers 877 raw complete layouts, records 331 route-tested placements, and reports an incomplete search. The independent M115 audit passes **21/21**; two separate audit runs produce byte-identical JSON and summary files. A second exact generator run reproduces all five generator artifacts byte-for-byte.

## Result

| U-03 shell-edge contact | Route-tested blocks | All three public-room samples | Of those, no U-03 hall-side sample |
|---|---:|---:|---:|
| North + west corner | 141 | 16 | 9 |
| North + east corner | 181 | 64 | 64 |
| North edge only | 9 | 0 | 0 |
| South contact | 0 | 0 | 0 |
| **Total** | **331** | **80** | **73** |

All 80 full public-route cases reach a sampled north-side U-02 goal. The northeast-corner group provides the strongest privacy-screen sample: 64 layouts reach all three public-room samples and none has a sampled U-03 hall-side reach. This is a result of the bounded search order and proxy model, not evidence that those 64 are superior house designs. The northwest group contains 16 full-route cases, seven with a sampled U-03 side. Nine north-edge-only arrangements do not reach all three public rooms.

The M37-ranked “best” is a machine ranking among this bounded sample and is not owner-selected. U-03's corridor-side sample is not a doorway. Public hall samples are not actual openings, a direct route length or a clearance check. No layout is accepted.

## Evidence identity and limits

- Selected-D study SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`. Proposal and room-program source hashes are stored in `search.json` and the independent audit.
- M37 generator SHA256 `8B634E5AE8BFC1889EF5C13B49E8042B4FC0BEF1326E190732AA881695CC9DA2`; M115 audit script SHA256 `19E2B3EB9A18A1911D5463C80DD5ED2DCF4ED6A3B7F1778FF268765E92A3E7E7`.
- Search SHA256 `D81C5E30D31057AC15C942BF2D6F34070AC564162FDE0C3D908147A6C0BEEA0D`; checks `9CF54BAA5BBB7029EC8AB21B039C84C4BE9DB0865BA08A6D614D09BA3DC244A6`; manifest `3EB88C2E0F70D791C2B7C91D6EF3B0D3B03655E1B4EC1946AAE624482E7965B1`; candidate archive `11360170F462FC28FFD50B71808DE12180331121B0041C2DA637458F1EDA9FB1`; SVG `CE926EF07970EC4A073E2A0A8E8256F7EA7978E563897DC862D39F5C8606D56D`.
- Two audit runs match: audit JSON `986416F2831C5C83DFB8ABE8AAF6DDA65D42120314B8E121301CD71E401E56F8`; summary `F8C86EEC829420B255E4206F0F6F898DB308CE6C130F88AB286C571167912ED2`.
- The 24 seed records are independently checked against expected shell coordinates for both U-03 orientations. The auditor also checks source hashes, route preservation, all seven room bounds and source dimensions, half-foot proxy separation, six topology links, the complete route-tested archive, route reconstruction, north-side U-02 arrival, SVG XML and selected-D unchanged.
- The abstract model has no walls, doors, swings, exterior grade, emergency escape opening, finished dimensions, actual stairs, landings, floor openings, headroom, roof, structure, plumbing, MEP or yard/court/public-way conditions. U-03's sleeping-room classification and applicability of Connecticut code remain unresolved. A shell edge is not a constructed exterior wall.
- No Revit model, IFC, selected-D source, Incoming RFA or remote state was changed. This is not a code-compliance, accessibility, structural or construction-readiness finding.
