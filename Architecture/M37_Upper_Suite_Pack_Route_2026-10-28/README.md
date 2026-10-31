# M37 - upper-suite room packing and public-hall route screen

Status: **bounded search completed; no candidate satisfies the current room-link, lift-clearance and public-route requirements. This is not proof that no arrangement exists.**

## Owner inputs carried forward

- Preserve the source room areas and primary-only U-05 bathroom access.
- Provide the owner-directed private path U-01 -> C-PRIVATE -> U-02 -> U-03.
- Retain guest hall access and the U-03/U-04 Jack-and-Jill relationship through U-06.
- **Owner revision, 2026-10-28:** U-03 has the private route only; remove the direct U-03-to-public-hall door. Preserve guest hall access and both Jack-and-Jill links.
- Keep the 4 ft stair-to-upper public hall test and source lift reservation visible; neither is detailed construction geometry.

## Current validator and refreshed default — 2026-10-28

The M-37 PowerShell generator now passes **27/27** integrity checks. The checked-in 1,500-node default and two clean replays reproduce byte-for-byte. The default reaches its 1,500-node cap, records 285 room-block layouts, and has zero lift/approach-clear route placements, so it tests no corridor routes. Hashes: search `20B4A13EF50B41F6CDF456375A724D8CB2892FEA103718E94CFA73382AF479F1`, checks `79143C3E720DC16F8C98FBA41DFF5AB05E45A08EC2A3901AC7F06E50411A59B8`, SVG `F70BF29156763863A38F6322B7E9B5ACFDD677BC0BE9DA9C5195A5BE6E138EDC`, manifest `6638C4F9F9266DC2D7EF6459B6B66E7A3AC009DDACB2D4B44B480DCD6E401A2E`. Older hashes elsewhere in this report identify earlier implementation checkpoints and are not hashes of the current artifacts.

The expanded balanced screen with eight added packing contacts and nine sampled public room-edge goals records reach counts U-01: 19, U-02: 6, U-03 corridor-side proximity: 6 and U-04: 12 across 25 layouts/routes. These counts overlap by layout; none reaches the required U-01/U-02/U-04 trio. The reproducible top partial visualization is documented separately in `Architecture/M39_Upper_Suite_Partial_Access_Study_2026-10-28/README.md`. No sample constitutes an actual door or opening.

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

At that implementation checkpoint, **20/20** checks validated source fingerprints, unchanged selected-D input, source-derived dimensions/offsets, private-only U-03 access, all six root plans, landing-aligned seed arithmetic and obstacle clearance, retained guest and Jack-and-Jill topology, exact clearance-grid parity, and bounded search accounting. The checked-in default and two independent default replays match byte-for-byte for `search.json` (`8FCF8F8A4A56583D8E343FFB60EEAA85A2FCFF2156615AA2078BC988EFB9BF913`), `checks.json` (`C85632785DE1C8579061E8862454997977DB21EB022708939DE7A469AE745B31`), SVG (`5D3E17656880B98D279850499CE9A6C4064E80F76F43F9C478BC77E4093FEC02`) and manifest (`391833694DAE146C2E6D3BEC2BE1DB7C117A0F0E3D6EE8D92393B5464D280DFA`). JSON parses and SVG parses as XML; the outside-repository output guard rejected its target without creating it; `git diff --check` passes. These checks do not turn a no-candidate result into an architectural rejection. A passing check count validates setup and report integrity, not a viable layout.

### U-02-only contact-sampling experiment — 2026-10-28

The search now accepts optional `-RootSearchScope`, `-U02RootPlanVariant`, and `-AdditionalContactSamples` controls. Defaults (`balanced`, `baseline`, `0`) preserve the established search. `guest-branch-first` changes only traversal order in the U-02-rooted tree; it changes no links, room dimensions or owner requirements. Extra samples preserve all five legacy anchors, then add evenly spaced positions within the source-derived 3.5 ft reservation interval, snapped to the existing 1/6 ft grid.

