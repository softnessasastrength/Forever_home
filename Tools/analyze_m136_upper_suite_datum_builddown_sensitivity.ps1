param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M136_Upper_Suite_Datum_Builddown_Sensitivity_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m78Directory = Join-Path $repo 'Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29'
$m83Directory = Join-Path $repo 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
$m103Directory = Join-Path $repo 'Architecture/M103_Upper_Suite_Sloped_Ceiling_Thresholds_2026-10-30'
$searchPath = Join-Path $m78Directory 'search.json'
$m78ManifestPath = Join-Path $m78Directory 'manifest.json'
$roofPath = Join-Path $m83Directory 'roof-options.json'
$m103JsonPath = Join-Path $m103Directory 'effective-eave-thresholds.json'
$m103CsvPath = Join-Path $m103Directory 'effective-eave-thresholds.csv'
$codeNotePath = Join-Path $repo 'Research/Connecticut_Roof_Code_Research_2026-10-28.md'
$roomProgramPath = Join-Path $repo 'Requirements/Room_Program.md'
$selectedDPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Format-Number([double]$Value) {
    $Value.ToString('0.######', [Globalization.CultureInfo]::InvariantCulture)
}

$inputs = @($searchPath, $m78ManifestPath, $roofPath, $m103JsonPath, $m103CsvPath, $codeNotePath, $roomProgramPath, $selectedDPath)
foreach ($path in $inputs) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required M136 input is missing: $path" }
}

$search = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$m78Manifest = Get-Content -LiteralPath $m78ManifestPath -Raw | ConvertFrom-Json
$roof = Get-Content -LiteralPath $roofPath -Raw | ConvertFrom-Json
$m103 = Get-Content -LiteralPath $m103JsonPath -Raw | ConvertFrom-Json
$sourceHashes = [ordered]@{
    m78_search = Get-Sha256 $searchPath
    m78_manifest = Get-Sha256 $m78ManifestPath
    m83_roof_options = Get-Sha256 $roofPath
    m103_threshold_json = Get-Sha256 $m103JsonPath
    m103_threshold_csv = Get-Sha256 $m103CsvPath
    ct_code_research_note = Get-Sha256 $codeNotePath
    room_program = Get-Sha256 $roomProgramPath
    selected_d_study = Get-Sha256 $selectedDPath
}

if ($m78Manifest.output_hashes_sha256.search -ne $sourceHashes.m78_search) { throw 'M78 search hash does not match its manifest.' }
if ($roof.source_fingerprints_sha256.m78_search -ne $sourceHashes.m78_search -or
    $roof.source_fingerprints_sha256.m78_manifest -ne $sourceHashes.m78_manifest -or
    $roof.source_fingerprints_sha256.selected_d_study -ne $sourceHashes.selected_d_study) {
    throw 'M83 options do not bind the current M78 and selected-D sources.'
}
if ($roof.coordinate_basis.absolute_eave_elevation -notmatch 'unassigned') { throw 'M83 eave datum must remain unassigned.' }
if ($m103.milestone -ne 'M103' -or $m103.result_count -ne 24 -or @($m103.failures).Count -ne 0) { throw 'M103 threshold report is incomplete or failed.' }
if ($m103.source_hashes_sha256.m78_search -ne $sourceHashes.m78_search -or
    $m103.source_hashes_sha256.m83_roof_options -ne $sourceHashes.m83_roof_options -or
    $m103.source_hashes_sha256.ct_code_research_note -ne $sourceHashes.ct_code_research_note -or
    $m103.source_hashes_sha256.room_program -ne $sourceHashes.room_program -or
    $m103.source_hashes_sha256.selected_d_study -ne $sourceHashes.selected_d_study) {
    throw 'M103 report is stale against current source inputs.'
}

