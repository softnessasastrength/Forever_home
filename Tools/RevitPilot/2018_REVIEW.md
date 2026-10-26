# Revit 2018 review handoff

Status: awaiting execution on the owner's other computer. No 2018 result is implied by this checklist.

## Files and protection

The transfer package contains the fixture IFC2x3, AutoCAD 2010 DWG, two-page PDF, CSV/JSON records, manifest, 2027 native source/families and backup. Extract to a new review directory. The native RVT/RFA are archives for Revit 2027; do not expect them to open in 2018. Do not overwrite them with imported or reconstructed output.

The fixture is an isolated test, not the Forever Home design. Its wall centerlines are 24 x 18 ft, with a separate stair between test levels at 0 and 10 ft. The enclosed room is approximately 404.444444 sf, not 432 sf, because room boundaries lie inside wall faces. There is no floor slab, roof or approved stair/accessibility design. Three IFC storeys include the default project level plus the two named pilot levels; they are not a proposed house section.

## Procedure

1. Record Revit 2018 exact build, IFC importer version if identifiable, date, and available template.
2. Create a separate blank 2018 review project. Link IFC2x3 first; record warnings, units, origin and orientation. Save the review project under a new name.
3. If appropriate, test Open IFC separately. Keep results separate from the linked case; record conversion time and warnings. Do not infer native editability from appearance.
4. Inspect four walls, one door, one window, one room/space, one equipment proxy and one stair/flight with railings. Compare openings and relationships as well as visible geometry.
5. Compare `elements.json` / `elements.csv`: all nine `FH-PILOT-*` identifiers, categories, room area and host information. Revit UniqueIds are native provenance; reconstructed/imported element IDs may differ. In the 2027 IFC export, the test mechanical equipment is an `IfcBuildingElementProxy`; record whether 2018 further changes its representation.
6. Measure wall centerline spacing, level separation and equipment box (2 x 2 x 3 ft). Record tolerances and observed deviations. Check stair geometry without treating the test stair as code-approved.
7. In another view/project, import or link DWG using known units. Compare the visible plan with PDF page 1 and measurements; verify orientation, openings, equipment and stair. Header verification alone is insufficient.
8. Capture plan, 3D and property screenshots without account details or unrelated personal data. Record each test as pass, discrepancy, failure or not tested.
9. Save the review project and findings separately. Never replace the authoritative 2027 files.

## Result table to complete

| Test | Result | Evidence / discrepancy |
|---|---|---|
| 2018 product/build and method | Not tested | |
| IFC link | Not tested | |
| IFC open/conversion, if attempted | Not tested | |
| Units/origin/orientation and measured dimensions | Not tested | |
| Wall/opening/door/window geometry | Not tested | |
| Room area and metadata | Not tested | |
| Stair/run/railings | Not tested | |
| Equipment proxy and category loss | Not tested | |
| Nine fixture IDs | Not tested | |
| Hosted relations / editability limitations | Not tested | |
| DWG visual and dimensional comparison | Not tested | |

Return findings before closing CO-013. A successful IFC import is not a native 2027-to-2018 backward-save or proof of parametric equivalence.