Reproduce the expanded U-02-only contact search twice:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope U-02-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-u02-contact-samples-8-correct-grid-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope U-02-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-u02-contact-samples-8-correct-grid-b'
```

Review caught a PowerShell variable-name collision: `$grid` (six cells per foot) and `$script:Grid` (intended feet per step) referred to the same case-insensitive script variable. The first expanded-sampling trial used an incorrect step and is discarded; none of its results or hashes is accepted below. The corrected sampler uses `$script:GridStepFt`, and an integrity check confirms the intended 1/6 ft step. The zero-sample default search is unchanged geometrically.

Both corrected-grid runs pass **23/23** integrity checks and match byte-for-byte: `search.json` SHA256 `5A5B5510694A6D5EC9FC1016976308472DE73B4BB41DBD732B65AF6A92F96AD1`, `checks.json` `2FF6A72DAF6C31364ABC0BC09A647CB392D168CC9E9F87960170263F2E067ECF`, SVG `EAD70F18E62616470281D560CE868B2B8CFC990E43F8E87FD697C8F1C4944255`, and manifest `C66945A7A731A15673823B17995CAE4C895BC4F930E8ECFE2AAC7834AF4042DC`. JSON and SVG/XML parse in both output directories. Each run expands 9,000 of 12,000 permitted nodes across three valid U-02 root/orientation/landing seeds; the fourth seed is outside the source shell. It records 200 complete packings and 200 lift/approach-clear route placements. U-02 has a hall-side reachable point in 179 cases; U-01 and U-04 remain unreachable, so the required three-room public route is absent. The search is incomplete because valid-seed budgets are exhausted. A 1,200-node smoke comparison records two layouts with legacy contacts and six with eight additional samples, showing broader contact coverage but no route success. An earlier 12,000-node U-02-only ordering test without extra samples recorded four layouts and no viable route; reordering the same room-link tree did not alter those packings.

Refresh the checked-in default and its two clean replays with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -NodeLimit 1500 -LayoutLimit 5000 -OutputDirectory 'Architecture/M37_Upper_Suite_Pack_Route_2026-10-28'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -NodeLimit 1500 -LayoutLimit 5000 -OutputDirectory '.local/revalidation/m37-default-correct-grid-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -NodeLimit 1500 -LayoutLimit 5000 -OutputDirectory '.local/revalidation/m37-default-correct-grid-b'
```

The three corrected outputs match exactly: `search.json` SHA256 `89580F29792E788A0ED66C12B02E014A9AD57EAC308737398FFDD0BBAA4AF626`, `checks.json` `34EFEF6C7D184A2001C11D9C234976371CD32D2612D23819F471BC81203EF1E3`, SVG `59756FD4D9C50ABB282E4A273B82405103D8EB7F7037342B644FDB40D1E404EB`, and manifest `4ABF234E7C05360086E8AA53F12296E2A2293EB5E4512FB9B0DE984645361F4E`. Each passes **25/25** checks, reports the 1/6 ft route grid, and parses as JSON/XML. The default still caps at 1,500 nodes, records 285 bounded layouts and finds zero placements clear of the landing approach, so it runs zero corridor tests. This remains a search diagnostic, not a design rejection.

### Balanced-root expanded-contact comparison — 2026-10-28

To test whether denser contacts solve the target room connection when no root room is privileged, reproduce:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope balanced -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-balanced-contact-samples-8-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope balanced -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-balanced-contact-samples-8-b'
```

Both runs pass **23/23** checks and match byte-for-byte: `search.json` SHA256 `1F2BD093B83C969346803D9B25D2929EB6E0A8629FB8BA37B2AEFA0976456E38`, `checks.json` `AB4AF73A3B77AE12A15BE8F75B6BC0A700D76281CDC3B5D01F1DF9F204783460`, SVG `ED0055C7D887390C00B15BCD6AFB968D73F8BF4888236366F0A640C589FC829E`, and manifest `2EAEF2F7C510BA2B679C1116291B2DC6BB67F7D8F5EFC35BEE92B7B0597DED69`. Each expands 9,000 nodes, records 25 complete layouts and 25 route tests; U-01 is hall-reachable in 19, while U-02 and U-04 are reachable in zero. No layout reaches the required three public rooms. The bounded search is incomplete because per-seed budgets were exhausted. This balanced result and the U-02-only result trade which room connects; more contact samples alone have not solved the room-door graph. The next useful model should represent specified public doorway/contact edges during packing, or test owner-approved landing-contact alternatives, before treating any arrangement as a design candidate.

### Off-centre public-edge goal samples — 2026-10-28

The route checker now accepts `-PublicDoorEdgeSamples` (1–9; default 1 preserves the centred-goal case). Each sample adds one schematic goal point on each side of each tested room. Sample positions are evenly spaced along the side after reserving half the source 3.5 ft contact interval at both corners, then aligned to the 1/6 ft grid. These points test corridor reach near hypothetical edge contacts; they do not place doors, openings or swings, and U-03 remains private-route-only by owner direction.

Reproduce the balanced-root test with five edge samples and eight additional room contacts:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope balanced -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 5 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-balanced-door-edge-samples-5-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope balanced -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 5 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-balanced-door-edge-samples-5-b'
```

