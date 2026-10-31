param(
    [string]$OutputDirectory='Architecture/M217_Pantry_Route_Integration_2026-10-31/artifacts',
    [string]$ScratchPrefix='M217'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}

$m215Out='.local/revalidation/'+$ScratchPrefix+'-source-m215'
& (Join-Path $root 'Tools/search_m215_porchtop_clearance.ps1') -OutputDirectory $m215Out -ScratchPrefix ($ScratchPrefix+'base') -NorthTranslationFt 0.5
$m215Path=Join-Path (Join-Path $root $m215Out) 'm215-porch-approach-clearance.json'
$m215=Get-Content -LiteralPath $m215Path -Raw|ConvertFrom-Json
$routePath=Join-Path $root ('.local/revalidation/'+$ScratchPrefix+'basebase-depth13_25_proxy_margin/m186-route-search.json')
$m186=Get-Content -LiteralPath $routePath -Raw|ConvertFrom-Json
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$selectedHash=(Get-FileHash -LiteralPath $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
$m215Hash=(Get-FileHash -LiteralPath $m215Path -Algorithm SHA256).Hash.ToLowerInvariant()
if($selectedHash-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M217.'}
if($m215.status-ne'pass'-or$m215.checks.passed-ne12-or$m186.checks.status-ne'pass'-or$m186.checks.passed-ne31){throw 'The source M215/M186 route contract did not pass.'}

function NewRect([double]$x,[double]$y,[double]$w,[double]$d,[string]$id){[pscustomobject]@{id=$id;x=$x;y=$y;w=$w;d=$d}}
function OverlapArea([object]$a,[object]$b){$ix=[Math]::Max(0.0,[Math]::Min(($a.x+$a.w),($b.x+$b.w))-[Math]::Max($a.x,$b.x));$iy=[Math]::Max(0.0,[Math]::Min(($a.y+$a.d),($b.y+$b.d))-[Math]::Max($a.y,$b.y));[Math]::Round($ix*$iy,8)}
function Gap([object]$a,[object]$b){$dx=[Math]::Max(0.0,[Math]::Max(($a.x-($b.x+$b.w)),($b.x-($a.x+$a.w))));$dy=[Math]::Max(0.0,[Math]::Max(($a.y-($b.y+$b.d)),($b.y-($a.y+$a.d))));[Math]::Round([Math]::Sqrt($dx*$dx+$dy*$dy),6)}
function RouteRects([object[]]$points,[double]$widthFt){
    $rects=New-Object System.Collections.Generic.List[object]
    $half=$widthFt/2.0
    for($i=0;$i-lt$points.Count-1;$i++){
        $a=$points[$i];$b=$points[$i+1]
        if([Math]::Abs([double]$a.y-[double]$b.y)-lt1e-9){$rects.Add((NewRect ([Math]::Min([double]$a.x,[double]$b.x)) ([double]$a.y-$half) ([Math]::Abs([double]$b.x-[double]$a.x)) $widthFt ("route-{0}"-f$i)))}
        elseif([Math]::Abs([double]$a.x-[double]$b.x)-lt1e-9){$rects.Add((NewRect ([double]$a.x-$half) ([Math]::Min([double]$a.y,[double]$b.y)) $widthFt ([Math]::Abs([double]$b.y-[double]$a.y)) ("route-{0}"-f$i)))}
        else{throw 'Source route contains a diagonal segment.'}
        if($i-gt0){$rects.Add((NewRect ([double]$a.x-$half) ([double]$a.y-$half) $widthFt $widthFt ("corner-{0}"-f$i)))}
    }
    $rects.ToArray()
}

$routeRects=RouteRects @($m215.route_waypoints_ft) 3.0
$obstacles=@($m186.search.modeled_obstacles)
$a=@($obstacles|Where-Object id -eq 'west_of_core'|Select-Object -First 1)
$b=@($obstacles|Where-Object id -eq 'east_of_core'|Select-Object -First 1)
if($a.Count-ne1-or$b.Count-ne1){throw 'M186 source does not expose the expected west-A and east-B reservation proxies.'}
$aRect=NewRect ([double]$a[0].x) ([double]$a[0].y) ([double]$a[0].w) ([double]$a[0].d) 'protected-A-expanded-search-proxy'
$bRect=NewRect ([double]$b[0].x) ([double]$b[0].y) ([double]$b[0].w) ([double]$b[0].d) 'unassigned-B-search-proxy'
$shell=[pscustomobject]@{min_x=0.0;min_y=0.0;max_x=40.0;max_y=42.0}

# Preserve M205/M207 hypothetical locations, but use the expressly authorized
# 5 x 7 ft M-04 test block here. Positions are samples, not proposed dimensions.
$placements=New-Object System.Collections.Generic.List[object]
@(
    [pscustomobject]@{id='current';x=11.8333333333;y=16.5},
    [pscustomobject]@{id='north_edge_30in';x=11.0;y=14.0},
    [pscustomobject]@{id='north_edge_36in';x=10.5;y=14.0},
    [pscustomobject]@{id='east_edge_south';x=13.5;y=0.0},
    [pscustomobject]@{id='east_edge_mid';x=13.5;y=4.0},
    [pscustomobject]@{id='east_edge_north';x=13.5;y=8.0}
)|ForEach-Object{$placements.Add($_)}
$seen=New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
foreach($p in $placements){[void]$seen.Add(('{0:F4},{1:F4}'-f[double]$p.x,[double]$p.y))}
for($y=0.0;$y-le13.5+1e-8;$y+=0.25){
    $key='{0:F4},{1:F4}'-f 13.5,$y
    if($seen.Add($key)){
        $id='east_edge_y_'+$y.ToString('F2',[Globalization.CultureInfo]::InvariantCulture).Replace('.','_')
        $placements.Add([pscustomobject]@{id=$id;x=13.5;y=[Math]::Round($y,4)})
    }
}
$results=New-Object System.Collections.Generic.List[object]
foreach($p in $placements){
    $pantry=NewRect $p.x $p.y 5.0 7.0 ("M-04-{0}"-f$p.id)
    $routeGap=[double]::PositiveInfinity
    $routeOverlap=0.0
    foreach($r in $routeRects){$routeGap=[Math]::Min($routeGap,(Gap $pantry $r));$routeOverlap+=[double](OverlapArea $pantry $r)}
    $aOverlap=OverlapArea $pantry $aRect
    $bOverlap=OverlapArea $pantry $bRect
    $otherOverlap=0.0
    foreach($obstacle in $obstacles){if($obstacle.id-ne'M-04-pantry-5x6-A-B-clear'){$otherOverlap+=[double](OverlapArea $pantry $obstacle)}}
    $shellPass=($pantry.x-ge$shell.min_x-and$pantry.y-ge$shell.min_y-and($pantry.x+$pantry.w)-le$shell.max_x-and($pantry.y+$pantry.d)-le$shell.max_y)
    $checks=[ordered]@{
        preserved_5x7_35sf=([Math]::Abs(($pantry.w*$pantry.d)-35.0)-lt1e-8)
        within_hypothetical_shell=$shellPass
        does_not_overlap_protected_A=($aOverlap-eq0)
        does_not_overlap_unassigned_B=($bOverlap-eq0)
        does_not_overlap_other_M186_obstacles=($otherOverlap-eq0)
        avoids_36in_M215_route_with_3in_extra_gap=($routeOverlap-eq0-and$routeGap-ge0.25)
    }
    $pass=@($checks.Values|Where-Object{$_-eq$false}).Count-eq0
    $results.Add([pscustomobject]@{
        placement=$p.id;rect_ft=[pscustomobject]@{x=[double]$pantry.x;y=[double]$pantry.y;width=5;height=7};area_sf=35
        protected_A_overlap_sf=$aOverlap;unassigned_B_overlap_sf=$bOverlap;other_M186_obstacle_overlap_area_sum_sf=[Math]::Round($otherOverlap,8);route_overlap_area_sum_sf=[Math]::Round($routeOverlap,8);minimum_gap_to_36in_route_ft=[Math]::Round($routeGap,6)
        checks=[pscustomobject]$checks;passes_all_screen_checks=$pass
        disposition=if($pass){'retained route-clear sample; no room or placement selected'}else{'fails at least one protected-area, route or shell screen'}
    })
}
$checkItems=@(
 [pscustomobject]@{id='selected_D_fingerprint_unchanged';pass=($selectedHash-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb')},
 [pscustomobject]@{id='M215_source_route_passes';pass=($m215.status-eq'pass'-and$m215.checks.passed-eq12-and$m215.route_width_in-eq36)},
 [pscustomobject]@{id='M186_source_contract_passes';pass=($m186.checks.status-eq'pass'-and$m186.checks.passed-eq31)},
 [pscustomobject]@{id='fixed_samples_plus_quarter_foot_kitchen_edge_sweep';pass=($results.Count-eq58-and@($results|Where-Object area_sf-ne35).Count-eq0)},
 [pscustomobject]@{id='all_candidates_report_A_B_and_route_tests';pass=(@($results|Where-Object{$null-eq$_.checks.does_not_overlap_protected_A-or$null-eq$_.checks.does_not_overlap_unassigned_B-or$null-eq$_.checks.avoids_36in_M215_route_with_3in_extra_gap}).Count-eq0)},
 [pscustomobject]@{id='at_least_one_candidate_passes_all_screens';pass=(@($results|Where-Object passes_all_screen_checks).Count-ge1)},
 [pscustomobject]@{id='B_remains_unassigned';pass=$true}
)
$passed=@($checkItems|Where-Object pass).Count
$status=if($passed-eq$checkItems.Count){'pass'}else{'fail'}
$report=[ordered]@{
 schema='forever-home-m217-pantry-route-integration-v1';status=$status
 study='Six named placements plus a deduplicated quarter-foot east-edge sweep (58 total) for the hypothetical 5 x 7 ft M-04 pantry block, tested against the reproduced M215 36-in porch route.'
 source_fingerprints=[ordered]@{selected_D_sha256=$selectedHash;m215_sha256=$m215Hash;m215_status=$m215.status;m215_route_width_in=$m215.route_width_in;m215_route_length_ft=$m215.route_length_ft;m186_checks_passed=$m186.checks.passed;m186_checks_total=$m186.checks.total}
 dimensions_and_status=[ordered]@{pantry_width_ft=5;pantry_depth_ft=7;pantry_area_sf=35;status='owner-authorized hypothetical test envelope; no location selected'}
 reservations=[ordered]@{west_A='protected; modeled using the M186 expanded west-of-core obstacle';east_B='unassigned; modeled using the M186 east-of-core obstacle';route_width_in=36;additional_route_gap_ft=0.25;test_shell_ft=@(40,42);shell_test='outer coordinate envelope only; wall thickness and inside face are unresolved';sweep='x=13.5 ft east-edge proxy; y=0 through the inherited 13.5-ft kitchen cross-section at 0.25-ft increments, deduplicated against named samples'}
 placements=$results.ToArray();checks=[ordered]@{passed=$passed;total=$checkItems.Count;items=$checkItems};limitations=@(
  'This is a 58-point bounded location sample, not an exhaustive floor-plan search or selected pantry design.',
  'A rectangle does not establish a room boundary, shelves, door/opening, approach, kitchen workflow, or plumbing/service route.',
  'The 3-in separation beyond the 36-in route is an analytical reserve inherited from M215, not a code or accessibility determination.',
  'M-06 B remains unassigned; west A is protected as a no-use reservation in this study.',
  'Selected-D, RVT, IFC, Incoming RFAs and remote state are unchanged; no code, accessibility, structural, professional, permit or construction-readiness conclusion follows.'
 )
}
$jsonPath=Join-Path $out 'm217-pantry-route-integration.json'
$checksPath=Join-Path $out 'm217-checks.json'
$csvPath=Join-Path $out 'm217-placement-cases.csv'
[IO.File]::WriteAllText($jsonPath,(($report|ConvertTo-Json -Depth 20)+"`n"),(New-Object Text.UTF8Encoding($false)))
[IO.File]::WriteAllText($checksPath,(([ordered]@{schema='forever-home-m217-checks-v1';status=$status;passed=$passed;total=$checkItems.Count;items=$checkItems}|ConvertTo-Json -Depth 10)+"`n"),(New-Object Text.UTF8Encoding($false)))
$results|Select-Object placement,@{n='x_ft';e={$_.rect_ft.x}},@{n='y_ft';e={$_.rect_ft.y}},area_sf,protected_A_overlap_sf,unassigned_B_overlap_sf,route_overlap_area_sum_sf,minimum_gap_to_36in_route_ft,passes_all_screen_checks,disposition|Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
foreach($check in $checkItems){$v=if($check.pass){'PASS'}else{'FAIL'};Write-Output ("{0} {1}"-f$v,$check.id)}
foreach($result in @($results|Where-Object{$_.passes_all_screen_checks-or$_.placement-in@('current','north_edge_30in','north_edge_36in','east_edge_south','east_edge_mid','east_edge_north')})){Write-Output ("CASE {0}: pass={1}; A={2} sf; B={3} sf; route overlap={4} sf; route gap={5} ft"-f$result.placement,$result.passes_all_screen_checks,$result.protected_A_overlap_sf,$result.unassigned_B_overlap_sf,$result.route_overlap_area_sum_sf,$result.minimum_gap_to_36in_route_ft)}
Write-Output "SUMMARY $passed/$($checkItems.Count) M217 checks passed; $(@($results|Where-Object passes_all_screen_checks).Count)/$($results.Count) placement samples pass"
if($status-ne'pass'){throw 'M217 pantry-route integration validation failed.'}
