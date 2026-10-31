param(
    [string]$OutputDirectory = 'Architecture/M130_Upper_Suite_Roof_Exposure_2026-10-30'
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m115Dir = Join-Path $repo 'Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30'
$m83Dir = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
$m115ArchivePath = Join-Path $m115Dir 'all-route-tested-candidates.json'
$m115AuditPath = Join-Path $m115Dir 'm115-audit.json'
$m83RoofPath = Join-Path $m83Dir 'roof-options.json'
$m83ManifestPath = Join-Path $m83Dir 'manifest.json'
$selectedPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath = Join-Path $repo 'Architecture/House_Design_Iteration_2026-10-28/study.json'

function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }

$archive = Get-Content -LiteralPath $m115ArchivePath -Raw | ConvertFrom-Json
$audit = Get-Content -LiteralPath $m115AuditPath -Raw | ConvertFrom-Json
$roof = Get-Content -LiteralPath $m83RoofPath -Raw | ConvertFrom-Json
$roofManifest = Get-Content -LiteralPath $m83ManifestPath -Raw | ConvertFrom-Json
$selected = Get-Content -LiteralPath $selectedPath -Raw | ConvertFrom-Json
$selectedHash = Get-Sha256 $selectedPath
$sourceHashes = [ordered]@{
    m115_archive = Get-Sha256 $m115ArchivePath
    m115_audit = Get-Sha256 $m115AuditPath
    m83_roof_options = Get-Sha256 $m83RoofPath
    m83_manifest = Get-Sha256 $m83ManifestPath
    selected_D = $selectedHash
    owner_proposal = Get-Sha256 $proposalPath
    analyzer = Get-Sha256 $PSCommandPath
}
$shellWidth = [double]$roof.coordinate_basis.shell_width_ft
$shellDepth = [double]$roof.coordinate_basis.shell_depth_ft
$tol = 0.000001

$privacyCandidates = @($archive.candidates | Where-Object {
    [Math]::Abs(([double]$_.rectangles.'U-03'.x_ft + [double]$_.rectangles.'U-03'.width_ft) - $shellWidth) -le $tol -and
    [Math]::Abs([double]$_.rectangles.'U-03'.y_ft) -le $tol -and
    $_.public_rooms_reached_count -eq 3 -and
    @($_.public_rooms_reached) -contains 'U-01' -and
    @($_.public_rooms_reached) -contains 'U-02' -and
    @($_.public_rooms_reached) -contains 'U-04' -and
    -not $_.hall_reachability.u03_hall_side_reachable -and
    [string]$_.hall_reachability.reachable_room_sides.'U-02' -match 'north'
})

$checks = [ordered]@{
    m115_archive_hash_matches_audit = ($audit.source_hashes_sha256.archive -eq $sourceHashes.m115_archive)
    m115_audit_all_checks_pass = (@($audit.checks.PSObject.Properties | Where-Object { -not $_.Value }).Count -eq 0)
    m83_roof_hash_matches_manifest = ($roofManifest.output_hashes_sha256.roof_options -eq $sourceHashes.m83_roof_options)
    selected_D_hash_matches_M115_sources = ($audit.source_hashes_sha256.selected_D_study -eq $selectedHash)
    selected_D_hash_matches_M83_sources = ($roof.source_fingerprints_sha256.selected_d_study -eq $selectedHash)
    shell_is_owner_authorized_hypothetical_38_333333_by_40 = ([Math]::Abs($shellWidth - 38.333333) -le $tol -and [Math]::Abs($shellDepth - 40.0) -le $tol)
    all_six_ideal_roof_cases_are_unselected_options = ($roof.results.Count -eq 6 -and @($roof.results | Where-Object { $_.selection_status -ne 'comparison option only; not owner-selected' }).Count -eq 0)
    sixty_four_northeast_privacy_candidates_retain_required_sampled_routes = ($privacyCandidates.Count -eq 64)
    every_privacy_candidate_reaches_exact_required_public_rooms = (@($privacyCandidates | Where-Object { $_.public_rooms_reached_count -ne 3 -or @($_.public_rooms_reached) -notcontains 'U-01' -or @($_.public_rooms_reached) -notcontains 'U-02' -or @($_.public_rooms_reached) -notcontains 'U-04' -or $_.hall_reachability.u03_hall_side_reachable -or [string]$_.hall_reachability.reachable_room_sides.'U-02' -notmatch 'north' }).Count -eq 0)
    each_candidate_has_seven_nonoverlapping_source_area_room_blocks = $true
    every_candidate_has_primary_bath = $true
    all_384_roof_room_cases_have_finite_nonnegative_rises = $true
    every_pitch_and_ridge_axis_is_covered = $true
    output_is_comparison_only_without_headroom_or_code_claim = $true
    selected_D_unchanged = $true
}

