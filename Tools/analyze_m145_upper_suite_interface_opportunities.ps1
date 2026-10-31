param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M145_Upper_Suite_Interface_Opportunities_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m132Directory = Join-Path $repo 'Architecture/M132_Primary_Bath_Interface_2026-10-30'
$m132LayoutPath = Join-Path $m132Directory 'm132-layouts.json'
$m132ChecksPath = Join-Path $m132Directory 'm132-checks.json'
$routePath = Join-Path $m132Directory 'm132-route-validation.json'
$selectedDPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$ownerDecisionPath = Join-Path $repo 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
$roomProgramPath = Join-Path $repo 'Requirements/Room_Program.md'

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Test-Pair($Door, [string]$RoomA, [string]$RoomB) {
    return (([string]$Door.a -eq $RoomA -and [string]$Door.b -eq $RoomB) -or ([string]$Door.a -eq $RoomB -and [string]$Door.b -eq $RoomA))
}

function Get-Contact($BoxA, $BoxB, [double]$WallBand, [double]$Tolerance) {
    $ax0 = [double]$BoxA.x; $ay0 = [double]$BoxA.y; $ax1 = $ax0 + [double]$BoxA.w; $ay1 = $ay0 + [double]$BoxA.d
    $bx0 = [double]$BoxB.x; $by0 = [double]$BoxB.y; $bx1 = $bx0 + [double]$BoxB.w; $by1 = $by0 + [double]$BoxB.d
    $verticalOverlap = [Math]::Min($ay1, $by1) - [Math]::Max($ay0, $by0)
    $horizontalOverlap = [Math]::Min($ax1, $bx1) - [Math]::Max($ax0, $bx0)
    if ($verticalOverlap -gt $Tolerance -and [Math]::Abs(($bx0 - $ax1) - $WallBand) -le $Tolerance) {
        return [pscustomobject]@{ wall_axis = 'vertical'; separation_ft = [Math]::Round($bx0 - $ax1, 6); contact_length_ft = [Math]::Round($verticalOverlap, 6) }
    }
    if ($verticalOverlap -gt $Tolerance -and [Math]::Abs(($ax0 - $bx1) - $WallBand) -le $Tolerance) {
        return [pscustomobject]@{ wall_axis = 'vertical'; separation_ft = [Math]::Round($ax0 - $bx1, 6); contact_length_ft = [Math]::Round($verticalOverlap, 6) }
    }
    if ($horizontalOverlap -gt $Tolerance -and [Math]::Abs(($by0 - $ay1) - $WallBand) -le $Tolerance) {
        return [pscustomobject]@{ wall_axis = 'horizontal'; separation_ft = [Math]::Round($by0 - $ay1, 6); contact_length_ft = [Math]::Round($horizontalOverlap, 6) }
    }
    if ($horizontalOverlap -gt $Tolerance -and [Math]::Abs(($ay0 - $by1) - $WallBand) -le $Tolerance) {
        return [pscustomobject]@{ wall_axis = 'horizontal'; separation_ft = [Math]::Round($ay0 - $by1, 6); contact_length_ft = [Math]::Round($horizontalOverlap, 6) }
    }
    return $null
}

$inputPaths = @($m132LayoutPath, $m132ChecksPath, $routePath, $selectedDPath, $ownerDecisionPath, $roomProgramPath)
foreach ($path in $inputPaths) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required M145 input is missing: $path" }
}

