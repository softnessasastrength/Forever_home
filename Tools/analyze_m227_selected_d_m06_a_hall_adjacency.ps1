param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Architecture/M227_Selected_D_M06_A_Hall_Adjacency_2026-10-31/artifacts/m227-selected-d-m06-a-hall-adjacency.json')
)

$ErrorActionPreference = 'Stop'
$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
$studyHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()
$expectedHash = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
if ($study.layout_variant -ne 'OwnerSelectedD' -or $studyHash -ne $expectedHash) {
    throw 'Selected-D source identity changed; review scope and re-pin before rerunning M227.'
}

$m06 = $study.selection.main_public_bath
if ($m06.id -ne 'M-06' -or $m06.type -ne 'half bath' -or $m06.footprint -ne 'TBD' -or $m06.position -ne 'TBD') {
    throw 'Selected-D M-06 must remain an unassigned half-bath search.'
}
$windowA = @($m06.search_windows | Where-Object id -eq 'west_of_core')
$windowB = @($m06.search_windows | Where-Object id -eq 'east_of_core')
if ($windowA.Count -ne 1 -or $windowB.Count -ne 1 -or
    $windowA[0].status -notlike 'Unassigned room-block gap only*' -or
    $windowB[0].status -notlike 'Unassigned room-block gap only*') {
    throw 'Expected west A and east B to remain unassigned search gaps.'
}

function New-Rect([string]$Id, [string]$Name, [double]$X, [double]$Y, [double]$W, [double]$D, [string]$Kind) {
    [pscustomobject]@{ id=$Id; name=$Name; x=$X; y=$Y; w=$W; d=$D; kind=$Kind }
}
function Get-EdgeContact($A, $B, [double]$MaxGapFt, [double]$Tolerance) {
    $ax1=[double]$A.x+[double]$A.w; $ay1=[double]$A.y+[double]$A.d
    $bx1=[double]$B.x+[double]$B.w; $by1=[double]$B.y+[double]$B.d
    $checks=@(
        [pscustomobject]@{axis='x';gap=[double]$B.x-$ax1;overlap=[Math]::Min($ay1,$by1)-[Math]::Max([double]$A.y,[double]$B.y)},
        [pscustomobject]@{axis='x';gap=[double]$A.x-$bx1;overlap=[Math]::Min($ay1,$by1)-[Math]::Max([double]$A.y,[double]$B.y)},
        [pscustomobject]@{axis='y';gap=[double]$B.y-$ay1;overlap=[Math]::Min($ax1,$bx1)-[Math]::Max([double]$A.x,[double]$B.x)},
        [pscustomobject]@{axis='y';gap=[double]$A.y-$by1;overlap=[Math]::Min($ax1,$bx1)-[Math]::Max([double]$A.x,[double]$B.x)}
    )
    foreach($check in $checks) {
        if($check.overlap -gt $Tolerance -and $check.gap -ge -$Tolerance -and $check.gap -le $MaxGapFt+$Tolerance) {
            return [pscustomobject]@{axis=$check.axis;gap_ft=[Math]::Round([Math]::Max(0,[double]$check.gap),6);projected_edge_ft=[Math]::Round([double]$check.overlap,6)}
        }
    }
    return $null
}
function Find-Path([object[]]$Boxes, [object[]]$Edges, [string]$Start, [string]$Goal) {
    $neighbors=@{}
    foreach($box in $Boxes) { $neighbors[$box.id]=New-Object 'System.Collections.Generic.List[object]' }
    foreach($edge in $Edges) {
        $neighbors[$edge.block_a].Add([pscustomobject]@{next=$edge.block_b;edge=$edge})
        $neighbors[$edge.block_b].Add([pscustomobject]@{next=$edge.block_a;edge=$edge})
    }
    $queue=New-Object 'System.Collections.Generic.Queue[string]'
    $queue.Enqueue($Start)
    $previous=@{$Start=$null}
    $previousEdge=@{}
    while($queue.Count -gt 0 -and -not $previous.ContainsKey($Goal)) {
        $current=$queue.Dequeue()
        foreach($neighbor in $neighbors[$current]) {
            if(-not $previous.ContainsKey([string]$neighbor.next)) {
                $previous[[string]$neighbor.next]=$current
                $previousEdge[[string]$neighbor.next]=$neighbor.edge
                $queue.Enqueue([string]$neighbor.next)
            }
        }
    }
    if(-not $previous.ContainsKey($Goal)) { return $null }
    $nodes=@(); $pathEdges=@(); $node=$Goal
    while($null -ne $node) {
        $nodes=@($node)+$nodes
        if($null -ne $previousEdge[$node]) { $pathEdges=@($previousEdge[$node])+$pathEdges }
        $node=$previous[$node]
    }
    [pscustomobject]@{nodes=$nodes;edges=$pathEdges}
}

