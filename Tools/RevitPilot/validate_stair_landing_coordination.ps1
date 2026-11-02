[CmdletBinding()]
param([Parameter(Mandatory)] [string] $StudyDirectory)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $StudyDirectory 'stair-landing-coordination-manifest.json'
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$checks = @()
function Check([string]$Name, [bool]$Pass, [string]$Detail) { $script:checks += [pscustomobject]@{name=$Name; pass=$Pass; detail=$Detail} }
Check 'manifest-present' (Test-Path -LiteralPath $manifestPath) $manifestPath
Check 'schema' ($m.schema -eq 'forever-home.native-stair-landing-coordination-v1') ([string]$m.schema)
Check 'disposable-status' ($m.status -match 'disposable' -and $m.status -match 'Selected-D untouched') ([string]$m.status)
$rvt = Join-Path $StudyDirectory $m.saved_rvt
Check 'rvt-present' (Test-Path -LiteralPath $rvt) $rvt
if (Test-Path -LiteralPath $rvt) { Check 'rvt-hash' ((Get-FileHash -LiteralPath $rvt -Algorithm SHA256).Hash.ToLowerInvariant() -eq $m.saved_rvt_sha256) ([string]$m.saved_rvt_sha256) } else { Check 'rvt-hash' $false 'RVT missing' }
Check 'native-stair' ([int]$m.stair.native_stair_count -ge 1 -and [int]$m.stair.stair_element_id -gt 0) ("count={0}; id={1}" -f $m.stair.native_stair_count,$m.stair.stair_element_id)
Check 'landing-positive' ([double]$m.landing.gap_ft -gt 0 -and [double]$m.landing.width_ft -gt 0 -and [double]$m.landing.area_sqft -gt 0) ("gap={0}; width={1}; area={2}" -f $m.landing.gap_ft,$m.landing.width_ft,$m.landing.area_sqft)
Check 'landing-marker' ([string]$m.landing.marker -eq 'FH-C-STAIR-LANDING-BRIDGE') ([string]$m.landing.marker)
Check 'circulation-proxy' ([int]$m.circulation.route_curve_count -eq 4 -and [double]$m.circulation.nominal_width_ft -gt 0 -and [double]$m.circulation.nominal_depth_ft -gt 0 -and -not [bool]$m.circulation.code_clearance_verified) ("curves={0}; width={1}; depth={2}; code={3}" -f $m.circulation.route_curve_count,$m.circulation.nominal_width_ft,$m.circulation.nominal_depth_ft,$m.circulation.code_clearance_verified)
Check 'floor-lineage' ([int]$m.floors.native_floor_count -ge 1 -and [int]$m.floors.landing_floor_id -gt 0) ("count={0}; landing={1}" -f $m.floors.native_floor_count,$m.floors.landing_floor_id)
$ifc = Join-Path $StudyDirectory 'FH_Stair_Landing_Coordination_Study.ifc'
$ifcText = if (Test-Path -LiteralPath $ifc) { Get-Content -LiteralPath $ifc -Raw } else { '' }
Check 'ifc-present' (Test-Path -LiteralPath $ifc) $ifc
Check 'ifc-step-schema' ($ifcText.StartsWith('ISO-10303-21;') -and $ifcText -match 'IFC2X3') 'IFC2X3 STEP'
Check 'ifc-stair-floor-entities' ($ifcText -match 'IFCSTAIR' -and (($ifcText -match 'IFCSLAB') -or ($ifcText -match 'IFCFLOOR'))) 'IFC stair + slab/floor entities'
$passed = @($checks | Where-Object pass).Count
$out = [pscustomobject]@{schema='forever-home.native-stair-landing-coordination-validation-v1'; pass=($passed -eq $checks.Count); passed=$passed; total=$checks.Count; checks=$checks; study_directory=(Resolve-Path $StudyDirectory).Path}
$out | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $StudyDirectory 'stair-landing-coordination-validation.json') -Encoding UTF8
$checks | Format-Table -AutoSize
$out | ConvertTo-Json -Depth 8
if (-not $out.pass) { exit 1 }
