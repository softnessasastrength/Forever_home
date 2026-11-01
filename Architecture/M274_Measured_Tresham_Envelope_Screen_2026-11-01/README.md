# M274 — Measured Tresham bounds in the west-A envelope screen

**Status:** reproducible gross-block comparison only; the lavatory remains unselected, M-06/A/B remain unassigned, and no installed room fit is established.

## Question and inputs

M230 compared west A against nominal candidate sink rectangles. For the KOHLER Tresham orientation with a 24-in width, it reported 5.0000 in gross width reserve. M269 later measured the same quarantined family from Revit positive-volume solids at 24.1319 × 19.5626 × 34.6878 in in unplaced family-symbol coordinates. M274 substitutes those measured plan bounds into the same two 0/90-degree envelope cases; it does not infer host rotation, installation, or selection.

M274 reads and pins:

- Selected-D study SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`.
- M230 gross west-A comparison report SHA256 `1859CED601E1982D41BAEE58A191F2766771729921FBCD8AC3A59DC590B0E686`.
- M269 family-inspection report SHA256 `A9B396221B90FF54DE773CCB80C02E6D9B6B26CA81EEEFFA0A504F33DF60F3C2` and current Tresham RFA SHA256 `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`.

The screening values are the scoped 2022 CSBC / 2021 IRC residential research inputs documented in `Research/CT_M06_Fixture_Clearance_Basis_2026-11-01.md`: 15 in from each fixture centerline to a side wall, partition, or vanity; 30 in between adjacent fixture centerlines; and 21 in forward clearance. The project code path remains undetermined. The selected 610AA001.020 toilet remains a 19 × 30.25 in manufacturer plan-envelope proxy without verified exact-SKU RFA/CAD.

## Reproduction

From the repository root, after the M269 report and exact RFA are available at the hash-checked local paths recorded in `Architecture/M269_Family_Connector_Inventory_2026-11-01/README.md`:

```powershell
.local/dotnet/dotnet.exe build Tools/M274Generator/M274Generator.csproj --configuration Release --output .local/revalidation/m274-build
.local/dotnet/dotnet.exe .local/revalidation/m274-build/M274Generator.dll Architecture/M230_West_A_Toilet_Lavatory_Envelopes_2026-10-31/artifacts/m230-report.json .local/revit-pilot/family-intake/derivatives/M269-Kohler-Tresham-Connector-Inspection-20261101/candidate-family-geometry.json Architecture/Selected_Design_Iteration_2026-10-27/study.json .local/revalidation/m274-run-a
.local/dotnet/dotnet.exe .local/revalidation/m274-build/M274Generator.dll Architecture/M230_West_A_Toilet_Lavatory_Envelopes_2026-10-31/artifacts/m230-report.json .local/revit-pilot/family-intake/derivatives/M269-Kohler-Tresham-Connector-Inspection-20261101/candidate-family-geometry.json Architecture/Selected_Design_Iteration_2026-10-27/study.json .local/revalidation/m274-run-b
```

The package-free .NET 10 build completed with **0 warnings and 0 errors**. Each run passes **15/15** embedded scope, source, and envelope checks. The two JSON outputs reproduce byte-for-byte across independent directories. Retained outputs are in `artifacts/`.

## Result

| Test orientation | Required gross width | Reserve in 62-in gross block | Required gross depth | Reserve in 137-in gross block |
|---|---:|---:|---:|---:|
| 0° symbol axes | 57.066 in | 4.9341 in | 51.25 in | 85.75 in |
| 90° symbol axes | 54.7813 in | 7.2187 in | 51.25 in | 85.75 in |

Both envelopes remain inside the **gross** 62 × 137 in west-A block under the inherited shared-back-line arrangement. For the 0° case, the measured width reduces nominal gross reserve from 5.0000 in to 4.9341 in. This difference is not a meaningful wall/finish allowance; it demonstrates why gross block containment cannot establish fit.

## Assumptions and limits

- The 24.1319 × 19.5626 in axis-aligned symbol bounds are treated as a rectangular plan envelope. Its bounding-box midpoint is used as a provisional lavatory centerline, and its axes are compared at 0° and 90°. The family was not placed or hosted; the origin-to-product-center relationship and installation orientation are unverified.
- The toilet is only the selected manufacturer's 19 × 30.25 in plan proxy. No exact-SKU 3D geometry is present.
- West A is a gross room-block gap, not finished interior dimensions. No wall construction, finished-face offset, faucet use zone, door leaf/swing, hall approach, privacy, or water/waste/vent route was tested.
- Tresham is a research candidate, not a selected product. A and B remain protected/unassigned; M-06 remains unassigned. Revit/IFC and selected-D were not opened or modified by this screen.
- No code-compliance, accessibility, constructibility, structural, professional, permit, or construction-readiness conclusion follows.

## Retained artifact hashes

| Artifact | SHA256 |
|---|---|
| `m274-report.json` | `3A29C9CB6F8DB5B523794416330B7EE446763ED91A7D3D60AFC30FFDBCC38B3A` |
| `m274-checks.json` | `F8C16A637AE37CD61F3F08B09FB997E3DE83971BED0AE2A90B94490417ED3A3A` |

The input hashes are embedded in each report and asserted by the generator. The Revit family report and derivative remain ignored local evidence; their paths and fingerprints are documented in M269.
