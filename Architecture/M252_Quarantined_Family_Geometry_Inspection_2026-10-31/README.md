# M252 - Quarantined Champion PRO bowl geometry inspection

**Status:** Revit geometry inspection completed in an isolated derivative. The inspected family is a predecessor bowl-only product, not the selected complete 610AA001.020 toilet; no M-06 placement or assignment follows.

## Scope

The owner indicated the Revit setup should be ready. In Revit 2027.3, the local RevitPilot `Inspect quarantined family geometry` command was run against the staged request for `american-standard-champion-pro-3195A101020-bowl.rfa`. The request pins the source to SHA256 `F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393` and disables the synthetic wall-host probe.

The command created a new Imperial project derivative at the ignored path `.local/revit-pilot/family-intake/derivatives/M250-champion-pro-bowl-geometry/`. It did not open selected-D, place a family instance, create a host probe, edit the source RFA, or change the selected-D/RVT/IFC baseline. Revit's report records the same expected source hash before and after inspection.

The per-user manifest was checked against the authorized AddInId `096B0D51-8883-4B3D-BD31-E9622201E785` and resolves to the current checkout's `.local/revit-pilot/m244-isolated-build/Release/net10.0-windows/RevitPilot.dll`, SHA256 `DAA178628A94057B9DA6A3F66175FD2CE4F58F4F496E92192369A27C16C4B0EC`. The Revit journal records this manifest loading with `NoError` and the measurement-complete dialog. No trust preference was changed in this run.

## Measured symbol geometry

Revit 2027 build `27.3.0.28` found three types: `3195A101.020`, `3195A101.021`, and `3195A101.222`. Each has six positive-volume solids and the same axis-aligned family-symbol bounds of **14.1253 x 29.1884 x 17.1581 in** (X x Y x Z). Total positive-solid volume is `1.283279 ft^3`. The bounds are family-symbol coordinates; this test did not place or orient the bowl in a room.

The report categorizes the family as Plumbing Fixtures and its placement type as WorkPlaneBased. This is evidence for the bowl component only. It does not represent the current selected 610AA001.020 complete toilet and cannot be used to approve a bathroom, clearance, door, approach, accessibility, or service route. West A remains protected for study; east B and M-06 remain unassigned.

## Evidence and checks

The Revit-generated JSON report is `.local/revit-pilot/family-intake/derivatives/M250-champion-pro-bowl-geometry/candidate-family-geometry.json`. It records:

- Schema `forever-home-candidate-family-geometry-v1`, status `pass`, Revit 2027 and zero placed instances.
- Source hash before/after: `F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393`.
- Derivative RVT SHA256: `C8284793D66E11BD0DD265B0159EC7C62392710E1F7B5E23EB90A0B9F00FE55E`.
- Three measured types with positive-volume solid bounds and explicit limitations.

A read-only PowerShell report audit passed **7/7** checks for schema/status, recorded source hash and quarantined path, derivative containment/hash, isolated project scope, all three type dimensions, and limitations. Revit still held the source file open, so Windows PowerShell could not independently reopen it for a second hash; the report itself records matching before/after hashes. The repository validator `Tools/RevitPilot/validate_candidate_family_geometry.ps1` could not run under this session's effective `Restricted` execution policy. No execution-policy or security setting was changed. Re-run that validator when Revit releases the source file and the repository script can be run under the owner's normal approved PowerShell setup.

Reproducible read-only audit inputs:

```text
Report: .local/revit-pilot/family-intake/derivatives/M250-champion-pro-bowl-geometry/candidate-family-geometry.json
Expected source: .local/revit-pilot/family-intake/candidates/american-standard-champion-pro-3195A101020-bowl.rfa
Expected source SHA256: F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393
Independent validator: Tools/RevitPilot/validate_candidate_family_geometry.ps1
```

When the source is no longer held by Revit and the normal PowerShell policy permits the repository script, rerun:

```powershell
powershell.exe -NoProfile -File Tools/RevitPilot/validate_candidate_family_geometry.ps1 -ReportPath .local/revit-pilot/family-intake/derivatives/M250-champion-pro-bowl-geometry/candidate-family-geometry.json -ExpectedSourcePath .local/revit-pilot/family-intake/candidates/american-standard-champion-pro-3195A101020-bowl.rfa -ExpectedSourceSHA256 F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393
```

The derivative and JSON remain ignored under `.local`; this note records the verified evidence without adding model artifacts to Git. No code-compliance, accessibility, structural-safety, professional-certification, permit-approval, or construction-readiness conclusion follows.
