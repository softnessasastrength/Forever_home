# M253 - Refresh public BIM evidence for selected M-06 toilet

**Status:** no public Revit family for the exact selected `610AA001.020` SKU was found in the sources checked. Keep the family search unresolved; retain M-06 and A/B as unassigned.

## Search scope

On 2026-10-31, checked the current manufacturer product page and its linked resources, plus public BIM catalog/index results for `610AA001.020`, `610AA001`, and `Champion PRO` Revit family terms. No account was created, no sign-in was attempted, and no paid or gated download was used.

## Findings

- American Standard's current [product page](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring) identifies `610AA001.020` as a complete two-piece Champion PRO toilet. It states a 17-in chair-height bowl with seat and 12-in rough-in. Its listed resources are a spec sheet and installation guide; it does not expose a Revit-family download.
- The linked [spec sheet](https://lixil.cdn.celum.cloud/167631_as_us_bath_spec__211A%20(7076)_0_original.pdf) is revised 2013 and identifies model `211AA.104`, with nominal dimensions 30-1/4 x 19 x 30-7/8 in. The linked [installation guide](https://lixil.cdn.celum.cloud/173349_as_us_bath_install__211A__211B__211C%20(4513)_0_original.pdf) is revision 5, dated 2019, and covers the 211AA/211BA/211CA series. These are predecessor documents; do not assign their complete-unit geometry to current SKU 610AA001.020.
- The current manufacturer page separately links a `610AA001` infographic. M120/M229 already pin and measure its plan callouts as 19 x 30-1/4 in. That supports a current-SKU 2D plan envelope only; it does not supply the full 3D solid or a Revit family. M229's refreshed image SHA256 is `F09F6BFBCBB62F53828BD99E46F2351BB279E4C031980BBC5E35790E0FE86FBF`.
- Exact-SKU searches across public BIMobject, BIMstore, RevitCity, and broad indexed RFA results returned no matching 610AA001.020 family. The [American Standard BIMstore catalogue](https://www.bimstore.co/manufacturers/american-standard) currently lists APAC products such as Signature, Cygnet, and Heron families; those are different products and regional variants, not the selected US Champion PRO SKU. RevitCity's generic American Standard toilet listing remains SKU-less and sign-in-gated for download, so it is not usable fit evidence.

## Design consequence

The M252 `3195A101.020` family is the bowl-only predecessor component. The current SKU's manufacturer infographic supplies a 2D footprint, while the linked specification documents are for the older 211AA assembly. Do not combine these sources into a fabricated current-SKU 3D family. Keep the toilet as a clearly labelled plan-envelope proxy until the owner-selected complete product's geometry or a verified manufacturer model is available.

The envelope does not establish installed fit, a toilet centerline, the applicable Connecticut clearance basis, lavatory fit, door/approach, service route, or any room assignment. West A remains protected for study; east B and M-06 remain unassigned. No code-compliance, accessibility, structural-safety, professional-certification, permit-approval, or construction-readiness conclusion follows.
