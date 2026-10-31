# M246 — Replay the steep-gable massing comparison

**Status:** reproducibility check of the existing M83 analysis; no pitch, ridge direction, house dimension, or roof geometry is selected.

## Reproduction

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1 -OutputDirectory .local/revalidation/M83-resume-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1 -OutputDirectory .local/revalidation/M83-resume-b
```

Both runs pass **13/13** generator checks. The retained M83 artifacts and both isolated replays match byte-for-byte:

| Artifact | SHA256 |
|---|---|
| `roof-options.json` | `39A54E0660F2C206634B4D0921F015870FA0DF4A39A71CFE7EA71799AB383550` |
| `checks.json` | `0498973FE03FF7D80EE4CCCCBEEC99995AE6AC1C757FAC96D479D8CE9C20DFD6` |
| `roof-options.svg` | `9C5EA4DBBB297A530463774C610CE8D1C81E18E7FA1135A414BCDBC632981219` |

The JSON parses with six cases on the source-bound hypothetical **38.333333 × 40 ft** upper-shell outline. The SVG parses as XML. The 12:12 comparison rises 20 ft above the relative eave for ridge-X and 19.1667 ft for ridge-Y; these are idealized half-span calculations, not building heights. Selected-D remains SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`.

## Limits

This replay verifies deterministic files and arithmetic only. M83 represents two open, zero-thickness faces per option; it does not create native Revit Roof elements, roof assemblies, framing, gable walls, overhangs, or an occupied roof/attic. No site, eave datum, structural criteria, code applicability, or professional design is established. See the M83 report for the original Revit/IFC host evidence and its limitations.
