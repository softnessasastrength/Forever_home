# M164 - Gable-end-only bedroom perimeter search

**Status:** completed bounded discrete search and roof sensitivity. The 38 1/3 x 40 ft shell remains the owner's exploration case only; no room arrangement, shell, roof, wall, opening or house dimension is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1, rerun M37 with the same room, shell, route and perimeter settings used for M163, increasing its node and layout limits. Keep the route-tested archives in ignored scratch folders.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-01-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U01PerimeterRootSeeds -U01PerimeterSeedEdge all `
  -U01PerimeterSpreadSeeds -RequiredPerimeterContactRooms 'U-01,U-03,U-04' `
  -NodeLimit 19200 -LayoutLimit 20000 -ExportAllRouteTestedCandidates `
  -OutputDirectory .local/revalidation/M164-expanded

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m163_expanded_m158_search.ps1 `
  -RunDirectory .local/revalidation/M164-expanded `
  -OutputDirectory .local/revalidation/M164-audit

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_upper_suite_candidate.ps1 `
  -RunDirectory .local/revalidation/M164-expanded `
  -TestShellWidthFt 38.333333 -TestShellDepthFt 40

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m163_expanded_roof_exposure.ps1 `
  -M163RunDirectory .local/revalidation/M164-expanded `
  -M163AuditDirectory .local/revalidation/M164-audit `
  -OutputDirectory .local/revalidation/M164-roof `
  -Milestone M164 -OutputFileStem m164-gable-exposure
```

Repeat M37 and both analyses into distinct ignored output directories to reproduce the hashes below. The existing M163 audit and roof-analysis scripts accept the new run directories and bind every source by SHA256; their historical command-line parameter names are retained for compatibility.

## Result

Two Windows PowerShell 5.1 runs pass **31/31** M37 checks and reproduce all five generator artifacts byte-for-byte. The generator exhausts its configured discrete search with **3,122/19,200** nodes, records **120 distinct** complete route-tested layouts, sets `search_complete=true`, and does not reach its node cap. This completion is limited to the declared root seeds, room-contact samples, grid and search rules; it is not an exhaustive proof over continuous floor plans.

The independent M163 verifier, pointed at each M164 run, passes **16/16** checks twice. All 120 candidates preserve the three required outline contacts and keep U-03 off sampled public hall sides; **48/120** reach every sampled side for U-01/U-02/U-04. All 102 M163 coordinate keys reappear, with 18 additional unique layouts. The best M37 candidate passes **115/115** independent candidate checks.

The roof analyzer passes **12/12** in repeated runs, returning **882** rows across 48 expanded route-qualified candidates, three bedroom-capable blocks, six ideal M83 gable cases, and one retained M158 route-qualified comparator. After M166 refreshed the M83 source fingerprint, this analysis was regenerated twice against the current M83 options; both outputs match byte-for-byte. For each ridge axis and pitch, **0/48** candidates place all three bedroom-capable blocks on gable-end contacts while avoiding every ideal eave contact. The best expanded candidate's worst-bedroom conditional effective-eave threshold remains **5 ft** in all six cases, matching the M158 route-qualified comparator. M168 further counts how many bedroom-capable blocks touch an ideal eave at 12:12: ridge X has two contacts in all 48 layouts, while ridge Y has one in 24 and two in 24. This orientation sensitivity does not show that any actual eave height or headroom is adequate; see the separate M168 report.

| Roof case | M164 route-qualified layouts with all three bedroom blocks off ideal eaves | Best worst-bedroom conditional threshold | M158 comparator |
|---|---:|---:|---:|
| Ridge X, 8:12 | 0 / 48 | 5 ft | 5 ft |
| Ridge X, 10:12 | 0 / 48 | 5 ft | 5 ft |
| Ridge X, 12:12 | 0 / 48 | 5 ft | 5 ft |
| Ridge Y, 8:12 | 0 / 48 | 5 ft | 5 ft |
| Ridge Y, 10:12 | 0 / 48 | 5 ft | 5 ft |
| Ridge Y, 12:12 | 0 / 48 | 5 ft | 5 ft |

The conditional threshold assumes the entire schematic bedroom block is required floor area. It is a ranking proxy only, based on the preliminary Connecticut 2022 CSBC amended 2021 IRC R305.1 research basis; room classification, legal required floor area, site, municipality, permit cycle, finished-floor/eave datum and roof build-down remain unresolved. No threshold is evaluated as passing or failing. A steeper ideal pitch does not remove the eave-contact limitation in this sample.

## Evidence fingerprints

| M164 generator artifact | SHA256 |
|---|---|
| `search.json` | `707FBF29A7D95DC332E81F14079AB174CF381CAE1398D8749078084C9688C719` |
| `checks.json` | `87EE7CA4E65928B657D9ED928D6342293105C8D9359313D118F368638D864D6A` |
| `upper-suite-search.svg` | `EC46628396BA3D4B1C439E4D04E7C043335B13E3E35085D8D3CAFD05E5F8FF9C` |
| `manifest.json` | `F2D91F2165F36DD49F43203CFCCAC13AEAD19A9ACF56307CFCA56C872795AB9C` |
| route-tested candidate archive | `C2FD422ADF8E6AF32770BB021B7D2191BD890F6037C36F403300AF51A35F28D5` |
| independent route/perimeter audit JSON | `5A40BCB977C1B911F8AC744E2445077AA9D8EA39B181E93E335FFF44DB3F2B69` |
| independent route/perimeter audit CSV | `FD56CE09AAB88D168B56351DDCC2392B81B12A26730A78CD61BCC9D079E35672` |
| roof exposure JSON (current M166 source refresh) | `F4A79EE7F2A9666D550A274F0579BAD37BD3F23EABB3E8A6CD205E50EFFBB593` |
| roof exposure CSV | `8D62CCF6E9BEEDD412D67AA7DF02A3876A036F5A008CF5FF7831305049E44520` |

Full M164 generator, audit and roof-analysis outputs remain under ignored `.local/revalidation/M164-*`; they do not replace M158/M163 source archives. The hashes above identify both repeated runs and the report results. No selected-D, Revit/IFC, Incoming RFA or remote file changed.

## Limits

The shell outline is not an exterior wall or EERO. The public-route grid samples are not doors, passage width, accessibility or egress validation. This is not a headroom survey, code-compliance determination, structural design, permit review or construction-ready model. No layout or roof is selected.
