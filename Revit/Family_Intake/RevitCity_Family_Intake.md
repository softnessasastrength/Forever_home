# RevitCity family intake

Status: **prepared; no external family downloaded or approved**

Use this intake for granular family selection after the C-study geometry is stable. Do not bulk-download or assume a RevitCity family is safe, parametric, licensed for reuse, or compatible with Revit 2027.

## Intake record

| Field | Required evidence |
|---|---|
| Family role / room ID | e.g. `M-06` main bath vanity, `U-06` Jack & Jill fixture |
| RevitCity URL and author | Source attribution; no private account data |
| File type / Revit version | RFA/RVT, origin version, upgrade path |
| Category and hosting | Door, Window, Plumbing Fixture, Furniture, etc.; wall/face/level host |
| Type and instance parameters | Dimensions, clearances, connectors, materials, visibility controls |
| Geometry budget | Polycount/detail level, nested families, imported meshes |
| Product/source status | Concept placeholder vs selected product; manufacturer/manual link if applicable |
| License/reuse note | Record visible terms; do not redistribute restricted files |
| Test result | Loads, places, schedules, exports, reopens; record failures |

## Review gates

1. Select the room, role and target dimensions before searching.
2. Download only to a quarantined local intake folder; never overwrite the authoritative model.
3. Open in a disposable Revit 2027 test file and inspect category, host, type catalog, nested content, warnings and materials.
4. Check nominal clearance envelopes and service/replacement paths against the C study.
5. Add only accepted families to the working model; preserve the original file and record any upgrade.
6. Re-run the room/ID manifest, schedules and export checks after each accepted family batch.

## Initial candidate groups

- Doors and windows: only after wall-host and nominal clear-opening tests.
- Bath fixtures: vanity, toilet and shower placeholders; accessibility and plumbing coordination remain open.
- Kitchen appliances: perimeter induction, sink, dishwasher, refrigerator; island remains appliance-free per current decision.
- Living equipment: pellet-hearth placeholder and CRT/service envelope; exact products and clearances remain unresolved.
- Lift: product-specific family only after manufacturer layout, pit, overrun and landing review.

No family is approved by being visually attractive or by loading without warnings. A family is accepted only with evidence in the intake record and a corresponding model/schedule update.
