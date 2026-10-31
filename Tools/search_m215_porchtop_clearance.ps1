param(
    [string]$OutputDirectory='Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts',
    [string]$ScratchPrefix='M215',
    [ValidateSet(0.5,1.0)][double]$NorthTranslationFt=0.5
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}

$m213Script='Tools/search_m213_kitchen_margin_sensitivity.ps1'
$m213Out='.local/revalidation/'+$ScratchPrefix+'-base-m213'
& (Join-Path $root $m213Script) -OutputDirectory $m213Out -ScratchPrefix ($ScratchPrefix+'base')
$m213=Get-Content (Join-Path (Join-Path $root $m213Out) 'm213-kitchen-margin-sensitivity.json') -Raw|ConvertFrom-Json
$routeRel='.local/revalidation/'+$ScratchPrefix+'base-depth13_25_proxy_margin/m186-route-search.json'
$route=Get-Content (Join-Path $root $routeRel) -Raw|ConvertFrom-Json
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$selectedHash=(Get-FileHash (Join-Path $root $selectedRel) -Algorithm SHA256).Hash.ToLowerInvariant()
if($selectedHash-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M215.'}
if($m213.status-ne'pass'-or$route.checks.status-ne'pass'-or$route.checks.passed-ne31){throw 'M213 source run or M186 route contract did not pass.'}

function NewRect([double]$x,[double]$y,[double]$w,[double]$d,[string]$id){[pscustomobject]@{id=$id;x=$x;y=$y;w=$w;d=$d}}
function Gap([object]$a,[object]$b){$dx=[Math]::Max(0.0,[Math]::Max(([double]$a.x-([double]$b.x+[double]$b.w)),([double]$b.x-([double]$a.x+[double]$a.w))));$dy=[Math]::Max(0.0,[Math]::Max(([double]$a.y-([double]$b.y+[double]$b.d)),([double]$b.y-([double]$a.y+[double]$a.d))));[Math]::Round([Math]::Sqrt($dx*$dx+$dy*$dy),6)}
function IntersectionArea([object]$a,[object]$b){$ix=[Math]::Max(0.0,[Math]::Min(([double]$a.x+[double]$a.w),([double]$b.x+[double]$b.w))-[Math]::Max([double]$a.x,[double]$b.x));$iy=[Math]::Max(0.0,[Math]::Min(([double]$a.y+[double]$a.d),([double]$b.y+[double]$b.d))-[Math]::Max([double]$a.y,[double]$b.y));[Math]::Round($ix*$iy,8)}
function RouteRects([object[]]$points){
 $rects=New-Object System.Collections.Generic.List[object]
 for($i=0;$i-lt$points.Count-1;$i++){
  $a=$points[$i];$b=$points[$i+1]
  if([Math]::Abs([double]$a.y-[double]$b.y)-lt1e-9){$rects.Add((NewRect ([Math]::Min([double]$a.x,[double]$b.x)) ([double]$a.y-1.5) ([Math]::Abs([double]$b.x-[double]$a.x)) 3.0 ("route-{0}"-f$i)))}
  elseif([Math]::Abs([double]$a.x-[double]$b.x)-lt1e-9){$rects.Add((NewRect ([double]$a.x-1.5) ([Math]::Min([double]$a.y,[double]$b.y)) 3.0 ([Math]::Abs([double]$b.y-[double]$a.y)) ("route-{0}"-f$i)))}
  else{throw 'Candidate route contains a diagonal segment.'}
  if($i-gt0){$rects.Add((NewRect ([double]$a.x-1.5) ([double]$a.y-1.5) 3.0 3.0 ("corner-{0}"-f$i)))}
 }
 $rects.ToArray()
}

# M215 shifts only the M213 dining/porch blocks and their nominal porch-face
# wall segments 1 ft north. The test shell, room areas, kitchen and furniture
# proxies remain unchanged. The door center and route are comparison geometry.
$shift=$NorthTranslationFt
$candidate=$m213.candidate_placements[0]
$dining=NewRect ([double]$candidate.dining_rect_ft.x) ([double]$candidate.dining_rect_ft.y+$shift) ([double]$candidate.dining_rect_ft.w) ([double]$candidate.dining_rect_ft.d) 'M-03-dining'
$porch=NewRect ([double]$candidate.porch_rect_ft.x) ([double]$candidate.porch_rect_ft.y+$shift) ([double]$candidate.porch_rect_ft.w) ([double]$candidate.porch_rect_ft.d) 'three-season-porch'
$doorX=[double]$candidate.porch_door_center_ft[0];$doorY=[double]$candidate.porch_door_center_ft[1]+$shift
$routeEndY=$doorY+3.0
$routeY=28.5+($shift/2.0)
$points=@(
 [pscustomobject]@{x=19.5;y=10.0},
 [pscustomobject]@{x=18.5;y=10.0},
 [pscustomobject]@{x=18.5;y=$routeY},
 [pscustomobject]@{x=$doorX;y=$routeY},
 [pscustomobject]@{x=$doorX;y=$routeEndY}
)
$routeRects=RouteRects $points
$obstacles=New-Object System.Collections.Generic.List[object]
foreach($raw in $route.search.modeled_obstacles){$y=[double]$raw.y;if([string]$raw.id -like 'porch-wall-*'){$y+=$shift};$obstacles.Add((NewRect ([double]$raw.x) $y ([double]$raw.w) ([double]$raw.d) ([string]$raw.id)))}
$clearances=New-Object System.Collections.Generic.List[object]
foreach($o in $obstacles){$gap=[double]::PositiveInfinity;foreach($r in $routeRects){$g=Gap $r $o;if($g-lt$gap){$gap=$g}};$clearances.Add([pscustomobject]@{obstacle=$o.id;minimum_route_edge_gap_ft=[Math]::Round($gap,6)})}
$minimumGap=($clearances|Measure-Object minimum_route_edge_gap_ft -Minimum).Minimum
$length=0.0;for($i=0;$i-lt$points.Count-1;$i++){$length+=[Math]::Abs([double]$points[$i+1].x-[double]$points[$i].x)+[Math]::Abs([double]$points[$i+1].y-[double]$points[$i].y)}

$west=@($obstacles|Where-Object id -eq 'west_of_core')[0]
$east=@($obstacles|Where-Object id -eq 'east_of_core')[0]
$westTop=[double]$west.y+[double]$west.d
$porchWallY=[double]$candidate.porch_rect_ft.y+$shift
$routeBandMinY=$westTop+1.5+0.25
$routeBandMaxY=$porchWallY-1.5-0.25
$minimumContinuousShift=$routeBandMinY-([double]$candidate.porch_rect_ft.y-1.5-0.25)
$minimumQuarterFootShift=[Math]::Ceiling($minimumContinuousShift/0.25)*0.25
$aRect=NewRect ([double]$west.x) ([double]$west.y) ([double]$west.w-0.25) ([double]$west.d) 'west-A-original'
$bRaw=@($obstacles|Where-Object id -eq 'east_of_core')[0]
$bRect=NewRect ([double]$bRaw.x) ([double]$bRaw.y) ([double]$bRaw.w) ([double]$bRaw.d) 'east-B-unassigned'
$aDining=IntersectionArea $aRect $dining;$aPorch=IntersectionArea $aRect $porch
$bDining=IntersectionArea $bRect $dining;$bPorch=IntersectionArea $bRect $porch
$shellOk=($dining.x-ge-0.6666666667-and$dining.y-ge-0.6666666667-and($dining.x+$dining.w)-le39.3333333333-and($dining.y+$dining.d)-le41.3333333333-and$porch.x-ge-0.6666666667-and$porch.y-ge-0.6666666667-and($porch.x+$porch.w)-le39.3333333333-and($porch.y+$porch.d)-le41.3333333333)
$furnitureInside=@($obstacles|Where-Object{$_.id -match 'table|chair'}|Where-Object{$_.x-lt$dining.x-1e-8-or$_.y-lt$dining.y-1e-8-or($_.x+$_.w)-gt($dining.x+$dining.w)+1e-8-or($_.y+$_.d)-gt($dining.y+$dining.d)+1e-8}).Count-eq0
$doorOpening=[pscustomobject]@{x=$doorX-2.5;y=$doorY;w=5.0;d=0.0}
$doorInside=($doorOpening.x-ge$porch.x-and($doorOpening.x+$doorOpening.w)-le($porch.x+$porch.w))
$checks=@(
 [pscustomobject]@{id='M213_and_M186_source_runs_pass';pass=($m213.status-eq'pass'-and$route.checks.passed-eq31);detail='The exact M213 candidate is regenerated before M215 geometry is derived.'},
 [pscustomobject]@{id='selected_D_fingerprint_unchanged';pass=($selectedHash-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Protected selected-D source hash is unchanged.'},
 [pscustomobject]@{id='36in_orthogonal_route_to_porch';pass=($points.Count-eq5-and[Math]::Abs($length-(33.5+$shift))-lt1e-8);detail='A continuous 36-in schematic route connects the open living edge to the porch terminus.'},
 [pscustomobject]@{id='positive_clearance_to_every_modeled_obstacle';pass=($minimumGap-ge0.25);detail='The swept route corridor remains at least 3 in from every M186 obstacle, including the expanded A reservation and shifted porch-wall segments.'},
 [pscustomobject]@{id='route_centerline_fits_A_to_porch_clearance_band';pass=($routeBandMinY-le$routeBandMaxY-and$routeY-ge$routeBandMinY-1e-8-and$routeY-le$routeBandMaxY+1e-8);detail='The horizontal route centerline clears the protected-A north edge and porch-face wall by the 3-in analysis buffer.'},
 [pscustomobject]@{id='quarter_foot_grid_translation_lower_bound';pass=([Math]::Abs($minimumContinuousShift-0.4166666667)-lt1e-6-and$minimumQuarterFootShift-eq0.5-and$shift-ge$minimumQuarterFootShift);detail='The vertical gap requires at least 0.4167 ft north translation; the first 0.25-ft search increment satisfying it is 0.5 ft.'},
 [pscustomobject]@{id='A_and_B_remain_clear_of_moved_social_blocks';pass=($aDining-eq0-and$aPorch-eq0-and$bDining-eq0-and$bPorch-eq0);detail='Dining and porch blocks have no area overlap with protected west A or the unassigned east B search reservation.'},
 [pscustomobject]@{id='dining_and_porch_within_hypothetical_shell';pass=$shellOk;detail='The 11 x 10 ft dining and 12 x 10 ft porch test blocks remain inside the 40 x 42 ft comparison shell.'},
 [pscustomobject]@{id='dining_furniture_and_use_zones_contained';pass=$furnitureInside;detail='All inherited dining table, chair and chair-use proxy rectangles remain inside the translated dining block.'},
 [pscustomobject]@{id='nominal_door_opening_within_porch_face';pass=$doorInside;detail='The tested nominal 5-ft porch opening fits the translated porch face.'},
 [pscustomobject]@{id='M06_B_remains_unassigned';pass=([string]$m213.route_contract.M06_B_status -match 'Unassigned');detail='No bathroom footprint or room assignment is introduced.'},
 [pscustomobject]@{id='kitchen_and_island_test_dimensions_inherited';pass=([double]$candidate.kitchen_depth_ft-eq13.25-and[double]$candidate.kitchen_area_sf-eq178.875-and[double]$candidate.route_length_ft-eq33.5);detail='The tested kitchen, island and route source remains the unselected M213 comparison.'}
)
$passed=@($checks|Where-Object pass).Count
$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$sourceRels=@($m213Script,'Tools/search_m186_public_route.ps1','Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json','Architecture/Selected_Design_Iteration_2026-10-27/study.json','Decisions/2026-10-31_M06_West_A_Protection.md','Decisions/2026-10-31_Kitchen_Area_Priority.md','Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md')
$hashes=[ordered]@{};foreach($rel in $sourceRels){$hashes[$rel]=(Get-FileHash (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$report=[ordered]@{schema='forever-home-m215-porch-approach-clearance-v1';status=$status;design_result='route_positive_3in_proxy_separation_passes;not_selected';method="Hold the M213 13.25 x 13.5 ft kitchen comparison, pantry, furniture and route width fixed. Translate only the 11 x 10 ft dining block, 12 x 10 ft porch, and their nominal face-wall segments $shift ft north within the source-comparison shell bounds. Test the explicitly defined orthogonal route and nominal 5-ft porch opening. The 3-in minimum route-obstacle separation is an analysis criterion only.";source_fingerprints_sha256=$hashes;selected_D_sha256=$selectedHash;owner_protected_A=$true;M06_B_status=[string]$m213.route_contract.M06_B_status;translation_north_ft=$shift;minimum_continuous_north_shift_for_3in_band_ft=[Math]::Round($minimumContinuousShift,6);minimum_quarter_foot_grid_shift_ft=$minimumQuarterFootShift;route_centerline_band_y_ft=@([Math]::Round($routeBandMinY,6),[Math]::Round($routeBandMaxY,6));test_shell_ft=@(40,42);kitchen_candidate=[ordered]@{depth_ft=13.25;cross_section_ft=13.5;area_sf=178.875;program_target_sf=168;island_ft=@(8,4);status='inherited schematic comparison; not selected'};dining_rect_ft=@($dining.x,$dining.y,$dining.w,$dining.d);porch_rect_ft=@($porch.x,$porch.y,$porch.w,$porch.d);nominal_door_center_ft=@($doorX,$doorY);route_width_in=36;route_waypoints_ft=$points;route_length_ft=[Math]::Round($length,4);minimum_obstacle_gap_ft=$minimumGap;clearance_to_original_A_ft=([double](@($clearances|Where-Object obstacle -eq 'west_of_core')[0].minimum_route_edge_gap_ft)+0.25);obstacle_clearances=$clearances.ToArray();protected_A_dining_overlap_sf=$aDining;protected_A_porch_overlap_sf=$aPorch;unassigned_B_dining_overlap_sf=$bDining;unassigned_B_porch_overlap_sf=$bPorch;dining_furniture_and_use_zones_inside=$furnitureInside;checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('This is one bounded path and layout sample, not an exhaustive search or selected design.','The kitchen, island, stool, pantry, dining use-zones, porch opening and shell remain schematic proxies or hypothetical comparison inputs.','A 3-in geometric gap is an analytical threshold, not an established circulation, accessibility, product or code requirement.','Physical walls, rough openings, door leaf/swing, thresholds, occupied movement, site fit, construction tolerance and services are not modeled.','Selected-D, Revit, IFC and source RFAs are unchanged. No code, accessibility, structural, professional, permit or construction-readiness conclusion is made.')}
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm215-porch-approach-clearance.json'),(($report|ConvertTo-Json -Depth 40)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm215-checks.json'),(($report.checks|ConvertTo-Json -Depth 30)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm215-obstacle-clearances.csv'),((@($clearances|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
if($passed-ne$checks.Count){throw "M215 failed $passed/$($checks.Count); see $out"}
Write-Output "M215 passed $passed/$($checks.Count); 36-in proxy route=$($report.route_length_ft) ft; minimum obstacle gap=$minimumGap ft; M-06/B remains unassigned."
