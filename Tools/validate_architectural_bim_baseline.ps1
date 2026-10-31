param(
    [string]$ExportDirectory = '.local/revit-pilot/selected-d/20261030T002652845Z',
    [string]$OutputDirectory = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$exportPath = if ([IO.Path]::IsPathRooted($ExportDirectory)) {
    [IO.Path]::GetFullPath($ExportDirectory)
} else {
    [IO.Path]::GetFullPath((Join-Path $repoRoot $ExportDirectory))
}
$repoPrefix = $repoRoot.TrimEnd([char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)) + [IO.Path]::DirectorySeparatorChar
$localPrefix = [IO.Path]::GetFullPath((Join-Path $repoRoot '.local')).TrimEnd([char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)) + [IO.Path]::DirectorySeparatorChar
if (-not $exportPath.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw "ExportDirectory must stay inside this checkout: $exportPath" }
if (-not (Test-Path -LiteralPath $exportPath -PathType Container)) { throw "Baseline export directory not found: $exportPath" }

$timestamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffZ', [Globalization.CultureInfo]::InvariantCulture)
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $outputPath = Join-Path $repoRoot ".local/revalidation/architectural-bim-baseline-$timestamp"
} elseif ([IO.Path]::IsPathRooted($OutputDirectory)) {
    $outputPath = [IO.Path]::GetFullPath($OutputDirectory)
} else {
    $outputPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory))
}
if (-not $outputPath.StartsWith($localPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw "OutputDirectory must stay under ignored .local/: $outputPath" }
if (Test-Path -LiteralPath $outputPath) { throw "Refusing to overwrite existing validation output: $outputPath" }
$outputParent = Split-Path -Parent $outputPath
if (-not (Test-Path -LiteralPath $outputParent -PathType Container)) { New-Item -ItemType Directory -Path $outputParent -Force | Out-Null }

$sourcePath = Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$rvtPath = Join-Path $exportPath 'FH_Selected_D_Space_Study.rvt'
$ifcPath = Join-Path $exportPath 'FH_Selected_D_Space_Study.ifc'
foreach ($path in @($sourcePath, $rvtPath, $ifcPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required baseline file not found: $path" }
}
$before = @{
    source = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
    rvt = (Get-FileHash -LiteralPath $rvtPath -Algorithm SHA256).Hash.ToLowerInvariant()
    ifc = (Get-FileHash -LiteralPath $ifcPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
New-Item -ItemType Directory -Path $outputPath | Out-Null

$generator = Join-Path $repoRoot 'Tools/build_selected_house_schematic.ps1'
$runs = @()
foreach ($suffix in @('a','b')) {
    $runPath = Join-Path $outputPath "selected-d-$suffix"
    & $generator -LayoutVariant OwnerSelectedD -OutputDirectory $runPath
    if (-not $?) { throw "Selected-D generator failed for replay $suffix." }
    $checksFile = Join-Path $runPath 'checks.json'
    if (-not (Test-Path -LiteralPath $checksFile -PathType Leaf)) { throw "Replay $suffix did not write checks.json." }
    $geometryReport = Get-Content -LiteralPath $checksFile -Raw | ConvertFrom-Json
    $geometryChecks = @($geometryReport.checks.PSObject.Properties)
    $geometryFailures = @($geometryChecks | Where-Object { $_.Value -ne $true })
    if ($geometryReport.layout_variant -ne 'OwnerSelectedD' -or $geometryChecks.Count -ne 43 -or $geometryFailures.Count -gt 0) {
        throw "Replay $suffix geometry gate failed: variant=$($geometryReport.layout_variant), checks=$($geometryChecks.Count), failures=$($geometryFailures.Name -join ', ')."
    }
    $files = @(Get-ChildItem -LiteralPath $runPath -File | Sort-Object Name)
    if ($files.Count -ne 7) { throw "Replay $suffix produced $($files.Count) files; expected seven." }
    $svgFiles = @($files | Where-Object Extension -eq '.svg')
    if ($svgFiles.Count -ne 3) { throw "Replay $suffix produced $($svgFiles.Count) SVG files; expected three." }
    foreach ($svg in $svgFiles) { [xml](Get-Content -LiteralPath $svg.FullName -Raw) | Out-Null }
    $hashes = [ordered]@{}
    foreach ($file in $files) { $hashes[$file.Name] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant() }
    $runs += [pscustomobject]@{ directory = $runPath; geometry_checks = $geometryChecks.Count; geometry_failures = $geometryFailures.Count; files = $hashes }
}
$namesA = @($runs[0].files.Keys | Sort-Object) -join "`n"
$namesB = @($runs[1].files.Keys | Sort-Object) -join "`n"
$sameNames = $namesA -eq $namesB
$sameHashes = $sameNames
foreach ($name in $runs[0].files.Keys) {
    if (-not $runs[1].files.Contains($name) -or $runs[0].files[$name] -ne $runs[1].files[$name]) { $sameHashes = $false }
}
if (-not $sameHashes) { throw 'Independent selected-D replays do not have the same seven file names and SHA256 values.' }

$python = Join-Path $repoRoot '.venv/Scripts/python.exe'
$ifcValidator = Join-Path $repoRoot 'Tools/RevitPilot/validate_selected_d_ifc.py'
if (-not (Test-Path -LiteralPath $python -PathType Leaf)) { throw "Repository IFC-validator Python environment is missing: $python" }
$ifcReportPath = Join-Path $outputPath 'selected-d-ifc-validation.json'
& $python $ifcValidator $exportPath --report $ifcReportPath
if ($LASTEXITCODE -ne 0) { throw "Selected-D IFC validator exited with code $LASTEXITCODE." }
$ifcReport = Get-Content -LiteralPath $ifcReportPath -Raw | ConvertFrom-Json
$checkProperties = @($ifcReport.checks.PSObject.Properties)
$failedChecks = @($checkProperties | Where-Object { $_.Value -ne $true })
if ($ifcReport.status -ne 'pass' -or $failedChecks.Count -gt 0 -or @($ifcReport.errors).Count -gt 0) {
    throw "IFC baseline validation failed: status=$($ifcReport.status), failed checks=$($failedChecks.Name -join ', '), errors=$(@($ifcReport.errors).Count)."
}

$after = @{
    source = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash.ToLowerInvariant()
    rvt = (Get-FileHash -LiteralPath $rvtPath -Algorithm SHA256).Hash.ToLowerInvariant()
    ifc = (Get-FileHash -LiteralPath $ifcPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
$unchanged = $before.source -eq $after.source -and $before.rvt -eq $after.rvt -and $before.ifc -eq $after.ifc
if (-not $unchanged) { throw 'A protected source, RVT, or IFC fingerprint changed during validation.' }

$summary = [ordered]@{
    schema = 'forever-home-architectural-bim-baseline-validation-v1'
    status = 'pass'
    utc = [DateTime]::UtcNow.ToString('o')
    checkout = $repoRoot
    output_directory = $outputPath
    baseline_export_directory = $exportPath
    source_sha256 = $after.source
    saved_rvt_sha256 = $after.rvt
    ifc_sha256 = $after.ifc
    replay_count = $runs.Count
    geometry_check_count_per_replay = 43
    geometry_failures_per_replay = 0
    generated_file_count_per_replay = 7
    replay_hashes_match = $sameHashes
    svg_count_per_replay = 3
    svg_xml_parseable = $true
    ifc_report = $ifcReportPath
    ifc_checks_passed = $checkProperties.Count
    ifc_errors = @($ifcReport.errors).Count
    protected_inputs_unchanged = $unchanged
    runs = $runs
    limitations = @('This validates the reproducible room-block source and retained space-study RVT/IFC only.', 'Native construction categories remain empty; physical house geometry is not established.', 'No site/jurisdiction, code compliance, accessibility, structural safety, professional approval, or construction readiness is determined.')
}
$summaryPath = Join-Path $outputPath 'baseline-validation.json'
[IO.File]::WriteAllText($summaryPath, (($summary | ConvertTo-Json -Depth 12) + "`n"), (New-Object Text.UTF8Encoding($false)))
Write-Output "PASS selected-D replays: $($runs.Count) x 43 geometry checks; seven byte-identical artifacts each"
Write-Output "PASS SVG: three parseable plans per replay"
Write-Output "PASS retained IFC: $($checkProperties.Count)/$($checkProperties.Count) checks; $(@($ifcReport.errors).Count) errors"
Write-Output "PASS protected selected-D source, RVT and IFC hashes unchanged"
Write-Output "REPORT $summaryPath"
