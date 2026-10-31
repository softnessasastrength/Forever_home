# M227 — Selected-D west A hall-adjacency audit

**Status:** selected-D room-block topology reproduced; no public entry, door or route is established.

## Reproduce

Run from the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m227_selected_d_m06_a_hall_adjacency.ps1
```

The script requires the selected-D study to match SHA256 `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`, rejects assigned A/B source windows, and writes the JSON report under `artifacts/`.

Two independent replays pass **8/8** source/scope checks and reproduce the retained report byte-for-byte (SHA256 `7B1E21F4C60553A8369B9E7E3D7B5B1770DAF5B2AD652F9D72CCBA9B3184E240`).

## Finding

- West A (`M06-A`, 58.99 sf gross) has **no exact shared edge** with M-05 Front Arrival / Hall and no path through exact coincident room-block edges.
- It has a coincident 11.4167-ft edge with M-03 Dining.
- A graph that treats separations of at most 0.5 ft as *adjacency sensitivities* finds the shortest chain `M-05 → M-01 Living → M06-A`, crossing two 0.5-ft (6-in) gaps. Those gaps are not openings, door clearances or walkable route widths.
- East B (92.17 sf gross) remains unassigned. The script is pinned to selected D; it does not change the file or choose a replacement room block.

This conflicts with the owner-selected first-fit intent of placing M-06 at the arrival/hall edge. A remains the owner-protected M-06 search window, but its public approach cannot be treated as solved by this room-block study. A focused owner question is pending on whether to keep A primary and test a connection or compare a separate hall-edge proposal while retaining A as fallback.

## Limits

The selected-D blocks have no modeled wall thickness, opening, door, swing, threshold, furniture, privacy screen or route. No room is assigned, and no toilet/lavatory fit, plumbing, service route, code compliance, accessibility, structural or construction conclusion follows. Keep A and B unassigned until the product geometry, applicable clearance basis, actual door/approach and plausible service route work together.
