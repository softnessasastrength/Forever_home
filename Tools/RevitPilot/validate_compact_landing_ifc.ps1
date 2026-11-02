[CmdletBinding()]
param([Parameter(Mandatory)] [string] $StudyDirectory)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $StudyDirectory 'landing-study-manifest.json'
$checks = @()
function Check([string]$Name, [bool]$Pass, [string]$Detail) {
    $script:checks += [pscustomobject]@{ name = $Name; pass = $Pass; detail = $Detail }
}
Check 'manifest-present' (Test-Path -LiteralPath $manifestPath) $manifestPath
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
Check 'schema' ($m.schema -eq 'forever-home.compact-core-native-landing-study-v1') ([string]$m.schema)
Check 'disposable-status' ($m.status -match 'disposable' -and $m.status -match 'Selected-D untouched') ([string]$m.status)
Check 'source-fingerprint' ($m.source_model_fingerprint.algorithm -eq 'sha256-of-saved-rvt-bytes-v1' -and $m.source_model_fingerprint.sha256 -match '^[0-9a-f]{64}$') ([string]$m.source_model_fingerprint.sha256)
Check 'model-fingerprint' ($m.model_fingerprint.algorithm -eq 'sha256-of-saved-rvt-bytes-v1' -and $m.model_fingerprint.sha256 -match '^[0-9a-f]{64}$') ([string]$m.model_fingerprint.sha256)
$rvt = Join-Path $StudyDirectory 'FH_Compact_Core_Landing_Study.rvt'
Check 'rvt-present' (Test-Path -LiteralPath $rvt) $rvt
if (Test-Path -LiteralPath $rvt) {
    Check 'rvt-hash' ((Get-FileHash -LiteralPath $rvt -Algorithm SHA256).Hash.ToLowerInvariant() -eq $m.model_fingerprint.sha256) $rvt
} else { Check 'rvt-hash' $false 'RVT is absent; hash not computed' }
$landing = $m.landing
Check 'landing-marker' ([string]$landing.marker -eq 'FH-C-STAIR-LANDING-BRIDGE') ([string]$landing.marker)
Check 'positive-landing-geometry' ([double]$landing.gap_ft -gt 0 -and [double]$landing.width_ft -gt 0 -and [double]$landing.area_sqft -gt 0) ("gap={0}; width={1}; area={2}" -f $landing.gap_ft,$landing.width_ft,$landing.area_sqft)
$ifc = Join-Path $StudyDirectory 'FH_Compact_Core_Landing_Study.ifc'
Check 'ifc-present' (Test-Path -LiteralPath $ifc) $ifc
$ifcText = if (Test-Path -LiteralPath $ifc) { Get-Content -LiteralPath $ifc -Raw } else { '' }
Check 'ifc-nonempty' ($ifcText.Length -gt 1000) ([string]$ifcText.Length)
Check 'ifc-step-header' ($ifcText.StartsWith('ISO-10303-21;')) 'IFC STEP header'
Check 'ifc-ifc2x3' ($ifcText -match 'IFC2X3') 'IFC2X3 schema marker'
Check 'ifc-floor-entity' (($ifcText -match 'IFCFLOOR') -or ($ifcText -match 'IFCSLAB')) 'IFC floor/slab entity'
Check 'ifc-landing-marker' ($ifcText -match 'FH-C-STAIR-LANDING-BRIDGE') 'landing marker in IFC text'
$passed = @($checks | Where-Object { $_.pass }).Count
$out = [pscustomobject]@{ schema = 'forever-home.compact-core-native-landing-validation-v1'; pass = ($passed -eq $checks.Count); passed = $passed; total = $checks.Count; checks = $checks; study_directory = (Resolve-Path $StudyDirectory).Path }
$out | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $StudyDirectory 'landing-validation.json') -Encoding UTF8
$checks | Format-Table -AutoSize
$out | ConvertTo-Json -Depth 8
if (-not $out.pass) { exit 1 }
