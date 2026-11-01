param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M242_Hall_Kitchen_Gap_Route_Sensitivity_2026-10-31/artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$studyPath=Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m215Path=Join-Path $repoRoot 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json'
$m228Path=Join-Path $repoRoot 'Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts/m228-west-a-dining-connection.json'
$m241Path=Join-Path $repoRoot 'Architecture/M241_Living_Kitchen_Interface_2026-10-31/artifacts/m241-report.json'
$expected=@{
    selected_d='516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    m215='f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
    m228='f4ab50fd02e4d71e434c4e4c83d63fe8d20b580810d7118a234bc4b2da8119ff'
    m241='390c552d3db658ee7762d55abf6532d16f8e1d8e3509927acad2a570a539c420'
}
function Get-Sha256([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-Overlap([double]$A0,[double]$A1,[double]$B0,[double]$B1){[math]::Max(0.0,[math]::Min($A1,$B1)-[math]::Max($A0,$B0))}
function Get-AreaOverlap($A,$B){(Get-Overlap $A.x ($A.x+$A.w) $B.x ($B.x+$B.w))*(Get-Overlap $A.y ($A.y+$A.h) $B.y ($B.y+$B.h))}
$actual=@{selected_d=Get-Sha256 $studyPath;m215=Get-Sha256 $m215Path;m228=Get-Sha256 $m228Path;m241=Get-Sha256 $m241Path}
foreach($key in $expected.Keys){if($actual[$key] -ne $expected[$key]){throw "Pinned $key SHA256 mismatch: $($actual[$key])"}}
$study=Get-Content -LiteralPath $studyPath -Raw|ConvertFrom-Json
$m215=Get-Content -LiteralPath $m215Path -Raw|ConvertFrom-Json
$m228=Get-Content -LiteralPath $m228Path -Raw|ConvertFrom-Json
$m241=Get-Content -LiteralPath $m241Path -Raw|ConvertFrom-Json
$roomById=@{}
foreach($r in $study.plans.main){$roomById[[string]$r.id]=[pscustomobject]@{id=[string]$r.id;x=[double]$r.x;y=[double]$r.y;w=[double]$r.w;h=[double]$(if($r.d){$r.d}else{$r.h})}}
$sourceKitchen=$roomById['M-02'];$hall=$roomById['M-05'];$livingSource=$roomById['M-01']
$movedLiving=@($m241.room_blocks_ft.moved_living)
$living=[pscustomobject]@{id='M-01 + 6 in east';x=[double]$movedLiving[0];y=[double]$movedLiving[1];w=[double]$movedLiving[2];h=[double]$movedLiving[3]}
$moveWest=[double]$m241.measured_interfaces.moved.hall_to_kitchen_gap_ft
if($moveWest -le 0){throw 'M241 does not define the positive M-05/M-02 test gap.'}
$candidateKitchen=[pscustomobject]@{id='M-02 - measured hall gap';x=($sourceKitchen.x-$moveWest);y=$sourceKitchen.y;w=$sourceKitchen.w;h=$sourceKitchen.h}
$routePoints=@($m215.route_waypoints_ft)
$origin=@($m228.coordinate_frames.m215_origin_source_ft)
$radius=([double]$m215.route_width_in/12.0/2.0)
function Distance-SegmentToRect([double]$X1,[double]$Y1,[double]$X2,[double]$Y2,$R){
    $x0=[math]::Min($X1,$X2);$xE=[math]::Max($X1,$X2);$y0=[math]::Min($Y1,$Y2);$yE=[math]::Max($Y1,$Y2)
    if([math]::Abs($Y1-$Y2) -lt 0.000001){$dx=if($xE -lt $R.x){$R.x-$xE}elseif($x0 -gt ($R.x+$R.w)){$x0-($R.x+$R.w)}else{0.0};$dy=if($Y1 -lt $R.y){$R.y-$Y1}elseif($Y1 -gt ($R.y+$R.h)){$Y1-($R.y+$R.h)}else{0.0}}
    elseif([math]::Abs($X1-$X2) -lt 0.000001){$dx=if($X1 -lt $R.x){$R.x-$X1}elseif($X1 -gt ($R.x+$R.w)){$X1-($R.x+$R.w)}else{0.0};$dy=if($yE -lt $R.y){$R.y-$yE}elseif($y0 -gt ($R.y+$R.h)){$y0-($R.y+$R.h)}else{0.0}}
    else{throw 'Pinned route contains a non-orthogonal segment; explicit geometry handling is required.'}
    [math]::Sqrt($dx*$dx+$dy*$dy)
}
function Measure-RouteClearance($Room){
    $best=[double]::PositiveInfinity;$bestSegment=-1
    for($i=0;$i -lt $routePoints.Count-1;$i++){
        $a=$routePoints[$i];$b=$routePoints[$i+1]
        $dist=Distance-SegmentToRect ([double]$a.x+[double]$origin[0]) ([double]$a.y+[double]$origin[1]) ([double]$b.x+[double]$origin[0]) ([double]$b.y+[double]$origin[1]) $Room
        if($dist -lt $best){$best=$dist;$bestSegment=$i+1}
    }
    [pscustomobject]@{minimum_centerline_distance_ft=[math]::Round($best,6);route_half_width_ft=[math]::Round($radius,6);signed_clearance_ft=[math]::Round(($best-$radius),6);nearest_route_segment=$bestSegment}
}
$sourceClearance=Measure-RouteClearance $sourceKitchen
$candidateClearance=Measure-RouteClearance $candidateKitchen
$aRect=$study.selection.main_public_bath.search_windows|Where-Object id -eq 'west_of_core'|Select-Object -First 1
$bRect=$study.selection.main_public_bath.search_windows|Where-Object id -eq 'east_of_core'|Select-Object -First 1
$protectedA=[pscustomobject]@{id='protected west A';x=[double]$aRect.x;y=[double]$aRect.y;w=[double]$aRect.w;h=[double]$(if($aRect.d){$aRect.d}else{$aRect.h})}
$unassignedB=[pscustomobject]@{id='unassigned east B';x=[double]$bRect.x;y=[double]$bRect.y;w=[double]$bRect.w;h=[double]$(if($bRect.d){$bRect.d}else{$bRect.h})}
$din=@($m228.dining_candidate.rect_ft);$dining=[pscustomobject]@{id='M228 dining proposal';x=[double]$din[0];y=[double]$din[1];w=[double]$din[2];h=[double]$din[3]}
$obstacles=@($living,$hall,$protectedA,$unassignedB,$dining,$roomById['M-04'])
$overlaps=@();foreach($o in $obstacles){$overlaps+=,[pscustomobject]@{with=$o.id;overlap_sf=[math]::Round((Get-AreaOverlap $candidateKitchen $o),6)}}
$candidateHallEdge=if([math]::Abs($candidateKitchen.x-($hall.x+$hall.w)) -lt 0.00001){[math]::Round((Get-Overlap $candidateKitchen.y ($candidateKitchen.y+$candidateKitchen.h) $hall.y ($hall.y+$hall.h)),6)}else{0.0}
$candidateLivingGap=[math]::Round(($candidateKitchen.x-($living.x+$living.w)),6)
$checks=[ordered]@{schema='forever-home.m242-hall-kitchen-route-sensitivity-checks.v1';result='pass';check_count=13;checks=[ordered]@{
    selected_d_hash_matches=($actual.selected_d -eq $expected.selected_d)
    m215_route_hash_matches=($actual.m215 -eq $expected.m215)
    m228_coordinate_frame_hash_matches=($actual.m228 -eq $expected.m228)
    m241_owner_move_hash_matches=($actual.m241 -eq $expected.m241)
    west_translation_equals_measured_six_inch_gap=([math]::Abs($moveWest-0.5) -lt 0.00001)
    kitchen_gross_area_preserved=([math]::Abs(($candidateKitchen.w*$candidateKitchen.h)-($sourceKitchen.w*$sourceKitchen.h)) -lt 0.00001)
    shell_containment_preserved=($candidateKitchen.x -ge 0 -and ($candidateKitchen.x+$candidateKitchen.w) -le 40 -and $candidateKitchen.y -ge 0 -and ($candidateKitchen.y+$candidateKitchen.h) -le 42)
    kitchen_hall_gap_closed=($candidateHallEdge -eq 12)
    no_positive_room_block_overlap=(@($overlaps|Where-Object overlap_sf -gt 0).Count -eq 0)
    living_kitchen_direct_gap_remains=($candidateLivingGap -gt 0)
    route_width_is_pinned_to_36_inches=([math]::Abs($m215.route_width_in-36.0) -lt 0.00001)
    source_route_clears_kitchen_block=($sourceClearance.signed_clearance_ft -gt 0)
    moved_kitchen_interferes_with_fixed_route_proxy=($candidateClearance.signed_clearance_ft -lt 0)
}}
if(@($checks.checks.Values|Where-Object{$_ -ne $true}).Count -gt 0){$checks.result='fail';throw "M242 checks failed: $(ConvertTo-Json $checks -Depth 10)"}
$report=[ordered]@{
    schema='forever-home.m242-hall-kitchen-route-sensitivity.v1'
    status='pass; analysis-only, schematic, not selected'
    candidate='Translate M-02 west only by the measured 0.5-ft M-05/M-02 gap; preserve its source gross area and room height.'
    source_hashes_sha256=$actual
    selected_d_modified=$false
    translation_west_ft=$moveWest
    room_blocks_ft=[ordered]@{source_kitchen=@($sourceKitchen.x,$sourceKitchen.y,$sourceKitchen.w,$sourceKitchen.h);candidate_kitchen=@($candidateKitchen.x,$candidateKitchen.y,$candidateKitchen.w,$candidateKitchen.h);hall=@($hall.x,$hall.y,$hall.w,$hall.h);moved_living=@($living.x,$living.y,$living.w,$living.h)}
    kitchen_area_sf=[math]::Round(($candidateKitchen.w*$candidateKitchen.h),6)
    interfaces=[ordered]@{moved_living_to_kitchen_gap_ft=$candidateLivingGap;hall_to_kitchen_shared_edge_ft=$candidateHallEdge}
    m215_route=[ordered]@{width_in=[double]$m215.route_width_in;coordinate_origin_ft=@([double]$origin[0],[double]$origin[1]);source_kitchen=$sourceClearance;candidate_kitchen=$candidateClearance;route_clearance_loss_in=[math]::Round(($sourceClearance.signed_clearance_ft-$candidateClearance.signed_clearance_ft)*12.0,6)}
    candidate_overlaps=$overlaps
    interpretation=@('A west shift equal to the measured 6-in hall/kitchen gap closes that room-block gap and gives M-05/M-02 a 12-ft shared edge while preserving the kitchen gross area.','With M-01 already in the owner-directed six-inch sensitivity, both living and kitchen touch M-05 as room blocks; this does not create wall openings or establish a continuous walkable/visually open connection.','The same kitchen move reduces the nearest edge clearance to the fixed M215 36-in route proxy by 6 in: from +4 in at source to -2 in (a 2-in intrusion) at the candidate kitchen edge. The specific M215 route therefore conflicts with this candidate; alternative route searches are not tested here.')
    limitations=@('M215 is one schematic route candidate; conflict with it does not prove that all route alignments fail.','Room-block gaps/contacts are not walls, openings, finished-face clearances or built dimensions. No route reroute, physical opening, door, furniture, fixture or service is modeled.','No room position is selected. West A remains protected; B and M-06 remain unassigned. This is not a code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion.')
}
$out=if([IO.Path]::IsPathRooted($OutputDirectory)){[IO.Path]::GetFullPath($OutputDirectory)}else{[IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory))}
[IO.Directory]::CreateDirectory($out)|Out-Null
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm242-report.json'),(ConvertTo-Json -InputObject $report -Depth 14)+"`r`n",$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm242-checks.json'),(ConvertTo-Json -InputObject $checks -Depth 12)+"`r`n",$utf8)
Write-Output "PASS: M242 $($checks.check_count)/$($checks.check_count); the 6-in kitchen translation closes the hall gap but intrudes $([math]::Round(-$candidateClearance.signed_clearance_ft*12.0,2)) in into the fixed M215 route proxy; selected-D unchanged."
