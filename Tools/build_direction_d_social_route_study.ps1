param([string]$OutputDirectory = 'Architecture/Direction_D_Social_Route_Study_2026-10-27')

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out = Join-Path $root $OutputDirectory
$candidatePath = Join-Path $root 'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$dPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$specPath = Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
$decisionPath = Join-Path $root 'Decisions/2026-10-27_Selected_Architectural_Direction_D.md'
$specText = Get-Content -Raw $specPath
$decisionText = Get-Content -Raw $decisionPath
$candidate = Get-Content -Raw $candidatePath | ConvertFrom-Json
$dSource = Get-Content -Raw $dPath | ConvertFrom-Json
$kitchen = $candidate.plans.main | Where-Object id -eq 'M-02'
$dining = $candidate.plans.main | Where-Object id -eq 'M-03'
$living = $candidate.plans.main | Where-Object id -eq 'M-01'
$entry = $candidate.plans.main | Where-Object id -eq 'M-05'
$islandSpec = $dSource.selection.kitchen
$shellNumbers = [regex]::Matches($dSource.selection.main_shell,'\d+')
$shellW = [double]$shellNumbers[0].Value; $shellD = [double]$shellNumbers[1].Value
$scale = 18.0
$originX = 54.0; $originY = 58.0
$porch = [ordered]@{ x=[double]$dining.x; y=([double]$dining.y+[double]$dining.d+0.5); w=12.0; d=10.0; gap_ft=0.5 }
$island = [ordered]@{
    x=([double]$kitchen.x+[double]$islandSpec.island_origin_local_ft[0])
    y=([double]$kitchen.y+[double]$islandSpec.island_origin_local_ft[1])
    w=[double]$islandSpec.island_ft[0]
    d=[double]$islandSpec.island_ft[1]
}
$table = [ordered]@{ x=([double]$dining.x+3.0); y=([double]$dining.y+4.8333333333); w=3.0; d=5.0 }
$chairs = @(
    [ordered]@{ id='D-chair-1'; x=($table.x-20.0/12); y=($table.y+0.25); w=20.0/12; d=1.5 },
    [ordered]@{ id='D-chair-2'; x=($table.x-20.0/12); y=($table.y+1.75); w=20.0/12; d=1.5 },
    [ordered]@{ id='D-chair-3'; x=($table.x-20.0/12); y=($table.y+3.25); w=20.0/12; d=1.5 },
    [ordered]@{ id='D-chair-4'; x=($table.x+0.75); y=($table.y-20.0/12); w=1.5; d=20.0/12 }
)
$chairsB = @(
    [ordered]@{ id='B-chair-1'; x=($table.x-20.0/12); y=($table.y+0.75); w=20.0/12; d=1.5 },
    [ordered]@{ id='B-chair-2'; x=($table.x-20.0/12); y=($table.y+2.75); w=20.0/12; d=1.5 },
    [ordered]@{ id='B-chair-3'; x=($table.x+0.75); y=($table.y-20.0/12); w=1.5; d=20.0/12 },
    [ordered]@{ id='B-chair-4'; x=($table.x+0.75); y=($table.y+$table.d); w=1.5; d=20.0/12 }
)
$doorWidth = 5.0
$doorX = [double]$dining.x + ([double]$dining.w-$doorWidth)/2
$doorCenterB = [double]$dining.x + [double]$dining.w/2 + 1.5
$doorXB = $doorCenterB-$doorWidth/2
$diningEast = [double]$dining.x + [double]$dining.w
$tableEast = [double]$table.x + [double]$table.w
$tableSouth = [double]$table.y + [double]$table.d
$routeWidth = 3.0
$routeX0 = $tableEast
$routeX1 = $diningEast
$routeY0 = $tableSouth
$routeY1 = [double]$dining.y+[double]$dining.d
$porchEast = $porch.x+$porch.w
$porchSouth = $porch.y+$porch.d
$shellEdgeReserveIn = ($shellD-$porchSouth)*12
$islandEastClearIn = (($kitchen.x+$kitchen.w)-($island.x+$island.w))*12
$islandFrontAisleIn = (($island.y-($kitchen.y+2.0))*12)
$islandBackClearFt = ($kitchen.y+$kitchen.d)-($island.y+$island.d)
$stoolAllowanceFt = 2.0
$islandBackRouteClearFt = $islandBackClearFt-$stoolAllowanceFt
$eastRouteClearFt = $diningEast-$tableEast
$southTableClearFt = $routeY1-$tableSouth
$bath = $candidate.selection.main_public_bath.search_windows | Where-Object id -eq 'east_of_core'

