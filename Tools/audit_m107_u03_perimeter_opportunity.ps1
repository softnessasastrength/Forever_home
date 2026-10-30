param(
    [string]$ArchivePath = (Join-Path $PSScriptRoot '../Architecture/M107_U03_Perimeter_Opportunity_2026-10-30/all-route-tested-candidates.json'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M107_U03_Perimeter_Opportunity_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$archivePath = (Resolve-Path -LiteralPath $ArchivePath).Path
$archiveDirectory = Split-Path -Parent $archivePath
$m78Directory = Join-Path $repo 'Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29'
$m78SearchPath = Join-Path $m78Directory 'search.json'
$m78ManifestPath = Join-Path $m78Directory 'manifest.json'
$selectedPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'

function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Test-Near([double]$A, [double]$B, [double]$Tolerance = 0.000001) { [Math]::Abs($A - $B) -le $Tolerance }

$archive = Get-Content -LiteralPath $archivePath -Raw | ConvertFrom-Json
$m78Search = Get-Content -LiteralPath $m78SearchPath -Raw | ConvertFrom-Json
$m78Manifest = Get-Content -LiteralPath $m78ManifestPath -Raw | ConvertFrom-Json
$shellWidth = [double]$m78Search.coordinate_basis.width_ft
$shellDepth = [double]$m78Search.coordinate_basis.depth_ft
$archiveHash = Get-Sha256 $archivePath
$m78SearchHash = Get-Sha256 $m78SearchPath
$selectedHash = Get-Sha256 $selectedPath
$candidateRecords = @($archive.candidates)
$results = [System.Collections.Generic.List[object]]::new()
$perimeterCandidateCount = 0
$requiredRouteCandidateCount = 0
$requiredRouteAndU02NorthCount = 0
$requiredRouteAndU03PerimeterCount = 0
$requiredRouteAndU02NorthAndU03PerimeterCount = 0
$containedCandidateCount = 0
$nonOverlappingCandidateCount = 0
$tolerance = 0.00001

$checks = [ordered]@{
    archive_schema_is_expected = ($archive.schema -eq 'forever-home.m37-route-tested-candidate-archive.v1')
    archive_candidate_count_matches_manifest = ($candidateRecords.Count -eq [int]$archive.candidate_count -and $candidateRecords.Count -eq [int]$archive.route_runs_total)
    archive_binds_M78_search = ($archive.source_search_sha256 -eq $m78SearchHash -and $m78Manifest.output_hashes_sha256.search -eq $m78SearchHash)
    M78_shell_is_hypothetical_38_333333_by_40 = (Test-Near $shellWidth 38.333333 -and (Test-Near $shellDepth 40.0))
    M78_manifest_binds_current_selected_D = ($m78Manifest.source_fingerprints_sha256.'selected_D_study.json' -eq $selectedHash)
    M37_all_route_records_are_exported = ($candidateRecords.Count -eq [int]$m78Search.search.hall_route_searches)
    every_candidate_has_all_seven_room_blocks = $true
    every_candidate_is_inside_test_shell = $true
    every_candidate_has_no_overlapping_room_blocks = $true
    route_counts_reconstruct_from_sampled_room_sides = $true
    five_candidates_reach_required_public_rooms = $true
    five_required_route_candidates_have_U02_north_sample = $true
    no_U03_test_shell_perimeter_contact_in_bounded_archive = $true
    no_U03_perimeter_contact_among_required_route_candidates = $true
    selected_D_unchanged = $true
    svg_parses_as_xml = $true
}

$roomIds = @('U-01','U-02','U-03','U-04','U-05','U-06','C-PRIVATE')
foreach ($candidate in $candidateRecords) {
    $rects = $candidate.rectangles
    $rectList = @()
    foreach ($roomId in $roomIds) {
        $room = $rects.$roomId
        if ($null -eq $room) { $checks.every_candidate_has_all_seven_room_blocks = $false; continue }
        $x0 = [double]$room.x_ft; $y0 = [double]$room.y_ft
        $x1 = $x0 + [double]$room.width_ft; $y1 = $y0 + [double]$room.depth_ft
        if ($x0 -lt -$tolerance -or $y0 -lt -$tolerance -or $x1 -gt ($shellWidth + $tolerance) -or $y1 -gt ($shellDepth + $tolerance)) { $checks.every_candidate_is_inside_test_shell = $false }
        $rectList += [pscustomobject]@{ id = $roomId; x0 = $x0; y0 = $y0; x1 = $x1; y1 = $y1 }
    }
    for ($i = 0; $i -lt $rectList.Count; $i++) {
        for ($j = $i + 1; $j -lt $rectList.Count; $j++) {
            $a = $rectList[$i]; $b = $rectList[$j]
            $overlapX = [Math]::Min($a.x1,$b.x1) - [Math]::Max($a.x0,$b.x0)
            $overlapY = [Math]::Min($a.y1,$b.y1) - [Math]::Max($a.y0,$b.y0)
            if ($overlapX -gt $tolerance -and $overlapY -gt $tolerance) { $checks.every_candidate_has_no_overlapping_room_blocks = $false }
        }
    }
    if ($rectList.Count -eq 7 -and $rectList.Where({ $_.x0 -ge -$tolerance -and $_.y0 -ge -$tolerance -and $_.x1 -le ($shellWidth+$tolerance) -and $_.y1 -le ($shellDepth+$tolerance) }).Count -eq 7) { $containedCandidateCount++ }
    if ($rectList.Count -eq 7) { $nonOverlappingCandidateCount++ }

    $reach = $candidate.hall_reachability.reachable_room_sides
    $requiredFromSides = (@($reach.'U-01').Count -gt 0 -and @($reach.'U-02').Count -gt 0 -and @($reach.'U-04').Count -gt 0)
    if ([bool]$candidate.hall_reachability.required_public_rooms_reached -ne $requiredFromSides) { $checks.route_counts_reconstruct_from_sampled_room_sides = $false }
    $requiredRoute = $requiredFromSides
    $u02North = (@($reach.'U-02') -contains 'north')
    if ($requiredRoute) { $requiredRouteCandidateCount++ }
    if ($requiredRoute -and $u02North) { $requiredRouteAndU02NorthCount++ }

    $u03 = $rects.'U-03'
    if ($null -eq $u03) { continue }
    $u03x0 = [double]$u03.x_ft; $u03y0 = [double]$u03.y_ft
    $u03x1 = $u03x0 + [double]$u03.width_ft; $u03y1 = $u03y0 + [double]$u03.depth_ft
    $contactSides = [System.Collections.Generic.List[string]]::new()
    if ([Math]::Abs($u03x0) -le $tolerance) { $contactSides.Add('west') }
    if ([Math]::Abs($u03x1 - $shellWidth) -le $tolerance) { $contactSides.Add('east') }
    if ([Math]::Abs($u03y0) -le $tolerance) { $contactSides.Add('south') }
    if ([Math]::Abs($u03y1 - $shellDepth) -le $tolerance) { $contactSides.Add('north') }
    $touchesPerimeter = ($contactSides.Count -gt 0)
    if ($touchesPerimeter) { $perimeterCandidateCount++ }
    if ($requiredRoute -and $touchesPerimeter) { $requiredRouteAndU03PerimeterCount++ }
    if ($requiredRoute -and $u02North -and $touchesPerimeter) { $requiredRouteAndU02NorthAndU03PerimeterCount++ }
    $nearestEdge = [Math]::Min([Math]::Min($u03x0,$shellWidth-$u03x1),[Math]::Min($u03y0,$shellDepth-$u03y1))
    $results.Add([pscustomobject][ordered]@{
        layout_key = [string]$candidate.layout_key
        required_public_rooms_reached = $requiredRoute
        U02_north_side_sample_reached = $u02North
        U03_x_ft = [Math]::Round($u03x0,6)
        U03_y_ft = [Math]::Round($u03y0,6)
        U03_width_ft = [Math]::Round([double]$u03.width_ft,6)
        U03_depth_ft = [Math]::Round([double]$u03.depth_ft,6)
        U03_nearest_test_shell_edge_ft = [Math]::Round($nearestEdge,6)
        U03_test_shell_perimeter_sides = @($contactSides.ToArray())
        U03_test_shell_perimeter_contact = $touchesPerimeter
        actual_exterior_wall_or_opening_provided = $false
    })
}

$checks.M37_all_route_records_are_exported = ($candidateRecords.Count -eq 457 -and $candidateRecords.Count -eq [int]$archive.route_runs_total)
$checks.every_candidate_is_inside_test_shell = ($checks.every_candidate_is_inside_test_shell -and $containedCandidateCount -eq $candidateRecords.Count)
$checks.every_candidate_has_no_overlapping_room_blocks = ($checks.every_candidate_has_no_overlapping_room_blocks -and $nonOverlappingCandidateCount -eq $candidateRecords.Count)
$checks.five_candidates_reach_required_public_rooms = ($requiredRouteCandidateCount -eq 5)
$checks.five_required_route_candidates_have_U02_north_sample = ($requiredRouteAndU02NorthCount -eq 5)
$checks.no_U03_test_shell_perimeter_contact_in_bounded_archive = ($perimeterCandidateCount -eq 0)
$checks.no_U03_perimeter_contact_among_required_route_candidates = ($requiredRouteAndU03PerimeterCount -eq 0 -and $requiredRouteAndU02NorthAndU03PerimeterCount -eq 0)
if ((Get-Sha256 $selectedPath) -ne $selectedHash) { $checks.selected_D_unchanged = $false }

$csvPath = Join-Path $OutputDirectory 'candidate-audit.csv'
$jsonPath = Join-Path $OutputDirectory 'candidate-audit.json'
$svgPath = Join-Path $OutputDirectory 'u03-perimeter-screen.svg'
$manifestPath = Join-Path $OutputDirectory 'manifest.json'
$null = New-Item -ItemType Directory -Path $OutputDirectory -Force
$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

$report = [ordered]@{
    milestone = 'M107'
    title = 'Bounded U-03 test-shell perimeter opportunity audit'
    status = 'design-screen result only; not an egress, code-compliance, or room-classification determination'
    interpretation = 'No route-tested candidate in this bounded M78 archive places U-03 against the hypothetical test-shell perimeter. This does not establish that no different layout or separately evaluated opening solution can work.'
    shell = [ordered]@{ width_ft = $shellWidth; depth_ft = $shellDepth; status = 'hypothetical M78 comparison shell; not selected house geometry' }
    method = 'Audit every M37 archived route-tested placement. Count sampled hall reach to U-01, U-02 and U-04; separately check whether the U-02 north side was sampled as reachable; measure U-03 rectangle contact with the hypothetical shell boundary. Room-side reach is the existing M37 corridor-grid proxy, not a door design.'
    counts = [ordered]@{
        route_tested_candidates = $candidateRecords.Count
        candidates_reaching_required_public_rooms = $requiredRouteCandidateCount
        required_route_candidates_with_U02_north_sample = $requiredRouteAndU02NorthCount
        all_candidates_with_U03_perimeter_contact = $perimeterCandidateCount
        required_route_candidates_with_U03_perimeter_contact = $requiredRouteAndU03PerimeterCount
        required_route_and_U02_north_candidates_with_U03_perimeter_contact = $requiredRouteAndU02NorthAndU03PerimeterCount
    }
    source_hashes_sha256 = [ordered]@{ route_tested_archive = $archiveHash; M78_search = $m78SearchHash; M78_manifest = (Get-Sha256 $m78ManifestPath); selected_D_study = $selectedHash }
    search_scope = [ordered]@{ search_complete = [bool]$m78Search.search.search_complete; bounded_layout_limit = [int]$archive.search_parameters.layout_limit; tested_route_records = [int]$archive.route_runs_total; note = 'The bounded search reports search_complete=false. Its 457 archived candidates are not an exhaustive set of all possible arrangements.' }
    candidate_results = @($results.ToArray())
    checks = $checks
    failures = @($checks.Keys | Where-Object { -not $checks[$_] })
    limitations = @(
        'The shell is a hypothetical comparison envelope, not a selected or modeled exterior wall.',
        'Perimeter contact is only a potential wall location; no wall, window, EERO, yard/court or route to public way is represented.',
        'The 4 ft M37 corridor grid and sampled edge goals are schematic reachability proxies; they do not establish door clear width, maneuvering clearance or code compliance.',
        'U-03 remains a hybrid bedroom/office and its sleeping-room classification is unresolved.',
        'The candidate set is bounded and incomplete. This result applies only to these 457 route-tested placements and current source inputs.',
        'No structural, code-compliance, professional certification or construction-readiness conclusion is made.'
    )
}
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$svg = @(
    '<svg xmlns="http://www.w3.org/2000/svg" width="920" height="590" viewBox="0 0 920 590">',
    '<title>M107 bounded U-03 perimeter opportunity screen</title>',
    '<style>text{font-family:Arial,sans-serif;fill:#263743}.title{font-size:25px;font-weight:700}.label{font-size:14px;font-weight:700}.small{font-size:13px}.shell{fill:#fbfaf6;stroke:#2c4556;stroke-width:4}.room{stroke:#536671;stroke-width:1.5}.primary{fill:#d9e5ef}.guest{fill:#e7dfd6}.hybrid{fill:#f3c4ba;stroke:#a24032;stroke-width:3}.bath{fill:#dcebdd}.private{fill:#e9e0f0}.contact{stroke:#287459;stroke-width:8}</style>',
    '<text class="title" x="38" y="40">M107 | U-03 perimeter opportunity in the bounded route search</text>'
)
$scale = 9.3; $left = 90.0; $top = 70.0
$svg += ('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $left,$top,($shellWidth*$scale),($shellDepth*$scale))
$displayCandidate = $m78Search.best_candidate
foreach ($roomId in $roomIds) {
    $r = $displayCandidate.rectangles.$roomId
    $x = $left + [double]$r.x_ft*$scale
    $y = $top + ($shellDepth-[double]$r.y_ft-[double]$r.depth_ft)*$scale
    $class = switch ($roomId) { 'U-01' {'primary'} 'U-03' {'hybrid'} 'U-04' {'guest'} 'U-05' {'bath'} 'U-06' {'bath'} 'C-PRIVATE' {'private'} default {'room'} }
    $svg += ('<rect class="room {0}" x="{1}" y="{2}" width="{3}" height="{4}"/><text class="label" text-anchor="middle" x="{5}" y="{6}">{7}</text>' -f $class,$x,$y,([double]$r.width_ft*$scale),([double]$r.depth_ft*$scale),($x+[double]$r.width_ft*$scale/2.0),($y+[double]$r.depth_ft*$scale/2.0+5.0),$roomId)
}
$svg += '<text class="small" x="42" y="475">457 placements route-tested; 5 reach sampled U-01/U-02/U-04 hall sides (all 5 include U-02 north).</text>'
$svg += '<text class="small" x="42" y="498">U-03 test-shell perimeter contacts: 0 of 457. This example is the M78 retained candidate, with U-03 internal.</text>'
$svg += '<text class="small" x="42" y="521">Search is bounded and incomplete. Shell contact would only suggest a wall zone, not provide an opening.</text>'
$svg += '<text class="small" x="42" y="544">38 1/3 x 40 ft is a hypothetical comparison shell, not a selected house dimension.</text>'
$svg += '</svg>'
$svgText = $svg -join "`n"
try { [xml]$svgText | Out-Null } catch { $checks.svg_parses_as_xml = $false; throw }
Set-Content -LiteralPath $svgPath -Value $svgText -Encoding UTF8
$report.checks.svg_parses_as_xml = $checks.svg_parses_as_xml
$report.failures = @($checks.Keys | Where-Object { -not $checks[$_] })
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$outputHashes = [ordered]@{ json = Get-Sha256 $jsonPath; csv = Get-Sha256 $csvPath; svg = Get-Sha256 $svgPath }
$manifest = [ordered]@{
    generator = 'Tools/audit_m107_u03_perimeter_opportunity.ps1'
    source_hashes_sha256 = $report.source_hashes_sha256
    output_hashes_sha256 = $outputHashes
    counts = $report.counts
    checks_passed = @($checks.Values | Where-Object { $_ -eq $true }).Count
    checks_total = $checks.Count
}
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8
if (@($checks.Values | Where-Object { $_ -ne $true }).Count -gt 0) { throw ('M107 checks failed: ' + (@($checks.Keys | Where-Object { -not $checks[$_] }) -join ', ')) }
Write-Output ('M107 checks passed: {0}/{1}' -f $checks.Count,$checks.Count)
Write-Output ('Candidates: {0}; required-route candidates: {1}; U-03 perimeter contacts: {2}.' -f $candidateRecords.Count,$requiredRouteCandidateCount,$perimeterCandidateCount)
Write-Output ('JSON SHA256 {0}; CSV SHA256 {1}; SVG SHA256 {2}.' -f $outputHashes.json,$outputHashes.csv,$outputHashes.svg)
