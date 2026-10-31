# M188 - Dining set placement sensitivity

**Status:** one unapproved placement restores a sampled route, with zero extra clearance at the table edge. No dining layout or route is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\search_m188_dining_set_placement.ps1 -ScratchPrefix M188-replay-01 -OutputDirectory .local\revalidation\M188-summary-01
```

Use a fresh output directory and unique scratch prefix for a replay. The runner alters a generated copy of M186 only in memory on disk, beside the original M186 script, and removes the temporary runner in a `finally` block. It writes each per-scenario M186 result to ignored `.local/revalidation/`.

## Basis and result

The source dining specification calls for a 36 x 60 in table, four traditional 18 x 20 in chairs, 36 in minimum chair pull-out and a separate continuous 36 in route to the porch. M186 represents the table as 5 x 3 ft and the chair bodies as 18 x 20 in rectangles. Exact product geometry, chair operation and door clear width are not represented.

M188 translates the existing entire table/chair arrangement by one foot east, west, north or south, preserving each proxy size and relative position. All five arrangements remain within the M178 11 x 10 ft dining test rectangle. Only the north translation restores a sampled route, at 56.5 ft and seven turns. That route has **0 ft extra geometric gap to the table edge** and travels 6.5 ft through unassigned space. The other four cases, including the baseline, have no sampled route.

The north shift is a search lead only. The zero table-edge margin leaves no allowance for tolerance or movement, and the route has not been checked against actual walls, openings, physical doors, thresholds, chair pull-out or occupied use. It does not establish a functional route or approve the layout. M-06/B remains unassigned; selected-D, Revit/IFC and Incoming RFA sources remain untouched.

## Outputs

- `artifacts-refined/m188-dining-placement.json`
- `artifacts-refined/m188-dining-placement.csv`
- `artifacts-refined/m188-checks.json`
- `artifacts-refined/m188-north-translation-route.svg` - M186 generated plan view of the only route-restoring translation; parsed as XML.

The initial `artifacts/` folder is the preliminary five-case run before table-edge gap and dining-block containment fields were added; `artifacts-refined/` is the final validated output. The refined retained run and independent replay match byte-for-byte: checks SHA256 `8293979CE37D18F0B5B5A39616516CE6BA355F422171774677224F36908B66F7`, CSV `338BD99CF5C77DD9E06890DCA13F46366B49C4AF0E029882307A248D9583765B`, JSON `4EF80EC90E966D5534A7E30F9E26FA739916ADE98A0026ACDE2D8AA470B00217`. The SVG parses and matches the independently generated M186 case overlay at SHA256 `BDFCB5E2090AF5A7B015220D4796AF8245A59A9DD7315D1B2A8684638F809D90`.
