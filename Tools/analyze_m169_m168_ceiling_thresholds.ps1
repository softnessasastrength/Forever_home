param(
    [string]$M164RoofReportPath = '.local/revalidation/M168-roof-a/m164-gable-exposure.json',
    [string]$M168ReportPath = 'Architecture/M168_M164_Ridge_Orientation_Screen_2026-10-31/m168-ridge-orientation.json',
    [string]$OutputDirectory = 'Architecture/M169_M168_Conditional_Eave_Thresholds_2026-10-31'
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

$roofPath = Resolve-RepoPath $M164RoofReportPath
$m168Path = Resolve-RepoPath $M168ReportPath
$output = Resolve-RepoPath $OutputDirectory
$m83Path = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30/roof-options.json'
$selectedPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
foreach ($path in @($roofPath,$m168Path,$m83Path,$selectedPath)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source missing: $path" } }

$roof = Get-Content -LiteralPath $roofPath -Raw | ConvertFrom-Json
$m168 = Get-Content -LiteralPath $m168Path -Raw | ConvertFrom-Json
$currentHashes = [ordered]@{
    m164_roof_report = Get-Sha256 $roofPath
    m168_report = Get-Sha256 $m168Path
    m83_roof_options = Get-Sha256 $m83Path
    selected_d = Get-Sha256 $selectedPath
}
$checks = [ordered]@{
    m168_binds_same_m164_roof_report = ($m168.source_sha256.m164_roof_report -eq $currentHashes.m164_roof_report)
    m168_binds_current_m83_options = ($m168.source_sha256.m83_roof_options -eq $currentHashes.m83_roof_options)
    m168_binds_current_selected_d = ($m168.source_sha256.selected_d -eq $currentHashes.selected_d)
    m164_roof_report_is_12_12_source_bound = ($roof.milestone -eq 'M164' -and $roof.roof_case_count -eq 6 -and $roof.room_case_row_count -eq 882)
    m168_has_96_layout_axis_rows = (@($m168.results).Count -eq 96)
    m168_candidate_axis_keys_are_unique = ((@($m168.results | ForEach-Object { "$($_.candidate_key)|$($_.ridge_axis)" } | Sort-Object -Unique)).Count -eq 96)
}

function Normalize-Edges([string]$Edges) {
    return ((@($Edges -split '[,;|]' | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ } | Sort-Object -Unique)) -join ',')
}

$eaveRows = @($m168.results)
$eaveByKey = @{}
foreach ($row in $eaveRows) { $eaveByKey["$($row.candidate_key)|$($row.ridge_axis)"] = $row }
$roofRows = @($roof.results | Where-Object { $_.candidate_set -eq 'M164 expanded route-qualified' -and $_.pitch -eq '12:12' -and $_.room_id -in @('U-01','U-03','U-04') })
$groups = $roofRows | Group-Object { "$($_.candidate_key)|$($_.ridge_axis)" }
$checks.has_exactly_288_bedroom_threshold_rows = ($roofRows.Count -eq 48 * 2 * 3)
$checks.has_exactly_96_candidate_axis_threshold_groups = ($groups.Count -eq 96)
$results = [System.Collections.Generic.List[object]]::new()
foreach ($group in $groups) {
    $items = @($group.Group | Sort-Object room_id)
    if ($items.Count -ne 3 -or (($items | Select-Object -ExpandProperty room_id -Unique | Sort-Object) -join ',' -cne 'U-01,U-03,U-04')) { throw "Incomplete bedroom set: $($group.Name)" }
    $candidateKey = [string]$items[0].candidate_key
    $axis = [string]$items[0].ridge_axis
    $eave = $eaveByKey["$candidateKey|$axis"]
    if ($null -eq $eave) { throw "No matching M168 eave count: $($group.Name)" }
    $values = @{}
    foreach ($item in $items) { $values[[string]$item.room_id] = [double]$item.conditional_effective_eave_ceiling_threshold_ft }
    $limiting = @($values.Keys | Where-Object { $values[$_] -ge 4.999999 } | Sort-Object)
    $contactCount = @($items | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.touched_ideal_eave_edges) }).Count
    $expectedEdges = @{
        'U-01' = Normalize-Edges ([string]$items[0].touched_ideal_eave_edges)
        'U-03' = Normalize-Edges ([string]$items[1].touched_ideal_eave_edges)
        'U-04' = Normalize-Edges ([string]$items[2].touched_ideal_eave_edges)
    }
    $actualEdges = @{
        'U-01' = Normalize-Edges ([string]$eave.u01_ideal_eave_edges)
        'U-03' = Normalize-Edges ([string]$eave.u03_ideal_eave_edges)
        'U-04' = Normalize-Edges ([string]$eave.u04_ideal_eave_edges)
    }
    $edgesMatch = (($expectedEdges['U-01'] -ceq $actualEdges['U-01']) -and ($expectedEdges['U-03'] -ceq $actualEdges['U-03']) -and ($expectedEdges['U-04'] -ceq $actualEdges['U-04']))
    $countsMatch = ([int]$eave.bedroom_blocks_touching_ideal_eave -eq $contactCount)
    if (-not $edgesMatch -or -not $countsMatch) { throw "M168 eave contacts disagree with source rows: $($group.Name)" }
    $results.Add([pscustomobject][ordered]@{
        candidate_key = $candidateKey
        ridge_axis = $axis
        pitch = '12:12'
        u01_conditional_threshold_ft = [Math]::Round($values['U-01'],6)
        u03_conditional_threshold_ft = [Math]::Round($values['U-03'],6)
        u04_conditional_threshold_ft = [Math]::Round($values['U-04'],6)
        bedroom_blocks_at_5ft_limiting_proxy = $limiting.Count
        limiting_room_ids = ($limiting -join ',')
        ideal_eave_contact_count = $contactCount
        m168_contact_count_matches_source = $countsMatch
        m168_room_edge_labels_match_source = $edgesMatch
        eave_contacts_match_5ft_limiting_count = ($contactCount -eq $limiting.Count)
        full_block_required_area_proxy = $true
        code_threshold_evaluated_as_pass_fail = $false
        selected = $false
    })
}
$checks.contact_count_matches_5ft_proxy_count_in_every_candidate = (@($results | Where-Object { -not $_.eave_contacts_match_5ft_limiting_count }).Count -eq 0)
$checks.m168_counts_and_edges_match_m164_source_rows = (@($results | Where-Object { -not $_.m168_contact_count_matches_source -or -not $_.m168_room_edge_labels_match_source }).Count -eq 0)
$checks.ridge_x_has_two_5ft_limiting_blocks_in_48_layouts = (@($results | Where-Object { $_.ridge_axis -eq 'X' -and $_.bedroom_blocks_at_5ft_limiting_proxy -eq 2 }).Count -eq 48)
$checks.ridge_y_has_one_5ft_limiting_block_in_24_layouts = (@($results | Where-Object { $_.ridge_axis -eq 'Y' -and $_.bedroom_blocks_at_5ft_limiting_proxy -eq 1 }).Count -eq 24)
$checks.ridge_y_has_two_5ft_limiting_blocks_in_24_layouts = (@($results | Where-Object { $_.ridge_axis -eq 'Y' -and $_.bedroom_blocks_at_5ft_limiting_proxy -eq 2 }).Count -eq 24)
$checks.ridge_y_one_block_cases_have_u03_as_limiter = (@($results | Where-Object { $_.ridge_axis -eq 'Y' -and $_.bedroom_blocks_at_5ft_limiting_proxy -eq 1 -and $_.limiting_room_ids -eq 'U-03' }).Count -eq 24)
$checks.ridge_y_one_block_cases_have_u04_threshold_4_166667_ft = (@($results | Where-Object { $_.ridge_axis -eq 'Y' -and $_.bedroom_blocks_at_5ft_limiting_proxy -eq 1 -and [Math]::Abs($_.u04_conditional_threshold_ft - 4.166667) -le 0.000001 }).Count -eq 16)
$checks.ridge_y_one_block_cases_have_u04_threshold_3_333334_ft = (@($results | Where-Object { $_.ridge_axis -eq 'Y' -and $_.bedroom_blocks_at_5ft_limiting_proxy -eq 1 -and [Math]::Abs($_.u04_conditional_threshold_ft - 3.333334) -le 0.000001 }).Count -eq 8)
$checks.ridge_y_one_block_u04_threshold_classes_cover_all_24 = (@($results | Where-Object { $_.ridge_axis -eq 'Y' -and $_.bedroom_blocks_at_5ft_limiting_proxy -eq 1 -and ([Math]::Abs($_.u04_conditional_threshold_ft - 4.166667) -le 0.000001 -or [Math]::Abs($_.u04_conditional_threshold_ft - 3.333334) -le 0.000001) }).Count -eq 24)
$summaries = [System.Collections.Generic.List[object]]::new()
foreach ($axis in @('X','Y')) {
    foreach ($count in 0..3) {
        $n = @($results | Where-Object { $_.ridge_axis -eq $axis -and $_.bedroom_blocks_at_5ft_limiting_proxy -eq $count }).Count
        $summaries.Add([pscustomobject][ordered]@{ ridge_axis = $axis; blocks_with_5ft_proxy_threshold = $count; layout_count = $n })
    }
}
$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object { $_.Key })
$report = [ordered]@{
    milestone = 'M169'
    title = 'Conditional effective-eave thresholds for M168 ridge options'
    status = 'conditional arithmetic sensitivity; no code pass/fail and no roof/layout selected'
    formula = 'effective_eave_ceiling = (z_eave - z_finished_floor) - b_eave; for the full-block area proxy, required floor/eave difference >= max(5 ft - minimum ideal rise, 7 ft - median ideal rise) + b_eave'
    assumption = 'Each complete schematic room rectangle stands for required floor area; this is a ranking proxy only.'
    candidate_axis_count = $results.Count
    pitch = '12:12'
    summaries = @($summaries)
    results = @($results | Sort-Object ridge_axis,candidate_key)
    source_sha256 = $currentHashes
    checks = $checks
    failures = $failures
    limitations = @(
        'The thresholds are algebraic conditions, not selected elevations, finished ceiling heights, or code pass/fail results.',
        'Negative thresholds are not interpreted as physical below-floor eaves.',
        'Required-floor-area interpretation, room/use classification, municipality, permit cycle, floor/eave datum, ceiling build-down, walls and roof assembly remain unresolved.',
        "M164's route-qualified layouts are discrete proposals from a finite grid and sampled route/perimeter checks; they do not establish complete-plan feasibility."
    )
}
if ($failures.Count -gt 0) { throw "M169 source or geometry checks failed: $($failures -join ', ')" }
New-Item -ItemType Directory -Force -Path $output | Out-Null
$jsonPath = Join-Path $output 'm169-conditional-eave-thresholds.json'
$csvPath = Join-Path $output 'm169-thresholds-by-layout.csv'
ConvertTo-Json -InputObject $report -Depth 15 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
$report.results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
Write-Output "M169 checks passed: $($checks.Count)/$($checks.Count); candidate/axis rows=$($results.Count); JSON SHA256 $(Get-Sha256 $jsonPath); CSV SHA256 $(Get-Sha256 $csvPath)."
