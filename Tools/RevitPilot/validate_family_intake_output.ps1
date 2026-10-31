param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ManifestPath,
    [string]$IncomingFolder,
    [switch]$AllowHistoricalSnapshot
)

$ErrorActionPreference = 'Stop'
$ManifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
if ([string]::IsNullOrWhiteSpace($IncomingFolder)) {
    $IncomingFolder = Join-Path $PSScriptRoot '../../Revit/Family_Intake/Incoming'
}
$IncomingFolder = (Resolve-Path -LiteralPath $IncomingFolder).Path
$canonicalIncomingFolder = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../Revit/Family_Intake/Incoming')).Path
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
$sourceFolderMatches = $manifestSourceFolder -ieq $IncomingFolder.TrimEnd('\')
$historicalSnapshotMatches = $AllowHistoricalSnapshot -and
    $manifestSourceFolder -ieq $canonicalIncomingFolder.TrimEnd('\') -and
    $IncomingFolder.TrimEnd('\') -ine $canonicalIncomingFolder.TrimEnd('\')
Assert-Intake ($sourceFolderMatches -or $historicalSnapshotMatches) 'Manifest source folder does not match the validated incoming folder or an explicitly authorized historical snapshot.'
Assert-Intake ($manifest.results.Count -eq $expectedFiles.Count) 'Result count does not match current incoming RFA count.'
$reportedFiles = @($manifest.results | ForEach-Object { $_.file } | Sort-Object)
Assert-Intake ((Compare-Object $expectedFiles $reportedFiles).Count -eq 0) 'Manifest file set differs from current incoming RFA set.'

foreach ($result in $manifest.results) {
    $safeLeafName = [System.IO.Path]::GetFileName([string]$result.file) -eq [string]$result.file
    $sourcePath = if ($safeLeafName) { Join-Path $IncomingFolder ([string]$result.file) } else { '' }
    $sourceExists = $safeLeafName -and (Test-Path -LiteralPath $sourcePath -PathType Leaf)
    Assert-Intake $safeLeafName "$($result.file): manifest filename must be a leaf filename."
    Assert-Intake $sourceExists "$($result.file): source family file is missing from the validated input folder."
    if ($sourceExists) {
        $actualSourceHash = (Get-FileHash -LiteralPath $sourcePath -Algorithm SHA256).Hash
        Assert-Intake ($actualSourceHash -ieq [string]$result.source_sha256) "$($result.file): source file SHA256 differs from the intake manifest."
    }
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

    if ($result.source_sha256 -eq '39715206f24de4b909e37324ce352bba3af348bca259b7a9c0ce335ed2ddc3ea') {
        $probe = $result.host_orientation_test
        $probePassed = $null -ne $probe -and [string]$probe.status -like 'measured on a disposable vertical wall host*'
        Assert-Intake $probePassed "$($result.file): hash-matched Evolution host-orientation probe did not complete successfully."
        if ($probePassed) {
            $hostBounds = $probe.global_bounds_in
            $hostMetrics = @($hostBounds.width, $hostBounds.projection, $hostBounds.height,
                $probe.total_volume_ft3, $probe.positive_volume_solid_count)
            $hostFinite = $true
            foreach ($value in $hostMetrics) {
                if ($null -eq $value -or [double]::IsNaN([double]$value) -or [double]::IsInfinity([double]$value)) { $hostFinite = $false }
            }
            $normal = @($probe.host_face_normal)
            $normalIsX = $normal.Count -eq 3 -and [Math]::Abs([double]$normal[0]) -gt 0.999 -and
                [Math]::Abs([double]$normal[1]) -lt 0.001 -and [Math]::Abs([double]$normal[2]) -lt 0.001
            $sameHost = $null -ne $probe.host_element_id -and
                [long]$probe.instance_host_element_id -eq [long]$probe.host_element_id -and
                [long]$probe.host_face_element_id -eq [long]$probe.host_element_id
            $axes = $probe.local_axes_in_project
            $xAxisIsWidth = @($axes.x).Count -eq 3 -and [Math]::Abs([double]$axes.x[1]) -gt 0.999 -and
                [Math]::Abs([double]$axes.x[0]) -lt 0.001 -and [Math]::Abs([double]$axes.x[2]) -lt 0.001
            $yAxisIsVertical = @($axes.y).Count -eq 3 -and [Math]::Abs([double]$axes.y[2]) -gt 0.999 -and
                [Math]::Abs([double]$axes.y[0]) -lt 0.001 -and [Math]::Abs([double]$axes.y[1]) -lt 0.001
            $zAxisIsProjection = @($axes.z).Count -eq 3 -and [Math]::Abs([double]$axes.z[0]) -gt 0.999 -and
                [Math]::Abs([double]$axes.z[1]) -lt 0.001 -and [Math]::Abs([double]$axes.z[2]) -lt 0.001
            $axesMatchIntent = $xAxisIsWidth -and $yAxisIsVertical -and $zAxisIsProjection
            $sourceGeometryDimensionsMatch = [Math]::Abs([double]$hostBounds.width - 22.0) -le 0.05 -and
                [Math]::Abs([double]$hostBounds.height - 34.25) -le 0.05 -and
                [Math]::Abs([double]$hostBounds.projection - 17.5052) -le 0.05
            Assert-Intake ($hostFinite -and $probe.positive_volume_solid_count -gt 0 -and $probe.total_volume_ft3 -gt 0) `
                "$($result.file): hosted-instance geometry metrics are missing, non-finite or non-positive."
            Assert-Intake $normalIsX "$($result.file): tested host face normal is not parallel to project X."
            Assert-Intake $sameHost "$($result.file): hosted instance or host-face reference does not resolve to the disposable wall."
            Assert-Intake $axesMatchIntent "$($result.file): local family axes do not map width/height/projection to project Y/Z/X."
            Assert-Intake $sourceGeometryDimensionsMatch "$($result.file): host extents do not match measured family geometry (22 x 34.25 x 17.5052 in) under the tested orientation."
            Write-Output ("HOSTED {0} | type {1} | {2:F4} in projection x {3:F4} in width x {4:F4} in height; {5} positive-volume solids" -f `
                $result.file, $probe.family_type, $hostBounds.projection, $hostBounds.width, $hostBounds.height, $probe.positive_volume_solid_count)
        }
    }
}

if ($errors.Count -gt 0) {
    foreach ($intakeError in $errors) { Write-Error "FAIL: $intakeError" -ErrorAction Continue }
    Write-Output ("FAILED: {0} of {1} checks failed." -f $errors.Count, $checks)
    exit 1
}

Write-Output ("PASS: {0} family results, {1} measured types; {2} intake integrity checks passed." -f `
    $manifest.results.Count, (($manifest.results | ForEach-Object { $_.types.Count } | Measure-Object -Sum).Sum), $checks)
Write-Output 'Screen only: these checks validate measurement presence and finite positive solid extents; they do not validate product size, placement, hosting, clearance, fit, or approval.'
if ($historicalSnapshotMatches) {
    Write-Output 'Historical snapshot mode: every manifest family filename and SHA256 was checked against the supplied snapshot; the canonical Incoming folder was not changed.'
}
