param([string]$Routes,[string]$Interfaces,[string]$Output)
$ErrorActionPreference='Stop';if(Test-Path $Output){throw 'Output exists'}
$r=Get-Content $Routes -Raw|ConvertFrom-Json;$f=Get-Content $Interfaces -Raw|ConvertFrom-Json
$s=Get-Content Architecture/Selected_Design_Iteration_2026-10-27/study.json -Raw|ConvertFrom-Json
function NewRect($x,$y,$w,$d){[pscustomobject]@{x=[double]$x;y=[double]$y;w=[double]$w;d=[double]$d}}
function Hit($a,$b){([math]::Min($a.x+$a.w,$b.x+$b.w)-[math]::Max($a.x,$b.x)-gt1e-6)-and([math]::Min($a.y+$a.d,$b.y+$b.d)-[math]::Max($a.y,$b.y)-gt1e-6)}
$sourcePantry=$s.plans.main|Where-Object id -eq 'M-04';$rows=@()
foreach($c in $r.results|Where-Object route_found){
 $l=@($f.results|Where-Object {$_.candidate-eq$c.candidate-and$_.mirrored-eq$c.mirrored})[0];$k=$l.kitchen
 $fixed=@($l.kitchen,$l.living,$l.entry)+@($s.selection.main_public_bath.search_windows)
 $fixed+=NewRect $c.dining.X $c.dining.Y $c.dining.W $c.dining.D
 foreach($flight in @($s.stair_core_test.lower_to_main,$s.stair_core_test.main_to_upper)){foreach($key in @('main_landing_ft','main_floor_opening_ft')){$a=$flight.$key;$fixed+=NewRect $a[0] $a[1] $a[2] $a[3]}}
 $lift=$s.stair_core_test.lift;$fixed+=NewRect $lift.origin_ft[0] $lift.origin_ft[1] $lift.width_ft $lift.depth_ft
 $sweeps=@();$h=$r.width_ft/2;for($i=0;$i-lt$c.path.Count;$i++){$a=$c.path[$i];$b=if($i-eq0){$a}else{$c.path[$i-1]};$sweeps+=NewRect ([math]::Min($a[0],$b[0])-$h) ([math]::Min($a[1],$b[1])-$h) ([math]::Abs($a[0]-$b[0])+$r.width_ft) ([math]::Abs($a[1]-$b[1])+$r.width_ft)}
 # North-adjacent pantry scope only; no reshaping or storage-area reduction.
 foreach($dims in @(@($sourcePantry.w,$sourcePantry.d),@($sourcePantry.d,$sourcePantry.w))){
  for($i=0;$i-le160;$i++){
   $p=NewRect (2.0/3+$i*.25) ($k.y+$k.d) $dims[0] $dims[1]
   if($p.x+$p.w-gt40-2.0/3-or$p.y+$p.d-gt42-2.0/3){continue}
   $bad=$false;foreach($o in $fixed){if(Hit $p $o){$bad=$true;break}};if($bad){continue};foreach($o in $sweeps){if(Hit $p $o){$bad=$true;break}};if($bad){continue}
   $lo=[math]::Max($p.x,$k.x)+$h;$hi=[math]::Min($p.x+$p.w,$k.x+$k.w)-$h;$portals=@()
   for($x=$lo;$x-le$hi+1e-7;$x+=.25){$q=NewRect ($x-$h) ($p.y-$h) $r.width_ft $r.width_ft;$blocked=$false;foreach($o in $l.obstacles){if(Hit $q $o){$blocked=$true}};if(-not$blocked){$portals+=,$x}}
   $spurs=@();$bridge=NewRect $c.bridge.X $c.bridge.Y $c.bridge.W $c.bridge.D
   foreach($point in $c.path){
    if($point[0]-gt$p.x-$h+1e-6-or$point[1]-lt$p.y+$h-1e-6-or$point[1]-gt$p.y+$p.d-$h+1e-6){continue}
    $spur=NewRect ($point[0]-$h) ($point[1]-$h) ($p.x+$r.width_ft-$point[0]+$h) $r.width_ft
    # The centreline ends one radius inside the pantry, so the entire terminal square is inside it.
    $spur.w=$p.x+$r.width_ft-$spur.x
    if($spur.x-lt$bridge.x-1e-6-or$spur.y-lt$bridge.y-1e-6-or$spur.x+$spur.w-gt$bridge.x+$bridge.w+1e-6-or$spur.y+$spur.d-gt$bridge.y+$bridge.d+1e-6){continue}
    $bad=$false;foreach($o in (@($fixed)+@($l.obstacles))){if(Hit $spur $o){$bad=$true;break}};if($bad){continue}
    $spurs+=,[pscustomobject]@{from_route_ft=$point;to_pantry_ft=@(($p.x+$h),$point[1]);swept_rect=$spur;length_ft=$p.x+$h-$point[0]}
   }
   $rows+=[pscustomobject]@{candidate=$c.candidate;pantry=$p;area_sf=$p.w*$p.d;existing_porch_route_preserved=$true;kitchen_shared_approach_count=$portals.Count;approach_centres_x=$portals;connector_spur_count=$spurs.Count;connector_spur_example=@($spurs|Sort-Object length_ft,@{Expression={[math]::Abs($_.to_pantry_ft[1]-($p.y+$p.d/2))}}|Select-Object -First 1);door_swing='unresolved'}
  }
 }
}
[ordered]@{route_sha256=(Get-FileHash $Routes).Hash;interface_sha256=(Get-FileHash $Interfaces).Hash;scope='north-adjacent full-area pantry translations and 90-degree orientation; source pantry removed only for comparison';placements=$rows;limitations='Static footprint and local 36-in approach patches only; no storage layout, door swing, plumbing or code finding'}|ConvertTo-Json -Depth 8|Set-Content $Output
Write-Output "Static placements $($rows.Count); approach-passing $(@($rows|Where-Object kitchen_shared_approach_count -gt 0).Count)"
Write-Output "Connector-side spur placements: $(@($rows|Where-Object connector_spur_count -gt 0).Count)"
