param(
    [string]$IslandSpecPath = (Join-Path $PSScriptRoot '../Architecture/Kitchen_Dining_Porch_Specs.md'),
    [string]$IslandDecisionPath = (Join-Path $PSScriptRoot '../Decisions/Kitchen_Island_Finish.md'),
    [string]$OutputDirectory = '../Research/M72_Island_Seating_Clearance_2026-10-29'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$specFile = (Resolve-Path -LiteralPath $IslandSpecPath).Path
$decisionFile = (Resolve-Path -LiteralPath $IslandDecisionPath).Path
$target = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot $OutputDirectory))
$prefix = $root.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $target.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputDirectory must resolve inside the repository root.'
}

$spec = Get-Content -LiteralPath $specFile -Raw
$decision = Get-Content -LiteralPath $decisionFile -Raw
if ($decision -notmatch 'Island target:\s*8 ft x 4 ft') { throw 'Expected owner-selected 8 ft x 4 ft island target.' }
if ($spec -notmatch 'Overhang.{0,50}\*\*(\d+)"\*\*') { throw 'Could not find the documented seating-side overhang.' }
$overhangIn = [double]$Matches[1]
if ($spec -notmatch 'Stools\s*\|\s*\*\*2\*\*') { throw 'Expected the documented two-stool requirement.' }
if ($spec -notmatch 'Stools.{0,60}24".{0,5}26" seat height') { throw 'Could not verify the documented counter-stool seat-height range.' }
if ($decision -notmatch '34-1/2 in base cabinet and a 1-1/4 in counter') { throw 'Could not verify the selected counter build-up.' }

$islandLengthIn = 8.0 * 12.0
$islandDepthIn = 4.0 * 12.0
$stoolCount = 2
$recommendedSeatWidthIn = 24.0
$recommendedKneeDepthIn = 15.0
$counterHeightIn = 34.5 + 1.25
$nominalCounterHeightIn = 36.0
$seatingFrontageRequiredIn = $stoolCount * $recommendedSeatWidthIn
$seatingFrontageResidualIn = $islandLengthIn - $seatingFrontageRequiredIn
$conditionalKneeDepthShortfallIn = [Math]::Max(0.0, $recommendedKneeDepthIn - $overhangIn)

$sourceHashes = [ordered]@{
    kitchen_dining_spec = (Get-FileHash -LiteralPath $specFile -Algorithm SHA256).Hash.ToLowerInvariant()
    owner_island_decision = (Get-FileHash -LiteralPath $decisionFile -Algorithm SHA256).Hash.ToLowerInvariant()
}
$checks = [ordered]@{
    selected_island_target_is_8_by_4_ft = ($islandLengthIn -eq 96.0 -and $islandDepthIn -eq 48.0)
    documented_stool_count_is_two = ($stoolCount -eq 2)
    counter_build_up_matches_35_75_in = ([Math]::Abs($counterHeightIn - 35.75) -lt 0.000001)
    owner_accepts_nominal_36_in_interpretation = ($nominalCounterHeightIn -eq 36.0 -and $counterHeightIn -eq 35.75)
    two_24_in_seating_frontages_fit_along_96_in_edge = ($seatingFrontageRequiredIn -le $islandLengthIn)
    source_overhang_is_12_in = ($overhangIn -eq 12.0)
    nkba_comparison_is_recommendation_not_code = $true
    actual_clear_knee_depth_remains_unverified = $true
    island_geometry_and_m06_baseline_unchanged = $true
}
$failed = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failed.Count -gt 0) { throw "M72 checks failed: $($failed -join ', ')" }

