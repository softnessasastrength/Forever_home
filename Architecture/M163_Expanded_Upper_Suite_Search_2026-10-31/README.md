# M163 - Expanded upper-suite route and perimeter search

**Status:** bounded, reproducible room-block diagnostic. The owner-authorized 38 1/3 x 40 ft shell remains an exploration case; no room arrangement, shell, roof, wall, opening or house dimension is selected.

## Reproduce

Run from the repository root in Windows PowerShell 5.1. The large generator outputs belong in ignored scratch paths; the audited summary can be regenerated into this report directory.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-01-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U01PerimeterRootSeeds -U01PerimeterSeedEdge all `
  -U01PerimeterSpreadSeeds -RequiredPerimeterContactRooms 'U-01,U-03,U-04' `
  -NodeLimit 9600 -LayoutLimit 10000 -ExportAllRouteTestedCandidates `
  -OutputDirectory .local/revalidation/M163-expanded

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m163_expanded_m158_search.ps1 `
  -RunDirectory .local/revalidation/M163-expanded `
  -OutputDirectory Architecture/M163_Expanded_Upper_Suite_Search_2026-10-31

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_upper_suite_candidate.ps1 `
  -RunDirectory .local/revalidation/M163-expanded `
  -TestShellWidthFt 38.333333 -TestShellDepthFt 40

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m163_expanded_roof_exposure.ps1 `
  -OutputDirectory Architecture/M163_Expanded_Upper_Suite_Search_2026-10-31
```

For byte-for-byte repeatability, rerun M37 with the same switches and a separate output folder, then rerun the audit against that folder. The retained report binds the run by source and artifact SHA256 values.

## Result

Both independent M37 runs pass **31/31** generator checks and reproduce the same five output artifacts. The bounded search expands **3,065/9,600** nodes, reaches per-seed caps, archives **102 distinct** complete route-tested layouts and reports itself incomplete. The independent M163 audit passes **16/16** on both runs: every candidate preserves all three requested bedroom-capable outline contacts, clears shell/core proxy constraints, maintains seven source rooms and six topology contacts, and has no sampled U-03 public-side reach. **41/102** also reach every sampled side for U-01, U-02 and U-04. Both earlier M158 archive candidates reappear in this expanded set. The M37 best candidate independently passes **115/115** candidate checks.

The 102 archived records include candidates that do not meet every public-side sample; the count of 41 is the narrower subset meeting all sampled route and private-side conditions. These are grid-sampled route proxies, not actual doors, circulation clear widths, egress routes or accessibility findings. All 102 candidates are distinct by normalized room-coordinate key. The bounded search does not prove that unobserved options are impossible.

The roof sensitivity evaluates those 41 route-qualified candidates against all six existing M83 ideal 8:12, 10:12 and 12:12 gable planes on both ridge axes, plus the one retained M158 route-qualified baseline: **756 room/candidate/roof rows**, passing **12/12** source, geometry and area-median checks in two identical PowerShell runs. For the 41 expanded candidates, the lowest *worst-bedroom* conditional effective eave-ceiling threshold within each roof case is 5 ft, equal to the retained M158 route-qualified baseline in all six cases. No candidate is free of bedroom-block contact with an ideal eave on either ridge axis. Thus the expanded room search and steeper ideal pitches do not improve this study's controlling full-block/eave proxy. This is not a five-foot eave recommendation or an actual headroom result; floor/eave elevation, build-down and legal required floor area remain unknown. The conditional comparison is only a ranking aid within the stated proxy.

## Evidence

| Artifact | SHA256 |
|---|---|
| M37 `search.json` | `8C1BD0887123D5AA4A224EDC256CE8917268203B6C770F5438AC5074C1D46C72` |
| M37 `checks.json` | `8ED8920FDE373C2EF30371FE96E8A5F844DEAA7565F7287CCAEC90A01C9344B8` |
| M37 `upper-suite-search.svg` | `9597906F6BD16A9E65411C643EE8C320AECC36FD55061D98D3849180CD19587C` |
| M37 `manifest.json` | `F5AB70F6C689415F5A4854EE92433D65F8E4AD02F7AC02DB48449500AA203E09` |
| M37 route-tested archive (ignored scratch) | `9ECDCAC64B404BCA21E07E663440703C7496E360BF80A8FCA6B4B5A885309CBE` |
| Independent audit JSON | `880A8E33EA9737AB4269FC9CB053ECD8D8D2671F81BB5ADA654D03640DD41EAB` |
| Independent audit CSV | `8AF8896C677CCC9D47E827EC11352C5B51BE8C8DFA3B810DBF72B2AE09C34245` |
| Roof exposure JSON | `211D34BE82099B98F95E677E8F4D4C2E715966ABBD95262E75566C64228D62F2` |
| Roof exposure CSV | `604EAD5956F507B5883E98322F3BF712D23FBB8D8F63E4D8E0DC57BE801990AD` |
| Independent audit script | `Tools/audit_m163_expanded_m158_search.ps1` (SHA256 `C6025211F8D4A8E6ECCA2DE3ACBAB446C9D90B34184BD29B78AEFA113FC02FAF`) |
| Roof exposure script | `Tools/analyze_m163_expanded_roof_exposure.ps1` (SHA256 `D862E57B209F7F1F796145EB441A13B4A485FE430575EE7A2A8D97C2699E6D21`) |

The detailed route audit tables and roof exposure tables are alongside this README. Full route-tested generator archives remain under ignored `.local/revalidation/M163-expanded/` and `M163-expanded-repeat/`; they do not replace or alter the retained M158 evidence. The roof analyzer binds those scratch archives to the tracked independent audit, the retained M158 route-qualified comparator, M83 roof options and selected-D source by SHA256.

## Limits

The outline is not an exterior wall or EERO; the hypothetical shell is not a selected house dimension. No window product, net-clear opening, sill/grade, stair, actual room door, roof assembly, floor/eave datum, finished headroom, structure, plumbing, Revit placement or IFC export is validated. No code classification or applicability is assigned. Selected-D, Revit/IFC, Incoming RFAs, owner choices and remote state are unchanged. This is not code compliance, structural safety, certification, permit approval or construction readiness.
