param([string]$OutputDirectory='Architecture/M184_Social_Route_Pantry_Overlay_2026-10-31/artifacts')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$socialRel='Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
function Hash184([string]$relative){$path=Join-Path $root $relative;if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing input $relative"};(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()}
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count -gt 0){throw "Refusing to overwrite nonempty output directory $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out -Force|Out-Null}
$bath=Get-Content -LiteralPath (Join-Path $root $bathRel) -Raw|ConvertFrom-Json
$social=Get-Content -LiteralPath (Join-Path $root $socialRel) -Raw|ConvertFrom-Json
$selectedHash=Hash184 $selectedRel
$m02=@($bath.plans.main|Where-Object id -eq 'M-02')[0]
$originX=[double]$m02.x
$originY=[double]$m02.y
$pantry=@($bath.plans.main|Where-Object id -eq 'M-04')[0]
$searchA=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'west_of_core')[0]
$searchB=@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0]
function UnionIntersection184([object[]]$route,[object]$target){
 $clipped=New-Object System.Collections.Generic.List[object]
 foreach($r in $route){$x0=[Math]::Max([double]$r.x,[double]$target.x);$x1=[Math]::Min(([double]$r.x+[double]$r.w),([double]$target.x+[double]$target.w));$y0=[Math]::Max([double]$r.y,[double]$target.y);$y1=[Math]::Min(([double]$r.y+[double]$r.h),([double]$target.y+[double]$target.d));if(($x1-$x0)-gt1e-7-and($y1-$y0)-gt1e-7){$clipped.Add([pscustomobject]@{x0=$x0;x1=$x1;y0=$y0;y1=$y1})}}
 $xs=@($clipped|ForEach-Object{[double]$_.x0;[double]$_.x1}|Sort-Object -Unique);$area=0.0
 for($i=0;$i-lt$xs.Count-1;$i++){$dx=$xs[$i+1]-$xs[$i];if($dx-le1e-7){continue};$mid=($xs[$i]+$xs[$i+1])/2;$intervals=@($clipped|Where-Object{$_.x0-lt($mid+1e-7)-and$_.x1-gt($mid-1e-7)}|Sort-Object y0);if($intervals.Count){$start=[double]$intervals[0].y0;$end=[double]$intervals[0].y1;$covered=0.0;for($j=1;$j-lt$intervals.Count;$j++){if([double]$intervals[$j].y0-le($end+1e-7)){$end=[Math]::Max($end,[double]$intervals[$j].y1)}else{$covered+=$end-$start;$start=[double]$intervals[$j].y0;$end=[double]$intervals[$j].y1}};$covered+=$end-$start;$area+=$dx*$covered}}
 return [Math]::Round($area,6)
}
$route=@($social.geometry.route_corridor_rectangles_ft)
$obstacles=@($pantry,$searchA,$searchB)
$results=New-Object System.Collections.Generic.List[object]
foreach($o in $obstacles){$hits=New-Object System.Collections.Generic.List[object];$index=0;foreach($r in $route){$dx=[Math]::Min(([double]$r.x+[double]$r.w),([double]$o.x+[double]$o.w))-[Math]::Max([double]$r.x,[double]$o.x);$dy=[Math]::Min(([double]$r.y+[double]$r.h),([double]$o.y+[double]$o.d))-[Math]::Max([double]$r.y,[double]$o.y);if($dx-gt1e-7-and$dy-gt1e-7){$hits.Add([ordered]@{route_rectangle_index=$index;intersection_area_sf=[Math]::Round($dx*$dy,6)})};$index++};$union=UnionIntersection184 $route $o;$results.Add([ordered]@{target=$o.id;source_rect_world_ft=[ordered]@{x=[double]$o.x;y=[double]$o.y;w=[double]$o.w;d=[double]$o.d};strict_positive_area_intersections=$hits.Count;sum_of_rectangle_pair_intersections_sf=[Math]::Round((@($hits|ForEach-Object{$_.intersection_area_sf}|Measure-Object -Sum).Sum),6);union_overlap_area_sf=$union;route_rectangles=$hits.ToArray()})}
$pantryResult=@($results|Where-Object target -eq 'M-04')[0]
$westResult=@($results|Where-Object target -eq 'west_of_core')[0]
$eastResult=@($results|Where-Object target -eq 'east_of_core')[0]
$checks=New-Object System.Collections.Generic.List[object]
function Add184([string]$id,[bool]$pass,[string]$detail){$script:checks.Add([pscustomobject]@{id=$id;pass=$pass;detail=$detail})}
Add184 'expected_study_sources' (($bath.schema -eq 'forever-home.selected-house-schematic.v1')-and($social.schema -eq 'forever-home-direction-d-social-route-v1')) 'The route and bath-first room blocks are the expected retained study outputs.'
Add184 'social_route_bound_to_current_bathfirst' ($social.source_fingerprints_sha256.PSObject.Properties[$bathRel].Value -eq (Hash184 $bathRel)) 'The social route was generated from the exact bath-first source currently overlaid.'
Add184 'selected_d_baseline_unchanged' (($selectedHash -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb')-and($social.source_fingerprints_sha256.PSObject.Properties[$selectedRel].Value -eq $selectedHash)) 'Selected-D source fingerprint remains at the protected baseline.'
Add184 'social_route_is_36_in_test' ([Math]::Abs(([double]$social.inputs.target_route_width_ft*12)-36)-lt0.001) 'The source route rectangles use the documented 36-in proxy width.'
Add184 'bath_first_pantry_is_found' (($null-ne$pantry)-and([double]$pantry.w-eq5)-and([double]$pantry.d-eq7)) 'M-04 is present in the source bath-first main-floor room blocks.'
Add184 'social_route_has_pantry_overlap' ($pantryResult.union_overlap_area_sf-gt0) 'At least one positive-area part of the 36-in corridor intersects the M-04 pantry block.'
Add184 'overlap_union_not_pair_sum' ($pantryResult.union_overlap_area_sf-le$pantryResult.sum_of_rectangle_pair_intersections_sf) 'Union area removes duplicate area where adjacent route rectangles overlap at corners.'
Add184 'b_search_window_stays_clear' ($eastResult.union_overlap_area_sf-eq0) 'The existing route corridor does not intersect the east/pantry-side M-06/B diagnostic window.'
Add184 'west_window_conflict_recorded' ($westResult.union_overlap_area_sf-gt0) 'The route also crosses the already-blocked west M-06 diagnostic window; that rectangle is not a physical bath.'
$bStatus=[string](@($bath.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core')[0].status)
Add184 'm06_b_unassigned' ($bStatus -match 'Unassigned') 'The B region remains an unassigned search gap.'
$passed=@($checks|Where-Object pass).Count;$status='fail';if($passed-eq$checks.Count){$status='pass'}
$report=[ordered]@{schema='forever-home-m184-social-route-pantry-overlay-v1';status='existing route fails pantry overlay; no route or room selected';source_fingerprints_sha256=[ordered]@{$bathRel=(Hash184 $bathRel);$socialRel=(Hash184 $socialRel);$selectedRel=$selectedHash};coordinate_origin_source_ft=@($originX,$originY);route_width_in=[Math]::Round([double]$social.inputs.target_route_width_ft*12,3);existing_social_route_internal_obstacle_intersection_count=[int]$social.geometry.route_obstacle_intersection_count;compared_obstacles=$results.ToArray();finding=('The existing M173 36-in route corridor has {0:F3} sf union overlap with source M-04 pantry and {1:F3} sf with the blocked west M-06 search diagnostic; it has {2:F3} sf overlap with the east B search window. The original social-route check reports zero intersections against its modeled kitchen/dining obstacles, which did not include these room-block overlays.' -f [double]$pantryResult.union_overlap_area_sf,[double]$westResult.union_overlap_area_sf,[double]$eastResult.union_overlap_area_sf);disposition='Do not carry the M173 route forward as a complete bath-first circulation solution. M-06/B remains unassigned; this overlay does not select an alternative or make a physical room.';limitations=@('Rectangles are existing schematic route and room-block proxies in the shared source coordinate frame, not walls or verified openings.','Union overlap areas are geometric intersections only; no door leaf, approach, movement, privacy, service, finish or tolerance is modeled.','The blocked west M-06 rectangle is a diagnostic overlay, not a physical fixture.','No Revit/IFC model or selected-D source was changed; no code, accessibility, structural, professional, permit or construction-readiness finding.');checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks.ToArray()}}
$encoding=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm184-pantry-overlay.json'),(($report|ConvertTo-Json -Depth 30)+"`n"),$encoding)
[IO.File]::WriteAllText((Join-Path $out 'm184-checks.json'),(($report.checks|ConvertTo-Json -Depth 20)+"`n"),$encoding)
[IO.File]::WriteAllText((Join-Path $out 'm184-overlap-summary.csv'),((@($results|ForEach-Object{[pscustomobject]@{target=$_.target;intersection_rectangle_pairs=$_.strict_positive_area_intersections;pair_sum_sf=$_.sum_of_rectangle_pair_intersections_sf;union_overlap_sf=$_.union_overlap_area_sf}}|ConvertTo-Csv -NoTypeInformation)-join "`n")+"`n"),$encoding)
Write-Output ("M184: {0}/{1}; pantry union overlap={2:F3} sf; west diagnostic={3:F3} sf; B window={4:F3} sf; selected-D unchanged." -f $passed,$checks.Count,[double]$pantryResult.union_overlap_area_sf,[double]$westResult.union_overlap_area_sf,[double]$eastResult.union_overlap_area_sf)
if($passed-ne$checks.Count){exit 1}
