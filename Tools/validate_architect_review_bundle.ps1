param(
    [string]$Output = '.local/revalidation/architect-review-bundle-m402.json',
    [string]$CompositionManifest = '.local/revit-pilot/multi-level-composition/20261103T150109911Z/multi-level-composition-manifest.json',
    [string]$InteriorManifest = '.local/revit-pilot/interior-design-study/20261103T134122674Z/interior-design-study-manifest.json',
    [string]$RoofManifest = '.local/revit-pilot/native-roof-shell/20261103T122806425Z/native-roof-shell-manifest.json',
    [string]$StairValidation = '.local/revit-pilot/split-rise-native-stair/20261101T225749874Z/native-stair-validation.json',
    [string]$M06Report = '.local/revalidation/m06-coordination-gate-sequence.json'
)

$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
$checks = [System.Collections.Generic.List[object]]::new()
function Check([string]$Name, [bool]$Pass, [string]$Detail) {
    $checks.Add([pscustomobject]@{ name=$Name; pass=$Pass; detail=$Detail })
    if ($Pass) { Write-Output "PASS $Name`: $Detail" } else { Write-Output "FAIL $Name`: $Detail" }
}
function ReadJson([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "Missing required evidence: $Path" }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}
function ResolveEvidence([string]$BaseDirectory, [string]$RelativePath) {
    $candidate = Join-Path $BaseDirectory $RelativePath
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { throw "Missing artifact: $candidate" }
    return Get-Item -LiteralPath $candidate
}
function HashMatches([IO.FileInfo]$File, [string]$Expected) {
    return ((Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash -eq $Expected)
}
function IsIfc2x3([IO.FileInfo]$File) {
    $head = Get-Content -LiteralPath $File.FullName -Raw
    return ($head -match 'IFC2X3')
}

$composition = ReadJson $CompositionManifest
$interior = ReadJson $InteriorManifest
$roof = ReadJson $RoofManifest
$stair = ReadJson $StairValidation
$m06 = ReadJson $M06Report
$selectedHash = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'

Check 'composition_schema' ($composition.schema -eq 'forever-home-multi-level-composition-v10') $composition.schema
Check 'composition_selected_d_lineage' ($composition.selected_d_sha256 -eq $selectedHash) $composition.selected_d_sha256
Check 'composition_inventory' ($composition.wall_count -gt 0 -and $composition.floor_count -gt 0 -and $composition.roof_count -gt 0 -and $composition.native_opening_count -gt 0) ("walls={0}; floors={1}; roofs={2}; openings={3}" -f $composition.wall_count,$composition.floor_count,$composition.roof_count,$composition.native_opening_count)
Check 'composition_m06_unassigned' ($composition.status -match 'not selected-D' -and $composition.limitations -match 'M-06/B remains unassigned') 'M-06/B remains unassigned'
Check 'interior_study_validated' ($interior.schema -eq 'forever-home-interior-design-study-v1' -and $interior.cases.Count -eq 3 -and $interior.wall_count -eq 72) ("cases={0}; walls={1}; baths={2}" -f $interior.cases.Count,$interior.wall_count,$interior.primary_bath_vignette_count)
Check 'interior_selected_d_lineage' ($interior.selected_d_sha256 -eq $selectedHash) $interior.selected_d_sha256
Check 'roof_study_present' ($roof.native_roof_count -eq 3 -and $roof.skylight_reservation_count -eq 9) ("roofs={0}; skylights={1}" -f $roof.native_roof_count,$roof.skylight_reservation_count)
Check 'native_stair_evidence_present' ($stair.pass -eq $true) $stair.schema
Check 'm06_boundary_preserved' ($m06.status -eq 'screen-valid-but-fit-blocked') $m06.status

$compositionDir = Split-Path -Parent (Join-Path $repo $CompositionManifest)
$interiorDir = Split-Path -Parent (Join-Path $repo $InteriorManifest)
$roofDir = Split-Path -Parent (Join-Path $repo $RoofManifest)
$stairDir = Split-Path -Parent (Join-Path $repo $StairValidation)
$stairManifest = ReadJson (Join-Path $stairDir 'study-manifest.json')
$compositionRvt = ResolveEvidence $compositionDir $composition.saved_rvt
$compositionIfc = ResolveEvidence $compositionDir $composition.ifc
$interiorRvt = ResolveEvidence $interiorDir $interior.saved_rvt
$interiorIfc = ResolveEvidence $interiorDir $interior.ifc
$roofRvt = ResolveEvidence $roofDir $roof.saved_rvt
$roofIfc = ResolveEvidence $roofDir $roof.ifc.file
$stairRvt = ResolveEvidence $stairDir $stairManifest.saved_rvt
$stairIfc = ResolveEvidence $stairDir $stairManifest.ifc
Check 'composition_artifact_hashes' ((HashMatches $compositionRvt $composition.saved_rvt_sha256) -and (HashMatches $compositionIfc $composition.ifc_sha256)) ("RVT={0}; IFC={1}" -f $compositionRvt.Length,$compositionIfc.Length)
Check 'interior_artifact_hashes' ((HashMatches $interiorRvt $interior.saved_rvt_sha256) -and (HashMatches $interiorIfc $interior.ifc_sha256)) ("RVT={0}; IFC={1}" -f $interiorRvt.Length,$interiorIfc.Length)
Check 'roof_artifact_hashes' ((HashMatches $roofRvt $roof.saved_rvt_sha256) -and (HashMatches $roofIfc $roof.ifc.sha256)) ("RVT={0}; IFC={1}" -f $roofRvt.Length,$roofIfc.Length)
Check 'stair_artifacts_present' ((HashMatches $stairRvt $stairManifest.saved_rvt_sha256) -and $stairIfc.Length -gt 0) ("RVT={0}; IFC={1}" -f $stairRvt.Length,$stairIfc.Length)
Check 'composition_ifc2x3' (IsIfc2x3 $compositionIfc) 'IFC2X3 header present'
Check 'interior_ifc2x3' (IsIfc2x3 $interiorIfc) 'IFC2X3 header present'
Check 'roof_ifc2x3' (IsIfc2x3 $roofIfc) 'IFC2X3 header present'
Check 'stair_ifc2x3' (IsIfc2x3 $stairIfc) 'IFC2X3 header present'

$failed = @($checks | Where-Object { -not $_.pass })
$out = if ([IO.Path]::IsPathRooted($Output)) { $Output } else { Join-Path $repo $Output }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out) | Out-Null
[ordered]@{
    schema = 'forever-home-architect-review-bundle-v1'
    status = if ($failed.Count -eq 0) { 'pass' } else { 'fail' }
    selected_d_sha256 = $selectedHash
    checks = $checks
    evidence = [ordered]@{ composition=$CompositionManifest; interior=$InteriorManifest; roof=$RoofManifest; stair=$StairValidation; m06=$M06Report }
    limitations = @(
        'This bundle indexes disposable comparison studies; it does not promote any derivative to Selected-D.',
        'M-06/B remains fit-blocked or unassigned until product, approach, service-route and clearance evidence agree.',
        'No code-compliance, structural-safety, professional, permit or construction-readiness conclusion follows.'
    )
} | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $out -Encoding UTF8
if ($failed.Count -gt 0) { throw "Architect-review bundle failed $($failed.Count) check(s)" }
Write-Output "PASS: architect-review bundle completed $($checks.Count) checks; report $out"
