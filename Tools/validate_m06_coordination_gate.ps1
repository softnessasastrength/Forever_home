param(
    [string]$OutputPath = '.local/revalidation/m06-coordination-gate.json',
    [string]$SelectedDPath = 'Architecture/Selected_Design_Iteration_2026-10-27/study.json',
    [string]$SinkReportPath = '.local/revalidation/m06-evolution-family-current.json',
    [string]$ToiletReportPath = '.local/revalidation/M95-current-toilet-envelope.json'
)

$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
function Read-Json([string]$path) {
    $full = if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $repo $path }
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { throw "Missing evidence: $path" }
    return Get-Content -LiteralPath $full -Raw | ConvertFrom-Json
}
function Check([string]$name, [bool]$pass, [string]$detail) {
    $script:checks += [pscustomobject]@{ name=$name; pass=$pass; detail=$detail }
}

$checks = @()
$selected = Read-Json $SelectedDPath
$sink = Read-Json $SinkReportPath
$toilet = Read-Json $ToiletReportPath
$selectedHash = (Get-FileHash -LiteralPath (Join-Path $repo $SelectedDPath) -Algorithm SHA256).Hash.ToLowerInvariant()

Check 'selected_d_fingerprint' ($selectedHash -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb') 'Selected-D source remains the pinned owner-selected study.'
Check 'm06_unassigned' ($selected.selection.main_public_bath.footprint -eq 'TBD' -and $selected.selection.main_public_bath.position -eq 'TBD') 'M-06 remains unassigned.'
Check 'verified_lavatory_geometry' ($sink.result -eq 'PASS' -and $sink.check_count -ge 17) 'American Standard Evolution family evidence is measured and hash-pinned.'
Check 'current_toilet_envelope' ($toilet.schema -eq 'forever-home-m06-current-toilet-infographic-envelope-v1' -and $toilet.candidate.exact_revit_family_or_solid_geometry_verified -eq $false -and @($toilet.target_zone.orientations | Where-Object { $_.contained_in_gross_B -eq $true }).Count -eq 2) 'Current 610AA infographic is only a gross envelope, contained in B in both orientations.'
Check 'clearance_basis_present' (Test-Path (Join-Path $repo 'Research/CT_M06_Fixture_Clearance_Basis_2026-11-01.md')) 'Preliminary 15/30/21-in screening basis is present and labelled non-compliance.'

$gates = [ordered]@{
    product_geometry = $false
    finished_face_clearance = $false
    door_and_approach = $false
    service_route = $false
    room_assignment = $false
}
$report = [ordered]@{
    schema = 'forever-home-m06-coordination-gate-v1'
    status = if (@($checks | Where-Object { -not $_.pass }).Count -eq 0) { 'screen-valid-but-fit-blocked' } else { 'evidence-invalid' }
    selected_d_sha256 = $selectedHash
    checks = $checks
    coordination_gates = $gates
    limitations = @(
        'The exact current 610AA001.020 Revit family or assembled solid geometry remains unavailable.',
        'The sink evidence is a verified family comparison, not a selected fixture installation.',
        'The 15/30/21-in values are a preliminary Connecticut screening basis, not a code-compliance determination.',
        'No finished-face clearance, real door leaf/swing, public approach, or supply/drain/vent route is modelled.',
        'B must remain unassigned until all four coordination gates support a fit.'
    )
}
$out = if ([IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $repo $OutputPath }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out) | Out-Null
$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $out -Encoding UTF8
if (@($checks | Where-Object { -not $_.pass }).Count -gt 0) { throw 'M-06 evidence contract failed; see report.' }
Write-Output "PASS: M-06 coordination evidence contract valid; fit remains blocked pending product/clearance/door/approach/service gates. Report: $out"
