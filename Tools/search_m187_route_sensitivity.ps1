param([string]$OutputDirectory='Architecture/M187_Route_Sensitivity_2026-10-31/artifacts',[string]$ScratchPrefix='M187')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}
$base=Join-Path $root 'Tools/search_m186_public_route.ps1'
$baseText=[IO.File]::ReadAllText($base)
$needle='$obstacles=@($entry,$pantry,$west,$east,$counter,$island,$stools,$halfwall,$wallReturn,$table)+$chairs+$porchWalls'
if(([regex]::Matches($baseText,[regex]::Escape($needle))).Count-ne1){throw 'M186 obstacle declaration changed; refusing an unreviewed text transformation.'}
$cases=@(
 [pscustomobject]@{id='assumed_stool_use';remove=@('assumed-stool-use-proxy');meaning='Removes the assumed 24-in stool occupancy proxy only.'},
 [pscustomobject]@{id='east_B_search_window';remove=@('east_of_core');meaning='Relaxes the reserved unassigned east/B search window only; does not assign B.'},
 [pscustomobject]@{id='west_diagnostic';remove=@('west_of_core');meaning='Removes the already-blocked west diagnostic rectangle only.'},
 [pscustomobject]@{id='pantry';remove=@('M-04-pantry');meaning='Removes the pantry room-block proxy only.'},
 [pscustomobject]@{id='island';remove=@('island');meaning='Removes the kitchen island proxy only.'},
 [pscustomobject]@{id='halfwall_and_return';remove=@('half-wall','half-wall-return');meaning='Removes the half-wall and return proxies only.'},
 [pscustomobject]@{id='entry';remove=@('M-05-entry');meaning='Removes the entry room-block proxy only.'},
 [pscustomobject]@{id='dining_set';remove=@('dining-table','south-chair-1','south-chair-2','west-chair-1','west-chair-2');meaning='Removes table and four stationary chair-body proxies together.'},
 [pscustomobject]@{id='perimeter_casework';remove=@('perimeter-run');meaning='Removes the perimeter cabinet-run proxy only.'}
)
$baseline=Get-Content (Join-Path $root 'Architecture/M186_Multiturn_Route_Search_2026-10-31/artifacts/m186-route-search.json') -Raw|ConvertFrom-Json
$casesOut=New-Object System.Collections.Generic.List[object]
$temp=Join-Path (Split-Path $base -Parent) ('m187-generated-'+[guid]::NewGuid().ToString('N')+'.ps1')
try {
 foreach($case in $cases){
  $line=$needle+"`n`$obstacles=@(`$obstacles|Where-Object {`$_.id -notin @("+(@($case.remove|ForEach-Object {"'$_'"}) -join ',')+")})"
  [IO.File]::WriteAllText($temp,$baseText.Replace($needle,$line),(New-Object Text.UTF8Encoding($false)))
  $sub=Join-Path $root ('.local/revalidation/'+$ScratchPrefix+'-'+$case.id)
  if((Test-Path -LiteralPath $sub)-and @(Get-ChildItem -LiteralPath $sub -Force).Count-gt0){throw "Refusing to overwrite sensitivity scratch directory: $sub"}
  & $temp -OutputDirectory ('.local/revalidation/'+$ScratchPrefix+'-'+$case.id)
  $r=Get-Content (Join-Path $sub 'm186-route-search.json') -Raw|ConvertFrom-Json
  $casesOut.Add([ordered]@{relaxation=$case.id;removed_proxy_ids=@($case.remove);meaning=$case.meaning;path_found=[bool]$r.search.path_found;route_length_ft=$r.search.route_length_ft;turn_count=$r.search.route_turn_count;expanded_nodes=$r.search.centerline_bounds.expanded_nodes;reachable_nodes=$r.search.centerline_bounds.reached_node_count;nearest_door_manhattan_ft=$r.search.centerline_bounds.nearest_reachable_to_porch_door.distance_manhattan_ft;remaining_blocked_frontier=@($r.search.centerline_bounds.blocked_frontier_edges|Select-Object -First 5);interpretation='Single-proxy sensitivity only. Any route is an analysis-grid candidate with that proxy removed, not a selected or validated layout.'})
 }
} finally {if(Test-Path -LiteralPath $temp){Remove-Item -LiteralPath $temp -Force}}
$checks=New-Object System.Collections.Generic.List[object]
function Check187([string]$id,[bool]$pass,[string]$detail){$checks.Add([ordered]@{id=$id;pass=$pass;detail=$detail})}
Check187 'baseline_no_path' (-not[bool]$baseline.search.path_found) 'The retained combined-constraint M186 baseline has no sampled route.'
Check187 'nine_independent_cases' ($casesOut.Count-eq9) 'Nine declared one-at-a-time relaxations were evaluated.'
Check187 'selected_D_hash_unchanged' ((Get-FileHash (Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json') -Algorithm SHA256).Hash.ToLowerInvariant()-eq$baseline.selected_d_sha256) 'The selected-D source hash matches M186.'
$bCheck=@($baseline.checks.items|Where-Object id -eq 'm06_b_unassigned')
Check187 'B_still_unassigned' ($bCheck.Count-eq1-and[bool]$bCheck[0].pass) 'M186 asserts that east/B remains unassigned.'
Check187 'all_outputs_collected' ($casesOut.Count-eq9) 'Every declared run produced a parsable report.'
foreach($c in $casesOut){Check187 ('result:'+ $c.relaxation) ($c.expanded_nodes-gt0-and$c.reachable_nodes-gt0) 'Sensitivity search ran and returned a reachable region.'}
$status='pass';if(@($checks|Where-Object {-not$_.pass}).Count-gt0){$status='fail'}
$report=[ordered]@{schema='forever-home-m187-route-sensitivity-v1';status=$status;method='Replays M186 nine times, each time removing only the listed obstacle proxy or the explicitly grouped dining set, then records route reachability and remaining frontier.';baseline_m186_sha256=(Get-FileHash (Join-Path $root 'Architecture/M186_Multiturn_Route_Search_2026-10-31/artifacts/m186-route-search.json') -Algorithm SHA256).Hash.ToLowerInvariant();selected_d_sha256=$baseline.selected_d_sha256;baseline_path_found=[bool]$baseline.search.path_found;analysis_grid_step_ft=$baseline.search.grid_step_ft;route_width_in=$baseline.search.route_width_in;cases=$casesOut.ToArray();checks=[ordered]@{status=$status;passed=@($checks|Where-Object pass).Count;total=$checks.Count;items=$checks.ToArray()};limitations=@('This sensitivity relaxes analysis proxies, not actual geometry. A restored path does not authorize removing a room, furniture or M-06 reservation.','An east/B relaxation does not assign B or establish fixture, clearance, privacy, approach or service feasibility.','The finite quarter-foot grid and rectangular proxies do not prove continuous route impossibility or usability.','No Revit/IFC model, selected-D baseline or source family is modified.','No code, accessibility, structural, professional, permit or construction-readiness claim is made.')}
$utf8=New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm187-route-sensitivity.json'),(($report|ConvertTo-Json -Depth 40)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm187-checks.json'),(($report.checks|ConvertTo-Json -Depth 40)+"`n"),$utf8)
$csvRows=New-Object System.Collections.Generic.List[object]
foreach($case in $casesOut){$csvRows.Add([pscustomobject]@{relaxation=$case['relaxation'];path_found=$case['path_found'];route_length_ft=$case['route_length_ft'];turn_count=$case['turn_count'];reachable_nodes=$case['reachable_nodes'];nearest_door_manhattan_ft=$case['nearest_door_manhattan_ft'];meaning=$case['meaning']})}
$csvRows|Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath (Join-Path $out 'm187-route-sensitivity.csv')
if($status-ne'pass'){throw 'M187 validation checks failed.'}
Write-Output "M187 $status; $(@($checks|Where-Object pass).Count)/$($checks.Count) checks; $(@($casesOut|Where-Object path_found).Count)/$($casesOut.Count) relaxations restore a sampled path."
