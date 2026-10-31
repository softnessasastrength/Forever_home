param(
    [string]$OutputDirectory = 'Architecture/M30_Upper_Suite_Adjacency_Audit_2026-10-28'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$studyPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$programPath = Join-Path $root 'Requirements/Room_Program.md'
$decisionPath = Join-Path $root 'Decisions/2026-10-27_Selected_Architectural_Direction_D.md'
foreach ($path in @($studyPath, $programPath, $decisionPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required M30 source is missing: $path" }
}

$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$programText = Get-Content -LiteralPath $programPath -Raw -Encoding utf8
$decisionText = Get-Content -LiteralPath $decisionPath -Raw -Encoding utf8
$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check([string]$Name, [bool]$Passed, [string]$Detail) {
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; detail = $Detail })
}

$rooms = @($study.plans.upper)
$doors = @($study.upper_door_matrix)
$roomIds = @($rooms | ForEach-Object { [string]$_.id })
$doorIds = @($doors | ForEach-Object { [string]$_.id })
$uniqueRoomIds = @($roomIds | Sort-Object -Unique)
$uniqueDoorIds = @($doorIds | Sort-Object -Unique)
$validEndpoints = @($doors | Where-Object { $_.a -notin $roomIds -or $_.b -notin $roomIds }).Count -eq 0
$selectedD = $study.layout_variant -eq 'OwnerSelectedD'
$hasProgramRequirements = $programText.Contains('Primary') -and
    $programText.Contains('boutique') -and
    $programText.Contains('Hybrid') -and
    $programText.Contains('Jack & Jill') -and
    $programText.Contains('Guest') -and
    $programText.Contains('shared circulation')
$hasDecisionRequirements = $decisionText.Contains('private connector') -and
    $decisionText.Contains('guest access from the hall') -and
    $decisionText.Contains('Jack-and-Jill shared by the hybrid and guest rooms')

Add-Check 'study_is_owner_selected_d' $selectedD "layout_variant=$($study.layout_variant)"
Add-Check 'upper_rooms_have_unique_ids' ($roomIds.Count -eq $uniqueRoomIds.Count -and $roomIds.Count -gt 0) "room_ids=$($roomIds -join ',')"
Add-Check 'upper_door_reservations_have_unique_ids' ($doorIds.Count -eq $uniqueDoorIds.Count -and $doorIds.Count -gt 0) "door_ids=$($doorIds -join ',')"
Add-Check 'every_door_endpoint_names_an_upper_room_or_circulation_block' $validEndpoints 'Door reservations are checked against the upper-level plan IDs.'
Add-Check 'room_program_adjacency_requirements_are_present' $hasProgramRequirements 'Source text includes the primary/boutique/hybrid, primary-bath, J&J, and guest-circulation requirements.'
Add-Check 'selected_direction_privacy_requirements_are_present' $hasDecisionRequirements 'Source text includes the private connector, hall-accessible guest, and hybrid/guest J&J arrangement.'

$edges = @($doors | ForEach-Object {
    [ordered]@{
        door_id = [string]$_.id
        from = [string]$_.a
        to = [string]$_.b
        nominal_reservation_ft = [double]$_.nominal_reservation_ft
        status = 'schematic reservation only; not a clear opening or verified door'
    }
})
function Test-Connected([string]$Start, [string]$Target, [string[]]$AllowedNodes, $EdgeList) {
    if ($Start -notin $AllowedNodes -or $Target -notin $AllowedNodes) { return $false }
    $visited = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $queue = [System.Collections.Generic.Queue[string]]::new()
    [void]$visited.Add($Start)
    $queue.Enqueue($Start)
    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        if ($current -eq $Target) { return $true }
        foreach ($edge in $EdgeList) {
            $next = $null
            if ($edge.from -eq $current) { $next = $edge.to }
            elseif ($edge.to -eq $current) { $next = $edge.from }
            if ($null -ne $next -and $next -in $AllowedNodes -and $visited.Add($next)) { $queue.Enqueue($next) }
        }
    }
    return $false
}

$suiteNodes = @('U-01', 'U-02', 'U-03', 'C-PRIVATE')
$privateChainConnected = Test-Connected 'U-01' 'U-03' $suiteNodes $edges
$guestHallDoor = @($doors | Where-Object { ($_.a -eq 'U-04' -and $_.b -eq 'C-UPPER') -or ($_.b -eq 'U-04' -and $_.a -eq 'C-UPPER') }).Count -gt 0
$primaryBathDoors = @($doors | Where-Object { $_.a -eq 'U-05' -or $_.b -eq 'U-05' })
$primaryBathOnlyPrimary = ($primaryBathDoors.Count -eq 1 -and (($primaryBathDoors[0].a -eq 'U-05' -and $primaryBathDoors[0].b -eq 'U-01') -or ($primaryBathDoors[0].b -eq 'U-05' -and $primaryBathDoors[0].a -eq 'U-01')))
$jAndJHasHybrid = @($doors | Where-Object { ($_.a -eq 'U-03' -and $_.b -eq 'U-06') -or ($_.b -eq 'U-03' -and $_.a -eq 'U-06') }).Count -gt 0
$jAndJHasGuest = @($doors | Where-Object { ($_.a -eq 'U-04' -and $_.b -eq 'U-06') -or ($_.b -eq 'U-04' -and $_.a -eq 'U-06') }).Count -gt 0
$boutiqueHallDoor = @($doors | Where-Object { ($_.a -eq 'U-02' -and $_.b -eq 'C-UPPER') -or ($_.b -eq 'U-02' -and $_.a -eq 'C-UPPER') }).Count -gt 0

