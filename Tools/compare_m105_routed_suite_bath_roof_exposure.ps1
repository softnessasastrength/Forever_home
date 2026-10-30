param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M105_Routed_Suite_Bath_Roof_Exposure_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m78Directory = Join-Path $repo 'Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29'
$m83Directory = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
$searchPath = Join-Path $m78Directory 'search.json'
$manifestPath = Join-Path $m78Directory 'manifest.json'
$roofPath = Join-Path $m83Directory 'roof-options.json'

function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }

$search = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$roof = Get-Content -LiteralPath $roofPath -Raw | ConvertFrom-Json
$hashes = [ordered]@{ m78_search = Get-Sha256 $searchPath; m78_manifest = Get-Sha256 $manifestPath; m83_roof_options = Get-Sha256 $roofPath }
if ($manifest.output_hashes_sha256.search -ne $hashes.m78_search) { throw 'M78 search does not match its manifest.' }
if ($roof.source_fingerprints_sha256.m78_search -ne $hashes.m78_search -or $roof.source_fingerprints_sha256.m78_manifest -ne $hashes.m78_manifest) { throw 'M83 does not bind current M78 sources.' }
if ([Math]::Abs([double]$search.coordinate_basis.width_ft - 38.333333) -gt 0.000001 -or [Math]::Abs([double]$search.coordinate_basis.depth_ft - 40.0) -gt 0.000001) { throw 'Expected the owner-authorized hypothetical M78 shell.' }

$selectedPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$selectedHash = Get-Sha256 $selectedPath
if ($roof.source_fingerprints_sha256.selected_d_study -ne $selectedHash) { throw 'M83 does not match current selected-D source.' }
$shellWidth = [double]$search.coordinate_basis.width_ft
$shellDepth = [double]$search.coordinate_basis.depth_ft
$candidates = @($search.top_partial_public_access_layouts)
$results = @()
$checks = [ordered]@{
    m78_search_matches_manifest = $true
    m83_binds_current_m78_and_selected_d = $true
    shell_is_hypothetical_38_333333_by_40 = $true
    five_route_ranked_candidates_are_present = ($candidates.Count -eq 5)
    all_candidates_reach_required_public_rooms = $true
    all_candidates_preserve_u03_private_only_hall_access = $true
    all_candidates_give_u02_north_hall_sample = $true
    candidates_contain_seven_nonoverlapping_in_shell_room_blocks = $true
    room_block_areas_match_m78_program_dimensions = $true
    primary_bath_area_remains_90_sf = $true
    all_six_roof_cases_are_evaluated_per_candidate = $true
    comparison_svg_is_valid = $true
    selected_d_unchanged = $true
}