$layouts = Get-Content -LiteralPath $m132LayoutPath -Raw | ConvertFrom-Json
$m132Checks = Get-Content -LiteralPath $m132ChecksPath -Raw | ConvertFrom-Json
$routes = Get-Content -LiteralPath $routePath -Raw | ConvertFrom-Json
$selectedD = Get-Content -LiteralPath $selectedDPath -Raw | ConvertFrom-Json
$ownerDecision = Get-Content -LiteralPath $ownerDecisionPath -Raw
$sourceHashes = [ordered]@{
    m132_layouts = Get-Sha256 $m132LayoutPath
    m132_checks = Get-Sha256 $m132ChecksPath
    m132_route_validation = Get-Sha256 $routePath
    selected_d_study = Get-Sha256 $selectedDPath
    owner_followup_decision = Get-Sha256 $ownerDecisionPath
    room_program = Get-Sha256 $roomProgramPath
}
$tolerance = 0.000001
$matrix = @($selectedD.upper_door_matrix)
$doorWidths = @($matrix | ForEach-Object { [double]$_.nominal_reservation_ft } | Select-Object -Unique)
$nominalReservationFt = if ($doorWidths.Count -eq 1) { [double]$doorWidths[0] } else { [double]::NaN }
$obsoleteU03HallEntry = @($matrix | Where-Object { (Test-Pair $_ 'U-03' 'C-UPPER') }).Count -eq 1
$expectedPrivateLinks = @(
    [pscustomobject]@{ room_a = 'U-01'; room_b = 'C-PRIVATE'; link_id = 'D-U03'; reservation_basis = 'selected-D upper_door_matrix source proxy' },
    [pscustomobject]@{ room_a = 'C-PRIVATE'; room_b = 'U-02'; link_id = 'D-U04'; reservation_basis = 'selected-D upper_door_matrix source proxy' },
    [pscustomobject]@{ room_a = 'U-02'; room_b = 'U-03'; link_id = 'owner-directed private link'; reservation_basis = 'source 3.5 ft proxy only; this new link is absent from the selected-D matrix' },
    [pscustomobject]@{ room_a = 'U-03'; room_b = 'U-06'; link_id = 'D-U09'; reservation_basis = 'selected-D Jack-and-Jill link proxy' },
    [pscustomobject]@{ room_a = 'U-06'; room_b = 'U-04'; link_id = 'D-U08'; reservation_basis = 'selected-D Jack-and-Jill link proxy' },
    [pscustomobject]@{ room_a = 'U-01'; room_b = 'U-05'; link_id = 'D-U02'; reservation_basis = 'selected-D primary-only bath link proxy' }
)
$candidateIds = @('M130-NE-19', 'M130-NE-24')
$candidateRouteMap = @{}
foreach ($route in $routes.results) { $candidateRouteMap[[string]$route.candidate_id] = $route }

$checks = [ordered]@{
    m132_source_layouts_pass_all_checks = ($m132Checks.check_count -eq 25 -and $m132Checks.passed_count -eq 25 -and @($m132Checks.failed).Count -eq 0)
    route_report_binds_exact_layout_artifact = ($routes.candidate_json_sha256 -eq $sourceHashes.m132_layouts)
    selected_d_door_reservations_have_one_consistent_value = ($doorWidths.Count -eq 1 -and [Math]::Abs($nominalReservationFt - 3.5) -lt $tolerance)
    superseded_u03_hall_entry_present_in_baseline_and_excluded = $obsoleteU03HallEntry
    owner_directs_no_u03_hall_entry = ($ownerDecision -match 'omit a direct U-03.*C-UPPER door' -and $ownerDecision -match 'U-03 remains private-route-only with no direct shared-hall door')
    owner_decision_preserves_required_private_and_jack_jill_links = ($ownerDecision -match 'U-01.*C-PRIVATE.*U-02.*U-03' -and $ownerDecision -match 'U-03.*U-06.*U-06.*U-04' -and $ownerDecision -match 'U-03 remains private-route-only')
    owner_requires_direct_u02_hall_arrival = ($ownerDecision -match 'direct arrival from the upper shared hall to U-02')
    exact_two_m132_comparison_layouts_present = (@($layouts).Count -eq 2 -and @($layouts | Where-Object { $_.candidate_id -in $candidateIds }).Count -eq 2)
    contact_interfaces_have_complete_source_dimensions = $true
    six_room_links_checked_per_layout = $true
    private_and_guest_hall_route_samples_match_owner_choice = $true
    no_door_geometry_or_code_clearance_claim = $true
}

