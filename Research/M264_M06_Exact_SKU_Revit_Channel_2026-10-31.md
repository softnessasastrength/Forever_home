# M264 — Public Revit-delivery route for the selected M-06 toilet

**Checked:** 2026-10-31

**Status:** public-channel research only; no sign-in, account creation, chat request, download, or fixture selection.

## Finding

American Standard's official current product page identifies the selected Champion PRO `610AA001.020` as a complete two-piece toilet with seat and wax ring, and advertises a 17-in chair-height bowl with seat and 12-in rough-in. The public product page exposes a spec sheet, an installation guide, and product imagery; it does not expose a direct Revit-family download. The linked spec/install PDFs are the older 211AA-series materials already documented in M253, so they do not establish a complete 610AA001.020 Revit model.

American Standard/LIXIL identifies ATS Spec Tool as its Revit and BIM specification channel. ATS's public help says Revit availability is indicated by a Revit link on the product detail; if absent, users are directed to live chat. Its public download instructions require the user to log in and create a project or specification before downloading a Revit file. The public ATS index queries for the exact `610AA001.020` SKU returned no indexed family result. Therefore an exact family may exist behind the spec workflow or may not be indexed; this search cannot establish either case. No sign-in or live-chat request was attempted.

## Consequence for the model

The M262-measured `3195A101.020` RFA remains a predecessor bowl-only component with 13.9997 × 29.0628 × 17.0953 in positive-solid symbol bounds. The separate 211AA104 RFA measures only a seat. Combining those families, or scaling either to the 610AA001.020 plan image, would fabricate a current-product assembly. Keep the exact selected toilet as a labeled 2D plan-envelope proxy only; do not use either predecessor RFA as its 3D fit model. M-06, west A and east B remain unassigned.

The next evidence that can close this source gap without gated access is an owner-provided exact-SKU manufacturer family/drawing or a publicly downloadable exact-SKU family with source URL and hash recorded. Room fit still requires a selected lavatory, finished-face geometry, door/approach, project-specific clearance basis and plausible plumbing route.

## Public sources checked

- [American Standard — Champion PRO 610AA001.020 product page](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring) — product identity, advertised features and visible resource links.
- [American Standard — Technical Document Tools](https://www.americanstandard-us.com/pages/technical-document-tools) — identifies ATS Spec Solutions as its professional specification tool.
- [LIXIL Pro — 2022 residential product literature](https://lixilpro.com/media/spaey01b/02-aloft-hotels-gen-40.pdf) — public description of ATS as its Revit/3D plumbing specification partner.
- [ATS Spec Tool FAQ — Revit availability and downloads](https://www.atssoftware.com/faq_category/spec-tool/) — says a Revit link appears on product details when a family is available and requires a logged-in project/spec for download. No gated function was used.
- [M253 exact-SKU family search](../Architecture/M253_M06_Current_SKU_BIM_Refresh_2026-10-31/README.md) — prior public catalog search and current-product 2D-envelope evidence.

This channel research does not establish code compliance, accessibility, structural safety, professional approval, permit readiness or construction readiness.
