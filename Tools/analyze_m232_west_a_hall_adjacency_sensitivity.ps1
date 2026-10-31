param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M232_West_A_Hall_Adjacency_Sensitivity_2026-10-31/artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$studyPath = Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m228Path = Join-Path $repoRoot 'Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts/m228-west-a-dining-connection.json'
$m215Path = Join-Path $repoRoot 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json'
$priorityPath = Join-Path $repoRoot 'Decisions/2026-10-31_M06_A_Access_Search_Priority.md'
$expected = [ordered]@{
    selected_d = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    m228 = 'f4ab50fd02e4d71e434c4e4c83d63fe8d20b580810d7118a234bc4b2da8119ff'
    m215 = 'f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
    access_priority = 'b4d9cd595ac1531026139102c31f47d33f80450941aef0411b012adc694cedb1'
}
function Get-Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Assert-Hash([string]$Name, [string]$Actual, [string]$Target) { if ($Actual -ne $Target) { throw "$Name SHA256 mismatch: $Actual" } }
function Rect([string]$Id, [string]$Name, [double]$X, [double]$Y, [double]$W, [double]$H) {
    [pscustomobject]@{ id=$Id; name=$Name; x=$X; y=$Y; w=$W; h=$H }
}
function Area($A, $B) {
    $W = [Math]::Max(0.0, [Math]::Min($A.x+$A.w,$B.x+$B.w)-[Math]::Max($A.x,$B.x))
    $H = [Math]::Max(0.0, [Math]::Min($A.y+$A.h,$B.y+$B.h)-[Math]::Max($A.y,$B.y))
    $W*$H
}
function Contact($A, $B, [double]$Tolerance=0.000001) {
    $OverlapX = [Math]::Min($A.x+$A.w,$B.x+$B.w)-[Math]::Max($A.x,$B.x)
    $OverlapY = [Math]::Min($A.y+$A.h,$B.y+$B.h)-[Math]::Max($A.y,$B.y)
    if ([Math]::Abs(($A.x+$A.w)-$B.x) -le $Tolerance -and $OverlapY -gt $Tolerance) { return [pscustomobject]@{axis='x'; edge_length_ft=[Math]::Round($OverlapY,6)} }
    if ([Math]::Abs(($B.x+$B.w)-$A.x) -le $Tolerance -and $OverlapY -gt $Tolerance) { return [pscustomobject]@{axis='x'; edge_length_ft=[Math]::Round($OverlapY,6)} }
    if ([Math]::Abs(($A.y+$A.h)-$B.y) -le $Tolerance -and $OverlapX -gt $Tolerance) { return [pscustomobject]@{axis='y'; edge_length_ft=[Math]::Round($OverlapX,6)} }
    if ([Math]::Abs(($B.y+$B.h)-$A.y) -le $Tolerance -and $OverlapX -gt $Tolerance) { return [pscustomobject]@{axis='y'; edge_length_ft=[Math]::Round($OverlapX,6)} }
    $null
}
function Gap($A, $B) {
    $Dx=[Math]::Max([Math]::Max($A.x-($B.x+$B.w),$B.x-($A.x+$A.w)),0.0)
    $Dy=[Math]::Max([Math]::Max($A.y-($B.y+$B.h),$B.y-($A.y+$A.h)),0.0)
    [Math]::Sqrt($Dx*$Dx+$Dy*$Dy)
}

$sourceStudyHash = Get-Hash $studyPath
$m228Hash = Get-Hash $m228Path
$m215Hash = Get-Hash $m215Path
$priorityHash = Get-Hash $priorityPath
Assert-Hash 'Selected-D' $sourceStudyHash $expected.selected_d
Assert-Hash 'M228 dining adjacency report' $m228Hash $expected.m228
Assert-Hash 'M215 porch route report' $m215Hash $expected.m215
Assert-Hash 'Owner A-primary direction' $priorityHash $expected.access_priority

$Study=Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$M228=Get-Content -LiteralPath $m228Path -Raw | ConvertFrom-Json
$M215=Get-Content -LiteralPath $m215Path -Raw | ConvertFrom-Json
$Priority=Get-Content -LiteralPath $priorityPath -Raw
$M06=$Study.selection.main_public_bath
if ($M06.footprint -ne 'TBD' -or $M06.position -ne 'TBD' -or $M06.service_route -ne 'TBD' -or
    $M06.search_windows.Count -ne 2 -or
    @($M06.search_windows | Where-Object { $_.status -notlike 'Unassigned room-block gap only*' }).Count -gt 0 -or
    $M228.dining_candidate.candidate_status -or
    $Priority -notmatch 'Keep west A primary') {
    throw 'Expected unassigned selected-D M-06 windows, owner A-primary direction, and the pinned M228 proposal.'
}

