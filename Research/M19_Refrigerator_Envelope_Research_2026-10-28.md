# M19 refrigerator depth and door-open screen

**Status:** dimensional stress test only; neither reference product nor the B-first M19 arrangement is selected. Do not use this as a product recommendation, code/accessibility finding, or Revit/IFC placement approval.

## Why this screen exists

The M19 perimeter-run option measured its 48 in aisle from a nominal 24 in counter face to the island. That is a valid counter-to-island rectangle check, but the refrigerator slot is at the end of that run and its physical depth can project past the counter line. The specification prefers a 36 in counter-depth refrigerator; a product-sized opening and an open-door condition therefore need their own check before the schematic is promoted.

## Manufacturer-published reference envelopes

| GE reference model | Published width | Published overall depth | Depth with door open 90 degrees | Door-open width including handles | Rear / side air clearance | Product status |
|---|---:|---:|---:|---:|---:|---|
| GWE19JMLES, French door | 32.75 in | 31 in | 42 in | 40.5 in | 2 in / 1/8 in | Discontinued |
| GZS22IMNES, side by side | 35.75 in | 30.75 in | 46.5 in | 42.25 in | 2 in / 1/8 in | Discontinued |

GE's manufacturer pages report both product dimensions and 90-degree door-open depth; they also identify the models as no longer manufactured. See [GWE19JMLES product/specification page](https://www.geappliances.com/appliance/GE-ENERGY-STAR-18-6-Cu-Ft-Counter-Depth-French-Door-Refrigerator-GWE19JMLES), [GZS22IMNES product page](https://www.geappliances.com/appliance/GE-21-8-Cu-Ft-Counter-Depth-Side-By-Side-Refrigerator-GZS22IMNES), and its [GE dimensional comparison](https://products.geappliances.com/appliance/gea-compare/%26sku%3DGZS22IMNES%26sku%3DGZS22DMJES). GE also advises measuring door-opening and installation space, not just nominal width and depth, in its [appliance pathway guidance](https://products.geappliances.com/appliance/gea-support-search-content?contentId=000060161).

These are old but manufacturer-documented envelopes, chosen to expose a geometric issue in the existing 36 in placeholder slot. They are **not** current shopping shortlists. GE's data for the two examples does not establish the currently selected model's door-swing shape, hand clearance, surrounding casework fit, utility connections, or actual installation datum.

## Reproducible calculation

Run from repository root in Windows PowerShell 5.1:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/test_m19_refrigerator_envelope.ps1
```

The script reads the existing M19 `study.json`; it does not change it. The north-run counter-to-island face gap is 48 in. For this screening calculation, the published 2 in rear air-clearance value is added to each manufacturer product-depth value. The exact model installation drawing must confirm how the clearances and dimension datums apply before a design is fixed.

| Reference model | Remaining gap, doors closed | Remaining gap, doors at 90 degrees | Compared with 42 in documented island/counter minimum |
|---|---:|---:|---|
| GWE19JMLES | 39 in | 28 in | Closed state is 3 in short |
| GZS22IMNES | 39.25 in | 23.5 in | Closed state is 2.75 in short |

The second unit's listed body width plus two 1/8 in side air clearances consumes the full 36 in module, leaving no spare for casework tolerances or fillers. Both units' manufacturer-listed open widths exceed the nominal module by 4.5 in and 6.25 in respectively. These are flags for a chosen current product's installation drawing and hinge geometry, not claims of an installation failure under code.

The current M19 test arrangement is therefore **not ready for product-sized Revit placement**. A current refrigerator model, location/recess, sides of door swing, required surrounding clearances, and the intended aisle basis must be coordinated first. The script deliberately keeps product status, source links, and non-claims in its report so the comparison cannot masquerade as an approved purchase or layout.

The result and drawing are in [`Architecture/M19_Refrigerator_Envelope_Study_2026-10-28/`](../Architecture/M19_Refrigerator_Envelope_Study_2026-10-28/). This screen contains no dishwasher-open or range-open geometry: the project has not selected products with verified plan operating envelopes for those appliances.
