param(
    [string]$CandidateRunDirectory = (Join-Path $PSScriptRoot '../Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29'),
    [string]$OutputDirectory = 'Architecture/M79_U02_Hall_Approach_Slot_2026-10-29'
)

$ErrorActionPreference = 'Stop'
$repo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$candidateRun = (Resolve-Path -LiteralPath $CandidateRunDirectory).Path
$candidateFile = Join-Path $candidateRun 'search.json'
$manifestFile = Join-Path $candidateRun 'manifest.json'
$selectedFile = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$candidate = Get-Content -LiteralPath $candidateFile -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $manifestFile -Raw | ConvertFrom-Json
$selected = Get-Content -LiteralPath $selectedFile -Raw | ConvertFrom-Json
$candidateHash = (Get-FileHash -LiteralPath $candidateFile -Algorithm SHA256).Hash.ToLowerInvariant()
$selectedHash = (Get-FileHash -LiteralPath $selectedFile -Algorithm SHA256).Hash.ToLowerInvariant()

if ($candidateHash -ne $manifest.output_hashes_sha256.search) { throw 'M78 candidate report does not match its retained manifest.' }
if ($selectedHash -ne $candidate.source_fingerprints_sha256.'selected_D_study.json' -or
    $selectedHash -ne $manifest.source_fingerprints_sha256.'selected_D_study.json') { throw 'Selected-D source fingerprint differs from the M78 candidate or manifest.' }
if ($candidate.coordinate_basis.width_ft -ne 38.333333 -or $candidate.coordinate_basis.depth_ft -ne 40 -or
    $candidate.coordinate_basis.shell_case -notmatch 'hypothetical|unselected') { throw 'Expected the owner-authorized hypothetical M78 shell case.' }
if ($null -eq $candidate.best_candidate -or -not $candidate.best_candidate.hall_reachability.required_public_rooms_reached) { throw 'M78 has no route-valid public-room candidate.' }
if ($candidate.best_candidate.hall_reachability.u03_hall_side_reachable) { throw 'M78 candidate contradicts the private-only U-03 route requirement.' }

$room = $candidate.best_candidate.rectangles.'U-02'
$approach = $candidate.reserved_stair_approach
$doorWidths = @($selected.upper_door_matrix | ForEach-Object { [double]$_.nominal_reservation_ft } | Sort-Object -Unique)
$nominalReservationFt = $doorWidths | Where-Object { [Math]::Abs($_ - 3.5) -lt 0.000001 } | Select-Object -First 1
if ($null -eq $nominalReservationFt) { throw 'Selected-D source has no nominal 3.5 ft door reservation.' }
if (-not @($candidate.best_candidate.hall_reachability.reachable_room_sides.'U-02' | Where-Object { $_ -eq 'north' }).Count) { throw 'The M78 winner has no north-side U-02 hall reachability sample.' }

$wallY = [double]$room.y_ft + [double]$room.depth_ft
$centerX = [double]$approach.x_ft + ([double]$approach.width_ft / 2.0)
$approachCenterY = [double]$approach.y_ft + ([double]$approach.depth_ft / 2.0)
$roomCenterX = [double]$room.x_ft + ([double]$room.width_ft / 2.0)
$openingStartX = $centerX - ($nominalReservationFt / 2.0)
$openingEndX = $centerX + ($nominalReservationFt / 2.0)
$approachGap = [double]$approach.y_ft - $wallY
$wallToGoal = $approachCenterY - $wallY
$checks = [ordered]@{
    M78_candidate_fingerprint_matches_manifest = ($candidateHash -eq $manifest.output_hashes_sha256.search)
    selected_D_fingerprint_matches_candidate_and_manifest = ($selectedHash -eq $candidate.source_fingerprints_sha256.'selected_D_study.json' -and $selectedHash -eq $manifest.source_fingerprints_sha256.'selected_D_study.json')
    test_shell_is_explicitly_hypothetical_M78 = ($candidate.coordinate_basis.width_ft -eq 38.333333 -and $candidate.coordinate_basis.depth_ft -eq 40 -and $candidate.coordinate_basis.shell_case -match 'hypothetical|unselected')
    owner_direct_U02_public_route_requirement_reaches_candidate = [bool]$candidate.best_candidate.hall_reachability.required_public_rooms_reached
    U02_north_edge_has_a_hall_route_sample = (@($candidate.best_candidate.hall_reachability.reachable_room_sides.'U-02' | Where-Object { $_ -eq 'north' }).Count -gt 0)
    U03_has_no_public_side_reach = (-not [bool]$candidate.best_candidate.hall_reachability.u03_hall_side_reachable)
    selected_D_nominal_reservation_is_3_5_ft = ([Math]::Abs([double]$nominalReservationFt - 3.5) -lt 0.000001)
    nominal_slot_is_contained_on_U02_north_edge = ($openingStartX -ge [double]$room.x_ft -and $openingEndX -le ([double]$room.x_ft + [double]$room.width_ft))
    slot_center_aligns_with_landing_approach_centerline = ([Math]::Abs($centerX - $roomCenterX) -lt 0.000001)
    source_selected_D_unchanged_during_run = ((Get-FileHash -LiteralPath $selectedFile -Algorithm SHA256).Hash.ToLowerInvariant() -eq $selectedHash)
}
$failures = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failures.Count -gt 0) { throw "M79 checks failed: $($failures -join ', ')" }

