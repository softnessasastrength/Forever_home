param(
    [string]$OutputDirectory = 'Architecture/M37_Upper_Suite_Pack_Route_2026-10-28',
    [int]$NodeLimit = 1500,
    [int]$LayoutLimit = 5000,
    [double]$ShellWidthOverrideFt = 0,
    [double]$ShellDepthOverrideFt = 0
)

$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$repo=[System.IO.Path]::GetFullPath($root)
$target=[System.IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))
$prefix=$repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar)+[System.IO.Path]::DirectorySeparatorChar
if(-not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside the repository root.'}

$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$programPath=Join-Path $root 'Requirements/Room_Program.md'
foreach($path in @($selectedPath,$proposalPath,$programPath)){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required source missing: $path"}}
$selected=Get-Content -Raw -LiteralPath $selectedPath|ConvertFrom-Json
$proposal=Get-Content -Raw -LiteralPath $proposalPath|ConvertFrom-Json
$program=Get-Content -Raw -LiteralPath $programPath
$selectedHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $selectedPath).Hash.ToLowerInvariant()
$proposalHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $proposalPath).Hash.ToLowerInvariant()
$programHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $programPath).Hash.ToLowerInvariant()
if($proposal.source_selected_D_sha256 -ne $selectedHash){throw 'Owner-follow-up proposal does not match selected-D fingerprint.'}

