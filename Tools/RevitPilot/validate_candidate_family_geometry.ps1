param(
    [Parameter(Mandatory = $true)]
    [string]$ReportPath,
    [Parameter(Mandatory = $true)]
    [string]$ExpectedSourcePath,
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Fa-f0-9]{64}$')]
    [string]$ExpectedSourceSHA256
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$localRoot = Join-Path $repoRoot '.local/revit-pilot'
$candidateRoot = Join-Path $localRoot 'family-intake/candidates'
$derivativeRoot = Join-Path $localRoot 'family-intake/derivatives'
$reportFull = [IO.Path]::GetFullPath($ReportPath)
$sourceFull = [IO.Path]::GetFullPath($ExpectedSourcePath)
$checks = [System.Collections.Generic.List[object]]::new()

function Test-UnderDirectory([string]$Path, [string]$Directory) {
    $trimCharacters = [char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $prefix = [IO.Path]::GetFullPath($Directory).TrimEnd($trimCharacters) + [IO.Path]::DirectorySeparatorChar
    return [IO.Path]::GetFullPath($Path).StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}

function Add-Check([string]$Name, [bool]$Passed, [string]$Evidence) {
    $checks.Add([pscustomobject]@{ name = $Name; passed = $Passed; evidence = $Evidence })
}

if (!(Test-Path -LiteralPath $reportFull -PathType Leaf)) { throw "Report not found: $reportFull" }
$report = Get-Content -LiteralPath $reportFull -Raw | ConvertFrom-Json

$geometrySchema = 'forever-home-candidate-family-geometry-v1'
$hostProbeSchema = 'forever-home-candidate-family-host-probe-v1'
$isHostProbe = $report.schema -eq $hostProbeSchema
Add-Check 'report_schema' ($report.schema -eq $geometrySchema -or $isHostProbe) "schema=$($report.schema)"
Add-Check 'report_status' ([string]$report.status -like 'pass;*') "status=$($report.status)"
Add-Check 'report_in_local_revit_pilot' (Test-UnderDirectory $reportFull $localRoot) "report=$reportFull"
Add-Check 'source_in_quarantine' (Test-UnderDirectory $sourceFull $candidateRoot) "source=$sourceFull"

$reportedSource = [IO.Path]::GetFullPath([string]$report.source.path)
$sourceHashMatches = [string]::Equals([string]$report.source.sha256_before, [string]$report.source.sha256_after, [StringComparison]::OrdinalIgnoreCase) -and
    [string]::Equals([string]$report.source.sha256_before, $ExpectedSourceSHA256, [StringComparison]::OrdinalIgnoreCase) -and
    [string]::Equals((Get-FileHash -LiteralPath $sourceFull -Algorithm SHA256).Hash, $ExpectedSourceSHA256, [StringComparison]::OrdinalIgnoreCase)
Add-Check 'source_path_and_hash' ($reportedSource -eq $sourceFull -and $sourceHashMatches) "before=$($report.source.sha256_before); after=$($report.source.sha256_after); expected=$ExpectedSourceSHA256"

$derivativeFull = [IO.Path]::GetFullPath([string]$report.derivative.path)
$derivativeExists = Test-Path -LiteralPath $derivativeFull -PathType Leaf
$derivativeHashMatches = $derivativeExists -and [string]::Equals((Get-FileHash -LiteralPath $derivativeFull -Algorithm SHA256).Hash, [string]$report.derivative.sha256, [StringComparison]::OrdinalIgnoreCase)
Add-Check 'derivative_in_isolated_directory' ((Test-UnderDirectory $derivativeFull $derivativeRoot) -and $derivativeFull.EndsWith('.rvt', [StringComparison]::OrdinalIgnoreCase)) "derivative=$derivativeFull"
Add-Check 'derivative_hash' $derivativeHashMatches "reported=$($report.derivative.sha256); exists=$derivativeExists"
$expectedInstanceCount = if ($isHostProbe) { 1 } else { 0 }
$scopeValid = $report.project_scope.derivative_type -eq 'new_imperial_project' -and
    $report.project_scope.selected_d_opened -eq $false -and
    [int]$report.project_scope.family_instances_placed -eq $expectedInstanceCount
if ($isHostProbe) { $scopeValid = $scopeValid -and $report.project_scope.synthetic_host_probe_only -eq $true }
Add-Check 'project_scope_isolated' $scopeValid "scope=$($report.project_scope | ConvertTo-Json -Compress)"
Add-Check 'family_metadata_present' (![string]::IsNullOrWhiteSpace([string]$report.family) -and ![string]::IsNullOrWhiteSpace([string]$report.category) -and ![string]::IsNullOrWhiteSpace([string]$report.placement_type)) "family=$($report.family); category=$($report.category); placement=$($report.placement_type)"

if ($isHostProbe) {
    $probe = $report.host_probe
    $hostIdsMatch = $null -ne $probe -and
        [long]$probe.host_element_id -gt 0 -and
        [long]$probe.host_element_id -eq [long]$probe.instance_host_element_id -and
        [long]$probe.host_element_id -eq [long]$probe.host_face_element_id
    Add-Check 'synthetic_wall_host_identity' ($probe.status -like '*synthetic wall*' -and $hostIdsMatch) "probe_status=$($probe.status); host=$($probe.host_element_id); instance_host=$($probe.instance_host_element_id); host_face=$($probe.host_face_element_id)"

    $instanceBounds = $probe.instance_bounds_project_in
    $instanceBoundsValid = $null -ne $instanceBounds -and [int]$probe.positive_volume_solid_count -gt 0
    if ($instanceBoundsValid) {
        foreach ($axis in @('width_x','depth_y','height_z')) {
            if ($null -eq $instanceBounds.$axis -or [double]::IsNaN([double]$instanceBounds.$axis) -or [double]::IsInfinity([double]$instanceBounds.$axis) -or [double]$instanceBounds.$axis -le 0) { $instanceBoundsValid = $false; break }
        }
        foreach ($side in @('min','max')) {
            if ($null -eq $instanceBounds.$side -or @($instanceBounds.$side).Count -ne 3) { $instanceBoundsValid = $false; break }
            foreach ($coordinate in @($instanceBounds.$side)) {
                if ([double]::IsNaN([double]$coordinate) -or [double]::IsInfinity([double]$coordinate)) { $instanceBoundsValid = $false; break }
            }
        }
        if ($instanceBoundsValid) {
            $instanceBoundsValid = [math]::Abs(([double]$instanceBounds.max[0] - [double]$instanceBounds.min[0]) - [double]$instanceBounds.width_x) -le 0.001 -and
                [math]::Abs(([double]$instanceBounds.max[1] - [double]$instanceBounds.min[1]) - [double]$instanceBounds.depth_y) -le 0.001 -and
                [math]::Abs(([double]$instanceBounds.max[2] - [double]$instanceBounds.min[2]) - [double]$instanceBounds.height_z) -le 0.001
        }
    }
    Add-Check 'synthetic_instance_has_finite_positive_solids_and_bounds' $instanceBoundsValid "solid_count=$($probe.positive_volume_solid_count); bounds=$($instanceBounds | ConvertTo-Json -Compress)"

    $connectors = $probe.connectors
    $connectorReportValid = $null -ne $connectors -and
        [int]$connectors.count -eq @($connectors.connectors).Count -and
        [int]$connectors.connected_connector_count -eq @($connectors.connectors | Where-Object { $_.is_connected -eq $true }).Count -and
        $connectors.any_connectors_connected -eq ([int]$connectors.connected_connector_count -gt 0) -and
        $connectors.external_service_network_modelled -eq $false
    Add-Check 'connector_report_does_not_claim_service_network' $connectorReportValid "connector_inventory=$($connectors | ConvertTo-Json -Compress)"
}

$types = @($report.types)
$typesValid = $types.Count -gt 0 -and [int]$report.type_count -eq $types.Count
foreach ($type in $types) {
    $b = $type.bounds
    $solidCount = [int]$type.solid_metrics.positive_volume_solid_count
    $hasBounds = $null -ne $b -and $b.units -eq 'inches' -and [int]$b.solid_bounding_box_corner_count -ge 8
    if ($hasBounds) {
        foreach ($key in @('min_x','max_x','min_y','max_y','min_z','max_z','width_x','depth_y','height_z')) {
            if ($null -eq $b.$key -or [double]::IsNaN([double]$b.$key) -or [double]::IsInfinity([double]$b.$key)) { $hasBounds = $false; break }
        }
        if ($hasBounds) {
            $hasBounds = [double]$b.width_x -gt 0 -and [double]$b.depth_y -gt 0 -and [double]$b.height_z -gt 0 -and
                [math]::Abs(([double]$b.max_x - [double]$b.min_x) - [double]$b.width_x) -le 0.001 -and
                [math]::Abs(([double]$b.max_y - [double]$b.min_y) - [double]$b.depth_y) -le 0.001 -and
                [math]::Abs(([double]$b.max_z - [double]$b.min_z) - [double]$b.height_z) -le 0.001
        }
    }
    if ($solidCount -le 0 -or !$hasBounds -or $type.geometry_status -ne 'measured_from_positive_volume_solids') { $typesValid = $false }
}
Add-Check 'every_type_has_finite_positive_solid_bounds' $typesValid "types=$($types.Count); positive-volume solid geometry required"

$limitations = @($report.limitations)
$limitationsText = $limitations -join ' '
$noPlacementClaim = $limitationsText -match 'not placed' -or $limitationsText -match 'no instance was placed'
$hostProbeLimitations = !$isHostProbe -or ($limitationsText -match 'synthetic wall' -and $limitationsText -match 'service.route' -and $limitationsText -match 'code compliance')
$limitationsValid = $limitations.Count -ge 3 -and ($noPlacementClaim -or $isHostProbe) -and $hostProbeLimitations -and $limitationsText -match 'code compliance'
Add-Check 'limitations_explicit' $limitationsValid "limitation_count=$($limitations.Count)"

$passedCount = @($checks | Where-Object passed).Count
$failedCount = $checks.Count - $passedCount
$checks | ForEach-Object { '{0} {1}: {2}' -f ($(if ($_.passed) { 'PASS' } else { 'FAIL' }), $_.name, $_.evidence) }
"SUMMARY $passedCount/$($checks.Count) checks passed"
if ($failedCount -gt 0) { throw "Candidate family geometry validation failed: $failedCount check(s) failed." }