$rows = [System.Collections.Generic.List[object]]::new()
$candidateRows = [System.Collections.Generic.List[object]]::new()
$candidateIndex = 0
foreach ($candidate in $privacyCandidates) {
    $candidateIndex++
    $candidateId = 'M130-NE-{0:D2}' -f $candidateIndex
    $rooms = @($candidate.rectangles.PSObject.Properties | ForEach-Object { $_.Value })
    if ($rooms.Count -ne 7) { $checks.each_candidate_has_seven_nonoverlapping_source_area_room_blocks = $false; continue }

    $boxes = @()
    foreach ($room in $rooms) {
        $sourceDimensions = $selected.plans.upper | Where-Object { $_.id -eq $room.id } | Select-Object -First 1
        if ($null -eq $sourceDimensions -or [Math]::Abs(([double]$room.width_ft * [double]$room.depth_ft) - ([double]$sourceDimensions.w * [double]$sourceDimensions.d)) -gt $tol) {
            $checks.each_candidate_has_seven_nonoverlapping_source_area_room_blocks = $false
        }
        $x0 = [double]$room.x_ft; $y0 = [double]$room.y_ft
        $x1 = $x0 + [double]$room.width_ft; $y1 = $y0 + [double]$room.depth_ft
        if ($x0 -lt -$tol -or $y0 -lt -$tol -or $x1 -gt ($shellWidth + $tol) -or $y1 -gt ($shellDepth + $tol)) { $checks.each_candidate_has_seven_nonoverlapping_source_area_room_blocks = $false }
        $boxes += [pscustomobject]@{ id = [string]$room.id; x0 = $x0; y0 = $y0; x1 = $x1; y1 = $y1 }
    }
    for ($i = 0; $i -lt $boxes.Count; $i++) {
        for ($j = $i + 1; $j -lt $boxes.Count; $j++) {
            $overlapX = [Math]::Min($boxes[$i].x1,$boxes[$j].x1) - [Math]::Max($boxes[$i].x0,$boxes[$j].x0)
            $overlapY = [Math]::Min($boxes[$i].y1,$boxes[$j].y1) - [Math]::Max($boxes[$i].y0,$boxes[$j].y0)
            if ($overlapX -gt $tol -and $overlapY -gt $tol) { $checks.each_candidate_has_seven_nonoverlapping_source_area_room_blocks = $false }
        }
    }

    $bath = $candidate.rectangles.'U-05'
    if ($null -eq $bath) { $checks.every_candidate_has_primary_bath = $false; continue }
    $candidateRows.Add([pscustomobject][ordered]@{
        candidate_id = $candidateId
        source_layout_key = [string]$candidate.layout_key
        u03_width_ft = [Math]::Round([double]$candidate.rectangles.'U-03'.width_ft,6)
        u03_depth_ft = [Math]::Round([double]$candidate.rectangles.'U-03'.depth_ft,6)
        u03_x_ft = [Math]::Round([double]$candidate.rectangles.'U-03'.x_ft,6)
        u03_y_ft = [Math]::Round([double]$candidate.rectangles.'U-03'.y_ft,6)
        u05_x_ft = [Math]::Round([double]$bath.x_ft,6)
        u05_y_ft = [Math]::Round([double]$bath.y_ft,6)
        u05_width_ft = [Math]::Round([double]$bath.width_ft,6)
        u05_depth_ft = [Math]::Round([double]$bath.depth_ft,6)
        u05_area_sf = [Math]::Round([double]$bath.width_ft * [double]$bath.depth_ft,4)
        layout_bounds_width_ft = [Math]::Round([double]$candidate.layout_bounds_ft.width,6)
        layout_bounds_depth_ft = [Math]::Round([double]$candidate.layout_bounds_ft.depth,6)
        route_sample_count = [int]$candidate.public_rooms_reached_count
        u03_public_side_reachable = [bool]$candidate.hall_reachability.u03_hall_side_reachable
    })

    foreach ($option in $roof.results) {
        $axis = [string]$option.ridge_axis
        $span = if ($axis -eq 'X') { $shellDepth } else { $shellWidth }
        $start = if ($axis -eq 'X') { [double]$bath.y_ft } else { [double]$bath.x_ft }
        $length = if ($axis -eq 'X') { [double]$bath.depth_ft } else { [double]$bath.width_ft }
        $end = $start + $length
        $ridge = $span / 2.0
        $farDistance = [Math]::Max([Math]::Abs($start - $ridge),[Math]::Abs($end - $ridge))
        $nearDistance = [Math]::Min([Math]::Abs($start - $ridge),[Math]::Abs($end - $ridge))
        $minRise = ($span / 2.0 - $farDistance) * [double]$option.pitch_ratio
        $maxRise = if ($start -le $ridge -and $end -ge $ridge) { ($span / 2.0) * [double]$option.pitch_ratio } else { ($span / 2.0 - $nearDistance) * [double]$option.pitch_ratio }
        if ($minRise -lt -$tol -or $maxRise -lt ($minRise - $tol) -or [double]::IsNaN($minRise) -or [double]::IsInfinity($maxRise)) { $checks.all_384_roof_room_cases_have_finite_nonnegative_rises = $false }
        $rows.Add([pscustomobject][ordered]@{
            candidate_id = $candidateId
            roof_case_id = [string]$option.case_id
            pitch = "$($option.pitch_rise_units):$($option.pitch_run_units)"
            ridge_axis = $axis
            u05_minimum_ideal_roof_rise_above_relative_eave_ft = [Math]::Round([Math]::Max(0.0,$minRise),6)
            u05_maximum_ideal_roof_rise_above_relative_eave_ft = [Math]::Round($maxRise,6)
            fixture_clearance_or_headroom_checked = $false
            interpretation = 'Ideal zero-thickness roof-plane rise over the full U-05 room block only; no fixture/use zone or finished floor datum.'
        })
    }
}

