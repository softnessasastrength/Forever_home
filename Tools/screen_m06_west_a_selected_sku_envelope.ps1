param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M229_M06_West_A_Selected_SKU_Envelope_2026-10-31/artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$studyPath = Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$inputsPath = Join-Path $repoRoot 'Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30/m120-inputs.json'
$m120ReportPath = Join-Path $repoRoot 'Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30/m120-report.json'
$expectedStudyHash = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
$expectedInputsHash = '6cf5ff8d772c792ae7e12fca132126d7a5ce88ac98874ef4e4ce4778a0ac4a60'

function Get-Hash([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Assert-Equal([string]$Name, $Actual, $Expected) {
    if ($Actual -ne $Expected) { throw "$Name mismatch: expected '$Expected'; found '$Actual'." }
}

$studyHash = Get-Hash $studyPath
$inputsHash = Get-Hash $inputsPath
Assert-Equal 'Selected-D SHA256' $studyHash $expectedStudyHash
Assert-Equal 'M120 observations SHA256' $inputsHash $expectedInputsHash

$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$inputs = Get-Content -LiteralPath $inputsPath -Raw | ConvertFrom-Json
$m120 = Get-Content -LiteralPath $m120ReportPath -Raw | ConvertFrom-Json
$m06 = $study.selection.main_public_bath
$windows = @($m06.search_windows)
$west = @($windows | Where-Object id -eq 'west_of_core')
$east = @($windows | Where-Object id -eq 'east_of_core')
$wc = $inputs.american_standard.dimensions_in
$basis = $inputs.screen_basis

if ($study.layout_variant -ne 'OwnerSelectedD' -or $m06.id -ne 'M-06' -or
    $m06.footprint -ne 'TBD' -or $m06.position -ne 'TBD' -or $m06.service_route -ne 'TBD') {
    throw 'Selected-D M-06 must remain unassigned before this screen can run.'
}
if ($west.Count -ne 1 -or $east.Count -ne 1 -or
    $west[0].status -notlike 'Unassigned room-block gap only*' -or
    $east[0].status -notlike 'Unassigned room-block gap only*') {
    throw 'Both selected-D M-06 windows must remain unassigned room-block gaps.'
}
if ($m120.schema -ne 'forever-home.m120-m06-current-envelope-screen.v1' -or
    $m120.source_fingerprints_sha256.selected_D -ne $studyHash -or
    $m120.source_evidence.target_wc_sku -ne '610AA001.020' -or
    $inputs.selected_wc_sku -ne '610AA001.020' -or
    $inputs.american_standard.rfa_or_cad_for_exact_sku_verified -ne $false) {
    throw 'M120 must identify the selected SKU and bind it to this selected-D source without asserting CAD.'
}
if ([string]$inputs.american_standard.infographic_sha256 -notmatch '^[0-9a-fA-F]{64}$' -or
    [double]$wc.overall_width -ne 19.0 -or [double]$wc.projection -ne 30.25 -or
    [double]$basis.wc_centerline_to_side_obstruction_in -ne 15.0 -or
    [double]$basis.front_clearance_in -ne 21.0 -or
    $basis.applicability_determined -ne $false) {
    throw 'Expected the hash-recorded manufacturer infographic plan callouts and provisional spacing values.'
}

$westWidthIn = [double]$west[0].w * 12.0
$westDepthIn = [double]$west[0].d * 12.0
$bodyWidthIn = [double]$wc.overall_width
$bodyDepthIn = [double]$wc.projection
$sideIn = [double]$basis.wc_centerline_to_side_obstruction_in
$frontIn = [double]$basis.front_clearance_in
$orientations = @(
    [ordered]@{ rotation_deg = 0; body_width_in = $bodyWidthIn; body_depth_in = $bodyDepthIn },
    [ordered]@{ rotation_deg = 90; body_width_in = $bodyDepthIn; body_depth_in = $bodyWidthIn }
)
$results = @(
    foreach ($o in $orientations) {
        # This rectangle reserves 15 in each side from the toilet centerline and 21 in in front.
        $requiredWidth = [Math]::Max([double]$o.body_width_in, 2.0 * $sideIn)
        $requiredDepth = [double]$o.body_depth_in + $frontIn
        [ordered]@{
            rotation_deg = [int]$o.rotation_deg
            selected_sku_plan_body_width_in = [double]$o.body_width_in
            selected_sku_plan_body_projection_in = [double]$o.body_depth_in
            required_body_plus_side_spacing_width_in = [Math]::Round($requiredWidth, 3)
            required_body_plus_front_strip_depth_in = [Math]::Round($requiredDepth, 3)
            centerline_to_each_side_obstruction_screen_in = $sideIn
            front_clear_strip_screen_in = $frontIn
            contained_in_gross_west_a = ($requiredWidth -le $westWidthIn -and $requiredDepth -le $westDepthIn)
            remaining_gross_width_in = [Math]::Round(($westWidthIn - $requiredWidth), 3)
            remaining_gross_depth_in = [Math]::Round(($westDepthIn - $requiredDepth), 3)
            assumption = 'Rectangular current-SKU manufacturer infographic plan envelope; centered WC centerline for side-spacing proxy; front strip begins at nominal fixture projection.'
        }
    }
)
$containedCount = @($results | Where-Object contained_in_gross_west_a).Count
$checks = [ordered]@{
    schema = 'forever-home.m06-west-a-selected-sku-envelope-checks.v1'
    result = 'pass'
    check_count = 14
    checks = [ordered]@{
        selected_d_hash_matches_pinned_baseline = ($studyHash -eq $expectedStudyHash)
        m120_observations_hash_matches_pinned_record = ($inputsHash -eq $expectedInputsHash)
        m120_screen_matches_selected_d_hash = ($m120.source_fingerprints_sha256.selected_D -eq $studyHash)
        selected_sku_is_owner_selected_610aa = ($inputs.selected_wc_sku -eq '610AA001.020' -and $m120.source_evidence.target_wc_sku -eq '610AA001.020')
        infographic_source_digest_is_recorded = ($inputs.american_standard.infographic_sha256 -match '^[0-9a-fA-F]{64}$')
        manufacturer_plan_width_is_positive = ([double]$wc.overall_width -gt 0)
        manufacturer_plan_projection_is_positive = ([double]$wc.projection -gt 0)
        current_sku_dimensions_are_19_by_30_25 = ([double]$wc.overall_width -eq 19.0 -and [double]$wc.projection -eq 30.25)
        preliminary_side_spacing_is_15_in = ($sideIn -eq 15.0)
        preliminary_front_spacing_is_21_in = ($frontIn -eq 21.0)
        code_applicability_remains_undetermined = ($basis.applicability_determined -eq $false)
        west_a_and_east_b_remain_unassigned = ($west[0].status -like 'Unassigned room-block gap only*' -and $east[0].status -like 'Unassigned room-block gap only*')
        both_plan_orientations_fit_the_gross_comparison_rectangle = ($containedCount -eq 2)
        no_exact_sku_cad_or_room_fit_claim = ($inputs.american_standard.rfa_or_cad_for_exact_sku_verified -eq $false -and $m06.footprint -eq 'TBD' -and $m06.position -eq 'TBD')
    }
    contained_orientation_count = $containedCount
}
if (@($checks.checks.Values | Where-Object { $_ -ne $true }).Count -gt 0) {
    $checks.result = 'fail'
    throw "M229 checks failed: $($checks | ConvertTo-Json -Depth 8)"
}

$report = [ordered]@{
    schema = 'forever-home.m06-west-a-selected-sku-envelope.v1'
    status = 'bounded gross-rectangle screen; no room assignment or installed fit established'
    selected_d_sha256 = $studyHash
    m120_observations_sha256 = $inputsHash
    selected_sku = '610AA001.020'
    plan_envelope_source = 'American Standard manufacturer infographic; digest recorded in M120 observations'
    plan_envelope_source_sha256 = [string]$inputs.american_standard.infographic_sha256
    current_sku_plan_dimensions_in = [ordered]@{ width = $bodyWidthIn; projection = $bodyDepthIn }
    exact_sku_rfa_or_cad_verified = [bool]$inputs.american_standard.rfa_or_cad_for_exact_sku_verified
    code_screen = [ordered]@{
        basis = '2022 CSBC / adopted 2021 IRC R307.1 and P2705.1; provisional one-family spacing screen'
        side_centerline_min_in = $sideIn
        front_clear_strip_in = $frontIn
        local_applicability_determined = [bool]$basis.applicability_determined
    }
    west_a = [ordered]@{
        gross_width_in = [Math]::Round($westWidthIn, 3)
        gross_depth_in = [Math]::Round($westDepthIn, 3)
        gross_area_sf = [double]$west[0].gross_area_sf
        remains_unassigned = $true
    }
    east_b_remains_unassigned = $true
    orientation_count = $results.Count
    contained_orientation_count = $containedCount
    orientations = $results
    evaluated = [ordered]@{
        current_selected_sku_manufacturer_plan_envelope = $true
        exact_sku_3d_family_or_cad = $false
        complete_fixture_pair_or_lavatory = $false
        actual_room_walls_or_finished_faces = $false
        door_swing_or_hall_approach = $false
        water_waste_vent_or_service_route = $false
        code_applicability_or_compliance = $false
        room_assignment = $false
        selected_d_or_ifc_modified = $false
    }
    limitations = @(
        'The 19 x 30.25 in dimensions are current-SKU manufacturer infographic plan callouts; no exact-SKU RFA/CAD or complete current installation drawing was verified.',
        'A is a 62 x 137 in gross room-block gap, not finished clear interior dimensions or an established room.',
        'The 15 in / 21 in values are provisional residential spacing screens; project-specific applicability and accessibility scope are undetermined.',
        'The lavatory, adjacent-fixture spacing, actual door and operation, arrival route, finished walls, privacy and plumbing/services are not included.',
        'Containment of the toilet-only screen does not establish that A can be assigned or that M-06 fits.'
    )
}

$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) { [System.IO.Path]::GetFullPath($OutputDirectory) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory)) }
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null
[System.IO.File]::WriteAllText((Join-Path $resolvedOutput 'm229-report.json'), (ConvertTo-Json -InputObject $report -Depth 16) + "`r`n", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $resolvedOutput 'm229-checks.json'), (ConvertTo-Json -InputObject $checks -Depth 12) + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: M229 $($checks.check_count)/$($checks.check_count); $containedCount/2 selected-SKU plan-envelope orientation screens contained in gross west A. A and B remain unassigned."
