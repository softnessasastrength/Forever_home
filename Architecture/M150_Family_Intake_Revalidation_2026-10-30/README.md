# M150 — Revalidate retained Revit family-intake evidence

Status: the saved Revit 2027 family-intake measurements replay against byte-matched local RFA sources. This does not approve a family or resolve M-06 fit.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
.\.venv\Scripts\python.exe Tools/RevitPilot/validate_family_intake.py
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/validate_family_intake_snapshot.ps1 .\.local\revit-pilot\family-intake\20261031T012424079Z\intake-manifest.json -SnapshotDirectory .local/revalidation/M150-family-intake-e
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/validate_family_intake_snapshot.ps1 .\.local\revit-pilot\family-intake\20261031T012424079Z\intake-manifest.json -SnapshotDirectory .local/revalidation/M150-family-intake-f
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m120_m06_current_envelope_screen.ps1 -OutputDirectory .local/revalidation/M150-m06-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m120_m06_current_envelope_screen.ps1 -OutputDirectory .local/revalidation/M150-m06-b
```

The snapshot verifier resolves each manifest SHA256 only from `Revit/Family_Intake/Incoming` and the quarantined `.local/revit-pilot/family-intake/candidates` directory. It copies those exact bytes to a new ignored scratch directory, adjusts only the copied manifest's `source_folder`, then runs the existing Revit intake-output validator. It refuses a non-hash-matching source and refuses to overwrite an existing snapshot. The original source RFAs, run manifest and Revit study remain untouched.

## Results

- Family-source/provenance validator: passes for the two queued manufacturer families, the four quarantined public research families, the archived rejection and the RevitCity disposition.
- Revit 2027.3 family-intake run `20261031T012424079Z`: two snapshot replays each match all six recorded source hashes and pass **155/155** intake integrity checks across **24 measured types**. The retained manifest SHA256 is `009CA58CF3C31A236E264DD9AF6CC30EEFA44B3A269DF1B453C807D0A3A94849`.
- M-06 gross-envelope generator: two PowerShell 5.1 replays each pass **14/14** checks and contain all **16/16** current research toilet/lavatory rectangle pairs in the unassigned 124 x 84 in pantry-side search window. This remains gross-envelope arithmetic.
- The saved intake measured the 3195A101.020 predecessor bowl family at 13.9997 x 29.0628 x 17.0953 in (six positive-volume solids); it is a bowl-only predecessor component, not the selected 610AA001.020 assembly. The linked 211AA RFA is a seat family (5325.010), not a toilet tank/bowl assembly.
- The Evolution 0467.400 family was measured at 22 x 34.25 x 17.5052 in and its family orientation was tested on one disposable wall host. The type description says “Basin only” while its pedestal option is Yes; visual assembly review, connections and current product status remain unresolved.
- The quarantined Tresham family has ten types, three positive-volume solids per type, and 24.0063 x 19.4998 x 34.625 in symbol-local bounds. Manufacturer non-ADA status and untested host orientation remain relevant limitations.

## Historical file-set discrepancy

The older `validate_family_intake_output.ps1` run against today's `Incoming` directory reports 153/155 checks and two failures because its retained manifest contains six files, whereas `Incoming` now contains five. One recorded family (Tresham) is available in the quarantined candidate directory by the exact SHA256 but is not currently in `Incoming`. M150 revalidates the recorded six-file set by source hash instead of asserting that a historical manifest equals today's mutable folder. No source was moved, removed or overwritten.

## Limits and next gates

The exact current Champion PRO 610AA001.020 RFA and complete current-SKU installation drawing remain unavailable. The 3195A family is bowl-only and the associated 4225A104.020 predecessor tank record explicitly has no Revit design file. M120 uses manufacturer-envelope rectangles and research lavatory body measurements, not a placed toilet assembly. Actual wall faces, fixture orientation, door/leaf, entry approach, selected clearance basis applicability, rough-in/service route and plumbing connections remain open. Keep M-06/B unassigned.

The live Revit prompt still names a stale RevitPilot DLL path and is awaiting owner direction; no prompt option was clicked in this milestone. Selected-D source SHA256 remains `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`.

No code-compliance, accessibility, structural-safety, professional-certification, permit or construction-readiness claim follows.
