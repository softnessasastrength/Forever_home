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
