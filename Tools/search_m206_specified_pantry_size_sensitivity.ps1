param(
    [string]$OutputDirectory='Architecture/M206_Pantry_Location_Sensitivity_2026-10-31/artifacts',
    [string]$ScratchPrefix='M206'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}

$baseRel='Tools/search_m186_public_route.ps1'
$m204Rel='Architecture/M204_M06A_Door_Alignment_2026-10-31/artifacts/m204-m06a-door-alignment.json'
$m178Rel='Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json'
$m202Rel='Architecture/M202_Fully_Open_Kitchen_Route_2026-10-31/artifacts/m202-fully-open-kitchen-route.json'
$m203Rel='Architecture/M203_M06A_Circulation_Tradeoff_2026-10-31/artifacts/m203-m06a-circulation-tradeoff.json'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$specRel='Architecture/Kitchen_Dining_Porch_Specs.md'
$sourceRels=@($baseRel,$m204Rel,$m178Rel,$m202Rel,$m203Rel,$selectedRel,$bathRel,$specRel,'Decisions/2026-10-31_Kitchen_Area_Priority.md','Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md')
function Hash205([string]$rel){(Get-FileHash -LiteralPath (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$hashes=[ordered]@{};foreach($rel in $sourceRels){$hashes[$rel]=Hash205 $rel}
if($hashes[$selectedRel]-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D source fingerprint changed; refusing M206.'}
$m204=Get-Content (Join-Path $root $m204Rel) -Raw|ConvertFrom-Json
$m202=Get-Content (Join-Path $root $m202Rel) -Raw|ConvertFrom-Json
$m203=Get-Content (Join-Path $root $m203Rel) -Raw|ConvertFrom-Json
if($m204.status-ne'pass'-or@($m204.door_samples|Where-Object path_found).Count-gt0){throw 'M204 expected no-route baseline changed.'}
if([bool]$m202.opening_case.route_found-or[bool]$m203.tradeoff.route_found){throw 'M202/M203 no-route baseline changed.'}
$bath=Get-Content (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$eastB=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
if([string]$eastB.status -notmatch 'Unassigned'){throw 'M-06/B is no longer explicitly unassigned.'}
$base=[IO.File]::ReadAllText((Join-Path $root $baseRel))
$oldOpenX='$openX=[double]$cand.halfwall_rect_ft[0]+[double]$cand.halfwall_rect_ft[2]'
$oldOpenY='$openY=[double]$m180.revised_route.opening_centerline_y_ft'
$oldPantry='$pantry=NewRect186 ([double]$pantrySource.x-[double]$origin.x) ([double]$pantrySource.y-[double]$origin.y) ([double]$pantrySource.w) ([double]$pantrySource.d) ''M-04-pantry'''
$oldObstacles="`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$halfwall,`$wallReturn,`$table)+`$chairs+`$porchWalls"
$oldTable="`$table=NewRect186 3 17.5 5 3 'dining-table'"
$oldChairs="`$chairs=@((NewRect186 3.5 15.8333333333 1.5 1.6666666667 'south-chair-1'),(NewRect186 6 15.8333333333 1.5 1.6666666667 'south-chair-2'),(NewRect186 1.3333333333 17.5 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.3333333333 19 1.6666666667 1.5 'west-chair-2'))"
$oldWalls="`$porchWalls=@((NewRect186 -0.5 24.5 6.5 0.5 'porch-wall-west-of-door'),(NewRect186 11 24.5 0.5 0.5 'porch-wall-east-of-door'))"
$oldDoor="`$routeDoor=[pscustomobject]@{x=8.5;y=24.5}"
$oldEnd="`$routeEnd=[pscustomobject]@{x=8.5;y=27.5}"
$oldGoal="AddCheck186 'goal_is_nominal_porch_door' ((`$routeDoor.x-ge6)-and(`$routeDoor.x-le11)-and(`$routeDoor.y-eq24.5)) 'Route search ends at the nominal 5-ft porch-door reservation before extending 3 ft into the porch.'"
$pairs=@(@($oldOpenX,'open start x'),@($oldOpenY,'open start y'),@($oldPantry,'pantry source assignment'),@($oldObstacles,'obstacle set'),@($oldTable,'table'),@($oldChairs,'chairs'),@($oldWalls,'porch walls'),@($oldDoor,'door'),@($oldEnd,'porch terminus'),@($oldGoal,'goal check'))
foreach($pair in $pairs){if(([regex]::Matches($base,[regex]::Escape([string]$pair[0]))).Count-ne1){throw "M186 source changed at $($pair[1]); refusing M206 transform."}}
$openingPattern="(?m)^AddCheck186 'opening_reservation_crossed'.*$"
if(([regex]::Matches($base,$openingPattern)).Count-ne1){throw 'M186 opening check changed; inspect before M206.'}

# M04 in the bath-first route source is 5 x 7 ft (35 sf); the kitchen specification is 5 x 6 ft (30 sf).
# M206 tests the documented 5 x 6 ft target while preserving and reporting the source mismatch.
$cases=@(
 [pscustomobject]@{id='current';pantry_x=11.8333333333333;pantry_y=16.5;dining_shift_x=0.0;shared_kitchen_edge_ft=0.0},
 [pscustomobject]@{id='north_edge_30in';pantry_x=11.0;pantry_y=14.0;dining_shift_x=0.0;shared_kitchen_edge_ft=2.5},
 [pscustomobject]@{id='north_edge_36in';pantry_x=10.5;pantry_y=14.0;dining_shift_x=-0.5;shared_kitchen_edge_ft=3.0}
)
$origin=@($bath.plans.main|Where-Object id -eq 'M-02')[0]
$aSource=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'west_of_core')[0]
$aRect=[pscustomobject]@{x=[double]$aSource.x-[double]$origin.x;y=[double]$aSource.y-[double]$origin.y;w=[double]$aSource.w;d=[double]$aSource.d}
function Overlap206([double]$x0,[double]$y0,[double]$w0,[double]$d0,[double]$x1,[double]$y1,[double]$w1,[double]$d1){
 $dx=[Math]::Min(($x0+$w0),($x1+$w1))-[Math]::Max($x0,$x1);$dy=[Math]::Min(($y0+$d0),($y1+$d1))-[Math]::Max($y0,$y1)
 if($dx-lt0){$dx=0};if($dy-lt0){$dy=0};return ($dx*$dy)
}
function UnionOverlap206([object[]]$rectangles,[object]$target){
 $xs=New-Object System.Collections.Generic.List[double];$xs.Add([double]$target.x);$xs.Add(([double]$target.x+[double]$target.w))
 foreach($r in $rectangles){$x0=[Math]::Max([double]$target.x,[double]$r.x);$x1=[Math]::Min(([double]$target.x+[double]$target.w),([double]$r.x+[double]$r.w));if($x1-gt$x0){$xs.Add($x0);$xs.Add($x1)}}
 $ordered=@($xs|Sort-Object -Unique);$area=0.0
 for($i=0;$i-lt$ordered.Count-1;$i++){$x0=[double]$ordered[$i];$x1=[double]$ordered[$i+1];if($x1-le$x0){continue};$xm=($x0+$x1)/2;$ys=New-Object System.Collections.Generic.List[object]
  foreach($r in $rectangles){if($xm-gt$r.x-and$xm-lt($r.x+$r.w)){$y0=[Math]::Max([double]$target.y,[double]$r.y);$y1=[Math]::Min(([double]$target.y+[double]$target.d),([double]$r.y+[double]$r.d));if($y1-gt$y0){$ys.Add([pscustomobject]@{a=$y0;b=$y1})}}}
  $iv=@($ys|Sort-Object a);if($iv.Count){$lo=[double]$iv[0].a;$hi=[double]$iv[0].b;$cover=0.0;for($j=1;$j-lt$iv.Count;$j++){if([double]$iv[$j].a-le$hi){$hi=[Math]::Max($hi,[double]$iv[$j].b)}else{$cover+=$hi-$lo;$lo=[double]$iv[$j].a;$hi=[double]$iv[$j].b}};$cover+=$hi-$lo;$area+=($x1-$x0)*$cover}
 }
 return [Math]::Round($area,6)
}
$runs=New-Object System.Collections.Generic.List[object]
$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m206-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
$utf8=New-Object Text.UTF8Encoding($false)
try{
 foreach($c in $cases){
  $dx=[double]$c.dining_shift_x
  $pantry="`$pantry=NewRect186 $($c.pantry_x) $($c.pantry_y) 5 6 'M-04-pantry-spec-size-sensitivity'"
  $table="`$table=NewRect186 $(3.5+$dx) 15.5 3 5 'rotated-36x60-table'"
  $chairs="`$chairs=@((NewRect186 $(1.8333333333+$dx) 16 1.6666666667 1.5 'west-chair-1'),(NewRect186 $(1.8333333333+$dx) 18.5 1.6666666667 1.5 'west-chair-2'),(NewRect186 $(6.5+$dx) 16 1.6666666667 1.5 'east-chair-1'),(NewRect186 $(6.5+$dx) 18.5 1.6666666667 1.5 'east-chair-2'))`n`$pullouts=@((NewRect186 $(.5+$dx) 16 3 1.5 'west-chair-1-use-36in'),(NewRect186 $(.5+$dx) 18.5 3 1.5 'west-chair-2-use-36in'),(NewRect186 $(6.5+$dx) 16 3 1.5 'east-chair-1-use-36in'),(NewRect186 $(6.5+$dx) 18.5 3 1.5 'east-chair-2-use-36in'))"
  $walls="`$porchWalls=@((NewRect186 -0.5 24.5 7 0.5 'porch-wall-west-of-east-door'),(NewRect186 11.5 24.5 0 0.5 'porch-wall-east-of-door'))"
  $obstacles="`$obstacles=@(`$entry,`$pantry,`$east,`$counter,`$island,`$stools,`$table)+`$chairs+`$pullouts+`$porchWalls"
  $door="`$routeDoor=[pscustomobject]@{x=9.0;y=24.5}`n`$expectedDoorX=9.0"
  $end="`$routeEnd=[pscustomobject]@{x=9.0;y=27.5}"
  $goal="AddCheck186 'goal_is_allowed_porch_face_sample' (([Math]::Abs(`$routeDoor.x-`$expectedDoorX)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-24.5)-lt1e-8)-and(`$expectedDoorX-eq9.0)) 'Route search ends at the M204 east five-foot door sample.'"
  $openCheck="AddCheck186 'fully_open_starts_inside_living' (([Math]::Abs(`$openingNode.x-`$routeStart.x)-lt1e-8)-and([Math]::Abs(`$openingNode.y-`$routeStart.y)-lt1e-8)) 'The route starts in M-01 with the half-wall/return removed.'"
  $generated=$base.Replace($oldOpenX,'$openX=[double]$routeStart.x').Replace($oldOpenY,'$openY=[double]$routeStart.y').Replace($oldPantry,$pantry).Replace($oldObstacles,$obstacles).Replace($oldTable,$table).Replace($oldChairs,$chairs).Replace($oldWalls,$walls).Replace($oldDoor,$door).Replace($oldEnd,$end).Replace($oldGoal,$goal)
  $generated=[regex]::Replace($generated,$openingPattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m)$openCheck},1)
  $sub='.local/revalidation/'+$ScratchPrefix+'-'+$c.id;$full=Join-Path $root $sub
  if((Test-Path -LiteralPath $full)-and @(Get-ChildItem -LiteralPath $full -Force).Count-gt0){throw "Refusing to overwrite nonempty scratch: $full"}
  [IO.File]::WriteAllText($temp,$generated,$utf8);& $temp -OutputDirectory $sub
  $r=Get-Content (Join-Path $full 'm186-route-search.json') -Raw|ConvertFrom-Json
  $pantryRect=[pscustomobject]@{x=[double]$c.pantry_x;y=[double]$c.pantry_y;w=5.0;d=6.0}
  $diningRect=[pscustomobject]@{x=[double]$dx;y=14.0;w=11.0;d=10.0}
  $kitchenRect=[pscustomobject]@{x=0.0;y=0.0;w=13.5;d=14.0}
  $pantryAOverlap=Overlap206 $pantryRect.x $pantryRect.y $pantryRect.w $pantryRect.d $aRect.x $aRect.y $aRect.w $aRect.d
  $pantryDiningOverlap=Overlap206 $pantryRect.x $pantryRect.y $pantryRect.w $pantryRect.d $diningRect.x $diningRect.y $diningRect.w $diningRect.d
  $pantryKitchenOverlap=Overlap206 $pantryRect.x $pantryRect.y $pantryRect.w $pantryRect.d $kitchenRect.x $kitchenRect.y $kitchenRect.w $kitchenRect.d
  $routeAOverlap=if($r.search.path_found){UnionOverlap206 @($r.search.route_rectangles_ft) $aRect}else{0.0}
  $combinedAOverlap=if($r.search.path_found){UnionOverlap206 (@($pantryRect)+@($r.search.route_rectangles_ft)) $aRect}else{$pantryAOverlap}
  $shellLeft=-[double]$origin.x;$diningWestMargin=[double]$diningRect.x-$shellLeft
  $runs.Add([pscustomobject]@{case=$c.id;pantry_rect_ft=@($c.pantry_x,$c.pantry_y,5,6);dining_shift_x_ft=$dx;dining_west_margin_to_test_shell_ft=[Math]::Round($diningWestMargin,6);kitchen_north_wall_shared_length_ft=$c.shared_kitchen_edge_ft;door_swing_modeled=$false;pantry_A_overlap_sf=[Math]::Round($pantryAOverlap,6);route_A_union_overlap_sf=$routeAOverlap;combined_pantry_route_A_union_overlap_sf=$combinedAOverlap;pantry_dining_zone_overlap_sf=[Math]::Round($pantryDiningOverlap,6);pantry_kitchen_zone_overlap_sf=[Math]::Round($pantryKitchenOverlap,6);path_found=[bool]$r.search.path_found;route_length_ft=$r.search.route_length_ft;route_turns=$r.search.route_turn_count;reachable_nodes=$r.search.centerline_bounds.reached_node_count;nearest_to_door_ft=$r.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;checks_passed=$r.checks.passed;checks_total=$r.checks.total;M06_B_status=[string]$eastB.status;route_rectangles_ft=$r.search.route_rectangles_ft;modeled_obstacles=$r.search.modeled_obstacles})
 }
}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}
$checks=@(
 [pscustomobject]@{id='three_spec_size_pantry_cases_tested';pass=($runs.Count-eq3-and@($runs|Where-Object{[double]$_.pantry_rect_ft[2]-ne5-or[double]$_.pantry_rect_ft[3]-ne6}).Count-eq0);detail='Baseline, north-edge 30-in shared-wall and north-edge 36-in shared-wall positions retain the specified 5 x 6 ft block.'},
 [pscustomobject]@{id='every_M186_contract_passes';pass=(@($runs|Where-Object{$_.checks_passed-ne$_.checks_total}).Count-eq0);detail='All three modified M186 searches pass their full route-search contracts.'},
 [pscustomobject]@{id='B_remains_unassigned';pass=([string]$eastB.status-match'Unassigned'-and@($runs|Where-Object M06_B_status -notmatch 'Unassigned').Count-eq0);detail='Pantry-side M-06/B remains an obstacle and unassigned in every case.'},
 [pscustomobject]@{id='selected_D_hash_protected';pass=($hashes[$selectedRel]-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Selected-D source fingerprint remains unchanged.'},
 [pscustomobject]@{id='pantry_and_dining_proxy_overlap_reported';pass=(@($runs|Where-Object{[double]$_.pantry_dining_zone_overlap_sf-gt1e-6}).Count-eq0);detail='All tested pantry footprints remain outside the dining room block; the 6-in dining shift is reported separately.'},
 [pscustomobject]@{id='documented_pantry_size_used';pass=(@($runs|Where-Object{[double]$_.pantry_rect_ft[2]-ne5-or[double]$_.pantry_rect_ft[3]-ne6}).Count-eq0);detail='All test rectangles use the 5 x 6 ft (30 sf) kitchen specification; the 5 x 7 ft M04 source mismatch remains disclosed.'}
)
$passed=@($checks|Where-Object pass).Count;$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$report=[ordered]@{schema='forever-home-m206-pantry-location-sensitivity-v1';status=$status;design_result='unapproved_pantry_location_sensitivity';method='Three 5 x 6 ft specification-sized M-04 test placements compare the current position with two positions directly north of the candidate kitchen; the east x=9 M204 porch door, fully open living start, B obstacle, kitchen, island, stool and social use proxies are held constant except the stated 6-in west dining shift in the 36-in case.';owner_authorization='Owner authorized relocation sensitivity on 2026-10-31; no pantry position selected.';source_fingerprints_sha256=$hashes;selected_d_sha256=$hashes[$selectedRel];M06_B_status=[string]$eastB.status;pantry_size_sources=[ordered]@{route_study_proxy_ft=@(5,7);route_study_proxy_area_sf=35;kitchen_specification_ft=@(5,6);kitchen_specification_area_sf=30;resolution='This run tests the 5 x 6 ft kitchen specification; source route block remains 5 x 7 ft.'};cases=$runs.ToArray();checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('Only three positions are tested; this is not an exhaustive pantry-location search.','Door leaf, rough opening, swing, shelving, work aisles, storage fit, service routes and wall thickness are not modeled. The shared-wall lengths of 30 in and 36 in do not prove a door fits.','The 40 x 42 ft shell and all room/furniture blocks are schematic proxies; the pantry dimensions conflict across sources; this run tests the 5 x 6 ft kitchen target.','A pantry position overlapping M-06/A consumes unassigned bath-search area and is a trade-off, not an assignment. B remains unassigned and protected.','No code, accessibility, structural, permit, professional or construction-readiness conclusion follows. Revit, IFC, selected-D and RFAs are unchanged.')}
[IO.File]::WriteAllText((Join-Path $out 'm206-pantry-location-sensitivity.json'),(($report|ConvertTo-Json -Depth 50)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm206-checks.json'),(($report.checks|ConvertTo-Json -Depth 20)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm206-cases.csv'),((@($runs|Select-Object case,pantry_rect_ft,dining_shift_x_ft,dining_west_margin_to_test_shell_ft,kitchen_north_wall_shared_length_ft,door_swing_modeled,pantry_A_overlap_sf,route_A_union_overlap_sf,combined_pantry_route_A_union_overlap_sf,pantry_dining_zone_overlap_sf,pantry_kitchen_zone_overlap_sf,path_found,route_length_ft,route_turns,reachable_nodes,nearest_to_door_ft,checks_passed,checks_total,M06_B_status|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
if($passed-ne$checks.Count){throw "M206 integrity failed $passed/$($checks.Count); see $out"}
Write-Output "M206 pass $passed/$($checks.Count); $(@($runs|Where-Object path_found).Count)/$($runs.Count) pantry cases find a route; B remains unassigned."
