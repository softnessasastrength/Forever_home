param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$RunDirectory,
    [string]$CandidateField = 'best_candidate'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = [System.IO.Path]::GetFullPath((Join-Path $root '..'))
$run = (Resolve-Path -LiteralPath $RunDirectory).Path
$errors = New-Object System.Collections.Generic.List[string]
$checksRun = 0

function Assert-Check([bool]$Condition, [string]$Message) {
    $script:checksRun++
    if (-not $Condition) { $script:errors.Add($Message) }
}

function Get-OverlapLength([double]$A0, [double]$A1, [double]$B0, [double]$B1) {
    [Math]::Max(0.0, [Math]::Min($A1, $B1) - [Math]::Max($A0, $B0))
}

function Get-AxisGap([double]$A0, [double]$A1, [double]$B0, [double]$B1) {
    if ($A1 -le $B0) { return ($B0 - $A1) }
    if ($B1 -le $A0) { return ($A0 - $B1) }
    return 0.0
}

function Test-BoxesOverlap($A, $B) {
    ((Get-OverlapLength $A.x_ft ($A.x_ft + $A.width_ft) $B.x_ft ($B.x_ft + $B.width_ft)) -gt 0.000001 -and
        (Get-OverlapLength $A.y_ft ($A.y_ft + $A.depth_ft) $B.y_ft ($B.y_ft + $B.depth_ft)) -gt 0.000001)
}

function Test-RequiredContact($A, $B, [double]$WallGap, [double]$DoorReservation) {
    $gx = Get-AxisGap $A.x_ft ($A.x_ft + $A.width_ft) $B.x_ft ($B.x_ft + $B.width_ft)
    $gy = Get-AxisGap $A.y_ft ($A.y_ft + $A.depth_ft) $B.y_ft ($B.y_ft + $B.depth_ft)
    $overlapY = Get-OverlapLength $A.y_ft ($A.y_ft + $A.depth_ft) $B.y_ft ($B.y_ft + $B.depth_ft)
    $overlapX = Get-OverlapLength $A.x_ft ($A.x_ft + $A.width_ft) $B.x_ft ($B.x_ft + $B.width_ft)
    (($gx -le ($WallGap + 0.000001) -and $gy -lt 0.000001 -and $overlapY -ge ($DoorReservation - 0.000001)) -or
        ($gy -le ($WallGap + 0.000001) -and $gx -lt 0.000001 -and $overlapX -ge ($DoorReservation - 0.000001)))
}

$searchPath = Join-Path $run 'search.json'
$checksPath = Join-Path $run 'checks.json'
$manifestPath = Join-Path $run 'manifest.json'
$svgPath = Join-Path $run 'upper-suite-search.svg'
foreach ($path in @($searchPath, $checksPath, $manifestPath, $svgPath)) {
    Assert-Check (Test-Path -LiteralPath $path -PathType Leaf) "Missing run artifact: $path"
}
if ($errors.Count -gt 0) { throw ($errors -join [Environment]::NewLine) }

$report = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$generatorChecks = Get-Content -LiteralPath $checksPath -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$selectedPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$followupPath = Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$programPath = Join-Path $root 'Requirements/Room_Program.md'
$selectedStudy = Get-Content -LiteralPath $selectedPath -Raw | ConvertFrom-Json

Assert-Check ($generatorChecks.failed.Count -eq 0 -and $generatorChecks.count -gt 0) 'Generator integrity checks include failures or no checks.'
foreach ($property in $generatorChecks.checks.PSObject.Properties) {
    Assert-Check ([bool]$property.Value) "Generator check failed: $($property.Name)"
}
Assert-Check ([string]$manifest.generator -eq 'Tools/test_m37_upper_suite_pack_and_route.ps1') 'Unexpected generator recorded in manifest.'

