param([Parameter(Mandatory=$true)][string]$Routes,[Parameter(Mandatory=$true)][string]$Interfaces,[Parameter(Mandatory=$true)][string]$Output,[string]$SelectedD,[string]$DiningFurniture,[string]$LivingFurniture)
$ErrorActionPreference='Stop'
$r=Get-Content $Routes -Raw|ConvertFrom-Json;$f=Get-Content $Interfaces -Raw|ConvertFrom-Json
$selected=$null
if($SelectedD){$selected=Get-Content $SelectedD -Raw|ConvertFrom-Json;if((Get-FileHash $SelectedD).Hash-ne$r.selected_d_sha256){throw 'Selected-D fingerprint mismatch'}}
$furniture=$null
if($DiningFurniture){$furniture=Get-Content $DiningFurniture -Raw|ConvertFrom-Json;if((Get-FileHash $DiningFurniture).Hash-ne$r.dining_furniture_sha256){throw 'Dining furniture fingerprint mismatch'}}
if((Get-FileHash $Interfaces).Hash-ne$r.input_sha256){throw 'Route input fingerprint mismatch'}
function Area($a,$b){[math]::Max(0.0,[math]::Min($a.x+$a.w,$b.x+$b.w)-[math]::Max($a.x,$b.x))*[math]::Max(0.0,[math]::Min($a.y+$a.d,$b.y+$b.d)-[math]::Max($a.y,$b.y))}
$checks=0;$segments=0
foreach($case in $r.results){
 $c=@($f.results|Where-Object {$_.candidate-eq$case.candidate-and$_.mirrored-eq$case.mirrored})
 if($c.Count-ne1){throw 'Ambiguous source case'};$c=$c[0]
 if(-not$case.route_found){continue}
 $rooms=@($c.entry,$c.living,$c.kitchen)
 $obstacles=@($c.obstacles)
 if(@($case.livingObstacles).Count-gt0){
  if(-not$LivingFurniture-or(Get-FileHash $LivingFurniture).Hash-ne$case.living_source_sha256){throw 'Living source missing or hash mismatch'}
  $livingSource=Get-Content $LivingFurniture -Raw|ConvertFrom-Json;$expectedLiving=@()
  foreach($o in $livingSource.living_test.fixtures){$localY=if($case.living_transform-eq'whole-set local-Y mirror'){$c.living.d-$o.y-$o.d}elseif($case.living_transform-eq'source local placement'){$o.y}else{throw 'Unknown living transform'};$expectedLiving+=[pscustomobject]@{x=$c.living.x+$o.x;y=$c.living.y+$localY;w=$o.w;d=$o.d}}
  if($expectedLiving.Count-ne@($case.livingObstacles).Count){throw 'Living proxy count mismatch'}
  for($j=0;$j-lt$expectedLiving.Count;$j++){foreach($key in @('x','y','w','d')){if([math]::Abs($expectedLiving[$j].$key-$case.livingObstacles[$j].$key)-gt1e-6){throw 'Living transform mismatch'}}}
  $obstacles+=$expectedLiving
 }
 if($null-ne$case.bridge){
  if($null-eq$selected){throw 'Dining validation requires SelectedD'}
  $d=$selected.plans.main|Where-Object id -eq 'M-03'
  $dining=[pscustomobject]@{x=$case.dining.X;y=$case.dining.Y;w=$case.dining.W;d=$case.dining.D}
  foreach($key in @('x','w','d')){if([math]::Abs($dining.$key-$d.$key)-gt1e-6){throw 'Dining source mismatch'}}
  if([math]::Abs($dining.y-$d.y)-gt1e-6-and[math]::Abs($dining.y-($selected.shells.main[1]-$d.d))-gt1e-6){throw 'Unknown dining translation'}
  $bridge=[pscustomobject]@{x=$case.bridge.X;y=$case.bridge.Y;w=$case.bridge.W;d=$case.bridge.D}
  $rooms+=@($bridge,$dining);$obstacles+=@($selected.selection.main_public_bath.search_windows)+@($selected.plans.main|Where-Object id -eq 'M-04')
  $porch=$null
  if($null-ne$case.porch){
   $porch=[pscustomobject]@{x=$case.porch.X;y=$case.porch.Y;w=$case.porch.W;d=$case.porch.D}
   if([math]::Abs($porch.w-$selected.shells.porch_ft[0])-gt1e-6-or[math]::Abs($porch.d-$selected.shells.porch_ft[1])-gt1e-6-or[math]::Abs($porch.y-$selected.shells.main[1])-gt1e-6-or[math]::Abs(($porch.x+$porch.w/2)-($dining.x+$dining.w/2))-gt1e-6){throw 'Porch source/attachment mismatch'}
   if($case.door_reservation_ft.Count-ne2-or[math]::Abs($case.door_reservation_ft[0]-$dining.x)-gt1e-6-or[math]::Abs($case.door_reservation_ft[1]-$dining.x-5)-gt1e-6){throw 'Door reservation mismatch'}
   $rooms+=@($porch)
  }
  if(@($case.diningObstacles).Count-gt0){
   if($null-eq$furniture){throw 'Furniture source required'}
   $raw=@($furniture.table_rect_ft)+@($furniture.chair_body_rectangles_ft)+@($furniture.pullout_use_rectangles_ft)
   $minX=($raw|ForEach-Object {$_.x}|Measure-Object -Minimum).Minimum;$maxX=($raw|ForEach-Object {$_.x+$_.w}|Measure-Object -Maximum).Maximum
   $minY=($raw|ForEach-Object {$_.y}|Measure-Object -Minimum).Minimum;$maxY=($raw|ForEach-Object {$_.y+$_.d}|Measure-Object -Maximum).Maximum
   $expected=@();foreach($o in $raw){
    if($r.dining_transform-like'90-degree*'){$expected+=[pscustomobject]@{x=$dining.x+$dining.w/2-($o.y+$o.d-($minY+$maxY)/2);y=$dining.y+$dining.d/2+$o.x-($minX+$maxX)/2;w=$o.d;d=$o.w}}
    else{$expected+=[pscustomobject]@{x=$o.x-$furniture.dining_block_ft[0]+$dining.x;y=$o.y-$furniture.dining_block_ft[1]+$dining.y;w=$o.w;d=$o.d}}
   }
   if($expected.Count-ne@($case.diningObstacles).Count){throw 'Furniture count mismatch'}
   for($j=0;$j-lt$expected.Count;$j++){foreach($key in @('x','y','w','d')){if([math]::Abs($expected[$j].$key-$case.diningObstacles[$j].$key)-gt1e-6){throw 'Furniture transform mismatch'}}}
   $obstacles+=$expected
  }
 }
 for($i=0;$i-lt$rooms.Count;$i++){for($j=$i+1;$j-lt$rooms.Count;$j++){if((Area $rooms[$i] $rooms[$j])-gt1e-6){throw 'Overlapping room union invalidates area-sum validator'}}}
 $path=@($case.path);if($path.Count-eq0){throw 'Empty passing path'}
 $h=$r.width_ft/2
 if([math]::Abs($path[0][0]-($c.entry.x+$c.entry.w/2))-gt1e-6-or[math]::Abs($path[0][1]-($c.entry.y+$h))-gt1e-6){throw 'Wrong arrival endpoint'}
 $last=$path[-1];if($null-ne$case.bridge){$targetY=if($porch){$porch.y+$h}elseif($furniture){$dining.y+$dining.d-$h}else{$dining.y+$h};if([math]::Abs($last[1]-$targetY)-gt1e-6-or$last[0]-lt$dining.x+$h-1e-6-or$last[0]-gt$dining.x+$dining.w-$h+1e-6){throw 'Wrong dining/porch endpoint'}}else{$goals=@($c.living_portals|Where-Object {[math]::Abs($_.x-$last[0])-lt1e-6-and[math]::Abs($_.y-$last[1])-lt1e-6});if($goals.Count-eq0){throw 'Wrong interface endpoint'}}
 for($i=0;$i-lt$path.Count;$i++){
  $a=$path[$i];$b=if($i-eq0){$a}else{$path[$i-1]}
  $dx=[math]::Abs($a[0]-$b[0]);$dy=[math]::Abs($a[1]-$b[1]);if($dx-gt1e-7-and$dy-gt1e-7){throw 'Diagonal path'}
  $q=[pscustomobject]@{x=[math]::Min($a[0],$b[0])-$h;y=[math]::Min($a[1],$b[1])-$h;w=$dx+$r.width_ft;d=$dy+$r.width_ft}
  if($porch-and$q.y-lt$porch.y-1e-7-and$q.y+$q.d-gt$porch.y+1e-7){if($q.x-lt$case.door_reservation_ft[0]-1e-6-or$q.x+$q.w-gt$case.door_reservation_ft[1]+1e-6){throw 'Route crosses closed porch wall interval'}}
  $covered=0.0;foreach($room in $rooms){$covered+=Area $q $room};if([math]::Abs($covered-$q.w*$q.d)-gt1e-5){throw "Swept area outside room union: case=$($case.candidate), i=$i, covered=$covered, expected=$($q.w*$q.d), q=$($q|ConvertTo-Json -Compress)"}
  foreach($o in $obstacles){if((Area $q $o)-gt1e-6){throw 'Swept obstacle collision'}};$segments++
 };$checks++
}
if(Test-Path $Output){throw 'Output exists'}
[ordered]@{status='pass';route_cases=$checks;swept_patches=$segments;route_sha256=(Get-FileHash $Routes).Hash;method='Independent intersection-area sum over verified disjoint rooms; every segment and turn square checked';limitations='Same schematic input proxies; no door, furniture completeness, code or construction validation'}|ConvertTo-Json|Set-Content $Output
Write-Output "PASS $checks route cases; $segments swept patches"
