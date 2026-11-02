[CmdletBinding()]
param([Parameter(Mandatory)] [string] $StudyDirectory)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $StudyDirectory 'study-manifest.json'
$checks = @()
function Check([string]$Name, [bool]$Pass, [string]$Detail) {
    $script:checks += [pscustomobject]@{ name = $Name; pass = $Pass; detail = $Detail }
    if (-not $Pass) { throw "$Name failed: $Detail" }
}
Check 'manifest-present' (Test-Path -LiteralPath $manifestPath) $manifestPath
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
Check 'schema' ($m.schema -eq 'forever-home-m324-native-split-rise-stair-v1') $m.schema
Check 'disposable-status' ($m.status -match 'disposable' -and $m.status -match 'no selected-D promotion') $m.status
Check 'native-stair-count' ([int]$m.native_stair_count -eq 2) ([string]$m.native_stair_count)
Check 'flight-count' (@($m.flights).Count -eq 2) ([string]@($m.flights).Count)
Check 'four-risers-each' (@($m.flights | Where-Object { [int]$_.actual_risers -ne 4 }).Count -eq 0) (($m.flights | ForEach-Object actual_risers) -join ',')
Check 'level-datums' ((@($m.levels | ForEach-Object elevation_ft) -join ',') -eq '0,2.5,5') ((@($m.levels | ForEach-Object elevation_ft) -join ','))
Check 'total-rise' ([double]$m.total_rise_in -eq 60) ([string]$m.total_rise_in)
$rvt = Join-Path $StudyDirectory $m.saved_rvt
Check 'rvt-present' (Test-Path -LiteralPath $rvt) $rvt
Check 'rvt-hash' ((Get-FileHash -LiteralPath $rvt -Algorithm SHA256).Hash -eq $m.saved_rvt_sha256) $rvt
$ifc = Join-Path $StudyDirectory ($m.ifc -replace '/', '\')
Check 'ifc-present' (Test-Path -LiteralPath $ifc) $ifc
$ifcText = Get-Content -LiteralPath $ifc -Raw
Check 'ifc-nonempty' ($ifcText.Length -gt 1000) ([string]$ifcText.Length)
Check 'ifc-step-header' ($ifcText.StartsWith('ISO-10303-21;')) 'IFC STEP header'
Check 'ifc-ifc2x3' ($ifcText -match 'IFC2X3') 'IFC2X3 schema marker'
Check 'ifc-stair-entities' (($ifcText -match 'IFCSTAIR') -or ($ifcText -match 'IFCSTAIRFLIGHT')) 'IFC stair entity'
$out = [pscustomobject]@{ schema = 'forever-home-m324-native-split-rise-stair-validation-v1'; pass = $true; checks = $checks; study_directory = (Resolve-Path $StudyDirectory).Path }
$out | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $StudyDirectory 'native-stair-validation.json') -Encoding UTF8
$out | ConvertTo-Json -Depth 8
