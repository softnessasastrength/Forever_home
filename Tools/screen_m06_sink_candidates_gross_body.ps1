param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_Sink_Gross_Body_Screen_2026-10-28.json')
)

$ErrorActionPreference = 'Stop'
$checks = 0
$failures = [System.Collections.Generic.List[string]]::new()
function Assert-Check([bool]$Condition, [string]$Message) {
    $script:checks++
    if (-not $Condition) { $script:failures.Add($Message) }
}

$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$studyHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$expectedStudyHash = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
$m06 = $study.selection.main_public_bath
$window = @($m06.search_windows | Where-Object id -eq 'east_of_core')

Assert-Check ($studyHash -eq $expectedStudyHash) 'Selected-D study fingerprint changed; review the source before relying on this screen.'
Assert-Check ($study.layout_variant -eq 'OwnerSelectedD' -and $m06.id -eq 'M-06' -and $m06.type -eq 'half bath') 'Input is not the owner-selected D M-06 half-bath study.'
Assert-Check ($m06.footprint -eq 'TBD' -and $m06.position -eq 'TBD' -and $m06.first_fit_candidate -eq 'east_of_core') 'M-06 is assigned or the first-fit priority changed; review before proceeding.'
Assert-Check ($window.Count -eq 1 -and $window[0].status -like 'Unassigned room-block gap only*') 'Pantry-side B is not the documented unassigned gross gap.'

$widthFt = [double]$window[0].w
$depthFt = [double]$window[0].d
$widthIn = $widthFt * 12
$depthIn = $depthFt * 12
Assert-Check ([Math]::Abs($widthIn - 158.0) -lt 0.000001 -and [Math]::Abs($depthIn - 84.0) -lt 0.000001) 'Pantry-side B no longer derives to the documented 158 x 84 in gross block.'

# Product dimensions below are nominal overall body dimensions from the cited manufacturer sources.
# They are not Revit measurements, interior clear dimensions, fixture clearances, or layout instructions.
$candidates = @(
    [ordered]@{
        id = 'american-standard-evolution-0467004.020'
        name = 'American Standard Evolution 22-in 4-in-centerset pedestal lavatory'
        status = 'research-only; discontinued; exact family type-to-SKU and assembly mapping unresolved'
        source = 'https://www.americanstandard-us.com/products/22-inch-evolution-r-4-inch-centerset-pedestal-sink-top'
        dimensions_source = 'Manufacturer product page; nominal overall 22 x 17.5 x 34.25 in'
        width_in = 22.0
        depth_in = 17.5
        height_in = 34.25
        candidate_rfa_geometry_measured = $true
        rfa_type_to_sku_mapping_verified = $false
    },
    [ordered]@{
        id = 'kohler-tresham-k-2844-4-0'
        name = 'KOHLER Tresham K-2844-4-0 24-in square pedestal sink'
        status = 'research-only; exact Revit family is behind Studio KOHLER sign-in and has not been inspected'
        source = 'https://www.kohler.com/en/products/bathroom-sinks/shop-bathroom-sinks/tresham-24-pedestal-bathroom-sink-with-4-centerset-faucet-holes-2844-4'
        dimensions_source = 'KOHLER specification dated 2024-03-16; nominal overall 24 x 19.5 x 34.625 in'
        width_in = 24.0
        depth_in = 19.5
        height_in = 34.625
        candidate_rfa_geometry_measured = $false
        rfa_type_to_sku_mapping_verified = $false
    },
    [ordered]@{
        id = 'american-standard-edgemere-0445400.020'
        name = 'American Standard Edgemere 4-in-centerset pedestal sink top and leg combination'
        status = 'research-only; consumer page displays purchase price while LIXIL Pro marks the combination discontinued; no complete-combination design file is listed'
        source = 'https://www.americanstandard-us.com/products/edgemere-r-4-inch-centerset-pedestal-sink-top-and-leg-combination'
        dimensions_source = 'American Standard specification dated 2017-04; nominal overall 25 x 19.5 x 35.625 in'
        width_in = 25.0
        depth_in = 19.5
        height_in = 35.625
        candidate_rfa_geometry_measured = $false
        rfa_type_to_sku_mapping_verified = $false
    }
)

