param(
    [string]$M164RunDirectory = '.local/revalidation/M164-expanded',
    [string]$M164AuditDirectory = '.local/revalidation/M164-audit',
    [string]$RoofReportPath = '.local/revalidation/M168-roof-a/m164-gable-exposure.json',
    [string]$OutputDirectory = 'Architecture/M168_M164_Ridge_Orientation_Screen_2026-10-31'
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

$run = Resolve-RepoPath $M164RunDirectory
$auditDir = Resolve-RepoPath $M164AuditDirectory
$roofPath = Resolve-RepoPath $RoofReportPath
$output = Resolve-RepoPath $OutputDirectory
$sourcePaths = [ordered]@{
    m164_search = Join-Path $run 'search.json'
    m164_manifest = Join-Path $run 'manifest.json'
    m164_archive = Join-Path $run 'all-route-tested-candidates.json'
    m164_audit = Join-Path $auditDir 'm163-expanded-joint-perimeter-audit.json'
    m164_roof_report = $roofPath
    m158_search = Join-Path $repo 'Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31/search.json'
    m158_manifest = Join-Path $repo 'Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31/manifest.json'
    m158_archive = Join-Path $repo 'Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31/all-route-tested-candidates.json'
    m158_audit = Join-Path $repo 'Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31/m158-joint-perimeter-audit.json'
    m83_roof_options = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30/roof-options.json'
    selected_d = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
}
foreach ($path in $sourcePaths.Values) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source missing: $path" } }

$roof = Get-Content -LiteralPath $roofPath -Raw | ConvertFrom-Json
$audit = Get-Content -LiteralPath $sourcePaths.m164_audit -Raw | ConvertFrom-Json
$roofOptions = Get-Content -LiteralPath $sourcePaths.m83_roof_options -Raw | ConvertFrom-Json
$currentHashes = [ordered]@{}
foreach ($key in $sourcePaths.Keys) { $currentHashes[$key] = Get-Sha256 $sourcePaths[$key] }

$expectedSourceMap = [ordered]@{
    m164_search = 'm163_search'; m164_manifest = 'm163_manifest'; m164_archive = 'm163_archive';
    m164_audit = 'm163_audit'; m158_search = 'm158_search'; m158_manifest = 'm158_manifest';
    m158_archive = 'm158_archive'; m158_audit = 'm158_audit'; m83_roof_options = 'm83_roof_options'; selected_d = 'selected_d'
}
$checks = [ordered]@{}
foreach ($pair in $expectedSourceMap.GetEnumerator()) {
    $expected = [string]$roof.source_hashes_sha256.($pair.Value)
    $checks["$($pair.Key)_matches_bound_roof_report"] = ($expected -eq $currentHashes[$pair.Key])
}
$routeQualified = @($audit.candidates | Where-Object { $_.all_public_and_private_only -eq $true })
$routeKeys = @($routeQualified | ForEach-Object { [string]$_.layout_key } | Sort-Object -Unique)
$roofCandidates = @($roof.results | Where-Object { $_.candidate_set -eq 'M164 expanded route-qualified' } | ForEach-Object { [string]$_.candidate_key } | Sort-Object -Unique)
$checks.m164_audit_has_120_unique_route_tested_candidates = (@($audit.candidates | Select-Object -ExpandProperty layout_key -Unique).Count -eq 120)
$checks.route_qualified_candidate_set_matches_roof_report = (($routeKeys -join "`n") -ceq ($roofCandidates -join "`n") -and $routeKeys.Count -eq 48)
$checks.roof_report_uses_current_six_case_m83_set = (@($roofOptions.pitch_cases).Count -eq 3 -and @($roofOptions.results | Select-Object -ExpandProperty case_id -Unique).Count -eq 6)

$rows = [System.Collections.Generic.List[object]]::new()
$summaries = [System.Collections.Generic.List[object]]::new()
$roof12 = @($roof.results | Where-Object { $_.candidate_set -eq 'M164 expanded route-qualified' -and $_.pitch -eq '12:12' -and $_.room_id -in @('U-01','U-03','U-04') })
$checks.has_exactly_288_steep_case_bedroom_rows = ($roof12.Count -eq 48 * 2 * 3)
$grouped = $roof12 | Group-Object { "$($_.candidate_key)|$($_.ridge_axis)" }
$checks.has_exactly_96_layout_axis_groups = ($grouped.Count -eq 48 * 2)
foreach ($group in $grouped) {
    $groupRows = @($group.Group | Sort-Object room_id)
    $candidateKey = [string]$groupRows[0].candidate_key
    $axis = [string]$groupRows[0].ridge_axis
    $uniqueRooms = @($groupRows | Select-Object -ExpandProperty room_id -Unique)
    if ($groupRows.Count -ne 3 -or (($uniqueRooms -join ',') -cne 'U-01,U-03,U-04')) { throw "Expected one row for each bedroom-capable block in $axis / $candidateKey" }
    $contacts = @{}
    foreach ($room in $groupRows) { $contacts[[string]$room.room_id] = [string]$room.touched_ideal_eave_edges }
    $count = @($contacts.Values | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count
    $rows.Add([pscustomobject][ordered]@{
        candidate_key = $candidateKey
        ridge_axis = $axis
        pitch = '12:12'
        u01_ideal_eave_edges = $contacts['U-01']
        u03_ideal_eave_edges = $contacts['U-03']
        u04_ideal_eave_edges = $contacts['U-04']
        bedroom_blocks_touching_ideal_eave = $count
        selected = $false
        interpretation = 'route-qualified room-block proposal; ideal geometry only'
    })
}
foreach ($axis in @('X','Y')) {
    $axisRows = @($rows | Where-Object { $_.ridge_axis -eq $axis })
    foreach ($contactCount in 0..3) {
        $n = @($axisRows | Where-Object { $_.bedroom_blocks_touching_ideal_eave -eq $contactCount }).Count
        $summaries.Add([pscustomobject][ordered]@{ ridge_axis = $axis; bedroom_blocks_touching_ideal_eave = $contactCount; layout_count = $n })
    }
}
$checks.ridge_x_has_48_layouts_with_two_bedroom_eave_contacts = (@($rows | Where-Object { $_.ridge_axis -eq 'X' -and $_.bedroom_blocks_touching_ideal_eave -eq 2 }).Count -eq 48)
$checks.ridge_y_splits_24_one_contact_and_24_two_contacts = (@($rows | Where-Object { $_.ridge_axis -eq 'Y' -and $_.bedroom_blocks_touching_ideal_eave -eq 1 }).Count -eq 24 -and @($rows | Where-Object { $_.ridge_axis -eq 'Y' -and $_.bedroom_blocks_touching_ideal_eave -eq 2 }).Count -eq 24)
$checks.no_12_12_layout_keeps_all_three_blocks_off_ideal_eaves = (@($rows | Where-Object { $_.bedroom_blocks_touching_ideal_eave -eq 0 }).Count -eq 0)
$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object { $_.Key })

$report = [ordered]@{
    milestone = 'M168'
    title = 'M164 ridge orientation and bedroom eave-contact screen'
    status = 'comparative proposal screen; no roof or layout selected'
    method = 'Count U-01, U-03 and U-04 blocks touching an ideal eave for each of 48 route-qualified M164 room-block layouts and both ridge axes at 12:12; validate every row against the current M164 route audit and M83 source fingerprints.'
    shell = 'owner-authorized 38.333333 x 40 ft exploration outline only'
    pitch = '12:12; steepest of the three existing comparison cases'
    route_qualified_layout_count = 48
    layout_axis_row_count = $rows.Count
    summaries = @($summaries)
    results = @($rows | Sort-Object ridge_axis,candidate_key)
    source_sha256 = $currentHashes
    checks = $checks
    failures = $failures
    limitations = @(
        'M164 candidates are discrete room-block proposals, not selected rooms or finished plans; the search is finite and inherits its declared route samples.',
        'An ideal eave contact is not finished ceiling height, wall placement, dormer feasibility, required floor area, or a code pass/fail result.',
        'Ridge Y reduces the sampled count of bedroom-capable blocks touching ideal eaves in half the options; the remaining contact and all absolute datum/build-down inputs stay unresolved.',
        'No roof pitch, ridge axis, shell, exterior wall, window, structural system, room classification, or construction detail is selected.'
    )
}
if ($failures.Count -gt 0) { throw "M168 source or geometry checks failed: $($failures -join ', ')" }
New-Item -ItemType Directory -Force -Path $output | Out-Null
$jsonPath = Join-Path $output 'm168-ridge-orientation.json'
$csvPath = Join-Path $output 'm168-bedroom-eave-contacts.csv'
ConvertTo-Json -InputObject $report -Depth 15 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
$report.results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
Write-Output "M168 checks passed: $($checks.Count)/$($checks.Count); route-qualified layouts=$($routeKeys.Count); axis rows=$($rows.Count); JSON SHA256 $(Get-Sha256 $jsonPath); CSV SHA256 $(Get-Sha256 $csvPath)."
