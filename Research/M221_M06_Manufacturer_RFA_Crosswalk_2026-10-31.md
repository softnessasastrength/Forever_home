# M221 — M-06 manufacturer Revit-file crosswalk check

Date: 2026-10-31. Status: bounded public source review; no fixture selected or placed.

## Scope

Check the publicly visible American Standard/LIXIL pages for the owner-selected Champion PRO 610AA001.020 and its linked Champion PRO 211AA104.020 predecessor. Do not use a sign-in, create an account, or infer an exact-SKU family mapping from a predecessor listing.

## Findings

- The current [American Standard product page for 610AA001.020](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring) identifies the selected SKU and lists a specification sheet and installation guide among its public product resources. The public page exposes no Revit-family link. The published page continues to identify a 17-in seat height and a 12-in rough-in; this is not a complete plan/installation drawing or exact family geometry.
- The [LIXIL Pro page for predecessor 211AA104.020](https://lixilpro.com/products/toilets/Floor-Standing-Toilets/Champion-PRO-Two-Piece-128-gpf-48-Lpf-Chair-Height-Elongated-Toilet-Less-Seat/White-%28020%29-211AA104020/) lists a Revit-file link. A direct, unauthenticated download from its public manufacturer CDN is 331,776 bytes, SHA256 `37D3E56962B81F4B0ACE3D36D25BAFC03B7DEE1232E7DE7BBF9B95E4B0B75F63`. It is byte-identical to `Revit/Family_Intake/Incoming/american-standard-champion-pro-211AA104-020-predecessor.rfa`.
- The new quarantined retrieval at `.local/revit-pilot/family-intake/candidates/m06-lixil-211aa-predecessor-20261031/` carries `source-manifest.json` with the public URL and digest. Its bytes match a family already inspected read-only in Revit 2027.3: one Plumbing Fixtures type `5325.010`, the elongated slow-close seat, measured from two solids at 14.2591 × 17.0527 × 1.4658 in. It is not the bowl/tank assembly. No second Revit open was needed for this byte-identical copy.
- The predecessor listing and the selected current SKU are separate product records. The linked predecessor RFA cannot substantiate the complete 610AA001.020 body, installed envelope, bowl/tank relationship or an M-06 fit. The current-SKU exact model remains unverified. This bounded page review does not prove that no exact family exists in any other public or account-gated source.

## Decision and next evidence gate

Do not substitute the seat-only predecessor RFA for the selected toilet. Keep west A protected and east B unassigned until a complete current-SKU family or manufacturer dimension/installation drawing, a researched applicable clearance basis, actual door/approach geometry, and a plausible service route are checked together in a disposable derivative. The lavatory product and all wall, rough-in and plumbing layout choices remain open.

No account, credentials, purchase, selected-D edit, RFA modification, Revit placement, IFC export, code conclusion or remote change was made. The existing native and IFC baseline is untouched.
