# M151 — M-06 pantry-side search-window adjacency

Status: reproducible room-block topology screen. M-06 remains unassigned.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m151_m06_hall_adjacency.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m151_m06_hall_adjacency.ps1 -OutputDirectory .local/revalidation/M151-replay
```

The script binds the owner-follow-up study, selected-D study, room program, owner direction and M120 gross-envelope report by SHA256. It reconstructs near-contact between proposed room rectangles, builds a block-adjacency graph, and writes a JSON report, CSV and SVG. The output directory must remain inside this repository.

## Findings

Both PowerShell runs pass **11/11 checks** and reproduce byte-identical artifacts:

- JSON SHA256: `4a82e292dbe8c1e96f7544174adeb2d6513de312ffd6632da1142d648157b628`
- CSV SHA256: `6e47bf34c7445e7c1be664f9f456eddeb95171520a1e04fa58d59bf8e59649f94`
- SVG SHA256: `30f1c8d6ac37fe796c9a8d0193681fbbff67dbd721ebc6f752d42befd77e88eb`

The current 40 × 42 ft owner-follow-up test envelope places the 124 × 84 in pantry-side M06-B search window against the pantry block and 0.5 ft from the dining block. It has **no direct block adjacency** to M-05 Entry / hall. The shortest adjacency chain is M-05 → M-01 Living → M-03 Dining → M06-B. The SVG parses as XML.

This exposes a mismatch between the requested arrival/hall-edge search priority and the current pantry-side window location. It does not show that a person can travel through living and dining: adjacency edges are not corridors, and this screen contains no openings, doors, clearances, circulation strips, fixtures, plumbing or service route. The owner-selected pantry-side window remains the first research window; any alternate placement needs a separately labeled test and must not silently replace it.

## Limits

The rectangles are schematic blocks with nominal 0.5 ft separation, not wall faces or clear room dimensions. This is not a door, circulation, accessibility, egress, code, service, Revit or IFC determination. The test shell is not an approved house footprint. Selected-D and all source RFAs remain unchanged. Keep M-06/B unassigned pending actual product geometry, an applicable clearance basis, entry/approach and plausible service routing.
