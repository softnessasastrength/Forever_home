param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$ToiletReportPath = (Join-Path $PSScriptRoot '../.local/revalidation/M95-current-toilet-envelope.json'),
    [string]$SinkReportPath = (Join-Path $PSScriptRoot '../Research/M06_Sink_Gross_Body_Screen_2026-10-28.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../.local/revalidation/M96-current-toilet-sink-gross-pair.json')
)

$ErrorActionPreference = 'Stop'
$checks = 0
$failures = [System.Collections.Generic.List[string]]::new()
function Assert-Check([bool]$Condition, [string]$Message) {
    $script:checks++
    if (-not $Condition) { $script:failures.Add($Message) }
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$toiletFile = (Resolve-Path -LiteralPath $ToiletReportPath).Path
$sinkFile = (Resolve-Path -LiteralPath $SinkReportPath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$toilet = Get-Content -LiteralPath $toiletFile -Raw | ConvertFrom-Json
$sinks = Get-Content -LiteralPath $sinkFile -Raw | ConvertFrom-Json
$studyHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$toiletHash = (Get-FileHash -LiteralPath $toiletFile -Algorithm SHA256).Hash.ToLowerInvariant()
$sinkHash = (Get-FileHash -LiteralPath $sinkFile -Algorithm SHA256).Hash.ToLowerInvariant()
$m06 = $study.selection.main_public_bath
$window = @($m06.search_windows | Where-Object id -eq 'east_of_core')

Assert-Check ($studyHash -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb') 'Selected-D source fingerprint changed; review the baseline before relying on this screen.'
Assert-Check ($study.layout_variant -eq 'OwnerSelectedD' -and $m06.id -eq 'M-06' -and $m06.type -eq 'half bath') 'Input is not the owner-selected D M-06 half-bath study.'
Assert-Check ($m06.footprint -eq 'TBD' -and $m06.position -eq 'TBD' -and $m06.first_fit_candidate -eq 'east_of_core') 'M-06 assignment or first-fit priority changed.'
Assert-Check ($window.Count -eq 1 -and $window[0].status -like 'Unassigned room-block gap only*') 'B is not the documented unassigned gross room-block gap.'
Assert-Check ($toilet.schema -eq 'forever-home-m06-current-toilet-infographic-envelope-v1' -and $toilet.study.sha256 -eq $studyHash) 'Expected a current-SKU toilet envelope report from the same selected-D source.'
Assert-Check ($toilet.candidate.selected_sku -eq 'American Standard Champion PRO 610AA001.020' -and $toilet.candidate.exact_revit_family_or_solid_geometry_verified -eq $false) 'Expected the selected current SKU with detailed solids still explicitly unverified.'
Assert-Check ($toilet.candidate.image_sha256 -eq 'F09F6BFBCBB62F53828BD99E46F2351BB279E4C031980BBC5E35790E0FE86FBF' -and $toilet.candidate.image_bytes -eq 133750) 'Current-toilet image provenance does not match the reviewed manufacturer infographic.'
Assert-Check ([double]$toilet.candidate.manufacturer_annotated_overall_in.length -eq 30.25 -and [double]$toilet.candidate.manufacturer_annotated_overall_in.width -eq 19.0 -and [double]$toilet.candidate.manufacturer_annotated_overall_in.height -eq 30.875 -and [double]$toilet.candidate.annotated_rough_in_in -eq 12.0) 'Current-SKU annotated product dimensions differ from the reviewed infographic.'
Assert-Check ($sinks.schema -eq 'forever-home-m06-sink-gross-body-screen-v1' -and $sinks.study.sha256 -eq $studyHash) 'Expected a sink candidate report from the same selected-D source.'
$treshamInput = @($sinks.candidates | Where-Object id -eq 'kohler-tresham-k-2844-4-0')
Assert-Check ($treshamInput.Count -eq 1 -and [double]$treshamInput[0].nominal_overall_body_in.width -eq 24.0 -and [double]$treshamInput[0].nominal_overall_body_in.depth -eq 19.5 -and $treshamInput[0].design_file_sha256 -eq '3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949' -and $treshamInput[0].candidate_rfa_geometry_measured -eq $false) 'KOHLER Tresham source dimensions/hash or unmeasured status differ from the reviewed input.'

$grossWidthIn = [double]$window[0].w * 12.0
$grossDepthIn = [double]$window[0].d * 12.0
$wcWidthIn = [double]$toilet.candidate.manufacturer_annotated_overall_in.width
$wcProjectionIn = [double]$toilet.candidate.manufacturer_annotated_overall_in.length
$expectedB = [Math]::Abs($grossWidthIn - 158.0) -lt 0.000001 -and [Math]::Abs($grossDepthIn - 84.0) -lt 0.000001
Assert-Check $expectedB 'B no longer derives to the documented 158 x 84 in gross dimensions.'

# Preliminary same-rear-wall screening diagram only: the WC centerline is 15 in from
# one side boundary; sink centerline is 30 in from it; 21-in front strips are rectangular.
$wcCenterXIn = 15.0
$sinkCenterXIn = 45.0
$frontStripIn = 21.0
$fixturePairs = @()
foreach ($sink in $sinks.candidates) {
    $sinkWidthIn = [double]$sink.nominal_overall_body_in.width
    $sinkDepthIn = [double]$sink.nominal_overall_body_in.depth
    if ($sinkWidthIn -le 0 -or $sinkDepthIn -le 0) { throw "Invalid sink dimensions for '$($sink.id)'" }
    foreach ($orientation in @(
        [ordered]@{rotation_deg=0; width_in=$sinkWidthIn; depth_in=$sinkDepthIn},
        [ordered]@{rotation_deg=90; width_in=$sinkDepthIn; depth_in=$sinkWidthIn}
    )) {
        $wcLeftIn = $wcCenterXIn - ($wcWidthIn / 2.0)
        $wcRightIn = $wcCenterXIn + ($wcWidthIn / 2.0)
        $sinkLeftIn = $sinkCenterXIn - ([double]$orientation.width_in / 2.0)
        $sinkRightIn = $sinkCenterXIn + ([double]$orientation.width_in / 2.0)
        $wcToSinkEdgeIn = $sinkLeftIn - $wcCenterXIn
        $bodyGapIn = $sinkLeftIn - $wcRightIn
        $requiredWidthIn = [Math]::Max($wcRightIn, $sinkRightIn)
        $requiredDepthIn = [Math]::Max(($wcProjectionIn + $frontStripIn), ([double]$orientation.depth_in + $frontStripIn))
        $nonoverlap = $sinkLeftIn -ge $wcRightIn
        $sideSpacing = $wcToSinkEdgeIn -ge 15.0
        $contained = $requiredWidthIn -le $grossWidthIn -and $requiredDepthIn -le $grossDepthIn
        if (-not $nonoverlap -or -not $sideSpacing -or -not $contained) {
            throw "Gross pair screen failed for '$($sink.id)' at sink rotation $($orientation.rotation_deg)."
        }
        $fixturePairs += [ordered]@{
            sink_id = $sink.id
            sink_name = $sink.name
            sink_source = $sink.source
            sink_dimensions_source = $sink.dimensions_source
            sink_status = $sink.status
            sink_family_geometry_measured = [bool]$sink.candidate_rfa_geometry_measured
            sink_sku_mapping_verified = [bool]$sink.rfa_type_to_sku_mapping_verified
            sink_rotation_deg = $orientation.rotation_deg
            toilet_centerline_from_side_boundary_in = $wcCenterXIn
            sink_centerline_from_toilet_centerline_in = $sinkCenterXIn - $wcCenterXIn
            toilet_body_width_along_wall_in = $wcWidthIn
            toilet_projection_from_rear_line_in = $wcProjectionIn
            sink_body_width_along_wall_in = $orientation.width_in
            sink_body_depth_from_rear_line_in = $orientation.depth_in
            toilet_centerline_to_sink_body_edge_in = $wcToSinkEdgeIn
            toilet_centerline_to_sink_body_edge_meets_15in_screen = $sideSpacing
            body_gap_along_wall_in = $bodyGapIn
            required_gross_width_in = $requiredWidthIn
            required_gross_depth_including_front_strip = $requiredDepthIn
            contained_in_gross_B = $contained
            bodies_nonoverlapping_in_assumed_axis = $nonoverlap
            assumption = 'Symmetric rectangular product envelopes on a hypothetical shared rear wall; 15-in WC centerline side screen, 30-in fixture centerline spacing, and 21-in front depth strips.'
        }
    }
}

Assert-Check ($fixturePairs.Count -eq ($sinks.candidates.Count * 2)) 'Not every sink candidate was screened in both plan orientations.'
$tresham = @($fixturePairs | Where-Object sink_id -eq 'kohler-tresham-k-2844-4-0')
Assert-Check ($tresham.Count -eq 2 -and @($tresham | Where-Object { $_.sink_family_geometry_measured -or $_.sink_sku_mapping_verified }).Count -eq 0) 'Tresham must remain a nominal candidate with unmeasured family geometry.'

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Error "FAIL: $failure" -ErrorAction Continue }
    throw "Current-SKU toilet/lavatory gross pair screen failed $($failures.Count) of $checks checks."
}

$report = [ordered]@{
    schema = 'forever-home-m06-current-sku-toilet-sink-gross-pair-screen-v1'
    result = "PASS: $checks checks; $($fixturePairs.Count) current-SKU toilet/lavatory body-plus-strip combinations fit the gross B rectangle under stated assumptions. This is not a room fit."
    study = [ordered]@{sha256=$studyHash; layout_variant=$study.layout_variant}
    inputs = [ordered]@{
        toilet_report_sha256 = $toiletHash
        sink_report_sha256 = $sinkHash
        selected_toilet_sku = $toilet.candidate.selected_sku
        toilet_image_sha256 = $toilet.candidate.image_sha256
        toilet_plan_envelope_in = [ordered]@{width=$wcWidthIn; projection=$wcProjectionIn}
        sink_catalogue_candidates = $sinks.candidates.Count
    }
    zone = [ordered]@{
        id = 'east_of_core'
        label = 'Pantry-side B'
        gross_width_in = $grossWidthIn
        gross_depth_in = $grossDepthIn
        status = 'unassigned room-block gap only'
    }
    assumptions = [ordered]@{
        clearance_reference = '2021 IRC R307.1 / P2705.1 preliminary screen recorded in Research/M06_Clearance_Basis_2026-10-30.md; local applicability unresolved'
        wc_centerline_from_one_side_boundary_in = $wcCenterXIn
        wc_centerline_to_sink_centerline_in = $sinkCenterXIn - $wcCenterXIn
        front_clearance_depth_strip_in = $frontStripIn
        sink_plan_orientations_tested = @(0,90)
    }
    fixture_pairs = $fixturePairs
    gates = [ordered]@{
        current_toilet_annotated_plan_envelope = $true
        exact_toilet_revit_solids = $false
        sink_selected = $false
        sink_revit_solids = $false
        finished_wall_faces = $false
        actual_clearance_polygons = $false
        door_and_approach = $false
        privacy = $false
        water_waste_and_vent_route = $false
        code_or_accessibility_applicability = $false
        m06_assigned = $false
        revit_placement_or_ifc = $false
    }
    limitations = @(
        'B is a 158 x 84 in gross search gap, not a room with finished wall faces or usable clear dimensions.',
        'Toilet dimensions come from a manufacturer current-SKU infographic; sink dimensions come from nominal manufacturer product documentation. Neither input is measured Revit solid geometry.',
        'Clearance is a preliminary rectangle/depth-strip abstraction of the cited minimums, not the actual IRC clearance figure or an accessibility design.',
        'The shared-wall layout is a screening assumption, not a design decision. Sink candidates are research-only and none is selected.',
        'No wall build-up, entry, door leaf/swing, arrival path, privacy, actual approach, rough-in coordination, service route, Revit placement, IFC, or local code applicability is tested.',
        'A passing gross envelope screen does not establish a viable room fit or authorize assignment of M-06.'
    )
}

$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
[System.IO.File]::WriteAllText($resolvedOutput, (ConvertTo-Json -InputObject $report -Depth 16) + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: M-06 current-SKU toilet/lavatory gross pair screen passed $checks checks; $($fixturePairs.Count) combinations saved to $resolvedOutput"
Write-Output 'Screen only: B remains unassigned; no actual geometry, complete clearance, door/approach, service route, code result, Revit placement or IFC is validated.'
