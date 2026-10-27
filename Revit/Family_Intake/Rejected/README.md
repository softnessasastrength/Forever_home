# Rejected RevitCity candidates

These source files are retained for provenance and recovery, but are retired from active model selection. The failed RVT/IFC trials and their results remain in ignored `.local/revit-pilot/` evidence. Do not load these candidates into the active house model.

## M-02 island alternatives

| Object | Source | Disposition |
|---|---|---|
| 19967 — Island Cabinet or Countertop | [RevitCity listing](https://www.revitcity.com/downloads.php?action=view&object_id=19967); archived `Island_Cabinet_or_Countertop_19967.rfa`; SHA-256 `D8552A7DEF0887146479BDB91AE04969D9532FDF02461F094018AEE254335A03` | Rejected after IFC geometry check: plan origin is about 1 in east/north of target; exported surface is near z=1.14 ft and only about 0.5 in thick. The isolated failure report remains at `.local/revit-pilot/exports/20261027T182112895Z/kitchen-island-validation.json`. |
| 21015 — Cooking Island, Kichen Table | [RevitCity listing](https://www.revitcity.com/downloads.php?action=view&object_id=21015); source copy retained at ignored `.local/revit-pilot/family-intake/rejected/21015/`; SHA-256 `82B901EF8D5A60210618F5340EF3F25466DEBC02B096DC128319BE74285AC14B` | Rejected for this role: fixed 1000 mm width does not match the documented 8 × 4 ft target, and integrated cooktop/oven/stools conflict with the appliance-free island decision. |

## Current island basis retained for study

RevitCity 7216 is retained in ignored `.local/revit-pilot/family-intake/7216/` as a simple adjustable base-block source. Four 4 × 2 ft modules plus a separately generated 8 × 4 ft generic top form the only currently validated island assembly: the top is 35.75 in actual and owner-accepted as nominally 36 in; the later IFC fit check passed 13/13. The 7216 RFA alone is not a finished or approved countertop/product: its exported base is 34.5 in high and reuse terms remain unreviewed. See `../RevitCity_Family_Intake.md` and `../../../PLAN.md` M14.