$results = @()
$routeSummary = @()
foreach ($candidateId in $candidateIds) {
    $candidates = @($layouts | Where-Object { $_.candidate_id -eq $candidateId })
    if ($candidates.Count -ne 1) { throw "Expected exactly one M132 layout for $candidateId." }
    $candidate = $candidates[0]
    $roomList = @([pscustomobject]@{ id = [string]$candidate.u01.id; x = [double]$candidate.u01.x; y = [double]$candidate.u01.y; w = [double]$candidate.u01.w; d = [double]$candidate.u01.d })
    $roomList += [pscustomobject]@{ id = [string]$candidate.u05.id; x = [double]$candidate.u05.x; y = [double]$candidate.u05.y; w = [double]$candidate.u05.w; d = [double]$candidate.u05.d }
    foreach ($room in $candidate.other_rooms) { $roomList += [pscustomobject]@{ id = [string]$room.id; x = [double]$room.x; y = [double]$room.y; w = [double]$room.w; d = [double]$room.d } }
    if ($roomList.Count -ne 7 -or @($roomList.id | Select-Object -Unique).Count -ne 7) {
        $checks.contact_interfaces_have_complete_source_dimensions = $false
        throw "Candidate $candidateId does not contain seven unique room blocks."
    }
    $roomMap = @{}
    foreach ($room in $roomList) { $roomMap[$room.id] = $room }
    foreach ($link in $expectedPrivateLinks) {
        $contact = Get-Contact $roomMap[$link.room_a] $roomMap[$link.room_b] 0.5 $tolerance
        if ($null -eq $contact) {
            $checks.contact_interfaces_have_complete_source_dimensions = $false
            throw "No 0.5 ft interface with positive contact found for $candidateId $($link.room_a)/$($link.room_b)."
        }
        $reservationFits = ($nominalReservationFt -le [double]$contact.contact_length_ft + $tolerance)
        $margin = ([double]$contact.contact_length_ft - $nominalReservationFt) / 2.0
        $results += [pscustomobject][ordered]@{
            candidate_id = $candidateId
            interface_type = if ($link.room_a -eq 'U-01' -and $link.room_b -eq 'U-05') { 'primary-only bath access' } elseif ($link.room_a -eq 'U-03' -and $link.room_b -eq 'U-06' -or $link.room_a -eq 'U-06' -and $link.room_b -eq 'U-04') { 'Jack-and-Jill link' } else { 'private-suite link' }
            room_a = $link.room_a
            room_b = $link.room_b
            source_link_id = $link.link_id
            reservation_basis = $link.reservation_basis
            wall_axis = $contact.wall_axis
            block_separation_ft = [double]$contact.separation_ft
            nominal_wall_band_ft = 0.5
            shared_boundary_length_ft = [double]$contact.contact_length_ft
            comparison_reservation_ft = $nominalReservationFt
            centered_end_margin_ft = [Math]::Round($margin, 6)
            reservation_fits_boundary_arithmetic = $reservationFits
            opening_or_door_modeled = $false
            leaf_swing_approach_checked = $false
            wall_assembly_checked = $false
            service_route_checked = $false
            selected = $false
        }
    }
    $route = $candidateRouteMap[$candidateId]
    if ($null -eq $route) { $checks.private_and_guest_hall_route_samples_match_owner_choice = $false; throw "M37 route result missing for $candidateId." }
    $publicReach = $route.public_room_sample_sides
    $u01Sides = @($publicReach.'U-01' | Select-Object -Unique)
    $u02Sides = @($publicReach.'U-02' | Select-Object -Unique)
    $u03Sides = @($publicReach.'U-03' | Select-Object -Unique)
    $u04Sides = @($publicReach.'U-04' | Select-Object -Unique)
    if ($u01Sides.Count -eq 0 -or $u02Sides.Count -eq 0 -or $u04Sides.Count -eq 0 -or $u03Sides.Count -gt 0) {
        $checks.private_and_guest_hall_route_samples_match_owner_choice = $false
    }
    $routeSummary += [pscustomobject][ordered]@{
        candidate_id = $candidateId
        u01_primary_public_side_samples = $u01Sides -join ';'
        u02_required_direct_hall_side_samples = $u02Sides -join ';'
        u04_guest_public_side_samples = $u04Sides -join ';'
        u03_public_side_samples = $u03Sides -join ';'
        u03_direct_hall_link_removed = $true
        route_is_sampled_grid_only = $true
        actual_public_doors_modeled = $false
        private_path_door_sequence = 'U-01 -> C-PRIVATE -> U-02 -> U-03'
    }
}

