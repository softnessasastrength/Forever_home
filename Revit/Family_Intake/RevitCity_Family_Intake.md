# RevitCity family intake

Status: **The two unsuitable island alternatives are retired. RevitCity 7216 is the only current island base candidate used in a dimensionally passing assembly with a separate generic top; the RFA alone is not a finished or approved product.**

Use this intake for granular family selection against the stable selected-D space study, with all trials in disposable derivatives. Do not bulk-download or assume a RevitCity family is safe, parametric, licensed for reuse, or compatible with Revit 2027.

## Intake record

| Field | Required evidence |
|---|---|
| Family role / room ID | e.g. `M-06` main bath vanity, `U-06` Jack & Jill fixture |
| RevitCity URL and author | Source attribution; no private account data |
| File type / Revit version | RFA/RVT, origin version, upgrade path |
| Category and hosting | Door, Window, Plumbing Fixture, Furniture, etc.; wall/face/level host |
| Type and instance parameters | Dimensions, clearances, connectors, materials, visibility controls |
| Geometry budget | Polycount/detail level, nested families, imported meshes |
| Product/source status | Concept placeholder vs selected product; manufacturer/manual link if applicable |
| License/reuse note | Record visible terms; do not redistribute restricted files |
| Test result | Loads, places, schedules, exports, reopens; record failures |

## Review gates

1. Select the room, role and target dimensions before searching.
2. Download only to a quarantined local intake folder; never overwrite the authoritative model.
3. Open in a disposable Revit 2027 test file and inspect category, host, type catalog, nested content, warnings and materials.
4. Check nominal clearance envelopes and service/replacement paths against the C study.
5. Add only accepted families to the working model; preserve the original file and record any upgrade.
6. Re-run the room/ID manifest, schedules and export checks after each accepted family batch.

## Initial candidate groups

- Doors and windows: only after wall-host and nominal clear-opening tests.
- Bath fixtures: vanity, toilet and shower placeholders; accessibility and plumbing coordination remain open.
- Kitchen appliances: perimeter induction, sink, dishwasher, refrigerator; island remains appliance-free per current decision.
- Living equipment: pellet-hearth placeholder and CRT/service envelope; exact products and clearances remain unresolved.
- Lift: product-specific family only after manufacturer layout, pit, overrun and landing review.

## M-02 kitchen island candidate — failed fit trial

Disposition: **retired from the active candidate pool**; source bytes are retained under `Rejected/` with the test evidence linked there.

