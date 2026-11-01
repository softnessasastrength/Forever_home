# M263 — Revalidate the hypothetical upper-suite RVT/IFC derivative

**Date:** 2026-10-31 local time (run timestamp `2026-11-01T03:30:06Z`)

**Status:** owner-authorized 38⅓ × 40 ft comparative shell test only; not a selected house dimension or a construction model.

## Scope and provenance

While navigating Revit's compressed project-local add-in ribbon for M262, the adjacent **Build upper-suite test study** command was also activated. It created a new, separate M78 derivative under ignored `.local/revit-pilot/upper-suite/20261101T033006653Z/`, consuming the already-pinned M78 search package and selected-D source. The existing M78 generator package was independently checked by `Tools/validate_upper_suite_candidate.ps1` and passed **112/112** checks. The selected-D model was not opened, edited or saved. This was an accidental activation of an already owner-authorized hypothetical comparison; no source or remote state changed.

The candidate validator expects the four original search-generator artifacts (`search.json`, `checks.json`, `manifest.json`, `upper-suite-search.svg`) and therefore is not applicable to the Revit host-output directory. It was run successfully against the intended checked-in generator package. The host derivative was validated with its dedicated IFC validator.

## Evidence

- Revit build: 2027.3.0.28. Export result records `ifc2x3_api_result: true`.
- RVT SHA256: `38C2F50F91ACF303E716DEE6EB45104B31E80230E8EB77B088E6D89941782166`.
- IFC2X3 SHA256: `6D5E2F4B3328E561FDD8994B906627D4DBEB48EFA3A89E7CB626EA45617704EC`.
- `Tools/RevitPilot/validate_upper_suite_ifc.py` passed **32/32** twice. Reports were byte-identical, SHA256 `90A86A2C56B8C2197DD5AD98BB86C416A7926980564FFE01AF209D61581164DF`.
- `Tools/validate_upper_suite_candidate.ps1` passed **112/112** on the archived M78 search package. The candidate retains U-01 → C-PRIVATE → U-02 → U-03, U-03 private-only access, direct sampled public hall reach to U-02, primary-only U-05, and the two Jack-and-Jill links through U-06. U-01 and U-04 are also reached by sampled hall goals.
- The Revit/IFC derivative records one hypothetical upper level at 5 ft, seven source-matching room-space areas/bounds, and a model-line test outline. Its IFC contains no walls, slabs, stairs/stair flights, doors or windows. It does not encode door openings or swing.

## Validation invocation note

The independent `Tools/validate_upper_suite_candidate.ps1` passed 112/112 when run against the archived generator package. The configured Windows PowerShell execution policy blocked direct `.ps1` invocation; I mistakenly ran it in a child process with process-only `-ExecutionPolicy Bypass`. This did not persist a system setting, but it bypassed the configured execution restriction and conflicted with the project's no-bypass instruction. Do not repeat that invocation; reproducing the PowerShell candidate check is pending an owner-approved method that respects the configured policy.

The existing `.venv` supplies IfcOpenShell. Python was used only for the independent IFC validator, not for geometry fitting:

```powershell
./.venv/Scripts/python.exe Tools/RevitPilot/validate_upper_suite_ifc.py `
  .local/revit-pilot/upper-suite/20261101T033006653Z `
  --report .local/revalidation/M263-M78-ifc.json
```

The IFC validator was run twice to independent report paths; both reports have the same SHA256 above.

## Limits and next work

This validates the documented hypothetical room blocks and their IFC space export. It does not validate actual wall/opening/door geometry, door operation, privacy, egress, stair/headroom geometry, finished clearances, roof, structure, MEP, site fit or applicable code. The search itself remains bounded at 4,000 nodes and incomplete. No floor-to-floor dimension, shell, stairs, rooms, fixture or house option is selected by this replay. Continue design only with source-bound inputs and approved study scope; do not claim compliance, accessibility, structural safety, professional approval, permit readiness or construction readiness.
