# M133 — Primary bath product-envelope fit

**Status:** proposal-only geometric test. Neither shell, U-05 block, product, layout nor door is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m133_primary_bath_candidate.ps1
```

The analyzer writes `m133-report.json`, `m133-checks.json`, `m133-fixture-layouts.csv` and `m133-plan.svg`. A separate replay may use an ignored output directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m133_primary_bath_candidate.ps1 -OutputDirectory .local/revalidation/M133-repeat
```

## Source-based proposal

The study places nominal product envelopes in both unchanged M130 U-05 blocks from M132, using local origin `(0,0)` at the room's southwest corner:

| Item | M130-NE-19 (108 x 120 in) | M130-NE-24 (120 x 108 in) |
|---|---:|---:|
| 610AA toilet comparison envelope | west wall, `(0,20)`, 30 1/4 x 19 in | west wall, `(0,20)`, 30 1/4 x 19 in |
| KOHLER Tresham K-2844-4-0 nominal envelope | west wall, `(0,47.5)`, 19 1/2 x 24 in | west wall, `(0,47.5)`, 19 1/2 x 24 in |
| KOHLER Entity K-26108-LA-0 nominal plan envelope | centered on north edge, `(24,88)`, 60 x 32 in | centered on north edge, `(30,76)`, 60 x 32 in |
| Selected-D primary-bath nominal reservation | centered on south edge, `x=33..75`, 42 in wide | centered on south edge, `x=39..81`, 42 in wide |

The toilet faces east. Its centerline is 29 1/2 in north of the south room edge; the Tresham centerline is 59 1/2 in north, giving the prior explicit 30-in layout assumption. A 30-in-wide side-clearance screen (15 in from the WC centerline) and a 21-in-deep frontal strip are checked against the other fixture bodies. Both fit inside the gross room bounds without fixture-body overlap. The checker also confirms that no fixture body intersects the reserved south-wall line segment; it does not test a door approach or passage. The tub is centered on the north edge. These are only plan-envelope calculations.

The 610AA dimensions come from the product infographic already recorded in the M-06 research; the toilet still has no exact-SKU Revit solids. KOHLER lists the Tresham as 24 x 19 1/2 x 34 5/8 in nominal in its collection sheet and exposes a direct product-family RFA URL. That family has been downloaded without sign-in to the ignored intake quarantine, SHA256 `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`; its category, type data, parameters and physical geometry have not yet been inspected in Revit. KOHLER lists the Entity bath as 60 x 32 x 15 3/4 in overall with integral apron/flange for alcove installation; its family was subsequently retrieved under M134 to ignored quarantine, SHA256 `DBE1D03ACD1C4DBB5DF2B670CDF87A2E5ADC74E35EF4FEC46382EE0A7AB5B948`. Both manufacturer families remain uninspected, and the bath family drain hand is unverified.

## Verification

- Windows PowerShell 5.1: **12/12 checks pass** across both source layouts.
- A second run to `.local/revalidation/M142-M133-repeat/` matches all four generated artifacts byte-for-byte:
  - checks JSON: `4DBB60C6203E09C11ED68530932ADF6FDC5EA70984A5919D44F588A5E3507672`
  - fixture-layout CSV: `0628D6FA430CD39001371650158AC3190AD289601C06947D984050EA067A7A14`
  - plan SVG: `7DC8AFCB6C74648862DEE931CAFA79B160F470832E44A28851B960C7684665DA`
  - report JSON: `91B11F7AA940D19279E484603B00708FC4773F5B014459EA3FD6C4794BE8A863`
- SVG parses as XML. Inputs are SHA256-pinned to selected-D, M132, the M-06 sink envelope data and clearance note, the upper-suite product research note, and `Research/M06_Toilet_Options_2026-10-27.md` (SHA256 `7BDAE9F61FD7A8855DC8A18DEE03F09CFA9FC40F8FCA4733367D8A9389A74B89`). The analyzer now records the exact-SKU toilet source note directly; its 19 x 30 1/4 in plan envelope remains an infographic-based comparison, not verified Revit solids.

## Limits and next gate

The 3 1/2-ft value is a nominal topology reservation within the existing 0.5-ft M37 wall-band convention. It is not a selected door, opening dimension, leaf, swing or passage. The study has no actual wall thickness/finish, bathing access/use envelope, lavatory use envelope, threshold or approach, door operation, plumbing rough-in, water/waste/vent route, roof datum or finished headroom. The 15-in side and 21-in front values are preliminary project research screens whose local adoption and applicability are unresolved; the 30-in centerline spacing is a study assumption. No code, accessibility, structural, professional-approval, Revit-placement or IFC conclusion follows. U-05 remains an unassigned room-block proposal, and M-06/B remains unassigned.

Next: inspect both quarantined KOHLER families read-only in Revit when the host window can be observed safely; then add a physical doorway and fixture approach only from documented source constraints. Do not save changes to the source families or alter selected-D.
