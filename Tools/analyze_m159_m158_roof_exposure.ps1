param(
    [string]$M158Directory = (Join-Path $PSScriptRoot '../Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31'),
    [string]$M83Directory = (Join-Path $PSScriptRoot '../Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M159_M158_Gable_Exposure_2026-10-31')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
function Resolve-RepoPath([string]$Path) {
    $resolved = if ([IO.Path]::IsPathRooted($Path)) { [IO.Path]::GetFullPath($Path) } else { [IO.Path]::GetFullPath((Join-Path $repo $Path)) }
    $prefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw "Path must resolve inside the repository: $Path" }
    return $resolved
}
function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }

$m158 = Resolve-RepoPath $M158Directory
$m83 = Resolve-RepoPath $M83Directory
$selectedPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$paths = [ordered]@{
    search = Join-Path $m158 'search.json'
    manifest = Join-Path $m158 'manifest.json'
    archive = Join-Path $m158 'all-route-tested-candidates.json'
    audit = Join-Path $m158 'm158-joint-perimeter-audit.json'
    roof_options = Join-Path $m83 'roof-options.json'
    selected_d = $selectedPath
}
foreach ($path in $paths.Values) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source missing: $path" } }

$search = Get-Content -LiteralPath $paths.search -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $paths.manifest -Raw | ConvertFrom-Json
$archive = Get-Content -LiteralPath $paths.archive -Raw | ConvertFrom-Json
$audit = Get-Content -LiteralPath $paths.audit -Raw | ConvertFrom-Json
$roof = Get-Content -LiteralPath $paths.roof_options -Raw | ConvertFrom-Json
$hashes = [ordered]@{}
foreach ($key in $paths.Keys) { $hashes[$key] = Get-Sha256 $paths[$key] }

$shellW = [double]$roof.coordinate_basis.shell_width_ft
$shellD = [double]$roof.coordinate_basis.shell_depth_ft
$bedroomIds = @('U-01','U-03','U-04')
$candidateRows = @($archive.candidates)
$checks = [ordered]@{
    m158_generator_hashes_match_manifest = (
        $hashes.search -eq [string]$manifest.output_hashes_sha256.search -and
        $hashes.archive -eq [string]$manifest.optional_route_tested_candidate_archive.sha256 -and
        @($candidateRows).Count -eq [int]$manifest.optional_route_tested_candidate_archive.candidate_count
    )
    m158_audit_is_complete_and_current = (
        $audit.milestone -eq 'M158' -and @($audit.failures).Count -eq 0 -and
        @($audit.candidates).Count -eq @($candidateRows).Count -and
        $audit.hashes_sha256.search -eq $hashes.search -and $audit.hashes_sha256.archive -eq $hashes.archive
    )
    m83_roof_case_set_has_six_unselected_options = (@($roof.results).Count -eq 6 -and $roof.status -match 'no pitch')
    shell_dimensions_match_m158_search = (
        [Math]::Abs($shellW - [double]$search.coordinate_basis.width_ft) -le 0.000001 -and
        [Math]::Abs($shellD - [double]$search.coordinate_basis.depth_ft) -le 0.000001
    )
    shell_remains_hypothetical_and_eave_unassigned = ($roof.coordinate_basis.shell_status -match 'hypothetical' -and $roof.coordinate_basis.absolute_eave_elevation -match 'unassigned')
    selected_d_fingerprint_matches_m83 = ($hashes.selected_d -eq [string]$roof.source_fingerprints_sha256.selected_d_study)
    exactly_two_archived_candidates = (@($candidateRows).Count -eq 2)
    each_candidate_has_all_seven_source_rooms = (@($candidateRows | Where-Object { @($_.rectangles.PSObject.Properties.Name).Count -ne 7 }).Count -eq 0)
    bedroom_room_blocks_are_identical_between_candidates = $true
    only_u05_differs_between_the_two_candidates = $true
    every_room_section_is_inside_the_roof_cross_slope = $true
}