$sourcePaths = [ordered]@{
    'selected_D_study.json' = $selectedPath
    'owner_followup_study.json' = $followupPath
    'Requirements/Room_Program.md' = $programPath
}
foreach ($key in $sourcePaths.Keys) {
    $expected = [string]$manifest.source_fingerprints_sha256.$key
    $actual = (Get-FileHash -LiteralPath $sourcePaths[$key] -Algorithm SHA256).Hash.ToLowerInvariant()
    Assert-Check ($expected -eq $actual) "Source fingerprint changed or mismatched: $key"
}

$artifactMap = [ordered]@{
    search = $searchPath
    checks = $checksPath
    svg = $svgPath
}
foreach ($key in $artifactMap.Keys) {
    $expected = [string]$manifest.output_hashes_sha256.$key
    $actual = (Get-FileHash -LiteralPath $artifactMap[$key] -Algorithm SHA256).Hash.ToLowerInvariant()
    Assert-Check ($expected -eq $actual) "Output hash mismatched: $key"
}
[xml](Get-Content -LiteralPath $svgPath -Raw) | Out-Null
Assert-Check ($report.failures.Count -eq 0) 'Search report records failed checks.'
Assert-Check (-not [string]::IsNullOrWhiteSpace([string]$report.coordinate_basis.shell_case)) 'Coordinate basis is missing a shell-case label.'
Assert-Check ($report.coordinate_basis.shell_case -match 'unselected proposal|unapproved') 'Exploratory upper shell is not explicitly labelled as unapproved.'

$candidate = $report.$CandidateField
Assert-Check ($null -ne $candidate -and $null -ne $candidate.rectangles) "Candidate field '$CandidateField' is empty."
if ($null -eq $candidate -or $null -eq $candidate.rectangles) {
    $failed = $errors.Count
    foreach ($item in $errors) { Write-Error "FAIL: $item" -ErrorAction Continue }
    Write-Output ("FAILED: {0} of {1} independent checks." -f $failed, $checksRun)
    exit 1
}

$rectangles = $candidate.rectangles
$expectedIds = @('U-01', 'C-PRIVATE', 'U-02', 'U-03', 'U-04', 'U-05', 'U-06')
Assert-Check ((Compare-Object ($expectedIds | Sort-Object) (@($rectangles.PSObject.Properties.Name) | Sort-Object)).Count -eq 0) 'Candidate room/connector inventory differs from the source upper-suite graph.'

$doorValues = @(Get-Content -LiteralPath $selectedPath -Raw | ConvertFrom-Json).upper_door_matrix | ForEach-Object { [double]$_.nominal_reservation_ft } | Sort-Object -Unique
$doorReservation = $doorValues | Where-Object { [Math]::Abs($_ - 3.5) -lt 0.000001 } | Select-Object -First 1
Assert-Check ($null -ne $doorReservation) 'Source 3.5-ft nominal contact reservation was not found.'
$wallGap = 0.5
$shellWidth = [double]$report.coordinate_basis.width_ft
$shellDepth = [double]$report.coordinate_basis.depth_ft

foreach ($id in $expectedIds) {
    $rect = $rectangles.$id
    $source = $report.source_dimensions_ft.$id
    $sameOrientation = [Math]::Abs([double]$rect.width_ft - [double]$source.width_ft) -le 0.000001 -and
        [Math]::Abs([double]$rect.depth_ft - [double]$source.depth_ft) -le 0.000001
    $rotatedOrientation = [Math]::Abs([double]$rect.width_ft - [double]$source.depth_ft) -le 0.000001 -and
        [Math]::Abs([double]$rect.depth_ft - [double]$source.width_ft) -le 0.000001
    Assert-Check ($sameOrientation -or $rotatedOrientation) "$id dimensions differ from documented source dimensions in either allowed orientation."
    Assert-Check ([double]$rect.x_ft -ge -0.000001 -and [double]$rect.y_ft -ge -0.000001 -and
        ([double]$rect.x_ft + [double]$rect.width_ft) -le ($shellWidth + 0.000001) -and
        ([double]$rect.y_ft + [double]$rect.depth_ft) -le ($shellDepth + 0.000001)) "$id lies outside the labelled exploratory shell."
    Assert-Check (-not (Test-BoxesOverlap $rect $report.local_lift_keepout)) "$id overlaps projected lift reservation."
    Assert-Check (-not (Test-BoxesOverlap $rect $report.reserved_stair_approach)) "$id overlaps reserved stair approach."
}