function Sha([string]$p) { (Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash.ToLowerInvariant() }
function RectSvg([double]$x,[double]$y,[double]$w,[double]$h,[string]$class) {
    $sx=[Math]::Round($originX+$x*$scale,2); $sy=[Math]::Round($originY+$y*$scale,2)
    "<rect x='$sx' y='$sy' width='$([Math]::Round($w*$scale,2))' height='$([Math]::Round($h*$scale,2))' class='$class'/>"
}
function TextSvg([double]$x,[double]$y,[string]$class,[string]$label) {
    $sx=[Math]::Round($originX+$x*$scale,2); $sy=[Math]::Round($originY+$y*$scale,2)
    "<text x='$sx' y='$sy' class='$class'>$([System.Security.SecurityElement]::Escape($label))</text>"
}

$svg = @()
$svg += "<text x='36' y='34' class='h'>Direction D social route and furnishing fit - unapproved schematic</text>"
$svg += "<text x='36' y='56' class='note'>B-first adjacency candidate; existing room blocks retained. Dashed test shell is 40 x 42 ft, not an approved exterior wall line.</text>"
$svg += RectSvg 0 0 $shellW $shellD 'shell'
foreach($r in $candidate.plans.main) {
    $class=if($r.id -eq 'M-06'){'bath'}else{'room'}
    $svg += RectSvg ([double]$r.x) ([double]$r.y) ([double]$r.w) ([double]$r.d) $class
    $svg += TextSvg ([double]$r.x+0.2) ([double]$r.y+0.75) 'label' "$($r.id) $($r.name)"
}
$svg += RectSvg $porch.x $porch.y $porch.w $porch.d 'porch'
$svg += TextSvg ($porch.x+0.25) ($porch.y+1.0) 'label' 'X-01 Porch 12 x 10 ft (test adjacency)'
$svg += RectSvg ([double]$bath.x) ([double]$bath.y) ([double]$bath.w) ([double]$bath.d) 'bath'
$svg += TextSvg ([double]$bath.x+0.2) ([double]$bath.y+1.0) 'tiny' 'M-06 B SEARCH WINDOW (unassigned; no bath fit)'
$svg += RectSvg $island.x $island.y $island.w $island.d 'island'
$svg += TextSvg ($island.x+0.35) ($island.y+2.1) 'small' '8 x 4 island'
$svg += TextSvg ($kitchen.x+0.2) ($kitchen.y+15.3) 'small' '48 in post-seating route clearance to shared room edge'
# Dining table and four documented 18 x 20 in chair proxies. This deliberately
# asymmetrical proposal reserves the east side and south end as the route.
$svg += RectSvg $table.x $table.y $table.w $table.d 'table'
$svg += TextSvg ($table.x+0.15) ($table.y+2.7) 'small' '36 x 60 table'
foreach($c in $chairs){$svg += RectSvg $c.x $c.y $c.w $c.d 'chair'}
$svg += TextSvg ($table.x-0.35) ($table.y-0.2) 'tiny' '3 chairs west + 1 north; proposal only'
# Unoccupied east-side/south-end 36-in route, joining the island approach to a
# centered 5-ft French-door reservation and the attached porch block.
$routeStartX=$island.x+$island.w/2
$routeStartY=$island.y+$island.d+$stoolAllowanceFt
$routeJoinY=$dining.y
$routePathX=$routeStartX
$routeTurnY=$tableSouth+($routeWidth/2)
$routeDoorCenter=$dining.x+$dining.w/2
$routeRects=@(
    [ordered]@{x=($routeStartX-$routeWidth/2);y=$routeStartY;w=$routeWidth;h=($routeTurnY-$routeStartY)},
    [ordered]@{x=($routeDoorCenter-$routeWidth/2);y=$tableSouth;w=($routeStartX-$routeDoorCenter+$routeWidth);h=$routeWidth},
    [ordered]@{x=($routeDoorCenter-$routeWidth/2);y=$routeTurnY;w=$routeWidth;h=($routeY1-$routeTurnY)}
)
$routeRectsB=@(
    [ordered]@{x=($routeStartX-$routeWidth/2);y=$routeStartY;w=$routeWidth;h=($routeTurnY-$routeStartY)},
    [ordered]@{x=($doorCenterB-$routeWidth/2);y=$tableSouth;w=($routeStartX-$doorCenterB+$routeWidth);h=$routeWidth},
    [ordered]@{x=($doorCenterB-$routeWidth/2);y=$routeTurnY;w=$routeWidth;h=($routeY1-$routeTurnY)}
)
$routeTurnY=$tableSouth+($routeWidth/2)
$routePoly="$(($routeStartX*$scale+$originX)),$(($routeStartY*$scale+$originY)) $(($routeStartX*$scale+$originX)),$(($routeJoinY*$scale+$originY)) $(($routePathX*$scale+$originX)),$(($routeTurnY*$scale+$originY)) $(($routeDoorCenter*$scale+$originX)),$(($routeTurnY*$scale+$originY)) $(($routeDoorCenter*$scale+$originX)),$(($routeY1*$scale+$originY))"
$svg += "<polyline points='$routePoly' class='route'/>"
$doorSvgX=$originX+$doorX*$scale; $doorSvgY=$originY+$routeY1*$scale
$svg += "<line x1='$doorSvgX' y1='$doorSvgY' x2='$($doorSvgX+$doorWidth*$scale)' y2='$doorSvgY' class='door'/>"
$svg += TextSvg ($doorX+0.1) ($routeY1-0.2) 'tiny' '5-ft French-door pair reservation; clear leaf unverified'
# Label the existing shared kitchen/living edge as a length allowance, without
# asserting a wall segment position.
$sharedEdge=$living.y+$living.d-$kitchen.y
$svg += TextSvg ($kitchen.x+$kitchen.w+0.15) ($kitchen.y+7) 'tiny' '8-ft half-wall + 7-ft remaining open edge (position not assigned)'
$svg += TextSvg 0 ($shellD+1.4) 'note' "Porch-to-test-outline reserve: $([Math]::Round($shellEdgeReserveIn,1)) in; this is a fit warning, not wall thickness allowance."
$svg += TextSvg 0 ($shellD+2.4) 'note' "Route proposal: 36 in; east dining band $([Math]::Round($eastRouteClearFt,2)) ft, south table end $([Math]::Round($southTableClearFt,2)) ft; French-door leaf clear width unresolved."
$svg += TextSvg 0 ($shellD+3.4) 'note' 'Not for construction: room boundaries, openings, wall/floor assemblies, site orientation and entry approach are schematic or unresolved.'

$report=[ordered]@{
    schema='forever-home-direction-d-social-route-v1'
    status='unapproved furnishing and social-route proposal; not house geometry or a selected layout'
    source_fingerprints_sha256=[ordered]@{
        'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'=Sha $candidatePath
        'Architecture/Selected_Design_Iteration_2026-10-27/study.json'=Sha $dPath
        'Architecture/Kitchen_Dining_Porch_Specs.md'=Sha $specPath
        'Decisions/2026-10-27_Selected_Architectural_Direction_D.md'=Sha $decisionPath
    }
    inputs=[ordered]@{
        main_shell_test_ft=@($shellW,$shellD)
        porch_ft=@(12,10)
        porch_wall_gap_ft=0.5
        island_ft=@($island.w,$island.d)
        island_origin_local_ft=@([double]$islandSpec.island_origin_local_ft[0],[double]$islandSpec.island_origin_local_ft[1])
        table_ft=@(3,5)
        chairs_in=@(18,20)
        target_route_width_ft=3
        french_door_pair_nominal_ft=5
        half_wall_and_minimum_opening_ft=@(8,6)
    }
    geometry=[ordered]@{
        kitchen_id='M-02'; dining_id='M-03'; living_id='M-01'; entry_id='M-05'
        island_world_rect_ft=@([Math]::Round($island.x,3),[Math]::Round($island.y,3),$island.w,$island.d)
        dining_table_world_rect_ft=@([Math]::Round($table.x,3),[Math]::Round($table.y,3),$table.w,$table.d)
        dining_chairs_world_rects_ft=$chairs
        alternative_dining_chairs_world_rects_ft=$chairsB
        porch_world_rect_ft=@([Math]::Round($porch.x,3),[Math]::Round($porch.y,3),$porch.w,$porch.d)
        proposed_door_opening_world_ft=@([Math]::Round($doorX,3),[Math]::Round($routeY1,3),$doorWidth)
        porch_to_test_shell_edge_reserve_in=[Math]::Round($shellEdgeReserveIn,2)
        island_front_clearance_in=[Math]::Round($islandFrontAisleIn,2)
        island_east_edge_clearance_in=[Math]::Round($islandEastClearIn,2)
        island_back_total_allowance_ft=[Math]::Round($islandBackClearFt,3)
        documented_stool_allowance_ft=$stoolAllowanceFt
        post_seating_route_clear_ft=[Math]::Round($islandBackRouteClearFt,3)
        dining_east_clear_band_ft=[Math]::Round($eastRouteClearFt,3)
        dining_south_table_clear_ft=[Math]::Round($southTableClearFt,3)
        proposed_route_centerline_world_ft=@(@([Math]::Round($routeStartX,3),[Math]::Round($routeStartY,3)),@([Math]::Round($routePathX,3),[Math]::Round($routeJoinY,3)),@([Math]::Round($routePathX,3),[Math]::Round($routeTurnY,3)),@([Math]::Round($routeDoorCenter,3),[Math]::Round($routeTurnY,3)),@([Math]::Round($routeDoorCenter,3),[Math]::Round($routeY1,3)))
        route_corridor_rectangles_ft=$routeRects
        kitchen_living_shared_edge_ft=[Math]::Round($sharedEdge,3)
        half_wall_allowance_ft=@(8,[Math]::Round($sharedEdge-8,3))
        m06_window_b_remains_unassigned=$true
        entry_approach='Unverified; M-05 is on the east exterior wall in inherited B-first adjacency candidate.'
    }
    route=[ordered]@{
        target_width_in=36
        connected_by_plan_polyline=$true
        dining_furniture_arrangement='Three chairs on the west long side and one at the north end; no chairs at the south end or east side. Deliberately asymmetric proposal to preserve the porch route.'
        nominal_door_width_in=60
        clear_leaf_width_verified=$false
        status='36-in geometric corridor passes the drawn table/chair proxies; actual door clear width, leaf swing, floor transition and furnished-use clearance require product/site review.'
    }
    second_route_scenario=[ordered]@{
        furniture_arrangement='Two chairs on the west long side, one north and one south; more conventional end seating, with all chairs clear of the east-side/south-turn route.'
        nominal_door_center_offset_from_dining_center_ft=1.5
        nominal_door_width_ft=$doorWidth
        clear_leaf_width_verified=$false
        route_corridor_rectangles_ft=$routeRectsB
        route_centerline_world_ft=@(@([Math]::Round($routeStartX,3),[Math]::Round($routeStartY,3)),@([Math]::Round($routeStartX,3),[Math]::Round($routeTurnY,3)),@([Math]::Round($doorCenterB,3),[Math]::Round($routeTurnY,3)),@([Math]::Round($doorCenterB,3),[Math]::Round($routeY1,3)))
        tradeoff='The 5-ft nominal porch-door reservation shifts 1.5 ft east of the dining centerline; actual wall returns and visual alignment need review.'
    }
    tradeoffs=@(
        'Keeping pantry-side M-06 window B clear uses the bath-first candidate, which moves M-05 entry/hall to the east exterior wall; front orientation and approach are unresolved.',
        'Adding the documented porch directly to dining leaves only 4 in to the 42-ft test-outline edge. The test outline cannot be treated as a coordinated exterior wall line; porch footprint or main-shell envelope needs owner/site coordination.',
        'The route-preserving four-seat table arrangement is asymmetric (three chairs on one long side, one at the north end). A conventional chair arrangement may obstruct the proposed route when occupied.',
        'A second, more evenly seated option moves the nominal 5-ft French-door reservation 1.5 ft east of the dining centerline; verify wall returns and sightline before selection.',
        'The 5-ft nominal French-door pair reservation is not evidence of a 36-in clear leaf; vendor clear opening and swing remain unresolved.',
        'The 8-ft half wall and remaining open span are only edge-length arithmetic; no wall segment location, height-bearing status or framing is defined.'
    )
}

$checks=@(
    @{id='source_candidate_room_blocks';pass=([Math]::Abs(($kitchen.w*$kitchen.d)-277.333333333) -lt 0.01 -and [Math]::Abs(($dining.w*$dining.d)-158.666666667) -lt 0.01)},
    @{id='island_within_kitchen';pass=($island.x -ge $kitchen.x -and $island.y -ge $kitchen.y -and ($island.x+$island.w) -le ($kitchen.x+$kitchen.w) -and ($island.y+$island.d) -le ($kitchen.y+$kitchen.d))},
    @{id='island_work_aisle';pass=($islandFrontAisleIn -ge 42 -and $islandFrontAisleIn -ge 48 -and $islandEastClearIn -ge 42)},
    @{id='route_width_at_island_exit';pass=($islandBackRouteClearFt*12 -ge 36)},
    @{id='dining_route_around_furniture';pass=($eastRouteClearFt -ge 3 -and $southTableClearFt -ge 3 -and ($routePathX-$routeWidth/2) -ge $tableEast -and ($routePathX+$routeWidth/2) -le $diningEast -and $doorX -le ($dining.x+$dining.w/2) -and ($doorX+$doorWidth) -ge ($dining.x+$dining.w/2))},
    @{id='route_corridor_avoids_table_and_seated_chairs';pass=(@($routeRects|Where-Object{($_.x -lt $tableEast) -and (($_.x+$_.w) -gt $table.x) -and ($_.y -lt $tableSouth) -and (($_.y+$_.h) -gt $table.y)}).Count -eq 0 -and @($routeRects|Where-Object{$seg=$_; @($chairs|Where-Object{($_.x -lt ($seg.x+$seg.w)) -and (($_.x+$_.w) -gt $seg.x) -and ($_.y -lt ($seg.y+$seg.h)) -and (($_.y+$_.h) -gt $seg.y)}).Count -gt 0}).Count -eq 0)},
    @{id='offset_door_option_route_clear';pass=($doorXB -ge $dining.x -and ($doorXB+$doorWidth) -le $diningEast -and ($doorCenterB-$routeWidth/2) -ge $dining.x -and ($doorCenterB+$routeWidth/2) -le $diningEast -and ($routePathX-$routeWidth/2) -ge $tableEast -and @($routeRectsB|Where-Object{($_.x -lt $tableEast) -and (($_.x+$_.w) -gt $table.x) -and ($_.y -lt $tableSouth) -and (($_.y+$_.h) -gt $table.y)}).Count -eq 0 -and @($routeRectsB|Where-Object{$seg=$_; @($chairsB|Where-Object{($_.x -lt ($seg.x+$seg.w)) -and (($_.x+$_.w) -gt $seg.x) -and ($_.y -lt ($seg.y+$seg.h)) -and (($_.y+$_.h) -gt $seg.y)}).Count -gt 0}).Count -eq 0)},
    @{id='porch_adjacent_and_inside_test_extent';pass=([Math]::Abs($porch.y-($dining.y+$dining.d+0.5)) -lt 0.001 -and ($porchEast -le $shellW) -and ($porchSouth -le $shellD))},
    @{id='bath_search_window_b_unassigned';pass=($bath.id -eq 'east_of_core' -and $candidate.selection.main_public_bath.footprint -eq 'TBD')},
    @{id='half_wall_edge_length_arithmetic';pass=($sharedEdge -ge 14 -and [Math]::Abs($islandEastClearIn) -ge 42)},
    @{id='door_clear_width_not_overclaimed';pass=(-not $report.route.clear_leaf_width_verified)},
    @{id='documented_inputs_present';pass=($specText -match '8''-0.*4''-0' -and $specText -match '12''-0.*10''-0' -and $specText -match '36.*60.*30' -and $specText -match '18.*20' -and $specText -match '5''-0' -and $specText -match '36" min' -and $specText -match '42" min' -and $decisionText -match '40 x 42' -and $decisionText -match 'search window B, east')},
    @{id='source_fingerprints_recorded';pass=($report.source_fingerprints_sha256.Count -eq 4)}
)
$checksOut=[ordered]@{status=if(@($checks|Where-Object{-not $_.pass}).Count -eq 0){'pass'}else{'fail'};passed=@($checks|Where-Object pass).Count;total=$checks.Count;checks=$checks;scope='Plan-coordinate, documented-clearance and provenance checks; not code/accessibility/IFC or construction validation.'}
$report['generated_utc']=[DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
New-Item -ItemType Directory -Force -Path $out|Out-Null
Set-Content -LiteralPath (Join-Path $out 'study.json') -Value ($report|ConvertTo-Json -Depth 12) -Encoding UTF8
$style="<style>text{font-family:Arial,sans-serif;fill:#29251f}.h{font-size:23px;font-weight:bold}.label{font-size:11px;font-weight:bold}.small{font-size:9px}.tiny{font-size:8px}.note{font-size:11px;fill:#8a482e}.shell{fill:none;stroke:#444;stroke-width:2;stroke-dasharray:8 5}.room{fill:#e8dfce;stroke:#554d44;stroke-width:1.4}.bath{fill:#fff4d3;stroke:#a57b27;stroke-width:1;stroke-dasharray:4 3}.porch{fill:#e6f0ed;stroke:#47776b;stroke-width:1.4}.island{fill:#d4dfc8;stroke:#5c704d;stroke-width:1.5}.table{fill:#bd8e61;stroke:#593c24;stroke-width:1.3}.chair{fill:#f4e5c9;stroke:#6f593b;stroke-width:1}.route{fill:none;stroke:#2c91a6;stroke-width:36;stroke-opacity:.4;stroke-linejoin:round;stroke-linecap:butt}.door{stroke:#265866;stroke-width:5}</style>"
$svgBody=$svg -join "`n"
$svgDoc="<?xml version='1.0' encoding='UTF-8'?><svg xmlns='http://www.w3.org/2000/svg' width='1200' height='1000' viewBox='0 0 1200 1000'>$style<rect width='1200' height='1000' fill='#fbf9f3'/>$svgBody</svg>"
Set-Content -LiteralPath (Join-Path $out 'social-route-plan.svg') -Value $svgDoc -Encoding UTF8
$svgB=@($svg|Where-Object{$_ -notmatch "class='chair'" -and $_ -notmatch "class='route'" -and $_ -notmatch "class='door'" -and $_ -notmatch '3 chairs west' -and $_ -notmatch '5-ft French-door pair reservation'})
$svgB[0]="<text x='36' y='34' class='h'>Direction D social route - Option B, even table seating / offset doors</text>"
$svgB+=TextSvg ($table.x-0.35) ($table.y-0.2) 'tiny' '2 west + 1 north + 1 south; proposal only'
foreach($c in $chairsB){$svgB+=RectSvg $c.x $c.y $c.w $c.d 'chair'}
$routePolyB="$(($routeStartX*$scale+$originX)),$(($routeStartY*$scale+$originY)) $(($routeStartX*$scale+$originX)),$(($routeTurnY*$scale+$originY)) $(($doorCenterB*$scale+$originX)),$(($routeTurnY*$scale+$originY)) $(($doorCenterB*$scale+$originX)),$(($routeY1*$scale+$originY))"
$svgB+="<polyline points='$routePolyB' class='route'/>"
$doorSvgXB=$originX+$doorXB*$scale
$svgB+="<line x1='$doorSvgXB' y1='$doorSvgY' x2='$($doorSvgXB+$doorWidth*$scale)' y2='$doorSvgY' class='door'/>"
$svgB+=TextSvg ($doorXB+0.1) ($routeY1-0.2) 'tiny' 'Option B: 5-ft pair shifted 1.5 ft east of dining centerline.'
$svgDocB="<?xml version='1.0' encoding='UTF-8'?><svg xmlns='http://www.w3.org/2000/svg' width='1200' height='1000' viewBox='0 0 1200 1000'>$style<rect width='1200' height='1000' fill='#fbf9f3'/>$($svgB -join "`n")</svg>"
Set-Content -LiteralPath (Join-Path $out 'social-route-plan-offset-door.svg') -Value $svgDocB -Encoding UTF8
Set-Content -LiteralPath (Join-Path $out 'checks.json') -Value ($checksOut|ConvertTo-Json -Depth 7) -Encoding UTF8
if($checksOut.status -ne 'pass'){throw 'Social-route study checks failed.'}
Write-Output "Direction D social-route study: $($checksOut.passed)/$($checksOut.total) checks passed."
Write-Output "Porch/test-shell edge reserve: $([Math]::Round($shellEdgeReserveIn,1)) in (reported as a trade-off, not treated as acceptable wall allowance)."
