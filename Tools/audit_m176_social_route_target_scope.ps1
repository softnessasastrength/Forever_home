param(
    [string]$OutputDirectory = 'Architecture/M176_Social_Route_Target_Scope_Audit_2026-10-31',
    [switch]$OverwriteGenerated
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outputPath = Join-Path $root $OutputDirectory
$m172Path = Join-Path $root 'Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'
$m173Path = Join-Path $root 'Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
$m173ChecksPath = Join-Path $root 'Architecture/Direction_D_Social_Route_Study_2026-10-27/checks.json'
$candidatePath = Join-Path $root 'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$selectedDPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'

foreach ($path in @($m172Path, $m173Path, $m173ChecksPath, $candidatePath, $selectedDPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source is missing: $path" }
}
if ((Test-Path -LiteralPath $outputPath) -and -not $OverwriteGenerated) {
    $existing = @(Get-ChildItem -LiteralPath $outputPath -Force -ErrorAction Stop)
    if ($existing.Count -gt 0) { throw "Refusing to overwrite generated output: $outputPath. Choose a new -OutputDirectory or explicitly pass -OverwriteGenerated." }
}
if (-not (Test-Path -LiteralPath $outputPath)) { New-Item -ItemType Directory -Path $outputPath | Out-Null }

$m172 = Get-Content -LiteralPath $m172Path -Raw | ConvertFrom-Json
$m173 = Get-Content -LiteralPath $m173Path -Raw | ConvertFrom-Json
$m173Checks = Get-Content -LiteralPath $m173ChecksPath -Raw | ConvertFrom-Json
$candidate = Get-Content -LiteralPath $candidatePath -Raw | ConvertFrom-Json
$selectedDHash = (Get-FileHash -LiteralPath $selectedDPath -Algorithm SHA256).Hash.ToLowerInvariant()

$checks = New-Object System.Collections.Generic.List[object]
function Add-AuditCheck([string]$Id, [bool]$Pass, [string]$Detail) {
    $script:checks.Add([ordered]@{ id=$Id; pass=$Pass; detail=$Detail })
}
function Get-Hash([string]$RelativePath) {
    $path = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Fingerprint source is missing: $RelativePath" }
    return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}

$m172SourcesMatch = $true
foreach ($entry in $m172.source_fingerprints_sha256.PSObject.Properties) {
    if ((Get-Hash $entry.Name) -ne ([string]$entry.Value).ToLowerInvariant()) { $m172SourcesMatch = $false }
}
$m173SourcesMatch = $true
foreach ($entry in $m173.source_fingerprints_sha256.PSObject.Properties) {
    if ((Get-Hash $entry.Name) -ne ([string]$entry.Value).ToLowerInvariant()) { $m173SourcesMatch = $false }
}

$m02 = @($candidate.plans.main | Where-Object id -eq 'M-02') | Select-Object -First 1
$m03 = @($candidate.plans.main | Where-Object id -eq 'M-03') | Select-Object -First 1
if ($null -eq $m02 -or $null -eq $m03) { throw 'Bath-first alternative must contain both M-02 and M-03.' }

$targetKitchen = $m172.targets.M02_kitchen_ft
$targetDining = $m172.targets.M03_dining_ft
$targetKitchenArea = [double]$m172.targets.M02_kitchen_area_sf
$targetDiningArea = [double]$m172.targets.M03_dining_area_sf
$candidateKitchenArea = [double]$m02.w * [double]$m02.d
$candidateDiningArea = [double]$m03.w * [double]$m03.d
$targetTotal = [double]$m172.targets.combined_target_area_sf
$candidateTotal = $candidateKitchenArea + $candidateDiningArea
$kitchenOverage = $candidateKitchenArea - $targetKitchenArea
$diningOverage = $candidateDiningArea - $targetDiningArea
$totalOverage = $candidateTotal - $targetTotal

Add-AuditCheck 'm172_input_schema' ($m172.schema -eq 'forever-home-m172-compact-social-space-constraints-v1') 'Compact target study is the expected source schema.'
Add-AuditCheck 'm173_input_schema' ($m173.schema -eq 'forever-home-direction-d-social-route-v1') 'Route study is the expected source schema.'
Add-AuditCheck 'target_sources_current' $m172SourcesMatch 'Every M172 fingerprint matches the current repository source.'
Add-AuditCheck 'route_sources_current' $m173SourcesMatch 'Every M173 fingerprint matches the current repository source.'
Add-AuditCheck 'candidate_room_blocks_present' ($m02.id -eq 'M-02' -and $m03.id -eq 'M-03') 'Bath-first comparison contains the expected kitchen and dining IDs.'
Add-AuditCheck 'owner_kitchen_target_14x12' ([Math]::Abs(($targetKitchen[0] * $targetKitchen[1]) - 168) -lt 0.001 -and $targetKitchenArea -eq 168) 'M172 source binds the owner-directed 14 x 12 ft / 168 sf kitchen target.'
Add-AuditCheck 'owner_dining_target_11x10' ([Math]::Abs(($targetDining[0] * $targetDining[1]) - 110) -lt 0.001 -and $targetDiningArea -eq 110) 'M172 source binds the owner-directed 11 x 10 ft / 110 sf dining target.'
Add-AuditCheck 'candidate_kitchen_area_recomputed' ([Math]::Abs($candidateKitchenArea - 277.3333333333333) -lt 0.01) 'M-02 area is recomputed from the broad alternative rectangle, not copied from its narrative.'
Add-AuditCheck 'candidate_dining_area_recomputed' ([Math]::Abs($candidateDiningArea - 158.6666666666667) -lt 0.01) 'M-03 area is recomputed from the broad alternative rectangle, not copied from its narrative.'
Add-AuditCheck 'broad_candidate_exceeds_both_targets' ($kitchenOverage -gt 0 -and $diningOverage -gt 0) 'Both route-study room blocks exceed their owner-directed area targets.'
Add-AuditCheck 'route_study_reports_29_checks' ($m173Checks.status -eq 'pass' -and $m173Checks.passed -eq 29 -and $m173Checks.total -eq 29) 'The historical route check report passes 29/29 for its own test geometry.'
Add-AuditCheck 'route_study_is_not_selected_geometry' ($m173.geometry.m06_window_b_remains_unassigned -eq $true -and $m173.status -like 'unapproved*') 'The route study is explicitly unapproved and retains M-06/B as unassigned.'
Add-AuditCheck 'selected_d_source_unchanged' ($selectedDHash -eq ([string]$m173.source_fingerprints_sha256.'Architecture/Selected_Design_Iteration_2026-10-27/study.json').ToLowerInvariant()) 'Current selected-D source matches the route study fingerprint.'

$report = [ordered]@{
    schema = 'forever-home-m176-social-route-target-scope-audit-v1'
    status = 'source-bound dimensional scope audit; no layout selected'
    inputs = [ordered]@{
        m172_study_sha256 = (Get-FileHash -LiteralPath $m172Path -Algorithm SHA256).Hash.ToLowerInvariant()
        m173_study_sha256 = (Get-FileHash -LiteralPath $m173Path -Algorithm SHA256).Hash.ToLowerInvariant()
        m173_checks_sha256 = (Get-FileHash -LiteralPath $m173ChecksPath -Algorithm SHA256).Hash.ToLowerInvariant()
        bath_first_candidate_sha256 = (Get-FileHash -LiteralPath $candidatePath -Algorithm SHA256).Hash.ToLowerInvariant()
        selected_d_sha256 = $selectedDHash
    }
    owner_program_targets = [ordered]@{
        M02_kitchen_ft = @([double]$targetKitchen[0], [double]$targetKitchen[1])
        M02_area_sf = $targetKitchenArea
        M03_dining_ft = @([double]$targetDining[0], [double]$targetDining[1])
        M03_area_sf = $targetDiningArea
        combined_area_sf = $targetTotal
        interpretation = 'Owner-directed program-area targets; not approved finished dimensions.'
    }
    m173_route_test_candidate = [ordered]@{
        M02_kitchen_ft = @([double]$m02.w, [double]$m02.d)
        M02_area_sf = [Math]::Round($candidateKitchenArea, 2)
        M02_over_target_sf = [Math]::Round($kitchenOverage, 2)
        M02_over_target_percent = [Math]::Round(100*$kitchenOverage/$targetKitchenArea, 2)
        M03_dining_ft = @([double]$m03.w, [double]$m03.d)
        M03_area_sf = [Math]::Round($candidateDiningArea, 2)
        M03_over_target_sf = [Math]::Round($diningOverage, 2)
        M03_over_target_percent = [Math]::Round(100*$diningOverage/$targetDiningArea, 2)
        combined_area_sf = [Math]::Round($candidateTotal, 2)
        combined_over_target_sf = [Math]::Round($totalOverage, 2)
        combined_over_target_percent = [Math]::Round(100*$totalOverage/$targetTotal, 2)
        status = [string]$candidate.status
    }
    route_evidence = [ordered]@{
        checks_passed = [int]$m173Checks.passed
        checks_total = [int]$m173Checks.total
        route_obstacle_intersections = [int]$m173.geometry.route_obstacle_intersection_count
        interpretation = 'The route result is valid only for the broader M173 alternative extents above; it does not test the 14 x 12 ft and 11 x 10 ft program targets.'
    }
    conclusion = 'M173 route/furnishing checks do not establish fit at the owner-directed compact kitchen and dining area targets. The 277.33 sf kitchen and 158.67 sf dining blocks are 65.08% and 44.24% larger than their respective 168 sf and 110 sf targets. Their 29/29 route pass remains a broad, unapproved alternative result.'
    next_design_gate = 'Create a separate connected open-plan proposal bound to 168 sf kitchen and 110 sf dining program areas. Preserve room-area targets, distinguish area zones from fixed rectangles, include the documented 8 x 4 ft island, source-sized perimeter run, seating proxy, dining furniture, half-wall/opening, porch door reservation and connected route. Report any geometry that spills between conceptual zones; do not edit selected-D or claim the compact targets already fit.'
    limitations = @(
        'This is an audit of source scope and area arithmetic, not a replacement layout or a geometry fit.',
        'The M173 route script tests living-to-porch circulation and does not verify a route from the island work face.',
        'Appliance door operation, exact stool occupied envelope, wall construction, door clear width, thresholds, services, site, and professional review remain unresolved.',
        'M-06/B remains unassigned; no code-compliance, structural-safety, certification, permit, or construction-readiness claim follows.'
    )
}
$passed = @($checks | Where-Object pass).Count
$checkStatus = 'fail'
if ($passed -eq $checks.Count) { $checkStatus = 'pass' }
$checkReport = [ordered]@{ status = $checkStatus; passed=$passed; total=$checks.Count; checks=$checks.ToArray() }

$csvRows = @(
    [pscustomobject]@{ program_id='M-02'; program_area_sf=$targetKitchenArea; candidate_width_ft=[double]$m02.w; candidate_depth_ft=[double]$m02.d; candidate_area_sf=[Math]::Round($candidateKitchenArea,2); over_target_sf=[Math]::Round($kitchenOverage,2); over_target_percent=[Math]::Round(100*$kitchenOverage/$targetKitchenArea,2) },
    [pscustomobject]@{ program_id='M-03'; program_area_sf=$targetDiningArea; candidate_width_ft=[double]$m03.w; candidate_depth_ft=[double]$m03.d; candidate_area_sf=[Math]::Round($candidateDiningArea,2); over_target_sf=[Math]::Round($diningOverage,2); over_target_percent=[Math]::Round(100*$diningOverage/$targetDiningArea,2) },
    [pscustomobject]@{ program_id='combined'; program_area_sf=$targetTotal; candidate_width_ft=$null; candidate_depth_ft=$null; candidate_area_sf=[Math]::Round($candidateTotal,2); over_target_sf=[Math]::Round($totalOverage,2); over_target_percent=[Math]::Round(100*$totalOverage/$targetTotal,2) }
)

$report | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $outputPath 'm176-social-route-target-scope.json') -Encoding UTF8
$checkReport | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath (Join-Path $outputPath 'm176-checks.json') -Encoding UTF8
$csvRows | ConvertTo-Csv -NoTypeInformation | Set-Content -LiteralPath (Join-Path $outputPath 'm176-area-comparison.csv') -Encoding UTF8
Write-Output ("M176 target-scope audit: {0}/{1} checks passed; M02 {2:F2} sf vs {3:F0}, M03 {4:F2} sf vs {5:F0}; route study remains bound to larger candidate blocks." -f $passed,$checks.Count,$candidateKitchenArea,$targetKitchenArea,$candidateDiningArea,$targetDiningArea)
if ($passed -ne $checks.Count) { exit 1 }
