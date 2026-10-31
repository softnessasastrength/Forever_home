param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ManifestPath,
    [string[]]$SourceRoots,
    [string]$SnapshotDirectory
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$ManifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
if (-not $SourceRoots -or $SourceRoots.Count -eq 0) {
    $SourceRoots = @(
        (Join-Path $repo 'Revit/Family_Intake/Incoming'),
        (Join-Path $repo '.local/revit-pilot/family-intake/candidates')
    )
}
$resolvedRoots = @($SourceRoots | ForEach-Object { (Resolve-Path -LiteralPath $_).Path })
if ([string]::IsNullOrWhiteSpace($SnapshotDirectory)) {
    $SnapshotDirectory = Join-Path $repo ('.local/revalidation/family-intake-snapshot-' + [guid]::NewGuid().ToString('N'))
}
$resolvedSnapshot = if ([IO.Path]::IsPathRooted($SnapshotDirectory)) {
    [IO.Path]::GetFullPath($SnapshotDirectory)
} else {
    [IO.Path]::GetFullPath((Join-Path $repo $SnapshotDirectory))
}
$localPrefix = [IO.Path]::GetFullPath((Join-Path $repo '.local/revalidation')).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedSnapshot.StartsWith($localPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'SnapshotDirectory must resolve under repository .local/revalidation.'
}
foreach ($sourceRoot in $resolvedRoots) {
    $rootPrefix = $sourceRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if ($resolvedSnapshot.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'SnapshotDirectory cannot be inside a source root.'
    }
}
if (Test-Path -LiteralPath $resolvedSnapshot) {
    throw "SnapshotDirectory already exists; refusing to overwrite it: $resolvedSnapshot"
}

$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
if ($manifest.status -notlike 'executed;*' -or @($manifest.results).Count -eq 0) {
    throw 'Manifest is not a completed Revit family-intake run.'
}
$sourceFiles = @()
foreach ($root in $resolvedRoots) {
    $sourceFiles += Get-ChildItem -LiteralPath $root -Filter '*.rfa' -File -Recurse
}
$hashIndex = @{}
foreach ($source in $sourceFiles) {
    $hash = (Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if (-not $hashIndex.ContainsKey($hash)) { $hashIndex[$hash] = @() }
    $hashIndex[$hash] += $source
}

$resolvedSources = @()
foreach ($result in $manifest.results) {
    $expectedHash = ([string]$result.source_sha256).ToLowerInvariant()
    if ($expectedHash -notmatch '^[0-9a-f]{64}$') { throw "Missing or malformed source_sha256 for $($result.file)." }
    if (-not $hashIndex.ContainsKey($expectedHash)) {
        throw "No source RFA in the permitted source roots matches $($result.file) hash $expectedHash."
    }
    $matches = @($hashIndex[$expectedHash])
    $sameName = @($matches | Where-Object { $_.Name -eq [string]$result.file })
    $source = if ($sameName.Count -gt 0) { $sameName[0] } else { $matches[0] }
    $resolvedSources += [pscustomobject]@{ Result = $result; Source = $source; Hash = $expectedHash }
}

New-Item -ItemType Directory -Path $resolvedSnapshot | Out-Null
foreach ($entry in $resolvedSources) {
    $destination = Join-Path $resolvedSnapshot ([string]$entry.Result.file)
    Copy-Item -LiteralPath $entry.Source.FullName -Destination $destination
    $copiedHash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($copiedHash -ne $entry.Hash) { throw "Snapshot copy hash mismatch for $($entry.Result.file)." }
}
$manifest.source_folder = $resolvedSnapshot
$snapshotManifest = Join-Path $resolvedSnapshot 'intake-manifest.json'
ConvertTo-Json -InputObject $manifest -Depth 100 | Set-Content -LiteralPath $snapshotManifest -Encoding utf8

$validator = Join-Path $PSScriptRoot 'validate_family_intake_output.ps1'
$validationOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $validator $snapshotManifest -IncomingFolder $resolvedSnapshot 2>&1
$validatorExitCode = $LASTEXITCODE
$validationOutput | ForEach-Object { Write-Output $_ }
if ($validatorExitCode -ne 0) { throw "Family intake output checks failed for hash-matched snapshot (exit $validatorExitCode)." }
Write-Output ("SNAPSHOT SOURCES PASS: {0}/{0} manifest family hashes matched authorized local source files; files copied to {1}" -f $resolvedSources.Count, $resolvedSnapshot)
