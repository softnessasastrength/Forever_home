param(
    [string]$Output = '.local/revalidation/verified-bim-milestone.json',
    [string]$NativeStairStudyDirectory = '.local/revit-pilot/split-rise-native-stair/20261101T225749874Z',
    [string]$NativeRoofStudyDirectory = '.local/revit-pilot/native-roof-shell/20261102T041843122Z',
    [string]$M218StudyDirectory = '.local/revit-pilot/m218-pantry-door-study/20261101T212718036Z',
    [string]$M06CoordinationReport = '.local/revalidation/m06-coordination-gate-m336.json',
    [string]$M06ProxyStudyDirectory = '.local/revit-pilot/m06-proxy-study/20261102T122827829Z',
    [string]$NativeOpeningStudyDirectory = '.local/revit-pilot/main-floor-openings/20261102T125705634Z',
    [string]$DocumentedDoorStudyDirectory = '.local/revit-pilot/documented-door-study/20261102T133842605Z',
    [string]$DocumentedOpeningAssemblyDirectory = '.local/revit-pilot/documented-opening-assembly/20261102T135857068Z',
    [string]$IntegratedMainFloorAssemblyDirectory = '.local/revit-pilot/integrated-main-floor-assembly/20261102T141223011Z',
    [string]$MainFloorCoordinationReport = '.local/revalidation/main-floor-chain-20261102/coordination.json'
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
$m325 = Read-Json (Join-Path $NativeStairStudyDirectory 'native-stair-validation.json')
$m333 = Read-Json (Join-Path $NativeRoofStudyDirectory 'native-roof-shell-validation.json')
$m218 = Read-Json (Join-Path $M218StudyDirectory 'm218-revit-study-manifest.json')
$m06Coordination = Read-Json $M06CoordinationReport
$m06Proxy = Read-Json (Join-Path $M06ProxyStudyDirectory 'm06-proxy-study-manifest.json')
$m346Openings = Read-Json (Join-Path $NativeOpeningStudyDirectory 'opening-study-manifest.json')
$m347Doors = Read-Json (Join-Path $DocumentedDoorStudyDirectory 'documented-door-study-manifest.json')
$m348Assembly = Read-Json (Join-Path $DocumentedOpeningAssemblyDirectory 'documented-opening-assembly-manifest.json')
$m349Assembly = Read-Json (Join-Path $IntegratedMainFloorAssemblyDirectory 'integrated-main-floor-assembly-manifest.json')
$mainFloorCoordination = Read-Json $MainFloorCoordinationReport

Add-Check 'selected_d_baseline' ($baseline.status -eq 'pass' -and $baseline.replay_count -eq 2 -and $baseline.geometry_check_count_per_replay -eq 43 -and $baseline.ifc_checks_passed -eq 26 -and $baseline.protected_inputs_unchanged) '2 x 43 source replay; retained IFC 26/26; protected inputs unchanged'
Add-Check 'main_floor_wall_plate_chain' ($chain.passed -eq 9 -and $chain.total -eq 9) 'M318 provenance/inventory gate'
Add-Check 'm06_public_candidate' ([bool]$m06.pass -and @($m06.checks | Where-Object { $_.pass -ne $true }).Count -eq 0) 'isolated public-family evidence with no placement'
Add-Check 'm06_gross_envelope' ($m120.status -match '^passed' -and $m120.pair_count -eq 16 -and $m120.gross_containment_count -eq 16 -and -not [bool]$m120.fit_window.assigned) '16/16 gross pairs; B remains unassigned'
Add-Check 'm02_kitchen_ifc' ($m321.status -eq 'pass' -and @($m321.checks.PSObject.Properties | Where-Object { $_.Value -ne $true }).Count -eq 0) 'isolated kitchen furnishing IFC gate'
Add-Check 'm333_native_roof' ($m333.passed -eq $m333.total -and $m333.total -eq 13 -and @($m333.checks | Where-Object { $_.pass -ne $true }).Count -eq 0) 'three native 8:12/10:12/12:12 roof RVT/IFC gate'
Add-Check 'm325_native_stair' ($m325.pass -eq $true -and $m325.checks.Count -ge 14 -and @($m325.checks | Where-Object { $_.pass -ne $true }).Count -eq 0) 'disposable native split-rise stair RVT/IFC gate'
Add-Check 'm218_native_pantry_doors' ($m218.status -match '^pass' -and @($m218.files).Count -eq 2 -and @($m218.files | Where-Object { $_.sha256 -and $_.bytes -gt 0 -and $_.wall_count -eq 13 -and $_.model_curve_count -eq 48 }).Count -eq 2 -and $m218.project_scope.selected_d_opened -eq $false -and $m218.project_scope.selected_d_modified -eq $false) 'two native pantry swing derivatives; Selected-D untouched'
Add-Check 'm336_m06_coordination_contract' ($m06Coordination.status -eq 'screen-valid-but-fit-blocked' -and $m06Coordination.selected_d_sha256 -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb' -and $m06Coordination.coordination_gates.product_geometry -eq $false -and $m06Coordination.coordination_gates.door_and_approach -eq $false -and $m06Coordination.coordination_gates.service_route -eq $false -and $m06Coordination.coordination_gates.room_assignment -eq $false) 'M336 M-06 evidence contract valid while fit remains blocked'
Add-Check 'm344_native_m06_proxy' ($m06Proxy.schema -eq 'forever-home-m06-proxy-study-v1' -and $m06Proxy.status -eq 'disposable proxy comparison; not selected and B unassigned' -and @($m06Proxy.records | Where-Object { $_.selected -ne $false }).Count -eq 0 -and @($m06Proxy.gates.PSObject.Properties | Where-Object { $_.Value -ne $false }).Count -eq 0 -and $m06Proxy.ifc.file -eq 'FH_M06_Proxy_Setup.ifc' -and $m06Proxy.ifc.sha256.Length -eq 64) 'M344 native M-06 proxy RVT/IFC remains labelled and unassigned'
Add-Check 'm346_native_main_floor_openings' ($m346Openings.schema -eq 'forever-home-main-floor-opening-study-v1' -and $m346Openings.status -match '^disposable native opening comparison' -and @($m346Openings.cases).Count -eq 2 -and @($m346Openings.cases | Where-Object { $_.wall_count -eq 11 -and @($_.apertures).Count -eq 3 -and @($_.apertures | Where-Object { $_.selected -ne $false }).Count -eq 0 -and $_.saved_rvt_sha256.Length -eq 64 -and $_.ifc_sha256.Length -eq 64 }).Count -eq 2) 'M346 native front/rear/pantry opening comparison remains disposable and unselected'
Add-Check 'm347_documented_door_study' ($m347Doors.schema -eq 'forever-home-documented-door-study-v1' -and $m347Doors.status -eq 'disposable nominal door-family comparison; not selected-D' -and @($m347Doors.cases).Count -eq 2 -and @($m347Doors.cases | Where-Object { $_.wall_count -eq 8 -and $_.door_count -eq 4 -and @($_.door_records).Count -eq 4 -and @($_.door_records | Where-Object { $_.selected -ne $false }).Count -eq 0 -and $_.saved_rvt_sha256.Length -eq 64 -and $_.ifc_sha256.Length -eq 64 }).Count -eq 2) 'M347 documented nominal D-01/D-02/D-03/D-04 family comparison remains disposable and unselected'
Add-Check 'm348_documented_opening_assembly' ($m348Assembly.schema -eq 'forever-home-documented-opening-assembly-v1' -and $m348Assembly.status -eq 'disposable documented opening assembly comparison; not selected-D' -and @($m348Assembly.cases).Count -eq 2 -and @($m348Assembly.cases | Where-Object { $_.wall_count -eq 16 -and $_.door_count -eq 4 -and $_.opening_count -eq 4 -and @($_.door_records).Count -eq 4 -and @($_.door_records | Where-Object { $_.selected -ne $false -or $_.opening_modeled -ne $true }).Count -eq 0 -and $_.saved_rvt_sha256.Length -eq 64 -and $_.ifc_sha256.Length -eq 64 }).Count -eq 2) 'M348 documented nominal openings use native host segments and remain disposable and unselected'
Add-Check 'm349_integrated_main_floor_assembly' ($m349Assembly.schema -eq 'forever-home-integrated-main-floor-assembly-v1' -and $m349Assembly.status -eq 'disposable integrated assembly comparison; not selected-D' -and @($m349Assembly.cases).Count -eq 3 -and $m349Assembly.wall_count -eq 57 -and $m349Assembly.door_count -eq 12 -and @($m349Assembly.cases | Where-Object { $_.wall_count -eq 19 -and $_.door_count -eq 4 -and $_.selected -eq $false -and @($_.door_records).Count -eq 4 -and @($_.door_records | Where-Object { $_.selected -ne $false -or $_.opening_modeled -ne $true }).Count -eq 0 }).Count -eq 3 -and $m349Assembly.saved_rvt_sha256.Length -eq 64 -and $m349Assembly.ifc_sha256.Length -eq 64) 'M349 integrated candidate-21 main-floor assembly remains disposable and unselected'
Add-Check 'main_floor_coordination_chain' ($mainFloorCoordination.schema -eq 'forever-home-main-floor-coordination-chain-v1' -and $mainFloorCoordination.passed -eq 9 -and $mainFloorCoordination.total -eq 9) 'native wall/plate provenance and profile gate'

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
