param(
    [string]$OutputDirectory = 'Architecture/M37_Upper_Suite_Pack_Route_2026-10-28',
    [int]$NodeLimit = 1500,
    [int]$LayoutLimit = 5000,
    [double]$ShellWidthOverrideFt = 0,
    [double]$ShellDepthOverrideFt = 0,
    [switch]$LandingAlignedRootSeeds,
    [switch]$U03PerimeterRootSeeds,
    [ValidateSet('all','north','east','south','west')]
    [string]$U03PerimeterSeedEdge = 'all',
    [switch]$U03PerimeterSpreadSeeds,
    [switch]$EarlyPublicRoutePrune,
    [switch]$DeferredEarlyRouteChecks,
    [switch]$ExportAllRouteTestedCandidates,
    [ValidateSet('balanced','U-01-only','U-02-only','U-03-only','U-04-only')]
    [string]$RootSearchScope = 'balanced',
    [ValidateSet('baseline','guest-branch-first')]
    [string]$U02RootPlanVariant = 'baseline',
    [ValidateRange(0,64)]
    [int]$AdditionalContactSamples = 0,
    [ValidateRange(1,9)]
    [int]$PublicDoorEdgeSamples = 1,
    [string]$ValidateCandidateJsonPath = '',
    [string]$CandidateRouteReportPath = ''
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
    $script:ShellW=$ShellWidthOverrideFt;$script:ShellD=$ShellDepthOverrideFt
    $ownerEnvelope=([Math]::Abs($script:ShellW-[double]$proposal.shell.width_ft) -le 0.000001 -and [Math]::Abs($script:ShellD-[double]$proposal.shell.depth_ft) -le 0.000001)
    $m76Envelope=([Math]::Abs($script:ShellW-38.333333) -le 0.000001 -and [Math]::Abs($script:ShellD-40.0) -le 0.000001)
    if($ownerEnvelope){$script:ShellCase='exploratory full main-floor 40 x 42 ft envelope used as upper-shell expansion; unselected proposal'}
    elseif($m76Envelope){$script:ShellCase='M76-derived 38.333333 x 40 ft hypothetical upper-shell test envelope; unselected proposal, owner-authorized exploration only'}
    else{throw 'Shell override must match the existing 40 x 42 ft owner-follow-up envelope or the explicitly authorized M76 38.333333 x 40 ft sensitivity case.'}
}else{
    $script:ShellW=[double]$selected.shells.rear_upper[0];$script:ShellD=[double]$selected.shells.rear_upper[1]
    $script:ShellCase='selected-D-derived 36 x 32 ft rear-upper wing test envelope'
}
$script:GridStepFt=1.0/6.0
$script:NodeLimit=[Math]::Max(100,$NodeLimit)
$script:UseLandingAlignedRootSeeds=($LandingAlignedRootSeeds.IsPresent -eq $true)
$script:UseU03PerimeterRootSeeds=($U03PerimeterRootSeeds.IsPresent -eq $true)
$script:UseU03PerimeterSpreadSeeds=($U03PerimeterSpreadSeeds.IsPresent -eq $true)
$script:UseEarlyPublicRoutePrune=($EarlyPublicRoutePrune.IsPresent -eq $true)
$script:UseDeferredEarlyRouteChecks=($DeferredEarlyRouteChecks.IsPresent -eq $true)
if($script:UseEarlyPublicRoutePrune -and -not $script:UseLandingAlignedRootSeeds){throw 'Early public-route pruning requires -LandingAlignedRootSeeds so checked room goals remain in a fixed frame.'}
if($script:UseDeferredEarlyRouteChecks -and -not $script:UseEarlyPublicRoutePrune){throw '-DeferredEarlyRouteChecks requires -EarlyPublicRoutePrune.'}
if($script:UseU03PerimeterRootSeeds -and (-not $script:UseLandingAlignedRootSeeds -or $RootSearchScope -ne 'U-03-only')){throw '-U03PerimeterRootSeeds requires -LandingAlignedRootSeeds and -RootSearchScope U-03-only.'}
if($script:UseU03PerimeterSpreadSeeds -and -not $script:UseU03PerimeterRootSeeds){throw '-U03PerimeterSpreadSeeds requires -U03PerimeterRootSeeds.'}
if(-not $script:UseU03PerimeterRootSeeds -and $U03PerimeterSeedEdge -ne 'all'){throw '-U03PerimeterSeedEdge requires -U03PerimeterRootSeeds.'}
$script:EarlyRouteCheckCount=0
$script:EarlyRoutePruneRejects=0
$script:EarlyRouteCheckpointSkips=0
$script:AllSearchRoots=@('U-01','U-02','U-04')
$script:SearchRoots=if($RootSearchScope -eq 'balanced'){@($script:AllSearchRoots)}else{@($RootSearchScope.Replace('-only',''))}
$script:LandingSeedSides=@('north','east_south_edge')
if($script:UseU03PerimeterRootSeeds){
    $edges=if($U03PerimeterSeedEdge -eq 'all'){@('north','east','south','west')}else{@($U03PerimeterSeedEdge)}
    if($script:UseU03PerimeterSpreadSeeds){$script:LandingSeedSides=@(foreach($edge in $edges){foreach($fraction in @(0.0,0.5,1.0)){('{0}@{1}' -f $edge,$fraction.ToString('F1',[Globalization.CultureInfo]::InvariantCulture))}})}
    else{$script:LandingSeedSides=$edges}
}
$script:AdditionalContactSamples=$AdditionalContactSamples
$script:PublicDoorEdgeSamples=$PublicDoorEdgeSamples
$script:PerRootOrientationNodeBudget=[Math]::Max(1,[Math]::Floor($script:NodeLimit/($script:SearchRoots.Count*2.0*$(if($script:UseLandingAlignedRootSeeds){$script:LandingSeedSides.Count}else{1}))))
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
$script:Topology=@(
    [ordered]@{id='U01_PRIVATE';a='U-01';b='C-PRIVATE'},
    [ordered]@{id='BOUTIQUE_PRIVATE';a='C-PRIVATE';b='U-02'},
    [ordered]@{id='PRIVATE_HYBRID';a='U-02';b='U-03'},
    [ordered]@{id='HYBRID_JJ';a='U-03';b='U-06'},
    [ordered]@{id='GUEST_JJ';a='U-06';b='U-04'},
    [ordered]@{id='PRIMARY_BATH';a='U-01';b='U-05'}
)
$script:RootPlans=[ordered]@{
    'U-01'=@(
        [ordered]@{id='U01_PRIVATE';child='C-PRIVATE';parent='U-01'},
        [ordered]@{id='BOUTIQUE_PRIVATE';child='U-02';parent='C-PRIVATE'},
        [ordered]@{id='PRIVATE_HYBRID';child='U-03';parent='U-02'},
        [ordered]@{id='HYBRID_JJ';child='U-06';parent='U-03'},
        [ordered]@{id='GUEST_JJ';child='U-04';parent='U-06'},
        [ordered]@{id='PRIMARY_BATH';child='U-05';parent='U-01'}
    )
    'U-02'=@(
        [ordered]@{id='BOUTIQUE_PRIVATE';child='C-PRIVATE';parent='U-02'},
        [ordered]@{id='U01_PRIVATE';child='U-01';parent='C-PRIVATE'},
        [ordered]@{id='PRIVATE_HYBRID';child='U-03';parent='U-02'},
        [ordered]@{id='HYBRID_JJ';child='U-06';parent='U-03'},
        [ordered]@{id='GUEST_JJ';child='U-04';parent='U-06'},
        [ordered]@{id='PRIMARY_BATH';child='U-05';parent='U-01'}
    )
    'U-03'=@(
        [ordered]@{id='PRIVATE_HYBRID';child='U-02';parent='U-03'},
        [ordered]@{id='HYBRID_JJ';child='U-06';parent='U-03'},
        [ordered]@{id='BOUTIQUE_PRIVATE';child='C-PRIVATE';parent='U-02'},
        [ordered]@{id='GUEST_JJ';child='U-04';parent='U-06'},
        [ordered]@{id='U01_PRIVATE';child='U-01';parent='C-PRIVATE'},
        [ordered]@{id='PRIMARY_BATH';child='U-05';parent='U-01'}
    )
    'U-04'=@(
        [ordered]@{id='GUEST_JJ';child='U-06';parent='U-04'},
        [ordered]@{id='HYBRID_JJ';child='U-03';parent='U-06'},
        [ordered]@{id='PRIVATE_HYBRID';child='U-02';parent='U-03'},
        [ordered]@{id='BOUTIQUE_PRIVATE';child='C-PRIVATE';parent='U-02'},
        [ordered]@{id='U01_PRIVATE';child='U-01';parent='C-PRIVATE'},
        [ordered]@{id='PRIMARY_BATH';child='U-05';parent='U-01'}
    )
}
if($U02RootPlanVariant -eq 'guest-branch-first'){
    $script:RootPlans['U-02']=@(
        [ordered]@{id='PRIVATE_HYBRID';child='U-03';parent='U-02'},
        [ordered]@{id='HYBRID_JJ';child='U-06';parent='U-03'},
        [ordered]@{id='GUEST_JJ';child='U-04';parent='U-06'},
        [ordered]@{id='BOUTIQUE_PRIVATE';child='C-PRIVATE';parent='U-02'},
        [ordered]@{id='U01_PRIVATE';child='U-01';parent='C-PRIVATE'},
        [ordered]@{id='PRIMARY_BATH';child='U-05';parent='U-01'}
    )
}
$script:Order=@($script:RootPlans['U-01'])

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
        if($script:AdditionalContactSamples -gt 0){
            # Preserve all five legacy anchors exactly. Extra points are snapped to the
            # existing 1/6 ft grid; invariant string keys avoid pipeline scans here.
            $ySamples=[System.Collections.Generic.List[double]]::new();$yKeys=[System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
            foreach($v in $ys){$key=([Math]::Round($v,6)).ToString('F6',[Globalization.CultureInfo]::InvariantCulture);if($yKeys.Add($key)){$ySamples.Add([double]$v)}}
            $minY=[double]$parent.y_ft+$script:DoorReservation-$o.d;$maxY=[double]$parent.y_ft+[double]$parent.depth_ft-$script:DoorReservation
            if($maxY -ge $minY){for($i=0;$i -lt $script:AdditionalContactSamples;$i++){$t=if($script:AdditionalContactSamples -eq 1){0.5}else{$i/([double]$script:AdditionalContactSamples-1)};$v=$minY+($maxY-$minY)*$t;$tick=[int][Math]::Round($v/$script:GridStepFt);$sample=[double]($tick*$script:GridStepFt);$key=($sample.ToString('F6',[Globalization.CultureInfo]::InvariantCulture));if($yKeys.Add($key)){$ySamples.Add($sample)}}}
            $xSamples=[System.Collections.Generic.List[double]]::new();$xKeys=[System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
            foreach($v in $xs){$key=([Math]::Round($v,6)).ToString('F6',[Globalization.CultureInfo]::InvariantCulture);if($xKeys.Add($key)){$xSamples.Add([double]$v)}}
            $minX=[double]$parent.x_ft+$script:DoorReservation-$o.w;$maxX=[double]$parent.x_ft+[double]$parent.width_ft-$script:DoorReservation
            if($maxX -ge $minX){for($i=0;$i -lt $script:AdditionalContactSamples;$i++){$t=if($script:AdditionalContactSamples -eq 1){0.5}else{$i/([double]$script:AdditionalContactSamples-1)};$v=$minX+($maxX-$minX)*$t;$tick=[int][Math]::Round($v/$script:GridStepFt);$sample=[double]($tick*$script:GridStepFt);$key=$sample.ToString('F6',[Globalization.CultureInfo]::InvariantCulture);if($xKeys.Add($key)){$xSamples.Add($sample)}}}
            $ys=$ySamples.ToArray();$xs=$xSamples.ToArray()
        }
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
    foreach($id in @('U-01','C-PRIVATE','U-02','U-03','U-05','U-06','U-04')){$r=$state[$id];if($script:UseLandingAlignedRootSeeds){$normalized[$id]=New-Box $id $r.x_ft $r.y_ft $r.width_ft $r.depth_ft}else{$normalized[$id]=New-Box $id ($r.x_ft-$bounds.min_x) ($r.y_ft-$bounds.min_y) $r.width_ft $r.depth_ft}}
    $key=(@($normalized.Keys|Sort-Object|ForEach-Object{$r=$normalized[$_];'{0}:{1:F4},{2:F4},{3:F4},{4:F4}' -f $_,$r.x_ft,$r.y_ft,$r.width_ft,$r.depth_ft}) -join '|')
    if($script:UniqueKeys.Add($key)){$script:Layouts.Add([ordered]@{bounds=$bounds;rects=$normalized;key=$key})}
}
function Search-Layout([int]$index,$state){
    if(($script:Nodes-$script:RootNodeStart) -ge $script:PerRootOrientationNodeBudget -or $script:Layouts.Count -ge $script:LayoutLimit){return}
    $script:Nodes++
    if($script:UseEarlyPublicRoutePrune -and $script:UseDeferredEarlyRouteChecks){
        $routeCheckpoint=($index -eq 0 -or $index -ge $script:Order.Count -or ($index -gt 0 -and $script:Order[$index-1].child -in @('U-01','U-02','U-04')))
        if($routeCheckpoint){if(-not (Test-PartialPublicAccess $state $liftKeepout)){$script:EarlyRoutePruneRejects++;return}}
        else{$script:EarlyRouteCheckpointSkips++}
    }elseif($script:UseEarlyPublicRoutePrune -and -not (Test-PartialPublicAccess $state $liftKeepout)){$script:EarlyRoutePruneRejects++;return}
    if($index -ge $script:Order.Count){Add-CompletedLayout $state;return}
    $edge=$script:Order[$index];$parent=$state[$edge.parent];$spec=$script:Rooms[$edge.child]
    foreach($candidate in (Get-CandidateChildren $parent $spec)){
        $valid=$true
        if(-not(Test-ParentContact $candidate $parent)){$valid=$false}
        if($valid -and $script:UseLandingAlignedRootSeeds){
            if($candidate.x_ft -lt -0.000001 -or $candidate.y_ft -lt -0.000001 -or ($candidate.x_ft+$candidate.width_ft) -gt ($script:ShellW+0.000001) -or ($candidate.y_ft+$candidate.depth_ft) -gt ($script:ShellD+0.000001)){$valid=$false}
            if($valid -and (Test-BoxesOverlap $candidate $liftKeepout)){$valid=$false}
            if($valid -and (Test-BoxesOverlap $candidate $script:StartApproach)){$valid=$false}
        }
        if($valid){foreach($existingId in $state.Keys){if($existingId -eq $edge.parent){continue};if(-not(Test-Separated $candidate $state[$existingId])){$valid=$false;break}}}
        if(-not $valid){continue}
        $state.Add($edge.child,$candidate)
        $bounds=Get-CurrentBounds $state
        if($bounds.width -le ($script:ShellW+0.000001) -and $bounds.depth -le ($script:ShellD+0.000001)){Search-Layout ($index+1) $state}
        $state.Remove($edge.child)
        if(($script:Nodes-$script:RootNodeStart) -ge $script:PerRootOrientationNodeBudget -or $script:Layouts.Count -ge $script:LayoutLimit){return}
    }
}

$script:DoorReservation=3.5
function Test-CorridorSquare([double]$cx,[double]$cy,$rects,$keepout){
    if($cx -lt 2.0-0.000001 -or $cx -gt ($script:ShellW-2.0+0.000001) -or $cy -lt 2.0-0.000001 -or $cy -gt ($script:ShellD-2.0+0.000001)){return $false}
    $corr=New-Box '4ft corridor test square' ($cx-2.0) ($cy-2.0) 4.0 4.0
    foreach($r in $rects.Values){if((Get-OverlapLength $corr.x_ft ($corr.x_ft+$corr.width_ft) $r.x_ft ($r.x_ft+$r.width_ft)) -gt 0.000001 -and (Get-OverlapLength $corr.y_ft ($corr.y_ft+$corr.depth_ft) $r.y_ft ($r.y_ft+$r.depth_ft)) -gt 0.000001){return $false}}
    if((Get-OverlapLength $corr.x_ft ($corr.x_ft+$corr.width_ft) $keepout.x_ft ($keepout.x_ft+$keepout.width_ft)) -gt 0.000001 -and (Get-OverlapLength $corr.y_ft ($corr.y_ft+$corr.depth_ft) $keepout.y_ft ($keepout.y_ft+$keepout.depth_ft)) -gt 0.000001){return $false}
    return $true
}
function Get-AccessibleGoals($room){
    $goals=[System.Collections.Generic.List[object]]::new()
    $minXTick=[int][Math]::Ceiling(($room.x_ft+$script:DoorReservation/2.0)/$script:GridStepFt)
    $maxXTick=[int][Math]::Floor(($room.x_ft+$room.width_ft-$script:DoorReservation/2.0)/$script:GridStepFt)
    $minYTick=[int][Math]::Ceiling(($room.y_ft+$script:DoorReservation/2.0)/$script:GridStepFt)
    $maxYTick=[int][Math]::Floor(($room.y_ft+$room.depth_ft-$script:DoorReservation/2.0)/$script:GridStepFt)
    if($maxXTick -lt $minXTick -or $maxYTick -lt $minYTick){return @()}
    for($i=0;$i -lt $script:PublicDoorEdgeSamples;$i++){
        $t=if($script:PublicDoorEdgeSamples -eq 1){0.5}else{$i/([double]$script:PublicDoorEdgeSamples-1)}
        $xTick=[int][Math]::Round($minXTick+($maxXTick-$minXTick)*$t)
        $yTick=[int][Math]::Round($minYTick+($maxYTick-$minYTick)*$t)
        $x=[double]($xTick*$script:GridStepFt);$y=[double]($yTick*$script:GridStepFt)
        $goals.Add([ordered]@{side='west';x=($room.x_ft-2.5);y=$y})
        $goals.Add([ordered]@{side='east';x=($room.x_ft+$room.width_ft+2.5);y=$y})
        $goals.Add([ordered]@{side='south';x=$x;y=($room.y_ft-2.5)})
        $goals.Add([ordered]@{side='north';x=$x;y=($room.y_ft+$room.depth_ft+2.5)})
    }
    return @($goals.ToArray())
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
        if(-not $rects.Contains($id)){continue}
        $goals=Get-AccessibleGoals $rects[$id];$sides=[System.Collections.Generic.List[string]]::new()
        foreach($g in $goals){$ix=[int][Math]::Round([double]$g.x*$grid);$iy=[int][Math]::Round([double]$g.y*$grid);if([Math]::Abs($ix/$grid-[double]$g.x) -gt 0.000001 -or [Math]::Abs($iy/$grid-[double]$g.y) -gt 0.000001){continue};if($ix -ge 0 -and $ix -le $maxIx -and $iy -ge 0 -and $iy -le $maxIy -and $visited[$ix,$iy] -and -not $blocked[$ix,$iy]){$sides.Add($g.side)}}
        $reachable[$id]=@($sides)
    }
    [ordered]@{visited_cells=$visitedCount;reachable_room_sides=$reachable;required_public_rooms_reached=(@($reachable['U-01']).Count -gt 0 -and @($reachable['U-02']).Count -gt 0 -and @($reachable['U-04']).Count -gt 0);u03_hall_side_reachable=(@($reachable['U-03']).Count -gt 0)}
}
if(-not [string]::IsNullOrWhiteSpace($ValidateCandidateJsonPath)){
    if([string]::IsNullOrWhiteSpace($CandidateRouteReportPath)){throw 'Candidate route validation requires -CandidateRouteReportPath.'}
    if(-not $script:UseLandingAlignedRootSeeds -or [Math]::Abs($script:ShellW-38.333333) -gt 0.000001 -or [Math]::Abs($script:ShellD-40.0) -gt 0.000001){throw 'Candidate validation is limited to the landing-aligned hypothetical 38.333333 x 40 ft test shell.'}
    $candidatePath=[System.IO.Path]::GetFullPath((Join-Path $repo $ValidateCandidateJsonPath))
    if(-not $candidatePath.StartsWith(($repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar)+[System.IO.Path]::DirectorySeparatorChar),[StringComparison]::OrdinalIgnoreCase)){throw 'Candidate JSON must resolve inside this repository.'}
    if(-not (Test-Path -LiteralPath $candidatePath -PathType Leaf)){throw "Candidate JSON is missing: $candidatePath"}
    $candidateDocument=Get-Content -LiteralPath $candidatePath -Raw | ConvertFrom-Json
    $candidateRows=@($candidateDocument)
    if($candidateRows.Count -ne 2){throw "Expected the two exact M132 M130-source layouts; found $($candidateRows.Count)."}
    $routeRows=[System.Collections.Generic.List[object]]::new()
    foreach($candidate in $candidateRows){
        $rects=[ordered]@{}
        foreach($room in @($candidate.other_rooms)+@($candidate.u01)+@($candidate.u05)){
            if($rects.Contains([string]$room.id)){throw "Duplicate room in $($candidate.candidate_id)/$($candidate.variant): $($room.id)"}
            $rects[[string]$room.id]=New-Box ([string]$room.id) ([double]$room.x) ([double]$room.y) ([double]$room.w) ([double]$room.d)
        }
        $route=Get-HallReachability $rects $liftKeepout
        if($null -eq $route){$routeRows.Add([pscustomobject][ordered]@{candidate_id=[string]$candidate.candidate_id;variant=[string]$candidate.variant;route_result='blocked start or no route result';visited_grid_cells=0;public_room_sample_sides=@{};required_public_rooms_reached=$false;u03_public_side_reachable=$false})}
        else{$routeRows.Add([pscustomobject][ordered]@{candidate_id=[string]$candidate.candidate_id;variant=[string]$candidate.variant;route_result='sampled grid result';visited_grid_cells=[int]$route.visited_cells;public_room_sample_sides=$route.reachable_room_sides;required_public_rooms_reached=[bool]$route.required_public_rooms_reached;u03_public_side_reachable=[bool]$route.u03_hall_side_reachable})}
    }
    $routeChecks=[ordered]@{
        two_exact_M130_source_layouts_checked=($routeRows.Count -eq 2)
        both_layouts_reach_sampled_U01_U02_U04_public_edges=(@($routeRows|Where-Object { -not $_.required_public_rooms_reached }).Count -eq 0)
        neither_layout_reaches_a_sampled_U03_public_edge=(@($routeRows|Where-Object { $_.u03_public_side_reachable }).Count -eq 0)
        sampled_hall_grid_route_is_not_a_door_or_accessibility_check=$true
    }
    $routeFailed=@($routeChecks.Keys|Where-Object{-not $routeChecks[$_]})
    $candidateHash=(Get-FileHash -LiteralPath $candidatePath -Algorithm SHA256).Hash.ToLowerInvariant()
    $candidateRelativePath=$candidatePath.Substring($repo.Length).TrimStart([char[]]@('\','/'))
    $report=[ordered]@{schema='forever-home.m37-candidate-route-validation.v1';status=if($routeFailed.Count){'FAIL'}else{'PASS'};shell=[ordered]@{width_ft=$script:ShellW;depth_ft=$script:ShellD;status=$script:ShellCase};route_grid_ft=([double](1.0/$grid));public_edge_samples_per_room_side=$script:PublicDoorEdgeSamples;landing_start=[ordered]@{x_ft=$startX;y_ft=$startY};lift_keepout=$liftKeepout;candidate_json_path=$candidateRelativePath;candidate_json_sha256=$candidateHash;generator='Tools/test_m37_upper_suite_pack_and_route.ps1';generator_sha256=(Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant();results=@($routeRows);checks=[ordered]@{passed_count=($routeChecks.Count-$routeFailed.Count);check_count=$routeChecks.Count;failed=$routeFailed;checks=$routeChecks};interpretation='Sampled 4 ft corridor-grid connectivity from the reserved landing approach to room-edge goals. It identifies reachable sides, not actual door openings, private-room door links, passage clear width, accessibility, egress or code compliance.'}
    $reportPath=[System.IO.Path]::GetFullPath((Join-Path $repo $CandidateRouteReportPath))
    if(-not $reportPath.StartsWith(($repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar)+[System.IO.Path]::DirectorySeparatorChar),[StringComparison]::OrdinalIgnoreCase)){throw 'Candidate route report must resolve inside this repository.'}
    $reportDir=Split-Path -Parent $reportPath
    if(-not(Test-Path -LiteralPath $reportDir)){New-Item -ItemType Directory -Path $reportDir -Force|Out-Null}
    [System.IO.File]::WriteAllText($reportPath,(ConvertTo-Json -InputObject $report -Depth 12)+"`n",[System.Text.UTF8Encoding]::new($false))
    Write-Output ("M37 candidate route validation {0}: {1}/{2} checks; {3} layouts; {4} samples per room edge" -f $report.status,$report.checks.passed_count,$report.checks.check_count,$routeRows.Count,$script:PublicDoorEdgeSamples)
    if($routeFailed.Count){throw "M37 candidate route validation failed: $($routeFailed -join ', ')"}
    return
}
function Test-PartialPublicAccess($rects,$keepout){
    $script:EarlyRouteCheckCount++
    $placedRequired=@(@('U-01','U-02','U-04')|Where-Object{$rects.Contains($_)})
    if($placedRequired.Count -eq 0){return $true}
    # In the fixed landing-aligned frame, adding room rectangles only removes
    # walkable cells. It cannot restore access to an already-placed public room.
    $route=Get-HallReachability $rects $keepout
    if($null -eq $route){return $false}
    foreach($id in $placedRequired){if(@($route.reachable_room_sides[$id]).Count -eq 0){return $false}}
    return $true
}

foreach($rootId in $script:SearchRoots){
    $script:Order=@($script:RootPlans[$rootId])
    $anchorSpec=$script:Rooms[$rootId]
    foreach($anchor in @([ordered]@{w=$anchorSpec.width_ft;d=$anchorSpec.depth_ft},[ordered]@{w=$anchorSpec.depth_ft;d=$anchorSpec.width_ft})){
        $seedSides=@('origin')
        if($script:UseLandingAlignedRootSeeds){$seedSides=$script:LandingSeedSides}
        foreach($seedSide in $seedSides){
            $script:RootNodeStart=$script:Nodes
            $seedParts=$seedSide -split '@';$seedEdge=$seedParts[0];$seedFraction=0.5
            if($script:UseU03PerimeterRootSeeds -and $seedParts.Count -gt 1){$seedFraction=[double]::Parse($seedParts[1],[Globalization.CultureInfo]::InvariantCulture)}
            if($script:UseU03PerimeterRootSeeds){
                if($seedEdge -in @('north','south')){$rootX=$seedFraction*($script:ShellW-$anchor.w);$rootY=if($seedEdge -eq 'north'){0.0}else{$script:ShellD-$anchor.d}}
                elseif($seedEdge -in @('east','west')){$rootX=if($seedEdge -eq 'east'){$script:ShellW-$anchor.w}else{0.0};$rootY=$seedFraction*($script:ShellD-$anchor.d)}
                else{throw "Unsupported U-03 perimeter seed: $seedSide"}
            }elseif($seedEdge -eq 'north'){
                # Align the root's north-side goal sample with the source landing approach centre.
                $rootX=$startX-$anchor.w/2.0;$rootY=$startY-2.5-$anchor.d
            }elseif($seedEdge -eq 'east_south_edge'){
                # Align the root's east-side goal sample one 4ft corridor width below the approach centre.
                # Its corridor square then abuts the south edge of the reserved landing approach.
                $rootX=$startX-2.5-$anchor.w;$rootY=($startY-4.0)-$anchor.d/2.0
            }else{$rootX=0.0;$rootY=0.0}
            $rootBox=New-Box $rootId $rootX $rootY $anchor.w $anchor.d
            $seedInvalid=($rootX -lt -0.000001 -or $rootY -lt -0.000001 -or ($rootX+$anchor.w) -gt ($script:ShellW+0.000001) -or ($rootY+$anchor.d) -gt ($script:ShellD+0.000001) -or (Test-BoxesOverlap $rootBox $liftKeepout) -or ($seedSide -ne 'origin' -and (Test-BoxesOverlap $rootBox $script:StartApproach)))
            if($seedInvalid){
                $script:RootSearchStats.Add([pscustomobject]@{root_room=[string]$rootId;anchor_width_ft=$anchor.w;anchor_depth_ft=$anchor.d;root_x_ft=$rootX;root_y_ft=$rootY;nodes_expanded=0;seed=$seedSide;seed_rejected=$true})
                continue
            }
            $state=[ordered]@{$rootId=$rootBox}
            Search-Layout 0 $state
            $script:RootSearchStats.Add([pscustomobject]@{root_room=[string]$rootId;anchor_width_ft=$anchor.w;anchor_depth_ft=$anchor.d;root_x_ft=$rootBox.x_ft;root_y_ft=$rootBox.y_ft;nodes_expanded=($script:Nodes-$script:RootNodeStart);seed=$seedSide;seed_rejected=$false})
            if($script:Layouts.Count -ge $script:LayoutLimit){break}
        }
        if($script:Layouts.Count -ge $script:LayoutLimit){break}
    }
    if($script:Layouts.Count -ge $script:LayoutLimit){break}
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
$layouts=@($script:Layouts|Sort-Object @{Expression={ $_.bounds.width*$_.bounds.depth }},@{Expression={ $_.bounds.width+$_.bounds.depth }})
$tested=[System.Collections.Generic.List[object]]::new();$bestPrivate=$null;$bestU03Side=$null;$translationsTested=0;$routeRuns=0
foreach($layout in $layouts){
    if($script:UseLandingAlignedRootSeeds){$translations=@([ordered]@{offset_x_ft=0.0;offset_y_ft=0.0;rects=$layout.rects})}else{$translations=Find-LiftClearTranslations $layout $liftKeepout}
    foreach($placement in $translations){
        $translationsTested++
        $route=Get-HallReachability $placement.rects $liftKeepout;$routeRuns++
        if($null -eq $route){continue}
        $publicReach=@(@('U-01','U-02','U-04')|Where-Object{@($route.reachable_room_sides[$_]).Count -gt 0})
        $record=[ordered]@{layout_key=$layout.key;layout_bounds_ft=[ordered]@{width=$layout.bounds.width;depth=$layout.bounds.depth};translation_ft=[ordered]@{x=$placement.offset_x_ft;y=$placement.offset_y_ft};rectangles=$placement.rects;public_rooms_reached=$publicReach;public_rooms_reached_count=$publicReach.Count;hall_reachability=$route}
        $tested.Add($record)
        if($route.required_public_rooms_reached -and $null -eq $bestPrivate){$bestPrivate=$record}
        if($route.u03_hall_side_reachable -and $null -eq $bestU03Side){$bestU03Side=$record}
    }
}

$routeAccessCounts=[ordered]@{}
foreach($id in @('U-01','U-02','U-03','U-04')){$routeAccessCounts[$id]=@($tested|Where-Object{@($_.hall_reachability.reachable_room_sides[$id]).Count -gt 0}).Count}
$routesToPrimaryPrivateGuest=0
foreach($routeRecord in $tested){$reach=$routeRecord.hall_reachability.reachable_room_sides;if(@($reach['U-01']).Count -gt 0 -and @($reach['U-02']).Count -gt 0 -and @($reach['U-04']).Count -gt 0){$routesToPrimaryPrivateGuest++}}
$topPartialLayouts=@($tested|ForEach-Object{[pscustomobject]@{access_count=[int]$_.public_rooms_reached_count;layout_key=[string]$_.layout_key;record=$_}}|Sort-Object -Property @{Expression='access_count';Descending=$true},@{Expression='layout_key';Descending=$false}|Select-Object -First 5|ForEach-Object{$_.record})
$maxPublicRoomsReached=0;foreach($routeRecord in $tested){if([int]$routeRecord.public_rooms_reached_count -gt $maxPublicRoomsReached){$maxPublicRoomsReached=[int]$routeRecord.public_rooms_reached_count}}
$routeSamples=@($tested|Select-Object -First 5|ForEach-Object{[ordered]@{layout_key=$_.layout_key;translation_ft=$_.translation_ft;visited_cells=$_.hall_reachability.visited_cells;reachable_room_sides=$_.hall_reachability.reachable_room_sides;required_public_rooms_reached=$_.hall_reachability.required_public_rooms_reached;u03_hall_side_reachable=$_.hall_reachability.u03_hall_side_reachable}})
$searchBudgetReached=@($script:RootSearchStats|Where-Object{$_.nodes_expanded -ge $script:PerRootOrientationNodeBudget}).Count -gt 0
$searchComplete=(-not $searchBudgetReached -and $script:Layouts.Count -lt $script:LayoutLimit)
$winner=$bestPrivate
$rootPlanIntegrity=($script:RootPlans.Count -eq ($script:AllSearchRoots.Count+1))
$expectedU02RootOrder=if($U02RootPlanVariant -eq 'guest-branch-first'){@('PRIVATE_HYBRID','HYBRID_JJ','GUEST_JJ','BOUTIQUE_PRIVATE','U01_PRIVATE','PRIMARY_BATH')}else{@('BOUTIQUE_PRIVATE','U01_PRIVATE','PRIVATE_HYBRID','HYBRID_JJ','GUEST_JJ','PRIMARY_BATH')}
$u02RootPlanVariantIntegrity=((@($script:RootPlans['U-02']|ForEach-Object{[string]$_.id}) -join ',') -eq (@($expectedU02RootOrder) -join ','))
foreach($rootId in @($script:AllSearchRoots)+@('U-03')){
    $plan=@($script:RootPlans[$rootId])
    $visited=[System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $visited.Add($rootId)|Out-Null
    if($plan.Count -ne 6 -or $plan[-1].child -ne 'U-05'){$rootPlanIntegrity=$false}
    foreach($edge in $plan){if(-not $visited.Contains([string]$edge.parent) -or -not $visited.Add([string]$edge.child)){$rootPlanIntegrity=$false}}
    if($visited.Count -ne 7){$rootPlanIntegrity=$false}
}
$rootRoomsObserved=@($script:RootSearchStats|ForEach-Object{if($_.PSObject.Properties['root_room']){[string]$_.root_room}}|Sort-Object -Unique)
$expectedRootSeedRuns=$script:SearchRoots.Count*2*$(if($script:UseLandingAlignedRootSeeds){$script:LandingSeedSides.Count}else{1})
$expectedObservedRootScope=@($script:SearchRoots|Sort-Object -Unique)
$alignedRootSeeds=($script:RootSearchStats.Count -eq $expectedRootSeedRuns)
if($script:UseLandingAlignedRootSeeds){
    foreach($seedRecord in $script:RootSearchStats){
        $seedParts=$seedRecord.seed -split '@';$seedEdge=$seedParts[0];$seedFraction=0.5
        if($script:UseU03PerimeterRootSeeds -and $seedParts.Count -gt 1){$seedFraction=[double]::Parse($seedParts[1],[Globalization.CultureInfo]::InvariantCulture)}
        if($script:UseU03PerimeterRootSeeds -and $seedEdge -in @('north','south')){$expectedX=$seedFraction*($script:ShellW-$seedRecord.anchor_width_ft);$expectedY=if($seedEdge -eq 'north'){0.0}else{$script:ShellD-$seedRecord.anchor_depth_ft}}
        elseif($script:UseU03PerimeterRootSeeds -and $seedEdge -in @('east','west')){$expectedX=if($seedEdge -eq 'east'){$script:ShellW-$seedRecord.anchor_width_ft}else{0.0};$expectedY=$seedFraction*($script:ShellD-$seedRecord.anchor_depth_ft)}
        elseif($seedEdge -eq 'north'){$expectedX=$startX-$seedRecord.anchor_width_ft/2.0;$expectedY=$startY-2.5-$seedRecord.anchor_depth_ft}
        elseif($seedEdge -eq 'east_south_edge'){$expectedX=$startX-2.5-$seedRecord.anchor_width_ft;$expectedY=($startY-4.0)-$seedRecord.anchor_depth_ft/2.0}
        else{$alignedRootSeeds=$false;continue}
        $expectedBox=New-Box $seedRecord.root_room $expectedX $expectedY $seedRecord.anchor_width_ft $seedRecord.anchor_depth_ft
        $seedShouldReject=($expectedX -lt -0.000001 -or $expectedY -lt -0.000001 -or ($expectedX+$seedRecord.anchor_width_ft) -gt ($script:ShellW+0.000001) -or ($expectedY+$seedRecord.anchor_depth_ft) -gt ($script:ShellD+0.000001) -or (Test-BoxesOverlap $expectedBox $liftKeepout) -or (Test-BoxesOverlap $expectedBox $script:StartApproach))
        if([Math]::Abs($seedRecord.root_x_ft-$expectedX) -gt 0.000001 -or [Math]::Abs($seedRecord.root_y_ft-$expectedY) -gt 0.000001 -or ([bool]$seedRecord.seed_rejected -ne [bool]$seedShouldReject)){$alignedRootSeeds=$false}
    }
}
$landingSeedLayoutIntegrity=$true
if($script:UseLandingAlignedRootSeeds){foreach($layout in $script:Layouts){foreach($r in $layout.rects.Values){if($r.x_ft -lt -0.000001 -or $r.y_ft -lt -0.000001 -or ($r.x_ft+$r.width_ft) -gt ($script:ShellW+0.000001) -or ($r.y_ft+$r.depth_ft) -gt ($script:ShellD+0.000001) -or (Test-BoxesOverlap $r $liftKeepout) -or (Test-BoxesOverlap $r $script:StartApproach)){$landingSeedLayoutIntegrity=$false;break}};if(-not $landingSeedLayoutIntegrity){break}}}
$checks=[ordered]@{
    selected_D_source_matches_owner_followup=($proposal.source_selected_D_sha256 -eq $selectedHash)
    all_six_upper_rooms_and_private_connector_come_from_selected_D=($script:Rooms.Count -eq 7)
    all_room_dimensions_match_selected_D=(@($script:Rooms.Keys|Where-Object{$id=$_;$sourceRoom=$selected.plans.upper|Where-Object id -eq $id;(-not $sourceRoom) -or ([Math]::Abs($script:Rooms[$id].width_ft-[double]$sourceRoom.w) -gt 0.000001) -or ([Math]::Abs($script:Rooms[$id].depth_ft-[double]$sourceRoom.d) -gt 0.000001)}).Count -eq 0)
    door_reservation_is_source_derived_3_5ft=([Math]::Abs($script:DoorReservation-3.5) -lt 0.000001)
    owner_private_sequence_is_in_search_graph=(@($script:Topology|Where-Object{$_.id -eq 'U01_PRIVATE' -and $_.a -eq 'U-01' -and $_.b -eq 'C-PRIVATE'}).Count -eq 1 -and @($script:Topology|Where-Object{$_.id -eq 'BOUTIQUE_PRIVATE' -and $_.a -eq 'C-PRIVATE' -and $_.b -eq 'U-02'}).Count -eq 1 -and @($script:Topology|Where-Object{$_.id -eq 'PRIVATE_HYBRID' -and $_.a -eq 'U-02' -and $_.b -eq 'U-03'}).Count -eq 1)
    hybrid_guest_JJ_is_in_search_graph=(@($script:Topology|Where-Object{$_.id -eq 'HYBRID_JJ' -and $_.a -eq 'U-03' -and $_.b -eq 'U-06'}).Count -eq 1 -and @($script:Topology|Where-Object{$_.id -eq 'GUEST_JJ' -and $_.a -eq 'U-06' -and $_.b -eq 'U-04'}).Count -eq 1)
    search_root_scope_matches_requested=(($rootRoomsObserved -join ',') -eq ($expectedObservedRootScope -join ',') -and @($script:RootSearchStats).Count -eq $expectedRootSeedRuns)
    each_root_plan_preserves_all_links_and_places_primary_bath_last=$rootPlanIntegrity
    U02_root_plan_variant_matches_requested=$u02RootPlanVariantIntegrity
    additional_contact_sample_count_is_bounded=($script:AdditionalContactSamples -ge 0 -and $script:AdditionalContactSamples -le 64)
    additional_contact_grid_step_is_one_sixth_ft=([Math]::Abs($script:GridStepFt-(1.0/6.0)) -lt 0.000001)
    public_door_edge_sample_count_is_bounded=($script:PublicDoorEdgeSamples -ge 1 -and $script:PublicDoorEdgeSamples -le 9)
    public_door_goal_points_reserve_source_contact=(@($script:Rooms.Keys|Where-Object{$r=$script:Rooms[$_];$goals=@(Get-AccessibleGoals $r);$goals.Count -ne (4*$script:PublicDoorEdgeSamples) -or @($goals|Where-Object{$g=$_;($g.side -in @('west','east') -and ($g.y -lt ($r.y_ft+$script:DoorReservation/2.0-0.000001) -or $g.y -gt ($r.y_ft+$r.depth_ft-$script:DoorReservation/2.0+0.000001))) -or ($g.side -in @('north','south') -and ($g.x -lt ($r.x_ft+$script:DoorReservation/2.0-0.000001) -or $g.x -gt ($r.x_ft+$r.width_ft-$script:DoorReservation/2.0+0.000001)))}).Count -gt 0}).Count -eq 0)
    public_access_counts_match_reachability=(@($tested|Where-Object{$record=$_;$expected=@(@('U-01','U-02','U-04')|Where-Object{@($record.hall_reachability.reachable_room_sides[$_]).Count -gt 0});$record.public_rooms_reached_count -ne $expected.Count -or (($record.public_rooms_reached -join ',') -ne ($expected -join ','))}).Count -eq 0)
    partial_access_report_is_ranked_and_bounded=($topPartialLayouts.Count -le 5 -and ($topPartialLayouts.Count -eq 0 -or [int]$topPartialLayouts[0].public_rooms_reached_count -eq $maxPublicRoomsReached))
    landing_aligned_root_seeds_follow_source_approach_sample=((-not $script:UseLandingAlignedRootSeeds) -or $alignedRootSeeds)
    landing_seeded_room_boxes_remain_inside_shell_and_clear_of_obstacles=((-not $script:UseLandingAlignedRootSeeds) -or $landingSeedLayoutIntegrity)
    blocked_grid_matches_exact_clearance_predicate=$script:BlockedGridParityCheck
    upper_frame_offset_and_lift_projection_are_source_derived=([Math]::Abs($upperOffset-6.0) -lt 0.000001 -and [Math]::Abs($liftKeepout.y_ft-28.0) -lt 0.000001 -and [Math]::Abs($liftKeepout.depth_ft-[Math]::Min(8.0,($script:ShellD-28.0))) -lt 0.000001)
    upper_shell_dimensions_match_documented_case=(($script:ShellCase -match '^selected-D-derived') -and [Math]::Abs($script:ShellW-[double]$selected.shells.rear_upper[0]) -lt 0.000001 -and [Math]::Abs($script:ShellD-[double]$selected.shells.rear_upper[1]) -lt 0.000001) -or (($script:ShellCase -match '^exploratory full main-floor') -and [Math]::Abs($script:ShellW-[double]$proposal.shell.width_ft) -lt 0.000001 -and [Math]::Abs($script:ShellD-[double]$proposal.shell.depth_ft) -lt 0.000001) -or (($script:ShellCase -match '^M76-derived') -and [Math]::Abs($script:ShellW-38.333333) -lt 0.000001 -and [Math]::Abs($script:ShellD-40.0) -lt 0.000001)
    stair_landing_start_is_source_derived=([Math]::Abs($startX-19.1666666667) -lt 0.000001 -and [Math]::Abs($startY-30.0) -lt 0.000001)
    final_translations_reserve_source_stair_approach=([Math]::Abs($script:StartApproach.x_ft-17.1666666667) -lt 0.000001 -and [Math]::Abs($script:StartApproach.y_ft-28.0) -lt 0.000001 -and $script:StartApproach.width_ft -eq 4.0 -and $script:StartApproach.depth_ft -eq 4.0)
    search_is_deterministic_and_bounded=($script:Nodes -le $script:NodeLimit -and $script:Layouts.Count -le $script:LayoutLimit -and @($script:RootSearchStats|Where-Object{$_.nodes_expanded -gt $script:PerRootOrientationNodeBudget}).Count -eq 0)
    owner_revised_U03_private_route_only_matches_proposal=($proposal.owner_inputs.u03_shared_hall_access -eq $false -and @($proposal.upper_suite.excluded_access_edges|Where-Object{$_.a -eq 'U-03' -and $_.b -eq 'C-UPPER'}).Count -eq 1)
    owner_required_U02_direct_shared_hall_arrival_matches_proposal=($proposal.owner_inputs.u02_direct_shared_hall_arrival_required -eq $true -and @($proposal.upper_suite.retained_shared_access_edges|Where-Object{$_.a -eq 'U-02' -and $_.b -eq 'C-UPPER' -and $_.status -like 'owner-required direct shared-hall arrival*'}).Count -eq 1)
    any_winner_reaches_all_required_public_rooms=($null -eq $winner -or $winner.hall_reachability.required_public_rooms_reached)
    route_summary_matches_tested_records=($tested.Count -le $routeRuns -and $routeAccessCounts['U-01'] -le $tested.Count -and $routeAccessCounts['U-02'] -le $tested.Count -and $routeAccessCounts['U-03'] -le $tested.Count -and $routeAccessCounts['U-04'] -le $tested.Count -and $routesToPrimaryPrivateGuest -le $tested.Count)
    selected_D_file_unchanged_during_run=((Get-FileHash -Algorithm SHA256 -LiteralPath $selectedPath).Hash.ToLowerInvariant() -eq $selectedHash)
}
if($script:UseEarlyPublicRoutePrune){
    $checks['early_public_route_pruning_requires_fixed_landing_aligned_frame']=$script:UseLandingAlignedRootSeeds
    $checks['early_route_checks_do_not_exceed_expanded_nodes']=($script:EarlyRouteCheckCount -le $script:Nodes)
    $checks['early_route_rejections_do_not_exceed_route_checks']=($script:EarlyRoutePruneRejects -le $script:EarlyRouteCheckCount)
    if($script:UseDeferredEarlyRouteChecks){$checks['early_route_checkpoint_coverage_matches_node_visits']=(($script:EarlyRouteCheckCount+$script:EarlyRouteCheckpointSkips) -eq $script:Nodes)}
}
if($script:UseU03PerimeterRootSeeds){
    $expectedSeedEdges=if($U03PerimeterSeedEdge -eq 'all'){@('north','east','south','west')}else{@($U03PerimeterSeedEdge)}
    if($script:UseU03PerimeterSpreadSeeds){$expectedSeedLabels=@(foreach($edge in $expectedSeedEdges){foreach($fraction in @(0.0,0.5,1.0)){('{0}@{1}' -f $edge,$fraction.ToString('F1',[Globalization.CultureInfo]::InvariantCulture))}})}else{$expectedSeedLabels=$expectedSeedEdges}
    $checks['U03_perimeter_seed_edge_and_fraction_controls_match_request']=(($script:LandingSeedSides -join ',') -eq ($expectedSeedLabels -join ',') -and $RootSearchScope -eq 'U-03-only')
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
    search=[ordered]@{algorithm=$(if($script:UseU03PerimeterRootSeeds){'targeted U-03 root placement on each hypothetical shell edge, then deterministic tree-attached room placement and sampled public-route filtering'}elseif($script:UseEarlyPublicRoutePrune){'deterministic landing-aligned tree search with monotone early pruning: once a placed required-public room has no corridor goal reachable, later room obstacles cannot restore that route; final layouts are still checked by the full route test'}elseif($script:UseLandingAlignedRootSeeds){'deterministic landing-aligned root seeding; align north-side room goal to the landing approach centre or east-side goal one source 4ft corridor width south of centre; reject room candidates outside shell or overlapping lift/approach during placement; evaluate hall route only after a complete packing'}else{'deterministic tree-attached rectangle search; place the primary bath last; sample five contact alignments with 0.5ft wall bands and source 3.5ft contact reservations; enumerate translation boundaries from shell, lift and reserved stair approach'});contact_sampling='Preserve the five legacy anchors; append the requested number of evenly spaced positions on each axis within the source 3.5ft door-reservation interval, snapped to the 1/6ft search grid.';public_door_edge_samples=$script:PublicDoorEdgeSamples;public_door_edge_sample_basis='Hall reachability is tested at evenly spaced goal points along each room side, with each point kept at least half the source door-reservation interval from side corners. These are route samples only, not door locations or openings.';root_search_scope=$RootSearchScope;u02_root_plan_variant=$U02RootPlanVariant;additional_contact_samples=$script:AdditionalContactSamples;landing_aligned_root_seed_search=$script:UseLandingAlignedRootSeeds;landing_root_seed_sides=$(if($script:UseLandingAlignedRootSeeds){$script:LandingSeedSides}else{@('origin')});node_limit=$script:NodeLimit;search_root_rooms=$script:SearchRoots;per_root_orientation_node_budget=$script:PerRootOrientationNodeBudget;nodes_expanded=$script:Nodes;node_limit_reached=$searchBudgetReached;root_orientation_runs=@($script:RootSearchStats);layout_limit=$script:LayoutLimit;layouts_recorded=$script:Layouts.Count;raw_complete_layouts=$script:RawLayouts;start_approach_translation_rejects=$script:StartApproachTranslationRejected;translations_tested=$translationsTested;hall_route_searches=$routeRuns;routes_with_clear_stair_approach=$tested.Count;coordinate_grid_ft=$script:GridStepFt;source_door_reservation_ft=$script:DoorReservation;search_complete=$searchComplete}
    source_dimensions_ft=$script:Rooms
    coordinate_basis=[ordered]@{shell_case=$script:ShellCase;width_ft=$script:ShellW;depth_ft=$script:ShellD;selected_D_upper_frame_offset_ft=$upperOffset;note=$(if($script:ShellCase -match '^M76-derived'){'Owner-authorized exploration of a M76 sensitivity case only; not a selected or approved building dimension.'}elseif($script:ShellCase -match '^exploratory full main-floor'){'The full-plate case reuses the owner-follow-up 40 x 42 ft main-floor test envelope as an unapproved upper-shell expansion comparison.'}else{'Shell dimensions are derived from the selected-D source study.'})}
    preserved_constraints=@('U-01 to primary-only U-05 through a nominal 3.5ft contact reservation','U-01 to C-PRIVATE to U-02','owner-directed U-02 to U-03 private route only; no direct U-03 to C-UPPER door','owner-required direct U-02 shared-hall arrival; actual opening remains unmodeled','U-04 retains independent guest shared-hall access','U-03 and U-04 each contact U-06 for Jack-and-Jill access','source 8x8ft lift reservation, clipped to its upper-wing projection','4ft-wide hall route from source upper landing to U-01, U-02 and U-04; sampled side goals do not establish doors')
    local_lift_keepout=$liftKeepout
    reserved_stair_approach=$script:StartApproach
    upper_landing_local=$landingLocal
    route_access_counts_by_room=$routeAccessCounts
    route_cases_reaching_U01_U02_U04=$routesToPrimaryPrivateGuest
    candidate_private_only=$bestPrivate
    top_partial_public_access_layouts=$topPartialLayouts
    first_route_with_U03_hall_side_reachable=$bestU03Side
    best_candidate=$winner
    tested_route_samples=$routeSamples
    first_translation_diagnostics=@($script:TranslationDiagnostics|Select-Object -First 3)
    checks=$checks
    failures=$failed
    limitations=@('The tree search is deterministic but bounded by NodeLimit/LayoutLimit and samples five contact-alignment anchors; it is not an exhaustive proof that no layout exists.','A 0.5ft gap represents a nominal wall allowance, and a 3.5ft edge reservation is inherited from selected-D door-matrix data, not clear opening or door-swing geometry.','Room connection goals are sample points 2.5ft beyond each room-block side, a schematic reachability proxy rather than a door or specified clearance.','The hall search checks a 4ft swept square on a 2in translation grid. It does not model walls, doors, swings, landings beyond the source connector, headroom, floor openings, stairs, structure, services, furniture or fire/life-safety.','The lift keepout is a plan projection from the source reservation; verify actual shaft and floor opening in Revit.','No Revit, IFC, code, accessibility, structural or construction validation is made. A search candidate is a room-block concept only.','The revised private-route-only direction excludes a direct U-03 shared-hall door; actual private and public openings remain unmodeled. Corridor proximity to U-03 is not evidence of a doorway. No room sizes or selected-D baseline are edited.')
}
if($script:UseU03PerimeterRootSeeds){
    $report.search['u03_perimeter_root_seeds']=$true
    $report.search['algorithm']='targeted U-03 root placement on the requested hypothetical shell edge(s), using center or spread along-edge fractions, then deterministic room placement and sampled public-route filtering'
    $report.search['u03_perimeter_seed_edge']=$U03PerimeterSeedEdge
    $report.search['u03_perimeter_spread_seeds']=$script:UseU03PerimeterSpreadSeeds
}
if($script:UseEarlyPublicRoutePrune){
    $report.search['early_public_route_pruning']= $true
    $report.search['early_route_check_count']=$script:EarlyRouteCheckCount
    $report.search['early_route_prune_rejections']=$script:EarlyRoutePruneRejects
    if($script:UseDeferredEarlyRouteChecks){
        $report.search['early_route_checkpoint_policy']='Check after the root, after each required-public room is placed, and before recording a complete layout; defer checks across intervening private/primary/JJ connector blocks.'
        $report.search['early_route_checkpoint_skips']=$script:EarlyRouteCheckpointSkips
        $report.limitations+= 'Early route pruning is valid only in the fixed landing-aligned frame: adding room rectangles can remove walkable cells but cannot restore a route to an already placed required-public room. Checks are deferred across non-public room placements, then applied after the next required-public room and before a complete layout is recorded. It validates only the sampled corridor proxy.'
    }else{
        $report.limitations+= 'Early route pruning is valid only in the fixed landing-aligned frame: adding room rectangles can remove walkable cells but cannot restore a route to an already placed required-public room. It validates only the sampled corridor proxy.'
    }
}

if(-not(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target|Out-Null}
$jsonPath=Join-Path $target 'search.json';$checkPath=Join-Path $target 'checks.json';$svgPath=Join-Path $target 'upper-suite-search.svg'
$report|ConvertTo-Json -Depth 28|Set-Content -LiteralPath $jsonPath -Encoding utf8
$checkReport=[ordered]@{count=$checks.Count;passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@();checks=$checks;search_summary=$report.search;source_fingerprints_sha256=$report.source_fingerprints_sha256;interpretation='A passing integrity check validates search setup and evidence. A viable layout is claimed only when its recorded hall reachability checks pass.'}
$checkReport|ConvertTo-Json -Depth 20|Set-Content -LiteralPath $checkPath -Encoding utf8

$routeCandidateArchivePath = $null
$routeCandidateArchiveHash = $null
if($ExportAllRouteTestedCandidates){
    $routeCandidateArchivePath=Join-Path $target 'all-route-tested-candidates.json'
    $routeCandidateArchive=[ordered]@{
        schema='forever-home.m37-route-tested-candidate-archive.v1'
        source_search_sha256=(Get-FileHash -LiteralPath $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant()
        source_fingerprints_sha256=$report.source_fingerprints_sha256
        search_parameters=$report.search
        candidate_count=$tested.Count
        route_runs_total=$routeRuns
        candidates=@($tested)
        interpretation='Archive contains only complete packings with a non-null sampled hall-route result from this bounded run.'
    }
    ConvertTo-Json -InputObject $routeCandidateArchive -Depth 28|Set-Content -LiteralPath $routeCandidateArchivePath -Encoding utf8
    $routeCandidateArchiveHash=(Get-FileHash -LiteralPath $routeCandidateArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
}

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
} elseif($topPartialLayouts.Count -gt 0){
    $partial=$topPartialLayouts[0]
    foreach($id in $partial.rectangles.Keys){$r=$partial.rectangles[$id];$class='room';if($id -eq 'C-PRIVATE'){$class='private'}elseif($id -in @('U-05','U-06')){$class='bath'};$label=$id;if($partial.public_rooms_reached -contains $id){$label+=' [edge goal]'};$svg.Add(('<rect class="{0}" x="{1}" y="{2}" width="{3}" height="{4}"/><text class="label" x="{5}" y="{6}">{7}</text>' -f $class,($sx+$r.x_ft*$scale),($sy+$r.y_ft*$scale),($r.width_ft*$scale),($r.depth_ft*$scale),($sx+$r.x_ft*$scale+4),($sy+$r.y_ft*$scale+15),$label))}
    $svg.Add(('<text class="warn" x="40" y="700">Partial route diagnostic: {0}/3 required public rooms have a reachable sampled edge.</text>' -f $partial.public_rooms_reached_count))
} else {$svg.Add('<text class="warn" x="40" y="710">No approach-clear layout was available for a route diagnostic.</text>')}
$svg.Add(('<text class="note" x="40" y="730">Nodes {0}; layouts {1}; search complete {2}. A capped search is not proof of impossibility.</text>' -f $script:Nodes,$script:Layouts.Count,$searchComplete))
$svg.Add('<text class="note" x="40" y="752">Not Revit walls, door swings, floor openings, code or engineering.</text>')
$svg.Add('</svg>')
$svg -join "`n"|Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest=[ordered]@{generator='Tools/test_m37_upper_suite_pack_and_route.ps1';source_fingerprints_sha256=$report.source_fingerprints_sha256;search_parameters=[ordered]@{node_limit=$script:NodeLimit;layout_limit=$script:LayoutLimit;root_search_scope=$RootSearchScope;u02_root_plan_variant=$U02RootPlanVariant;additional_contact_samples=$script:AdditionalContactSamples;public_door_edge_samples=$script:PublicDoorEdgeSamples;landing_aligned_root_seed_search=$script:UseLandingAlignedRootSeeds;shell_width_override_ft=$ShellWidthOverrideFt;shell_depth_override_ft=$ShellDepthOverrideFt};output_hashes_sha256=[ordered]@{search=(Get-FileHash $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks=(Get-FileHash $checkPath -Algorithm SHA256).Hash.ToLowerInvariant();svg=(Get-FileHash $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
if($script:UseU03PerimeterRootSeeds){$manifest.search_parameters['u03_perimeter_root_seeds']=$true;$manifest.search_parameters['u03_perimeter_seed_edge']=$U03PerimeterSeedEdge;$manifest.search_parameters['u03_perimeter_spread_seeds']=$script:UseU03PerimeterSpreadSeeds}
if($script:UseEarlyPublicRoutePrune){$manifest.search_parameters['early_public_route_pruning']=$true}
if($script:UseDeferredEarlyRouteChecks){$manifest.search_parameters['deferred_early_route_checks']=$true}
if($ExportAllRouteTestedCandidates){$manifest.optional_route_tested_candidate_archive=[ordered]@{file='all-route-tested-candidates.json';sha256=$routeCandidateArchiveHash;candidate_count=$tested.Count}}
$manifest|ConvertTo-Json -Depth 12|Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output("M37 search-integrity checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output("Search nodes: {0}/{1}; bounded layouts: {2}; lift-clear route placements: {3}; route runs: {4}." -f $script:Nodes,$script:NodeLimit,$script:Layouts.Count,$translationsTested,$routeRuns)
Write-Output("Required public-room candidate: {0}; U-03 corridor-side reach observed: {1}." -f ($null -ne $bestPrivate),($null -ne $bestU03Side))
if($ExportAllRouteTestedCandidates){Write-Output("Optional route-tested candidate archive: {0} complete route records; SHA256 {1}." -f $tested.Count,$routeCandidateArchiveHash)}
