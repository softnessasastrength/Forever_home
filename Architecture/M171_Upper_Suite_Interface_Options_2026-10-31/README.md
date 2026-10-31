# M171 - Upper-suite room-interface options

**Status:** reproducible interface geometry audit for unselected room-block proposals. The 38 1/3 x 40 ft shell is an owner-authorized exploration case only. No room layout, wall, door, roof, or house dimension is selected.

## Finding

M171 joins M164's independent audit of route-qualified layouts to the exact M37 candidate archive. It checks each required internal room link and records the projected overlap of the two room-block faces and the gap between those faces. M37 documents that 0.5 ft gap as a nominal wall allowance. The measured spans are therefore interface opportunities across a wall zone, not actual walls, door openings, or clear widths.

All 48 layouts that pass the sampled public/private route gate have six positive face-overlap intervals, and all six links preserve the documented 0.5 ft nominal wall allowance:

| Required link | Orientation | Face-overlap span in 48 proposals |
|---|---|---:|
| U-01 to C-PRIVATE | Horizontal | 10 ft |
| C-PRIVATE to U-02 | Horizontal | 10 ft |
| U-02 to U-03 | Vertical | 3.5 ft |
| U-03 to U-06 | Horizontal | 12 ft |
| U-06 to U-04 | Horizontal | 12 ft |
| U-01 to U-05 | Vertical | 9 or 10 ft |

The 3.5 ft U-02/U-03 span is the limiting internal interface in every candidate. M37 describes the inherited 3.5 ft reservation as a nominal edge-contact reservation, not a clear opening. It must not be read as a door specification.

In the sampled four-foot upper-hall route search, U-02 has east and north reachable room sides in all 48 candidates; 24 also have a south reachable side. U-01 and U-04 have an east reachable side in all 48. U-03 remains unreachable from the sampled public hall sides in every qualified candidate. These are grid-reachability results, not door locations, passage-width checks, or privacy/egress/accessibility validation.

The geometric ordering is descriptive only: it sorts by the minimum, median, then total of the six face-overlap spans and by lower maximum nominal wall gap. Twelve candidates have 57.5 ft summed face-overlap span; 36 have 56.5 ft. The difference is solely the U-01/U-05 interface span (10 ft versus 9 ft). These totals are not usable floor area or a design-quality score.

## Reproduce

M171 consumes M164's deterministic 120-candidate route archive and independent audit, then selects the 48 layouts satisfying U-01/U-02/U-04 sampled public reach while keeping U-03 private. Recreate the M164 inputs twice in separate ignored scratch directories; these are the M164 documented parameters with only the output paths changed:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-01-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U01PerimeterRootSeeds -U01PerimeterSeedEdge all `
  -U01PerimeterSpreadSeeds -RequiredPerimeterContactRooms 'U-01,U-03,U-04' `
  -NodeLimit 19200 -LayoutLimit 20000 -ExportAllRouteTestedCandidates `
  -OutputDirectory .local/revalidation/M171-source-a

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m163_expanded_m158_search.ps1 `
  -RunDirectory .local/revalidation/M171-source-a `
  -OutputDirectory .local/revalidation/M171-audit-a
```

Repeat the same two commands with `M171-source-b` and `M171-audit-b`. The audit writes `m163-expanded-joint-perimeter-audit.json`; pass the two generated source/audit pairs into M171:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m171_upper_suite_interface_options.ps1 `
  -RunDirectory .local/revalidation/M171-source-a `
  -AuditDirectory .local/revalidation/M171-audit-a `
  -OutputDirectory .local/revalidation/M171-a

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m171_upper_suite_interface_options.ps1 `
  -RunDirectory .local/revalidation/M171-source-b `
  -AuditDirectory .local/revalidation/M171-audit-b `
  -OutputDirectory .local/revalidation/M171-b
```

Then run once with `-OutputDirectory Architecture/M171_Upper_Suite_Interface_Options_2026-10-31` to refresh the retained JSON/CSV. The script checks source and audit fingerprints, the unchanged selected-D and owner-follow-up source hashes, the current M37 generator fingerprint, 48 unique route-qualified keys, all 288 link intervals, and the wall-gap/topology invariants. It confines every path to the repository.

The two independent source/audit inputs pass **17/17** checks and reproduce both M171 outputs byte-for-byte:

- JSON SHA256: `E2569D7F77EF699C85EDA4376D1C9FF4056001AAF86CB1553CE9133B75D6ECDF`
- CSV SHA256: `86AEB8D19704E584A3CC8A7D79390F7B79D7CDE9434FF950568E798794F1D91A`

## Limits and next design gate

M171 does not generate walls or openings and does not apply a door width. Door leaf, net clear opening, swing, privacy, hardware, thresholds, approach, finished wall faces, structure, MEP and applicable code remain unresolved. The upper-hall route is sampled on a four-foot corridor grid and does not prove a physical route. No layout is selected; selected-D and Revit/IFC source artifacts remain unchanged. The next native Revit step is a disposable door/partition study after the owner can dismiss the introductory Revit overlay and a candidate interface is chosen for that test.

This is not a code-compliance, accessibility, egress, structural-safety, professional-review, permit, or construction-readiness determination.
