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
| Roof comparison | M333 native run; `.local/revit-pilot/native-roof-shell/20261102T041843122Z/` | Three native `FootPrintRoof` comparisons at 8:12/10:12/12:12; independent validator passes 13/13, including RVT/IFC hashes and IFCROOF. No native roof is selected. |
| Pantry door comparison | M218/M219 native run; `.local/revit-pilot/m218-pantry-door-study/20261101T212718036Z/` | Two fresh disposable RVTs compare swing into kitchen versus pantry; validator passes 9/9 with recorded hashes and native wall/curve inventories. No door family, rough opening, approach or selected-D edit is implied. |
| M-06 family evidence | M270/M317 | Public KOHLER Cimarron family inspected in an isolated derivative; positive solids and sanitary connector recorded; 8/8 evidence replay passes. No instance is placed in Selected-D. |
| M-06 envelope screen | M320 | Current-SKU plan proxy plus research lavatories: 14/14 checks and 16/16 gross containment pairs. B remains unassigned. |
| M-02 island furnishing IFC | M321 | Isolated Revit 2027.3 furnishing derivative passes IFC2x3 validation 13/13 with matching audit/export lineage. |
| Native split-rise stair study | M325 | Disposable Revit 2027.3 derivative contains two native stairs with four risers each across 0/2.5/5 ft datums; RVT hash and IFC2x3 stair export pass 15/15. |
| Compact-core native house derivative | M327 | Disposable Revit 2027.3 candidate audit records 17 rooms/78 walls/5 nominal doors/2 native stairs/3 floors with zero warnings; geometry QA has 0 issues; IFC2x3/DWG/PDF/CSV exports are non-empty and independent IFC validation passes with no errors. |
| Offline RevitPilot contracts | Current checked-in test suite | 53/53 tests pass; RevitPilot build completes with zero errors and the repository's existing Autodesk reference-conflict warnings. |

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

python Tools/RevitPilot/validate_compact_manifest.py `
  .local/revit-pilot/compact-core/20261101T230538811Z/study-manifest.json

python Tools/RevitPilot/validate_compact_ifc.py `
  .local/revit-pilot/exports/20261101T231519726Z `
  .local/revit-pilot/compact-core/20261101T230538811Z `
  --report .local/revit-pilot/exports/20261101T231519726Z/ifc-validation.json

pwsh -NoProfile -File Tools/validate_verified_bim_milestone.ps1
```

The Revit-dependent runs require Revit 2027/2027.3 and the exact hash-verified project-local RevitPilot DLL under the repository authorization. Select **Load Once** only for that matching path and hash.

## Remaining gates

- Selected-D remains a 21-space room-boundary study, not a finished house model.
- Native wall, floor and stair candidates are disposable comparisons; wall types, layered floor assemblies, openings, doors, stairs, roof assemblies, structure, MEP, finishes and site geometry are not selected.
- The M327 compact-core derivative is a valid native coordination test, not the selected house: it retains provisional floor types, generic nominal doors and a documented upper-stair landing gap.
- The stair/section and floor-to-floor relationship remains unresolved. The 8–10 ft values are clear-height study alternatives, not storey spacing.
- M-06 exact current-SKU family geometry, finished-face clearance, door/approach, and a plausible water/waste/vent service route remain unproven. Keep A protected and B unassigned.
- The pantry door comparison is the only currently document-supported native opening study; front/porch openings, wall assemblies, floor assemblies and other door families remain unselected.
- Kitchen/living/dining/pantry openings and furniture routes remain schematic; the isolated M-02 furnishing derivative is not a whole-house coordination result.
- Connecticut research values are preliminary screening inputs only. Confirm municipality, permit date, code path, accessibility scope and professional review before any compliance claim.

## Repository safety

Work remains on the local sandbox branch. No remote state was changed, no history was rewritten, and unrelated existing worktree edits remain preserved and unstaged.
## M333 native roof-shell study checkpoint

The disposable native roof study is now host-verified. `NativeRoofShellStudyCommand` created three side-by-side 40 × 42 ft `FootPrintRoof` elements from the documented 8:12, 10:12 and 12:12 options, exported IFC2x3, and saved an RVT. Because Revit retains the SaveAs handle during the command, `Tools/RevitPilot/finalize_native_roof_hash.ps1` records the RVT hash only after Revit closes. The final derivative is `.local/revit-pilot/native-roof-shell/20261102T041843122Z/`; RVT SHA256 `C1C2273F0CC7FEAFC6869617B5060DE2D247BC0899B1A1AFA456C18A636591B0`, IFC SHA256 `917E4F7674A932C68FA017C18AA2C1912E1F5DDCED324603266E60D82C40B31A`, validation **13/13**. This is a comparative roof shell only; it does not select pitch, assembly, framing, drainage, code path or structure.

## M328 native landing study checkpoint

The compact-core derivative has an explicitly open upper stair-to-floor gap. `CompactLandingStudyCommand` now defines a disposable native floor bridge from measured bounds and `validate_compact_landing_ifc.ps1` checks the expected manifest, RVT hash, positive bridge geometry and IFC2x3 floor marker. A controlled run produced `.local/revit-pilot/compact-core-landing/20261102T005830531Z/` with a 5.625 ft × 3.3333 ft bridge and saved RVT SHA256 `8d9bdf1901037828c3012e1b4bf8f3df16b8305e064ac34c906437e1b56e3f71`. IFC export exposed a Revit transaction requirement; the command now wraps export in a rollback transaction and requires one clean rerun. The corrected DLL is hash-checked and registered only at the project-local path. This study does not select a stair/landing or establish headroom, guard/rail, structural, accessibility, code, professional or construction readiness.
