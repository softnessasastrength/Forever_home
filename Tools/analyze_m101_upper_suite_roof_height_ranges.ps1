param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M101_Upper_Suite_Roof_Height_Ranges_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m78Directory = Join-Path $repo 'Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29'
$m83Directory = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
$searchPath = Join-Path $m78Directory 'search.json'
$m78ManifestPath = Join-Path $m78Directory 'manifest.json'
$roofPath = Join-Path $m83Directory 'roof-options.json'

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

$search = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$m78Manifest = Get-Content -LiteralPath $m78ManifestPath -Raw | ConvertFrom-Json
$roof = Get-Content -LiteralPath $roofPath -Raw | ConvertFrom-Json
$searchHash = Get-Sha256 $searchPath
$manifestHash = Get-Sha256 $m78ManifestPath
$roofHash = Get-Sha256 $roofPath

if ($m78Manifest.output_hashes_sha256.search -ne $searchHash) { throw 'M78 search hash does not match its manifest.' }
if ($roof.source_fingerprints_sha256.m78_search -ne $searchHash -or
    $roof.source_fingerprints_sha256.m78_manifest -ne $manifestHash) { throw 'M83 roof options do not bind the current M78 sources.' }
if ($roof.coordinate_basis.shell_status -notmatch 'hypothetical' -or
    $roof.coordinate_basis.absolute_eave_elevation -notmatch 'unassigned') { throw 'Expected an explicitly hypothetical shell and unassigned eave datum.' }