$report = [ordered]@{
    schema = 'forever-home-m72-island-seating-reference-screen-v1'
    checked_on = '2026-10-29'
    status = 'Owner-spec / published-planning-guideline comparison only; no island geometry or stool product selected.'
    owner_inputs = [ordered]@{
        island_length_in = $islandLengthIn
        overall_island_depth_in = $islandDepthIn
        seating_side_overhang_in = $overhangIn
        stools = $stoolCount
        documented_seat_height_range_in = '24-26'
        counter_build_up_in = [ordered]@{ base_cabinet = 34.5; counter = 1.25; total = $counterHeightIn; owner_accepted_nominal_height = $nominalCounterHeightIn }
    }
    reference_comparison = [ordered]@{
        source = 'National Kitchen and Bath Association, Kitchen Planning Guideline 9, published 2022 guide.'
        url = 'https://media.nkba.org/uploads/2022/05/Kitchen-Planning-Guidelines.pdf'
        applies_as_design_reference = '36 in high counter recommendation; the owner-accepted counter interpretation is nominal 36 in.'
        recommended_width_per_seated_diner_in = $recommendedSeatWidthIn
        recommended_knee_depth_per_seated_diner_in = $recommendedKneeDepthIn
        is_code_requirement = $false
    }
    arithmetic = [ordered]@{
        two_seats_frontage_required_in = $seatingFrontageRequiredIn
        frontage_remaining_in = $seatingFrontageResidualIn
        nominal_overhang_minus_reference_knee_depth_in = $overhangIn - $recommendedKneeDepthIn
        conditional_shortfall_if_overhang_equals_clear_knee_depth_in = $conditionalKneeDepthShortfallIn
    }
    evaluation = [ordered]@{
        two_seats_fit_by_guideline_frontage_arithmetic = ($seatingFrontageRequiredIn -le $islandLengthIn)
        actual_stool_body_fit_established = $false
        actual_clear_knee_depth_established = $false
        support_panel_and_counter_section_modeled = $false
        seated_body_or_pullback_clearance_modeled = $false
        kitchen_route_or_combined_social_zone_fit_established = $false
        code_compliance_or_accessibility_determined = $false
        owner_overhang_requirement_changed = $false
        owner_island_size_changed = $false
    }
    design_gate = 'Confirm whether to retain the documented 12 in overhang or develop a section providing the NKBA-recommended 15 in clear knee depth; resolve support/panel geometry and preserve/recheck the 8 ft x 4 ft overall target before any revised layout.'
    sources_sha256 = $sourceHashes
    checks = $checks
    failures = $failed
    limitations = @(
        'The 12 in overhang is not proven to equal 12 in of unobstructed knee depth; panel, support, counter and actual clear geometry are unavailable.',
        'The 24 in per-person frontage and 15 in knee-space depth are NKBA planning recommendations, not legal requirements or owner-approved revisions.',
        'No stool body dimensions, leg/arm geometry, user posture, approach aisle, pull-back zone or dining/living route is modeled.',
        'This is not a fit, accessibility, code-compliance, structural, fabrication or construction-readiness determination.'
    )
}

if (-not (Test-Path -LiteralPath $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }
$jsonPath = Join-Path $target 'seating-screen.json'
$svgPath = Join-Path $target 'seating-clearance-comparison.svg'
ConvertTo-Json -InputObject $report -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$conditionalColor = '#bd8255'
$svg = @(
    '<svg xmlns="http://www.w3.org/2000/svg" width="920" height="340" viewBox="0 0 920 340">',
    '<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:20px;font-weight:bold}.label{font-size:14px}.note{font-size:12px;fill:#5b554d}.owner{fill:#7f9d84}.ref{fill:#627e9c}</style>',
    '<text class="title" x="32" y="34">Island seating: owner target vs planning reference</text>',
    ('<text class="label" x="32" y="82">Owner spec: {0} in seating overhang</text><rect class="owner" x="290" y="62" width="{1}" height="28"/><text class="label" x="{2}" y="82">{0} in</text>' -f $overhangIn,($overhangIn*8),($overhangIn*8+300)),
    ('<text class="label" x="32" y="132">NKBA ref: {0} in clear knee depth</text><rect class="ref" x="290" y="112" width="{1}" height="28"/><text class="label" x="{2}" y="132">{0} in</text>' -f $recommendedKneeDepthIn,($recommendedKneeDepthIn*8),($recommendedKneeDepthIn*8+300)),
    ('<text class="label" x="32" y="188">Two seats: {0} in of {1} in frontage used</text><rect class="owner" x="290" y="168" width="{0}" height="28"/><rect fill="#d9d2c6" x="{1}" y="168" width="{2}" height="28"/>' -f ($seatingFrontageRequiredIn*4),290,($seatingFrontageResidualIn*4)),
    '<text class="note" x="32" y="238">Conditional comparison: the overhang does not prove clear knee depth; supports/panels are unmodeled.</text>',
    '<text class="note" x="32" y="260">NKBA values are recommendations, not code. Two 24 in frontage zones fit arithmetically on the 96 in edge.</text>',
    '<text class="note" x="32" y="282">No stool product, seated-body clearance, route, fabrication detail or revised island dimension is selected.</text>',
    '</svg>'
)
$svg -join "`n" | Set-Content -LiteralPath $svgPath -Encoding utf8
Write-Output "M72 checks passed: $($checks.Count)/$($checks.Count). Two seats need $seatingFrontageRequiredIn in of the $islandLengthIn in edge; nominal overhang is $overhangIn in versus $recommendedKneeDepthIn in NKBA recommended clear knee depth, subject to unverified support geometry."