if ($rows.Count -ne 384 -or $candidateRows.Count -ne 64) { $checks.sixty_four_northeast_privacy_candidates_retain_required_sampled_routes = $false }
if ((@($rows.pitch | Sort-Object -Unique) -join ',') -ne '10:12,12:12,8:12' -or (@($rows.ridge_axis | Sort-Object -Unique) -join ',') -ne 'X,Y') { $checks.every_pitch_and_ridge_axis_is_covered = $false }
if ($roof.status -notmatch 'comparison' -or @($roof.results | Where-Object { $_.selection_status -ne 'comparison option only; not owner-selected' }).Count -ne 0) { $checks.output_is_comparison_only_without_headroom_or_code_claim = $false }
if ((Get-Sha256 $selectedPath) -ne $selectedHash) { $checks.selected_D_unchanged = $false }
$failed = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failed.Count -gt 0) { throw "M130 roof exposure screen failed: $($failed -join ', ')" }

$bestAtPitch = @()
foreach ($pitch in @('8:12','10:12','12:12')) {
    foreach ($axis in @('X','Y')) {
        $best = $rows | Where-Object { $_.pitch -eq $pitch -and $_.ridge_axis -eq $axis } | Sort-Object { -[double]$_.u05_minimum_ideal_roof_rise_above_relative_eave_ft },{ [double]$_.u05_maximum_ideal_roof_rise_above_relative_eave_ft } | Select-Object -First 1
        $bestAtPitch += [pscustomobject][ordered]@{
            pitch = $pitch; ridge_axis = $axis; best_sample_candidate_id = $best.candidate_id
            highest_minimum_u05_roof_rise_ft = $best.u05_minimum_ideal_roof_rise_above_relative_eave_ft
            corresponding_maximum_u05_roof_rise_ft = $best.u05_maximum_ideal_roof_rise_above_relative_eave_ft
            ranking_basis = 'largest minimum ideal roof-plane rise over U-05 rectangle among the 64 bounded privacy candidates; descriptive screen only'
        }
    }
}

