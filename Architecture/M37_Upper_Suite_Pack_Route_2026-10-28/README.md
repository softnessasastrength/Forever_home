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

An optional `-LandingAlignedRootSeeds` mode tests two source-derived access samples: a north-side room goal at the landing-approach centre, and an east-side room goal one 4 ft corridor width south, so its corridor square meets the south edge of the approach. Room candidates that leave the shell or overlap the lift/approach are rejected during placement. This second alignment is a search seed, not an approved door location. Reproduce the two-run experiment with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -LandingAlignedRootSeeds -NodeLimit 3000 -LayoutLimit 2000 -OutputDirectory '.local/revalidation/m37-east-south-edge-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -LandingAlignedRootSeeds -NodeLimit 3000 -LayoutLimit 2000 -OutputDirectory '.local/revalidation/m37-east-south-edge-b'
```

Across twelve root/orientation/side seeds, three east-side roots fall outside the 36 x 32 ft shell; the remaining nine are searched. At 3,000 nodes, 2,172 nodes were expanded and 11 complete seven-room packings were recorded, with 11 lift/approach-clear placements and 11 public-hall route tests. Hall reach counts are U-01: 4, U-02: 0, U-04: 1; zero layouts reach all three required public rooms. The bounded search remains incomplete and does not prove infeasibility. Two runs pass 20/20 setup checks and match byte-for-byte for `search.json` (`931DCF413670531A00F2F8912F25B64FCE7CAE23E7319B7D3C986FDED09879B7`), `checks.json` (`EDE3ED47ADE17805A9C4A641561F4272C11C5857069530D539D48690FE928F3B`), SVG (`0CDD18708B40F5ADDFC806F771133DBF2EFED530C24393C4FD812339C087DFA2`) and manifest (`D90071F701E44A4FFD9197A5CCEAD563FF3185F0B6D87DFF72723D731251EF12`). An earlier north-only 40 x 42 ft route-seeded comparison did not finish within five CPU-minutes and is not evidence. Next, focus the room-side/contact search on creating a route to U-02 while retaining the private chain, guest access and Jack-and-Jill links. Any unselected 40 x 42 ft comparison remains a separate test envelope and must not be read as an approved upper-floor size.

A **12,000-node landing-seed budget** stress replay was then run twice with a 10,000-layout cap. Reproduce with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-contact-depth-12000'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-contact-depth-12000-b'
```

Each run stops at the allocated per-seed budgets after 6,875 total nodes, records 23 complete layouts and checks 23 hall routes. Hall reach counts are U-01: 8, U-02: 0, U-04: 2; no route reaches the required three-room set. The two result folders match exactly: search `65CFD30841797B1873D0DF5BFE6BEC435237063A25D7A8FC3374BF125E60FBBB`, checks `0761C3B0D0C3AB7B99773F8ACB200B34D780309DC67AEC0B3997AD16B233B815`, SVG `6EC471AB510145FA1EE429EADB1B7C354CE710E32C8189C7308ADED777A08009`, manifest `01923C7A2E07BA92137E01098BFD39C2BFD87098C75EE2829670638292EDE436`. Both pass 20/20 checks and parse as JSON/XML. This is a deterministic but bounded stress sample; it does not establish that all possible contacts, layout trees or door arrangements fail. The persistent zero U-02 hall access indicates the next useful change is to include the public doorway/contact connection in the search graph or vary the root-to-landing contact, rather than merely increase node count.

An unselected **40 x 42 ft comparison envelope** (`-ShellWidthOverrideFt 40 -ShellDepthOverrideFt 42`) was also searched at the same node/layout limits. It produced 1,128 bounded layouts, 82 lift/stair-approach-clear translations and 82 corridor route tests. U-01 and U-02 were hall-side reachable in 0 routes, U-04 in 51, and U-03 corridor-side in 54; none reached the required public-room combination U-01/U-02/U-04. U-03's corridor-side reach is only a geometric proximity diagnostic, not a hall door, and is not required under the owner revision. This larger shell is a comparison based on the main-floor test envelope, not selected upper-floor geometry.

An **earlier U-01-root-only** 10,000-node default-envelope stress run increased coverage to 1,930 bounded layouts, 598 approach/lift-clear translations and 598 route searches. Hall-side reach counts were U-01: 0, U-02: 0, U-04: 231; U-03 corridor-side reach: 57. No route reached U-01/U-02/U-04 together, the candidate remained absent, and both orientation budgets were exhausted. Greater search budget alone did not solve the private-suite-to-hall connection; the layout/route search strategy must change. The run is retained under ignored `.local/revalidation/m37-private-only-default-10000/` and remains bounded, not exhaustive.

The current **20/20** checks validate source fingerprints, unchanged selected-D input, source-derived dimensions/offsets, private-only U-03 access, all six root plans, landing-aligned seed arithmetic and obstacle clearance, retained guest and Jack-and-Jill topology, exact clearance-grid parity, and bounded search accounting. The checked-in default and two independent default replays match byte-for-byte for `search.json` (`8FCF8F8A4A56583D8E343FFB60EEAA85A2FCFF2156615AA2078BC988EFB9BF913`), `checks.json` (`C85632785DE1C8579061E8862454997977DB21EB022708939DE7A469AE745B31`), SVG (`5D3E17656880B98D279850499CE9A6C4064E80F76F43F9C478BC77E4093FEC02`) and manifest (`391833694DAE146C2E6D3BEC2BE1DB7C117A0F0E3D6EE8D92393B5464D280DFA`). JSON parses and SVG parses as XML; the outside-repository output guard rejected its target without creating it; `git diff --check` passes. These checks do not turn a no-candidate result into an architectural rejection. A passing check count validates setup and report integrity, not a viable layout.

## Limits and next work

This is a room-block and clearance-envelope screen, not Revit geometry. The nominal 3.5 ft reservations are source door-matrix values, not verified clear openings. The screen does not model partitions, actual door leaves/swings, corridor-door connections, landing shape beyond the source block, stairs, floor opening, headroom, furniture, finishes, structure, services, fire/life safety, code, accessibility, IFC or construction. The lift is an existing schematic reservation, not a selected product or shaft design.

Next: vary contact anchors and route connections to U-02; the current seeds yield partial access to U-01 and U-04 but no U-02 hall-side reach. Keep the private U-01 → C-PRIVATE → U-02 → U-03 chain, guest access and Jack-and-Jill links. Current bounded searches have produced no supported three-room public route. If one emerges, inspect it in a disposable Revit derivative; do not change selected D. Separately test illustrative steep-gable pitch cases only as labelled proposals, with Connecticut code research remaining site-, municipality- and permit-date-dependent. No code-compliance, structural-safety, certification or construction-readiness claim is made.
