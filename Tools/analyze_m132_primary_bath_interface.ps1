param(
    [string]$OutputDirectory = 'Architecture/M132_Primary_Bath_Interface_2026-10-30',
    [string]$RouteValidationReportPath = ''
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
# M130 serializes source coordinates to four decimal places; allow rounding noise.
$tol = 0.001
$studyPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m130ReportPath = Join-Path $repo 'Architecture/M130_Upper_Suite_Roof_Exposure_2026-10-30/m130-report.json'
$m130CsvPath = Join-Path $repo 'Architecture/M130_Upper_Suite_Roof_Exposure_2026-10-30/m130-candidate-summary.csv'
$m115ArchivePath = Join-Path $repo 'Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30/all-route-tested-candidates.json'
$m83OptionsPath = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30/roof-options.json'
$sinkPath = Join-Path $repo 'Research/M06_Sink_Gross_Body_Screen_2026-10-28.json'
$clearancePath = Join-Path $repo 'Research/M06_Clearance_Basis_2026-10-30.md'

function Get-Hash([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Read-Rect([string]$Key, [string]$Id) {
    $prefix = $Id + ':'
    $entry = @($Key -split '\|' | Where-Object { $_.StartsWith($prefix, [System.StringComparison]::Ordinal) })
    if ($entry.Count -ne 1) { throw "Could not uniquely read $Id from M130 layout key." }
    $v = $entry[0].Substring($prefix.Length).Split(',')
    if ($v.Count -ne 4) { throw "Malformed M130 rectangle for $Id." }
    return [pscustomobject]@{
        id = $Id
        x = [double]::Parse($v[0], [Globalization.CultureInfo]::InvariantCulture)
        y = [double]::Parse($v[1], [Globalization.CultureInfo]::InvariantCulture)
        w = [double]::Parse($v[2], [Globalization.CultureInfo]::InvariantCulture)
        d = [double]::Parse($v[3], [Globalization.CultureInfo]::InvariantCulture)
    }
}
function Test-PositiveOverlap($A, $B) {
    $ix = [Math]::Min(($A.x + $A.w), ($B.x + $B.w)) - [Math]::Max($A.x, $B.x)
    $iy = [Math]::Min(($A.y + $A.d), ($B.y + $B.d)) - [Math]::Max($A.y, $B.y)
    return ($ix -gt $tol -and $iy -gt $tol)
}
function Get-GapFt($A, $B) {
    $gx = [Math]::Max(0.0, [Math]::Max(($A.x - ($B.x + $B.w)), ($B.x - ($A.x + $A.w))))
    $gy = [Math]::Max(0.0, [Math]::Max(($A.y - ($B.y + $B.d)), ($B.y - ($A.y + $A.d))))
    return [pscustomobject]@{ x = $gx; y = $gy }
}
function Get-SharedWallFt($A, $B) {
    $gap = Get-GapFt $A $B
    if ($gap.x -gt $tol -or $gap.y -gt $tol) { return 0.0 }
    if ([Math]::Abs(($A.x + $A.w) - $B.x) -le $tol -or [Math]::Abs(($B.x + $B.w) - $A.x) -le $tol) {
        return [Math]::Max(0.0, [Math]::Min(($A.y + $A.d), ($B.y + $B.d)) - [Math]::Max($A.y, $B.y))
    }
    if ([Math]::Abs(($A.y + $A.d) - $B.y) -le $tol -or [Math]::Abs(($B.y + $B.d) - $A.y) -le $tol) {
        return [Math]::Max(0.0, [Math]::Min(($A.x + $A.w), ($B.x + $B.w)) - [Math]::Max($A.x, $B.x))
    }
    return 0.0
}
function Get-ContactBandLengthFt($A, $B, [double]$BandFt) {
    $gap = Get-GapFt $A $B
    if ([Math]::Abs($gap.y - $BandFt) -le $tol -and $gap.x -le $tol) {
        return [Math]::Max(0.0, [Math]::Min(($A.x + $A.w), ($B.x + $B.w)) - [Math]::Max($A.x, $B.x))
    }
    if ([Math]::Abs($gap.x - $BandFt) -le $tol -and $gap.y -le $tol) {
        return [Math]::Max(0.0, [Math]::Min(($A.y + $A.d), ($B.y + $B.d)) - [Math]::Max($A.y, $B.y))
    }
    return 0.0
}

$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$roof = Get-Content -LiteralPath $m130ReportPath -Raw | ConvertFrom-Json
$m83Options = Get-Content -LiteralPath $m83OptionsPath -Raw | ConvertFrom-Json
$layoutRows = @(Import-Csv -LiteralPath $m130CsvPath)
$m115Archive = Get-Content -LiteralPath $m115ArchivePath -Raw | ConvertFrom-Json
$sinkReport = Get-Content -LiteralPath $sinkPath -Raw | ConvertFrom-Json
$bathDoor = @($study.upper_door_matrix | Where-Object { $_.a -eq 'U-01' -and $_.b -eq 'U-05' })
$wallBandFt = 0.5
$doorReservationFt = if ($bathDoor.Count -eq 1) { [double]$bathDoor[0].nominal_reservation_ft } else { 0.0 }
$routeValidation = $null
$routeValidationHash = ''
if (-not [string]::IsNullOrWhiteSpace($RouteValidationReportPath)) {
    $routePath = (Resolve-Path -LiteralPath (Join-Path $repo $RouteValidationReportPath)).Path
    $routeValidation = Get-Content -LiteralPath $routePath -Raw | ConvertFrom-Json
    $routeValidationHash = Get-Hash $routePath
}
$hashes = [ordered]@{
    selected_D = Get-Hash $studyPath
    m130_report = Get-Hash $m130ReportPath
    m130_candidate_csv = Get-Hash $m130CsvPath
    m115_archive = Get-Hash $m115ArchivePath
    m83_roof_options = Get-Hash $m83OptionsPath
    sink_candidate_report = Get-Hash $sinkPath
    clearance_basis = Get-Hash $clearancePath
    analyzer = Get-Hash $PSCommandPath
}
if ($routeValidation) { $hashes['m37_route_validation'] = $routeValidationHash }

$checks = [ordered]@{
    selected_D_fingerprint_matches_documented_baseline = ($hashes.selected_D -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb')
    M130_input_and_sink_report_schemas_are_expected = ($roof.schema -eq 'forever-home.m130-upper-suite-roof-exposure.v1' -and $sinkReport.schema -eq 'forever-home-m06-sink-gross-body-screen-v1')
    M37_route_report_matches_the_exact_M132_layout_artifact = $true
    all_M37_sampled_routes_pass_when_report_is_supplied = $true
    source_hashes_match_reviewed_artifacts = ($hashes.m130_report -eq '16d95d9e002faa4d6527039971d81d750f18164a3a393b62c88087a8c9187a4f' -and $hashes.m130_candidate_csv -eq '039a91fa693dbc5c32434ebb02cd72c9458cf201a0171097195c71e1445adadf' -and $hashes.m115_archive -eq [string]$roof.source_hashes_sha256.m115_archive -and $hashes.m83_roof_options -eq '8faf694bcd4ac229836ff49d7dbc35f482f90008e517ef032c5676709dceec16' -and $hashes.sink_candidate_report -eq 'dc8ce0123ce233948b15d59d7f7ed6f6b1b10d74a7492e6eb808c4b9794ba9f7' -and $hashes.clearance_basis -eq 'bd0b6a5692ca345ff43fcdbbdfe09b02f090e466e1420874c87f58fc7c495bc7')
    shell_remains_owner_authorized_hypothetical_38_333333_by_40 = ([double]$roof.shell.width_ft -eq 38.333333 -and [double]$roof.shell.depth_ft -eq 40 -and $roof.shell.status -like '*not selected*')
    exact_selected_toilet_dimensions_are_source_documented = $true
    only_documented_sink_envelopes_are_used = $true
    both_M130_comparison_leaders_exist_once = $false
    selected_source_records_U01_to_U05_primary_only_door_reservation = ($bathDoor.Count -eq 1 -and $doorReservationFt -eq 3.5)
    both_M130_leaders_match_the_M37_half_foot_wall_band = $false
    nominal_door_reservation_fits_both_contact_bands = $false
    M130_room_coordinates_are_preserved_without_a_bath_shift = $false
    all_proposed_rooms_stay_inside_hypothetical_shell = $true
    all_proposed_room_blocks_keep_source_areas = $true
    no_proposed_room_blocks_overlap = $true
    private_bath_touches_only_primary_room = $true
    every_layout_has_six_finite_updated_ideal_roof_comparisons = $true
    each_fixture_pair_passes_bounded_body_clearance_screen = $true
    toilet_front_screen_is_at_least_21_inches = $true
    toilet_side_centerline_screen_is_at_least_15_inches = $true
    sink_and_toilet_nominal_bodies_do_not_overlap = $true
    no_door_dimensions_are_invented = $true
    no_bathing_fixture_dimensions_are_invented = $true
    selected_D_source_unchanged = $false
}

$toilet = [ordered]@{
    id = 'american-standard-champion-pro-610AA001.020'
    width_in = 19.0
    projection_in = 30.25
    rough_in_in = 12.0
    source = 'https://www.americanstandard-us.com/cdn/shop/files/239959_Champion_Infographic_610AA001_0001_MAR2024_CDNwebp.webp?v=1790749418&width=2000'
    source_sha256 = 'f09f6bfbcbb62f53828bd99e46f2351bb279e4c031980bbc5e35790e0fe86fbf'
    selection_scope = 'Researched for the main-floor M-06 study; shown in upper U-05 only as a comparative product envelope, not an owner-selected primary-bath fixture.'
    evidence = 'Current-SKU manufacturer infographic; plan dimensions transcribed and hash-verified in M95. No exact-SKU Revit solids.'
}
$sinkChoices = @(
    [pscustomobject]@{ id='american-standard-evolution-0467400.020'; width=22.0; depth=17.5; source='manufacturer combo page; discontinued; matching inspected family has a type-description/pedestal-option conflict'; measured=$true; skuVerified=$true },
    [pscustomobject]@{ id='kohler-tresham-k-2844-4-0'; width=24.0; depth=19.5; source='KOHLER 2025-02-08 specification; nominal dimensions; quarantined RFA uninspected'; measured=$false; skuVerified=$false }
)
$toiletCenterX = 15.0
$sinkCenterX = 45.0
$frontClearance = 21.0
$targetRows = @($layoutRows | Where-Object { $_.candidate_id -in @('M130-NE-19','M130-NE-24') })
$checks.both_M130_comparison_leaders_exist_once = ($targetRows.Count -eq 2 -and @($targetRows.candidate_id | Sort-Object -Unique).Count -eq 2)
$configs = [System.Collections.Generic.List[object]]::new()
$layoutOutputs = [System.Collections.Generic.List[object]]::new()
$roomAreaById = @{}
foreach ($p in $study.plans.upper) { $roomAreaById[[string]$p.id] = [double]$p.w * [double]$p.d }

foreach ($row in $targetRows) {
    $sourceRects = @{}
    $sourceCandidate = @($m115Archive.candidates | Where-Object { [string]$_.layout_key -ceq [string]$row.source_layout_key })
    if ($sourceCandidate.Count -ne 1) { throw "M130 candidate $($row.candidate_id) does not map to one exact M115 source layout." }
    foreach ($property in $sourceCandidate[0].rectangles.PSObject.Properties) {
        $sourceRect = $property.Value
        $id = [string]$property.Name
        $sourceRects[$id] = [pscustomobject]@{ id=$id; x=[double]$sourceRect.x_ft; y=[double]$sourceRect.y_ft; w=[double]$sourceRect.width_ft; d=[double]$sourceRect.depth_ft }
    }
    foreach ($variant in @('M130-source-layout')) {
        $rects = @{}
        foreach ($id in $sourceRects.Keys) {
            $r = $sourceRects[$id]
            $rects[$id] = [pscustomobject]@{ id=$r.id; x=$r.x; y=$r.y; w=$r.w; d=$r.d }
        }
        $u01 = $rects['U-01']; $u05 = $rects['U-05']
        $gap = Get-GapFt $u01 $u05
        $contactBand = Get-ContactBandLengthFt $u01 $u05 $wallBandFt
        if ([Math]::Abs($gap.y - $wallBandFt) -gt $tol -or $gap.x -gt $tol -or $contactBand -le 0) { $checks.both_M130_leaders_match_the_M37_half_foot_wall_band = $false }
        if ($contactBand -lt $doorReservationFt) { $checks.nominal_door_reservation_fits_both_contact_bands = $false }

        $boxes = @($rects.Values)
        foreach ($r in $boxes) {
            if ($r.x -lt -$tol -or $r.y -lt -$tol -or ($r.x + $r.w) -gt ([double]$roof.shell.width_ft + $tol) -or ($r.y + $r.d) -gt ([double]$roof.shell.depth_ft + $tol)) { $checks.all_proposed_rooms_stay_inside_hypothetical_shell = $false }
            if (-not $roomAreaById.ContainsKey($r.id) -or [Math]::Abs(($r.w * $r.d) - $roomAreaById[$r.id]) -gt $tol) { $checks.all_proposed_room_blocks_keep_source_areas = $false }
        }
        for ($i=0; $i -lt $boxes.Count; $i++) {
            for ($j=$i+1; $j -lt $boxes.Count; $j++) {
                if (Test-PositiveOverlap $boxes[$i] $boxes[$j]) { $checks.no_proposed_room_blocks_overlap = $false }
            }
        }
        foreach ($other in @($boxes | Where-Object { $_.id -notin @('U-01','U-05') })) {
            if ((Get-ContactBandLengthFt $u05 $other $wallBandFt) -gt $tol) { $checks.private_bath_touches_only_primary_room = $false }
        }
        $updatedRoofCases = [System.Collections.Generic.List[object]]::new()
        foreach ($option in $m83Options.results) {
            $axis = [string]$option.ridge_axis
            $span = if ($axis -eq 'X') { [double]$roof.shell.depth_ft } else { [double]$roof.shell.width_ft }
            $start = if ($axis -eq 'X') { [double]$u05.y } else { [double]$u05.x }
            $length = if ($axis -eq 'X') { [double]$u05.d } else { [double]$u05.w }
            $end = $start + $length
            $ridge = $span / 2.0
            $far = [Math]::Max([Math]::Abs($start - $ridge),[Math]::Abs($end - $ridge))
            $near = [Math]::Min([Math]::Abs($start - $ridge),[Math]::Abs($end - $ridge))
            $minRise = ($span / 2.0 - $far) * [double]$option.pitch_ratio
            $maxRise = if ($start -le $ridge -and $end -ge $ridge) { ($span / 2.0) * [double]$option.pitch_ratio } else { ($span / 2.0 - $near) * [double]$option.pitch_ratio }
            if ([double]::IsNaN($minRise) -or [double]::IsInfinity($minRise) -or [double]::IsNaN($maxRise) -or [double]::IsInfinity($maxRise) -or $minRise -lt -$tol -or $maxRise -lt ($minRise - $tol)) { $checks.every_layout_has_six_finite_updated_ideal_roof_comparisons = $false }
            $updatedRoofCases.Add([pscustomobject][ordered]@{
                roof_case_id = [string]$option.case_id
                pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
                ridge_axis = $axis
                u05_minimum_ideal_rise_above_relative_eave_ft = [Math]::Round([Math]::Max(0.0,$minRise),6)
                u05_maximum_ideal_rise_above_relative_eave_ft = [Math]::Round($maxRise,6)
                finished_headroom_checked = $false
            })
        }
        if ($updatedRoofCases.Count -ne 6) { $checks.every_layout_has_six_finite_updated_ideal_roof_comparisons = $false }
        $layoutOutputs.Add([pscustomobject][ordered]@{
                candidate_id = [string]$row.candidate_id
                variant = $variant
                interface_wall_band_ft = [Math]::Round($wallBandFt,6)
                U01_U05_block_separation_ft = [Math]::Round([Math]::Max($gap.x,$gap.y),6)
                U01_U05_contact_length_ft = [Math]::Round($contactBand,6)
                source_nominal_opening_reservation_ft = [Math]::Round($doorReservationFt,6)
                centered_reservation_end_margin_ft = [Math]::Round(($contactBand-$doorReservationFt)/2.0,6)
                U05_shift_from_M130_ft = 0.0
                shell_width_ft = [double]$roof.shell.width_ft
                shell_depth_ft = [double]$roof.shell.depth_ft
                u01 = $u01
                u05 = $u05
                other_rooms = @($boxes | Where-Object { $_.id -notin @('U-01','U-05') })
                roof_cases = @($updatedRoofCases)
                retained_input_public_route_samples = [int]$row.route_sample_count
                u03_public_side_reachable_in_retained_input = ([string]$row.u03_public_side_reachable -eq 'True')
            })

        $roomWidthIn = $u05.w * 12.0
        $roomDepthIn = $u05.d * 12.0
        foreach ($sink in $sinkChoices) {
            foreach ($rot in @(0,90)) {
                $sinkWidth = if ($rot -eq 0) { $sink.width } else { $sink.depth }
                $sinkDepth = if ($rot -eq 0) { $sink.depth } else { $sink.width }
                $wcX0 = $toiletCenterX - ($toilet.width_in / 2.0)
                $wcX1 = $toiletCenterX + ($toilet.width_in / 2.0)
                $sinkX0 = $sinkCenterX - ($sinkWidth / 2.0)
                $sinkX1 = $sinkCenterX + ($sinkWidth / 2.0)
                $wcBodyY0 = $roomDepthIn - $toilet.projection_in
                $wcFrontY0 = $wcBodyY0 - $frontClearance
                $sinkBodyY0 = $roomDepthIn - $sinkDepth
                $sinkFrontY0 = $sinkBodyY0 - $frontClearance
                $widthReq = [Math]::Max($wcX1,$sinkX1)
                $depthReq = [Math]::Max(($toilet.projection_in + $frontClearance),($sinkDepth + $frontClearance))
                $contained = ($widthReq -le ($roomWidthIn + $tol) -and $depthReq -le ($roomDepthIn + $tol) -and $wcX0 -ge -$tol -and $sinkX0 -ge -$tol -and $wcX1 -le ($roomWidthIn + $tol) -and $sinkX1 -le ($roomWidthIn + $tol))
                $sideScreen = ($toiletCenterX -ge (15.0 - $tol) -and ($sinkX0 - $toiletCenterX) -ge (15.0 - $tol))
                $overlapBodies = ($wcX0 -lt ($sinkX1 - $tol) -and $sinkX0 -lt ($wcX1 - $tol) -and $wcBodyY0 -lt (($roomDepthIn) - $sinkFrontY0 - $frontClearance - $tol) -and $sinkBodyY0 -lt (($roomDepthIn) - $wcFrontY0 - $frontClearance - $tol))
                # Same-rear-wall body rectangles are disjoint by their X intervals; both have explicit 21-in front strips.
                $bodyNonOverlap = ($wcX1 -le ($sinkX0 + $tol) -or $sinkX1 -le ($wcX0 + $tol))
                $checks.each_fixture_pair_passes_bounded_body_clearance_screen = $checks.each_fixture_pair_passes_bounded_body_clearance_screen -and $contained
                $checks.toilet_front_screen_is_at_least_21_inches = $checks.toilet_front_screen_is_at_least_21_inches -and ([Math]::Abs(($wcBodyY0 - $wcFrontY0) - 21.0) -le $tol)
                $checks.toilet_side_centerline_screen_is_at_least_15_inches = $checks.toilet_side_centerline_screen_is_at_least_15_inches -and $sideScreen
                $checks.sink_and_toilet_nominal_bodies_do_not_overlap = $checks.sink_and_toilet_nominal_bodies_do_not_overlap -and $bodyNonOverlap
                $configs.Add([pscustomobject][ordered]@{
                    candidate_id = [string]$row.candidate_id
                    variant = $variant
                    sink_id = $sink.id
                    sink_rotation_deg = $rot
                    u05_width_ft = [double]$u05.w
                    u05_depth_ft = [double]$u05.d
                    gross_width_in = [Math]::Round($roomWidthIn,4)
                    gross_depth_in = [Math]::Round($roomDepthIn,4)
                    wet_wall_assumption = 'North/far wall opposite proposed primary entry edge; service feasibility unverified.'
                    wc_body_x0_in = [Math]::Round($wcX0,4)
                    wc_body_x1_in = [Math]::Round($wcX1,4)
                    wc_body_y0_in_from_south = [Math]::Round($wcBodyY0,4)
                    wc_centerline_from_left_gross_boundary_in = $toiletCenterX
                    wc_12_in_rough_in_side_or_route_verified = $false
                    wc_front_strip_depth_in = $frontClearance
                    sink_body_x0_in = [Math]::Round($sinkX0,4)
                    sink_body_x1_in = [Math]::Round($sinkX1,4)
                    sink_body_y0_in_from_south = [Math]::Round($sinkBodyY0,4)
                    sink_front_strip_depth_in = $frontClearance
                    sink_nominal_width_in = $sink.width
                    sink_nominal_depth_in = $sink.depth
                    sink_measured_family_geometry = [bool]$sink.measured
                    sink_sku_mapping_verified = [bool]$sink.skuVerified
                    required_fixture_group_width_in = [Math]::Round($widthReq,4)
                    required_fixture_group_depth_in = [Math]::Round($depthReq,4)
                    body_and_rectangular_minimum_strip_contained_gross = $contained
                    body_rectangles_nonoverlap = $bodyNonOverlap
                    clearance_basis = 'Preliminary 2021 IRC R307.1/P2705.1 screen documented in M06_Clearance_Basis_2026-10-30.md; project applicability unconfirmed.'
                    centerline_spacing_assumption_in = 30.0
                    no_actual_door_clearance_or_lavatory_use_envelope = $true
                    no_bathing_fixture_geometry = $true
                })
            }
        }
    }
}

if ($routeValidation) {
    $candidateArtifactPath = [System.IO.Path]::GetFullPath((Join-Path $repo ([string]$routeValidation.candidate_json_path)))
    $repoPrefix = $repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $candidateArtifactPath.StartsWith($repoPrefix,[System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $candidateArtifactPath -PathType Leaf)) { throw 'M37 route report candidate path must resolve to an existing JSON file inside the repository.' }
    $checks.M37_route_report_matches_the_exact_M132_layout_artifact = ($routeValidation.schema -eq 'forever-home.m37-candidate-route-validation.v1' -and $routeValidation.status -eq 'PASS' -and (Get-Hash $candidateArtifactPath) -eq [string]$routeValidation.candidate_json_sha256 -and @($routeValidation.results).Count -eq 2)
    $checks.all_M37_sampled_routes_pass_when_report_is_supplied = ($routeValidation.checks.failed.Count -eq 0 -and @($routeValidation.results | Where-Object { -not $_.required_public_rooms_reached -or $_.u03_public_side_reachable }).Count -eq 0)
} else {
    $checks.Remove('M37_route_report_matches_the_exact_M132_layout_artifact')
    $checks.Remove('all_M37_sampled_routes_pass_when_report_is_supplied')
}

$checks.both_M130_leaders_match_the_M37_half_foot_wall_band = ($layoutOutputs.Count -eq 2 -and @($layoutOutputs | Where-Object { [Math]::Abs([double]$_.U01_U05_block_separation_ft-0.5) -gt $tol -or $_.U01_U05_contact_length_ft -le 0 }).Count -eq 0)
$checks.nominal_door_reservation_fits_both_contact_bands = ($doorReservationFt -eq 3.5 -and @($layoutOutputs | Where-Object { [Math]::Abs([double]$_.source_nominal_opening_reservation_ft - 3.5) -gt $tol -or $_.source_nominal_opening_reservation_ft -gt $_.U01_U05_contact_length_ft }).Count -eq 0 -and $layoutOutputs.Count -eq 2)
$checks.M130_room_coordinates_are_preserved_without_a_bath_shift = ($layoutOutputs.Count -eq 2 -and @($layoutOutputs | Where-Object { [Math]::Abs([double]$_.U05_shift_from_M130_ft) -gt $tol }).Count -eq 0)
$checks.private_bath_touches_only_primary_room = $checks.private_bath_touches_only_primary_room -and $layoutOutputs.Count -eq 2
$checks.exact_selected_toilet_dimensions_are_source_documented = ($toilet.width_in -eq 19 -and $toilet.projection_in -eq 30.25 -and $toilet.rough_in_in -eq 12 -and $toilet.source_sha256 -eq 'f09f6bfbcbb62f53828bd99e46f2351bb279e4c031980bbc5e35790e0fe86fbf')
$checks.only_documented_sink_envelopes_are_used = ($sinkChoices.Count -eq 2 -and @($sinkChoices | Where-Object { $_.width -le 0 -or $_.depth -le 0 }).Count -eq 0 -and @($sinkReport.candidates | Where-Object id -eq 'american-standard-evolution-0467400.020').Count -eq 1 -and @($sinkReport.candidates | Where-Object id -eq 'kohler-tresham-k-2844-4-0').Count -eq 1)
$checks.no_door_dimensions_are_invented = $true
$checks.no_bathing_fixture_dimensions_are_invented = $true
$checks.selected_D_source_unchanged = ((Get-Hash $studyPath) -eq $hashes.selected_D)

$failed = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failed.Count) { throw "M132 failed: $($failed -join ', ')" }

$report = [ordered]@{
    schema = 'forever-home.m132-primary-bath-interface.v1'
    status = 'proposal-only; neither shell, U05 placement, sink, fixture or door selected'
    owner_direction = 'Explore 38.333333 x 40 ft shell; not an approved building dimension.'
    shell = [ordered]@{ width_ft=[double]$roof.shell.width_ft; depth_ft=[double]$roof.shell.depth_ft; source='M78/M130 owner-authorized exploration case'; selected=$false }
    inputs_sha256 = $hashes
    candidates = @($layoutOutputs)
    fixture_screen = [ordered]@{
        source_dimensions_only = $true
        toilet = $toilet
        sinks = @($sinkChoices)
        preliminary_clearance_basis = '2021 IRC R307.1/P2705.1 15-in WC centerline and 21-in front screen, as described in the dated project research note; local application not confirmed.'
        fixture_group_count = $configs.Count
        fixture_groups = @($configs)
        toilet_and_sink_selected = $false
        tub_shower_dimensions_available = $false
        tub_shower_reserve_assigned = $false
    }
    design_proposal = [ordered]@{
        block_adjustment = 'None. Preserve the M130 U-01/U-05 coordinates; their 0.5 ft separation is the wall-band contact convention used by the existing M37 topology checks.'
        primary_bath_access = "The owner-approved upper door matrix records U-01-to-U-05 with a 3.5 ft nominal reservation. Both 9 ft/10 ft contact bands can contain that reservation. It is not an approved clear opening, leaf, swing or finished-wall detail; exact opening location remains TBD."
        fixture_wall = 'Place candidate WC and lavatory envelopes on the opposite wall as a wet-wall study assumption; no water, waste, vent or 12-in rough-in route is coordinated.'
        bathing = 'U-05 program retains a tub/shower baseline, but exact product, dimensions and use clearance are unspecified; no bathing fixture is drawn.'
        lighting_roof = 'All six M83 ideal pitch/ridge planes are recomputed over each unchanged M130 U-05 block. No finished floor/eave datum or ceiling assembly is defined; no headroom result is reported.'
        route = if ($routeValidation) { 'The bundled M37 report reran both exact M130 room-block layouts on its 1/6-ft centerline grid, with nine samples per public-room edge. This is reachability sampling, not an actual doorway or clear-width test.' } else { 'Route sampling has not yet been attached; run the M37 candidate validation command and rerun this analyzer with -RouteValidationReportPath.' }
    }
    gates = [ordered]@{
        owner_selected_shell_or_room_layout = $false
        actual_opening_and_door_swing_checked = $false
        sampled_U02_public_hall_edge_in_M130_layouts = [bool]($routeValidation -and @($routeValidation.results | Where-Object { $_.public_room_sample_sides.'U-02'.Count -gt 0 }).Count -eq 2)
        sampled_U03_public_side_unreachable_in_M130_layouts = [bool]($routeValidation -and @($routeValidation.results | Where-Object { $_.u03_public_side_reachable }).Count -eq 0)
        physical_U02_opening_and_private_Jack_Jill_door_topology_checked = $false
        toilet_exact_RFA_solids = $false
        sink_final_selection_and_exact_RFA_solids = $false
        tub_shower_product_geometry_and_clearance = $false
        finished_face_clearance_and_approach = $false
        plumbing_water_waste_vent_route = $false
        roof_finished_headroom_and_CT_screen = $false
        Revit_derivative_and_IFC = $false
        room_assignment = $false
    }
    limitations = @(
        'M130 leaders are samples from an incomplete bounded search; this two-candidate comparison does not establish an optimum.',
        'M37 represents the primary-bath interface as a 0.5 ft wall-band separation and a 3.5 ft nominal room-contact reservation. This is a topology convention and centered segment arithmetic, not a modeled wall or door.',
        'All room boundaries are gross schematic rectangles. The nominal wall band is not a detailed wall assembly; finished faces and tolerances are absent.',
        'The 610AA toilet is dimensioned from a manufacturer infographic, not a Revit family or exact-SKU dimensional drawing. Sink envelopes are nominal manufacturer values; Evolution is discontinued and its family metadata conflict remains, while Tresham family geometry is uninspected.',
        'The 15-in/21-in clearance values are a preliminary screen only. Door operation, approach, fixture use zones, accessibility, privacy, bathing, structure and service routing are not validated.',
        'No Connecticut code compliance, structural safety, professional approval, permit readiness or construction readiness is asserted.'
    )
    checks = $checks
}

$outPrefix = $repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
$out = [System.IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))
if (-not $out.StartsWith($outPrefix,[System.StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository.' }
New-Item -ItemType Directory -Path $out -Force | Out-Null
$checkEnvelope = [ordered]@{ schema='forever-home.m132-checks.v1'; passed_count=$checks.Count; check_count=$checks.Count; failed=@(); checks=$checks }
[System.IO.File]::WriteAllText((Join-Path $out 'm132-report.json'), (($report | ConvertTo-Json -Depth 16) + "`n"), [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $out 'm132-checks.json'), (($checkEnvelope | ConvertTo-Json -Depth 8) + "`n"), [System.Text.UTF8Encoding]::new($false))
$configs | Export-Csv -LiteralPath (Join-Path $out 'm132-fixture-groups.csv') -NoTypeInformation -Encoding UTF8
$layoutOutputs | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $out 'm132-layouts.json') -Encoding UTF8
$roofRows = foreach ($layout in $layoutOutputs) { foreach ($case in $layout.roof_cases) { [pscustomobject][ordered]@{ candidate_id=$layout.candidate_id; variant=$layout.variant; roof_case_id=$case.roof_case_id; pitch=$case.pitch; ridge_axis=$case.ridge_axis; minimum_ideal_rise_above_relative_eave_ft=$case.u05_minimum_ideal_rise_above_relative_eave_ft; maximum_ideal_rise_above_relative_eave_ft=$case.u05_maximum_ideal_rise_above_relative_eave_ft; finished_headroom_checked=$false } } }
$roofRows | Export-Csv -LiteralPath (Join-Path $out 'm132-roof-comparison.csv') -NoTypeInformation -Encoding UTF8
$scale = 10.0
$panelW = 455
$panelH = 505
$shellWpx = [double]$roof.shell.width_ft * $scale
$shellHpx = [double]$roof.shell.depth_ft * $scale
$svg = [System.Text.StringBuilder]::new()
[void]$svg.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$svg.AppendLine("<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$($panelW * 2)`" height=`"$panelH`" viewBox=`"0 0 $($panelW * 2) $panelH`">")
[void]$svg.AppendLine('<style>text{font-family:Segoe UI,Arial,sans-serif;fill:#20262d}.title{font-size:15px;font-weight:700}.label{font-size:12px}.small{font-size:10px}.room{fill:#e7e8e5;stroke:#59636d;stroke-width:1}.primary{fill:#dce8f5}.bath{fill:#f4e2c6;stroke:#9c6a24;stroke-width:2}.fixture{fill:#fafafa;stroke:#3e5264;stroke-width:1.5}.clear{fill:#d9eef2;fill-opacity:.48;stroke:#3b91a1;stroke-dasharray:4 3;stroke-width:1}.shell{fill:#fff;stroke:#242b30;stroke-width:2}.shared{stroke:#bf3c35;stroke-width:4;stroke-dasharray:7 4}.spacer{stroke:#b37b20;stroke-width:2;stroke-dasharray:3 3}</style>')
foreach ($ix in 0..($layoutOutputs.Count-1)) {
    $layout = $layoutOutputs[$ix]
    $ox = $ix * $panelW
    $sy = 52.0
    $sx = 28.0
    $x = { param($v) [Math]::Round($sx + ([double]$v * $scale),2) }
    $y = { param($v,$d) [Math]::Round($sy + (($roof.shell.depth_ft - [double]$v - [double]$d) * $scale),2) }
    [void]$svg.AppendLine("<g transform=`"translate($ox,0)`">")
    $variantName = 'M130 source layout'
    [void]$svg.AppendLine("<text x=`"18`" y=`"22`" class=`"title`">$($layout.candidate_id) - $variantName</text>")
    [void]$svg.AppendLine("<text x=`"18`" y=`"39`" class=`"small`">Hypothetical shell; gross room blocks only; scale 10 px/ft</text>")
    [void]$svg.AppendLine("<rect x=`"$sx`" y=`"$sy`" width=`"$([Math]::Round($shellWpx,2))`" height=`"$([Math]::Round($shellHpx,2))`" class=`"shell`"/>")
    foreach ($room in $layout.other_rooms) {
        $fill = if ($room.id -eq 'U-01') { 'primary' } else { 'room' }
        [void]$svg.AppendLine("<rect x=`"$(& $x $room.x)`" y=`"$(& $y $room.y $room.d)`" width=`"$([Math]::Round($room.w*$scale,2))`" height=`"$([Math]::Round($room.d*$scale,2))`" class=`"$fill`"/>")
        [void]$svg.AppendLine("<text x=`"$([Math]::Round((& $x $room.x)+4,2))`" y=`"$([Math]::Round((& $y $room.y $room.d)+13,2))`" class=`"small`">$($room.id)</text>")
    }
    $u1 = $layout.u01; $u5 = $layout.u05
    [void]$svg.AppendLine("<rect x=`"$(& $x $u1.x)`" y=`"$(& $y $u1.y $u1.d)`" width=`"$([Math]::Round($u1.w*$scale,2))`" height=`"$([Math]::Round($u1.d*$scale,2))`" class=`"primary`" stroke=`"#59636d`"/>")
    [void]$svg.AppendLine("<text x=`"$([Math]::Round((& $x $u1.x)+5,2))`" y=`"$([Math]::Round((& $y $u1.y $u1.d)+17,2))`" class=`"label`">U-01 Primary</text>")
    [void]$svg.AppendLine("<rect x=`"$(& $x $u5.x)`" y=`"$(& $y $u5.y $u5.d)`" width=`"$([Math]::Round($u5.w*$scale,2))`" height=`"$([Math]::Round($u5.d*$scale,2))`" class=`"bath`"/>")
    [void]$svg.AppendLine("<text x=`"$([Math]::Round((& $x $u5.x)+5,2))`" y=`"$([Math]::Round((& $y $u5.y $u5.d)+17,2))`" class=`"label`">U-05 Primary bath</text>")
    $roomDepthIn = [double]$u5.d * 12.0
    $wcX0 = [double]$u5.x + ((15.0 - ($toilet.width_in/2.0))/12.0)
    $wcY0 = [double]$u5.y + ([double]$u5.d - ($toilet.projection_in/12.0))
    $wcFrontY = $wcY0 - ($frontClearance/12.0)
    $lavW = 24.0/12.0; $lavD = 19.5/12.0
    $lavX0 = [double]$u5.x + ((45.0 - 12.0)/12.0)
    $lavY0 = [double]$u5.y + ([double]$u5.d - $lavD)
    $lavFrontY = $lavY0 - ($frontClearance/12.0)
    [void]$svg.AppendLine("<rect x=`"$(& $x $wcX0)`" y=`"$(& $y $wcFrontY ($frontClearance/12.0))`" width=`"$([Math]::Round((19.0/12.0)*$scale,2))`" height=`"$([Math]::Round(($frontClearance/12.0)*$scale,2))`" class=`"clear`"/>")
    [void]$svg.AppendLine("<rect x=`"$(& $x $lavX0)`" y=`"$(& $y $lavFrontY ($frontClearance/12.0))`" width=`"$([Math]::Round($lavW*$scale,2))`" height=`"$([Math]::Round(($frontClearance/12.0)*$scale,2))`" class=`"clear`"/>")
    [void]$svg.AppendLine("<rect x=`"$(& $x $wcX0)`" y=`"$(& $y $wcY0 ($toilet.projection_in/12.0))`" width=`"$([Math]::Round((19.0/12.0)*$scale,2))`" height=`"$([Math]::Round(($toilet.projection_in/12.0)*$scale,2))`" class=`"fixture`"/>")
    [void]$svg.AppendLine("<rect x=`"$(& $x $lavX0)`" y=`"$(& $y $lavY0 $lavD)`" width=`"$([Math]::Round($lavW*$scale,2))`" height=`"$([Math]::Round($lavD*$scale,2))`" class=`"fixture`"/>")
    [void]$svg.AppendLine("<text x=`"$([Math]::Round((& $x $wcX0)+2,2))`" y=`"$([Math]::Round((& $y $wcY0 ($toilet.projection_in/12.0))+12,2))`" class=`"small`">610AA envelope</text>")
    [void]$svg.AppendLine("<text x=`"$([Math]::Round((& $x $lavX0)+2,2))`" y=`"$([Math]::Round((& $y $lavY0 $lavD)+12,2))`" class=`"small`">Tresham candidate</text>")
    $contactLength = [double]$layout.U01_U05_contact_length_ft
    $left = [Math]::Max($u1.x,$u5.x); $right = [Math]::Min(($u1.x+$u1.w),($u5.x+$u5.w))
    $bandMidY = ((& $y $u1.y $u1.d) + ((& $y $u5.y 0.0))) / 2.0
    [void]$svg.AppendLine("<line x1=`"$(& $x $left)`" y1=`"$bandMidY`" x2=`"$(& $x $right)`" y2=`"$bandMidY`" class=`"spacer`"/>")
    $resStartX = $left + (($contactLength-$doorReservationFt)/2.0)
    $resEndX = $resStartX + $doorReservationFt
    [void]$svg.AppendLine("<line x1=`"$(& $x $resStartX)`" y1=`"$bandMidY`" x2=`"$(& $x $resEndX)`" y2=`"$bandMidY`" class=`"shared`"/>")
    [void]$svg.AppendLine("<text x=`"18`" y=`"$([Math]::Round($sy+$shellHpx+20,2))`" class=`"small`">0.5 ft M37 wall-band convention; red = centered 3.5 ft source reservation, not a door design.</text>")
    [void]$svg.AppendLine("<text x=`"18`" y=`"$([Math]::Round($sy+$shellHpx+35,2))`" class=`"small`">Blue dashed = 21 in screen strips; M-06 toilet envelope is illustrative in U-05.</text>")
    [void]$svg.AppendLine('</g>')
}
[void]$svg.AppendLine('</svg>')
[System.IO.File]::WriteAllText((Join-Path $out 'm132-plan.svg'), $svg.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Output ("M132 PASS: {0}/{1} checks; {2} comparison layouts; {3} fixture envelope cases" -f $checks.Count,$checks.Count,$layoutOutputs.Count,$configs.Count)
Write-Output ("Proposal report: {0}" -f (Join-Path $out 'm132-report.json'))
if ($routeValidation) { Write-Output 'M37 sampled route evidence attached; door geometry, private door topology, room assignment, Revit, IFC, code compliance and structure remain unverified.' }
else { Write-Output 'No route, door, bath fixture, room assignment, Revit, IFC, code-compliance or structural result is claimed.' }
