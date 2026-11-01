# M254 — Quarantined Evolution sink synthetic-host probe

**Status:** synthetic-host probe complete; product and room-fit approval remain open. On 2026-11-01 UTC, the patched RevitPilot build reran the isolated test and its independent validator passed 14/14. This is evidence about the quarantined family in a synthetic fixture only, not a bathroom fit, code finding, or product selection.

## Scope and safety

This is an orientation/geometry test for the quarantined American Standard Evolution series RFA, not a fixture selection or room assignment. The source is the exact recorded file `american-standard-evolution-0467004.020.rfa`, SHA256 `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`. Revit's before/after hashes match; independent PowerShell hashes of the Incoming and quarantine copies also match. Neither source copy was edited.

The first run used the approved Revit 2027.3 project-local RevitPilot build in a new Imperial project. It placed only type `0467.400` on a 10 x 10 ft synthetic wall, a test harness dimension and not a house dimension. The report says `selected_d_opened=false`; no room or service network was present. The selected-D baseline, retained RVT and IFC were not modified. West A remains protected for study; east B and M-06 remain unassigned.

## First-run evidence

Raw report and derivative (both ignored under `.local`):

- `.local/revit-pilot/family-intake/derivatives/M254-evolution-synthetic-host-probe-20261031/candidate-family-geometry.json` — SHA256 `E1432533C2C1B76FD45BE9E8DC2940A7506CC10DD77675740E4C33FD8B75BFD2`.
- `.local/revit-pilot/family-intake/derivatives/M254-evolution-synthetic-host-probe-20261031/FH_Candidate_Family_Geometry.rvt` — SHA256 `28B9DC63C392E3AE9DA1EF69086BE371D8A2DA4BCA181CD332EF94AF20355F30` after closing the derivative in Revit.

Revit 2027.3 build `27.3.0.28` reports category Plumbing Fixtures, `WorkPlaneBased`, three family types (`0467.100`, `0467.400`, `0467.800`), and three positive-volume solids for each. For `0467.400`, the family-symbol bounds are 22.1256 x 34.3128 x 17.568 in. On the synthetic vertical face, the instance axes rotate those extents to project X/Y/Z bounds of 17.568 x 22.1256 x 34.3128 in. The face-host, instance-host, and host-face element IDs agree. The type parameter `Pedestal Option` is Yes, but this report does not isolate each solid's shape or confirm the complete modeled pedestal configuration. Treat the published overall Evolution dimensions and the RFA's physical completeness as separate source questions until a product-specific visual check is completed.

The report lists three round piping connectors (one 1-1/4 in radius and two 3/8 in radius), all unconnected; it explicitly reports that no service network is modeled. Their inventory does not establish routing or constructability.

## Validation and repair

The documented validator initially returned **12/14**. `family_metadata_present` failed because Revit reported an empty `OwnerFamily.Name`; `limitations_explicit` failed because the validator demanded the literal phrase “synthetic wall,” while the report accurately said “synthetic-host probe” and “test wall.” The latter was a validator wording defect, not missing limitation evidence.

The validator checks for both `synthetic-host` and `test wall`, along with the service-route and code-compliance limitations. The first-run report returned **13/14** after the wording repair; the patched runtime report now passes **14/14**. `CandidateFamilyGeometryCommand.cs` now falls back to the RFA filename stem when Revit supplies a blank owner-family name and records `family_name_source` so that fallback is visible.

The patched source built in a fresh ignored directory with **0 errors and 2 existing MSB3277 reference-conflict warning groups**. DLL SHA256: `C26F2C7DB0EE61A63139224253306E0B406C97A2DDE37C7A87ADCF43BB8E0974`. Its generated manifest uses authorized AddInId `096B0D51-8883-4B3D-BD31-E9622201E785` and resolves inside this checkout. The prior per-user registration was preserved at `.local/revit-pilot/registration-backups/20261031T221431/ForeverHome.Pilot.addin`, SHA256 `F62A7B32E4C94411CAE3C55162AFD198026363EBEF2450A1D5EE516FC1D71436`. The current manifest hash is `8C6646E1C85E7C2E6F3A812B9493705233A7513B8D80EF600B4B7CC2A4F23259`.

The exact local DLL was shown in Revit's unsigned-add-in prompt, independently matched to the current manifest and SHA256, and **Load Once** was selected. Revit's journal records `NoError` for `ForeverHome.Pilot.addin`. The new request is staged beside that DLL for the same source and type, with output path `.local/revit-pilot/family-intake/derivatives/M254-evolution-synthetic-host-probe-20261031-rerun/`. The output directory did not yet exist at checkpoint. The staged command then completed in Revit 2027.3: it opened the quarantined source, placed only type `0467.400` on a synthetic vertical wall in a new Imperial project, saved the derivative, and left selected-D unopened. After the derivative was closed and Revit exited to release file handles, the independent validator passed **14/14**. The report identifies the filename fallback with `family_name_source=source_filename_fallback`.

## Patched Revit rerun evidence

- Report: `.local/revit-pilot/family-intake/derivatives/M254-evolution-synthetic-host-probe-20261031-rerun/candidate-family-geometry.json`, SHA256 `7E5FA0349D31C9480A876719A0D446E44C20881C7B07F0EA9A77A5238C1460F7`.
- Disposable RVT: `.local/revit-pilot/family-intake/derivatives/M254-evolution-synthetic-host-probe-20261031-rerun/FH_Candidate_Family_Geometry.rvt`, SHA256 `E5A4311C9C44BABE0F024A6397B100B562AE77A5F40F9FBE2BC02358CD861D74`.
- Source RFA before/after and independent post-close SHA256: `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`.
- The report records three positive-volume solids for each of three types, matching synthetic host IDs, finite instance bounds `17.568 x 22.1256 x 34.3128 in`, and three unconnected piping connectors. None establish an installed fixture, room fit, clearances, approach, applicable Connecticut requirements, or service routing.
## Reproduction commands

Build command used:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/build.ps1 `
  -Dotnet '.local/dotnet/dotnet.exe' -BuildDirectory m254-family-name-fallback-20261031
```

After running the staged RevitPilot command in the blank disposable project, validate its report with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/validate_candidate_family_geometry.ps1 `
  -ReportPath '.local/revit-pilot/family-intake/derivatives/M254-evolution-synthetic-host-probe-20261031-rerun/candidate-family-geometry.json' `
  -ExpectedSourcePath '.local/revit-pilot/family-intake/candidates/american-standard-evolution-0467004.020.rfa' `
  -ExpectedSourceSHA256 '39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA'
```

These commands use the repository's documented process invocation; no persistent execution-policy or security setting was changed.

## Independent selected-D / IFC baseline

On 2026-10-31 local time (report timestamp 2026-11-01 UTC), `Tools/validate_architectural_bim_baseline.ps1` passed: two deterministic selected-D replays, **43/43** checks each, seven matching output artifacts per replay, three parseable SVGs each, and retained IFC2x3 validation **26/26 with zero errors**. The protected source, RVT and IFC hashes remained unchanged. Report: `.local/revalidation/architectural-bim-baseline-20261101T022059469Z/baseline-validation.json`, SHA256 `E9822D78EEF30351C21713F4C3EC9394215801301C8D3EE6850B8EC297934684`.

This baseline validates the documented schematic geometry/export, not a complete native architectural model. Native construction categories remain empty. No code-compliance, accessibility, structural-safety, professional-certification, permit-approval, or construction-readiness conclusion follows.
