# House design iteration — owner follow-up, 2026-10-28

Status: **separate schematic proposal; selected-D baseline preserved**.

The owner directed a private primary → boutique → hybrid suite sequence, returned the social-room study targets to kitchen 14 × 12 ft and dining 11 × 10 ft, requested a steep-roof exploration, and identified Connecticut for code research. The owner later superseded the earlier U-03 shared-hall choice: the current proposal gives U-03 the private route only, with no direct shared-hall door. The owner has now also required direct shared-hall arrival to U-02 while preserving its private links to C-PRIVATE and U-03. Guest hall access and both Jack-and-Jill links remain. The exact decision history and tradeoffs are in [the follow-up decision](../../Decisions/2026-10-28_House_Design_Direction_Followup.md).

## Files and reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_owner_followup_design.ps1
```

- `study.json`: source fingerprint, room blocks, upper-suite topology target, roof inputs and limitations.
- `checks.json`: 18 named room-block, adjacency, unassigned-M-06, topology and fit-screen checks, including the owner-required direct U-02 shared-hall edge.
- `main-plan.svg`: proposed local-coordinate room blocks, comparison core and unassigned M-06 B search window.
- `roof-concept.svg`: qualitative, not-to-scale steep-gable section prompt.
- `manifest.json`: input and generated-output hashes.

Coordinates use the selected-D schematic convention (feet; x right, y toward rear); they are not a survey or georeference. The 40 × 42 ft main shell is still a test envelope. The proposed entry is near its local west edge, not an approved entry orientation. The 0.5 ft block separations carry forward a nominal wall allowance; they are not wall faces, clear openings or door widths.

## Main-floor proposal

| ID | Study block | Proposed origin (ft) | Test size (ft) | Area |
|---|---|---:|---:|---:|
| M-01 | Living | (5.5, 0.667) | 16 × 15 | 240 sf |
| M-02 | Kitchen | (22, 0.667) | 14 × 12 | 168 sf |
| M-03 | Dining | (22, 13.167) | 11 × 10 | 110 sf |
| M-04 | Pantry | (31.5, 23.667) | 5 × 7 | 35 sf |
| M-05 | Entry / hall | (0.667, 10.667) | 4.333 × 12 | 52 sf |

These rectangles fit the test envelope, do not overlap one another or the inherited comparison stair/lift rectangles, and create nominal 6 in block adjacencies for kitchen–living, kitchen–dining, dining–pantry and entry–living. They establish no actual wall or passage. Dining-to-porch access, the porch itself, entry door/approach, windows, half wall and furnished routes still require layout work.

The pantry's proposed placement defines a smaller **72.33 sf gross** pantry-side M-06 search window east of the comparison core. The empty window clears this proposal's room and core rectangles; it is not an M-06 footprint or fixture fit. Keep it unassigned until actual product envelopes, applicable clearance basis, door/approach and a service route support placement.

## Kitchen fit gate

Within M-02's 14 × 12 ft room block, the inherited 8 × 4 ft island plus 42 in clearance at each end of its 8 ft axis requires 15 ft, which exceeds either block axis. This is before perimeter cabinets, half wall, seating, appliance-open envelopes and tolerance. The separate older 24 in counter + 42 in aisle + 48 in island + 42 in aisle + 6 in half-wall chain totals 13 ft 6 in; the 14 ft axis leaves only 6 in and the 12 ft axis is 18 in short. A first combined island/table screen is now recorded in [M33](../M33_Open_Social_Zone_Fit_2026-10-28/README.md). It demonstrates one open-zone furniture-body candidate and specified rectangular clearances across the nominal kitchen/dining blocks. It does not place counters or prove the continuous dining-to-porch route. The study reports the original block-fit conflict rather than shrinking a requirement by arithmetic magic.

## Upper-suite intent

The current topology target adds U-02 → U-03 to U-01 → C-PRIVATE → U-02, requires direct U-02 → C-UPPER arrival, excludes a direct U-03 → C-UPPER edge, and retains guest C-UPPER access plus U-03 ↔ U-06 ↔ U-04 Jack-and-Jill access. This is a revision of earlier same-day owner choices. `study.json` records the access graph; corridor, room-block rearrangement, walls, openings, door swings and privacy/acoustic performance remain unresolved. A sampled corridor-side goal is not an actual door or clearance check. The first direct-adjacency fit screen is in [M34](../M34_Upper_Suite_Private_Link_2026-10-28/README.md): one westward U-03 shift overlaps the current hall and lift reservation, so the private route remains an intent rather than demonstrated geometry.

## Roof concept and code context

`roof-concept.svg` depicts a steep gable qualitatively and explicitly not to scale. Pitch, ridge direction/elevation, roof intersections over the rear wing, assemblies, drainage, snow/wind inputs and structure remain TBD. Connecticut DAS currently identifies the 2022 State Building Code as adopted; its official adoption page reports the 2026 update delayed pending legislative approval. A town/parcel and permit date are needed to confirm local requirements and the applicable code at filing. See the linked primary sources in the follow-up decision. No code, structural or construction claim is made.

## Validation boundary

Re-running the script twice into fresh scratch directories should produce identical four study artifacts and pass 17/17 explicit checks. Passing checks cover only rectangle containment/overlap/adjacency, clearance from comparison-core rectangles, target room arithmetic, the unassigned search gap, the revised access graph and the recorded kitchen-fit shortfall. The generator refuses output paths outside the repository root. No Revit host action or IFC export was performed for this proposal. The saved selected-D Revit/IFC evidence remains a separate space-study baseline with no walls, slabs, stairs, doors or windows.
