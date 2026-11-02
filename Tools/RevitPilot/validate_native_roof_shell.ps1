[CmdletBinding()]
param([Parameter(Mandatory)][string]$StudyDirectory)
$ErrorActionPreference = 'Stop'
$dir = (Resolve-Path -LiteralPath $StudyDirectory).Path
$manifestPath = Join-Path $dir 'native-roof-shell-manifest.json'
$rvt = Join-Path $dir 'FH_Native_Roof_Shell_Comparison.rvt'
$ifc = Join-Path $dir 'FH_Native_Roof_Shell_Comparison.ifc'
$checks = [System.Collections.Generic.List[object]]::new()
function Check([string]$Name, [bool]$Pass, [string]$Detail) { $checks.Add([pscustomobject]@{name=$Name; pass=$Pass; detail=$Detail}) }
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Missing native-roof-shell-manifest.json in $dir" }
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
Check 'schema' ($m.schema -eq 'forever-home.native-roof-shell-v1') $m.schema
Check 'disposable_status' ($m.status -match 'disposable native roof') $m.status
Check 'selected_d_source_hash' ($m.source_sha256 -eq '516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB') $m.source_sha256
Check 'native_roof_count' ([int]$m.native_roof_count -eq 3) ([string]$m.native_roof_count)
$labels = @($m.roofs | ForEach-Object { $_.option })
Check 'documented_options' (@(Compare-Object @('8:12','10:12','12:12') $labels -PassThru).Count -eq 0) ($labels -join ',')
Check 'rvt_present' (Test-Path -LiteralPath $rvt) $rvt
if (Test-Path -LiteralPath $rvt) {
    $actual = (Get-FileHash -LiteralPath $rvt -Algorithm SHA256).Hash
    Check 'rvt_hash' ($actual -eq $m.saved_rvt_sha256) $actual
}
Check 'ifc_present' (Test-Path -LiteralPath $ifc) $ifc
if (Test-Path -LiteralPath $ifc) {
    $bytes = [IO.File]::ReadAllBytes($ifc)
    $text = [Text.Encoding]::UTF8.GetString($bytes)
    $actual = (Get-FileHash -LiteralPath $ifc -Algorithm SHA256).Hash
    Check 'ifc_nonempty' ($bytes.Length -gt 1000) ([string]$bytes.Length)
    Check 'ifc_step' ($text -match 'ISO-10303-21;') 'STEP header'
    Check 'ifc_schema' ($text -match 'IFC2X3') 'IFC2X3 marker'
    Check 'ifc_roof_entity' ($text -match 'IFCROOF') 'IFCROOF entity'
    Check 'ifc_hash' ($actual -eq $m.ifc.sha256) $actual
}
$passed = @($checks | Where-Object pass).Count
$report = [pscustomobject]@{ schema='forever-home.native-roof-shell-validation-v1'; study_directory=$dir; passed=$passed; total=$checks.Count; checks=$checks }
$reportPath = Join-Path $dir 'native-roof-shell-validation.json'
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath -Encoding UTF8
$checks | Format-Table -AutoSize
if ($passed -ne $checks.Count) { Write-Error "FAIL: $passed/$($checks.Count) checks passed; report $reportPath"; exit 1 }
Write-Output "PASS: $passed/$($checks.Count) checks passed; report $reportPath"