$checks.six_room_links_checked_per_layout = ($results.Count -eq 12 -and @($results | Select-Object -ExpandProperty candidate_id -Unique).Count -eq 2)
$checks.room_link_reservations_fit_all_shared_boundaries = (@($results | Where-Object { -not $_.reservation_fits_boundary_arithmetic }).Count -eq 0)
$checks.private_and_guest_hall_route_samples_match_owner_choice = $checks.private_and_guest_hall_route_samples_match_owner_choice -and ($routeSummary.Count -eq 2)
$failures = @($checks.Keys | Where-Object { -not $checks[$_] })

$report = [ordered]@{
    milestone = 'M145'
    title = 'Owner-directed upper-suite room-link boundary opportunity screen'
    status = 'comparison-only contact arithmetic; no doors or wall openings are modeled'
    design_basis = 'M130-NE-19 and M130-NE-24 are unchanged M132 comparison layouts in the hypothetical 38.333333 x 40 ft shell. Latest owner route is U-01 -> C-PRIVATE -> U-02 -> U-03; U-03 has private access only. Guest U-04 hall access and both U-03/U-06 and U-06/U-04 Jack-and-Jill links remain in scope; U-02 requires direct hall arrival.'
    reservation_method = 'For room-to-room boundaries separated by the M132 0.5 ft wall-band convention, compare overlap length with 3.5 ft nominal opening reservation recorded in the selected-D upper_door_matrix. For new U-02/U-03 link, 3.5 ft is used only as a source-derived comparison proxy, not an owner-approved opening dimension.'
    limitations = @(
        'The selected-D door matrix is a source for nominal reservations, not verified clear widths or a door schedule for M132 layouts.',
        'Centered end margins show only whether a rectangular reservation can fit along a shared block boundary; wall thickness, jambs, leaf, swing, approach, privacy and circulation conflicts are not modeled.',
        'Public access evidence is the M37 sampled grid reachable-side report. It does not locate or validate actual U-01/U-02/U-04 doors; no U-03 public side is retained under the owner decision.',
        'No accessibility, egress, code-compliance, fixture-use, structure, MEP service route or Revit/IFC finding is made.',
        'Both M132 layouts remain hypothetical and unselected. Selected-D geometry and IFC remain untouched.'
    )
    source_hashes_sha256 = $sourceHashes
    checks = $checks
    failures = $failures
    room_link_result_count = $results.Count
    room_links = @($results)
    public_route_sample_count = $routeSummary.Count
    public_routes = @($routeSummary)
}
if ($failures.Count -gt 0) { throw "M145 failed checks: $($failures -join ', ')." }

$resolvedOutput = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$repoPrefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutput.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $resolvedOutput)) { New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null }
$jsonPath = Join-Path $resolvedOutput 'm145-interface-opportunities.json'
$csvPath = Join-Path $resolvedOutput 'm145-room-links.csv'
$routeCsvPath = Join-Path $resolvedOutput 'm145-public-route-samples.csv'
ConvertTo-Json -InputObject $report -Depth 10 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
$routeSummary | Export-Csv -LiteralPath $routeCsvPath -NoTypeInformation -Encoding UTF8
Write-Output "M145 checks passed: $($checks.Count)/$($checks.Count); $($results.Count) room links; $($routeSummary.Count) public route summaries; report SHA256 $((Get-Sha256 $jsonPath))."
