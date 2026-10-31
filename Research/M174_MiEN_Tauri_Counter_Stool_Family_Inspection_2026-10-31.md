# MiEN Tauri counter-stool geometry and fit gate

**Status:** product height verified from manufacturer; Revit symbol geometry inspection prepared but not yet run. No stool or seating arrangement is selected.

## Manufacturer evidence

MiEN identifies the Tauri counter stool `TAURI-STL-24-N-N` at a 23.75 in seat height. Its current [Tauri product page](https://miencompany.com/product/tauri/) lists counter stools at 23.75 in. The current [4-leg chair and stool cut sheet](https://miencompany.com/wp-content/uploads/2025/10/tauri-4-leg-chair-cut-sheet-g003.pdf) gives counter-stool seat height as 23.75 in. The project kitchen specification asks for two stools with a 24–26 in seat height. The Tauri is therefore 0.25 in below the written lower bound; do not round it to 24 in or alter the specification silently.

The product page describes the Tauri as student seating with an ergonomic, winged shell. That shape may project beyond a conventional rectangular stool footprint, so a generic 24-in-deep occupancy box is not a substitute for its actual symbol envelope or seated-use area.

## Quarantined family provenance

- Public manufacturer symbol bundle: MiEN Tauri counter and cafe stools, downloaded from the product's public symbols link without an account.
- Counter family: `.local/revit-pilot/family-intake/candidates/m174-mien-tauri-stool/TAURI-STL-24-N-N.rfa`.
- SHA256: `720F3F1D172285E62C6B4EC0ECEE3A31421DA34B8926AD4D80B30C9B9572F53D`.
- The adjacent `source.json` records the public product page, symbol library, bundle hash and this member-family hash. Source is retained in ignored quarantine, not selected or placed.

## Revit inspection readiness and limits

`Tools/RevitPilot/CandidateFamilyGeometryCommand.cs` compiles in the project-local Revit 2027 build `build-m189-m06-candidate-geometry`. It measures axis-aligned family-symbol bounds from positive-volume solids after applying nested transforms, records type parameters and source/derivative hashes, and refuses sources outside quarantine or outputs outside isolated derivatives. It does not place an instance or open selected-D.

The local request is prepared for the exact counter-stool file and hash. The per-user manifest was backed up under ignored `.local/revit-pilot/registration-backups/20261031T144042272Z/` and now points to the hash-checked repository-local DLL. Revit is still running the previous session; the current computer-use surface reports the Revit window's accessibility state unavailable, so this session has not restarted Revit, accepted any load prompt, or claimed a host measurement. Do not overwrite the source RFA or selected-D.

The symbol bounds, once captured, will describe product geometry only. They will not establish occupied posture, pull-back distance, side spacing, circulation, comfort or code compliance. Use the measured symbol to replace the assumed body rectangle, but preserve the separate occupied-use and route checks.

## Next gates

1. Restart Revit without discarding any open work, then load **once** only if the trust prompt identifies the exact local RevitPilot DLL and SHA256 in the registration record.
2. Run the prepared quarantined-family geometry request and validate its report with `Tools/RevitPilot/validate_candidate_family_geometry.ps1`.
3. Re-run the route sensitivity with the measured stool body plus a separately labeled use-envelope assumption; retain M-06/B as unassigned.
4. Ask the owner whether a quarter-inch difference from the selected seat-height range is acceptable only if the measurement survives host/orientation review and the product is otherwise under consideration.

This is not a product approval, accessible seating check, code review, structural assessment, or construction-ready design.
