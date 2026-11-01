# M265 — Selected-D retained IFC revalidation

Date: 2026-10-31 (recorded at the next session checkpoint)
Scope: independently revalidate the already retained selected-D Revit/IFC pair. No geometry generation or Revit command ran in this increment.

## Inputs and evidence

- Study directory: `.local/revit-pilot/selected-d/20261030T002652845Z/`
- Source study SHA256: `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`
- RVT SHA256: `C6CED6ACD0E59E49EA0E9821153204FC81ED6CEDE2FCD4F4D7E387C0ACEFD6D0`
- IFC2X3 SHA256: `56251F4754567C78EBB657EC2B99894958C15EF73663F737742F3F36A8472F6F`
- Validator: `Tools/RevitPilot/validate_selected_d_ifc.py`
- Reports: ignored local files `.local/revalidation/M265-selected-d-ifc-a.json` and `M265-selected-d-ifc-b.json`
- Both runs returned `status=pass`, 26/26 checks true, zero errors. The reports are byte-identical; SHA256 `449B98D7720BB10DCD53BA999A99AA6DD207950783C43EB3CFCA0800085C079B`.

## Reproduction

From the repository root, using the existing environment (no installation or geometry fitting):

```powershell
.venv\Scripts\python.exe Tools\RevitPilot\validate_selected_d_ifc.py .local\revit-pilot\selected-d\20261030T002652845Z --report .local\revalidation\M265-selected-d-ifc-a.json
.venv\Scripts\python.exe Tools\RevitPilot\validate_selected_d_ifc.py .local\revit-pilot\selected-d\20261030T002652845Z --report .local\revalidation\M265-selected-d-ifc-b.json
Get-FileHash .local\revalidation\M265-selected-d-ifc-a.json,.local\revalidation\M265-selected-d-ifc-b.json -Algorithm SHA256
```

## Limits and next work

This verifies the retained 21-space IFC export's lineage, IFC2X3 schema, spaces, storeys, names, areas, bounds, body profiles and intentionally empty construction categories. It is not a fresh geometry-generator replay and does not add native walls, slabs, stairs, doors, windows, roof, fixtures or services. It is not a complete building model or a code, accessibility, structural, professional, permit or construction-readiness review.

Revit 2027 was running at the checkpoint with its introductory trial WebView overlay. The supported Windows UI bridge exposed the Revit parent window but rejected the overlay's close-control click as belonging to an untargeted `msedgewebview2.exe` child. The documented permission is limited to closing that visible overlay; no workaround, trust-setting change, add-in load, Revit command, save or model edit was attempted. The approved project-local DLL and manifest were only read and hash-checked. Continue by reopening/refreshing Revit when its overlay is accessible; verify the exact manifest path/hash before any Load Once prompt.

No tracked model, incoming family, remote ref, or selected-D file was changed. Local validation reports are ignored.
