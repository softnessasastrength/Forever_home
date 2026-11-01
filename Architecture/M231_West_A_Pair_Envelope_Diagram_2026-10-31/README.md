# M231 — Visualize two M230 same-wall envelope examples

**Status:** explanatory diagram only; neither sink is selected and west A remains an unassigned search reservation.

## Owner direction

The owner confirmed: **keep west A primary** for the M-06 search. The diagram compares two M230 body-envelope examples inside the gross 62 × 137 in A block. It does not assign A or B, select a sink, or resolve the missing hall-to-living opening.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/draw_m06_west_a_pair_envelopes.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/draw_m06_west_a_pair_envelopes.ps1 -OutputDirectory .local/revalidation/M231-replay-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/draw_m06_west_a_pair_envelopes.ps1 -OutputDirectory .local/revalidation/M231-replay-2
```

The generator pins the M230 report SHA256 `1859CED601E1982D41BAEE58A191F2766771729921FBCD8AC3A59DC590B0E686`, selects nominal Tresham and the widest-screened TOTO Clayton case, marks both **unselected**, and parses the generated SVG as XML.

## Result and limits

All three runs pass **8/8** checks and reproduce both files byte-for-byte.

| Artifact | SHA256 |
|---|---|
| `m231-checks.json` | `721C04AD8D6D21B80DC6CCF6EC17DF9B8DC15AAC2EF670133BD39ABD3352538B` |
| `m231-west-a-pair-envelopes.svg` | `E57519854BDD0FBAE535C1F50367719971531657A380A9A131B653ECB3A205AA` |

The drawing shows the 610AA001.020 current-SKU manufacturer infographic plan envelope and two research sink envelopes aligned to one hypothetical shared back line. It labels the 15-in WC side-centerline, 30-in fixture-centerline and 21-in front-strip assumptions. Tresham is shown from nominal 24 × 19½ in plan dimensions; Clayton illustrates the 27 × 19⅝ in widest tested source case, which leaves 3½ in of gross A width before wall finishes. The line at 51¼ in marks the body-plus-front-strip depth screen; it is not a complete clear-floor-area boundary.

No actual walls, finished faces, fixtures as installed, door, hall approach, privacy, faucet zone, plumbing or service route are drawn. In particular, the 0.5-ft M-01/M-05 gap remains an unmodeled access issue. A remains the primary search area by owner direction, but A/B/M-06 remain unassigned. No code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.
