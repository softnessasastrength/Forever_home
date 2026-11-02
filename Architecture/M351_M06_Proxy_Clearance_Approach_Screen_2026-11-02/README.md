# M351 — M-06 proxy clearance and approach screen

**Status:** complete as a source-pinned comparison screen; no fixture, room, door, route, or code result is selected.

## Purpose

Carry the existing native M-06 proxy evidence into the current Selected-D B gross window and make the remaining promotion gates machine-readable. The screen uses the measured TOTO Nexus toilet proxy and Evolution lavatory evidence from M344, the current Selected-D toilet/lavatory gross-pair replay, and the repository's provisional 15/30/21-inch residential screening basis.

## Reproduction

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_m06_proxy_clearance_approach.ps1
```

The retained output is `.local/revalidation/m351-m06-proxy-clearance-approach.json` (ignored). It passes 9/9 source and gate checks.

## Result

- Selected-D SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`.
- The current Selected-D pantry-side B gross window remains **158 × 84 in** and unassigned.
- M344 proxy family hashes remain pinned; neither proxy is promoted to the owner-selected fixture.
- The current gross toilet/lavatory screen remains a 16-case comparison, not a room fit.
- Exact owner-product geometry, finished-face clearance, door/approach, service route, and B assignment remain **false/open**.

This screen deliberately separates a passing source/gross comparison from the unresolved architectural gates. It does not establish code compliance, accessibility, structural safety, professional approval, permit readiness, or construction readiness.
