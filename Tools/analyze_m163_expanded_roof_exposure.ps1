param(
    [string]$M163RunDirectory = '.local/revalidation/M163-expanded',
    [string]$M163AuditDirectory = 'Architecture/M163_Expanded_Upper_Suite_Search_2026-10-31',
    [string]$M158Directory = 'Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31',
    [string]$M83Directory = 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30',
    [string]$OutputDirectory = '.local/revalidation/M163-roof-exposure'
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
function Get-LengthBelowRise([double]$Start, [double]$End, [double]$Span, [double]$Ratio, [double]$Rise) {
    $distance = [Math]::Min($Span / 2.0, [Math]::Max(0.0, $Rise / $Ratio))
    $left = [Math]::Max(0.0, [Math]::Min($End, $distance) - [Math]::Max($Start, 0.0))
    $right = [Math]::Max(0.0, [Math]::Min($End, $Span) - [Math]::Max($Start, $Span - $distance))
    return ($left + $right)
}
function Get-MedianRise([double]$Start, [double]$End, [double]$Span, [double]$Ratio) {
    $samples = @( ([Math]::Min($Start, $Span - $Start) * $Ratio), ([Math]::Min($End, $Span - $End) * $Ratio) )
    $ridge = $Span / 2.0
    if ($Start -le $ridge -and $End -ge $ridge) { $samples += ($Span / 2.0) * $Ratio }
    $low = [double](($samples | Measure-Object -Minimum).Minimum)
    $high = [double](($samples | Measure-Object -Maximum).Maximum)
    for ($i = 0; $i -lt 80; $i++) {
        $mid = ($low + $high) / 2.0
        if ((Get-LengthBelowRise $Start $End $Span $Ratio $mid) -ge (($End - $Start) / 2.0)) { $high = $mid } else { $low = $mid }
    }
    return [Math]::Round((($low + $high) / 2.0), 9)
}
function Get-RoomCaseRows($Candidate, $Option, [double]$ShellWidth, [double]$ShellDepth, [string]$CandidateSet) {
    $axis = [string]$Option.ridge_axis
    $span = if ($axis -eq 'X') { $ShellDepth } elseif ($axis -eq 'Y') { $ShellWidth } else { throw "Unsupported ridge axis: $axis" }
    $ratio = [double]$Option.pitch_ratio
    foreach ($roomId in @('U-01','U-03','U-04')) {
        $room = $Candidate.rectangles.$roomId
        $start = if ($axis -eq 'X') { [double]$room.y_ft } else { [double]$room.x_ft }
        $width = if ($axis -eq 'X') { [double]$room.depth_ft } else { [double]$room.width_ft }
        $end = $start + $width
        if ([Math]::Abs($start) -le 0.00001) { $start = 0.0 }
        if ([Math]::Abs($end - $span) -le 0.00001) { $end = $span }
        $crossSlopeLength = $end - $start
        if ($start -lt -0.000001 -or $end -gt ($span + 0.000001) -or $width -le 0) { throw "Invalid roof cross-slope interval: $($Candidate.layout_key) / $roomId / $axis" }
        $edgeRises = @( ([Math]::Min($start, $span - $start) * $ratio), ([Math]::Min($end, $span - $end) * $ratio) )
        if ($start -le ($span / 2.0) -and $end -ge ($span / 2.0)) { $edgeRises += (($span / 2.0) * $ratio) }
        $minRise = [Math]::Round([double](($edgeRises | Measure-Object -Minimum).Minimum), 9)
        $medianRise = Get-MedianRise $start $end $span $ratio
        $below = Get-LengthBelowRise $start $end $span $ratio $medianRise
        $eaves = @()
        if ([Math]::Abs($start) -le 0.00001) { $eaves += if ($axis -eq 'X') { 'south' } else { 'west' } }
        if ([Math]::Abs($end - $span) -le 0.00001) { $eaves += if ($axis -eq 'X') { 'north' } else { 'east' } }
        $fullAreaProxy = 5.0 - $minRise
        $halfAreaProxy = 7.0 - $medianRise
        $combined = [Math]::Max($fullAreaProxy, $halfAreaProxy)
        [pscustomobject][ordered]@{
            candidate_set = $CandidateSet
            candidate_key = [string]$Candidate.layout_key
            roof_case_id = [string]$Option.case_id
            pitch = "$($Option.pitch_rise_units):$($Option.pitch_run_units)"
            ridge_axis = $axis
            room_id = $roomId
            x_ft = [Math]::Round([double]$room.x_ft, 6)
            y_ft = [Math]::Round([double]$room.y_ft, 6)
            width_ft = [Math]::Round([double]$room.width_ft, 6)
            depth_ft = [Math]::Round([double]$room.depth_ft, 6)
            cross_slope_start_ft = [Math]::Round($start, 6)
            cross_slope_end_ft = [Math]::Round($end, 6)
            touched_ideal_eave_edges = ($eaves -join ';')
            minimum_ideal_rise_ft = $minRise
            median_ideal_rise_ft = $medianRise
            median_area_bisection_error_ft = [Math]::Abs($below - ($crossSlopeLength / 2.0))
            conditional_full_block_at_5ft_threshold_ft = [Math]::Round($fullAreaProxy, 9)
            conditional_half_block_at_7ft_threshold_ft = [Math]::Round($halfAreaProxy, 9)
            conditional_effective_eave_ceiling_threshold_ft = [Math]::Round($combined, 9)
            conditional_absolute_relation = 'z_eave - z_finished_floor >= conditional threshold + b_eave'
        }
    }
}

$run = Resolve-RepoPath $M163RunDirectory
$m163AuditPath = Join-Path (Resolve-RepoPath $M163AuditDirectory) 'm163-expanded-joint-perimeter-audit.json'
$m158 = Resolve-RepoPath $M158Directory
$m83 = Resolve-RepoPath $M83Directory
$paths = [ordered]@{
    m163_search = Join-Path $run 'search.json'
    m163_manifest = Join-Path $run 'manifest.json'
    m163_archive = Join-Path $run 'all-route-tested-candidates.json'
    m163_audit = $m163AuditPath
    m158_search = Join-Path $m158 'search.json'
    m158_manifest = Join-Path $m158 'manifest.json'
    m158_archive = Join-Path $m158 'all-route-tested-candidates.json'
    m158_audit = Join-Path $m158 'm158-joint-perimeter-audit.json'
    m83_roof_options = Join-Path $m83 'roof-options.json'
    selected_d = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
}
foreach ($path in $paths.Values) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required M163 roof input missing: $path" } }
$hashes = [ordered]@{}
foreach ($key in $paths.Keys) { $hashes[$key] = Get-Sha256 $paths[$key] }
$search = Get-Content $paths.m163_search -Raw | ConvertFrom-Json
$manifest = Get-Content $paths.m163_manifest -Raw | ConvertFrom-Json
$archive = Get-Content $paths.m163_archive -Raw | ConvertFrom-Json
$audit = Get-Content $paths.m163_audit -Raw | ConvertFrom-Json
$baseSearch = Get-Content $paths.m158_search -Raw | ConvertFrom-Json
$baseManifest = Get-Content $paths.m158_manifest -Raw | ConvertFrom-Json
$baseArchive = Get-Content $paths.m158_archive -Raw | ConvertFrom-Json
$baseAudit = Get-Content $paths.m158_audit -Raw | ConvertFrom-Json
$roof = Get-Content $paths.m83_roof_options -Raw | ConvertFrom-Json
$checks = [ordered]@{}
$checks.m163_m37_and_archive_match_manifest = ($hashes.m163_search -eq $manifest.output_hashes_sha256.search -and $hashes.m163_archive -eq $manifest.optional_route_tested_candidate_archive.sha256 -and @($archive.candidates).Count -eq [int]$manifest.optional_route_tested_candidate_archive.candidate_count)
$checks.m163_independent_audit_is_current = ($audit.milestone -eq 'M163' -and @($audit.failures).Count -eq 0 -and $audit.hashes_sha256.search -eq $hashes.m163_search -and $audit.hashes_sha256.archive -eq $hashes.m163_archive)
$checks.m158_baseline_and_audit_are_intact = ($hashes.m158_search -eq $baseManifest.output_hashes_sha256.search -and $hashes.m158_archive -eq $baseManifest.optional_route_tested_candidate_archive.sha256 -and $baseAudit.milestone -eq 'M158' -and @($baseAudit.failures).Count -eq 0 -and $baseAudit.hashes_sha256.search -eq $hashes.m158_search -and $baseAudit.hashes_sha256.archive -eq $hashes.m158_archive)
$checks.unique_m163_layout_keys = (@($archive.candidates.layout_key | Sort-Object -Unique).Count -eq @($archive.candidates).Count)
$checks.six_m83_roof_cases_share_owner_test_shell_and_remain_unselected = (@($roof.results).Count -eq 6 -and $roof.status -match 'no pitch' -and @($roof.results | Where-Object { $_.selection_status -notmatch 'not owner-selected' }).Count -eq 0 -and [Math]::Abs([double]$roof.coordinate_basis.shell_width_ft - [double]$search.coordinate_basis.width_ft) -le 0.000001 -and [Math]::Abs([double]$roof.coordinate_basis.shell_depth_ft - [double]$search.coordinate_basis.depth_ft) -le 0.000001)
$checks.m163_search_is_still_bounded_and_incomplete = ([bool]$search.search.node_limit_reached -and -not [bool]$search.search.search_complete -and [int]$search.search.nodes_expanded -le [int]$manifest.search_parameters.node_limit)
$checks.selected_d_source_matches_roof_case_source = ($hashes.selected_d -eq [string]$roof.source_fingerprints_sha256.selected_d_study)
$routeKeys = @($audit.candidates | Where-Object all_public_and_private_only | ForEach-Object layout_key)
$routeCandidates = @($archive.candidates | Where-Object { $_.layout_key -in $routeKeys })
$checks.route_qualified_archive_matches_audit = ($routeCandidates.Count -eq $routeKeys.Count -and $routeCandidates.Count -eq [int]$audit.full_public_and_private_only_count -and $routeCandidates.Count -gt 0)
$baseRouteKeys = @($baseAudit.candidates | Where-Object all_public_and_private_only | ForEach-Object layout_key)
$baseRouteCandidates = @($baseArchive.candidates | Where-Object { $_.layout_key -in $baseRouteKeys })
$checks.m158_route_comparator_is_present = ($baseRouteCandidates.Count -ge 1 -and $baseRouteCandidates.Count -eq $baseRouteKeys.Count)
$rows = [System.Collections.Generic.List[object]]::new()
foreach ($candidate in $routeCandidates) { foreach ($option in $roof.results) { foreach ($row in (Get-RoomCaseRows $candidate $option ([double]$roof.coordinate_basis.shell_width_ft) ([double]$roof.coordinate_basis.shell_depth_ft) 'M163 expanded route-qualified')) { $rows.Add($row) } } }
foreach ($candidate in $baseRouteCandidates) { foreach ($option in $roof.results) { foreach ($row in (Get-RoomCaseRows $candidate $option ([double]$roof.coordinate_basis.shell_width_ft) ([double]$roof.coordinate_basis.shell_depth_ft) 'M158 retained route-qualified')) { $rows.Add($row) } } }
$checks.expected_row_count = ($rows.Count -eq (($routeCandidates.Count + $baseRouteCandidates.Count) * 6 * 3))
$checks.median_bisection_splits_each_room_area = (@($rows | Where-Object { $_.median_area_bisection_error_ft -gt 0.00001 }).Count -eq 0)
$checks.no_absolute_datum_or_threshold_pass_fail = (@($rows | Where-Object { $_.conditional_absolute_relation -ne 'z_eave - z_finished_floor >= conditional threshold + b_eave' -or [double]::IsNaN([double]$_.conditional_effective_eave_ceiling_threshold_ft) }).Count -eq 0 -and $roof.coordinate_basis.absolute_eave_elevation -match 'unassigned')
$failures = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failures.Count -gt 0) { throw "M163 roof exposure checks failed: $($failures -join ', ')" }
$summaries = @()
foreach ($option in $roof.results) {
    $scores = @()
    foreach ($candidate in $routeCandidates) {
        $caseRows = @($rows | Where-Object { $_.candidate_set -eq 'M163 expanded route-qualified' -and $_.candidate_key -eq $candidate.layout_key -and $_.roof_case_id -eq $option.case_id })
        $scores += [pscustomobject]@{ candidate_key = [string]$candidate.layout_key; worst_bedroom_proxy_threshold_ft = [double](($caseRows | Measure-Object conditional_effective_eave_ceiling_threshold_ft -Maximum).Maximum) }
    }
    $best = $scores | Sort-Object worst_bedroom_proxy_threshold_ft,candidate_key | Select-Object -First 1
    $baseRows = @($rows | Where-Object { $_.candidate_set -eq 'M158 retained route-qualified' -and $_.roof_case_id -eq $option.case_id })
    $baseWorst = [double](($baseRows | Measure-Object conditional_effective_eave_ceiling_threshold_ft -Maximum).Maximum)
    $summaries += [pscustomobject][ordered]@{
        roof_case_id = [string]$option.case_id
        pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
        ridge_axis = [string]$option.ridge_axis
        route_qualified_expanded_candidate_count = $routeCandidates.Count
        best_expanded_worst_bedroom_proxy_threshold_ft = [double]$best.worst_bedroom_proxy_threshold_ft
        one_best_expanded_candidate_key = [string]$best.candidate_key
        retained_m158_worst_bedroom_proxy_threshold_ft = $baseWorst
        relative_threshold_delta_ft_lower_is_less = [Math]::Round(([double]$best.worst_bedroom_proxy_threshold_ft - $baseWorst), 9)
        selection_status = 'comparison only; no roof, layout, eave, floor datum, room classification, or code result selected'
    }
}
$report = [ordered]@{
    milestone = 'M163'
    title = 'Conditional ideal-gable exposure sensitivity for expanded route-qualified room blocks'
    status = 'relative geometry only; no room layout, roof, floor/eave datum, ceiling build-down, classification or code result selected'
    method = 'For each bedroom-capable room block, evaluate minimum and area-median ideal zero-thickness roof-plane rise over the cross-slope interval. Assuming the entire modeled rectangle is required floor area, report max(5 ft - minimum rise, 7 ft - median rise) as a conditional effective eave-ceiling threshold; absolute datum and build-down remain symbolic.'
    route_qualified_expanded_candidate_count = $routeCandidates.Count
    retained_m158_route_qualified_candidate_count = $baseRouteCandidates.Count
    search_nodes_expanded = [int]$search.search.nodes_expanded
    search_node_limit = [int]$manifest.search_parameters.node_limit
    search_node_limit_reached = [bool]$search.search.node_limit_reached
    search_complete = [bool]$search.search.search_complete
    roof_case_count = @($roof.results).Count
    room_case_row_count = $rows.Count
    source_hashes_sha256 = $hashes
    checks = $checks
    failures = $failures
    summaries_by_roof_case = $summaries
    results = @($rows)
    limitations = @(
        'M163 candidates are bounded room-block layouts in the hypothetical owner-authorized shell, not selected rooms, walls, or a house plan.',
        'The full schematic rectangle is only a required-floor-area proxy; formal room classification, applicable legal floor area, municipality, permit cycle and applicable code are unresolved.',
        'Ideal planes omit structure, roof thickness, ceiling build-down variation, walls, offsets, dormers, openings and construction details.',
        'No absolute floor/eave datum is known; no threshold is evaluated as pass or fail. A lower relative threshold is not a compliance or fit finding.',
        'This is not code compliance, headroom survey, EERO, accessibility, structural design, permit, Revit placement or IFC evidence.'
    )
}
$output = Resolve-RepoPath $OutputDirectory
if (-not (Test-Path -LiteralPath $output)) { New-Item -ItemType Directory -Path $output -Force | Out-Null }
$json = Join-Path $output 'm163-expanded-roof-exposure.json'
$csv = Join-Path $output 'm163-expanded-roof-exposure.csv'
ConvertTo-Json -InputObject $report -Depth 14 | Set-Content -LiteralPath $json -Encoding utf8
$rows | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
Write-Output "M163 roof checks passed: $($checks.Count)/$($checks.Count); expanded route-qualified candidates=$($routeCandidates.Count); rows=$($rows.Count); JSON SHA256 $(Get-Sha256 $json); CSV SHA256 $(Get-Sha256 $csv)."
