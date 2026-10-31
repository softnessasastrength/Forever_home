# M162 - Connecticut sloped-ceiling thresholds for M158 room blocks

**Status:** source-bound symbolic geometry sensitivity. Neither M158 candidate, the 38 1/3 × 40 ft exploration shell, roof option, floor/eave datum, nor ceiling build-down is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m162_m158_ct_ceiling_thresholds.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m162_m158_ct_ceiling_thresholds.ps1 -OutputDirectory .local/revalidation/M162-repeat
```

The script verifies M158 search, manifest, candidate archive and independent audit; M83 roof options; M159's link from M158 to those roof options; the Connecticut research note; Room Program; and selected-D source. It produces `ct-sloped-ceiling-thresholds.json` and `ct-sloped-ceiling-thresholds.csv`.

Both Windows PowerShell 5.1 runs pass **16/16** checks and produce 48 room/candidate/roof rows. JSON SHA256 is `6C8087DAC2AA0297953BB4AA8D6D87F2DF22FA06F4E46348EC31DF6AF0D549A2`; CSV SHA256 is `CF487F1FB539E6A0AB605F58F07E4C3F8B47761669C7DC278B89FC5F0749D903`. The two outputs match byte-for-byte. The report contains each room's program use but makes no code classification, threshold pass/fail, roof selection, or code-applicability decision.

## Method

For each M158 block U-01 through U-04 and all six ideal gable options in M83 (8:12, 10:12 and 12:12 with ridge X or Y), the script computes the minimum, median and maximum zero-thickness roof-plane rise over that room's cross-slope interval. It finds the median with deterministic bisection on the room rectangle's uniform area distribution and checks that the result bisects the modeled area.

The conditional screen carries forward Connecticut 2022 CSBC amended 2021 IRC R305.1's sloped-ceiling language: at least 5 ft over the required floor area, with at least half of that required area at 7 ft. For arithmetic only, this study treats the entire modeled rectangle as the required-floor-area proxy. It expresses the needed effective eave ceiling height as:

```text
H_eff = (z_eave - z_finished_floor) - b_eave
H_eff >= max(5 ft - minimum_ideal_rise, 7 ft - median_ideal_rise)
```

Equivalently, each row records `z_eave - z_finished_floor >= threshold + b_eave`. All three variables remain unknown. U-02 remains a boutique/walk-in and is not counted as a legal bedroom by the room program; it is included as a room-block sensitivity because its final code classification and use remain unresolved. U-03's sleeping-room status also remains unverified.

## Finding

For the three bedroom-capable blocks U-01, U-03 and U-04, the largest conditional threshold is **5 ft** in every tested ridge/pitch case. In ridge-X cases U-01 and U-04 reach opposite ideal eaves; in ridge-Y cases U-03 and U-04 reach the west ideal eave. Thus at least one 5 ft full-block proxy controls each comparison. Steeper planes improve relative rise in other blocks, but do not remove the eave-contact constraint in these M158 arrangements.

This does not select a 5 ft eave ceiling or show a workable roof section. Negative per-room algebraic thresholds are not interpreted as physical below-floor eaves. The floor/eave separation, finished-ceiling build-down, wall/eave location, roof assembly, dormers, room classification, actual required floor area, and permit applicability remain unresolved. No condition is evaluated as passing or failing.

## Authority and limits

The official [2022 Connecticut State Building Code with Errata #1](https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf) contains the amended 2021 IRC R305.1 text. Connecticut DAS lists the [2022 CSBC among current code resources](https://portal.ct.gov/das/services-for-agencies-and-municipalities/safety-codes-and-inspections) and identifies its adopted model codes on the [adoption-process page](https://portal.ct.gov/das/knowledge-base/articles/ctbuys/safety-codes-and-inspections/connecticut-state-building-codes-adoption-process); the permit site, municipality, formal room classification and applicable code cycle for this project are unknown. The dated [Connecticut roof-code research note](../../Research/Connecticut_Roof_Code_Research_2026-10-28.md) records adoption-cycle caveats.

This is not a code-compliance determination, room pass/fail, structural design, headroom survey, EERO analysis, Revit placement, or IFC result. The M158 blocks and gable planes are schematic, idealized comparisons only. Selected-D, Revit/IFC, incoming RFAs and owner selections are unchanged.
