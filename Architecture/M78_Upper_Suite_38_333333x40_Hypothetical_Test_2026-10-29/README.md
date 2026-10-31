# M78 - Upper-suite room packing at 38.333333 x 40 ft (hypothetical)

Status: owner-authorized exploration only; no shell or room dimensions selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope balanced -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds `
  -NodeLimit 4000 -LayoutLimit 5000 `
  -OutputDirectory Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_upper_suite_candidate.ps1 `
  Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29 `
  -TestShellWidthFt 38.333333 -TestShellDepthFt 40
```

## Result

- Two isolated runs passed the M37 integrity suite **28/28** and produced identical `search.json`, `checks.json`, `upper-suite-search.svg`, and `manifest.json` hashes. Search: 3,996/4,000 nodes, 457 complete room packings recorded, all 457 route-tested, and search incomplete because the node limit was reached.
- A fresh full replay after the later opt-in U-03 seed work ran in ignored scratch `.local/revalidation/M117-M78Replay/`. Its M37 integrity suite again passed **28/28**, and `Tools/validate_upper_suite_candidate.ps1` independently passed **112/112**. All four outputs match the retained M78 package byte-for-byte: search `F23FAE3A197108EE9099CDD8B3A28D58B6F32DEE1E4C1F12537888F88C679467`, checks `43E6CCDFD04F91675063C4A044D3826D2EC12A97D1299216354B62FA61A6C042`, SVG `27C4CC47BDCB0E3E371D1363204AEBCA1D236BFE29AB61AB1E37BFAFE57190E7`, manifest `A7E4DEDE04D3FD5615546CBB7B6045DF40929826BFC5F23E12D0109FFCD08269`. A later search-mode option had added a false-valued field to default JSON; the generator now emits that field only when its opt-in mode is active, restoring exact default-output compatibility.
- A candidate reaches sampled public hall goals for U-01, U-02 and U-04 while retaining the required private U-01/C-PRIVATE/U-02/U-03 topology, primary-only U-05 connection, and both U-03/U-04 Jack-and-Jill links through U-06. U-03 has no sampled public-side reach, consistent with the owner-directed private-only route. The independent validator passes **112/112** checks against the hypothetical 38.333333 x 40 ft rectangle.
- The winning room-block arrangement is the same as the M46 candidate. Scheduled rooms total **759.28 sf**, within the combined 690-810 sf bands in `Requirements/Room_Program.md`; the 65 sf C-PRIVATE connector is separate from that scheduled total. Room coordinates span x=0..38.333333 ft and y=2..34.5 ft. Thus the 40 ft test has 5.5 ft from the northernmost room-block edge to the test boundary, before wall, stair, hall, or construction coordination; the room-block Y span itself is 32.5 ft.
- Selected-D remains a 36 x 32 ft upper-wing test envelope and was not changed. The 38.333333 x 40 ft test is a sensitivity case derived from the M46 candidate, not an approved house dimension or a proven minimum.

## Limits

The route uses a sampled 4 ft corridor grid and nominal room-contact reservations. It does not represent actual doors/openings or swings, wall thickness, privacy, egress, finished interior dimensions, floor openings, stair/headroom geometry, structure, services, roof, site, code applicability, Revit placement or IFC. The search is deterministic but bounded and incomplete; its candidate is a room-block concept only. No claim of code compliance, structural safety, professional approval, or construction readiness follows.

## Disposable Revit/IFC implementation (M81)

The Revit 2027.3.0.28 pilot command now consumes the archived `search.json` and selected-D source after checking both source hashes. It created `.local/revit-pilot/upper-suite/20261030T200906834Z/` as an isolated derivative. The selected-D source and all Incoming RFAs remain unchanged.

The saved model has one level, `M78 Upper FF (Hypothetical Test)` at 5 ft, seven source-matching room-boundary spaces and a model-line rectangle for the 38.333333 x 40 ft envelope translated by the documented upper-frame offset `[0, 6]` ft. The command verifies room areas before saving and exports IFC2X3 from that saved document. A subsequent Revit open visually confirmed the room-block plan. The model contains no walls, slabs, stairs, doors, windows, roof, structure, MEP or M-06 fixture.

Reproduce the independent check from the repository root:

```powershell
./.venv/Scripts/python.exe Tools/RevitPilot/validate_upper_suite_ifc.py .local/revit-pilot/upper-suite/20261030T200906834Z
```

Result: **32/32 checks passed**, IFC2X3 schema validation reports zero issues, and two independent validation reports match byte-for-byte (SHA256 `90A86A2C56B8C2197DD5AD98BB86C416A7926980564FFE01AF209D61581164DF`). The saved RVT is SHA256 `28BC319633C2EE96711896203355163D49469A64CC265F3540E449D1E6844995`; its IFC2X3 export is SHA256 `87478B8D794C88904AA4532BA5B96025F488AB9EFFED54E23B3F39B01A82C96`. The validator also checks the seven room rectangles remain inside the local hypothetical shell envelope and confirms the IFC has zero walls, slabs, stairs, stair flights, doors and windows.

This host result closes only Revit generation and room-space IFC validation for the test case. It does not validate actual door openings, stair geometry, privacy, egress, clear routes, code applicability, product fit, roof, services or structure. The bounded M78 search remains incomplete; this is not an approved shell dimension or a construction model.
