# M36 — steep-gable ridge orientation screen

Status: **two parametric orientation comparisons; no selected pitch or roof geometry**.

The owner requested a steep traditional gable and identified Connecticut for code research. The study uses only the existing 40 × 42 ft owner-follow-up **test envelope** to compare two ridge directions. It creates no roof solid and does not choose a pitch, ridge elevation, overhang, assembly or structure.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m36_roof_orientation_study.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m36_roof_orientation_study.ps1 -OutputDirectory '.local/revalidation/m36-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m36_roof_orientation_study.ps1 -OutputDirectory '.local/revalidation/m36-b'
```

Compare the `roof-study.json`, `checks.json`, `ridge-orientations.svg` and `manifest.json` hashes from both scratch runs. The generator fingerprints owner-study/design/code sources and rejects output directories outside the repository.

## Comparison

| Option | Ridge direction in the test frame | Transverse span | Half-run | Rise formula |
|---|---|---:|---:|---|
| A | Parallel to 42 ft side | 40 ft | 20 ft | `20 ft × pitch ratio` |
| B | Parallel to 40 ft side | 42 ft | 21 ft | `21 ft × pitch ratio` |

At an identical eventual pitch ratio, Option B has 1 ft more half-run and 5% more rise than A. The test envelope has no northing, site orientation or approved footprint, so this comparison does not choose the ridge direction. Pitch remains deliberately unset.

## Connecticut research and limits

The linked [preliminary Connecticut roof-code note](../../Research/Connecticut_Roof_Code_Research_2026-10-28.md) records official DAS adoption status as checked on 2026-10-28. DAS identifies the 2022 CSBC as current for permit filings from October 1, 2022; its adoption page says the planned 2026 effective date is delayed pending Legislative Regulation Review Committee approval. The adopted IRC amendment refers residential roof design to its tabled snow load. Separate IBC amendments address sloped-roof snow calculations and supporting snow/drift data; which path governs this future house must be confirmed for its classification, municipality and filing date.

A steep roof does not by itself resolve snow, drifting, wind, roof intersections, drainage, overhang, framing or attachment. The town/municipality, site, permit timing, terrain/exposure, adjacent-roof conditions and professional roof design remain open. No code-compliance, structural-safety, certification, permit or construction-readiness claim is made.
