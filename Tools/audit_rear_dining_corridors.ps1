param([Parameter(Mandatory=$true)][string]$Routes,[Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$s=Get-Content (Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json') -Raw|ConvertFrom-Json
$r=Get-Content $Routes -Raw|ConvertFrom-Json
if((Get-FileHash (Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json')).Hash-ne$r.selected_d_sha256){throw 'Source mismatch'}
function Rect($a){[pscustomobject]@{x=$a[0];y=$a[1];w=$a[2];d=$a[3]}}
function Intersect($a,$b){$x=[math]::Max($a.x,$b.x);$y=[math]::Max($a.y,$b.y);$w=[math]::Min($a.x+$a.w,$b.x+$b.w)-$x;$d=[math]::Min($a.y+$a.d,$b.y+$b.d)-$y;if($w-gt1e-7-and$d-gt1e-7){[pscustomobject]@{x=$x;y=$y;w=$w;d=$d}}}
$core=@();foreach($flight in @($s.stair_core_test.lower_to_main,$s.stair_core_test.main_to_upper)){foreach($key in @('main_landing_ft','main_floor_opening_ft')){$core+=Rect $flight.$key}}
$lift=$s.stair_core_test.lift;$core+=Rect @($lift.origin_ft[0],$lift.origin_ft[1],$lift.width_ft,$lift.depth_ft)
$rows=@();foreach($c in $r.results|Where-Object route_found){
 $b=[pscustomobject]@{x=$c.bridge.X;y=$c.bridge.Y;w=$c.bridge.W;d=$c.bridge.D}
 $d=[pscustomobject]@{x=$c.dining.X;y=$c.dining.Y;w=$c.dining.W;d=$c.dining.D}
 foreach($q in @($b,$d)){foreach($o in $core){if($null-ne(Intersect $q $o)){throw 'Core reservation collision'}}}
 $patches=@();$h=$r.width_ft/2
 for($i=0;$i-lt$c.path.Count;$i++){$a=$c.path[$i];$z=if($i-eq0){$a}else{$c.path[$i-1]};$q=[pscustomobject]@{x=[math]::Min($a[0],$z[0])-$h;y=[math]::Min($a[1],$z[1])-$h;w=[math]::Abs($a[0]-$z[0])+$r.width_ft;d=[math]::Abs($a[1]-$z[1])+$r.width_ft};$clip=Intersect $q $b;if($null-ne$clip){$patches+=$clip}}
 $xs=@($patches|ForEach-Object {$_.x;$_.x+$_.w}|Sort-Object -Unique);$area=0.0
 for($i=1;$i-lt$xs.Count;$i++){$mid=($xs[$i-1]+$xs[$i])/2;$ints=@($patches|Where-Object {$mid-gt$_.x-and$mid-lt$_.x+$_.w}|Sort-Object y);$end=[double]::NegativeInfinity;$length=0.0;foreach($p in $ints){$lo=[math]::Max($p.y,$end);$hi=$p.y+$p.d;if($hi-gt$lo){$length+=$hi-$lo};$end=[math]::Max($end,$hi)};$area+=($xs[$i]-$xs[$i-1])*$length}
 $rows+=[pscustomobject]@{candidate=$c.candidate;connector_envelope_sf=$b.w*$b.d;swept_connector_union_sf=$area;unoccupied_envelope_sf=$b.w*$b.d-$area;core_collision=$false}
}
if(Test-Path $Output){throw 'Output exists'}
[ordered]@{status='pass';route_sha256=(Get-FileHash $Routes).Hash;results=$rows;limitations='Exact swept union within proposed connector; not usable floor area, selected corridor walls, final core, or code result'}|ConvertTo-Json -Depth 6|Set-Content $Output
$rows|Measure-Object swept_connector_union_sf -Minimum -Maximum
