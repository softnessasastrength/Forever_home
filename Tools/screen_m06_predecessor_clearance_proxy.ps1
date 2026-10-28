param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$ProductEnvelopePath = (Join-Path $PSScriptRoot '../Research/M06_Champion_PRO_Predecessor_Envelope_Screen_2026-10-28.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_Champion_PRO_Predecessor_Clearance_Proxy_2026-10-28.json')
)

$ErrorActionPreference = 'Stop'
$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$productFile = (Resolve-Path -LiteralPath $ProductEnvelopePath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$product = Get-Content -LiteralPath $productFile -Raw | ConvertFrom-Json
$m06 = $study.selection.main_public_bath

if ($study.layout_variant -ne 'OwnerSelectedD') { throw "Expected owner-selected D; found '$($study.layout_variant)'." }
if ($m06.id -ne 'M-06' -or $m06.type -ne 'half bath' -or $m06.footprint -ne 'TBD' -or $m06.position -ne 'TBD') {
    throw 'M-06 is not the expected unassigned half-bath search in the selected-D study.'
}
if ($product.schema -ne 'forever-home-m06-predecessor-product-envelope-screen-v1' -or
    $product.target_candidate.exact_target_sku_geometry_verified -ne $false) {
    throw 'Expected the explicitly unverified 211AA predecessor-product envelope report.'
}
$studyHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$productHash = (Get-FileHash -LiteralPath $productFile -Algorithm SHA256).Hash.ToLowerInvariant()
if ($product.study_sha256 -ne $studyHash) { throw 'Predecessor report was generated from a different selected-D study.' }

# Preliminary detached-dwelling screening values from 2021 IRC §§ R307.1 / P2705.1.
# The assumptions below model an unassigned, gross rectangular window; they do not establish local applicability.
$sideClearanceIn = 15.0
$frontClearanceIn = 21.0
$proxyWidthIn = [double]$product.target_candidate.proxy_width_in
$proxyDepthIn = [double]$product.target_candidate.proxy_projection_in
$orientations = @(
    [ordered]@{rotation_deg=0;body_width_in=$proxyWidthIn;body_depth_in=$proxyDepthIn},
    [ordered]@{rotation_deg=90;body_width_in=$proxyDepthIn;body_depth_in=$proxyWidthIn}
)
$window = @($m06.search_windows | Where-Object id -eq 'east_of_core')
if ($window.Count -ne 1 -or $window[0].status -notlike 'Unassigned room-block gap only*') {
    throw 'Pantry-side B is missing or no longer an unassigned room-block gap.'
}
$grossWidthIn = [double]$window[0].w * 12.0
$grossDepthIn = [double]$window[0].d * 12.0
$orientationResults = @()
foreach ($orientation in $orientations) {
    # Lower-bound envelope assumes the toilet is centered between two opposing side boundaries.
    # The 21-in front zone begins at the predecessor body envelope's front edge.
    $screenWidthIn = [Math]::Max([double]$orientation.body_width_in, (2.0 * $sideClearanceIn))
    $screenDepthIn = [double]$orientation.body_depth_in + $frontClearanceIn
    $contained = $screenWidthIn -le $grossWidthIn -and $screenDepthIn -le $grossDepthIn
    $orientationResults += [ordered]@{
        rotation_deg = [int]$orientation.rotation_deg
        predecessor_body_width_in = [double]$orientation.body_width_in
        predecessor_body_depth_in = [double]$orientation.body_depth_in
        assumed_two_sided_screen_width_in = [Math]::Round($screenWidthIn, 3)
        screen_depth_in_including_front_clearance = [Math]::Round($screenDepthIn, 3)
        assumed_centerline_to_each_side_boundary_in = [Math]::Round($screenWidthIn / 2.0, 3)
        front_clearance_in = $frontClearanceIn
        contained_in_gross_B = $contained
        remaining_gross_width_in = [Math]::Round(($grossWidthIn - $screenWidthIn), 3)
        remaining_gross_depth_in = [Math]::Round(($grossDepthIn - $screenDepthIn), 3)
        assumption = 'Rectangular toilet body centered between hypothetical opposing side boundaries; minimum 21-in front strip measured from nominal predecessor body envelope.'
    }
}
if (@($orientationResults | Where-Object { -not $_.contained_in_gross_B }).Count -gt 0) {
    throw 'The predecessor-only toilet-plus-screening-envelope is not contained in gross B in both orientations.'
}

$report = [ordered]@{
    schema = 'forever-home-m06-predecessor-clearance-proxy-v1'
    result = 'PASS: both predecessor-only toilet-plus-minimum-screening envelopes are contained in the gross unassigned B window.'
    study_sha256 = $studyHash
    predecessor_product_report = [System.IO.Path]::GetFileName($productFile)
    predecessor_product_report_sha256 = $productHash
    owner_selected_target_sku = '610AA001.020'
    proxy_predecessor_sku = '211AA104.020'
    exact_target_sku_geometry_verified = $false
    search_window = [ordered]@{
        id = 'east_of_core'
        label = 'Pantry-side B'
        gross_width_in = $grossWidthIn
        gross_depth_in = $grossDepthIn
        gross_area_sf = [double]$window[0].gross_area_sf
        remains_unassigned = $true
    }
    preliminary_clearance_screen = [ordered]@{
        jurisdiction_research_basis = 'Connecticut 2022 CSBC; assumed detached one-family dwelling and preliminary 2021 IRC screen only; local applicability unconfirmed.'
        side_centerline_to_obstruction_in = $sideClearanceIn
        front_clearance_in = $frontClearanceIn
        source_15in = 'https://codes.iccsafe.org/content/IRC2021P1/chapter-3-building-planning'
        source_21in_and_fixture_installation = 'https://codes.iccsafe.org/content/IRC2021P1/chapter-27-plumbing-fixtures'
        clearance_30in_center_to_center_applied = $false
        reason_30in_not_applied = 'No selected lavatory or adjacent fixture geometry is included.'
    }
    orientations = $orientationResults
    evaluated = [ordered]@{
        predecessor_body_plus_side_and_front_screen_only = $true
        complete_room_fit = $false
        sink_or_lavatory = $false
        door_or_swing = $false
        entry_approach_or_access_route = $false
        wall_build_up_or_rough_in_location = $false
        water_drain_vent_or_service_route = $false
        adopted_code_applicability = $false
        current_610aa001_020_product_geometry = $false
        m06_assignment = $false
        ifc_or_revit_placement = $false
    }
    limitations = @(
        'B is a 158 x 84 in gross room-block gap, not verified clear interior dimensions or a room with walls.',
        'The body envelope is nominal predecessor product data and is not verified for current SKU 610AA001.020.',
        'The side-clearance bounding width assumes opposing side boundaries and centered placement; the actual wall and fixture topology is unknown.',
        'The 21-in front strip checks only a simple rectangle from the predecessor body; it is not door maneuvering, a user approach, or a lavatory clearance.',
        'No 30-in adjacent-fixture centerline test can be made without a selected sink or lavatory.',
        'This screen does not establish code compliance, accessibility, usability, plumbing feasibility, a room footprint, or assignment of B.'
    )
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$json = ConvertTo-Json -InputObject $report -Depth 12
[System.IO.File]::WriteAllText($resolvedOutput, $json + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: M-06 predecessor-only clearance proxy saved to $resolvedOutput"
