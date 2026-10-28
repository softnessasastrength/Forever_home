# M37 - upper-suite room packing and public-hall route screen

Status: **bounded search completed; no candidate satisfies the current room-link, lift-clearance and public-route requirements. This is not proof that no arrangement exists.**

## Owner inputs carried forward

- Preserve the source room areas and primary-only U-05 bathroom access.
- Provide the owner-directed private path U-01 -> C-PRIVATE -> U-02 -> U-03.
- Retain guest hall access and the U-03/U-04 Jack-and-Jill relationship through U-06.
- **Owner revision, 2026-10-28:** U-03 has the private route only; remove the direct U-03-to-public-hall door. Preserve guest hall access and both Jack-and-Jill links.
- Keep the 4 ft stair-to-upper public hall test and source lift reservation visible; neither is detailed construction geometry.

## Reproduce

From the repository root, Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -OutputDirectory '.local/revalidation/m37-repeat'
```

The generator fingerprints selected D, the owner-follow-up proposal and `Requirements/Room_Program.md`, rejects output outside the repository, and emits ordered JSON/checks/SVG/manifest artifacts. Compare artifact hashes across the two output directories to verify reproducibility. The checked-in `manifest.json` records output hashes.

## Method and result

The script packs the seven selected-D upper blocks (U-01 through U-06 and C-PRIVATE) with source room dimensions, two block orientations where distinct, 0.5 ft nominal wall bands and 3.5 ft nominal contact reservations. The bounded default now balances six orientations across roots U-01, U-02 and U-04, with six verified room-link plans; U-05 remains last in each plan. It searches a 36 x 32 ft upper test wing. Source coordinates place the clipped 8 x 4 ft lift projection at x=21 ft 2 in, y=28-32 ft and the upper stair landing at the rear edge; the corridor search starts from the landing's source-derived center approach. It tests a 4 ft swept public corridor at a 2 in translation grid.

The root-balanced **1,500-node default** reached its cap, allocating 250 nodes to each of six root orientations, and recorded 285 bounded layouts (430 complete packings); its reserved stair-approach filter left zero lift-clear route placements. A **10,000-node default-envelope stress run** expanded the three-root search to 1,607 layouts (2,525 complete packings), but again found zero placements clear of the reserved landing approach; therefore it tested zero corridors. The approach-overlap filter rejected 8,533 translations in that run. Root balancing did not address this bottleneck. No candidate met the public access, private link, and room-packing contract. This is a bounded search result, not proof that no arrangement exists. It samples a limited family of tree-attached room packings and contact alignments. The owner-revised contract requires guest access to U-01, U-02 and U-04; U-03 has no public door and remains reachable through U-02. Both Jack-and-Jill links and the private U-01 -> C-PRIVATE -> U-02 -> U-03 path remain required.

The three-root change is reproducible but is **not yet the next solution**: the next search should make landing-approach clearance a placement-time constraint, or explicitly model the landing and hall as route geometry before finalizing room packing. Simply raising the node limit or rotating roots has not produced a route candidate. An unselected 40 x 42 ft comparison remains a separate test-envelope question and must not be read as an approved upper-floor size.

An unselected **40 x 42 ft comparison envelope** (`-ShellWidthOverrideFt 40 -ShellDepthOverrideFt 42`) was also searched at the same node/layout limits. It produced 1,128 bounded layouts, 82 lift/stair-approach-clear translations and 82 corridor route tests. U-01 and U-02 were hall-side reachable in 0 routes, U-04 in 51, and U-03 corridor-side in 54; none reached the required public-room combination U-01/U-02/U-04. U-03's corridor-side reach is only a geometric proximity diagnostic, not a hall door, and is not required under the owner revision. This larger shell is a comparison based on the main-floor test envelope, not selected upper-floor geometry.

An **earlier U-01-root-only** 10,000-node default-envelope stress run increased coverage to 1,930 bounded layouts, 598 approach/lift-clear translations and 598 route searches. Hall-side reach counts were U-01: 0, U-02: 0, U-04: 231; U-03 corridor-side reach: 57. No route reached U-01/U-02/U-04 together, the candidate remained absent, and both orientation budgets were exhausted. Greater search budget alone did not solve the private-suite-to-hall connection; the layout/route search strategy must change. The run is retained under ignored `.local/revalidation/m37-private-only-default-10000/` and remains bounded, not exhaustive.

The current **18/18** checks validate source fingerprints, unchanged selected-D input, source-derived dimensions/offsets, private-only U-03 access, all six root plans, retained guest and Jack-and-Jill topology, exact clearance-grid parity, and bounded search accounting. The three-root smoke and 3,000-node tests pass integrity checks; the 10,000-node run used 9,996 nodes and produced no candidate. The checked-in default and two independent default replays match byte-for-byte for `search.json` (`91B637B9E94643C67DE52E8989BC656D3B8530119036557A3B2C32E0D226EF05`), `checks.json` (`92E3F6BD96CCA55EE632AAB3DA2C42A5AF570AE56A6C36B6A44952066C94302C`), SVG (`5D3E17656880B98D279850499CE9A6C4064E80F76F43F9C478BC77E4093FEC02`) and manifest (`C25CDB600575E4C85DB6E36B999D024D85E78B6F7DFE7DA20205C7850589D279`). JSON parses and SVG parses as XML; the outside-repository output guard rejected its target without creating it; `git diff --check` passes. These checks do not turn a no-candidate result into an architectural rejection. A passing check count validates setup and report integrity, not a viable layout.

## Limits and next work

This is a room-block and clearance-envelope screen, not Revit geometry. The nominal 3.5 ft reservations are source door-matrix values, not verified clear openings. The screen does not model partitions, actual door leaves/swings, corridor-door connections, landing shape beyond the source block, stairs, floor opening, headroom, furniture, finishes, structure, services, fire/life safety, code, accessibility, IFC or construction. The lift is an existing schematic reservation, not a selected product or shaft design.

Next: improve the search around the reserved landing approach and test whether public routes to U-01, U-02 and U-04 can be supported while keeping the U-03 door private-only. Current zero route placements mean the reserved approach currently rejects every packing before corridor search; inspect that interaction before broadening the search. If a viable proposal emerges, inspect it in a disposable Revit derivative; do not change selected D. Separately test illustrative steep-gable pitch cases only as labelled proposals, with Connecticut code research remaining site-, municipality- and permit-date-dependent. No code-compliance, structural-safety, certification or construction-readiness claim is made.
