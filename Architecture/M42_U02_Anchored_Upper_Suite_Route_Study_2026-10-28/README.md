# M42 — Directed upper-suite public-route search

Status: **bounded partial-access diagnostic; no candidate adopted**. This study reuses the M37 room-packing and corridor engine with directed root/order variations. It preserves owner-selected room links and does not alter selected D.

## Owner direction and inherited inputs

- Private sequence: U-01 → C-PRIVATE → U-02 → U-03. U-03 has no direct shared-hall door.
- U-04 retains independent shared-hall access; both U-03 ↔ U-06 and U-06 ↔ U-04 links remain required. U-05 remains primary-only.
- Selected-D room dimensions and areas, 36×32 ft upper-wing test envelope, 1/6 ft placement grid, nominal 0.5 ft wall band, source-derived 3.5 ft contact reservation, projected lift reservation, source upper landing and a 4 ft corridor sweep are inherited study inputs. Contact reservations are not clear door widths. The stair approach and corridor are schematic route proxies.

## Reproduce the U-02-first directed search

From the repository root in Windows PowerShell 5.1:

~~~powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope U-02-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -NodeLimit 6000 -LayoutLimit 5000 -OutputDirectory 'Architecture/M42_U02_Anchored_Upper_Suite_Route_Study_2026-10-28'
~~~

Two clean U-02-first runs pass **27/27** generator checks and reproduce byte-for-byte. The checked-in artifacts parse as JSON and SVG/XML. SHA256: search.json 957AE6C169C7E63B95B1822E215D8B8F4C5AE6C1B1DA27B7BB855A13367B03A; checks.json 77BB9F2B64AC35F43A523EA1585CF69F36E7DB5E6600116BB73FE7D055318847; upper-suite-search.svg 23E0C966A4018DB2BE0108E018898E78D315BB488869F462F863D5519A9F9A81; manifest.json DA62A5FC93B6AF05514884DC151A14D9C0B02E6FFC5FCA7D716F42BFCA7BFADA.

## U-02-first result

The bounded run expanded **4,500/6,000** nodes across three valid landing-aligned U-02 root seeds; a fourth seed was rejected by its shell/approach check. It recorded **12** complete room-block packings and tested 4 ft corridor reachability in all 12. No layout reaches the required public-access trio U-01/U-02/U-04.

| Block | Reachable layouts | Interpretation |
|---|---:|---|
| U-01 | 0/12 | no sampled public-hall contact |
| U-02 | 12/12 | sampled public-hall side reachable |
| U-03 | 12/12 | corridor-side proximity only; not a door or public access |
| U-04 | 0/12 | no sampled guest-hall contact |

The search is explicitly incomplete. It does not establish that the topology is infeasible. The directed U-02-first branch order yields private-chain contact and sampled public reach to U-02 in its tested layouts, while failing to connect U-01 or U-04 to the sampled public corridor.

## Complementary U-04-first stress search

The same search was run with -RootSearchScope U-04-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -NodeLimit 6000 -LayoutLimit 5000. It passed **27/27** checks but produced no complete seven-room packing, so no corridor was tested. Increasing the limit to 12,000 expanded **9,000/12,000** nodes and produced **2** complete layouts and **2** corridor tests. The route reached U-02 and U-04 in both, but U-01 in neither; the required trio was not reached. The search remains incomplete. This 12,000-node stress run is a single deterministic run, not independently replayed; its generated outputs and manifest are retained under u04-first-12k/.

The retained stress-run SHA256 values are search.json 80AB91766FBE0B02AFF7558E497BACE11592E8AEF02AC61F90A8A834FCD66828; checks.json 9CEFC7269DA159981D8DD7624FF57FEDCF3EE462E158328829953EF8B8D9AD78; upper-suite-search.svg A5349E98C80B9C00DCA9555C17412A31A850858550624BD58A7B50CCA6A8382D; manifest.json 5DF127FBEB764043B8C842D7902617EE0A0047886009CC44B8BA9528A8C4645E.

M37’s separate balanced 9,000-node run reaches U-01, U-02 and U-04 in different layouts, but no single tested layout reaches all three. M39 visualizes a partial case. These are search-order-sensitive bounded results, not proof of a design impossibility. The two directed tests expose a practical limitation in the current tree search: U-02-first packs and routes one branch; U-04-first barely yields route-tested layouts. Corridor feasibility is checked after complete room packing rather than guiding the search.

## Limits and next work

Room rectangles and contact bands are not walls or doors. The 3.5 ft edge reservation is inherited source data, not verified clear opening or code clearance. The 4 ft path is a swept-square plan proxy on a 2 in translation grid; the study does not verify door leaves/swings, landing maneuvering, stair geometry/headroom, floor openings, furniture, services, structure, code, accessibility, Revit or IFC. No room block was adopted; selected-D geometry and M-06 B remain unchanged. No safety, code-compliance, professional-certification or construction-readiness conclusion is made.

Next, improve the search by incorporating public-route reachability during placement enumeration, then run a bounded comparison before seeking an owner trade-off. If the refined search still cannot preserve U-01/U-02/U-04 public access with the private-only U-03 sequence, present the smallest evidence-backed room/core trade-off before changing the selected-D baseline.
