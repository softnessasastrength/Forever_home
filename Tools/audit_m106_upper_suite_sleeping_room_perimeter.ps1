param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M106_Upper_Suite_Sleeping_Room_Perimeter_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m78Directory = Join-Path $repo 'Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29'
$searchPath = Join-Path $m78Directory 'search.json'
$manifestPath = Join-Path $m78Directory 'manifest.json'
$selectedPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$programPath = Join-Path $repo 'Requirements/Room_Program.md'
$codeNotePath = Join-Path $repo 'Research/M106_CT_Sleeping_Room_EERO_Study_2026-10-30.md'

function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }

$search = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$selectedHash = Get-Sha256 $selectedPath
$programText = Get-Content -LiteralPath $programPath -Raw
$codeNoteText = Get-Content -LiteralPath $codeNotePath -Raw
$hashes = [ordered]@{
    m78_search = Get-Sha256 $searchPath
    m78_manifest = Get-Sha256 $manifestPath
    selected_d_study = $selectedHash
    room_program = Get-Sha256 $programPath
    ct_r310_research_note = Get-Sha256 $codeNotePath
}
if ($manifest.output_hashes_sha256.search -ne $hashes.m78_search) { throw 'M78 search does not match its manifest.' }
if ($manifest.source_fingerprints_sha256.'selected_D_study.json' -ne $selectedHash) { throw 'M78 archive no longer binds current selected-D source.' }

$shellWidth = [double]$search.coordinate_basis.width_ft
$shellDepth = [double]$search.coordinate_basis.depth_ft
$candidates = @($search.top_partial_public_access_layouts)
$screenRooms = @('U-01','U-03','U-04')
$expectedProgram = [ordered]@{ 'U-01'='Primary bedroom'; 'U-03'='Hybrid bedroom/office'; 'U-04'='Guest / third bedroom' }
$results = @()
$checks = [ordered]@{
    source_search_hash_matches_manifest = $true
    m78_binds_current_selected_d = $true
    shell_dimensions_match_hypothetical_m78_case = ([Math]::Abs($shellWidth-38.333333) -lt 0.000001 -and [Math]::Abs($shellDepth-40.0) -lt 0.000001)
    five_route_ranked_layouts_present = ($candidates.Count -eq 5)
    route_proxy_keeps_public_and_private_requirements = $true
    bedroom_capable_rooms_exist_in_source_program = $true
    room_program_labels_match_source = (($programText -match '\| U-01 \| Primary bedroom') -and ($programText -match '\| U-03 \|.*hybrid bedroom/office') -and ($programText -match '\| U-04 \| Guest / third bedroom'))
    code_note_cites_r310 = (($codeNoteText -match 'R310\.1') -and ($codeNoteText -match '2022 Connecticut State Building Code'))
    all_fifteen_room_candidate_rows_generated = $true
    u01_has_west_perimeter_contact = $true
    u03_has_no_test_shell_perimeter_contact = $true
    u04_has_east_perimeter_contact = $true
    perimeter_contact_is_not_misreported_as_an_opening = $true
    selected_d_unchanged = $true
    svg_parses_as_xml = $true
}

