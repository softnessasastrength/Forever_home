param(
    [Parameter(Mandatory=$true)][string]$StudyDirectory,
    [string]$Output = '.local/revalidation/walkthrough-composition.json'
)
$ErrorActionPreference='Stop'
$repo=(Get-Location).Path
$manifestPath=Join-Path $StudyDirectory 'walkthrough-composition-manifest.json'
if(-not(Test-Path $manifestPath)){throw "Missing composition manifest: $manifestPath"}
$m=Get-Content $manifestPath -Raw|ConvertFrom-Json
function C([string]$n,[bool]$p,[string]$d){[pscustomobject]@{name=$n;pass=$p;detail=$d}}
$checks=@(
 C 'schema' ($m.schema -eq 'forever-home-walkthrough-composition-v1') 'composition schema'
 C 'status' ($m.status -like 'disposable composed walkthrough*') 'composition remains unselected'
 C 'selected_d_hash' ($m.selected_d_sha256 -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb') 'Selected-D lineage'
 C 'inventory' ($m.wall_count -eq 57 -and $m.door_count -eq 12 -and $m.floor_count -eq 9 -and $m.roof_count -eq 3 -and $m.landing_count -eq 3) 'three side-by-side cases'
 C 'skylight_reservations' (@($m.cases|Where-Object{$_.skylight_reservations -eq 3}).Count -eq 3) 'nine labelled reservations across stair, kitchen and primary-bath study zones'
 C 'interior_proxies' (@($m.cases|Where-Object{$_.kitchen_island_count -eq 1 -and $_.primary_bath_vignette_count -eq 1}).Count -eq 3) 'three owner-directed kitchen islands and primary-bath vignettes'
 C 'cases' (@($m.cases).Count -eq 3 -and @($m.cases|Where-Object{$_.selected -eq $false -and $_.wall_count -eq 19 -and $_.door_count -eq 4 -and $_.floor_count -eq 3 -and $_.landing_count -eq 1 -and $_.roof_count -eq 1}).Count -eq 3) 'all cases unselected with expected native inventory'
 C 'files' ((Test-Path (Join-Path $StudyDirectory $m.saved_rvt)) -and (Test-Path (Join-Path $StudyDirectory $m.ifc)) -and (Get-Item (Join-Path $StudyDirectory $m.ifc)).Length -gt 0) 'saved RVT and IFC'
 C 'ifc_entities' ((Select-String -LiteralPath (Join-Path $StudyDirectory $m.ifc) -Pattern 'IFCWALL' -Quiet) -and (Select-String -LiteralPath (Join-Path $StudyDirectory $m.ifc) -Pattern 'IFCDOOR' -Quiet) -and (Select-String -LiteralPath (Join-Path $StudyDirectory $m.ifc) -Pattern 'IFCSLAB' -Quiet) -and (Select-String -LiteralPath (Join-Path $StudyDirectory $m.ifc) -Pattern 'IFCROOF' -Quiet)) 'IFC wall/door/floor/roof entities'
)
$failed=@($checks|Where-Object{-not$_.pass});$out=if([IO.Path]::IsPathRooted($Output)){$Output}else{Join-Path $repo $Output};New-Item -ItemType Directory -Force -Path (Split-Path $out -Parent)|Out-Null;[ordered]@{schema='forever-home-walkthrough-composition-validation-v1';status=if($failed.Count){'fail'}else{'pass'};passed=@($checks|Where-Object pass).Count;total=$checks.Count;checks=$checks;limitations=@('Disposable composition only; no selected-D promotion or code/structural/professional/construction conclusion.')}|ConvertTo-Json -Depth 12|Set-Content -LiteralPath $out -Encoding UTF8;if($failed.Count){throw "Walkthrough composition failed $($failed.Count) checks."};Write-Output "PASS: $($checks.Count)/$($checks.Count) walkthrough composition checks."