$results = @()
foreach ($candidate in $candidates) {
    $orientationA = $candidate.width_in -le $widthIn -and $candidate.depth_in -le $depthIn
    $orientationB = $candidate.depth_in -le $widthIn -and $candidate.width_in -le $depthIn
    Assert-Check ([bool]$orientationA) "$($candidate.id): source-sized body is not contained in B in its documented plan orientation."
    Assert-Check ([bool]$orientationB) "$($candidate.id): source-sized body is not contained in B when rotated 90 degrees."

    $results += [ordered]@{
        id = $candidate.id
        name = $candidate.name
        status = $candidate.status
        source = $candidate.source
        dimensions_source = $candidate.dimensions_source
        nominal_overall_body_in = [ordered]@{
            width = $candidate.width_in
            depth = $candidate.depth_in
            height = $candidate.height_in
        }
        candidate_rfa_geometry_measured = $candidate.candidate_rfa_geometry_measured
        rfa_type_to_sku_mapping_verified = $candidate.rfa_type_to_sku_mapping_verified
        body_rectangle_containment = [ordered]@{
            width_by_depth = [bool]$orientationA
            rotated_90_degrees = [bool]$orientationB
        }
    }
}

Assert-Check ($results.Count -eq 3 -and @($results | Where-Object id -eq 'kohler-tresham-k-2844-4-0').Count -eq 1 -and @($results | Where-Object id -eq 'american-standard-edgemere-0445400.020').Count -eq 1) 'Expected Evolution, Tresham and Edgemere in the comparison.'

$report = [ordered]@{
    schema = 'forever-home-m06-sink-gross-body-screen-v1'
    result = if ($failures.Count -eq 0) { 'PASS' } else { 'FAIL' }
    check_count = $checks
    failed_checks = @($failures)
    study = [ordered]@{
        layout_variant = $study.layout_variant
        file = [System.IO.Path]::GetFileName($studyFile)
        sha256 = $studyHash
        room_id = $m06.id
        assignment_status = 'unassigned; no room footprint or position'
        search_window = [ordered]@{
            id = 'east_of_core (pantry-side B)'
            status = 'gross unassigned room-block gap only'
            width_ft = $widthFt
            depth_ft = $depthFt
            width_in = $widthIn
            depth_in = $depthIn
        }
    }
    candidates = $results
    evaluated = [ordered]@{
        nominal_product_body_rectangle_only = $true
        product_selected = $false
        exact_KOHLER_RFA_measured = $false
        toilet_lavatory_combination = $false
        interior_clearances_or_approach = $false
        entry_door_or_swing = $false
        wall_build_up_or_room_footprint = $false
        plumbing_service_route = $false
        code_or_accessibility = $false
        room_assignment_or_IFC = $false
    }
    limitations = @(
        'B is a gross unassigned room-block gap, not usable clear interior dimensions or an approved bathroom footprint.',
        'Containment checks compare each sink body rectangle independently and do not combine it with a toilet or people/circulation envelopes.',
        'American Standard bounds use official nominal product dimensions; its separate Revit family screen records measured solids and unresolved hosting/type mapping.',
        'KOHLER Tresham bounds use the manufacturer specification; its exact 4-in-centerset Revit family is not yet available for inspection.',
        'Edgemere bounds use the manufacturer specification; product availability conflicts between the consumer storefront and LIXIL Pro, and no Revit family is listed for the full top-and-leg combination.',
        'No fixture is selected or placed, no M-06 geometry is assigned, and no clearance, service route, code, accessibility or IFC result is established.'
    )
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
[System.IO.File]::WriteAllText($resolvedOutput, (ConvertTo-Json -InputObject $report -Depth 12) + "`r`n", [System.Text.UTF8Encoding]::new($false))
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Error "FAIL: $failure" -ErrorAction Continue }
    throw "M-06 sink gross-body screen failed $($failures.Count) of $checks checks."
}
Write-Output "PASS: M-06 source-sized sink gross-body screen passed $checks checks; report saved to $resolvedOutput"
Write-Output 'Screen only: no fixture selected, combined layout, clearance, room assignment, code result, or IFC is validated.'
