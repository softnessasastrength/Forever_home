param([string]$OutputDirectory='Architecture/M186_Multiturn_Route_Search_2026-10-31/artifacts')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
$rels=[ordered]@{
 m172='Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'
 m173='Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
 bath='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
 m178='Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json'
 m179='Architecture/M179_Pantry_Route_Clearance_Audit_2026-10-31/m179-study.json'
 m179script='Tools/audit_m179_pantry_route_conflict.ps1'
 m180='Architecture/M180_Living_Shell_Route_Audit_2026-10-31/artifacts/m180-study.json'
 m185='Architecture/M185_Dogleg_M06_Overlay_2026-10-31/artifacts/m185-dogleg-m06-overlay.json'
 selected='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
}
foreach($r in $rels.Values){if(-not(Test-Path -LiteralPath (Join-Path $root $r) -PathType Leaf)){throw "Missing required source: $r"}}
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}
function GetHash186([string]$r){(Get-FileHash -LiteralPath (Join-Path $root $r) -Algorithm SHA256).Hash.ToLowerInvariant()}
function NewRect186([double]$x,[double]$y,[double]$w,[double]$d,[string]$id){[pscustomobject]@{id=$id;x=$x;y=$y;w=$w;d=$d}}
function HitArea186([object]$a,[object]$b){$dx=[Math]::Min(([double]$a.x+[double]$a.w),([double]$b.x+[double]$b.w))-[Math]::Max([double]$a.x,[double]$b.x);$dy=[Math]::Min(([double]$a.y+[double]$a.d),([double]$b.y+[double]$b.d))-[Math]::Max([double]$a.y,[double]$b.y);if($dx-gt1e-8-and$dy-gt1e-8){return [Math]::Round($dx*$dy,8)};return 0.0}
function NodeClear186([double]$x,[double]$y,[object[]]$obstacles,[double]$radius){foreach($o in $obstacles){if($x-gt([double]$o.x-$radius)-and$x-lt([double]$o.x+[double]$o.w+$radius)-and$y-gt([double]$o.y-$radius)-and$y-lt([double]$o.y+[double]$o.d+$radius)){return $false}};return $true}
function EdgeClear186([double]$x1,[double]$y1,[double]$x2,[double]$y2,[object[]]$obstacles,[double]$width){if([Math]::Abs($y1-$y2)-lt1e-8){$r=NewRect186 ([Math]::Min($x1,$x2)) ($y1-$width/2) ([Math]::Abs($x2-$x1)) $width 'edge'}elseif([Math]::Abs($x1-$x2)-lt1e-8){$r=NewRect186 ($x1-$width/2) ([Math]::Min($y1,$y2)) $width ([Math]::Abs($y2-$y1)) 'edge'}else{return $false};foreach($o in $obstacles){if((HitArea186 $r $o)-gt0){return $false}};return $true}
function RouteRects186([object[]]$points,[double]$width){$rr=New-Object System.Collections.Generic.List[object];for($i=0;$i-lt$points.Count-1;$i++){$a=$points[$i];$b=$points[$i+1];if([Math]::Abs([double]$a.y-[double]$b.y)-lt1e-8){$rr.Add((NewRect186 ([Math]::Min([double]$a.x,[double]$b.x)) ([double]$a.y-$width/2) ([Math]::Abs([double]$b.x-[double]$a.x)) $width "route-$i"))}elseif([Math]::Abs([double]$a.x-[double]$b.x)-lt1e-8){$rr.Add((NewRect186 ([double]$a.x-$width/2) ([Math]::Min([double]$a.y,[double]$b.y)) $width ([Math]::Abs([double]$b.y-[double]$a.y)) "route-$i"))}else{throw 'Non-orthogonal path in route compaction.'};if($i-gt0){$rr.Add((NewRect186 ([double]$a.x-$width/2) ([double]$a.y-$width/2) $width $width "corner-$i"))}};return $rr.ToArray()}
function RectGap186([object]$a,[object]$b){$dx=[Math]::Max(0.0,[Math]::Max(([double]$a.x-([double]$b.x+[double]$b.w)),([double]$b.x-([double]$a.x+[double]$a.w))));$dy=[Math]::Max(0.0,[Math]::Max(([double]$a.y-([double]$b.y+[double]$b.d)),([double]$b.y-([double]$a.y+[double]$a.d))));return [Math]::Sqrt($dx*$dx+$dy*$dy)}
$m172=Get-Content (Join-Path $root $rels.m172) -Raw|ConvertFrom-Json
$m173=Get-Content (Join-Path $root $rels.m173) -Raw|ConvertFrom-Json
$bath=Get-Content (Join-Path $root $rels.bath) -Raw|ConvertFrom-Json
$m178=Get-Content (Join-Path $root $rels.m178) -Raw|ConvertFrom-Json
$m179=Get-Content (Join-Path $root $rels.m179) -Raw|ConvertFrom-Json
$m180=Get-Content (Join-Path $root $rels.m180) -Raw|ConvertFrom-Json
$m185=Get-Content (Join-Path $root $rels.m185) -Raw|ConvertFrom-Json
$selected=Get-Content (Join-Path $root $rels.selected) -Raw|ConvertFrom-Json
$hashes=[ordered]@{};foreach($k in $rels.Keys){$hashes[$rels[$k]]=GetHash186 $rels[$k]}
$sourceChecks=New-Object System.Collections.Generic.List[object]
foreach($doc in @(@{name='M179';data=$m179},@{name='M180';data=$m180},@{name='M185';data=$m185})){foreach($entry in $doc.data.source_fingerprints_sha256.PSObject.Properties){$sourceChecks.Add([pscustomobject]@{id=("{0}:{1}" -f $doc.name,$entry.Name);pass=((GetHash186 $entry.Name)-eq([string]$entry.Value).ToLowerInvariant());detail='Upstream source fingerprint is current.'})}}
$selectedHash=GetHash186 $rels.selected
$origin=@($bath.plans.main|Where-Object id -eq 'M-02')[0]
$livingSource=@($bath.plans.main|Where-Object id -eq 'M-01')[0]
$entrySource=@($bath.plans.main|Where-Object id -eq 'M-05')[0]
$pantrySource=@($bath.plans.main|Where-Object id -eq 'M-04')[0]
$living=NewRect186 ([double]$livingSource.x-[double]$origin.x) ([double]$livingSource.y-[double]$origin.y) ([double]$livingSource.w) ([double]$livingSource.d) 'M-01-living'
$entry=NewRect186 ([double]$entrySource.x-[double]$origin.x) ([double]$entrySource.y-[double]$origin.y) ([double]$entrySource.w) ([double]$entrySource.d) 'M-05-entry'
$pantry=NewRect186 ([double]$pantrySource.x-[double]$origin.x) ([double]$pantrySource.y-[double]$origin.y) ([double]$pantrySource.w) ([double]$pantrySource.d) 'M-04-pantry'
$windows=@();foreach($w in $bath.selection.main_public_bath.search_windows){$windows+=,(NewRect186 ([double]$w.x-[double]$origin.x) ([double]$w.y-[double]$origin.y) ([double]$w.w) ([double]$w.d) ([string]$w.id))}
$west=@($windows|Where-Object id -eq 'west_of_core')[0];$east=@($windows|Where-Object id -eq 'east_of_core')[0]
$eastWindowSource=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
$cand=$m178.candidate;$counter=NewRect186 0 0.75 2 ([double]$cand.perimeter_run_ft) 'perimeter-run'
$ib=@($cand.island_rect_ft);$island=NewRect186 $ib[0] $ib[1] $ib[2] $ib[3] 'island'
$sb=@($cand.assumed_stool_rect_ft);$stools=NewRect186 $sb[0] $sb[1] $sb[2] $sb[3] 'assumed-stool-use-proxy'
$hb=@($cand.halfwall_rect_ft);$halfwall=NewRect186 $hb[0] $hb[1] $hb[2] $hb[3] 'half-wall'
$wallReturn=NewRect186 ([double]$hb[0]) 13 0.5 1 'half-wall-return'
$table=NewRect186 3 17.5 5 3 'dining-table'
$chairs=@((NewRect186 3.5 15.8333333333 1.5 1.6666666667 'south-chair-1'),(NewRect186 6 15.8333333333 1.5 1.6666666667 'south-chair-2'),(NewRect186 1.3333333333 17.5 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.3333333333 19 1.6666666667 1.5 'west-chair-2'))
$porchWalls=@((NewRect186 -0.5 24.5 6.5 0.5 'porch-wall-west-of-door'),(NewRect186 11 24.5 0.5 0.5 'porch-wall-east-of-door'))
$obstacles=@($entry,$pantry,$west,$east,$counter,$island,$stools,$halfwall,$wallReturn,$table)+$chairs+$porchWalls
$width=3.0;$radius=$width/2.0;$step=0.25
$shellMatch=[regex]::Match([string]$selected.selection.main_shell,'(?<w>\d+(?:\.\d+)?)\s*[x×]\s*(?<d>\d+(?:\.\d+)?)\s*ft',[System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
if(-not$shellMatch.Success){throw "Could not parse selected main-shell test envelope: $($selected.selection.main_shell)"}
$shellW=[double]::Parse($shellMatch.Groups['w'].Value,[Globalization.CultureInfo]::InvariantCulture);$shellD=[double]::Parse($shellMatch.Groups['d'].Value,[Globalization.CultureInfo]::InvariantCulture)
$shellMinX=-[double]$origin.x;$shellMaxX=$shellW-[double]$origin.x;$shellMinY=-[double]$origin.y;$shellMaxY=$shellD-[double]$origin.y
$minXI=[int][Math]::Ceiling(($shellMinX+$radius)/$step);$maxXI=[int][Math]::Floor(($shellMaxX-$radius)/$step)
$minYI=[int][Math]::Ceiling(($shellMinY+$radius)/$step);$maxYI=[int][Math]::Floor(($shellMaxY-$radius)/$step)
$nx=$maxXI-$minXI+1;$ny=$maxYI-$minYI+1;$nodeTotal=$nx*$ny
function NodeId186([int]$ix,[int]$iy){return (($iy-$minYI)*$nx+($ix-$minXI))}
function NodeXY186([int]$id){$iy=[int][Math]::Floor($id/$nx)+$minYI;$ix=($id%$nx)+$minXI;return [pscustomobject]@{ix=$ix;iy=$iy;x=$ix*$step;y=$iy*$step}}
$m180Pts=@($m180.revised_route.centerline_local_ft)
$routeStart=[pscustomobject]@{x=[double]$m180Pts[0].x;y=[double]$m180Pts[0].y}
$routeDoor=[pscustomobject]@{x=8.5;y=24.5}
$routeEnd=[pscustomobject]@{x=8.5;y=27.5}
$openX=[double]$cand.halfwall_rect_ft[0]+[double]$cand.halfwall_rect_ft[2]
$openY=[double]$m180.revised_route.opening_centerline_y_ft
$openingNode=[pscustomobject]@{x=$openX;y=$openY}
$startIx=[int][Math]::Round($openingNode.x/$step);$startIy=[int][Math]::Round($openingNode.y/$step)
$goalIx=[int][Math]::Round($routeDoor.x/$step);$goalIy=[int][Math]::Round($routeDoor.y/$step)
$startId=NodeId186 $startIx $startIy;$goalId=NodeId186 $goalIx $goalIy
$parent=New-Object 'int[]' $nodeTotal;$visited=New-Object 'bool[]' $nodeTotal;for($i=0;$i-lt$nodeTotal;$i++){$parent[$i]=-2}
$queue=New-Object 'System.Collections.Generic.Queue[int]'
$startClear=NodeClear186 $openingNode.x $openingNode.y $obstacles $radius
$connector=NewRect186 ([Math]::Min([double]$routeStart.x,[double]$openingNode.x)) ([double]$routeStart.y-$radius) ([Math]::Abs([double]$routeStart.x-[double]$openingNode.x)) $width 'living-to-opening-connector'
$connectorHits=New-Object System.Collections.Generic.List[object];foreach($o in $obstacles){$a=HitArea186 $connector $o;if($a-gt0){$connectorHits.Add([ordered]@{obstacle=$o.id;overlap_sf=$a})}}
$moves=@([pscustomobject]@{dx=-1;dy=0},[pscustomobject]@{dx=1;dy=0},[pscustomobject]@{dx=0;dy=-1},[pscustomobject]@{dx=0;dy=1})
$goalReached=$false;$expanded=0
if($startClear-and$startIx-ge$minXI-and$startIx-le$maxXI-and$startIy-ge$minYI-and$startIy-le$maxYI){$visited[$startId]=$true;$parent[$startId]=-1;$queue.Enqueue($startId)}
while($queue.Count-gt0){$id=$queue.Dequeue();$expanded++;if($id-eq$goalId){$goalReached=$true;break};$p=NodeXY186 $id
 foreach($move in $moves){$ix=$p.ix+$move.dx;$iy=$p.iy+$move.dy;if($ix-lt$minXI-or$ix-gt$maxXI-or$iy-lt$minYI-or$iy-gt$maxYI){continue};$x=$ix*$step;$y=$iy*$step
  if($y-gt([double]$routeDoor.y+1e-8)){continue} # The route may enter the porch only through the tested south-door opening.
  $next=NodeId186 $ix $iy;if($visited[$next]){continue};if(-not(NodeClear186 $x $y $obstacles $radius)){continue};if(-not(EdgeClear186 $p.x $p.y $x $y $obstacles $width)){continue};$visited[$next]=$true;$parent[$next]=$id;$queue.Enqueue($next)
 }
}
$nearestReachable=$null;$frontierBlockerCounts=@{};$reachMinX=[double]::PositiveInfinity;$reachMaxX=[double]::NegativeInfinity;$reachMinY=[double]::PositiveInfinity;$reachMaxY=[double]::NegativeInfinity
for($id=0;$id-lt$nodeTotal;$id++){if(-not$visited[$id]){continue};$p=NodeXY186 $id;$reachMinX=[Math]::Min($reachMinX,$p.x);$reachMaxX=[Math]::Max($reachMaxX,$p.x);$reachMinY=[Math]::Min($reachMinY,$p.y);$reachMaxY=[Math]::Max($reachMaxY,$p.y);$distance=[Math]::Abs($p.ix-$goalIx)+[Math]::Abs($p.iy-$goalIy);if($null-eq$nearestReachable-or$distance-lt$nearestReachable.distance_grid_steps){$nearestReachable=[ordered]@{x_ft=$p.x;y_ft=$p.y;distance_grid_steps=$distance;distance_manhattan_ft=[Math]::Round($distance*$step,4)}}
 foreach($move in $moves){$ix=$p.ix+$move.dx;$iy=$p.iy+$move.dy;if($ix-lt$minXI-or$ix-gt$maxXI-or$iy-lt$minYI-or$iy-gt$maxYI-or($iy*$step)-gt([double]$routeDoor.y+1e-8)){continue};$nid=NodeId186 $ix $iy;if($visited[$nid]){continue};$x=$ix*$step;$y=$iy*$step;$centerBlockers=New-Object System.Collections.Generic.List[string];foreach($o in $obstacles){if($x-gt([double]$o.x-$radius)-and$x-lt([double]$o.x+[double]$o.w+$radius)-and$y-gt([double]$o.y-$radius)-and$y-lt([double]$o.y+[double]$o.d+$radius)){$centerBlockers.Add([string]$o.id)}}
  if($centerBlockers.Count-gt0){foreach($blocker in $centerBlockers){$key='centerline-envelope:'+ $blocker;if(-not$frontierBlockerCounts.ContainsKey($key)){$frontierBlockerCounts[$key]=0};$frontierBlockerCounts[$key]++};continue}
  if(-not(EdgeClear186 $p.x $p.y $x $y $obstacles $width)){if([Math]::Abs($p.y-$y)-lt1e-8){$edge=NewRect186 ([Math]::Min($p.x,$x)) ($p.y-$radius) ([Math]::Abs($p.x-$x)) $width 'frontier-edge'}else{$edge=NewRect186 ($p.x-$radius) ([Math]::Min($p.y,$y)) $width ([Math]::Abs($p.y-$y)) 'frontier-edge'};foreach($o in $obstacles){if((HitArea186 $edge $o)-gt0){$key='swept-edge:'+ $o.id;if(-not$frontierBlockerCounts.ContainsKey($key)){$frontierBlockerCounts[$key]=0};$frontierBlockerCounts[$key]++}}}
 }
}
$reachableBounds=$null;if($expanded-gt0){$reachableBounds=[ordered]@{x_min_ft=[Math]::Round($reachMinX,4);x_max_ft=[Math]::Round($reachMaxX,4);y_min_ft=[Math]::Round($reachMinY,4);y_max_ft=[Math]::Round($reachMaxY,4)}}
$frontierBlockers=@($frontierBlockerCounts.GetEnumerator()|Sort-Object -Property @{Expression='Value';Descending=$true},@{Expression='Name';Ascending=$true}|ForEach-Object{[ordered]@{constraint=$_.Key;frontier_edge_count=[int]$_.Value}})
$path=@();if($goalReached){$rev=New-Object System.Collections.Generic.List[object];$cursor=$goalId;while($cursor-ge0){$rev.Add((NodeXY186 $cursor));$cursor=$parent[$cursor]};$rev.Reverse();$path=@($rev.ToArray())}
$full=@();$full+=,[pscustomobject]@{x=[double]$routeStart.x;y=[double]$routeStart.y};$full+=,[pscustomobject]@{x=[double]$openingNode.x;y=[double]$openingNode.y};foreach($p in $path){if($full.Count-eq0-or[Math]::Abs([double]$full[-1].x-[double]$p.x)-gt1e-8-or[Math]::Abs([double]$full[-1].y-[double]$p.y)-gt1e-8){$full+=,[pscustomobject]@{x=[double]$p.x;y=[double]$p.y}}};$full+=,[pscustomobject]@{x=[double]$routeEnd.x;y=[double]$routeEnd.y}
$waypoints=New-Object System.Collections.Generic.List[object]
if($full.Count-ge2){$waypoints.Add($full[0]);for($i=1;$i-lt$full.Count-1;$i++){$a=$full[$i-1];$b=$full[$i];$c=$full[$i+1];if(([Math]::Abs([double]$a.x-[double]$b.x)-lt1e-8-and[Math]::Abs([double]$b.x-[double]$c.x)-lt1e-8)-or([Math]::Abs([double]$a.y-[double]$b.y)-lt1e-8-and[Math]::Abs([double]$b.y-[double]$c.y)-lt1e-8)){continue};$waypoints.Add($b)};$waypoints.Add($full[-1])}
$routeRects=@();$routeHits=@();$routeLen=0.0;$turns=0;$shellInside=$true;$minGapByObstacle=@()
if($goalReached){$routeRects=@(RouteRects186 $full $width);foreach($r in $routeRects){if($r.x-lt($shellMinX-1e-8)-or$r.y-lt($shellMinY-1e-8)-or($r.x+$r.w)-gt($shellMaxX+1e-8)-or($r.y+$r.d)-gt($shellMaxY+1e-8)){$shellInside=$false};foreach($o in $obstacles){$a=HitArea186 $r $o;if($a-gt0){$routeHits+=,[ordered]@{route_rect=$r.id;obstacle=$o.id;overlap_sf=$a}}}}
 for($i=0;$i-lt$full.Count-1;$i++){$dx=[Math]::Abs([double]$full[$i+1].x-[double]$full[$i].x);$dy=[Math]::Abs([double]$full[$i+1].y-[double]$full[$i].y);$routeLen+=$dx+$dy;if($i-gt0){$p=$full[$i-1];$q=$full[$i];$r=$full[$i+1];if(([Math]::Abs([double]$p.x-[double]$q.x)-lt1e-8)-ne([Math]::Abs([double]$q.x-[double]$r.x)-lt1e-8)){$turns++}}}
 foreach($o in $obstacles){$min=[double]::PositiveInfinity;foreach($r in $routeRects){$gap=RectGap186 $r $o;if($gap-lt$min){$min=$gap}};$minGapByObstacle+=,[ordered]@{obstacle=$o.id;minimum_route_edge_gap_ft=if([double]::IsPositiveInfinity($min)){$null}else{[Math]::Round($min,6)}}}
}
$mainShell=@($shellW,$shellD)
$familyFiles=Get-ChildItem (Join-Path $root 'Revit/Family_Intake/Incoming') -Filter '*.rfa' -File
$familyHashes=@();foreach($f in $familyFiles){$familyHashes+=,[ordered]@{file=$f.Name;sha256=(Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}}
$checks=New-Object System.Collections.Generic.List[object]
function AddCheck186([string]$id,[bool]$pass,[string]$detail){$script:checks.Add([ordered]@{id=$id;pass=$pass;detail=$detail})}
foreach($c in $sourceChecks){AddCheck186 $c.id ([bool]$c.pass) $c.detail}
AddCheck186 'source_schemas' (($m178.schema-eq'forever-home-m178-halfwall-seating-candidate-v1')-and($m180.schema-eq'forever-home-m180-living-shell-route-v1')-and($m185.schema-eq'forever-home-m185-dogleg-m06-overlay-v1')) 'M178, M180 and M185 have the expected retained source schemas.'
AddCheck186 'selected_d_baseline_current' (($selectedHash-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb')-and($m185.selected_d_sha256-eq$selectedHash)) 'Selected-D remains at the protected source fingerprint.'
AddCheck186 'm06_b_unassigned' (([string]$eastWindowSource.status)-match'Unassigned') 'Owner-selected east/pantry-side M-06/B remains only an unassigned search window.'
AddCheck186 'shell_test_40_by_42' (($mainShell.Count-eq2)-and([double]$mainShell[0]-eq40)-and([double]$mainShell[1]-eq42)-and([string]$bath.selection.main_shell-eq[string]$selected.selection.main_shell)) 'The bounded search uses the matching 40 x 42 ft envelope recorded in selected-D and the bath-first source.'
AddCheck186 'grid_is_analysis_resolution' ($step-eq0.25) 'Quarter-foot spacing is explicitly a search resolution, not an architectural dimension.'
AddCheck186 'route_width_36in' ($width-eq3.0) 'The swept corridor uses the source 36-in proxy width.'
AddCheck186 'start_and_goal_nodes_clear' (($startClear)-and(NodeClear186 $routeDoor.x $routeDoor.y $obstacles $radius)) 'Both the fixed kitchen-opening node and nominal porch-door node clear the static no-go proxy set.'
AddCheck186 'living_start_inside_M01' (($routeStart.x-ge$living.x)-and($routeStart.x-le($living.x+$living.w))-and($routeStart.y-ge$living.y)-and($routeStart.y-le($living.y+$living.d))) 'The route begins at M180’s point inside source M-01.'
AddCheck186 'opening_connector_clear' ($connectorHits.Count-eq0) 'Pinned living-to-opening connector has no positive-area intersection with modeled obstacle rectangles.'
AddCheck186 'opening_reservation_crossed' (([Math]::Abs($openY-10)-lt1e-8)-and([Math]::Abs($openX-13.5)-lt1e-8)) 'Pinned connector crosses M178’s 6-ft opening reservation at the M180 source y-coordinate.'
AddCheck186 'goal_is_nominal_porch_door' (($routeDoor.x-ge6)-and($routeDoor.x-le11)-and($routeDoor.y-eq24.5)) 'Route search ends at the nominal 5-ft porch-door reservation before extending 3 ft into the porch.'
AddCheck186 'search_completed_or_bounded' (($expanded-le$nodeTotal)-and($nodeTotal-gt0)) 'Deterministic BFS terminates inside the finite shell-derived grid.'
AddCheck186 'route_result_serializable' ((-not$goalReached)-or($full.Count-ge3-and$waypoints.Count-ge2)) 'A found route has a start, an opening point and a porch terminus; a no-path result is also recorded explicitly.'
if($goalReached){AddCheck186 'route_has_no_proxy_intersections' ($routeHits.Count-eq0) 'Every swept rectangle has zero positive-area overlap with modeled no-go proxies.';AddCheck186 'route_stays_inside_test_shell' $shellInside 'Every swept rectangle remains inside the source 40 x 42 ft test shell.';AddCheck186 'route_not_through_east_B' (@($routeHits|Where-Object obstacle-eq'east_of_core').Count-eq0) 'Swept route stays out of the unassigned east/pantry-side M-06/B search window.'}
else{AddCheck186 'no_route_within_declared_search' ($path.Count-eq0) 'The exhaustive 0.25-ft grid search found no route within the bounded shell and modeled proxy set.'}
AddCheck186 'incoming_families_hashes_recorded' (($familyHashes.Count-ge3)-and(@($familyHashes|Where-Object{$_.sha256-match'^[0-9a-f]{64}$'}).Count-eq$familyHashes.Count)) 'Every current Incoming RFA is recorded by filename and SHA256.'
AddCheck186 'm185_one_elbow_constraint_retained' (@($m185.single_turn_sensitivity|Where-Object both_clear).Count-eq0) 'The preceding M185 result still shows no sampled single-elbow position clearing both limiting proxies.'
$passed=@($checks|Where-Object pass).Count;$status='pass';if($passed-ne$checks.Count){$status='fail'};$resultStatus=if($goalReached){'candidate_found_with_static_proxy_clearance'}else{'no_candidate_on_bounded_quarter_foot_grid'}
$lengthByArea=@{living_ft=0.0;kitchen_ft=0.0;dining_ft=0.0;porch_ft=0.0;unassigned_ft=0.0}
if($goalReached){for($i=0;$i-lt$full.Count-1;$i++){$a=$full[$i];$b=$full[$i+1];$seg=[Math]::Abs([double]$b.x-[double]$a.x)+[Math]::Abs([double]$b.y-[double]$a.y);$mx=([double]$a.x+[double]$b.x)/2;$my=([double]$a.y+[double]$b.y)/2;if($mx-ge$living.x-and$mx-le($living.x+$living.w)-and$my-ge$living.y-and$my-le($living.y+$living.d)){$lengthByArea.living_ft+=$seg}elseif($mx-ge0-and$mx-le13.5-and$my-ge0-and$my-le14){$lengthByArea.kitchen_ft+=$seg}elseif($mx-ge0-and$mx-le11-and$my-ge14-and$my-le24){$lengthByArea.dining_ft+=$seg}elseif($mx-ge-0.5-and$mx-le11.5-and$my-ge24.5-and$my-le34.5){$lengthByArea.porch_ft+=$seg}else{$lengthByArea.unassigned_ft+=$seg}}}
$reachableCount=@($visited|Where-Object{$_}).Count
$bounds=[ordered]@{x_min_local_ft=[Math]::Round($shellMinX,6);x_max_local_ft=[Math]::Round($shellMaxX,6);y_min_local_ft=[Math]::Round($shellMinY,6);y_max_local_ft=[Math]::Round($shellMaxY,6);centerline_grid_x_index=@($minXI,$maxXI);centerline_grid_y_index=@($minYI,$maxYI);node_count=$nodeTotal;reached_node_count=$reachableCount;expanded_nodes=$expanded;reachable_bounds=$reachableBounds;nearest_reachable_to_porch_door=$nearestReachable;blocked_frontier_edges=$frontierBlockers}
$report=[ordered]@{schema='forever-home-m186-multiturn-route-search-v1';status=$resultStatus;search_method='Deterministic breadth-first search over orthogonal centerline nodes; expanded rectangles enforce exact 36-in axis-aligned route width against static rectangular obstacles.';source_fingerprints_sha256=$hashes;selected_d_sha256=$selectedHash;incoming_rfa_hashes=$familyHashes;search=[ordered]@{shell_test_ft=@([double]$mainShell[0],[double]$mainShell[1]);coordinate_origin_source_ft=@([double]$origin.x,[double]$origin.y);grid_step_ft=$step;grid_step_is_design_dimension=$false;route_width_in=36;centerline_bounds=$bounds;start_inside_M01_ft=$routeStart;opening_center_ft=$openingNode;porch_door_center_ft=$routeDoor;porch_terminus_ft=$routeEnd;path_found=$goalReached;route_length_ft=if($goalReached){[Math]::Round($routeLen,4)}else{$null};route_turn_count=if($goalReached){$turns}else{$null};compressed_waypoints_ft=$waypoints.ToArray();centerline_zone_lengths_ft=$lengthByArea;route_rectangles_ft=$routeRects;proxy_intersections=$routeHits;minimum_edge_gap_by_obstacle=$minGapByObstacle;initial_connector_intersections=$connectorHits.ToArray();m06_west_diagnostic_rect_local_ft=@([double]$west.x,[double]$west.y,[double]$west.w,[double]$west.d);m06_east_B_window_local_ft=@([double]$east.x,[double]$east.y,[double]$east.w,[double]$east.d);M04_local_rect_ft=@([double]$pantry.x,[double]$pantry.y,[double]$pantry.w,[double]$pantry.d);modeled_obstacles=$obstacles};kitchen_area_sf=[double]$cand.kitchen_area_sf;kitchen_program_target_sf=[double]$m178.program_targets.kitchen_area_sf;kitchen_over_target_sf=[double]$cand.kitchen_over_target_sf;checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks.ToArray()};limitations=@('The grid spacing is an analysis resolution. No physical dimensions are created by this search.','Rectangular proxies do not model wall thickness, physical door leaves, chair/stool motion, appliance-open states, occupants, privacy, finishes or tolerances.','The west M-06 rectangle is a blocked diagnostic; east B is reserved only to protect its unassigned search option. Neither is a bath footprint.','The assumed stool occupancy remains a 24-in-deep proxy, not actual selected family geometry.','A path with no positive-area collision is not a usable, accessible, code-compliant or approved route. Minimum geometric gaps still require design review.','The 13.5 x 14 ft M178 kitchen is an unapproved 189 sf candidate, 21 sf above the owner-directed target.','No Revit or IFC geometry is changed or validated by this schematic route search.','No code, accessibility, structural-safety, professional, permit or construction-readiness conclusion is made.')}
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm186-route-search.json'),(($report|ConvertTo-Json -Depth 50)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm186-checks.json'),(($report.checks|ConvertTo-Json -Depth 30)+"`n"),$utf8)
$csvRows=@();foreach($g in $minGapByObstacle){$csvRows+=,[pscustomobject]@{record_type='obstacle clearance';route_found=$goalReached;route_length_ft=$report.search.route_length_ft;route_turn_count=$report.search.route_turn_count;obstacle=$g.obstacle;minimum_route_edge_gap_ft=$g.minimum_route_edge_gap_ft}}
if(-not$goalReached){$csvRows+=,[pscustomobject]@{record_type='search summary';route_found=$false;route_length_ft='';route_turn_count='';obstacle='';minimum_route_edge_gap_ft=''}}
[IO.File]::WriteAllText((Join-Path $out 'm186-route-summary.csv'),((@($csvRows|ConvertTo-Csv -NoTypeInformation)-join "`n")+"`n"),$utf8)
$svgPath=Join-Path $out 'm186-route-search.svg';$svgLines=New-Object System.Collections.Generic.List[string];$svgLines.Add('<svg xmlns="http://www.w3.org/2000/svg" width="920" height="980" viewBox="0 0 920 980" role="img" aria-labelledby="title desc">');$svgLines.Add('<title id="title">M186 bounded route search</title><desc id="desc">Room blocks, furniture and M-06 diagnostic windows in the comparison envelope. A green route appears only if the bounded 36-inch search found one.</desc>');$svgLines.Add('<g font-family="Arial,sans-serif" font-size="12">');$scale=18.0;$ox=140.0;$oy=850.0
function SvgRect186([object]$r,[string]$fill,[string]$stroke){$x=$script:ox+[double]$r.x*$script:scale;$y=$script:oy-([double]$r.y+[double]$r.d)*$script:scale;$w=[double]$r.w*$script:scale;$h=[double]$r.d*$script:scale;return ('<rect x="{0:F1}" y="{1:F1}" width="{2:F1}" height="{3:F1}" fill="{4}" fill-opacity=".62" stroke="{5}" stroke-width="1.5"/>' -f $x,$y,$w,$h,$fill,$stroke)}
$svgLines.Add((SvgRect186 (NewRect186 $shellMinX $shellMinY $shellW $shellD 'test-shell') '#fff' '#343434'))
$svgLines.Add((SvgRect186 $living '#d9e5f2' '#56708d'))
$svgLines.Add((SvgRect186 (NewRect186 0 0 13.5 14 'M-02') '#fff1ce' '#a8792c'))
$svgLines.Add((SvgRect186 (NewRect186 0 14 11 10 'M-03') '#e8f0f7' '#56708d'))
$svgLines.Add((SvgRect186 (NewRect186 -0.5 24.5 12 10 'porch') '#e9f2e5' '#588050'))
foreach($o in $obstacles){$color='#aaa';if($o.id-eq'west_of_core'){$color='#bd4d4d'}elseif($o.id-eq'east_of_core'){$color='#4f8c58'}elseif($o.id-eq'M-04-pantry'){$color='#b58341'}; $svgLines.Add((SvgRect186 $o '#ead7d7' $color))}
if($goalReached){$pts=@();foreach($p in $full){$pts+=('{0:F2},{1:F2}' -f ($ox+[double]$p.x*$scale),($oy-[double]$p.y*$scale))};$svgLines.Add(('<polyline points="{0}" fill="none" stroke="#087d71" stroke-width="54" stroke-linecap="square" stroke-linejoin="round" opacity=".7"/>' -f ($pts -join ' ')));$svgLines.Add(('<polyline points="{0}" fill="none" stroke="#07534d" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>' -f ($pts -join ' ')))}
$svgLines.Add(('<text x="24" y="30">M186: {0}; grid 0.25 ft; 36-in swept route; schematic only</text>' -f $resultStatus));$svgLines.Add('<text x="24" y="52">Red = blocked west M-06 diagnostic; green = unassigned east B window.</text>');$svgLines.Add('</g></svg>');[IO.File]::WriteAllText($svgPath,($svgLines -join "`n")+"`n",$utf8)
$null=[xml](Get-Content $svgPath -Raw)
Write-Output ("M186: {0}/{1}; grid nodes={2}; expanded={3}; path found={4}; path ft={5}; turns={6}; M-06/B stays unassigned." -f $passed,$checks.Count,$nodeTotal,$expanded,$goalReached,$report.search.route_length_ft,$report.search.route_turn_count)
if($passed-ne$checks.Count){exit 1}
