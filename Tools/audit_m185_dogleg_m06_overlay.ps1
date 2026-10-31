param([string]$OutputDirectory='Architecture/M185_Dogleg_M06_Overlay_2026-10-31/artifacts')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
$m172Rel='Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'
$m173Rel='Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$m178Rel='Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json'
$m179Rel='Architecture/M179_Pantry_Route_Clearance_Audit_2026-10-31/m179-study.json'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$inputs=@($m172Rel,$m173Rel,$bathRel,$m178Rel,$m179Rel,$selectedRel)
foreach($r in $inputs){if(-not(Test-Path -LiteralPath (Join-Path $root $r) -PathType Leaf)){throw "Missing source: $r"}}
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count -gt 0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}
function GetHash185([string]$r){(Get-FileHash -LiteralPath (Join-Path $root $r) -Algorithm SHA256).Hash.ToLowerInvariant()}
function NewRect185([double]$x,[double]$y,[double]$w,[double]$d,[string]$id){[pscustomobject]@{id=$id;x=$x;y=$y;w=$w;d=$d}}
function Rects([object[]]$pts,[double]$width,[string]$prefix){
 $a=New-Object System.Collections.Generic.List[object]
 for($i=0;$i-lt$pts.Count-1;$i++){$p=$pts[$i];$q=$pts[$i+1]
  if([Math]::Abs([double]$p.x-[double]$q.x)-lt1e-7){$rect=NewRect185 ([double]$p.x-$width/2) ([Math]::Min([double]$p.y,[double]$q.y)) $width ([Math]::Abs([double]$q.y-[double]$p.y)) "$prefix-segment-$i";$a.Add($rect)}
  elseif([Math]::Abs([double]$p.y-[double]$q.y)-lt1e-7){$rect=NewRect185 ([Math]::Min([double]$p.x,[double]$q.x)) ([double]$p.y-$width/2) ([Math]::Abs([double]$q.x-[double]$p.x)) $width "$prefix-segment-$i";$a.Add($rect)}
  else{throw "Route $prefix has a non-orthogonal segment."}
  if($i-gt0){$rect=NewRect185 ([double]$p.x-$width/2) ([double]$p.y-$width/2) $width $width "$prefix-corner-$i";$a.Add($rect)}
 }
 return $a.ToArray()
}
function Area([object]$a,[object]$b){$dx=[Math]::Min(([double]$a.x+[double]$a.w),([double]$b.x+[double]$b.w))-[Math]::Max([double]$a.x,[double]$b.x);$dy=[Math]::Min(([double]$a.y+[double]$a.d),([double]$b.y+[double]$b.d))-[Math]::Max([double]$a.y,[double]$b.y);if($dx-gt1e-7-and$dy-gt1e-7){return [Math]::Round($dx*$dy,6)};return 0.0}
$m172=Get-Content (Join-Path $root $m172Rel) -Raw|ConvertFrom-Json
$m173=Get-Content (Join-Path $root $m173Rel) -Raw|ConvertFrom-Json
$bath=Get-Content (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$m178=Get-Content (Join-Path $root $m178Rel) -Raw|ConvertFrom-Json
$m179=Get-Content (Join-Path $root $m179Rel) -Raw|ConvertFrom-Json
$selectedHash=GetHash185 $selectedRel
$origin=@($bath.plans.main|Where-Object id -eq 'M-02')[0]
$livingSource=@($bath.plans.main|Where-Object id -eq 'M-01')[0]
$pantrySource=@($bath.plans.main|Where-Object id -eq 'M-04')[0]
$living=NewRect185 ([double]$livingSource.x-[double]$origin.x) ([double]$livingSource.y-[double]$origin.y) ([double]$livingSource.w) ([double]$livingSource.d) 'M-01-living'
$pantry=NewRect185 ([double]$pantrySource.x-[double]$origin.x) ([double]$pantrySource.y-[double]$origin.y) ([double]$pantrySource.w) ([double]$pantrySource.d) 'M-04-pantry'
$windowSources=@($bath.selection.main_public_bath.search_windows)
$eastSource=@($windowSources|Where-Object id -eq 'east_of_core')[0]
$windows=@();foreach($w in $windowSources){$windows+=,(NewRect185 ([double]$w.x-[double]$origin.x) ([double]$w.y-[double]$origin.y) ([double]$w.w) ([double]$w.d) ([string]$w.id))}
$west=@($windows|Where-Object id -eq 'west_of_core')[0];$east=@($windows|Where-Object id -eq 'east_of_core')[0]
$oldPoints=@($m179.dogleg_route.centerline_ft)
$newPoints=@();foreach($p in $oldPoints){$y=[double]$p.y;if(([double]$p.x-eq11.25-or[double]$p.x-eq9.5)-and[double]$p.y-eq14.5){$y=13.5};$newPoints+=,[pscustomobject]@{x=[double]$p.x;y=$y}}
$oldRects=@(Rects $oldPoints 3.0 'm179-dogleg')
$newRects=@(Rects $newPoints 3.0 'm185-earlier-turn')
$crossSection=$m178.candidate.cross_section
$counter=NewRect185 0 0.75 2 12.5 'perimeter-run'
$islandBox=@($m178.candidate.island_rect_ft);$island=NewRect185 $islandBox[0] $islandBox[1] $islandBox[2] $islandBox[3] 'island'
$stoolBox=@($m178.candidate.assumed_stool_rect_ft);$stools=NewRect185 $stoolBox[0] $stoolBox[1] $stoolBox[2] $stoolBox[3] 'assumed-stool-occupancy'
$halfBox=@($m178.candidate.halfwall_rect_ft);$wall=NewRect185 $halfBox[0] $halfBox[1] $halfBox[2] $halfBox[3] 'half-wall'
$wallReturn=NewRect185 13 13 0.5 1 'half-wall-return'
$table=NewRect185 3 17.5 5 3 'dining-table'
$chairs=@((NewRect185 3.5 15.8333333333 1.5 1.6666666667 'south-chair-1'),(NewRect185 6 15.8333333333 1.5 1.6666666667 'south-chair-2'),(NewRect185 1.3333333333 17.5 1.6666666667 1.5 'west-chair-1'),(NewRect185 1.3333333333 19 1.6666666667 1.5 'west-chair-2'))
$porchWalls=@((NewRect185 -0.5 24.5 6.5 0.5 'porch-wall-west-of-door'),(NewRect185 11 24.5 0.5 0.5 'porch-wall-east-of-door'))
$modeled=@($counter,$island,$stools,$wall,$wallReturn,$table)+$chairs+$porchWalls
function Inspect([object[]]$route,[object[]]$obs){$hits=New-Object System.Collections.Generic.List[object];foreach($r in $route){foreach($o in $obs){$a=Area $r $o;if($a-gt0){$hits.Add([ordered]@{route_rect=$r.id;obstacle=$o.id;overlap_sf=$a})}}};return $hits.ToArray()}
function UnionArea185([object[]]$route,[object]$target){
 $clips=New-Object System.Collections.Generic.List[object]
 foreach($r in $route){$x0=[Math]::Max([double]$r.x,[double]$target.x);$x1=[Math]::Min(([double]$r.x+[double]$r.w),([double]$target.x+[double]$target.w));$y0=[Math]::Max([double]$r.y,[double]$target.y);$y1=[Math]::Min(([double]$r.y+[double]$r.d),([double]$target.y+[double]$target.d));if($x1-gt$x0-and$y1-gt$y0){$clips.Add([pscustomobject]@{x0=$x0;x1=$x1;y0=$y0;y1=$y1})}}
 $xs=@($clips|ForEach-Object{[double]$_.x0;[double]$_.x1}|Sort-Object -Unique);$area=0.0
 for($i=0;$i-lt$xs.Count-1;$i++){$dx=$xs[$i+1]-$xs[$i];if($dx-le1e-9){continue};$mid=($xs[$i]+$xs[$i+1])/2;$ints=@($clips|Where-Object{$_.x0-lt$mid-and$_.x1-gt$mid}|Sort-Object y0);if($ints.Count-gt0){$start=[double]$ints[0].y0;$end=[double]$ints[0].y1;$covered=0.0;for($j=1;$j-lt$ints.Count;$j++){if([double]$ints[$j].y0-le$end){$end=[Math]::Max($end,[double]$ints[$j].y1)}else{$covered+=$end-$start;$start=[double]$ints[$j].y0;$end=[double]$ints[$j].y1}};$covered+=$end-$start;$area+=$dx*$covered}}
 return [Math]::Round($area,6)
}
function RectGap185([object]$a,[object]$b){$dx=[Math]::Max(0.0,[Math]::Max(([double]$a.x-([double]$b.x+[double]$b.w)),([double]$b.x-([double]$a.x+[double]$a.w))));$dy=[Math]::Max(0.0,[Math]::Max(([double]$a.y-([double]$b.y+[double]$b.d)),([double]$b.y-([double]$a.y+[double]$a.d))));return [Math]::Sqrt($dx*$dx+$dy*$dy)}
$oldWest=Inspect $oldRects @($west);$oldPantry=Inspect $oldRects @($pantry);$oldEast=Inspect $oldRects @($east)
$newModeled=Inspect $newRects $modeled;$newWest=Inspect $newRects @($west);$newPantry=Inspect $newRects @($pantry);$newEast=Inspect $newRects @($east)
$minWestGap=[double]::PositiveInfinity;foreach($r in $newRects){$g=RectGap185 $r $west;if($g-lt$minWestGap){$minWestGap=$g}}
$a=New-Object System.Collections.Generic.List[object]
function Check([string]$id,[bool]$pass,[string]$detail){$script:a.Add([ordered]@{id=$id;pass=$pass;detail=$detail})}
$sourceMatch=$true;foreach($r in $m179.source_fingerprints_sha256.PSObject.Properties){if((GetHash185 $r.Name)-ne([string]$r.Value).ToLowerInvariant()){$sourceMatch=$false}}
$incoming=Get-ChildItem (Join-Path $root 'Revit/Family_Intake/Incoming') -Filter '*.rfa' -File
$incomingHashes=@();foreach($f in $incoming){$incomingHashes+=,[ordered]@{file=$f.Name;sha256=(Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()}}
Check 'm179_sources_current' $sourceMatch 'Every fingerprint bound by the source M179 route audit matches the current repository.'
Check 'selected_d_baseline_current' (($selectedHash-eq([string]$m178.source_fingerprints_sha256.'Architecture/Selected_Design_Iteration_2026-10-27/study.json'))-and($selectedHash-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb')) 'Selected-D source matches the protected baseline fingerprint recorded in M178.'
Check 'm06_zone_source' ($bath.selection.main_public_bath.owner_selected_first_fit_candidate-eq'east_of_core') 'Bath-first source retains the owner-selected pantry-side search candidate.'
Check 'm06_b_unassigned' ([string]$eastSource.status-match'Unassigned') 'East/pantry-side B remains an unassigned search window.'
Check 'm179_start_not_misrepresented_as_living' (([double]$oldPoints[0].x-lt[double]$living.x)-or([double]$oldPoints[0].x-gt([double]$living.x+[double]$living.w))) 'M179 begins outside source M-01; the dogleg is not a complete living-to-porch route.'
Check 'incoming_family_sources_present' ($incoming.Count-ge3) 'The three protected untracked manufacturer RFAs remain present in Incoming.'
Check 'incoming_family_hashes_recorded' ($incomingHashes.Count-eq$incoming.Count-and@($incomingHashes|Where-Object{$_.sha256-match'^[0-9a-f]{64}$'}).Count-eq$incoming.Count) 'Every RFA currently in Incoming has a SHA256 fingerprint in the report.'
Check 'original_dogleg_clears_pantry' ($oldPantry.Count-eq0) 'M179 dogleg remains clear of the bath-first pantry block.'
Check 'original_dogleg_clips_west_diagnostic' ($oldWest.Count-gt0) 'M179 dogleg full-width elbow overlaps the blocked west M-06 diagnostic window.'
Check 'original_dogleg_clears_east_B' ($oldEast.Count-eq0) 'M179 dogleg does not intersect the unassigned east/pantry-side B window.'
$orthogonal=$newPoints.Count-ge2;for($i=0;$i-lt$newPoints.Count-1;$i++){if(([Math]::Abs([double]$newPoints[$i].x-[double]$newPoints[$i+1].x)-gt1e-7) -and ([Math]::Abs([double]$newPoints[$i].y-[double]$newPoints[$i+1].y)-gt1e-7)){$orthogonal=$false}}
Check 'earlier_turn_orthogonal' $orthogonal 'Earlier-turn route retains an axis-aligned waypoint sequence.'
Check 'earlier_turn_clears_pantry' ($newPantry.Count-eq0) 'Earlier-turn route is clear of the source pantry block.'
Check 'earlier_turn_clears_west_diagnostic' ($newWest.Count-eq0) 'Earlier-turn corridor rectangles stay outside the blocked west M-06 diagnostic window.'
Check 'earlier_turn_clears_east_B' ($newEast.Count-eq0) 'Earlier-turn route stays outside the owner-selected east B search window.'
Check 'earlier_turn_west_edge_gap_recomputed' ([Math]::Abs(($minWestGap*12)-4)-lt0.001) 'Minimum rectangle-to-rectangle separation from the west diagnostic is recomputed as only 4 in.'
Check 'earlier_turn_stool_conflict_recorded' (@($newModeled|Where-Object obstacle -eq 'assumed-stool-occupancy').Count-gt0) 'Earlier turn conflicts with the explicitly assumed stool-occupancy proxy; it is not promoted as a clear route.'
Check 'earlier_turn_clears_other_modeled_proxies' (@($newModeled|Where-Object obstacle -ne 'assumed-stool-occupancy').Count-eq0) 'Earlier turn introduces no other positive-area overlap with counter, island, half-wall, dining furniture or porch-wall proxies.'
Check '36_in_route_width' ([double]$m179.dogleg_route.width_in-eq36) 'Both options use the same documented 36-in route-width proxy.'
Check 'kitchen_area_tradeoff_preserved' ([double]$m178.candidate.kitchen_over_target_sf-eq21) 'M178 remains a 189 sf proposal, explicitly 21 sf above the owner-directed 168 sf target.'
Check 'porch_terminus_preserved' ([Math]::Abs(([double]$newPoints[-1].y-[double]$m178.candidate.porch_rect_ft[1])-3)-lt0.001) 'The revised route still extends 3 ft into the porch test rectangle.'
$sweep=New-Object System.Collections.Generic.List[object]
$bestSample=$null
for($turnY=13.0;$turnY-le15.000001;$turnY+=0.25){$pts=@();for($i=0;$i-lt$oldPoints.Count;$i++){$yy=[double]$oldPoints[$i].y;if($i-eq2-or$i-eq3){$yy=$turnY};$pts+=,[pscustomobject]@{x=[double]$oldPoints[$i].x;y=$yy}};$rr=@(Rects $pts 3.0 ("turn-{0:F2}" -f $turnY));$westArea=UnionArea185 $rr $west;$stoolArea=UnionArea185 $rr $stools;$totalArea=[Math]::Round(($westArea+$stoolArea),6);$row=[ordered]@{turn_center_y_ft=[Math]::Round($turnY,2);west_diagnostic_union_overlap_sf=$westArea;assumed_stool_union_overlap_sf=$stoolArea;total_of_two_union_overlaps_sf=$totalArea;both_clear=($westArea-eq0-and$stoolArea-eq0)};$sweep.Add($row);if($null-eq$bestSample-or$totalArea-lt[double]$bestSample.total_of_two_union_overlaps_sf){$bestSample=$row}}
Check 'single_turn_sensitivity_no_false_clearance' (@($sweep|Where-Object both_clear).Count-eq0) 'The tested 13.00-15.00 ft quarter-foot single-elbow sweep has no sampled point clear of both the blocked west diagnostic and assumed stool proxy.'
$passed=@($a|Where-Object pass).Count;$status='fail';if($passed-eq$a.Count){$status='pass'}
$hashes=[ordered]@{};foreach($r in $inputs){$hashes[$r]=GetHash185 $r}
$kitchenEast=[double]$m178.candidate.kitchen_rect_ft[0]+[double]$m178.candidate.kitchen_rect_ft[2]
$livingGap=[double]$living.x-$kitchenEast
$report=[ordered]@{schema='forever-home-m185-dogleg-m06-overlay-v1';status='unapproved route conflict comparison; no room or route selected';source_fingerprints_sha256=$hashes;incoming_rfa_hashes=$incomingHashes;selected_d_sha256=$selectedHash;candidate_context=[ordered]@{kitchen_area_sf=[double]$m178.candidate.kitchen_area_sf;kitchen_program_target_sf=[double]$m178.program_targets.kitchen_area_sf;kitchen_over_target_sf=[double]$m178.candidate.kitchen_over_target_sf;route_width_in=36;M06_B_status=[string]$eastSource.status};living_interface=[ordered]@{source_M01_rect_local_ft=@([double]$living.x,[double]$living.y,[double]$living.w,[double]$living.d);kitchen_east_edge_ft=$kitchenEast;unassigned_kitchen_to_living_band_ft=[Math]::Round($livingGap,6);M179_start_ft=@([double]$oldPoints[0].x,[double]$oldPoints[0].y);M179_start_inside_M01=($oldPoints[0].x-ge$living.x-and$oldPoints[0].x-le($living.x+$living.w)-and$oldPoints[0].y-ge$living.y-and$oldPoints[0].y-le($living.y+$living.d))};m06_windows_local_to_kitchen_origin_ft=@([ordered]@{id='west_of_core';x=[double]$west.x;y=[double]$west.y;w=[double]$west.w;d=[double]$west.d},[ordered]@{id='east_of_core';x=[double]$east.x;y=[double]$east.y;w=[double]$east.w;d=[double]$east.d});pantry_local_to_kitchen_origin_ft=[ordered]@{x=[double]$pantry.x;y=[double]$pantry.y;w=[double]$pantry.w;d=[double]$pantry.d};M179_route=[ordered]@{centerline_ft=$oldPoints;west_diagnostic_intersections=$oldWest;west_diagnostic_union_overlap_sf=(UnionArea185 $oldRects $west);pantry_intersections=$oldPantry;east_B_intersections=$oldEast};M185_earlier_turn=[ordered]@{centerline_ft=$newPoints;width_in=36;turn_shift_ft=1;turn_y_ft=13.5;route_rectangles_ft=$newRects;west_diagnostic_intersections=$newWest;pantry_intersections=$newPantry;east_B_intersections=$newEast;existing_proxy_intersections=$newModeled;assumed_stool_union_overlap_sf=(UnionArea185 $newRects $stools);west_diagnostic_union_overlap_sf=(UnionArea185 $newRects $west);minimum_edge_gap_to_west_diagnostic_in=[Math]::Round(($minWestGap*12),6);porch_depth_reached_ft=[Math]::Round(([double]$newPoints[-1].y-[double]$m178.candidate.porch_rect_ft[1]),6)};single_turn_sensitivity=$sweep.ToArray();lowest_sampled_total_overlap=$bestSample;checks=[ordered]@{status=$status;passed=$passed;total=$a.Count;items=$a.ToArray()};conclusion='The M179 dogleg is not a complete living-to-porch route: its start at (14.5,10) ft lies in the 4 ft 4 in unassigned band between M-02 and source M-01. The route also overlaps the blocked west M-06 diagnostic by 0.708 sf. Moving the west turn 1 ft earlier removes that overlap but creates a 1.5 sf union overlap with the assumed stool-occupancy proxy; the quarter-foot single-elbow sensitivity sweep has no tested setting that clears both. East/pantry-side M-06/B stays clear but unassigned. Neither route nor room is selected.';limitations=@('All room blocks, M-06 windows, routes and fixture/furniture envelopes are schematic rectangles in a shared source coordinate frame.','The M179 start lies in an unassigned band; no physical opening or connection from living has been established.','The west M-06 rectangle is a blocked diagnostic, not a physical room; avoiding it is not an approach, door or code clearance.','The stool occupied-use zone is an explicit 24-in-deep assumption, not measured family geometry.','This candidate has no verified shell fit, walls/openings, door swing, furniture movement, appliance-open route, services, Revit host geometry or IFC export.','Kitchen test area remains 21 sf above the owner-directed program target.','M-06/B stays unassigned; no accessibility, code, structural-safety, professional, permit or construction-readiness conclusion follows.')}
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm185-dogleg-m06-overlay.json'),(($report|ConvertTo-Json -Depth 40)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm185-checks.json'),(($report.checks|ConvertTo-Json -Depth 30)+"`n"),$utf8)
$rows=@();foreach($r in $sweep){$rows+=,[pscustomobject]@{route=('single elbow turn y={0:F2} ft' -f $r.turn_center_y_ft);west_diagnostic_union_overlap_sf=$r.west_diagnostic_union_overlap_sf;assumed_stool_union_overlap_sf=$r.assumed_stool_union_overlap_sf;total_of_two_union_overlaps_sf=$r.total_of_two_union_overlaps_sf;both_clear=$r.both_clear}}
[IO.File]::WriteAllText((Join-Path $out 'm185-route-comparison.csv'),((@($rows|ConvertTo-Csv -NoTypeInformation)-join "`n")+"`n"),$utf8)
$svg=@'
<svg xmlns="http://www.w3.org/2000/svg" width="900" height="740" viewBox="-2 -2 42 35" role="img" aria-labelledby="title desc">
<title id="title">M185 schematic route against M-06 search windows</title><desc id="desc">An unapproved 13.5 by 14 foot kitchen, dining test zone and porch are shown with the M179 dogleg and a one-foot-earlier turn. M-06 windows remain diagnostic and unassigned.</desc>
<g transform="scale(20,-20) translate(0,-31)" font-family="Arial,sans-serif">
<rect x="0" y="0" width="13.5" height="14" fill="#fff8e8" stroke="#806b45" stroke-width=".08"/><rect x="0" y="14" width="11" height="10" fill="#edf4fb" stroke="#58748f" stroke-width=".08"/><rect x="-.5" y="24.5" width="12" height="10" fill="#eaf4e8" stroke="#60815b" stroke-width=".08"/>
<rect x="0" y=".75" width="2" height="12.5" fill="#bba989"/><rect x="5.5" y="3" width="4" height="8" fill="#d9c8a4" stroke="#806b45" stroke-width=".08"/><rect x="5.5" y="11" width="4" height="2" fill="#f7d5b5" stroke="#bc6c38" stroke-width=".06"/><rect x="13" y="0" width=".5" height="7" fill="#8a8983"/><rect x="13" y="13" width=".5" height="1" fill="#8a8983"/>
<rect x="3" y="17.5" width="5" height="3" fill="#b7c4cf"/><rect x="3.5" y="15.8333" width="1.5" height="1.667" fill="#aeb7bf"/><rect x="6" y="15.8333" width="1.5" height="1.667" fill="#aeb7bf"/><rect x="1.333" y="17.5" width="1.667" height="1.5" fill="#aeb7bf"/><rect x="1.333" y="19" width="1.667" height="1.5" fill="#aeb7bf"/>
<rect x="11.3333" y="15.5" width="5.1667" height="11.4167" fill="#efc8c8" fill-opacity=".7" stroke="#b53f3f" stroke-width=".08"/><rect x="20.5" y="16.5" width="13.1667" height="7" fill="#d8ead6" fill-opacity=".75" stroke="#4e8050" stroke-width=".08"/>
<polyline points="14.5,10 11.25,10 11.25,14.5 9.5,14.5 9.5,22.5 8.5,22.5 8.5,27.5" fill="none" stroke="#b34b78" stroke-width=".22" stroke-linejoin="round" stroke-linecap="square"/>
<polyline points="14.5,10 11.25,10 11.25,13.5 9.5,13.5 9.5,22.5 8.5,22.5 8.5,27.5" fill="none" stroke="#167f75" stroke-width=".12" stroke-linejoin="round" stroke-linecap="square"/>
<g transform="scale(1,-1)"><text x=".2" y="-1" font-size=".55">Kitchen test 13.5 x 14 ft (+21 sf)</text><text x=".2" y="-15" font-size=".55">Dining target zone 11 x 10 ft</text><text x="21" y="-19" font-size=".55">M-06/B search gap (unassigned)</text><text x="11.5" y="-15.2" font-size=".5">Blocked A diagnostic</text><text x="-0.4" y="-30" font-size=".55">Porch test zone</text></g>
</g></svg>
'@
[IO.File]::WriteAllText((Join-Path $out 'm185-plan.svg'),$svg,$utf8)
$null=[xml](Get-Content (Join-Path $out 'm185-plan.svg') -Raw)
Write-Output ("M185: {0}/{1}; original dogleg west-window overlaps={2}; earlier-turn overlaps={3}; pantry/B/proxy overlaps={4}/{5}/{6}; selected-D unchanged." -f $passed,$a.Count,$oldWest.Count,$newWest.Count,$newPantry.Count,$newEast.Count,$newModeled.Count)
if($passed-ne$a.Count){exit 1}
