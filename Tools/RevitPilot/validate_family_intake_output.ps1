param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ManifestPath,
    [string]$IncomingFolder
)

$ErrorActionPreference = 'Stop'
$ManifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
if ([string]::IsNullOrWhiteSpace($IncomingFolder)) {
    $IncomingFolder = Join-Path $PSScriptRoot '../../Revit/Family_Intake/Incoming'
}
$IncomingFolder = (Resolve-Path -LiteralPath $IncomingFolder).Path
$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$expectedFiles = @(Get-ChildItem -LiteralPath $IncomingFolder -Filter '*.rfa' -File | ForEach-Object { $_.Name } | Sort-Object)
$errors = New-Object System.Collections.Generic.List[string]
$checks = 0

function Assert-Intake([bool]$Condition, [string]$Message) {
    $script:checks++
    if (-not $Condition) { $script:errors.Add($Message) }
}

Assert-Intake ($manifest.revit_version -eq '2027') 'Unexpected Revit version in intake manifest.'
Assert-Intake ($manifest.status -like 'executed;*') 'Manifest does not identify a completed intake run.'
$manifestSourceFolder = [System.IO.Path]::GetFullPath([string]$manifest.source_folder).TrimEnd('\')
Assert-Intake ($manifestSourceFolder -ieq $IncomingFolder.TrimEnd('\')) 'Manifest source folder does not match the validated incoming folder.'
Assert-Intake ($manifest.results.Count -eq $expectedFiles.Count) 'Result count does not match current incoming RFA count.'
$reportedFiles = @($manifest.results | ForEach-Object { $_.file } | Sort-Object)
Assert-Intake ((Compare-Object $expectedFiles $reportedFiles).Count -eq 0) 'Manifest file set differs from current incoming RFA set.'

foreach ($result in $manifest.results) {
    Assert-Intake ($result.status -in @('loaded', 'already_present')) "$($result.file): family was not loaded successfully ($($result.status))."
    Assert-Intake (-not [string]::IsNullOrWhiteSpace($result.category)) "$($result.file): category is missing."
    Assert-Intake (-not [string]::IsNullOrWhiteSpace($result.placement_type)) "$($result.file): placement type is missing."
    Assert-Intake ($result.type_count -gt 0 -and $result.type_count -eq $result.types.Count) "$($result.file): type count does not match reported types."

    foreach ($type in $result.types) {
        $label = "$($result.file) / $($type.type)"
        Assert-Intake ($type.geometry_status -eq 'measured_from_positive_volume_solids') "${label}: geometry measurement is missing or used an unexpected method."
        Assert-Intake ($type.solid_metrics.positive_volume_solid_count -gt 0) "${label}: no positive-volume solids were measured."
        Assert-Intake ($type.solid_metrics.total_volume_ft3 -gt 0) "${label}: total solid volume is not positive."

        $bounds = $type.bounds
        $values = @($bounds.min_x, $bounds.max_x, $bounds.min_y, $bounds.max_y, $bounds.min_z, $bounds.max_z,
            $bounds.width_x, $bounds.depth_y, $bounds.height_z)
        $finite = $true
        foreach ($value in $values) {
            if ($null -eq $value -or [double]::IsNaN([double]$value) -or [double]::IsInfinity([double]$value)) { $finite = $false }
        }
        Assert-Intake ($bounds.units -eq 'inches' -and $finite) "${label}: bounds are missing, non-finite, or not reported in inches."
        Assert-Intake ($bounds.width_x -gt 0 -and $bounds.depth_y -gt 0 -and $bounds.height_z -gt 0) "${label}: one or more measured extents are not positive."

        Write-Output ("MEASURED {0} | {1} | {2:F4} x {3:F4} x {4:F4} in; {5} positive-volume solids" -f `
            $result.file, $type.type, $bounds.width_x, $bounds.depth_y, $bounds.height_z, $type.solid_metrics.positive_volume_solid_count)
    }
}

if ($errors.Count -gt 0) {
    foreach ($error in $errors) { Write-Error "FAIL: $error" -ErrorAction Continue }
    Write-Output ("FAILED: {0} of {1} checks failed." -f $errors.Count, $checks)
    exit 1
}

Write-Output ("PASS: {0} family results, {1} measured types; {2} intake integrity checks passed." -f `
    $manifest.results.Count, (($manifest.results | ForEach-Object { $_.types.Count } | Measure-Object -Sum).Sum), $checks)
Write-Output 'Screen only: these checks validate measurement presence and finite positive solid extents; they do not validate product size, placement, hosting, clearance, fit, or approval.'
