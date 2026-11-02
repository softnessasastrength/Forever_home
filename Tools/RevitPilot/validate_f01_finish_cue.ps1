param([Parameter(Mandatory=$true)][string]$StudyDirectory)
$ErrorActionPreference='Stop'; $study=(Resolve-Path -LiteralPath $StudyDirectory).Path
$manifest=Get-Content (Join-Path $study 'f01-finish-cue-manifest.json') -Raw | ConvertFrom-Json
function Hash([string]$p){(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()}
$rvt=Join-Path $study $manifest.saved_rvt; $ifc=Join-Path $study $manifest.ifc; $txt=Get-Content $ifc -Raw
$checks=@(
 [pscustomobject]@{name='schema';pass=$manifest.schema -eq 'forever-home-f01-finish-cue-v1';detail=$manifest.schema},
 [pscustomobject]@{name='status';pass=$manifest.status -eq 'disposable finish cue; not a selected floor assembly';detail=$manifest.status},
 [pscustomobject]@{name='material';pass=$manifest.material -like 'FH-F-01-EngHardwood-OakWarm*' -and $manifest.material_selected -and -not $manifest.assembly_selected;detail=$manifest.material},
 [pscustomobject]@{name='floor-count';pass=$manifest.floor_count -eq 1;detail="count=$($manifest.floor_count)"},
 [pscustomobject]@{name='rvt';pass=(Test-Path $rvt) -and (Hash $rvt) -eq $manifest.saved_rvt_sha256 -and (Get-Item $rvt).Length -gt 0;detail=$manifest.saved_rvt_sha256},
 [pscustomobject]@{name='ifc';pass=(Test-Path $ifc) -and (Hash $ifc) -eq $manifest.ifc_sha256 -and $manifest.ifc2x3 -and $txt.Contains("FILE_SCHEMA(('IFC2X3'))") -and ($txt -match 'IFCSLAB');detail=$manifest.ifc_sha256}
)
$checks|Format-Table; if(@($checks|Where-Object{-not $_.pass}).Count){throw 'F-01 finish-cue validation failed.'}; Write-Output "PASS: $($checks.Count)/$($checks.Count) F-01 finish-cue checks."
