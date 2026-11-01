# Rejected RevitCity candidates

These source files are retained for provenance and recovery, but are retired from active model selection. The failed RVT/IFC trials and their results remain in ignored `.local/revit-pilot/` evidence. Do not load these candidates into the active house model.

## M-02 island alternatives

| Object | Source | Disposition |
|---|---|---|
| 19967 — Island Cabinet or Countertop | [RevitCity listing](https://www.revitcity.com/downloads.php?action=view&object_id=19967); archived `Island_Cabinet_or_Countertop_19967.rfa`; SHA-256 `D8552A7DEF0887146479BDB91AE04969D9532FDF02461F094018AEE254335A03` | Rejected after IFC geometry check: plan origin is about 1 in east/north of target; exported surface is near z=1.14 ft and only about 0.5 in thick. The isolated failure report remains at `.local/revit-pilot/exports/20261027T182112895Z/kitchen-island-validation.json`. |
| 21015 — Cooking Island, Kichen Table | [RevitCity listing](https://www.revitcity.com/downloads.php?action=view&object_id=21015); source copy retained at ignored `.local/revit-pilot/family-intake/rejected/21015/`; SHA-256 `82B901EF8D5A60210618F5340EF3F25466DEBC02B096DC128319BE74285AC14B` | Rejected for this role: fixed 1000 mm width does not match the documented 8 × 4 ft target, and integrated cooktop/oven/stools conflict with the appliance-free island decision. |

## M-06 vanity placeholder

| Object | Source | Disposition |
|---|---|---|
| 22366 — Solid Surface Vanity Counter with Faucet | [RevitCity listing](https://www.revitcity.com/downloads.php?action=view&object_id=22366); archived `Solid_Surface_Vanity_Counter_w_Faucet_22366.rfa`; SHA-256 `3524AFC61B87377AA0809F18F6FA21C56343E22BFB9A9053CD91B9085629D154` | Retired from active intake after Revit 2027.3 measured all six types at 35.4331 in solid width while type labels range from 3 ft to 4 ft. Family Editor inspection found the 3-ft and 4-ft types both show a 2 ft 11 111/256 in default counter-width parameter. Root cause was not audited; no fit or product approval. Full evidence: `../RevitCity_Family_Intake.md` § “M-06 vanity candidate”. |

The source RFA was moved intact from `Incoming/` to this directory; it remains available locally for provenance and further diagnosis. No replacement fixture is selected, and M-06/A/B remain unassigned.

## Current island basis retained for study

RevitCity 7216 is retained in ignored `.local/revit-pilot/family-intake/7216/` as a simple adjustable base-block source. Four 4 × 2 ft modules plus a separately generated 8 × 4 ft generic top form the only currently validated island assembly: the top is 35.75 in actual and owner-accepted as nominally 36 in; the later IFC fit check passed 13/13. The 7216 RFA alone is not a finished or approved countertop/product: its exported base is 34.5 in high and reuse terms remain unreviewed. See `../RevitCity_Family_Intake.md` and `../../../PLAN.md` M14.
