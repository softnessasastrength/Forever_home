# M145 - Owner-directed upper-suite interface opportunities

Status: comparison-only boundary arithmetic on the unchanged M132 layouts. Neither layout nor any room, door, wall, opening, or roof is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m145_upper_suite_interface_opportunities.ps1
```

The script binds the two M132 room layouts, their 25-check report, M37 sampled route evidence, selected-D upper-door matrix, owner follow-up decision, and room program by SHA256. It checks six room-to-room boundaries per layout and emits JSON plus separate room-link and sampled-route CSVs. Output paths outside the repository are refused.

Two isolated PowerShell 5.1 runs pass **15/15 checks** and produce byte-identical JSON/CSV artifacts. The report SHA256 is `180C16C2BD24B9B4481CA7A9296F22D21964C8D7B0A962D8E00FE4FC02713E61`; the room-link CSV SHA256 is `B87BC966189A9C2343EE5ADF0ADCF5D673B6751079FED25B44BF8E102CD1F86B`; the route CSV SHA256 is `3FD7277B864607AFBBD5ECABD91633A0C0A0FBE2D654C6B19253B6E5A7696D65`.

## Owner-directed access graph screened

- Public hall samples: U-01 primary, U-02 direct arrival, and U-04 guest; no public-side U-03 access is retained.
- Private sequence: U-01 ↔ C-PRIVATE ↔ U-02 ↔ U-03.
- Jack-and-Jill links: U-03 ↔ U-06 ↔ U-04.
- Primary-only bath: U-01 ↔ U-05.

The earlier selected-D D-U06 entry from U-03 to C-UPPER is present in the source door matrix but is superseded by the owner’s private-route-only direction. M145 excludes it without changing selected-D. U-02 → U-03 is owner-directed but absent from the selected-D matrix; M145 compares that new contact against the same **3.5 ft source reservation as a proxy only**, not as an approved opening size.

## Boundary opportunity and tradeoff

All twelve room-link contacts are separated by the existing 0.5 ft schematic wall-band convention and can contain the source 3.5 ft nominal reservation arithmetically. The narrowest link in M130-NE-19 is U-01/C-PRIVATE at 6.5 ft, leaving 1.5 ft at each end if centered. In M130-NE-24 that boundary is exactly 3.5 ft, leaving **zero** end margin; the arrangement has no spare length for jambs or any revised opening once physical wall geometry is introduced. NE-24 has a longer U-01/U-05 primary-bath boundary (10 ft vs 9 ft), leaving 3.25 ft vs 2.75 ft centered margin. This is a schematic tradeoff, not a preferred-layout finding.

M37's sampled grid reaches U-02 from its north side and U-04 from its west side in both cases. U-01 has east and north samples in NE-19, and east samples in NE-24. U-03 has no sampled public-side edge in either layout. These are reachable grid goal samples only; they do not locate or validate doors.

## Exclusions

- A reservation along a block boundary is not an opening, clear width, door leaf, swing, privacy screen, approach, or passage test.
- Actual wall assemblies, jambs, hardware, corridor widths, room use zones, egress, applicable code, accessibility, service routing, and Revit/IFC placement are not modeled.
- M130-NE-19 and M130-NE-24 remain hypothetical 38 1/3 x 40 ft room-block comparisons. U-03 stays private-route-only in the proposal. The selected-D source, RVT, IFC, and RFAs are unchanged.

This study makes no code-compliance, structural-safety, professional-certification, permit, or construction-readiness claim.
