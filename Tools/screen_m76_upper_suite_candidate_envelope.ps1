param(
    [string]$CandidateRunDirectory = (Join-Path $PSScriptRoot '../Architecture/M46_Full_Plate_Upper_Suite_Comparison_2026-10-28'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M76_Upper_Suite_Envelope_Sensitivity_2026-10-29.json')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$candidateRun = (Resolve-Path -LiteralPath $CandidateRunDirectory).Path
$candidateFile = Join-Path $candidateRun 'search.json'
$manifestFile = Join-Path $candidateRun 'manifest.json'
$selectedFile = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$validatorFile = Join-Path $PSScriptRoot 'validate_upper_suite_candidate.ps1'
$candidate = Get-Content -LiteralPath $candidateFile -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $manifestFile -Raw | ConvertFrom-Json
$selected = Get-Content -LiteralPath $selectedFile -Raw | ConvertFrom-Json

if ($null -eq $candidate.best_candidate -or -not $candidate.best_candidate.hall_reachability.required_public_rooms_reached) {
    throw 'Expected the retained M46 candidate whose sampled route reaches U-01, U-02 and U-04.'
}
if ($candidate.coordinate_basis.width_ft -ne 40 -or $candidate.coordinate_basis.depth_ft -ne 42 -or
    $candidate.coordinate_basis.shell_case -notmatch 'unapproved|unselected proposal') {
    throw 'Expected the M46 unapproved 40 x 42 ft comparison as the candidate source.'
}
if ($manifest.output_hashes_sha256.search -ne (Get-FileHash $candidateFile -Algorithm SHA256).Hash.ToLowerInvariant()) {
    throw 'M46 candidate report hash does not match its retained manifest.'
}

$rectangles = $candidate.best_candidate.rectangles
$maxX = 0.0
$maxY = 0.0
foreach ($property in $rectangles.PSObject.Properties) {
    $room = $property.Value
    $maxX = [Math]::Max($maxX, ([double]$room.x_ft + [double]$room.width_ft))
    $maxY = [Math]::Max($maxY, ([double]$room.y_ft + [double]$room.depth_ft))
}
$selectedWidth = [double]$selected.shells.rear_upper[0]
$selectedDepth = [double]$selected.shells.rear_upper[1]
$fullComparisonWidth = [double]$candidate.coordinate_basis.width_ft
$fullComparisonDepth = [double]$candidate.coordinate_basis.depth_ft
$candidateBlockMinimumWidth = [Math]::Round($maxX, 6)
$candidateBlockMinimumDepth = [Math]::Round($maxY, 6)

$testCases = @(
    [ordered]@{id='selected-D-upper-wing';width_ft=$selectedWidth;depth_ft=$selectedDepth},
    [ordered]@{id='room-block-bounds-only';width_ft=$candidateBlockMinimumWidth;depth_ft=$candidateBlockMinimumDepth},
    [ordered]@{id='narrow-39-5';width_ft=$candidateBlockMinimumWidth;depth_ft=39.5},
    [ordered]@{id='narrow-40';width_ft=$candidateBlockMinimumWidth;depth_ft=40.0},
    [ordered]@{id='width-39-depth-40';width_ft=39.0;depth_ft=40.0},
    [ordered]@{id='width-40-depth-39-5';width_ft=40.0;depth_ft=39.5},
    [ordered]@{id='square-40';width_ft=40.0;depth_ft=40.0},
    [ordered]@{id='width-39-depth-42';width_ft=39.0;depth_ft=42.0},
    [ordered]@{id='narrow-42';width_ft=$candidateBlockMinimumWidth;depth_ft=42.0},
    [ordered]@{id='original-M46-shell';width_ft=$fullComparisonWidth;depth_ft=$fullComparisonDepth}
)

$powershell = Join-Path $PSHOME 'powershell.exe'
$results = [System.Collections.Generic.List[object]]::new()
foreach ($test in $testCases) {
    $priorErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $output = & $powershell -NoProfile -ExecutionPolicy Bypass -File $validatorFile $candidateRun `
        -TestShellWidthFt ([double]$test.width_ft) -TestShellDepthFt ([double]$test.depth_ft) 2>&1
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = $priorErrorActionPreference
    $messages = @($output | ForEach-Object { $_.ToString() })
    $passLine = @($messages | Where-Object { $_ -match '^PASS:' } | Select-Object -Last 1)
    $failureLine = @($messages | Where-Object { $_ -match '^FAILED:' } | Select-Object -Last 1)
    $checkCount = 0
    $failureCount = 0
    if ($passLine.Count -gt 0 -and $passLine[0] -match '^PASS: (\d+) independent checks') { $checkCount = [int]$Matches[1] }
    if ($failureLine.Count -gt 0 -and $failureLine[0] -match 'FAILED: (\d+) of (\d+)') {
        $failureCount = [int]$Matches[1]
        $checkCount = [int]$Matches[2]
    }
    $area = [Math]::Round(([double]$test.width_ft * [double]$test.depth_ft), 3)
    $results.Add([ordered]@{
        id = [string]$test.id
        status = 'hypothetical sensitivity case; not a selected design dimension'
        width_ft = [double]$test.width_ft
        depth_ft = [double]$test.depth_ft
        gross_area_sf = $area
        independent_validator_check_count = $checkCount
        failed_check_count = $failureCount
        sampled_public_route_pass = ($exitCode -eq 0 -and $passLine.Count -gt 0)
        validator_exit_code = $exitCode
        validator_summary = if ($passLine.Count -gt 0) { [string]$passLine[0] } elseif ($failureLine.Count -gt 0) { [string]$failureLine[0] } else { 'No validator summary line was captured.' }
    })
}

$passing = @($results | Where-Object { $_.sampled_public_route_pass } | Sort-Object { [double]$_.gross_area_sf }, { [double]$_.width_ft }, { [double]$_.depth_ft })
$selectedArea = $selectedWidth * $selectedDepth
$minimumPassing = if ($passing.Count -gt 0) { $passing[0] } else { $null }
$checks = [ordered]@{
    M46_source_is_fingerprint_matched = ($candidate.source_fingerprints_sha256.'selected_D_study.json' -eq $manifest.source_fingerprints_sha256.'selected_D_study.json')
    M46_winner_reaches_required_public_rooms = ($candidate.best_candidate.public_rooms_reached_count -eq 3)
    candidate_room_boxes_fit_inside_block_bounds = ([Math]::Abs($maxX - $candidateBlockMinimumWidth) -le 0.000001 -and [Math]::Abs($maxY - $candidateBlockMinimumDepth) -le 0.000001)
    selected_D_upper_dimensions_are_source_derived = ($selectedWidth -eq 36 -and $selectedDepth -eq 32)
    all_ten_validator_cases_ran = ($results.Count -eq 10 -and @($results | Where-Object { $_.independent_validator_check_count -eq 112 }).Count -eq 10)
    selected_wing_case_fails = (-not $results[0].sampled_public_route_pass)
    blocks_only_bounds_do_not_yet_pass_public_route = (-not $results[1].sampled_public_route_pass)
    original_M46_shell_still_passes = $results[-1].sampled_public_route_pass
    every_test_is_labelled_as_hypothetical = (@($results | Where-Object { $_.status -ne 'hypothetical sensitivity case; not a selected design dimension' }).Count -eq 0)
}
$failures = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failures.Count -gt 0) { throw "M76 checks failed: $($failures -join ', ')" }

$report = [ordered]@{
    schema = 'forever-home-m76-upper-suite-shell-sensitivity-v1'
    checked_on = '2026-10-29'
    status = 'Selected-D room-block baseline unchanged; unapproved envelope sensitivity of one existing M46 candidate.'
    source = [ordered]@{
        M46_candidate_run = 'Architecture/M46_Full_Plate_Upper_Suite_Comparison_2026-10-28/search.json'
        selected_D_study = 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
        independent_validator = 'Tools/validate_upper_suite_candidate.ps1'
        M46_source_shell_ft = [ordered]@{width=$fullComparisonWidth;depth=$fullComparisonDepth;status='unapproved comparison'}
    }
    selected_D_upper_shell_ft = [ordered]@{width=$selectedWidth;depth=$selectedDepth;gross_area_sf=$selectedArea;status='source test envelope, not a verified finished interior'}
    M46_candidate_room_block_bounds = [ordered]@{maximum_x_ft=$candidateBlockMinimumWidth;maximum_y_ft=$candidateBlockMinimumDepth;minimum_origin_anchored_shell_width_ft=$candidateBlockMinimumWidth;minimum_origin_anchored_shell_depth_ft=$candidateBlockMinimumDepth}
    selected_wing_shortfall_to_contain_room_blocks_ft = [ordered]@{width=[Math]::Round([Math]::Max(0.0,$candidateBlockMinimumWidth-$selectedWidth),3);depth=[Math]::Round([Math]::Max(0.0,$candidateBlockMinimumDepth-$selectedDepth),3)}
    cases = @($results)
    smallest_tested_passing_gross_envelope = $minimumPassing
    smallest_tested_passing_area_increase_sf = if ($null -ne $minimumPassing) { [Math]::Round(([double]$minimumPassing.gross_area_sf-$selectedArea),3) } else { $null }
    smallest_tested_passing_area_increase_percent = if ($null -ne $minimumPassing) { [Math]::Round((([double]$minimumPassing.gross_area_sf/$selectedArea)-1.0)*100.0,2) } else { $null }
    scope = 'The validator independently recomputes the existing 4 ft sampled hall-route proxy inside each stated shell. This is a small, selected-case sensitivity, not an exhaustive search for minimum building size.'
    limitations = @(
        'M46 room blocks, lift/stair reservations and route points remain the unapproved candidate; selected D is unchanged.',
        'Test shell boundaries are rectangles; wall thickness, doors, privacy, headroom, structure, code and construction details are not represented.',
        'Passing means only that this same M46 arrangement fits and its sampled 4 ft route still reaches U-01, U-02 and U-04 in the tested bounds.',
        'No route validates actual door openings or U-03 access; the owner-directed U-03 public edge remains excluded.'
    )
    checks = $checks
    failures = $failures
    source_fingerprints_sha256 = [ordered]@{
        M46_search_json = (Get-FileHash -LiteralPath $candidateFile -Algorithm SHA256).Hash.ToLowerInvariant()
        selected_D_study_json = (Get-FileHash -LiteralPath $selectedFile -Algorithm SHA256).Hash.ToLowerInvariant()
        independent_validator = (Get-FileHash -LiteralPath $validatorFile -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repo $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not $outputDir.StartsWith($repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'OutputPath must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
ConvertTo-Json -InputObject $report -Depth 16 | Set-Content -LiteralPath $resolvedOutput -Encoding utf8
Write-Output ("M76 independent shell tests: {0}; passing sampled route cases: {1}; smallest tested passing envelope: {2} x {3} ft." -f $results.Count,$passing.Count,$minimumPassing.width_ft,$minimumPassing.depth_ft)
