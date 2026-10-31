param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$ToiletReportPath = (Join-Path $PSScriptRoot '../Research/M06_Champion_PRO_Predecessor_Envelope_Screen_2026-10-28.json'),
    [string]$SinkReportPath = (Join-Path $PSScriptRoot '../Research/M06_Sink_Gross_Body_Screen_2026-10-28.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_Predecessor_Toilet_Sink_Gross_Pair_Screen_2026-10-28.json')
)

$ErrorActionPreference = 'Stop'
$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$toiletFile = (Resolve-Path -LiteralPath $ToiletReportPath).Path
$sinkFile = (Resolve-Path -LiteralPath $SinkReportPath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$toilet = Get-Content -LiteralPath $toiletFile -Raw | ConvertFrom-Json
$sinks = Get-Content -LiteralPath $sinkFile -Raw | ConvertFrom-Json

$m06 = $study.selection.main_public_bath
if ($study.layout_variant -ne 'OwnerSelectedD' -or $m06.id -ne 'M-06' -or
    $m06.type -ne 'half bath' -or $m06.footprint -ne 'TBD' -or $m06.position -ne 'TBD') {
    throw 'Expected unchanged selected-D M-06 half bath with no assigned footprint or position.'
}
if ($toilet.schema -ne 'forever-home-m06-predecessor-product-envelope-screen-v1' -or
    $toilet.target_candidate.exact_target_sku_geometry_verified -ne $false) {
    throw 'Expected the explicitly unverified 211AA predecessor toilet report.'
}
if ($sinks.schema -ne 'forever-home-m06-sink-gross-body-screen-v1' -or
    $sinks.study.sha256 -ne $toilet.study_sha256) {
    throw 'Sink and toilet reports must share the selected-D source fingerprint.'
}

$studyHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$toiletHash = (Get-FileHash -LiteralPath $toiletFile -Algorithm SHA256).Hash.ToLowerInvariant()
$sinkHash = (Get-FileHash -LiteralPath $sinkFile -Algorithm SHA256).Hash.ToLowerInvariant()
if ($toilet.study_sha256 -ne $studyHash -or $sinks.study.sha256 -ne $studyHash) {
    throw 'An upstream report was generated from a different selected-D source.'
}

$window = @($m06.search_windows | Where-Object id -eq 'east_of_core')
if ($window.Count -ne 1 -or $window[0].status -notlike 'Unassigned room-block gap only*') {
    throw 'Expected pantry-side B to remain an unassigned room-block gap.'
}
$grossWidthIn = [double]$window[0].w * 12.0
$grossDepthIn = [double]$window[0].d * 12.0
$toiletWidthIn = [double]$toilet.target_candidate.proxy_width_in
$toiletDepthIn = [double]$toilet.target_candidate.proxy_projection_in

# This is one transparent lower-bound diagram: toilet and pedestal/lavatory centers share a
# hypothetical rear wall line; the WC centerline is 15 in from a side boundary; sink centerline
# is 30 in from WC centerline; each fixture gets a 21 in front strip. No wall or door is modeled.
$wcCenterXIn = 15.0
$sinkCenterXIn = $wcCenterXIn + 30.0
$frontClearanceIn = 21.0
$fixturePairs = @()
foreach ($sink in $sinks.candidates) {
    $sinkWidthIn = [double]$sink.nominal_overall_body_in.width
    $sinkDepthIn = [double]$sink.nominal_overall_body_in.depth
    if ($sinkWidthIn -le 0 -or $sinkDepthIn -le 0) { throw "Invalid sink body dimensions for '$($sink.id)'" }
    $sinkOrientations = @(
        [ordered]@{rotation_deg=0; body_width_in=$sinkWidthIn; body_depth_in=$sinkDepthIn},
        [ordered]@{rotation_deg=90; body_width_in=$sinkDepthIn; body_depth_in=$sinkWidthIn}
    )
    foreach ($orientation in $sinkOrientations) {
        $toiletLeftIn = $wcCenterXIn - ($toiletWidthIn / 2.0)
        $toiletRightIn = $wcCenterXIn + ($toiletWidthIn / 2.0)
        $sinkLeftIn = $sinkCenterXIn - ([double]$orientation.body_width_in / 2.0)
        $sinkRightIn = $sinkCenterXIn + ([double]$orientation.body_width_in / 2.0)
        $requiredWidthIn = [Math]::Max($toiletRightIn, $sinkRightIn)
        $requiredDepthIn = [Math]::Max(($toiletDepthIn + $frontClearanceIn), ([double]$orientation.body_depth_in + $frontClearanceIn))
        $nonOverlappingAlongWall = $sinkLeftIn -ge $toiletRightIn
        $wcCenterlineToSinkBodyEdgeIn = $sinkLeftIn - $wcCenterXIn
        $wcCenterlineToSinkObstructionClear = $wcCenterlineToSinkBodyEdgeIn -ge 15.0
        $withinGrossB = $requiredWidthIn -le $grossWidthIn -and $requiredDepthIn -le $grossDepthIn
        if (-not $nonOverlappingAlongWall -or -not $wcCenterlineToSinkObstructionClear -or -not $withinGrossB) {
            throw "Gross toilet/lavatory pair screen failed for '$($sink.id)' at rotation $($orientation.rotation_deg)."
        }
        $fixturePairs += [ordered]@{
            sink_id = $sink.id
            sink_name = $sink.name
            sink_source = $sink.source
            sink_candidate_status = $sink.status
            sink_family_geometry_measured = [bool]$sink.candidate_rfa_geometry_measured
            sink_sku_mapping_verified = [bool]$sink.rfa_type_to_sku_mapping_verified
            sink_rotation_deg = [int]$orientation.rotation_deg
            sink_body_width_along_wall_in = [Math]::Round([double]$orientation.body_width_in, 3)
            sink_body_depth_from_rear_line_in = [Math]::Round([double]$orientation.body_depth_in, 3)
            wc_centerline_from_side_boundary_in = $wcCenterXIn
            sink_centerline_from_wc_centerline_in = 30.0
            toilet_body_left_in = [Math]::Round($toiletLeftIn, 3)
            toilet_body_right_in = [Math]::Round($toiletRightIn, 3)
            sink_body_left_in = [Math]::Round($sinkLeftIn, 3)
            sink_body_right_in = [Math]::Round($sinkRightIn, 3)
            wc_centerline_to_sink_nearest_body_edge_in = [Math]::Round($wcCenterlineToSinkBodyEdgeIn, 3)
            wc_centerline_to_sink_body_edge_meets_15in_screen = $wcCenterlineToSinkObstructionClear
            body_gap_along_wall_in = [Math]::Round(($sinkLeftIn - $toiletRightIn), 3)
            required_gross_width_in = [Math]::Round($requiredWidthIn, 3)
            required_gross_depth_in_including_front_strip = [Math]::Round($requiredDepthIn, 3)
            remaining_gross_B_width_in = [Math]::Round(($grossWidthIn - $requiredWidthIn), 3)
            remaining_gross_B_depth_in = [Math]::Round(($grossDepthIn - $requiredDepthIn), 3)
            contained_in_gross_B = $withinGrossB
            bodies_nonoverlapping_in_assumed_axis = $nonOverlappingAlongWall
            assumption = 'Symmetric bodies aligned to a hypothetical shared rear wall; centerlines 30 in apart; clearance strips applied as rectangular front depth only.'
        }
    }
}

$report = [ordered]@{
    schema = 'forever-home-m06-predecessor-toilet-sink-gross-pair-screen-v1'
    result = "PASS: all $($fixturePairs.Count) predecessor-toilet/lavatory body and minimum-strip combinations fit the modeled gross B rectangle under the stated same-wall assumptions. This is not a room fit."
    study_sha256 = $studyHash
    source_reports = [ordered]@{
        toilet_report = [System.IO.Path]::GetFileName($toiletFile)
        toilet_report_sha256 = $toiletHash
        sink_report = [System.IO.Path]::GetFileName($sinkFile)
        sink_report_sha256 = $sinkHash
    }
    toilet_proxy = [ordered]@{
        selected_target_sku = '610AA001.020'
        proxy_predecessor_sku = '211AA104.020'
        exact_target_sku_geometry_verified = $false
        nominal_body_width_in = $toiletWidthIn
        nominal_body_projection_in = $toiletDepthIn
        rear_wall_orientation_only = $true
    }
    search_window = [ordered]@{
        id = 'east_of_core'
        label = 'Pantry-side B'
        gross_width_in = $grossWidthIn
        gross_depth_in = $grossDepthIn
        gross_area_sf = [double]$window[0].gross_area_sf
        remains_unassigned = $true
    }
    preliminary_clearance_screen = [ordered]@{
        basis = 'Provisional 2021 IRC R307.1 / P2705.1 screening basis documented in Research/2026-10-28_Connecticut_M06_Clearance_Screen.md; local applicability unconfirmed.'
        wc_centerline_to_side_boundary_in = $wcCenterXIn
        wc_to_sink_centerline_in = 30.0
        front_clearance_in = $frontClearanceIn
        source_chapter_3 = 'https://codes.iccsafe.org/content/IRC2021P1/chapter-3-building-planning'
        source_chapter_27 = 'https://codes.iccsafe.org/content/IRC2021P2/chapter-27-plumbing-fixtures'
    }
    evaluated = [ordered]@{
        predecessor_toilet_body_plus_research_sink_bodies = $true
        front_rectangles_only = $true
        candidate_combinations = $fixturePairs.Count
        candidate_product_selected = $false
        exact_610aa001_020_geometry = $false
        complete_room_fit = $false
        wall_build_up_or_actual_usable_dimensions = $false
        door_or_swing = $false
        hall_approach_or_privacy = $false
        installation_or_rough_in_geometry = $false
        water_drain_vent_or_service_route = $false
        accessibility_or_code_compliance = $false
        m06_assignment = $false
        ifc_or_revit_placement = $false
    }
    fixture_pairs = $fixturePairs
    limitations = @(
        'B remains a 158 x 84 in gross room-block search gap, not a room with walls or verified usable clear dimensions.',
        'The toilet is nominal predecessor data for 211AA104.020 and is not verified for selected 610AA001.020.',
        'Lavatory products are research candidates, not owner-selected products; any uninspected family dimensions remain nominal product data.',
        'The diagram assumes a common rear wall, a WC centerline 15 in from one side boundary, lavatory centerline exactly 30 in from the WC centerline, and checks the nearest lavatory body edge remains at least 15 in from that WC centerline.',
        'Front clearance is reduced to a depth strip; this does not model the actual clearance polygon or user approach.',
        'No wall thickness, door, swing, privacy, hall route, plumbing connection, local code applicability, accessibility scope, or service route is tested.',
        'A contained rectangular screen does not establish comfortable use, a viable layout, code compliance, accessibility, or assignment of M-06.'
    )
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$json = ConvertTo-Json -InputObject $report -Depth 16
[System.IO.File]::WriteAllText($resolvedOutput, $json + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: M-06 predecessor-toilet/lavatory gross pair screen saved to $resolvedOutput ($($fixturePairs.Count) combinations)"