$candidateCases = @('M83-X-12:12', 'M83-Y-12:12', 'M83-X-10:12')
$candidateRooms = @('U-01', 'U-02', 'U-03', 'U-04')
$results = @()
foreach ($caseId in $candidateCases) {
    foreach ($roomId in $candidateRooms) {
        $row = @($m103.results | Where-Object { $_.roof_case_id -eq $caseId -and $_.room_id -eq $roomId })
        if ($row.Count -ne 1) { throw "Expected one M103 threshold row for $caseId / $roomId; found $($row.Count)." }
        $source = $row[0]
        $fullBlock = [double]$source.effective_finished_ceiling_at_eave_for_full_block_at_5ft_ft
        $halfBlock = [double]$source.effective_finished_ceiling_at_eave_for_half_block_at_7ft_ft
        $combined = [Math]::Max($fullBlock, $halfBlock)
        $fullLiteral = Format-Number $fullBlock
        $halfLiteral = Format-Number $halfBlock
        $combinedLiteral = Format-Number $combined
        $results += [pscustomobject][ordered]@{
            roof_case_id = $caseId
            pitch = [string]$source.pitch
            ridge_axis = [string]$source.ridge_axis
            room_id = $roomId
            minimum_plane_rise_above_relative_eave_ft = [double]$source.minimum_plane_rise_above_relative_eave_ft
            median_plane_rise_above_relative_eave_ft = [double]$source.median_plane_rise_above_relative_eave_ft
            effective_eave_threshold_for_full_modeled_block_at_5ft_ft = $fullBlock
            effective_eave_threshold_for_half_modeled_block_at_7ft_ft = $halfBlock
            effective_eave_threshold_for_both_generic_bands_ft = $combined
            effective_finished_eave_ceiling_formula = '(z_eave - z_finished_floor) - b_eave'
            full_block_5ft_condition = "(z_eave - z_finished_floor) - b_eave >= $fullLiteral ft"
            half_block_7ft_condition = "(z_eave - z_finished_floor) - b_eave >= $halfLiteral ft"
            combined_floor_to_eave_condition = "z_eave - z_finished_floor >= $combinedLiteral ft + b_eave"
            condition_evaluated = $false
            room_classification_resolved = $false
            legal_required_floor_area_established = $false
            fixture_height_zone_checked = $false
            m06_b_assigned = $false
        }
    }
}

if ($results.Count -ne 12) { throw "Expected 12 room/case sensitivity rows; produced $($results.Count)." }
$checks = [ordered]@{}
$checks.m78_manifest_matches_search = ($m78Manifest.output_hashes_sha256.search -eq $sourceHashes.m78_search)
$checks.m83_roof_options_bind_current_inputs = ($roof.source_fingerprints_sha256.m78_search -eq $sourceHashes.m78_search -and $roof.source_fingerprints_sha256.m78_manifest -eq $sourceHashes.m78_manifest -and $roof.source_fingerprints_sha256.selected_d_study -eq $sourceHashes.selected_d_study)
$checks.m103_threshold_report_binds_current_inputs = ($m103.source_hashes_sha256.m78_search -eq $sourceHashes.m78_search -and $m103.source_hashes_sha256.m83_roof_options -eq $sourceHashes.m83_roof_options -and $m103.source_hashes_sha256.ct_code_research_note -eq $sourceHashes.ct_code_research_note -and $m103.source_hashes_sha256.room_program -eq $sourceHashes.room_program -and $m103.source_hashes_sha256.selected_d_study -eq $sourceHashes.selected_d_study)
$checks.exactly_three_requested_roof_cases = (@($roof.results | Where-Object { $_.case_id -in $candidateCases }).Count -eq 3)
$checks.four_upper_room_blocks_present = (@($search.best_candidate.rectangles.PSObject.Properties | Where-Object { $_.Value.id -in $candidateRooms }).Count -eq 4)
$checks.eave_floor_and_builddown_remain_unassigned = ($roof.coordinate_basis.absolute_eave_elevation -match 'unassigned')
$checks.twelve_threshold_relations_reconstruct = ($results.Count -eq 12 -and @($results | Where-Object { [Math]::Abs($_.effective_eave_threshold_for_both_generic_bands_ft - [Math]::Max($_.effective_eave_threshold_for_full_modeled_block_at_5ft_ft, $_.effective_eave_threshold_for_half_modeled_block_at_7ft_ft)) -gt 0.000001 }).Count -eq 0)
$checks.all_conditions_and_fixture_tests_unevaluated = (@($results | Where-Object { $_.condition_evaluated -or $_.room_classification_resolved -or $_.legal_required_floor_area_established -or $_.fixture_height_zone_checked -or $_.m06_b_assigned }).Count -eq 0)
$failures = @($checks.Keys | Where-Object { -not $checks[$_] })

