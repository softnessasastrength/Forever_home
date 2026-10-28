# M37 - upper-suite room packing and public-hall route screen

Status: **bounded search completed; no candidate satisfies the current room-link, lift-clearance and public-route requirements. This is not proof that no arrangement exists.**

## Owner inputs carried forward

- Preserve the source room areas and primary-only U-05 bathroom access.
- Provide the owner-directed private path U-01 -> C-PRIVATE -> U-02 -> U-03.
- Retain guest hall access and the U-03/U-04 Jack-and-Jill relationship through U-06.
- The owner confirmed on 2026-10-28 that U-03 also retains shared-hall access alongside the private link.
- Keep the 4 ft stair-to-upper public hall test and source lift reservation visible; neither is detailed construction geometry.

## Reproduce

From the repository root, Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -OutputDirectory '.local/revalidation/m37-repeat'
```

The generator fingerprints selected D, the owner-follow-up proposal and `Requirements/Room_Program.md`, rejects output outside the repository, and emits ordered JSON/checks/SVG/manifest artifacts. Compare artifact hashes across the two output directories to verify reproducibility. The checked-in `manifest.json` records output hashes.

## Method and result

The script packs the seven selected-D upper blocks (U-01 through U-06 and C-PRIVATE) with source room dimensions, two block orientations where distinct, 0.5 ft nominal wall bands and 3.5 ft nominal contact reservations. The node budget is split evenly between both U-01 anchor orientations so the first depth-first branch cannot consume the whole search. It searches a 36 x 32 ft upper test wing. Source coordinates place the clipped 8 x 4 ft lift projection at x=21 ft 2 in, y=28-32 ft and the upper stair landing at the rear edge; the corridor search starts from the landing's source-derived center approach. It tests a 4 ft swept public corridor at a 2 in translation grid.

The default search reached its **1,500-node cap**, split evenly between both U-01 orientations. It recorded 332 unique layouts from 377 completed packings and tested 191 lift-clear route placements; 147 had a clear initial stair-approach square and reached the corridor search. U-01 and U-02 were each reached from the public hall in 0 cases, U-03 in 21 and U-04 in 63; none reached U-01, U-02 and U-04 together. It samples a bounded set of contact alignments and is not an exhaustive proof that no arrangement exists. A no-candidate result means the current screen has not produced a supported candidate. Preserve every unresolved room or access requirement rather than weakening it to make the diagram pass.

The 12/12 checks validate source fingerprints, unchanged selected-D source during execution, source-derived dimensions/offsets, owner-directed topology and bounded search accounting. Two default runs produced byte-identical `search.json` (`D1B37CEE9E26F43A27BC0F303AE7417CA06D43D4BDD8C0622158E7CEA0D413A0`), `checks.json` (`44AF4EE76AC55FB21DFDA119006167C6BF37BEDB6AE9C851EF5A7D390BA5EC1E`), SVG (`C317A62BBC8210A7295CA7D60A1212C499F04F66D2C182CB1AA35A2D8E19E140`) and manifest (`A167B1600670DBCACC7AC40CA0780ADE60F09ABC40F6AA64D16B2989C11FD183`). Both JSON and SVG files parse in both outputs; the outside-repository path guard rejects its target without creating it. These checks do not turn a no-candidate result into an architectural rejection. A passing check count validates the setup and report integrity, not a viable layout.

## Limits and next work

This is a room-block and clearance-envelope screen, not Revit geometry. The nominal 3.5 ft reservations are source door-matrix values, not verified clear openings. The screen does not model partitions, actual door leaves/swings, corridor-door connections, landing shape beyond the source block, stairs, floor opening, headroom, furniture, finishes, structure, services, fire/life safety, code, accessibility, IFC or construction. The lift is an existing schematic reservation, not a selected product or shaft design.

Next: change the search ordering/strategy to reserve an explicit clear route from the upper landing before packing rooms, then repeat the source-dimension and owner-access gates. If a viable proposal emerges, inspect it in a disposable Revit derivative; do not change selected D. Separately test illustrative steep-gable pitch cases only as labelled proposals, with Connecticut code research remaining site-, municipality- and permit-date-dependent. No code-compliance, structural-safety, certification or construction-readiness claim is made.
