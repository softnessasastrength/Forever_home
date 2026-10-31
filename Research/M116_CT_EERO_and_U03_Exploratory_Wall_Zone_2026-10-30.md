# M116 - Connecticut EERO basis and U-03 perimeter-zone screen

Checked: **2026-10-30**

Status: preliminary statewide research and schematic wall-zone screen only. This is not a code review, room assignment, opening design or compliance finding.

## Current Connecticut code snapshot

As checked on 2026-10-30, Connecticut DAS's [current-code regulations page](https://portal.ct.gov/das/home/office-of-state-building-inspector/connecticut-state-building-code/regulations?language=en_US) still lists the **2022 Connecticut State Building Code**, based on the 2021 model codes, as applying to permits filed from October 1, 2022. DAS's [adoption-process page](https://portal.ct.gov/DAS/Office-of-State-Building-Inspector/Building-and-Fire-Code-Adoption-Process) says the 2026 codes had been expected July 1, 2026 but the effective date was delayed pending approval by the Legislative Regulation Review Committee. A future project's permit date, municipality and code path are unknown; recheck them before design decisions rely on this snapshot.

## Conditional sleeping-room requirement

U-03 is programmed as a **hybrid bedroom/office**, with bedroom status unverified. If it is intended to serve as a sleeping room, the 2022 CSBC amendments to the 2021 IRC require at least one operable emergency escape and rescue opening in each sleeping room. R310.1 says the opening must open directly to a public way or to a yard/court that opens to a public way; the amendment allows a 36-inch unobstructed path from the yard to the public way. R310.2.1 requires at least 5.7 square feet net clear area, with a 5-square-foot exception for grade-floor or below-grade openings. The adopted 2021 IRC R310.2.2 supplies minimum net-clear dimensions of 20 inches wide and 24 inches high. Connecticut-amended R310.2.3 sets the bottom of the clear opening no more than 44 inches above the floor, subject to its fixed-platform exception. Sources: [official 2022 CSBC with Errata #1](https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf), [2021 IRC Chapter 3, ICC](https://codes.iccsafe.org/content/IRC2021P1/chapter-3-building-planning).

At the 5.7-square-foot area threshold, a 20-inch-wide clear opening would need 41.04 inches of clear height, while a 24-inch-high opening would need 34.2 inches of clear width. These are arithmetic bounds only; both minimum width and height, the required net area, normal operation, and the chosen product's actual clear opening must all be considered. The grade-floor exception is not assumed because the site and exterior elevation are unknown.

## What M115 changes for U-03

M115's bounded all-edge study archived 331 room-block arrangements. Of 80 that reach all three sampled public-room hall goals, 73 also avoid any sampled U-03 hall-side reach. Within those 73 privacy-screen candidates, 64 put U-03 at the northeast test-shell corner; nine put it at the northwest corner. The 64 northeast candidates have the source-preserved U-03 room rectangle of approximately 9.1667 x 13.6667 ft (125.28 square feet gross by rectangle arithmetic), touching the test-shell boundary along north and east edges. Those gross edge lengths are approximately 110 inches and 164 inches, respectively. This gives the schematic block two potential exterior-wall zones to investigate while retaining the sampled public route pattern and the owner-directed private-only topology.

The 125.28-square-foot rectangle is not net usable area: wall thickness, finishes, structure and final room shape are absent. Likewise, the 110- and 164-inch edge lengths are not opening widths or guaranteed clear wall lengths. They do not establish a wall, header, structural bracing, roof/eave clearance, sill height, window product, grade relationship, well/guard, qualifying yard/court, or route to a public way. A roof window is not presumed to satisfy the cited opening requirement.

The M115 north-east privacy group is therefore a **promising perimeter-zone hypothesis**, not a recommendation to select the northeast layout. Owner room classification, exact town/site, permit basis, exterior grade, opening operation/product, roof/ceiling geometry and professional review remain necessary before an opening can be evaluated. No model or selected-D geometry was changed.

## Reproduction

Run the source-bound check from the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m116_u03_eero_wall_zone.ps1
```

The script screens the archived M115 privacy subset and records threshold arithmetic. It does not place or size a window and does not output a pass/fail code result. See the generated hashes and check results in `Architecture/M116_U03_EERO_Wall_Zone_2026-10-30/README.md`.