$report = [ordered]@{
    schema = 'forever-home.m130-upper-suite-roof-exposure.v1'
    status = 'bounded comparison only; no room layout, roof, eave, shell or fixture plan selected'
    shell = [ordered]@{ width_ft = $shellWidth; depth_ft = $shellDepth; status = 'hypothetical exploration case; not selected building dimensions' }
    candidate_count = $candidateRows.Count
    roof_case_count = $roof.results.Count
    room_roof_case_row_count = $rows.Count
    source_hashes_sha256 = $sourceHashes
    candidate_summary = @($candidateRows)
    room_roof_cases = @($rows)
    comparison_leaders = @($bestAtPitch)
    interpretation = 'The highest minimum rise identifies only a room-block position with more ideal roof plane beneath the full U-05 rectangle for one pitch/ridge combination. It is not headroom: eave height, finished floor, ceiling build-down, roof thickness and fixture zones are absent.'
    limitations = @(
        'M115 is an incomplete bounded search; these 64 northeast layouts are only its sampled privacy-preserving subset.',
        'M83 roof surfaces are ideal zero-thickness comparison planes on the hypothetical 38.333333 x 40 ft shell; pitches and ridge axes remain unselected.',
        'U-05 toilet, tub, shower, lavatory, door swing, use zones, actual walls and services are absent.',
        'No floor/eave datum or ceiling assembly is established, so no finished headroom or Connecticut sloped-ceiling conclusion is possible.',
        'U-03 exterior opening, sleeping-room classification, exterior discharge and site conditions remain unresolved.',
        'No Revit, IFC, selected-D source, owner-supplied RFA, or remote state is changed; this is not code, structural, professional or construction-readiness approval.'
    )
    checks = $checks
    failed = @()
}

$repoPrefix = $repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
$out = [System.IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))
if (-not $out.StartsWith($repoPrefix,[System.StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository.' }
New-Item -ItemType Directory -Path $out -Force | Out-Null
$reportPath = Join-Path $out 'm130-report.json'
$checksPath = Join-Path $out 'm130-checks.json'
$csvPath = Join-Path $out 'm130-roof-exposure.csv'
$summaryPath = Join-Path $out 'm130-candidate-summary.csv'
$reportText = $report | ConvertTo-Json -Depth 8
$checkEnvelope = [ordered]@{ schema = 'forever-home.m130-checks.v1'; passed_count = $checks.Count; check_count = $checks.Count; failed = @(); checks = $checks }
[System.IO.File]::WriteAllText($reportPath,$reportText + "`n",[System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText($checksPath,($checkEnvelope | ConvertTo-Json -Depth 5) + "`n",[System.Text.UTF8Encoding]::new($false))
$rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
$candidateRows | Export-Csv -LiteralPath $summaryPath -NoTypeInformation -Encoding UTF8
Write-Output ("M130 PASS: {0}/{1} checks; {2} privacy candidates; {3} roof cases; {4} room-roof rows" -f $checks.Count,$checks.Count,$candidateRows.Count,$roof.results.Count,$rows.Count)
Write-Output ("Report: {0}" -f $reportPath)
