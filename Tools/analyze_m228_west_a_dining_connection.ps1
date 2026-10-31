param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts'),
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/Selected_Design_Iteration_2026-10-27/study.json'),
    [string]$DecisionPath = (Join-Path $PSScriptRoot '../Decisions/2026-10-31_Kitchen_Area_Priority.md'),
    [string]$ProtectionPath = (Join-Path $PSScriptRoot '../Decisions/2026-10-31_M06_West_A_Protection.md'),
    [string]$PorchPath = (Join-Path $PSScriptRoot '../Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json'),
    [string]$BathFirstPath = (Join-Path $PSScriptRoot '../Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'),
    [string]$M186ScriptPath = (Join-Path $PSScriptRoot 'search_m186_public_route.ps1')
)

$ErrorActionPreference = 'Stop'
$expected = [ordered]@{
    selected_d = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    dining_decision = 'da0ba56c557ca7ad141a6e207663d68ca99cb67a984d1df8c1ac1bafd6a693bf'
    west_a_protection = 'a5cf98360b75314f4d3486f925e9d860465bb33d1ecfce9b0cbb39ce0eff853b'
    m215 = 'f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
    bath_first = '07f4ead3c2d52f0df4e7da7dcde7310dfbef1f333a0b8f46853873ecb2231d50'
    m186_script = 'c882822e69a5f4408b487c176c570af4e132300de2d3aee9a5287322591f0732'
}
$paths = [ordered]@{ selected_d=$StudyPath; dining_decision=$DecisionPath; west_a_protection=$ProtectionPath; m215=$PorchPath; bath_first=$BathFirstPath; m186_script=$M186ScriptPath }
$fingerprints = [ordered]@{}
foreach ($key in $paths.Keys) {
    $file = (Resolve-Path -LiteralPath $paths[$key]).Path
    $hash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne $expected[$key]) { throw "Pinned input changed: $key ($hash)" }
    $fingerprints[$key] = $hash
}

$study = Get-Content -LiteralPath $StudyPath -Raw | ConvertFrom-Json
$porch = Get-Content -LiteralPath $PorchPath -Raw | ConvertFrom-Json
$bathFirst = Get-Content -LiteralPath $BathFirstPath -Raw | ConvertFrom-Json
$decisionText = Get-Content -LiteralPath $DecisionPath -Raw
$protectionText = Get-Content -LiteralPath $ProtectionPath -Raw
if ($study.layout_variant -ne 'OwnerSelectedD' -or $study.selection.main_public_bath.footprint -ne 'TBD' -or $study.selection.main_public_bath.position -ne 'TBD') {
    throw 'Selected-D or unresolved M-06 scope changed.'
}
if ($decisionText -notmatch '11\s+\S+\s+10\s*ft' -or $decisionText -notmatch 'authorized moving the dining and porch test footprints') {
    throw 'The owner-authorized dining target/movement scope is not present in the pinned decision.'
}
if ($protectionText -notmatch 'Protect A for M-06' -or $protectionText -notmatch 'remain free of pantry and circulation geometry') {
    throw 'West-A protection direction is not present in the pinned decision.'
}
$coordinateOrigin = @($bathFirst.plans.main | Where-Object id -eq 'M-02')[0]
if ([Math]::Abs([double]$coordinateOrigin.x-0.6666666666666666) -gt 0.000001 -or [Math]::Abs([double]$coordinateOrigin.y-0.6666666666666666) -gt 0.000001) {
    throw 'M186/M215 local coordinate origin changed; reconcile coordinate frames before comparison.'
}

function Rect($id, $name, [double]$x, [double]$y, [double]$w, [double]$h) {
    [pscustomobject]@{ id=$id; name=$name; x=$x; y=$y; w=$w; h=$h }
}
function IntersectionArea($a, $b) {
    $w = [Math]::Max(0.0, [Math]::Min($a.x+$a.w,$b.x+$b.w)-[Math]::Max($a.x,$b.x))
    $h = [Math]::Max(0.0, [Math]::Min($a.y+$a.h,$b.y+$b.h)-[Math]::Max($a.y,$b.y))
    return $w*$h
}
function Contact($a, $b, [double]$tol=0.000001) {
    $overlapX = [Math]::Min($a.x+$a.w,$b.x+$b.w)-[Math]::Max($a.x,$b.x)
    $overlapY = [Math]::Min($a.y+$a.h,$b.y+$b.h)-[Math]::Max($a.y,$b.y)
    if ([Math]::Abs(($a.x+$a.w)-$b.x) -le $tol -and $overlapY -gt $tol) { return [pscustomobject]@{axis='x'; edge_length_ft=[Math]::Round($overlapY,6)} }
    if ([Math]::Abs(($b.x+$b.w)-$a.x) -le $tol -and $overlapY -gt $tol) { return [pscustomobject]@{axis='x'; edge_length_ft=[Math]::Round($overlapY,6)} }
    if ([Math]::Abs(($a.y+$a.h)-$b.y) -le $tol -and $overlapX -gt $tol) { return [pscustomobject]@{axis='y'; edge_length_ft=[Math]::Round($overlapX,6)} }
    if ([Math]::Abs(($b.y+$b.h)-$a.y) -le $tol -and $overlapX -gt $tol) { return [pscustomobject]@{axis='y'; edge_length_ft=[Math]::Round($overlapX,6)} }
    return $null
}

