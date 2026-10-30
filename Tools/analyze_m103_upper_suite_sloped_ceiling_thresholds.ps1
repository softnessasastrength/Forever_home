param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M103_Upper_Suite_Sloped_Ceiling_Thresholds_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m78Directory = Join-Path $repo 'Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29'
$m83Directory = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
$searchPath = Join-Path $m78Directory 'search.json'
$m78ManifestPath = Join-Path $m78Directory 'manifest.json'
$roofPath = Join-Path $m83Directory 'roof-options.json'
$codeNotePath = Join-Path $repo 'Research/Connecticut_Roof_Code_Research_2026-10-28.md'
$roomProgramPath = Join-Path $repo 'Requirements/Room_Program.md'
$selectedDPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-RoofRise([double]$Coordinate, [double]$Span, [double]$PitchRatio) {
    [Math]::Max(0.0, [Math]::Min($Coordinate, $Span - $Coordinate)) * $PitchRatio
}

function Round-UpSix([double]$Value) {
    [Math]::Ceiling(($Value - 0.0000000001) * 1000000.0) / 1000000.0
}

function Get-RiseMedian([double]$Start, [double]$End, [double]$Span, [double]$PitchRatio) {
    $low = 0.0
    $high = (Get-RoofRise ([Math]::Min($End, $Span / 2.0)) $Span $PitchRatio)
    $high = [Math]::Max($high, (Get-RoofRise ([Math]::Max($Start, $Span / 2.0)) $Span $PitchRatio))
    for ($iteration = 0; $iteration -lt 60; $iteration++) {
        $candidate = ($low + $high) / 2.0
        $inset = $candidate / $PitchRatio
        $aboveStart = [Math]::Max($Start, $inset)
        $aboveEnd = [Math]::Min($End, $Span - $inset)
        $aboveLength = [Math]::Max(0.0, $aboveEnd - $aboveStart)
        if (($aboveLength / ($End - $Start)) -ge 0.5) { $low = $candidate } else { $high = $candidate }
    }
    [Math]::Round(($low + $high) / 2.0, 6)
}

$search = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$m78Manifest = Get-Content -LiteralPath $m78ManifestPath -Raw | ConvertFrom-Json
$roof = Get-Content -LiteralPath $roofPath -Raw | ConvertFrom-Json
$sourceHashes = [ordered]@{
    m78_search = Get-Sha256 $searchPath
    m78_manifest = Get-Sha256 $m78ManifestPath
    m83_roof_options = Get-Sha256 $roofPath
    ct_code_research_note = Get-Sha256 $codeNotePath
    room_program = Get-Sha256 $roomProgramPath
    selected_d_study = Get-Sha256 $selectedDPath
}
if ($m78Manifest.output_hashes_sha256.search -ne $sourceHashes.m78_search) { throw 'M78 search hash does not match its manifest.' }
if ($roof.source_fingerprints_sha256.m78_search -ne $sourceHashes.m78_search -or
    $roof.source_fingerprints_sha256.m78_manifest -ne $sourceHashes.m78_manifest) { throw 'M83 options do not bind current M78 sources.' }
if ($roof.coordinate_basis.absolute_eave_elevation -notmatch 'unassigned') { throw 'M83 eave datum must remain unassigned.' }

$shellWidth = [double]$roof.coordinate_basis.shell_width_ft
$shellDepth = [double]$roof.coordinate_basis.shell_depth_ft
$rooms = $search.best_candidate.rectangles
$results = @()
$checks = [ordered]@{
    m78_search_manifest_identity = ($m78Manifest.output_hashes_sha256.search -eq $sourceHashes.m78_search)
    m83_inputs_match_current_m78 = ($roof.source_fingerprints_sha256.m78_search -eq $sourceHashes.m78_search -and $roof.source_fingerprints_sha256.m78_manifest -eq $sourceHashes.m78_manifest)
    m83_selected_d_source_matches_current = ($roof.source_fingerprints_sha256.selected_d_study -eq $sourceHashes.selected_d_study)
    shell_matches_m78_hypothetical_case = ([Math]::Abs([double]$search.coordinate_basis.width_ft - $shellWidth) -lt 0.000001 -and [Math]::Abs([double]$search.coordinate_basis.depth_ft - $shellDepth) -lt 0.000001)
    seven_source_room_blocks_present = (@($rooms.PSObject.Properties | ForEach-Object { $_ }).Count -eq 7)
    four_candidate_room_blocks_for_generic_sloped_room_math = (@($rooms.PSObject.Properties | Where-Object { $_.Value.id -in @('U-01','U-02','U-03','U-04') } | ForEach-Object { $_ }).Count -eq 4)
    six_unselected_roof_options_present = ($roof.results.Count -eq 6)
    no_eave_or_floor_datum_assumed = ($roof.coordinate_basis.absolute_eave_elevation -match 'unassigned')
    thresholds_satisfy_stated_geometry = $true
    all_results_labeled_as_noncompliance_screen = $true
}

