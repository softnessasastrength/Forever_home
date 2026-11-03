# M377 — disposable interior design study

This package prepares the first interior-design derivative beyond the shell wireframe. It uses the source-fingerprinted Selected-D main-floor room blocks and creates three side-by-side native comparison cases at the owner-directed 8/9/10-ft clear-height range.

## Native content planned

- Native wall rectangles for the source M-01 through M-05 room blocks and the 40 × 42 ft shell.
- Native floor plates carrying the labelled F-01 engineered-oak display cue.
- An 8 × 4 ft appliance-free M-02 island proxy, preserving the documented kitchen direction.
- A labelled 9 × 10 ft U-05 primary-bath vignette with the separate-tub/tiled-rain-shower direction. It is deliberately outside the house shell because its final upper-level location and service geometry remain unresolved.
- A saved RVT, IFC2x3 export and machine-readable manifest.

## Boundaries

This is a disposable comparison, not Selected-D. The room-block partitions, island, floor and bath vignette are design coordination geometry. Wall/floor assemblies, openings, stair, roof, structure, MEP, code, accessibility and construction conclusions remain unresolved. M-06/B remains unassigned.

The command is `NativeInteriorDesignStudyCommand` and is registered as **Build interior design study**. Runtime is complete: Revit 2027.3 generated `.local/revit-pilot/interior-design-study/20261102T230602576Z/`; the saved RVT/IFC2x3 pair passes `Tools/RevitPilot/validate_interior_design_study.ps1` **11/11**. Revit reported 12 expected overlap warnings and 0 errors. The derivative remains disposable comparison geometry and is not selected-D, code-compliant, structurally engineered or construction-ready.
