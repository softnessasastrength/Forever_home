# M280 — Read-only M-06 family evidence comparison

**Status:** Complete as a source-bound family evidence review. Neither family is selected or assigned to M-06. This comparison does not demonstrate room fit, code compliance, a complete fixture assembly, or connected plumbing.

## Reproduction

The package-free C#/.NET 10 generator is `Tools/M280Generator`. From the repository root, after building with the repository's approved .NET 10 SDK:

```powershell
dotnet build Tools/M280Generator/M280Generator.csproj
dotnet run --project Tools/M280Generator/M280Generator.csproj -- ".local/revit-pilot/family-intake/derivatives/20261101T135547430Z-kohler-cimarron-readonly/candidate-family-geometry.json" ".local/revit-pilot/family-intake/candidates/kohler-cimarron-k2362-provenance.json" ".local/revit-pilot/family-intake/candidates/kohler-cimarron-k2362/type-catalog.txt" ".local/revit-pilot/family-intake/20261101T135818230Z/intake-manifest.json" ".local/revalidation/m280-replay"
```

The generator pins the Revit report, candidate provenance, 21-row type catalog, incoming-family intake manifest, and source RFA fingerprints; it refuses output outside the repository. Its retained run passed **28/28** checks. Two independent outputs have matching SHA256 values:

| Output | SHA256 |
|---|---|
| `m280-cimarron-review.json` | `9A7EDC06229CF8D75993A829D54DDAC3E2F88647F323CDD364B48AF041178C6E` |
| `m280-checks.json` | `88DF16C49C99C3941B416FEEABD44E633F1C29FC00F2C2AC8EA3F2770885A0B9` |

The checked-in artifacts are copies of those retained outputs. The report includes its input hashes and generator check results. Compare two clean output directories byte-for-byte to verify determinism.

## Evidence

- Revit 2027.3 (`27.3.0.28`) loaded the public KOHLER Cimarron K-2362 RFA into a new disposable project. The selected-D model was not opened, no family instances were placed, and the source RFA SHA256 remained `3E5FD99648DE9CB384A8269F82896A2684C52F6E6C46A098F2A16DCE34A08979` before and after.
- Two positive-volume symbol solids yield an unhosted, axis-aligned envelope of **22.8758 × 18.8761 × 34.6256 in**. KOHLER's nominal published envelope is **22.75 × 18.875 × 34.5 in**. These bounds are evidence about the family geometry, not finished or installed clearances.
- Revit loaded one generic `Not a Type-See Type Catalog` symbol, with Model metadata `K-2362-1-0`; the public type catalog contains 21 non-empty rows and three faucet-configuration SKU variants. Exact catalog-row-to-symbol geometry correspondence is unresolved. The family's `ADA Compliant = No` parameter is metadata, not a project compliance finding.
- One round sanitary piping connector was observed, radius **0.625 in**. Hot/cold labels occur as text parameters; supply connector objects and an external service network were not observed/tested.
- The incoming American Standard Evolution candidate retains three types whose descriptions say “Basin only”; each reports a `Pedestal Option = Yes` parameter. A synthetic wall-host probe measured bounds but does not establish a complete basin/pedestal assembly or plumbing connections. Its connector inventory was not recorded by the intake report.

## Limits and next evidence

The Cimarron is an **unselected proposal**. No room/door/approach fit, finished-face allowance, faucet use zone, or supply/drain/vent routing was tested. M-06, west A, and B remain unassigned/protected as recorded in the design decisions. Before an M-06 layout can be considered, select an exact product/type and verify its full installation geometry, applicable clearance basis, entry/approach, and plausible service route. Do not infer code compliance, structural safety, professional approval, or construction readiness from this report.

## Source files and public references

- Revit geometry report: ignored `.local/revit-pilot/family-intake/derivatives/20261101T135547430Z-kohler-cimarron-readonly/candidate-family-geometry.json` (SHA256 `66F4F70E16870CA488B9AB5FF4AD99B383B942D7E8CA7F0ACD7A2C6F2A716CE6`).
- Candidate provenance: ignored `.local/revit-pilot/family-intake/candidates/kohler-cimarron-k2362-provenance.json`.
- Public family archive: `https://techcomm.kohler.com/techcomm/cad/Sink-Pedestal-Lavatory-KOHLER-Cimarron-K-2362.zip`.
- Manufacturer product page: `https://www.kohler.com/en/products/bathroom-sinks/shop-bathroom-sinks/cimarron-pedestal-bathroom-sink-with-single-faucet-hole-2362-1?skuId=2362-1-0`.
- Manufacturer specification: `https://resources.kohler.com/onlinecatalog/pdf/1020683_4.pdf`; roughing-in sheet: `https://resources.kohler.com/onlinecatalog/pdf/1020683_1.pdf`.
- Incoming-family manifest: ignored `.local/revit-pilot/family-intake/20261101T135818230Z/intake-manifest.json` (SHA256 `315C7A6897AA233D5D827EEB08615F6CC67AE7AC43F1103EB8581AED2C7A22A2`).
