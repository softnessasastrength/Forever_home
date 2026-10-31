param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M156_M115_Sleeping_Room_Perimeter_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m115 = Join-Path $repo 'Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30'
$archivePath = Join-Path $m115 'all-route-tested-candidates.json'
$auditPath = Join-Path $m115 'm115-audit.json'
$searchPath = Join-Path $m115 'search.json'
$selectedPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$programPath = Join-Path $repo 'Requirements/Room_Program.md'
$codePath = Join-Path $repo 'Research/M106_CT_Sleeping_Room_EERO_Study_2026-10-30.md'
$tol = 0.00001

function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }

foreach ($path in @($archivePath,$auditPath,$searchPath,$selectedPath,$programPath,$codePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source missing: $path" }
}
$archive = Get-Content -LiteralPath $archivePath -Raw | ConvertFrom-Json
$audit = Get-Content -LiteralPath $auditPath -Raw | ConvertFrom-Json
$search = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$program = Get-Content -LiteralPath $programPath -Raw
$codeNote = Get-Content -LiteralPath $codePath -Raw
$selectedHash = Get-Sha256 $selectedPath
$hashes = [ordered]@{
    analyzer = Get-Sha256 $PSCommandPath
    m115_archive = Get-Sha256 $archivePath
    m115_audit = Get-Sha256 $auditPath
    m115_search = Get-Sha256 $searchPath
    selected_d_study = $selectedHash
    room_program = Get-Sha256 $programPath
    ct_r310_note = Get-Sha256 $codePath
}
$width = [double]$search.coordinate_basis.width_ft
$depth = [double]$search.coordinate_basis.depth_ft
$candidates = @($archive.candidates | Where-Object {
    $_.public_rooms_reached_count -eq 3 -and $_.hall_reachability.required_public_rooms_reached -and
    -not $_.hall_reachability.u03_hall_side_reachable -and
    @($_.hall_reachability.reachable_room_sides.'U-01').Count -gt 0 -and
    @($_.hall_reachability.reachable_room_sides.'U-02').Count -gt 0 -and
    @($_.hall_reachability.reachable_room_sides.'U-04').Count -gt 0 -and
    @($_.hall_reachability.reachable_room_sides.'U-03').Count -eq 0
})
$rooms = @('U-01','U-03','U-04')
$labels = [ordered]@{'U-01'='Primary bedroom';'U-03'='Hybrid bedroom/office';'U-04'='Guest / third bedroom'}
$roomRows = @()
$candidateRows = @()
foreach ($candidate in $candidates) {
    $key = [string]$candidate.layout_key
    $tx = [double]$candidate.translation_ft.x
    $ty = [double]$candidate.translation_ft.y
    $candidateContact = [ordered]@{}
    foreach ($roomId in $rooms) {
        $room = $candidate.rectangles.$roomId
        if ($null -eq $room) { throw "Candidate $key lacks $roomId." }
        $x0 = [double]$room.x_ft + $tx
        $x1 = $x0 + [double]$room.width_ft
        $y0 = [double]$room.y_ft + $ty
        $y1 = $y0 + [double]$room.depth_ft
        $contacts = [System.Collections.Generic.List[object]]::new()
        if ([Math]::Abs($x0) -le $tol) { $contacts.Add([pscustomobject]@{edge='west';length_ft=[Math]::Round([double]$room.depth_ft,6)}) }
        if ([Math]::Abs($x1-$width) -le $tol) { $contacts.Add([pscustomobject]@{edge='east';length_ft=[Math]::Round([double]$room.depth_ft,6)}) }
        if ([Math]::Abs($y0) -le $tol) { $contacts.Add([pscustomobject]@{edge='south';length_ft=[Math]::Round([double]$room.width_ft,6)}) }
        if ([Math]::Abs($y1-$depth) -le $tol) { $contacts.Add([pscustomobject]@{edge='north';length_ft=[Math]::Round([double]$room.width_ft,6)}) }
        $nearest = [Math]::Min([Math]::Min($x0,$width-$x1),[Math]::Min($y0,$depth-$y1))
        $edgeNames = @($contacts | ForEach-Object edge)
        $candidateContact[$roomId] = $contacts.Count -gt 0
        $roomRows += [pscustomobject][ordered]@{
            layout_key=$key; room_id=$roomId; room_program_label=$labels[$roomId]
            x_ft=[Math]::Round($x0,6); y_ft=[Math]::Round($y0,6)
            width_ft=[Math]::Round([double]$room.width_ft,6); depth_ft=[Math]::Round([double]$room.depth_ft,6)
            nearest_test_shell_edge_ft=[Math]::Round($nearest,6)
            contacted_test_shell_edges=($edgeNames -join ';')
            perimeter_segment_lengths_ft=(@($contacts | ForEach-Object { "$($_.edge):$($_.length_ft)" }) -join ';')
            hypothetical_perimeter_contact=($contacts.Count -gt 0)
            actual_exterior_wall=$false; opening_provided=$false; sleeping_room_classification_confirmed=$false
        }
    }
    $candidateRows += [pscustomobject][ordered]@{
        layout_key=$key; u01_perimeter_contact=$candidateContact['U-01']; u03_perimeter_contact=$candidateContact['U-03']; u04_perimeter_contact=$candidateContact['U-04']
        all_three_bedroom_candidates_touch_test_perimeter=($candidateContact['U-01'] -and $candidateContact['U-03'] -and $candidateContact['U-04'])
        selected=$false
    }
}
$roomSummary = @()
foreach ($roomId in $rooms) {
    $rows = @($roomRows | Where-Object room_id -eq $roomId)
    $touching = @($rows | Where-Object hypothetical_perimeter_contact)
    $edgeCounts = [ordered]@{}
    foreach ($edge in @('north','east','south','west')) { $edgeCounts[$edge] = @($touching | Where-Object { $_.contacted_test_shell_edges -split ';' -contains $edge }).Count }
    $roomSummary += [pscustomobject][ordered]@{
        room_id=$roomId; room_program_label=$labels[$roomId]; route_candidate_count=$rows.Count
        candidates_touching_hypothetical_perimeter=$touching.Count
        candidates_with_no_test_perimeter_contact=($rows.Count-$touching.Count)
        edge_contact_candidate_counts=$edgeCounts
        actual_exterior_wall_count=0; emergency_escape_opening_count=0
    }
}
$u01Summary = $roomSummary | Where-Object room_id -eq 'U-01'
$u03Summary = $roomSummary | Where-Object room_id -eq 'U-03'
$u04Summary = $roomSummary | Where-Object room_id -eq 'U-04'
$manifest = Get-Content -LiteralPath (Join-Path $m115 'manifest.json') -Raw | ConvertFrom-Json
$checks = [ordered]@{
    m115_archive_matches_audit=($hashes.m115_archive -eq [string]$audit.source_hashes_sha256.archive)
    m115_search_matches_audit=($hashes.m115_search -eq [string]$audit.source_hashes_sha256.search)
    m115_manifest_matches_archive=($hashes.m115_archive -eq [string]$manifest.optional_route_tested_candidate_archive.sha256)
    m115_audit_passes_21_of_21=(@($audit.checks.PSObject.Properties).Count -eq 21 -and @($audit.checks.PSObject.Properties | Where-Object {-not [bool]$_.Value}).Count -eq 0)
    hypothetical_shell_matches_owner_selected_exploration=([Math]::Abs($width-38.333333) -lt $tol -and [Math]::Abs($depth-40) -lt $tol)
    exactly_73_route_compatible_candidates=($candidates.Count -eq 73)
    all_candidate_rows_cover_three_bedroom_program_spaces=($roomRows.Count -eq 219)
    u01_perimeter_count_matches_reproduced_archive_result=($u01Summary.candidates_touching_hypothetical_perimeter -eq 0)
    u03_perimeter_count_matches_reproduced_archive_result=($u03Summary.candidates_touching_hypothetical_perimeter -eq 73)
    u04_perimeter_count_matches_reproduced_archive_result=($u04Summary.candidates_touching_hypothetical_perimeter -eq 28)
    no_candidate_gives_all_three_bedroom_spaces_perimeter_contact=(@($candidateRows | Where-Object all_three_bedroom_candidates_touch_test_perimeter).Count -eq 0)
    owner_program_identifies_three_bedroom_capable_spaces=(($program -match '\| U-01 \| Primary bedroom') -and ($program -match '\| U-03 \|.*hybrid bedroom/office') -and ($program -match '\| U-04 \| Guest / third bedroom'))
    code_note_identifies_connecticut_r310_basis=(($codeNote -match 'R310\.1') -and ($codeNote -match '5\.7 sf'))
    no_room_is_claimed_as_exterior_wall_or_opening=(@($roomRows | Where-Object {$_.actual_exterior_wall -or $_.opening_provided}).Count -eq 0)
    no_candidate_selected=(@($candidateRows | Where-Object selected).Count -eq 0)
    selected_d_unchanged=((Get-Sha256 $selectedPath) -eq $selectedHash)
}
$failures = @($checks.Keys | Where-Object {-not $checks[$_]})
$report = [ordered]@{
    milestone='M156'; title='M115 route-compatible bedroom-candidate perimeter contact screen'
    status='bounded hypothetical shell-edge contact analysis; no layout, exterior wall, opening, sleeping-room classification or code result selected'
    shell='38.333333 x 40 ft owner-authorized exploration case only'; search_is_incomplete=$true
    candidate_filter='M115 archive candidates with sampled U-01/U-02/U-04 hall-side reach and no sampled U-03 public-side reach'
    method='Translate each U-01/U-03/U-04 room rectangle into the M115 shell coordinate frame and measure exact contact with the hypothetical shell boundary.'
    hashes_sha256=$hashes; checks=$checks; failures=$failures
    route_compatible_candidates=$candidates.Count; room_summary=$roomSummary; candidates=$candidateRows; room_rows=$roomRows
    limitations=@(
        'A room-block edge coincident with the test-shell outline is only a possible exterior-wall zone; it is not an authored wall or opening.',
        'No opening product, net clear area, clear width/height, sill, well, grade, qualifying yard/court or route to public way is modeled.',
        'The room program calls U-01, U-03 and U-04 bedroom-capable spaces, but final sleeping-room classification and site-specific code applicability are unresolved.',
        'M115 is a bounded incomplete search. Candidate counts describe only its retained 73 route-compatible records and do not establish feasibility or probability.',
        'No roof, floor, stair, structure, physical door, Revit placement, IFC or construction geometry is established.'
    )
}
if ($failures.Count) { throw "M156 failed checks: $($failures -join ', ')" }
$resolved = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$prefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if (-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside repository root.' }
if (-not (Test-Path -LiteralPath $resolved)) { New-Item -ItemType Directory -Path $resolved -Force | Out-Null }
$json = Join-Path $resolved 'm156-perimeter-screen.json'
$csv = Join-Path $resolved 'm156-room-perimeter.csv'
$summary = Join-Path $resolved 'm156-candidate-summary.csv'
ConvertTo-Json -InputObject $report -Depth 14 | Set-Content -LiteralPath $json -Encoding utf8
$roomRows | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
$candidateRows | Export-Csv -LiteralPath $summary -NoTypeInformation -Encoding UTF8
Write-Output "M156 passed $($checks.Count)/$($checks.Count); candidates=$($candidates.Count); room rows=$($roomRows.Count); report SHA256=$(Get-Sha256 $json)"
