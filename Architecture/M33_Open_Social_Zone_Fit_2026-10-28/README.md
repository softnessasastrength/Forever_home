# M33 — open kitchen/dining furniture and clearance screen

Status: **one reproducible schematic candidate; not coordinated building geometry**.

This screen tests the owner's 14 × 12 ft kitchen and 11 × 10 ft dining targets as one open social zone, preserving the selected-D island geometry and using the dining table and clearances documented in `Architecture/Kitchen_Dining_Porch_Specs.md`. It does not change either source study or assign M-06 B.

## Reproduce

From the repository root, run Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m33_open_social_zone_fit.ps1
```

The generator writes `fit.json`, `checks.json`, `open-social-zone.svg` and `manifest.json` to this directory. Use a fresh repository-local scratch path to verify repeatability:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m33_open_social_zone_fit.ps1 -OutputDirectory '.local/revalidation/m33-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m33_open_social_zone_fit.ps1 -OutputDirectory '.local/revalidation/m33-b'
```

Compare SHA256 hashes of all four output files across runs. The generator checks the selected-D fingerprint recorded by the owner-follow-up study and refuses an output path outside the repository.

## Result

- **14/14** explicit source, target, containment, non-overlap and comparison-core checks pass.
- The table body is 60 × 36 in, with its long axis along x, centered in M-03. Its placement is an inspectable candidate, not an owner-selected furniture layout.
- The source-derived 36 in minimum chair pull-back envelope fits the M-03 rectangle exactly. The documented 42 in preferred wall/door clearance envelope extends 0.5 ft beyond M-03 at each side and at its rear edge.
- The retained 8 × 4 ft island body and its 42 in envelope clear the table body and 36 in table envelope. The island envelope extends 2.167 ft east and 1.5 ft north beyond M-02 into otherwise unassigned shell area. This is consistent with treating kitchen and dining as an open zone, subject to a real plan proving those areas remain available.
- Island and table candidate envelopes clear the comparison stair/lift rectangles and the empty, unassigned M-06 B search window.

## Limits and next work

The screen models room-block rectangles and furniture bodies only. Perimeter cabinets, the half wall, sink/range/hood/refrigerator/dishwasher, appliance-open envelopes, wall thicknesses, door locations/swings, porch geometry, seated-chair extents, and a separate continuous route from dining to porch remain unmodeled. The zero gap between the island's 42 in envelope and the table's 36 in envelope is a boundary contact between unlike clearance tests, not proof of a usable circulation route. Resolve cabinetry and circulation before treating this as a workable layout.

M-06 B remains an empty search window: no fixture, room footprint, door/approach or service route is assigned. No Revit edit, IFC export, code-compliance review, accessibility finding, structural analysis or construction-readiness claim is made. The proposal's Connecticut code context remains subject to a municipality, site and permit date.
