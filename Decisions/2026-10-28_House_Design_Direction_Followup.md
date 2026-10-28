# Owner follow-up: house design direction — 2026-10-28

Status: **owner-directed inputs for a separate schematic proposal**. This record does not revise or replace the selected-D baseline.

## Owner direction

1. Make the hybrid room part of the private primary/boutique/hybrid sequence. Retain guest hall access and both hybrid/guest Jack-and-Jill links; retain primary-only access to the primary bath. The owner initially confirmed U-03 shared-hall access alongside the new private-suite link, then revised that choice later on 2026-10-28 to **private route only**: U-03 is to connect through U-02 and has no direct shared-hall door in the current proposal. The earlier confirmation is superseded. The route, location, walls and doors are not yet designed.
2. Return the kitchen and dining study targets to the earlier documented **14 × 12 ft** and **11 × 10 ft**, respectively. These are area-program study targets (168 sf and 110 sf), not approved finished dimensions.
3. Explore a steep traditional gable roof concept. Roof pitch, ridge orientation/elevation, spans, assemblies, openings and structure remain unassigned.
4. Use Connecticut as the code-research jurisdiction. The municipality, parcel, permit schedule and reviewing authority remain unknown.

## Owner revision — U-03 access (2026-10-28)

The latest owner direction supersedes the earlier same-day shared-hall choice: keep the U-01 → C-PRIVATE → U-02 → U-03 private sequence and omit a direct U-03 → C-UPPER door. Preserve the guest's independent shared-hall access and both Jack-and-Jill links (U-03 ↔ U-06 and U-06 ↔ U-04). This revises the schematic access graph only; selected D and its existing room/door data remain unchanged. Door placement, privacy, egress, walls and circulation still require design and Revit review.

## First schematic test

`Architecture/House_Design_Iteration_2026-10-28/` is a derivative room-block proposal generated from the selected-D 40 × 42 ft **test** envelope. It preserves the selected-D source files, Revit model and IFC evidence. Its five main-floor blocks pass shell containment, non-overlap, comparison-core clearance and adjacency arithmetic; M-06 B remains a gross unassigned search window. A private U-01 → C-PRIVATE → U-02 → U-03 route is captured as a topology requirement only. The upper room-block layout has not yet been rearranged to realize it.

The proposed entry is placed near the local west edge to fit the study blocks. This is not an approved front elevation, site orientation or entry door. The porch, exterior openings, walls and furnishings remain unplaced.

## Kitchen tradeoff exposed by the selected targets

The 14 × 12 ft M-02 block cannot contain the existing 8 × 4 ft island with 42 in clearance at both ends of its 8 ft axis: that axis needs 15 ft, exceeding either block axis (14 ft and 12 ft). This room-block screen excludes base cabinets, the half wall, seating, appliance-open envelopes and tolerance. The open kitchen/dining/living arrangement may provide usable space outside M-02, but that combined furnished route has not yet been tested. The separate documented counter/island/aisle/half-wall chain is 13 ft 6 in, leaving only 6 in in the 14 ft axis and exceeding the 12 ft axis by 18 in.

No island size, clearance target or room dimension has been silently changed. The next test should first use the documented open relationship to kitchen, dining and living, including the dining table, occupied seating, perimeter work surfaces and route to the porch. If that combined layout still fails, the design gate is to choose which input to revise: enlarge M-02, reduce/reconfigure the island and its seating/work arrangement, or revisit the target clearances with a designer. Until then, 14 × 12 remains a room-program target and the island is not fitted.

## Connecticut code research — preliminary, not a compliance review

The Connecticut Department of Administrative Services currently identifies the **2022 Connecticut State Building Code** as the adopted code, based on the 2021 I-Codes. Its adoption-process page says the next code package, expected in 2026, is delayed pending Legislative Regulation Review Committee approval. The actual code applicable to a future permit must be confirmed with the municipality and state authority at that time; the owner has not supplied a town or parcel.

The adopted 2022 code's IRC amendments address roof snow loading, while its IBC amendments require slope-related snow-load considerations for sloped roofs. A steep roof is therefore a form to explore, not a way to assume away snow loading. Site-specific loads, exposure, drifting, wind, roof geometry, framing and attachment require qualified design. No code-compliance, structural-safety, professional-certification or permit claim is made.

Sources checked 2026-10-28:

- [Connecticut State Building Code — regulations and adopted model codes](https://portal.ct.gov/en/das/office-of-state-building-inspector/connecticut-state-building-code/regulations)
- [Connecticut building and fire code adoption process — 2026 update delayed](https://portal.ct.gov/en/DAS/Office-of-State-Building-Inspector/Building-and-Fire-Code-Adoption-Process)
- [2022 Connecticut State Building Code, including amendments and errata](https://portal.ct.gov/-/media/DAS/Office-of-State-Building-Inspector/2022-State-Codes/2022-CSBC-Final.pdf)

## Reproduce and limits

From repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_owner_followup_design.ps1
```

The generator records the selected-D source fingerprint and emits the proposal JSON, geometry/fit checks and SVGs. Its passing result validates only the stated room-block arithmetic and topology contract. It does not model native Revit walls, doors, roof solids, site, services or structure; it does not determine code applicability or prove accessibility, egress, or construction readiness.
