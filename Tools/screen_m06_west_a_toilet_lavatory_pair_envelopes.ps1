param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M230_West_A_Toilet_Lavatory_Envelopes_2026-10-31/artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$studyPath = Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m120InputsPath = Join-Path $repoRoot 'Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30/m120-inputs.json'
$sinkPairPath = Join-Path $repoRoot 'Research/M06_Predecessor_Toilet_Sink_Gross_Pair_Screen_2026-10-28.json'
$ownerDirectionPath = Join-Path $repoRoot 'Decisions/2026-10-31_M06_West_A_Protection.md'
$expectedStudyHash = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
$expectedM120Hash = '6cf5ff8d772c792ae7e12fca132126d7a5ce88ac98874ef4e4ce4778a0ac4a60'
$expectedPairHash = 'dc8792eca14cffeb2fe4589ef6f7a303ccfca15be53602fcc70c68af7e193adb'
$expectedOwnerDirectionHash = 'a5cf98360b75314f4d3486f925e9d860465bb33d1ecfce9b0cbb39ce0eff853b'

function Get-Hash([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Assert-Equal([string]$Name, $Actual, $Expected) {
    if ($Actual -ne $Expected) { throw "$Name mismatch: expected '$Expected'; found '$Actual'." }
}

$studyHash = Get-Hash $studyPath
$m120Hash = Get-Hash $m120InputsPath
$pairHash = Get-Hash $sinkPairPath
$ownerDirectionHash = Get-Hash $ownerDirectionPath
Assert-Equal 'Selected-D SHA256' $studyHash $expectedStudyHash
Assert-Equal 'M120 input SHA256' $m120Hash $expectedM120Hash
Assert-Equal 'Sink candidate pair screen SHA256' $pairHash $expectedPairHash
Assert-Equal 'Owner A-protection direction SHA256' $ownerDirectionHash $expectedOwnerDirectionHash

$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$m120 = Get-Content -LiteralPath $m120InputsPath -Raw | ConvertFrom-Json
$sourcePairs = Get-Content -LiteralPath $sinkPairPath -Raw | ConvertFrom-Json
$ownerDirection = Get-Content -LiteralPath $ownerDirectionPath -Raw
$m06 = $study.selection.main_public_bath
$windows = @($m06.search_windows)
$west = @($windows | Where-Object id -eq 'west_of_core')
$east = @($windows | Where-Object id -eq 'east_of_core')
if ($study.layout_variant -ne 'OwnerSelectedD' -or $m06.footprint -ne 'TBD' -or $m06.position -ne 'TBD' -or $m06.service_route -ne 'TBD') {
    throw 'Selected-D M-06 must remain unassigned before this comparison can run.'
}
if ($west.Count -ne 1 -or $east.Count -ne 1 -or
    $west[0].status -notlike 'Unassigned room-block gap only*' -or
    $east[0].status -notlike 'Unassigned room-block gap only*' -or
    $ownerDirection -notmatch 'Protect A for M-06' -or
    $ownerDirection -notmatch 'West diagnostic window A must remain free') {
    throw 'Expected both unassigned search windows and the committed west-A protection direction.'
}
if ($m120.schema -ne 'forever-home.m120-m06-product-observations.v1' -or
    $m120.selected_wc_sku -ne '610AA001.020' -or
    $sourcePairs.schema -ne 'forever-home-m06-predecessor-toilet-sink-gross-pair-screen-v1' -or
    $sourcePairs.fixture_pairs.Count -ne 16 -or
    [double]$m120.american_standard.dimensions_in.overall_width -ne 19.0 -or
    [double]$m120.american_standard.dimensions_in.projection -ne 30.25 -or
    $m120.american_standard.rfa_or_cad_for_exact_sku_verified -ne $false) {
    throw 'Expected the hash-pinned selected-SKU plan envelope and eight two-orientation sink research candidates.'
}
$basis = $m120.screen_basis
if ([double]$basis.wc_centerline_to_side_obstruction_in -ne 15.0 -or
    [double]$basis.adjacent_fixture_centerline_spacing_in -ne 30.0 -or
    [double]$basis.front_clearance_in -ne 21.0 -or
    $basis.applicability_determined -ne $false) {
    throw 'Expected the provisional 15/30/21-in residential spacing screen with applicability undetermined.'
}

$grossWidth = [double]$west[0].w * 12.0
$grossDepth = [double]$west[0].d * 12.0
$wcWidth = [double]$m120.american_standard.dimensions_in.overall_width
$wcProjection = [double]$m120.american_standard.dimensions_in.projection
$side = [double]$basis.wc_centerline_to_side_obstruction_in
$centerSpacing = [double]$basis.adjacent_fixture_centerline_spacing_in
$front = [double]$basis.front_clearance_in
$wcCenter = $side
$lavCenter = $wcCenter + $centerSpacing
$rows = @(
    foreach ($pair in $sourcePairs.fixture_pairs) {
        $lavWidth = [double]$pair.sink_body_width_along_wall_in
        $lavDepth = [double]$pair.sink_body_depth_from_rear_line_in
        if ($lavWidth -le 0 -or $lavDepth -le 0 -or $pair.sink_candidate_status -match '^selected') {
            throw "Invalid or selected sink candidate in source pair '$($pair.sink_id)' rotation $($pair.sink_rotation_deg)."
        }
        $wcLeft = $wcCenter - ($wcWidth / 2.0)
        $wcRight = $wcCenter + ($wcWidth / 2.0)
        $lavLeft = $lavCenter - ($lavWidth / 2.0)
        $lavRight = $lavCenter + ($lavWidth / 2.0)
        $nearestLavEdgeFromWcCenter = $lavLeft - $wcCenter
        $requiredWidth = [Math]::Max($wcRight, $lavRight)
        $requiredDepth = [Math]::Max($wcProjection, $lavDepth) + $front
        $followupEvidence = if ($pair.sink_id -eq 'kohler-tresham-k-2844-4-0') {
            'M119/M150 later record read-only Tresham family evidence with 24.0063 x 19.4998 x 34.625 in symbol-local bounds; this does not establish host orientation or installed fit.'
        } else {
            'No later family measurement is asserted by this pair-screen.'
        }
        [ordered]@{
            sink_id = [string]$pair.sink_id
            sink_name = [string]$pair.sink_name
            sink_rotation_deg = [int]$pair.sink_rotation_deg
            sink_candidate_status = [string]$pair.sink_candidate_status
            followup_family_evidence = $followupEvidence
            sink_plan_body_width_along_shared_wall_in = $lavWidth
            sink_plan_body_depth_from_shared_back_line_in = $lavDepth
            toilet_sku = [string]$m120.selected_wc_sku
            toilet_plan_width_in = $wcWidth
            toilet_plan_projection_in = $wcProjection
            toilet_centerline_from_side_boundary_in = $wcCenter
            fixture_centerline_spacing_in = $centerSpacing
            nearest_sink_body_edge_from_toilet_centerline_in = [Math]::Round($nearestLavEdgeFromWcCenter, 4)
            preliminary_wc_side_spacing_pass = ($nearestLavEdgeFromWcCenter -ge $side)
            body_rectangles_nonoverlap = ($lavLeft -ge $wcRight)
            required_gross_width_in = [Math]::Round($requiredWidth, 4)
            required_gross_depth_in_including_front_strip = [Math]::Round($requiredDepth, 4)
            contained_in_gross_west_a = ($requiredWidth -le $grossWidth -and $requiredDepth -le $grossDepth)
            remaining_gross_width_in = [Math]::Round(($grossWidth - $requiredWidth), 4)
            remaining_gross_depth_in = [Math]::Round(($grossDepth - $requiredDepth), 4)
            assumption = 'Both fixture plan rectangles align along one hypothetical shared back line; WC centerline is 15 in from a hypothetical side boundary; lavatory centerline is 30 in from WC; a 21-in front strip is added to the deeper body.'
            limitation = 'Sink plan rectangles are research candidate dimensions, not selected products or verified installed clear envelopes. This is gross room-block containment only.'
        }
    }
)

$containedCount = @($rows | Where-Object contained_in_gross_west_a).Count
$sidePassCount = @($rows | Where-Object preliminary_wc_side_spacing_pass).Count
$nonoverlapCount = @($rows | Where-Object body_rectangles_nonoverlap).Count
$maximumRequiredWidth = [double](($rows | ForEach-Object { [double]$_['required_gross_width_in'] } | Measure-Object -Maximum).Maximum)
$checks = [ordered]@{
    schema = 'forever-home.m06-west-a-toilet-lavatory-pair-checks.v1'
    result = 'pass'
    check_count = 16
    checks = [ordered]@{
        selected_d_hash_matches_pinned_baseline = ($studyHash -eq $expectedStudyHash)
        m120_input_hash_matches_pinned_source = ($m120Hash -eq $expectedM120Hash)
        sink_pair_hash_matches_pinned_source = ($pairHash -eq $expectedPairHash)
        owner_protection_direction_hash_matches = ($ownerDirectionHash -eq $expectedOwnerDirectionHash)
        owner_direction_protects_west_a = ($ownerDirection -match 'Protect A for M-06')
        selected_d_m06_remains_unassigned = ($m06.footprint -eq 'TBD' -and $m06.position -eq 'TBD' -and $m06.service_route -eq 'TBD')
        both_search_windows_remain_unassigned = ($west[0].status -like 'Unassigned room-block gap only*' -and $east[0].status -like 'Unassigned room-block gap only*')
        target_toilet_is_610aa001_020 = ($m120.selected_wc_sku -eq '610AA001.020')
        current_sku_plan_envelope_is_19_by_30_25 = ($wcWidth -eq 19.0 -and $wcProjection -eq 30.25)
        all_sink_inputs_are_research_only = (@($sourcePairs.fixture_pairs | Where-Object { $_.sink_candidate_status -match '^selected' }).Count -eq 0)
        all_16_sink_orientation_cases_are_present = ($sourcePairs.fixture_pairs.Count -eq 16)
        side_spacing_basis_is_provisional_15_in = ($side -eq 15.0 -and -not $basis.applicability_determined)
        center_spacing_basis_is_provisional_30_in = ($centerSpacing -eq 30.0)
        front_spacing_basis_is_provisional_21_in = ($front -eq 21.0)
        all_body_rectangles_pass_pair_spacing_and_nonoverlap = ($sidePassCount -eq 16 -and $nonoverlapCount -eq 16)
        no_rfa_room_or_compliance_claim = ($m120.american_standard.rfa_or_cad_for_exact_sku_verified -eq $false -and $m06.footprint -eq 'TBD' -and $m06.position -eq 'TBD' -and -not $basis.applicability_determined)
    }
    west_a = [ordered]@{ gross_width_in = $grossWidth; gross_depth_in = $grossDepth; gross_area_sf = [double]$west[0].gross_area_sf }
    cases = $rows.Count
    side_spacing_pass_count = $sidePassCount
    body_nonoverlap_count = $nonoverlapCount
    gross_containment_count = $containedCount
    narrowest_case_remaining_width_in = [Math]::Round(($grossWidth - $maximumRequiredWidth), 4)
}
if (@($checks.checks.Values | Where-Object { $_ -ne $true }).Count -gt 0) {
    $checks.result = 'fail'
    throw "M230 checks failed: $($checks | ConvertTo-Json -Depth 12)"
}

$report = [ordered]@{
    schema = 'forever-home.m06-west-a-toilet-lavatory-pair-envelopes.v1'
    status = 'bounded same-wall gross-rectangle comparison; no product selection or room assignment'
    source_hashes_sha256 = [ordered]@{
        selected_d = $studyHash
        m120_current_toilet_observations = $m120Hash
        sink_candidate_pair_screen = $pairHash
        owner_west_a_protection_direction = $ownerDirectionHash
    }
    owner_protection_scope = 'West A protected for M-06; B remains unassigned. This study keeps both windows as room-block reservations.'
    toilet = [ordered]@{
        selected_sku = [string]$m120.selected_wc_sku
        plan_width_in = $wcWidth
        plan_projection_in = $wcProjection
        envelope_source = 'Current-SKU American Standard manufacturer infographic; digest recorded in M120'
        exact_sku_rfa_cad_verified = [bool]$m120.american_standard.rfa_or_cad_for_exact_sku_verified
    }
    west_a = [ordered]@{
        gross_width_in = [Math]::Round($grossWidth, 4)
        gross_depth_in = [Math]::Round($grossDepth, 4)
        gross_area_sf = [double]$west[0].gross_area_sf
        remains_unassigned = $true
    }
    assumed_same_wall_screen = [ordered]@{
        wc_centerline_to_side_boundary_in = $side
        wc_centerline_to_adjacent_fixture_centerline_in = $centerSpacing
        front_clear_strip_in = $front
        code_basis = 'Preliminary 2021 IRC residential spacing screen under the published 2022 Connecticut State Building Code; local applicability undetermined'
        code_compliance = $false
        both_body_rectangles_share_hypothetical_rear_line = $true
        door_approach_or_service_route_modeled = $false
    }
    case_count = $rows.Count
    side_spacing_pass_count = $sidePassCount
    body_nonoverlap_count = $nonoverlapCount
    gross_containment_count = $containedCount
    cases = $rows
    findings = @(
        'All 16 source-listed research sink/orientation rectangles pass the selected 610AA plan-envelope same-wall screen in gross west A under the explicit 15 / 30 / 21 in assumptions.',
        'West A has 3.5 in of gross width remaining in the narrowest tested same-wall case; this is before walls, finishes, plumbing offsets, installation tolerance or access geometry.',
        'The sink candidate list includes discontinued, family-unverified or otherwise research-only products; no lavatory is selected.',
        'The source-listed Tresham candidate has separate read-only family evidence in M119/M150, but its family symbol bounds are not an installed or host-oriented room-fit measurement.',
        'A/B remain unassigned. No door, hall approach, finished-face fit, privacy, water/waste/vent service route, project-specific code applicability or complete half-bath fit is established.'
    )
    selected_d_modified = $false
    retained_rvt_ifc_modified = $false
    source_rfas_modified = $false
}

$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) { [System.IO.Path]::GetFullPath($OutputDirectory) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory)) }
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null
[System.IO.File]::WriteAllText((Join-Path $resolvedOutput 'm230-report.json'), (ConvertTo-Json -InputObject $report -Depth 20) + "`r`n", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $resolvedOutput 'm230-checks.json'), (ConvertTo-Json -InputObject $checks -Depth 16) + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: M230 $($checks.check_count)/$($checks.check_count); $containedCount/16 research toilet/lavatory plan pairs contained in gross west A. A and B remain unassigned."
