[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)][string]$RunDirectory,
  [Parameter(Mandatory=$true)][string]$Output
)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $RunDirectory 'floor-plate-manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Missing floor-plate-manifest.json" }
$m = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$checks = @()
$checks += [pscustomobject]@{ name='schema'; pass=($m.schema -eq 'forever-home-main-floor-floor-plate-v1'); detail=$m.schema }
$checks += [pscustomobject]@{ name='source_rvt_hash'; pass=((Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $RunDirectory $m.saved_rvt)).Hash -eq $m.saved_rvt_sha256); detail=$m.saved_rvt_sha256 }
$checks += [pscustomobject]@{ name='floor_count'; pass=($m.floor_count -eq 3 -and @($m.floors).Count -eq 3); detail="floor_count=$($m.floor_count)" }
$checks += [pscustomobject]@{ name='profile_areas'; pass=(@($m.floors | Where-Object { $_.profile_width_ft -eq 40 -and $_.profile_depth_ft -eq 42 -and $_.profile_area_sqft -eq 1680 }).Count -eq 3); detail='three 40 x 42 ft / 1,680 sf profiles' }
$checks += [pscustomobject]@{ name='wall_count_preserved'; pass=($m.wall_count -eq 42); detail=$m.wall_count }
$result = [ordered]@{ schema='forever-home-main-floor-floor-plate-validation-v1'; run_directory=(Resolve-Path $RunDirectory).Path; pass=(@($checks | Where-Object { -not $_.pass }).Count -eq 0); checks=$checks; limitations=$m.limitations }
$result | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $Output -Encoding utf8
$checks | Format-Table -AutoSize
Write-Host ("pass : {0}; checks : {1}/{2}" -f $result.pass,(@($checks|Where-Object pass).Count),$checks.Count)
if (-not $result.pass) { exit 1 }