$boxes=@(
    foreach($room in $study.plans.main) {
        New-Rect ([string]$room.id) ([string]$room.name) ([double]$room.x) ([double]$room.y) ([double]$room.w) ([double]$room.d) 'selected-D room-block comparison'
    }
    New-Rect 'M06-A' 'West A / dining-side search window' ([double]$windowA[0].x) ([double]$windowA[0].y) ([double]$windowA[0].w) ([double]$windowA[0].d) 'unassigned search-window proxy'
    New-Rect 'M06-B' 'East B / pantry-side search window' ([double]$windowB[0].x) ([double]$windowB[0].y) ([double]$windowB[0].w) ([double]$windowB[0].d) 'unassigned search-window proxy'
)
$tol=0.000001
$allContacts=@()
for($i=0;$i -lt $boxes.Count;$i++) {
    for($j=$i+1;$j -lt $boxes.Count;$j++) {
        $contact=Get-EdgeContact $boxes[$i] $boxes[$j] 0.5 $tol
        if($null -ne $contact) {
            $allContacts += [pscustomobject][ordered]@{
                block_a=$boxes[$i].id; block_b=$boxes[$j].id; axis=$contact.axis
                gap_ft=$contact.gap_ft; projected_edge_ft=$contact.projected_edge_ft
                relation=if($contact.gap_ft -le $tol){'coincident room-block edges'}else{'schematic gap proxy'}
                wall_or_opening_modeled=$false; walkable_route_demonstrated=$false
            }
        }
    }
}
$exact=@($allContacts | Where-Object gap_ft -le $tol)
$near=@($allContacts | Where-Object { [double]$_.gap_ft -le (0.5+$tol) })
$directExactHall=@($exact | Where-Object {($_.block_a -eq 'M-05' -and $_.block_b -eq 'M06-A') -or ($_.block_a -eq 'M06-A' -and $_.block_b -eq 'M-05')}).Count -gt 0
$directNearHall=@($near | Where-Object {($_.block_a -eq 'M-05' -and $_.block_b -eq 'M06-A') -or ($_.block_a -eq 'M06-A' -and $_.block_b -eq 'M-05')}).Count -gt 0
$aDining=@($exact | Where-Object {($_.block_a -eq 'M-03' -and $_.block_b -eq 'M06-A') -or ($_.block_a -eq 'M06-A' -and $_.block_b -eq 'M-03')})
$exactPath=Find-Path $boxes $exact 'M-05' 'M06-A'
$nearPath=Find-Path $boxes $near 'M-05' 'M06-A'
$pathNodes=if($null -eq $nearPath){@()}else{@($nearPath.nodes)}
$pathEdges=if($null -eq $nearPath){@()}else{@($nearPath.edges)}
$checks=[ordered]@{
    selected_d_source_hash_pinned=($studyHash -eq $expectedHash)
    west_a_is_unassigned=($windowA[0].status -like 'Unassigned room-block gap only*')
    east_b_is_unassigned=($windowB[0].status -like 'Unassigned room-block gap only*')
    west_a_not_directly_adjacent_to_public_hall=(-not $directExactHall)
    no_exact_room_block_path_from_hall_to_west_a=($null -eq $exactPath)
    west_a_touches_dining_block=($aDining.Count -gt 0)
    half_foot_schematic_chain_runs_via_living=($null -ne $nearPath -and $nearPath.nodes.Count -eq 3 -and $nearPath.nodes[1] -eq 'M-01')
    no_physical_door_or_route_claimed=(@($allContacts | Where-Object { $_.wall_or_opening_modeled -or $_.walkable_route_demonstrated }).Count -eq 0)
}
$report=[ordered]@{
    schema='forever-home-m227-selected-d-m06-a-hall-adjacency-v1'
    status='bounded room-block adjacency audit; no bath, door, approach, or route selected'
    source_sha256=[ordered]@{selected_d_study=$studyHash}
    owner_direction=[ordered]@{west_a_protected_for_m06=$true;east_b_remains_unassigned=$true;arrival_hall_edge_is_first_fit_intent=$true}
    west_a=[ordered]@{id='M06-A';x_ft=[double]$windowA[0].x;y_ft=[double]$windowA[0].y;width_ft=[double]$windowA[0].w;depth_ft=[double]$windowA[0].d;gross_area_sf=[double]$windowA[0].gross_area_sf;assigned=$false}
    east_b=[ordered]@{id='M06-B';gross_area_sf=[double]$windowB[0].gross_area_sf;assigned=$false}
    public_hall=[ordered]@{id='M-05';name='Front arrival / hall';direct_exact_contact_with_west_a=$directExactHall;direct_contact_within_half_foot_proxy=$directNearHall}
    exact_contacts=$exact
    contacts_with_up_to_half_foot_gap=$near
    shortest_half_foot_topology_chain_from_hall_to_west_a=$pathNodes
    topology_chain_edges=$pathEdges
    checks=$checks
    interpretation='West A is not directly adjacent to M-05 in the selected-D room-block plan. It shares a coincident block edge with M-03 Dining. A shortest graph chain from M-05 to A uses two 0.5-ft room-block gaps via M-01 Living. These are topology observations only; gaps are not doors or walkable route widths.'
    limitations=@(
        'Selected-D main-room and search-window rectangles are schematic comparison blocks; no wall thickness, finish, opening, door leaf, swing, sill, or threshold is modeled.',
        'The 0.5-ft proximity threshold is an adjacency sensitivity only and is not a code width, circulation width, or door approach.',
        'No accessible or usable route, privacy, M-06 room geometry, fixture placement, service path, or code compliance is established.',
        'West A and east B remain unassigned; this analysis does not change or replace the owner-selected D source.'
    )
}
$failed=@($checks.GetEnumerator() | Where-Object { -not [bool]$_.Value })
if($failed.Count -gt 0) { throw ('M227 contract failed: ' + (($failed | ForEach-Object Key) -join ', ')) }
$outputFull=[System.IO.Path]::GetFullPath($OutputPath)
[System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($outputFull)) | Out-Null
$json=ConvertTo-Json -InputObject $report -Depth 24
[System.IO.File]::WriteAllText($outputFull,$json+[Environment]::NewLine,(New-Object System.Text.UTF8Encoding($false)))
Write-Output "M227: $($checks.Count)/$($checks.Count) source and scope checks pass; M-05 direct contact with west A = $directExactHall; west A and east B remain unassigned."
Write-Output "Report: $outputFull"