$candidateKeys = @()
$candidateIndex = 0
foreach ($candidate in $candidates) {
    $candidateIndex++
    $candidateId = 'M78-TOP-{0:D2}' -f $candidateIndex
    $candidateKeys += [pscustomobject][ordered]@{ candidate_id = $candidateId; layout_key = [string]$candidate.layout_key }
    if (-not $candidate.hall_reachability.required_public_rooms_reached -or $candidate.hall_reachability.u03_hall_side_reachable -or [string]$candidate.hall_reachability.reachable_room_sides.'U-02' -notmatch 'north') { $checks.route_proxy_keeps_public_and_private_requirements = $false }
    foreach ($roomId in $screenRooms) {
        $room = $candidate.rectangles.$roomId
        if ($null -eq $room) { $checks.bedroom_capable_rooms_exist_in_source_program = $false; continue }
        $x0 = [double]$room.x_ft; $y0 = [double]$room.y_ft
        $x1 = $x0 + [double]$room.width_ft; $y1 = $y0 + [double]$room.depth_ft
        $contacts = [System.Collections.Generic.List[string]]::new()
        if ([Math]::Abs($x0) -le 0.000001) { $contacts.Add('west') }
        if ([Math]::Abs($x1-$shellWidth) -le 0.000001) { $contacts.Add('east') }
        if ([Math]::Abs($y0) -le 0.000001) { $contacts.Add('south') }
        if ([Math]::Abs($y1-$shellDepth) -le 0.000001) { $contacts.Add('north') }
        $lengths = [ordered]@{
            west = $(if ($contacts.Contains('west')) { [Math]::Round([double]$room.depth_ft,6) } else { 0.0 })
            east = $(if ($contacts.Contains('east')) { [Math]::Round([double]$room.depth_ft,6) } else { 0.0 })
            south = $(if ($contacts.Contains('south')) { [Math]::Round([double]$room.width_ft,6) } else { 0.0 })
            north = $(if ($contacts.Contains('north')) { [Math]::Round([double]$room.width_ft,6) } else { 0.0 })
        }
        $nearestEdge = [Math]::Min([Math]::Min($x0,$shellWidth-$x1),[Math]::Min($y0,$shellDepth-$y1))
        $isSleepingCandidate = ($roomId -in @('U-01','U-03','U-04'))
        if ($isSleepingCandidate -and $contacts.Count -eq 0) { $hasPerimeterWallContact = $false } else { $hasPerimeterWallContact = ($contacts.Count -gt 0) }
        $results += [pscustomobject][ordered]@{
            candidate_id = $candidateId
            m78_layout_key = [string]$candidate.layout_key
            room_id = $roomId
            room_program_label = $expectedProgram[$roomId]
            sleeping_room_status = $(if ($roomId -eq 'U-03') { 'bedroom-capable; sleeping-room classification unverified' } else { 'programmed bedroom candidate; permit classification still requires review' })
            x_ft = [Math]::Round($x0,6)
            y_ft = [Math]::Round($y0,6)
            width_ft = [Math]::Round([double]$room.width_ft,6)
            depth_ft = [Math]::Round([double]$room.depth_ft,6)
            nearest_test_shell_edge_ft = [Math]::Round($nearestEdge,6)
            contacted_test_shell_edges = @($contacts.ToArray())
            perimeter_contact_lengths_ft = $lengths
            test_shell_perimeter_wall_opportunity = $hasPerimeterWallContact
            actual_exterior_wall = $false
            emergency_escape_opening_provided = $false
        }
        if ($roomId -eq 'U-01' -and -not $contacts.Contains('west')) { $checks.u01_has_west_perimeter_contact = $false }
        if ($roomId -eq 'U-03' -and $contacts.Count -gt 0) { $checks.u03_has_no_test_shell_perimeter_contact = $false }
        if ($roomId -eq 'U-04' -and -not $contacts.Contains('east')) { $checks.u04_has_east_perimeter_contact = $false }
    }
}
if ($results.Count -ne 15) { $checks.all_fifteen_room_candidate_rows_generated = $false }
$checks.perimeter_contact_is_not_misreported_as_an_opening = (@($results | Where-Object { $_.actual_exterior_wall -or $_.emergency_escape_opening_provided }).Count -eq 0)
if ((Get-Sha256 $selectedPath) -ne $selectedHash) { $checks.selected_d_unchanged = $false }

