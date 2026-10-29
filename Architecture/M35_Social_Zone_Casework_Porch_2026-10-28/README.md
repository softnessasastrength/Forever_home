# M35 — social-zone casework, occupied chairs and porch route

Status: **one measured schematic candidate; not owner-selected or coordinated Revit geometry**.

This study advances the owner-directed 14 × 12 ft kitchen and 11 × 10 ft dining targets. It tests a perimeter appliance run, the existing 8 × 4 ft appliance-free island, a short half wall, four source-sized dining chairs, a 36 in path to a 5 ft French-door opening, and two 12 × 10 ft porch positions. The selected-D source, Revit model and IFC baseline remain unchanged. M-06 B remains unassigned.

## Reproduce

Windows PowerShell 5.1, from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m35_social_zone_casework_porch.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m35_social_zone_casework_porch.ps1 -OutputDirectory '.local/revalidation/m35-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m35_social_zone_casework_porch.ps1 -OutputDirectory '.local/revalidation/m35-b'
```

The default output is this directory. Compare SHA256 for `fit.json`, `checks.json`, `social-zone-casework-porch.svg` and `manifest.json` from the two scratch runs. The generator checks source fingerprints and rejects output paths outside the repository.

## Findings

- **29/29 checks pass.** The screen reuses dimensions and nominal clearance values in `Architecture/Kitchen_Dining_Porch_Specs.md` and the selected-D island source.
- The M33 baseline island/table placement has a **5.166667 sf** overlap between the island's 42 in envelope and the table's preferred 42 in envelope. Shifting the island 0.5 ft south preserves its 8 × 4 ft body inside M-02 and removes that overlap. The resulting island-to-table bodies leave 7 ft between them; their preferred clearance envelopes meet at a boundary.
- A proposed 24 in-deep south-wall run fits the listed 36 in refrigerator-width reservation, a 36 in sink-base option, an adjacent 24 in dishwasher, and a 30 in range with 12 in counter landing each side: **150 in of 168 in**, with 18 in left unallocated. The resulting south-counter-face to island-body aisle is exactly **42 in**. The refrigerator's depth, product opening envelope, range product, sink choice, exact filler/cabinet arrangement and counter details remain unresolved.
- A proposed 6 ft-long, 6 in-thick half wall uses the low end of the specification's 8 ft ± 12 in range and leaves a 6 ft continuous opening to living. Its nearest edge clears the island envelope.
- Four chairs use the specified 18 × 20 in footprints. The east side is left chair-free, giving a distinct 36 in table-to-porch route that reaches the proposed 5 ft French-door opening. The candidate porch continues that 36 in band to a proposed 3 ft exterior opening. Door leaf clearances and swings, stools at the island, occupied people, thresholds, landings and grade are not modeled.
- The **east porch** candidate is 12 × 10 ft, sits beside dining with a nominal 6 in wall zone, clears B, the island envelope and selected-D comparison-core rectangles, and projects 5.5 ft beyond the 40 × 42 ft main-shell test boundary. It meets the pantry block along an edge without positive-area overlap. Its orientation is a proposal, not a site decision.
- The **north porch** candidate occupies **70 sf** of the pantry-side M-06 B gross search window. It is not carried forward in this arrangement. B remains unassigned; its footprint, fixture, clearance basis, approach, door and service route are still unresolved.
- The island's 42 in envelope extends 2.167 ft east of M-02 and 0.5 ft into M-03. Those spaces must remain open; the room-block study does not establish the finished walls or actual counter faces.

## Limits and next work

This is an axis-aligned plan-envelope screen, not a coordinated room layout. It does not model the island stools required by the source specification, appliance-depth/opening envelopes, cabinetry doors/drawers, plumbing or hood duct, wall solids, door leaves/swings, a site, roof intersections or Revit/IFC geometry. The 36 in route is a proposal checked against the four placed chair rectangles, not an accessibility or code determination. Connecticut code applicability still needs a municipality, site and permit timing. No code, structural, professional certification, permit or construction-readiness claim is made.

The M72 screen now compares the documented two-stool/12 in overhang inputs against NKBA's 24 in frontage and 15 in knee-space recommendations for a nominal 36 in counter. It does not resolve actual stool product/body geometry or the island section. Next design work remains exact appliance operating envelopes and actual stool/approach placement, then comparison of the east porch against a site-oriented entry/garden layout. No room target, fixture, door or M-06 placement was silently selected by this study.
