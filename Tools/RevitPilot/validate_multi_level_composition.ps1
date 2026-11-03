param([Parameter(Mandatory=$true)][string]$StudyDirectory)
$ErrorActionPreference='Stop'
$m=Get-Content (Join-Path $StudyDirectory 'multi-level-composition-manifest.json') -Raw|ConvertFrom-Json
$checks=@(
 [pscustomobject]@{name='schema';pass=$m.schema -eq 'forever-home-multi-level-composition-v6';detail=$m.schema},
 [pscustomobject]@{name='status';pass=$m.status -like 'disposable*not selected-D';detail=$m.status},
 [pscustomobject]@{name='selected_d';pass=$m.selected_d_sha256 -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb';detail=$m.selected_d_sha256},
 [pscustomobject]@{name='levels';pass=@($m.levels).Count -eq 3 -and @($m.levels|Where-Object{$_.elevation_ft -in @(-5,0,5)}).Count -eq 3;detail="count=$(@($m.levels).Count)"},
 [pscustomobject]@{name='inventory';pass=$m.room_block_count -eq 21 -and $m.room_space_count -eq 21 -and $m.wall_count -eq 84 -and $m.floor_count -eq 22 -and $m.roof_count -eq 3 -and $m.stair_count -eq 2 -and $m.stair_run_count -eq 2;detail="blocks=$($m.room_block_count) spaces=$($m.room_space_count) walls=$($m.wall_count) floors=$($m.floor_count) roofs=$($m.roof_count) stairs=$($m.stair_count) runs=$($m.stair_run_count)"},
 [pscustomobject]@{name='stair_study';pass=$m.stair_study.risers_per_flight -eq 8 -and $m.stair_study.riser_in -eq 7.5 -and $m.stair_study.tread_in -eq 11 -and $m.stair_study.status -like 'documented*';detail='two native 5 ft comparison flights; unresolved final stair criteria'},
 [pscustomobject]@{name='interior_proxies';pass=$m.kitchen_island_count -eq 1 -and $m.primary_bath_fixture_proxy_count -eq 2 -and $m.interior_proxy_status -like 'owner-approved*';detail="islands=$($m.kitchen_island_count) bath_proxies=$($m.primary_bath_fixture_proxy_count)"},
 [pscustomobject]@{name='skylights';pass=$m.skylight_reservation_count -eq 9 -and $m.skylight_status -like 'nine non-cutting*';detail=$m.skylight_status},
 [pscustomobject]@{name='site_markers';pass=$m.site_direction_marker_count -eq 2 -and $m.site_direction_status -like 'two dimension-neutral*';detail=$m.site_direction_status},
 [pscustomobject]@{name='door_proxies';pass=$m.door_proxy_count -eq 3 -and $m.door_proxy_status -like 'three nominal display*';detail=$m.door_proxy_status},
 [pscustomobject]@{name='exterior';pass=$m.porch_patio_reservation_count -eq 1 -and $m.driveway_reservation -like 'documented*' -and $m.future_pool_route -like 'documented*';detail='porch/patio plus labelled site reservations'},
 [pscustomobject]@{name='files';pass=(Test-Path (Join-Path $StudyDirectory $m.saved_rvt)) -and (Test-Path (Join-Path $StudyDirectory $m.ifc)) -and (Get-Item (Join-Path $StudyDirectory $m.ifc)).Length -gt 0;detail='RVT and IFC present'},
 [pscustomobject]@{name='hashes';pass=$m.saved_rvt_sha256 -eq ((Get-FileHash (Join-Path $StudyDirectory $m.saved_rvt) -Algorithm SHA256).Hash.ToLower()) -and $m.ifc_sha256 -eq ((Get-FileHash (Join-Path $StudyDirectory $m.ifc) -Algorithm SHA256).Hash.ToLower());detail='manifest hashes'},
 [pscustomobject]@{name='ifc2x3';pass=$m.ifc2x3 -and (Select-String -LiteralPath (Join-Path $StudyDirectory $m.ifc) -Pattern 'FILE_SCHEMA\(\(\x27IFC2X3\x27\)\)' -Quiet) -and (Select-String -LiteralPath (Join-Path $StudyDirectory $m.ifc) -Pattern 'IFCWALL' -Quiet) -and (Select-String -LiteralPath (Join-Path $StudyDirectory $m.ifc) -Pattern 'IFCSLAB' -Quiet) -and (Select-String -LiteralPath (Join-Path $StudyDirectory $m.ifc) -Pattern 'IFCROOF' -Quiet);detail='IFC2X3 wall/slab/roof entities'}
)
$checks|Format-Table; if(@($checks|Where-Object{-not $_.pass}).Count){throw 'M385 multi-level validation failed.'}; Write-Output "PASS: $($checks.Count)/$($checks.Count) multi-level composition checks."
