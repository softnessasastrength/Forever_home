param(
    [string]$OutputDirectory='Architecture/M207_Pantry_Edge_Sensitivity_2026-10-31/artifacts-v4',
    [string]$ScratchPrefix='M207'
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
 [pscustomobject]@{id='current';pantry_x=11.8333333333333;pantry_y=16.5;dining_shift_x=0.0;shared_kitchen_edge_ft=0.0},
 [pscustomobject]@{id='north_edge_30in';pantry_x=11.0;pantry_y=14.0;dining_shift_x=0.0;shared_kitchen_edge_ft=2.5},
 [pscustomobject]@{id='north_edge_36in';pantry_x=10.5;pantry_y=14.0;dining_shift_x=-0.5;shared_kitchen_edge_ft=3.0},
 [pscustomobject]@{id='east_edge_south';pantry_x=13.5;pantry_y=0.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0},
 [pscustomobject]@{id='east_edge_mid';pantry_x=13.5;pantry_y=4.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0},
 [pscustomobject]@{id='east_edge_north';pantry_x=13.5;pantry_y=8.0;dining_shift_x=0.0;shared_kitchen_edge_ft=6.0}
)
'@
if(-not $scriptText.Contains($oldCases)){throw 'M206 case block changed; refusing M207 transform.'}
$scriptText=$scriptText.Replace($oldCases,$newCases)
$scriptText=$scriptText.Replace('m206','m207').Replace('M206','M207')
$scriptText=$scriptText.Replace('Three 5 x 6 ft specification-sized M-04 test placements compare the current position with two positions directly north of the candidate kitchen;', 'Six 5 x 6 ft specification-sized M-04 placements compare the current position, two north-edge cases and three east-edge cases around the candidate kitchen;')
$scriptText=$scriptText.Replace('Baseline, north-edge 30-in shared-wall and north-edge 36-in shared-wall positions retain the specified 5 x 6 ft block.', 'All six current/north/east edge positions retain the specified 5 x 6 ft block.')
$scriptText=$scriptText.Replace('pass=($runs.Count-eq3-and@','pass=($runs.Count-eq6-and@')
$scriptText=$scriptText.Replace("three_spec_size_pantry_cases_tested", "six_spec_size_pantry_cases_tested")
$scriptText=$scriptText.Replace("every_M186_contract_passes", "M186_contract_passes_or_rejects_start_gate")
$oldM186Condition='pass=(@($runs|Where-Object{$_.checks_passed-ne$_.checks_total}).Count-eq0);'
$newM186Condition='pass=(@($runs|Where-Object{($_.checks_passed-ne$_.checks_total)-and-not($_.checks_passed-eq28-and$_.checks_total-eq29-and$_.reachable_nodes-eq0-and$_.failed_M186_check_ids.Count-eq1-and$_.failed_M186_check_ids[0]-eq''start_and_goal_nodes_clear'')}).Count-eq0);'
$scriptText=$scriptText.Replace($oldM186Condition,$newM186Condition)
$scriptText=$scriptText.Replace("All three modified M186 searches pass their full route-search contracts.", "Each M186 search either passes its full contract or is explicitly rejected because the pantry blocks the fixed route start/goal gate before grid expansion.")
$oldRunPrefix='$runs.Add([pscustomobject]@{case=$c.id;'
$newRunPrefix='$runs.Add([pscustomobject]@{case=$c.id;start_goal_gate_clear=[bool](@($r.checks.items|Where-Object id -eq ''start_and_goal_nodes_clear''|Where-Object pass).Count-eq1);failed_M186_check_ids=@($r.checks.items|Where-Object{-not $_.pass}|ForEach-Object id);'
if(-not $scriptText.Contains($oldRunPrefix)){throw 'M206 case-result schema changed; refusing M207 update.'}
$scriptText=$scriptText.Replace($oldRunPrefix,$newRunPrefix)
$scriptText=$scriptText.Replace('These three positions are schematic samples in the 40 x 42 ft test envelope, not an exhaustive pantry-location search.', 'These six positions are schematic edge samples in the 40 x 42 ft test envelope, not an exhaustive pantry-location search.')
$scriptText=$scriptText.Replace("'current position with two positions directly north of the candidate kitchen';", "'current/north/east edge positions around the candidate kitchen';")
$scriptText=$scriptText.Replace("$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m207-generated-'", "$temp=Join-Path (Split-Path (Join-Path $root $baseRel) -Parent) ('m207-generated-'")
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
[IO.File]::WriteAllText((Join-Path $root 'Tools/search_m207_pantry_edge_sensitivity.generated.ps1'),$scriptText,(New-Object Text.UTF8Encoding($false)))
try{
    & (Join-Path $root 'Tools/search_m207_pantry_edge_sensitivity.generated.ps1') -OutputDirectory $OutputDirectory -ScratchPrefix $ScratchPrefix
}finally{
    Remove-Item -LiteralPath (Join-Path $root 'Tools/search_m207_pantry_edge_sensitivity.generated.ps1') -Force -ErrorAction SilentlyContinue
}
