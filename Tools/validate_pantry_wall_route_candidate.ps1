param([Parameter(Mandatory=$true)][string]$InputPath,[Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference='Stop'; if(Test-Path $Output){throw 'Output exists'}
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$full=[IO.Path]::GetFullPath((Join-Path $root $InputPath)); if(-not $full.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Input outside checkout'}
$j=Get-Content $full -Raw|ConvertFrom-Json; $p=$j.room_blocks|Where-Object id -eq 'M-04'; if($null -eq $p){throw 'M-04 pantry missing'}
$half=[double]$j.route_width_ft/2; $x=[double]$p.x; $y=[double]$p.y; $w=[double]$p.w; $d=[double]$p.d; $t=2.0/3.0
$walls=@([pscustomobject]@{name='south';x0=$x;y0=$y;x1=$x+$w;y1=$y+$t},[pscustomobject]@{name='east';x0=$x+$w-$t;y0=$y;x1=$x+$w;y1=$y+$d},[pscustomobject]@{name='north';x0=$x;y0=$y+$d-$t;x1=$x+$w;y1=$y+$d},[pscustomobject]@{name='west';x0=$x;y0=$y;x1=$x+$t;y1=$y+$d})
$hits=@();$route=@($j.main_route); for($n=1;$n-lt$route.Count;$n++){ $ax=[double]$route[$n-1][0];$ay=[double]$route[$n-1][1];$bx=[double]$route[$n][0];$by=[double]$route[$n][1];$xmin=([math]::Min($ax,$bx))-$half;$xmax=([math]::Max($ax,$bx))+$half;$ymin=([math]::Min($ay,$by))-$half;$ymax=([math]::Max($ay,$by))+$half; foreach($wall in $walls){$dx=([math]::Min($xmax,[double]$wall.x1)-[math]::Max($xmin,[double]$wall.x0));$dy=([math]::Min($ymax,[double]$wall.y1)-[math]::Max($ymin,[double]$wall.y0)); if($dx -gt 1e-6 -and $dy -gt 1e-6){$hits += [pscustomobject]@{segment=$n;wall=$wall.name;overlap_sf=$dx*$dy}}}}
$status=if($hits.Count -eq 0){'pass'}else{'fail'}; [ordered]@{status=$status;input_sha256=(Get-FileHash $full).Hash;pantry=[ordered]@{x=$x;y=$y;w=$w;d=$d};route_width_ft=[double]$j.route_width_ft;wall_route_collisions=$hits}|ConvertTo-Json -Depth 10|Set-Content $Output
Write-Output "$status : $($hits.Count) pantry-wall/main-route bound collisions"; if($status -ne 'pass'){throw 'Pantry wall/main-route candidate failed'}
