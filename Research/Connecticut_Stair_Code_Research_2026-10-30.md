# Connecticut stair-riser and tread basis for the selected-D vertical study

Checked: **2026-10-30**
Status: **state-code research and source-bound arithmetic only; project applicability and stair design are unresolved**

## Published Connecticut provision

Connecticut DAS lists the **2022 Connecticut State Building Code (CSBC)** as current and says it applies to permit applications filed on or after October 1, 2022. The CSBC adopts the 2021 IRC with Connecticut amendments. Under the amended residential stair provisions, IRC R311.7.5.1 sets a maximum riser height of **8 1/4 in (209.5 mm)** and limits the difference between the largest and smallest riser in one flight to **3/8 in (9.5 mm)**. Amended R311.7.5.2 sets a minimum tread depth of **9 in (229 mm)** and limits variation within a flight to **3/8 in**. The specified exceptions address existing-stair replacement/alteration and spirals; they are not assumed to apply to this new-home study.

These are published statewide provisions, not a determination that this hypothetical project falls under a specific building/occupancy path, municipality, permit date or adopted code. Confirm the code edition and classification with the eventual local authority. This note is not code-compliance review.

## Comparison with the project sources

The selected-D room-study source places Lower FF at -5 ft, Main FF at 0 ft and Upper FF at +5 ft. Each adjacent test transition is therefore **60 in**. Its inherited B-derived stair plan uses **8 equal 7.5 in risers**, **7 treads at 11 in**, and describes these as comparison arithmetic only; final count and geometry remain unselected. The arithmetic totals 60 in rise and a 77 in straight tread run. If the 60 in transition is retained, 7 risers would each be 8.5714 in and exceed the published CT maximum; 8 equal risers at 7.5 in are the minimum count that stays under 8.25 in.

The separate `Architecture/Stairs_Half_Story.md` owner-intent document prefers **6 risers at 7.25 in** (43.5 in total) and a 5-to-7 count range. Its former generic 7.75 in IRC ceiling is not the current Connecticut amendment. At the 60 in D test rise, even seven equal risers would be 8.5714 in, while six preferred 7.25 in risers fall short by 16.5 in. This is a real section-design mismatch, not a reason to silently change the D datum or the owner's preference. Possible study directions include retaining the 8-riser D comparison, revisiting adjacent floor datums, or studying multiple short flights and a landing; none is selected here.

`Tools/analyze_m112_stair_rise_code_basis.ps1` reads the selected-D study, selected-direction decision, owner stair-intent file and this basis note; it emits the exact calculation and checks under this package. It does not model or validate Revit stairs, floor openings, assemblies, headroom, guards, support, egress, or structure. No native stair or house geometry was changed.

## Sources

- Connecticut DAS, [2022 CSBC regulations and adoption page](https://portal.ct.gov/en/das/office-of-state-building-inspector/connecticut-state-building-code/regulations), checked 2026-10-30.
- Connecticut DAS, [2022 Connecticut State Building Code with Errata #1](https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf?rev=a59cc11db0564caaa5477bd696ee85f2), amended IRC R311.7.5.1 and R311.7.5.2, pp. 138-139 of the code PDF.

No municipality or permit schedule has been supplied. Do not claim code compliance, accessibility, structural safety, professional certification, or construction readiness from this arithmetic.