$report = [ordered]@{
    schema = 'forever-home-m79-u02-hall-approach-slot-v1'
    checked_on = '2026-10-29'
    status = 'Schematic north-edge nominal door-reservation alignment test only; no actual door or building dimension selected.'
    source = [ordered]@{
        M78_candidate = 'Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/search.json'
        selected_D_study = 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
        M78_report_sha256 = $candidateHash
        selected_D_sha256 = $selectedHash
    }
    shell_test = [ordered]@{width_ft=[double]$candidate.coordinate_basis.width_ft;depth_ft=[double]$candidate.coordinate_basis.depth_ft;status='hypothetical, unselected test envelope'}
    U02_north_edge = [ordered]@{x_start_ft=[double]$room.x_ft;x_end_ft=[double]$room.x_ft+[double]$room.width_ft;y_ft=$wallY;length_ft=[double]$room.width_ft}
    nominal_wall_edge_reservation = [ordered]@{width_ft=[double]$nominalReservationFt;center_x_ft=$centerX;x_start_ft=$openingStartX;x_end_ft=$openingEndX;source='selected-D upper_door_matrix nominal_reservation_ft';status='reserved test interval, not a modeled clear opening'}
    reserved_landing_approach = [ordered]@{x_start_ft=[double]$approach.x_ft;x_end_ft=[double]$approach.x_ft+[double]$approach.width_ft;y_start_ft=[double]$approach.y_ft;y_end_ft=[double]$approach.y_ft+[double]$approach.depth_ft;center_x_ft=$centerX;center_y_ft=$approachCenterY;width_ft=[double]$approach.width_ft;depth_ft=[double]$approach.depth_ft;source='selected-D stair/landing approach carried through M78'}
    derived_alignment = [ordered]@{room_center_x_ft=$roomCenterX;approach_center_x_ft=$centerX;horizontal_centerline_offset_ft=[Math]::Round([Math]::Abs($centerX-$roomCenterX),6);north_wall_to_approach_box_gap_ft=[Math]::Round($approachGap,6);north_wall_to_approach_center_ft=[Math]::Round($wallToGoal,6);nominal_side_margin_each_ft=[Math]::Round(($room.width_ft-$nominalReservationFt)/2.0,6)}
    U02_hall_route_sample = [ordered]@{reachable_north_edge=$true;room_id='U-02';room_side='north';source='M78 winner reachability plus independent 112-check candidate validation';actual_door_opening=$false}
    limitations = @(
        'The 3.5 ft value is a nominal source contact reservation, not a verified clear opening, door leaf size, or accessibility clearance.',
        'No wall, door family, frame, jamb, sill, swing, latch, privacy control, wall thickness, or actual hall path is modeled.',
        'The 4 ft landing-approach square is a plan proxy inherited from selected D; it does not prove a door can connect without a wall or stair conflict.',
        'The 38.333333 x 40 ft envelope remains an unselected hypothetical test case.',
        'This screen is not code compliance, accessibility review, fire/life-safety review, structural assessment, or construction documentation.'
    )
    checks = $checks
    failures = $failures
}

