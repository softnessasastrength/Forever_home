param(
    [Parameter(Mandatory=$true)][string]$CandidateManifestPath,
    [Parameter(Mandatory=$true)][string]$FloorPlateManifestPath,
    [Parameter(Mandatory=$true)][string]$Output
)

$ErrorActionPreference = 'Stop'

function Resolve-RepoPath([string]$Path) {
    if ([System.IO.Path]::IsPathRooted($Path)) { return [System.IO.Path]::GetFullPath($Path) }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Path))
}

function Hash-File([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Missing file: $Path" }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

$candidatePath = Resolve-RepoPath $CandidateManifestPath
$platePath = Resolve-RepoPath $FloorPlateManifestPath
$outputPath = Resolve-RepoPath $Output
$candidate = Get-Content -LiteralPath $candidatePath -Raw | ConvertFrom-Json
$plates = Get-Content -LiteralPath $platePath -Raw | ConvertFrom-Json
$checks = New-Object System.Collections.Generic.List[object]

function Check([string]$Name, [bool]$Pass, [string]$Detail) {
    $checks.Add([pscustomobject]@{ name=$Name; pass=$Pass; detail=$Detail })
}

$candidateRun = Split-Path -Parent $candidatePath
$candidateRvt = Join-Path $candidateRun $candidate.saved_rvt
$plateRun = Split-Path -Parent $platePath
$plateRvt = Join-Path $plateRun $plates.saved_rvt

$candidateActual = Hash-File $candidateRvt
$plateActual = Hash-File $plateRvt
Check 'candidate_saved_rvt_hash' ($candidateActual -eq $candidate.saved_rvt_sha256.ToUpperInvariant()) "actual=$candidateActual"
Check 'plate_saved_rvt_hash' ($plateActual -eq $plates.saved_rvt_sha256.ToUpperInvariant()) "actual=$plateActual"
Check 'source_chain_hash' ($plates.source_rvt_sha256.ToUpperInvariant() -eq $candidate.saved_rvt_sha256.ToUpperInvariant()) 'floor derivative source equals M313 candidate RVT'
Check 'candidate_wall_count' ([int]$candidate.wall_count -eq 42) "count=$($candidate.wall_count)"
Check 'plate_wall_count' ([int]$plates.wall_count -eq 42) "count=$($plates.wall_count)"
Check 'plate_count' ([int]$plates.floor_count -eq 3 -and @($plates.floors).Count -eq 3) "count=$($plates.floor_count)"

$expectedOffsets = @(0.0, 60.0, 120.0)
$actualOffsets = @($plates.floors | ForEach-Object { [double]$_.offset_ft })
$offsetsMatch = $actualOffsets.Count -eq 3
for ($i=0; $i -lt [Math]::Min($actualOffsets.Count, 3); $i++) {
    if ([Math]::Abs($actualOffsets[$i] - $expectedOffsets[$i]) -gt 0.000001) { $offsetsMatch = $false }
}
Check 'translated_plate_offsets' $offsetsMatch "offsets=$($actualOffsets -join ',')"
$profilesMatch = @($plates.floors | Where-Object {
    [Math]::Abs([double]$_.profile_width_ft - 40.0) -le 0.000001 -and
    [Math]::Abs([double]$_.profile_depth_ft - 42.0) -le 0.000001 -and
    [Math]::Abs([double]$_.profile_area_sqft - 1680.0) -le 0.000001
}).Count -eq 3
Check 'plate_profiles' $profilesMatch 'all three plates are 40 x 42 ft / 1,680 sf'
Check 'unselected_status' ($plates.status -match 'unselected' -and $candidate.status -match 'unselected') 'both source and derivative are explicitly unselected'
$checksArray = @($checks | ForEach-Object { $_ })
$passedCount = @($checksArray | Where-Object { $_.pass -eq $true }).Count

$report = [pscustomobject]@{
    schema = 'forever-home-main-floor-coordination-chain-v1'
    status = 'disposable wall/plate provenance gate; not selected-D or construction approval'
    candidate_manifest = $candidatePath
    floor_plate_manifest = $platePath
    checks = $checksArray
    passed = $passedCount
    total = $checksArray.Count
    limitations = @(
        'This gate proves source lineage and inventory/profile consistency only.',
        'The template floor type, wall assembly, openings, doors, stairs, roof, structure, MEP and clearances remain unresolved.',
        'No code, structural, professional, permit or construction-readiness conclusion follows.'
    )
}
$parent = Split-Path -Parent $outputPath
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding UTF8
if ($report.passed -ne $report.total) {
    $checks | Format-Table | Out-String | Write-Error
    exit 1
}
Write-Output "PASS: $($report.passed)/$($report.total) checks passed."
