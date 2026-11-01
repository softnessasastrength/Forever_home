# M259 — Revit roof-massing host and IFC refresh

**Status:** verified disposable comparison; no roof option or house geometry selected.

## Scope

M259 checks that the documented M83 source generator and Revit 2027.3 host path still reproduce a valid IFC2X3 comparison, then reruns the selected-D room-boundary baseline. It does not author or edit the selected-D model.

M83 compares three previously documented pitch ratios (8:12, 10:12 and 12:12) in both ridge orientations on the hypothetical 38.333333 × 40 ft M78 outline. Those dimensions are a test envelope, not a proposed house size. Each Revit option is a pair of open, zero-thickness planar faces stored as `Generic Model` `DirectShape`; the display offsets separate alternatives and are not house coordinates.

## Reproduce source geometry

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1 -OutputDirectory '.local/revalidation/M259-roof-source-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1 -OutputDirectory '.local/revalidation/M259-roof-source-b'
```

Both isolated runs pass 13/13 checks. All four generated files (`roof-options.json`, `checks.json`, `manifest.json`, `roof-options.svg`) match each other and the checked-in package byte-for-byte. The input JSON SHA256 is `39A54E0660F2C206634B4D0921F015870FA0DF4A39A71CFE7EA71799AB383550`.

## Reproduce Revit host and validate IFC

The active per-user Revit 2027 manifest retained AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`, resolved inside this checkout, and pointed to `.local/revit-pilot/m254-family-name-fallback-20261031/Release/net10.0-windows/RevitPilot.dll`, SHA256 `C26F2C7DB0EE61A63139224253306E0B406C97A2DDE37C7A87ADCF43BB8E0974`. Its trust prompt matched the project-local path; **Load Once** was chosen. No global trust setting or manifest was changed for this run.

In Revit 2027.3, run **Add-Ins → Forever Home Pilot → Build M83 gable massing options**. The command created `.local/revit-pilot/roof-massing/20261101T030907380Z/` and reported IFC2X3 export API success. Validate the exact run twice without overwriting its retained export record:

```powershell
./.venv/Scripts/python.exe Tools/RevitPilot/validate_gable_massing_ifc.py '.local/revit-pilot/roof-massing/20261101T030907380Z' --report '.local/revalidation/M259-M83-host-validation/ifc-validation.json'
./.venv/Scripts/python.exe Tools/RevitPilot/validate_gable_massing_ifc.py '.local/revit-pilot/roof-massing/20261101T030907380Z' --report '.local/revalidation/M259-M83-host-validation/ifc-validation-run2.json'
```

All three checks (including a post-close run after visual inspection) pass 21/21; the three report files are byte-identical (SHA256 `06F8292A79CC2C2124D042548E08669955DBFBFE9DD73A0717697B07A802D412`). Revit visual inspection used a temporary 3D view that was not saved; the on-disk RVT and IFC hashes still match their export record after Revit closed. IFC schema issues: 0. Entity counts: six `IfcBuildingElementProxy` meshes and no `IfcRoof`, `IfcWall`, `IfcSlab`, `IfcDoor`, `IfcWindow` or `IfcStair`. RVT SHA256: `5E74FDF963558A97F04130F8FAB8776A6A169514216664F99FF3BE5017EDE174`. IFC2X3 SHA256: `472C07B6CCD0C221C45C42C1D9A62C96DF360E234DD1C808EED04014F747B856`.

## Reproduce selected-D baseline

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_architectural_bim_baseline.ps1 -OutputDirectory '.local/revalidation/M259-BIM-baseline'
```

The report at `.local/revalidation/M259-BIM-baseline/baseline-validation.json` passes two 43/43 generations, seven byte-identical output files per generation, three parseable SVGs per run, retained IFC2X3 26/26 with zero errors, and unchanged protected inputs. Report SHA256: `06AB910FB11B80D6EB6513BCCC2E76761B44CF24AA6CF7086B1CCEDE5D1E5E94`.

## Protected inputs and limitations

Selected-D study/RVT/IFC SHA256 values remain `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`, `C6CED6ACD0E59E49EA0E9821153204FC81ED6CEDE2FCD4F4D7E387C0ACEFD6D0` and `56251F4754567C78EBB657EC2B99894958C15EF73663F737742F3F36A8472F6F`. The incoming locked Evolution RFA remains `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`.

The M83 RVT contains one relative test level and six generic open meshes; it has zero native roofs, walls, floors, doors, windows or stairs. It does not represent a roof assembly, eaves/ridge elevations, overhangs, gable walls, openings, framing, drainage, insulation, ventilation, loads, site response or code determination. Connecticut is the research jurisdiction, but municipality, parcel, permit date and project criteria remain unspecified. Nothing here establishes code compliance, accessibility, structural safety, professional certification, permit approval or construction readiness.
