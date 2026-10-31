# M117 - U-03 gable and conditional EERO height screen

Status: reproducible ideal-roof-plane comparison only. No U-03 orientation, roof axis, pitch, eave height, window product, room assignment or code result is selected.

## Question and source geometry

Can a steep gable provide a more favorable theoretical opening zone for the northeast privacy-screen branch? M115 has 64 such room-block candidates, but M116 correction shows two distinct source-preserved U-03 orientations: 44 at 13.6667 x 9.1667 ft (north/east shell contacts 164/110 in) and 20 at 9.1667 x 13.6667 ft (110/164 in). M117 carries both orientations through each M83 ideal roof plane: 8:12, 10:12 and 12:12 pitches with ridge axes X and Y.

For each case, a hypothetical 20 in clear-width opening segment is placed at the segment of the touching gable wall nearest the ridge. Its clear height is 41.04 in, derived by dividing the conditional 5.7 sf Connecticut EERO area threshold by 20 in. Its bottom is held at the conditional 44 in maximum. This is arithmetic, not a window selection. The theoretical minimum roof-plane rise over the assumed opening segment is compared with the resulting 85.04 in opening top to report a conditional floor-to-eave threshold. Negative raw thresholds mean only that the ideal roof plane would be above that opening top even with a zero-relative eave datum; they do not establish a feasible roof or window.

## Results

For the 44 north-long room candidates, the north wall is 164 in and east wall 110 in. With ridge Y, the north wall is the gable end and the ideal rise at the assumed window segment is 8, 10 and 12 ft for 8:12, 10:12 and 12:12. With ridge X, the east gable end provides 5, 6.25 and 7.5 ft. For the 20 east-long candidates, those comparisons swap: ridge X produces 8, 10 and 12 ft; ridge Y produces 5, 6.25 and 7.5 ft.

Thus the longer side of the schematic room block, when it contacts the chosen gable end, gives the larger theoretical opening-zone rise in this model. That describes only the ideal roof-plane arithmetic. It is not a recommendation: room orientation and ridge axis remain unselected, and no continuous roof over the suite, ceiling, gable wall, eave, framing, thickness, product clear opening, exterior grade or discharge path is represented.

The computed raw eave thresholds are in `m117-cases.csv`. The report also retains the zero-clamped value for display; use raw values to see when the ideal plane already exceeds the assumed opening top relative to a zero-eave datum.

## Basis and limitations

The conditional threshold inputs come from M116's dated research against Connecticut's 2022 CSBC / adopted 2021 IRC basis. The relevant primary sources are [Connecticut DAS current code regulations](https://portal.ct.gov/das/home/office-of-state-building-inspector/connecticut-state-building-code/regulations?language=en_US), [Connecticut DAS adoption status](https://portal.ct.gov/DAS/Office-of-State-Building-Inspector/Building-and-Fire-Code-Adoption-Process), the [official 2022 CSBC with Errata #1](https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf), and [2021 IRC Chapter 3](https://codes.iccsafe.org/content/IRC2021P1/chapter-3-building-planning). Sleeping-room classification, site, municipality, permit date and applicability remain unverified; recheck before relying on the code snapshot.

M83 represents ideal zero-thickness gable planes on the 38 1/3 x 40 ft hypothetical shell. It does not model framing, overhangs, walls, ceilings, dormers, structure, water management, openings or exterior conditions. The 38 1/3 x 40 ft shell and all M115 layouts remain exploratory, not selected. Selected-D, Revit, IFC and Incoming RFAs were not modified. No structural, code-compliance, professional certification or construction-readiness conclusion is made.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m117_u03_gable_eero_clearance.ps1
```

The source-bound analyzer passes **19/19** checks. Two sequential runs reproduce all three outputs byte-for-byte:

- `m117-report.json`: `BF2A5598282D4ADDE0A11F851D2222B1152A202ADA4156829C65C2C21FA4EC6B`
- `m117-checks.json`: `EEC9FD7CBDDF555E957C23844EB975E04BA0B176093E1B0CA967B5FD78FDC094`
- `m117-cases.csv`: `F20E037831B18253A360898C8B3401FEAA8BE78EF4831C669835DCAC0B41660E`

The report binds its M115 archive/audit, corrected M116 report, M83 roof options and manifest, selected-D and proposal sources, and generator/audit scripts by SHA256. Selected-D's source hash is preserved as `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`.