$report = [ordered]@{
    milestone = 'M136'
    title = 'Symbolic finished-floor/eave/build-down sensitivity for hypothetical upper-suite room blocks'
    status = 'source-bound geometric conditions only; no datum values or compliance outcome assigned'
    selected_roof_cases = @('M83-X-12:12', 'M83-Y-12:12', 'M83-X-10:12')
    variables = [ordered]@{
        z_eave = 'unknown geometric eave elevation'
        z_finished_floor = 'unknown finished-floor elevation'
        b_eave = 'unknown distance from geometric eave datum to finished ceiling at eave; assumes a single scalar only for this algebraic relation'
        effective_finished_eave_ceiling = '(z_eave - z_finished_floor) - b_eave'
    }
    method = 'Re-express the M103 minimum/median ideal-roof rise thresholds as inequalities in unknown eave elevation, finished-floor elevation and scalar eave build-down. For each conditional room/case, the combined inequality is z_eave - z_finished_floor >= max(5 - minimumRise, 7 - medianRise) + b_eave. No value is supplied for any variable.'
    code_reference = [ordered]@{
        basis = 'Connecticut 2022 CSBC amended 2021 IRC R305.1, subject to unresolved municipality, permit code cycle, classification and applicability'
        generic_room_bands_ft = [ordered]@{ full_modeled_block_minimum = 5.0; at_least_half_modeled_block = 7.0 }
        source_note_sha256 = $sourceHashes.ct_code_research_note
        official_source = 'https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf?hash=D6499605AC2B583D21207216CBEDE5D5&rev=a59cc11db0564caaa5477bd696ee85f2'
    }
    assumptions = @(
        'The whole M78 schematic rectangle is used as a proxy area; it is not established as code-defined required floor area.',
        'Roof faces are ideal, zero-thickness planes with a relative eave datum; framing, finish, offsets, dormers and structure are not modeled.',
        'A single scalar eave build-down is used only to state the relationship. A spatially variable ceiling profile requires a defined surface and a new analysis.',
        'U-02 remains geometry-only because its room classification is unresolved; no M-06 fixture zone or showerhead zone is evaluated.'
    )
    source_hashes_sha256 = $sourceHashes
    checks = $checks
    failures = $failures
    result_count = $results.Count
    results = @($results)
    limitations = @(
        'This is an algebraic relationship, not a selected section, actual ceiling profile, room pass/fail or code-compliance result.',
        'No floor/eave datum, roof assembly thickness, ceiling build-down, pitch or ridge direction is selected.',
        'The three roof cases are study comparisons only; 38 1/3 x 40 ft remains hypothetical.',
        'M-06/B remains unassigned pending exact fixture geometry, applicable clearance basis, door/approach and plausible service routing.',
        'Selected-D geometry, Revit models, IFC exports and source families are not modified.'
    )
}
if ($failures.Count -gt 0) { throw "M136 failed checks: $($failures -join ', ')." }

$resolvedOutput = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$repoPrefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutput.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $resolvedOutput)) { New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null }
$jsonPath = Join-Path $resolvedOutput 'datum-builddown-sensitivity.json'
$csvPath = Join-Path $resolvedOutput 'datum-builddown-sensitivity.csv'
ConvertTo-Json -InputObject $report -Depth 10 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
Write-Output "M136 checks passed: $($checks.Count)/$($checks.Count); $($results.Count) rows; JSON SHA256 $((Get-Sha256 $jsonPath)); CSV SHA256 $((Get-Sha256 $csvPath))."
