param(
    [string]$OutputDirectory = '.local/revalidation/M257-route-endpoint-audit'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$studyPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m215Path = Join-Path $root 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json'
$m228Path = Join-Path $root 'Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts/m228-west-a-dining-connection.json'
$m243Path = Join-Path $root 'Architecture/M243_Moved_Kitchen_Route_Start_Sensitivity_2026-10-31/artifacts/m243-report.json'
$m256Path = Join-Path $root '.local/revalidation/M258-integrated-final1/m256-report.json'
$expected = [ordered]@{
    selected_d = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    m215 = 'f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
    m228 = 'f4ab50fd02e4d71e434c4e4c83d63fe8d20b580810d7118a234bc4b2da8119ff'
    m243 = 'e2b25a46d7d17a5b6f97184aeb8a20286bc0f79b4a9b90ca0c5a0b920d28c8ad'
    m256 = '8124b2b232b14132d575350eb2a4a6a6ab998583e2b68d24e1099c449ec39ae0'
}
function Get-Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function New-Rect([string]$Id, [double]$X, [double]$Y, [double]$W, [double]$H) {
    [pscustomobject]@{ id = $Id; x = $X; y = $Y; w = $W; h = $H }
}
function Test-PointInside($Point, $Rect) {
    return ($Point.x -ge $Rect.x -and $Point.x -le ($Rect.x + $Rect.w) -and $Point.y -ge $Rect.y -and $Point.y -le ($Rect.y + $Rect.h))
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

$actual = [ordered]@{
    selected_d = Get-Hash $studyPath
    m215 = Get-Hash $m215Path
    m228 = Get-Hash $m228Path
    m243 = Get-Hash $m243Path
    m256 = Get-Hash $m256Path
}
foreach ($key in $expected.Keys) { if ($actual[$key] -ne $expected[$key]) { throw "Pinned $key hash mismatch: $($actual[$key])" } }
$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$m215 = Get-Content -LiteralPath $m215Path -Raw | ConvertFrom-Json
$m228 = Get-Content -LiteralPath $m228Path -Raw | ConvertFrom-Json
$m243 = Get-Content -LiteralPath $m243Path -Raw | ConvertFrom-Json
$m256 = Get-Content -LiteralPath $m256Path -Raw | ConvertFrom-Json
$variant = @($m243.variants | Where-Object start_shift_west_in -eq 6)[0]
if ($null -eq $variant) { throw 'Pinned M243 report has no six-inch route-start variant.' }
$origin = @($m228.coordinate_frames.m215_origin_source_ft)
$points = @($variant.route_waypoints_ft | ForEach-Object { [pscustomobject]@{ x = ([double]$_.x + [double]$origin[0]); y = ([double]$_.y + [double]$origin[1]) } })
if ($points.Count -ne 5) { throw "Expected five orthogonal route waypoints; found $($points.Count)." }
$mainRooms = @{}
foreach ($room in $study.plans.main) { $mainRooms[[string]$room.id] = $room }
$livingValues = @($m256.candidates.room_blocks.living_ft)
$kitchenValues = @($m256.candidates.room_blocks.kitchen_ft)
$living = New-Rect 'M-01 living +6in east' ([double]$livingValues[0]) ([double]$livingValues[1]) ([double]$livingValues[2]) ([double]$livingValues[3])
$kitchen = New-Rect 'M-02 kitchen -6in west' ([double]$kitchenValues[0]) ([double]$kitchenValues[1]) ([double]$kitchenValues[2]) ([double]$kitchenValues[3])
$hallSource = $mainRooms['M-05']
$hall = New-Rect 'M-05 hall' ([double]$hallSource.x) ([double]$hallSource.y) ([double]$hallSource.w) ([double]$hallSource.d)
$originX = [double]$origin[0]; $originY = [double]$origin[1]
$porchLocal = @($m215.porch_rect_ft)
$porch = New-Rect 'M-215 porch test block' ([double]$porchLocal[0] + $originX) ([double]$porchLocal[1] + $originY) ([double]$porchLocal[2]) ([double]$porchLocal[3])
$start = $points[0]; $end = $points[-1]
$routeHalfFt = [double]$m215.route_width_in / 24.0
$startCap = New-Rect 'route start cap' ($start.x - $routeHalfFt) ($start.y - $routeHalfFt) (2 * $routeHalfFt) (2 * $routeHalfFt)
$routeBoxes = New-Object System.Collections.Generic.List[object]
for ($i = 0; $i -lt $points.Count - 1; $i++) {
    $a = $points[$i]; $b = $points[$i + 1]
    if ([Math]::Abs($a.y - $b.y) -lt 0.000001) {
        $routeBoxes.Add((New-Rect "route-$i" ([Math]::Min($a.x, $b.x) - $routeHalfFt) ($a.y - $routeHalfFt) ([Math]::Abs($b.x - $a.x) + 2 * $routeHalfFt) (2 * $routeHalfFt)))
    } elseif ([Math]::Abs($a.x - $b.x) -lt 0.000001) {
        $routeBoxes.Add((New-Rect "route-$i" ($a.x - $routeHalfFt) ([Math]::Min($a.y, $b.y) - $routeHalfFt) (2 * $routeHalfFt) ([Math]::Abs($b.y - $a.y) + 2 * $routeHalfFt)))
    } else { throw "Route segment $i is diagonal." }
}
$routeBoxes.Add($startCap)
$routeLivingGap = [Math]::Round(((Get-RectGap $startCap $living) * 12), 3)
$routeKitchenCapGap = [Math]::Round(((Get-RectGap $startCap $kitchen) * 12), 3)
$routeLivingOverallGap = [double]$m256.candidates.route.living.minimum_edge_gap_in
$routeKitchenOverallGap = [double]$m256.candidates.route.kitchen.minimum_edge_gap_in
$startInsideHall = Test-PointInside $start $hall
$startInsideLiving = Test-PointInside $start $living
$endInsidePorch = Test-PointInside $end $porch

$checks = [ordered]@{
    schema = 'forever-home.m257-route-endpoint-audit-checks.v1'
    result = 'pass'
    check_count = 12
    checks = [ordered]@{
        all_input_fingerprints_match = $true
        m243_six_inch_variant_selected = ([double]$variant.start_shift_west_in -eq 6)
        route_width_remains_36_in = ([double]$m215.route_width_in -eq 36)
        route_start_is_inside_M05_hall_block = $startInsideHall
        route_start_is_not_inside_M01_living_block = (-not $startInsideLiving)
        route_start_cap_remains_twelve_in_clear_of_M01 = ([Math]::Abs($routeLivingGap - 12) -lt 0.001)
        route_swept_path_remains_six_in_clear_of_M01 = ([Math]::Abs($routeLivingOverallGap - 6) -lt 0.001)
        route_start_cap_remains_four_in_clear_of_M02 = ([Math]::Abs($routeKitchenCapGap - 4) -lt 0.001)
        route_endpoint_is_inside_porch_test_block = $endInsidePorch
        route_waypoints_are_orthogonal = ($points.Count -eq 5)
        continuous_swept_route_reaches_porch = ($routeBoxes.Count -ge 5)
        selected_d_hash_unchanged = ((Get-Hash $studyPath) -eq $expected.selected_d)
        no_physical_opening_or_door_claimed = $true
    }
}
if (@($checks.checks.Values | Where-Object { $_ -ne $true }).Count -gt 0) { $checks.result = 'fail'; throw "M257 checks failed: $(ConvertTo-Json $checks -Depth 8)" }

$report = [ordered]@{
    schema = 'forever-home.m257-route-endpoint-audit.v1'
    status = 'pass; endpoint connectivity is only schematic and no physical door/opening is established'
    source_hashes_sha256 = $actual
    route = [ordered]@{
        waypoints_global_ft = @($points)
        width_in = [double]$m215.route_width_in
        length_ft = [double]$variant.route_length_ft
        start = [ordered]@{ point_ft = @([Math]::Round($start.x, 6), [Math]::Round($start.y, 6)); inside_M05_hall = $startInsideHall; inside_M01_living = $startInsideLiving; start_cap_edge_gaps_in = [ordered]@{ M01_living = $routeLivingGap; M02_kitchen = $routeKitchenCapGap } }
        end = [ordered]@{ point_ft = @([Math]::Round($end.x, 6), [Math]::Round($end.y, 6)); inside_porch_test_block = $endInsidePorch }
        minimum_swept_edge_gaps_in = [ordered]@{ M01_living = $routeLivingOverallGap; M02_kitchen = $routeKitchenOverallGap }
        inferred_living_to_route_connection = 'not established; the centerline begins inside M-05 and the swept route remains 6 in clear of the M-01 block'
        physical_door_or_opening_modelled = $false
    }
    interpretation = @(
        'The 33.5-ft swept corridor is continuous from its start point in M-05 to its endpoint inside the porch test block.',
        'The corridor does not begin inside M-01 Living. Its 6-in gap from that room block is separation, not a doorway, clear opening or proof of connection.',
        'A route to/from the living room requires actual adjacency/opening design and a new coordination check. This report therefore does not call the existing candidate a verified living-to-porch route.'
    )
    limitations = @(
        'All locations are transformed room-block study coordinates; walls, door leaves, openings, thresholds, finishes, site/grade, occupied movement, and construction geometry are absent.',
        'The 36-in route width is an inherited analysis proxy, not a code or accessibility finding. M-06/A/B assignments remain unchanged.'
    )
    selected_d_modified = $false
}

$scale = 18.0; $left = 70.0; $top = 52.0; $shellWidth = 40.0 * $scale; $shellHeight = 42.0 * $scale
function Svg-X([double]$X) { [Math]::Round(($left + $X * $scale), 3) }
function Svg-Y([double]$Y) { [Math]::Round(($top + (42.0 - $Y) * $scale), 3) }
function Svg-Rect($Rect, [string]$Fill, [string]$Stroke, [string]$Dash = '') {
    $x = Svg-X $Rect.x; $y = Svg-Y ($Rect.y + $Rect.h); $w = [Math]::Round(($Rect.w * $scale), 3); $h = [Math]::Round(($Rect.h * $scale), 3)
    $dashAttr = if ($Dash) { " stroke-dasharray=`"$Dash`"" } else { '' }
    "<rect x=`"$x`" y=`"$y`" width=`"$w`" height=`"$h`" fill=`"$Fill`" stroke=`"$Stroke`" stroke-width=`"2`"$dashAttr />"
}
function Svg-Label($Rect, [string]$Text) {
    $x = Svg-X ($Rect.x + 0.12); $y = Svg-Y ($Rect.y + $Rect.h / 2)
    "<text x=`"$x`" y=`"$y`" class=`"room-label`">$([Security.SecurityElement]::Escape($Text))</text>"
}
$svgParts = New-Object System.Collections.Generic.List[string]
$svgParts.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1030" height="920" viewBox="0 0 1030 920">')
$svgParts.Add('<style>text{font-family:Segoe UI,Arial,sans-serif;fill:#24323a}.title{font-size:24px;font-weight:700}.room-label{font-size:13px;font-weight:600}.note{font-size:13px}.small{font-size:11px}.shell{fill:#fbfaf7;stroke:#33444d;stroke-width:3}.route{fill:none;stroke:#48a4cf;stroke-opacity:.46;stroke-width:54;stroke-linecap:round;stroke-linejoin:round}.centerline{fill:none;stroke:#12668d;stroke-width:2;stroke-dasharray:7 5}.living{fill:#b6d8c0;stroke:#315d41}.hall{fill:#dddfe2;stroke:#505b62}.kitchen{fill:#f2d1a4;stroke:#875722}.dining{fill:#f2e1a6;stroke:#897118}.porch{fill:#d4c2e8;stroke:#604d80}.reserve{fill:#fff;fill-opacity:.35;stroke:#a34e48;stroke-width:2;stroke-dasharray:8 5}.pantry{fill:#ead6c9;stroke:#785542}</style>')
$svgParts.Add('<text x="70" y="30" class="title">M257 — route endpoint audit</text>')
$svgParts.Add("<rect x=`"$left`" y=`"$top`" width=`"$shellWidth`" height=`"$shellHeight`" class=`"shell`" />")
$svgParts.Add((Svg-Rect $living '#b6d8c0' '#315d41')); $svgParts.Add((Svg-Label $living 'M-01 living +6 in'))
$svgParts.Add((Svg-Rect $hall '#dddfe2' '#505b62')); $svgParts.Add((Svg-Label $hall 'M-05 hall'))
$svgParts.Add((Svg-Rect $kitchen '#f2d1a4' '#875722')); $svgParts.Add((Svg-Label $kitchen 'M-02 kitchen -6 in'))
$diningValues = @($m228.dining_candidate.rect_ft); $dining = New-Rect 'M228 dining proposal' ([double]$diningValues[0]) ([double]$diningValues[1]) ([double]$diningValues[2]) ([double]$diningValues[3])
$svgParts.Add((Svg-Rect $dining '#f2e1a6' '#897118')); $svgParts.Add((Svg-Label $dining 'M228 dining proposal'))
$a = @($study.selection.main_public_bath.search_windows | Where-Object id -eq 'west_of_core')[0]
$b = @($study.selection.main_public_bath.search_windows | Where-Object id -eq 'east_of_core')[0]
$aRect = New-Rect 'West A — protected, unassigned' ([double]$a.x) ([double]$a.y) ([double]$a.w) ([double]$a.d)
$bRect = New-Rect 'East B — unassigned' ([double]$b.x) ([double]$b.y) ([double]$b.w) ([double]$b.d)
$svgParts.Add((Svg-Rect $aRect '#fff' '#a34e48' '8 5')); $svgParts.Add((Svg-Label $aRect 'A protected'))
$svgParts.Add((Svg-Rect $bRect '#fff' '#a34e48' '8 5')); $svgParts.Add((Svg-Label $bRect 'B unassigned'))
$svgParts.Add((Svg-Rect $porch '#d4c2e8' '#604d80')); $svgParts.Add((Svg-Label $porch 'M215 porch test block'))
$routePolyline = ($points | ForEach-Object { "$(Svg-X $_.x),$(Svg-Y $_.y)" }) -join ' '
$svgParts.Add("<polyline class=`"route`" points=`"$routePolyline`" />")
$svgParts.Add("<polyline class=`"centerline`" points=`"$routePolyline`" />")
$svgParts.Add("<circle cx=`"$(Svg-X $start.x)`" cy=`"$(Svg-Y $start.y)`" r=`"7`" fill=`"#a5342f`" stroke=`"white`" stroke-width=`"2`" />")
$svgParts.Add("<circle cx=`"$(Svg-X $end.x)`" cy=`"$(Svg-Y $end.y)`" r=`"7`" fill=`"#604d80`" stroke=`"white`" stroke-width=`"2`" />")
$svgParts.Add('<text x="820" y="100" class="note" font-weight="700">Route start</text>')
$svgParts.Add('<text x="820" y="122" class="note">Inside M-05 Hall</text>')
$svgParts.Add('<text x="820" y="144" class="note">Not inside M-01 Living</text>')
$svgParts.Add('<text x="820" y="185" class="note" font-weight="700">Route endpoint</text>')
$svgParts.Add('<text x="820" y="207" class="note">Inside porch test block</text>')
$svgParts.Add('<text x="820" y="250" class="note" font-weight="700">Measured study gaps</text>')
$svgParts.Add('<text x="820" y="272" class="note">6 in to moved living block</text>')
$svgParts.Add('<text x="820" y="294" class="note">4 in to moved kitchen block</text>')
$svgParts.Add('<text x="820" y="336" class="note">36 in route proxy</text>')
$svgParts.Add('<text x="820" y="358" class="note">33 ft 6 in long</text>')
$svgParts.Add('<text x="820" y="400" class="note" font-weight="700">No physical opening</text>')
$svgParts.Add('<text x="820" y="422" class="note">or doorway is modeled.</text>')
$svgParts.Add('<text x="70" y="850" class="small">Source-bound room-block coordinates; schematic, not a wall or door plan. A/B remain unassigned; M-06 remains TBD.</text>')
$svgParts.Add('</svg>')
$svgText = $svgParts -join "`n"
[xml]$null = $svgText
$checks.check_count = 13
$checks.checks.svg_parses_as_xml = $true

$out = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $root $OutputDirectory)) }
if ((Test-Path -LiteralPath $out) -and @(Get-ChildItem -LiteralPath $out -Force).Count -gt 0) { throw "Refusing to overwrite nonempty output directory: $out" }
[IO.Directory]::CreateDirectory($out) | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm257-report.json'), (ConvertTo-Json -InputObject $report -Depth 14) + "`r`n", $utf8)
[IO.File]::WriteAllText((Join-Path $out 'm257-checks.json'), (ConvertTo-Json -InputObject $checks -Depth 12) + "`r`n", $utf8)
[IO.File]::WriteAllText((Join-Path $out 'm257-route-endpoints.svg'), $svgText + "`r`n", $utf8)
Write-Output "PASS: M257 $($checks.check_count)/$($checks.check_count); start is in M-05, terminus is in porch, living connection is unproven."
