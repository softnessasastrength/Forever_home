param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$inputPath = Join-Path $repoRoot 'Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30/m120-inputs.json'
$proposalPath = Join-Path $repoRoot 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$pairPath = Join-Path $repoRoot 'Research/M06_Predecessor_Toilet_Sink_Gross_Pair_Screen_2026-10-28.json'
$selectedDPath = Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$inputHashExpected = '6cf5ff8d772c792ae7e12fca132126d7a5ce88ac98874ef4e4ce4778a0ac4a60'
$proposalHashExpected = '0519c9f350c41fbc9f7ba1b6b926c2b26e40f17cb5eacc3c13d5acaaf2749537'
$pairHashExpected = 'dc8792eca14cffeb2fe4589ef6f7a303ccfca15be53602fcc70c68af7e193adb'
$selectedDHashExpected = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'

function Get-Hash([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Assert-Equal([string]$Name, $Actual, $Expected) {
    if ($Actual -ne $Expected) { throw "$Name mismatch: expected '$Expected'; found '$Actual'." }
}

$inputHash = Get-Hash $inputPath
$proposalHash = Get-Hash $proposalPath
$pairHash = Get-Hash $pairPath
$selectedDHash = Get-Hash $selectedDPath
Assert-Equal 'Input observations SHA256' $inputHash $inputHashExpected
Assert-Equal 'Owner proposal SHA256' $proposalHash $proposalHashExpected
Assert-Equal 'Pair candidate source SHA256' $pairHash $pairHashExpected
Assert-Equal 'Selected-D source SHA256' $selectedDHash $selectedDHashExpected

$inputs = Get-Content -LiteralPath $inputPath -Raw | ConvertFrom-Json
$proposal = Get-Content -LiteralPath $proposalPath -Raw | ConvertFrom-Json
$pairs = Get-Content -LiteralPath $pairPath -Raw | ConvertFrom-Json
if ($inputs.schema -ne 'forever-home.m120-m06-product-observations.v1' -or
    $proposal.M06.status -ne 'unassigned; no footprint, position, fixture or service route' -or
    $proposal.M06.first_fit_window.id -ne 'M06-B' -or
    $pairs.schema -ne 'forever-home-m06-predecessor-toilet-sink-gross-pair-screen-v1') {
    throw 'Unexpected M120 input schema or M-06 assignment state.'
}

$wc = $inputs.american_standard.dimensions_in
$basis = $inputs.screen_basis
$grossWidth = [Math]::Round(([double]$proposal.M06.first_fit_window.width_ft * 12), 4)
$grossDepth = [Math]::Round(([double]$proposal.M06.first_fit_window.depth_ft * 12), 4)
$wcCenter = [double]$basis.wc_centerline_to_side_obstruction_in
$lavCenter = $wcCenter + [double]$basis.adjacent_fixture_centerline_spacing_in
$front = [double]$basis.front_clearance_in
$rows = @()
foreach ($pair in $pairs.fixture_pairs) {
    $lavWidth = [double]$pair.sink_body_width_along_wall_in
    $lavDepth = [double]$pair.sink_body_depth_from_rear_line_in
    $wcLeft = $wcCenter - ([double]$wc.overall_width / 2)
    $wcRight = $wcCenter + ([double]$wc.overall_width / 2)
    $lavLeft = $lavCenter - ($lavWidth / 2)
    $lavRight = $lavCenter + ($lavWidth / 2)
    $centerSpacing = $lavCenter - $wcCenter
    $nearestLavEdgeFromWcCenter = $lavLeft - $wcCenter
    $requiredWidth = [Math]::Max($wcRight, $lavRight)
    $requiredDepth = [Math]::Max(([double]$wc.projection + $front), ($lavDepth + $front))
    $contained = $requiredWidth -le $grossWidth -and $requiredDepth -le $grossDepth
    $rows += [ordered]@{
        sink_id = [string]$pair.sink_id
        sink_name = [string]$pair.sink_name
        sink_rotation_deg = [int]$pair.sink_rotation_deg
        sink_source_candidate_status = [string]$pair.sink_candidate_status
        wc_sku = [string]$inputs.selected_wc_sku
        wc_dimensions_source = 'American Standard current-SKU manufacturer infographic; plan size 19 x 30.25 in'
        wc_width_in = [double]$wc.overall_width
        wc_projection_in = [double]$wc.projection
        lavatory_symbol_bounds_are_installed_geometry = $false
        wc_centerline_to_side_boundary_in = $wcCenter
        centerline_spacing_in = $centerSpacing
        nearest_lavatory_body_edge_from_wc_centerline_in = [Math]::Round($nearestLavEdgeFromWcCenter, 4)
        nearest_lavatory_edge_meets_15in_screen = ($nearestLavEdgeFromWcCenter -ge [double]$basis.wc_centerline_to_side_obstruction_in)
        wc_left_in = [Math]::Round($wcLeft, 4)
        wc_right_in = [Math]::Round($wcRight, 4)
        lavatory_left_in = [Math]::Round($lavLeft, 4)
        lavatory_right_in = [Math]::Round($lavRight, 4)
        body_boxes_nonoverlap_in_assumed_axis = ($lavLeft -ge $wcRight)
        required_gross_width_in = [Math]::Round($requiredWidth, 4)
        required_gross_depth_in_including_front_strip = [Math]::Round($requiredDepth, 4)
        fit_window_width_in = $grossWidth
        fit_window_depth_in = $grossDepth
        contained_in_gross_B_rectangle = $contained
        inherited_assumption = 'Bodies aligned to one hypothetical rear wall; 30-in fixture centerlines and 15-in WC side-centerline minimum; a rectangular 21-in front strip; no door or service geometry.'
    }
}

$passing = @($rows | Where-Object { $_.contained_in_gross_B_rectangle }).Count
$clearancePass = @($rows | Where-Object { $_.nearest_lavatory_edge_meets_15in_screen }).Count
$nonoverlapPass = @($rows | Where-Object { $_.body_boxes_nonoverlap_in_assumed_axis }).Count
$checks = [ordered]@{
    schema = 'forever-home.m120-m06-screen-checks.v1'
    result = if ($passing -eq $rows.Count -and $clearancePass -eq $rows.Count -and $nonoverlapPass -eq $rows.Count) { 'pass' } else { 'fail' }
    check_count = 14
    checks = [ordered]@{
        observation_input_hash_matches = ($inputHash -eq $inputHashExpected)
        selected_d_hash_matches = ($selectedDHash -eq $selectedDHashExpected)
        owner_proposal_hash_matches = ($proposalHash -eq $proposalHashExpected)
        predecessor_pair_source_hash_matches = ($pairHash -eq $pairHashExpected)
        m06_remains_unassigned = ($proposal.M06.status -eq 'unassigned; no footprint, position, fixture or service route')
        current_wc_source_identifies_selected_sku = ($inputs.selected_wc_sku -eq '610AA001.020')
        current_wc_plan_bounds_are_finite_positive = ([double]$wc.overall_width -gt 0 -and [double]$wc.projection -gt 0)
        wc_rough_in_is_retained = ([double]$wc.rough_in -eq 12.0)
        sink_candidate_pair_count_matches = ($rows.Count -eq $pairs.fixture_pairs.Count)
        all_pairs_meet_preliminary_side_spacing_screen = ($clearancePass -eq $rows.Count)
        all_pair_body_boxes_nonoverlap_under_assumption = ($nonoverlapPass -eq $rows.Count)
        all_pairs_contained_in_gross_B_rectangle = ($passing -eq $rows.Count)
        no_pair_promoted_to_selected_fixture = ($rows | Where-Object { $_.sink_source_candidate_status -notmatch 'selected' }).Count -eq $rows.Count
        no_room_assignment_or_compliance_claim = (-not $inputs.screen_basis.applicability_determined -and $proposal.M06.status -like 'unassigned*')
    }
    counts = [ordered]@{ pairs = $rows.Count; side_spacing_screen_pass = $clearancePass; body_nonoverlap_pass = $nonoverlapPass; gross_containment_pass = $passing }
}
if ($checks.result -ne 'pass' -or @($checks.checks.Values | Where-Object { $_ -ne $true }).Count -gt 0) {
    throw "M120 validation failed: $($checks | ConvertTo-Json -Depth 8)"
}

$report = [ordered]@{
    schema = 'forever-home.m120-m06-current-envelope-screen.v1'
    status = 'passed labelled gross-rectangle screen; no product selection, placed fit or M-06 assignment'
    source_fingerprints_sha256 = [ordered]@{
        observations = $inputHash
        selected_D = $selectedDHash
        owner_followup_proposal = $proposalHash
        predecessor_sink_candidate_screen = $pairHash
    }
    source_evidence = [ordered]@{
        target_wc_sku = [string]$inputs.selected_wc_sku
        toilet_manufacturer_infographic_sha256 = [string]$inputs.american_standard.infographic_sha256
        tresham_rfa_sha256 = [string]$inputs.tresham.source_sha256
        tresham_placement_type = [string]$inputs.tresham.placement_type
        tresham_positive_solids = [int]$inputs.tresham.positive_volume_solid_count
        tresham_family_symbol_bounds_in = $inputs.tresham.bounds_in
    }
    fit_window = [ordered]@{
        id = [string]$proposal.M06.first_fit_window.id
        gross_width_in = $grossWidth
        gross_depth_in = $grossDepth
        gross_area_sf = [double]$proposal.M06.first_fit_window.area_sf
        location_label = 'Pantry-side first search window, owner-selected; entry/hall edge study context'
        assigned = $false
    }
    screen_basis = [ordered]@{
        wc_side_centerline_min_in = [double]$basis.wc_centerline_to_side_obstruction_in
        adjacent_fixture_centerline_spacing_in = [double]$basis.adjacent_fixture_centerline_spacing_in
        front_clear_strip_in = $front
        jurisdiction = 'Connecticut research basis; local applicability not determined'
        code_compliance = $false
    }
    pair_count = $rows.Count
    gross_containment_count = $passing
    fixture_pairs = $rows
    conclusions = @(
        'The current manufacturer infographic publishes 19-in width and 30.25-in projection callouts for the selected 610AA001.020 SKU; current linked spec paperwork remains predecessor documentation.',
        'Revit disposable intake measured the quarantined Tresham symbol from three positive-volume solids and identified WorkPlaneBased placement; no project host or connection objects were validated.',
        'The sampled research lavatory boxes and current published WC plan rectangle fit the unassigned 124 x 84 in gross B rectangle under the inherited simplified same-wall assumptions.',
        'Gross containment does not establish actual fit, door/approach, plumbing route, accessibility, code applicability or selection. M-06 remains unassigned.'
    )
    limitations = @(
        'No exact-current-SKU toilet RFA or complete current-SKU installation drawing was verified.',
        'The Tresham bounds are family-symbol positive-solid extents, not hosted/project-oriented geometry or a connector audit.',
        'Research lavatory families are not selected products; source dimensions may not represent installed clear envelopes.',
        'Actual room walls, finished faces, door leaf/swing, approach and privacy, plumbing rough-ins and service routing are absent.',
        'This is neither a code-compliance nor accessibility review; municipality, permit date, occupancy and adopted-code applicability remain for project-specific confirmation.'
    )
}
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) { [System.IO.Path]::GetFullPath($OutputDirectory) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory)) }
if (-not (Test-Path -LiteralPath $resolvedOutput)) { New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null }
$reportPath = Join-Path $resolvedOutput 'm120-report.json'
$checksPath = Join-Path $resolvedOutput 'm120-checks.json'
[System.IO.File]::WriteAllText($reportPath, (ConvertTo-Json -InputObject $report -Depth 16) + "`r`n", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText($checksPath, (ConvertTo-Json -InputObject $checks -Depth 12) + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: M120 $($checks.check_count)/$($checks.check_count); $passing/$($rows.Count) research toilet/lavatory boxes contained in gross B. No M-06 assignment."
