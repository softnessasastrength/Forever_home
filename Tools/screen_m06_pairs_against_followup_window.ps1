param(
    [string]$ProposalPath = (Join-Path $PSScriptRoot '../Architecture/House_Design_Iteration_2026-10-28/study.json'),
    [string]$PairScreenPath = (Join-Path $PSScriptRoot '../Research/M06_Predecessor_Toilet_Sink_Gross_Pair_Screen_2026-10-28.json'),
    [string]$SelectedDPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json')
)

$ErrorActionPreference = 'Stop'
$proposalFile = (Resolve-Path -LiteralPath $ProposalPath).Path
$pairFile = (Resolve-Path -LiteralPath $PairScreenPath).Path
$selectedDFile = (Resolve-Path -LiteralPath $SelectedDPath).Path
$proposal = Get-Content -LiteralPath $proposalFile -Raw | ConvertFrom-Json
$pairs = Get-Content -LiteralPath $pairFile -Raw | ConvertFrom-Json
$selectedD = Get-Content -LiteralPath $selectedDFile -Raw | ConvertFrom-Json

if ($proposal.schema -ne 'forever-home.owner-followup-design-study.v1' -or
    $proposal.M06.status -ne 'unassigned; no footprint, position, fixture or service route') {
    throw 'Expected the separate owner-follow-up proposal with M-06 explicitly unassigned.'
}
if ($pairs.schema -ne 'forever-home-m06-predecessor-toilet-sink-gross-pair-screen-v1' -or
    $pairs.evaluated.exact_610aa001_020_geometry -ne $false -or
    $pairs.evaluated.m06_assignment -ne $false) {
    throw 'Expected the versioned predecessor-only 16-pair screen with no current-SKU geometry or assignment.'
}
$selectedDHash = (Get-FileHash -LiteralPath $selectedDFile -Algorithm SHA256).Hash.ToLowerInvariant()
$proposalHash = (Get-FileHash -LiteralPath $proposalFile -Algorithm SHA256).Hash.ToLowerInvariant()
$pairHash = (Get-FileHash -LiteralPath $pairFile -Algorithm SHA256).Hash.ToLowerInvariant()
if ($proposal.source_selected_D_sha256 -ne $selectedDHash -or $pairs.study_sha256 -ne $selectedDHash) {
    throw 'The proposal, selected-D source and M54 pair report do not share the recorded source identity.'
}

$window = $proposal.M06.first_fit_window
if ($window.id -ne 'M06-B' -or $window.status -ne 'unassigned search window only; not M-06 geometry') {
    throw 'The follow-up M-06 first-fit window is missing or no longer marked as an unassigned search gap.'
}
$grossWidthIn = [Math]::Round(([double]$window.width_ft * 12.0), 3)
$grossDepthIn = [Math]::Round(([double]$window.depth_ft * 12.0), 3)
$results = @()
foreach ($pair in $pairs.fixture_pairs) {
    $requiredWidthIn = [double]$pair.required_gross_width_in
    $requiredDepthIn = [double]$pair.required_gross_depth_in_including_front_strip
    $contained = $requiredWidthIn -le $grossWidthIn -and $requiredDepthIn -le $grossDepthIn
    $results += [ordered]@{
        sink_id = [string]$pair.sink_id
        sink_name = [string]$pair.sink_name
        sink_rotation_deg = [int]$pair.sink_rotation_deg
        predecessor_toilet_proxy_sku = [string]$pairs.toilet_proxy.proxy_predecessor_sku
        selected_target_sku = [string]$pairs.toilet_proxy.selected_target_sku
        exact_target_sku_geometry_verified = $false
        required_gross_width_in = $requiredWidthIn
        required_gross_depth_in_including_front_strip = $requiredDepthIn
        contained_in_followup_B_gross_window = $contained
        remaining_gross_width_in = [Math]::Round(($grossWidthIn - $requiredWidthIn), 3)
        remaining_gross_depth_in = [Math]::Round(($grossDepthIn - $requiredDepthIn), 3)
        inherited_pair_assumptions = [string]$pair.assumption
    }
}
$passing = @($results | Where-Object { $_.contained_in_followup_B_gross_window }).Count
$status = if ($passing -eq $results.Count) { 'PASS: all source-screened predecessor-toilet/lavatory boxes fit the follow-up B gross window under the inherited hypothetical same-wall assumptions.' } else { "PARTIAL: $passing of $($results.Count) source-screened fixture boxes fit the follow-up B gross window under the inherited hypothetical same-wall assumptions." }

$report = [ordered]@{
    schema = 'forever-home-m06-followup-window-pair-recheck-v1'
    result = $status
    source_fingerprints_sha256 = [ordered]@{
        selected_D_study = $selectedDHash
        owner_followup_proposal = $proposalHash
        predecessor_pair_screen = $pairHash
    }
    followup_window = [ordered]@{
        id = [string]$window.id
        label = 'Pantry-side B in separate owner-follow-up room-block proposal'
        x_ft = [double]$window.x_ft
        y_ft = [double]$window.y_ft
        gross_width_in = $grossWidthIn
        gross_depth_in = $grossDepthIn
        gross_area_sf = [double]$window.area_sf
        status = [string]$window.status
        remains_unassigned = $true
    }
    source_screen_geometry = [ordered]@{
        pair_report = [System.IO.Path]::GetFileName($pairFile)
        pair_count = $results.Count
        source_screen_window_in = @([double]$pairs.search_window.gross_width_in,[double]$pairs.search_window.gross_depth_in)
        followup_window_is_smaller = ($grossWidthIn -lt [double]$pairs.search_window.gross_width_in)
    }
    evaluated = [ordered]@{
        predecessor_toilet_and_research_sink_rectangles_only = $true
        pair_containment_count = $passing
        candidate_product_selected = $false
        current_610aa001_020_geometry = $false
        actual_room_fit = $false
        M06_assignment = $false
        door_swing_hall_approach_or_privacy = $false
        walls_or_usable_clear_dimensions = $false
        installation_or_service_route = $false
        code_compliance_or_accessibility = $false
        Revit_or_IFC = $false
    }
    fixture_pairs = $results
    limitations = @(
        'The follow-up M-06-B rectangle is an unassigned gross room-block gap, not actual room or wall geometry.',
        'The inherited WC is the 211AA104.020 predecessor proxy; current 610AA001.020 plan dimensions remain unverified.',
        'The lavatory candidates are research-only; some exact family/type geometry remains uninspected and no candidate is selected.',
        'The inherited same-wall clearances are rectangular screening abstractions, not an actual clearance polygon or door/approach layout.',
        'No wall build-up, opening, swing, hall approach, privacy, finish, rough-in, water/drain/vent route, accessibility scope or local code applicability is tested.',
        'Passing gross containment does not assign M-06 or establish a usable, compliant, accessible, or buildable bathroom.'
    )
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$json = ConvertTo-Json -InputObject $report -Depth 12
[System.IO.File]::WriteAllText($resolvedOutput, $json + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "$status ($passing/$($results.Count)); saved to $resolvedOutput"
