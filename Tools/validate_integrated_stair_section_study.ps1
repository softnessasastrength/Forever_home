param([Parameter(Mandatory=$true)][string]$StudyDirectory)
$ErrorActionPreference='Stop'
$m=Get-Content (Join-Path $StudyDirectory 'integrated-stair-section-manifest.json') -Raw|ConvertFrom-Json
$rvt=Join-Path $StudyDirectory $m.saved_rvt; $ifc=Join-Path $StudyDirectory $m.ifc
$checks=@(
 [pscustomobject]@{name='schema';pass=$m.schema -eq 'forever-home-integrated-stair-section-v1';detail=$m.schema},
 [pscustomobject]@{name='basis';pass=$m.basis -eq 'B' -and [double]$m.total_rise_in -eq 60;detail='basis B; 60 in'},
 [pscustomobject]@{name='levels';pass=$m.levels -eq 3;detail="levels=$($m.levels)"},
 [pscustomobject]@{name='walls';pass=$m.wall_count -eq 12;detail="walls=$($m.wall_count)"},
 [pscustomobject]@{name='floors';pass=$m.floor_count -eq 3;detail="floors=$($m.floor_count)"},
 [pscustomobject]@{name='native_stairs';pass=$m.native_stair_count -eq 2;detail="stairs=$($m.native_stair_count)"},
 [pscustomobject]@{name='section';pass=$m.section_count -eq 1;detail="sections=$($m.section_count)"},
 [pscustomobject]@{name='files';pass=(Test-Path $rvt) -and (Test-Path $ifc) -and (Get-Item $ifc).Length -gt 0;detail='RVT and IFC present'},
 [pscustomobject]@{name='hashes';pass=$m.saved_rvt_sha256 -eq ((Get-FileHash $rvt -Algorithm SHA256).Hash.ToLower()) -and (Select-String -LiteralPath $ifc -Pattern 'IFC2X3' -Quiet);detail='RVT hash and IFC2X3 header'},
 [pscustomobject]@{name='limitations';pass=@($m.limitations).Count -ge 3 -and ($m.limitations -match 'Selected-D');detail='limitations retained'}
)
$checks|Format-Table; if(@($checks|Where-Object{-not $_.pass}).Count){throw 'Integrated stair section validation failed.'}; Write-Output "PASS: $($checks.Count)/$($checks.Count) integrated stair section checks."
