param(
    [string]$OutputDirectory = '.local/revalidation/M256-integrated-room-route'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$studyPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m228Path = Join-Path $root 'Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts/m228-west-a-dining-connection.json'
$m215Path = Join-Path $root 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json'
$m232Path = Join-Path $root 'Architecture/M232_West_A_Hall_Adjacency_Sensitivity_2026-10-31/artifacts/m232-report.json'
$m242Path = Join-Path $root 'Architecture/M242_Hall_Kitchen_Gap_Route_Sensitivity_2026-10-31/artifacts/m242-report.json'
$m243Path = Join-Path $root 'Architecture/M243_Moved_Kitchen_Route_Start_Sensitivity_2026-10-31/artifacts/m243-report.json'
$expected = [ordered]@{
    selected_d = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    m228 = 'f4ab50fd02e4d71e434c4e4c83d63fe8d20b580810d7118a234bc4b2da8119ff'
    m215 = 'f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
    m232 = 'dd324b1b88d73902a03e33144dd4f48694fbb6839dec86be1f5f69623ea7a180'
    m242 = '54c197565569919636ea0fa851e86fcb05fccc5b11a6b4841a09e7f6dbdb8711'
    m243 = '30309c0bf4c4a478b67e3f1d183d75e8de09ea3c5b19f2c301d66ceb6ea29ac8'
}

function Get-Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function New-Rect([string]$Id, [double]$X, [double]$Y, [double]$W, [double]$H) {
    [pscustomobject]@{ id = $Id; x = $X; y = $Y; w = $W; h = $H }
}
function Get-OverlapArea($A, $B) {
    $dx = [Math]::Max(0.0, [Math]::Min(($A.x + $A.w), ($B.x + $B.w)) - [Math]::Max($A.x, $B.x))
    $dy = [Math]::Max(0.0, [Math]::Min(($A.y + $A.h), ($B.y + $B.h)) - [Math]::Max($A.y, $B.y))
    [Math]::Round(($dx * $dy), 8)
}
function Get-RectGap($A, $B) {
    $dx = [Math]::Max(0.0, [Math]::Max(($A.x - ($B.x + $B.w)), ($B.x - ($A.x + $A.w))))
    $dy = [Math]::Max(0.0, [Math]::Max(($A.y - ($B.y + $B.h)), ($B.y - ($A.y + $A.h))))
    [Math]::Round([Math]::Sqrt(($dx * $dx) + ($dy * $dy)), 8)
}
function Get-SharedEdgeLength($A, $B) {
    $overlapX = [Math]::Min(($A.x + $A.w), ($B.x + $B.w)) - [Math]::Max($A.x, $B.x)
    $overlapY = [Math]::Min(($A.y + $A.h), ($B.y + $B.h)) - [Math]::Max($A.y, $B.y)
    if ([Math]::Abs(($A.x + $A.w) - $B.x) -lt 0.00001 -or [Math]::Abs(($B.x + $B.w) - $A.x) -lt 0.00001) { return [Math]::Max(0.0, $overlapY) }
    if ([Math]::Abs(($A.y + $A.h) - $B.y) -lt 0.00001 -or [Math]::Abs(($B.y + $B.h) - $A.y) -lt 0.00001) { return [Math]::Max(0.0, $overlapX) }
    return 0.0
}

$actual = [ordered]@{
    selected_d = Get-Hash $studyPath
    m228 = Get-Hash $m228Path
    m215 = Get-Hash $m215Path
    m232 = Get-Hash $m232Path
    m242 = Get-Hash $m242Path
    m243 = Get-Hash $m243Path
}
# Pin every input report before combining its geometry.
if ($actual.selected_d -ne $expected.selected_d -or $actual.m228 -ne $expected.m228 -or $actual.m215 -ne $expected.m215 -or $actual.m232 -ne $expected.m232 -or
    $actual.m242 -ne $expected.m242 -or $actual.m243 -ne $expected.m243) {
    throw "A source report fingerprint changed: $(ConvertTo-Json $actual -Compress)"
}

$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$m228 = Get-Content -LiteralPath $m228Path -Raw | ConvertFrom-Json
$m215 = Get-Content -LiteralPath $m215Path -Raw | ConvertFrom-Json
$m232 = Get-Content -LiteralPath $m232Path -Raw | ConvertFrom-Json
$m242 = Get-Content -LiteralPath $m242Path -Raw | ConvertFrom-Json
$m243 = Get-Content -LiteralPath $m243Path -Raw | ConvertFrom-Json
if ($m232.candidate.living_translation_east_ft -ne 0.5 -or $m242.translation_west_ft -ne 0.5 -or $m243.candidate_kitchen_translation_west_ft -ne 0.5) {
    throw 'The integrated candidate no longer matches its two recorded six-inch studies.'
}
$route = @($m243.variants | Where-Object start_shift_west_in -eq 6)[0]
if ($null -eq $route -or $route.minimum_clearance_all_obstacles_in -lt 3 -or @($route.proxy_intersections).Count -ne 0) {
    throw 'The M243 six-inch route candidate does not meet its recorded proxy contract.'
}

$livingValues = @($m232.candidate.proposed_living_rect_ft)
$kitchenValues = @($m242.room_blocks_ft.candidate_kitchen)
$living = New-Rect 'M-01 +6in east' ([double]$livingValues[0]) ([double]$livingValues[1]) ([double]$livingValues[2]) ([double]$livingValues[3])
$kitchen = New-Rect 'M-02 -6in west' ([double]$kitchenValues[0]) ([double]$kitchenValues[1]) ([double]$kitchenValues[2]) ([double]$kitchenValues[3])
$hallRow = @($study.plans.main | Where-Object id -eq 'M-05')[0]
$hall = New-Rect 'M-05 hall' ([double]$hallRow.x) ([double]$hallRow.y) ([double]$hallRow.w) ([double]$hallRow.d)
$origin = @($m228.coordinate_frames.m215_origin_source_ft)
$half = [double]$m243.route_width_in / 24.0
$routePoints = @($route.route_waypoints_ft | ForEach-Object {
    [pscustomobject]@{ x = ([double]$_.x + [double]$origin[0]); y = ([double]$_.y + [double]$origin[1]) }
})
if ($routePoints.Count -ne 5) { throw "Expected five orthogonal route waypoints; found $($routePoints.Count)." }
$routeRects = New-Object System.Collections.Generic.List[object]
for ($i = 0; $i -lt $routePoints.Count - 1; $i++) {
    $a = $routePoints[$i]; $b = $routePoints[$i + 1]
    if ([Math]::Abs($a.y - $b.y) -lt 1e-8) {
        $routeRects.Add((New-Rect "route-$i" ([Math]::Min($a.x, $b.x)) ($a.y - $half) ([Math]::Abs($b.x - $a.x)) (2 * $half)))
    } elseif ([Math]::Abs($a.x - $b.x) -lt 1e-8) {
        $routeRects.Add((New-Rect "route-$i" ($a.x - $half) ([Math]::Min($a.y, $b.y)) (2 * $half) ([Math]::Abs($b.y - $a.y))))
    } else { throw "Route segment $i is diagonal." }
    if ($i -gt 0) { $routeRects.Add((New-Rect "corner-$i" ($a.x - $half) ($a.y - $half) (2 * $half) (2 * $half))) }
}
$routeRects.Insert(0, (New-Rect 'route-start-cap' ($routePoints[0].x - $half) ($routePoints[0].y - $half) (2 * $half) (2 * $half)))
$routeRects.Add((New-Rect 'route-end-cap' ($routePoints[-1].x - $half) ($routePoints[-1].y - $half) (2 * $half) (2 * $half)))

function Measure-RouteVsRect($PathRects, $Obstacle) {
    $overlap = 0.0
    $gap = [double]::PositiveInfinity
    foreach ($box in $PathRects) {
        $overlap = [Math]::Max($overlap, (Get-OverlapArea $box $Obstacle))
        $gap = [Math]::Min($gap, (Get-RectGap $box $Obstacle))
    }
    [pscustomobject]@{ obstacle = $Obstacle.id; maximum_overlap_sf = [Math]::Round($overlap, 6); minimum_edge_gap_in = [Math]::Round(($gap * 12), 3) }
}
$livingRoute = Measure-RouteVsRect $routeRects $living
$kitchenRoute = Measure-RouteVsRect $routeRects $kitchen
$livingKitchenSeparation = [Math]::Round(($kitchen.x - ($living.x + $living.w)), 6)
$candidateRoomOverlap = Get-OverlapArea $living $kitchen
$a = @($study.selection.main_public_bath.search_windows | Where-Object id -eq 'west_of_core')[0]
$b = @($study.selection.main_public_bath.search_windows | Where-Object id -eq 'east_of_core')[0]
if ($study.selection.main_public_bath.footprint -ne 'TBD' -or $study.selection.main_public_bath.position -ne 'TBD' -or $study.selection.main_public_bath.service_route -ne 'TBD') {
    throw 'Selected-D M-06 assignment is no longer TBD.'
}
$aRect = New-Rect 'protected west A' ([double]$a.x) ([double]$a.y) ([double]$a.w) ([double]$a.d)
$bRect = New-Rect 'unassigned east B' ([double]$b.x) ([double]$b.y) ([double]$b.w) ([double]$b.d)
$areaRows = @(
    [pscustomobject]@{ room = $living.id; gross_area_sf = [Math]::Round(($living.w * $living.h), 6) }
    [pscustomobject]@{ room = $kitchen.id; gross_area_sf = [Math]::Round(($kitchen.w * $kitchen.h), 6) }
)
$roomReservationOverlaps = @(
    [pscustomobject]@{ room = $living.id; reservation = $aRect.id; overlap_sf = Get-OverlapArea $living $aRect }
    [pscustomobject]@{ room = $living.id; reservation = $bRect.id; overlap_sf = Get-OverlapArea $living $bRect }
    [pscustomobject]@{ room = $kitchen.id; reservation = $aRect.id; overlap_sf = Get-OverlapArea $kitchen $aRect }
    [pscustomobject]@{ room = $kitchen.id; reservation = $bRect.id; overlap_sf = Get-OverlapArea $kitchen $bRect }
)

$checks = [ordered]@{
    schema = 'forever-home.m256-integrated-living-kitchen-route-checks.v1'
    result = 'pass'
    check_count = 21
    checks = [ordered]@{
        selected_d_fingerprint_matches = ($actual.selected_d -eq $expected.selected_d)
        m228_frame_and_dining_fingerprint_match = ($actual.m228 -eq $expected.m228)
        m215_shell_and_route_fingerprint_match = ($actual.m215 -eq $expected.m215)
        m232_living_candidate_matches_owner_test = ($m232.candidate.living_translation_east_ft -eq 0.5)
        m242_kitchen_candidate_preserves_source_area = ([Math]::Abs(([double]$kitchen.w * [double]$kitchen.h) - [double]$m242.kitchen_area_sf) -lt 0.000001)
        m243_route_is_based_on_same_kitchen_translation = ([Math]::Abs([double]$m243.candidate_kitchen_translation_west_ft - 0.5) -lt 0.000001)
        m243_route_candidate_has_zero_recorded_proxy_intersections = (@($route.proxy_intersections).Count -eq 0)
        m243_route_candidate_retains_minimum_three_in_proxy_gap = ([double]$route.minimum_clearance_all_obstacles_in -ge 3)
        route_is_36_in_wide = ([Math]::Abs([double]$m243.route_width_in - 36) -lt 0.000001)
        living_and_kitchen_room_blocks_do_not_overlap = ($candidateRoomOverlap -eq 0)
        living_and_kitchen_blocks_do_not_share_a_direct_edge = ((Get-SharedEdgeLength $living $kitchen) -eq 0)
        moved_living_abuts_hall_over_twelve_feet = ([Math]::Abs((Get-SharedEdgeLength $living $hall) - 12) -lt 0.000001)
        moved_kitchen_abuts_hall_over_twelve_feet = ([Math]::Abs((Get-SharedEdgeLength $kitchen $hall) - 12) -lt 0.000001)
        fully_open_living_kitchen_preference_is_not_claimed_as_met = ((Get-SharedEdgeLength $living $kitchen) -eq 0)
        living_retains_240_sf = ([Math]::Abs(($living.w * $living.h) - 240) -lt 0.000001)
        room_blocks_remain_inside_documented_test_shell = ($living.x -ge 0 -and $living.y -ge 0 -and ($living.x + $living.w) -le [double]$m215.test_shell_ft[0] -and ($living.y + $living.h) -le [double]$m215.test_shell_ft[1] -and $kitchen.x -ge 0 -and $kitchen.y -ge 0 -and ($kitchen.x + $kitchen.w) -le [double]$m215.test_shell_ft[0] -and ($kitchen.y + $kitchen.h) -le [double]$m215.test_shell_ft[1])
        route_does_not_overlap_shifted_living = ($livingRoute.maximum_overlap_sf -eq 0)
        route_does_not_overlap_shifted_kitchen = ($kitchenRoute.maximum_overlap_sf -eq 0)
        living_and_kitchen_do_not_consume_A_or_B = (@($roomReservationOverlaps | Where-Object overlap_sf -gt 0.000001).Count -eq 0)
        selected_d_keeps_m06_unassigned_and_b_protected = ($study.selection.main_public_bath.position -eq 'TBD' -and $study.selection.main_public_bath.footprint -eq 'TBD' -and $study.selection.main_public_bath.service_route -eq 'TBD' -and $a.id -eq 'west_of_core' -and $b.id -eq 'east_of_core')
    }
}
if (@($checks.checks.Values | Where-Object { $_ -ne $true }).Count -gt 0) {
    $checks.result = 'fail'
    throw "M256 checks failed: $(ConvertTo-Json $checks -Depth 10)"
}

$report = [ordered]@{
    schema = 'forever-home.m256-integrated-living-kitchen-route.v1'
    status = 'analysis-only integration of prior owner-directed and derived sensitivities; not a selected layout'
    source_hashes_sha256 = $actual
    candidates = [ordered]@{
        living_translation_east_ft = 0.5
        kitchen_translation_west_ft = 0.5
        route_start_translation_west_in = 6
        room_blocks = [ordered]@{ living_ft = @($living.x, $living.y, $living.w, $living.h); kitchen_ft = @($kitchen.x, $kitchen.y, $kitchen.w, $kitchen.h) }
        room_gross_areas_sf = $areaRows
        intervening_hall_width_between_living_and_kitchen_blocks_ft = $livingKitchenSeparation
        room_block_overlap_sf = [Math]::Round($candidateRoomOverlap, 6)
        living_kitchen_interface = 'No direct room-block edge; M-05 hall occupies the corresponding 12-ft north-south band, with remaining gap unassigned. Owner preference for a fully open connection is not demonstrated.'
        route = [ordered]@{
            width_in = [double]$m243.route_width_in
            length_ft = [double]$route.route_length_ft
            minimum_gap_to_existing_M243_proxies_in = [double]$route.minimum_clearance_all_obstacles_in
            living = $livingRoute
            kitchen = $kitchenRoute
        }
        protected_search_window_overlaps_sf = $roomReservationOverlaps
        m06_assignment = 'TBD; unchanged'
    }
    interpretation = @(
        'The three existing sensitivities can be composed without positive-area overlap between the M-01 and M-02 room blocks or between the 36-in swept route and either block in this schematic coordinate model.',
        'The route retains the M243 3-in minimum reserve against its previously checked obstacles; its newly measured gaps to M-01 and M-02 are reported separately. This is not a full physical route or wall-opening study.',
        'M-01 remains 240 sf gross and the M-02 envelope remains the source gross area. M-05 intervenes between their room-block extents, so this candidate does not demonstrate the owner-preferred fully open living/kitchen connection. The moves are comparisons only; no kitchen dimension, route, room placement or door is selected.'
    )
    limitations = @(
        'The room blocks and route are schematic rectangles. No wall thickness, finished face, door leaf, opening, threshold, occupied movement, appliance operation, fixture, plumbing or other service is modeled.',
        'The route''s 36-in width and 3-in reserve are inherited analysis proxies, not code or accessibility requirements. Connecticut applicability remains project-specific and unverified.',
        'West A remains protected and unassigned; east B and M-06 remain unassigned. No compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.'
    )
    selected_d_modified = $false
}
$out = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $root $OutputDirectory)) }
if ((Test-Path -LiteralPath $out) -and @(Get-ChildItem -LiteralPath $out -Force).Count -gt 0) { throw "Refusing to overwrite nonempty output directory: $out" }
[IO.Directory]::CreateDirectory($out) | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm256-report.json'), (ConvertTo-Json -InputObject $report -Depth 16) + "`r`n", $utf8)
[IO.File]::WriteAllText((Join-Path $out 'm256-checks.json'), (ConvertTo-Json -InputObject $checks -Depth 14) + "`r`n", $utf8)
Write-Output "PASS: M256 $($checks.check_count)/$($checks.check_count); M-01/M-02 room blocks and the shifted 36-in route compose without modeled overlap."
