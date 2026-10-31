# M114 - Offset U-03 along the hypothetical west shell edge

Status: bounded room-block exploration only. No room arrangement, house dimension, opening or code solution is selected.

## Scope and preserved direction

The owner selected **38 1/3 x 40 ft only as an exploratory upper-suite shell case**. Selected-D remains the separate 36 x 32 ft test wing. M114 extends M113 by seeding U-03 at three positions (0, 1/2 and 1) along the west edge, for both source-preserved room orientations. It retains the existing U-02 direct shared-hall sample, U-04 guest access sample, private U-01 -> C-PRIVATE -> U-02 -> U-03 topology, both Jack-and-Jill links through U-06, lift keepout and stair-approach proxy. U-03 has no direct shared-hall topology link.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-03-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U03PerimeterRootSeeds `
  -U03PerimeterSeedEdge west -U03PerimeterSpreadSeeds `
  -NodeLimit 1200 -LayoutLimit 5000 -ExportAllRouteTestedCandidates `
  -OutputDirectory Architecture/M114_U03_West_Edge_Offset_Search_2026-10-30

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m114_u03_west_offset_search.ps1
```

The M37 generator passes **29/29** integrity checks. It expands 810/1,200 nodes, archives 141 route-tested arrangements, and reports `search_complete: false`. The independent M114 audit passes **19/19**; separate runs produce identical audit JSON and summary. M113's independent audit was also rerun against its archived package and passes **17/17** with its historical generator pinned.

`Tools/validate_upper_suite_candidate.ps1 .local/revalidation/M114-west-offset -TestShellWidthFt 38.333333 -TestShellDepthFt 40` passes **113** independent checks on the generator-ranked candidate. Its sampled U-02 north-side point is `(11.5, 9.6667)` ft and its outside hall goal `(11.5, 12.1667)` ft is 25.5 ft in grid distance from the landing-approach start. This is not a modeled opening, direct route length, accessibility finding or compliance result.

An exact second M37 run reproduced all five archived generator artifacts byte-for-byte: search, checks, manifest, full route-tested candidate archive and SVG. Two independent M114 audit runs also match byte-for-byte. The M113 audit JSON and summary match their checked-in replay artifacts.

A subsequent full M78 default-mode replay exposed a single provenance-only false field introduced by the U-03 opt-in mode. The generator now emits that field only when enabled. The exact M78 search, checks, SVG and manifest were replayed in ignored scratch with all four hashes matching the retained package, M37 passed 28/28, and the independent candidate validator passed 112/112. The M113, M114 and M115 archived audits also continue to pass 17/17, 19/19 and 21/21 respectively. See M118 in `PLAN.md` and `PROGRESS.md` for the replay record.

## Result

| Measure | Count |
|---|---:|
| Route-tested complete room-block arrangements | 141 |
| U-03 west-edge contact | 141 |
| U-03 north-edge contact (corner position) | 141 |
| U-03 east or south edge contact | 0 |
| Layouts reaching sampled U-01/U-02/U-04 public goals | 16 |
| Those 16 with sampled north-side U-02 arrival | 16 |
| Full-route layouts with no sampled U-03 hall-side reach | 9 |
| Full-route layouts with a sampled U-03 hall-side reach | 7 |

All completed route-tested arrangements seeded at `west@0.0` ended at the northwest corner; the middle and far-end seeds were attempted for both orientations but did not produce the archived route-tested layouts. The search is bounded and order-sensitive, so this is not proof that other positions or layouts cannot work.

The nine layouts without a sampled U-03 hall-side reach are the better privacy-screen subset under the owner's direction. None is a selected or validated room plan. Even the 16 full-route cases provide only reachability to sampled room-side points in a 4 ft abstract grid; they are not doors, opening locations, clearances, code findings, or proof of buildable circulation. The generator's “best” candidate has a U-03 hall-side sample and is not a preferred design.

## Evidence identity and limits

- Selected-D study SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`; proposal and room-program fingerprints are recorded in `search.json` and the independent audit.
- M37 generator SHA256: `8B634E5AE8BFC1889EF5C13B49E8042B4FC0BEF1326E190732AA881695CC9DA2`. M114 audit script SHA256: `2D5209BE47917EC3EC21FCDB550151941A7D9DC3286AC35AF6B144AB743801A6`.
- Search SHA256 `CE60632ABE0ABA3AAF94133F63B9B656704B130FDA2CED73BBD359F47D5B7741`; checks `BB7A1B493FDD95AAAA97521455B46FB030DC9E781BA48618D0DCA8B11BE465E8`; manifest `727A41204D7D75D631EF9CA47940937DB13D00C260C2B544BD65C2E1E1DC9842`; candidate archive `751525CA7CC67F31AD82955C6D1AA1632CB415792B47DB1C5118E2280634AF9D`; SVG `A54776A1D5F609E8977604D64B0C8B7CC1953A95FA0FBDD3CCBB6E5F613FE2A0`.
- Two independent M114 audit outputs match: audit JSON `A91268EFDE198C60255462ACDBCB3A2E3EFD6259DCFB60240FF1E919CF929BB4`; summary `34673D8E0FB5EFB4F797DACCCB98B0D3F1E299677E2EECC86DA20C2C84EB6A`.
- No walls, actual openings, door swings, fixture geometry, clearances, floor openings, stairs, headroom, structure, MEP, exterior grade, qualifying yard/court or route to a public way are represented. U-03 sleeping-room classification and applicable site code remain unresolved. See M106 for the conditional Connecticut opening discussion.
- No Revit, IFC, selected-D source, Incoming RFA or remote state was changed. The 38 1/3 x 40 ft test shell remains unapproved.
