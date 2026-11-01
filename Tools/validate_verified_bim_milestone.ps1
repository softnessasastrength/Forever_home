param(
    [string]$Output = '.local/revalidation/verified-bim-milestone.json',
    [string]$NativeStairStudyDirectory = '.local/revit-pilot/split-rise-native-stair/20261101T225749874Z'
)

$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
function Read-Json([string]$RelativePath) {
    $path = Join-Path $repo $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing evidence: $RelativePath" }
    return Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
}
function Add-Check([string]$Name, [bool]$Pass, [string]$Detail) {
    $script:checks += [pscustomobject]@{ name=$Name; pass=$Pass; detail=$Detail }
}

$checks = @()
$baseline = Read-Json '.local/revalidation/architectural-bim-baseline-20261101T-recheck/baseline-validation.json'
$chain = Read-Json '.local/revalidation/m318-main-floor-coordination-final.json'
$m06 = Read-Json '.local/revalidation/m06-cimarron-evidence.json'
$m120 = Read-Json '.local/revalidation/M320-m120-current-envelope-pwsh/m120-report.json'
$m321 = Read-Json '.local/revalidation/M321-kitchen-island-ifc-final.json'
$m83 = Read-Json '.local/revit-pilot/roof-massing/20261101T210719010Z/ifc-validation.json'
$m325 = Read-Json (Join-Path $NativeStairStudyDirectory 'native-stair-validation.json')

Add-Check 'selected_d_baseline' ($baseline.status -eq 'pass' -and $baseline.replay_count -eq 2 -and $baseline.geometry_check_count_per_replay -eq 43 -and $baseline.ifc_checks_passed -eq 26 -and $baseline.protected_inputs_unchanged) '2 x 43 source replay; retained IFC 26/26; protected inputs unchanged'
Add-Check 'main_floor_wall_plate_chain' ($chain.passed -eq 9 -and $chain.total -eq 9) 'M318 provenance/inventory gate'
Add-Check 'm06_public_candidate' ([bool]$m06.pass -and @($m06.checks | Where-Object { $_.pass -ne $true }).Count -eq 0) 'isolated public-family evidence with no placement'
Add-Check 'm06_gross_envelope' ($m120.status -match '^passed' -and $m120.pair_count -eq 16 -and $m120.gross_containment_count -eq 16 -and -not [bool]$m120.fit_window.assigned) '16/16 gross pairs; B remains unassigned'
Add-Check 'm02_kitchen_ifc' ($m321.status -eq 'pass' -and @($m321.checks.PSObject.Properties | Where-Object { $_.Value -ne $true }).Count -eq 0) 'isolated kitchen furnishing IFC gate'
Add-Check 'm83_roof_ifc' ($m83.status -eq 'pass' -and @($m83.checks.PSObject.Properties | Where-Object { $_.Value -ne $true }).Count -eq 0) 'six-case comparative roof-surface IFC gate'
Add-Check 'm325_native_stair' ($m325.pass -eq $true -and $m325.checks.Count -ge 14 -and @($m325.checks | Where-Object { $_.pass -ne $true }).Count -eq 0) 'disposable native split-rise stair RVT/IFC gate'

$outPath = if ([IO.Path]::IsPathRooted($Output)) { [IO.Path]::GetFullPath($Output) } else { [IO.Path]::GetFullPath((Join-Path $repo $Output)) }
$parent = Split-Path -Parent $outPath
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$failed = @($checks | Where-Object { -not $_.pass })
$report = [pscustomobject]@{
    schema = 'forever-home-verified-bim-milestone-v1'
    status = if ($failed.Count -eq 0) { 'pass' } else { 'fail' }
    passed = @($checks | Where-Object pass).Count
    total = $checks.Count
    checks = $checks
    limitations = @('This proves the documented evidence gates only.', 'Native openings, stairs, roof assemblies, structure, MEP, site fit and professional review remain open.', 'No code-compliance, structural-safety or construction-readiness conclusion follows.')
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outPath -Encoding UTF8
if ($failed.Count -gt 0) { $failed | Format-Table | Out-String | Write-Error; exit 1 }
Write-Output "PASS: $($report.passed)/$($report.total) verified BIM milestone checks."
