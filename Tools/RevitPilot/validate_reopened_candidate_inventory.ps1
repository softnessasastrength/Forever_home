param(
    [Parameter(Mandatory = $true)] [string] $Inventory,
    [Parameter(Mandatory = $true)] [string] $Output
)

$ErrorActionPreference = 'Stop'
$inventoryPath = (Resolve-Path $Inventory).Path
$report = Get-Content $inventoryPath -Raw | ConvertFrom-Json

if ($report.schema -ne 'forever-home-main-floor-candidate-reopened-inventory-v1') {
    throw "Unexpected inventory schema: $($report.schema)"
}

$checks = @(
    [pscustomobject]@{ name = 'source_hash_recorded'; pass = ($report.assertions | Where-Object name -eq 'source_hash_recorded').pass -eq $true; detail = $report.source_rvt_sha256 },
    [pscustomobject]@{ name = 'expected_wall_count'; pass = ($report.counts.walls -eq 42); detail = "$($report.counts.walls) walls" },
    [pscustomobject]@{ name = 'expected_curve_count'; pass = ($report.counts.model_curves -eq 252); detail = "$($report.counts.model_curves) model curves" },
    [pscustomobject]@{ name = 'no_unapproved_building_categories'; pass = ($report.counts.floors -eq 0 -and $report.counts.doors -eq 0 -and $report.counts.roofs -eq 0 -and $report.counts.stairs -eq 0); detail = "floors=$($report.counts.floors), doors=$($report.counts.doors), roofs=$($report.counts.roofs), stairs=$($report.counts.stairs)" }
)

$result = [pscustomobject]@{
    schema = 'forever-home-main-floor-candidate-reopened-inventory-validation-v1'
    inventory = $inventoryPath
    source_rvt_sha256 = $report.source_rvt_sha256
    checks = $checks
    pass = [bool]($checks.pass -notcontains $false)
    limitations = @('This validates the read-only comparison derivative only; it is not selected-D, code, structural, professional or construction approval.')
}

New-Item -ItemType Directory -Force (Split-Path $Output) | Out-Null
$result | ConvertTo-Json -Depth 6 | Set-Content -Path $Output -Encoding UTF8
if (-not $result.pass) { throw "Reopened candidate inventory validation failed: $Output" }
$result | Format-List