foreach ($option in $roof.results) {
    $ratio = [double]$option.pitch_ratio
    $axis = [string]$option.ridge_axis
    $span = if ($axis -eq 'X') { $shellDepth } else { $shellWidth }
    $ridge = $span / 2.0
    foreach ($property in $rooms.PSObject.Properties) {
        $room = $property.Value
        if ([string]$room.id -notin @('U-01','U-02','U-03','U-04')) { continue }
        $start = if ($axis -eq 'X') { [double]$room.y_ft } else { [double]$room.x_ft }
        $length = if ($axis -eq 'X') { [double]$room.depth_ft } else { [double]$room.width_ft }
        $end = $start + $length
        if ($start -lt -0.000001 -or $end -gt ($span + 0.000001)) { throw "Room $($room.id) extends outside the ideal gable cross-section." }
        $minEndpointDistance = [Math]::Min([Math]::Abs($start - $ridge), [Math]::Abs($end - $ridge))
        $maxEndpointDistance = [Math]::Max([Math]::Abs($start - $ridge), [Math]::Abs($end - $ridge))
        $minRise = [Math]::Round(($span / 2.0 - $maxEndpointDistance) * $ratio, 6)
        $maxRise = if ($start -le $ridge -and $end -ge $ridge) { [Math]::Round(($span / 2.0) * $ratio, 6) } else { [Math]::Round(($span / 2.0 - $minEndpointDistance) * $ratio, 6) }
        $medianRise = Get-RiseMedian $start $end $span $ratio
        $effectiveEaveForFullBlock5Ft = Round-UpSix (5.0 - $minRise)
        $effectiveEaveForHalfBlock7Ft = Round-UpSix (7.0 - $medianRise)
        $requiredEffectiveEave = [Math]::Max($effectiveEaveForFullBlock5Ft, $effectiveEaveForHalfBlock7Ft)
        if (($requiredEffectiveEave + $minRise) -lt (5.0 - 0.00001) -or ($requiredEffectiveEave + $medianRise) -lt (7.0 - 0.00001)) { $checks.thresholds_satisfy_stated_geometry = $false }
        $row = [pscustomobject][ordered]@{
            roof_case_id = [string]$option.case_id
            pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
            ridge_axis = $axis
            room_id = [string]$room.id
            room_block_area_sf = [Math]::Round([double]$room.width_ft * [double]$room.depth_ft, 4)
            minimum_plane_rise_above_relative_eave_ft = $minRise
            median_plane_rise_above_relative_eave_ft = $medianRise
            maximum_plane_rise_above_relative_eave_ft = $maxRise
            effective_finished_ceiling_at_eave_for_full_block_at_5ft_ft = $effectiveEaveForFullBlock5Ft
            effective_finished_ceiling_at_eave_for_half_block_at_7ft_ft = $effectiveEaveForHalfBlock7Ft
            effective_finished_ceiling_at_eave_meeting_both_generic_thresholds_ft = $requiredEffectiveEave
            bathroom_fixture_zone_checked = $false
            code_applicability_determined = $false
        }
        $checks.all_results_labeled_as_noncompliance_screen = $checks.all_results_labeled_as_noncompliance_screen -and -not $row.code_applicability_determined -and -not $row.bathroom_fixture_zone_checked
        $results += $row
    }
}

if ($results.Count -ne 24) { throw "Expected 24 candidate-room/roof rows; produced $($results.Count)." }
$report = [ordered]@{
    milestone = 'M103'
    title = 'Parametric effective-eave thresholds for hypothetical upper-suite blocks'
    status = 'geometric threshold algebra only; not a code-compliance result'
    code_reference = [ordered]@{
        jurisdiction_research = 'Connecticut statewide preliminary research; applicable municipality, code cycle and classification unresolved'
        provision = '2022 Connecticut State Building Code, amended 2021 IRC R305.1, sloped-ceiling exception'
        generic_thresholds_ft = [ordered]@{ full_modeled_block_minimum = 5.0; at_least_half_modeled_block = 7.0 }
        caution = 'The code refers to required floor area, which may not equal these gross schematic room-block rectangles. Bathroom fixture-specific ceiling checks are not calculated.'
        source_note_sha256 = $sourceHashes.ct_code_research_note
        official_code_url = 'https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf?rev=a59cc11db0564caaa5477bd696ee85f2'
    }
    method = 'For candidate rooms U-01 through U-04 only, calculate the minimum and median ideal roof-plane rise above relative eave. Report the minimum finished-ceiling height at the eave datum that would make the entire modeled rectangle at least 5 ft and at least half its area at least 7 ft, if the generic sloped-room thresholds apply to that room. U-02 is included as geometry only because its room classification remains unresolved.'
    area_assumption = 'The complete M78 room-block rectangle is screened; this is a conservative geometric assumption, not a determination of legal required floor area. U-05/U-06 bathrooms are excluded pending fixture locations; C-PRIVATE is excluded because hallway/circulation applicability is not resolved here.'
    source_hashes_sha256 = $sourceHashes
    checks = $checks
    failures = @($checks.Keys | Where-Object { -not $checks[$_] })
    result_count = $results.Count
    results = @($results)
    limitations = @(
        'No effective eave height is assigned; each output is a required threshold, not an assumed design input.',
        'The ideal roof plane has zero thickness and omits framing, roof assembly, finish ceiling, wall/eave offsets, dormers and structure.',
        'The generic 5 ft/7 ft calculation does not establish room classification, legal required floor area, applicable code or compliance.',
        'U-02 room classification is unresolved. U-05/U-06 bathrooms need fixture locations and separate R305.1 fixture-use review; no bathroom or showerhead area is tested. C-PRIVATE circulation is also excluded.',
        '38.333333 x 40 ft remains an owner-authorized exploration case only. Selected-D and source room blocks are unchanged.'
    )
}
if ($report.failures.Count -gt 0) { throw "M103 failed checks: $($report.failures -join ', ')." }

$resolvedOutput = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$repoPrefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutput.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $resolvedOutput)) { New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null }
$jsonPath = Join-Path $resolvedOutput 'effective-eave-thresholds.json'
$csvPath = Join-Path $resolvedOutput 'effective-eave-thresholds.csv'
ConvertTo-Json -InputObject $report -Depth 10 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
Write-Output "M103 threshold checks passed: $($checks.Count)/$($checks.Count); $($results.Count) rows; JSON SHA256 $((Get-Sha256 $jsonPath)); CSV SHA256 $((Get-Sha256 $csvPath))."