$rooms = @{}
foreach ($room in $study.plans.main) { $rooms[[string]$room.id] = Rect ([string]$room.id) ([string]$room.name) ([double]$room.x) ([double]$room.y) ([double]$room.w) ([double]$room.d) }
$windowA = @($study.selection.main_public_bath.search_windows | Where-Object id -eq 'west_of_core')[0]
$windowB = @($study.selection.main_public_bath.search_windows | Where-Object id -eq 'east_of_core')[0]
$a = Rect 'M06-A' 'Protected west bath search window' ([double]$windowA.x) ([double]$windowA.y) ([double]$windowA.w) ([double]$windowA.d)
$b = Rect 'M06-B' 'Unassigned east bath search window' ([double]$windowB.x) ([double]$windowB.y) ([double]$windowB.w) ([double]$windowB.d)

# The 11 x 10 ft target and movement permission are owner-directed in the pinned decision.
# Align the block's west edge to A and its north edge to M-01's south edge; this is a derived proposal.
$diningW = 11.0
$diningH = 10.0
$dining = Rect 'M-03-proposal' 'Dining proposal (owner target; not selected)' ($a.x-$diningW) ($rooms['M-01'].y+$rooms['M-01'].h) $diningW $diningH
$shellW = [double]$porch.test_shell_ft[0]
$shellH = [double]$porch.test_shell_ft[1]
$fixed = @($rooms['M-02'],$rooms['M-04'],$rooms['M-05'],$a,$b)
$overlaps = @(
    foreach ($obstacle in $fixed) {
        $area = IntersectionArea $dining $obstacle
        [pscustomobject]@{ with=$obstacle.id; overlap_sf=[Math]::Round($area,6) }
    }
)

