param(
    [string]$Output = '.local/revalidation/m352-walkthrough-coordination-package.json'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
function ResolveRepoPath([string]$p) { [IO.Path]::GetFullPath((Join-Path $root $p)) }
function FileHash([string]$p) { (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant() }
function Require([bool]$ok, [string]$message) { if (-not $ok) { throw $message } }
function Check([string]$name, [bool]$pass, [string]$detail) { [ordered]@{ name=$name; pass=$pass; detail=$detail } }

$selected = ResolveRepoPath 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$selectedHash = FileHash $selected
$expectedSelectedHash = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
$roofDir = ResolveRepoPath '.local/revit-pilot/native-roof-shell/20261102T041843122Z'
$landingDir = ResolveRepoPath '.local/revit-pilot/compact-core-landing/20261102T033153576Z'
$floorDir = ResolveRepoPath '.local/revit-pilot/main-floor-floor-plate/20261101T220743680Z'
$assemblyDir = ResolveRepoPath '.local/revit-pilot/integrated-main-floor-assembly/20261102T141223011Z'
$roof = Get-Content (Join-Path $roofDir 'native-roof-shell-manifest.json') -Raw | ConvertFrom-Json
$landing = Get-Content (Join-Path $landingDir 'landing-study-manifest.json') -Raw | ConvertFrom-Json
$floor = Get-Content (Join-Path $floorDir 'floor-plate-manifest.json') -Raw | ConvertFrom-Json
$assembly = Get-Content (Join-Path $assemblyDir 'integrated-main-floor-assembly-manifest.json') -Raw | ConvertFrom-Json
$selectedDoc = Get-Content $selected -Raw | ConvertFrom-Json

$checks = @(
    Check 'selected_d_hash' ($selectedHash -eq $expectedSelectedHash) 'Selected-D source is unchanged.'
    Check 'roof_manifest' ($roof.schema -eq 'forever-home.native-roof-shell-v1' -and $roof.status -like 'disposable native roof comparison*' -and $roof.native_roof_count -eq 3) 'Three unselected documented roof options are present.'
    Check 'roof_files' ((Test-Path (Join-Path $roofDir $roof.saved_rvt)) -and (Test-Path (Join-Path $roofDir $roof.ifc.file)) -and (Get-Item (Join-Path $roofDir $roof.ifc.file)).Length -gt 0) 'Roof RVT and IFC are present and non-empty.'
    Check 'landing_manifest' ($landing.schema -eq 'forever-home.compact-core-native-landing-study-v1' -and $landing.status -like 'disposable*' -and $landing.landing.area_sqft -gt 0) 'Landing bridge manifest is present with positive measured area.'
    Check 'landing_files' ((Test-Path (Join-Path $landingDir $landing.saved_rvt)) -and (Test-Path (Join-Path $landingDir $landing.ifc))) 'Landing RVT and IFC are present.'
    Check 'floor_manifest' ($floor.schema -eq 'forever-home-main-floor-floor-plate-v1' -and $floor.status -like 'disposable*' -and $floor.floor_count -eq 3) 'Three provisional floor plates are present.'
    Check 'assembly_manifest' ($assembly.schema -eq 'forever-home-integrated-main-floor-assembly-v1' -and $assembly.status -like 'disposable*' -and $assembly.wall_count -eq 57 -and $assembly.door_count -eq 12) 'Integrated main-floor assembly is present and unselected.'
    Check 'assembly_ifc' ((Test-Path (Join-Path $assemblyDir $assembly.ifc)) -and (Get-Item (Join-Path $assemblyDir $assembly.ifc)).Length -gt 0 -and (Select-String -LiteralPath (Join-Path $assemblyDir $assembly.ifc) -Pattern 'IFCWALL' -Quiet) -and (Select-String -LiteralPath (Join-Path $assemblyDir $assembly.ifc) -Pattern 'IFCDOOR' -Quiet)) 'Integrated assembly IFC contains wall and door entities.'
    Check 'm06_unassigned' ($selectedDoc.selection.main_public_bath.footprint -eq 'TBD' -and $selectedDoc.selection.main_public_bath.service_route -eq 'TBD') 'M-06 remains unassigned in Selected-D.'
)
$failed = @($checks | Where-Object { -not $_.pass })
$report = [ordered]@{
    schema = 'forever-home-walkthrough-coordination-package-v1'
    status = if ($failed.Count -eq 0) { 'PASS: retained derivatives are lineage-compatible for a future disposable walkthrough composition.' } else { 'FAIL' }
    source_hashes_sha256 = [ordered]@{ selected_d = $selectedHash; roof_manifest = FileHash (Join-Path $roofDir 'native-roof-shell-manifest.json'); landing_manifest = FileHash (Join-Path $landingDir 'landing-study-manifest.json'); floor_manifest = FileHash (Join-Path $floorDir 'floor-plate-manifest.json'); assembly_manifest = FileHash (Join-Path $assemblyDir 'integrated-main-floor-assembly-manifest.json') }
    checks = $checks
    composition_created = $false
    limitations = @('This gate validates retained disposable derivatives; it does not create a new composed RVT.', 'Roof pitch, floor-to-floor datum, wall/floor assemblies, structure, MEP, and M-06 remain unselected.', 'A future composition must reopen and validate the combined derivative before walkthrough use.')
}
$out = ResolveRepoPath $Output
[IO.Directory]::CreateDirectory((Split-Path $out -Parent)) | Out-Null
[IO.File]::WriteAllText($out, (ConvertTo-Json $report -Depth 16) + "`r`n", [Text.UTF8Encoding]::new($false))
if ($failed.Count -gt 0) { throw "M352 coordination package failed $($failed.Count) checks." }
Write-Output "PASS: M352 coordination package gate $($checks.Count)/$($checks.Count); composition remains pending disposable Revit composition."
