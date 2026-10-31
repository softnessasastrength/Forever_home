param(
    [string]$OutputDirectory='Architecture/M218_Pantry_Door_Approach_2026-10-31/artifacts',
    [string]$ScratchPrefix='M218'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}

$m217Path=Join-Path $root 'Architecture/M217_Pantry_Route_Integration_2026-10-31/artifacts/m217-pantry-route-integration.json'
$m217Hash=(Get-FileHash -LiteralPath $m217Path -Algorithm SHA256).Hash.ToLowerInvariant()
$m217=Get-Content -LiteralPath $m217Path -Raw|ConvertFrom-Json
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$selectedHash=(Get-FileHash -LiteralPath $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
if($m217.status-ne'pass'-or$m217.checks.passed-ne7-or$m217.placements.Count-ne58){throw 'M217 source candidate/report does not pass its recorded integrity gate.'}
if($selectedHash-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing M218.'}
$candidate=@($m217.placements|Where-Object{$_.placement-eq'east_edge_y_1_25'-and$_.passes_all_screen_checks})
if($candidate.Count-ne1-or$candidate[0].rect_ft.x-ne13.5-or$candidate[0].rect_ft.y-ne1.25){throw 'Expected M217 y=1.25 ft pantry comparison is missing or changed.'}

$m215Out='.local/revalidation/'+$ScratchPrefix+'-source-m215'
& (Join-Path $root 'Tools/search_m215_porchtop_clearance.ps1') -OutputDirectory $m215Out -ScratchPrefix ($ScratchPrefix+'base') -NorthTranslationFt 0.5
$m215Path=Join-Path (Join-Path $root $m215Out) 'm215-porch-approach-clearance.json'
$m215=Get-Content -LiteralPath $m215Path -Raw|ConvertFrom-Json
$m186Path=Join-Path $root ('.local/revalidation/'+$ScratchPrefix+'basebase-depth13_25_proxy_margin/m186-route-search.json')
$m186=Get-Content -LiteralPath $m186Path -Raw|ConvertFrom-Json
if($m215.status-ne'pass'-or$m215.checks.passed-ne12-or$m186.checks.status-ne'pass'-or$m186.checks.passed-ne31){throw 'M215/M186 source route failed its contract.'}

function NewRect([double]$x,[double]$y,[double]$w,[double]$d,[string]$id){[pscustomobject]@{id=$id;x=$x;y=$y;w=$w;d=$d}}
function OverlapArea([object]$a,[object]$b){$ix=[Math]::Max(0.0,[Math]::Min(($a.x+$a.w),($b.x+$b.w))-[Math]::Max($a.x,$b.x));$iy=[Math]::Max(0.0,[Math]::Min(($a.y+$a.d),($b.y+$b.d))-[Math]::Max($a.y,$b.y));[Math]::Round($ix*$iy,8)}
function Gap([object]$a,[object]$b){$dx=[Math]::Max(0.0,[Math]::Max(($a.x-($b.x+$b.w)),($b.x-($a.x+$a.w))));$dy=[Math]::Max(0.0,[Math]::Max(($a.y-($b.y+$b.d)),($b.y-($a.y+$a.d))));[Math]::Round([Math]::Sqrt($dx*$dx+$dy*$dy),6)}
function RouteRects([object[]]$points,[double]$widthFt){$r=New-Object System.Collections.Generic.List[object];$h=$widthFt/2.0;for($i=0;$i-lt$points.Count-1;$i++){$a=$points[$i];$b=$points[$i+1];if([Math]::Abs([double]$a.y-[double]$b.y)-lt1e-9){$r.Add((NewRect ([Math]::Min([double]$a.x,[double]$b.x)) ([double]$a.y-$h) ([Math]::Abs([double]$b.x-[double]$a.x)) $widthFt ("seg-{0}"-f$i)))}elseif([Math]::Abs([double]$a.x-[double]$b.x)-lt1e-9){$r.Add((NewRect ([double]$a.x-$h) ([Math]::Min([double]$a.y,[double]$b.y)) $widthFt ([Math]::Abs([double]$b.y-[double]$a.y)) ("seg-{0}"-f$i)))}else{throw 'M215 route contains a diagonal segment.'};if($i-gt0){$r.Add((NewRect ([double]$a.x-$h) ([double]$a.y-$h) $widthFt $widthFt ("corner-{0}"-f$i)))} };$r.ToArray()}

$pantry=NewRect 13.5 1.25 5.0 7.0 'M-04-y1.25-proposal'
$doorWidth=2.5 # nominal 2 ft 6 in reservation in Kitchen_Dining_Porch_Specs.md
$approachWidth=3.0 # 36-in schematic approach proxy, not a code determination
$doorPositions=@(
 [pscustomobject]@{id='lower';start_y=$pantry.y},
 [pscustomobject]@{id='center';start_y=($pantry.y+$pantry.d-$doorWidth)/2.0},
 [pscustomobject]@{id='upper';start_y=($pantry.y+$pantry.d-$doorWidth)}
)
$obstacles=@($m186.search.modeled_obstacles|Where-Object id-ne'M-04-pantry-5x6-A-B-clear')
$routeRects=RouteRects @($m215.route_waypoints_ft) 3.0
$results=New-Object System.Collections.Generic.List[object]
foreach($position in $doorPositions){
 $opening=[pscustomobject]@{x=$pantry.x;y=[double]$position.start_y;width_ft=$doorWidth;wall='west shared edge; kitchen side assumed'}
 $centerY=[double]$opening.y+$doorWidth/2.0
 $approach=NewRect ($pantry.x-$approachWidth) ($centerY-$approachWidth/2.0) $approachWidth $approachWidth ("approach-{0}"-f$position.id)
 $approachObstacleOverlap=0.0;$approachRouteOverlap=0.0
 foreach($o in $obstacles){$approachObstacleOverlap+=[double](OverlapArea $approach $o)}
 foreach($r in $routeRects){$approachRouteOverlap+=[double](OverlapArea $approach $r)}
 $swingIntoKitchen=NewRect ($pantry.x-$doorWidth) ([double]$opening.y) $doorWidth $doorWidth ("swing-kitchen-{0}"-f$position.id)
 $swingIntoPantry=NewRect $pantry.x ([double]$opening.y) $doorWidth $doorWidth ("swing-pantry-{0}"-f$position.id)
 foreach($direction in @('kitchen','pantry')){
    $swing=if($direction-eq'kitchen'){$swingIntoKitchen}else{$swingIntoPantry}
    $swingObstacleOverlap=0.0;$swingRouteOverlap=0.0
    foreach($o in $obstacles){$swingObstacleOverlap+=[double](OverlapArea $swing $o)}
    foreach($r in $routeRects){$swingRouteOverlap+=[double](OverlapArea $swing $r)}
    $swingApproachOverlap=OverlapArea $swing $approach
    $checks=[ordered]@{
      '30in_opening_fits_7ft_pantry_edge'=($opening.y-ge$pantry.y-and($opening.y+$opening.width_ft)-le($pantry.y+$pantry.d))
      '36in_approach_proxy_clear_of_modeled_obstacles'=($approachObstacleOverlap-eq0-and$approachRouteOverlap-eq0)
      swing_proxy_clear_of_modeled_obstacles=($swingObstacleOverlap-eq0-and$swingRouteOverlap-eq0)
      B_unassigned_and_clear=([string]$m217.reservations.east_B -like '*unassigned*' -and $approachObstacleOverlap-eq0)
      protected_A_unchanged=([string]$m217.reservations.west_A -like '*protected*')
    }
    $pass=@($checks.Values|Where-Object{$_-eq$false}).Count-eq0
    $results.Add([pscustomobject]@{
      position=$position.id;swing_into=$direction;door_opening=[pscustomobject]@{width_ft=$doorWidth;start_y_ft=[double]$opening.y;end_y_ft=[double]($opening.y+$doorWidth);center_y_ft=$centerY}
      assumed_approach_rect_ft=[pscustomobject]@{x=$approach.x;y=$approach.y;width=$approach.w;depth=$approach.d}
      assumed_30in_swing_sweep_bbox_ft=[pscustomobject]@{x=$swing.x;y=$swing.y;width=$swing.w;depth=$swing.d}
      approach_obstacle_overlap_area_sum_sf=[Math]::Round($approachObstacleOverlap,8);approach_route_overlap_area_sum_sf=[Math]::Round($approachRouteOverlap,8)
      swing_obstacle_overlap_area_sum_sf=[Math]::Round($swingObstacleOverlap,8);swing_route_overlap_area_sum_sf=[Math]::Round($swingRouteOverlap,8)
      swing_approach_overlap_sf=$swingApproachOverlap;checks=[pscustomobject]$checks;passes_static_proxy_screen=$pass
      limitation=if($direction-eq'pantry'){'Shelving/storage conflict is not modeled.'}else{'Door swing occupies part of the assumed kitchen-side approach while open.'}
    })
 }
}
$caseSchemaValid=$true
foreach($case in $results){if(@($case.checks.PSObject.Properties).Count-ne5-or@($case.checks.PSObject.Properties|Where-Object{$_.Value -isnot [bool]}).Count-ne0){$caseSchemaValid=$false}}
$checkItems=@(
 [pscustomobject]@{id='M217_candidate_fingerprint_and_pass_status';pass=($m217.status-eq'pass'-and$m217Hash-eq'7e436b9a7d805e2803a1148fbd2bdacad017f86b7d444f7cbe77cbde30226853')},
 [pscustomobject]@{id='M215_M186_source_contracts';pass=($m215.checks.passed-eq12-and$m186.checks.passed-eq31)},
 [pscustomobject]@{id='three_positions_both_swing_directions_tested';pass=($results.Count-eq6-and@($results|Where-Object{!$_.passes_static_proxy_screen}).Count-eq0)},
 [pscustomobject]@{id='every_case_reports_five_boolean_checks';pass=$caseSchemaValid},
 [pscustomobject]@{id='kitchen_swing_overlap_with_approach_reported';pass=(@($results|Where-Object{$_.swing_into-eq'kitchen'-and$_.swing_approach_overlap_sf-le0}).Count-eq0)},
 [pscustomobject]@{id='M06_B_remains_unassigned';pass=([string]$m217.reservations.east_B -like '*unassigned*')}
)
$passed=@($checkItems|Where-Object pass).Count
$status=if($passed-eq$checkItems.Count){'pass'}else{'fail'}
$report=[ordered]@{
 schema='forever-home-m218-pantry-door-approach-v1';status=$status
 study='Three 30-in pantry opening positions and two assumed swing directions tested against the M217 y=1.25-ft pantry proposal and reproduced M215 route.'
 source_fingerprints=[ordered]@{selected_D_sha256=$selectedHash;m217_sha256=$m217Hash;m215_sha256=(Get-FileHash -LiteralPath $m215Path -Algorithm SHA256).Hash.ToLowerInvariant();m215_checks_passed=$m215.checks.passed;m186_checks_passed=$m186.checks.passed}
 inputs=[ordered]@{pantry_rect_ft=@(13.5,1.25,5,7);pantry_size_source_conflict='room studies 5x7 ft; kitchen specification 5x6 ft';nominal_opening_width_ft=2.5;door_leaf_width_assumption_ft=2.5;approach_proxy_ft=@(3,3);test_shell_outer_ft=@(40,42);location_status='proposal only'}
 results=$results.ToArray();checks=[ordered]@{passed=$passed;total=$checkItems.Count;items=$checkItems}
 limitations=@(
  'The 2 ft 6 in value is a documented nominal pantry-door reservation; equating it to a door leaf width is an explicit screening assumption.',
  'A 30 x 30 in rectangle bounds an assumed 90-degree door swing; it is not an exact swept arc, hinge/jamb model, rough opening or selected door.',
  'The 36 x 36 in kitchen-side approach is an analytical proxy, not a code or accessibility determination.',
  'A pantry swing has no shelf, storage or human-body model; a kitchen swing overlaps its assumed approach while open.',
  'Wall construction, finished clear width, thresholds, kitchen workflow, actual opening location and MEP services remain unresolved. M-06 B stays unassigned. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.'
 )
}
$jsonPath=Join-Path $out 'm218-pantry-door-approach.json';$checksPath=Join-Path $out 'm218-checks.json';$csvPath=Join-Path $out 'm218-door-options.csv'
[IO.File]::WriteAllText($jsonPath,(($report|ConvertTo-Json -Depth 20)+"`n"),(New-Object Text.UTF8Encoding($false)))
[IO.File]::WriteAllText($checksPath,(([ordered]@{schema='forever-home-m218-checks-v1';status=$status;passed=$passed;total=$checkItems.Count;items=$checkItems}|ConvertTo-Json -Depth 10)+"`n"),(New-Object Text.UTF8Encoding($false)))
$results|Select-Object position,swing_into,@{n='opening_start_y_ft';e={$_.door_opening.start_y_ft}},@{n='approach_obstacle_overlap_sf';e={$_.approach_obstacle_overlap_area_sum_sf}},@{n='swing_obstacle_overlap_sf';e={$_.swing_obstacle_overlap_area_sum_sf}},swing_approach_overlap_sf,swing_route_overlap_area_sum_sf,passes_static_proxy_screen,limitation|Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
foreach($check in $checkItems){$v=if($check.pass){'PASS'}else{'FAIL'};Write-Output ("{0} {1}"-f$v,$check.id)}
foreach($case in $results){Write-Output ("CASE {0}/{1}: clear={2}; swing/approach={3} sf; external obstacle overlap={4} sf"-f$case.position,$case.swing_into,$case.passes_static_proxy_screen,$case.swing_approach_overlap_sf,$case.swing_obstacle_overlap_area_sum_sf)}
Write-Output "SUMMARY $passed/$($checkItems.Count) M218 checks passed; $(@($results|Where-Object passes_static_proxy_screen).Count)/$($results.Count) door options clear modeled obstacles"
if($status-ne'pass'){throw 'M218 pantry door/approach validation failed.'}
