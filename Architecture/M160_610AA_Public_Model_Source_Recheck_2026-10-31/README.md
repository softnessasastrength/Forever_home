# M160 - Public current-SKU product and model-source recheck

**Checked:** 2026-10-31. **Disposition:** no exact-SKU Revit family or current-SKU assembly drawing was exposed by the public manufacturer page and uncredentialed indexed searches reviewed here. Keep M-06/B unassigned.

## Evidence reviewed

- The [American Standard product page for 610AA001.020](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring) identifies the current Champion PRO two-piece elongated toilet. It says the package includes a slow-close seat, metal trip lever, color-matched bolt caps and EZ-Install kit; it reports 1.28 gpf, 12-in rough-in and 17-in height with seat.
- The live manufacturer **Spec Sheet** link resolves to the 2013 `211AA.104` predecessor sheet, and the **Installation Guide** link resolves to the August 2019 `211AA/211BA/211CA` series manual. They are not current 610AA assembly drawings. The predecessor sheet specifies bowl `3195A.101` and tank `4225A.104`, describes the seat and supply as separately sold, and gives nominal dimensions 30-1/4 x 19 x 30-7/8 in. That predecessor component list must not be used to identify current-SKU components.
- The official product page separately displays the already archived 2024 610AA infographic. M120/M141 have retained its public URL, download hash and annotated 19-in width x 30-1/4-in projection, 30-7/8-in overall height, 16-1/2-in bowl height, 17-in height-with-seat and 12-in rough-in. M160 did not alter or replace that source package.
- Public exact-SKU/model searches for `610AA001.020` with RFA, Revit, BIM, CAD and 3D-model terms returned the manufacturer product listing and sellers, but no indexed exact-SKU RFA or dimensional assembly drawing. The product page exposes only the predecessor spec and series installation PDF as technical resources; no family link appeared.
- A distinct public LIXIL Pro page for the Champion PRO chair-height bowl lists white SKU `3195A101.020` and a Revit file. That family is bowl-only (coordinating tank sold separately), not the selected `610AA001.020` complete toilet; the existing Incoming file exactly matches the public RFA at SHA256 `F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393`. Its six-solid symbol bounds are already captured in the source-bound Revit intake report. This separate page does not change the exact-current-SKU search result or establish a bowl-to-tank mapping.

## Method and limits

Reviewed the public manufacturer page and opened its two linked technical documents. Ran public exact-SKU searches for RFA/Revit/BIM/CAD/3D model sources. No account, credential, form, support request, paid source, gated download or access-control bypass was used. Search-index absence does not prove no family exists in a registered or unindexed library.

The exact current-SKU Revit family and installed tank/bowl/seat solids remain unverified. The old 211AA series files cannot fill that gap. M120's current-SKU infographic supports a nominal plan rectangle only; it does not establish actual assembly geometry, finished clearances, sink fit, door/approach, or water/waste/vent routing. Keep both M-06-B and the hall-edge alternative unassigned until those inputs can be tested together. No local code applicability or compliance finding is made.

## Sources

- [Current American Standard 610AA001.020 product page](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring)
- [Manufacturer-linked 2013 predecessor specification](https://lixil.cdn.celum.cloud/167631_as_us_bath_spec__211A%20(7076)_0_original.pdf)
- [Manufacturer-linked 2019 predecessor-series installation guide](https://lixil.cdn.celum.cloud/173349_as_us_bath_install__211A__211B__211C%20(4513)_0_original.pdf)
- [LIXIL Pro 3195A101 chair-height bowl page and Revit file](https://lixilpro.com/products/toilets/Floor-Standing-Toilets/Champion-PRO-Chair-Height-Elongated-Bowl/Bone-%28021%29-3195A101021/)
- Earlier exact-family boundary checks: M122/M129/M142/M155 in `PLAN.md`, `PROGRESS.md`, and `Research/M06_Toilet_Options_2026-10-27.md`.
