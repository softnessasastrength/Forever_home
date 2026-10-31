# M132 - Primary-bath interface test

**Status:** proposal-only comparison; the owner-authorized 38 1/3 x 40 ft shell remains hypothetical. No room layout, bathroom, sink, door, roof or fixture is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m132_primary_bath_interface.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 -LandingAlignedRootSeeds `
  -PublicDoorEdgeSamples 9 `
  -ValidateCandidateJsonPath Architecture/M132_Primary_Bath_Interface_2026-10-30/m132-layouts.json `
  -CandidateRouteReportPath Architecture/M132_Primary_Bath_Interface_2026-10-30/m132-route-validation.json
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m132_primary_bath_interface.ps1 `
  -RouteValidationReportPath Architecture/M132_Primary_Bath_Interface_2026-10-30/m132-route-validation.json
```

The source-bound analyzer checks the selected-D fingerprint, M130's two roof-exposure leaders, room-block areas and shell containment. It preserves both M130 room layouts unchanged. Their U-01/U-05 blocks are separated by the existing 0.5 ft wall-band convention; the 9 ft or 10 ft contact length supports the owner-approved door-matrix reservation of 3.5 ft. A centered reservation fits arithmetically with 2.75 ft or 3.25 ft of length remaining at each end. This is only a topology reservation, not a door width, clear opening or wall detail.

The fixture screen pairs the current-SKU American Standard Champion PRO 610AA001.020 annotated plan envelope (19 x 30 1/4 in) with two documented lavatory candidates: discontinued American Standard Evolution 0467400.020 (22 x 17 1/2 in) and nominal KOHLER Tresham K-2844-4-0 (24 x 19 1/2 in). The 610AA was researched for the main-floor M-06 half bath; it appears in U-05 here only as a comparative envelope, not as an owner-selected primary-bath toilet. Both sink plan orientations are screened. A same-wall arrangement uses the existing preliminary 2021 IRC R307.1/P2705.1 screen recorded in [M-06 clearance research](../../Research/M06_Clearance_Basis_2026-10-30.md): 15 in from the water-closet centerline to the side obstruction and 21 in in front. A 30 in WC-to-sink centerline separation is an explicit layout assumption from earlier M-06 screens. The clearance values' local applicability has not been confirmed.

The M83 ideal roof planes are recomputed over each unchanged U-05 rectangle for all six pitch/ridge comparisons. The report and CSV record only relative rise above an unspecified eave plane. The SVG shows the two room-block options, the 0.5 ft wall-band convention, centered nominal reservation, and toilet/sink envelopes with dashed 21 in strips. It is not a dimensioned construction plan.

The source analyzer passes **25/25** checks after attaching M37's route report and emits two layout comparisons, eight fixture-envelope cases and twelve roof cases. It pins the reviewed M115, M130, M83, selected-D, sink and clearance-research inputs by SHA256 and checks that the route report fingerprints the exact layout JSON. M37 independently passes **4/4** checks on both layouts. Two complete three-command replays, one in the tracked package and one in ignored scratch, produce byte-identical artifacts:

| Artifact | SHA256 |
|---|---|
| `m132-checks.json` | `E2D43F63BBF7F857C0BCF33CE2DB3AF3388B85740B979BCEB1E022B8C8566F7D` |
| `m132-fixture-groups.csv` | `DD25B0D6F50BD067ADEDA7976E884ECBAFF2DFE5C80D6E9BC8150AB13D504BD1` |
| `m132-layouts.json` | `C9868179D98AB132209E34CACF44D05DBD732FC889801A02289D3411C6B00853` |
| `m132-plan.svg` | `A82B4FAAAE05EF2647867E2C18B03D979BE545B07C8D1721D30B3347D2D7D59D` |
| `m132-report.json` | `64F79B489A2B8245162AF896E0FF8DE988707B4CB3DF9D7B99AEBDB05C545F4C` |
| `m132-roof-comparison.csv` | `64870BBAB17DD5EC62743F85322BA8C375B8EC03A5B0E5A0F3AAE1C2D78861C2` |
| `m132-route-validation.json` | `1D96A5BCDB848AF1F1B7E77FF5D6C7536A024DD21C590387E245C8A743D87737` |

## Findings

- Both M130 leaders preserve the M37 0.5 ft wall-band convention. U-01/U-05 contact lengths are 9 ft (NE-19) and 10 ft (NE-24); each accommodates the source 3.5 ft nominal door reservation as centered arithmetic. This confirms the topological reservation fits; actual wall and door geometry remain unmodeled.
- M37's route engine passes both layouts at its 1/6-ft grid and nine sampled points per public-room edge: U-01, U-02 and U-04 each have reachable sampled edges, including north-side U-02 arrival, and U-03 has no reachable public-side sample. This is a grid reachability result, not an opening, private-door or clear-width validation.
- The preliminary rectangular fixture-group screen fits both lavatory candidates in both orientations in each layout (8/8 combinations). This does not test finished-wall faces, lavatory use envelopes, an actual door or a complete bath arrangement.
- At 12:12, the unchanged block candidates retain the roof-axis trade-off: NE-24 has 10 ft minimum ideal rise for ridge X and 7.166667 ft for ridge Y; NE-19 has 9 ft for ridge X and 8.166667 ft for ridge Y. The eave is unspecified, so these are not finished headroom.
- No floor/eave datum, ceiling assembly or roof thickness is available; none of these rises is finished headroom. No conditional Connecticut ceiling screen is possible.

## Open design and validation gates

- Door location, width, leaf, swing, finished-wall opening and actual passage from U-01 are untested.
- The selected-D upper-door matrix supplies only a 3.5 ft nominal reservation for U-01/U-05. Its exact opening location, width interpretation, leaf, swing and finished-wall passage remain untested. U-03's absence of a public-side sample is not proof of private access through U-02; both private links and the Jack-and-Jill door topology still need physical door checks.
- The toilet lacks exact-SKU Revit solids. Evolution is discontinued and its family description conflicts with its pedestal metadata; the Tresham family is uninspected. Neither lavatory is selected.
- U-05 retains the room-program tub/shower baseline, but no product or dimensions were supplied; bathing fixture and use clearances are not represented.
- Rough-in position, water/waste/vent routing, wall build-up, final fixture clearance, accessibility and applicable code path remain unresolved. The current study does not assign a bathroom footprint.
- Revit and IFC generation were not run. The live Revit add-in prompt/manifest mismatch recorded in `Project/AI_Handoff.md` remains a separate host-validation blocker.

This is a design exploration, not a code review, structural assessment, professional approval, permit submission or construction document.
