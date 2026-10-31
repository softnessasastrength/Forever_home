# M230 — Same-wall toilet/lavatory envelope comparison in west A

**Status:** bounded candidate comparison; no sink selected, no room assigned, and no installed fit established.

## Scope

The owner directed the primary search to keep west A available for M-06 and east B unassigned. M229 showed that the owner-selected American Standard 610AA001.020 current-SKU manufacturer plan envelope can fit a toilet-only spacing proxy inside gross A. M230 extends that same-wall abstraction to the eight already documented sink candidates in both plan orientations, using the same provisional 15 / 30 / 21 in screen documented by M120. It does not change selected-D or promote any candidate.

## Reproduce

Run in Windows PowerShell 5.1 from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m06_west_a_toilet_lavatory_pair_envelopes.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m06_west_a_toilet_lavatory_pair_envelopes.ps1 -OutputDirectory .local/revalidation/M230-replay-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m06_west_a_toilet_lavatory_pair_envelopes.ps1 -OutputDirectory .local/revalidation/M230-replay-2
```

The script pins the selected-D study, M120 current-SKU observations, M120 sink-pair inputs and owner A-protection decision by SHA256. It refuses assigned A/B/M-06, refuses selected sink candidates in the source snapshot, and verifies the 610AA plan dimensions and provisional spacing numbers.

## Results

All three runs pass **16/16** input/scope/geometry checks and reproduce both JSON outputs byte-for-byte.

- All 16 research sink/orientation rectangles clear the same-wall 30-in fixture-centerline spacing and the body non-overlap check.
- All 16 satisfy the plan-only 15-in WC-centerline-to-side-obstruction screen and fit inside gross west A under the assumed arrangement.
- The widest screen occupies 58.5 in of A's 62 in gross width, leaving **3.5 in** before wall thickness, finish layers, fitting tolerances or installation offsets. Every case needs 51.25 in of gross depth under this abstraction; A's source block is 137 in deep.
- Sink candidates remain research-only. Tresham's old candidate status snapshot predates its read-only inspection: M119/M150 record a near-nominal 24.0063 × 19.4998 × 34.625 in family-symbol bound, without host orientation or installed-fit verification. M230 includes that follow-up note in the Tresham cases.

| Artifact | SHA256 |
|---|---|
| `m230-checks.json` | `64D39E7A089902D91CF777AEAF28F09E6B1F3A3233D246B29D25069A6D43ADC4` |
| `m230-report.json` | `1859CED601E1982D41BAEE58A191F2766771729921FBCD8AC3A59DC590B0E686` |

## Assumptions and limits

The toilet is represented by its current-SKU manufacturer infographic plan callouts (19 × 30¼ in), not a Revit family or current installation drawing. Sink envelopes are the research-only plan rectangles in the pinned M120 candidate screen; they do not necessarily equal installed or usable clear envelopes. The assumed pair places both body rectangles along one hypothetical shared back line, centers the WC 15 in from a side boundary, spaces the sink centerline 30 in from the WC centerline, and adds a 21-in front strip to the deeper body.

This is **gross room-block containment only**. The narrow 3.5-in margin shows why A's 62-in gross width is not proof of a workable clear interior: actual wall build-ups alone could consume that reserve. No finished-face dimensions, faucet use zone, door leaf/operation, hall approach, privacy, water/waste/vent route, fixture connections or project-specific code applicability were evaluated. A and B stay unassigned; no code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows. Selected-D, RVT/IFC and source RFAs remain unchanged.
