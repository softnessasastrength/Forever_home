# M352 — Walkthrough coordination package gate

**Status:** retained-derivative lineage gate complete; a new composed RVT remains the next runtime action.

## Purpose

Verify that the already validated disposable studies can be carried forward together without changing Selected-D or silently selecting unresolved dimensions.

## Reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_walkthrough_coordination_package.ps1
```

The retained ignored output is `.local/revalidation/m352-walkthrough-coordination-package.json` and passes **9/9** checks.

## Evidence covered

- Selected-D source hash is unchanged.
- M333 roof-shell derivative contains three unselected native roof options and non-empty RVT/IFC files.
- M328 landing derivative contains a positive-area native landing bridge and RVT/IFC files.
- M315 floor-plate derivative contains three provisional plates.
- M349 integrated main-floor derivative contains 57 walls, 12 unselected nominal doors, and IFC wall/door entities.
- M-06 remains `TBD` in Selected-D.

## Limitation

This gate does **not** create a new composed RVT. Roof pitch, floor-to-floor datum, wall/floor assemblies, stair continuation, structure, MEP, and M-06 remain unselected or unresolved. The next runtime milestone is a disposable Revit composition that reopens or recreates these inputs and then receives its own RVT/IFC/reopen validation.
