param(
    [string]$OutputDirectory='Architecture/M203_M06A_Circulation_Tradeoff_2026-10-31/artifacts',
    [string]$ScratchPrefix='M203'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}

$baseRel='Tools/search_m186_public_route.ps1'
$m178Rel='Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json'
$m187Rel='Architecture/M187_Route_Sensitivity_2026-10-31/artifacts/m187-route-sensitivity.json'
$m195Rel='Architecture/M195_Social_Layout_Search_2026-10-31/artifacts/m195-social-layout-search.json'
$m198Rel='Architecture/M198_Porch_Door_Alignment_2026-10-31/artifacts/m198-porch-door-alignment.json'
$m202Rel='Architecture/M202_Fully_Open_Kitchen_Route_2026-10-31/artifacts/m202-fully-open-kitchen-route.json'
$specRel='Architecture/Kitchen_Dining_Porch_Specs.md'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$sourceRels=@($baseRel,$m178Rel,$m187Rel,$m195Rel,$m198Rel,$m202Rel,$specRel,$selectedRel,$bathRel,'Decisions/2026-10-31_Kitchen_Area_Priority.md','Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md')
function Hash203([string]$rel){(Get-FileHash -LiteralPath (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$hashes=[ordered]@{};foreach($rel in $sourceRels){$hashes[$rel]=Hash203 $rel}
if($hashes[$selectedRel]-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M203.'}
$m178=Get-Content (Join-Path $root $m178Rel) -Raw|ConvertFrom-Json
$m187=Get-Content (Join-Path $root $m187Rel) -Raw|ConvertFrom-Json
$m195=Get-Content (Join-Path $root $m195Rel) -Raw|ConvertFrom-Json
$m198=Get-Content (Join-Path $root $m198Rel) -Raw|ConvertFrom-Json
$m202=Get-Content (Join-Path $root $m202Rel) -Raw|ConvertFrom-Json
$bath=Get-Content (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$westA=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'west_of_core')[0]
$eastB=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
if([string]$eastB.status -notmatch 'Unassigned'){throw 'M-06/B is not in the expected unassigned source state.'}
if([bool]$m202.opening_case.route_found){throw 'M202 baseline changed; inspect before M203.'}
$priorA=@($m187.cases|Where-Object relaxation -eq 'west_diagnostic')[0]
if($null-eq$priorA-or-not[bool]$priorA.path_found){throw 'M187 west-A sensitivity changed; inspect before M203.'}
$door=@($m198.door_search.samples|Sort-Object nearest_to_door_ft|Select-Object -First 1)[0]
if($null-eq$door-or[Math]::Abs([double]$door.door_center_x_ft-9)-gt1e-8){throw 'M198 best-gap sample changed; inspect before M203.'}

$base=[IO.File]::ReadAllText((Join-Path $root $baseRel))
$oldOpenX='$openX=[double]$cand.halfwall_rect_ft[0]+[double]$cand.halfwall_rect_ft[2]'
$oldOpenY='$openY=[double]$m180.revised_route.opening_centerline_y_ft'
$oldObstacles="`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$halfwall,`$wallReturn,`$table)+`$chairs+`$porchWalls"
$oldTable="`$table=NewRect186 3 17.5 5 3 'dining-table'"
$oldChairs="`$chairs=@((NewRect186 3.5 15.8333333333 1.5 1.6666666667 'south-chair-1'),(NewRect186 6 15.8333333333 1.5 1.6666666667 'south-chair-2'),(NewRect186 1.3333333333 17.5 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.3333333333 19 1.6666666667 1.5 'west-chair-2'))"
$oldWalls="`$porchWalls=@((NewRect186 -0.5 24.5 6.5 0.5 'porch-wall-west-of-door'),(NewRect186 11 24.5 0.5 0.5 'porch-wall-east-of-door'))"
$oldDoor="`$routeDoor=[pscustomobject]@{x=8.5;y=24.5}"
$oldEnd="`$routeEnd=[pscustomobject]@{x=8.5;y=27.5}"
$oldGoal="AddCheck186 'goal_is_nominal_porch_door' ((`$routeDoor.x-ge6)-and(`$routeDoor.x-le11)-and(`$routeDoor.y-eq24.5)) 'Route search ends at the nominal 5-ft porch-door reservation before extending 3 ft into the porch.'"
$pairs=@(@($oldOpenX,'open-start x'),@($oldOpenY,'open-start y'),@($oldObstacles,'obstacle list'),@($oldTable,'dining table'),@($oldChairs,'chair set'),@($oldWalls,'porch walls'),@($oldDoor,'door'),@($oldEnd,'porch endpoint'),@($oldGoal,'door goal'))
foreach($pair in $pairs){if(([regex]::Matches($base,[regex]::Escape([string]$pair[0]))).Count-ne1){throw "M186 source changed at $($pair[1]); refusing unreviewed transform."}}
$openingPattern="(?m)^AddCheck186 'opening_reservation_crossed'.*$"
if(([regex]::Matches($base,$openingPattern)).Count-ne1){throw 'M186 opening check changed; inspect before M203.'}

$doorX=[double]$door.door_center_x_ft
$table="`$table=NewRect186 3.5 15.5 3 5 'rotated-36x60-table'"
$chairs="`$chairs=@((NewRect186 1.8333333333 16 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.8333333333 18.5 1.6666666667 1.5 'west-chair-2'),(NewRect186 6.5 16 1.6666666667 1.5 'east-chair-1'),(NewRect186 6.5 18.5 1.6666666667 1.5 'east-chair-2'))`n`$pullouts=@((NewRect186 .5 16 3 1.5 'west-chair-1-use-36in'),(NewRect186 .5 18.5 3 1.5 'west-chair-2-use-36in'),(NewRect186 6.5 16 3 1.5 'east-chair-1-use-36in'),(NewRect186 6.5 18.5 3 1.5 'east-chair-2-use-36in'))"
$walls="`$porchWalls=@((NewRect186 -0.5 24.5 7 0.5 'porch-wall-west-of-door'),(NewRect186 11.5 24.5 0 0.5 'porch-wall-east-of-door'))"
# Relax west A only; keep the east B window and every other fixed obstacle.
$obstacles="`$obstacles=@(`$entry,`$pantry,`$east,`$counter,`$island,`$stools,`$table)+`$chairs+`$pullouts+`$porchWalls"
$doorLine="`$routeDoor=[pscustomobject]@{x=$doorX;y=24.5}"
$endLine="`$routeEnd=[pscustomobject]@{x=$doorX;y=27.5}"
$goalLine="AddCheck186 'goal_is_eastmost_tested_porch_door' (([Math]::Abs(`$routeDoor.x-$doorX)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-24.5)-lt1e-8)) 'Route ends at the M198 best-gap five-foot door sensitivity, not a selected location.'"
$openCheck="AddCheck186 'fully_open_starts_inside_living' (([Math]::Abs(`$openingNode.x-`$routeStart.x)-lt1e-8)-and([Math]::Abs(`$openingNode.y-`$routeStart.y)-lt1e-8)) 'The route starts in source M-01 with no half-wall or return.'"
$generated=$base.Replace($oldOpenX,'$openX=[double]$routeStart.x').Replace($oldOpenY,'$openY=[double]$routeStart.y').Replace($oldObstacles,$obstacles).Replace($oldTable,$table).Replace($oldChairs,$chairs).Replace($oldWalls,$walls).Replace($oldDoor,$doorLine).Replace($oldEnd,$endLine).Replace($oldGoal,$goalLine)
$generated=[regex]::Replace($generated,$openingPattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m)$openCheck},1)
$sub='.local/revalidation/'+$ScratchPrefix+'-A-tradeoff';$full=Join-Path $root $sub
if((Test-Path -LiteralPath $full)-and @(Get-ChildItem -LiteralPath $full -Force).Count-gt0){throw "Refusing to overwrite route scratch: $full"}
$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m203-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
$utf8=New-Object Text.UTF8Encoding($false)
try{[IO.File]::WriteAllText($temp,$generated,$utf8);& $temp -OutputDirectory $sub;$route=Get-Content (Join-Path $full 'm186-route-search.json') -Raw|ConvertFrom-Json}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}

function UnionHitArea203([object[]]$rectangles,[object]$target){
 $xs=New-Object System.Collections.Generic.List[double];$xs.Add([double]$target.x);$xs.Add(([double]$target.x+[double]$target.w))
 foreach($r in $rectangles){$x0=[Math]::Max([double]$target.x,[double]$r.x);$x1=[Math]::Min(([double]$target.x+[double]$target.w),([double]$r.x+[double]$r.w));if($x1-gt$x0){$xs.Add($x0);$xs.Add($x1)}}
 $ordered=@($xs|Sort-Object -Unique);$area=0.0
 for($i=0;$i-lt$ordered.Count-1;$i++){$x0=[double]$ordered[$i];$x1=[double]$ordered[$i+1];if($x1-le$x0){continue};$xm=($x0+$x1)/2;$ys=New-Object System.Collections.Generic.List[object]
  foreach($r in $rectangles){if($xm-gt$r.x-and$xm-lt($r.x+$r.w)){$y0=[Math]::Max([double]$target.y,[double]$r.y);$y1=[Math]::Min(([double]$target.y+[double]$target.d),([double]$r.y+[double]$r.d));if($y1-gt$y0){$ys.Add([pscustomobject]@{a=$y0;b=$y1})}}}
  $iv=@($ys|Sort-Object a);if($iv.Count){$lo=[double]$iv[0].a;$hi=[double]$iv[0].b;$cover=0.0;for($j=1;$j-lt$iv.Count;$j++){if([double]$iv[$j].a-le$hi){$hi=[Math]::Max($hi,[double]$iv[$j].b)}else{$cover+=$hi-$lo;$lo=[double]$iv[$j].a;$hi=[double]$iv[$j].b}};$cover+=$hi-$lo;$area+=($x1-$x0)*$cover}
 }
 return [Math]::Round($area,6)
}
function CenterlineLengthIn203([object[]]$points,[object]$r){$length=0.0;for($i=0;$i-lt$points.Count-1;$i++){$a=$points[$i];$b=$points[$i+1];if([Math]::Abs([double]$a.y-[double]$b.y)-lt1e-8){if([double]$a.y-ge$r.y-and[double]$a.y-le($r.y+$r.d)){$length+=[Math]::Max(0.0,[Math]::Min([Math]::Max([double]$a.x,[double]$b.x),$r.x+$r.w)-[Math]::Max([Math]::Min([double]$a.x,[double]$b.x),$r.x))}}elseif([Math]::Abs([double]$a.x-[double]$b.x)-lt1e-8){if([double]$a.x-ge$r.x-and[double]$a.x-le($r.x+$r.w)){$length+=[Math]::Max(0.0,[Math]::Min([Math]::Max([double]$a.y,[double]$b.y),$r.y+$r.d)-[Math]::Max([Math]::Min([double]$a.y,[double]$b.y),$r.y))}}};return [Math]::Round($length,4)}
$aRect=[pscustomobject]@{x=[double]$westA.x-.6666666666666666;y=[double]$westA.y-.6666666666666666;w=[double]$westA.w;d=[double]$westA.d}
$aArea=if($route.search.path_found){UnionHitArea203 @($route.search.route_rectangles_ft) $aRect}else{0.0}
$aCenterline=if($route.search.path_found){CenterlineLengthIn203 @($route.search.compressed_waypoints_ft) $aRect}else{0.0}
$proxyGaps=@($route.search.minimum_edge_gap_by_obstacle|Where-Object{$_.obstacle -match 'island|stool|chair-use|dining-table'}|ForEach-Object{[double]$_.minimum_route_edge_gap_ft})
$minimumProxyGap=if($proxyGaps.Count){($proxyGaps|Measure-Object -Minimum).Minimum}else{$null}
$openReach=[double]$route.search.centerline_bounds.reached_node_count
$checks=@(
 [pscustomobject]@{id='only_west_A_released';pass=(@($route.search.modeled_obstacles|Where-Object {$_.id -eq 'west_of_core'}).Count-eq0-and@($route.search.modeled_obstacles|Where-Object {$_.id -eq 'east_of_core'}).Count-eq1);detail='The west diagnostic A is released for this sensitivity; east B remains a route obstacle.'},
 [pscustomobject]@{id='B_unassigned';pass=([string]$eastB.status -match 'Unassigned');detail='Pantry-side M-06/B remains unassigned.'},
 [pscustomobject]@{id='open_kitchen_living_start';pass=([Math]::Abs([double]$route.search.opening_center_ft.x-[double]$route.search.start_inside_M01_ft.x)-lt1e-8-and[Math]::Abs([double]$route.search.opening_center_ft.y-[double]$route.search.start_inside_M01_ft.y)-lt1e-8);detail='Search starts at the source living point with no half-wall or return.'},
 [pscustomobject]@{id='door_matches_M198_best_gap';pass=([Math]::Abs([double]$route.search.porch_door_center_ft.x-$doorX)-lt1e-8);detail='Five-foot door remains at the best-gap M198 sensitivity, not selected design.'},
 [pscustomobject]@{id='route_engine_contract_passes';pass=($route.checks.passed-eq$route.checks.total);detail='M186 completed every source and finite-grid contract check.'},
 [pscustomobject]@{id='selected_D_fingerprint_protected';pass=($hashes[$selectedRel]-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Selected-D remains at its protected source SHA256.'},
 [pscustomobject]@{id='A_use_measured_as_tradeoff';pass=($aArea-ge0-and$aCenterline-ge0);detail='Any route-area overlap and centerline length inside A are separately reported; A is not called a bathroom.'}
)
$passed=@($checks|Where-Object pass).Count;$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$result=if($route.search.path_found){'route_found_consuming_unassigned_A_tradeoff'}else{'no_route_even_with_A_released'}
$report=[ordered]@{schema='forever-home-m203-m06a-circulation-tradeoff-v1';status=$status;design_result=$result;method='One explicit trade-off releases only west diagnostic A from the M202 fully-open M186 route obstacle set; B, pantry, entry, casework, 8x4 island, assumed stool use, table/chairs/use zones and M198 best-gap five-foot door remain fixed.';source_fingerprints_sha256=$hashes;selected_d_sha256=$hashes[$selectedRel];tradeoff=[ordered]@{M06_A_status='Unassigned diagnostic window released for route sensitivity only; not an assigned bathroom.';M06_A_route_union_overlap_sf=$aArea;route_centerline_length_inside_A_ft=$aCenterline;M06_B_status=[string]$eastB.status;B_remains_obstacle=$true;kitchen_dimensions_ft=@(13.5,14);kitchen_area_sf=189;island_dimensions_ft=@(8,4);door_center_x_ft=$doorX;door_width_ft=5;route_found=[bool]$route.search.path_found;route_length_ft=$route.search.route_length_ft;route_turns=$route.search.route_turn_count;waypoints_ft=$route.search.compressed_waypoints_ft;reachable_nodes=$route.search.centerline_bounds.reached_node_count;nearest_to_door_ft=$route.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;minimum_modeled_proxy_gap_ft=$minimumProxyGap;proxy_gaps=$route.search.minimum_edge_gap_by_obstacle;unassigned_travel_ft=$route.search.centerline_zone_lengths_ft.unassigned_ft;proxy_intersections=$route.search.proxy_intersections};m186_checks=[ordered]@{passed=$route.checks.passed;total=$route.checks.total;status=$route.checks.status};checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('A is an unassigned search window, not a bathroom. A route using it is a circulation-versus-future-bath trade-off, not an approved plan.','The route and room/furniture/stool-use objects are rectangular proxies; no physical wall, opening, fixture, door swing, threshold, appliance operation or site route is modeled.','The unassigned kitchen/living band remains unresolved; a passed route would not assign that band or validate a physical connection.','The assumed stool body/use envelope is not measured family geometry; no positive margin proves a usable path.','No code/accessibility, structural, professional, permit or construction-readiness conclusion follows. Revit, IFC, selected-D and Incoming RFA sources are unchanged.')}
[IO.File]::WriteAllText((Join-Path $out 'm203-m06a-circulation-tradeoff.json'),(($report|ConvertTo-Json -Depth 50)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm203-checks.json'),(($report.checks|ConvertTo-Json -Depth 20)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm203-route-summary.csv'),((@([pscustomobject]@{result=$result;route_found=$route.search.path_found;route_length_ft=$route.search.route_length_ft;turns=$route.search.route_turn_count;nearest_to_door_ft=$route.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;A_union_overlap_sf=$aArea;route_centerline_inside_A_ft=$aCenterline;minimum_proxy_gap_ft=$minimumProxyGap;unassigned_travel_ft=$route.search.centerline_zone_lengths_ft.unassigned_ft;M06_B_status=$eastB.status}|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
if($passed-ne$checks.Count){throw "M203 integrity failed $passed/$($checks.Count); see $out"}
Write-Output "M203 pass $passed/$($checks.Count); route=$($route.search.path_found); A overlap=$aArea sf; B remains unassigned."