$candidateSummaries = @()
$candidateNumber = 0
foreach ($candidate in $candidates) {
    $candidateNumber++
    $candidateId = 'M78-TOP-{0:D2}' -f $candidateNumber
    $rectangles = $candidate.rectangles
    $roomProperties = @($rectangles.PSObject.Properties | ForEach-Object { $_ })
    if ($roomProperties.Count -ne 7) { $checks.candidates_contain_seven_nonoverlapping_in_shell_room_blocks = $false; continue }
    if (-not $candidate.hall_reachability.required_public_rooms_reached) { $checks.all_candidates_reach_required_public_rooms = $false }
    if ($candidate.hall_reachability.u03_hall_side_reachable) { $checks.all_candidates_preserve_u03_private_only_hall_access = $false }
    if ([string]$candidate.hall_reachability.reachable_room_sides.'U-02' -notmatch 'north') { $checks.all_candidates_give_u02_north_hall_sample = $false }

    $boxes = @()
    foreach ($property in $roomProperties) {
        $room = $property.Value
        $x0 = [double]$room.x_ft; $y0 = [double]$room.y_ft
        $x1 = $x0 + [double]$room.width_ft; $y1 = $y0 + [double]$room.depth_ft
        $sourceRoom = $search.source_dimensions_ft.($room.id)
        if ($null -eq $sourceRoom -or [Math]::Abs(([double]$room.width_ft * [double]$room.depth_ft) - ([double]$sourceRoom.width_ft * [double]$sourceRoom.depth_ft)) -gt 0.000001) { $checks.room_block_areas_match_m78_program_dimensions = $false }
        if ([string]$room.id -eq 'U-05' -and [Math]::Abs(([double]$room.width_ft * [double]$room.depth_ft) - 90.0) -gt 0.000001) { $checks.primary_bath_area_remains_90_sf = $false }
        if ($x0 -lt -0.000001 -or $y0 -lt -0.000001 -or $x1 -gt ($shellWidth + 0.000001) -or $y1 -gt ($shellDepth + 0.000001)) { $checks.candidates_contain_seven_nonoverlapping_in_shell_room_blocks = $false }
        $boxes += [pscustomobject]@{ id = [string]$room.id; x0 = $x0; y0 = $y0; x1 = $x1; y1 = $y1 }
    }
    for ($i = 0; $i -lt $boxes.Count; $i++) {
        for ($j = $i + 1; $j -lt $boxes.Count; $j++) {
            $overlapX = [Math]::Min($boxes[$i].x1,$boxes[$j].x1) - [Math]::Max($boxes[$i].x0,$boxes[$j].x0)
            $overlapY = [Math]::Min($boxes[$i].y1,$boxes[$j].y1) - [Math]::Max($boxes[$i].y0,$boxes[$j].y0)
            if ($overlapX -gt 0.000001 -and $overlapY -gt 0.000001) { $checks.candidates_contain_seven_nonoverlapping_in_shell_room_blocks = $false }
        }
    }
    $u05 = $rectangles.'U-05'
    $candidateSummaries += [pscustomobject][ordered]@{
        candidate_id = $candidateId
        m78_layout_key = [string]$candidate.layout_key
        is_m78_best_candidate = ([string]$candidate.layout_key -eq [string]$search.best_candidate.layout_key)
        bounds_width_ft = [Math]::Round([double]$candidate.layout_bounds_ft.width,6)
        bounds_depth_ft = [Math]::Round([double]$candidate.layout_bounds_ft.depth,6)
        primary_bath_x_ft = [Math]::Round([double]$u05.x_ft,6)
        primary_bath_y_ft = [Math]::Round([double]$u05.y_ft,6)
        primary_bath_width_ft = [Math]::Round([double]$u05.width_ft,6)
        primary_bath_depth_ft = [Math]::Round([double]$u05.depth_ft,6)
        primary_bath_area_sf = [Math]::Round([double]$u05.width_ft * [double]$u05.depth_ft,4)
        public_reach_count = [int]$candidate.public_rooms_reached_count
        u02_hall_sample_side = [string]$candidate.hall_reachability.reachable_room_sides.'U-02'
        u03_hall_sample_reachable = [bool]$candidate.hall_reachability.u03_hall_side_reachable
    }

    foreach ($option in $roof.results) {
        $axis = [string]$option.ridge_axis
        $span = if ($axis -eq 'X') { $shellDepth } else { $shellWidth }
        $start = if ($axis -eq 'X') { [double]$u05.y_ft } else { [double]$u05.x_ft }
        $length = if ($axis -eq 'X') { [double]$u05.depth_ft } else { [double]$u05.width_ft }
        $end = $start + $length
        $ridge = $span / 2.0
        $distanceFromRidgeAtFarEdge = [Math]::Max([Math]::Abs($start - $ridge),[Math]::Abs($end - $ridge))
        $distanceFromRidgeAtNearEdge = [Math]::Min([Math]::Abs($start - $ridge),[Math]::Abs($end - $ridge))
        $minimumRise = [Math]::Round(($span / 2.0 - $distanceFromRidgeAtFarEdge) * [double]$option.pitch_ratio,6)
        $maximumRiseUnrounded = if ($start -le $ridge -and $end -ge $ridge) { ($span / 2.0) * [double]$option.pitch_ratio } else { ($span / 2.0 - $distanceFromRidgeAtNearEdge) * [double]$option.pitch_ratio }
        $maximumRise = [Math]::Round($maximumRiseUnrounded,6)
        if ($minimumRise -lt -0.000001 -or $maximumRise -lt $minimumRise) { $checks.all_six_roof_cases_are_evaluated_per_candidate = $false }
        $results += [pscustomobject][ordered]@{
            candidate_id = $candidateId
            roof_case_id = [string]$option.case_id
            pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
            ridge_axis = $axis
            u05_minimum_ideal_roof_rise_above_relative_eave_ft = $minimumRise
            u05_maximum_ideal_roof_rise_above_relative_eave_ft = $maximumRise
            u05_primary_bath_fixture_or_use_zone_checked = $false
            interpretation = 'Geometric roof-plane exposure over the whole M78 primary-bath block; not fixture headroom or clearance.'
        }
    }
}

