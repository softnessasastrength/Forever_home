# M157 — U-01 perimeter-rooted upper-suite search

**Status:** reproducible bounded search diagnostic. The owner-authorized 38 1/3 × 40 ft shell remains an exploration-only envelope. No room layout or shell is selected.

## Reproduce

Run from the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-01-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U01PerimeterRootSeeds -U01PerimeterSeedEdge all `
  -U01PerimeterSpreadSeeds -NodeLimit 4800 -LayoutLimit 10000 `
  -ExportAllRouteTestedCandidates `
  -OutputDirectory Architecture/M157_U01_Perimeter_Root_Search_2026-10-30

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m157_u01_perimeter_search.ps1 `
  -RunDirectory Architecture/M157_U01_Perimeter_Root_Search_2026-10-30 `
  -OutputDirectory Architecture/M157_U01_Perimeter_Root_Search_2026-10-30
```

M37 now offers opt-in `-U01PerimeterRootSeeds`, parallel to its existing U-03 mode. It places U-01 at edge positions on all four sides, with three along-edge fractions in each allowed orientation. The new switches are omitted from default report metadata unless selected. Before/after regression runs using the exact pre-change M37 script and the modified M37 script match all four default artifacts byte-for-byte on current source inputs.

## Result

The generator passes **29/29** checks and expands **3,600/4,800** nodes. The bounded search records 766 complete packings, all 766 with a sampled lift-approach-clear route test, and remains incomplete. It finds no candidate that reaches sampled U-01/U-02/U-04 public sides while keeping U-03 off public-side samples. U-03 has at least one public-side sample in **291/766** route-tested packings.

The independent audit passes **20/20** checks across all 766 records, verifying source room identities and dimensions, test-shell containment, pairwise non-overlap and all six nominal 0.5 ft/3.5 ft room-contact links. Perimeter-outline contact counts are U-01 **766/766**, U-03 **0/766**, and U-04 **20/766**. No candidate gives all three bedroom-capable rooms outline contact. This search bias therefore shifts the perimeter opportunity from U-03 to U-01 without solving the combined exterior-frontage and route/privacy problem.

Two separate generator runs produce identical SHA256 hashes for the five M37 artifacts. Two audit runs also match both independent audit artifacts byte-for-byte. The audit was replayed after the M158 generator extension against the current M37 source and still passes 20/20:

On 2026-10-31, the exact M157 generator command was also replayed twice with the current M37 source in ignored scratch directories. Both runs pass 29/29, record 3,600/4,800 nodes and 766 route-tested packings, and reproduce all five packaged M157 generator artifact hashes exactly. The independent archive audit was then replayed twice against the current source; both pass 20/20 and reproduce the report/CSV hashes below.

| Artifact | SHA256 |
|---|---|
| `search.json` | `681C6A516113C564C6E998674BCD13639E132B5ADEB84BAC583D7F3F6B4C0B05` |
| `checks.json` | `E49A8200B31C749558C3965ED4D92E20857D01950D7638ABB8F0F27B982B01EA` |
| `upper-suite-search.svg` | `8002162E72051CE7C92C88B133299CCB6B142B4DC76A0115F2326AD9E0042CBD` |
| `manifest.json` | `E7B9D8AF178644A6D18EA6A6AEF4B65388EC8B1197905104EE6A354B3C59F29A` |
| `all-route-tested-candidates.json` | `9FBF6A65B478AC88215E19E14C109CED5F39CAE944BC3F84F5AA5FF550113A4F` |
| `m157-audit.json` | `64CF0CD87F6298D0E4F5B85C650590B33BA9FD890469FC4E7C56F6E47A9C5765` |
| `m157-candidate-audit.csv` | `06A3075A9BB2429C2B17CAD28E06C46ECE20F1FEDEBFB77AA784E301811F2BE7` |

## Limits and next search

The route tests are sampled 4 ft grid proxies. The outline is not a wall; none of these rows provides an opening, a legal EERO, qualifying exterior yard/court, sill or grade relationship. Room sleeping classifications and Connecticut permit applicability remain unresolved. Roof, stairs, doors, services, Revit geometry and IFC were not added by this search.

M158 has since required U-01/U-03/U-04 joint outline contact. Its bounded archive contains two candidates, one of which meets the sampled U-01/U-02/U-04 public goals while keeping U-03 off sampled public sides. See `Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31/README.md`; the results remain hypothetical room-block diagnostics. Revit host work remains unavailable while the active trust prompt names a stale DLL different from the verified manifest target.
