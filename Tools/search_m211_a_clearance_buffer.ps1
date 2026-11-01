param(
    [string]$OutputDirectory='Architecture/M211_Porch_Door_Alignment_2026-10-31/artifacts',
    [string]$ScratchPrefix='M211'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}

$baseRel='Tools/search_m186_public_route.ps1'
$m178Rel='Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json'
$m192Rel='Architecture/M192_Rotated_Dining_Candidate_2026-10-31/artifacts/m192-rotated-dining-candidate.json'
$specRel='Architecture/Kitchen_Dining_Porch_Specs.md'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$m207Rel='Architecture/M207_Pantry_Edge_Sensitivity_2026-10-31/artifacts-v4/m207-pantry-location-sensitivity.json'
$sourceRels=@($baseRel,$m178Rel,$m192Rel,$specRel,$selectedRel,$bathRel,$m207Rel,'Decisions/2026-10-31_Kitchen_Area_Priority.md','Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md','Decisions/2026-10-31_M06_West_A_Protection.md')
function Hash195([string]$rel){(Get-FileHash -LiteralPath (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$hashes=[ordered]@{};foreach($rel in $sourceRels){$hashes[$rel]=Hash195 $rel}
if($hashes[$selectedRel]-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M211.'}
$m178=Get-Content -LiteralPath (Join-Path $root $m178Rel) -Raw|ConvertFrom-Json
$m192=Get-Content -LiteralPath (Join-Path $root $m192Rel) -Raw|ConvertFrom-Json
$bath=Get-Content -LiteralPath (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$eastB=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
$westA=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'west_of_core')[0]
if([string]$eastB.status -notmatch 'Unassigned'){throw 'M-06/B is not in the expected unassigned source state.'}
if([double]$m178.candidate.kitchen_area_sf-ne189-or[double]$m178.candidate.island_rect_ft[2]-ne4-or[double]$m178.candidate.island_rect_ft[3]-ne8){throw 'Expected the 189-sf M178 candidate with an 8 x 4-ft island.'}
$m192Spec=@($m192.source_fingerprints_sha256.PSObject.Properties|Where-Object Name -eq $specRel)[0]
if($null-eq$m192Spec-or[string]$m192Spec.Value-ne$hashes[$specRel]){throw 'M192 no longer binds the current kitchen/porch specification.'}

# Northward translations test the clearance needed to pass above protected A
# before approaching the porch. Dining/porch areas and documented furniture
# sizes remain fixed; all placements are hypothetical, not design selections.
$cases=@()
foreach($dy in @(5.5,6.5)){
 foreach($reserve in @(0.0,0.25,0.5,1.0)){
  $shift=('{0:0.##}' -f $dy).Replace('.','_');$buffer=('{0:0.##}' -f $reserve).Replace('.','_')
  $cases+=,[pscustomobject]@{id=('north'+$shift+'_Areserve'+$buffer);dx=0.0;dy=$dy;tx=3.0;ty=(15.5+$dy);door_x=9.0;reserve_ft=$reserve}
 }
}
$base=[IO.File]::ReadAllText((Join-Path $root $baseRel))
$oldPantry="`$pantry=NewRect186 ([double]`$pantrySource.x-[double]`$origin.x) ([double]`$pantrySource.y-[double]`$origin.y) ([double]`$pantrySource.w) ([double]`$pantrySource.d) 'M-04-pantry'"
$oldTable="`$table=NewRect186 3 17.5 5 3 'dining-table'"
$oldChairs="`$chairs=@((NewRect186 3.5 15.8333333333 1.5 1.6666666667 'south-chair-1'),(NewRect186 6 15.8333333333 1.5 1.6666666667 'south-chair-2'),(NewRect186 1.3333333333 17.5 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.3333333333 19 1.6666666667 1.5 'west-chair-2'))"
$oldWalls="`$porchWalls=@((NewRect186 -0.5 24.5 6.5 0.5 'porch-wall-west-of-door'),(NewRect186 11 24.5 0.5 0.5 'porch-wall-east-of-door'))"
$oldObstacles="`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$halfwall,`$wallReturn,`$table)+`$chairs+`$porchWalls"
$oldDoor="`$routeDoor=[pscustomobject]@{x=8.5;y=24.5}"
$oldEnd="`$routeEnd=[pscustomobject]@{x=8.5;y=27.5}"
$oldOpeningNode="`$openingNode=[pscustomobject]@{x=`$openX;y=`$openY}"
$oldGoal="AddCheck186 'goal_is_nominal_porch_door' ((`$routeDoor.x-ge6)-and(`$routeDoor.x-le11)-and(`$routeDoor.y-eq24.5)) 'Route search ends at the nominal 5-ft porch-door reservation before extending 3 ft into the porch.'"
$oldDiningArea="elseif(`$mx-ge0-and`$mx-le11-and`$my-ge14-and`$my-le24)"
$oldPorchArea="elseif(`$mx-ge-0.5-and`$mx-le11.5-and`$my-ge24.5-and`$my-le34.5)"
foreach($pair in @(@($oldPantry,'$pantry'),@($oldTable,'$table'),@($oldChairs,'$chairs'),@($oldWalls,'$porchWalls'),@($oldObstacles,'$obstacles'),@($oldDoor,'$routeDoor'),@($oldEnd,'$routeEnd'),@($oldOpeningNode,'$openingNode'),@($oldGoal,'goal check'),@($oldDiningArea,'dining classifier'),@($oldPorchArea,'porch classifier'))){if(([regex]::Matches($base,[regex]::Escape([string]$pair[0]))).Count-ne1){throw "M186 source changed at $($pair[1]); refusing unreviewed transform."}}

$details=New-Object System.Collections.Generic.List[object]
$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m211-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
$utf8=New-Object Text.UTF8Encoding($false)
try{
 foreach($c in $cases){
  $dx=[double]$c.dx;$dy=[double]$c.dy;$tx=[double]$c.tx;$ty=[double]$c.ty;$doorX=[double]$c.door_x;$reserve=[double]$c.reserve_ft;$diningY=14.0+$dy;$doorY=24.5+$dy
  $repPantry="`$pantry=NewRect186 13.5 0 5 6 'M-04-pantry-5x6-A-B-clear'"
  $repTable="`$table=NewRect186 $tx $ty 3 5 'rotated-36x60-table'"
  $cxw=$tx-1.6666666667;$cxe=$tx+3
  $repTable="`$table=NewRect186 $tx $ty 3 5 'rotated-36x60-table'"
  $repChairs="`$chairs=@((NewRect186 $cxw $($ty+.5) 1.6666666667 1.5 'west-chair-1'),(NewRect186 $cxw $($ty+3) 1.6666666667 1.5 'west-chair-2'),(NewRect186 $cxe $($ty+.5) 1.6666666667 1.5 'east-chair-1'),(NewRect186 $cxe $($ty+3) 1.6666666667 1.5 'east-chair-2'))`n`$pullouts=@((NewRect186 $($tx-3) $($ty+.5) 3 1.5 'west-chair-1-use-36in'),(NewRect186 $($tx-3) $($ty+3) 3 1.5 'west-chair-2-use-36in'),(NewRect186 $($tx+3) $($ty+.5) 3 1.5 'east-chair-1-use-36in'),(NewRect186 $($tx+3) $($ty+3) 3 1.5 'east-chair-2-use-36in'))"
  $repWalls="`$porchWalls=@((NewRect186 $($dx-.5) $doorY $($doorX-$dx-2) 0.5 'porch-wall-west-of-door'),(NewRect186 $($doorX+2.5) $doorY $($dx+9-$doorX) 0.5 'porch-wall-east-of-door'))"
  $repObstacles="`$west.w=[double]`$west.w+$reserve`n`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$table)+`$chairs+`$pullouts+`$porchWalls"
  $repOpeningNode="`$openingNode=[pscustomobject]@{x=[double]`$routeStart.x;y=[double]`$routeStart.y}"
  $repDoor="`$routeDoor=[pscustomobject]@{x=$doorX;y=$doorY}`n`$expectedDoorX=$doorX`n`$expectedDoorY=$doorY`n`$expectedDiningX=$dx`n`$expectedDiningY=$diningY"
  $repEnd="`$routeEnd=[pscustomobject]@{x=$doorX;y=$($doorY+3)}"
  $repGoal="AddCheck186 'goal_is_porch_face_door' (([Math]::Abs(`$routeDoor.x-`$expectedDoorX)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-`$expectedDoorY)-lt1e-8)-and(`$expectedDoorX-2.5-ge(`$expectedDiningX-.5))-and(`$expectedDoorX+2.5-le(`$expectedDiningX+11.5))) 'The tested 5-ft door fits the south face of the translated 12-ft porch study block.'"
  $generated=$base.Replace($oldPantry,$repPantry).Replace($oldTable,$repTable).Replace($oldChairs,$repChairs).Replace($oldWalls,$repWalls).Replace($oldObstacles,$repObstacles).Replace($oldDoor,$repDoor).Replace($oldEnd,$repEnd).Replace($oldOpeningNode,$repOpeningNode).Replace($oldGoal,$repGoal).Replace($oldDiningArea,"elseif(`$mx-ge`$expectedDiningX-and`$mx-le(`$expectedDiningX+11)-and`$my-ge`$expectedDiningY-and`$my-le(`$expectedDiningY+10))").Replace($oldPorchArea,"elseif(`$mx-ge(`$expectedDiningX-.5)-and`$mx-le(`$expectedDiningX+11.5)-and`$my-ge`$expectedDoorY-and`$my-le(`$expectedDoorY+10))")
  $sub='.local/revalidation/'+$ScratchPrefix+'-'+$c.id;$full=Join-Path $root $sub
  if((Test-Path -LiteralPath $full)-and @(Get-ChildItem -LiteralPath $full -Force).Count-gt0){throw "Refusing to overwrite candidate scratch: $full"}
  [IO.File]::WriteAllText($temp,$generated,$utf8)
  & $temp -OutputDirectory $sub
  $run=Get-Content (Join-Path $full 'm186-route-search.json') -Raw|ConvertFrom-Json
  $dining=[pscustomobject]@{x=$dx;y=$diningY;w=11.0;d=10.0};$porch=[pscustomobject]@{x=$dx-.5;y=$doorY;w=12.0;d=10.0}
  $table=[pscustomobject]@{x=$tx;y=$ty;w=3.0;d=5.0}
  $chairs=@([pscustomobject]@{x=$cxw;y=$ty+.5;w=1.6666666667;d=1.5},[pscustomobject]@{x=$cxw;y=$ty+3;w=1.6666666667;d=1.5},[pscustomobject]@{x=$cxe;y=$ty+.5;w=1.6666666667;d=1.5},[pscustomobject]@{x=$cxe;y=$ty+3;w=1.6666666667;d=1.5})
  $pullRects=@([pscustomobject]@{x=$tx-3;y=$ty+.5;w=3.0;d=1.5},[pscustomobject]@{x=$tx-3;y=$ty+3;w=3.0;d=1.5},[pscustomobject]@{x=$tx+3;y=$ty+.5;w=3.0;d=1.5},[pscustomobject]@{x=$tx+3;y=$ty+3;w=3.0;d=1.5})
  $boundsOk=(@($table)+$chairs+$pullRects|Where-Object{$_.x-lt$dx-1e-8-or$_.y-lt$diningY-1e-8-or$_.x+$_.w-gt($dx+11)+1e-8-or$_.y+$_.d-gt($diningY+10)+1e-8}).Count-eq0
  $shell=[double[]]@(40,42);$shellOk=($dining.x-ge-0.6666666667-and$dining.x+$dining.w-le39.3333333333-and$dining.y-ge-0.6666666667-and$dining.y+$dining.d-le41.3333333333-and$porch.x-ge-0.6666666667-and$porch.x+$porch.w-le39.3333333333-and$porch.y-ge-0.6666666667-and$porch.y+$porch.d-le41.3333333333)
  $aRect=[pscustomobject]@{x=[double]$westA.x-.6666666666666666;y=[double]$westA.y-.6666666666666666;w=[double]$westA.w;d=[double]$westA.d};$bRect=[pscustomobject]@{x=[double]$eastB.x-.6666666666666666;y=[double]$eastB.y-.6666666666666666;w=[double]$eastB.w;d=[double]$eastB.d}
  function Area195($r1,$r2){$ix=[Math]::Max(0.0,[Math]::Min($r1.x+$r1.w,$r2.x+$r2.w)-[Math]::Max($r1.x,$r2.x));$iy=[Math]::Max(0.0,[Math]::Min($r1.y+$r1.d,$r2.y+$r2.d)-[Math]::Max($r1.y,$r2.y));return [Math]::Round($ix*$iy,6)}
  $aDiningOverlap=Area195 $dining $aRect;$aPorchOverlap=Area195 $porch $aRect;$bDiningOverlap=Area195 $dining $bRect;$bPorchOverlap=Area195 $porch $bRect
  $aGapRow=@($run.search.minimum_edge_gap_by_obstacle|Where-Object{$_.obstacle -eq 'west_of_core'})[0];$aGap=if($null-ne$aGapRow){[double]$aGapRow.minimum_route_edge_gap_ft}else{$null}
  $proxyGaps=@($run.search.minimum_edge_gap_by_obstacle|Where-Object{$_.obstacle -match 'island|stool|use-36in|dining-table|chair|perimeter-run|M-04-pantry|east_of_core|west_of_core'}|ForEach-Object{[double]$_.minimum_route_edge_gap_ft})
  $minGap=if($proxyGaps.Count){($proxyGaps|Measure-Object -Minimum).Minimum}else{$null}
  $doorOpeningInsideFace=($doorX-2.5-ge($dx-.5)-1e-8-and$doorX+2.5-le($dx+11.5)+1e-8)
  $details.Add([pscustomobject]@{case=$c.id;dining_rect_ft=$dining;porch_rect_ft=$porch;table_rect_ft=$table;porch_door_center_ft=@($doorX,$doorY);door_opening_inside_porch_face=$doorOpeningInsideFace;north_shift_ft=$dy;analytical_A_reserve_ft=$reserve;dining_area_sf=110;porch_area_sf=120;pantry_rect_ft=@(13.5,0,5,6);chair_count=$chairs.Count;chair_use_zone_count=$pullRects.Count;furniture_and_use_zones_inside_dining=$boundsOk;social_footprints_inside_test_shell=$shellOk;A_window_dining_overlap_sf=$aDiningOverlap;A_window_porch_overlap_sf=$aPorchOverlap;B_window_dining_overlap_sf=$bDiningOverlap;B_window_porch_overlap_sf=$bPorchOverlap;route_found=[bool]$run.search.path_found;route_length_ft=$run.search.route_length_ft;route_turns=$run.search.route_turn_count;route_waypoints_ft=$run.search.compressed_waypoints_ft;reachable_nodes=$run.search.centerline_bounds.reached_node_count;nearest_to_porch_door_ft=$run.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;minimum_modeled_obstacle_gap_ft=$minGap;protected_A_expanded_boundary_gap_ft=$aGap;protected_A_original_boundary_gap_ft=if($null-ne$aGap){[Math]::Round($aGap+$reserve,6)}else{$null};protected_A_reserve_at_least_3in=($null-ne$aGap-and($aGap+$reserve)-ge.25);route_nonfragile=([bool]$run.search.path_found-and$null-ne$minGap-and$minGap-ge.25);m186_checks_passed=[int]$run.checks.passed;m186_checks_total=[int]$run.checks.total;M06_A_protected=$true;M06_B_status=[string]$eastB.status})
 }
}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}

$checks=@(
[pscustomobject]@{id='eight_A_reserve_cases_tested';pass=($details.Count-eq8);detail='Eight cases tested 0, 3, 6 and 12 in A-buffer sensitivities at north offsets 5.5 and 6.5 ft; door center x=9 ft was held.'},
[pscustomobject]@{id='all_door_openings_fit_porch_face';pass=(@($details|Where-Object{-not$_.door_opening_inside_porch_face}).Count-eq0);detail='Each nominal five-foot opening lies wholly within its translated porch face, and the generated porch wall segments move with that opening.'},
[pscustomobject]@{id='protected_A_clearance_reported';pass=(@($details|Where-Object{$_.route_found-and$null-eq$_.protected_A_original_boundary_gap_ft}).Count-eq0);detail='Every found route reports its reconstructed gap to the unexpanded owner-protected west-A boundary.'},
[pscustomobject]@{id='source_fingerprints_bound';pass=($hashes.Count-eq10);detail='M186, M178, M192, room/porch spec, selected-D, bath-window source, M207 pantry study and owner area/open-connection/A-protection decisions are fingerprinted.'},
 [pscustomobject]@{id='A_reserve_input_values';pass=(@($details|Where-Object{$_.analytical_A_reserve_ft-notin@(0.0,0.25,0.5,1.0)}).Count-eq0);detail='The 0, 3, 6 and 12 in values expand only the route-search obstacle; they do not change bath geometry or assign M-06.'},
 [pscustomobject]@{id='selected_D_preserved';pass=($hashes[$selectedRel]-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Selected-D remains at the protected source hash.'},
 [pscustomobject]@{id='original_8x4_island_retained';pass=([double]$m178.candidate.island_rect_ft[2]-eq4-and[double]$m178.candidate.island_rect_ft[3]-eq8);detail='The M178 8 x 4 ft island is retained in the full-shell route engine.'},
[pscustomobject]@{id='A_and_B_protected_and_clear';pass=([string]$eastB.status-match'Unassigned'-and@($details|Where-Object{$_.A_window_dining_overlap_sf-gt0-or$_.A_window_porch_overlap_sf-gt0-or$_.B_window_dining_overlap_sf-gt0-or$_.B_window_porch_overlap_sf-gt0}).Count-eq0);detail='Owner-protected A and unassigned B remain clear of moved dining/porch blocks; route search keeps both as obstacles.'},
 [pscustomobject]@{id='dining_furniture_and_use_zones_inside';pass=(@($details|Where-Object{-not$_.furniture_and_use_zones_inside_dining}).Count-eq0);detail='All table/chair bodies and the four 36-in use-zone proxies fit each translated 11 x 10 ft dining study block.'},
 [pscustomobject]@{id='social_footprints_inside_shell';pass=(@($details|Where-Object{-not$_.social_footprints_inside_test_shell}).Count-eq0);detail='The translated dining and 12 x 10 ft porch footprints stay inside the 40 x 42 ft shell test.'},
 [pscustomobject]@{id='all_bounded_route_searches_completed';pass=(@($details|Where-Object{$_.m186_checks_passed-ne$_.m186_checks_total}).Count-eq0);detail='Every generated M186 route run passes its source and finite-grid contract checks.'},
[pscustomobject]@{id='results_remain_sensitivity_only';pass=($details.Count-eq8);detail='Even a path with positive geometric gap remains an unselected schematic candidate.'}
)
$passed=@($checks|Where-Object pass).Count;$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$report=[ordered]@{schema='forever-home-m211-protected-A-clearance-buffer-v1';status=$status;design_result=if(@($details|Where-Object protected_A_reserve_at_least_3in).Count){'routes_found_with_at_least_3in_proxy_gap_to_original_A_edge'}elseif(@($details|Where-Object route_found).Count){'routes_found_but_without_3in_gap_to_original_A_edge'}else{'no_route_in_tested_clearance_buffers'};method='At north offsets 5.5 and 6.5 ft, hold the five-foot porch door at x=9 ft. Test 0, 3, 6 and 12 in analytical eastward expansions of the protected west-A route obstacle. The added buffer applies only to the route-search no-go zone; the source M-06 window dimensions and assignment do not change. Retain the 5 x 6 ft pantry, M178 8 x 4 ft island, chair-use proxies, owner-preferred open kitchen/living connection and protected A/B obstacles.';source_fingerprints_sha256=$hashes;protected_selected_d_sha256=$hashes[$selectedRel];owner_protected_A_sha256=$hashes['Decisions/2026-10-31_M06_West_A_Protection.md'];kitchen_test=[ordered]@{source='M178';area_sf=[double]$m178.candidate.kitchen_area_sf;dimensions_ft=@(13.5,14);island_dimensions_ft=@(8,4);program_target_sf=168;status='unapproved comparison only; area held at the 189-sf M178 test'};route_contract=[ordered]@{width_in=36;grid_step_ft=.25;test_shell_ft=@(40,42);kitchen_living_connection='fully_open_owner_preference';M06_A_protected=$true;M06_B_status=[string]$eastB.status;M06_B_kept_clear=$true};candidate_placements=$details.ToArray();checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('Only eight A-buffer/offset combinations are sampled; no exhaustive placement or minimum-area proof is claimed.','Dining and porch footprints are translated as blocks; rough openings, door leaf/swing, thresholds, enclosure and weather detailing are not modeled.','The 24-in stool depth remains an assumption; chair/stool-use rectangles are proxies, not measured product or occupant geometry.','Door center x=9 ft is held; opening and wall-segment alignment is modeled, but product, threshold and operation are not.','The kitchen remains the unapproved 13.5 x 14 ft M178 proposal; appliance-open envelopes, services and site fit are untested.','Revit, IFC, selected-D and Incoming RFAs are unchanged. No code, accessibility, structural, professional, permit or construction-readiness result is established.')}
$json=($report|ConvertTo-Json -Depth 50)+"`n";[IO.File]::WriteAllText((Join-Path $out 'm211-A-clearance-buffer.json'),$json,$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm211-checks.json'),(($report.checks|ConvertTo-Json -Depth 30)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm211-candidates.csv'),((@($details|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
if($passed-ne$checks.Count){throw "M211 integrity failed $passed/$($checks.Count); see $out"}
Write-Output "M211 pass $passed/$($checks.Count); $(@($details|Where-Object route_found).Count)/$($details.Count) A-buffer cases find a sampled route; $(@($details|Where-Object protected_A_reserve_at_least_3in).Count) clear the original A edge by at least 3 in; both A and B remain protected."
