param(
    [string]$OutputDirectory='Architecture/M204_M06A_Door_Alignment_2026-10-31/artifacts',
    [string]$ScratchPrefix='M204'
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
$m203Rel='Architecture/M203_M06A_Circulation_Tradeoff_2026-10-31/artifacts/m203-m06a-circulation-tradeoff.json'
$specRel='Architecture/Kitchen_Dining_Porch_Specs.md'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$sourceRels=@($baseRel,$m178Rel,$m187Rel,$m195Rel,$m198Rel,$m202Rel,$m203Rel,$specRel,$selectedRel,$bathRel,'Decisions/2026-10-31_Kitchen_Area_Priority.md','Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md')
function Hash204([string]$rel){(Get-FileHash -LiteralPath (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$hashes=[ordered]@{};foreach($rel in $sourceRels){$hashes[$rel]=Hash204 $rel}
if($hashes[$selectedRel]-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M204.'}
$m178=Get-Content (Join-Path $root $m178Rel) -Raw|ConvertFrom-Json
$m187=Get-Content (Join-Path $root $m187Rel) -Raw|ConvertFrom-Json
$m195=Get-Content (Join-Path $root $m195Rel) -Raw|ConvertFrom-Json
$m198=Get-Content (Join-Path $root $m198Rel) -Raw|ConvertFrom-Json
$m202=Get-Content (Join-Path $root $m202Rel) -Raw|ConvertFrom-Json
$m203=Get-Content (Join-Path $root $m203Rel) -Raw|ConvertFrom-Json
$bath=Get-Content (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$westA=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'west_of_core')[0]
$eastB=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
if([string]$eastB.status -notmatch 'Unassigned'){throw 'M-06/B is not in the expected unassigned source state.'}
if([bool]$m202.opening_case.route_found-or[bool]$m203.tradeoff.route_found){throw 'M202/M203 baseline changed; review before M204.'}
if(@($m195.candidate_placements|Where-Object case -eq 'centered_table').Count-ne1){throw 'M195 centered-table source case changed.'}
$doorSamples=@(2.0,5.5,9.0)
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
$pairs=@(@($oldOpenX,'open start x'),@($oldOpenY,'open start y'),@($oldObstacles,'obstacle list'),@($oldTable,'table'),@($oldChairs,'chairs'),@($oldWalls,'porch walls'),@($oldDoor,'door'),@($oldEnd,'porch end'),@($oldGoal,'goal'))
foreach($pair in $pairs){if(([regex]::Matches($base,[regex]::Escape([string]$pair[0]))).Count-ne1){throw "M186 source changed at $($pair[1]); refusing unreviewed transform."}}
$openingPattern="(?m)^AddCheck186 'opening_reservation_crossed'.*$"
if(([regex]::Matches($base,$openingPattern)).Count-ne1){throw 'M186 opening check changed; inspect before M204.'}
$runs=New-Object System.Collections.Generic.List[object]
$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m204-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
$utf8=New-Object Text.UTF8Encoding($false)
try{
 foreach($doorX in $doorSamples){
  $table="`$table=NewRect186 3.5 15.5 3 5 'rotated-36x60-table'"
  $chairs="`$chairs=@((NewRect186 1.8333333333 16 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.8333333333 18.5 1.6666666667 1.5 'west-chair-2'),(NewRect186 6.5 16 1.6666666667 1.5 'east-chair-1'),(NewRect186 6.5 18.5 1.6666666667 1.5 'east-chair-2'))`n`$pullouts=@((NewRect186 .5 16 3 1.5 'west-chair-1-use-36in'),(NewRect186 .5 18.5 3 1.5 'west-chair-2-use-36in'),(NewRect186 6.5 16 3 1.5 'east-chair-1-use-36in'),(NewRect186 6.5 18.5 3 1.5 'east-chair-2-use-36in'))"
  $walls="`$porchWalls=@((NewRect186 -0.5 24.5 $($doorX-2) 0.5 'porch-wall-west-of-door'),(NewRect186 $($doorX+2.5) 24.5 $(9-$doorX) 0.5 'porch-wall-east-of-door'))"
  # West A is released as a trade-off; B and all other proxies are retained.
  $obstacles="`$obstacles=@(`$entry,`$pantry,`$east,`$counter,`$island,`$stools,`$table)+`$chairs+`$pullouts+`$porchWalls"
  $door="`$routeDoor=[pscustomobject]@{x=$doorX;y=24.5}`n`$expectedDoorX=$doorX"
  $end="`$routeEnd=[pscustomobject]@{x=$doorX;y=27.5}"
  $goal="AddCheck186 'goal_is_allowed_porch_face_sample' (([Math]::Abs(`$routeDoor.x-`$expectedDoorX)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-24.5)-lt1e-8)-and(`$expectedDoorX-ge2)-and(`$expectedDoorX-le9)) 'The five-foot opening is fully within the 12-ft porch face.'"
  $openCheck="AddCheck186 'fully_open_starts_inside_living' (([Math]::Abs(`$openingNode.x-`$routeStart.x)-lt1e-8)-and([Math]::Abs(`$openingNode.y-`$routeStart.y)-lt1e-8)) 'The route starts in M-01 with the half-wall/return removed.'"
  $generated=$base.Replace($oldOpenX,'$openX=[double]$routeStart.x').Replace($oldOpenY,'$openY=[double]$routeStart.y').Replace($oldObstacles,$obstacles).Replace($oldTable,$table).Replace($oldChairs,$chairs).Replace($oldWalls,$walls).Replace($oldDoor,$door).Replace($oldEnd,$end).Replace($oldGoal,$goal)
  $generated=[regex]::Replace($generated,$openingPattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m)$openCheck},1)
  $key=$doorX.ToString('0.0').Replace('.','p');$sub='.local/revalidation/'+$ScratchPrefix+'-door-'+$key;$full=Join-Path $root $sub
  if((Test-Path -LiteralPath $full)-and @(Get-ChildItem -LiteralPath $full -Force).Count-gt0){throw "Refusing to overwrite candidate scratch: $full"}
  [IO.File]::WriteAllText($temp,$generated,$utf8);& $temp -OutputDirectory $sub
  $r=Get-Content (Join-Path $full 'm186-route-search.json') -Raw|ConvertFrom-Json
  $runs.Add([pscustomobject]@{door_center_x_ft=$doorX;path_found=[bool]$r.search.path_found;route_length_ft=$r.search.route_length_ft;route_turns=$r.search.route_turn_count;waypoints_ft=$r.search.compressed_waypoints_ft;reachable_nodes=$r.search.centerline_bounds.reached_node_count;nearest_to_door_ft=$r.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;checks_passed=$r.checks.passed;checks_total=$r.checks.total;M06_B_status=[string]$eastB.status;modeled_obstacles=$r.search.modeled_obstacles;route_rectangles_ft=$r.search.route_rectangles_ft;centerline_zone_lengths_ft=$r.search.centerline_zone_lengths_ft;minimum_edge_gap_by_obstacle=$r.search.minimum_edge_gap_by_obstacle})
 }
}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}
function UnionHitArea204([object[]]$rectangles,[object]$target){$xs=New-Object System.Collections.Generic.List[double];$xs.Add([double]$target.x);$xs.Add(([double]$target.x+[double]$target.w));foreach($r in $rectangles){$x0=[Math]::Max([double]$target.x,[double]$r.x);$x1=[Math]::Min(([double]$target.x+[double]$target.w),([double]$r.x+[double]$r.w));if($x1-gt$x0){$xs.Add($x0);$xs.Add($x1)}};$ordered=@($xs|Sort-Object -Unique);$area=0.0;for($i=0;$i-lt$ordered.Count-1;$i++){$x0=[double]$ordered[$i];$x1=[double]$ordered[$i+1];if($x1-le$x0){continue};$xm=($x0+$x1)/2;$ys=New-Object System.Collections.Generic.List[object];foreach($r in $rectangles){if($xm-gt$r.x-and$xm-lt($r.x+$r.w)){$y0=[Math]::Max([double]$target.y,[double]$r.y);$y1=[Math]::Min(([double]$target.y+[double]$target.d),([double]$r.y+[double]$r.d));if($y1-gt$y0){$ys.Add([pscustomobject]@{a=$y0;b=$y1})}}};$iv=@($ys|Sort-Object a);if($iv.Count){$lo=[double]$iv[0].a;$hi=[double]$iv[0].b;$cover=0.0;for($j=1;$j-lt$iv.Count;$j++){if([double]$iv[$j].a-le$hi){$hi=[Math]::Max($hi,[double]$iv[$j].b)}else{$cover+=$hi-$lo;$lo=[double]$iv[$j].a;$hi=[double]$iv[$j].b}};$cover+=$hi-$lo;$area+=($x1-$x0)*$cover}};return [Math]::Round($area,6)}
$aRect=[pscustomobject]@{x=[double]$westA.x-.6666666666666666;y=[double]$westA.y-.6666666666666666;w=[double]$westA.w;d=[double]$westA.d}
foreach($sample in $runs){$sample|Add-Member -NotePropertyName M06_A_route_union_overlap_sf -NotePropertyValue $(if($sample.path_found){UnionHitArea204 @($sample.route_rectangles_ft) $aRect}else{0.0});$sample|Add-Member -NotePropertyName M06_A_status -NotePropertyValue 'Released only for this circulation sensitivity; not an assigned bathroom.'}
$checks=@(
 [pscustomobject]@{id='three_door_positions_tested';pass=($runs.Count-eq3-and[Math]::Abs($runs[0].door_center_x_ft-2)-lt1e-8-and[Math]::Abs($runs[1].door_center_x_ft-5.5)-lt1e-8-and[Math]::Abs($runs[2].door_center_x_ft-9)-lt1e-8);detail='West, centered and east five-foot door positions were tested.'},
 [pscustomobject]@{id='every_M186_contract_passes';pass=(@($runs|Where-Object{$_.checks_passed-ne$_.checks_total}).Count-eq0);detail='All generated full-shell route searches pass their contract checks.'},
 [pscustomobject]@{id='A_tradeoff_is_explicit';pass=(@($runs|Where-Object{$_.M06_A_status -notmatch 'Released'}).Count-eq0);detail='A is released only as a route sensitivity and never assigned as a bathroom.'},
 [pscustomobject]@{id='B_remains_unassigned';pass=([string]$eastB.status-match'Unassigned'-and@($runs|Where-Object M06_B_status -notmatch 'Unassigned').Count-eq0);detail='Pantry-side B remains unassigned and blocked in all route cases.'},
 [pscustomobject]@{id='selected_D_hash_protected';pass=($hashes[$selectedRel]-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Selected-D source fingerprint remains unchanged.'},
 [pscustomobject]@{id='door_positions_not_selected';pass=$true;detail='All tested centers remain sensitivity samples; no final door position is selected.'}
)
$passed=@($checks|Where-Object pass).Count;$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$first=@($runs|Where-Object path_found|Sort-Object door_center_x_ft|Select-Object -First 1)
$report=[ordered]@{schema='forever-home-m204-m06a-door-alignment-v1';status=$status;design_result=if($first.Count){'route_found_for_some_A_tradeoff_door_sample'}else{'no_route_in_west_center_east_A_tradeoff_samples'};method='Three porch-door center samples with fully open kitchen/living start and west diagnostic A released; B, pantry, entry, island, stool, dining and chair-use proxies remain.';source_fingerprints_sha256=$hashes;selected_d_sha256=$hashes[$selectedRel];M06_A_status='Released only for circulation sensitivity; unassigned, not a bath.';M06_B_status=[string]$eastB.status;door_samples=$runs;first_route_sample=if($first.Count){$first[0]}else{$null};checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('Only west, centered and east door positions are sampled; this is not an exhaustive door placement search.','A is an unassigned search option used as a separate circulation-versus-future-bath trade-off; B remains protected.','The existing 5-ft opening, room, furniture, stool-use, route and site geometries are proxies.','The kitchen/living band, physical doors/walls, thresholds, pantry openings, furniture movement and site conditions are not coordinated.','A path would not establish code, accessibility, structural, professional, permit or construction readiness. Revit, IFC, selected-D and Incoming RFA files are unchanged.')}
[IO.File]::WriteAllText((Join-Path $out 'm204-m06a-door-alignment.json'),(($report|ConvertTo-Json -Depth 50)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm204-checks.json'),(($report.checks|ConvertTo-Json -Depth 20)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm204-door-samples.csv'),((@($runs|Select-Object door_center_x_ft,path_found,route_length_ft,route_turns,reachable_nodes,nearest_to_door_ft,M06_A_route_union_overlap_sf,M06_A_status,M06_B_status|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
if($passed-ne$checks.Count){throw "M204 integrity failed $passed/$($checks.Count); see $out"}
Write-Output "M204 pass $passed/$($checks.Count); $(@($runs|Where-Object path_found).Count)/$($runs.Count) west/center/east A-tradeoff door positions find routes; B remains unassigned."
