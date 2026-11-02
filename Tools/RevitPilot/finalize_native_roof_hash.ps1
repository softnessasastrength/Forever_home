[CmdletBinding()]
param([Parameter(Mandatory)][string]$StudyDirectory)
$ErrorActionPreference = 'Stop'
$dir = (Resolve-Path -LiteralPath $StudyDirectory).Path
$manifestPath = Join-Path $dir 'native-roof-shell-manifest.json'
$rvt = Join-Path $dir 'FH_Native_Roof_Shell_Comparison.rvt'
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Missing native-roof-shell-manifest.json in $dir" }
if (-not (Test-Path -LiteralPath $rvt)) { throw "Missing saved RVT in $dir" }
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$m.saved_rvt_sha256 = (Get-FileHash -LiteralPath $rvt -Algorithm SHA256).Hash
$m | ConvertTo-Json -Depth 16 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
Write-Output "Finalized native roof RVT hash: $($m.saved_rvt_sha256)"
