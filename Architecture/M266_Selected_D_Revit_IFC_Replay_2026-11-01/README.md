# M266 — Fresh selected-D Revit study and IFC2X3 validation

Date: 2026-11-01
Branch: `codex/house-design-sandbox` (local only)

## Reproduction and output

In Revit 2027.3, the verified project-local RevitPilot `Build selected D space study` command read the checked-in `study.json` and wrote a new, separate derivative to:

`.local/revit-pilot/selected-d/20261101T122301834Z/`

The Revit completion dialog confirmed a saved room-boundary study and successful IFC2x3 export API call. No selected-D source file was opened or altered. The saved model fingerprint is `6073D5F1174B4009AB7EE17F430E0F788687FDBD64BA755C381E08BD0C58FC05` (520,192 bytes); the checked-in source study hash is `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`; IFC hash is `E3B3C22C1CC58CEB8A1A7884CD122D90FD2337F372C2E9CD1CF293E4772ED999` (80,281 bytes).

The independent checker was run twice with the existing Python environment:

```powershell
.venv\Scripts\python.exe Tools\RevitPilot\validate_selected_d_ifc.py .local\revit-pilot\selected-d\20261101T122301834Z --report .local\revalidation\M266-selected-d-ifc-a.json
.venv\Scripts\python.exe Tools\RevitPilot\validate_selected_d_ifc.py .local\revit-pilot\selected-d\20261101T122301834Z --report .local\revalidation\M266-selected-d-ifc-b.json
Get-FileHash .local\revalidation\M266-selected-d-ifc-a.json,.local\revalidation\M266-selected-d-ifc-b.json -Algorithm SHA256
```

Both runs pass **26/26** checks with zero errors. Reports are byte-identical, SHA256 `0AC0CDEA6D2589F6145C7F425BC99372C1DDD84C278173A597F6B3F3AE228FA9`. Checks include source and manifest identity, saved-RVT/export fingerprint agreement, IFC2X3 parsing/schema validation, 21 unique spaces, room IDs/names/areas/levels/plan bounds/body areas, and deliberately empty construction categories.

## Limits

The model has three levels and 21 room-boundary spaces, but zero walls, doors, floors or stairs. No native roof, windows, fixtures or service network was authored. The exported IFC is a verifiable space-study deliverable, not a complete house model. The PS geometry replay was not run in this increment because the effective Windows PowerShell policy is `Restricted`; no execution-policy override was used. Prior source-generation replay evidence remains recorded in M262/M258.

**Subsequent validation:** M283 and the 2026-11-01 follow-up replay in `Architecture/M283_Selected_D_Baseline_Replay_2026-11-01/README.md` reran both source geometry and IFC validation successfully using the then-current policy configuration; that follow-up did not modify the RVT/IFC or selected-D source.
