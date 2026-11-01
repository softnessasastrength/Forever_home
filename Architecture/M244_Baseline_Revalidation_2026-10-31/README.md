# M244 — Current-checkout geometry and IFC baseline replay

**Status:** reproduced selected-D room-block geometry and validated the retained IFC2x3 export from the present sandbox checkout. This does not validate native construction geometry.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_architectural_bim_baseline.ps1 `
  -OutputDirectory .local/revalidation/M244-current-baseline
```

The validator generates selected-D twice into isolated folders, compares all seven outputs, parses all SVGs, validates the retained IFC, and confirms protected input hashes.

## Result

The command exits successfully. Each generation passes **43/43** room-block checks; all seven artifacts match between runs, all three plan SVGs per run parse, and the retained IFC passes **26/26** checks with zero errors. The IFC2x3 schema, storeys, space IDs/names/areas/levels/bounds and body-profile areas match the documented selected-D study. The checked Revit room inventory matches source IDs and areas. The stacked L-02/U-06 overlap is 0 sf; the main bath footprint remains TBD.

| Protected input | SHA256 |
|---|---|
| Selected-D source | `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb` |
| Retained RVT | `c6ced6acd0e59e49ea0e9821153204fc81ed6cede2fcd4f4d7e387c0acefd6d0` |
| Retained IFC | `56251f4754567c78ebb657ec2b99894958c15ef73663f737742f3f36a8472f6f` |
| M244 validation report | `a1e387082544e3a116dcca9e3428cbc9b6c8cfcf3f8afdfd9ac12e70f964e93b` |

The report and child-run evidence are retained under the ignored `.local/revalidation/M244-current-baseline/` directory. Construction categories remain empty. Thus the pipeline reproduces its documented room-space study and validates its matching retained space-study RVT/IFC, but it has not yet produced a native architectural house model.

## Limits and outstanding work

No room/wall/door/fixture/building-envelope geometry was edited. M-06/A/B remain unassigned; exact current 610AA whole-fixture geometry, a locally applicable clearance basis, a supported approach/door and a plausible service route are not jointly established. The Revit process is running, but the supported Computer Use bridge twice returned `Accessibility state unavailable` for its currently listed window; no UI action or add-in load occurred. A native Revit derivative, wall/opening verification, family placement, and fresh RVT-to-IFC round trip remain outstanding. This is not a code-compliance, accessibility, structural-safety, professional, permit or construction-readiness claim.
