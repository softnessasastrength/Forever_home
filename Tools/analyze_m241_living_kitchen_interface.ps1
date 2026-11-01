param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M241_Living_Kitchen_Interface_2026-10-31/artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$studyPath = Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m228Path = Join-Path $repoRoot 'Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts/m228-west-a-dining-connection.json'
$m232Path = Join-Path $repoRoot 'Architecture/M232_West_A_Hall_Adjacency_Sensitivity_2026-10-31/artifacts/m232-report.json'
$decisionPath = Join-Path $repoRoot 'Decisions/2026-10-31_M01_Living_Translation_Test.md'
$expected = @{
    selected_d = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    m228 = 'f4ab50fd02e4d71e434c4e4c83d63fe8d20b580810d7118a234bc4b2da8119ff'
    m232 = '41adf2b56df9a6b2ff318dc98609dd1dd9636445bb1c6dcdce0c864c05100651'
    owner_decision = 'ef07fc60f94ec61a62a0cae486fbd18be040a02c1659fa1be35f341be369ec99'
}
function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-Overlap([double]$A0,[double]$A1,[double]$B0,[double]$B1) { [math]::Max(0.0, [math]::Min($A1,$B1)-[math]::Max($A0,$B0)) }
function Get-Rect($Room) {
    [pscustomobject]@{ id=[string]$Room.id; x=[double]$Room.x; y=[double]$Room.y; w=[double]$Room.w; h=[double]$(if($Room.d){$Room.d}else{$Room.h}) }
}
$actual = @{
    selected_d = Get-Sha256 $studyPath
    m228 = Get-Sha256 $m228Path
    m232 = Get-Sha256 $m232Path
    owner_decision = Get-Sha256 $decisionPath
}
foreach($key in $expected.Keys) { if($actual[$key] -ne $expected[$key]) { throw "Pinned $key SHA256 mismatch: $($actual[$key])" } }
$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$m228 = Get-Content -LiteralPath $m228Path -Raw | ConvertFrom-Json
$m232 = Get-Content -LiteralPath $m232Path -Raw | ConvertFrom-Json
$decision = Get-Content -LiteralPath $decisionPath -Raw
if($decision -notmatch 'Test 6 in east move' -or $m232.selected_d_modified -ne $false) { throw 'Owner direction or selected-D preservation does not match the pinned study.' }
$rooms = @{}
foreach($room in $study.plans.main) { $rooms[[string]$room.id] = Get-Rect $room }
$living = $rooms['M-01']; $hall = $rooms['M-05']; $kitchen = $rooms['M-02']
$candidateArray = @($m232.candidate.proposed_living_rect_ft)
$candidate = [pscustomobject]@{ id='M-01 + 6 in east'; x=[double]$candidateArray[0]; y=[double]$candidateArray[1]; w=[double]$candidateArray[2]; h=[double]$candidateArray[3] }
$diningArray = @($m228.dining_candidate.rect_ft)
$dining = [pscustomobject]@{ id='M228 dining proposal'; x=[double]$diningArray[0]; y=[double]$diningArray[1]; w=[double]$diningArray[2]; h=[double]$diningArray[3] }
$tol = 0.00001
function Measure-Interfaces($L) {
    $hallGap = [math]::Round([double]($hall.x-($L.x+$L.w)),6)
    $livingKitchenGap = [math]::Round([double]($kitchen.x-($L.x+$L.w)),6)
    $hallKitchenGap = [math]::Round([double]($kitchen.x-($hall.x+$hall.w)),6)
    $livingHallEdge = if([math]::Abs(($L.x+$L.w)-$hall.x) -le $tol) { [math]::Round((Get-Overlap $L.y ($L.y+$L.h) $hall.y ($hall.y+$hall.h)),6) } else { 0.0 }
    $livingDiningEdge = if([math]::Abs(($L.y+$L.h)-$dining.y) -le $tol) { [math]::Round((Get-Overlap $L.x ($L.x+$L.w) $dining.x ($dining.x+$dining.w)),6) } else { 0.0 }
    [pscustomobject]@{
        living_to_hall_gap_ft=$hallGap
        living_hall_shared_edge_ft=$livingHallEdge
        living_to_kitchen_x_gap_ft=$livingKitchenGap
        hall_to_kitchen_gap_ft=$hallKitchenGap
        living_to_dining_shared_edge_ft=$livingDiningEdge
    }
}
$sourceMeasures=Measure-Interfaces $living
$movedMeasures=Measure-Interfaces $candidate
$delta=[pscustomobject]@{
    living_to_hall_gap_change_ft=[math]::Round(($movedMeasures.living_to_hall_gap_ft-$sourceMeasures.living_to_hall_gap_ft),6)
    living_to_hall_shared_edge_change_ft=[math]::Round(($movedMeasures.living_hall_shared_edge_ft-$sourceMeasures.living_hall_shared_edge_ft),6)
    living_to_kitchen_gap_change_ft=[math]::Round(($movedMeasures.living_to_kitchen_x_gap_ft-$sourceMeasures.living_to_kitchen_x_gap_ft),6)
    living_to_dining_shared_edge_change_ft=[math]::Round(($movedMeasures.living_to_dining_shared_edge_ft-$sourceMeasures.living_to_dining_shared_edge_ft),6)
}
$checks=[ordered]@{
    schema='forever-home.m241-living-kitchen-interface-checks.v1'
    result='pass'
    check_count=12
    checks=[ordered]@{
        selected_d_hash_matches=($actual.selected_d -eq $expected.selected_d)
        m228_hash_matches=($actual.m228 -eq $expected.m228)
        m232_hash_matches=($actual.m232 -eq $expected.m232)
        owner_direction_hash_matches=($actual.owner_decision -eq $expected.owner_decision)
        owner_authorized_translation_exactly_six_inches=([math]::Abs(($candidate.x-$living.x)-0.5) -lt $tol -and [math]::Abs($candidate.y-$living.y) -lt $tol)
        moved_living_area_preserved=([math]::Abs(($candidate.w*$candidate.h)-($living.w*$living.h)) -lt $tol)
        source_living_hall_gap_is_six_inches=([math]::Abs($sourceMeasures.living_to_hall_gap_ft-0.5) -lt $tol)
        move_closes_living_hall_gap=([math]::Abs($movedMeasures.living_to_hall_gap_ft) -lt $tol -and $movedMeasures.living_hall_shared_edge_ft -gt 0)
        living_kitchen_gap_remains_positive=($movedMeasures.living_to_kitchen_x_gap_ft -gt 0)
        hall_kitchen_gap_is_unchanged=([math]::Abs($movedMeasures.hall_to_kitchen_gap_ft-$sourceMeasures.hall_to_kitchen_gap_ft) -lt $tol)
        moved_living_dining_edge_is_positive=($movedMeasures.living_to_dining_shared_edge_ft -gt 0)
        selected_d_unchanged=($m232.selected_d_modified -eq $false -and (Get-Sha256 $studyPath) -eq $expected.selected_d)
    }
}
if(@($checks.checks.Values | Where-Object {$_ -ne $true}).Count -gt 0) { $checks.result='fail'; throw "M241 checks failed: $(ConvertTo-Json $checks -Depth 10)" }
$report=[ordered]@{
    schema='forever-home.m241-living-kitchen-interface.v1'
    status='pass; schematic room-block interface analysis only'
    owner_direction='Test the six-inch east translation of M-01; analysis only'
    source_hashes_sha256=$actual
    selected_d_modified=$false
    room_blocks_ft=[ordered]@{ source_living=@($living.x,$living.y,$living.w,$living.h); moved_living=@($candidate.x,$candidate.y,$candidate.w,$candidate.h); hall=@($hall.x,$hall.y,$hall.w,$hall.h); kitchen=@($kitchen.x,$kitchen.y,$kitchen.w,$kitchen.h); m228_dining_proposal=@($dining.x,$dining.y,$dining.w,$dining.h) }
    measured_interfaces=[ordered]@{ source=$sourceMeasures; moved=$movedMeasures; change=$delta }
    interpretation=@(
        'The east translation closes the source six-inch M-01/M-05 room-block gap and creates a 12-ft shared block edge with M-05.',
        'The move reduces the horizontal M-01/M-02 gap from 5 ft 4 in to 4 ft 10 in, but does not create a direct living/kitchen shared edge. M-05 remains between those blocks, and the M-05/M-02 gap remains 6 in.',
        'The M228 dining block remains a proposal and keeps positive edge adjacency with moved M-01; this is not a physical opening, door, or walkable-route finding.',
        'These are unassigned gaps between schematic room blocks, not measured wall thicknesses, openings, or clearances. A fully open kitchen/living connection cannot be confirmed or rejected from these rectangles alone.'
    )
    limitations=@('No walls, wall thicknesses, openings, doors, furniture, fixtures, circulation width, service routes or construction tolerances are modeled.','No room, kitchen size, M-06 assignment or door/opening is selected. A and B remain unassigned.','No code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.')
}
$out=if([IO.Path]::IsPathRooted($OutputDirectory)){[IO.Path]::GetFullPath($OutputDirectory)}else{[IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory))}
[IO.Directory]::CreateDirectory($out)|Out-Null
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm241-report.json'),(ConvertTo-Json -InputObject $report -Depth 12)+"`r`n",$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm241-checks.json'),(ConvertTo-Json -InputObject $checks -Depth 12)+"`r`n",$utf8)
Write-Output "PASS: M241 $($checks.check_count)/$($checks.check_count); six-inch M-01 translation closes hall gap, but leaves M-01/M-02 separated by $($movedMeasures.living_to_kitchen_x_gap_ft) ft; selected-D unchanged."