$resolvedOutputDirectory = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) { [System.IO.Path]::GetFullPath($OutputDirectory) } else { [System.IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$repoPrefix = $repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutputDirectory.StartsWith($repoPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $resolvedOutputDirectory)) { New-Item -ItemType Directory -Path $resolvedOutputDirectory -Force | Out-Null }
$jsonPath = Join-Path $resolvedOutputDirectory 'u02-approach-slot.json'
$svgPath = Join-Path $resolvedOutputDirectory 'u02-approach-slot.svg'
ConvertTo-Json -InputObject $report -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding utf8

$scale = 36.0
$originX = 180.0
$leftWorld = 8.0
$topPixel = 88.0
$topWorldY = 34.0
$mapX = { param([double]$x) ($originX + (($x - $leftWorld) * $scale)) }
$mapY = { param([double]$y) ($topPixel + (($topWorldY - $y) * $scale)) }
$roomLeft = & $mapX ([double]$room.x_ft)
$roomRight = & $mapX ([double]$room.x_ft + [double]$room.width_ft)
$roomTop = & $mapY $wallY
$roomBottom = & $mapY ([double]$room.y_ft)
$approachLeft = & $mapX ([double]$approach.x_ft)
$approachRight = & $mapX ([double]$approach.x_ft + [double]$approach.width_ft)
$approachTop = & $mapY ([double]$approach.y_ft + [double]$approach.depth_ft)
$approachBottom = & $mapY ([double]$approach.y_ft)
$centerPixelX = & $mapX $centerX
$goalPixelY = & $mapY $approachCenterY
$openingPixelLeft = & $mapX $openingStartX
$openingPixelRight = & $mapX $openingEndX
$svg = @(
    '<svg xmlns="http://www.w3.org/2000/svg" width="1100" height="800" viewBox="0 0 1100 800">',
    '<title>M79 U-02 nominal hall approach slot alignment test</title>',
    '<style>text{font-family:Arial,sans-serif;fill:#253342}.title{font-size:26px;font-weight:700}.label{font-size:18px}.small{font-size:15px}.room{fill:#dfe9ef;stroke:#334b5c;stroke-width:3}.approach{fill:#f5c96a;fill-opacity:.38;stroke:#9a6815;stroke-width:3;stroke-dasharray:10 7}.wall{stroke:#243c50;stroke-width:8}.slot{stroke:#177245;stroke-width:11;stroke-dasharray:12 6}.center{stroke:#bd513b;stroke-width:2;stroke-dasharray:7 6}.marker{fill:#bd513b}.note{fill:#6a3d30}</style>',
    '<text class="title" x="48" y="42">M79 | U-02 hall-side approach alignment (schematic)</text>',
    ('<rect class="room" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $roomLeft,$roomTop,($roomRight-$roomLeft),($roomBottom-$roomTop)),
    ('<text class="label" x="{0}" y="{1}">U-02 | {2} x {3} ft source room block</text>' -f ($roomLeft+28),($roomTop+110),[Math]::Round($room.width_ft,3),[Math]::Round($room.depth_ft,3)),
    ('<rect class="approach" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $approachLeft,$approachTop,($approachRight-$approachLeft),($approachBottom-$approachTop)),
    ('<text class="label" x="{0}" y="{1}">Reserved 4 x 4 ft landing approach</text>' -f ($approachLeft-35),($approachTop-14)),
    ('<line class="wall" x1="{0}" y1="{1}" x2="{2}" y2="{1}"/>' -f $roomLeft,$roomTop,$roomRight),
    ('<line class="slot" x1="{0}" y1="{1}" x2="{2}" y2="{1}"/>' -f $openingPixelLeft,$roomTop,$openingPixelRight),
    ('<line class="center" x1="{0}" y1="{1}" x2="{0}" y2="{2}"/>' -f $centerPixelX,$roomTop,$goalPixelY),
    ('<circle class="marker" cx="{0}" cy="{1}" r="7"/>' -f $centerPixelX,$goalPixelY),
    ('<text class="small" x="{0}" y="{1}">Nominal {2} ft reservation: x={3}..{4} ft</text>' -f ($openingPixelLeft-70),($roomTop-20),$nominalReservationFt,[Math]::Round($openingStartX,3),[Math]::Round($openingEndX,3)),
    ('<text class="small" x="{0}" y="{1}">Aligned center x={2} ft; hall-goal center y={3} ft</text>' -f ($approachLeft-110),($approachBottom+34),[Math]::Round($centerX,3),[Math]::Round($approachCenterY,3)),
    '<text class="small note" x="48" y="740">Green dash is a nominal wall-edge reservation, not an actual door or clear opening. No swing, wall, jamb, or path geometry.</text>',
    '<text class="small note" x="48" y="766">38.333333 x 40 ft remains an unselected hypothetical test shell; see accompanying JSON for source checks and limits.</text>',
    '</svg>'
)
$svg -join "`n" | Set-Content -LiteralPath $svgPath -Encoding utf8
[xml](Get-Content -LiteralPath $svgPath -Raw) | Out-Null
$svgHash = (Get-FileHash -LiteralPath $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()
$jsonHash = (Get-FileHash -LiteralPath $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output ("M79 checks passed: {0}/{1}; nominal slot x={2}..{3} ft on U-02 north edge; centered on approach at ({4},{5}) ft. JSON SHA256 {6}; SVG SHA256 {7}." -f $checks.Count,($checks.Count+$failures.Count),[Math]::Round($openingStartX,3),[Math]::Round($openingEndX,3),[Math]::Round($centerX,3),[Math]::Round($approachCenterY,3),$jsonHash,$svgHash)
