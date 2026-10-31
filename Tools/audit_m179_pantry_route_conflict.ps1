param([string]$OutputDirectory='Architecture/M179_Pantry_Route_Clearance_Audit_2026-10-31')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out=Join-Path $root $OutputDirectory
$m172Rel='Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'
$m173Rel='Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
$bathRel='Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$m178Rel='Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json'
foreach($r in @($m172Rel,$m173Rel,$bathRel,$m178Rel)){if(-not(Test-Path -LiteralPath (Join-Path $root $r) -PathType Leaf)){throw "Missing source: $r"}}
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}
function GetShaM179($r){(Get-FileHash -LiteralPath (Join-Path $root $r) -Algorithm SHA256).Hash.ToLowerInvariant()}
$m172=Get-Content (Join-Path $root $m172Rel) -Raw|ConvertFrom-Json;$m173=Get-Content (Join-Path $root $m173Rel) -Raw|ConvertFrom-Json
$bath=Get-Content (Join-Path $root $bathRel) -Raw|ConvertFrom-Json;$m178=Get-Content (Join-Path $root $m178Rel) -Raw|ConvertFrom-Json
$fingerprintChecks=New-Object System.Collections.Generic.List[object]
foreach($entry in $m173.source_fingerprints_sha256.PSObject.Properties){$fingerprintChecks.Add([pscustomobject]@{id="m173:$($entry.Name)";pass=((GetShaM179 $entry.Name)-eq([string]$entry.Value).ToLowerInvariant());detail='M173 source fingerprint'})}
foreach($entry in $m178.source_fingerprints_sha256.PSObject.Properties){$fingerprintChecks.Add([pscustomobject]@{id="m178:$($entry.Name)";pass=((GetShaM179 $entry.Name)-eq([string]$entry.Value).ToLowerInvariant());detail='M178 source fingerprint'})}
$main=$bath.plans.main;$m02=@($main|Where-Object id -eq 'M-02')[0];$m04=@($main|Where-Object id -eq 'M-04')[0]
if($null-eq$m02-or$null-eq$m04){throw 'Bath-first main-floor M-02 or M-04 block is missing.'}
$originX=[double]$m02.x;$originY=[double]$m02.y
$pantry=[ordered]@{id='M-04-pantry-candidate';x=([double]$m04.x-$originX);y=([double]$m04.y-$originY);w=[double]$m04.w;d=[double]$m04.d}
$kitchen=[ordered]@{x=0.0;y=0.0;w=13.5;d=14.0};$dining=[ordered]@{x=0.0;y=14.0;w=11.0;d=10.0}
$porch=[ordered]@{x=-0.5;y=24.5;w=12.0;d=10.0};$counter=[ordered]@{id='perimeter-run';x=0.0;y=0.75;w=2.0;d=12.5}
$island=[ordered]@{id='island';x=5.5;y=3.0;w=4.0;d=8.0};$stools=[ordered]@{id='assumed-stools';x=5.5;y=11.0;w=4.0;d=2.0}
$wall=[ordered]@{id='half-wall';x=13.0;y=0.0;w=0.5;d=7.0};$return=[ordered]@{id='wall-return';x=13.0;y=13.0;w=0.5;d=1.0}
$table=[ordered]@{id='dining-table';x=3.0;y=17.5;w=5.0;d=3.0}
$chairs=@([ordered]@{id='south-chair-1';x=3.5;y=15.8333333333;w=1.5;d=1.6666666667},[ordered]@{id='south-chair-2';x=6.0;y=15.8333333333;w=1.5;d=1.6666666667},[ordered]@{id='west-chair-1';x=1.3333333333;y=17.5;w=1.6666666667;d=1.5},[ordered]@{id='west-chair-2';x=1.3333333333;y=19.0;w=1.6666666667;d=1.5})
$porchWalls=@([ordered]@{id='porch-wall-west';x=-0.5;y=24.5;w=6.5;d=0.5},[ordered]@{id='porch-wall-east';x=11.0;y=24.5;w=0.5;d=0.5})
$oldPoints=@();foreach($p in $m178.candidate.route_centerline_ft){$oldPoints+=,[pscustomobject]@{x=[double]$p.x;y=[double]$p.y}}
$newPoints=@([pscustomobject]@{x=14.5;y=10.0},[pscustomobject]@{x=11.25;y=10.0},[pscustomobject]@{x=11.25;y=14.5},[pscustomobject]@{x=9.5;y=14.5},[pscustomobject]@{x=9.5;y=22.5},[pscustomobject]@{x=8.5;y=22.5},[pscustomobject]@{x=8.5;y=27.5})
function Rects($pts,$width){$r=New-Object System.Collections.Generic.List[object];for($i=0;$i-lt$pts.Count-1;$i++){$a=$pts[$i];$b=$pts[$i+1];if([Math]::Abs($a.x-$b.x)-lt0.000001){$r.Add([ordered]@{id="segment-$i";x=$a.x-$width/2;y=[Math]::Min($a.y,$b.y);w=$width;d=[Math]::Abs($b.y-$a.y)})}else{$r.Add([ordered]@{id="segment-$i";x=[Math]::Min($a.x,$b.x);y=$a.y-$width/2;w=[Math]::Abs($b.x-$a.x);d=$width})};if($i-gt0){$r.Add([ordered]@{id="corner-$i";x=$a.x-$width/2;y=$a.y-$width/2;w=$width;d=$width})}};return $r.ToArray()}
function Hit($a,$b){$dx=[Math]::Min($a.x+$a.w,$b.x+$b.w)-[Math]::Max($a.x,$b.x);$dy=[Math]::Min($a.y+$a.d,$b.y+$b.d)-[Math]::Max($a.y,$b.y);if($dx-gt0.000001-and$dy-gt0.000001){return [ordered]@{route=$a.id;obstacle=$b.id;overlap_area_sf=[Math]::Round($dx*$dy,5)}};return $null}
$oldRects=Rects $oldPoints 3.0;$newRects=Rects $newPoints 3.0
$obstacles=@($counter)+@($island)+@($stools)+@($table)+@($chairs)+@($wall)+@($return)+@($porchWalls)+@($pantry)
$oldHits=New-Object System.Collections.Generic.List[object];$newHits=New-Object System.Collections.Generic.List[object]
foreach($r in $oldRects){foreach($o in $obstacles){$h=Hit $r $o;if($null-ne$h){$oldHits.Add($h)}}}
foreach($r in $newRects){foreach($o in $obstacles){$h=Hit $r $o;if($null-ne$h){$newHits.Add($h)}}}
$checks=New-Object System.Collections.Generic.List[object];foreach($c in $fingerprintChecks){$checks.Add($c)}
function Add($id,$pass,$detail){$script:checks.Add([pscustomobject]@{id=$id;pass=[bool]$pass;detail=$detail})}
$pantryY=[double]$pantry.y;$doglegY=[double]$newPoints[2].y;$doglegNorth=$doglegY+1.5;$doglegSouth=$doglegY-1.5
$diningRouteWest=[double]$newRects[6].x;$diningRouteEast=$diningRouteWest+3.0
$eastSpill=($newPoints[1].x+1.5-$dining.w)*12
$m06=[bool]$m178.source_fingerprints_sha256.'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
Add 'straight_route_hits_pantry_candidate' (@($oldHits|Where-Object obstacle -eq 'M-04-pantry-candidate').Count-gt0) 'The M178 straight east-aisle route intersects M-04 in the bath-first alternative.'
Add 'pantry_candidate_starts_north_of_dogleg' ($doglegNorth-le$pantryY) 'Dogleg cross-corridor ends south of the pantry block with a measurable gap.'
Add 'dogleg_cross_corridor_clears_stool_zone' ($doglegSouth-ge13.0) 'Westward shift occurs after the assumed stool zone ends.'
Add 'dogleg_cross_corridor_clears_pantry' ($doglegNorth-le$pantryY) 'Westward shift completes before the pantry starts.'
Add 'dining_leg_inside_target_width' ($diningRouteWest-ge0-and$diningRouteEast-le$dining.w) 'Long dining leg occupies the east 36 in band within the 11 ft dining test zone.'
Add 'dining_leg_tangent_to_table_not_overlapping' ([Math]::Abs($diningRouteWest-($table.x+$table.w))-lt0.000001) '36 in route meets the table east edge without positive-area overlap; no east-side chair is proposed.'
Add 'stationary_chairs_clear' (@($newHits|Where-Object{$_.obstacle-like '*chair*'}).Count-eq0) 'Dogleg does not intersect the four stationary chair rectangles.'
Add 'revised_route_avoids_all_modeled_obstacles' ($newHits.Count-eq0) 'Revised route has no positive-area overlap with the pantry, furniture, casework, island/stool or wall proxies.'
Add 'porch_door_crossing_retained' ($newPoints[-1].x-ge6-and$newPoints[-1].x-le11) '36 in route centerline crosses within the nominal 5 ft porch-door reservation.'
Add 'porch_reach_retained' ([Math]::Abs(($newPoints[-1].y-$porch.y)-3)-lt0.001) 'Route still reaches 3 ft into the porch candidate.'
Add 'unassigned_entry_spill_quantified' ($eastSpill-gt0) 'The short kitchen-to-dining dogleg connector spills east of the dining test width; pantry is clear at this earlier y-position.'
Add 'kitchen_area_tradeoff_retained' ($m178.candidate.kitchen_area_sf-eq189-and$m178.candidate.kitchen_over_target_sf-eq21) 'M178 +21 sf area proposal remains explicit.'
Add 'm06_b_unassigned' ($m173.geometry.m06_window_b_remains_unassigned-eq$true) 'M-06/B remains unassigned.'
$passed=@($checks|Where-Object pass).Count;$status='fail';if($passed-eq$checks.Count){$status='pass'}
$sourceHashes=[ordered]@{};foreach($r in @($m172Rel,$m173Rel,$bathRel,$m178Rel)){$sourceHashes[$r]=GetShaM179 $r}
$report=[ordered]@{schema='forever-home-m179-pantry-route-audit-v1';status='route alternative in unapproved bath-first room-block comparison';source_fingerprints_sha256=$sourceHashes;room_overlay=[ordered]@{M02_origin_in_source_ft=@($originX,$originY);M04_source_rect_ft=@($m04.x,$m04.y,$m04.w,$m04.d);M04_local_rect_ft=@($pantry.x,$pantry.y,$pantry.w,$pantry.d);M04_status='Unapproved bath-first room-block alternative; overlay comparison only.'};m178_straight_route=[ordered]@{centerline_ft=$oldPoints;pantry_positive_area_intersections=$oldHits.ToArray()};dogleg_route=[ordered]@{centerline_ft=$newPoints;width_in=36;route_rectangles_ft=$newRects;positive_area_intersections=$newHits.ToArray();dining_east_extent_in=$eastSpill;pantry_start_local_y_ft=$pantryY;dogleg_turn_local_y_ft=$doglegY};conclusion='The M178 straight east-side route collides with the M-04 pantry block in the existing bath-first room-block alternative. A dogleg shifts west before the pantry begins and continues along the dining east edge; it clears the modeled pantry, furniture and wall rectangles while retaining the nominal porch door. The dogleg has a 21 in transverse spill beyond the dining width below the pantry and relies on the proposed absence of east-side dining chairs. No room layout or route is selected.';limitations=@('Bath-first blocks are unapproved and larger than owner room-area targets; coordinate overlay is comparative only.','Dining leg is tangent to the 36 in table edge envelope and depends on no east-side chair; pulled-back seating and people are not measured.','The 21 in transition spill is unassigned and may conflict with other rooms or shell boundaries.','Porch door is a nominal 5 ft reservation, not a verified clear opening. Appliance-open envelopes, wall construction, threshold, shell, site, service routes, Revit and IFC are not validated.','M-06/B remains unassigned; no code compliance, accessibility, structural safety, certification, permit approval or construction readiness is established.')}
$checkReport=[ordered]@{status=$status;passed=$passed;total=$checks.Count;checks=$checks.ToArray()}
$report|ConvertTo-Json -Depth 80|Set-Content (Join-Path $out 'm179-study.json') -Encoding UTF8
$checkReport|ConvertTo-Json -Depth 50|Set-Content (Join-Path $out 'm179-checks.json') -Encoding UTF8
$checks.ToArray()|Export-Csv (Join-Path $out 'm179-checks.csv') -NoTypeInformation -Encoding UTF8
Write-Output ("M179: {0}/{1}; direct pantry hits {2}; dogleg hits {3}; pantry begins y={4:F2} ft; dogleg turn y={5:F2} ft; route spill {6:F0} in." -f $passed,$checks.Count,@($oldHits|Where-Object obstacle -eq 'M-04-pantry-candidate').Count,$newHits.Count,$pantryY,$doglegY,$eastSpill)
if($passed-ne$checks.Count){exit 1}
