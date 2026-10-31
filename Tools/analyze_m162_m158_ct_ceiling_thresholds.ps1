param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M162_M158_CT_Sloped_Ceiling_Thresholds_2026-10-31')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Format-Number([double]$Value) { $Value.ToString('0.######', [Globalization.CultureInfo]::InvariantCulture) }

$m158Directory = Join-Path $repo 'Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31'
$m83Directory = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
$m158SearchPath = Join-Path $m158Directory 'search.json'
$m158ManifestPath = Join-Path $m158Directory 'manifest.json'
$m158ArchivePath = Join-Path $m158Directory 'all-route-tested-candidates.json'
$m158AuditPath = Join-Path $m158Directory 'm158-joint-perimeter-audit.json'
$roofPath = Join-Path $m83Directory 'roof-options.json'
$m159Path = Join-Path $repo 'Architecture/M159_M158_Gable_Exposure_2026-10-31/m159-relative-gable-exposure.json'
$ctNotePath = Join-Path $repo 'Research/Connecticut_Roof_Code_Research_2026-10-28.md'
$roomProgramPath = Join-Path $repo 'Requirements/Room_Program.md'
$selectedDPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$inputs = [ordered]@{
    m158_search = $m158SearchPath
    m158_manifest = $m158ManifestPath
    m158_archive = $m158ArchivePath
    m158_audit = $m158AuditPath
    m83_roof_options = $roofPath
    m159_roof_exposure = $m159Path
    ct_code_research_note = $ctNotePath
    room_program = $roomProgramPath
    selected_d_study = $selectedDPath
}
foreach ($path in $inputs.Values) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required M162 input missing: $path" }
}
$sourceHashes = [ordered]@{}
foreach ($key in $inputs.Keys) { $sourceHashes[$key] = Get-Sha256 $inputs[$key] }

$search = Get-Content -LiteralPath $m158SearchPath -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $m158ManifestPath -Raw | ConvertFrom-Json
$archive = Get-Content -LiteralPath $m158ArchivePath -Raw | ConvertFrom-Json
$audit = Get-Content -LiteralPath $m158AuditPath -Raw | ConvertFrom-Json
$roof = Get-Content -LiteralPath $roofPath -Raw | ConvertFrom-Json
$m159 = Get-Content -LiteralPath $m159Path -Raw | ConvertFrom-Json
$selected = Get-Content -LiteralPath $selectedDPath -Raw | ConvertFrom-Json
$ctText = Get-Content -LiteralPath $ctNotePath -Raw

$candidates = @($archive.candidates)
$roofCases = @($roof.results)
$roomIds = @('U-01','U-02','U-03','U-04')
$roomProgramUses = @{
    'U-01' = 'Primary bedroom'
    'U-02' = 'Boutique / walk-in; not counted as a legal bedroom in the room program'
    'U-03' = 'Hybrid bedroom / office; bedroom status unverified in the room program'
    'U-04' = 'Guest / third bedroom'
}
$checks = [ordered]@{}
$checks.m158_search_matches_manifest = ($sourceHashes.m158_search -eq [string]$manifest.output_hashes_sha256.search)
$checks.m158_archive_matches_manifest = (
    $sourceHashes.m158_archive -eq [string]$manifest.optional_route_tested_candidate_archive.sha256 -and
    $candidates.Count -eq [int]$manifest.optional_route_tested_candidate_archive.candidate_count
)
$checks.m158_audit_is_current_and_clean = (
    $audit.milestone -eq 'M158' -and @($audit.failures).Count -eq 0 -and
    @($audit.candidates).Count -eq $candidates.Count -and
    $audit.hashes_sha256.search -eq $sourceHashes.m158_search -and
    $audit.hashes_sha256.archive -eq $sourceHashes.m158_archive
)
$checks.m159_binds_current_m158_and_m83 = (
    $m159.milestone -eq 'M159' -and @($m159.failures).Count -eq 0 -and $m159.room_case_count -eq 84 -and
    $m159.sources_sha256.search -eq $sourceHashes.m158_search -and
    $m159.sources_sha256.archive -eq $sourceHashes.m158_archive -and
    $m159.sources_sha256.audit -eq $sourceHashes.m158_audit -and
    $m159.sources_sha256.roof_options -eq $sourceHashes.m83_roof_options -and
    $m159.sources_sha256.selected_d -eq $sourceHashes.selected_d_study
)
$checks.roof_case_set_is_six_unselected_options = ($roofCases.Count -eq 6 -and $roof.status -match 'no pitch')
$checks.shell_basis_matches_m158 = (
    [Math]::Abs([double]$roof.coordinate_basis.shell_width_ft - [double]$search.coordinate_basis.width_ft) -le 0.000001 -and
    [Math]::Abs([double]$roof.coordinate_basis.shell_depth_ft - [double]$search.coordinate_basis.depth_ft) -le 0.000001 -and
    $roof.coordinate_basis.absolute_eave_elevation -match 'unassigned'
)
$checks.selected_d_source_is_current = ($sourceHashes.selected_d_study -eq [string]$roof.source_fingerprints_sha256.selected_d_study)
$checks.code_note_cites_conditional_ct_r305_1 = ($ctText -match '2022 CSBC' -and $ctText -match 'R305\.1' -and $ctText -match '5.?ft' -and $ctText -match '7.?ft')
$checks.two_candidates_and_four_rooms_are_present = (
    $candidates.Count -eq 2 -and
    @($candidates | Where-Object { @($_.rectangles.PSObject.Properties.Name | Where-Object { $_ -in $roomIds }).Count -ne 4 }).Count -eq 0
)
$checks.room_program_use_map_is_complete = (@($roomIds | Where-Object { -not $roomProgramUses.ContainsKey($_) }).Count -eq 0)

