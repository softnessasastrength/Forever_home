param(
    [Parameter(Mandatory = $true)][string]$StudyDirectory,
    [Parameter(Mandatory = $true)][string]$Output
)

$ErrorActionPreference = 'Stop'
function Hash-Shared([string]$Path) {
    $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete)
    try { (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash.ToUpperInvariant() } finally { $stream.Dispose() }
}
function Check([string]$Name, [bool]$Pass, [string]$Detail) { $script:Checks += [pscustomobject]@{ name = $Name; pass = $Pass; detail = $Detail } }

$manifestPath = Join-Path $StudyDirectory 'opening-study-manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "Missing manifest: $manifestPath" }
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$Checks = @()
Check 'schema' ($manifest.schema -eq 'forever-home-main-floor-opening-study-v1') $manifest.schema
Check 'status' ($manifest.status -eq 'disposable native opening comparison; not selected-D') $manifest.status
Check 'input_hash' ((Hash-Shared (Join-Path (Get-Location) $manifest.input)) -eq $manifest.input_sha256) 'candidate input remains pinned'
Check 'case_count' (@($manifest.cases).Count -eq 2) "cases=$(@($manifest.cases).Count)"
Check 'case_ids' ((@($manifest.cases.case_id) | Sort-Object) -join ',' -eq 'pantry-30in,pantry-36in') '30-in and 36-in comparison cases'
foreach ($case in @($manifest.cases)) {
    $dir = Join-Path $StudyDirectory $case.case_id
    $rvt = Join-Path $dir $case.saved_rvt
    $ifc = Join-Path $dir $case.ifc
    Check "$($case.case_id)_rvt" ((Test-Path -LiteralPath $rvt -PathType Leaf) -and ((Hash-Shared $rvt) -eq $case.saved_rvt_sha256)) 'saved RVT exists and hash matches'
    $ifcText = if (Test-Path -LiteralPath $ifc -PathType Leaf) { Get-Content -LiteralPath $ifc -Raw } else { '' }
    $wallCount = ([regex]::Matches($ifcText, '#\d+=IFCWALL(?:STANDARDCASE)?\b', 'IgnoreCase')).Count
    Check "$($case.case_id)_ifc" ($ifcText -match 'ISO-10303-21;' -and $ifcText -match "FILE_SCHEMA\s*\(\s*\(\s*'IFC2X3" -and (Hash-Shared $ifc) -eq $case.ifc_sha256 -and $wallCount -ge 11) "IFC2x3; walls=$wallCount"
    Check "$($case.case_id)_geometry" ($case.wall_count -eq 11 -and @($case.apertures).Count -eq 3 -and @($case.apertures | Where-Object { $_.selected -ne $false }).Count -eq 0) '11 native wall segments; three documented apertures; none selected'
    $pantry = @($case.apertures | Where-Object id -eq 'pantry-door')[0]
    $expected = if ($case.case_id -eq 'pantry-30in') { 2.5 } else { 3.0 }
    Check "$($case.case_id)_pantry_width" ([Math]::Abs([double]$pantry.nominal_width_ft - $expected) -lt 0.000001) "nominal pantry gap=$($pantry.nominal_width_ft) ft"
}
$failed = @($Checks | Where-Object { -not $_.pass })
$report = [ordered]@{ schema = 'forever-home-native-main-floor-opening-validation-v1'; status = if ($failed.Count -eq 0) { 'pass' } else { 'fail' }; checks = $Checks; passed = @($Checks | Where-Object pass).Count; total = $Checks.Count; limitations = @('Native gaps are nominal comparison geometry, not door families or finished clear openings.', 'Template wall type and harness height remain unselected.', 'No code, accessibility, structural, professional, permit or construction conclusion follows.') }
$parent = Split-Path -Parent ([IO.Path]::GetFullPath($Output)); if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $Output -Encoding UTF8
if ($failed.Count -gt 0) { $failed | Format-Table | Out-String | Write-Error; exit 1 }
Write-Output "PASS: $($report.passed)/$($report.total) native opening checks."
