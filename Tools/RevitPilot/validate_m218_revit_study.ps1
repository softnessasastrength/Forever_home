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
}
Add-Check 'both_rvt_hashes_sizes_and_recorded_counts' $fileChecks ($fileEvidence -join '; ')

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
Write-Output 'LIMIT: this verifies manifest provenance and file identity/count metadata; it does not independently inspect native Revit element geometry.'