if ($candidates.Count -ne 2 -or $roofCases.Count -ne 6) { throw 'M162 requires exactly two M158 candidates and six M83 roof options.' }
$bedroomRoomsIdentical = $true
foreach ($id in $roomIds) {
    foreach ($field in @('x_ft','y_ft','width_ft','depth_ft')) {
        if ([Math]::Abs([double]$candidates[0].rectangles.$id.$field - [double]$candidates[1].rectangles.$id.$field) -gt 0.000001) { $bedroomRoomsIdentical = $false }
    }
}
$checks.upper_room_blocks_match_across_candidates = $bedroomRoomsIdentical

function Get-Rise([double]$position, [double]$span, [double]$ratio) {
    [Math]::Min($position, $span - $position) * $ratio
}

function Get-LengthBelowRise([double]$start, [double]$end, [double]$span, [double]$ratio, [double]$rise) {
    $distance = [Math]::Min($span / 2.0, [Math]::Max(0.0, $rise / $ratio))
    $leftLength = [Math]::Max(0.0, [Math]::Min($end, $distance) - [Math]::Max($start, 0.0))
    $rightLength = [Math]::Max(0.0, [Math]::Min($end, $span) - [Math]::Max($start, $span - $distance))
    return ($leftLength + $rightLength)
}

function Get-MedianRise([double]$start, [double]$end, [double]$span, [double]$ratio) {
    $samples = @((Get-Rise $start $span $ratio), (Get-Rise $end $span $ratio))
    $ridge = $span / 2.0
    if ($start -le $ridge -and $end -ge $ridge) { $samples += (Get-Rise $ridge $span $ratio) }
    $low = [double](($samples | Measure-Object -Minimum).Minimum)
    $high = [double](($samples | Measure-Object -Maximum).Maximum)
    for ($i = 0; $i -lt 80; $i++) {
        $mid = ($low + $high) / 2.0
        if ((Get-LengthBelowRise $start $end $span $ratio $mid) -ge (($end - $start) / 2.0)) { $high = $mid } else { $low = $mid }
    }
    return (($low + $high) / 2.0)
}