- RevitCity object 19967, “Island Cabinet or Countertop,” Revit Architecture 2018. Its unchanged source file was moved from `Incoming/` to `Rejected/` after the failed fit test. A temporary family-editor type `ForeverHome_8x4_Test` was loaded into the ignored derivative `.local/revit-pilot/design-models/selected-d-furnishing-study/FH_Selected_D_Furnishing_Study.rvt` after documenting the exact parameter edits; family constraints had to be removed in the temporary family-editor document because Revit rejected the 36 in height, 1.25 in counter thickness and 4 in plinth together.
- One Casework instance is placed on `D Main FF` in M-02. Revit API audit `.local/revit-pilot/audits/20261027T182056346Z/` and IFC export `.local/revit-pilot/exports/20261027T182112895Z/` share saved-model SHA256 `f18dc8e425c7a0409cdfafaa40cebd39c0d71d8afa8bef1f7e6d1ef660c36e0d`. Audit: 3 levels, 21 enclosed rooms, one Casework, 0 walls/openings, 0 warnings. IFC2X3: 0 schema-validation issues, 21 spaces, one `IfcFurnishingElement`; all non-annotation product geometry decodes. Six model-line annotation geometry exceptions are reported separately.
- The independent check `Tools/RevitPilot/validate_kitchen_island_ifc.py` fails the candidate's fit gate. IFC bounds are x=26.7467–34.7467 ft, y=6.7500–10.7500 ft and z=1.1401–1.1811 ft. The selected-D `study.json` target is x=26.6667–34.6667 ft, y=6.6667–10.6667 ft; the kitchen spec requires a 36 in counter height above the main level. Thus its 8 x 4 ft footprint is present, but it sits about 1 in east/north of the source-derived origin and exports only a ~0.5 in-thick surface at roughly 1 ft 2 in above floor. It is not an acceptable island model. Keep this derivative and report as a failed comparison; do not edit the source family or transfer the instance to the baseline.
- RevitCity object 21015, “Cooking Island, Kichen Table,” uploaded by Jeanbrice10 (original creator Brice Magdeleine), was inspected in Revit 2027. Its unchanged source copy is now at ignored `.local/revit-pilot/family-intake/rejected/21015/Cooking_Island_Kichen_Table_21015.rfa`; SHA256 is `82b901ef8d5a60210618f5340ef3f25466debc02b096dc128319be74285ac14b`. Family Type data lists 1700, 2100, 2800 and 3200 mm table lengths, all with a locked 1000 mm width; height and thickness are fixed at 900 mm and 32 mm. The geometry visibly includes a hob, oven and automatically arrayed stools. It conflicts with the appliance-free island direction and the 8 × 4 ft target. No family instance was placed, and the temporary type was removed from the unsaved inspection document. Status: **rejected for the M-02 island role**; its inspection evidence is retained in this intake record and the manifest. Download/reuse terms remain unreviewed.
- RevitCity object 7216, `island_cabinet_Generic_7216`, is retained as the only current base-module candidate. Its [RevitCity listing](https://www.revitcity.com/downloads.php?action=view&object_id=7216) describes a Revit Architecture 2008 generic block with adjustable length, height and mounting height, intended for quick plans/elevations and without door/detail geometry. Revit 2027 identified the family as level-based Casework with nominal 4 x 2 ft modules. The quarantined local source SHA256 is `9487A32D6C70789A772FA1E20F6CE80F7DBD196C76FBCFE695A3CA62E0B88626`; it remains unchanged and outside Git. Four instances were tested in `FH_Selected_D_Furnishing_Study_7216_Fit_Test_3`, an ignored saved copy, in the four quadrants of the source-derived 8 x 4 ft plan envelope. Matching IFC2X3 validation showed the base solid is 34.5 in high, despite the 3 ft type parameter. The later RevitPilot assembly added a separate 1.25 in generic top, yielding 35.75 in actual, accepted by the owner as nominally 36 in. Audit and IFC share saved RVT identity; IFC2X3 validation passes 13/13. The RFA itself remains a study block, not a finished countertop or approved product; reuse terms, seams, support and fabrication remain unresolved.
- The kitchen spec's `34-1/2 in base cabinet + 1-1/4 in counter = 36 in AFF` arithmetic totals 35-3/4 in; the 1/4 in discrepancy and the finish decision's unresolved material thickness/flush transition are retained as a design/shop-drawing question. No countertop or thickness was fabricated in the test. Reuse rights remain unreviewed, so the family stays quarantined. This remains massing/casework evidence only; perimeter obstacles and the 42 in aisle are not modeled.
- The exported IFC can verify the island's own bounds, not the documented 42 in clearances: perimeter counters and obstacles are not yet modeled in D. No circulation, accessibility, cabinet fit, or architectural approval is claimed.

## M-06 vanity candidate — research only

- The already-received RevitCity 22366 [listing](https://www.revitcity.com/downloads.php?action=view&object_id=22366) describes a parameter-controlled solid-surface vanity with adjustable counter dimensions, backsplash, basin offset, material and faucet visibility. It lists Revit Architecture 2020 and explicitly says the family has no casework below. It is a vanity/counter candidate, not a bathroom fit or complete cabinet.
- Revit 2027.3 loaded the source into the separate family-intake study `20261028T005203009Z`; the file SHA256 is `3524AFC61B87377AA0809F18F6FA21C56343E22BFB9A9053CD91B9085629D154`. That first run used an older pilot assembly and emitted only six type names. The corrected sandbox pilot was then host-run in separate study `20261028T015956023Z`; it measured six types from positive-volume solids. The four-foot-labelled type measures 35.4331 × 22 × 11.1850 in, and all six type definitions report the same 35.4331 in X extent despite their different width labels. The 3'-6" type variants have differing Z extents (9.6890 and 15.3130 in). Type parameters include 2 ft 7.5 in counter height, 2 in counter thickness, 1 ft 10 in counter depth and wall-mounted faucet enabled. This is a material type/solid-bounds discrepancy: inspect the family geometry and type formulas before any fit claim. Category is Plumbing Fixtures and placement is OneLevelBased. The family remains unapproved and unplaced; M-06 has no approved footprint, clearance basis, door or service route. Do not place 22366 in the house model merely because a nominal size might fit a search window.

The same run measured the queued RevitCity 17584 Sony flat LED television as one Generic Models / WorkPlaneBased type with three positive-volume solids and local bounds 42.7559 × 6.2992 × 26.5354 in. This is a modern flat LED placeholder, not the owner's selected legacy rear-projection CRT. It has not been placed and is not an acceptable substitution for the selected TV direction.

No family is approved by being visually attractive or by loading without warnings. A family is accepted only with evidence in the intake record and a corresponding model/schedule update.

## M-01 masonry hearth surround candidate — preliminary inspection

- RevitCity object 18782, “Masonry Fireplace,” credited to Weller & Michal. Its listing says Revit Architecture 2016; Revit's upgrade dialog identified the file as Revit 2017. Treat the version discrepancy as unresolved.
- Downloaded file SHA256: `22049e2b4d06ac545ba556054f7720eabf81f5882b94154a68073a9a94c7a738`. The original remains in the user's local Downloads folder; it is not added to this repository because reuse terms have not been reviewed.
- Revit 2027 loaded it into `.local/revit-pilot/design-models/selected-d-furnishing-study/FH_Selected_D_Furnishing_Study.rvt`, a derivative copied from the validated D space study. It appears in the Family Browser as Generic Models / `Masonry_Fireplace_18782`, with types `24W24H`, `32W40H Rumford`, `36W29H`, and `48W32H`. Its 3D view is an open masonry firebox with a smoke chamber/chimney. No family instance was placed; host/placement behavior, nested content, warnings attributable to the load, IFC representation, and reuse rights remain unverified.
- Family Type inspection of `36W29H` showed a 5 ft hearth width, 1 ft 11 in hearth depth, 6 ft 2 in mantel length, 2 ft 4 in chimney depth, and 4 ft mantel height. These are family geometry values, **not** appliance clearances or a fit approval.
- The owner-approved living-room direction is a pellet stove with a decorative masonry surround. This family depicts an open fireplace and cannot represent the chosen appliance. It may be considered as surround-only visual reference after a compatible stove and its listing are selected.
- Actual placement is gated on coordinated wall geometry and selection of a hearth wall/orientation. The current validated D model has 21 spaces but 0 walls/openings; assigning a location now would be arbitrary, and importing the open fireplace as the operating appliance would contradict the accepted direction.