# Test the candidate against M215's documented 36-in centerline route as axis-aligned swept rectangles.
$routeBoxes = @()
$waypoints = @($porch.route_waypoints_ft | ForEach-Object {
    [pscustomobject]@{x=([double]$_.x+[double]$coordinateOrigin.x);y=([double]$_.y+[double]$coordinateOrigin.y)}
})
for ($i=0; $i -lt $waypoints.Count-1; $i++) {
    $p0=$waypoints[$i]; $p1=$waypoints[$i+1]
    $half=[double]$porch.route_width_in/24.0
    $minX=[Math]::Min([double]$p0.x,[double]$p1.x)-$half
    $minY=[Math]::Min([double]$p0.y,[double]$p1.y)-$half
    $w=[Math]::Abs([double]$p1.x-[double]$p0.x)+2*$half
    $h=[Math]::Abs([double]$p1.y-[double]$p0.y)+2*$half
    $routeBoxes += Rect "route-$i" 'M215 36-in swept centerline proxy' $minX $minY $w $h
}
$routeOverlap = @($routeBoxes | ForEach-Object { [Math]::Round((IntersectionArea $dining $_),6) })
$routeAOverlap = @($routeBoxes | ForEach-Object { [Math]::Round((IntersectionArea $a $_),6) })
$routeBOverlap = @($routeBoxes | ForEach-Object { [Math]::Round((IntersectionArea $b $_),6) })
$minRouteGap = [double]::PositiveInfinity
foreach ($box in $routeBoxes) {
    $dx=[Math]::Max([Math]::Max($dining.x-($box.x+$box.w),$box.x-($dining.x+$dining.w)),0)
    $dy=[Math]::Max([Math]::Max($dining.y-($box.y+$box.h),$box.y-($dining.y+$dining.h)),0)
    $gap=[Math]::Sqrt($dx*$dx+$dy*$dy)
    if ($gap -lt $minRouteGap) { $minRouteGap=$gap }
}
$contacts = [ordered]@{
    west_A_to_dining = Contact $a $dining
    dining_to_living = Contact $dining $rooms['M-01']
    living_to_hall = Contact $rooms['M-01'] $rooms['M-05']
}
$hallLivingGap = [Math]::Round(([double]$rooms['M-05'].x - ([double]$rooms['M-01'].x+[double]$rooms['M-01'].w)),6)
$checks = @(
    [pscustomobject]@{id='selected_D_source_hash_pinned';pass=($fingerprints.selected_d -eq $expected.selected_d)},
    [pscustomobject]@{id='owner_dining_target_and_movement_source_pinned';pass=($fingerprints.dining_decision -eq $expected.dining_decision)},
    [pscustomobject]@{id='west_A_protection_source_pinned';pass=($fingerprints.west_a_protection -eq $expected.west_a_protection)},
    [pscustomobject]@{id='M06_and_both_windows_stay_unassigned';pass=($study.selection.main_public_bath.footprint -eq 'TBD' -and $study.selection.main_public_bath.position -eq 'TBD' -and $windowA.status -like 'Unassigned room-block gap only*' -and $windowB.status -like 'Unassigned room-block gap only*')},
    [pscustomobject]@{id='11x10_candidate_inside_40x42_test_shell';pass=($dining.x -ge 0 -and $dining.y -ge 0 -and $dining.x+$dining.w -le $shellW -and $dining.y+$dining.h -le $shellH)},
    [pscustomobject]@{id='no_overlap_with_fixed_rooms_A_or_B';pass=(@($overlaps|Where-Object{$_.overlap_sf -gt 0.000001}).Count -eq 0)},
    [pscustomobject]@{id='dining_touches_protected_A_without_consuming_it';pass=($null -ne $contacts.west_A_to_dining -and ($overlaps|Where-Object{$_.with -eq 'M06-A'}).overlap_sf -eq 0)},
    [pscustomobject]@{id='dining_touches_living';pass=($null -ne $contacts.dining_to_living)},
    [pscustomobject]@{id='M215_swept_route_does_not_cross_dining';pass=(@($routeOverlap|Where-Object{$_ -gt 0.000001}).Count -eq 0)},
    [pscustomobject]@{id='M215_swept_route_does_not_cross_protected_A';pass=(@($routeAOverlap|Where-Object{$_ -gt 0.000001}).Count -eq 0)},
    [pscustomobject]@{id='M215_swept_route_does_not_cross_unassigned_B';pass=(@($routeBOverlap|Where-Object{$_ -gt 0.000001}).Count -eq 0)},
    [pscustomobject]@{id='hall_link_explicitly_remains_unresolved';pass=($hallLivingGap -eq 0.5 -and $null -eq $contacts.living_to_hall)}
)

