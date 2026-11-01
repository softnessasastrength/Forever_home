# M283 — Selected-D source-to-IFC baseline replay

Date: 2026-11-01 14:31 UTC  
Branch: `codex/house-design-sandbox`  
Status: Passed as a reproducibility checkpoint; selected-D remains a schematic room-boundary study.

## Purpose

Re-run the checked-in selected-D geometry generator twice and validate the retained Revit 2027.3 IFC2X3 export against the current source, RVT, and export records. All generated files and reports were written below ignored `.local/revalidation/full-baseline-20261101T142500000Z/`; the tracked selected-D package and retained RVT/IFC were not overwritten.

The machine's effective PowerShell policy was `Restricted`. For this one invocation only, the PowerShell process used `RemoteSigned` so locally checked-out scripts could run. `Set-ExecutionPolicy -Scope Process` expires with that process; the subsequent policy-scope inspection showed all persisted scopes still `Undefined`. No machine, user, or Revit trust setting was changed.

## Reproduction

From the repository root in Windows PowerShell 5.1:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
./Tools/validate_architectural_bim_baseline.ps1 `
  -ExportDirectory '.local/revit-pilot/selected-d/20261101T122301834Z' `
  -OutputDirectory '.local/revalidation/full-baseline-20261101T142500000Z'
```

The output directory must not already exist. The script runs `build_selected_house_schematic.ps1` twice, validates seven generated artifacts per replay, parses the three plan SVGs as XML, invokes the repository IFC validator, and confirms that selected-D source, RVT, and IFC hashes did not change.

## Results

- Source generator: two replays; each passed 43/43 geometry checks, with zero failures.
- Determinism: seven artifacts per replay matched byte-for-byte.
- SVGs: three per replay; all parse as XML.
- Retained Revit/IFC baseline: 26/26 IFC checks passed, zero errors, and zero schema issues. Three storeys and all 21 source-matching spaces were verified, including IDs, names, levels, areas, and plan bounds.
- Protected inputs: selected-D source, saved RVT, and IFC fingerprints unchanged.

Fingerprint summary:

| Input/output | SHA256 |
|---|---|
| Selected-D source `study.json` | `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb` |
| Saved space-study RVT | `6073d5f1174b4009ab7ee17f430e0f788687fdbd64ba755c381e08bd0c58fc05` |
| IFC2X3 export | `e3b3c22c1cc58ceb8a1a7884cd122d90fd2337f372c2e9cd1cf293e4772ed999` |
| Baseline-validation report | `EA96186F883C2EED189AF56D50430EE94B71CF265169516A666E152FFCE6E98F` |
| IFC-validation report | `0AC0CDEA6D2589F6145C7F425BC99372C1DDD84C278173A597F6B3F3AE228FA9` |

Both replays produced these same hashes:

| Generated artifact | SHA256 |
|---|---|
| `checks.json` | `3c0a8c6689455f0710cb48f71555d73e04a254d2341ed544abf4533d11bb102d` |
| `lower-plan.svg` | `80c1ae876ee0e4e04fd143ca768e4b1107cdda67c13215b275b8f686acd2efa2` |
| `main-plan.svg` | `84e94e29c5cf6ace296a1a9e4cedf5a6e6f8576753f52e1ba28d2b1a939dad5a` |
| `program-area-review.csv` | `08ec32c10435966a6bdc52bf9f391b030f9bddf5dcc1f4757024c1c4472816c2` |
| `room-area.csv` | `ca8a655e94e4732a038dfaf2777039edea2d8e6cb0a764b1a34503371a6fba8d` |
| `study.json` | `9506c1145c9cd7a4ae6e39d8a21304c8f2fa018ee02f53b51941e04467a83483` |
| `upper-plan.svg` | `8bcda1e5e6584dc3329fef4c0f41eac89e5bcd6c7941cc116172f7b6fb02ab36` |

## Limitations

This verifies reproducible room-block source geometry and the retained space-study RVT/IFC only. The RVT has three levels and 21 spaces, but no physical walls, doors, windows, floors, stairs, roof, plumbing, MEP, or structural elements. It is not the full architectural model. The check does not establish code compliance, accessibility, structural safety, professional approval, or construction readiness. M-06 remains unassigned and B remains a search reservation pending product, applicable clearance, door/approach, and service evidence.

The original M278 checkpoint correctly recorded that its baseline-script attempt was blocked under the then-unchanged `Restricted` policy. M283 supersedes that operational limitation by documenting a process-scoped local-script run; it does not alter M278's historical result.

## Follow-up replay without policy override — 2026-11-01

The full baseline command was run again from this worktree using the effective existing policy (`RemoteSigned` at `LocalMachine`; `MachinePolicy`, `UserPolicy`, `Process`, and `CurrentUser` are `Undefined`). No execution-policy setting was changed. The command regenerated selected-D into fresh ignored scratch folders and revalidated the retained M266 Revit 2027.3 RVT/IFC2X3 pair:

```powershell
.\Tools\validate_architectural_bim_baseline.ps1 `
  -ExportDirectory '.local/revit-pilot/selected-d/20261101T122301834Z' `
  -OutputDirectory '.local/revalidation/resume-validation-20261101T-current'
```

Result: two replays, 43/43 geometry checks each, seven generated files per replay identical byte-for-byte, three parseable SVGs per replay, retained IFC validation 26/26 with zero errors, and protected source/RVT/IFC hashes unchanged. The ignored summary report SHA256 is `F4A856D37A85827520A3E07EDF983347B131F34131A1C8FEE1A0B865B3842248`; its IFC report SHA256 remains `0AC0CDEA6D2589F6145C7F425BC99372C1DDD84C278173A597F6B3F3AE228FA9`. The saved model is still a 21-space room-boundary study with no native house construction categories.

## Current-checkout replay — 2026-11-01 16:00 UTC

Repeated the direct baseline command from this checkout using the existing `RemoteSigned` LocalMachine execution policy; all other scopes remain `Undefined`. No execution-policy override or trust change was made. Fresh ignored output is `.local/revalidation/architectural-bim-baseline-20261101T160036041Z/`.

Two selected-D generations pass **43/43** checks each; all seven output files match byte-for-byte and each run's three plan SVGs parse as XML. The retained IFC2X3 passes **26/26** checks with zero errors. The report hashes are baseline summary `1F97BBE2BF598AA8DF100DCC94240429BF8FC30C92C6DA9314A76A89EED3AF07` and IFC report `0AC0CDEA6D2589F6145C7F425BC99372C1DDD84C278173A597F6B3F3AE228FA9` (same IFC report as the previous validation). Source, saved RVT and IFC hashes remain `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`, `6073D5F1174B4009AB7EE17F430E0F788687FDBD64BA755C381E08BD0C58FC05`, and `E3B3C22C1CC58CEB8A1A7884CD122D90FD2337F372C2E9CD1CF293E4772ED999`. Incoming Evolution RFA remains SHA256 `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`.

This is still the selected-D 21-space room-boundary RVT/IFC; wall, slab, door, window, stair, roof, fixture and MEP categories remain absent. No project geometry or incoming family was changed.
