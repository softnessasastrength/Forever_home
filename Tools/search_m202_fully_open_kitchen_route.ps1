param(
    [string]$OutputDirectory='Architecture/M202_Fully_Open_Kitchen_Route_2026-10-31/artifacts',
    [string]$ScratchPrefix='M202'
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
$specRel='Architecture/Kitchen_Dining_Porch_Specs.md'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$decisionRel='Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md'
$sourceRels=@($baseRel,$m178Rel,$m187Rel,$m195Rel,$m198Rel,$specRel,$selectedRel,$bathRel,$decisionRel)
function Hash202([string]$rel){(Get-FileHash -LiteralPath (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$hashes=[ordered]@{};foreach($rel in $sourceRels){$hashes[$rel]=Hash202 $rel}
if($hashes[$selectedRel]-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M202.'}
$m178=Get-Content -LiteralPath (Join-Path $root $m178Rel) -Raw|ConvertFrom-Json
$m187=Get-Content -LiteralPath (Join-Path $root $m187Rel) -Raw|ConvertFrom-Json
$m195=Get-Content -LiteralPath (Join-Path $root $m195Rel) -Raw|ConvertFrom-Json
$m198=Get-Content -LiteralPath (Join-Path $root $m198Rel) -Raw|ConvertFrom-Json
$bath=Get-Content -LiteralPath (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$eastB=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
if([string]$eastB.status -notmatch 'Unassigned'){throw 'M-06/B is not in the expected unassigned source state.'}
if(@($m187.cases|Where-Object relaxation -eq 'halfwall_and_return'|Where-Object path_found).Count-ne0){throw 'M187 half-wall sensitivity changed; inspect before comparing.'}
if(@($m195.candidate_placements|Where-Object case -eq 'centered_table').Count-ne1){throw 'Expected source-bound M195 centered table case.'}
$bestDoor=@($m198.door_search.samples|Sort-Object nearest_to_door_ft|Select-Object -First 1)[0]
if($null-eq$bestDoor-or[Math]::Abs([double]$bestDoor.door_center_x_ft-9)-gt1e-8){throw 'M198 best-gap door sample changed; review before M202.'}

# The fully-open preference removes the half-wall and return obstacles. Start the
# route at M180's source point within M-01; all other M186 obstacles remain.
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
$pairs=@(@($oldOpenX,'opening x'),@($oldOpenY,'opening y'),@($oldObstacles,'obstacle set'),@($oldTable,'table'),@($oldChairs,'chairs'),@($oldWalls,'porch walls'),@($oldDoor,'porch door'),@($oldEnd,'porch terminus'),@($oldGoal,'porch-door goal'))
foreach($pair in $pairs){if(([regex]::Matches($base,[regex]::Escape([string]$pair[0]))).Count-ne1){throw "M186 source changed at $($pair[1]); refusing unreviewed transform."}}
$openingPattern="(?m)^AddCheck186 'opening_reservation_crossed'.*$"
if(([regex]::Matches($base,$openingPattern)).Count-ne1){throw 'M186 opening check changed; inspect before transformation.'}

$doorX=[double]$bestDoor.door_center_x_ft
$table="`$table=NewRect186 3.5 15.5 3 5 'rotated-36x60-table'"
$chairs="`$chairs=@((NewRect186 1.8333333333 16 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.8333333333 18.5 1.6666666667 1.5 'west-chair-2'),(NewRect186 6.5 16 1.6666666667 1.5 'east-chair-1'),(NewRect186 6.5 18.5 1.6666666667 1.5 'east-chair-2'))`n`$pullouts=@((NewRect186 .5 16 3 1.5 'west-chair-1-use-36in'),(NewRect186 .5 18.5 3 1.5 'west-chair-2-use-36in'),(NewRect186 6.5 16 3 1.5 'east-chair-1-use-36in'),(NewRect186 6.5 18.5 3 1.5 'east-chair-2-use-36in'))"
$walls="`$porchWalls=@((NewRect186 -0.5 24.5 7 0.5 'porch-wall-west-of-door'),(NewRect186 11.5 24.5 0 0.5 'porch-wall-east-of-door'))"
$obstacles="`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$table)+`$chairs+`$pullouts+`$porchWalls"
$door="`$routeDoor=[pscustomobject]@{x=$doorX;y=24.5}"
$end="`$routeEnd=[pscustomobject]@{x=$doorX;y=27.5}"
$goal="AddCheck186 'goal_is_eastmost_tested_porch_door' (([Math]::Abs(`$routeDoor.x-$doorX)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-24.5)-lt1e-8)) 'Route ends at the M198 best-gap five-foot door sensitivity, not a selected location.'"
$openCheck="AddCheck186 'fully_open_starts_inside_living' (([Math]::Abs(`$openingNode.x-`$routeStart.x)-lt1e-8)-and([Math]::Abs(`$openingNode.y-`$routeStart.y)-lt1e-8)) 'The route starts at the M180 living-room point; the kitchen/living connector has no half-wall or return.'"
$generated=$base.Replace($oldOpenX,'$openX=[double]$routeStart.x').Replace($oldOpenY,'$openY=[double]$routeStart.y').Replace($oldObstacles,$obstacles).Replace($oldTable,$table).Replace($oldChairs,$chairs).Replace($oldWalls,$walls).Replace($oldDoor,$door).Replace($oldEnd,$end).Replace($oldGoal,$goal)
$generated=[regex]::Replace($generated,$openingPattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m)$openCheck},1)
$sub='.local/revalidation/'+$ScratchPrefix+'-fully-open';$full=Join-Path $root $sub
if((Test-Path -LiteralPath $full)-and @(Get-ChildItem -LiteralPath $full -Force).Count-gt0){throw "Refusing to overwrite route scratch: $full"}
$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m202-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
$utf8=New-Object Text.UTF8Encoding($false)
try{[IO.File]::WriteAllText($temp,$generated,$utf8);& $temp -OutputDirectory $sub;$route=Get-Content (Join-Path $full 'm186-route-search.json') -Raw|ConvertFrom-Json}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}
$removed=@($route.search.modeled_obstacles|Where-Object id -in @('half-wall','half-wall-return'))
$checks=@(
 [pscustomobject]@{id='route_starts_at_source_living_point';pass=([Math]::Abs([double]$route.search.opening_center_ft.x-[double]$route.search.start_inside_M01_ft.x)-lt1e-8-and[Math]::Abs([double]$route.search.opening_center_ft.y-[double]$route.search.start_inside_M01_ft.y)-lt1e-8);detail='The open-route search starts at the documented M180 point inside M-01.'},
 [pscustomobject]@{id='halfwall_and_return_removed';pass=($removed.Count-eq0);detail='Both half-wall proxies are excluded from the route obstacles.'},
 [pscustomobject]@{id='fixed_door_uses_best_M198_gap';pass=([Math]::Abs([double]$route.search.porch_door_center_ft.x-$doorX)-lt1e-8);detail='The door remains at the best-gap M198 sample and is not selected design.'},
 [pscustomobject]@{id='all_M186_contract_checks_pass';pass=($route.checks.passed-eq$route.checks.total);detail='Generated full-shell search completed every source and route-contract check.'},
 [pscustomobject]@{id='B_unassigned_and_protected';pass=([string]$eastB.status -match 'Unassigned' -and @($route.search.modeled_obstacles|Where-Object {$_.id -eq 'east_of_core'}).Count -eq 1 -and @($route.search.proxy_intersections|Where-Object {$_.obstacle -eq 'east_of_core'}).Count -eq 0);detail='Pantry-side M-06/B remains a modeled obstacle; any found route must clear it.'},
 [pscustomobject]@{id='selected_D_hash_protected';pass=($hashes[$selectedRel]-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Selected-D source fingerprint remains unchanged.'},
 [pscustomobject]@{id='open_connection_is_not_structurally_specified';pass=$true;detail='No opening span, header, beam or structural system is inferred.'}
)
$passed=@($checks|Where-Object pass).Count;$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$report=[ordered]@{schema='forever-home-m202-fully-open-kitchen-route-v1';status=$status;design_result=if($route.search.path_found){'sampled_route_found_in_fully_open_case'}else{'no_route_in_fully_open_case'};method='One fixed sensitivity removes only the kitchen half-wall and return; starts at M180 living-room route point; uses the M198 door center with the smallest measured Manhattan gap; preserves all other M186/M195 obstacles.';source_fingerprints_sha256=$hashes;selected_d_sha256=$hashes[$selectedRel];opening_case=[ordered]@{owner_preference='fully open';halfwall_removed=$true;opening_span_ft=$null;structural_solution=$null;kitchen_dimensions_ft=@(13.5,14);kitchen_area_sf=189;island_dimensions_ft=@(8,4);door_center_x_ft=$doorX;door_width_ft=5;M06_B_status=[string]$eastB.status;route_found=[bool]$route.search.path_found;route_length_ft=$route.search.route_length_ft;route_turns=$route.search.route_turn_count;waypoints_ft=$route.search.compressed_waypoints_ft;reachable_nodes=$route.search.centerline_bounds.reached_node_count;nearest_to_door_ft=$route.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;proxy_intersections=$route.search.proxy_intersections};m186_checks=[ordered]@{passed=$route.checks.passed;total=$route.checks.total;status=$route.checks.status};checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('This is one fixed route sensitivity and not a complete kitchen/living or dining layout study.','M-06/A and M-06/B remain unassigned blocked diagnostic windows; no bathroom is modeled.','The 189-sf candidate, furniture, stool use, walls, door and route are rectangular proxies; actual openings, door swing, thresholds, appliances, movement, site conditions and tolerances remain unmodeled.','A route would not establish code/accessibility compliance, structural adequacy, professional approval, permit approval or construction readiness.','Revit, IFC, selected-D and Incoming RFA sources are unchanged.')}
[IO.File]::WriteAllText((Join-Path $out 'm202-fully-open-kitchen-route.json'),(($report|ConvertTo-Json -Depth 40)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm202-checks.json'),(($report.checks|ConvertTo-Json -Depth 20)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm202-route-summary.csv'),((@([pscustomobject]@{case='fully_open';route_found=$report.opening_case.route_found;route_length_ft=$report.opening_case.route_length_ft;turns=$report.opening_case.route_turns;nearest_door_ft=$report.opening_case.nearest_to_door_ft;reachable_nodes=$report.opening_case.reachable_nodes;checks_passed=$report.checks.passed;checks_total=$report.checks.total}|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
if($passed-ne$checks.Count){throw "M202 integrity failed $passed/$($checks.Count); see $out"}
Write-Output "M202 pass $passed/$($checks.Count); full-open route found=$($route.search.path_found); M-06/B remains unassigned."