Add-Check 'guest_has_nominal_direct_shared_hall_access' $guestHallDoor 'This checks a door-matrix edge, not a usable opening or clear route.'
Add-Check 'primary_bath_is_nominally_accessed_only_from_primary' $primaryBathOnlyPrimary "primary_bath_door_edges=$($primaryBathDoors.Count)"
Add-Check 'j_and_j_has_nominal_hybrid_and_guest_connections' ($jAndJHasHybrid -and $jAndJHasGuest) "hybrid_edge=$jAndJHasHybrid; guest_edge=$jAndJHasGuest"
Add-Check 'upper_suite_topology_gap_is_detected' (-not $privateChainConnected) 'The shared C-UPPER hall and U-06 J&J bath are excluded when checking a private U-01-to-U-03 route; current reservations provide no such route.'
Add-Check 'boutique_shared_hall_exposure_is_detected' $boutiqueHallDoor 'Current door matrix includes U-02 to C-UPPER as well as U-02 to C-PRIVATE.'

$finding = [ordered]@{
    status = if (-not $privateChainConnected) { 'open design conflict' } else { 'private route represented schematically' }
    interpretation = 'For this audit, Primary/boutique/hybrid and U-03 suite connection mean a nominal path among U-01/U-02/U-03 that does not pass through shared C-UPPER circulation or the shared U-06 bath. This is a deliberately strict interpretation of the checked-in adjacency language; owner intent may instead allow a shared-hall connection.'
    observed = [ordered]@{
        primary_to_boutique_private_path = (Test-Connected 'U-01' 'U-02' $suiteNodes $edges)
        primary_to_hybrid_private_path = $privateChainConnected
        hybrid_nominal_shared_hall_door = @($doors | Where-Object { ($_.a -eq 'U-03' -and $_.b -eq 'C-UPPER') -or ($_.b -eq 'U-03' -and $_.a -eq 'C-UPPER') }).Count -gt 0
        boutique_nominal_shared_hall_door = $boutiqueHallDoor
        guest_nominal_shared_hall_door = $guestHallDoor
        j_and_j_connects_hybrid_and_guest = ($jAndJHasHybrid -and $jAndJHasGuest)
        primary_bath_nominal_neighbor = if ($primaryBathOnlyPrimary) { 'U-01 only' } else { 'review required' }
    }
    design_gate = 'Decide whether the hybrid must connect privately into the primary/boutique sequence, or whether hall access plus Jack-and-Jill is the intended separation. If private continuity is required, develop and compare room/door alternatives in a derivative; preserve the selected-D baseline until the owner accepts one.'
    proposals = @(
        [ordered]@{ id = 'retain_current_topology'; status = 'proposal; not selected'; consequence = 'Preserves direct guest hall access and J&J sharing, while leaving the hybrid outside the private primary/boutique path.' },
        [ordered]@{ id = 'test_private_hybrid_suite_connection'; status = 'proposal; requires a plan derivative'; consequence = 'Would need a revised adjacency/door arrangement; current blocks provide no private U-01-to-U-03 route without using the shared hall or U-06.' }
    )
}

$report = [ordered]@{
    schema = 'forever-home.m30-upper-suite-adjacency-audit.v1'
    status = if (@($checks | Where-Object { -not $_.passed }).Count -eq 0) { 'pass' } else { 'fail' }
    checks_passed = @($checks | Where-Object { $_.passed }).Count
    checks_total = $checks.Count
    checks = $checks
    source_fingerprints_sha256 = [ordered]@{
        selected_d_study = (Get-FileHash -LiteralPath $studyPath -Algorithm SHA256).Hash.ToLowerInvariant()
        room_program = (Get-FileHash -LiteralPath $programPath -Algorithm SHA256).Hash.ToLowerInvariant()
        selected_direction_decision = (Get-FileHash -LiteralPath $decisionPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    upper_level = [ordered]@{
        room_and_circulation_blocks = @($rooms | ForEach-Object { [ordered]@{ id = [string]$_.id; name = [string]$_.name; kind = [string]$_.kind } })
        nominal_door_edges = $edges
        private_primary_boutique_hybrid_path_present = $privateChainConnected
        boutique_has_shared_hall_edge = $boutiqueHallDoor
        guest_has_shared_hall_edge = $guestHallDoor
        j_and_j_connects_hybrid_and_guest = ($jAndJHasHybrid -and $jAndJHasGuest)
        primary_bath_neighbor_is_primary_only = $primaryBathOnlyPrimary
    }
    finding = $finding
    limitations = @(
        'Door-matrix reservations are schematic lines only; nominal 3.5 ft reservation length is not a measured clear opening, door leaf, swing or code value.',
        'This graph audit does not test wall construction, physical door locations, furniture, privacy acoustics, egress, accessibility or Revit/IFC geometry.',
        'The selected-D study remains unchanged; neither proposal is adopted.',
        'No professional, legal, code-compliance, structural-safety or construction-readiness claim is made.'
    )
}

$target = Join-Path $root $OutputDirectory
New-Item -ItemType Directory -Path $target -Force | Out-Null
$outputPath = Join-Path $target 'upper-suite-adjacency-audit.json'
$json = ConvertTo-Json -InputObject $report -Depth 16
Set-Content -LiteralPath $outputPath -Value $json -Encoding utf8
Write-Output "M30 upper-suite adjacency audit: $($report.checks_passed)/$($report.checks_total) reproducibility and source-contract checks passed."
Write-Output "Finding: private primary-to-hybrid path present = $privateChainConnected; boutique shared-hall edge = $boutiqueHallDoor."
Write-Output $outputPath
if ($report.status -ne 'pass') { exit 1 }
