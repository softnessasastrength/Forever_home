param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$ImagePath = (Join-Path $PSScriptRoot '../.local/revalidation/M95-champion-infographics/610AA001-Mar2024.webp'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../.local/revalidation/M95-current-toilet-envelope.json')
)

$ErrorActionPreference = 'Stop'
$checks = 0
$failures = [System.Collections.Generic.List[string]]::new()
function Assert-Check([bool]$Condition, [string]$Message) {
    $script:checks++
    if (-not $Condition) { $script:failures.Add($Message) }
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$imageFile = (Resolve-Path -LiteralPath $ImagePath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$studyHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$imageHash = (Get-FileHash -LiteralPath $imageFile -Algorithm SHA256).Hash.ToUpperInvariant()
$imageLength = (Get-Item -LiteralPath $imageFile).Length

$expectedStudyHash = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
$expectedImageHash = 'F09F6BFBCBB62F53828BD99E46F2351BB279E4C031980BBC5E35790E0FE86FBF'
$expectedImageLength = 133750
$m06 = $study.selection.main_public_bath
$window = @($m06.search_windows | Where-Object id -eq 'east_of_core')

Assert-Check ($studyHash -eq $expectedStudyHash) 'Selected-D source fingerprint changed; review the baseline before relying on this screen.'
Assert-Check ($study.layout_variant -eq 'OwnerSelectedD' -and $m06.id -eq 'M-06' -and $m06.type -eq 'half bath') 'Input is not the owner-selected D M-06 half-bath study.'
Assert-Check ($m06.footprint -eq 'TBD' -and $m06.position -eq 'TBD' -and $m06.first_fit_candidate -eq 'east_of_core') 'M-06 assignment or first-fit priority changed; review before proceeding.'
Assert-Check ($window.Count -eq 1 -and $window[0].status -like 'Unassigned room-block gap only*') 'Pantry-side B is not the documented unassigned gross gap.'
Assert-Check ($imageHash -eq $expectedImageHash -and $imageLength -eq $expectedImageLength) 'The manufacturer infographic bytes do not match the inspected hash-pinned image.'

$grossWidthIn = [double]$window[0].w * 12.0
$grossDepthIn = [double]$window[0].d * 12.0
Assert-Check ([Math]::Abs($grossWidthIn - 158.0) -lt 0.000001 -and [Math]::Abs($grossDepthIn - 84.0) -lt 0.000001) 'B no longer derives to the documented 158 x 84 in gross block.'

# These values are transcribed from the current manufacturer's 610AA001.020 infographic.
# The validator pins the image bytes; it does not perform OCR or verify detailed solid geometry.
$bodyWidthIn = 19.0
$bodyProjectionIn = 30.25
$bodyHeightIn = 30.875
$seatHeightIn = 17.0
$roughInIn = 12.0
$orientations = @(
    [ordered]@{rotation_deg=0; width_in=$bodyWidthIn; depth_in=$bodyProjectionIn},
    [ordered]@{rotation_deg=90; width_in=$bodyProjectionIn; depth_in=$bodyWidthIn}
)
$orientationResults = @()
foreach ($orientation in $orientations) {
    $fits = [double]$orientation.width_in -le $grossWidthIn -and [double]$orientation.depth_in -le $grossDepthIn
    Assert-Check $fits "Current-SKU nominal body envelope does not fit gross B in orientation $($orientation.rotation_deg)."
    $orientationResults += [ordered]@{
        rotation_deg = $orientation.rotation_deg
        body_width_in = $orientation.width_in
        body_depth_in = $orientation.depth_in
        contained_in_gross_B = $fits
    }
}

$report = [ordered]@{
    schema = 'forever-home-m06-current-toilet-infographic-envelope-v1'
    result = "PASS: $checks checks; current-SKU annotated rectangular envelope is contained in gross B in both orientations. This is not a room fit."
    study = [ordered]@{path='Architecture/Selected_Design_Iteration_2026-10-27/study.json'; sha256=$studyHash; layout_variant=$study.layout_variant}
    candidate = [ordered]@{
        selected_sku = 'American Standard Champion PRO 610AA001.020'
        evidence_type = 'manufacturer product-page infographic; values transcribed from annotation, not a Revit family or dimensional specification PDF'
        product_page = 'https://www.americanstandard-us.com/products/champion-r-pro-two-piece-1-28-gpf-4-8-lpf-chair-height-elongated-toilet-with-seat-and-wax-ring'
        image_source = 'https://www.americanstandard-us.com/cdn/shop/files/239959_Champion_Infographic_610AA001_0001_MAR2024_CDNwebp.webp?v=1790749418&width=2000'
        image_sha256 = $imageHash
        image_bytes = $imageLength
        manufacturer_annotated_overall_in = [ordered]@{length=$bodyProjectionIn; width=$bodyWidthIn; height=$bodyHeightIn}
        annotated_seat_height_in = $seatHeightIn
        annotated_rough_in_in = $roughInIn
        current_sku_infographic_seen = $true
        exact_revit_family_or_solid_geometry_verified = $false
        manufacturer_linked_spec_sheet_is_exact_current_sku = $false
    }
    target_zone = [ordered]@{
        id = 'east_of_core'
        label = 'Pantry-side B'
        status = 'unassigned gross room-block gap only'
        gross_width_in = $grossWidthIn
        gross_depth_in = $grossDepthIn
        orientations = $orientationResults
    }
    gates = [ordered]@{
        product_selected_for_purchase = $false
        exact_detailed_product_solids_verified = $false
        toilet_lavatory_combination_tested = $false
        applicable_clearance_basis_confirmed = $false
        door_and_approach_tested = $false
        service_route_tested = $false
        m06_assigned = $false
        ifc_or_revit_placement_validated = $false
    }
    limitations = @(
        'The 610AA001.020 product page links a specification sheet labelled 211AA.104; this infographic is separate evidence for the current SKU, not a replacement exact-SKU Revit family.',
        'The infographic labels overall 30-1/4 x 19 x 30-7/8 in dimensions, 17 in seat height, and 12 in rough-in, and notes slight seat-height variation. The body screen uses only the 19 x 30-1/4 in plan rectangle.',
        'The script pins the downloaded image hash and transcribes its visible annotations; it does not OCR the image or inspect geometric solids.',
        'B is a 158 x 84 in gross unassigned search window, not clear interior dimensions. This check excludes sink, walls, finish build-up, fixture clearances, entry, door swing, approach and plumbing/service routing.',
        'No Revit placement, IFC export, code compliance, accessibility, structural safety, or construction readiness is established.'
    )
}

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Error "FAIL: $failure" -ErrorAction Continue }
    throw "Current 610AA infographic screen failed $($failures.Count) of $checks checks."
}

$report.result = "PASS: $checks checks; current-SKU annotated rectangular envelope is contained in gross B in both orientations. This is not a room fit."
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
[System.IO.File]::WriteAllText($resolvedOutput, (ConvertTo-Json -InputObject $report -Depth 12) + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: M-06 current-SKU manufacturer-infographic envelope passed $checks checks; report saved to $resolvedOutput"
Write-Output 'Screen only: no lavatory pair, clearance, wall, door, approach, service route, room assignment, Revit placement or IFC is validated.'
