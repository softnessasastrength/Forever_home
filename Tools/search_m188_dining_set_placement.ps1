param([string]$OutputDirectory='Architecture/M188_Dining_Set_Placement_2026-10-31/artifacts',[string]$ScratchPrefix='M188')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}
$base=Join-Path $root 'Tools/search_m186_public_route.ps1'
$source=[IO.File]::ReadAllText($base)
$needle='$obstacles=@($entry,$pantry,$west,$east,$counter,$island,$stools,$halfwall,$wallReturn,$table)+$chairs+$porchWalls'
if(([regex]::Matches($source,[regex]::Escape($needle))).Count-ne1){throw 'M186 obstacle declaration changed; refusing an unreviewed text transformation.'}
$cases=@(
 [pscustomobject]@{id='baseline';dx=0;dy=0},
 [pscustomobject]@{id='east_1ft';dx=1;dy=0},
 [pscustomobject]@{id='west_1ft';dx=-1;dy=0},
 [pscustomobject]@{id='north_1ft';dx=0;dy=1},
 [pscustomobject]@{id='south_1ft';dx=0;dy=-1}
)
$temp=Join-Path (Split-Path $base -Parent) ('m188-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
$rows=New-Object System.Collections.Generic.List[object]
try {
 foreach($c in $cases){
  $dx=[double]$c.dx;$dy=[double]$c.dy
  $snippet=@"
`$table=NewRect186 $(3+$dx) $(17.5+$dy) 5 3 'dining-table'
`$chairs=@((NewRect186 $(3.5+$dx) $(15.8333333333+$dy) 1.5 1.6666666667 'south-chair-1'),(NewRect186 $(6+$dx) $(15.8333333333+$dy) 1.5 1.6666666667 'south-chair-2'),(NewRect186 $(1.3333333333+$dx) $(17.5+$dy) 1.6666666667 1.5 'west-chair-1'),(NewRect186 $(1.3333333333+$dx) $(19+$dy) 1.6666666667 1.5 'west-chair-2'))
`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$halfwall,`$wallReturn,`$table)+`$chairs+`$porchWalls
"@
  [IO.File]::WriteAllText($temp,$source.Replace($needle,$snippet.TrimEnd()),(New-Object Text.UTF8Encoding($false)))
  $sub='.local/revalidation/'+$ScratchPrefix+'-'+$c.id
  $full=Join-Path $root $sub
  if((Test-Path -LiteralPath $full)-and @(Get-ChildItem -LiteralPath $full -Force).Count-gt0){throw "Refusing to overwrite scratch directory: $full"}
  & $temp -OutputDirectory $sub
  $report=Get-Content (Join-Path $full 'm186-route-search.json') -Raw|ConvertFrom-Json
  $gap=@($report.search.minimum_edge_gap_by_obstacle|Where-Object obstacle -eq 'dining-table')[0].minimum_route_edge_gap_ft
  $minX=1.3333333333+$dx;$maxX=8+$dx;$minY=15.8333333333+$dy;$maxY=20.5+$dy
  $inDining=($minX-ge0-and$minY-ge14-and$maxX-le11-and$maxY-le24)
  $rows.Add([pscustomobject]@{case=$c.id;translation_x_ft=$dx;translation_y_ft=$dy;path_found=[bool]$report.search.path_found;route_length_ft=$report.search.route_length_ft;turn_count=$report.search.route_turn_count;reachable_nodes=$report.search.centerline_bounds.reached_node_count;nearest_door_manhattan_ft=$report.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;route_to_table_edge_gap_ft=$gap;table_and_chairs_inside_11_by_10_test_block=$inDining;dining_set_unchanged=$true;unassigned_route_length_ft=$report.search.centerline_zone_lengths_ft.unassigned_ft;limitation='Whole dining set translated as an analysis proposal; physical wall/door and chair-pullback operation remain unmodeled.'})
 }
} finally {if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}
$selected='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$selectedHash=(Get-FileHash (Join-Path $root $selected) -Algorithm SHA256).Hash.ToLowerInvariant()
$report=[ordered]@{schema='forever-home-m188-dining-set-placement-v1';status='complete_unapproved_layout_sensitivity';method='Reruns M186 with the documented 36x60-in table and four 18x20-in chair proxies translated as one rigid group by one foot along a single axis.';m186_source_sha256=(Get-FileHash $base -Algorithm SHA256).Hash.ToLowerInvariant();selected_d_sha256=$selectedHash;cases=$rows.ToArray();limitations=@('One-foot translations are proposal coordinates, not owner-selected dimensions.','All chair/table proxies move together and keep their M186 arrangement; alternative seating layouts were not tested.','A restored sampled route still requires a real door/opening, physical walls, chair operation and project review.','M-06/B remains unassigned; no fixture, clearance, approach or services are selected.','No Revit/IFC, selected-D baseline, Incoming RFA or remote state is modified.','No code, accessibility, structural, professional, permit or construction-readiness claim is made.')}
$utf8=New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm188-dining-placement.json'),(($report|ConvertTo-Json -Depth 30)+"`n"),$utf8)
$rows|Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath (Join-Path $out 'm188-dining-placement.csv')
$checks=@([pscustomobject]@{id='five_cases';pass=($rows.Count-eq5)},[pscustomobject]@{id='baseline_matches_m186';pass=([bool]$rows[0].path_found-eq[bool]((Get-Content (Join-Path $root 'Architecture/M186_Multiturn_Route_Search_2026-10-31/artifacts/m186-route-search.json') -Raw|ConvertFrom-Json).search.path_found))},[pscustomobject]@{id='same_table_chair_dimensions';pass=(@($rows|Where-Object {-not$_.dining_set_unchanged}).Count-eq0)},[pscustomobject]@{id='all_dining_bodies_inside_test_block';pass=(@($rows|Where-Object {-not$_.table_and_chairs_inside_11_by_10_test_block}).Count-eq0)},[pscustomobject]@{id='selected_D_unchanged';pass=($selectedHash-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb')},[pscustomobject]@{id='B_unassigned';pass=$true})
$checkReport=[ordered]@{status=if(@($checks|Where-Object {-not$_.pass}).Count-eq0){'pass'}else{'fail'};passed=@($checks|Where-Object pass).Count;total=$checks.Count;items=$checks}
[IO.File]::WriteAllText((Join-Path $out 'm188-checks.json'),(($checkReport|ConvertTo-Json -Depth 20)+"`n"),$utf8)
if($checkReport.status-ne'pass'){throw 'M188 validation checks failed.'}
Write-Output "M188 $($checkReport.status); $($checkReport.passed)/$($checkReport.total); $(@($rows|Where-Object path_found).Count)/$($rows.Count) table placements restore a sampled route."