$svgLines = [System.Collections.Generic.List[string]]::new()
$scale = 7.4
$plotLeft = 128.0
$plotTop = 86.0
$svgLines.Add('<svg xmlns="http://www.w3.org/2000/svg" width="850" height="550" viewBox="0 0 850 550">')
$svgLines.Add('<title>M106 bedroom-capable room blocks and hypothetical shell perimeter</title>')
$svgLines.Add('<style>text{font-family:Arial,sans-serif;fill:#263743}.title{font-size:25px;font-weight:700}.label{font-size:14px;font-weight:700}.small{font-size:13px}.shell{fill:#fbfaf6;stroke:#2c4556;stroke-width:4}.room{stroke:#536671;stroke-width:1.5}.edge{fill:#d9e5ef}.guest{fill:#e7dfd6}.hybrid{fill:#f3c4ba;stroke:#a24032;stroke-width:3}.marker{stroke:#287459;stroke-width:8}</style>')
$svgLines.Add('<text class="title" x="38" y="40">M106 | Bedroom-capable blocks at the M78 test perimeter</text>')
$svgLines.Add(('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $plotLeft,$plotTop,($shellWidth*$scale),($shellDepth*$scale)))
$basis = $search.best_candidate.rectangles
foreach ($roomId in $screenRooms) {
    $room = $basis.$roomId
    $x = $plotLeft + ([double]$room.x_ft*$scale)
    $y = $plotTop + (($shellDepth-[double]$room.y_ft-[double]$room.depth_ft)*$scale)
    $class = switch ($roomId) { 'U-01' {'edge'} 'U-03' {'hybrid'} 'U-04' {'guest'} }
    $svgLines.Add(('<rect class="room {0}" x="{1}" y="{2}" width="{3}" height="{4}"/>' -f $class,$x,$y,([double]$room.width_ft*$scale),([double]$room.depth_ft*$scale)))
    $svgLines.Add(('<text class="label" text-anchor="middle" x="{0}" y="{1}">{2}</text>' -f ($x+[double]$room.width_ft*$scale/2.0),($y+[double]$room.depth_ft*$scale/2.0+5.0),$roomId))
    if ($roomId -eq 'U-01') { $svgLines.Add(('<line class="marker" x1="{0}" y1="{1}" x2="{0}" y2="{2}"/>' -f $plotLeft,$y,($y+[double]$room.depth_ft*$scale))) }
    if ($roomId -eq 'U-04') { $eastX = $plotLeft+$shellWidth*$scale; $svgLines.Add(('<line class="marker" x1="{0}" y1="{1}" x2="{0}" y2="{2}"/>' -f $eastX,$y,($y+[double]$room.depth_ft*$scale))) }
}
$svgLines.Add('<text class="small" x="40" y="415">Green: U-01/U-04 touch a test-shell edge. Red: U-03 is internal, with no perimeter wall segment in this packing.</text>')
$svgLines.Add('<text class="small" x="40" y="440">R310.1 requires an opening in every sleeping room, opening directly to a public way or qualifying yard/court.</text>')
$svgLines.Add('<text class="small" x="40" y="465">No actual exterior wall/opening is modeled. U-03 status and any roof-opening approach remain unresolved.</text>')
$svgLines.Add('<text class="small" x="40" y="490">38⅓ × 40 ft hypothetical shell; room blocks and route samples only. Not a code compliance finding.</text>')
$svgLines.Add('</svg>')
$svgText = $svgLines -join "`n"
try { [xml]$svgText | Out-Null } catch { $checks.svg_parses_as_xml = $false; Write-Warning $_.Exception.Message }
$report = [ordered]@{
    milestone = 'M106'
    title = 'Conditional emergency escape opening perimeter screen'
    status = 'spatial design gate only; no egress opening is designed or code-compliance result made'
    code_basis = [ordered]@{
        jurisdiction = 'Connecticut statewide preliminary basis; local permit applicability unresolved'
        adopted_provision = '2022 Connecticut State Building Code, amended 2021 IRC R310.1'
        summary = 'Every sleeping room requires at least one operable emergency escape and rescue opening, which opens directly to a public way or to a yard/court that opens to a public way.'
        minimum_net_clear_area_reference_sf = 5.7
        maximum_clear_sill_height_reference_in = 44
        source_url = 'https://portal.ct.gov/das/-/media/das/office-of-state-building-inspector/2022-state-codes/2022-csbc-final.pdf?rev=a59cc11db0564caaa5477bd696ee85f2'
        detailed_citation_note_sha256 = $hashes.ct_r310_research_note
    }
    shell = [ordered]@{ width_ft = $shellWidth; depth_ft = $shellDepth; status = 'M78 hypothetical comparison envelope; not selected house geometry' }
    source_hashes_sha256 = $hashes
    method = 'Check whether the room-block rectangles touch the perimeter of the hypothetical M78 shell. Perimeter contact is only a potential external wall location; it does not establish a wall, window, net clear dimensions, exterior yard/route, sill height or emergency escape opening.'
    conditional_gate = 'U-03 is programmed as a hybrid bedroom/office, but sleeping-room status is unverified. If the owner intends it to function as a sleeping room, its current M78 room block has no test-shell perimeter edge for a conventional exterior wall opening; revise room/shell geometry or evaluate a separately documented qualifying opening path.'
    candidate_count = $candidates.Count
    candidate_layout_keys = @($candidateKeys)
    results = @($results)
    checks = $checks
    failures = @($checks.Keys | Where-Object { -not $checks[$_] })
    limitations = @(
        'This screen measures mathematical contact to a rectangular test-shell line, not built exterior walls or openings.',
        'No window product, clear opening width/height, operation, sill height, well, guard, outside landing, yard/court or route to public way is modeled.',
        'A roof window or dormer is not assumed to qualify; its acceptability requires applicable-code interpretation and design review.',
        'U-03 sleeping-room status and Connecticut permit applicability remain unresolved; no compliance or safety conclusion follows.',
        'The top-five layout subset comes from M78''s bounded 457-packing search and is not exhaustive. Selected-D remains unchanged.'
    )
}
if ($report.failures.Count -gt 0) { throw "M106 failed: $($report.failures -join ', ')." }

$resolvedOutput = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory)) }
$repoPrefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $resolvedOutput.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }
if (-not (Test-Path -LiteralPath $resolvedOutput)) { New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null }
$jsonPath = Join-Path $resolvedOutput 'sleeping-room-perimeter.json'
$csvPath = Join-Path $resolvedOutput 'sleeping-room-perimeter.csv'
$svgPath = Join-Path $resolvedOutput 'sleeping-room-perimeter.svg'
ConvertTo-Json -InputObject $report -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
$svgText | Set-Content -LiteralPath $svgPath -Encoding utf8
[xml](Get-Content -LiteralPath $svgPath -Raw) | Out-Null
Write-Output "M106 checks passed: $($checks.Count)/$($checks.Count); $($results.Count) room/candidate rows; JSON SHA256 $((Get-Sha256 $jsonPath)); CSV SHA256 $((Get-Sha256 $csvPath)); SVG SHA256 $((Get-Sha256 $svgPath))."