for ($i = 0; $i -lt $expectedIds.Count; $i++) {
    for ($j = $i + 1; $j -lt $expectedIds.Count; $j++) {
        $a = $rectangles.($expectedIds[$i])
        $b = $rectangles.($expectedIds[$j])
        Assert-Check (-not (Test-BoxesOverlap $a $b)) "Room blocks overlap: $($expectedIds[$i]) / $($expectedIds[$j])"
    }
}

$requiredContacts = @(
    @('U-01', 'C-PRIVATE'),
    @('C-PRIVATE', 'U-02'),
    @('U-02', 'U-03'),
    @('U-03', 'U-06'),
    @('U-06', 'U-04'),
    @('U-01', 'U-05')
)
foreach ($edge in $requiredContacts) {
    Assert-Check (Test-RequiredContact $rectangles.($edge[0]) $rectangles.($edge[1]) $wallGap $doorReservation) `
        "Required nominal contact is absent: $($edge[0]) / $($edge[1])"
}

$hall = $candidate.hall_reachability
$publicReached = @($candidate.public_rooms_reached | Sort-Object)
Assert-Check ([bool]$hall.required_public_rooms_reached -and
    (@($publicReached | Where-Object { $_ -in @('U-01', 'U-02', 'U-04') }).Count -eq 3)) 'Candidate does not reach all required public rooms in the sampled hall-route proxy.'
Assert-Check ($report.preserved_constraints -contains 'owner-directed U-02 to U-03 private route only; no direct U-03 to C-UPPER door') 'U-03 private-only constraint is not recorded.'
Assert-Check ($report.preserved_constraints -contains 'owner-required direct U-02 shared-hall arrival; actual opening remains unmodeled') 'U-02 direct hall-arrival requirement is not recorded.'
Assert-Check ($report.preserved_constraints -contains '4ft-wide hall route from source upper landing to U-01, U-02 and U-04; sampled side goals do not establish doors') 'Public route is not labelled as the 4-ft sampled proxy.'

# Recompute the sampled 4-ft hall access from source landing coordinates and
# candidate room blocks. Do not accept the generator's reachability booleans as
# independent evidence. This remains a room-block grid proxy, not door geometry.
$step = [double]$report.search.coordinate_grid_ft
$grid = 1.0 / $step
$maxIx = [int][Math]::Round(($shellWidth - 2.0) * $grid)
$maxIy = [int][Math]::Round(($shellDepth - 2.0) * $grid)
$upperOffset = [double]$selectedStudy.plan_frame_offsets_ft.upper[1]
$landing = $selectedStudy.stair_core_test.main_to_upper.upper_landing_ft
$startX = [double]$landing[0] + [double]$landing[2] / 2.0
$startY = [double]$landing[1] - $upperOffset - 2.0
$startIx = [int][Math]::Round($startX * $grid)
$startIy = [int][Math]::Round($startY * $grid)
$lift = $selectedStudy.stair_core_test.lift
$liftOrigin = @($lift.origin_ft)
$liftKeepout = [pscustomobject]@{x_ft=[double]$liftOrigin[0];y_ft=([double]$liftOrigin[1]-$upperOffset);width_ft=[double]$lift.width_ft;depth_ft=[Math]::Min([double]$lift.depth_ft,($shellDepth-([double]$liftOrigin[1]-$upperOffset)))}
$blocked = [bool[,]]::new($maxIx + 1, $maxIy + 1)
$obstacles = @($rectangles.PSObject.Properties | ForEach-Object { $_.Value }) + @($liftKeepout)
foreach ($obstacle in $obstacles) {
    # Grid centres strictly inside a rectangle expanded by the 2-ft half-width
    # overlap a 4-ft corridor square; endpoint centres only touch and remain clear.
    $minX = [Math]::Max(12,([int][Math]::Floor(([double]$obstacle.x_ft - 2.0) * $grid) + 1))
    $maxX = [Math]::Min($maxIx,([int][Math]::Ceiling(([double]$obstacle.x_ft + [double]$obstacle.width_ft + 2.0) * $grid) - 1))
    $minY = [Math]::Max(12,([int][Math]::Floor(([double]$obstacle.y_ft - 2.0) * $grid) + 1))
    $maxY = [Math]::Min($maxIy,([int][Math]::Ceiling(([double]$obstacle.y_ft + [double]$obstacle.depth_ft + 2.0) * $grid) - 1))
    for ($ix = $minX; $ix -le $maxX; $ix++) {
        for ($iy = $minY; $iy -le $maxY; $iy++) { $blocked[$ix,$iy] = $true }
    }
}
$routeReachable = [bool[,]]::new($maxIx + 1, $maxIy + 1)
$routeDistance = [int[,]]::new($maxIx + 1, $maxIy + 1)
for ($ix = 0; $ix -le $maxIx; $ix++) { for ($iy = 0; $iy -le $maxIy; $iy++) { $routeDistance[$ix,$iy] = -1 } }
$independentRouteValid = $startIx -ge 12 -and $startIx -le $maxIx -and $startIy -ge 12 -and $startIy -le $maxIy
$routeQueue = [System.Collections.Generic.Queue[int]]::new()
if ($independentRouteValid -and -not $blocked[$startIx,$startIy]) {
    $stride = $maxIy + 1
    $routeReachable[$startIx,$startIy] = $true
    $routeDistance[$startIx,$startIy] = 0
    $routeQueue.Enqueue(($startIx * $stride) + $startIy)
    $directions = @(@(1,0),@(-1,0),@(0,1),@(0,-1))
    while ($routeQueue.Count -gt 0) {
        $cell = $routeQueue.Dequeue()
        $cx = [int][Math]::Floor($cell / $stride)
        $cy = $cell - ($cx * $stride)
        foreach ($direction in $directions) {
            $nx = $cx + [int]$direction[0]
            $ny = $cy + [int]$direction[1]
            if ($nx -lt 12 -or $nx -gt $maxIx -or $ny -lt 12 -or $ny -gt $maxIy) { continue }
            if ($routeReachable[$nx,$ny] -or $blocked[$nx,$ny]) { continue }
            $routeReachable[$nx,$ny] = $true
            $routeDistance[$nx,$ny] = $routeDistance[$cx,$cy] + 1
            $routeQueue.Enqueue(($nx * $stride) + $ny)
        }
    }
} else { $independentRouteValid = $false }
$doorSamples = [int]$report.search.public_door_edge_samples
$independentSides = [ordered]@{}
$bestGoals = [ordered]@{}
foreach ($id in @('U-01','U-02','U-04')) {
    $room = $rectangles.$id
    $minXTick = [int][Math]::Ceiling((([double]$room.x_ft + $doorReservation / 2.0) / $step))
    $maxXTick = [int][Math]::Floor((([double]$room.x_ft + [double]$room.width_ft - $doorReservation / 2.0) / $step))
    $minYTick = [int][Math]::Ceiling((([double]$room.y_ft + $doorReservation / 2.0) / $step))
    $maxYTick = [int][Math]::Floor((([double]$room.y_ft + [double]$room.depth_ft - $doorReservation / 2.0) / $step))
    $reachableSides = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $bestGoal = $null
    for ($sample = 0; $sample -lt $doorSamples; $sample++) {
        $t = if ($doorSamples -eq 1) { 0.5 } else { $sample / [double]($doorSamples - 1) }
        $xTick = [int][Math]::Round($minXTick + ($maxXTick - $minXTick) * $t)
        $yTick = [int][Math]::Round($minYTick + ($maxYTick - $minYTick) * $t)
        $x = $xTick * $step; $y = $yTick * $step
        $goals = @(
            [pscustomobject]@{side='west';x=([double]$room.x_ft-2.5);y=$y},
            [pscustomobject]@{side='east';x=([double]$room.x_ft+[double]$room.width_ft+2.5);y=$y},
            [pscustomobject]@{side='south';x=$x;y=([double]$room.y_ft-2.5)},
            [pscustomobject]@{side='north';x=$x;y=([double]$room.y_ft+[double]$room.depth_ft+2.5)}
        )
        foreach ($goal in $goals) {
            $gx = [int][Math]::Round([double]$goal.x * $grid)
            $gy = [int][Math]::Round([double]$goal.y * $grid)
            if ([Math]::Abs($gx / $grid - [double]$goal.x) -gt 0.000001 -or [Math]::Abs($gy / $grid - [double]$goal.y) -gt 0.000001) { continue }
            if ($gx -ge 12 -and $gx -le $maxIx -and $gy -ge 12 -and $gy -le $maxIy -and $routeReachable[$gx,$gy] -and -not $blocked[$gx,$gy]) {
                [void]$reachableSides.Add([string]$goal.side)
                $distance = $routeDistance[$gx,$gy]
                if ($null -eq $bestGoal -or $distance -lt $bestGoal.route_steps) {
                    $edgeX = if ($goal.side -in @('north','south')) { $x } elseif ($goal.side -eq 'west') { [double]$room.x_ft } else { [double]$room.x_ft + [double]$room.width_ft }
                    $edgeY = if ($goal.side -in @('west','east')) { $y } elseif ($goal.side -eq 'south') { [double]$room.y_ft } else { [double]$room.y_ft + [double]$room.depth_ft }
                    $bestGoal = [pscustomobject]@{side=[string]$goal.side;edge_center_x_ft=[Math]::Round($edgeX,4);edge_center_y_ft=[Math]::Round($edgeY,4);outside_goal_x_ft=[Math]::Round([double]$goal.x,4);outside_goal_y_ft=[Math]::Round([double]$goal.y,4);route_steps=$distance;route_length_ft=[Math]::Round($distance * $step,3)}
                }
            }
        }
    }
    $independentSides[$id] = @($reachableSides | Sort-Object)
    $bestGoals[$id] = $bestGoal
    $reportedSides = @($candidate.hall_reachability.reachable_room_sides.$id | Sort-Object -Unique)
    Assert-Check ((Compare-Object @($independentSides[$id]) $reportedSides).Count -eq 0) "Independent route replay disagrees with reported reachable sides for $id."
}
Assert-Check $independentRouteValid 'Source upper-landing approach is blocked in the independent route replay.'
Assert-Check ($independentSides['U-02'].Count -gt 0) 'The owner-required direct U-02 hall arrival is not independently reachable in the 4-ft grid proxy.'
Assert-Check ($independentSides['U-01'].Count -gt 0 -and $independentSides['U-04'].Count -gt 0) 'A required public-room hall goal is not independently reachable in the 4-ft grid proxy.'

if ($errors.Count -gt 0) {
    foreach ($item in $errors) { Write-Error "FAIL: $item" -ErrorAction Continue }
    Write-Output ("FAILED: {0} of {1} independent checks." -f $errors.Count, $checksRun)
    exit 1
}

Write-Output ("PASS: {0} independent checks. Candidate {1}; shell {2} x {3} ft is explicitly exploratory/unapproved; sampled public hall route reaches U-01, U-02 ({4}) and U-04. Nearest U-02 wall-edge sample is {5} at ({6},{7}) ft; outside hall goal is ({8},{9}) ft, {10} ft from the landing-approach grid start. These are not door or compliance findings." -f $checksRun, $candidate.layout_key, $shellWidth, $shellDepth, (@($independentSides['U-02']) -join ','), $bestGoals['U-02'].side, $bestGoals['U-02'].edge_center_x_ft, $bestGoals['U-02'].edge_center_y_ft, $bestGoals['U-02'].outside_goal_x_ft, $bestGoals['U-02'].outside_goal_y_ft, $bestGoals['U-02'].route_length_ft)
