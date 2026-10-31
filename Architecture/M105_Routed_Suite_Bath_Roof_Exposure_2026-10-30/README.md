# M105 - Roof-edge sensitivity in route-ranked upper-suite layouts

Status: comparison of five archived M78 layouts only. No candidate move, upper-shell dimension, pitch or ridge direction is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/compare_m105_routed_suite_bath_roof_exposure.ps1
```

The tool verifies M78/M83 fingerprints, room count, room areas, shell containment, non-overlap and the archived route results. It evaluates the minimum/maximum ideal roof-plane rise over U-05's full schematic block for all six M83 roof options. It writes 30 roof/candidate rows plus source-bound JSON.

## Comparison

All five retained layouts have sampled hall access to U-01, U-02 and U-04, north-side U-02 access, no U-03 public-side reach, and a 90 sf U-05 block. M78 tested 457 complete room packings; these are only the archived five highest-ranked public-access records, not an exhaustive roof optimization.

At 8:12, minimum plane rise above the relative eave across U-05 is:

| Archived candidate | U-05 x, y (ft) | U-05 block (ft) | Ridge X | Ridge Y | Minimum of both axes |
|---|---:|---:|---:|---:|---:|
| M78-TOP-01 | 0, 1 | 9 × 10 | 0.667 ft | 0 ft | 0 ft |
| M78-TOP-02 (M78 winner) | 0, 2 | 10 × 9 | 1.333 ft | 0 ft | 0 ft |
| M78-TOP-03 | 0.5, 1 | 9 × 10 | 0.667 ft | 0.333 ft | 0.333 ft |
| M78-TOP-04 | 1, 1 | 9 × 10 | 0.667 ft | 0.667 ft | 0.667 ft |
| M78-TOP-05 | 1.333, 1 | 9 × 10 | 0.667 ft | 0.889 ft | 0.667 ft |

M78-TOP-05 is the most balanced of these five against the two ridge directions: compared with M78's current winner it raises the U-05 block's minimum relative roof plane for ridge Y from 0 to 0.889 ft, while reducing the ridge-X value from 1.333 to 0.667 ft. Compared with TOP-04 it holds the X value and raises Y from 0.667 to 0.889 ft. This is a room-block roof-edge trade-off, not a bathroom fixture/headroom result or recommendation. The U-05 block remains 90 sf and retains the source route proxy.

The side-by-side plan is available as [routed-bath-roof-alternative.svg](routed-bath-roof-alternative.svg). Two independent PowerShell 5.1 runs pass **13/13 checks**, the SVG parses as XML, and JSON/CSV/SVG outputs match the checked-in files. SHA256: JSON `424312A30240E1252A39B0FD1BF567F58BB9B4BEA2B4A04D41B725220AF43D19`; CSV `BF4278BB1DB471CA65EEE9BC8EBBD07D42042C933B25F41D04BDBA104FD90BAA`; SVG `39A55B56E59922E07E2096E0E22AB6AC794C5913536A976A0336CD84465D39F3`.

## Limits

- Rises are measured above an unassigned eave plane, not above finished floor or ceiling.
- The bath check covers the whole room rectangle. No toilet, tub, showerhead, lavatory, use zone, swing, wall, service route or applicable clear height is modeled.
- Hall routes are M78 grid samples and nominal room-contact links, not doors or accessible clear paths.
- A bounded search can omit better layouts; no choice follows without a fixed ridge direction, floor/eave datum, roof build-down and bath fixture plan.
- Selected-D and incoming family sources remain unchanged.