$MainRooms=@{}
foreach ($Room in $Study.plans.main) { $MainRooms[[string]$Room.id]=Rect ([string]$Room.id) ([string]$Room.name) ([double]$Room.x) ([double]$Room.y) ([double]$Room.w) ([double]$Room.d) }
$LivingSource=$MainRooms['M-01']
$Hall=$MainRooms['M-05']
$OriginalGap=[double]$Hall.x-([double]$LivingSource.x+[double]$LivingSource.w)
if ([Math]::Abs($OriginalGap-0.5) -gt 0.000001) { throw "Expected the recorded 0.5-ft living/hall gap; found $OriginalGap." }

# This is an analysis-only translation that closes the measured block gap exactly.
$DeltaEast=$OriginalGap
$Living=Rect 'M-01-study' 'Living room (0.5-ft east translation sensitivity)' ([double]$LivingSource.x+$DeltaEast) ([double]$LivingSource.y) ([double]$LivingSource.w) ([double]$LivingSource.h)
$DiningValues=@($M228.dining_candidate.rect_ft)
$Dining=Rect 'M-03-study' 'M228 derived dining proposal (not selected)' ([double]$DiningValues[0]) ([double]$DiningValues[1]) ([double]$DiningValues[2]) ([double]$DiningValues[3])
$WindowA=@($M06.search_windows | Where-Object id -eq 'west_of_core')[0]
$WindowB=@($M06.search_windows | Where-Object id -eq 'east_of_core')[0]
$A=Rect 'M06-A' 'Protected west A' ([double]$WindowA.x) ([double]$WindowA.y) ([double]$WindowA.w) ([double]$WindowA.d)
$B=Rect 'M06-B' 'Unassigned east B' ([double]$WindowB.x) ([double]$WindowB.y) ([double]$WindowB.w) ([double]$WindowB.d)
$Fixed=@($MainRooms['M-02'],$MainRooms['M-04'])
$OverlapRows=@()
foreach ($Obstacle in @($Hall,$Dining,$A,$B)+$Fixed) { $OverlapRows += [ordered]@{with=$Obstacle.id; overlap_sf=[Math]::Round((Area $Living $Obstacle),6)} }
$Contacts=[ordered]@{
    hall_to_living=Contact $Hall $Living
    living_to_dining=Contact $Living $Dining
    dining_to_west_A=Contact $Dining $A
}

# Rebuild the M215 36-in swept rectangles in selected-D coordinates to test the moved living block.
$Origin=@($M228.coordinate_frames.m215_origin_source_ft)
$RoutePoints=@($M215.route_waypoints_ft | ForEach-Object { [pscustomobject]@{x=([double]$_.x+[double]$Origin[0]); y=([double]$_.y+[double]$Origin[1])} })
$Half=[double]$M215.route_width_in/24.0
$RouteBoxes=@()
for ($Index=0; $Index -lt $RoutePoints.Count-1; $Index++) {
    $P0=$RoutePoints[$Index]; $P1=$RoutePoints[$Index+1]
    $MinX=[Math]::Min([double]$P0.x,[double]$P1.x)-$Half
    $MinY=[Math]::Min([double]$P0.y,[double]$P1.y)-$Half
    $W=[Math]::Abs([double]$P1.x-[double]$P0.x)+2*$Half
    $H=[Math]::Abs([double]$P1.y-[double]$P0.y)+2*$Half
    $RouteBoxes += Rect "M215-$Index" 'M215 36-in porch route swept proxy' $MinX $MinY $W $H
}
$RouteOverlaps=@($RouteBoxes | ForEach-Object { [Math]::Round((Area $Living $_),6) })
$MinimumRouteGap=[double]::PositiveInfinity
foreach ($Box in $RouteBoxes) { $G=Gap $Living $Box; if ($G -lt $MinimumRouteGap) { $MinimumRouteGap=$G } }

$ShellW=[double]$M215.test_shell_ft[0]
$ShellH=[double]$M215.test_shell_ft[1]
$Checks=[ordered]@{
    schema='forever-home.m06-west-a-hall-adjacency-sensitivity-checks.v1'
    result='pass'
    check_count=15
    checks=[ordered]@{
        selected_d_hash_matches=$sourceStudyHash -eq $expected.selected_d
        m228_report_hash_matches=$m228Hash -eq $expected.m228
        m215_report_hash_matches=$m215Hash -eq $expected.m215
        owner_A_primary_direction_hash_matches=$priorityHash -eq $expected.access_priority
        owner_direction_keeps_west_A_primary=$Priority -match 'Keep west A primary'
        selected_d_m06_and_A_B_remain_unassigned=($M06.footprint -eq 'TBD' -and $M06.position -eq 'TBD' -and $M06.service_route -eq 'TBD' -and $A.id -eq 'M06-A' -and $B.id -eq 'M06-B')
        sensitivity_equals_measured_gap=([Math]::Abs($DeltaEast-$OriginalGap) -lt 0.000001)
        moved_living_touches_hall_for_12_ft=($null -ne $Contacts.hall_to_living -and [Math]::Abs($Contacts.hall_to_living.edge_length_ft-12.0) -lt 0.000001)
        moved_living_retains_dining_contact=($null -ne $Contacts.living_to_dining -and $Contacts.living_to_dining.edge_length_ft -gt 10.0)
        dining_still_touches_A=($null -ne $Contacts.dining_to_west_A -and [Math]::Abs($Contacts.dining_to_west_A.edge_length_ft-9.5) -lt 0.000001)
        no_overlap_with_hall_dining_A_B_kitchen_pantry=(@($OverlapRows | Where-Object { $_.overlap_sf -gt 0.000001 }).Count -eq 0)
        living_area_is_preserved=([Math]::Abs(($Living.w*$Living.h)-240.0) -lt 0.000001)
        moved_living_inside_test_shell=($Living.x -ge 0 -and $Living.y -ge 0 -and $Living.x+$Living.w -le $ShellW -and $Living.y+$Living.h -le $ShellH)
        no_overlap_with_M215_36_in_swept_porch_route=(@($RouteOverlaps | Where-Object { $_ -gt 0.000001 }).Count -eq 0)
        selected_d_source_was_not_edited=((Get-Hash $studyPath) -eq $sourceStudyHash)
    }
    route_minimum_gap_to_moved_living_ft=[Math]::Round($MinimumRouteGap,6)
}
if (@($Checks.checks.Values | Where-Object { $_ -ne $true }).Count -gt 0) {
    $Checks.result='fail'
    throw "M232 checks failed: $($Checks | ConvertTo-Json -Depth 10)"
}

