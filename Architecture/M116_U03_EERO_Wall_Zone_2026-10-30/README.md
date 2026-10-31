# M116 - Conditional U-03 EERO wall-zone screen

Status: conditional code-basis and perimeter-zone screen. No window, wall, room assignment or compliance result is determined.

## Current code basis

Checked October 30, 2026. Connecticut DAS still lists the **2022 CSBC**, based on 2021 model codes, as current for permit applications from October 1, 2022. DAS reports that the planned July 1, 2026 effective date for the next code cycle was delayed pending Legislative Regulation Review Committee approval. Recheck the applicable municipality, permit date and code path when those project facts exist. [Current code regulations](https://portal.ct.gov/das/home/office-of-state-building-inspector/connecticut-state-building-code/regulations?language=en_US), [code adoption status](https://portal.ct.gov/DAS/Office-of-State-Building-Inspector/Building-and-Fire-Code-Adoption-Process).

If U-03 is intended for sleeping, the Connecticut-amended IRC R310.1 conditionally requires an operable emergency escape and rescue opening for each sleeping room to a public way or qualifying yard/court. The amendment gives 5.7 sf minimum net-clear area (5 sf for grade-floor or below-grade openings) and a 44 in maximum height from floor to the bottom of the clear opening. Adopted 2021 IRC R310.2.2 adds 20 in minimum net-clear width and 24 in minimum net-clear height. Sources: [official 2022 CSBC with Errata #1](https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf), [2021 IRC Chapter 3, ICC](https://codes.iccsafe.org/content/IRC2021P1/chapter-3-building-planning). This is a preliminary statewide basis, not a code review.

## Geometric screen

M115's full-route privacy subset contains 73 candidates. Sixty-four have U-03 touching the north and east edges of the hypothetical shell; nine touch north and west. Of the northeast 64, **44** place the longer source-preserved U-03 side north (13.6667 x 9.1667 ft) and **20** place it east (9.1667 x 13.6667 ft). Both have 125.28 sf gross area by rectangle arithmetic. North/east test-edge lengths swap: 164/110 in for the 44 north-long cases and 110/164 in for the 20 east-long cases. All 64 retain sampled U-01/U-02/U-04 public route reach and have no sampled U-03 hall-side reach. These counts are bounded-search results, not a room-orientation recommendation.

Those are gross room-block dimensions. They are not clear wall lengths or dimensions for a window. A 20 x 24 in clear opening is only 3.33 sf, so it would not meet the 5.7 sf minimum area. At the 20 in minimum width, area alone requires 41.04 in clear height; at 24 in clear height, it requires 34.2 in clear width. A selected product must satisfy the actual area, width, height, operability, sill and exterior discharge/path requirements together. No product or opening is sized here.

This makes the northeast branch a useful perimeter-zone hypothesis for further study. The shell outline does not establish an exterior wall; the study contains no window, roof/eave, finished floor, exterior grade, yard/court, guard/well or route to a public way. U-03's hybrid bedroom/office use is not resolved, and the 38 1/3 x 40 ft shell remains unselected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m116_u03_eero_wall_zone.ps1
```

The source-bound analyzer passes **21/21** checks. Two independent runs reproduce both output files byte-for-byte. The corrected orientation distribution is checked against the full M115 archive; report hashes are stored in the package output.

The script binds the M115 archive and audit, selected-D, owner proposal, room program and this code-basis note by SHA256. Its source includes no wall or window geometry, and the output expressly makes no code-compliance claim. No Revit, IFC, selected-D or RFA was changed.
