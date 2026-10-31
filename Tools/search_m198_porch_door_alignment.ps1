param(
    [string]$OutputDirectory='Architecture/M198_Porch_Door_Alignment_2026-10-31/artifacts',
    [string]$ScratchPrefix='M198'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}

$baseRel='Tools/search_m186_public_route.ps1'
$m178Rel='Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json'
$m195Rel='Architecture/M195_Social_Layout_Search_2026-10-31/artifacts/m195-social-layout-search.json'
$specRel='Architecture/Kitchen_Dining_Porch_Specs.md'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$sourceRels=@($baseRel,$m178Rel,$m195Rel,$specRel,$selectedRel,$bathRel,'Decisions/2026-10-31_Kitchen_Area_Priority.md')
function Hash198([string]$rel){(Get-FileHash -LiteralPath (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$hashes=[ordered]@{};foreach($rel in $sourceRels){$hashes[$rel]=Hash198 $rel}
if($hashes[$selectedRel]-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M198.'}
$m178=Get-Content -LiteralPath (Join-Path $root $m178Rel) -Raw|ConvertFrom-Json
$m195=Get-Content -LiteralPath (Join-Path $root $m195Rel) -Raw|ConvertFrom-Json
$bath=Get-Content -LiteralPath (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$westA=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'west_of_core')[0]
$eastB=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
if([string]$eastB.status -notmatch 'Unassigned'){throw 'M-06/B is not in the expected unassigned source state.'}
if(@($m195.candidate_placements|Where-Object case -eq 'centered_table').Count-ne1){throw 'Expected the source-bound M195 centered-table case.'}
$m195Spec=@($m195.source_fingerprints_sha256.PSObject.Properties|Where-Object Name -eq $specRel)[0]
if($null-eq$m195Spec-or[string]$m195Spec.Value-ne$hashes[$specRel]){throw 'M195 no longer binds the current room specification.'}

# Porch x extents are (-0.5, 11.5) ft; a 5-ft opening fits fully on that face
# with center positions from 2 to 9 ft. Half-foot steps are analysis samples only.
$doorCenters=New-Object System.Collections.Generic.List[double]
for($x=2.0;$x-le9.0+1e-8;$x+=0.5){$doorCenters.Add([Math]::Round($x,6))}
$base=[IO.File]::ReadAllText((Join-Path $root $baseRel))
$oldTable="`$table=NewRect186 3 17.5 5 3 'dining-table'"
$oldChairs="`$chairs=@((NewRect186 3.5 15.8333333333 1.5 1.6666666667 'south-chair-1'),(NewRect186 6 15.8333333333 1.5 1.6666666667 'south-chair-2'),(NewRect186 1.3333333333 17.5 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.3333333333 19 1.6666666667 1.5 'west-chair-2'))"
$oldWalls="`$porchWalls=@((NewRect186 -0.5 24.5 6.5 0.5 'porch-wall-west-of-door'),(NewRect186 11 24.5 0.5 0.5 'porch-wall-east-of-door'))"
$oldObstacles="`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$halfwall,`$wallReturn,`$table)+`$chairs+`$porchWalls"
$oldDoor="`$routeDoor=[pscustomobject]@{x=8.5;y=24.5}"
$oldEnd="`$routeEnd=[pscustomobject]@{x=8.5;y=27.5}"
$oldGoal="AddCheck186 'goal_is_nominal_porch_door' ((`$routeDoor.x-ge6)-and(`$routeDoor.x-le11)-and(`$routeDoor.y-eq24.5)) 'Route search ends at the nominal 5-ft porch-door reservation before extending 3 ft into the porch.'"
$pairs=@(@($oldTable,'table'),@($oldChairs,'chairs'),@($oldWalls,'porch wall'),@($oldObstacles,'obstacle set'),@($oldDoor,'door center'),@($oldEnd,'porch terminus'),@($oldGoal,'porch-door check'))
foreach($pair in $pairs){if(([regex]::Matches($base,[regex]::Escape([string]$pair[0]))).Count-ne1){throw "M186 source changed at $($pair[1]); refusing unreviewed transform."}}

$runs=New-Object System.Collections.Generic.List[object]
$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m198-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
$utf8=New-Object Text.UTF8Encoding($false)
try{
 foreach($doorX in $doorCenters){
  $table="`$table=NewRect186 3.5 15.5 3 5 'rotated-36x60-table'"
  $chairs="`$chairs=@((NewRect186 1.8333333333 16 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.8333333333 18.5 1.6666666667 1.5 'west-chair-2'),(NewRect186 6.5 16 1.6666666667 1.5 'east-chair-1'),(NewRect186 6.5 18.5 1.6666666667 1.5 'east-chair-2'))`n`$pullouts=@((NewRect186 .5 16 3 1.5 'west-chair-1-use-36in'),(NewRect186 .5 18.5 3 1.5 'west-chair-2-use-36in'),(NewRect186 6.5 16 3 1.5 'east-chair-1-use-36in'),(NewRect186 6.5 18.5 3 1.5 'east-chair-2-use-36in'))"
  $leftLen=$doorX-2;$rightStart=$doorX+2.5;$rightLen=9-$doorX
  $walls="`$porchWalls=@((NewRect186 -0.5 24.5 $leftLen 0.5 'porch-wall-west-of-door'),(NewRect186 $rightStart 24.5 $rightLen 0.5 'porch-wall-east-of-door'))"
  $obstacles="`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$halfwall,`$wallReturn,`$table)+`$chairs+`$pullouts+`$porchWalls"
  $door="`$routeDoor=[pscustomobject]@{x=$doorX;y=24.5}`n`$expectedDoorX=$doorX"
  $end="`$routeEnd=[pscustomobject]@{x=$doorX;y=27.5}"
  $goal="AddCheck186 'goal_is_finite_porch_door_sample' (([Math]::Abs(`$routeDoor.x-`$expectedDoorX)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-24.5)-lt1e-8)-and(`$expectedDoorX-ge2)-and(`$expectedDoorX-le9)) 'The 5-ft opening remains fully inside the documented 12-ft porch face.'"
  $generated=$base.Replace($oldTable,$table).Replace($oldChairs,$chairs).Replace($oldWalls,$walls).Replace($oldObstacles,$obstacles).Replace($oldDoor,$door).Replace($oldEnd,$end).Replace($oldGoal,$goal)
  $key=$doorX.ToString('0.0').Replace('.','p');$sub='.local/revalidation/'+$ScratchPrefix+'-door-'+$key;$full=Join-Path $root $sub
  if((Test-Path -LiteralPath $full)-and @(Get-ChildItem -LiteralPath $full -Force).Count-gt0){throw "Refusing to overwrite candidate scratch: $full"}
  [IO.File]::WriteAllText($temp,$generated,$utf8);& $temp -OutputDirectory $sub
  $route=Get-Content (Join-Path $full 'm186-route-search.json') -Raw|ConvertFrom-Json
  $runs.Add([pscustomobject]@{door_center_x_ft=$doorX;door_width_ft=5;porch_rect_ft=@(-.5,24.5,12,10);path_found=[bool]$route.search.path_found;route_length_ft=$route.search.route_length_ft;route_turns=$route.search.route_turn_count;route_waypoints_ft=$route.search.compressed_waypoints_ft;reachable_nodes=$route.search.centerline_bounds.reached_node_count;nearest_to_door_ft=$route.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;checks_passed=$route.checks.passed;checks_total=$route.checks.total;M06_B_status=[string]$eastB.status})
 }
}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}
$first=@($runs|Where-Object path_found|Sort-Object door_center_x_ft|Select-Object -First 1)
$aRect=[pscustomobject]@{x=[double]$westA.x-.6666666666666666;y=[double]$westA.y-.6666666666666666;w=[double]$westA.w;d=[double]$westA.d}
$porch=[pscustomobject]@{x=-.5;y=24.5;w=12;d=10}
$overlapX=[Math]::Max(0.0,[Math]::Min($porch.x+$porch.w,$aRect.x+$aRect.w)-[Math]::Max($porch.x,$aRect.x));$overlapY=[Math]::Max(0.0,[Math]::Min($porch.y+$porch.d,$aRect.y+$aRect.d)-[Math]::Max($porch.y,$aRect.y));$aOverlap=[Math]::Round($overlapX*$overlapY,6)
$checks=@(
 [pscustomobject]@{id='all_15_finite_door_positions_tested';pass=($runs.Count-eq15-and[Math]::Abs($runs[0].door_center_x_ft-2)-lt1e-8-and[Math]::Abs($runs[-1].door_center_x_ft-9)-lt1e-8);detail='All half-foot positions with a five-foot opening fully inside the 12-ft porch face were tested.'},
 [pscustomobject]@{id='every_embedded_m186_contract_passes';pass=(@($runs|Where-Object{$_.checks_passed-ne$_.checks_total}).Count-eq0);detail='Every generated full-shell route search passes its source and route-contract checks.'},
 [pscustomobject]@{id='fixed_kitchen_and_dining_inputs';pass=([double]$m178.candidate.kitchen_area_sf-eq189-and[double]$m178.candidate.island_rect_ft[2]-eq4-and[double]$m178.candidate.island_rect_ft[3]-eq8);detail='Kitchen remains the 189-sf M178 study with its 8 x 4 ft island; door position is the only intended variable.'},
 [pscustomobject]@{id='B_unassigned';pass=([string]$eastB.status-match'Unassigned'-and@($runs|Where-Object M06_B_status-notmatch'Unassigned').Count-eq0);detail='Pantry-side M-06/B remains unassigned in all cases.'},
 [pscustomobject]@{id='alternate_A_porch_tradeoff_reported';pass=($aOverlap-gt0);detail=("Porch overlaps alternate A by $aOverlap sf; A remains an unassigned diagnostic option, not a room.")},
 [pscustomobject]@{id='selected_D_hash_protected';pass=($hashes[$selectedRel]-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Selected-D fingerprint remains unchanged.'},
 [pscustomobject]@{id='door_locations_remain_sensitivities';pass=$true;detail='No tested opening position is recorded as selected design.'}
)
$passed=@($checks|Where-Object pass).Count;$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$result=if($first.Count){'route_found_for_one_or_more_door_positions'}else{'no_route_in_tested_door_positions'}
$outReport=[ordered]@{schema='forever-home-m198-porch-door-alignment-v1';status=$status;design_result=$result;method='Fifteen half-foot porch-door center samples across the available 12-ft porch face; M178 kitchen and M195 rotated dining/table/chair-use proxies stay fixed; each runs M186 full-shell 36-in quarter-foot BFS.';source_fingerprints_sha256=$hashes;selected_d_sha256=$hashes[$selectedRel];fixed_layout=[ordered]@{kitchen_dimensions_ft=@(13.5,14);kitchen_area_sf=189;island_dimensions_ft=@(8,4);dining_dimensions_ft=@(11,10);porch_dimensions_ft=@(12,10);door_width_ft=5;M06_A_porch_overlap_sf=$aOverlap;M06_B_status=[string]$eastB.status};door_search=[ordered]@{minimum_center_x_ft=2;maximum_center_x_ft=9;step_ft=.5;sample_count=$runs.Count;first_route_passing_sample=if($first.Count){$first[0]}else{$null};samples=$runs};checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('Door centers are sensitivity samples, not owner-selected architecture; five-foot opening size is inherited from the route study and remains unapproved.','Kitchen, dining, chair-use zones, stool proxy, half-wall, entry, pantry and M-06 windows remain fixed rectangular proxies.','A route found by this grid would still need exact physical walls, doors, thresholds, furniture movement, appliances, site connection and professional review.','The porch footprint overlaps alternate A; no bath is assigned there. Pantry-side B remains unassigned and protected.','Revit, IFC, selected-D and Incoming RFAs are unchanged. No code, accessibility, structural, permit or construction-readiness conclusion follows.')}
[IO.File]::WriteAllText((Join-Path $out 'm198-porch-door-alignment.json'),(($outReport|ConvertTo-Json -Depth 40)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm198-checks.json'),(($outReport.checks|ConvertTo-Json -Depth 20)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm198-door-samples.csv'),((@($runs|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
if($passed-ne$checks.Count){throw "M198 integrity failed $passed/$($checks.Count); see $out"}
Write-Output "M198 pass $passed/$($checks.Count); $(@($runs|Where-Object path_found).Count)/$($runs.Count) door positions find a sampled path; M-06/B remains unassigned."