$rows = [System.Collections.Generic.List[object]]::new()
foreach ($candidateIndex in 0..($candidates.Count - 1)) {
    $candidate = $candidates[$candidateIndex]
    foreach ($option in $roofCases) {
        $axis = [string]$option.ridge_axis
        $span = if ($axis -eq 'X') { [double]$roof.coordinate_basis.shell_depth_ft } elseif ($axis -eq 'Y') { [double]$roof.coordinate_basis.shell_width_ft } else { throw "Unsupported ridge axis: $axis" }
        $ratio = [double]$option.pitch_ratio
        foreach ($roomId in $roomIds) {
            $room = $candidate.rectangles.$roomId
            $start = if ($axis -eq 'X') { [double]$room.y_ft } else { [double]$room.x_ft }
            $width = if ($axis -eq 'X') { [double]$room.depth_ft } else { [double]$room.width_ft }
            $end = $start + $width
            if ($start -lt -0.000001 -or $end -gt ($span + 0.000001) -or $width -le 0) { throw "Invalid cross-slope interval for $roomId / $axis." }
            $points = @((Get-Rise $start $span $ratio), (Get-Rise $end $span $ratio))
            if ($start -le ($span / 2.0) -and $end -ge ($span / 2.0)) { $points += (Get-Rise ($span / 2.0) $span $ratio) }
            $minRise = [double](($points | Measure-Object -Minimum).Minimum)
            $maxRise = [double](($points | Measure-Object -Maximum).Maximum)
            $medianRaw = Get-MedianRise $start $end $span $ratio
            $medianRise = [Math]::Round($medianRaw, 9)
            $medianBelow = Get-LengthBelowRise $start $end $span $ratio $medianRise
            $medianAbove = $width - $medianBelow
            $threshold5 = 5.0 - $minRise
            $threshold7 = 7.0 - $medianRise
            $combined = [Math]::Max($threshold5, $threshold7)
            $area = $width * $(if ($axis -eq 'X') { [double]$room.width_ft } else { [double]$room.depth_ft })
            $rows.Add([pscustomobject][ordered]@{
                candidate_index = $candidateIndex + 1
                candidate_key = [string]$candidate.layout_key
                room_id = $roomId
                room_program_use = $roomProgramUses[$roomId]
                room_block_area_sf = [Math]::Round($area, 6)
                roof_case_id = [string]$option.case_id
                pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
                ridge_axis = $axis
                cross_slope_start_ft = [Math]::Round($start, 6)
                cross_slope_end_ft = [Math]::Round($end, 6)
                minimum_ideal_rise_ft = [Math]::Round($minRise, 6)
                median_ideal_rise_ft = [Math]::Round($medianRise, 6)
                maximum_ideal_rise_ft = [Math]::Round($maxRise, 6)
                median_below_area_fraction = [Math]::Round($medianBelow / $width, 9)
                median_at_or_above_area_fraction = [Math]::Round($medianAbove / $width, 9)
                full_block_at_5ft_eave_threshold_ft = [Math]::Round($threshold5, 6)
                half_block_at_7ft_eave_threshold_ft = [Math]::Round($threshold7, 6)
                combined_effective_eave_ceiling_threshold_ft = [Math]::Round($combined, 6)
                effective_ceiling_formula = '(z_eave - z_finished_floor) - b_eave'
                conditional_floor_to_eave_relation = "z_eave - z_finished_floor >= $(Format-Number $combined) ft + b_eave"
                entire_rectangle_assumed_as_required_floor_area_proxy = $true
                threshold_condition_evaluated = $false
                code_classification_determined = $false
                code_applicability_determined = $false
                roof_selected = $false
            })
            if ([Math]::Abs($medianBelow - ($width / 2.0)) -gt 0.0001 -or [Math]::Abs($medianAbove - ($width / 2.0)) -gt 0.0001) { throw "Median does not bisect rectangle area for $roomId / $($option.case_id)." }
        }
    }
}

