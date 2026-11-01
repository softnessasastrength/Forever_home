# M267 — Public KOHLER Tresham lavatory family inspection

Date: 2026-11-01
Status: measured research candidate only; not selected or placed in the house.

## Source and isolated procedure

- Product: KOHLER Tresham K-2844-4-0 pedestal lavatory; manufacturer’s product and nominal-dimension references are listed in `Research/Upper_Suite_Bath_Product_Options_2026-10-30.md`.
- Public RFA URL: `https://techcomm.kohler.com/techcomm/cad/Sink-Pedestal_Lavatory_4in_cc-Kohler-Tresham-2844-4.rfa`
- Quarantined source: `.local/revit-pilot/family-intake/candidates/kohler-tresham-k-2844-4-0-2026-10-30/Sink-Pedestal_Lavatory_4in_cc-Kohler-Tresham-2844-4.rfa`
- Sidecar/source SHA256: `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`; the Revit report records the same hash before and after opening. A read-shared independent hash during Revit use also matched.
- Revit 2027.3 / build `27.3.0.28`; command: **Inspect quarantined family geometry**.
- Disposable derivative: `.local/revit-pilot/family-intake/derivatives/M266-Kohler-Tresham-20261101T072618132/FH_Candidate_Family_Geometry.rvt`, hash `AF6AA3819884620AC70D3C12E7CFBDE0999ACC1C9A3F5AFE7F3BFFC5B6CC5486`.
- Report: `candidate-family-geometry.json`, hash `D7F00B90CE56F45AD3A47828E8F4C8A53386517B818C390FDA90712480A7771F`.

The RevitPilot request file was temporarily backed up to ignored `.local/revit-pilot/request-backups/20261101T072618132/candidate-family-request.json`, pointed at this exact quarantined source/hash and a new empty output directory, then restored byte-for-byte afterward. Its original SHA256 remains `8D3EBD5B8395D40EC7C6EE32EF149F8B89EC4229FE57EE9507EDFE45C8B9B888`. No permanent add-in setting or selected-D source changed.

## Findings

- Family category: **Plumbing Fixtures**; placement type: **WorkPlaneBased**.
- Ten named finish/color types; every type reports three positive-volume solids. All ten measured symbol bounds are `24.1319 × 19.5626 × 34.6878 in` in the family coordinate axes, matching the approximately 24 × 19½ × 34⅝ in nominal envelope documented for this family/product family. Bounding boxes include transformed positive-solid extents; they are not installation clearances.
- Type parameters report manufacturer `Kohler`, model `K-2844-4`, product documentation links, and a sanitary-connector string parameter. This read did not inspect a placed MEP connector or service network.
- Follow-up read-only Family Editor inspection opened the exact source RFA in Revit 2027.3, viewed `Preview` and `Front`, and opened the Family Types panel for its displayed Fireclay/White type. It showed `Width (report) = 2 ft 0 1/128 in` and `Length (report) = 1 ft 7 1/2 in`, versus measured positive-solid bounds of `24.1319 × 19.5626 in`; the report parameters are smaller by about `0.1241 in` and `0.0626 in`. The panel showed `Sanitary Radius = 5/8 in`, `Sanitary Diameter = 1 1/4 in` with formula `Sanitary Radius * 2`, a text value `Sanitary Connection`, and Waste/Vent/CW/HW connection flags. These are family parameters/flags; this inspection did not establish that Revit MEP `ConnectorElement`s exist or that they are correctly located/oriented. The file was closed without saving. Its SHA256 after closure remains `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`; the still-open derivative was read-shared-hashed at `AF6AA3819884620AC70D3C12E7CFBDE0999ACC1C9A3F5AFE7F3BFFC5B6CC5486`.
- Integrity assertions passed for ten measured types, positive solids on each, no family instances, selected-D not opened, unchanged source hash, derivative existence and derivative hash matching its report.

## Limits and disposition

No instance was placed and no synthetic-host probe was requested. This does not prove host orientation, clearance, door/approach, plumbing route, product availability, exact finish/SKU selection, or fit in either M-06 search window. The exact selected toilet `610AA001.020` still lacks a public complete-family source. Keep west A protected, east B unassigned and M-06 unassigned. The existing PowerShell candidate-family validator was not invoked because PowerShell’s effective execution policy is Restricted; the JSON assertions above were run inline without an execution-policy override. No code, accessibility, product approval, professional, permit, structural-safety or construction-readiness conclusion follows.
