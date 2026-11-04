[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$StudyDirectory)
$ErrorActionPreference='Stop'
$study=(Resolve-Path $StudyDirectory).Path
function Hash([string]$p){(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()}
$m=Get-Content (Join-Path $study 'm379-interior-coordination-manifest.json') -Raw | ConvertFrom-Json
$rvt=Join-Path $study $m.saved_rvt; $ifc=Join-Path $study $m.ifc
$checks=@(
 [pscustomobject]@{name='schema';pass=($m.schema -eq 'forever-home-m379-interior-coordination-v1');evidence=$m.schema},
 [pscustomobject]@{name='selected_d_protected';pass=($m.status -like '*not Selected-D*');evidence=$m.status},
 [pscustomobject]@{name='nine_ft_baseline';pass=([double]$m.baseline_clear_height_ft -eq 9);evidence=$m.baseline_clear_height_ft},
 [pscustomobject]@{name='island_direction';pass=($m.island_bias -eq 'dining/living connection');evidence=$m.island_bias},
 [pscustomobject]@{name='wall_count';pass=([int]$m.wall_count -eq 24);evidence=$m.wall_count},
 [pscustomobject]@{name='floor_count';pass=([int]$m.floor_count -eq 1);evidence=$m.floor_count},
 [pscustomobject]@{name='island_count';pass=([int]$m.kitchen_island_count -eq 1);evidence=$m.kitchen_island_count},
 [pscustomobject]@{name='bath_count';pass=([int]$m.bath_vignette_count -eq 1);evidence=$m.bath_vignette_count},
 [pscustomobject]@{name='stair_reservation';pass=([int]$m.stair_reservation_count -eq 1 -and $m.stair_direction -like 'tucked*');evidence=$m.stair_direction},
 [pscustomobject]@{name='rvt_hash';pass=((Hash $rvt) -eq [string]$m.saved_rvt_sha256);evidence=$m.saved_rvt_sha256},
 [pscustomobject]@{name='ifc_hash';pass=((Hash $ifc) -eq [string]$m.ifc_sha256);evidence=$m.ifc_sha256},
 [pscustomobject]@{name='ifc2x3';pass=($m.ifc2x3 -eq $true -and (Get-Content $ifc -Raw).Contains("FILE_SCHEMA(('IFC2X3'))"));evidence=$m.ifc2x3},
 [pscustomobject]@{name='limitations';pass=(@($m.limitations).Count -ge 4);evidence="count=$(@($m.limitations).Count)"}
)
$checks|ForEach-Object{"{0} {1}: {2}" -f ($(if($_.pass){'PASS'}else{'FAIL'}),$_.name,$_.evidence)}
$failed=@($checks|Where-Object{-not $_.pass});"SUMMARY $(@($checks|Where-Object pass).Count)/$($checks.Count) checks passed";if($failed.Count){exit 1}
