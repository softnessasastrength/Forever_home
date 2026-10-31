param(
    [string]$OutputDirectory='Architecture/M208_Protected_AB_Route_Search_2026-10-31/artifacts-v2',
    [string]$ScratchPrefix='M208-v2'
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$sourcePath=Join-Path $root 'Tools/search_m206_specified_pantry_size_sensitivity.ps1'
$scriptText=[IO.File]::ReadAllText($sourcePath)
$oldCases=@'
$cases=@(
 [pscustomobject]@{id='current';pantry_x=11.8333333333333;pantry_y=16.5;dining_shift_x=0.0;shared_kitchen_edge_ft=0.0},
 [pscustomobject]@{id='north_edge_30in';pantry_x=11.0;pantry_y=14.0;dining_shift_x=0.0;shared_kitchen_edge_ft=2.5},
 [pscustomobject]@{id='north_edge_36in';pantry_x=10.5;pantry_y=14.0;dining_shift_x=-0.5;shared_kitchen_edge_ft=3.0}
)
'@
$newCases=@'
$cases=@(
 [pscustomobject]@{id='east_south_door_west';pantry_x=13.5;pantry_y=0.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0;door_x=2.0},
 [pscustomobject]@{id='east_south_door_center';pantry_x=13.5;pantry_y=0.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0;door_x=5.5},
 [pscustomobject]@{id='east_south_door_east';pantry_x=13.5;pantry_y=0.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0;door_x=9.0},
 [pscustomobject]@{id='east_mid_door_west';pantry_x=13.5;pantry_y=4.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0;door_x=2.0},
 [pscustomobject]@{id='east_mid_door_center';pantry_x=13.5;pantry_y=4.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0;door_x=5.5},
 [pscustomobject]@{id='east_mid_door_east';pantry_x=13.5;pantry_y=4.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0;door_x=9.0}
)
'@
if(-not $scriptText.Contains($oldCases)){throw 'M206 source case block changed; refusing M208 transform.'}
$scriptText=$scriptText.Replace($oldCases,$newCases)
$scriptText=$scriptText.Replace('m206','m208').Replace('M206','M208')
$scriptText=$scriptText.Replace('Three 5 x 6 ft specification-sized M-04 test placements compare the current position with two positions directly north of the candidate kitchen;', 'Six combinations compare two A/B-clear east-edge pantry positions against west, center and east porch-door samples while retaining A and B as route obstacles;')
$scriptText=$scriptText.Replace('Baseline, north-edge 30-in shared-wall and north-edge 36-in shared-wall positions retain the specified 5 x 6 ft block.', 'All six door/pantry combinations retain the specified 5 x 6 ft block.')
$scriptText=$scriptText.Replace('pass=($runs.Count-eq3-and@','pass=($runs.Count-eq6-and@')
$scriptText=$scriptText.Replace("three_spec_size_pantry_cases_tested", "six_spec_size_pantry_cases_tested")
$scriptText=$scriptText.Replace("every_M186_contract_passes", "M186_contract_passes_or_rejects_start_gate")
$oldM186Condition='pass=(@($runs|Where-Object{$_.checks_passed-ne$_.checks_total}).Count-eq0);'
$newM186Condition='pass=(@($runs|Where-Object{($_.checks_passed-ne$_.checks_total)-and-not($_.checks_passed-eq28-and$_.checks_total-eq29-and$_.reachable_nodes-eq0-and$_.failed_M186_check_ids.Count-eq1-and$_.failed_M186_check_ids[0]-eq''start_and_goal_nodes_clear'')}).Count-eq0);'
$scriptText=$scriptText.Replace($oldM186Condition,$newM186Condition)
$scriptText=$scriptText.Replace("All three modified M186 searches pass their full route-search contracts.", "Each M186 search either passes its full contract or is explicitly rejected because the pantry blocks the fixed route start/goal gate before grid expansion.")
$oldRunPrefix='$runs.Add([pscustomobject]@{case=$c.id;'
$newRunPrefix='$runs.Add([pscustomobject]@{case=$c.id;start_goal_gate_clear=[bool](@($r.checks.items|Where-Object id -eq ''start_and_goal_nodes_clear''|Where-Object pass).Count-eq1);failed_M186_check_ids=@($r.checks.items|Where-Object{-not $_.pass}|ForEach-Object id);'
if(-not $scriptText.Contains($oldRunPrefix)){throw 'M206 case-result schema changed; refusing M208 update.'}
$scriptText=$scriptText.Replace($oldRunPrefix,$newRunPrefix)
$scriptText=$scriptText.Replace('$runs.Add([pscustomobject]@{case=$c.id;start_goal_gate_clear=', '$runs.Add([pscustomobject]@{case=$c.id;porch_door_x_ft=$c.door_x;start_goal_gate_clear=')
$oldObstacleSet='`$obstacles=@(`$entry,`$pantry,`$east,`$counter,`$island,`$stools,`$table)+`$chairs+`$pullouts+`$porchWalls'
$newObstacleSet='`$obstacles=@(`$entry,`$pantry,`$west,`$east,`$counter,`$island,`$stools,`$table)+`$chairs+`$pullouts+`$porchWalls'
if(-not $scriptText.Contains($oldObstacleSet)){throw 'M206 obstacle transform changed; refusing to run with A unprotected.'}
$scriptText=$scriptText.Replace($oldObstacleSet,$newObstacleSet)
$oldWalls='$walls="`$porchWalls=@((NewRect186 -0.5 24.5 7 0.5 ''porch-wall-west-of-east-door''),(NewRect186 11.5 24.5 0 0.5 ''porch-wall-east-of-door''))"'
$newWalls='$wallLeftWidth=[Math]::Max(0.0,[double]$c.door_x-2.0);$wallRightX=[double]$c.door_x+2.5;$wallRightWidth=[Math]::Max(0.0,9.0-[double]$c.door_x);$walls="`$porchWalls=@((NewRect186 -0.5 24.5 $wallLeftWidth 0.5 ''porch-wall-west-of-sample''),(NewRect186 $wallRightX 24.5 $wallRightWidth 0.5 ''porch-wall-east-of-sample''))"'
if(-not $scriptText.Contains($oldWalls)){throw 'M206 porch-wall source changed; refusing door sensitivity transform.'}
$scriptText=$scriptText.Replace($oldWalls,$newWalls)
$oldDoor='$door="`$routeDoor=[pscustomobject]@{x=9.0;y=24.5}`n`$expectedDoorX=9.0"'
$newDoor='$doorX=[double]$c.door_x;$door="`$routeDoor=[pscustomobject]@{x=$doorX;y=24.5}`n`$expectedDoorX=$doorX"'
if(-not $scriptText.Contains($oldDoor)){throw 'M206 door source changed; refusing door sensitivity transform.'}
$scriptText=$scriptText.Replace($oldDoor,$newDoor)
$oldEnd='$end="`$routeEnd=[pscustomobject]@{x=9.0;y=27.5}"'
$newEnd='$end="`$routeEnd=[pscustomobject]@{x=$doorX;y=27.5}"'
if(-not $scriptText.Contains($oldEnd)){throw 'M206 route terminus source changed; refusing door sensitivity transform.'}
$scriptText=$scriptText.Replace($oldEnd,$newEnd)
$oldGoal='$goal="AddCheck186 ''goal_is_allowed_porch_face_sample'' (([Math]::Abs(`$routeDoor.x-`$expectedDoorX)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-24.5)-lt1e-8)-and(`$expectedDoorX-eq9.0)) ''Route search ends at the M204 east five-foot door sample.''"'
$newGoal='$goal="AddCheck186 ''goal_is_allowed_porch_face_sample'' (([Math]::Abs(`$routeDoor.x-`$expectedDoorX)-lt1e-8)-and([Math]::Abs(`$routeDoor.y-24.5)-lt1e-8)-and(`$expectedDoorX-ge2.0)-and(`$expectedDoorX-le9.0)) ''Route search ends at one of the bounded M204 five-foot porch-door samples.''"'
if(-not $scriptText.Contains($oldGoal)){throw 'M206 goal check source changed; refusing door sensitivity transform.'}
$scriptText=$scriptText.Replace($oldGoal,$newGoal)
$scriptText=$scriptText.Replace('the east x=9 M204 porch door', 'the tested x=2, 5.5 and 9 ft five-foot porch-door centers')
$oldMethodSuffix='; the tested x=2, 5.5 and 9 ft five-foot porch-door centers, fully open living start, B obstacle, kitchen, island, stool and social use proxies are held constant except the stated 6-in west dining shift in the 36-in case.'
$newMethodSuffix='; the tested x=2, 5.5 and 9 ft five-foot porch-door centers, fully open living start, A/B obstacles, kitchen, island, stool and social-use proxies remain fixed.'
if(-not $scriptText.Contains($oldMethodSuffix)){throw 'M206 route method text changed; refusing inaccurate M208 report.'}
$scriptText=$scriptText.Replace($oldMethodSuffix,$newMethodSuffix)
$scriptText=$scriptText.Replace('All tested pantry footprints remain outside the dining room block; the 6-in dining shift is reported separately.', 'All tested east-edge pantry footprints remain outside the fixed dining room block.')
$oldDecisionRels="'Decisions/2026-10-31_Kitchen_Area_Priority.md','Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md')"
$newDecisionRels="'Decisions/2026-10-31_Kitchen_Area_Priority.md','Decisions/2026-10-31_Kitchen_Living_Opening_Preference.md','Decisions/2026-10-31_M06_West_A_Protection.md')"
if(-not $scriptText.Contains($oldDecisionRels)){throw 'M206 source-binding list changed; refusing to omit A-protection decision.'}
$scriptText=$scriptText.Replace($oldDecisionRels,$newDecisionRels)
$oldBCheck="[pscustomobject]@{id='B_remains_unassigned';pass=([string]`$eastB.status-match'Unassigned'-and@(`$runs|Where-Object M06_B_status -notmatch 'Unassigned').Count-eq0);detail='Pantry-side M-06/B remains an obstacle and unassigned in every case.'},"
$newBCheck="[pscustomobject]@{id='A_and_B_remain_protected';pass=(@(`$runs|Where-Object{[double]`$_.pantry_A_overlap_sf-gt1e-6-or[double]`$_.route_A_union_overlap_sf-gt1e-6}).Count-eq0-and[string]`$eastB.status-match'Unassigned'-and@(`$runs|Where-Object M06_B_status -notmatch 'Unassigned').Count-eq0);detail='A remains a route obstacle and has zero pantry/route overlap; B remains an obstacle and unassigned.'},"
if(-not $scriptText.Contains($oldBCheck)){throw 'M206 B-preservation check changed; refusing to weaken A/B protection.'}
$scriptText=$scriptText.Replace($oldBCheck,$newBCheck)
$scriptText=$scriptText.Replace('These three positions are schematic samples in the 40 x 42 ft test envelope, not an exhaustive pantry-location search.', 'These six combinations are schematic pantry/door samples in the 40 x 42 ft test envelope, not an exhaustive layout search.')
$scriptText=$scriptText.Replace("'current position with two positions directly north of the candidate kitchen';", "'current/north/east edge positions around the candidate kitchen';")
$scriptText=$scriptText.Replace("$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m208-generated-'", "$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m208-generated-'")
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
[IO.File]::WriteAllText((Join-Path $root 'Tools/search_m208_protected_ab_route_search.generated.ps1'),$scriptText,(New-Object Text.UTF8Encoding($false)))
try{
    & (Join-Path $root 'Tools/search_m208_protected_ab_route_search.generated.ps1') -OutputDirectory $OutputDirectory -ScratchPrefix $ScratchPrefix
}finally{
    Remove-Item -LiteralPath (Join-Path $root 'Tools/search_m208_protected_ab_route_search.generated.ps1') -Force -ErrorAction SilentlyContinue
}
