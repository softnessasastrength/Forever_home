# M243 — Route start sensitivity beside the hypothetical moved kitchen

**Status:** analysis-only comparison. Neither the M242 westward kitchen translation nor either route-start shift is selected.

## Reproduce

Run in Windows PowerShell 5.1 from the repository root. Each replay needs a fresh scratch prefix because the upstream M215/M213/M186 generators refuse to overwrite occupied output folders.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m243_route_start_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M258-m243-doc-run1 -ScratchPrefix M258-doc-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m243_route_start_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M258-m243-doc-run2 -ScratchPrefix M258-doc-b
```

The script regenerates M215 and its pinned M213/M186 route source, then tests the M242 kitchen rectangle in M215/M186's local frame using the M228 origin. It changes only the route's start x-coordinate. Swept 36-in rectangles include intermediate-turn boxes plus explicit start and end caps. Source hashes include the selected-D source, M242 candidate, M228 transform and M215/M213/M186 generators and retained M215 result.

## Result

All three runs pass **14/14** checks and reproduce both JSON files byte-for-byte. Checks SHA256: `05a442256502a5652d03e6d6ae614641858c6b3f4c6fa6790990b4563ddae21b`. Report SHA256: `e2b25a46d7d17a5b6f97184aeb8a20286bc0f79b4a9b90ca0c5a0b920d28c8ad`.

| Start shift west | Route length | Gap to shifted kitchen | Minimum gap to all tested obstacles | Intersections |
|---:|---:|---:|---:|---:|
| 0 in | 34 ft | −2 in; 0.5 sf endpoint-cap overlap | 0 in | 1 |
| 3 in | 33.75 ft | 1 in | 1 in | 0 |
| 6 in | 33.5 ft | 4 in | 3 in | 0 |

The 6-in route adjustment is one existing 0.25-ft grid increment beyond the 3-in sensitivity and clears the moved kitchen by 4 in while preserving a 3-in minimum to the other pinned proxies, including the analytical west-A reserve and porch wall. This is a single route adjustment, not an exhaustive search.

## Limits

The 3-in obstacle separation is M215's analysis screen, not a verified code or accessibility rule. Route rectangles, M06 reservation, room blocks, kitchen and porch geometry are schematic. The path does not define physical openings, doors, wall finishes or services; no RVT geometry was generated. The 0.25-ft grid is a search resolution, not a design dimension. Selected-D is unchanged; west A remains protected, east B and M-06 unassigned. No code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.
