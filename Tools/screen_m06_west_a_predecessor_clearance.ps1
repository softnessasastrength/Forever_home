param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$PredecessorEnvelopePath = (Join-Path $PSScriptRoot '../Research/M06_Champion_PRO_Predecessor_Envelope_Screen_2026-10-28.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Architecture/M226_M06_West_A_Clearance_Proxy_2026-10-31/artifacts/m226-west-a-clearance-proxy.json')
)

$ErrorActionPreference = 'Stop'
$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$productFile = (Resolve-Path -LiteralPath $PredecessorEnvelopePath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$product = Get-Content -LiteralPath $productFile -Raw | ConvertFrom-Json
$m06 = $study.selection.main_public_bath

if ($study.layout_variant -ne 'OwnerSelectedD') { throw "Expected OwnerSelectedD; found '$($study.layout_variant)'." }
if ($m06.id -ne 'M-06' -or $m06.type -ne 'half bath' -or $m06.footprint -ne 'TBD' -or $m06.position -ne 'TBD') {
    throw 'M-06 is not unassigned in the selected-D source.'
}
if ($product.schema -ne 'forever-home-m06-predecessor-product-envelope-screen-v1' -or
    $product.study_sha256 -ne (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant() -or
    $product.target_candidate.exact_target_sku_geometry_verified -ne $false) {
    throw 'Expected the hash-matched, explicitly unverified predecessor envelope report.'
}
if ($product.target_candidate.target_sku -ne '610AA001.020' -or $product.target_candidate.proxy_series -ne '211AA104.020') {
    throw 'The product report does not identify the selected SKU and distinct predecessor proxy.'
}

$windows = @($m06.search_windows)
$west = @($windows | Where-Object id -eq 'west_of_core')
$east = @($windows | Where-Object id -eq 'east_of_core')
if ($west.Count -ne 1 -or $east.Count -ne 1 -or
    $west[0].status -notlike 'Unassigned room-block gap only*' -or
    $east[0].status -notlike 'Unassigned room-block gap only*') {
    throw 'Expected both source search windows to remain unassigned room-block gaps.'
}

$studyHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$productHash = (Get-FileHash -LiteralPath $productFile -Algorithm SHA256).Hash.ToLowerInvariant()
$sideClearanceIn = 15.0
$frontClearanceIn = 21.0
$bodyWidthIn = [double]$product.target_candidate.proxy_width_in
$bodyDepthIn = [double]$product.target_candidate.proxy_projection_in
$westWidthIn = [double]$west[0].w * 12.0
$westDepthIn = [double]$west[0].d * 12.0

$orientations = @(
    [ordered]@{ rotation_deg = 0; body_width_in = $bodyWidthIn; body_depth_in = $bodyDepthIn },
    [ordered]@{ rotation_deg = 90; body_width_in = $bodyDepthIn; body_depth_in = $bodyWidthIn }
)
$results = @(
    foreach ($orientation in $orientations) {
        # This lower-bound box checks only a centered predecessor body plus minimum WC spacing.
        $requiredWidthIn = [Math]::Max([double]$orientation.body_width_in, 2.0 * $sideClearanceIn)
        $requiredDepthIn = [double]$orientation.body_depth_in + $frontClearanceIn
        [ordered]@{
            rotation_deg = [int]$orientation.rotation_deg
            predecessor_body_width_in = [double]$orientation.body_width_in
            predecessor_body_depth_in = [double]$orientation.body_depth_in
            required_toilet_only_width_in = [Math]::Round($requiredWidthIn, 3)
            required_toilet_body_plus_front_strip_depth_in = [Math]::Round($requiredDepthIn, 3)
            side_clearance_centerline_to_each_side_in = $sideClearanceIn
            front_clearance_in = $frontClearanceIn
            contained_in_gross_west_a = ($requiredWidthIn -le $westWidthIn -and $requiredDepthIn -le $westDepthIn)
            remaining_gross_width_in = [Math]::Round(($westWidthIn - $requiredWidthIn), 3)
            remaining_gross_depth_in = [Math]::Round(($westDepthIn - $requiredDepthIn), 3)
            assumption = 'Rectangular predecessor toilet envelope centered between hypothetical opposing sides; minimum front strip begins at its nominal front edge.'
        }
    }
)

$report = [ordered]@{
    schema = 'forever-home-m06-west-a-predecessor-clearance-proxy-v1'
    status = 'bounded proxy screen; not a bathroom fit or code-compliance result'
    selected_d_study_sha256 = $studyHash
    predecessor_envelope_report = [System.IO.Path]::GetFileName($productFile)
    predecessor_envelope_report_sha256 = $productHash
    owner_selected_target_sku = '610AA001.020'
    proxy_predecessor_sku = '211AA104.020'
    exact_target_sku_geometry_verified = $false
    current_code_screen = [ordered]@{
        jurisdiction = 'Connecticut; project municipality, permit timing and occupancy confirmation remain open'
        code_basis = '2022 CSBC / adopted 2021 IRC, sections R307.1 and P2705.1, preliminary residential spacing screen'
        side_centerline_clearance_in = $sideClearanceIn
        front_clearance_in = $frontClearanceIn
        adjacent_fixture_center_to_center_in = 30.0
        adjacent_fixture_tested = $false
        p2705_1_door_window_operation_checked = $false
        source_ct_current_code = 'https://portal.ct.gov/das/home/office-of-state-building-inspector/connecticut-state-building-code/regulations?language=en_US'
        source_ct_adopted_code = 'https://portal.ct.gov/-/media/DAS/Office-of-State-Building-Inspector/2022-State-Codes/2022-CSBC-Final.pdf'
        source_irc_r307_1 = 'https://codes.iccsafe.org/content/IRC2021P1/chapter-3-building-planning'
        source_irc_p2705_1 = 'https://codes.iccsafe.org/content/IRC2021P2/chapter-27-plumbing-fixtures'
    }
    protected_window = [ordered]@{
        id = 'west_of_core'
        label = 'West A / dining-side search window'
        gross_width_in = [Math]::Round($westWidthIn, 3)
        gross_depth_in = [Math]::Round($westDepthIn, 3)
        gross_area_sf = [double]$west[0].gross_area_sf
        remains_unassigned = $true
    }
    east_window = [ordered]@{
        id = 'east_of_core'
        label = 'East B / pantry-side search window'
        gross_area_sf = [double]$east[0].gross_area_sf
        remains_unassigned = $true
    }
    orientations = $results
    evaluated = [ordered]@{
        predecessor_body_plus_side_and_front_screen_only = $true
        complete_room_fit = $false
        selected_610aa_geometry = $false
        lavatory_or_adjacent_fixture = $false
        door_or_swing_and_hall_approach = $false
        finished_wall_faces_or_rough_in = $false
        drain_vent_water_or_service_route = $false
        m06_room_assignment = $false
        selected_d_or_ifc_modified = $false
    }
    limitations = @(
        'A is a gross 5.1667 x 11.4167 ft room-block gap, not a verified room or clear interior dimension.',
        'The 19 x 30.25 in body proxy is predecessor 211AA series data and is not verified for target SKU 610AA001.020.',
        'The screen excludes the lavatory and 30-in center-to-center check, real door and swing, hall approach, finished-face tolerances, plumbing route and services.',
        'The screen does not show that west A adjoins the required public hall approach or that either window can be assigned.',
        'The 15-in / 21-in values are preliminary 2021 IRC spacing checks under the Connecticut 2022 CSBC; municipality, permit path, occupancy and any applicable accessibility scope require confirmation.'
    )
}

$outputFull = [System.IO.Path]::GetFullPath($OutputPath)
$outputDir = [System.IO.Path]::GetDirectoryName($outputFull)
[System.IO.Directory]::CreateDirectory($outputDir) | Out-Null
$json = ConvertTo-Json -InputObject $report -Depth 20
[System.IO.File]::WriteAllText($outputFull, $json + [Environment]::NewLine, (New-Object System.Text.UTF8Encoding($false)))
$passCount = @($results | Where-Object contained_in_gross_west_a).Count
Write-Output "M226 bounded toilet-only predecessor screen: $passCount/2 orientations contained in gross west A; A and B remain unassigned."
Write-Output "Report: $outputFull"
