param([string]$OutputDirectory='Architecture/M178_Halfwall_Seating_Candidate_2026-10-31',[switch]$OverwriteGenerated)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out=Join-Path $root $OutputDirectory
$m172Path=Join-Path $root 'Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'
$m173Path=Join-Path $root 'Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
foreach($p in @($m172Path,$m173Path,$selectedPath)){if(-not(Test-Path -LiteralPath $p -PathType Leaf)){throw "Missing source: $p"}}
if((Test-Path -LiteralPath $out) -and -not$OverwriteGenerated -and @(Get-ChildItem -LiteralPath $out -Force).Count -gt 0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}
$m172=Get-Content $m172Path -Raw|ConvertFrom-Json;$m173=Get-Content $m173Path -Raw|ConvertFrom-Json
$targetK=[double]$m172.targets.M02_kitchen_area_sf;$targetD=[double]$m172.targets.M03_dining_area_sf
$k=[ordered]@{x=0.0;y=0.0;w=13.5;d=14.0};$dining=[ordered]@{x=0.0;y=14.0;w=11.0;d=10.0};$porch=[ordered]@{x=-0.5;y=24.5;w=12.0;d=10.0}
$counter=[ordered]@{id='perimeter-run';x=0.0;y=0.75;w=2.0;d=12.5}
$modules=@([ordered]@{id='sink-base';d=3.0},[ordered]@{id='dishwasher';d=2.0},[ordered]@{id='range-landing-west';d=1.0},[ordered]@{id='induction-range';d=2.5},[ordered]@{id='range-landing-east';d=1.0},[ordered]@{id='refrigerator';d=3.0})
$cursor=0.75;foreach($m in $modules){$m.x=0.0;$m.y=$cursor;$m.w=2.0;$cursor += [double]$m.d}
$island=[ordered]@{id='island';x=5.5;y=3.0;w=4.0;d=8.0}
$stools=[ordered]@{id='assumed-two-stool-zone';x=5.5;y=11.0;w=4.0;d=2.0}
$wall=[ordered]@{id='half-wall';x=13.0;y=0.0;w=0.5;d=7.0}
$opening=[ordered]@{id='living-opening';x=13.0;y=7.0;w=0.5;d=6.0}
$return=[ordered]@{id='wall-return';x=13.0;y=13.0;w=0.5;d=1.0}
$table=[ordered]@{id='dining-table';x=3.0;y=17.5;w=5.0;d=3.0}
$chairs=@([ordered]@{id='south-chair-1';x=3.5;y=15.8333333333;w=1.5;d=1.6666666667},[ordered]@{id='south-chair-2';x=6.0;y=15.8333333333;w=1.5;d=1.6666666667},[ordered]@{id='west-chair-1';x=1.3333333333;y=17.5;w=1.6666666667;d=1.5},[ordered]@{id='west-chair-2';x=1.3333333333;y=19.0;w=1.6666666667;d=1.5})
$door=[ordered]@{left=6.0;right=11.0;center=8.5;y=24.5;width=5.0}
$porchWalls=@([ordered]@{id='porch-wall-west-of-door';x=-0.5;y=24.5;w=6.5;d=0.5},[ordered]@{id='porch-wall-east-of-door';x=11.0;y=24.5;w=0.5;d=0.5})
$points=@([pscustomobject]@{x=14.5;y=10.0},[pscustomobject]@{x=11.25;y=10.0},[pscustomobject]@{x=11.25;y=22.5},[pscustomobject]@{x=8.5;y=22.5},[pscustomobject]@{x=8.5;y=27.5});$routeWidth=3.0
function Overlap($a,$b){$dx=[Math]::Min($a.x+$a.w,$b.x+$b.w)-[Math]::Max($a.x,$b.x);$dy=[Math]::Min($a.y+$a.d,$b.y+$b.d)-[Math]::Max($a.y,$b.y);if($dx-gt 0.000001-and $dy-gt 0.000001){return [ordered]@{a=$a.id;b=$b.id;area_sf=[Math]::Round($dx*$dy,5)}};return $null}
function RouteRects($pts,$width){$r=New-Object System.Collections.Generic.List[object];for($i=0;$i-lt $pts.Count-1;$i++){$a=$pts[$i];$b=$pts[$i+1];if([Math]::Abs($a.x-$b.x)-lt 0.000001){$r.Add([ordered]@{id="route-$i";x=$a.x-$width/2;y=[Math]::Min($a.y,$b.y);w=$width;d=[Math]::Abs($b.y-$a.y)})}else{$r.Add([ordered]@{id="route-$i";x=[Math]::Min($a.x,$b.x);y=$a.y-$width/2;w=[Math]::Abs($b.x-$a.x);d=$width})};if($i-gt 0){$r.Add([ordered]@{id="route-corner-$i";x=$a.x-$width/2;y=$a.y-$width/2;w=$width;d=$width})}};return $r.ToArray()}
$route=RouteRects $points $routeWidth;$obstacles=@($counter)+@($modules)+@($island)+@($stools)+@($table)+@($chairs)+@($wall)+@($return)+@($porchWalls)
$hits=New-Object System.Collections.Generic.List[object];foreach($r in $route){foreach($o in $obstacles){$h=Overlap $r $o;if($null-ne$h){$hits.Add($h)}}}
$checks=New-Object System.Collections.Generic.List[object];function Check($id,$pass,$detail){$script:checks.Add([pscustomobject]@{id=$id;pass=[bool]$pass;detail=$detail})}
function HashRel($rel){(Get-FileHash -LiteralPath (Join-Path $root $rel) -Algorithm SHA256).Hash.ToLowerInvariant()}
$m172Match=$true;foreach($p in $m172.source_fingerprints_sha256.PSObject.Properties){if((HashRel $p.Name)-ne([string]$p.Value).ToLowerInvariant()){$m172Match=$false}}
$m173Match=$true;foreach($p in $m173.source_fingerprints_sha256.PSObject.Properties){if((HashRel $p.Name)-ne([string]$p.Value).ToLowerInvariant()){$m173Match=$false}}
$section=2.0+3.5+4.0+3.5+0.5;$runLength=($modules|ForEach-Object{[double]$_['d']}|Measure-Object -Sum).Sum
$stoolDepth=2.0;$crossAisle1=($island.x-($counter.x+$counter.w))*12;$crossAisle2=(13.0-($island.x+$island.w))*12
$routeAisleLeft=9.5;$routeAisleRight=13.0;$routeCenter=11.25;$routeMargin=($crossAisle2-36.0)/2
$tableClear=[ordered]@{west_in=($table.x-$dining.x)*12;east_in=($dining.x+$dining.w-$table.x-$table.w)*12;south_in=($table.y-$dining.y)*12;north_in=($dining.y+$dining.d-$table.y-$table.d)*12}
$routeSpill=($routeCenter+$routeWidth/2-[double]$dining.x-[double]$dining.w)*12
$selectedHash=(Get-FileHash $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
Check 'm172_sources_current' $m172Match 'M172 source fingerprints match current inputs.'
Check 'm173_sources_current' $m173Match 'M173 source fingerprints match current inputs.'
Check 'selected_d_unchanged' ($selectedHash-eq([string]$m172.source_fingerprints_sha256.'Architecture/Selected_Design_Iteration_2026-10-27/study.json').ToLowerInvariant()) 'Selected-D study hash matches its M172 binding.'
Check 'owner_area_targets_bound' ($targetK-eq168-and$targetD-eq110) 'Program targets remain 168 sf kitchen and 110 sf dining.'
Check 'kitchen_candidate_area_tradeoff' ([Math]::Abs($k.w*$k.d-189)-lt 0.001-and [Math]::Abs($k.w*$k.d-$targetK-21)-lt 0.001) 'Rotated 13.5 x 14 ft candidate is 189 sf, +21 sf.'
Check 'coupled_cross_section_sums' ([Math]::Abs($section-13.5)-lt 0.001) '2 ft counter + 42 in + 4 ft island + 42 in + 6 in wall = 13.5 ft.'
Check 'candidate_cross_section_fits' ($k.w-ge$section) 'The 13.5 ft cross-section fits the proposed 13.5 ft kitchen axis exactly.'
Check 'perimeter_run_matches_modules' ([Math]::Abs($runLength-12.5)-lt 0.001) 'Source-size cabinet modules total 12.5 ft.'
Check 'perimeter_run_fits_long_axis' ($runLength-le$k.d-1.0) '12.5 ft run plus two 0.75 ft end reserves fits the 14 ft axis.'
Check 'counter_and_island_aisle_42' ([Math]::Abs($crossAisle1-42)-lt 0.001) 'Counter front to island is 42 in.'
Check 'island_and_halfwall_aisle_42' ([Math]::Abs($crossAisle2-42)-lt 0.001) 'Island edge to half-wall face is 42 in.'
Check 'route_width_and_margins' ([Math]::Abs(($routeWidth*12)-36)-lt 0.001-and[Math]::Abs($routeMargin-3)-lt 0.001) '36 in route fits centered in the 42 in aisle with 3 in margins.'
Check 'island_inside_kitchen' ($island.x-ge$k.x-and$island.y-ge$k.y-and$island.x+$island.w-le$k.w-and$island.y+$island.d-le$k.d) '8 x 4 ft island body fits inside the candidate envelope.'
Check 'assumed_stool_zone_inside_kitchen' ($stools.x+$stools.w-le$k.w-and$stools.y+$stools.d-le$k.d) '2 ft assumed occupied depth fits at the 4 ft dining-facing end.'
Check 'stool_end_side_allowance_disclosed' ($stools.w-eq4-and$stools.w*12-eq48) 'Two assumed 24 in positions use all 48 in; no side allowance.'
Check 'halfwall_length_within_source_band' ($wall.d-ge7-and$wall.d-le9) '7 ft half-wall proposal is at the low end of the documented 8 ft +/- 12 in band.'
Check 'opening_and_return_fit' ($opening.d-eq6-and$return.d-eq1-and$wall.d+$opening.d+$return.d-eq14) '7 ft wall, 6 ft opening and 1 ft end return fit along the 14 ft side.'
$orthogonal=$true;for($i=0;$i-lt$points.Count-1;$i++){if([Math]::Abs($points[$i].x-$points[$i+1].x)-gt0.000001-and[Math]::Abs($points[$i].y-$points[$i+1].y)-gt0.000001){$orthogonal=$false}}
Check 'living_route_crosses_opening' ($points[0].y-ge7-and$points[0].y+$routeWidth/2-le13-and$points[0].y-$routeWidth/2-ge7) '36 in approach crosses the 6 ft side opening with 18 in margins.'
Check 'route_centerline_orthogonal' $orthogonal 'Every route segment is axis-aligned.'
Check 'route_avoids_closed_state_obstacles' ($hits.Count-eq0) 'Route does not overlap modeled closed-state casework, seating/table proxies or wall segments.'
Check 'dining_candidate_area' ([Math]::Abs($dining.w*$dining.d-$targetD)-lt 0.001) 'Dining remains 11 x 10 ft / 110 sf.'
Check 'dining_table_clearance_proxy' (@($tableClear.Values|Where-Object{[double]$_-lt36}).Count-eq0) 'Table has at least 36 in to each dining test-zone edge.'
Check 'porch_candidate_area' ([Math]::Abs($porch.w*$porch.d-120)-lt 0.001) 'Porch remains a 12 x 10 ft / 120 sf test rectangle.'
Check 'route_reaches_porch' ([Math]::Abs(($points[-1].y-$porch.y)-3)-lt0.001) 'Route continues 3 ft into the porch candidate.'
Check 'route_spill_reported' ($routeSpill-gt0) 'Dining-side corridor east spill is explicitly quantified.'
Check 'm06_b_unassigned' ($m173.geometry.m06_window_b_remains_unassigned-eq$true) 'M-06/B remains unassigned.'
$passed=@($checks|Where-Object pass).Count;$status='fail';if($passed-eq$checks.Count){$status='pass'}
$hashes=[ordered]@{'Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'=(Get-FileHash $m172Path -Algorithm SHA256).Hash.ToLowerInvariant();'Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'=(Get-FileHash $m173Path -Algorithm SHA256).Hash.ToLowerInvariant();'Architecture/Selected_Design_Iteration_2026-10-27/study.json'=$selectedHash}
$report=[ordered]@{schema='forever-home-m178-halfwall-seating-candidate-v1';status='unapproved rotated kitchen/open-plan proposal';source_fingerprints_sha256=$hashes;program_targets=[ordered]@{kitchen_area_sf=$targetK;dining_area_sf=$targetD};candidate=[ordered]@{kitchen_rect_ft=@(0,0,13.5,14);kitchen_area_sf=189;kitchen_over_target_sf=21;cross_section=[ordered]@{counter_depth_ft=2;counter_island_aisle_ft=3.5;island_width_ft=4;island_halfwall_aisle_ft=3.5;halfwall_thickness_ft=0.5;total_ft=$section};perimeter_run_ft=$runLength;island_rect_ft=@($island.x,$island.y,$island.w,$island.d);assumed_stool_rect_ft=@($stools.x,$stools.y,$stools.w,$stools.d);halfwall_rect_ft=@($wall.x,$wall.y,$wall.w,$wall.d);opening_length_ft=6;wall_return_ft=1;route_width_in=36;route_centerline_ft=$points;route_aisle_margins_in=@(3,3);route_east_spill_past_dining_in=$routeSpill;dining_rect_ft=@($dining.x,$dining.y,$dining.w,$dining.d);table_clearance_in=$tableClear;porch_rect_ft=@($porch.x,$porch.y,$porch.w,$porch.d)};conclusion='The rotated 13.5 x 14 ft test envelope carries the 12.5 ft run and 13.5 ft counter/aisle/island/aisle/wall section, with the island at 42 in from both counter and half-wall and a 36 in route through the 6 ft opening. The kitchen is +21 sf over its area target. Two 24 in stool proxies occupy the full 4 ft island end with no side allowance. Dining-route spill and all unverified conditions remain explicit; no layout is selected.';limitations=@('Room block is unapproved; target areas do not approve its 13.5 x 14 ft shape.','The assumed seating on the 4 ft island end is not confirmed by product geometry or owner selection.','Route spills east of dining into unassigned adjacent space; pantry and other room conflicts are not evaluated.','Appliance-open envelopes, occupied/pulled-back seating, physical door clear width, thresholds, shell fit, site, service routes, Revit and IFC are not validated.','No code compliance, accessibility, structural safety, certification, permit approval or construction readiness is established.')}
$checkReport=[ordered]@{status=$status;passed=$passed;total=$checks.Count;checks=$checks.ToArray()}
$report|ConvertTo-Json -Depth 80|Set-Content (Join-Path $out 'm178-study.json') -Encoding UTF8
$checkReport|ConvertTo-Json -Depth 50|Set-Content (Join-Path $out 'm178-checks.json') -Encoding UTF8
$checks.ToArray()|Export-Csv (Join-Path $out 'm178-checks.csv') -NoTypeInformation -Encoding UTF8
$svg=@("<svg xmlns='http://www.w3.org/2000/svg' width='960' height='1220' viewBox='0 0 960 1220'>",'<style>text{font:14px Arial;fill:#302b25}.t{font-size:22px;font-weight:bold}.k{fill:#f4eadb;stroke:#554b40;stroke-width:2}.d{fill:#f7f0e4;stroke:#766b5d;stroke-width:2}.p{fill:#e8efe2;stroke:#65745e;stroke-width:2}.cab{fill:#d9c7aa;stroke:#6a5944}.i{fill:#dce7db;stroke:#667963;stroke-width:2}.s{fill:#dce7db;fill-opacity:.35;stroke:#667963;stroke-dasharray:6 4}.tab{fill:#c99f68;stroke:#6a4f32}.c{fill:#c8b6a0;stroke:#655a4e}.r{fill:#67a7ca;fill-opacity:.28;stroke:#287aa6}.w{stroke:#745d42;stroke-width:8}.o{stroke:#f4eadb;stroke-width:10}.door{stroke:#ad6b45;stroke-width:7}</style>',"<text class='t' x='24' y='32'>M178 - rotated kitchen + living-to-porch route (proposal)</text>","<text x='24' y='54'>189 sf kitchen (+21 sf); 36 in route; 42 in aisles; no selection or appliance-open test</text>")
$sc=38.0;$ox=130.0;$oy=1110.0;function X([double]$v){$ox+$v*$sc};function Y([double]$v){$oy-$v*$sc};function SvgRectM178($a,$cl,$label=''){$xx=X $a.x;$yy=Y ($a.y+$a.d);$ww=$a.w*$sc;$hh=$a.d*$sc;$q="<rect class='$cl' x='$xx' y='$yy' width='$ww' height='$hh'/>";if($label){$q+="<text x='$($xx+5)' y='$($yy+18)'>$label</text>"};return $q}
$svg+=(SvgRectM178 $porch 'p' 'Porch 12 x 10');$svg+=(SvgRectM178 $dining 'd' 'Dining 11 x 10');$svg+=(SvgRectM178 $k 'k' 'Kitchen 13.5 x 14');$svg+=(SvgRectM178 $counter 'cab' '12.5 ft run');$svg+=(SvgRectM178 $island 'i' 'Island 8 x 4');$svg+=(SvgRectM178 $stools 's' 'Assumed 24 in stool zone');$svg+=(SvgRectM178 $table 'tab' '36 x 60 table');foreach($c in $chairs){$svg+=(SvgRectM178 $c 'c')};foreach($r in $route){$svg+=(SvgRectM178 $r 'r')}
$svg+="<line class='w' x1='$(X 13.25)' y1='$(Y 0)' x2='$(X 13.25)' y2='$(Y 7)'/>";$svg+="<line class='o' x1='$(X 13.25)' y1='$(Y 7)' x2='$(X 13.25)' y2='$(Y 13)'/>";$svg+="<line class='w' x1='$(X 13.25)' y1='$(Y 13)' x2='$(X 13.25)' y2='$(Y 14)'/>";$svg+="<line class='door' x1='$(X 6)' y1='$(Y 24.5)' x2='$(X 11)' y2='$(Y 24.5)'/>";$svg+="<text x='24' y='1160'>Living approaches from east through 6 ft opening; dining route spills into unassigned east band.</text>";$svg+="<text x='24' y='1182'>North is up. Clear door widths, wall construction and appliance operation are not modeled.</text>";$svg+='</svg>'
$svg|Set-Content (Join-Path $out 'm178-plan.svg') -Encoding UTF8
Write-Output ("M178 candidate: {0}/{1}; kitchen 189 sf (+21); section {2:F1} ft; aisles {3:F0}/{4:F0} in; route hits {5}; east spill {6:F1} in." -f $passed,$checks.Count,$section,$crossAisle1,$crossAisle2,$hits.Count,$routeSpill)
if($passed-ne$checks.Count){exit 1}
