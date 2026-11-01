# M232 — West-A access-chain room-block sensitivity

**Status:** analysis-only comparison. M-01's hypothetical shift is not selected and is not a door, opening, or circulation design.

## Owner direction and scope

The owner directed: **“Keep west A primary.”** M232 asks whether a room-block adjacency chain to that protected search area can be formed by translating M-01 Living east by the measured 0.5 ft gap to M-05 Hall. It preserves M-01's 240 sf gross block and uses the existing M228 dining proposal. It does not change selected-D or assign A, B, M-06, or the dining proposal.

## Reproduce

Run from the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m232_west_a_hall_adjacency_sensitivity.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m232_west_a_hall_adjacency_sensitivity.ps1 -OutputDirectory .local/revalidation/M232-replay-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m232_west_a_hall_adjacency_sensitivity.ps1 -OutputDirectory .local/revalidation/M232-replay-2
```

The script pins SHA256 fingerprints for selected-D, M228, M215, and the separate owner A-priority addendum. It builds the route's 36-in swept rectangles in selected-D coordinates and checks room-block overlaps and edge contacts. Outputs are JSON; no Revit API or model mutation is involved.

## Result

All three runs pass **15/15** checks. Retained outputs and both replays are byte-identical.

| Artifact | SHA256 |
|---|---|
| `m232-checks.json` | `441E800CD299335D8F9BDAE42B09A75BA29ABBB3022BE7F7427AE5307C7B11DF` |
| `m232-report.json` | `41ADF2B56DF9A6B2FF318DC98609DD1DD9636445BB1C6DCDCE0C864C05100651` |

The 0.5-ft east translation yields 12 ft of M-05/M-01 shared block edge. With M228's unselected dining proposal retained, M-01 shares 10.833333 ft with dining, and dining shares 9.5 ft with west A. The moved living block keeps its 240 sf gross area, does not overlap the screened room blocks or any M215 36-in route swept rectangle, and remains 0.5 ft from the nearest route proxy.

## Limits and next evidence

Shared block edges do not prove wall openings, doors, a continuous walkable path, a private/public approach, fixture fit, or plumbing/service routing. Wall thicknesses, finishes, thresholds, furniture, and actual circulation are absent. This sensitivity moves M-01 outside the prior dining/porch movement scope and must not be promoted into selected-D without owner approval. A/B/M-06 remain unassigned. No code-compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows.
