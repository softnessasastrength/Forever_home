# M248 — Revalidate the current selected-D / IFC baseline

**Status:** current checkout validation passed. This baseline remains a 21-space room-study RVT/IFC package, not a complete architectural house model.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_architectural_bim_baseline.ps1 -OutputDirectory .local/revalidation/M247-current-baseline
```

The retained `baseline-validation.json` passes. Each of two selected-D generations passes **43/43** geometry checks and produces seven byte-identical artifacts; all six plan SVGs parse. The retained IFC2x3 passes **26/26** independent checks with zero schema errors. Revit room inventory IDs/areas, IFC storeys, space identities/names/areas/levels/bounds/body-profile areas and export lineage match the pinned source. The L-02/U-06 stacked plan overlap remains 0 sf; M-06 footprint remains TBD.

| Evidence | SHA256 |
|---|---|
| `baseline-validation.json` | `6325795E1735FAA19AE78567705D2BF455E901760CC49D07BA228E5057CC8239` |
| selected-D source | `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` |
| retained space-study RVT | `C6CED6ACD0E59E49EA0E9821153204FC81ED6CEDE2FCD4F4D7E387C0ACEFD6D0` |
| retained IFC2x3 | `56251F4754567C78EBB657EC2B99894958C15EF73663F737742F3F36A8472F6F` |
| Incoming Evolution RFA | `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA` |

The script reports `construction_categories_remain_empty: true`. Thus geometry generation and IFC validation are reproducible for the documented room-space study; native building walls, floors, doors, windows, stairs, fixtures, services and a native roof remain outstanding. No selected-D, retained export, incoming family or remote state changed.
