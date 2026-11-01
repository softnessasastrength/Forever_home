# Clear-ceiling wall-height comparison basis

Date: 2026-11-01

## Owner-selected inputs

- Use Selected-D as the current plan-envelope basis: main 40 × 42 ft; lower and upper rear envelopes 36 × 32 ft.
- Show 8, 9 and 10 ft as clear-ceiling alternatives.
- Leave floor-to-floor elevations and the stair unresolved.

## Geometry scope

Generate three isolated, single-level comparison models, one for each Selected-D shell footprint. Each model displays the 8-, 9- and 10-ft alternatives side by side at a local zero datum. The side-by-side model-space offsets exist only to make the height comparison visible. They are not site coordinates, connected storeys, or building placement.

Use native Revit Basic Walls and the blank Imperial template's first deterministically sorted basic wall type as a temporary visualization placeholder. Give each wall a height matching its labeled clear-height case, with the wall top serving only as the nominal clear-height reference. No floor, ceiling, finish, or structural assembly is modeled; therefore the geometry is a clear-height proxy, not a coordinated wall or section detail. The plan rectangles use the Selected-D envelope dimensions, with each comparison translated to a local origin.

Do not create floor datums above or below the local base, stack the three shell types, model stairs or openings, or infer an assembly thickness. Preserve the source study and its Revit/IFC outputs. All generated RVTs and manifests belong in ignored `.local/revit-pilot/clear-ceiling-wall-height/<timestamp>/`.

This comparison does not establish code compliance, structural safety, accessibility, professional approval, permit approval, or construction readiness.