$Report=[ordered]@{
    schema='forever-home.m06-west-a-hall-adjacency-sensitivity.v1'
    status='analysis-only room-block translation; not selected and not a door or route design'
    owner_direction='Keep west A primary for M-06'
    source_hashes_sha256=[ordered]@{selected_d=$sourceStudyHash;m228=$m228Hash;m215=$m215Hash;access_priority=$priorityHash}
    candidate=[ordered]@{
        living_translation_east_ft=[Math]::Round($DeltaEast,6)
        source_living_rect_ft=@([double]$LivingSource.x,[double]$LivingSource.y,[double]$LivingSource.w,[double]$LivingSource.h)
        proposed_living_rect_ft=@([Math]::Round($Living.x,6),[Math]::Round($Living.y,6),[Math]::Round($Living.w,6),[Math]::Round($Living.h,6))
        living_area_sf=[Math]::Round(($Living.w*$Living.h),6)
        measured_original_M01_M05_gap_ft=[Math]::Round($OriginalGap,6)
        adjacency_chain=[ordered]@{
            hall_to_living_edge_ft=$Contacts.hall_to_living.edge_length_ft
            living_to_M228_dining_edge_ft=$Contacts.living_to_dining.edge_length_ft
            M228_dining_to_west_A_edge_ft=$Contacts.dining_to_west_A.edge_length_ft
        }
        overlap_checks=$OverlapRows
        M215_route_swept_overlap_sf_by_segment=$RouteOverlaps
        M215_route_minimum_edge_gap_ft=[Math]::Round($MinimumRouteGap,6)
        inside_hypothetical_shell=$true
    }
    interpretation=@(
        'A 0.5-ft east translation of M-01 closes the measured 0.5-ft block gap to M-05 without overlap in the checked room rectangles and creates 12 ft of block-edge adjacency.',
        'With M228 dining retained as a proposal, the block-topology chain is M-05 hall -> M-01 living -> M-03 dining proposal -> protected west A. Every shared edge is room-block adjacency only; no wall opening or door is established.',
        'The shifted living rectangle retains its 240-sf gross area and has zero positive-area overlap with the M215 36-in porch-route swept boxes; its nearest edge gap to that route proxy is reported above.',
        'This sensitivity moves M-01, which is outside the prior dining/porch movement authorization. It is not selected and must not be written into selected-D without owner approval.'
    )
    limitations=@(
        'All room blocks, the M228 dining rectangle, and the M215 route are schematic comparison inputs; no wall thickness, door, opening, threshold, circulation clearance, furniture or services are modeled.',
        'The adjacency chain does not prove a continuous walkable route from hall to bath or a private/public access decision.',
        'M-06/A/B remain unassigned; fixture pair evidence is not placed into this topology test.',
        'No code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.'
    )
    selected_d_modified=$false
}
$ResolvedOutput=if ([IO.Path]::IsPathRooted($OutputDirectory)) {[IO.Path]::GetFullPath($OutputDirectory)} else {[IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory))}
[IO.Directory]::CreateDirectory($ResolvedOutput) | Out-Null
[IO.File]::WriteAllText((Join-Path $ResolvedOutput 'm232-report.json'),(ConvertTo-Json -InputObject $Report -Depth 20)+"`r`n",[Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText((Join-Path $ResolvedOutput 'm232-checks.json'),(ConvertTo-Json -InputObject $Checks -Depth 14)+"`r`n",[Text.UTF8Encoding]::new($false))
Write-Output "PASS: M232 $($Checks.check_count)/$($Checks.check_count); A-primary room-block chain tested with no source layout edits, no door and no assignment."
