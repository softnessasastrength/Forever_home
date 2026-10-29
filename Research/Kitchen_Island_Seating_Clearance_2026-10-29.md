# Island seating reference screen — 2026-10-29

Status: **owner-spec comparison to a published planning recommendation; no island revision or stool placement selected.**

## Source inputs

- The owner-selected island target is 8 ft × 4 ft. The kitchen specification calls for two stools at 24–26 in seat height and a 12 in dining-side overhang.
- `Decisions/Kitchen_Island_Finish.md` records a 34-1/2 in base cabinet plus 1-1/4 in counter, totaling 35-3/4 in. The owner accepted that arithmetic result as a nominal 36 in counter for study purposes.
- NKBA's published [Kitchen Planning Guideline 9](https://media.nkba.org/uploads/2022/05/Kitchen-Planning-Guidelines.pdf) recommends 24 in of width and 15 in of knee-space depth for each diner at a 36 in high counter. The guide separately identifies these as recommendations; this is not a code or accessibility finding.

## Measured arithmetic

Two 24 in seating-frontage allowances use 48 in of the island's 96 in dining-facing edge, leaving 48 in of frontage outside those nominal allowances. That checks only recommended linear frontage, not actual stool bodies, end panels, spacing comfort or room fit.

The documented 12 in seating-side overhang is 3 in less than the NKBA 15 in knee-space recommendation **if** the clear knee depth equals the overhang. The actual clear depth cannot be confirmed without a dimensioned section showing cabinet face, supports, panels, counter edge and any obstruction. Do not silently increase the overall island depth or reduce its cabinet depth to reconcile the comparison.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m72_island_seating_clearance.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m72_island_seating_clearance.ps1 -OutputDirectory '../.local/revalidation/M72-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m72_island_seating_clearance.ps1 -OutputDirectory '../.local/revalidation/M72-b'
```

The generator fingerprints the kitchen specification and owner island decision, emits a JSON calculation record and SVG comparison, runs nine input/non-claim checks, and rejects output paths outside the repository.

## Open design gate

The owner may retain the 12 in overhang as a preference, or direct a detail study to provide 15 in of clear knee depth while preserving and rechecking the 8 ft × 4 ft overall target. In either case, the actual island section/support, selected stool model and body, stool pull-back zone, and combined kitchen/dining/living/porch circulation remain to be resolved. No code compliance, accessibility, product fit, structural/support or fabrication conclusion follows from this screen.
