param(
    [string]$ProposalPath = (Join-Path $PSScriptRoot '../Architecture/House_Design_Iteration_2026-10-28/study.json'),
    [string]$PairScreenPath = (Join-Path $PSScriptRoot '../Research/M06_Predecessor_Toilet_Sink_Gross_Pair_Screen_2026-10-28.json'),
    [string]$TargetEnvelopePath = (Join-Path $PSScriptRoot '../Research/M06_610AA001_020_Retail_Reported_Envelope_2026-10-28.json'),
    [string]$SelectedDPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json')
)

$ErrorActionPreference = 'Stop'
$proposalFile = (Resolve-Path -LiteralPath $ProposalPath).Path
$pairFile = (Resolve-Path -LiteralPath $PairScreenPath).Path
$targetEnvelopeFile = (Resolve-Path -LiteralPath $TargetEnvelopePath).Path
$selectedDFile = (Resolve-Path -LiteralPath $SelectedDPath).Path
$proposal = Get-Content -LiteralPath $proposalFile -Raw | ConvertFrom-Json
$pairs = Get-Content -LiteralPath $pairFile -Raw | ConvertFrom-Json
$targetEnvelope = Get-Content -LiteralPath $targetEnvelopeFile -Raw | ConvertFrom-Json
$selectedD = Get-Content -LiteralPath $selectedDFile -Raw | ConvertFrom-Json

if ($proposal.schema -ne 'forever-home.owner-followup-design-study.v1' -or
    $proposal.M06.status -ne 'unassigned; no footprint, position, fixture or service route') {
    throw 'Expected the separate owner-follow-up proposal with M-06 explicitly unassigned.'
}
if ($pairs.schema -ne 'forever-home-m06-predecessor-toilet-sink-gross-pair-screen-v1' -or
    $pairs.evaluated.exact_610aa001_020_geometry -ne $false -or
    $pairs.evaluated.m06_assignment -ne $false) {
    throw 'Expected the versioned predecessor-only 16-pair screen with no current-SKU geometry or assignment.'
}
if ($targetEnvelope.schema -ne 'forever-home-m06-retailer-reported-target-envelope-v1' -or
    $targetEnvelope.target_sku -ne '610AA001.020' -or
    $targetEnvelope.evaluation.manufacturer_verified_current_product_geometry -ne $false) {
    throw 'Expected the exact-SKU retailer-reported envelope with manufacturer geometry still unverified.'
}
$selectedDHash = (Get-FileHash -LiteralPath $selectedDFile -Algorithm SHA256).Hash.ToLowerInvariant()
$proposalHash = (Get-FileHash -LiteralPath $proposalFile -Algorithm SHA256).Hash.ToLowerInvariant()
$pairHash = (Get-FileHash -LiteralPath $pairFile -Algorithm SHA256).Hash.ToLowerInvariant()
$targetEnvelopeHash = (Get-FileHash -LiteralPath $targetEnvelopeFile -Algorithm SHA256).Hash.ToLowerInvariant()
if ($proposal.source_selected_D_sha256 -ne $selectedDHash -or $pairs.study_sha256 -ne $selectedDHash) {
    throw 'The proposal, selected-D source and M54 pair report do not share the recorded source identity.'
}

