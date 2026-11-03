param(
    [string]$CompositionDirectory = '.local/revit-pilot/multi-level-composition/20261103T150109911Z',
    [string]$SequenceReport = '.local/revalidation/verified-bim-sequence-m396.json',
    [string]$Output = '.local/revalidation/m396-review-handoff.json'
)

$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
function Read-Json([string]$path) {
    $full = if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $repo $path }
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { throw "Missing evidence: $path" }
    return Get-Content -LiteralPath $full -Raw | ConvertFrom-Json
}
function Full([string]$path) { if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $repo $path } }
function Check([string]$name, [bool]$pass, [string]$detail) { $script:checks += [pscustomobject]@{ name = $name; pass = $pass; detail = $detail } }

$manifest = Read-Json (Join-Path $CompositionDirectory 'multi-level-composition-manifest.json')
$sequence = Read-Json $SequenceReport
$rvt = Full (Join-Path $CompositionDirectory $manifest.saved_rvt)
$ifc = Full (Join-Path $CompositionDirectory $manifest.ifc)
$checks = @()
Check 'composition_schema' ($manifest.schema -eq 'forever-home-multi-level-composition-v10') $manifest.schema
Check 'selected_d_protected' ($manifest.selected_d_sha256 -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb') $manifest.selected_d_sha256
Check 'native_opening_inventory' ($manifest.native_opening_count -eq 3 -and $manifest.opening_status -like 'three native wall openings*') $manifest.opening_status
Check 'interior_inventory' ($manifest.kitchen_island_count -eq 1 -and $manifest.primary_bath_fixture_proxy_count -eq 2) "island=$($manifest.kitchen_island_count); bath=$($manifest.primary_bath_fixture_proxy_count)"
Check 'roof_skylight_inventory' ($manifest.roof_count -eq 3 -and $manifest.skylight_reservation_count -eq 9) "roofs=$($manifest.roof_count); skylights=$($manifest.skylight_reservation_count)"
Check 'unassigned_m06_boundary' ($manifest.limitations -join ' ' -match 'M-06/B remains unassigned') 'M-06/B remains unassigned'
Check 'rvt_lineage' ((Test-Path -LiteralPath $rvt -PathType Leaf) -and ($manifest.saved_rvt_sha256 -eq (Get-FileHash -LiteralPath $rvt -Algorithm SHA256).Hash.ToLowerInvariant())) $manifest.saved_rvt_sha256
Check 'ifc_lineage' ((Test-Path -LiteralPath $ifc -PathType Leaf) -and ($manifest.ifc_sha256 -eq (Get-FileHash -LiteralPath $ifc -Algorithm SHA256).Hash.ToLowerInvariant())) $manifest.ifc_sha256
Check 'ifc2x3_entities' ($manifest.ifc2x3 -and (Select-String -LiteralPath $ifc -Pattern 'FILE_SCHEMA\(\(\x27IFC2X3\x27\)\)' -Quiet) -and (Select-String -LiteralPath $ifc -Pattern 'IFCWALL' -Quiet) -and (Select-String -LiteralPath $ifc -Pattern 'IFCROOF' -Quiet)) 'IFC2X3 wall/roof entities present'
Check 'ifc_openings' (@((Select-String -LiteralPath $ifc -Pattern 'IFCOPENINGELEMENT' -AllMatches).Matches).Count -eq 3) "IFCOPENINGELEMENT count=$(@((Select-String -LiteralPath $ifc -Pattern 'IFCOPENINGELEMENT' -AllMatches).Matches).Count)"
Check 'consolidated_sequence' ($sequence.status -eq 'pass' -and $sequence.steps.Count -eq 13 -and @($sequence.steps | Where-Object { $_.pass -ne $true }).Count -eq 0) "steps=$($sequence.steps.Count); status=$($sequence.status)"

$failed = @($checks | Where-Object { -not $_.pass })
$out = Full $Output
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out) | Out-Null
[ordered]@{
    schema = 'forever-home-m396-review-handoff-v2'
    status = if ($failed.Count -eq 0) { 'pass' } else { 'fail' }
    composition_directory = $CompositionDirectory
    sequence_report = $SequenceReport
    checks = $checks
    limitations = @(
        'This packet gate proves source lineage and retained evidence only; it does not select the disposable composition.',
        'Native openings are nominal comparison cuts; door families, clear leaves, swing, threshold, approach, assemblies, structure, MEP and code remain open.',
        'No professional, permit or construction-readiness conclusion follows.'
    )
} | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $out -Encoding UTF8
$checks | Format-Table
if ($failed.Count) { throw "M396 review handoff failed $($failed.Count) checks." }
Write-Output "PASS: $($checks.Count)/$($checks.Count) review-handoff checks; report $Output"
