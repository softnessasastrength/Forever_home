param(
    [Parameter(Mandatory = $true)]
    [string]$StudyDirectory
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$localRoot = Join-Path $repoRoot '.local/revit-pilot'
$studyFull = [IO.Path]::GetFullPath($StudyDirectory)
$manifestPath = Join-Path $studyFull 'm218-revit-study-manifest.json'
$checks = New-Object System.Collections.Generic.List[object]

function Test-UnderDirectory([string]$Path, [string]$Directory) {
    $trim = [char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $prefix = [IO.Path]::GetFullPath($Directory).TrimEnd($trim) + [IO.Path]::DirectorySeparatorChar
    return [IO.Path]::GetFullPath($Path).StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}

function Add-Check([string]$Name, [bool]$Passed, [string]$Evidence) {
    $checks.Add([pscustomobject]@{ name = $Name; passed = $Passed; evidence = $Evidence })
}

if (!(Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "M-218 Revit manifest not found: $manifestPath" }
$report = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$schema = 'forever-home-m218-revit-pantry-door-study-v1'
$expectedSources = @{
    selected_d = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    m215 = 'f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
    m217 = '7e436b9a7d805e2803a1148fbd2bdacad017f86b7d444f7cbe77cbde30226853'
    m218 = '946aaf98fc44fa67cd5546168feecd896d4c36543bc097553c75c7389385a3d43'
}

Add-Check 'manifest_schema' ($report.schema -eq $schema) "schema=$($report.schema)"
Add-Check 'study_output_under_local_revit_pilot' ((Test-UnderDirectory $studyFull $localRoot) -and (Test-UnderDirectory $manifestPath $localRoot)) "study=$studyFull"
Add-Check 'study_status' ([string]$report.status -like 'pass;*') "status=$($report.status)"

$sourceMatches = $true
foreach ($key in $expectedSources.Keys) {
    $actual = [string]$report.source_sha256.$key
    if (![string]::Equals($actual, $expectedSources[$key], [StringComparison]::OrdinalIgnoreCase)) { $sourceMatches = $false }
}
Add-Check 'pinned_sources_match' $sourceMatches "sources=$($report.source_sha256 | ConvertTo-Json -Compress)"

$scope = $report.project_scope
$scopeMatches = $null -ne $scope -and $scope.derivative_type -eq 'fresh imperial project per swing' -and
    $scope.selected_d_opened -eq $false -and $scope.selected_d_modified -eq $false
Add-Check 'selected_design_not_opened_or_modified' $scopeMatches "scope=$($scope | ConvertTo-Json -Compress)"

$files = @($report.files)
$actualSwings = @($files | ForEach-Object { [string]$_.swing_into } | Sort-Object -Unique)
$bothAlternatives = $files.Count -eq 2 -and $actualSwings.Count -eq 2 -and
    $actualSwings[0] -eq 'kitchen' -and $actualSwings[1] -eq 'pantry'
Add-Check 'both_swing_alternatives_present_once' $bothAlternatives "swings=$($actualSwings -join ','); files=$($files.Count)"

$fileChecks = $true
$fileEvidence = New-Object System.Collections.Generic.List[string]
$inventoryChecks = $true
$inventoryEvidence = New-Object System.Collections.Generic.List[string]
foreach ($file in $files) {
    $name = [string]$file.file_name
    $expectedName = if ($file.swing_into -eq 'kitchen') { 'FH_M218_Pantry_Swing_Into_Kitchen.rvt' } else { 'FH_M218_Pantry_Swing_Into_Pantry.rvt' }
    $filePath = Join-Path $studyFull $name
    $exists = (Test-Path -LiteralPath $filePath -PathType Leaf) -and $name -eq $expectedName
    $bytesMatch = $false
    $hashMatch = $false
    if ($exists) {
        $info = Get-Item -LiteralPath $filePath
        $hash = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash
        $bytesMatch = $info.Length -gt 0 -and $info.Length -eq [long]$file.bytes
        $hashMatch = [string]::Equals($hash, [string]$file.sha256, [StringComparison]::OrdinalIgnoreCase)
    }
    $countsMatch = [int]$file.wall_count -eq 13 -and [int]$file.model_curve_count -eq 48
    $fileChecks = $fileChecks -and $exists -and $bytesMatch -and $hashMatch -and $countsMatch
    $fileEvidence.Add("$name exists=$exists bytes=$bytesMatch hash=$hashMatch counts=$countsMatch")

    $walls = @($file.walls)
    $curves = @($file.model_curves)
    $validWallRows = $walls.Count -eq 13
    foreach ($row in $walls) {
        $validWallRows = $validWallRows -and [string]$row.marker -match '^M218-(lower|center|upper)-PANTRY-'
        $validWallRows = $validWallRows -and $null -ne $row.height_ft -and [math]::Abs([double]$row.height_ft - 10.0) -lt 0.00001
        foreach ($pointName in @('start','end')) {
            $point = $row.$pointName
            $validWallRows = $validWallRows -and $null -ne $point -and
                [math]::Abs([double]$point.z) -lt 0.00001 -and
                [double]::IsNaN([double]$point.x) -eq $false -and [double]::IsInfinity([double]$point.x) -eq $false -and
                [double]::IsNaN([double]$point.y) -eq $false -and [double]::IsInfinity([double]$point.y) -eq $false -and
                [double]$point.x -ge 13.499 -and [double]$point.x -le 78.501 -and
                [double]$point.y -ge 1.249 -and [double]$point.y -le 8.251
        }
    }
    $validCurveRows = $curves.Count -eq 48
    foreach ($row in $curves) {
        $validCurveRows = $validCurveRows -and [string]$row.marker -match '^M218-(lower|center|upper)-'
        $validCurveRows = $validCurveRows -and $null -eq $row.height_ft
        foreach ($pointName in @('start','end')) {
            $point = $row.$pointName
            $validCurveRows = $validCurveRows -and $null -ne $point -and
                [math]::Abs([double]$point.z - 0.05) -lt 0.00001 -and
                [double]::IsNaN([double]$point.x) -eq $false -and [double]::IsInfinity([double]$point.x) -eq $false -and
                [double]::IsNaN([double]$point.y) -eq $false -and [double]::IsInfinity([double]$point.y) -eq $false -and
                [double]$point.x -ge -0.001 -and [double]$point.x -le 80.001 -and
                [double]$point.y -ge -0.001 -and [double]$point.y -le 35.001
        }
    }
    $wallMarkersUnique = (@($walls | ForEach-Object { [string]$_.marker } | Sort-Object -Unique).Count -eq $walls.Count)
    $curveMarkersUnique = (@($curves | ForEach-Object { [string]$_.marker } | Sort-Object -Unique).Count -eq $curves.Count)
    $perPositionCounts = $true
    foreach ($position in @('lower','center','upper')) {
        $positionWalls = @($walls | Where-Object { [string]$_.marker -like "M218-$position-PANTRY-*" }).Count
        $expectedWalls = if ($position -eq 'center') { 5 } else { 4 }
        $positionCurves = @($curves | Where-Object { [string]$_.marker -like "M218-$position-*" }).Count
        $perPositionCounts = $perPositionCounts -and $positionWalls -eq $expectedWalls -and $positionCurves -eq 16
        foreach ($family in @('M02-envelope-not-walls','36in-approach-proxy',"$($file.swing_into)-swing-bounds-not-door-leaf",'M215-route-centerline-')) {
            if ($family.EndsWith('-')) {
                $matches = @($curves | Where-Object { [string]$_.marker -like "M218-$position-$family*" }).Count
            } else {
                $matches = @($curves | Where-Object { [string]$_.marker -like "M218-$position-$family-*" }).Count
            }
            $perPositionCounts = $perPositionCounts -and $matches -eq 4
        }
    }
    $inventoryOk = $validWallRows -and $validCurveRows -and $wallMarkersUnique -and $curveMarkersUnique -and $perPositionCounts
    $inventoryChecks = $inventoryChecks -and $inventoryOk
    $inventoryEvidence.Add("$name native wall_records=$($walls.Count) wall_geometry=$validWallRows curve_records=$($curves.Count) curve_geometry=$validCurveRows unique_markers=$($wallMarkersUnique -and $curveMarkersUnique) per_position_families=$perPositionCounts")
}
Add-Check 'both_rvt_hashes_sizes_and_recorded_counts' $fileChecks ($fileEvidence -join '; ')
Add-Check 'native_geometry_inventory_coordinates_and_markers' $inventoryChecks ($inventoryEvidence -join '; ')

$limitations = @($report.limitations)
$keepsBUnassigned = ($limitations -join "`n") -match 'east B remains unassigned'
$keepsAProtected = ($limitations -join "`n") -match 'West A remains protected'
Add-Check 'm06_search_windows_preserved' ($keepsAProtected -and $keepsBUnassigned) "west_A_protected=$keepsAProtected; east_B_unassigned=$keepsBUnassigned"

$passed = @($checks | Where-Object passed).Count
$status = if ($passed -eq $checks.Count) { 'pass' } else { 'fail' }
foreach ($check in $checks) {
    $verdict = if ($check.passed) { 'PASS' } else { 'FAIL' }
    Write-Output ("{0} {1}: {2}" -f $verdict, $check.name, $check.evidence)
}
Write-Output "SUMMARY $passed/$($checks.Count) M218 Revit study integrity checks passed"
if ($status -ne 'pass') { exit 1 }
Write-Output 'LIMIT: this verifies the command-recorded native Revit wall/model-curve inventory, endpoint envelopes, markers and hashes; it does not reopen the RVT independently or validate fit, door usability, code, accessibility, or services.'
