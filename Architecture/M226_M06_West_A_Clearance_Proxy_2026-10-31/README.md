# M226 — West A toilet-only clearance proxy

**Status:** reproducible lower-bound comparison; no room assigned and no selected-product fit established.

## Owner scope

The owner directed west A to remain protected for M-06, with east B left unassigned. This study asks only whether a rectangular toilet-body-plus-minimum-spacing box can fit inside the gross west A search window under a clearly labeled predecessor-product proxy. It does not choose A, B, a toilet orientation, or any room geometry.

## Reproduction

Run under Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m06_west_a_predecessor_clearance.ps1
```

The script pins the selected-D source and the existing predecessor envelope report by SHA256. It writes `artifacts/m226-west-a-clearance-proxy.json` deterministically.

## Result

West A is a 62 × 137 in **gross unassigned room-block gap**. The script applies 2021 IRC preliminary residential clearances of 15 in from the water-closet centerline to each side obstruction and 21 in in front, consistent with R307.1/P2705.1 as adopted under the current published 2022 Connecticut State Building Code for qualifying residential scope.

Using the **unverified predecessor 211AA104.020** rectangular 19 × 30.25 in envelope, both plan orientations fit this toilet-only lower-bound box inside gross A:

- 0°: 30 × 51.25 in required envelope; 32 in gross-width and 85.75 in gross-depth remainder.
- 90°: 30.25 × 40 in required envelope; 31.75 in gross-width and 97 in gross-depth remainder.

The retained JSON and two isolated replays are byte-identical (SHA256 `C88C5C15ED170AB30A399828E9173477F06FDAF98EE6655372F1643FD8AC42DA`).

These numbers do not describe the selected current SKU 610AA001.020. The manufacturer page's linked PDFs identify older 211AA-family products, as recorded in [M225](../../Research/M225_M06_Exact_SKU_Resource_Audit_2026-10-31.md). The displayed containment therefore establishes only that the **proxy box** is inside the *gross* comparison rectangle.

## Explicitly not evaluated

- Exact current-SKU toilet geometry, lavatory, or 30-in center-to-center spacing to an adjacent fixture.
- Finished wall faces, wall thickness, rough-in, door leaf/swing, door operation, hall arrival/approach, privacy, or service routes.
- Whether A actually adjoins the selected public arrival/hall approach, whether its gross gap can become a room, or whether B can be assigned.
- Project-specific code applicability, accessibility requirements, or code compliance.

No selected-D source, RVT, IFC, RFA, room assignment, or remote state changed. Keep A and B unassigned until exact product geometry, applicable clearance basis, a real door/approach, and plausible service routing can be coordinated together. No code, accessibility, structural, professional, permit, or construction-readiness conclusion follows.
