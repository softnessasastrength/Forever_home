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
- A candidate reaches sampled public hall goals for U-01, U-02 and U-04 while retaining the required private U-01/C-PRIVATE/U-02/U-03 topology, primary-only U-05 connection, and both U-03/U-04 Jack-and-Jill links through U-06. U-03 has no sampled public-side reach, consistent with the owner-directed private-only route. The independent validator passes **112/112** checks against the hypothetical 38.333333 x 40 ft rectangle.
- The winning room-block arrangement is the same as the M46 candidate. Scheduled rooms total **759.28 sf**, within the combined 690-810 sf bands in `Requirements/Room_Program.md`; the 65 sf C-PRIVATE connector is separate from that scheduled total. Room coordinates span x=0..38.333333 ft and y=2..34.5 ft. Thus the 40 ft test has 5.5 ft from the northernmost room-block edge to the test boundary, before wall, stair, hall, or construction coordination; the room-block Y span itself is 32.5 ft.
- Selected-D remains a 36 x 32 ft upper-wing test envelope and was not changed. The 38.333333 x 40 ft test is a sensitivity case derived from the M46 candidate, not an approved house dimension or a proven minimum.

## Limits

The route uses a sampled 4 ft corridor grid and nominal room-contact reservations. It does not represent actual doors/openings or swings, wall thickness, privacy, egress, finished interior dimensions, floor openings, stair/headroom geometry, structure, services, roof, site, code applicability, Revit placement or IFC. The search is deterministic but bounded and incomplete; its candidate is a room-block concept only. No claim of code compliance, structural safety, professional approval, or construction readiness follows.
