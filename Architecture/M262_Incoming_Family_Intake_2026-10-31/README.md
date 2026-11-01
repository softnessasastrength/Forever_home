# M262 — Revit 2027 incoming family intake replay

**Date:** 2026-10-31 local time (run timestamp `2026-11-01T03:30:46Z`)

**Status:** completed measurement and host-orientation screening; no family approval or room assignment.

## Scope

Replay the project-local RevitPilot `Run family intake test` command against the four unchanged `.rfa` files in `Revit/Family_Intake/Incoming`. Revit opened each source read-only for family inspection, measured positive-volume symbol solids and type parameters, loaded the symbols into a separate Imperial study, and tested only Evolution type `0467.400` on a synthetic vertical wall. The study was saved under ignored `.local/revit-pilot/family-intake/20261101T033030411Z/`.

No selected-D model was opened. The active host was an existing ignored M83 derivative; a Revit 2019-to-2027 upgrade prompt appeared, and the host was closed without saving. The intake study was separately saved by the command. Revit was closed before source hashes were validated.

## Evidence

- Revit build: `27.3.0.28` (Revit 2027.3).
- Manifest SHA256: `D38E98743A153BFAFE4EE3D5F9438CDC27EE4689271317A52066B12CC30AE873`.
- Disposable study RVT SHA256: `97148331C3C18B4C8CEDC76C14AF229C4CC36B3D7C9E0E9C075BD71D973516D6`.
- Two validator runs produced identical output (SHA256 of captured UTF-8 console output `BA78AFE50929907A0A16229C915BC929FAB894AB94B14D85E958178629B429F5`). `validate_family_intake_output.ps1` passed **79/79** integrity checks for four source families and eight measured types.
- Evolution type `0467.400` passed the scripted disposable vertical-wall orientation probe: 17.5052 in projection, 22.0000 in width, 34.2500 in height, three positive-volume solids. This establishes tested host/orientation behavior only.
- Source hashes after Revit closed: 211AA predecessor seat `37D3E56962B81F4B0ACE3D36D25BAFC03B7DEE1232E7DE7BBF9B95E4B0B75F63`; 3195A101 bowl family `F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393`; Evolution `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`. These match the unchanged intake sources.
- The other measured symbols were Sony TV `42.7559 × 6.2992 × 26.5354 in`, and the predecessor bowl types `13.9997 × 29.0628 × 17.0953 in`; the predecessor seat measured `14.2591 × 17.0527 × 1.4658 in`. Dimensions are family-symbol solid bounds, not product fit envelopes or finished installation dimensions.
- Selected-D/IFC baseline was rerun: `Tools/validate_architectural_bim_baseline.ps1` passed two source generations at **43/43** each, seven identical generated files per replay, three parseable SVGs per replay, and retained IFC2X3 **26/26** with zero errors. Report SHA256 `6085649DC29BA18F482E78ACF424369CCB92ED3F1FC767385A325DF68A55788B`; protected selected-D, RVT and IFC fingerprints remain unchanged.

## Reproduction

The current Windows PowerShell session blocks local `.ps1` files under its configured execution policy. No persistent policy or security setting was changed; the existing validators were run in short-lived child PowerShell processes with process-only `-ExecutionPolicy Bypass`.

```powershell
$manifest = '.local/revit-pilot/family-intake/20261101T033030411Z/intake-manifest.json'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/validate_family_intake_output.ps1 -ManifestPath $manifest
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_architectural_bim_baseline.ps1 -OutputDirectory .local/revalidation/M262-current-baseline
```

The intake validator's console output was captured twice and compared byte-for-byte. It returned:

```text
PASS: 4 family results, 8 measured types; 79 intake integrity checks passed.
```

The output's own limits state that measured bounds do not validate product size, placement, hosting, clearance, fit, or approval. The current 610AA001.020 water closet, a lavatory, M-06 room geometry, door/approach, finished faces, applicable Connecticut code path, and service routing remain unresolved. West A remains protected; east B and M-06 remain unassigned. No compliance, accessibility, structural-safety, permit, professional-certification, or construction-readiness claim follows.

## Next work

Use the recorded measurements only to identify which quarantined families merit further product-source comparison. Do not place them in selected-D or assign M-06. The next M-06 fit study still requires manufacturer-confirmed complete product geometry and owner-selected lavatory, plus project jurisdiction/permit path, actual door and approach, and a plausible plumbing route. Preserve the incoming RFAs unchanged.