$window = $proposal.M06.first_fit_window
if ($window.id -ne 'M06-B' -or $window.status -ne 'unassigned search window only; not M-06 geometry') {
    throw 'The follow-up M-06 first-fit window is missing or no longer marked as an unassigned search gap.'
}
$grossWidthIn = [Math]::Round(([double]$window.width_ft * 12.0), 3)
$grossDepthIn = [Math]::Round(([double]$window.depth_ft * 12.0), 3)
$toiletWidthIn = [double]$targetEnvelope.retailer_reported_overall_dimensions_in.width
$toiletDepthIn = [double]$targetEnvelope.retailer_reported_overall_dimensions_in.depth
$wcCenterXIn = 15.0
$sinkCenterXIn = 45.0
$frontClearanceIn = 21.0
if ([Math]::Abs($toiletWidthIn - [double]$pairs.toilet_proxy.nominal_body_width_in) -gt 0.001 -or
    [Math]::Abs($toiletDepthIn - [double]$pairs.toilet_proxy.nominal_body_projection_in) -gt 0.001) {
    throw 'Retailer-reported current-SKU plan envelope diverges from predecessor input; rebuild all pair calculations with the new plan bounds.'
}
$results = @()
foreach ($pair in $pairs.fixture_pairs) {
    $sinkWidthIn = [double]$pair.sink_body_width_along_wall_in
    $sinkDepthIn = [double]$pair.sink_body_depth_from_rear_line_in
    $toiletRightIn = $wcCenterXIn + ($toiletWidthIn / 2.0)
    $sinkLeftIn = $sinkCenterXIn - ($sinkWidthIn / 2.0)
    $sinkRightIn = $sinkCenterXIn + ($sinkWidthIn / 2.0)
    $requiredWidthIn = [Math]::Max($toiletRightIn, $sinkRightIn)
    $requiredDepthIn = [Math]::Max(($toiletDepthIn + $frontClearanceIn), ($sinkDepthIn + $frontClearanceIn))
    if ([Math]::Abs($requiredWidthIn - [double]$pair.required_gross_width_in) -gt 0.001 -or
        [Math]::Abs($requiredDepthIn - [double]$pair.required_gross_depth_in_including_front_strip) -gt 0.001) {
        throw "Recalculated plan envelope does not match retained predecessor screen for '$($pair.sink_id)' rotation $($pair.sink_rotation_deg)."
    }
    $contained = $requiredWidthIn -le $grossWidthIn -and $requiredDepthIn -le $grossDepthIn
    $results += [ordered]@{
        sink_id = [string]$pair.sink_id
        sink_name = [string]$pair.sink_name
        sink_rotation_deg = [int]$pair.sink_rotation_deg
        selected_target_sku = [string]$pairs.toilet_proxy.selected_target_sku
        toilet_plan_dimension_source = 'retailer-reported current SKU; XY dimensions cross-match the predecessor proxy'
        toilet_body_width_in = $toiletWidthIn
        toilet_body_depth_in = $toiletDepthIn
        sink_centerline_from_wc_centerline_in = 30.0
        toilet_centerline_from_hypothetical_side_boundary_in = $wcCenterXIn
        exact_target_sku_geometry_verified = $false
        required_gross_width_in = $requiredWidthIn
        required_gross_depth_in_including_front_strip = $requiredDepthIn
        contained_in_followup_B_gross_window = $contained
        remaining_gross_width_in = [Math]::Round(($grossWidthIn - $requiredWidthIn), 3)
        remaining_gross_depth_in = [Math]::Round(($grossDepthIn - $requiredDepthIn), 3)
        inherited_pair_assumptions = [string]$pair.assumption
    }
}
$passing = @($results | Where-Object { $_.contained_in_followup_B_gross_window }).Count
$status = if ($passing -eq $results.Count) { 'PASS: all retailer-reported target-SKU plan/lavatory boxes fit the follow-up B gross window under the hypothetical same-wall assumptions.' } else { "PARTIAL: $passing of $($results.Count) retailer-reported target-SKU/lavatory boxes fit the follow-up B gross window under the hypothetical same-wall assumptions." }