$shellWidth = [double]$roof.coordinate_basis.shell_width_ft
$shellDepth = [double]$roof.coordinate_basis.shell_depth_ft
$rooms = $search.best_candidate.rectangles
$results = @()
$checks = [ordered]@{
    m78_search_hash_matches_manifest = $true
    m83_roof_options_bind_m78_search_and_manifest = $true
    shell_dimensions_match_m78_search = ([Math]::Abs([double]$search.coordinate_basis.width_ft - $shellWidth) -lt 0.000001 -and [Math]::Abs([double]$search.coordinate_basis.depth_ft - $shellDepth) -lt 0.000001)
    eave_datum_remains_unassigned = $true
    room_blocks_are_present = (@($rooms.PSObject.Properties | ForEach-Object { $_ }).Count -eq 7)
    all_six_unselected_roof_cases_are_present = ($roof.results.Count -eq 6)
    selected_d_hash_matches_m83_source = ((Get-Sha256 (Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json')) -eq $roof.source_fingerprints_sha256.selected_d_study)
    every_room_range_is_nonnegative_and_ordered = $true
    relative_height_scales_with_pitch = $true
}

foreach ($option in $roof.results) {
    $ratio = [double]$option.pitch_ratio
    $ridgeAxis = [string]$option.ridge_axis
    $span = if ($ridgeAxis -eq 'X') { $shellDepth } elseif ($ridgeAxis -eq 'Y') { $shellWidth } else { throw "Unsupported ridge axis: $ridgeAxis" }
    $ridge = $span / 2.0
    foreach ($property in $rooms.PSObject.Properties) {
        $room = $property.Value
        $start = if ($ridgeAxis -eq 'X') { [double]$room.y_ft } else { [double]$room.x_ft }
        $length = if ($ridgeAxis -eq 'X') { [double]$room.depth_ft } else { [double]$room.width_ft }
        $end = $start + $length
        if ($start -lt -0.000001 -or $end -gt ($span + 0.000001)) { throw "Room $($room.id) crosses the test-shell roof section." }
        $fartherEndpoint = [Math]::Max([Math]::Abs($start - $ridge), [Math]::Abs($end - $ridge))
        $nearerEndpoint = [Math]::Min([Math]::Abs($start - $ridge), [Math]::Abs($end - $ridge))
        $containsRidge = ($start -le $ridge -and $end -ge $ridge)
        $minRise = [Math]::Round(($span / 2.0 - $fartherEndpoint) * $ratio, 6)
        $maxRise = if ($containsRidge) { [Math]::Round(($span / 2.0) * $ratio, 6) } else { [Math]::Round(($span / 2.0 - $nearerEndpoint) * $ratio, 6) }
        if ($minRise -lt -0.000001 -or $maxRise -lt $minRise) { $checks.every_room_range_is_nonnegative_and_ordered = $false }
        $results += [pscustomobject][ordered]@{
            roof_case_id = $option.case_id
            pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
            ridge_axis = $ridgeAxis
            room_id = [string]$room.id
            room_cross_slope_start_ft = [Math]::Round($start, 6)
            room_cross_slope_end_ft = [Math]::Round($end, 6)
            minimum_roof_rise_above_eave_over_room_block_ft = $minRise
            maximum_roof_rise_above_eave_over_room_block_ft = $maxRise
            eave_height_ft = $null
            clear_headroom_ft = $null
            interpretation = 'Ideal roof-plane height range above relative eave across schematic room block; not clear interior headroom.'
        }
    }
}

foreach ($axis in @('X','Y')) {
    foreach ($roomId in @($rooms.PSObject.Properties | ForEach-Object { $_.Value.id })) {
        $roomCases = @($results | Where-Object { $_.ridge_axis -eq $axis -and $_.room_id -eq $roomId })
        $ordered = @($roomCases | Sort-Object { [int]($_.pitch.Split(':')[0]) })
        for ($i = 1; $i -lt $ordered.Count; $i++) {
            if ([double]$ordered[$i].minimum_roof_rise_above_eave_over_room_block_ft -lt [double]$ordered[$i-1].minimum_roof_rise_above_eave_over_room_block_ft -or
                [double]$ordered[$i].maximum_roof_rise_above_eave_over_room_block_ft -lt [double]$ordered[$i-1].maximum_roof_rise_above_eave_over_room_block_ft) {
                $checks.relative_height_scales_with_pitch = $false
            }
        }
    }
}

$summaries = @()
foreach ($option in $roof.results) {
    $caseRows = @($results | Where-Object { $_.roof_case_id -eq $option.case_id })
    $lowest = $caseRows | Sort-Object { [double]$_.minimum_roof_rise_above_eave_over_room_block_ft } | Select-Object -First 1
    $lowestRooms = @($caseRows | Where-Object { [double]$_.minimum_roof_rise_above_eave_over_room_block_ft -eq [double]$lowest.minimum_roof_rise_above_eave_over_room_block_ft } | ForEach-Object { $_.room_id } | Sort-Object)
    $highest = $caseRows | Sort-Object { [double]$_.maximum_roof_rise_above_eave_over_room_block_ft } -Descending | Select-Object -First 1
    $summaries += [pscustomobject][ordered]@{
        roof_case_id = $option.case_id
        pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
        ridge_axis = [string]$option.ridge_axis
        lowest_room_ids = $lowestRooms
        lowest_room_minimum_rise_above_eave_ft = [double]$lowest.minimum_roof_rise_above_eave_over_room_block_ft
        highest_room_id = $highest.room_id
        highest_room_maximum_rise_above_eave_ft = [double]$highest.maximum_roof_rise_above_eave_over_room_block_ft
    }
}

$report = [ordered]@{
    milestone = 'M101'
    title = 'Upper-suite room-block relative roof-height ranges'
    status = 'hypothetical comparative screen; no pitch, ridge direction, eave datum, or room dimensions selected'
    shell = [ordered]@{ width_ft = $shellWidth; depth_ft = $shellDepth; source = 'owner-authorized M78 comparison case only' }
    method = 'For each M83 ideal gable plane, evaluate the roof-plane elevation above the eave at both cross-slope room-block edges and at the ridge if the block spans it. The reported range is relative and excludes roof thickness, framing, ceiling finish, floor elevation, walls and offsets.'
    sources_sha256 = [ordered]@{ m78_search = $searchHash; m78_manifest = $manifestHash; m83_roof_options = $roofHash; selected_d_study = $roof.source_fingerprints_sha256.selected_d_study }
    checks = $checks
    failures = @($checks.Keys | Where-Object { -not $checks[$_] })
    room_case_count = $results.Count
    roof_case_summaries = @($summaries)
    results = @($results)
    limitations = @(
        'This is mathematical comparison of ideal zero-thickness roof planes over schematic room blocks; it is not interior headroom or clear height.',
        'Absolute eave and floor datums, wall placement, roof build-up, framing depth, ceiling plane, dormers and openings are unassigned.',
        'No minimum headroom, code threshold, structural design, snow or wind load, drainage, egress, or construction detail is assessed.',
        'The 38.333333 x 40 ft envelope is a hypothetical comparison case, not an approved house dimension; selected-D is unchanged.'
    )
}
if ($report.failures.Count -gt 0 -or $results.Count -ne 42) { throw "M101 failed: $($report.failures -join ', '); result count $($results.Count)." }

$resolvedOutput = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$repoPrefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutput.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $resolvedOutput)) { New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null }

$jsonPath = Join-Path $resolvedOutput 'relative-roof-height-ranges.json'
$csvPath = Join-Path $resolvedOutput 'relative-roof-height-ranges.csv'
ConvertTo-Json -InputObject $report -Depth 10 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
Write-Output "M101 checks passed: $($checks.Count)/$($checks.Count); $($results.Count) room/roof cases; JSON SHA256 $((Get-Sha256 $jsonPath)); CSV SHA256 $((Get-Sha256 $csvPath))."
