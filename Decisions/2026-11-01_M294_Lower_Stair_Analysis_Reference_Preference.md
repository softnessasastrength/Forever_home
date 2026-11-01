# M294 lower stair/circulation reference preference

Date: 2026-11-01
Status: **Owner-selected analytical reference; not selected-D geometry and not an instruction to create native Revit stair objects.**

The owner prefers the **least layout change** option from M289 and accepts its **tangent geometry** for further analysis. This preference resolves M290's comparison question in favor of the minimum combined block-change reference, not the larger-change option with a positive measured gap.

## Referenced M289 candidate

- Combined absolute block-change score: **1.1193 ft** (ranking metric, not physical travel distance).
- L-01: same area **250.5556 sq ft**, candidate rectangle **13.5 × 18.5597 ft** at approximately `(9.6667, 12.7737) ft`.
- C-LOWER: source position and same area retained, **6.6667 × 11.8333 ft** at approximately `(10.1667, 0.6667) ft`.
- Stair envelope: east-west, **10.375 × 3.1667 ft** at approximately `(24.9167, 12.1667) ft`, using the M285 six-riser / five-tread / two-landing depth comparison.
- Route proxy: **9.25 ft**, two orthogonal turns, using M215's 36-in project screening precedent; proxy occupation in C-LOWER is **0.4583 sq ft**.
- The stair/path proxy is **0 in** from the candidate L-01 rectangle: exact tangency at the abstract rectangle level. The owner accepts that tangency as a comparison preference.

## Boundaries

This selects a preference for continuing the analysis. It does not select room dimensions or a physical stair, change selected-D, move a floor datum, authorize a Revit/IFC object, or establish access, code compliance, accessibility, structure, or buildability. Tangency has no allowance for actual wall thickness, finishes, tolerances, railings, door leaves, or installation geometry. Those remain unresolved. Keep both M-06 search windows protected; M-06/A/B remain unassigned and west A protected.

The 43½-in owner-preferred rise also remains **16½ in short** of each 60-in selected-D level transition. Resolve that section relationship and the actual stair opening/landing approach before proposing native stair geometry.

## Evidence

Source study and reproduction: `Architecture/M289_Joint_Lower_Stair_Circulation_Study_2026-11-01/README.md`. Residual partition: `Architecture/M290_Circulation_Residual_Partition_2026-11-01/README.md`. Current-checkout replay and CT screening: `Architecture/M293_CT_Stair_Reproducibility_2026-11-01/README.md` and `Research/CT_Stair_Geometry_Checklist_2026-11-01.md`.