$report = [ordered]@{
    schema = 'forever-home-m06-followup-window-pair-recheck-v1'
    result = $status
    source_fingerprints_sha256 = [ordered]@{
        selected_D_study = $selectedDHash
        owner_followup_proposal = $proposalHash
        predecessor_pair_screen = $pairHash
        target_sku_retail_envelope = $targetEnvelopeHash
    }
    followup_window = [ordered]@{
        id = [string]$window.id
        label = 'Pantry-side B in separate owner-follow-up room-block proposal'
        x_ft = [double]$window.x_ft
        y_ft = [double]$window.y_ft
        gross_width_in = $grossWidthIn
        gross_depth_in = $grossDepthIn
        gross_area_sf = [double]$window.area_sf
        status = [string]$window.status
        remains_unassigned = $true
    }
    source_screen_geometry = [ordered]@{
        pair_report = [System.IO.Path]::GetFileName($pairFile)
        target_envelope_report = [System.IO.Path]::GetFileName($targetEnvelopeFile)
        pair_count = $results.Count
        source_screen_window_in = @([double]$pairs.search_window.gross_width_in,[double]$pairs.search_window.gross_depth_in)
        followup_window_is_smaller = ($grossWidthIn -lt [double]$pairs.search_window.gross_width_in)
    }
    toilet_envelope = [ordered]@{
        target_sku = '610AA001.020'
        width_in = $toiletWidthIn
        depth_in = $toiletDepthIn
        dimensions_are_retailer_reported = $true
        current_manufacturer_dimension_sheet_found = $false
        plan_dimensions_match_predecessor_proxy = $true
        retailer_source = [string]$targetEnvelope.retailer_source
        manufacturer_page = [string]$targetEnvelope.manufacturer_cross_check.product_page
        vertical_height_used_in_plan_screen = $false
        seat_height_discrepancy = 'American Standard page reports 17 in with seat; Wayfair reports 16.5 in seat height.'
    }
    code_screen_basis = [ordered]@{
        status_as_of = '2026-10-28'
        jurisdiction = 'Connecticut; project municipality, permit date and occupancy classification are unknown.'
        adopted_code_basis = '2022 Connecticut State Building Code adopts the 2021 IRC; 2026 code cycle was delayed pending approval.'
        assumed_scope = 'Detached one-family dwelling within 2021 IRC scope; confirm with the project municipality.'
        preliminary_sections = 'IRC R307.1 / Figure R307.1 and P2705.1; 15 in WC center to side obstruction, 30 in adjacent-fixture centerlines, 21 in clear in front; fixtures must not interfere with door/window operation.'
        source_ct_current_code = 'https://portal.ct.gov/en/das/office-of-state-building-inspector/connecticut-state-building-code/regulations'
        source_ct_2026_adoption_status = 'https://portal.ct.gov/das/office-of-state-building-inspector/building-and-fire-code-adoption-process'
        source_irc_2021_chapter_3 = 'https://codes.iccsafe.org/content/IRC2021P1/chapter-3-building-planning'
        source_irc_2021_chapter_27 = 'https://codes.iccsafe.org/content/IRC2021P2/chapter-27-plumbing-fixtures'
        is_compliance_determination = $false
    }
    evaluated = [ordered]@{
        retailer_reported_current_sku_plan_and_research_sink_rectangles_only = $true
        pair_containment_recalculated_from_target_retail_envelope = $true
        pair_containment_count = $passing
        candidate_product_selected = $false
        current_610aa001_020_geometry = $false
        actual_room_fit = $false
        M06_assignment = $false
        door_swing_hall_approach_or_privacy = $false
        walls_or_usable_clear_dimensions = $false
        installation_or_service_route = $false
        code_compliance_or_accessibility = $false
        Revit_or_IFC = $false
    }
    fixture_pairs = $results
    limitations = @(
        'The follow-up M-06-B rectangle is an unassigned gross room-block gap, not actual room or wall geometry.',
        'The exact-SKU XY input is retailer-reported and cross-matches the predecessor plan numbers; the current manufacturer drawing and inspected current-SKU family remain unavailable.',
        'Retailer and manufacturer seat-height reports differ (16.5 versus 17 in); no vertical envelope conclusion is made.',
        'The lavatory candidates are research-only; some exact family/type geometry remains uninspected and no candidate is selected.',
        'The inherited same-wall clearances are rectangular screening abstractions, not an actual clearance polygon or door/approach layout.',
        'No wall build-up, opening, swing, hall approach, privacy, finish, rough-in, water/drain/vent route, accessibility scope or local code applicability is tested.',
        'Passing gross containment does not assign M-06 or establish a usable, compliant, accessible, or buildable bathroom.'
    )
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$json = ConvertTo-Json -InputObject $report -Depth 12
[System.IO.File]::WriteAllText($resolvedOutput, $json + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "$status ($passing/$($results.Count)); retailer-reported target plan envelope; saved to $resolvedOutput"
