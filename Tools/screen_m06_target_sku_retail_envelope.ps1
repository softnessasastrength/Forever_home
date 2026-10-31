param(
    [string]$PredecessorReportPath = (Join-Path $PSScriptRoot '../Research/M06_Champion_PRO_Predecessor_Envelope_Screen_2026-10-28.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_610AA001_020_Retail_Reported_Envelope_2026-10-28.json')
)

$ErrorActionPreference = 'Stop'
$predecessorFile = (Resolve-Path -LiteralPath $PredecessorReportPath).Path
$predecessor = Get-Content -LiteralPath $predecessorFile -Raw | ConvertFrom-Json
if ($predecessor.schema -ne 'forever-home-m06-predecessor-product-envelope-screen-v1' -or
    $predecessor.target_candidate.target_sku -ne '610AA001.020' -or
    $predecessor.target_candidate.exact_target_sku_geometry_verified -ne $false) {
    throw 'Expected the current 610AA target and explicitly unverified 211AA predecessor report.'
}

$predecessorHash = (Get-FileHash -LiteralPath $predecessorFile -Algorithm SHA256).Hash.ToLowerInvariant()
$retailerWidthIn = 19.0
$retailerDepthIn = 30.25
$retailerHeightIn = 31.0
$predecessorWidthIn = [double]$predecessor.target_candidate.proxy_width_in
$predecessorDepthIn = [double]$predecessor.target_candidate.proxy_projection_in
$planMatch = [Math]::Abs($retailerWidthIn - $predecessorWidthIn) -le 0.001 -and
    [Math]::Abs($retailerDepthIn - $predecessorDepthIn) -le 0.001

$report = [ordered]@{
    schema = 'forever-home-m06-retailer-reported-target-envelope-v1'
    status = 'Secondary seller dimensions for exact target SKU; use for a labelled plan-envelope screen only.'
    checked_on = '2026-10-28'
    target_sku = '610AA001.020'
    dimension_source = 'Wayfair listing identifies American Standard part 610AA001.020 and reports overall dimensions 31 H x 19 W x 30.25 D in.'
    retailer_reported_overall_dimensions_in = [ordered]@{
        width = $retailerWidthIn
        depth = $retailerDepthIn
        height = $retailerHeightIn
    }
    retailer_reported_seat_height_in = 16.5
    predecessor_comparison = [ordered]@{
        predecessor_sku = [string]$predecessor.target_candidate.proxy_series
        predecessor_report_sha256 = $predecessorHash
        predecessor_plan_width_in = $predecessorWidthIn
        predecessor_plan_depth_in = $predecessorDepthIn
        target_retailer_plan_width_in = $retailerWidthIn
        target_retailer_plan_depth_in = $retailerDepthIn
        plan_envelopes_match_within_0_001_in = $planMatch
        predecessor_reported_height_in = [double]$predecessor.target_candidate.proxy_height_in
        target_retailer_height_in = $retailerHeightIn
        height_difference_in = [Math]::Round(($retailerHeightIn - [double]$predecessor.target_candidate.proxy_height_in), 3)
    }
    manufacturer_cross_check = [ordered]@{
        product_page = 'https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring'
        page_identifies_sku = '610AA001.020'
        page_reports_rough_in_in = 12
        page_reports_seat_height_in = 17
        linked_dimension_sheet_sku = '211AA.104 predecessor, not 610AA001.020'
        current_manufacturer_dimension_sheet_found = $false
        vertical_seat_height_matches_retailer = $false
    }
    retailer_source = 'https://www.wayfair.com/home-improvement/pdp/american-standard-champion-pro-two-piece-toilet-with-slow-close-seat-wax-ring-chair-height-white-asd13048.html'
    evaluation = [ordered]@{
        suitable_for_labelled_plan_envelope_screen = $planMatch
        manufacturer_verified_current_product_geometry = $false
        current_sku_rfa_or_cad_verified = $false
        current_sku_vertical_dimensions_reconciled = $false
        room_fit_or_clearance_established = $false
        door_approach_or_service_route_established = $false
        m06_assignment = $false
    }
    limitations = @(
        'The plan width and depth are retailer-reported for the exact SKU, not confirmed by a current manufacturer dimension drawing or inspected current-SKU Revit family.',
        'American Standard reports 17 in seat height and a 12 in rough-in; Wayfair reports 16.5 in seat height. Preserve the height discrepancy and do not use the retailer vertical dimension as verified geometry.',
        'The manufacturer product page links a dimension sheet for predecessor 211AA.104; matching plan numbers do not prove identity of the current SKU or every installed projection.',
        'This source does not establish room fit, code compliance, accessible design, door/approach, service routing, or assignment of B.'
    )
}
if (-not $planMatch) { throw 'The retailer-reported current-SKU plan envelope diverges from the inherited predecessor plan envelope; do not use the predecessor pair screen.' }

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$json = ConvertTo-Json -InputObject $report -Depth 10
[System.IO.File]::WriteAllText($resolvedOutput, $json + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: retailer-reported 610AA plan dimensions match the predecessor proxy's plan envelope; vertical and product-family evidence remain unresolved. Saved to $resolvedOutput"
