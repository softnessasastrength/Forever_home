# Verified BIM milestone — 2026-11-01

This is the current local-sandbox handoff for the Forever Home architectural BIM pipeline. It records what is reproducibly verified and what remains deliberately unresolved. It is not a claim of code compliance, structural safety, professional approval, permit readiness, or construction readiness.

## Verified evidence

| Area | Evidence | Result |
| --- | --- | --- |
| Selected-D source geometry | `Tools/validate_architectural_bim_baseline.ps1`; `.local/revalidation/architectural-bim-baseline-20261101T-recheck/` | Two independent replays pass 43/43; seven artifacts per replay match byte-for-byte; six SVGs parse. |
| Selected-D retained IFC | Same baseline report | IFC2x3 passes 26/26 with zero errors; protected source, RVT and IFC hashes remain unchanged. |
| Native main-floor walls | M313 run and reopen audit | Disposable Revit 2027.3 derivative contains 42 native walls and 252 model curves; reopen inventory passes. |
| Provisional floor plates | M314/M318 | Exact M313 source chain preserved; three 40 × 42 ft / 1,680 sf provisional plates at display offsets 0/60/120 ft; M318 passes 9/9. |
| Floor-plate IFC | M315 | IFC2x3 export passes 6/6, including 42 walls and three slab entities. |
| Roof comparison | M83 host runs | Six open-mesh 8:12/10:12/12:12 comparisons with both ridge axes; independent IFC checks pass 21/21. No native roof is selected. |
| M-06 family evidence | M270/M317 | Public KOHLER Cimarron family inspected in an isolated derivative; positive solids and sanitary connector recorded; 8/8 evidence replay passes. No instance is placed in Selected-D. |
| M-06 envelope screen | M320 | Current-SKU plan proxy plus research lavatories: 14/14 checks and 16/16 gross containment pairs. B remains unassigned. |
| M-02 island furnishing IFC | M321 | Isolated Revit 2027.3 furnishing derivative passes IFC2x3 validation 13/13 with matching audit/export lineage. |
| Native split-rise stair study | M325 | Disposable Revit 2027.3 derivative contains two native stairs with four risers each across 0/2.5/5 ft datums; RVT hash and IFC2x3 stair export pass 15/15. |
| Offline RevitPilot contracts | Current checked-in test suite | 49/49 tests pass; RevitPilot build completes with zero errors and the repository's existing Autodesk reference-conflict warnings. |

## Reproduction commands

Run from the repository root. Outputs must remain under ignored `.local/revalidation/` unless a README names a tracked artifact destination.

```powershell
pwsh -NoProfile -File Tools/validate_architectural_bim_baseline.ps1 `
  -OutputDirectory .local/revalidation/baseline-replay

pwsh -NoProfile -File Tools/RevitPilot/validate_main_floor_coordination_chain.ps1 `
  -CandidateManifestPath .local/revit-pilot/main-floor-candidate/20261101T215346325Z/manifest.json `
  -FloorPlateManifestPath .local/revit-pilot/main-floor-floor-plate/20261101T220743680Z/floor-plate-manifest.json `
  -Output .local/revalidation/m318-main-floor-coordination.json

pwsh -NoProfile -File Tools/build_m120_m06_current_envelope_screen.ps1 `
  -OutputDirectory .local/revalidation/m320-m120-current-envelope

python Tools/RevitPilot/validate_kitchen_island_ifc.py `
  .local/revit-pilot/exports/20261028T003116629Z `
  .local/revit-pilot/audits/20261028T003043114Z `
  Architecture/Selected_Design_Iteration_2026-10-27/study.json

pwsh -NoProfile -File Tools/RevitPilot/validate_m324_native_stair_ifc.ps1 `
  -StudyDirectory .local/revit-pilot/split-rise-native-stair/20261101T225749874Z

pwsh -NoProfile -File Tools/validate_verified_bim_milestone.ps1
```

The Revit-dependent runs require Revit 2027/2027.3 and the exact hash-verified project-local RevitPilot DLL under the repository authorization. Select **Load Once** only for that matching path and hash.

## Remaining gates

- Selected-D remains a 21-space room-boundary study, not a finished house model.
- Native wall, floor and stair candidates are disposable comparisons; wall types, layered floor assemblies, openings, doors, stairs, roof assemblies, structure, MEP, finishes and site geometry are not selected.
- The stair/section and floor-to-floor relationship remains unresolved. The 8–10 ft values are clear-height study alternatives, not storey spacing.
- M-06 exact current-SKU family geometry, finished-face clearance, door/approach, and a plausible water/waste/vent service route remain unproven. Keep A protected and B unassigned.
- Kitchen/living/dining/pantry openings and furniture routes remain schematic; the isolated M-02 furnishing derivative is not a whole-house coordination result.
- Connecticut research values are preliminary screening inputs only. Confirm municipality, permit date, code path, accessibility scope and professional review before any compliance claim.

## Repository safety

Work remains on the local sandbox branch. No remote state was changed, no history was rewritten, and unrelated existing worktree edits remain preserved and unstaged.
