# M225 — M-06 exact-SKU public resource audit

**Date:** 2026-10-31

**Status:** public-source audit complete; selected fixture fit remains unresolved.

## Scope and method

Rechecked the manufacturer product page for the owner-selected American Standard Champion PRO 610AA001.020, followed its visible specification-sheet and installation-guide links, and searched public web indexes for exact-SKU Revit/RFA/BIM files. No account, credentials, purchase, or access-control bypass was used.

## Findings

- The [American Standard page](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring) identifies model 610AA001.020 and states a 17-in seat height and 12-in rough-in. Its visible resources are a spec sheet and installation guide; it does not expose a Revit-family download.
- Following the spec-sheet link returns [PDF 167631](https://lixil.cdn.celum.cloud/167631_as_us_bath_spec__211A%20(7076)_0_original.pdf). Its contents identify **211AA.104**, revised 2013, and list the predecessor 3195A.101 bowl and 4225A.104 tank. The drawing gives nominal 30-1/4 × 19 × 30-7/8 in dimensions and says seat and supply are sold separately.
- Following the installation-guide link returns [PDF 173349](https://lixil.cdn.celum.cloud/173349_as_us_bath_install__211A__211B__211C%20(4513)_0_original.pdf), revision 5 (2019). It identifies the 211AA/211BA/211CA series and the separate 3195A bowl and 4225A tank. It also cautions that pictures may not define exact china/component contours.
- The linked PDFs therefore document the older 211AA assembly, not the selected 610AA001.020. Their dimensions, component relationship and installation details must not be used as exact selected-SKU geometry. This source-link mismatch explains why the existing predecessor RFA cannot close the current fit gate.
- Exact-SKU public searches returned the manufacturer listing and retail listings, but no exact-SKU Revit/RFA family. Search failure is bounded evidence only; it does not prove that such a file is unavailable elsewhere.

## Disposition

Keep the selected 610AA001.020 as the design intent, but treat its exact assembled envelope as **unverified**. Do not substitute the 211AA PDF or seat-only predecessor RFA. Keep west A reserved for M-06 and east B unassigned until exact current-SKU geometry (or a current manufacturer dimension/installation drawing), applicable clearance basis, real door/approach geometry and plausible service route can be reviewed together in a disposable derivative.

The current pantry comparison continues to retain both swing directions by owner choice. Revit host generation remains pending because the supported Computer Use native pipe is unavailable in this session. Selected-D, the existing RVT/IFC pair and source RFAs were not changed. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
