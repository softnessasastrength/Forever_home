param(
    [string]$OutputDirectory='Architecture/M197_Kitchen_Envelope_Route_Search_2026-10-31/artifacts',
    [string]$ScratchPrefix='M197'
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
$sourceRels=@($baseRel,$m178Rel,$m192Rel,$specRel,$selectedRel,$bathRel,'Decisions/2026-10-31_Kitchen_Area_Priority.md')
function Hash197([string]$rel){(Get-FileHash -LiteralPath (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$hashes=[ordered]@{};foreach($rel in $sourceRels){$hashes[$rel]=Hash197 $rel}
if($hashes[$selectedRel]-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M197.'}
$m178=Get-Content -LiteralPath (Join-Path $root $m178Rel) -Raw|ConvertFrom-Json
$m192=Get-Content -LiteralPath (Join-Path $root $m192Rel) -Raw|ConvertFrom-Json
$bath=Get-Content -LiteralPath (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$eastB=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
if([string]$eastB.status -notmatch 'Unassigned'){throw 'M-06/B is not in the expected unassigned source state.'}
$m192Spec=@($m192.source_fingerprints_sha256.PSObject.Properties|Where-Object Name -eq $specRel)[0]
if($null-eq$m192Spec-or[string]$m192Spec.Value-ne$hashes[$specRel]){throw 'M192 no longer binds the current kitchen/porch specification.'}

# Sweep the cross-section only, at 3-in analysis increments, through the documented
# source M-02 width. Keep the 14-ft depth, 12.5-ft run, larger island, assumed stool
# zone and six-foot opening; the extra width is unassigned aisle area, not a selected room.
$sourceKitchen=@($bath.plans.main|Where-Object id -eq 'M-02')[0]
$maxWidth=[double]$sourceKitchen.w
$widths=New-Object System.Collections.Generic.List[double]
for($w=13.5;$w-lt$maxWidth-1e-8;$w+=0.25){$widths.Add([Math]::Round($w,6))}
if([Math]::Abs($widths[$widths.Count-1]-$maxWidth)-gt1e-8){$widths.Add($maxWidth)}
$base=[IO.File]::ReadAllText((Join-Path $root $baseRel))
$oldKitchen='$cand=$m178.candidate;$counter=NewRect186 0 0.75 2 ([double]$cand.perimeter_run_ft) ''perimeter-run'''
$oldOpeningCheck="AddCheck186 'opening_reservation_crossed' (([Math]::Abs(`$openY-10)-lt1e-8)-and([Math]::Abs(`$openX-13.5)-lt1e-8))"
$oldDoorCheck="AddCheck186 'goal_is_nominal_porch_door' ((`$routeDoor.x-ge6)-and(`$routeDoor.x-le11)-and(`$routeDoor.y-eq24.5)) 'Route search ends at the nominal 5-ft porch-door reservation before extending 3 ft into the porch.'"
$oldTable="`$table=NewRect186 3 17.5 5 3 'dining-table'"
$oldChairs="`$chairs=@((NewRect186 3.5 15.8333333333 1.5 1.6666666667 'south-chair-1'),(NewRect186 6 15.8333333333 1.5 1.6666666667 'south-chair-2'),(NewRect186 1.3333333333 17.5 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.3333333333 19 1.6666666667 1.5 'west-chair-2'))"
$oldWalls="`$porchWalls=@((NewRect186 -0.5 24.5 6.5 0.5 'porch-wall-west-of-door'),(NewRect186 11 24.5 0.5 0.5 'porch-wall-east-of-door'))"
$oldObstacles="`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$halfwall,`$wallReturn,`$table)+`$chairs+`$porchWalls"
$oldRouteDoor="`$routeDoor=[pscustomobject]@{x=8.5;y=24.5}"
$oldEnd="`$routeEnd=[pscustomobject]@{x=8.5;y=27.5}"
$oldKitchenArea='elseif($mx-ge0-and$mx-le13.5-and$my-ge0-and$my-le14)'
$oldDiningArea='elseif($mx-ge0-and$mx-le11-and$my-ge14-and$my-le24)'
$oldPorchArea='elseif($mx-ge-0.5-and$mx-le11.5-and$my-ge24.5-and$my-le34.5)'
$pairs=@(@($oldKitchen,'candidate injection'),@($oldOpeningCheck,'opening check'),@($oldDoorCheck,'porch-door check'),@($oldTable,'table'),@($oldChairs,'chairs'),@($oldWalls,'porch walls'),@($oldObstacles,'obstacles'),@($oldRouteDoor,'porch door'),@($oldEnd,'porch terminus'),@($oldKitchenArea,'kitchen classifier'),@($oldDiningArea,'dining classifier'),@($oldPorchArea,'porch classifier'))
foreach($pair in $pairs){if(([regex]::Matches($base,[regex]::Escape([string]$pair[0]))).Count-ne1){throw "M186 source changed at $($pair[1]); refusing unreviewed transform."}}

$runs=New-Object System.Collections.Generic.List[object]
$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m197-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
$utf8=New-Object Text.UTF8Encoding($false)
try{
 foreach($width in $widths){
  $inject="`$m178.candidate.kitchen_rect_ft=@(0,0,$width,14);`$m178.candidate.kitchen_area_sf=[Math]::Round($width*14,6);`$m178.candidate.kitchen_over_target_sf=[Math]::Round((`$width*14)-168,6);`$m178.candidate.halfwall_rect_ft=@(($width-.5),0,.5,7);`n`$cand=`$m178.candidate;`$counter=NewRect186 0 0.75 2 ([double]`$cand.perimeter_run_ft) 'perimeter-run'"
  $table="`$table=NewRect186 3.5 15.5 3 5 'rotated-36x60-table'"
  $chairs="`$chairs=@((NewRect186 1.8333333333 16 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.8333333333 18.5 1.6666666667 1.5 'west-chair-2'),(NewRect186 6.5 16 1.6666666667 1.5 'east-chair-1'),(NewRect186 6.5 18.5 1.6666666667 1.5 'east-chair-2'))`n`$pullouts=@((NewRect186 .5 16 3 1.5 'west-chair-1-use-36in'),(NewRect186 .5 18.5 3 1.5 'west-chair-2-use-36in'),(NewRect186 6.5 16 3 1.5 'east-chair-1-use-36in'),(NewRect186 6.5 18.5 3 1.5 'east-chair-2-use-36in'))"
  $walls="`$porchWalls=@((NewRect186 -.5 24.5 3.5 .5 'porch-wall-west-of-door'),(NewRect186 8 24.5 3.5 .5 'porch-wall-east-of-door'))"
  $obstacles="`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$halfwall,`$wallReturn,`$table)+`$chairs+`$pullouts+`$porchWalls"
  $door="`$routeDoor=[pscustomobject]@{x=5.5;y=24.5}"
  $end="`$routeEnd=[pscustomobject]@{x=5.5;y=27.5}"
  $openingCheck="AddCheck186 'opening_reservation_crossed' (([Math]::Abs(`$openY-10)-lt1e-8)-and([Math]::Abs(`$openX-`$cand.kitchen_rect_ft[2])-lt1e-8))"
  $doorCheck="AddCheck186 'goal_is_dining_aligned_porch_door' (([Math]::Abs(`$routeDoor.x-5.5)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-24.5)-lt1e-8)) 'Route ends at the tested five-foot porch door centered on the dining block.'"
  $kitchenClassifier="elseif(`$mx-ge0-and`$mx-le$width-and`$my-ge0-and`$my-le14)"
  $generated=$base.Replace($oldKitchen,$inject).Replace($oldOpeningCheck,$openingCheck).Replace($oldDoorCheck,$doorCheck).Replace($oldTable,$table).Replace($oldChairs,$chairs).Replace($oldWalls,$walls).Replace($oldObstacles,$obstacles).Replace($oldRouteDoor,$door).Replace($oldEnd,$end).Replace($oldKitchenArea,$kitchenClassifier)
  $sub='.local/revalidation/'+$ScratchPrefix+'-'+$width.ToString('0.######').Replace('.','p');$full=Join-Path $root $sub
  if((Test-Path -LiteralPath $full)-and @(Get-ChildItem -LiteralPath $full -Force).Count-gt0){throw "Refusing to overwrite candidate scratch: $full"}
  [IO.File]::WriteAllText($temp,$generated,$utf8);& $temp -OutputDirectory $sub
  $report=Get-Content (Join-Path $full 'm186-route-search.json') -Raw|ConvertFrom-Json
  $runs.Add([pscustomobject]@{kitchen_width_ft=$width;kitchen_depth_ft=14;kitchen_area_sf=[Math]::Round($width*14,4);area_over_168sf_target=[Math]::Round(($width*14)-168,4);island_ft=@(8,4);opening_width_ft=6;path_found=[bool]$report.search.path_found;route_length_ft=$report.search.route_length_ft;route_turns=$report.search.route_turn_count;reachable_nodes=$report.search.centerline_bounds.reached_node_count;nearest_door_manhattan_ft=$report.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;checks_passed=$report.checks.passed;checks_total=$report.checks.total;M06_B_status=[string]$eastB.status})
 }
}finally{if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}
$first=@($runs|Where-Object path_found|Sort-Object kitchen_area_sf|Select-Object -First 1)
$result=if($first.Count){'route_found_in_one_or_more_width_samples'}else{'no_route_in_tested_width_samples'}
$checks=@(
 [pscustomobject]@{id='width_samples_span_m178_to_source_m02';pass=($runs.Count-eq17-and[Math]::Abs($runs[0].kitchen_width_ft-13.5)-lt1e-8-and[Math]::Abs($runs[-1].kitchen_width_ft-$maxWidth)-lt1e-8);detail='Quarter-foot cross-section increments reach, but do not exceed, the source M-02 width.'},
 [pscustomobject]@{id='every_embedded_m186_contract_passes';pass=(@($runs|Where-Object{$_.checks_passed-ne$_.checks_total}).Count-eq0);detail='Each generated full-shell search completed all source and route-contract checks.'},
 [pscustomobject]@{id='larger_island_preserved';pass=([double]$m178.candidate.island_rect_ft[2]-eq4-and[double]$m178.candidate.island_rect_ft[3]-eq8);detail='The 8 x 4 ft island source envelope is unchanged.'},
 [pscustomobject]@{id='B_unassigned';pass=([string]$eastB.status-match'Unassigned'-and@($runs|Where-Object M06_B_status-notmatch'Unassigned').Count-eq0);detail='Pantry-side M-06/B remains unassigned throughout the study.'},
 [pscustomobject]@{id='source_selected_d_unchanged';pass=($hashes[$selectedRel]-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Selected-D source hash remains protected.'},
 [pscustomobject]@{id='sweep_is_explicitly_nonselecting';pass=$true;detail='Width samples are a bounded sensitivity, not selected architectural dimensions.'}
)
$passed=@($checks|Where-Object pass).Count;$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$outReport=[ordered]@{schema='forever-home-m197-kitchen-envelope-route-search-v1';status=$status;design_result=$result;method='Quarter-foot kitchen-width samples from M178 width through source M-02 width; fixed 14-ft depth and one M195 rotated dining/porch arrangement; each uses the M186 full-shell 36-in route grid.';source_fingerprints_sha256=$hashes;selected_d_sha256=$hashes[$selectedRel];kitchen_search=[ordered]@{minimum_width_ft=13.5;maximum_width_ft=$maxWidth;sample_step_ft=.25;depth_ft=14;area_target_sf=168;island_body_ft=@(8,4);opening_width_ft=6;area_samples=$runs.Count;first_route_passing_sample=if($first.Count){$first[0]}else{$null};samples=$runs};route_contract=[ordered]@{width_in=36;grid_step_ft=.25;test_shell_ft=@(40,42);M06_B_status=[string]$eastB.status};checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('Only kitchen width varies; depth, counter run, island, stool proxy, opening elevation, dining/table/chair proxies and porch door remain fixed.','A first route-passing sample would be a minimum only along this one-dimensional quarter-foot sweep and this one dining arrangement, not a global minimum or approved dimension.','The added cross-section is test envelope only; actual walls, appliances, furniture movement, doors, thresholds, site geometry, services and tolerances are not modeled.','A route proxy does not establish code compliance, accessibility, structural adequacy, professional approval, permit approval or construction readiness.','Revit, IFC, selected-D and Incoming RFA files are unchanged; M-06/B stays unassigned.')}
[IO.File]::WriteAllText((Join-Path $out 'm197-kitchen-envelope-route-search.json'),(($outReport|ConvertTo-Json -Depth 40)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm197-checks.json'),(($outReport.checks|ConvertTo-Json -Depth 20)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm197-width-samples.csv'),((@($runs|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
if($passed-ne$checks.Count){throw "M197 integrity failed $passed/$($checks.Count); see $out"}
Write-Output "M197 pass $passed/$($checks.Count); $(@($runs|Where-Object path_found).Count)/$($runs.Count) width samples find a path; M-06/B remains unassigned."