Both runs pass **25/25** checks and match byte-for-byte: `search.json` SHA256 `CED36039A1188BF7CC014E4B9B060D8D8A92580C91CDD34D36665CBF57D88E58`, `checks.json` `FCE02E92643071EF6061BEAFB804C24F6B0B4D48304FA89EFA61C3B79B7F19FA`, SVG `ED0055C7D887390C00B15BCD6AFB968D73F8BF4888236366F0A640C589FC829E`, and manifest `D78680FDFBBBFD65BAF5E05D497EF3981510AFA4E4B455E1314B221C8634D04A`. Each expands 9,000 nodes and tests 25 approach-clear layouts. Edge samples reach U-01 in 19 layouts, U-02 in 6, U-03 in 6, and U-04 in 8; zero layouts reach the required U-01/U-02/U-04 trio. U-03 corridor-side proximity is a diagnostic only and is not a public door. The bounded search is incomplete; these results do not prove infeasibility or establish actual door locations.

## Limits and next work

This is a room-block and clearance-envelope screen, not Revit geometry. The nominal 3.5 ft reservations are source door-matrix values, not verified clear openings. The screen does not model partitions, actual door leaves/swings, corridor-door connections, landing shape beyond the source block, stairs, floor opening, headroom, furniture, finishes, structure, services, fire/life safety, code, accessibility, IFC or construction. The lift is an existing schematic reservation, not a selected product or shaft design.

Next: model specified public doorway/contact edges during placement or test owner-approved landing-contact alternatives. The corrected U-02-only and balanced-root tests connect different individual public rooms but neither produces U-01/U-02/U-04 together. Keep the private U-01 → C-PRIVATE → U-02 → U-03 chain, guest access and Jack-and-Jill links; inspect any future candidate only in a disposable Revit derivative, never by changing selected D. Connecticut steep-gable and permit inputs remain site-, municipality- and date-dependent. No code-compliance, structural-safety, certification or construction-readiness claim is made.

### U-01 perimeter-root mode (M157)

The opt-in switches `-U01PerimeterRootSeeds`, `-U01PerimeterSeedEdge` and `-U01PerimeterSpreadSeeds` mirror the earlier U-03-root mode. They require `-LandingAlignedRootSeeds` and `-RootSearchScope U-01-only`; they do not alter default output. Reproduce the owner-authorized 38 1/3 × 40 ft exploration case with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-01-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U01PerimeterRootSeeds -U01PerimeterSeedEdge all `
  -U01PerimeterSpreadSeeds -NodeLimit 4800 -LayoutLimit 10000 `
  -ExportAllRouteTestedCandidates -OutputDirectory .local/revalidation/M157-U01
```

The M157 search passes 29/29, records 766 route-tested packings and remains incomplete. U-01 touches the hypothetical outline in all 766, U-03 in none and U-04 in 20. No record reaches all three public-room samples while retaining no U-03 public-side sample. See `Architecture/M157_U01_Perimeter_Root_Search_2026-10-30/README.md` and `Tools/audit_m157_u01_perimeter_search.ps1` for the independent 20/20 candidate-archive audit. Outline contact is not a wall or an EERO.

### Joint U-01/U-03/U-04 perimeter-contact mode (M158)

The opt-in `-RequiredPerimeterContactRooms 'U-01,U-03,U-04'` constraint requires all three bedroom-capable program blocks to touch the hypothetical test-shell outline. It uses the same owner-authorized 38 1/3 x 40 ft search and five sampled points per public room. The modified default M37 replay remains byte-identical to the pre-M157 artifact set. Two joint-mode runs pass 31/31 and match all five artifacts; independent archive audits pass 16/16 twice, and the best-candidate validator passes 115/115. Both retained candidates have the three requested outline contacts; one meets all sampled public-route points while keeping U-03 private in the sampled proxy. The second fails the public-route condition. This is incomplete room-block arithmetic only. No shell, layout, wall, window, roof, door, code result or house design is selected. See `Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31/README.md`.