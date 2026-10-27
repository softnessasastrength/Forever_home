# Direction D kitchen and dining room-size comparison

Status: **unselected comparison only**. This study compares the room-block sizes already carried by selected direction D with the older DD-012 / kitchen-and-dining target dimensions. It does not change the selected-D source, adopt either scheme, place rooms, or authorize architectural construction geometry.

## Reproduce

From the repository root, run Windows PowerShell 5.1:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/compare_direction_d_social_room_sizes.ps1
```

The script reads the selected-D study and documented requirements, records SHA256 fingerprints in `comparison.json`, and regenerates `comparison.json`, `comparison.svg`, `selected-d-test-block-plan.svg`, `older-target-plan.svg`, and `checks.json`. The two per-scheme SVGs draw the independent room envelopes and illustrative island/table test blocks; they do not imply room adjacency. Its checks fail closed if source dimensions, documented inputs or arithmetic no longer match the encoded acceptance checks. The generated timestamp varies; the geometric results do not.

## Evidence

The 13 ft 6 in kitchen section is the source-documented minimum arithmetic chain: 24 in perimeter base + 42 in clear aisle + 48 in island + 42 in clear aisle + 6 in half wall. With both aisles at the published preferred 48 in, that chain becomes 14 ft 6 in.

| Scheme | Kitchen block | Minimum chain remainder on long / short axis | Preferred chain remainder on long / short axis | Dining block | Table envelope: minimum / preferred |
|---|---:|---:|---:|---:|---|
| Current selected-D test blocks | 17 ft 4 in × 16 ft | +46 / +30 in | +34 / +18 in | 11 ft 4 in × 14 ft | Fits / fits |
| Older documented targets | 14 ft × 12 ft | +6 / −18 in | −6 / −30 in | 11 ft × 10 ft | Fits / does not fit |

The dining envelope uses the documented 36 × 60 in table plus 36 in minimum or 42 in preferred clearance on each side. Its corresponding rectangles are 9 × 11 ft and 10 × 12 ft. The older 11 × 10 ft target accommodates the minimum rectangle when oriented with 11 ft along the table's 11 ft axis; it does not accommodate the preferred rectangle. The selected-D dining test block accommodates both arithmetic envelopes.

The kitchen specification calls for an 8 ft half wall and at least a 6 ft clear opening where the connection is not fully open. Their contiguous edge arithmetic totals 14 ft. The older 14 × 12 ft kitchen has exactly 14 ft on its long axis; this establishes only possible dimensional length, not an actual shared living-room edge. Selected-D's block has more length on either axis, but adjacency and half-wall placement remain unmodeled.

The documented 36 in route from the dining table edge to the porch door is **not verified** in either scheme: the study has no selected porch-door position, leaf swing, furniture placement or route geometry. Likewise, the clear-room status of either room-block size, cabinet/appliance projections, seated stool occupation, finish build-up and tolerances remain unresolved. The schematic comparison is not a code, accessibility, structural or construction review.

## Acceptance result

The latest generated `checks.json` records **8/8** source and arithmetic checks passing. These checks verify transcription, documented input presence, envelope arithmetic, source fingerprint integrity and non-claims; they are not a finding that either candidate is a complete or buildable plan. No room-size choice is inferred from the numbers. The 14 × 12 ft target is particularly constrained for the selected appliance-free island and half-wall arrangement; the owner must choose whether to retain the larger D test blocks or explicitly develop a revised compact layout before walls and floors are considered.
