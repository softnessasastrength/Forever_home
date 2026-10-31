param([string]$OutputDirectory = 'Architecture/Direction_D_Social_Route_Study_2026-10-27')

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out = Join-Path $root $OutputDirectory
$candidatePath = Join-Path $root 'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$dPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$specPath = Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
$decisionPath = Join-Path $root 'Decisions/2026-10-27_Selected_Architectural_Direction_D.md'
$kitchenFinishPath = Join-Path $root 'Decisions/Kitchen_Island_Finish.md'
$specText = Get-Content -Raw $specPath
$decisionText = Get-Content -Raw $decisionPath
$kitchenFinishText = Get-Content -Raw $kitchenFinishPath
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
$porchRotated = [ordered]@{ x=([double]$dining.x+([double]$dining.w-10.0)/2); y=$porch.y; w=10.0; d=12.0; gap_ft=0.5 }
$island = [ordered]@{
    x=([double]$kitchen.x+[double]$islandSpec.island_origin_local_ft[0])
    y=([double]$kitchen.y+[double]$islandSpec.island_origin_local_ft[1])
    w=[double]$islandSpec.island_ft[0]
    d=[double]$islandSpec.island_ft[1]
}
# M19 fit envelope: source-documented 24-in perimeter depth and module widths.
# The run is west-aligned on the documented north sink wall to preserve a
# clear east-side route lane around the cabinet endpoint. It remains a study.
$perimeterDepthFt = 2.0
$perimeterRunFt = (36+24+12+30+12+36)/12.0 # sink, DW, min landing, range, min landing, refrigerator
$perimeterX = [double]$kitchen.x
$perimeterY = [double]$kitchen.y + [double]$kitchen.d-$perimeterDepthFt
$perimeterModules = @(
    [ordered]@{id='sink_base';label='36 in sink base';width_ft=3.0},
    [ordered]@{id='dishwasher';label='24 in dishwasher';width_ft=2.0},
    [ordered]@{id='range_landing_west';label='12 in landing';width_ft=1.0},
    [ordered]@{id='induction_range';label='30 in induction range';width_ft=2.5},
    [ordered]@{id='range_landing_east';label='12 in landing';width_ft=1.0},
    [ordered]@{id='refrigerator';label='36 in refrigerator';width_ft=3.0}
)
$moduleX=$perimeterX
foreach($m in $perimeterModules){$m['x']=$moduleX;$m['y']=$perimeterY;$m['depth_ft']=$perimeterDepthFt;$moduleX += [double]$m.width_ft}
$halfWall = [ordered]@{x=([double]$kitchen.x+[double]$kitchen.w);y=[double]$kitchen.y;w=0.5;d=8.0}
$livingOpening = [ordered]@{x=([double]$kitchen.x+[double]$kitchen.w);y=([double]$kitchen.y+8.0);w=0.5;d=6.0}
$livingEdgeReserveFt = ([Math]::Min(([double]$kitchen.y+[double]$kitchen.d),([double]$living.y+[double]$living.d))-[Math]::Max([double]$kitchen.y,[double]$living.y))-($halfWall.d+$livingOpening.d)
$islandToCounterIn = ($perimeterY-$island.y-$island.d)*12
$table = [ordered]@{ x=([double]$dining.x+3.5); y=([double]$dining.y+([double]$dining.d-5.0)/2); w=3.0; d=5.0 }
$chairs = @(
    [ordered]@{ id='D-chair-1'; x=($table.x-20.0/12); y=($table.y+0.75); w=20.0/12; d=1.5 },
    [ordered]@{ id='D-chair-2'; x=($table.x-20.0/12); y=($table.y+2.75); w=20.0/12; d=1.5 },
    [ordered]@{ id='D-chair-3'; x=($table.x+0.75); y=($table.y-20.0/12); w=1.5; d=20.0/12 },
    [ordered]@{ id='D-chair-4'; x=($table.x+0.75); y=($table.y+$table.d); w=1.5; d=20.0/12 }
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
$tableClearancesFt=[ordered]@{west=[Math]::Round([double]$table.x-[double]$dining.x,3);east=[Math]::Round($diningEast-$tableEast,3);north=[Math]::Round([double]$table.y-[double]$dining.y,3);south=[Math]::Round(([double]$dining.y+[double]$dining.d)-$tableSouth,3)}
$routeWidth = 3.0
# Study-only occupied-stool depth proxy. The kitchen spec defines two stools and
# a 12-in overhang but does not specify an occupied plan-depth envelope.
$stoolAllowanceFt = 2.0
$routeY1 = [double]$dining.y+[double]$dining.d
$routePorchEndY = [double]$porch.y + $routeWidth
$routeLivingY = $livingOpening.y + $livingOpening.d/2
$routeLivingX = [double]$living.x + ($routeWidth/2)
$routeLaneX = ($moduleX + $halfWall.x) / 2
$routePathX = $island.x + $island.w/2
$routeMergeY = $table.y - ($routeWidth/2) - (2.0/12.0)
$routeTurnY = $routeY1 - 0.5
$routeDoorCenter = [double]$dining.x + [double]$dining.w/2
$routeDoorCenterB = $routeDoorCenter + 1.5
$routePointsA = @(
    @($routeLivingX,$routeLivingY),@($routeLaneX,$routeLivingY),@($routeLaneX,$routeMergeY),
    @($routePathX,$routeMergeY),@($routePathX,$routeTurnY),@($routeDoorCenter,$routeTurnY),@($routeDoorCenter,$routePorchEndY)
)
$routePointsB = @(
    @($routeLivingX,$routeLivingY),@($routeLaneX,$routeLivingY),@($routeLaneX,$routeMergeY),
    @($routePathX,$routeMergeY),@($routePathX,$routeTurnY),@($routeDoorCenterB,$routeTurnY),@($routeDoorCenterB,$routePorchEndY)
)
function New-RouteRects([object[]]$points,[double]$width) {
    $rects=@()
    for($i=0;$i -lt ($points.Count-1);$i++) {
        $p0=$points[$i];$p1=$points[$i+1]
        if([Math]::Abs([double]$p0[0]-[double]$p1[0]) -lt 0.000001) {
            $rects += [ordered]@{x=([double]$p0[0]-$width/2);y=([Math]::Min([double]$p0[1],[double]$p1[1]));w=$width;h=([Math]::Abs([double]$p1[1]-[double]$p0[1]))}
        } else {
            $rects += [ordered]@{x=([Math]::Min([double]$p0[0],[double]$p1[0]));y=([double]$p0[1]-$width/2);w=([Math]::Abs([double]$p1[0]-[double]$p0[0]));h=$width}
        }
        if($i -gt 0) {
            $corner=$p0
            $rects += [ordered]@{x=([double]$corner[0]-$width/2);y=([double]$corner[1]-$width/2);w=$width;h=$width}
        }
    }
    return ,$rects
}
function Test-RoutePointsAxisAligned([object[]]$points) {
    for($i=0;$i -lt ($points.Count-1);$i++) {
        $dx=[Math]::Abs([double]$points[$i+1][0]-[double]$points[$i][0])
        $dy=[Math]::Abs([double]$points[$i+1][1]-[double]$points[$i][1])
        if($dx -gt 0.000001 -and $dy -gt 0.000001){return $false}
    }
    return $true
}
$routeRects=New-RouteRects -points $routePointsA -width $routeWidth
$routeRectsB=New-RouteRects -points $routePointsB -width $routeWidth
$stoolZone=[ordered]@{x=[double]$island.x;y=([double]$island.y+[double]$island.d);w=[double]$island.w;d=$stoolAllowanceFt}
function Get-RectIntersections([object[]]$routeRectangles,[object[]]$obstacles) {
    $hits=@()
    foreach($r in $routeRectangles) { foreach($o in $obstacles) {
        $overlapX=[Math]::Min(([double]$r.x+[double]$r.w),([double]$o.x+[double]$o.w))-[Math]::Max([double]$r.x,[double]$o.x)
        $overlapY=[Math]::Min(([double]$r.y+[double]$r.h),([double]$o.y+[double]$o.d))-[Math]::Max([double]$r.y,[double]$o.y)
        if($overlapX -gt 0.000001 -and $overlapY -gt 0.000001) { $hits += [ordered]@{obstacle=$o.id;route_rect=$r;overlap_area_sf=[Math]::Round($overlapX*$overlapY,4)} }
    } }
    return ,$hits
}
$fixedKitchenObstacles=@($perimeterModules | ForEach-Object { [ordered]@{id=$_.id;x=[double]$_.x;y=[double]$_.y;w=[double]$_.width_ft;d=[double]$_.depth_ft} })
$wallObstacle=[ordered]@{id='half_wall';x=[double]$halfWall.x;y=[double]$halfWall.y;w=[double]$halfWall.w;d=[double]$halfWall.d}
$routeObstaclesA=@($fixedKitchenObstacles)+@([ordered]@{id='island';x=$island.x;y=$island.y;w=$island.w;d=$island.d})+@([ordered]@{id='stool_allowance';x=$stoolZone.x;y=$stoolZone.y;w=$stoolZone.w;d=$stoolZone.d})+@([ordered]@{id='dining_table';x=$table.x;y=$table.y;w=$table.w;d=$table.d})+@($chairs)+@($wallObstacle)
$routeObstaclesB=@($fixedKitchenObstacles)+@([ordered]@{id='island';x=$island.x;y=$island.y;w=$island.w;d=$island.d})+@([ordered]@{id='stool_allowance';x=$stoolZone.x;y=$stoolZone.y;w=$stoolZone.w;d=$stoolZone.d})+@([ordered]@{id='dining_table';x=$table.x;y=$table.y;w=$table.w;d=$table.d})+@($chairsB)+@($wallObstacle)
$routeObstacleHitsA=Get-RectIntersections -routeRectangles $routeRects -obstacles $routeObstaclesA
$routeObstacleHitsB=Get-RectIntersections -routeRectangles $routeRectsB -obstacles $routeObstaclesB
$porchEast = $porch.x+$porch.w
$porchSouth = $porch.y+$porch.d
$rotatedPorchSouth = $porchRotated.y+$porchRotated.d
$rotatedPorchOverflowIn = [Math]::Max(0,($rotatedPorchSouth-$shellD)*12)
$shellEdgeReserveIn = ($shellD-$porchSouth)*12
$islandEastClearIn = (($kitchen.x+$kitchen.w)-($island.x+$island.w))*12
$islandFrontAisleIn = (($island.y-($kitchen.y+2.0))*12)
$islandBackClearFt = $perimeterY-($island.y+$island.d)
$islandBackRouteClearFt = $islandBackClearFt-$stoolAllowanceFt
$islandPostStoolRouteShortfallIn = [Math]::Max(0,(36.0-$islandBackRouteClearFt*12))
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
function Get-MinRouteChairClearanceIn([object[]]$points,[object[]]$chairRects,[double]$routeWidthIn) {
    $best=[double]::PositiveInfinity
    for($i=0;$i -lt ($points.Count-1);$i++) {
        $p0=$points[$i];$p1=$points[$i+1]
        $segmentMinX=[Math]::Min([double]$p0[0],[double]$p1[0]);$segmentMaxX=[Math]::Max([double]$p0[0],[double]$p1[0])
        $segmentMinY=[Math]::Min([double]$p0[1],[double]$p1[1]);$segmentMaxY=[Math]::Max([double]$p0[1],[double]$p1[1])
        foreach($b in $chairRects){
        $dx=0.0;$dy=0.0
        if($segmentMaxX -lt $b.x){$dx=$b.x-$segmentMaxX}elseif(($b.x+$b.w) -lt $segmentMinX){$dx=$segmentMinX-($b.x+$b.w)}
        if($segmentMaxY -lt $b.y){$dy=$b.y-$segmentMaxY}elseif(($b.y+$b.d) -lt $segmentMinY){$dy=$segmentMinY-($b.y+$b.d)}
        $clearance=[Math]::Max(0,([Math]::Sqrt(($dx*$dx)+($dy*$dy))*12)-($routeWidthIn/2))
        if($clearance -lt $best){$best=$clearance}
        }
    }
    [Math]::Round($best,1)
}
$routeChairGapAIn=Get-MinRouteChairClearanceIn -points $routePointsA -chairRects $chairs -routeWidthIn ($routeWidth*12)
$routeChairGapBIn=Get-MinRouteChairClearanceIn -points $routePointsB -chairRects $chairsB -routeWidthIn ($routeWidth*12)
$routeTableGapAIn=Get-MinRouteChairClearanceIn -points $routePointsA -chairRects @([ordered]@{x=$table.x;y=$table.y;w=$table.w;d=$table.d}) -routeWidthIn ($routeWidth*12)
$routeTableGapBIn=Get-MinRouteChairClearanceIn -points $routePointsB -chairRects @([ordered]@{x=$table.x;y=$table.y;w=$table.w;d=$table.d}) -routeWidthIn ($routeWidth*12)
function Convert-RoutePointsToSvg([object[]]$points) {
    (($points | ForEach-Object { "$([Math]::Round($originX+[double]$_[0]*$scale,2)),$([Math]::Round($originY+[double]$_[1]*$scale,2))" }) -join ' ')
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
$svg += RectSvg $halfWall.x $halfWall.y $halfWall.w $halfWall.d 'wallproposal'
$svg += RectSvg $livingOpening.x $livingOpening.y $livingOpening.w $livingOpening.d 'openingproposal'
$svg += TextSvg ($halfWall.x+0.55) ($halfWall.y+4.3) 'tiny' '8-ft half-wall proposal'
$svg += TextSvg ($livingOpening.x+0.55) ($livingOpening.y+3.2) 'tiny' '6-ft opening proposal'
$svg += RectSvg $porch.x $porch.y $porch.w $porch.d 'porch'
$svg += TextSvg ($porch.x+0.25) ($porch.y+1.0) 'label' 'X-01 Porch 12 x 10 ft (test adjacency)'
$svg += RectSvg ([double]$bath.x) ([double]$bath.y) ([double]$bath.w) ([double]$bath.d) 'bath'
$svg += TextSvg ([double]$bath.x+0.2) ([double]$bath.y+1.0) 'tiny' 'M-06 B SEARCH WINDOW (unassigned; no bath fit)'
$svg += RectSvg $island.x $island.y $island.w $island.d 'island'
$svg += TextSvg ($island.x+0.35) ($island.y+2.1) 'small' '8 x 4 island'
$svg += RectSvg $perimeterX $perimeterY $perimeterRunFt $perimeterDepthFt 'counter'
$svg += TextSvg ($perimeterX+0.1) ($perimeterY+0.75) 'tiny' 'M19 perimeter run: 12 ft 6 in; source-sized schematic placeholders'
foreach($m in $perimeterModules){
    $svg += RectSvg ([double]$m.x) ([double]$m.y) ([double]$m.width_ft) $perimeterDepthFt 'appliance'
    $svg += TextSvg ([double]$m.x+0.05) ([double]$m.y+1.35) 'tiny' ([string]$m.id)
}
$svg += TextSvg ($kitchen.x+0.2) ($kitchen.y+15.3) 'small' "After 24 in stool allowance: $([Math]::Round($islandBackRouteClearFt*12,1)) in remains to counter front; 36 in route target misses by $([Math]::Round($islandPostStoolRouteShortfallIn,1)) in"
# Dining table and four documented 18 x 20 in chair proxies. This deliberately
# asymmetrical proposal reserves the east side and south end as the route.
$svg += RectSvg $table.x $table.y $table.w $table.d 'table'
$svg += TextSvg ($table.x+0.15) ($table.y+2.7) 'small' '36 x 60 table'
foreach($c in $chairs){$svg += RectSvg $c.x $c.y $c.w $c.d 'chair'}
$svg += TextSvg ($table.x-0.35) ($table.y-0.2) 'tiny' '2 chairs west; one at each end'
# Render the same multi-leg route rectangles that are checked against every
# modeled obstacle; avoid maintaining a separate, unvalidated drawing path.
$routeStartX=$routePointsA[0][0]; $routeStartY=$routePointsA[0][1]
$routePoly=Convert-RoutePointsToSvg -points $routePointsA
$svg += "<polyline points='$routePoly' class='route'/>"
$doorSvgX=$originX+$doorX*$scale; $doorSvgY=$originY+$routeY1*$scale
$svg += "<line x1='$doorSvgX' y1='$doorSvgY' x2='$($doorSvgX+$doorWidth*$scale)' y2='$doorSvgY' class='door'/>"
$svg += TextSvg ($doorX+0.1) ($routeY1-0.2) 'tiny' '5-ft French-door pair reservation; clear leaf unverified'
# Label the existing shared kitchen/living edge as a length allowance, without
# asserting a wall segment position.
$sharedEdge=$living.y+$living.d-$kitchen.y
$svg += TextSvg ($kitchen.x+$kitchen.w+0.15) ($kitchen.y+7) 'tiny' '8-ft half-wall + 6-ft opening + 1-ft remainder (proposal)'
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
        'Decisions/Kitchen_Island_Finish.md'=Sha $kitchenFinishPath
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
        stool_occupancy_allowance_ft=$stoolAllowanceFt
        stool_occupancy_allowance_basis='Assumed 2-ft plan-depth proxy; the source defines two stools and a 12-in overhang but no occupied-use depth.'
    }
    geometry=[ordered]@{
        kitchen_id='M-02'; dining_id='M-03'; living_id='M-01'; entry_id='M-05'
        tested_route_origin='Living-room side of the proposed kitchen/living opening.'
        tested_route_destination='Through a nominal dining-door reservation and the 6-in test gap to 3 ft inside the 12 x 10 ft porch test rectangle.'
        island_world_rect_ft=@([Math]::Round($island.x,3),[Math]::Round($island.y,3),$island.w,$island.d)
        kitchen_fit_study=[ordered]@{
            status='Schematic M19 fit option; positions/order are a test arrangement, not owner-selected fixture locations.'
            perimeter_run_world_rect_ft=@([Math]::Round($perimeterX,3),[Math]::Round($perimeterY,3),[Math]::Round($perimeterRunFt,3),$perimeterDepthFt)
            perimeter_modules=$perimeterModules
            island_to_perimeter_counter_clearance_in=[Math]::Round($islandToCounterIn,2)
            required_range_landing_each_side_in=12
            appliance_open_clearances_modeled=$false
            service_routes_modeled=$false
            layout_assumptions=@('One north-wall run west-aligned within the M-02 room-block test rectangle to leave an east-side route lane.','Source-size modules arranged sink, adjacent dishwasher, range with 12-in minimum landings and refrigerator.','Module footprints use the documented 24-in base depth; appliance door swings and operating envelopes are not modeled.')
        }
        dining_table_world_rect_ft=@([Math]::Round($table.x,3),[Math]::Round($table.y,3),$table.w,$table.d)
        table_edge_clearances_ft=$tableClearancesFt
        dining_chairs_world_rects_ft=$chairs
        alternative_dining_chairs_world_rects_ft=$chairsB
        porch_world_rect_ft=@([Math]::Round($porch.x,3),[Math]::Round($porch.y,3),$porch.w,$porch.d)
        porch_orientation_comparison=@(
            [ordered]@{id='12-wide-10-deep';rect_ft=@([Math]::Round($porch.x,3),[Math]::Round($porch.y,3),$porch.w,$porch.d);area_sf=120;test_outline_edge_reserve_in=[Math]::Round($shellEdgeReserveIn,2);relationship='Inside the 42-ft test outline by arithmetic; only 4 in remains at its rear edge.'},
            [ordered]@{id='10-wide-12-deep';rect_ft=@([Math]::Round($porchRotated.x,3),[Math]::Round($porchRotated.y,3),$porchRotated.w,$porchRotated.d);area_sf=120;test_outline_extension_in=[Math]::Round($rotatedPorchOverflowIn,2);relationship='Centered on dining; 20 in extends beyond the 42-ft test outline.'}
        )
        proposed_door_opening_world_ft=@([Math]::Round($doorX,3),[Math]::Round($routeY1,3),$doorWidth)
        porch_to_test_shell_edge_reserve_in=[Math]::Round($shellEdgeReserveIn,2)
        island_front_clearance_in=[Math]::Round($islandFrontAisleIn,2)
        island_east_edge_clearance_in=[Math]::Round($islandEastClearIn,2)
        island_to_counter_front_clear_ft=[Math]::Round($islandBackClearFt,3)
        assumed_stool_occupancy_allowance_ft=$stoolAllowanceFt
        post_seating_route_clear_ft=[Math]::Round($islandBackRouteClearFt,3)
        post_seating_route_target_in=36
        post_seating_route_shortfall_in=[Math]::Round($islandPostStoolRouteShortfallIn,3)
        kitchen_island_to_living_porch_route_verified=$false
        dining_east_clear_band_ft=[Math]::Round($eastRouteClearFt,3)
        dining_south_table_clear_ft=[Math]::Round($southTableClearFt,3)
        dining_east_route_surplus_over_36in_ft=[Math]::Round($eastRouteClearFt-3.0,3)
        proposed_route_centerline_world_ft=@($routePointsA | ForEach-Object {[ordered]@{x=[Math]::Round([double]$_[0],3);y=[Math]::Round([double]$_[1],3)}})
        route_terminus_y_inside_porch_ft=[Math]::Round($routePorchEndY-$porch.y,3)
        route_corridor_rectangles_ft=$routeRects
        route_obstacle_intersections=$routeObstacleHitsA
        route_obstacle_intersection_count=$routeObstacleHitsA.Count
        route_table_proxy_gap_in=$routeTableGapAIn
        kitchen_living_shared_edge_ft=[Math]::Round($sharedEdge,3)
        half_wall_and_opening_proposal_world_rects_ft=[ordered]@{half_wall=@($halfWall.x,$halfWall.y,$halfWall.w,$halfWall.d);opening=@($livingOpening.x,$livingOpening.y,$livingOpening.w,$livingOpening.d)}
        half_wall_edge_length_allowances_ft=@(8,6,[Math]::Round($sharedEdge-14,3))
        m06_window_b_remains_unassigned=$true
        entry_approach='Unverified; M-05 is on the east exterior wall in inherited B-first adjacency candidate.'
    }
    route=[ordered]@{
        target_width_in=36
        connected_by_plan_polyline=$true
        dining_furniture_arrangement='Two chairs on the west long side and one at each table end; no chairs on the route side.'
        nearest_route_to_seated_chair_in=$routeChairGapAIn
        route_to_chair_proxy_clearance_in=$routeChairGapAIn
        clearance_method='Minimum axis-aligned route-centerline-segment to chair-rectangle distance minus half the 36-in route width; rounded to 0.1 in.'
        nominal_door_width_in=60
        clear_leaf_width_verified=$false
        status='Living-to-porch 36-in route clearance is measured from orthogonal route centerline segments to modeled obstacle rectangles. Actual door clear width, leaf swing, floor transition, finished walls and furnished-use clearance require product/site review.'
    }
    second_route_scenario=[ordered]@{
        furniture_arrangement='Two chairs on the west long side, one north and one south; more conventional end seating, with all chairs clear of the east-side/south-turn route.'
        nominal_door_center_offset_from_dining_center_ft=1.5
        nominal_door_width_ft=$doorWidth
        clear_leaf_width_verified=$false
        nearest_route_to_seated_chair_in=$routeChairGapBIn
        route_to_chair_proxy_clearance_in=$routeChairGapBIn
        clearance_method='Minimum axis-aligned route-centerline-segment to chair-rectangle distance minus half the 36-in route width; rounded to 0.1 in.'
        route_corridor_rectangles_ft=$routeRectsB
        route_obstacle_intersections=$routeObstacleHitsB
        route_obstacle_intersection_count=$routeObstacleHitsB.Count
        route_table_proxy_gap_in=$routeTableGapBIn
        route_centerline_world_ft=@($routePointsB | ForEach-Object {[ordered]@{x=[Math]::Round([double]$_[0],3);y=[Math]::Round([double]$_[1],3)}})
        tradeoff='The 5-ft nominal porch-door reservation shifts 1.5 ft east of the dining centerline; actual wall returns and visual alignment need review.'
    }
    tradeoffs=@(
        'Keeping pantry-side M-06 window B clear uses the bath-first candidate, which moves M-05 entry/hall to the east exterior wall; front orientation and approach are unresolved.',
        'Adding the documented porch directly to dining leaves only 4 in to the 42-ft test-outline edge. The test outline cannot be treated as a coordinated exterior wall line; porch footprint or main-shell envelope needs owner/site coordination.',
        'Both door options use the same four-chair proposal: two chairs along the west long side and one at each end. The door-centered option leaves less separation between the route corner and the occupied south-end chair.',
        'The offset option moves the nominal 5-ft French-door reservation 1.5 ft east of the dining centerline; verify wall returns and sightline before selection.',
        'The 5-ft nominal French-door pair reservation is not evidence of a 36-in clear leaf; vendor clear opening and swing remain unresolved.',
        'The 8-ft half-wall and 6-ft opening are proposed positions on the shared edge; no wall height, bearing status, framing or openings in the actual building are defined.',
        'The route is a living-to-porch circulation proposal; it does not verify a post-seating route from the kitchen island work face. The island, stool and counter aisle remains a separate fit problem.'
    )
}

