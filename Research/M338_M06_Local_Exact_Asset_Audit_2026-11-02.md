# M338 — Local exact-SKU M-06 asset audit

## Scope

This is a read-only repository audit performed without opening Revit, signing into any service, downloading a gated asset, or changing the selected-D model. It checks whether the owner-selected American Standard Champion PRO `610AA001.020` has already been quarantined locally as a complete Revit family or current assembled dimension drawing.

## Reproduction

From the repository root:

```powershell
rg -n -i "610AA001\.020|610AA|Champion PRO" Revit Research Architecture .local/revit-pilot/family-intake
Get-ChildItem Revit/Family_Intake/Incoming,.local/revit-pilot/family-intake/candidates -Recurse -File |
  Where-Object { $_.Name -match '610|Champion|211|3195|4225' }
```

## Result

- The exact current-SKU product page and manufacturer infographic are documented, but no exact current-SKU RFA or complete current-SKU installation drawing is present in the local intake.
- `3195A101.020` is a measured predecessor bowl-only family; `211AA104.020` is a predecessor seat family. Their separate existence does not establish a complete `610AA001.020` assembly and they must not be combined by inference.
- The retained American Standard Evolution RFA is an independently verified lavatory-family candidate, not a toilet substitute.
- The current 610AA infographic remains a plan-envelope proxy only.

## Consequence

M-06/B remains unassigned. Product geometry, finished-face clearance, door/approach, service routing and room assignment remain open. A disposable native fixture study may proceed only after the owner supplies an exact current-SKU asset/drawing or explicitly authorizes a labelled proxy.

This audit is not a code-compliance, accessibility, structural, professional, permit or construction-readiness determination.
