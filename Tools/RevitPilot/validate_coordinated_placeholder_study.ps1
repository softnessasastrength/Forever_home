param([Parameter(Mandatory=$true)][string]$StudyDirectory)
$ErrorActionPreference='Stop'
$study=(Resolve-Path -LiteralPath $StudyDirectory).Path
$manifest=Get-Content (Join-Path $study 'coordinated-placeholder-study-manifest.json') -Raw | ConvertFrom-Json
function Hash([string]$p){(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()}
$rvt=Join-Path $study $manifest.saved_rvt; $ifc=Join-Path $study $manifest.ifc; $txt=Get-Content $ifc -Raw
$checks=@(
 [pscustomobject]@{name='schema';pass=$manifest.schema -eq 'forever-home-coordinated-placeholder-study-v1';detail=$manifest.schema},
 [pscustomobject]@{name='status';pass=$manifest.status -eq 'disposable documented coordination placeholders; not selected-D';detail=$manifest.status},
 [pscustomobject]@{name='source-hash';pass=(Hash (Join-Path (Get-Location) $manifest.input)) -eq $manifest.input_sha256;detail=$manifest.input_sha256},
 [pscustomobject]@{name='documented-dimensions';pass=$manifest.wall_placeholder_width_in -eq 5.5 -and $manifest.floor_build_up_in -eq 1.5 -and $manifest.nominal_opening_width_in -eq 36.0;detail='5.5-in wall / 1.5-in floor / 36-in openings'},
 [pscustomobject]@{name='inventory';pass=$manifest.wall_count -eq 11 -and $manifest.floor_count -eq 1 -and $manifest.door_count -eq 3;detail="walls=$($manifest.wall_count), floors=$($manifest.floor_count), doors=$($manifest.door_count)"},
 [pscustomobject]@{name='unselected';pass=$manifest.selected -eq $false;detail='Selected-D remains untouched'},
 [pscustomobject]@{name='rvt';pass=(Test-Path $rvt) -and (Hash $rvt) -eq $manifest.saved_rvt_sha256 -and (Get-Item $rvt).Length -gt 0;detail=$manifest.saved_rvt_sha256},
 [pscustomobject]@{name='ifc';pass=(Test-Path $ifc) -and (Hash $ifc) -eq $manifest.ifc_sha256 -and $manifest.ifc2x3 -and $txt.Contains("FILE_SCHEMA(('IFC2X3'))") -and $txt.Contains('IFCWALL') -and $txt.Contains('IFCSLAB') -and $txt.Contains('IFCDOOR');detail=$manifest.ifc_sha256}
)
$checks|Format-Table
$failed=@($checks|Where-Object{-not $_.pass}); if($failed.Count){throw 'Coordinated placeholder study validation failed.'}; Write-Output "PASS: $($checks.Count)/$($checks.Count) coordinated placeholder checks."
