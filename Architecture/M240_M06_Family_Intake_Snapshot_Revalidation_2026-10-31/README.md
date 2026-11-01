# M240 — Revalidate the hash-pinned family intake snapshot

**Date:** 2026-10-31  
**Scope:** read-only source-file/hash and prior Revit-measurement-manifest validation. No family placement or design assignment.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/validate_family_intake_snapshot.ps1 `
  -ManifestPath .local/revit-pilot/family-intake/20261031T012424079Z/intake-manifest.json `
  -SnapshotDirectory .local/revalidation/M240-family-intake-snapshot-replay
```

The script finds each manifest source by its pinned SHA256 in the authorized Incoming/quarantine roots, copies the exact bytes into a new `.local/revalidation` snapshot, rewrites only the copied manifest's source-folder path, and runs the family-intake output validator there. It refuses to overwrite an existing snapshot. Original family files are not opened for writing or modified.

## Result

- **6/6** manifest family hashes matched the authorized local files; **24** measured types passed **173** family-intake integrity checks.
- Snapshot console log: `.local/revalidation/M240-family-intake-snapshot-replay.log`, SHA256 `14C93478B03B1BD4DFD9557785A6F4BE4590758DFFD7AE7CE14EBFAEC9D67CF4`.
- Source manifest SHA256: `009CA58CF3C31A236E264DD9AF6CC30EEFA44B3A269DF1B453C807D0A3A94849`. Snapshot manifest SHA256: `541934FDD859207290511C20EE26ED8B1293AA3A6392098441E1223604D4DAD8`.
- M-06-related recorded symbols include the 211AA predecessor seat (`5325.010`, 14.2591 × 17.0527 × 1.4658 in), 3195A predecessor bowl (13.9997 × 29.0628 × 17.0953 in), Evolution wall-hosted sink family (three symbol types), and Tresham K-2844-4-0 family (24.0063 × 19.4998 × 34.6250 in in the measured family coordinates).

## Limits and disposition

These are family-local physical-solid bounds and source-integrity results. They do not prove dimensions in the intended project orientation, installed fit, correct host, actual whole-fixture assembly, door/approach clearance, product suitability, plumbing/service route, or code applicability. In particular, neither the 211AA predecessor seat nor its bowl is the selected current 610AA001.020 complete toilet. The Tresham and Evolution candidates remain research geometry only. M-06, west A and east B remain unassigned pending the combined product/clearance/access/service gate. No selected-D, RVT, IFC, or incoming RFA was changed.
