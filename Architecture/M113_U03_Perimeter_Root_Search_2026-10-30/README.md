# M113 - U-03-rooted perimeter opportunity screen

Status: bounded room-block search and trade-off evidence only. No room arrangement or shell dimension is selected.

## Scope

The owner authorized continued exploration of a **38 1/3 x 40 ft hypothetical upper-suite shell**. This is not a selected house size; selected D retains its separate 36 x 32 ft test wing. M113 tests a different search strategy after M107/M108 repeatedly found no U-03 perimeter contact: root the room-block search at U-03, try each cardinal shell edge, then attach the remaining blocks through the existing room-link graph.

The sample preserves the owner-directed private route U-01 -> C-PRIVATE -> U-02 -> U-03, direct shared-hall arrival at U-02, independent guest hall access at U-04, both Jack-and-Jill links through U-06, the source lift projection and reserved stair approach. The route gate is still the existing 4 ft grid proxy. No direct U-03 hall door is added.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-03-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U03PerimeterRootSeeds `
  -NodeLimit 1200 -LayoutLimit 5000 -ExportAllRouteTestedCandidates `
  -OutputDirectory Architecture/M113_U03_Perimeter_Root_Search_2026-10-30

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m113_u03_perimeter_search.ps1
```

The generator passes **28/28** integrity checks. The search expanded 464/1,200 nodes and recorded 45 complete route-tested room-block arrangements. It hit its bound and is incomplete. The independent M113 audit passes **16/16** checks; two audit runs match byte-for-byte. The SVG parses as XML.

## Result

| Measure | Count |
|---|---:|
| Complete room-block arrangements tested | 45 |
| U-03 touching west shell edge | 45 |
| U-03 touching north/east/south shell edge | 0 |
| Sampled U-03 corridor-side contact | 45 |
| Reaching at least one of U-01/U-02/U-04 | 28 |
| Reaching U-02's required hall-side sample | 0 |
| Reaching all three required public-room samples | 0 |

In this centered-edge/root order and bounded node allocation, only west-edge U-03 arrangements completed. The reachability counts were 17 with no required public-room side reached and 28 with one (U-01 or U-04); none reached U-02. A reachable U-03 side is merely a corridor grid sample, not a door or permission to create a shared-hall opening. No candidate clears the required route screen, so no layout is accepted.

In the first archived arrangement, U-02 sits west of U-03 and outside the stair-side route proxy. M114 should vary U-03's position along the west edge and retain every required route/adjacency constraint before considering any layout further. This is a search hypothesis, not a dimension or design decision.

## Evidence identity and limits

- Selected-D study SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`.
- M37 search SHA256 `2A6F06FD83690D6E39A830B96848349AAC72E74778B19EFDC7457C000D50E752`; check report `EE27AB5E537316B240E0B5C1D1927D71B88A68FCA7C1CF2DD23D5A06D4D94870`; full candidate archive `81A1306B8D95EAE36C1FE232D43DEEBC86E98B31AA3FE1EAEB5DB29930227CD5`.
- Independent audit `m113-audit.json` SHA256 `63CDB435ECFF396C47E0BC21E3515020297459336ED25140E15CE938930153DA`; summary SHA256 `6FFED3D6D19469141990A72C21C6048BC8F92C18383494A6BCF67E69FE89E560`.
- The generator archive does not model walls, actual openings, clearances, floor openings, landings, headroom, structure, MEP, finished dimensions, exterior grade, a qualifying yard/court, or a route to a public way. The hypothetical shell boundary is not an exterior wall. U-03 sleeping-room status and code applicability remain unresolved; see [M106](../M106_Upper_Suite_Sleeping_Room_Perimeter_2026-10-30/README.md).
- `validate_upper_suite_candidate.ps1` is intentionally not a fit-for-purpose pass condition here: it requires a `best_candidate` satisfying every required public-room route, while M113 found none. The source-bound 16-check audit validates all 45 archived room blocks and reconstructs the sampled route counts instead.
- A full default M78 byte-for-byte replay of the modified M37 generator was stopped after more than five minutes. A 100-node default-mode smoke run passed 28/28 with the same balanced search roots; the existing M78 artifacts were not changed. A complete default-output regression remains outstanding.

No Revit, IFC, selected-D geometry, room dimensions, product family, or remote state was changed.