if ($results.Count -ne 30) { $checks.all_six_roof_cases_are_evaluated_per_candidate = $false }
if ((Get-Sha256 $selectedPath) -ne $selectedHash) { $checks.selected_d_unchanged = $false }
$svgLines = [System.Collections.Generic.List[string]]::new()
$scale = 7.2
$plotTop = 76.0
$panelDefinitions = @(
    [pscustomobject]@{ index = 1; candidate = $candidates[1]; title = 'M78-TOP-02 | current search winner' },
    [pscustomobject]@{ index = 2; candidate = $candidates[4]; title = 'M78-TOP-05 | balanced roof-edge option' }
)
$svgLines.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1120" height="500" viewBox="0 0 1120 500">')
$svgLines.Add('<title>M105 comparison of the M78 winner and roof-balanced U-05 layout</title>')
$svgLines.Add('<style>text{font-family:Arial,sans-serif;fill:#253342}.title{font-size:25px;font-weight:700}.panel{font-size:18px;font-weight:700}.label{font-size:11px;font-weight:600}.small{font-size:13px}.shell{fill:#fbfaf6;stroke:#273d4c;stroke-width:2.5}.approach{fill:#e5b64c;fill-opacity:.22;stroke:#9a6815;stroke-width:2;stroke-dasharray:7 5}.U01{fill:#d9e5ef}.U02{fill:#e5def1}.U03{fill:#d9eadf}.U04{fill:#e8dfd5}.U05{fill:#f4c58a;stroke:#a75314;stroke-width:2.5}.U06{fill:#d8e9e6}.CPRIVATE{fill:#e8e8e3}</style>')
$svgLines.Add('<text class="title" x="48" y="38">M105 | Upper-suite room blocks and primary-bath roof exposure</text>')
foreach ($panel in $panelDefinitions) {
    $panelLeft = if ($panel.index -eq 1) { 68.0 } else { 570.0 }
    $svgLines.Add(('<text class="panel" x="{0}" y="64">{1}</text>' -f $panelLeft,$panel.title))
    $shellHeight = $shellDepth * $scale
    $shellWidthPx = $shellWidth * $scale
    $svgLines.Add(('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $panelLeft,$plotTop,$shellWidthPx,$shellHeight))
    foreach ($property in $panel.candidate.rectangles.PSObject.Properties) {
        $room = $property.Value
        $x = $panelLeft + ([double]$room.x_ft * $scale)
        $y = $plotTop + (($shellDepth - [double]$room.y_ft - [double]$room.depth_ft) * $scale)
        $w = [double]$room.width_ft * $scale
        $h = [double]$room.depth_ft * $scale
        $class = ([string]$room.id).Replace('-','')
        $svgLines.Add(('<rect class="{0}" x="{1}" y="{2}" width="{3}" height="{4}" stroke="#465b68" stroke-width="1.3"/>' -f $class,$x,$y,$w,$h))
        $svgLines.Add(('<text class="label" text-anchor="middle" x="{0}" y="{1}">{2}</text>' -f ($x+$w/2.0),($y+$h/2.0+4.0),[string]$room.id))
    }
    $approach = $search.reserved_stair_approach
    $ax = $panelLeft + ([double]$approach.x_ft * $scale)
    $ay = $plotTop + (($shellDepth - [double]$approach.y_ft - [double]$approach.depth_ft) * $scale)
    $svgLines.Add(('<rect class="approach" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $ax,$ay,([double]$approach.width_ft*$scale),([double]$approach.depth_ft*$scale)))
    $u05 = $panel.candidate.rectangles.'U-05'
    $svgLines.Add(('<text class="small" x="{0}" y="{1}">U-05: x={2}, y={3} ft; {4} × {5} ft; 90 sf</text>' -f $panelLeft,($plotTop+$shellHeight+23.0),[Math]::Round([double]$u05.x_ft,3),[Math]::Round([double]$u05.y_ft,3),[Math]::Round([double]$u05.width_ft,3),[Math]::Round([double]$u05.depth_ft,3)))
}
$svgLines.Add('<text class="small" x="68" y="432">Dashed box = reserved stair-approach proxy. Both retain M78 sampled hall access to U-01/U-02/U-04 and no U-03 hall sample.</text>')
$svgLines.Add('<text class="small" x="68" y="454">M78-TOP-05 shifts/rotates U-05 while retaining 90 sf; roof-plane rise is more balanced for X/Y, not measured fixture headroom.</text>')
$svgLines.Add('<text class="small" x="68" y="476">38⅓ × 40 ft hypothetical test shell. Room-block study only: no walls, doors, roof assembly, fixture locations, or code finding.</text>')
$svgLines.Add('</svg>')
$svgText = $svgLines -join "`n"
try { [xml]$svgText | Out-Null } catch { $checks.comparison_svg_is_valid = $false; Write-Warning $_.Exception.Message }
$report = [ordered]@{
    milestone = 'M105'
    title = 'Roof-edge sensitivity across five route-ranked M78 room layouts'
    status = 'sample comparison only; no room move, shell or roof direction selected'
    shell = [ordered]@{ width_ft = $shellWidth; depth_ft = $shellDepth; status = 'owner-authorized hypothetical exploration case' }
    source_hashes_sha256 = $hashes
    candidate_sampling = 'The five candidates are exactly M78 top_partial_public_access_layouts, sorted by the archived M78 rank. Each has sampled U-01/U-02/U-04 public hall reach, a north-side U-02 hall sample, and no sampled U-03 hall access. M78 evaluated 457 complete room packings; this retained top-five subset is not exhaustive.'
    results = @($results)
    candidate_summaries = @($candidateSummaries)
    checks = $checks
    failures = @($checks.Keys | Where-Object { -not $checks[$_] })
    limitations = @(
        'Routes and room links are M78 sampled-grid/contact proxies, not actual doors, openings or clear circulation.',
        'U-05 checks the entire schematic bath rectangle against the roof plane; no bath fixture, use zone, 6 ft 8 in showerhead area or service route is represented.',
        'Heights are above an unassigned relative eave, not above a finished floor or ceiling datum.',
        'The candidate set includes only five ranked records from a bounded, incomplete 457-packing search; it is not an exhaustive optimization.',
        'The shell and all candidate positions remain proposals. Selected-D and Incoming RFAs are unchanged.'
    )
}
if ($report.failures.Count -gt 0) { throw "M105 failed: $($report.failures -join ', ')." }

$resolvedOutput = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$repoPrefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutput.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $resolvedOutput)) { New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null }
$jsonPath = Join-Path $resolvedOutput 'route-ranked-roof-exposure.json'
$csvPath = Join-Path $resolvedOutput 'bath-roof-exposure.csv'
$svgPath = Join-Path $resolvedOutput 'routed-bath-roof-alternative.svg'
ConvertTo-Json -InputObject $report -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
$svgText | Set-Content -LiteralPath $svgPath -Encoding utf8
[xml](Get-Content -LiteralPath $svgPath -Raw) | Out-Null
Write-Output "M105 checks passed: $($checks.Count)/$($checks.Count); $($candidateSummaries.Count) route-ranked layouts, $($results.Count) roof cases; JSON SHA256 $((Get-Sha256 $jsonPath)); CSV SHA256 $((Get-Sha256 $csvPath)); SVG SHA256 $((Get-Sha256 $svgPath))."