$report = [ordered]@{
    schema='forever-home-m228-west-a-dining-connection-v1'
    status=if (@($checks|Where-Object{-not $_.pass}).Count -eq 0) {'pass'} else {'fail'}
    candidate_status='derived schematic adjacency proposal; not selected; not a room assignment'
    source_sha256=$fingerprints
    owner_directions=[ordered]@{ west_A_protected=$true; east_B_unassigned=$true; dining_target_ft=@(11,10); dining_and_porch_movement_authorized=$true }
    source_room_blocks=[ordered]@{
        living=$rooms['M-01']; hall=$rooms['M-05']; west_A=$a; east_B=$b
    }
    coordinate_frames=[ordered]@{
        selected_d='global plan coordinates from OwnerSelectedD'
        m215_route='M186 local coordinates; translated to selected-D frame by adding the pinned BathFirst M-02 origin'
        m215_origin_source_ft=@([double]$coordinateOrigin.x,[double]$coordinateOrigin.y)
    }
    dining_candidate=[ordered]@{
        rect_ft=@([Math]::Round($dining.x,6),[Math]::Round($dining.y,6),$diningW,$diningH)
        area_sf=110
        translation_from_M215_dining_ft=@([Math]::Round($dining.x-([double]$porch.dining_rect_ft[0]+[double]$coordinateOrigin.x),6),[Math]::Round($dining.y-([double]$porch.dining_rect_ft[1]+[double]$coordinateOrigin.y),6))
        contacts=$contacts
        overlaps=$overlaps
        m215_36in_route_minimum_separation_ft=[Math]::Round($minRouteGap,6)
        m215_36in_route_overlap_sf_by_segment=$routeOverlap
        m215_36in_route_overlap_with_A_sf_by_segment=$routeAOverlap
        m215_36in_route_overlap_with_B_sf_by_segment=$routeBOverlap
    }
    hall_interface=[ordered]@{ living_hall_gap_ft=$hallLivingGap; projected_edge_ft=12; direct_block_contact=$false; actual_opening_or_walkable_route_modeled=$false }
    passed_checks=@($checks|Where-Object pass).Count
    total_checks=$checks.Count
    checks=$checks
    limitations=@(
        'This is room-block adjacency and overlap analysis only. It does not place walls, doors, jambs, swings, thresholds, furniture or privacy screens.',
        'A direct A-to-dining and dining-to-living contact does not prove an opening, public approach, or usable route through the half bath.',
        'The selected-D M-05/M-01 blocks remain separated by a 0.5-ft modeled gap; this report does not reinterpret that gap as a wall or doorway.',
        'The M215 path is stored in M186 local coordinates. This script translates it by the pinned BathFirst M-02 origin before comparing against selected-D global room blocks.',
        'The route comparison reuses only the M215 36-in swept corridor proxy. It does not establish code/accessibility adequacy, occupied movement, or a complete connected path from hall to bath.',
        'The 11 x 10 ft dining rectangle is the owner-directed study target and this position is a derived proposal. It does not alter selected-D or the M215 selected candidate.',
        'No M-06 fixture geometry, lavatory, applicable project-specific clearance, services, or room assignment is evaluated. A and B stay unassigned.'
    )
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$reportPath=Join-Path $OutputDirectory 'm228-west-a-dining-connection.json'
$checksPath=Join-Path $OutputDirectory 'm228-checks.json'
$svgPath=Join-Path $OutputDirectory 'm228-west-a-dining-connection.svg'
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $reportPath -Encoding UTF8
$checksDoc=[ordered]@{schema='forever-home-m228-checks-v1';passed=$report.passed_checks;total=$report.total_checks;checks=$checks}
$checksDoc | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $checksPath -Encoding UTF8

$scale=14.0; $margin=38.0; $svgW=40*$scale+2*$margin; $svgH=42*$scale+2*$margin
function SvgY([double]$y,[double]$h=0) { return [Math]::Round($margin+(42-$y-$h)*$scale,2) }
function SvgRect($rect,$fill,$label) {
    $x=[Math]::Round($margin+$rect.x*$scale,2); $y=SvgY $rect.y $rect.h; $w=[Math]::Round($rect.w*$scale,2); $h=[Math]::Round($rect.h*$scale,2)
    return "<rect x=`"$x`" y=`"$y`" width=`"$w`" height=`"$h`" fill=`"$fill`" stroke=`"#27364b`" stroke-width=`"1.5`"/><text x=`"$($x+5)`" y=`"$($y+16)`" font-size=`"11`" font-family=`"Arial`">$label</text>"
}
$routeSvgPoints = @($waypoints | ForEach-Object { '{0},{1}' -f ([Math]::Round($margin+$_.x*$scale,2)),(SvgY $_.y) }) -join ' '
$svg = @(
    "<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$svgW`" height=`"$svgH`" viewBox=`"0 0 $svgW $svgH`">",
    '<rect width="100%" height="100%" fill="#ffffff"/>',
    '<text x="38" y="22" font-size="16" font-family="Arial" font-weight="bold">M228 - west-A access adjacency proposal (schematic)</text>',
    "<rect x=`"$margin`" y=`"$margin`" width=`"$([Math]::Round(40*$scale,2))`" height=`"$([Math]::Round(42*$scale,2))`" fill=`"none`" stroke=`"#8b97a8`" stroke-dasharray=`"5 4`"/>",
    (SvgRect $rooms['M-01'] '#e8edf4' 'M-01 Living'),
    (SvgRect $rooms['M-02'] '#f5ead5' 'M-02 Kitchen'),
    (SvgRect $rooms['M-04'] '#e8e8e8' 'M-04 Pantry'),
    (SvgRect $rooms['M-05'] '#dce9f7' 'M-05 Hall'),
    (SvgRect $a '#e4f1e4' 'M-06 A (protected, unassigned)'),
    (SvgRect $b '#f3f3f3' 'M-06 B (unassigned)'),
    (SvgRect $dining '#f9e4c8' 'M-03 dining proposal 11 x 10'),
    ("<polyline points=`"$routeSvgPoints`" fill=`"none`" stroke=`"#2878b8`" stroke-width=`"4`" stroke-dasharray=`"7 4`"/>"),
    ("<text x=`"$margin`" y=`"$($svgH-20)`" font-size=`"11`" font-family=`"Arial`">M-01/M-05 still have a 6-in gap; no door, bath fit, or walkable route is established.</text>"),
    '</svg>'
)
$svg -join "`n" | Set-Content -LiteralPath $svgPath -Encoding UTF8
Write-Output ($report|ConvertTo-Json -Depth 8)
