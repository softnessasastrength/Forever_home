# M233 — Owner-directed M-01 six-inch translation study

**Status:** source-bound visual comparison of an unselected room-block sensitivity. Selected-D was not edited.

## Owner direction

After M232, the owner answered: **“Test 6 in east move.”** The separate decision record authorizes analysis of the 0.5-ft east translation only. It does not select that layout, define a door/opening, or change the selected-D source.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/draw_m232_m01_six_in_sensitivity.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/draw_m232_m01_six_in_sensitivity.ps1 -OutputDirectory .local/revalidation/M233-replay-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/draw_m232_m01_six_in_sensitivity.ps1 -OutputDirectory .local/revalidation/M233-replay-2
```

The script pins selected-D, M215, M228, M232, and the owner's M-01 test-direction addendum. It draws source room blocks, protected west A, unassigned east B, the M228 dining proposal, the M215 centerline proxy, and the moved M-01 outline. SVG is parsed as XML; no Revit API is used.

## Result and limits

All three runs pass **10/10** checks and produce byte-identical SVG/check JSON files.

| Artifact | SHA256 |
|---|---|
| `m233-checks.json` | `F3C51A710E69359AE6DF19695C6EA5C214D6B45F1793E045F44A0CC2FACDC151` |
| `m233-m01-six-inch-sensitivity.svg` | `7D3F97953783EDDB726761495F122851C289A4FFB0ED922F1FF76C39C5205113` |

M232's comparison shows a 12-ft M-05/M-01 block edge after the shift and a block-adjacency chain through the M228 dining proposal to west A. M-01 retains 240 sf gross area; the screened blocks do not overlap, and the M215 route proxy remains 0.5 ft away at its nearest point. Dashed source geometry and solid study geometry are distinct in the SVG.

This is room-block geometry only. It does not establish physical walls/openings, door placement or swing, route width at transitions, actual clearances, privacy, fixtures, or service routing. A/B/M-06 remain unassigned. No code-compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows.
