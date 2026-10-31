# M241 — M-01 / hall / kitchen interface audit

**Status:** completed analysis-only follow-up to the owner's six-inch east-translation test. No room or opening is selected; selected-D remains unchanged.

## Reproduce

Run in Windows PowerShell 5.1 from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m241_living_kitchen_interface.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m241_living_kitchen_interface.ps1 -OutputDirectory .local/revalidation/M241-replay-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m241_living_kitchen_interface.ps1 -OutputDirectory .local/revalidation/M241-replay-2
```

The script hash-pins selected-D, M228 dining, M232 translation, and the owner's six-inch test direction. It writes deterministic JSON and checks files only to the requested output directory.

## Result

All three PowerShell 5.1 runs pass **12/12** checks. `m241-report.json` and `m241-checks.json` match byte-for-byte across the retained package and two replays.

| Interface measure | Selected-D source blocks | M-01 + 6 in east |
|---|---:|---:|
| M-01 to M-05 horizontal gap | 0 ft 6 in | 0 ft; 12-ft shared edge |
| M-01 to M-02 horizontal gap | 5 ft 4 in | 4 ft 10 in |
| M-05 to M-02 horizontal gap | 0 ft 6 in | 0 ft 6 in |
| M-01 to M228 dining shared edge | 11 ft | 10 ft 10 in |

The move closes the schematic living/hall gap and improves the hall-to-living block contact. It reduces the living/dining shared block edge by 2 in. It does not create direct living/kitchen block contact; M-05 remains in the intervening room-block band. The owner-preferred fully open connection cannot be judged from these rectangles.

## Limits

These are room-block coordinate comparisons, not wall faces or clear dimensions. The six-inch bands are unassigned gaps in this source and must not be interpreted as wall thickness. No wall, opening, door, circulation width, furniture, fixture, or service is modeled. M228 dining is still a proposal. M-06 and A/B remain unassigned. This is not a code, accessibility, structural, permit, professional, or construction-readiness determination.

Retained output hashes are recorded in `PLAN.md` and `PROGRESS.md` after verification.
