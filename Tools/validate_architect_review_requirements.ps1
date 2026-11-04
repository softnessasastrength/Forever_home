param(
    [string]$CompositionManifest = '.local/revit-pilot/multi-level-composition/20261103T150109911Z/multi-level-composition-manifest.json',
    [string]$BundleReport = '.local/revalidation/architect-review-bundle-sequence.json',
    [string]$Output = '.local/revalidation/architect-review-requirements.json'
)

$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
function Json([string]$Path) { Get-Content -LiteralPath (Join-Path $root $Path) -Raw | ConvertFrom-Json }
$m = Json $CompositionManifest
$bundle = Json $BundleReport
$checks = [System.Collections.Generic.List[object]]::new()
function Check([string]$Name, [bool]$Pass, [string]$Kind, [string]$Evidence) {
    $checks.Add([pscustomobject]@{ requirement=$Name; pass=$Pass; classification=$Kind; evidence=$Evidence })
    if ($Pass) { Write-Output "PASS $Name`: $Kind — $Evidence" } else { Write-Output "OPEN $Name`: $Kind — $Evidence" }
}

Check 'native walls' ($m.wall_count -gt 0) 'native comparison' "wall_count=$($m.wall_count)"
Check 'floor candidates' ($m.floor_count -gt 0) 'native comparison' "floor_count=$($m.floor_count); assembly unselected"
Check 'roof candidates' ($m.roof_count -eq 3) 'native comparison' '8:12, 10:12 and 12:12 options'
Check 'circulation' ($m.stair_count -eq 2 -and $m.stair_run_count -eq 2) 'proxy plus separate native study' 'composition proxies; native stair evidence indexed separately'
Check 'kitchen' ($m.kitchen_island_count -gt 0) 'proxy' '8 x 4 ft island direction; placement/clearance unresolved'
Check 'baths' ($m.primary_bath_fixture_proxy_count -gt 0) 'proxy' 'separate tub/tiled rain-shower direction; fit unresolved'
Check 'patio/porch' ($m.porch_patio_reservation_count -eq 1) 'reservation' '12 x 10 ft source reservation; site fit unresolved'
Check 'driveway/pool route' ($m.site_direction_marker_count -eq 2) 'direction marker' 'brick checkerboard driveway and future brick route; dimensions unassigned'
Check 'skylights' ($m.skylight_reservation_count -eq 9) 'reservation solids' 'nine non-cutting reservations across three zones'
Check 'fixture proxies' ($m.primary_bath_fixture_proxy_count -gt 0) 'selected direction, unselected products' 'M-06/B remains unassigned and fit-blocked'
Check 'exports and evidence' ($bundle.status -eq 'pass' -and @($bundle.artifacts).Count -eq 10) 'verified handoff' "bundle=$($bundle.status); artifacts=$(@($bundle.artifacts).Count)"

$out = if ([IO.Path]::IsPathRooted($Output)) { $Output } else { Join-Path $root $Output }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out) | Out-Null
[ordered]@{
    schema='forever-home-architect-review-requirements-v1'
    status='pass-with-open-gates'
    composition_manifest=$CompositionManifest
    bundle_report=$BundleReport
    checks=$checks
    limitations=@(
        'Pass indicates documented category evidence, not a completed selected design.',
        'M-06/B, floor-to-floor/stair section, assemblies, openings, MEP, accessibility, site fit and Connecticut applicability remain open.',
        'No code-compliance, structural-safety, professional, permit or construction-readiness claim follows.'
    )
} | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $out -Encoding UTF8
if (@($checks | Where-Object { -not $_.pass }).Count -gt 0) { throw 'Architect review requirement matrix has missing evidence.' }
Write-Output "PASS: $($checks.Count)/$($checks.Count) requirement evidence checks; status pass-with-open-gates"