if ($candidateRows.Count -ne 2) { throw 'Expected exactly two M158 archive records.' }
$baseRooms = $candidateRows[0].rectangles
foreach ($candidate in $candidateRows) {
    foreach ($id in $bedroomIds) {
        $room = $candidate.rectangles.$id
        $base = $baseRooms.$id
        foreach ($field in @('x_ft','y_ft','width_ft','depth_ft')) {
            if ([Math]::Abs([double]$room.$field - [double]$base.$field) -gt 0.000001) { $checks.bedroom_room_blocks_are_identical_between_candidates = $false }
        }
    }
}
$differentRooms = [System.Collections.Generic.List[string]]::new()
foreach ($property in $baseRooms.PSObject.Properties) {
    $other = $candidateRows[1].rectangles.($property.Name)
    foreach ($field in @('x_ft','y_ft','width_ft','depth_ft')) {
        if ([Math]::Abs([double]$property.Value.$field - [double]$other.$field) -gt 0.000001) { $differentRooms.Add([string]$property.Name); break }
    }
}
$checks.only_u05_differs_between_the_two_candidates = (@($differentRooms.ToArray() | Sort-Object -Unique) -join ',') -eq 'U-05'

$rows = [System.Collections.Generic.List[object]]::new()
foreach ($candidateIndex in 0..($candidateRows.Count - 1)) {
    $candidate = $candidateRows[$candidateIndex]
    $candidateLabel = if ([bool]$candidate.hall_reachability.required_public_rooms_reached -and -not [bool]$candidate.hall_reachability.u03_hall_side_reachable) { 'sampled-route-and-privacy-proxy-pass' } else { 'sampled-route-proxy-incomplete' }
    foreach ($option in $roof.results) {
        $axis = [string]$option.ridge_axis
        $span = if ($axis -eq 'X') { $shellD } elseif ($axis -eq 'Y') { $shellW } else { throw "Unsupported ridge axis: $axis" }
        $ridge = $span / 2.0
        foreach ($property in $candidate.rectangles.PSObject.Properties) {
            $room = $property.Value
            $start = if ($axis -eq 'X') { [double]$room.y_ft } else { [double]$room.x_ft }
            $length = if ($axis -eq 'X') { [double]$room.depth_ft } else { [double]$room.width_ft }
            $end = $start + $length
            if ($start -lt -0.000001 -or $end -gt ($span + 0.000001)) { $checks.every_room_section_is_inside_the_roof_cross_slope = $false; continue }
            $farthest = [Math]::Max([Math]::Abs($start - $ridge), [Math]::Abs($end - $ridge))
            $nearest = [Math]::Min([Math]::Abs($start - $ridge), [Math]::Abs($end - $ridge))
            $containsRidge = ($start -le $ridge -and $end -ge $ridge)
            $minRise = [Math]::Round(($span / 2.0 - $farthest) * [double]$option.pitch_ratio, 6)
            $maxRise = if ($containsRidge) { [Math]::Round(($span / 2.0) * [double]$option.pitch_ratio, 6) } else { [Math]::Round(($span / 2.0 - $nearest) * [double]$option.pitch_ratio, 6) }
            $eaveEdges = @()
            if ([Math]::Abs($start) -le 0.000001) { $eaveEdges += if ($axis -eq 'X') { 'south' } else { 'west' } }
            if ([Math]::Abs($end - $span) -le 0.000001) { $eaveEdges += if ($axis -eq 'X') { 'north' } else { 'east' } }
            $rows.Add([pscustomobject][ordered]@{
                candidate_index = $candidateIndex + 1
                candidate_key = [string]$candidate.layout_key
                route_proxy_class = $candidateLabel
                roof_case_id = [string]$option.case_id
                pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
                ridge_axis = $axis
                room_id = [string]$room.id
                room_cross_slope_start_ft = [Math]::Round($start,6)
                room_cross_slope_end_ft = [Math]::Round($end,6)
                touched_ideal_eave_edges = ($eaveEdges -join ';')
                minimum_relative_roof_rise_ft = $minRise
                maximum_relative_roof_rise_ft = $maxRise
                absolute_eave_elevation_ft = $null
                clear_interior_headroom_ft = $null
                interpretation = 'Ideal zero-thickness gable-plane rise above a relative eave across a schematic room block; not interior headroom.'
            })
        }
    }
}