$checks.room_roof_result_count_is_48 = ($rows.Count -eq 2 * 6 * 4)
$checks.unique_candidate_room_roof_keys = (@($rows | Select-Object -ExpandProperty candidate_index -Unique).Count -eq 2 -and @($rows | Select-Object -ExpandProperty roof_case_id -Unique).Count -eq 6 -and @($rows | Select-Object -ExpandProperty room_id -Unique).Count -eq 4)
$checks.median_rise_is_bounded_by_minimum_and_maximum = (@($rows | Where-Object { $_.median_ideal_rise_ft -lt ($_.minimum_ideal_rise_ft - 0.000001) -or $_.median_ideal_rise_ft -gt ($_.maximum_ideal_rise_ft + 0.000001) }).Count -eq 0)
$checks.thresholds_reconstruct_from_ideal_rise = (@($rows | Where-Object {
    [Math]::Abs($_.full_block_at_5ft_eave_threshold_ft - (5.0 - $_.minimum_ideal_rise_ft)) -gt 0.00001 -or
    [Math]::Abs($_.half_block_at_7ft_eave_threshold_ft - (7.0 - $_.median_ideal_rise_ft)) -gt 0.00001 -or
    [Math]::Abs($_.combined_effective_eave_ceiling_threshold_ft - [Math]::Max($_.full_block_at_5ft_eave_threshold_ft, $_.half_block_at_7ft_eave_threshold_ft)) -gt 0.00001
}).Count -eq 0)
$checks.no_datum_or_code_pass_fail_was_assigned = (@($rows | Where-Object { $_.threshold_condition_evaluated -or $_.code_classification_determined -or $_.code_applicability_determined -or $_.roof_selected }).Count -eq 0)
$failures = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failures.Count -gt 0) { throw "M162 source or geometry checks failed: $($failures -join ', ')" }

$report = [ordered]@{
    milestone = 'M162'
    title = 'Conditional Connecticut sloped-ceiling threshold relations for M158 room blocks'
    status = 'symbolic geometric sensitivity only; no roof, floor/eave datum, ceiling build-down, room classification, or compliance result selected'
    code_reference = [ordered]@{
        basis = '2022 Connecticut State Building Code amendments to 2021 IRC R305.1; applicability depends on site, permit cycle, use classification and required-floor-area interpretation'
        official_code_pdf = 'https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf'
        official_adoption_page = 'https://portal.ct.gov/das/knowledge-base/articles/ctbuys/safety-codes-and-inspections/connecticut-state-building-codes-adoption-process'
        generic_bands_ft = [ordered]@{ full_modeled_block_minimum = 5.0; at_least_half_modeled_block = 7.0 }
        research_note_sha256 = $sourceHashes.ct_code_research_note
    }
    method = 'For each rectangular M158 block, compute ideal zero-thickness gable rise across its cross-slope interval. The median is solved by bisection on the uniform rectangle-area distribution. Assuming the entire modeled block represents required floor area, the symbolic effective eave ceiling threshold is max(5 ft - minimum rise, 7 ft - median rise).'
    unknowns = [ordered]@{
        z_eave = 'unknown geometric eave elevation'
        z_finished_floor = 'unknown finished-floor elevation'
        b_eave = 'unknown roof/eave-to-finished-ceiling build-down; one scalar used only symbolically'
        effective_finished_eave_ceiling = '(z_eave - z_finished_floor) - b_eave'
    }
    candidates = $candidates.Count
    room_roof_rows = $rows.Count
    source_hashes_sha256 = $sourceHashes
    checks = $checks
    failures = $failures
    limitations = @(
        'The M158 candidates are incomplete room-block arrangements in a hypothetical 38 1/3 x 40 ft exploration shell, not rooms, walls, or a selected plan.',
        'The full schematic rectangle is a proxy for required floor area; the applicable legal area and room classification are unresolved.',
        'Ideal planes omit roof framing, thickness, ceiling build-down variation, walls, eave offsets, dormers, openings, and structure.',
        'No absolute floor/eave datum is known, so no threshold condition is evaluated and no roof option passes or fails.',
        'This is not code compliance, structural design, EERO, accessibility, permit, Revit placement, or IFC evidence.'
    )
    results = @($rows)
}

$resolvedOutput = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$repoPrefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutput.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $resolvedOutput)) { New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null }
$jsonPath = Join-Path $resolvedOutput 'ct-sloped-ceiling-thresholds.json'
$csvPath = Join-Path $resolvedOutput 'ct-sloped-ceiling-thresholds.csv'
ConvertTo-Json -InputObject $report -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
Write-Output "M162 checks passed: $($checks.Count)/$($checks.Count); $($rows.Count) room/candidate/roof rows; JSON SHA256 $(Get-Sha256 $jsonPath); CSV SHA256 $(Get-Sha256 $csvPath)."
