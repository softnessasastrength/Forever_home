# M101 - Upper-suite room blocks beneath the hypothetical gable

Status: comparative geometry screen. The owner selected the 38⅓ × 40 ft case for continued exploration only. The shell, roof pitch, ridge direction, and eave datum remain unselected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m101_upper_suite_roof_height_ranges.ps1
```

The script hash-checks the M78 search against its manifest, confirms M83 binds the same M78 inputs and current selected-D source, and evaluates each of the seven room blocks against all six M83 roof options. The JSON stores provenance, checks, limitations and case summaries; the CSV contains all 42 room/roof/room-block height ranges. Outputs are deterministic and the output path must resolve inside the repository.

## Result

The source screen passes **9/9 checks** and produces 42 room/case rows. Independent runs to separate ignored directories produce identical output hashes: JSON `143DACB30BD4F40793B47BE225B70F5490DAF39987C4AF9F67B489CE274C6457`; CSV `FA0E1FB05ADA716759841ABDCC008E0DCC6C12A377C9701A48874D4DE24C0DE2`.

The two ridge directions place the low roof plane over different room blocks:

| M83 option | Lowest room block(s) | Minimum roof-plane rise above relative eave |
|---|---|---:|
| 8:12, ridge X | U-05 | 1.333 ft |
| 10:12, ridge X | U-05 | 1.667 ft |
| 12:12, ridge X | U-05 | 2.000 ft |
| 8:12, ridge Y | U-01, U-04 and U-05 | 0 ft |
| 10:12, ridge Y | U-01, U-04 and U-05 | 0 ft |
| 12:12, ridge Y | U-01, U-04 and U-05 | 0 ft |

This follows directly from the M78 room rectangles: U-05 begins 2 ft from the test shell's south edge, while U-01, U-04 and U-05 meet a test-shell side edge along the cross-slope axis when the ridge runs Y. It is a prompt to coordinate the room blocks, eave/wall location and roof orientation together. It is not a finding that any room has inadequate or adequate headroom, since floor and eave elevations, wall thickness, roof assembly and finished ceiling plane are unknown.

## Limits

- Reported values are ideal gable plane elevation above a relative eave across schematic room blocks; they are not clear interior heights.
- M83 uses zero-thickness surfaces without framing, overhang, dormers, gable wall, roof build-up or floor datum.
- No minimum headroom, CT code applicability, egress, structure, loads, drainage or construction detail is evaluated.
- The larger test shell is an exploration case, not an adopted building dimension. Selected-D and the Incoming RFAs remain unchanged.
