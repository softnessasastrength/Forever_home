param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$FamilyPath = (Join-Path $PSScriptRoot '../.local/revit-pilot/family-intake/candidates/american-standard-evolution-0467004.020.rfa'),
    [string]$IntakeManifestPath = (Join-Path $PSScriptRoot '../.local/revit-pilot/family-intake/20261028T023252013Z/intake-manifest.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_Evolution_Family_Envelope_Screen_2026-10-28.json')
)

$ErrorActionPreference = 'Stop'
$checks = 0
$failures = [System.Collections.Generic.List[string]]::new()
function Assert-Check([bool]$Condition, [string]$Message) {
    $script:checks++
    if (-not $Condition) { $script:failures.Add($Message) }
}

$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$familyFile = (Resolve-Path -LiteralPath $FamilyPath).Path
$intakeFile = (Resolve-Path -LiteralPath $IntakeManifestPath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$intake = Get-Content -LiteralPath $intakeFile -Raw | ConvertFrom-Json
$familyHash = (Get-FileHash -LiteralPath $familyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$expectedFamilyHash = '39715206f24de4b909e37324ce352bba3af348bca259b7a9c0ce335ed2ddc3ea'
$sink = @($intake.results | Where-Object file -eq 'american-standard-evolution-0467004.020.rfa')
$studyHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$m06 = $study.selection.main_public_bath
$window = @($m06.search_windows | Where-Object id -eq 'east_of_core')

Assert-Check ($familyHash -eq $expectedFamilyHash) 'Candidate RFA SHA256 differs from the source recorded for this review.'
Assert-Check ($intake.revit_version -eq '2027' -and $intake.status -like 'executed;*') 'Intake manifest is not a completed Revit 2027 run.'
Assert-Check ($study.layout_variant -eq 'OwnerSelectedD' -and $m06.id -eq 'M-06' -and $m06.type -eq 'half bath') 'Study does not identify the owner-selected D M-06 half bath.'
Assert-Check ($m06.footprint -eq 'TBD' -and $m06.position -eq 'TBD' -and $m06.first_fit_candidate -eq 'east_of_core') 'M-06 is no longer an unassigned B-first study; review inputs before proceeding.'
Assert-Check ($window.Count -eq 1 -and $window[0].status -like 'Unassigned room-block gap only*') 'Pantry-side B is not the expected unassigned gross search gap.'
Assert-Check ($sink.Count -eq 1 -and $sink[0].status -in @('loaded','already_present')) 'Exact source family has no successful intake result.'

$types = @()
if ($sink.Count -eq 1) { $types = @($sink[0].types) }
$typeNames = @($types | ForEach-Object type | Sort-Object)
$expectedTypeNames = @('0467.100','0467.400','0467.800')
Assert-Check ($sink[0].category -eq 'Plumbing Fixtures' -and $sink[0].placement_type -eq 'WorkPlaneBased') 'Candidate category or placement type differs from the inspected family.'
Assert-Check ($types.Count -eq 3 -and (Compare-Object $expectedTypeNames $typeNames).Count -eq 0) 'Candidate type set differs from the three measured Evolution variants.'
$fourInType = @($types | Where-Object type -eq '0467.400')
$familyDescription = @($fourInType[0].parameters | Where-Object name -eq 'Description')[0].value
$familyModel = @($fourInType[0].parameters | Where-Object name -eq 'Model')[0].value
$pedestalOption = @($fourInType[0].parameters | Where-Object name -eq 'Pedestal Option')[0].value
$installationType = @($fourInType[0].parameters | Where-Object name -eq 'Installation Type')[0].value
$holePunchLocation = @($fourInType[0].parameters | Where-Object name -eq 'Hole Punch Location')[0].value
$productDocumentationLink = @($fourInType[0].parameters | Where-Object name -eq 'Product Documentation Link')[0].value
Assert-Check ($fourInType.Count -eq 1 -and $familyModel -eq '0467.400' -and $familyDescription -like '*4" centers*' -and $holePunchLocation -like '*4"*') 'Four-inch centerset family type metadata does not match the measured Evolution option.'
Assert-Check ($pedestalOption -eq 'Yes' -and $installationType -eq 'Pedestal') 'The measured type does not expose the documented pedestal option and installation type.'
Assert-Check ($productDocumentationLink -like '*specsheet0467400.pdf*') 'The measured type documentation link does not identify the official 0467400 combo specification.'

$measuredTypes = @()
foreach ($type in $types) {
    $bounds = $type.bounds
    $measured = $null -ne $bounds -and $type.geometry_status -eq 'measured_from_positive_volume_solids' -and
        $type.solid_metrics.positive_volume_solid_count -eq 3 -and $type.solid_metrics.total_volume_ft3 -gt 0
    Assert-Check ([bool]$measured) "$($type.type): expected three positive-volume solids and finite measured bounds."

    $widthDifference = [Math]::Abs([double]$bounds.width_x - 22.0)
    $heightDifference = [Math]::Abs([double]$bounds.depth_y - 34.25)
    $depthDifference = [Math]::Abs([double]$bounds.height_z - 17.5)
    # Revit's triangulated family bounds are compared with the manufacturer's nominal product dimensions.
    # 0.01 in is a numerical comparison tolerance here, not a design or installation allowance.
    $dimensionsCorrespond = $widthDifference -le 0.01 -and $heightDifference -le 0.01 -and $depthDifference -le 0.01
    Assert-Check $dimensionsCorrespond "$($type.type): local XYZ extents do not reconcile to nominal width/height/depth under the documented work-plane axis mapping."

    $measuredTypes += [ordered]@{
        type = $type.type
        positive_volume_solids = $type.solid_metrics.positive_volume_solid_count
        volume_ft3 = $type.solid_metrics.total_volume_ft3
        family_local_xyz_in = [ordered]@{
            x_width = $bounds.width_x
            y_nominal_overall_height = $bounds.depth_y
            z_nominal_projection = $bounds.height_z
        }
        differences_from_nominal_in = [ordered]@{
            width = [Math]::Round($widthDifference, 4)
            overall_height = [Math]::Round($heightDifference, 4)
            projection = [Math]::Round($depthDifference, 4)
        }
        local_y_is_project_vertical_only_after_vertical_face_hosting = $true
    }
}

$report = [ordered]@{
    schema = 'forever-home-m06-sink-family-envelope-screen-v1'
    result = if ($failures.Count -eq 0) { 'PASS' } else { 'FAIL' }
    check_count = $checks
    failed_checks = @($failures)
    target_product = [ordered]@{
        name = 'American Standard Evolution 22-Inch 4-Inch Centerset Pedestal Sink Top and Leg Combination'
        sku = '0467400.020'
        current_status = 'LIXIL Pro lists the combo discontinued; consumer page says unavailable for online sale'
        product_page = 'https://www.americanstandard-us.com/products/22-inch-evolution-r-4-inch-centerset-pedestal-sink-top-and-leg-combination'
        official_nominal_dimensions_in = [ordered]@{ width = 22.0; depth = 17.5; overall_height = 34.25 }
        rfa_source = 'https://lixil.cdn.celum.cloud/253890_Basin-Pedestal-American_Standard-Evolution-0467_Series_original.rfa'
        rfa_sha256 = $familyHash
        measured_file_name_retained_from_separate_top_listing = 'american-standard-evolution-0467004.020.rfa'
    }
    study = [ordered]@{ file = [System.IO.Path]::GetFileName($studyFile); sha256 = $studyHash }
    intake = [ordered]@{ file = [System.IO.Path]::GetFileName($intakeFile); revit_version = $intake.revit_version; revit_build = $intake.revit_build }
    family = [ordered]@{
        category = $sink[0].category
        placement_type = $sink[0].placement_type
        types = $measuredTypes
        axis_interpretation = 'For this work-plane-based family, local X/Y are interpreted as width/height when hosted on a vertical face; local Z is interpreted as projection from that face. This mapping is not validated by a placed instance.'
        type_sku_association_supported = $true
        type_description = $familyDescription
        pedestal_option = $pedestalOption
        installation_type = $installationType
        type_description_pedestal_assembly_resolved = $false
    }
    gross_body_screen = [ordered]@{
        selected_search_window = 'east_of_core (pantry side B)'
        window_width_ft = [double]$window[0].w
        window_depth_ft = [double]$window[0].d
        body_22x17_5_contained_both_orientations = ((22.0 / 12 -le [double]$window[0].w -and 17.5 / 12 -le [double]$window[0].d) -and (17.5 / 12 -le [double]$window[0].w -and 22.0 / 12 -le [double]$window[0].d))
    }
    evaluated = [ordered]@{
        nominal_body_bounds_only = $true
        selected_fixture = $false
        exact_RFA_type_to_SKU_source_association = $true
        hosted_assembly_geometry_verified = $false
        placed_host_orientation = $false
        toilet_sink_clearance_or_user_approach = $false
        door_or_swing = $false
        interior_finish_or_wall_build_up = $false
        plumbing_route_or_connector_compatibility = $false
        code_or_accessibility_compliance = $false
        room_assignment = $false
        IFC = $false
    }
    limitations = @(
        'The 22 x 17.5 in body rectangle is compared with the gross unassigned B room-block gap, not usable clear interior dimensions.',
        'Gross body containment does not include the toilet, required clearances, user approach, door, wall assembly, plumbing route or service access.',
        'The official combo page links the same RFA; type 0467.400, its 4-in faucet metadata, pedestal option, spec-sheet link and measured overall envelope support association with SKU 0467400.020. Its type description still says “Basin only,” so family assembly geometry is not treated as conclusively verified.',
        'The family was measured in a disposable intake project only; no instance was placed, saved in the house model or exported to IFC.'
    )
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
[System.IO.File]::WriteAllText($resolvedOutput, (ConvertTo-Json -InputObject $report -Depth 12) + "`r`n", [System.Text.UTF8Encoding]::new($false))
if ($failures.Count -gt 0) {
    foreach ($failure in $failures) { Write-Error "FAIL: $failure" -ErrorAction Continue }
    throw "M-06 sink family screen failed $($failures.Count) of $checks checks."
}
Write-Output "PASS: M-06 Evolution family/source screen passed $checks checks; report saved to $resolvedOutput"
Write-Output 'Screen only: no selected fixture, hosted placement, clearance layout, service route, room assignment, code result, or IFC is validated.'
