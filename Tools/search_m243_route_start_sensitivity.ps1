param(
    [string]$OutputDirectory='Architecture/M243_Moved_Kitchen_Route_Start_Sensitivity_2026-10-31/artifacts',
    [string]$ScratchPrefix='M243-retained'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path|Split-Path -Parent
$m215Script=Join-Path $root 'Tools/search_m215_porchtop_clearance.ps1'
$m228Path=Join-Path $root 'Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts/m228-west-a-dining-connection.json'
$m215Out=Join-Path $root ('.local/revalidation/'+$ScratchPrefix+'-m215-output')
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}
$null=& $m215Script -NorthTranslationFt 0.5 -OutputDirectory ('.local/revalidation/'+$ScratchPrefix+'-m215-output') -ScratchPrefix $ScratchPrefix
$m215Path=Join-Path $m215Out 'm215-porch-approach-clearance.json'
$m186Path=Join-Path $root ('.local/revalidation/'+$ScratchPrefix+'base-depth13_25_proxy_margin/m186-route-search.json')
$m242Path=Join-Path $root 'Architecture/M242_Hall_Kitchen_Gap_Route_Sensitivity_2026-10-31/artifacts/m242-report.json'
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
function Hash([string]$p){(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()}
$expected=[ordered]@{
    selected_d='516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    m242='54c197565569919636ea0fa851e86fcb05fccc5b11a6b4841a09e7f6dbdb8711'
    m215_script='8a63ade035b7a6ab95b79823badf6185c875cf4b2ca15dce24fb5b0661c88d23'
    m215_report='f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
    m228='f4ab50fd02e4d71e434c4e4c83d63fe8d20b580810d7118a234bc4b2da8119ff'
    m213_script='f6d527ae6814c901a1cdbc62e220a1fe3ca287c576d35d4ba6518f2f64cd1ada'
    m186_script='c882822e69a5f4408b487c176c570af4e132300de2d3aee9a5287322591f0732'
}
$m186Script=Join-Path $root 'Tools/search_m186_public_route.ps1'
$m213Script=Join-Path $root 'Tools/search_m213_kitchen_margin_sensitivity.ps1'
$actual=[ordered]@{selected_d=Hash $selectedPath;m242=Hash $m242Path;m215_script=Hash $m215Script;m213_script=Hash $m213Script;m186_script=Hash $m186Script;m228=Hash $m228Path;m215_report=Hash $m215Path}
foreach($k in $expected.Keys){if($actual[$k] -ne $expected[$k]){throw "Pinned $k SHA256 mismatch: $($actual[$k])"}}
$m215=Get-Content -LiteralPath $m215Path -Raw|ConvertFrom-Json
$m186=Get-Content -LiteralPath $m186Path -Raw|ConvertFrom-Json
$m242=Get-Content -LiteralPath $m242Path -Raw|ConvertFrom-Json
if((Hash $m215Path) -ne $expected.m215_report -or $m215.checks.passed -ne 12 -or $m186.checks.passed -ne 31 -or $m215.translation_north_ft -ne 0.5){throw 'M215/M213/M186 prerequisite generation did not match its pinned contract.'}
$m228=Get-Content -LiteralPath $m228Path -Raw|ConvertFrom-Json
$originFt=@($m228.coordinate_frames.m215_origin_source_ft)
$sourcePoints=@();foreach($p in $m215.route_waypoints_ft){$sourcePoints+=,[pscustomobject]@{x=[double]$p.x;y=[double]$p.y}}
if($sourcePoints.Count -ne 5 -or $sourcePoints[0].x -ne 19.5 -or $sourcePoints[0].y -ne 10){throw 'Unexpected retained M215 start route.'}
$oldStart=[pscustomobject]@{x=$sourcePoints[0].x;y=$sourcePoints[0].y}
$width=[double]$m215.route_width_in/12.0
function NewRect([double]$x,[double]$y,[double]$w,[double]$h,[string]$id){[pscustomobject]@{id=$id;x=$x;y=$y;w=$w;h=$h}}
function Overlap([object]$a,[object]$b){$dx=[Math]::Min(($a.x+$a.w),($b.x+$b.w))-[Math]::Max($a.x,$b.x);$dy=[Math]::Min(($a.y+$a.h),($b.y+$b.h))-[Math]::Max($a.y,$b.y);if($dx -gt 1e-8 -and $dy -gt 1e-8){[Math]::Round(($dx*$dy),8)}else{0.0}}
function RectGap([object]$a,[object]$b){$dx=[Math]::Max(0.0,[Math]::Max(($a.x-($b.x+$b.w)),($b.x-($a.x+$a.w))));$dy=[Math]::Max(0.0,[Math]::Max(($a.y-($b.y+$b.h)),($b.y-($a.y+$a.h))));[Math]::Round([Math]::Sqrt($dx*$dx+$dy*$dy),8)}
$k=@($m242.room_blocks_ft.candidate_kitchen)
$kLocal=NewRect ([double]$k[0]-$originFt[0]) ([double]$k[1]-$originFt[1]) ([double]$k[2]) ([double]$k[3]) 'candidate-kitchen-west-6in'
$obstacles=New-Object System.Collections.Generic.List[object]
foreach($raw in $m186.search.modeled_obstacles){$oy=[double]$raw.y;if([string]$raw.id -like 'porch-wall-*'){$oy+=0.5};$obstacles.Add((NewRect ([double]$raw.x) $oy ([double]$raw.w) ([double]$raw.d) ([string]$raw.id)))}
$obstacles.Add($kLocal)
$variants=New-Object System.Collections.Generic.List[object]
foreach($shift in @(0.0,0.25,0.5)){
    $points=@();foreach($p in $sourcePoints){$points+=,[pscustomobject]@{x=[double]$p.x;y=[double]$p.y}}
    $points[0]=[pscustomobject]@{x=($oldStart.x-$shift);y=$oldStart.y}
    $routeRects=New-Object System.Collections.Generic.List[object]
    for($i=0;$i -lt $points.Count-1;$i++){
        $a=$points[$i];$b=$points[$i+1]
        if([Math]::Abs($a.y-$b.y) -lt 1e-9){$routeRects.Add((NewRect ([Math]::Min($a.x,$b.x)) ($a.y-$width/2) ([Math]::Abs($b.x-$a.x)) $width "route-$i"))}
        elseif([Math]::Abs($a.x-$b.x) -lt 1e-9){$routeRects.Add((NewRect ($a.x-$width/2) ([Math]::Min($a.y,$b.y)) $width ([Math]::Abs($b.y-$a.y)) "route-$i"))}
        else{throw 'Route contains a diagonal segment.'}
        if($i -gt 0){$routeRects.Add((NewRect ($a.x-$width/2) ($a.y-$width/2) $width $width "corner-$i"))}
    }
    $routeRects.Insert(0,(NewRect ($points[0].x-$width/2) ($points[0].y-$width/2) $width $width 'route-start-cap'))
    $routeRects.Add((NewRect ($points[-1].x-$width/2) ($points[-1].y-$width/2) $width $width 'route-end-cap'))
    $hits=New-Object System.Collections.Generic.List[object];$gaps=New-Object System.Collections.Generic.List[object]
    foreach($o in $obstacles){$min=[double]::PositiveInfinity;foreach($rr in $routeRects){$area=Overlap $rr $o;if($area -gt 0){$hits.Add([pscustomobject]@{route_rect=$rr.id;obstacle=$o.id;overlap_sf=$area})};$min=[Math]::Min($min,(RectGap $rr $o))};$gaps.Add([pscustomobject]@{obstacle=$o.id;minimum_route_edge_gap_ft=[Math]::Round($min,6)})}
    $length=0.0;for($i=0;$i -lt $points.Count-1;$i++){$length+=[Math]::Abs($points[$i+1].x-$points[$i].x)+[Math]::Abs($points[$i+1].y-$points[$i].y)}
    $kYIntersect=@($routeRects|Where-Object{$_.y -lt ($kLocal.y+$kLocal.h) -and ($_.y+$_.h) -gt $kLocal.y})
    $routeMaxX=($kYIntersect|ForEach-Object{[double]$_.x+[double]$_.w}|Measure-Object -Maximum).Maximum
    $kSignedGap=if($null -eq $routeMaxX){[double]::PositiveInfinity}else{[double]$kLocal.x-[double]$routeMaxX}
    $kGap=@($gaps|Where-Object obstacle -eq 'candidate-kitchen-west-6in')[0].minimum_route_edge_gap_ft
    $minGap=($gaps|Measure-Object minimum_route_edge_gap_ft -Minimum).Minimum
    $variants.Add([pscustomobject]@{start_shift_west_in=[math]::Round($shift*12,3);start_ft=@($points[0].x,$points[0].y);route_waypoints_ft=$points;route_length_ft=[Math]::Round($length,4);route_rectangles_count=$routeRects.Count;candidate_kitchen_edge_clearance_in=[math]::Round($kSignedGap*12,3);minimum_clearance_all_obstacles_in=[math]::Round($minGap*12,3);proxy_intersections=$hits.ToArray();obstacle_clearances=$gaps.ToArray()})
}
$baseline=$variants[0];$threeIn=$variants[1];$sixIn=$variants[2]
$checks=[ordered]@{schema='forever-home.m243-route-start-sensitivity-checks.v1';result='pass';check_count=14;checks=[ordered]@{
    selected_d_hash_matches=($actual.selected_d -eq $expected.selected_d)
    m242_candidate_hash_matches=($actual.m242 -eq $expected.m242)
    M215_result_matches_pinned_replay=($actual.m215_report -eq $expected.m215_report)
    M228_coordinate_frame_hash_matches=($actual.m228 -eq $expected.m228)
    route_generator_hash_matches=($actual.m215_script -eq $expected.m215_script)
    upstream_geometry_generators_pinned=($actual.m213_script -eq $expected.m213_script -and $actual.m186_script -eq $expected.m186_script)
    source_route_contract_passed=($m215.checks.passed -eq 12 -and $m186.checks.passed -eq 31)
    baseline_route_overlaps_shifted_kitchen_by_two_inches=(@($baseline.proxy_intersections|Where-Object obstacle -eq 'candidate-kitchen-west-6in').Count -gt 0 -and [math]::Abs($baseline.candidate_kitchen_edge_clearance_in+2) -lt 0.001)
    three_in_start_move_clears_but_is_under_reserve=(@($threeIn.proxy_intersections).Count -eq 0 -and [math]::Abs($threeIn.candidate_kitchen_edge_clearance_in-1) -lt 0.001 -and $threeIn.minimum_clearance_all_obstacles_in -lt 3)
    six_in_start_move_meets_three_in_proxy_reserve=(@($sixIn.proxy_intersections).Count -eq 0 -and [math]::Abs($sixIn.candidate_kitchen_edge_clearance_in-4) -lt 0.001 -and $sixIn.minimum_clearance_all_obstacles_in -ge 3)
    path_after_start_is_unchanged=(@(Compare-Object @($m215.route_waypoints_ft|Select-Object -Skip 1|ForEach-Object {"$($_.x),$($_.y)"}) @($sixIn.route_waypoints_ft|Select-Object -Skip 1|ForEach-Object {"$($_.x),$($_.y)"})).Count -eq 0)
    endpoint_caps_are_checked=($baseline.route_rectangles_count -eq 9 -and $threeIn.route_rectangles_count -eq 9 -and $sixIn.route_rectangles_count -eq 9)
    selected_d_unchanged=((Hash $selectedPath) -eq $expected.selected_d)
}}
if(@($checks.checks.Values|Where-Object{$_ -ne $true}).Count -gt 0){$checks.result='fail';throw "M243 checks failed: $(ConvertTo-Json $checks -Depth 10)"}
$report=[ordered]@{
    schema='forever-home.m243-route-start-sensitivity.v1'
    status='pass; analysis-only path adjustment; not selected'
    source_hashes_sha256=$actual
    candidate_kitchen_translation_west_ft=0.5
    route_width_in=$m215.route_width_in
    route_grid_step_ft=0.25
    candidate_route_start_old_ft=@($oldStart.x,$oldStart.y)
    variants=$variants.ToArray()
    interpretation=@('With the 6-in west kitchen translation from M242, the fixed M215 start cap overlaps the candidate kitchen block by 2 in. Moving the route start west by 3 in removes overlap but leaves only 1 in clearance to the kitchen, below the M215 study reserve.',"A 6-in start adjustment, on the existing 0.25-ft grid, gives 4 in clearance to the moved kitchen and a 3-in minimum gap to the full pinned obstacle set. The 33.5-ft centerline retains the rest of M215's path and clears the checked proxies.",'The adjusted route and kitchen remain unselected schematic comparisons. The 3-in gap is an M215 analytical screen, not a code or accessibility requirement. The route does not define a door/opening or verify physical wall/finish clearance.')
    limitations=@('Route search is limited to this single M215 path with two route-start sensitivities; it is not an exhaustive reroute search.','The kitchen shift and route start are unselected proxies. Quarter-foot is an existing M186 analysis resolution, not a design dimension.','No room, wall, door, furniture, fixture, service or selected-D geometry changed. West A remains protected; B and M-06 remain unassigned.','No code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.')
}
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm243-report.json'),(ConvertTo-Json -InputObject $report -Depth 20)+"`r`n",$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm243-checks.json'),(ConvertTo-Json -InputObject $checks -Depth 14)+"`r`n",$utf8)
Write-Output "PASS: M243 $($checks.check_count)/$($checks.check_count); 3-in start shift leaves 1 in to kitchen, 6-in shift leaves 4 in and preserves the 3-in overall proxy reserve."
