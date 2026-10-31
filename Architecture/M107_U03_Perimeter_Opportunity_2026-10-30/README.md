# M107 - Bounded U-03 test-shell perimeter opportunity audit

Status: geometry-search screen only. It does not classify U-03 as a sleeping room, design an exterior wall or emergency escape opening, or determine code compliance.

## Reproduce the archived search

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope balanced -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds `
  -NodeLimit 4000 -LayoutLimit 5000 `
  -OutputDirectory .local/revalidation/M107-source -ExportAllRouteTestedCandidates
```

The archive is included here as `all-route-tested-candidates.json` (457 route-tested placements; SHA256 `F4B206596E54BA0D72E8DAC72021EAE9318FDF7BC4D75C55D3152FA5E3142F28`). Its source search SHA256 matches the checked-in M78 `search.json`. The opt-in switch adds only the full candidate archive and metadata to the M37 run. Its standard `search.json`, `checks.json` and SVG matched the M78 checked-in outputs byte-for-byte: `F23FAE3A197108EE9099CDD8B3A28D58B6F32DEE1E4C1F12537888F88C679467`, `43E6CCDFD04F91675063C4A044D3826D2EC12A97D1299216354B62FA61A6C042` and `27C4CC47BDB0E3E371D1363204AEBCA1D236BFE29AB61AB1E37BFAFE57190E7` respectively. The M37 integrity checks pass 28/28.

The search is deliberately bounded. It reached the per-root node limit (3,996 nodes expanded against a 4,000 limit) and reports `search_complete: false`; 457 full placements received route tests. This archive is not an exhaustive enumeration of all possible plans.

## Reproduce this audit

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m107_u03_perimeter_opportunity.ps1
```

The PowerShell 5.1 audit verifies archive/source binding, selected-D source binding, room-block containment/non-overlap, and route-side reconstruction, then writes JSON, CSV, XML-parseable SVG and a hash manifest. To write a separate replay:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m107_u03_perimeter_opportunity.ps1 -OutputDirectory .local/revalidation/M107-replay
```

Two independent audit runs pass **16/16 checks** and match the checked-in JSON (`4D3C875BE12B7EE19485B59A5D7257EC55C9935B44E04E176D69AD4AAB9F40F5`), CSV (`5694A12290DBA1036CDE66F43A09F0F4D41A58135AA45CCE652412ED382D6D9D`) and SVG (`33FECC98570429E0D347780199215FEC2A11130523DF3E8DEA368F76A1D5F176`). SVG parsing passes.

## Result

| Screen | Count |
|---|---:|
| Archived route-tested placements | 457 |
| Placements reaching sampled hall sides of U-01, U-02 and U-04 | 5 |
| Those five with a sampled north-side U-02 arrival | 5 |
| Any placement with U-03 touching the hypothetical shell perimeter | 0 |
| Required-route placement with U-03 perimeter contact | 0 |

Within this bounded sample, the U-03 room block stays inside the shell in every route-tested placement. None of the five candidates that pass the required public-room route proxy gives U-03 a shell-edge segment. If U-03 is intended for sleeping, the room/shell arrangement needs further design study or a separately evaluated opening strategy. This does not prove that another arrangement is impossible or that a roof opening is acceptable.

## Limits and next decision

- `38.333333 × 40 ft` is the owner's authorized hypothetical shell test, not a selected house dimension.
- M37's sampled 4 ft corridor reachability and room-side goals are schematic proxies, not door, maneuvering or code checks.
- Shell contact would only indicate a possible perimeter wall zone. No wall, clear opening, yard/court, exterior route or grade is modeled.
- U-03 remains a hybrid bedroom/office; whether it is intended or classified as a sleeping room is unresolved.
- The current result is restricted to 457 route-tested candidates from an incomplete bounded search. It does not establish that other room plans or shell shapes cannot solve the issue.
- No selected-D geometry, incoming RFA, Revit model or remote branch was modified.
