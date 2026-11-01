# M272 — Porch-connected patio adjacency study

**Status:** owner-directed relationship plan; exterior patio remains undimensioned and unfitted to a surveyed site.

## Owner-selected requirements represented

- Continue from the documented 12 × 10 ft three-season porch through its 3 × 3 ft minimum landing to an outdoor walking route.
- Keep the patio dining zone separate from the fire/lounge zone.
- Reserve an unlocated area for a future outdoor fireplace; its type, fuel, product and installation envelope are unknown.
- Branch the future pool route from the walking path before it reaches the lounge seating area.
- Reserve the lounge zone for the previously selected Adirondack model, whose exact source asset has not yet been recovered.

The SVG is an adjacency diagram. It draws the porch and minimum landing using the dimensions in the project specification; all exterior positions, clear route width, patio boundary, zone sizes, furniture footprints and orientation are **not to scale and not selected**. The porch exit side is deliberately unspecified. The arrows express connectivity only and are not a route-width or accessibility check.

## Validation

From the repository root, Windows PowerShell 5.1 can repeat the diagram checks directly (no execution-policy override):

```powershell
$path = 'Architecture/M272_Patio_Adjacency_Study_2026-11-01/patio-adjacencies.svg'
[xml]$svg = Get-Content -LiteralPath $path -Raw
$raw = [System.IO.File]::ReadAllText((Resolve-Path $path))
$required = @('THREE-SEASON','12 × 10 ft','3 × 3 ft','PORCH EXIT','PATIO DINING','FIRE / LOUNGE','future fireplace reserve','FUTURE POOL ROUTE','not to scale','site-fitted')
$missing = @($required | Where-Object { $raw -notmatch [regex]::Escape($_) })
if ($missing.Count) { throw "Missing labels/caveats: $($missing -join ', ')" }
$paths = $svg.SelectNodes('//*[local-name()="path"]')
if ($paths.Count -lt 2) { throw 'Missing connection paths' }
$porch = $svg.SelectSingleNode('//*[local-name()="rect" and @class="porch"]')
$landing = $svg.SelectSingleNode('//*[local-name()="rect" and @class="landing"]')
if ($porch.GetAttribute('width') -ne '240' -or $porch.GetAttribute('height') -ne '200' -or $landing.GetAttribute('width') -ne '60' -or $landing.GetAttribute('height') -ne '60') { throw 'Dimension-proxy ratios do not represent 12x10 and 3x3 at 20 px/ft' }
"PASS: SVG XML; $($required.Count) label/caveat checks; dimension-proxy ratios; $($paths.Count) paths."
```

This passed with 10 label/caveat checks and four SVG paths. Checks validate diagram content and well-formedness only.

## Limits and next steps

This does not establish a patio footprint or site fit. Needed next are the surveyed site/house location and grade, the recovered Adirondack model, and—before fixing a fireplace reserve size—the selected fireplace type or product instructions. Once the site is known, a dimensioned plan can test routes, door swings and thresholds, grading, drainage, pool safety provisions and local requirements. No code-compliance, accessibility, structural, permit, professional-certification or construction-readiness determination is made.
