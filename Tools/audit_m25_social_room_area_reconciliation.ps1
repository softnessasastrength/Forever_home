param(
    [string]$OutputDirectory = 'Architecture/M25_Social_Room_Area_Reconciliation_2026-10-28'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$studyPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$reviewPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/program-area-review.csv'
$programPath = Join-Path $root 'Requirements/Room_Program.md'
$decisionPath = Join-Path $root 'Decisions/2026-10-27_Selected_Architectural_Direction_D.md'
$gatePath = Join-Path $root 'Architecture/Direction_D_Main_Floor_Design_Gates_2026-10-27.md'
foreach ($path in @($studyPath, $reviewPath, $programPath, $decisionPath, $gatePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required M25 source is missing: $path" }
}

$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$review = @(Import-Csv -LiteralPath $reviewPath | Where-Object { $_.id -in @('M-01', 'M-02', 'M-03') })
$programText = Get-Content -LiteralPath $programPath -Raw -Encoding utf8
$roomIds = @('M-01', 'M-02', 'M-03')
$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check([string]$Name, [bool]$Passed, [string]$Detail) {
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; detail = $Detail })
}

$layoutIsSelectedD = $study.layout_variant -eq 'OwnerSelectedD'
Add-Check 'study_is_owner_selected_d' $layoutIsSelectedD "layout_variant=$($study.layout_variant)"
Add-Check 'area_review_has_exactly_three_social_rooms' ($review.Count -eq 3) "rows=$($review.Count)"
Add-Check 'area_review_has_expected_room_ids_once_each' (@($review.id | Sort-Object -Unique).Count -eq 3 -and @($review.id | Sort-Object) -join ',' -eq 'M-01,M-02,M-03') "ids=$(@($review.id | Sort-Object) -join ',')"

$rooms = [System.Collections.Generic.List[object]]::new()
$sourceAreasMatch = $true
$validRanges = $true
$programRangesMatch = $true
foreach ($identifier in $roomIds) {
    $block = @($study.plans.main | Where-Object { $_.id -eq $identifier })
    $row = @($review | Where-Object { $_.id -eq $identifier })
    if ($block.Count -ne 1 -or $row.Count -ne 1) {
        $sourceAreasMatch = $false
        $validRanges = $false
        continue
    }
    $area = [double]$block[0].w * [double]$block[0].d
    $minimum = [double]$row[0].minimum_sf
    $maximum = [double]$row[0].maximum_sf
    $rangeSeparator = [char]0x2013
    $programPattern = "(?m)^\|\s*$([regex]::Escape($identifier))\s*\|[^\r\n]*?\|\s*(?<minimum>\d+)\s*(?:$rangeSeparator|-)\s*(?<maximum>\d+)\s*sf"
    $programMatch = [regex]::Match($programText, $programPattern)
    if (-not $programMatch.Success -or
        [double]$programMatch.Groups['minimum'].Value -ne $minimum -or
        [double]$programMatch.Groups['maximum'].Value -ne $maximum) {
        $programRangesMatch = $false
    }
    $reportedArea = [double]$row[0].area_sf
    if ([math]::Abs($area - $reportedArea) -gt 0.01) { $sourceAreasMatch = $false }
    if ($minimum -le 0 -or $maximum -lt $minimum) { $validRanges = $false }
    $excess = [math]::Max([double]0.0, [double]($area - $maximum))
    $rooms.Add([ordered]@{
        id = $identifier
        name = [string]$block[0].name
        selected_d_study_area_sf = [math]::Round($area, 2)
        program_range_sf = [ordered]@{ minimum = $minimum; maximum = $maximum }
        above_program_max_sf = [math]::Round($excess, 2)
        above_max_percent = if ($excess -gt 0) { [math]::Round(($excess / $maximum) * 100, 1) } else { 0 }
        disposition = 'study variance only; no room-size revision or layout adopted'
    })
}
Add-Check 'study_areas_match_generated_program_review' $sourceAreasMatch 'Area arithmetic uses source block width multiplied by depth and compares it with the generated review CSV.'
Add-Check 'program_ranges_are_present_and_ordered' $validRanges 'Ranges are read from the generated review of the checked-in room program.'
Add-Check 'generated_area_review_ranges_match_room_program_source' $programRangesMatch 'The three min/max ranges are cross-checked against the Requirements/Room_Program.md table.'

