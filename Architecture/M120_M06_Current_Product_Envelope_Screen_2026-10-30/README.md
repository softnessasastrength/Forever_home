# M120 — M-06 current-product envelope update

**Status: source-bound preliminary plan-envelope screen; M-06 remains unassigned.** This corrects the earlier reliance on secondary seller dimensions for the selected American Standard 610AA001.020 and adds positive-solid measurements for the quarantined KOHLER Tresham family. It does not approve either product or establish a bathroom layout.

## New evidence

- The official [American Standard product page](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring) identifies 610AA001.020 and reports a 12-in rough-in and 17-in seat height. Its linked specification download remains predecessor documentation.
- The same manufacturer page links an infographic whose dimension callouts show the current product at 19 in overall width, 30-1/4 in projection, 30-7/8 in overall height, 16-1/2 in bowl height, 17 in seat height and a 12-in rough-in. The public image URL and observed SHA256 are in `m120-inputs.json`. The image was retrieved without sign-in to ignored `.local/revalidation/M119/610AA001-manufacturer-infographic.webp`; it is not redistributed here. The 16-1/2 in label is bowl height, distinct from the 17-in seat height, so the manufacturer's own diagram resolves that distinction. A seller's 16-1/2 in seat-height claim remains inconsistent with the manufacturer's explicit seat callout.
- Revit 2027.3 disposable family intake `.local/revit-pilot/family-intake/20261031T012424079Z/intake-manifest.json` measured the exact quarantined Tresham source SHA `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`. Ten types each have three positive-volume solids; the selected white type's family-symbol bounds are 24.0063 × 19.4998 × 34.625 in, placement type `WorkPlaneBased`. This is the family symbol frame, not host-oriented or installed geometry. Its category is Plumbing Fixtures. Source was not saved or edited.

## Reproducible gross-envelope screen

Run from repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m120_m06_current_envelope_screen.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m120_m06_current_envelope_screen.ps1 -OutputDirectory .local/revalidation/M120-repeat
```

The generator consumes the checked-in source observations, the owner-follow-up study, and the predecessor sink candidate list; it verifies their hashes and recalculates each same-wall pair. Expected outputs are `m120-report.json` and `m120-checks.json`. Only 2021 IRC residential minimum-spacing proxies of 15 in from the water-closet centerline to a side obstruction, 30 in to an adjacent-fixture centerline, and 21 in front are applied, following the dated Connecticut basis in [M-06 clearance research](../../Research/M06_Clearance_Basis_2026-10-30.md). Applicability is not determined.

The 124 × 84 in pantry-side B rectangle in the separate owner-follow-up proposal contains all eight recalculated toilet/lavatory bounding-box pairs under the inherited same-wall abstraction. This is gross containment only. It does not place any fixture, establish clear usable floor area, test a door leaf or approach, confirm plumbing connections, identify a service route, or resolve a site-specific code path. The Tresham is a non-ADA product and is not an accessibility solution. Keep B unassigned.

## Limits and next gates

- 610AA001.020 remains without an exact-SKU RFA or complete current-SKU installation sheet; manufacturer infographic plan dimensions are stronger evidence than the prior retailer-only plan values, but are still a two-dimensional product illustration.
- Tresham symbol-local bounds are not a placement test; its host orientation, connector objects and clearances remain unverified. Manufacturer documentation says it is not ADA compliant.
- Evolution remains a discontinued candidate with unresolved family representation. The 3195A101 RFA is a predecessor bowl only.
- Actual walls/finished faces, fixture orientation, door and approach, privacy, rough-in datum, water/waste/vent route and locally applicable requirements remain open.
- This screen makes no code-compliance, accessibility, safety, professional-certification or construction-readiness determination.

No selected-D source/model, IFC, owner-selected fixture, Incoming RFA source or remote state was modified.
