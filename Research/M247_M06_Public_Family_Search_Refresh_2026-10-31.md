# M247 — Refresh the public RFA/CAD search for M-06 toilet 610AA001.020

**Research date:** 2026-10-31  
**Status:** bounded public search; no exact-SKU Revit/CAD file found in the sources reviewed. No family was downloaded, placed or approved.

## Source checks

- The [current American Standard product page](https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring) still identifies 610AA001.020. Its visible specification-sheet and installation-guide links resolve to documents titled for the predecessor 211AA series; those documents must not be treated as current-SKU installation geometry.
- The product page's [610AA001 infographic](https://www.americanstandard-us.com/cdn/shop/files/239959_Champion_Infographic_610AA001_0001_MAR2024_CDNwebp.webp?v=1790749418&width=2000) was fetched without authentication to ignored `.local/revalidation/M247_610AA_current_infographic.webp`. It is 133,750 bytes, SHA256 `F09F6BFBCBB62F53828BD99E46F2351BB279E4C031980BBC5E35790E0FE86FBF`, matching the already pinned M120 image exactly. The manufacturer image labels 19 in width, 30-1/4 in projection, 30-7/8 in total height, 16-1/2 in bowl height, 17 in with seat, and 12 in rough-in. This remains dimensioned product imagery, not a Revit family or installation drawing.
- Exact-SKU public index searches for `610AA001.020` with RFA/Revit/BIM/CAD/DWG/STEP terms returned the official product record and retail product listings, but no exact-SKU model file. RevitCity's public [“American standard toilet” search](https://www.revitcity.com/downloads.php?action=search&keywords=American+standard+toilet) lists a generic “American Standard Toilet” dated Revit Architecture 2011, with no 610AA model identifier or dimensions. The listing says “Login or Join to download”; no account sign-in, account creation, or download was attempted. The public search result therefore is not evidence for this product. Its detail page could not be fetched during this check (HTTP 502).
- Public searches of BIMobject and ARCAT did not return an exact 610AA001.020 model. Returned models were unrelated; this is bounded search evidence only, not proof that an exact file does not exist elsewhere.

The existing M229 toilet-only gross-A screen was replayed twice using the pinned current-SKU infographic observations. Both Windows PowerShell 5.1 runs pass **14/14** checks and reproduce the retained report/check files byte-for-byte: `m229-report.json` SHA256 `C22B03748EB81CD60C7E5095C517D86768B30A1951DD02A161CCBD1DF6D6CBBC`, `m229-checks.json` SHA256 `77575C5482A3D02B9562DC198D52FB1BD4F2A0CCBAE3199AEE3E92C26ED46BE4`. Both plan orientations pass only the modeled 15-in side / 21-in front spacing proxy and gross A containment. This remains toilet-only; it does not test the sink, walls, door/approach, services or actual room fit.

## Disposition

The current-SKU plan envelope can continue to use the pinned manufacturer infographic as a **plan-only** input to explicitly provisional layout screens. Do not use the linked 211AA PDFs or predecessor RFAs as a substitute for complete 610AA geometry. Do not download the generic RevitCity 2011 family behind its sign-in gate. Keep west A protected for the M-06 investigation and east B unassigned until product geometry, applicable clearance basis, actual door/approach and plausible water/waste/vent routing are evaluated together in a disposable Revit derivative.

No selected-D, RVT, IFC, Incoming RFA or remote state changed. This research does not establish code compliance, accessibility, a fit, a room assignment, structural safety, professional certification, permit approval or construction readiness.
