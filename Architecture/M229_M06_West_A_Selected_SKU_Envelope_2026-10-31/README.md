# M229 — West A selected-SKU toilet plan-envelope screen

**Status:** reproducible toilet-only gross containment screen; no room assignment or installed fit established.

## Purpose

M226 used the same 19 × 30¼ in plan dimensions as an explicitly unverified 211AA predecessor proxy. M120 provides stronger evidence: the American Standard manufacturer infographic is associated with the owner-selected 610AA001.020 and records 19 in overall width and 30¼ in projection, along with the infographic SHA256. M229 re-runs the bounded west-A screen using those current-SKU callouts. It does not promote the infographic to a Revit family, exact 3D solid, or installation drawing.

## Reproduce

Run in Windows PowerShell 5.1 from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m06_west_a_selected_sku_envelope.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m06_west_a_selected_sku_envelope.ps1 -OutputDirectory .local/revalidation/M229-replay-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m06_west_a_selected_sku_envelope.ps1 -OutputDirectory .local/revalidation/M229-replay-2
```

The script pins selected-D SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` and M120 observations SHA256 `6CF5FF8D772C792AE7E12FCA132126D7A5CE88AC98874EF4E4CE4778A0AC4A60`. The current image at the manufacturer URL recorded in M120 was fetched again on 2026-10-31; its SHA256 `F09F6BFBCBB62F53828BD99E46F2351BB279E4C031980BBC5E35790E0FE86FBF` matches the pinned observation. The script verifies selected-SKU identity and the recorded image digest, requires M-06 and both A/B source windows to remain unassigned, and records that no exact-SKU RFA/CAD was verified. The downloaded verification copy is kept only under ignored `.local/revalidation/M229-source-image-check/`.

## Result

All three runs pass **14/14** checks and produce byte-identical JSON/check files.

| Orientation | Body plan envelope | Side-spacing proxy | Front strip | Gross A containment |
|---|---:|---:|---:|---|
| 0° | 19 × 30¼ in | 30 in width | 51¼ in depth including 21 in | Pass |
| 90° | 30¼ × 19 in | 30¼ in width | 40 in depth including 21 in | Pass |

West A is 62 × 137 in gross. This is a room-block gap, not a clear interior room. The 15-in WC-centerline side spacing and 21-in front strip are retained only as the preliminary 2021 IRC residential screening values documented in [M-06 clearance basis](../../Research/M06_Clearance_Basis_2026-10-30.md); local code path and applicability remain undetermined.

| Artifact | SHA256 |
|---|---|
| `m229-checks.json` | `77575C5482A3D02B9562DC198D52FB1BD4F2A0CCBAE3199AEE3E92C26ED46BE4` |
| `m229-report.json` | `C22B03748EB81CD60C7E5095C517D86768B30A1951DD02A161CCBD1DF6D6CBBC` |

## Limits and next gate

The current-SKU **plan dimensions** now have a manufacturer-infographic source. Exact 3D family/CAD, current installation drawing, lavatory and adjacent-fixture spacing, finished faces, door operation, hall approach, privacy, and water/waste/vent/service routing remain unresolved. The screen does not establish that west A can become a room, and it assigns neither A nor B. Selected-D, retained RVT/IFC, incoming/quarantined source families, and remote state were not changed. No code-compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows.