$bedroomSummaries = @()
foreach ($candidateIndex in 1..$candidateRows.Count) {
    foreach ($option in $roof.results) {
        $caseRows = @($rows | Where-Object { $_.candidate_index -eq $candidateIndex -and $_.roof_case_id -eq $option.case_id -and $_.room_id -in $bedroomIds })
        $lowest = $caseRows | Sort-Object { [double]$_.minimum_relative_roof_rise_ft } | Select-Object -First 1
        $bedroomSummaries += [pscustomobject][ordered]@{
            candidate_index = $candidateIndex
            roof_case_id = [string]$option.case_id
            pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
            ridge_axis = [string]$option.ridge_axis
            lowest_bedroom_capable_room_ids = @($caseRows | Where-Object { [double]$_.minimum_relative_roof_rise_ft -eq [double]$lowest.minimum_relative_roof_rise_ft } | ForEach-Object room_id | Sort-Object)
            minimum_relative_rise_over_bedroom_capable_blocks_ft = [double]$lowest.minimum_relative_roof_rise_ft
        }
    }
}

$checks['all_expected_candidate_room_case_rows_present'] = ($rows.Count -eq 84)
$checks['bedroom_summaries_present_for_both_candidates_and_all_roof_cases'] = ($bedroomSummaries.Count -eq 12)
$eaveContactCases = 0
foreach ($candidateIndex in 1..$candidateRows.Count) {
    foreach ($option in $roof.results) {
        $touchingBedroomCount = @($rows | Where-Object { $_.candidate_index -eq $candidateIndex -and $_.roof_case_id -eq $option.case_id -and $_.room_id -in $bedroomIds -and -not [string]::IsNullOrWhiteSpace([string]$_.touched_ideal_eave_edges) } | Select-Object -ExpandProperty room_id -Unique).Count
        if ($touchingBedroomCount -ge 2) { $eaveContactCases++ }
    }
}
$checks['at_least_two_bedroom_capable_blocks_touch_ideal_eaves_in_every_case'] = ($eaveContactCases -eq 12)
$checks['all_reported_relative_rises_are_nonnegative_and_ordered'] = (@($rows | Where-Object { $_.minimum_relative_roof_rise_ft -lt -0.000001 -or $_.maximum_relative_roof_rise_ft -lt $_.minimum_relative_roof_rise_ft }).Count -eq 0)
$failures = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failures.Count -gt 0) { throw "M159 checks failed: $($failures -join ', ')" }

$report = [ordered]@{
    milestone = 'M159'
    title = 'M158 room-block exposure under existing ideal gable comparisons'
    status = 'hypothetical geometric sensitivity; no roof, room layout, eave, floor, ceiling, or shell dimension selected'
    shell = [ordered]@{ width_ft=$shellW; depth_ft=$shellD; source='M83 hypothetical shell comparison, cross-checked to M158' }
    method = 'For each M158 archived room rectangle and each of the six M83 ideal gable planes, compute the minimum and maximum relative plane rise over its cross-slope interval; mark only whether the rectangle reaches an ideal eave edge.'
    candidate_count = $candidateRows.Count
    room_case_count = $rows.Count
    sources_sha256 = $hashes
    checks = $checks
    failures = $failures
    bedroom_exposure_summaries = $bedroomSummaries
    limitations = @(
        'The source archive contains two incomplete room-block arrangements, not walls, rooms, or a selected plan.',
        'Ideal roof planes have no thickness, framing, overhang, roof-to-wall intersection, ceiling build-down, or absolute eave/floor datum.',
        'Relative roof-plane rise is not finished clear headroom, a bedroom suitability result, or an opening/EERO result.',
        'No code applicability, structural design/load, weathering, drainage, egress, accessibility, Revit placement, or IFC output is evaluated.'
    )
    room_cases = @($rows)
}
$out = Resolve-RepoPath $OutputDirectory
if (-not (Test-Path -LiteralPath $out)) { New-Item -ItemType Directory -Path $out -Force | Out-Null }
$jsonPath = Join-Path $out 'm159-relative-gable-exposure.json'
$csvPath = Join-Path $out 'm159-room-gable-exposure.csv'
ConvertTo-Json -InputObject $report -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
Write-Output "M159 checks passed: $($checks.Count)/$($checks.Count); $($rows.Count) room/candidate/roof rows; JSON SHA256 $(Get-Sha256 $jsonPath); CSV SHA256 $(Get-Sha256 $csvPath)."