$checks=@(
    @{id='source_candidate_room_blocks';pass=([Math]::Abs(($kitchen.w*$kitchen.d)-277.333333333) -lt 0.01 -and [Math]::Abs(($dining.w*$dining.d)-158.666666667) -lt 0.01)},
    @{id='table_documented_preferred_clearances';pass=(@($tableClearancesFt.Values|Where-Object{$_ -lt 3.5}).Count -eq 0)},
    @{id='island_within_kitchen';pass=($island.x -ge $kitchen.x -and $island.y -ge $kitchen.y -and ($island.x+$island.w) -le ($kitchen.x+$kitchen.w) -and ($island.y+$island.d) -le ($kitchen.y+$kitchen.d))},
    @{id='island_work_aisle';pass=($islandFrontAisleIn -ge 42 -and $islandFrontAisleIn -ge 48 -and $islandEastClearIn -ge 42)},
    @{id='m19_perimeter_run_inside_kitchen';pass=($perimeterX -ge $kitchen.x -and ($perimeterX+$perimeterRunFt) -le ($kitchen.x+$kitchen.w) -and [Math]::Abs($moduleX-($perimeterX+$perimeterRunFt)) -lt 0.001)},
    @{id='m19_island_to_counter_aisle';pass=($perimeterY -ge ($island.y+$island.d) -and $islandToCounterIn -ge 48)},
    @{id='m19_documented_range_landings';pass=(@($perimeterModules|Where-Object{$_.id -like 'range_landing_*'}).Count -eq 2 -and @($perimeterModules|Where-Object{$_.id -eq 'induction_range' -and $_.width_ft -eq 2.5}).Count -eq 1)},
    @{id='stool_occupancy_depth_is_labelled_assumption';pass=($report.inputs.stool_occupancy_allowance_ft -eq 2 -and $report.inputs.stool_occupancy_allowance_basis -match 'Assumed' -and $report.geometry.Contains('assumed_stool_occupancy_allowance_ft'))},
    @{id='m19_sink_dw_adjacent';pass=([Math]::Abs(($perimeterModules[1].x)-($perimeterModules[0].x+$perimeterModules[0].width_ft)) -lt 0.001)},
    @{id='m19_fixture_sizes_match_documented_sources';pass=($specText -match '24" deep' -and $specText -match '36" wide.*double-bowl' -and $specText -match '24" wide.*immediately adjacent' -and $specText -match '36" W.*counter-depth' -and $kitchenFinishText -match '30 in induction unit on the perimeter wall')},
    @{id='m19_specified_appliance_operation_not_claimed';pass=(-not $report.geometry.kitchen_fit_study.appliance_open_clearances_modeled -and -not $report.geometry.kitchen_fit_study.service_routes_modeled)},
    @{id='island_post_stool_gap_shortfall_is_explicit';pass=($islandBackRouteClearFt -gt 0 -and [Math]::Abs($islandBackRouteClearFt*12-24) -lt 0.001 -and [Math]::Abs($islandPostStoolRouteShortfallIn-12) -lt 0.001 -and -not $report.geometry.kitchen_island_to_living_porch_route_verified)},
    @{id='dining_route_around_furniture';pass=($eastRouteClearFt -ge 3 -and $southTableClearFt -ge 3 -and ($routePathX-$routeWidth/2) -ge $tableEast -and ($routePathX+$routeWidth/2) -le $diningEast -and $doorX -le ($dining.x+$dining.w/2) -and ($doorX+$doorWidth) -ge ($dining.x+$dining.w/2))},
    @{id='centered_door_route_chair_clearance_measured';pass=($routeChairGapAIn -ge 0)},
    @{id='offset_door_option_route_clear';pass=($doorXB -ge $dining.x -and ($doorXB+$doorWidth) -le $diningEast -and ($doorCenterB-$routeWidth/2) -ge $dining.x -and ($doorCenterB+$routeWidth/2) -le $diningEast -and ($routePathX-$routeWidth/2) -ge $tableEast -and $routeChairGapBIn -gt 0)},
    @{id='offset_option_increases_seated_chair_route_gap';pass=($routeChairGapBIn -gt $routeChairGapAIn)},
    @{id='centered_route_corridor_clear_of_modeled_obstacles';pass=($routeObstacleHitsA.Count -eq 0 -and $routeTableGapAIn -ge 0)},
    @{id='offset_route_corridor_clear_of_modeled_obstacles';pass=($routeObstacleHitsB.Count -eq 0 -and $routeTableGapBIn -ge 0)},
    @{id='route_centerlines_remain_axis_aligned';pass=( (Test-RoutePointsAxisAligned -points $routePointsA) -and (Test-RoutePointsAxisAligned -points $routePointsB) )},
    @{id='route_corridor_rectangles_preserve_36in_width';pass=(@($routeRects+$routeRectsB|Where-Object{([Math]::Abs([double]$_.w-$routeWidth) -gt 0.000001) -and ([Math]::Abs([double]$_.h-$routeWidth) -gt 0.000001) -or ([double]$_.w -le 0) -or ([double]$_.h -le 0)}).Count -eq 0)},
    @{id='route_crosses_proposed_living_opening';pass=($routePointsA[0][0] -ge $living.x -and $routePointsA[0][1] -ge $livingOpening.y -and $routePointsA[0][1] -le ($livingOpening.y+$livingOpening.d) -and $routePointsA[1][0] -lt $livingOpening.x -and $routePointsA[1][1] -eq $routePointsA[0][1])},
    @{id='route_crosses_door_gap_and_reaches_porch';pass=([Math]::Abs($routePointsA[$routePointsA.Count-1][0]-$routeDoorCenter) -lt 0.001 -and $routePointsA[$routePointsA.Count-1][1] -ge ($porch.y+$routeWidth) -and $doorX -le $routeDoorCenter -and ($doorX+$doorWidth) -ge $routeDoorCenter)},
    @{id='porch_adjacent_and_inside_test_extent';pass=([Math]::Abs($porch.y-($dining.y+$dining.d+0.5)) -lt 0.001 -and ($porchEast -le $shellW) -and ($porchSouth -le $shellD))},
    @{id='rotated_porch_same_documented_area';pass=($porchRotated.w*$porchRotated.d -eq $porch.w*$porch.d -and [Math]::Abs(($porchRotated.x+$porchRotated.w/2)-($dining.x+$dining.w/2)) -lt 0.001 -and [Math]::Abs($rotatedPorchOverflowIn-20) -lt 0.01)},
    @{id='bath_search_window_b_unassigned';pass=($bath.id -eq 'east_of_core' -and $candidate.selection.main_public_bath.footprint -eq 'TBD')},
    @{id='half_wall_and_opening_edge_length_arithmetic';pass=($sharedEdge -ge 15 -and [Math]::Abs((8+6+1)-$sharedEdge) -lt 0.001 -and $livingEdgeReserveFt -eq 1)},
    @{id='door_clear_width_not_overclaimed';pass=(-not $report.route.clear_leaf_width_verified)},
    @{id='documented_inputs_present';pass=($specText -match '8''-0.*4''-0' -and $specText -match '12''-0.*10''-0' -and $specText -match '36.*60.*30' -and $specText -match '18.*20' -and $specText -match '5''-0' -and $specText -match '36" min' -and $specText -match '42" min' -and $decisionText -match '40 x 42' -and $decisionText -match 'search window B, east')},
    @{id='source_fingerprints_recorded';pass=($report.source_fingerprints_sha256.Count -eq 5)}
)
$checksOut=[ordered]@{status=if(@($checks|Where-Object{-not $_.pass}).Count -eq 0){'pass'}else{'fail'};passed=@($checks|Where-Object pass).Count;total=$checks.Count;checks=$checks;scope='Plan-coordinate, documented-clearance and provenance checks; not code/accessibility/IFC or construction validation.'}
New-Item -ItemType Directory -Force -Path $out|Out-Null
Set-Content -LiteralPath (Join-Path $out 'study.json') -Value ($report|ConvertTo-Json -Depth 12) -Encoding UTF8
$style="<style>text{font-family:Arial,sans-serif;fill:#29251f}.h{font-size:23px;font-weight:bold}.label{font-size:11px;font-weight:bold}.small{font-size:9px}.tiny{font-size:8px}.note{font-size:11px;fill:#8a482e}.shell{fill:none;stroke:#444;stroke-width:2;stroke-dasharray:8 5}.room{fill:#e8dfce;stroke:#554d44;stroke-width:1.4}.bath{fill:#fff4d3;stroke:#a57b27;stroke-width:1;stroke-dasharray:4 3}.porch{fill:#e6f0ed;stroke:#47776b;stroke-width:1.4}.island{fill:#d4dfc8;stroke:#5c704d;stroke-width:1.5}.counter{fill:#f1e9dc;stroke:#675a4b;stroke-width:1.5}.appliance{fill:#e7d8c6;fill-opacity:.72;stroke:#625242;stroke-width:1;stroke-dasharray:3 2}.table{fill:#bd8e61;stroke:#593c24;stroke-width:1.3}.chair{fill:#f4e5c9;stroke:#6f593b;stroke-width:1}.wallproposal{fill:#6a6258;stroke:#38332d;stroke-width:1}.openingproposal{fill:#b4d7df;fill-opacity:.5;stroke:#327385;stroke-width:1;stroke-dasharray:4 3}.route{fill:none;stroke:#2c91a6;stroke-width:54;stroke-opacity:.4;stroke-linejoin:round;stroke-linecap:butt}.door{stroke:#265866;stroke-width:5}</style>"
$svgBody=$svg -join "`r`n"
$svgDoc="<?xml version='1.0' encoding='UTF-8'?><svg xmlns='http://www.w3.org/2000/svg' width='1200' height='1000' viewBox='0 0 1200 1000'>$style<rect width='1200' height='1000' fill='#fbf9f3'/>$svgBody</svg>"
Set-Content -LiteralPath (Join-Path $out 'social-route-plan.svg') -Value $svgDoc -Encoding UTF8
$svgB=@($svg|Where-Object{$_ -notmatch "class='chair'" -and $_ -notmatch "class='route'" -and $_ -notmatch "class='door'" -and $_ -notmatch '2 chairs west' -and $_ -notmatch '5-ft French-door pair reservation'})
$svgB[0]="<text x='36' y='34' class='h'>Direction D social route - Option B, even table seating / offset doors</text>"
$svgB+=TextSvg ($table.x-0.35) ($table.y-0.2) 'tiny' '2 west + 1 north + 1 south; proposal only'
foreach($c in $chairsB){$svgB+=RectSvg $c.x $c.y $c.w $c.d 'chair'}
$routePolyB=Convert-RoutePointsToSvg -points $routePointsB
$svgB+="<polyline points='$routePolyB' class='route'/>"
$doorSvgXB=$originX+$doorXB*$scale
$svgB+="<line x1='$doorSvgXB' y1='$doorSvgY' x2='$($doorSvgXB+$doorWidth*$scale)' y2='$doorSvgY' class='door'/>"
$svgB+=TextSvg ($doorXB+0.1) ($routeY1-0.2) 'tiny' 'Option B: 5-ft pair shifted 1.5 ft east of dining centerline.'
$svgDocB="<?xml version='1.0' encoding='UTF-8'?><svg xmlns='http://www.w3.org/2000/svg' width='1200' height='1000' viewBox='0 0 1200 1000'>$style<rect width='1200' height='1000' fill='#fbf9f3'/>$($svgB -join "`r`n")</svg>"
Set-Content -LiteralPath (Join-Path $out 'social-route-plan-offset-door.svg') -Value $svgDocB -Encoding UTF8
$ps=16.0; $bx1=76.0; $bx2=620.0; $by=108.0
$dinW=[double]$dining.w*$ps; $dinD=[double]$dining.d*$ps; $porchLocalY=14.5*$ps
$boundaryY=$by+(42.0-[double]$dining.y)*$ps
$porchAX=$bx1+(([double]$dining.w-12.0)/2)*$ps; $porchBX=$bx2+(([double]$dining.w-10.0)/2)*$ps
$porchSvg=@"
<?xml version='1.0' encoding='UTF-8'?>
<svg xmlns='http://www.w3.org/2000/svg' width='1120' height='610' viewBox='0 0 1120 610'>
<style>text{font-family:Arial,sans-serif;fill:#29251f}.h{font-size:21px;font-weight:bold}.lbl{font-size:15px}.note{font-size:13px;fill:#87472f}.room{fill:#eee5d5;stroke:#5a4d3e;stroke-width:2}.porch{fill:#e6f0ed;stroke:#47776b;stroke-width:2}.shell{stroke:#9b4a32;stroke-width:3;stroke-dasharray:9 5}.door{stroke:#326877;stroke-width:7}</style>
<rect width='1120' height='610' fill='#fbf9f3'/>
<text x='36' y='40' class='h'>Porch orientation versus the 40 x 42 ft shell test outline</text>
<text x='$bx1' y='78' class='lbl'>Option A - 12 ft wide x 10 ft deep</text>
<text x='$bx2' y='78' class='lbl'>Option B - rotate: 10 ft wide x 12 ft deep</text>
<rect x='$bx1' y='$by' width='$dinW' height='$dinD' class='room'/>
<text x='$($bx1+8)' y='$($by+24)' class='lbl'>M-03 Dining 11 ft 4 in x 14 ft</text>
<rect x='$porchAX' y='$($by+$porchLocalY)' width='$(12*$ps)' height='$(10*$ps)' class='porch'/>
<text x='$($porchAX+8)' y='$($by+$porchLocalY+24)' class='lbl'>X-01 Porch 12 x 10 ft</text>
<line x1='$($bx1-30)' y1='$boundaryY' x2='$($bx1+$dinW+30)' y2='$boundaryY' class='shell'/>
<line x1='$($bx1+$dinW/2-2.5*$ps)' y1='$($by+$dinD)' x2='$($bx1+$dinW/2+2.5*$ps)' y2='$($by+$dinD)' class='door'/>
<text x='$bx1' y='535' class='note'>4 in to the outline edge. Numeric containment only; no credible exterior wall allowance.</text>
<rect x='$bx2' y='$by' width='$dinW' height='$dinD' class='room'/>
<text x='$($bx2+8)' y='$($by+24)' class='lbl'>M-03 Dining 11 ft 4 in x 14 ft</text>
<rect x='$porchBX' y='$($by+$porchLocalY)' width='$(10*$ps)' height='$(12*$ps)' class='porch'/>
<text x='$($porchBX+8)' y='$($by+$porchLocalY+24)' class='lbl'>X-01 Porch 10 x 12 ft; same 120 sf</text>
<line x1='$($bx2-30)' y1='$boundaryY' x2='$($bx2+$dinW+30)' y2='$boundaryY' class='shell'/>
<line x1='$($bx2+$dinW/2-2.5*$ps)' y1='$($by+$dinD)' x2='$($bx2+$dinW/2+2.5*$ps)' y2='$($by+$dinD)' class='door'/>
<text x='$bx2' y='535' class='note'>Extends 20 in beyond the outline. Porch side is 8 in inside each dining edge.</text>
<text x='36' y='580' class='note'>Blue line: centered nominal 5 ft door-pair reservation. Red dashed line: rear edge of test outline. Neither drawing defines walls or site placement.</text>
</svg>
"@
Set-Content -LiteralPath (Join-Path $out 'porch-orientation-options.svg') -Value $porchSvg -Encoding UTF8
Set-Content -LiteralPath (Join-Path $out 'checks.json') -Value ($checksOut|ConvertTo-Json -Depth 7) -Encoding UTF8
if($checksOut.status -ne 'pass'){throw 'Social-route study checks failed.'}
Write-Output "Direction D social-route study: $($checksOut.passed)/$($checksOut.total) checks passed."
Write-Output "Porch/test-shell edge reserve: $([Math]::Round($shellEdgeReserveIn,1)) in (reported as a trade-off, not treated as acceptable wall allowance)."