$currentTotal = [double](($rooms | ForEach-Object { [double]$_.selected_d_study_area_sf } | Measure-Object -Sum).Sum)
$minimumTotal = [double](($rooms | ForEach-Object { $_.program_range_sf.minimum } | Measure-Object -Sum).Sum)
$maximumTotal = [double](($rooms | ForEach-Object { $_.program_range_sf.maximum } | Measure-Object -Sum).Sum)
$totalExcess = [math]::Round([math]::Max([double]0.0, [double]($currentTotal - $maximumTotal)), 2)
$reductionToMinimum = [math]::Round([math]::Max([double]0.0, [double]($currentTotal - $minimumTotal)), 2)
Add-Check 'current_social_area_matches_derived_total' ([math]::Abs($currentTotal - 676.0) -lt 0.01) "current_total_sf=$currentTotal"
Add-Check 'program_range_total_matches_documented_bounds' ($minimumTotal -eq 420 -and $maximumTotal -eq 525) "range_total_sf=$minimumTotal..$maximumTotal"
Add-Check 'aggregate_maximum_variance_is_151_sf' ([math]::Abs($totalExcess - 151.0) -lt 0.01) "above_combined_max_sf=$totalExcess"
Add-Check 'combined_minimum_reduction_is_256_sf' ([math]::Abs($reductionToMinimum - 256.0) -lt 0.01) "reduction_to_combined_minimum_sf=$reductionToMinimum"
Add-Check 'no_layout_or_baseline_mutation_requested' ($study.layout_variant -eq 'OwnerSelectedD') 'This report is an area comparison; it emits no room coordinates or replacement study.'

$status = if (@($checks | Where-Object { -not $_.passed }).Count -eq 0) { 'pass' } else { 'fail' }
$report = [ordered]@{
    schema = 'forever-home.m25-social-room-area-reconciliation.v1'
    status = $status
    checks_passed = @($checks | Where-Object { $_.passed }).Count
    checks_total = $checks.Count
    checks = $checks
    source_fingerprints_sha256 = [ordered]@{
        selected_d_study = (Get-FileHash -LiteralPath $studyPath -Algorithm SHA256).Hash.ToLowerInvariant()
        generated_program_area_review = (Get-FileHash -LiteralPath $reviewPath -Algorithm SHA256).Hash.ToLowerInvariant()
        room_program = (Get-FileHash -LiteralPath $programPath -Algorithm SHA256).Hash.ToLowerInvariant()
        selected_direction_decision = (Get-FileHash -LiteralPath $decisionPath -Algorithm SHA256).Hash.ToLowerInvariant()
        main_floor_design_gates = (Get-FileHash -LiteralPath $gatePath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    comparison = [ordered]@{
        rooms = @($rooms)
        selected_d_social_room_area_sf = [math]::Round($currentTotal, 2)
        program_combined_range_sf = [ordered]@{ minimum = $minimumTotal; maximum = $maximumTotal }
        above_combined_program_max_sf = $totalExcess
        reduction_to_combined_program_minimum_sf = $reductionToMinimum
        reduction_percent_of_current_area_to_reach_combined_max = [math]::Round(($totalExcess / $currentTotal) * 100, 1)
        reduction_percent_of_current_area_to_reach_combined_minimum = [math]::Round(($reductionToMinimum / $currentTotal) * 100, 1)
    }
    decision_options = @(
        [ordered]@{
            id = 'retain_current_study_areas_for_one_furnished_fit_test'
            status = 'proposal; not selected'
            effect = 'Keeps the selected-D room-block areas while testing furniture, hearth, kitchen equipment, routes and storage; records that all three social rooms exceed preliminary program ceilings.'
        },
        [ordered]@{
            id = 'retarget_within_documented_program_ranges'
            status = 'proposal; not selected'
            effect = "Brings the three-room total to no more than $maximumTotal sf, a derived reduction of $totalExcess sf from current blocks; new dimensions and positions require a separately authorized study."
        }
    )
    limitations = @(
        'The documented program ranges are preliminary study references, not code or professional standards.',
        'The 40 x 42 ft shell is an owner-selected test envelope; this comparison does not calculate gross area, circulation, wall thickness or a finished building footprint.',
        'The study is room-block geometry. No wall, opening, furniture, appliance, structural or MEP geometry is created.',
        'M-06 remains unassigned and is not counted in this social-room subtotal.'
    )
}

$target = Join-Path $root $OutputDirectory
New-Item -ItemType Directory -Path $target -Force | Out-Null
$outputPath = Join-Path $target 'area-reconciliation.json'
$json = ConvertTo-Json -InputObject $report -Depth 14
Set-Content -LiteralPath $outputPath -Value $json -Encoding utf8
Write-Output "M25 social-room area reconciliation: $($report.checks_passed)/$($report.checks_total) checks passed."
Write-Output $outputPath
if ($report.status -ne 'pass') { exit 1 }
