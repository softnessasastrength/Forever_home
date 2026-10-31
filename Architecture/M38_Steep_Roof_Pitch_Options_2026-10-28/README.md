# M38 - illustrative steep-gable pitch comparison

Status: **six massing comparisons; no pitch or roof geometry selected.** The owner asked to explore a steep traditional gable and use Connecticut for code research. This study makes candidate pitch assumptions explicit rather than silently promoting one into the design.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m38_steep_roof_pitch_options.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m38_steep_roof_pitch_options.ps1 -OutputDirectory '.local/revalidation/m38-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m38_steep_roof_pitch_options.ps1 -OutputDirectory '.local/revalidation/m38-b'
```

The generator fingerprints selected D, the owner-follow-up study/decision and current Connecticut roof-code research. It emits JSON/check/SVG/manifest artifacts and rejects output paths outside the repository.

## Illustrative cases

The existing 40 x 42 ft **test envelope** has two ridge directions. Option A runs the ridge parallel to the 42 ft side, giving a 40 ft transverse span and 20 ft half-run. Option B runs parallel to the 40 ft side, giving a 42 ft span and 21 ft half-run. At any identical pitch ratio, B raises the ridge 5% more above its future eave.

The script compares explicitly hypothetical 8:12, 10:12 and 12:12 ratios. Rise above eave is `half-run × rise/run`; the two sloped-plane area excludes all overhangs and roof intersections. The modeled rises are:

| Comparison | 8:12 | 10:12 | 12:12 |
|---|---:|---:|---:|
| A, 20 ft half-run | 13.33 ft | 16.67 ft | 20 ft |
| B, 21 ft half-run | 14 ft | 17.5 ft | 21 ft |

The corresponding theoretical two-plane surface areas are about 2,019 sf, 2,187 sf and 2,376 sf for either ridge orientation, or roughly 20%, 30% and 41% above the 1,680 sf projected test footprint. The SVG now reports both rise and surface area beside each case. This is geometric area only, not a roofing takeoff, material order or cost estimate; the source footprint is still a test envelope.

These are substantial ridge rises. The 12:12 case is 45 degrees. That does not establish how the house will look or fit: eave and floor datums, exterior elevations, site orientation, roof intersections, attic/ceiling geometry and the final building footprint are unknown. All three pitches remain **comparison proposals only**.

## Connecticut code context and limits

See [Connecticut roof-code research](../../Research/Connecticut_Roof_Code_Research_2026-10-28.md). The 2022 CSBC adoption and pending successor date are recorded from official DAS sources. Connecticut's roof-snow provisions do not allow this schematic to assume a steep slope removes the design snow load. Applicable code path, municipality, permit date, ground snow data, drifting, wind exposure and adjacent roofs remain unknown. Code applicability and project compliance cannot be established from a state name alone.

The official DAS status was rechecked on 2026-10-29 and remains as recorded in the dated addendum to the research note. No project-specific code path or roof load follows from that statewide status.

The run passes 12/12 arithmetic/provenance/non-claim checks; two scratch runs produce byte-identical JSON, checks, SVG and manifest (hashes are in `PROGRESS.md`). This is no roof solid, load calculation, framing design, code review, permit review or construction documentation. No structure or architectural dimension is adopted.
