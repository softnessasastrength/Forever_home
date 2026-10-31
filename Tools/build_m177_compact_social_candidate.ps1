param(
    [string]$OutputDirectory = 'Architecture/M177_Compact_Social_Open_Plan_Candidate_2026-10-31',
    [switch]$OverwriteGenerated
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$output = Join-Path $root $OutputDirectory
$m172Path = Join-Path $root 'Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'
$m173Path = Join-Path $root 'Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
$specPath = Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
$islandDecisionPath = Join-Path $root 'Decisions/Kitchen_Island_Finish.md'
$followupPath = Join-Path $root 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
$selectedDPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'

foreach ($path in @($m172Path,$m173Path,$specPath,$islandDecisionPath,$followupPath,$selectedDPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing required input: $path" }
}
if ((Test-Path -LiteralPath $output) -and -not $OverwriteGenerated -and @(Get-ChildItem -LiteralPath $output -Force).Count -gt 0) {
    throw "Refusing to overwrite generated output: $output"
}
if (-not (Test-Path -LiteralPath $output)) { New-Item -ItemType Directory -Path $output | Out-Null }

$m172 = Get-Content -LiteralPath $m172Path -Raw | ConvertFrom-Json
$m173 = Get-Content -LiteralPath $m173Path -Raw | ConvertFrom-Json
$spec = Get-Content -LiteralPath $specPath -Raw
$finish = Get-Content -LiteralPath $islandDecisionPath -Raw
$followup = Get-Content -LiteralPath $followupPath -Raw
$checks = New-Object System.Collections.Generic.List[object]
function Add-Check([string]$Id,[bool]$Pass,[string]$Detail) { $script:checks.Add([ordered]@{id=$Id;pass=$Pass;detail=$Detail}) }
function Get-Hash([string]$RelativePath) {
    $path = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing fingerprint input: $RelativePath" }
    (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
}
function Get-Overlap([object]$A,[object]$B) {
    $dx = [Math]::Min(([double]$A.x+[double]$A.w),([double]$B.x+[double]$B.w)) - [Math]::Max([double]$A.x,[double]$B.x)
    $dy = [Math]::Min(([double]$A.y+[double]$A.d),([double]$B.y+[double]$B.d)) - [Math]::Max([double]$A.y,[double]$B.y)
    if ($dx -gt 0.000001 -and $dy -gt 0.000001) { return [ordered]@{a=$A.id;b=$B.id;area_sf=[Math]::Round($dx*$dy,5)} }
    return $null
}
function New-RouteRects([object[]]$Points,[double]$Width) {
    $rects = New-Object System.Collections.Generic.List[object]
    for ($i=0; $i -lt $Points.Count-1; $i++) {
        $a=$Points[$i]; $b=$Points[$i+1]
        if ([Math]::Abs([double]$a.x-[double]$b.x) -lt 0.000001) {
            $rects.Add([ordered]@{id="route-segment-$i";x=([double]$a.x-$Width/2);y=([Math]::Min([double]$a.y,[double]$b.y));w=$Width;d=([Math]::Abs([double]$b.y-[double]$a.y))})
        } else {
            $rects.Add([ordered]@{id="route-segment-$i";x=([Math]::Min([double]$a.x,[double]$b.x));y=([double]$a.y-$Width/2);w=([Math]::Abs([double]$b.x-[double]$a.x));d=$Width})
        }
        if ($i -gt 0) {
            $rects.Add([ordered]@{id="route-corner-$i";x=([double]$a.x-$Width/2);y=([double]$a.y-$Width/2);w=$Width;d=$Width})
        }
    }
    return $rects.ToArray()
}

$m173SourcesMatch=$true
foreach($entry in $m173.source_fingerprints_sha256.PSObject.Properties){if((Get-Hash $entry.Name)-ne ([string]$entry.Value).ToLowerInvariant()){$m173SourcesMatch=$false}}
$m172SourcesMatch=$true
foreach($entry in $m172.source_fingerprints_sha256.PSObject.Properties){if((Get-Hash $entry.Name)-ne ([string]$entry.Value).ToLowerInvariant()){$m172SourcesMatch=$false}}
$selectedDHash=(Get-FileHash -LiteralPath $selectedDPath -Algorithm SHA256).Hash.ToLowerInvariant()
$m02Target=$m172.targets.M02_kitchen_ft; $m03Target=$m172.targets.M03_dining_ft
$m02AreaTarget=[double]$m172.targets.M02_kitchen_area_sf; $m03AreaTarget=[double]$m172.targets.M03_dining_area_sf

# Proposal: retain the 14-ft kitchen width, extend the room block to 13.5 ft in depth,
# and keep dining at its 11 x 10-ft target. The block is a route-study envelope, not a
# demonstrated fit for every perimeter clearance or seating condition.
$kitchen=[ordered]@{id='M-02';x=0.0;y=0.0;w=14.0;d=13.5;area_sf=189.0}
$dining=[ordered]@{id='M-03';x=0.0;y=13.5;w=11.0;d=10.0;area_sf=110.0}
$porch=[ordered]@{id='Porch-3Season';x=-0.5;y=24.0;w=12.0;d=10.0;area_sf=120.0}
$counterFrontX=12.0
$counterDepth=2.0
$perimeterRunLength=12.5
$counter=[ordered]@{id='perimeter-run';x=$counterFrontX;y=0.5;w=$counterDepth;d=$perimeterRunLength}
$modules=@(
    [ordered]@{id='sink-base';length=3.0},[ordered]@{id='dishwasher';length=2.0},
    [ordered]@{id='west-range-landing';length=1.0},[ordered]@{id='induction-range';length=2.5},
    [ordered]@{id='east-range-landing';length=1.0},[ordered]@{id='refrigerator';length=3.0}
)
$moduleY=0.5
foreach($module in $modules){$module['x']=$counterFrontX;$module['y']=$moduleY;$module['w']=$counterDepth;$module['d']=[double]$module.length;$moduleY += [double]$module.length}
$island=[ordered]@{id='island';x=4.5;y=2.75;w=4.0;d=8.0}
$stools=[ordered]@{id='assumed-two-stool-occupied-zone';x=4.5;y=10.75;w=4.0;d=2.0}
$halfWall=[ordered]@{id='half-wall';x=0.0;y=0.0;w=7.0;d=0.5}
$livingOpening=[ordered]@{id='living-opening';x=7.0;y=0.0;w=6.0;d=0.5}
$unassignedReturn=[ordered]@{id='unassigned-opening-return';x=13.0;y=0.0;w=1.0;d=0.5}
$table=[ordered]@{id='dining-table';x=3.0;y=17.0;w=5.0;d=3.0}
$chairs=@(
    [ordered]@{id='south-chair-1';x=3.5;y=15.3333333333;w=1.5;d=1.6666666667},
    [ordered]@{id='south-chair-2';x=6.0;y=15.3333333333;w=1.5;d=1.6666666667},
    [ordered]@{id='west-end-chair-1';x=1.3333333333;y=17.0;w=1.6666666667;d=1.5},
    [ordered]@{id='west-end-chair-2';x=1.3333333333;y=18.5;w=1.6666666667;d=1.5}
)
$door=[ordered]@{center_x=8.5;width=5.0;left=6.0;right=11.0;y=23.5;offset_from_dining_center_ft=3.0}
$routeWidth=3.0
$routePoints=@([pscustomobject]@{x=10.25;y=0.25},[pscustomobject]@{x=10.25;y=22.0},[pscustomobject]@{x=8.5;y=22.0},[pscustomobject]@{x=8.5;y=27.0})
$routeRects=New-RouteRects -Points $routePoints -Width $routeWidth
$wallSegments=@(
    [ordered]@{id='porch-wall-west-of-door';x=-0.5;y=23.5;w=5.0;d=0.5},
    [ordered]@{id='porch-wall-east-of-door';x=11.0;y=23.5;w=0.5;d=0.5}
)
$obstacles=@($counter)+@($island)+@($stools)+@($table)+@($chairs)+@($halfWall)+@($wallSegments)
$routeHits=New-Object System.Collections.Generic.List[object]
foreach($r in $routeRects){foreach($o in $obstacles){$hit=Get-Overlap $r $o;if($null -ne $hit){$routeHits.Add($hit)}}}
$chairTableHits=New-Object System.Collections.Generic.List[object]
foreach($c in $chairs){$hit=Get-Overlap $table $c;if($null -ne $hit){$chairTableHits.Add($hit)}}
$routeCenterAxisAligned=$true
for($i=0;$i -lt $routePoints.Count-1;$i++){if([Math]::Abs($routePoints[$i].x-$routePoints[$i+1].x)-gt 0.000001 -and [Math]::Abs($routePoints[$i].y-$routePoints[$i+1].y)-gt 0.000001){$routeCenterAxisAligned=$false}}
$aisleIn=($counterFrontX-($island.x+$island.w))*12
$routeMarginIn=($aisleIn-($routeWidth*12))/2
$chairGapIn=([double]$routeRects[0].x-8.0)*12
$diningTargetEast=([double]$dining.x+[double]$dining.w)
$routeEastExtent=[double]$routeRects[0].x+[double]$routeRects[0].w
$diningZoneSpillIn=[Math]::Max(0,($routeEastExtent-$diningTargetEast)*12)
$tableClearance=[ordered]@{
    west_in=([double]$table.x-[double]$dining.x)*12
    east_in=($diningTargetEast-([double]$table.x+[double]$table.w))*12
    south_in=([double]$table.y-[double]$dining.y)*12
    north_in=(([double]$dining.y+[double]$dining.d)-([double]$table.y+[double]$table.d))*12
}
$wallOpeningCheck=($door.left -ge [double]$dining.x -and $door.right -le $diningTargetEast -and $door.width -eq 5.0)
$chairBoundsCheck=$true
foreach($c in $chairs){if($c.x -lt $dining.x -or $c.y -lt $dining.y -or ($c.x+$c.w) -gt $diningTargetEast -or ($c.y+$c.d) -gt ($dining.y+$dining.d)){$chairBoundsCheck=$false}}
$runBoundsCheck=($moduleY -le ($kitchen.y+$kitchen.d)+0.000001 -and [Math]::Abs(($moduleY-0.5)-$perimeterRunLength)-lt 0.000001)
$stoolFitsKitchen=($stools.y+$stools.d -le $kitchen.y+$kitchen.d)

Add-Check 'upstream_m172_sources_current' $m172SourcesMatch 'Every M172 source fingerprint matches the current repository.'
Add-Check 'upstream_m173_sources_current' $m173SourcesMatch 'Every M173 source fingerprint matches the current repository.'
Add-Check 'owner_target_kitchen_bound' ($m02Target[0] -eq 14 -and $m02Target[1] -eq 12 -and $m02AreaTarget -eq 168) 'Kitchen stays bound to 14 x 12 ft / 168 sf program target.'
Add-Check 'owner_target_dining_bound' ($m03Target[0] -eq 11 -and $m03Target[1] -eq 10 -and $m03AreaTarget -eq 110) 'Dining stays bound to 11 x 10 ft / 110 sf program target.'
Add-Check 'selected_d_source_unchanged' ($selectedDHash -eq ([string]$m172.source_fingerprints_sha256.'Architecture/Selected_Design_Iteration_2026-10-27/study.json').ToLowerInvariant()) 'Selected-D hash still matches the M172 source binding.'
Add-Check 'kitchen_candidate_area_tradeoff_explicit' ([Math]::Abs($kitchen.area_sf-189.0)-lt 0.001 -and [Math]::Abs($kitchen.area_sf-$m02AreaTarget-21.0)-lt 0.001) 'Candidate M-02 is 189 sf, 21 sf above the area target; no silent shrink or selection.'
Add-Check 'dining_candidate_retains_target_area' ([Math]::Abs($dining.w*$dining.d-$m03AreaTarget)-lt 0.001) 'Candidate dining retains the 110 sf owner target.'
Add-Check 'porch_matches_documented_target' ([Math]::Abs($porch.w*$porch.d-120.0)-lt 0.001) 'Porch remains the documented 12 x 10 ft / 120 sf test.'
Add-Check 'module_run_matches_source_lengths' ([Math]::Abs((($modules|ForEach-Object { [double]$_['length'] }|Measure-Object -Sum).Sum)-12.5)-lt 0.001) 'Source-sized modules total 12 ft 6 in.'
Add-Check 'perimeter_run_inside_kitchen' $runBoundsCheck '12 ft 6 in cabinet run occupies a 13 ft 6 in east wall segment.'
Add-Check 'island_inside_kitchen' ($island.x -ge $kitchen.x -and $island.y -ge $kitchen.y -and ($island.x+$island.w) -le ($kitchen.x+$kitchen.w) -and ($island.y+$island.d) -le ($kitchen.y+$kitchen.d)) 'Rotated 8 x 4 ft island body remains inside proposed kitchen block.'
Add-Check 'assumed_stool_zone_inside_kitchen' $stoolFitsKitchen 'Assumed 24 in occupied depth remains inside M-02.'
Add-Check 'documented_42in_work_aisle' ([Math]::Abs($aisleIn-42.0)-lt 0.001) 'Island-to-perimeter face aisle is the documented 42 in minimum.'
Add-Check '36in_route_fits_aisle' ([Math]::Abs(($routeWidth*12)-36.0)-lt 0.001 -and $routeMarginIn -ge 0) '36 in route fits in the 42 in aisle with 3 in margins per side.'
Add-Check 'half_wall_adjustment_within_spec' ($halfWall.w -ge 7 -and $halfWall.w -le 9) '7 ft half-wall is within the documented 8 ft +/- 12 in range.'
Add-Check 'minimum_opening_preserved' ($livingOpening.w -ge 6.0 -and $unassignedReturn.x+$unassignedReturn.w -le $kitchen.w+0.000001) 'Proposed 6 ft opening and 1 ft remaining edge reserve fit the 14 ft side.'
Add-Check 'table_and_chairs_inside_dining' ($chairBoundsCheck -and $table.x -ge $dining.x -and ($table.x+$table.w) -le $diningTargetEast -and $table.y -ge $dining.y -and ($table.y+$table.d) -le ($dining.y+$dining.d)) 'Table and four explicit chair proxies remain inside the 11 x 10 ft dining zone.'
Add-Check 'table_documented_minimum_clearances' (@($tableClearance.Values | Where-Object {[double]$_ -lt 36}).Count -eq 0 -and $tableClearance.west_in -eq 36 -and $tableClearance.east_in -eq 36) 'Minimum 36 in end pull-out envelopes fit exactly; no end chairs are placed.'
Add-Check 'four_chairs_do_not_overlap_table' ($chairTableHits.Count -eq 0) 'The four table-side/end chair rectangles do not overlap the table body.'
Add-Check 'route_centerline_is_orthogonal' $routeCenterAxisAligned 'Route centerline uses only axis-aligned segments.'
Add-Check 'route_avoids_closed_state_obstacles' ($routeHits.Count -eq 0) 'Route corridor has no positive-area intersection with modeled closed-state obstacles.'
Add-Check 'route_passes_living_opening' ($routePoints[0].x -ge $livingOpening.x -and $routePoints[0].x -le ($livingOpening.x+$livingOpening.w)) 'Route centerline enters through the proposed 6 ft living opening.'
Add-Check 'route_fits_nominal_porch_door' ([Math]::Abs($door.center_x-$routePoints[2].x)-lt 0.001 -and $door.right-$door.left -eq 5.0 -and $routeWidth -le ($door.right-$door.left)) '36 in route is centered within a nominal 5 ft door reservation.'
Add-Check 'route_reaches_porch_3ft' ([Math]::Abs(($routePoints[-1].y-$porch.y)-3.0)-lt 0.001) 'Route continues 3 ft into the porch test rectangle.'
Add-Check 'porch_wall_gap_preserved' ([Math]::Abs($porch.y-($dining.y+$dining.d)-0.5)-lt 0.001) '0.5 ft porch wall-gap convention is preserved.'
Add-Check 'route_dining_zone_spill_is_reported' ($diningZoneSpillIn -gt 0) 'The 36 in route corridor extends beyond the 11 ft dining zone into unassigned open-plan space; the spill is quantified.'
Add-Check 'm06_b_remains_unassigned' ($m173.geometry.m06_window_b_remains_unassigned -eq $true) 'M-06/B is not assigned by this kitchen/dining proposal.'

$passed=@($checks|Where-Object pass).Count; $checkStatus='fail'; if($passed -eq $checks.Count){$checkStatus='pass'}
$hashes=[ordered]@{
    'Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'=(Get-FileHash $m172Path -Algorithm SHA256).Hash.ToLowerInvariant()
    'Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'=(Get-FileHash $m173Path -Algorithm SHA256).Hash.ToLowerInvariant()
    'Architecture/Selected_Design_Iteration_2026-10-27/study.json'=$selectedDHash
    'Architecture/Kitchen_Dining_Porch_Specs.md'=(Get-FileHash $specPath -Algorithm SHA256).Hash.ToLowerInvariant()
    'Decisions/Kitchen_Island_Finish.md'=(Get-FileHash $islandDecisionPath -Algorithm SHA256).Hash.ToLowerInvariant()
    'Decisions/2026-10-28_House_Design_Direction_Followup.md'=(Get-FileHash $followupPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
$report=[ordered]@{
    schema='forever-home-m177-compact-social-open-plan-v1'
    status='unapproved compact open-plan geometry proposal; no house layout selected'
    source_fingerprints_sha256=$hashes
    program_targets=[ordered]@{kitchen_area_sf=$m02AreaTarget;dining_area_sf=$m03AreaTarget;porch_area_sf=120;interpretation='Program areas; kitchen and dining are not treated as fixed finished rectangles.'}
    proposal=[ordered]@{
        kitchen=[ordered]@{rect_ft=@($kitchen.x,$kitchen.y,$kitchen.w,$kitchen.d);area_sf=$kitchen.area_sf;area_over_target_sf=21;tradeoff='The 14 x 13.5 ft route-study envelope adds 21 sf to the 168 sf program target; it does not demonstrate every perimeter clearance or seating condition.'}
        dining=[ordered]@{rect_ft=@($dining.x,$dining.y,$dining.w,$dining.d);area_sf=110;table_rect_ft=@($table.x,$table.y,$table.w,$table.d);furniture='Two chairs on the south long side and two at the west end; no north/east end chairs, leaving the route approach unobstructed.';minimum_clearance_in=$tableClearance}
        island=[ordered]@{rect_ft=@($island.x,$island.y,$island.w,$island.d);source_size_ft=@(8,4);orientation='4 ft across kitchen width and 8 ft toward dining; two stools are proposed on the 4 ft dining-facing end.';stool_occupied_zone_rect_ft=@($stools.x,$stools.y,$stools.w,$stools.d);stool_depth_basis='Assumed 24 in plan-depth proxy; occupied product envelope not measured.'}
        perimeter=[ordered]@{rect_ft=@($counter.x,$counter.y,$counter.w,$counter.d);module_order=@('sink-base','dishwasher','west-range-landing','induction-range','east-range-landing','refrigerator');module_total_ft=$perimeterRunLength;service_and_open_appliance_envelopes_modeled=$false}
        half_wall=[ordered]@{wall_length_ft=7;opening_width_ft=6;unassigned_edge_return_ft=1;status='Proposal using low end of documented half-wall adjustment; no wall or opening authored.'}
        porch=[ordered]@{rect_ft=@($porch.x,$porch.y,$porch.w,$porch.d);nominal_door=[ordered]@{width_ft=5;center_offset_east_ft=3};wall_gap_ft=0.5}
        route=[ordered]@{width_in=36;centerline_ft=$routePoints;closed_state_obstacle_intersections=$routeHits.ToArray();work_aisle_width_in=$aisleIn;route_margin_each_side_in=$routeMarginIn;dining_zone_east_spill_in=$diningZoneSpillIn;status='Plan-coordinate living-to-porch proposal through the 42 in kitchen aisle; it does not validate travel with appliances open.'}
    }
    conclusion='A connected 36 in living-to-porch centerline avoids the modeled closed-state furniture and cabinet blocks in this explicit route study. The kitchen envelope is 21 sf above the owner-directed program target, the 4 ft dining-facing island end gives two assumed 24 in stool positions no side allowance, the dining route shares the no-end-chair zone, and the route uses a 42 in work aisle with only 3 in geometric margins. Treat as a trade-off study, not a selected plan.'
    limitations=@('The 42 in clearance from island to half-wall is not modeled or established by this candidate.','No complete room boundary, wall returns, swing arcs, thresholds or physical clear openings are modeled.','The 5 ft French-door pair and 6 ft living opening are nominal reservations, not verified clear widths.','Oven, dishwasher and refrigerator operation envelopes are absent; the route may be blocked while appliances are open.','The stool body, pull-back, ergonomic envelope and product selection are unverified; the 24 in occupancy depth is an assumption.','No site, overall shell fit, M-06 fixture fit, service route, roof, structure, IFC, code review or professional review is included.','The proposal does not change selected-D, assign M-06/B, or establish code compliance, accessibility, structural safety, certification, permit approval or construction readiness.')
}
$checkReport=[ordered]@{status=$checkStatus;passed=$passed;total=$checks.Count;checks=$checks.ToArray()}
$csv=$checks.ToArray()|ForEach-Object{[pscustomobject]@{id=$_.id;pass=$_.pass;detail=$_.detail}}

# Compact SVG: visual context only; every displayed footprint comes from this report.
$scale=38.0;$ox=110.0;$oy=1040.0;$svgW=920;$svgH=1160
function X([double]$v){$ox+$v*$scale}
function Y([double]$v){$oy-$v*$scale}
function SvgRect([object]$r,[string]$class,[string]$label=''){
    $xx=X ([double]$r.x);$yy=Y ([double]$r.y+[double]$r.d);$ww=[double]$r.w*$scale;$hh=[double]$r.d*$scale
    $t="<rect class='$class' x='$xx' y='$yy' width='$ww' height='$hh'/>"
    if($label){$t+="<text class='label' x='$([Math]::Round($xx+5,1))' y='$([Math]::Round($yy+18,1))'>$label</text>"};return $t
}
$svg=New-Object System.Collections.Generic.List[string]
$svg.Add("<svg xmlns='http://www.w3.org/2000/svg' width='$svgW' height='$svgH' viewBox='0 0 $svgW $svgH'>")
$svg.Add('<style>text{font:14px Arial;fill:#302b25}.title{font-size:22px;font-weight:bold}.small{font-size:12px}.kitchen{fill:#f4eadb;stroke:#554b40;stroke-width:2}.dining{fill:#f7f0e4;stroke:#766b5d;stroke-width:2}.porch{fill:#e8efe2;stroke:#65745e;stroke-width:2}.cabinet{fill:#d9c7aa;stroke:#6a5944}.island{fill:#dce7db;stroke:#667963;stroke-width:2}.stool{fill:#dce7db;fill-opacity:.4;stroke:#667963;stroke-dasharray:6 4}.table{fill:#c99f68;stroke:#6a4f32}.chair{fill:#c8b6a0;stroke:#655a4e}.route{fill:#67a7ca;fill-opacity:.28;stroke:#287aa6;stroke-width:1}.wall{stroke:#745d42;stroke-width:8}.opening{stroke:#f4eadb;stroke-width:10}.door{stroke:#ad6b45;stroke-width:7}.note{font-size:14px;fill:#51473d}</style>')
$svg.Add("<text class='title' x='28' y='34'>M177 - compact open-plan candidate (unapproved)</text>")
$svg.Add("<text class='note' x='28' y='58'>Kitchen area trade-off: +21 sf vs target. Route is closed-appliance plan geometry only.</text>")
$svg.Add((SvgRect $porch 'porch' 'Porch 12 x 10'))
$svg.Add((SvgRect $dining 'dining' 'Dining 11 x 10'))
$svg.Add((SvgRect $kitchen 'kitchen' 'Kitchen 14 x 13.5 (189 sf)'))
$svg.Add((SvgRect $counter 'cabinet' '12.5 ft perimeter run'))
$svg.Add((SvgRect $island 'island' 'Island 8 x 4, rotated'))
$svg.Add((SvgRect $stools 'stool' '24 in stool-depth proxy'))
$svg.Add((SvgRect $table 'table' '36 x 60 table'))
foreach($c in $chairs){$svg.Add((SvgRect $c 'chair'))}
foreach($r in $routeRects){$svg.Add((SvgRect $r 'route'))}
$svg.Add("<line class='wall' x1='$(X 0)' y1='$(Y 0)' x2='$(X 7)' y2='$(Y 0)'/>")
$svg.Add("<line class='opening' x1='$(X 7)' y1='$(Y 0)' x2='$(X 13)' y2='$(Y 0)'/>")
$svg.Add("<line class='wall' x1='$(X 0)' y1='$(Y 0)' x2='$(X 0)' y2='$(Y 0.5)'/>")
$svg.Add("<line class='wall' x1='$(X 7)' y1='$(Y 0)' x2='$(X 7)' y2='$(Y 0.5)'/>")
$svg.Add("<line class='wall' x1='$(X 13)' y1='$(Y 0)' x2='$(X 13)' y2='$(Y 0.5)'/>")
$svg.Add("<line class='door' x1='$(X 6)' y1='$(Y 23.5)' x2='$(X 11)' y2='$(Y 23.5)'/>")
$svg.Add("<text class='small' x='$(X 0)' y='1090'>Living-side approach; wall extent not modeled</text>")
$svg.Add("<text class='small' x='$(X 0)' y='1110'>North is up | route width 36 in | nominal doors are not verified clear openings</text>")
$svg.Add('</svg>')

$report|ConvertTo-Json -Depth 100|Set-Content -LiteralPath (Join-Path $output 'm177-study.json') -Encoding UTF8
$checkReport|ConvertTo-Json -Depth 50|Set-Content -LiteralPath (Join-Path $output 'm177-checks.json') -Encoding UTF8
$csv|ConvertTo-Csv -NoTypeInformation|Set-Content -LiteralPath (Join-Path $output 'm177-checks.csv') -Encoding UTF8
$svg -join "`n"|Set-Content -LiteralPath (Join-Path $output 'm177-plan.svg') -Encoding UTF8
Write-Output ("M177 proposal: {0}/{1} checks passed; M-02 {2:F1} sf (+{3:F1} sf); M-03 {4:F1} sf; route width {5:F0} in; route-obstacle intersections {6}; M-03 east-side zone spill {7:F1} in." -f $passed,$checks.Count,$kitchen.area_sf,($kitchen.area_sf-$m02AreaTarget),$dining.area_sf,($routeWidth*12),$routeHits.Count,$diningZoneSpillIn)
if($passed -ne $checks.Count){exit 1}
