# M318 — main-floor wall/plate provenance coordination gate

## Purpose

M313 produced a disposable 40 × 42 ft main-floor native-wall candidate. M314 reopened that exact RVT and added three translated provisional floor plates. This milestone independently checks that the floor derivative still points to the byte-identical M313 source, preserves the 42-wall inventory, and contains the three documented 40 × 42 ft comparison plates at the recorded display offsets.

This is a provenance and inventory gate, not a selected-D edit or a coordinated building model. The plates use the Revit template's default floor type; no structural or finish assembly is selected.

## Reproduce

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/validate_main_floor_coordination_chain.ps1 `
  -CandidateManifestPath '.local/revit-pilot/main-floor-candidate/20261101T215346325Z/manifest.json' `
  -FloorPlateManifestPath '.local/revit-pilot/main-floor-floor-plate/20261101T220743680Z/floor-plate-manifest.json' `
  -Output '.local/revalidation/m318-main-floor-coordination.json'
```

The validator checks both saved-RVT hashes, the source chain, 42-wall preservation, three plates, 0/60/120 ft display offsets, 40 × 42 ft / 1,680 sf profiles, and explicit unselected status. It does not infer floor-to-floor spacing from the display offsets.

## Limits

No actual doors, openings, stairs, roof, structure, MEP, finish assemblies, clearances, code applicability or professional review is established. The Selected-D source and retained IFC remain untouched. M-06 and B remain unassigned.
