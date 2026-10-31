# M153 — Hall-edge M-06 search-window sensitivity

Status: an unassigned gross-block alternative, measured separately from the owner-selected pantry-side B window.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m153_m06_hall_adjacent_window.ps1 -OutputDirectory .local/revalidation/M153-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m153_m06_hall_adjacent_window.ps1 -OutputDirectory .local/revalidation/M153-b
```

The script hash-binds the owner-follow-up study, selected-D study, room program, owner decision and M120 envelope report. It derives an alternative position from existing block edges, while preserving the existing B rectangle and assignment status. The output directory must remain inside the repository.

## Findings

Both runs pass **12/12 checks** and reproduce byte-identical outputs:

- JSON SHA256: `c2bfd33883c2a73eb6e701bba87684a82c6129e1acdce3625ade6031bd4175d9`
- CSV SHA256: `f41d1e752c58b56bc4f03d6ce599f2fbd2ad84b5a7e982a2ae3a8b94e2393ea2`
- SVG SHA256: `0ced096fd7d47124ccc70099c92bf413c9e767a26ad400903c1b8d462ab8ed6e`

M06-H keeps the current pantry-side window's 10.3333 × 7 ft gross dimensions and is positioned at x=5.5 ft, y=16.1667 ft. Those coordinates are derived from the M-05 east edge plus 0.5 ft and the M-01 north edge plus 0.5 ft. It has a 6.5 ft projected edge overlap with M-05 across a 0.5 ft schematic gap, and a 10.3333 ft projected overlap with M-01 across that gap. It has no positive-area overlap with any current main-room or inherited stair/lift comparison rectangle. The SVG parses as XML.

This demonstrates a gross-block location that meets the arrival/hall-edge adjacency intent within the current test envelope. The tradeoff is that it is no longer the owner-selected pantry-side window. Keep M06-B first in research priority; M06-H is an unselected alternative sensitivity only.

## Limits

Projected contacts across a nominal block gap do not establish an opening, clear width, door swing, approach, privacy or walkable route. No product body, toilet/lavatory orientation, applicable clearance basis, rough-in, connection or service route is included. The source blocks, shell and stair/lift envelopes are comparison inputs, not approved design geometry. M-06 remains unassigned. No code, accessibility, egress, structural or construction determination follows.