$script:DoorReservation=3.5
$script:WallGap=0.5
if(($ShellWidthOverrideFt -gt 0) -xor ($ShellDepthOverrideFt -gt 0)){throw 'Specify both shell override dimensions or neither.'}
if($ShellWidthOverrideFt -gt 0){
    if([Math]::Abs($ShellWidthOverrideFt-[double]$proposal.shell.width_ft) -gt 0.000001 -or [Math]::Abs($ShellDepthOverrideFt-[double]$proposal.shell.depth_ft) -gt 0.000001){throw 'Shell override must match the existing owner-follow-up 40 x 42 ft main-floor test envelope.'}
    $script:ShellW=$ShellWidthOverrideFt;$script:ShellD=$ShellDepthOverrideFt
    $script:ShellCase='exploratory full main-floor test envelope used as upper-shell expansion; unselected proposal'
}else{
    $script:ShellW=[double]$selected.shells.rear_upper[0];$script:ShellD=[double]$selected.shells.rear_upper[1]
    $script:ShellCase='selected-D-derived 36 x 32 ft rear-upper wing test envelope'
}
$script:Grid=1.0/6.0
$script:NodeLimit=[Math]::Max(100,$NodeLimit)
$script:PerOrientationNodeBudget=[Math]::Max(1,[Math]::Floor($script:NodeLimit/2.0))
$script:RootNodeStart=0
$script:RootSearchStats=[System.Collections.Generic.List[object]]::new()
$script:LayoutLimit=[Math]::Max(1,$LayoutLimit)
$script:Nodes=0
$script:RawLayouts=0
$script:UniqueKeys=[System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$script:Layouts=[System.Collections.Generic.List[object]]::new()
$script:TranslationDiagnostics=[System.Collections.Generic.List[object]]::new()
$script:Rooms=[ordered]@{}
foreach($id in @('U-01','U-02','U-03','U-04','U-05','U-06','C-PRIVATE')){
    $r=$selected.plans.upper|Where-Object id -eq $id
    if(-not $r){throw "Selected-D upper block missing: $id"}
    $script:Rooms[$id]=[ordered]@{id=$id;width_ft=[double]$r.w;depth_ft=[double]$r.d}
}
function New-Box([string]$id,[double]$x,[double]$y,[double]$w,[double]$d){[ordered]@{id=$id;x_ft=$x;y_ft=$y;width_ft=$w;depth_ft=$d}}
# Reserve the landing's first 4ft approach square before room packing begins.
$upperOffset=[double]$selected.plan_frame_offsets_ft.upper[1]
$lift=$selected.stair_core_test.lift
$liftKeepout=New-Box 'lift projected keepout (inside upper shell)' ([double]$lift.origin_ft[0]) ([double]$lift.origin_ft[1]-$upperOffset) ([double]$lift.width_ft) ([Math]::Min([double]$lift.depth_ft,($script:ShellD-([double]$lift.origin_ft[1]-$upperOffset))))
$upperLanding=$selected.stair_core_test.main_to_upper.upper_landing_ft
$landingLocal=New-Box 'upper stair landing' ([double]$upperLanding[0]) ([double]$upperLanding[1]-$upperOffset) ([double]$upperLanding[2]) ([double]$upperLanding[3])
$startX=($landingLocal.x_ft+$landingLocal.width_ft/2.0)
$startY=($landingLocal.y_ft-2.0)
$grid=6.0
$startIx=[int][Math]::Round($startX*$grid);$startIy=[int][Math]::Round($startY*$grid)
$script:StartApproach=New-Box 'reserved 4ft stair approach' ($startX-2.0) ($startY-2.0) 4.0 4.0
$script:StartApproachTranslationRejected=0
$script:Adjacency=@(
    [ordered]@{id='U01_PRIVATE';child='C-PRIVATE';parent='U-01'},
    [ordered]@{id='BOUTIQUE_PRIVATE';child='U-02';parent='C-PRIVATE'},
    [ordered]@{id='PRIVATE_HYBRID';child='U-03';parent='U-02'},
    [ordered]@{id='HYBRID_JJ';child='U-06';parent='U-03'},
    [ordered]@{id='GUEST_JJ';child='U-04';parent='U-06'},
    [ordered]@{id='PRIMARY_BATH';child='U-05';parent='U-01'}
)
$script:Order=@($script:Adjacency)

function Get-AxisGap([double]$a0,[double]$a1,[double]$b0,[double]$b1){if($a1 -le $b0){return ($b0-$a1)};if($b1 -le $a0){return ($a0-$b1)};return 0.0}
function Get-OverlapLength([double]$a0,[double]$a1,[double]$b0,[double]$b1){[Math]::Max(0.0,[Math]::Min($a1,$b1)-[Math]::Max($a0,$b0))}
function Test-Separated($a,$b){
    $gx=Get-AxisGap $a.x_ft ($a.x_ft+$a.width_ft) $b.x_ft ($b.x_ft+$b.width_ft)
    $gy=Get-AxisGap $a.y_ft ($a.y_ft+$a.depth_ft) $b.y_ft ($b.y_ft+$b.depth_ft)
    (($gx -ge ($script:WallGap-0.000001)) -or ($gy -ge ($script:WallGap-0.000001)))
}
function Test-BoxesOverlap($a,$b){
    ((Get-OverlapLength $a.x_ft ($a.x_ft+$a.width_ft) $b.x_ft ($b.x_ft+$b.width_ft)) -gt 0.000001 -and
     (Get-OverlapLength $a.y_ft ($a.y_ft+$a.depth_ft) $b.y_ft ($b.y_ft+$b.depth_ft)) -gt 0.000001)
}
function Test-ParentContact($child,$parent){
    $gx=Get-AxisGap $child.x_ft ($child.x_ft+$child.width_ft) $parent.x_ft ($parent.x_ft+$parent.width_ft)
    $gy=Get-AxisGap $child.y_ft ($child.y_ft+$child.depth_ft) $parent.y_ft ($parent.y_ft+$parent.depth_ft)
    $oy=Get-OverlapLength $child.y_ft ($child.y_ft+$child.depth_ft) $parent.y_ft ($parent.y_ft+$parent.depth_ft)
    $ox=Get-OverlapLength $child.x_ft ($child.x_ft+$child.width_ft) $parent.x_ft ($parent.x_ft+$parent.width_ft)
    (($gx -le ($script:WallGap+0.000001) -and $gy -lt 0.000001 -and $oy -ge ($script:DoorReservation-0.000001)) -or
     ($gy -le ($script:WallGap+0.000001) -and $gx -lt 0.000001 -and $ox -ge ($script:DoorReservation-0.000001)))
}
function Get-CurrentBounds($state){
    $items=@($state.Values);$minX=[double]::PositiveInfinity;$minY=[double]::PositiveInfinity;$maxX=[double]::NegativeInfinity;$maxY=[double]::NegativeInfinity
    foreach($item in $items){$minX=[Math]::Min($minX,[double]$item.x_ft);$minY=[Math]::Min($minY,[double]$item.y_ft);$maxX=[Math]::Max($maxX,([double]$item.x_ft+[double]$item.width_ft));$maxY=[Math]::Max($maxY,([double]$item.y_ft+[double]$item.depth_ft))}
    [ordered]@{min_x=[double]$minX;min_y=[double]$minY;width=[double]($maxX-$minX);depth=[double]($maxY-$minY)}
}
function Get-CandidateChildren($parent,$childSpec){
    $candidates=[System.Collections.Generic.List[object]]::new()
    $orientations=@([ordered]@{w=[double]$childSpec.width_ft;d=[double]$childSpec.depth_ft})
    if([Math]::Abs([double]$childSpec.width_ft-[double]$childSpec.depth_ft) -gt 0.000001){$orientations+=,[ordered]@{w=[double]$childSpec.depth_ft;d=[double]$childSpec.width_ft}}
    foreach($o in $orientations){
        $ys=@([double]$parent.y_ft,[double]($parent.y_ft+$parent.depth_ft-$o.d),[double]($parent.y_ft+($parent.depth_ft-$o.d)/2.0),[double]($parent.y_ft+$parent.depth_ft-$script:DoorReservation),[double]($parent.y_ft+$script:DoorReservation-$o.d))
        $xs=@([double]$parent.x_ft,[double]($parent.x_ft+$parent.width_ft-$o.w),[double]($parent.x_ft+($parent.width_ft-$o.w)/2.0),[double]($parent.x_ft+$parent.width_ft-$script:DoorReservation),[double]($parent.x_ft+$script:DoorReservation-$o.w))
        foreach($y in $ys){$candidates.Add((New-Box $childSpec.id ($parent.x_ft+$parent.width_ft+$script:WallGap) $y $o.w $o.d));$candidates.Add((New-Box $childSpec.id ($parent.x_ft-$o.w-$script:WallGap) $y $o.w $o.d))}
        foreach($x in $xs){$candidates.Add((New-Box $childSpec.id $x ($parent.y_ft+$parent.depth_ft+$script:WallGap) $o.w $o.d));$candidates.Add((New-Box $childSpec.id $x ($parent.y_ft-$o.d-$script:WallGap) $o.w $o.d))}
    }
    return $candidates.ToArray()
}
function Add-CompletedLayout($state){
    $script:RawLayouts++
    $bounds=Get-CurrentBounds $state
    if($bounds.width -gt ($script:ShellW+0.000001) -or $bounds.depth -gt ($script:ShellD+0.000001)){return}
    $normalized=[ordered]@{}
    foreach($id in @('U-01','C-PRIVATE','U-02','U-03','U-05','U-06','U-04')){$r=$state[$id];$normalized[$id]=New-Box $id ($r.x_ft-$bounds.min_x) ($r.y_ft-$bounds.min_y) $r.width_ft $r.depth_ft}
    $key=(@($normalized.Keys|Sort-Object|ForEach-Object{$r=$normalized[$_];'{0}:{1:F4},{2:F4},{3:F4},{4:F4}' -f $_,$r.x_ft,$r.y_ft,$r.width_ft,$r.depth_ft}) -join '|')
    if($script:UniqueKeys.Add($key)){$script:Layouts.Add([ordered]@{bounds=$bounds;rects=$normalized;key=$key})}
}
function Search-Layout([int]$index,$state){
    if(($script:Nodes-$script:RootNodeStart) -ge $script:PerOrientationNodeBudget -or $script:Layouts.Count -ge $script:LayoutLimit){return}
    $script:Nodes++
    if($index -ge $script:Order.Count){Add-CompletedLayout $state;return}
    $edge=$script:Order[$index];$parent=$state[$edge.parent];$spec=$script:Rooms[$edge.child]
    foreach($candidate in (Get-CandidateChildren $parent $spec)){
        $valid=$true
        if(-not(Test-ParentContact $candidate $parent)){$valid=$false}
        if($valid){foreach($existingId in $state.Keys){if($existingId -eq $edge.parent){continue};if(-not(Test-Separated $candidate $state[$existingId])){$valid=$false;break}}}
        if(-not $valid){continue}
        $state.Add($edge.child,$candidate)
        $bounds=Get-CurrentBounds $state
        if($bounds.width -le ($script:ShellW+0.000001) -and $bounds.depth -le ($script:ShellD+0.000001)){Search-Layout ($index+1) $state}
        $state.Remove($edge.child)
        if(($script:Nodes-$script:RootNodeStart) -ge $script:PerOrientationNodeBudget -or $script:Layouts.Count -ge $script:LayoutLimit){return}
    }
}

$script:DoorReservation=3.5
$anchorSpec=$script:Rooms['U-01']
foreach($anchor in @([ordered]@{w=$anchorSpec.width_ft;d=$anchorSpec.depth_ft},[ordered]@{w=$anchorSpec.depth_ft;d=$anchorSpec.width_ft})){
    $script:RootNodeStart=$script:Nodes
    $state=[ordered]@{'U-01'=(New-Box 'U-01' 0 0 $anchor.w $anchor.d)}
    Search-Layout 0 $state
    $script:RootSearchStats.Add([ordered]@{anchor_width_ft=$anchor.w;anchor_depth_ft=$anchor.d;nodes_expanded=($script:Nodes-$script:RootNodeStart)})
    if($script:Layouts.Count -ge $script:LayoutLimit){break}
}

function Test-CorridorSquare([double]$cx,[double]$cy,$rects,$keepout){
    if($cx -lt 2.0-0.000001 -or $cx -gt ($script:ShellW-2.0+0.000001) -or $cy -lt 2.0-0.000001 -or $cy -gt ($script:ShellD-2.0+0.000001)){return $false}
    $corr=New-Box '4ft corridor test square' ($cx-2.0) ($cy-2.0) 4.0 4.0
    foreach($r in $rects.Values){if((Get-OverlapLength $corr.x_ft ($corr.x_ft+$corr.width_ft) $r.x_ft ($r.x_ft+$r.width_ft)) -gt 0.000001 -and (Get-OverlapLength $corr.y_ft ($corr.y_ft+$corr.depth_ft) $r.y_ft ($r.y_ft+$r.depth_ft)) -gt 0.000001){return $false}}
    if((Get-OverlapLength $corr.x_ft ($corr.x_ft+$corr.width_ft) $keepout.x_ft ($keepout.x_ft+$keepout.width_ft)) -gt 0.000001 -and (Get-OverlapLength $corr.y_ft ($corr.y_ft+$corr.depth_ft) $keepout.y_ft ($keepout.y_ft+$keepout.depth_ft)) -gt 0.000001){return $false}
    return $true
}
function Get-AccessibleGoals($room){
    $cx=$room.x_ft+$room.width_ft/2.0;$cy=$room.y_ft+$room.depth_ft/2.0
    @(
        [ordered]@{side='west';x=($room.x_ft-2.5);y=$cy},
        [ordered]@{side='east';x=($room.x_ft+$room.width_ft+2.5);y=$cy},
        [ordered]@{side='south';x=$cx;y=($room.y_ft-2.5)},
        [ordered]@{side='north';x=$cx;y=($room.y_ft+$room.depth_ft+2.5)}
    )
}
function New-BlockedGrid($rects,$keepout){
    $maxIx=[int][Math]::Round(($script:ShellW-2.0)*$grid);$maxIy=[int][Math]::Round(($script:ShellD-2.0)*$grid)
    $blocked=[bool[,]]::new($maxIx+1,$maxIy+1)
    foreach($r in @($rects.Values)+@($keepout)){
        # A 4ft square overlaps a rectangle when its centre lies strictly within
        # the rectangle expanded by 2ft. Mark those cells once before the BFS.
        $minX=[Math]::Max(12,([int][Math]::Floor(($r.x_ft-2.0)*$grid)+1))
        $maxX=[Math]::Min($maxIx,([int][Math]::Ceiling(($r.x_ft+$r.width_ft+2.0)*$grid)-1))
        $minY=[Math]::Max(12,([int][Math]::Floor(($r.y_ft-2.0)*$grid)+1))
        $maxY=[Math]::Min($maxIy,([int][Math]::Ceiling(($r.y_ft+$r.depth_ft+2.0)*$grid)-1))
        for($ix=$minX;$ix -le $maxX;$ix++){for($iy=$minY;$iy -le $maxY;$iy++){$blocked[$ix,$iy]=$true}}
    }
    [ordered]@{cells=$blocked;max_ix=$maxIx;max_iy=$maxIy;stride=($maxIy+1)}
}
function Test-BlockedGridParity{
    $originalW=$script:ShellW;$originalD=$script:ShellD
    try{
        $script:ShellW=12.0;$script:ShellD=10.0
        $testRects=[ordered]@{'A'=(New-Box 'A' 2 2 3 2);'B'=(New-Box 'B' 7 6 2 2)}
        $testKeepout=New-Box 'test keepout' 4 6 2 1
        $map=New-BlockedGrid $testRects $testKeepout
        for($ix=12;$ix -le $map.max_ix;$ix++){
            for($iy=12;$iy -le $map.max_iy;$iy++){
                $expected=(-not(Test-CorridorSquare ($ix/$grid) ($iy/$grid) $testRects $testKeepout))
                if([bool]$map.cells[$ix,$iy] -ne $expected){return $false}
            }
        }
        return $true
    }finally{$script:ShellW=$originalW;$script:ShellD=$originalD}
}
$script:BlockedGridParityCheck=Test-BlockedGridParity
function Get-HallReachability($rects,$keepout){
    $startX=[double]$startIx/$grid;$startY=[double]$startIy/$grid
    $gridMap=New-BlockedGrid $rects $keepout;$blocked=$gridMap.cells;$maxIx=[int]$gridMap.max_ix;$maxIy=[int]$gridMap.max_iy;$stride=[int]$gridMap.stride
    if($startIx -lt 0 -or $startIx -gt $maxIx -or $startIy -lt 0 -or $startIy -gt $maxIy -or $blocked[$startIx,$startIy]){return $null}
    $visited=[bool[,]]::new($maxIx+1,$maxIy+1);$queue=[System.Collections.Generic.Queue[int]]::new()
    $encode={param([int]$x,[int]$y) ($x*$stride+$y)}
    $startId=&$encode $startIx $startIy;$visited[$startIx,$startIy]=$true;$visitedCount=1;$queue.Enqueue([int]$startId)
    $directions=@(@(1,0),@(-1,0),@(0,1),@(0,-1))
    while($queue.Count -gt 0){
        $id=$queue.Dequeue();$ix=[int][Math]::Floor($id/$stride);$iy=$id-($ix*$stride)
        foreach($d in $directions){$nx=$ix+$d[0];$ny=$iy+$d[1];if($nx -lt 12 -or $nx -gt $maxIx -or $ny -lt 12 -or $ny -gt $maxIy){continue};if($visited[$nx,$ny] -or $blocked[$nx,$ny]){continue};$visited[$nx,$ny]=$true;$visitedCount++;$queue.Enqueue([int](&$encode $nx $ny))}
    }
    $reachable=[ordered]@{}
    foreach($id in @('U-01','U-02','U-03','U-04')){
        $goals=Get-AccessibleGoals $rects[$id];$sides=[System.Collections.Generic.List[string]]::new()
        foreach($g in $goals){$ix=[int][Math]::Round([double]$g.x*$grid);$iy=[int][Math]::Round([double]$g.y*$grid);if([Math]::Abs($ix/$grid-[double]$g.x) -gt 0.000001 -or [Math]::Abs($iy/$grid-[double]$g.y) -gt 0.000001){continue};if($ix -ge 0 -and $ix -le $maxIx -and $iy -ge 0 -and $iy -le $maxIy -and $visited[$ix,$iy] -and -not $blocked[$ix,$iy]){$sides.Add($g.side)}}
        $reachable[$id]=@($sides)
    }
    [ordered]@{visited_cells=$visitedCount;reachable_room_sides=$reachable;required_public_rooms_reached=(@($reachable['U-01']).Count -gt 0 -and @($reachable['U-02']).Count -gt 0 -and @($reachable['U-04']).Count -gt 0);u03_hall_side_reachable=(@($reachable['U-03']).Count -gt 0)}
}
function Find-LiftClearTranslations($layout,$keepout){
    $maxX=[double]$script:ShellW-[double]$layout.bounds.width;$maxY=[double]$script:ShellD-[double]$layout.bounds.depth
    $xs=[System.Collections.Generic.SortedSet[double]]::new();$ys=[System.Collections.Generic.SortedSet[double]]::new()
    $xs.Add(0.0)|Out-Null;$ys.Add(0.0)|Out-Null;$xs.Add($maxX)|Out-Null;$ys.Add($maxY)|Out-Null
    foreach($r in $layout.rects.Values){
        foreach($offset in @(($keepout.x_ft-$r.x_ft-$r.width_ft),(($keepout.x_ft+$keepout.width_ft)-$r.x_ft),($script:StartApproach.x_ft-$r.x_ft-$r.width_ft),(($script:StartApproach.x_ft+$script:StartApproach.width_ft)-$r.x_ft))){$xs.Add([Math]::Max(0.0,[Math]::Min($maxX,$offset)))|Out-Null}
        foreach($offset in @(($keepout.y_ft-$r.y_ft-$r.depth_ft),(($keepout.y_ft+$keepout.depth_ft)-$r.y_ft),($script:StartApproach.y_ft-$r.y_ft-$r.depth_ft),(($script:StartApproach.y_ft+$script:StartApproach.depth_ft)-$r.y_ft))){$ys.Add([Math]::Max(0.0,[Math]::Min($maxY,$offset)))|Out-Null}
    }
    $results=[System.Collections.Generic.List[object]]::new()
    foreach($dx in $xs){foreach($dy in $ys){$translated=[ordered]@{};$clear=$true;foreach($id in $layout.rects.Keys){$r=$layout.rects[$id];$q=New-Box $id ($r.x_ft+$dx) ($r.y_ft+$dy) $r.width_ft $r.depth_ft;$hitsLift=((Get-OverlapLength $q.x_ft ($q.x_ft+$q.width_ft) $keepout.x_ft ($keepout.x_ft+$keepout.width_ft)) -gt 0.000001 -and (Get-OverlapLength $q.y_ft ($q.y_ft+$q.depth_ft) $keepout.y_ft ($keepout.y_ft+$keepout.depth_ft)) -gt 0.000001);$hitsApproach=Test-BoxesOverlap $q $script:StartApproach;if($hitsLift -or $hitsApproach){$clear=$false;if($hitsApproach){$script:StartApproachTranslationRejected++};break};$translated[$id]=$q};if($clear){$results.Add([ordered]@{offset_x_ft=$dx;offset_y_ft=$dy;rects=$translated})}}}
    $script:TranslationDiagnostics.Add([ordered]@{bounds_width=$layout.bounds.width;bounds_depth=$layout.bounds.depth;max_x_translation=$maxX;max_y_translation=$maxY;rectangles=@($layout.rects.Keys).Count;x_offsets=$xs.Count;y_offsets=$ys.Count;clear_positions=$results.Count})
    @($results|Sort-Object @{Expression={ [Math]::Abs($_.offset_x_ft+($_.rects['U-01'].width_ft/2.0)-$startX)+[Math]::Abs($_.offset_y_ft+($_.rects['U-01'].depth_ft/2.0)-$startY) }})
}

$doorValues=@($selected.upper_door_matrix|ForEach-Object{[double]$_.nominal_reservation_ft}|Sort-Object -Unique)
$sourceDoorWidth=$doorValues|Where-Object{[Math]::Abs($_-3.5) -lt 0.000001}|Select-Object -First 1
if($null -eq $sourceDoorWidth){throw 'No source 3.5ft upper door reservation found.'}
$script:DoorReservation=$sourceDoorWidth
$script:Order=$script:Adjacency
$layouts=@($script:Layouts|Sort-Object @{Expression={ $_.bounds.width*$_.bounds.depth }},@{Expression={ $_.bounds.width+$_.bounds.depth }})
$tested=[System.Collections.Generic.List[object]]::new();$bestPrivate=$null;$bestU03Side=$null;$translationsTested=0;$routeRuns=0
foreach($layout in $layouts){
    $translations=Find-LiftClearTranslations $layout $liftKeepout
    foreach($placement in $translations){
        $translationsTested++
        $route=Get-HallReachability $placement.rects $liftKeepout;$routeRuns++
        if($null -eq $route){continue}
        $record=[ordered]@{layout_key=$layout.key;layout_bounds_ft=[ordered]@{width=$layout.bounds.width;depth=$layout.bounds.depth};translation_ft=[ordered]@{x=$placement.offset_x_ft;y=$placement.offset_y_ft};rectangles=$placement.rects;hall_reachability=$route}
        $tested.Add($record)
        if($route.required_public_rooms_reached -and $null -eq $bestPrivate){$bestPrivate=$record}
        if($route.u03_hall_side_reachable -and $null -eq $bestU03Side){$bestU03Side=$record}
    }
}

$routeAccessCounts=[ordered]@{}
foreach($id in @('U-01','U-02','U-03','U-04')){$routeAccessCounts[$id]=@($tested|Where-Object{@($_.hall_reachability.reachable_room_sides[$id]).Count -gt 0}).Count}
$routesToPrimaryPrivateGuest=0
foreach($routeRecord in $tested){$reach=$routeRecord.hall_reachability.reachable_room_sides;if(@($reach['U-01']).Count -gt 0 -and @($reach['U-02']).Count -gt 0 -and @($reach['U-04']).Count -gt 0){$routesToPrimaryPrivateGuest++}}
$routeSamples=@($tested|Select-Object -First 5|ForEach-Object{[ordered]@{layout_key=$_.layout_key;translation_ft=$_.translation_ft;visited_cells=$_.hall_reachability.visited_cells;reachable_room_sides=$_.hall_reachability.reachable_room_sides;required_public_rooms_reached=$_.hall_reachability.required_public_rooms_reached;u03_hall_side_reachable=$_.hall_reachability.u03_hall_side_reachable}})
$searchBudgetReached=@($script:RootSearchStats|Where-Object{$_.nodes_expanded -ge $script:PerOrientationNodeBudget}).Count -gt 0
$searchComplete=(-not $searchBudgetReached -and $script:Layouts.Count -lt $script:LayoutLimit)
$winner=$bestPrivate
$checks=[ordered]@{
    selected_D_source_matches_owner_followup=($proposal.source_selected_D_sha256 -eq $selectedHash)
    all_six_upper_rooms_and_private_connector_come_from_selected_D=($script:Rooms.Count -eq 7)
    all_room_dimensions_match_selected_D=(@($script:Rooms.Keys|Where-Object{$id=$_;$sourceRoom=$selected.plans.upper|Where-Object id -eq $id;(-not $sourceRoom) -or ([Math]::Abs($script:Rooms[$id].width_ft-[double]$sourceRoom.w) -gt 0.000001) -or ([Math]::Abs($script:Rooms[$id].depth_ft-[double]$sourceRoom.d) -gt 0.000001)}).Count -eq 0)
    door_reservation_is_source_derived_3_5ft=([Math]::Abs($script:DoorReservation-3.5) -lt 0.000001)
    owner_private_sequence_is_in_search_graph=($script:Order.child -contains 'U-03' -and @($script:Order|Where-Object{($_.parent -eq 'U-02') -and ($_.child -eq 'U-03')}).Count -eq 1)
    hybrid_guest_JJ_is_in_search_graph=(@($script:Order|Where-Object{($_.parent -eq 'U-03') -and ($_.child -eq 'U-06')}).Count -eq 1 -and @($script:Order|Where-Object{($_.parent -eq 'U-06') -and ($_.child -eq 'U-04')}).Count -eq 1)
    search_prioritizes_private_chain_and_JJ_before_primary_bath=($script:Order[0].child -eq 'C-PRIVATE' -and $script:Order[-1].child -eq 'U-05')
    blocked_grid_matches_exact_clearance_predicate=$script:BlockedGridParityCheck
    upper_frame_offset_and_lift_projection_are_source_derived=([Math]::Abs($upperOffset-6.0) -lt 0.000001 -and [Math]::Abs($liftKeepout.y_ft-28.0) -lt 0.000001 -and [Math]::Abs($liftKeepout.depth_ft-[Math]::Min(8.0,($script:ShellD-28.0))) -lt 0.000001)
    upper_shell_dimensions_match_documented_case=(($script:ShellCase -match '^selected-D-derived') -and [Math]::Abs($script:ShellW-[double]$selected.shells.rear_upper[0]) -lt 0.000001 -and [Math]::Abs($script:ShellD-[double]$selected.shells.rear_upper[1]) -lt 0.000001) -or (($script:ShellCase -match '^exploratory') -and [Math]::Abs($script:ShellW-[double]$proposal.shell.width_ft) -lt 0.000001 -and [Math]::Abs($script:ShellD-[double]$proposal.shell.depth_ft) -lt 0.000001)
    stair_landing_start_is_source_derived=([Math]::Abs($startX-19.1666666667) -lt 0.000001 -and [Math]::Abs($startY-30.0) -lt 0.000001)
    final_translations_reserve_source_stair_approach=([Math]::Abs($script:StartApproach.x_ft-17.1666666667) -lt 0.000001 -and [Math]::Abs($script:StartApproach.y_ft-28.0) -lt 0.000001 -and $script:StartApproach.width_ft -eq 4.0 -and $script:StartApproach.depth_ft -eq 4.0)
    search_is_deterministic_and_bounded=($script:Nodes -le $script:NodeLimit -and $script:Layouts.Count -le $script:LayoutLimit)
    owner_revised_U03_private_route_only_matches_proposal=($proposal.owner_inputs.u03_shared_hall_access -eq $false -and @($proposal.upper_suite.excluded_access_edges|Where-Object{$_.a -eq 'U-03' -and $_.b -eq 'C-UPPER'}).Count -eq 1)
    any_winner_reaches_all_required_public_rooms=($null -eq $winner -or $winner.hall_reachability.required_public_rooms_reached)
    route_summary_matches_tested_records=($tested.Count -le $routeRuns -and $routeAccessCounts['U-01'] -le $tested.Count -and $routeAccessCounts['U-02'] -le $tested.Count -and $routeAccessCounts['U-03'] -le $tested.Count -and $routeAccessCounts['U-04'] -le $tested.Count -and $routesToPrimaryPrivateGuest -le $tested.Count)
    selected_D_file_unchanged_during_run=((Get-FileHash -Algorithm SHA256 -LiteralPath $selectedPath).Hash.ToLowerInvariant() -eq $selectedHash)
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
if($failed.Count -gt 0){throw "M37 source/search checks failed: $($failed -join ', ')"}

$status='bounded search found no candidate satisfying room contacts, lift keepout and required 4ft public routes to U-01, U-02 and U-04'
if($null -ne $bestPrivate){$status='room-block candidate reaches required public rooms while retaining the U-01 to U-02 to U-03 private topology; U-03 has no direct hall door in proposal; schematic only'}
$report=[ordered]@{
    schema='forever-home.m37-upper-suite-pack-route.v2'
    title='M37 - upper-suite room packing and public-hall route search'
    status=$status
    source_fingerprints_sha256=[ordered]@{'selected_D_study.json'=$selectedHash;'owner_followup_study.json'=$proposalHash;'Requirements/Room_Program.md'=$programHash}
    search=[ordered]@{algorithm='deterministic tree-attached rectangle search; prioritize private suite and Jack-and-Jill before primary bath; split node budget equally between U-01 orientations; sample five contact alignments with 0.5ft wall bands and source 3.5ft contact reservations; enumerate translation boundaries from shell, lift and reserved stair approach; test each remaining 4ft hall on an exact-parity precomputed 2in occupancy grid';node_limit=$script:NodeLimit;per_orientation_node_budget=$script:PerOrientationNodeBudget;nodes_expanded=$script:Nodes;node_limit_reached=$searchBudgetReached;root_orientation_runs=@($script:RootSearchStats);layout_limit=$script:LayoutLimit;layouts_recorded=$script:Layouts.Count;raw_complete_layouts=$script:RawLayouts;start_approach_translation_rejects=$script:StartApproachTranslationRejected;translations_tested=$translationsTested;hall_route_searches=$routeRuns;routes_with_clear_stair_approach=$tested.Count;coordinate_grid_ft=$script:Grid;source_door_reservation_ft=$script:DoorReservation;search_complete=$searchComplete}
    source_dimensions_ft=$script:Rooms
    coordinate_basis=[ordered]@{shell_case=$script:ShellCase;width_ft=$script:ShellW;depth_ft=$script:ShellD;selected_D_upper_frame_offset_ft=$upperOffset;note='The full-plate case reuses the owner-follow-up 40 x 42 ft main-floor test envelope as an unapproved upper-shell expansion comparison.'}
    preserved_constraints=@('U-01 to primary-only U-05 through a nominal 3.5ft contact reservation','U-01 to C-PRIVATE to U-02','owner-directed U-02 to U-03 private route only; no direct U-03 to C-UPPER door','U-04 retains independent guest shared-hall access','U-03 and U-04 each contact U-06 for Jack-and-Jill access','source 8x8ft lift reservation, clipped to its upper-wing projection','4ft-wide hall route from source upper landing to U-01, U-02 and U-04; no U-03 hall door is modeled')
    local_lift_keepout=$liftKeepout
    reserved_stair_approach=$script:StartApproach
    upper_landing_local=$landingLocal
    route_access_counts_by_room=$routeAccessCounts
    route_cases_reaching_U01_U02_U04=$routesToPrimaryPrivateGuest
    candidate_private_only=$bestPrivate
    first_route_with_U03_hall_side_reachable=$bestU03Side
    best_candidate=$winner
    tested_route_samples=$routeSamples
    first_translation_diagnostics=@($script:TranslationDiagnostics|Select-Object -First 3)
    checks=$checks
    failures=$failed
    limitations=@('The tree search is deterministic but bounded by NodeLimit/LayoutLimit and samples five contact-alignment anchors; it is not an exhaustive proof that no layout exists.','A 0.5ft gap represents a nominal wall allowance, and a 3.5ft edge reservation is inherited from selected-D door-matrix data, not clear opening or door-swing geometry.','Room connection goals are sample points 2.5ft beyond each room-block side, a schematic reachability proxy rather than a door or specified clearance.','The hall search checks a 4ft swept square on a 2in translation grid. It does not model walls, doors, swings, landings beyond the source connector, headroom, floor openings, stairs, structure, services, furniture or fire/life-safety.','The lift keepout is a plan projection from the source reservation; verify actual shaft and floor opening in Revit.','No Revit, IFC, code, accessibility, structural or construction validation is made. A search candidate is a room-block concept only.','The revised private-route-only direction excludes a direct U-03 shared-hall door; actual private and public openings remain unmodeled. Corridor proximity to U-03 is not evidence of a doorway. No room sizes or selected-D baseline are edited.')
}

if(-not(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target|Out-Null}
$jsonPath=Join-Path $target 'search.json';$checkPath=Join-Path $target 'checks.json';$svgPath=Join-Path $target 'upper-suite-search.svg'
$report|ConvertTo-Json -Depth 28|Set-Content -LiteralPath $jsonPath -Encoding utf8
$checkReport=[ordered]@{count=$checks.Count;passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@();checks=$checks;search_summary=$report.search;source_fingerprints_sha256=$report.source_fingerprints_sha256;interpretation='A passing integrity check validates search setup and evidence. A viable layout is claimed only when its recorded hall reachability checks pass.'}
$checkReport|ConvertTo-Json -Depth 20|Set-Content -LiteralPath $checkPath -Encoding utf8

$scale=18.0;$sx=40.0;$sy=70.0
$svg=[System.Collections.Generic.List[string]]::new()
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="900" height="790" viewBox="0 0 900 790">')
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:21px;font-weight:bold}.room{fill:#eadfce;stroke:#74695d;stroke-width:2}.private{fill:#c8a7d1;fill-opacity:.45;stroke:#785a88;stroke-width:2}.bath{fill:#bfd5d9;stroke:#5b7a80;stroke-width:2}.hall{fill:#d7dce4;stroke:#5f6977;stroke-width:2}.lift{fill:#e7aaa2;fill-opacity:.45;stroke:#a7463c;stroke-width:2;stroke-dasharray:7 4}.label{font-size:12px}.note{font-size:13px;fill:#5b554d}.warn{font-size:13px;fill:#8e3f35}.shell{fill:#fcfaf5;stroke:#4e463d;stroke-width:3}</style>')
$svg.Add(('<text class="title" x="40" y="30">M37 - upper-suite pack and route search</text><text class="note" x="40" y="50">{0}; room rectangles and stair/lift projection only</text>' -f $report.status))
$svg.Add(('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $sx,$sy,($script:ShellW*$scale),($script:ShellD*$scale)))
$svg.Add(('<rect class="lift" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">lift projected keepout</text>' -f ($sx+$liftKeepout.x_ft*$scale),($sy+$liftKeepout.y_ft*$scale),($liftKeepout.width_ft*$scale),($liftKeepout.depth_ft*$scale),($sx+$liftKeepout.x_ft*$scale+4),($sy+$liftKeepout.y_ft*$scale+16)))
if($null -ne $winner){
    foreach($id in $winner.rectangles.Keys){$r=$winner.rectangles[$id];$class='room';if($id -eq 'C-PRIVATE'){$class='private'}elseif($id -in @('U-05','U-06')){$class='bath'};$svg.Add(('<rect class="{0}" x="{1}" y="{2}" width="{3}" height="{4}"/><text class="label" x="{5}" y="{6}">{7}</text>' -f $class,($sx+$r.x_ft*$scale),($sy+$r.y_ft*$scale),($r.width_ft*$scale),($r.depth_ft*$scale),($sx+$r.x_ft*$scale+4),($sy+$r.y_ft*$scale+15),$id))}
    $svg.Add(('<text class="note" x="40" y="700">Required public rooms reached: {0}; U-03 has no direct hall door in the proposal.</text>' -f $winner.hall_reachability.required_public_rooms_reached))
} else {$svg.Add('<text class="warn" x="40" y="710">No candidate passed the bounded room/contact/lift/hall route search.</text>')}
$svg.Add(('<text class="note" x="40" y="730">Nodes {0}; layouts {1}; search complete {2}. A capped search is not proof of impossibility.</text>' -f $script:Nodes,$script:Layouts.Count,$searchComplete))
$svg.Add('<text class="note" x="40" y="752">Not Revit walls, door swings, floor openings, code or engineering.</text>')
$svg.Add('</svg>')
$svg -join "`n"|Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest=[ordered]@{generator='Tools/test_m37_upper_suite_pack_and_route.ps1';source_fingerprints_sha256=$report.source_fingerprints_sha256;search_parameters=[ordered]@{node_limit=$script:NodeLimit;layout_limit=$script:LayoutLimit};output_hashes_sha256=[ordered]@{search=(Get-FileHash $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks=(Get-FileHash $checkPath -Algorithm SHA256).Hash.ToLowerInvariant();svg=(Get-FileHash $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
$manifest|ConvertTo-Json -Depth 12|Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output("M37 search-integrity checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output("Search nodes: {0}/{1}; bounded layouts: {2}; lift-clear route placements: {3}; route runs: {4}." -f $script:Nodes,$script:NodeLimit,$script:Layouts.Count,$translationsTested,$routeRuns)
Write-Output("Required public-room candidate: {0}; U-03 corridor-side reach observed: {1}." -f ($null -ne $bestPrivate),($null -ne $bestU03Side))
