# RevitCity family intake

Status: **No M-02 island family approved. RevitCity 19967 failed geometry validation; 21015 was inspected and conflicts with the documented island use and dimensions.**

Use this intake for granular family selection after the C-study geometry is stable. Do not bulk-download or assume a RevitCity family is safe, parametric, licensed for reuse, or compatible with Revit 2027.

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

- RevitCity object 19967, “Island Cabinet or Countertop,” source file `Incoming/Island_Cabinet_or_Countertop_19967.rfa`, Revit Architecture 2018. The original file remains unchanged. A temporary family-editor type `ForeverHome_8x4_Test` was loaded into the ignored derivative `.local/revit-pilot/design-models/selected-d-furnishing-study/FH_Selected_D_Furnishing_Study.rvt` after documenting the exact parameter edits; family constraints had to be removed in the temporary family-editor document because Revit rejected the 36 in height, 1.25 in counter thickness and 4 in plinth together.
- One Casework instance is placed on `D Main FF` in M-02. Revit API audit `.local/revit-pilot/audits/20261027T182056346Z/` and IFC export `.local/revit-pilot/exports/20261027T182112895Z/` share saved-model SHA256 `f18dc8e425c7a0409cdfafaa40cebd39c0d71d8afa8bef1f7e6d1ef660c36e0d`. Audit: 3 levels, 21 enclosed rooms, one Casework, 0 walls/openings, 0 warnings. IFC2X3: 0 schema-validation issues, 21 spaces, one `IfcFurnishingElement`; all non-annotation product geometry decodes. Six model-line annotation geometry exceptions are reported separately.
- The independent check `Tools/RevitPilot/validate_kitchen_island_ifc.py` fails the candidate's fit gate. IFC bounds are x=26.7467–34.7467 ft, y=6.7500–10.7500 ft and z=1.1401–1.1811 ft. The selected-D `study.json` target is x=26.6667–34.6667 ft, y=6.6667–10.6667 ft; the kitchen spec requires a 36 in counter height above the main level. Thus its 8 x 4 ft footprint is present, but it sits about 1 in east/north of the source-derived origin and exports only a ~0.5 in-thick surface at roughly 1 ft 2 in above floor. It is not an acceptable island model. Keep this derivative and report as a failed comparison; do not edit the source family or transfer the instance to the baseline.
- RevitCity object 21015, “Cooking Island, Kichen Table,” uploaded by Jeanbrice10 (original creator Brice Magdeleine), was downloaded to the local quarantined intake at `.local/revit-pilot/family-intake/21015/Cooking_Island_Kichen_Table_21015.rfa`; SHA256 is `82b901ef8d5a60210618f5340ef3f25466debc02b096dc128319be74285ac14b`. Revit 2027 opened the Revit Architecture 2020 RFA for inspection. Family Type data lists 1700, 2100, 2800 and 3200 mm table lengths, all with a locked 1000 mm width. The type formulas lock table height at 900 mm and thickness at 32 mm. The geometry visibly includes a hob, oven and automatically arrayed stools; the chair count is formula-driven by table length. This conflicts with the recorded kitchen decision that the island remain appliance-free, and it cannot meet the documented approximately 8 x 4 ft / 36 in counter target without changing locked family formulas and removing appliance geometry. No family instance was placed. A temporary 8 ft study type was created only in the active unsaved Revit document and then the unplaced family was removed; the derivative on disk and source RFA were not saved or changed. Download/reuse license terms remain unreviewed. Status: tested-unapproved for the M-02 island role; retain only as a reference until the owner changes the appliance-free decision or a compatible island family is found.
- RevitCity object 7216, `island_cabinet_Generic_7216`, was inspected in Revit 2027 as a Casework family with level-based placement and nominal 4 x 2 ft modules. The quarantined local source SHA256 is `9487A32D6C70789A772FA1E20F6CE80F7DBD196C76FBCFE695A3CA62E0B88626`; it remains unchanged and outside Git. Four instances were tested in `FH_Selected_D_Furnishing_Study_7216_Fit_Test_3`, an ignored saved copy, in the four quadrants of the source-derived 8 x 4 ft plan envelope. The Revit audit at `.local/revit-pilot/audits/20261027T192333070Z/` records 4 Casework instances, 3 levels, 21 rooms and zero warnings. Matching IFC2X3 export `.local/revit-pilot/manifest-workspaces/selected-d-7216-fit-test/.local/revit-pilot/exports/20261027T193519083Z/` has the same RVT fingerprint, zero IFC schema issues, all 21 spaces/3 storeys, and all non-annotation product geometry decodes. Every module matches its 4 x 2 ft plan cell and the union matches the source origin and 8 x 4 ft footprint. The IFC geometry top is only 34.5 in above floor (z=2.875 ft), not the required 36 in. The family type's nominal 3 ft height parameter is not borne out by exported solid geometry. Status: fit **failed**, candidate **not approved**.
- The kitchen spec's `34-1/2 in base cabinet + 1-1/4 in counter = 36 in AFF` arithmetic totals 35-3/4 in; the 1/4 in discrepancy and the finish decision's unresolved material thickness/flush transition are retained as a design/shop-drawing question. No countertop or thickness was fabricated in the test. Reuse rights remain unreviewed, so the family stays quarantined. This remains massing/casework evidence only; perimeter obstacles and the 42 in aisle are not modeled.
- The exported IFC can verify the island's own bounds, not the documented 42 in clearances: perimeter counters and obstacles are not yet modeled in D. No circulation, accessibility, cabinet fit, or architectural approval is claimed.

No family is approved by being visually attractive or by loading without warnings. A family is accepted only with evidence in the intake record and a corresponding model/schedule update.

## M-01 masonry hearth surround candidate — preliminary inspection

- RevitCity object 18782, “Masonry Fireplace,” credited to Weller & Michal. Its listing says Revit Architecture 2016; Revit's upgrade dialog identified the file as Revit 2017. Treat the version discrepancy as unresolved.
- Downloaded file SHA256: `22049e2b4d06ac545ba556054f7720eabf81f5882b94154a68073a9a94c7a738`. The original remains in the user's local Downloads folder; it is not added to this repository because reuse terms have not been reviewed.
- Revit 2027 loaded it into `.local/revit-pilot/design-models/selected-d-furnishing-study/FH_Selected_D_Furnishing_Study.rvt`, a derivative copied from the validated D space study. It appears in the Family Browser as Generic Models / `Masonry_Fireplace_18782`, with types `24W24H`, `32W40H Rumford`, `36W29H`, and `48W32H`. Its 3D view is an open masonry firebox with a smoke chamber/chimney. No family instance was placed; host/placement behavior, nested content, warnings attributable to the load, IFC representation, and reuse rights remain unverified.
- Family Type inspection of `36W29H` showed a 5 ft hearth width, 1 ft 11 in hearth depth, 6 ft 2 in mantel length, 2 ft 4 in chimney depth, and 4 ft mantel height. These are family geometry values, **not** appliance clearances or a fit approval.
- The owner-approved living-room direction is a pellet stove with a decorative masonry surround. This family depicts an open fireplace and cannot represent the chosen appliance. It may be considered as surround-only visual reference after a compatible stove and its listing are selected.
- Actual placement is gated on coordinated wall geometry and selection of a hearth wall/orientation. The current validated D model has 21 spaces but 0 walls/openings; assigning a location now would be arbitrary, and importing the open fireplace as the operating appliance would contradict the accepted direction.
