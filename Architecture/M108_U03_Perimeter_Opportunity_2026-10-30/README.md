# M108 - Double-budget U-03 perimeter opportunity screen

Status: a larger, still incomplete search screen. No code-compliance conclusion or room classification is determined.

## Reproduce the search

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope balanced -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds `
  -NodeLimit 8000 -LayoutLimit 5000 `
  -OutputDirectory .local/revalidation/M108-source -ExportAllRouteTestedCandidates
```

This exact run passes **28/28 M37 integrity checks** and archives 863 complete route-tested placements. It reaches 7,992/8,000 search nodes and reports `search_complete: false`; the archive is not exhaustive. The checked-in source outputs are search JSON (`E6307FAB86F36271B9A1EE88848B9349E106ECBF21849356BC223AE059A18A2C`), checks (`BC4FDCC86F7062E8A27795E5CD53EBB032A9D80C483BAAF1486DB7ECB3A63FEE`), SVG (`CE556A5273BFA61F47B9573569177E6D04F79FAC33313F3BC15C594E93399AE1`) and route archive (`44380542825724E40C28BF3F1915E7F626F7C0509E2A0D4ED2251EAF623BCFF2`).

## Reproduce the perimeter audit

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m107_u03_perimeter_opportunity.ps1 `
  -Milestone M108 `
  -ArchivePath Architecture/M108_U03_Perimeter_Opportunity_2026-10-30/all-route-tested-candidates.json `
  -SearchPath Architecture/M108_U03_Perimeter_Opportunity_2026-10-30/search.json `
  -SearchManifestPath Architecture/M108_U03_Perimeter_Opportunity_2026-10-30/search-manifest.json `
  -ExpectedCandidateCount 863 -ExpectedRequiredRouteCandidateCount 5 `
  -ExpectedRequiredRouteAndU02NorthCount 5
```

Two audit runs pass **16/16 checks**, produce identical CSV and SVG, and parse the SVG as XML. Output hashes: JSON `DE78C3278A0C1EB15397B3816D81383427B40C3A57DF7FAB0F43EFCCE9F626A4`; CSV `12871C360B72670DFD5F7863647F5FEA0D5A17B862436B878BE276A71A99A8D3`; SVG `3A7E54825F09873B3F1ABB10B8664C42181298899DDEBBB14F081D17BFDE669A`.

## Result

| Screen | 4,000-node run M107 | 8,000-node run M108 |
|---|---:|---:|
| Search nodes expanded | 3,996 / 4,000 | 7,992 / 8,000 |
| Route-tested placements | 457 | 863 |
| Candidates reaching sampled U-01/U-02/U-04 hall sides | 5 | 5 |
| Those candidates with sampled north-side U-02 reach | 5 | 5 |
| U-03 test-shell perimeter contacts | 0 | 0 |

Doubling the node allowance nearly doubles archived placements without adding any new candidate to the required sampled public-route set or creating a U-03 perimeter-contact opportunity. This strengthens the design signal but does not prove that a different room arrangement, shell, or search strategy cannot work.

## Limits

- The 38.333333 × 40 ft envelope is a hypothetical study case, not a selected house dimension.
- The search hit its node budget and is incomplete.
- M37's corridor grid and sampled room-side reach remain planning proxies, not door clearances or a code analysis.
- U-03 remains a hybrid bedroom/office; sleeping-room status and any emergency escape opening strategy are unresolved.
- Perimeter contact would only identify a possible wall segment. No exterior wall, opening, exterior grade, qualifying yard/court or route to public way is modeled.
- No selected-D geometry, incoming RFA, Revit model or remote branch was modified.
