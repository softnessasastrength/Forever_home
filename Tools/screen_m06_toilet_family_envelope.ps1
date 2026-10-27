param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_Champion_PRO_Family_Envelope_Screen_2026-10-27.json')
)

$ErrorActionPreference = 'Stop'
$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$m06 = $study.selection.main_public_bath

if ($study.layout_variant -ne 'OwnerSelectedD') {
    throw "Expected the owner-selected D study; found layout variant '$($study.layout_variant)'."
}
if ($m06.id -ne 'M-06' -or $m06.type -ne 'half bath') {
    throw 'The selected-D study does not identify M-06 as a half bath.'
}
if ($m06.first_fit_candidate -ne 'east_of_core') {
    throw "Expected the owner-selected pantry-side search window B (east_of_core); found '$($m06.first_fit_candidate)'."
}
if ($m06.footprint -ne 'TBD' -or $m06.position -ne 'TBD') {
    throw 'M-06 is no longer unassigned. Review the study before running this proxy-only screen.'
}

# Nominal envelope from American Standard's 211AA.104 manufacturer sheet.
# This is a predecessor-family proxy, not verified geometry for 610AA001.020.
$proxy = [ordered]@{
    target_sku = '610AA001.020'
    proxy_series = '211AA.104'
    proxy_width_in = 19.0
    proxy_projection_in = 30.25
    proxy_height_in = 30.875
    exact_target_sku_geometry_verified = $false
    source = 'https://lixil.cdn.celum.cloud/167631_as_us_bath_spec__211A%20(7076)_0_original.pdf'
}

$windowResults = @()
foreach ($window in $m06.search_windows) {
    if ($window.status -notlike 'Unassigned room-block gap only*') {
        throw "Search window '$($window.id)' is no longer an unassigned gap. Review the study before using this screen."
    }
    if ([double]$window.w -le 0 -or [double]$window.d -le 0 -or [double]$window.gross_area_sf -le 0) {
        throw "Search window '$($window.id)' has non-positive bounds or area."
    }
    $widthIn = [double]$window.w * 12.0
    $depthIn = [double]$window.d * 12.0
    $orientations = @(
        [ordered]@{ rotation_deg = 0; body_width_in = $proxy.proxy_width_in; body_depth_in = $proxy.proxy_projection_in },
        [ordered]@{ rotation_deg = 90; body_width_in = $proxy.proxy_projection_in; body_depth_in = $proxy.proxy_width_in }
    )
    $orientationResults = @()
    foreach ($orientation in $orientations) {
        $bodyWidthFt = $orientation.body_width_in / 12.0
        $bodyDepthFt = $orientation.body_depth_in / 12.0
        $fits = ($bodyWidthFt -le [double]$window.w) -and ($bodyDepthFt -le [double]$window.d)
        $orientationResults += [ordered]@{
            rotation_deg = $orientation.rotation_deg
            body_width_in = $orientation.body_width_in
            body_depth_in = $orientation.body_depth_in
            contained_in_gross_search_window = $fits
            remaining_width_in = [Math]::Round(($widthIn - $orientation.body_width_in), 3)
            remaining_depth_in = [Math]::Round(($depthIn - $orientation.body_depth_in), 3)
            allowable_origin_x_ft = if ($fits) { @([Math]::Round([double]$window.x, 6), [Math]::Round(([double]$window.x + [double]$window.w - $bodyWidthFt), 6)) } else { $null }
            allowable_origin_y_ft = if ($fits) { @([Math]::Round([double]$window.y, 6), [Math]::Round(([double]$window.y + [double]$window.d - $bodyDepthFt), 6)) } else { $null }
        }
    }
    $windowResults += [ordered]@{
        id = $window.id
        label = $window.label
        gross_width_ft = [double]$window.w
        gross_depth_ft = [double]$window.d
        gross_area_sf = [double]$window.gross_area_sf
        remains_unassigned_room_block_gap = $true
        orientations = $orientationResults
    }
}

$b = @($windowResults | Where-Object id -eq 'east_of_core')
if ($b.Count -ne 1 -or @($b[0].orientations | Where-Object { -not $_.contained_in_gross_search_window }).Count -gt 0) {
    throw 'The predecessor-family body envelope does not fit wholly inside B in both tested plan orientations.'
}

$report = [ordered]@{
    schema = 'forever-home-m06-family-envelope-screen-v1'
    result = 'PASS: predecessor-family rectangular body envelope is contained in B in both tested plan orientations.'
    study = [System.IO.Path]::GetFileName($studyFile)
    study_sha256 = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
    study_layout_variant = $study.layout_variant
    owner_selected_candidate = 'east_of_core'
    target_candidate = $proxy
    search_windows = $windowResults
    evaluated = [ordered]@{
        body_envelope_containment_only = $true
        exact_610aa_geometry = $false
        half_bath_clearances = $false
        vanity_or_lavatory = $false
        door_or_swing = $false
        user_approach_or_hall_route = $false
        wall_location_or_rough_in = $false
        drain_vent_or_service_path = $false
        m06_room_assignment = $false
        ifc_export = $false
    }
    limitations = @(
        'B is an unassigned 13 ft 2 in by 7 ft room-block gap, not a bathroom or clear interior dimension.',
        'The measured plan envelope is from predecessor series 211AA.104 and is not verified for target SKU 610AA001.020.',
        'This rectangular containment screen does not establish a usable fixture layout, required clearances, a room footprint, plumbing feasibility, code compliance, or accessibility.'
    )
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    [System.IO.Path]::GetFullPath($OutputPath)
} else {
    [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath))
}
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$json = ConvertTo-Json -InputObject $report -Depth 12
[System.IO.File]::WriteAllText($resolvedOutput, $json + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: M-06 family-envelope screen saved to $resolvedOutput"
