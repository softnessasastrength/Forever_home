# M239 — Public Revit-family recheck for Champion PRO 610AA001.020

**Research date:** 2026-10-31  
**Status:** bounded public-source check; no new family downloaded or approved.

## Target identity

The repository identifies the first M-06 toilet research target as **American Standard Champion PRO 610AA001.020**. It remains a research target, not a fully fitted or installed fixture selection.

## Results

1. The [American Standard 610AA001.020 product page](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring) identifies the exact SKU and lists a spec sheet and installation guide as the visible public resources. The page exposes no RFA/Revit-family download link. The earlier M225 source audit remains valid: those linked PDFs identify predecessor 211AA series components and are not authoritative exact-SKU body drawings.
2. The official [LIXIL Pro 211AA104.020 predecessor page](https://lixilpro.com/products/toilets/Floor-Standing-Toilets/Champion-PRO-Two-Piece-128-gpf-48-Lpf-Chair-Height-Elongated-Toilet-Less-Seat/White-%28020%29-211AA104020/) does expose a Revit download. Its CDN link resolves to the already quarantined `american-standard-champion-pro-211AA104-020-predecessor.rfa` (SHA256 `37D3E56962B81F4B0ACE3D36D25BAFC03B7DEE1232E7DE7BBF9B95E4B0B75F63`). Read-only Revit inspection recorded one Plumbing Fixtures type `5325.010`, geometry measuring as a slow-close seat only; it is not the predecessor toilet body, nor the current 610AA fixture. The RFA's presence on a predecessor product page does not make it a whole-toilet family.
3. Public BIMobject search results for TOTO contain Revit objects such as the Drake family, but those are TOTO products and do not correspond to the selected American Standard SKU. They are excluded. Other search-index results did not produce an exact 610AA RFA with traceable manufacturer provenance.

## Disposition

No newly verified exact-SKU Revit family was found in this bounded review. Do not place the TOTO family or the predecessor seat-only RFA as if it represented 610AA001.020. Keep the current target and all M-06 windows unassigned until exact assembled geometry (or a sufficiently detailed current manufacturer drawing), applicable clearance basis, actual door/approach, and a plausible service route can be evaluated together in a disposable Revit derivative. Search absence is limited to the sources reviewed and does not prove global non-availability.

No Revit file was downloaded or changed in this pass. Selected-D, the retained RVT/IFC, and the incoming Evolution RFA remain untouched. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
