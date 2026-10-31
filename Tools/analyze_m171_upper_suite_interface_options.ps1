param(
    [Parameter(Mandatory=$true)][string]$RunDirectory,
    [Parameter(Mandatory=$true)][string]$AuditDirectory,
    [Parameter(Mandatory=$true)][string]$OutputDirectory
)

$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent))
function Resolve-RepoPath([string]$path) {
    if ([System.IO.Path]::IsPathRooted($path)) { $full = [System.IO.Path]::GetFullPath($path) }
    else { $full = [System.IO.Path]::GetFullPath((Join-Path $root $path)) }
    $prefix = $root.TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar,[System.IO.Path]::AltDirectorySeparatorChar)) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $full.StartsWith($prefix,[System.StringComparison]::OrdinalIgnoreCase)) { throw "Path must remain inside this repository: $full" }
    return $full
}

$run = Resolve-RepoPath $RunDirectory
$auditDir = Resolve-RepoPath $AuditDirectory
$out = Resolve-RepoPath $OutputDirectory
$archivePath = Join-Path $run 'all-route-tested-candidates.json'
$searchPath = Join-Path $run 'search.json'
$auditPath = Join-Path $auditDir 'm163-expanded-joint-perimeter-audit.json'
foreach ($path in @($archivePath,$searchPath,$auditPath)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source artifact missing: $path" } }
if (-not (Test-Path -LiteralPath $out -PathType Container)) { [void](New-Item -ItemType Directory -Path $out -Force) }

$archive = Get-Content -LiteralPath $archivePath -Raw | ConvertFrom-Json
$search = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$audit = Get-Content -LiteralPath $auditPath -Raw | ConvertFrom-Json
$archiveHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archivePath).Hash.ToLowerInvariant()
$searchHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $searchPath).Hash.ToLowerInvariant()
$auditArchiveHash = [string]$audit.hashes_sha256.archive
$auditSearchHash = [string]$audit.hashes_sha256.search
$selectedDPath = Resolve-RepoPath 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$ownerFollowupPath = Resolve-RepoPath 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$generatorPath = Resolve-RepoPath 'Tools/test_m37_upper_suite_pack_and_route.ps1'
$selectedDHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $selectedDPath).Hash.ToLowerInvariant()
$ownerFollowupHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $ownerFollowupPath).Hash.ToLowerInvariant()
$generatorHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $generatorPath).Hash.ToLowerInvariant()

$sourceLinks = @(
    [ordered]@{id='U01_PRIVATE';a='U-01';b='C-PRIVATE'},
    [ordered]@{id='BOUTIQUE_PRIVATE';a='C-PRIVATE';b='U-02'},
    [ordered]@{id='PRIVATE_HYBRID';a='U-02';b='U-03'},
    [ordered]@{id='HYBRID_JJ';a='U-03';b='U-06'},
    [ordered]@{id='GUEST_JJ';a='U-06';b='U-04'},
    [ordered]@{id='PRIMARY_BATH';a='U-01';b='U-05'}
)
$routeCandidates = @($audit.candidates | Where-Object { $_.all_public_and_private_only -eq $true })
$rows = New-Object 'System.Collections.Generic.List[object]'
$candidateSummaries = New-Object 'System.Collections.Generic.List[object]'
$tol = 0.0001
$bad = New-Object 'System.Collections.Generic.List[string]'

foreach ($verified in $routeCandidates) {
    $candidate = @($archive.candidates | Where-Object { $_.layout_key -ceq $verified.layout_key })
    if ($candidate.Count -ne 1) { [void]$bad.Add("candidate map count for $($verified.layout_key): $($candidate.Count)"); continue }
    $candidate = $candidate[0]
    $linkRows = New-Object 'System.Collections.Generic.List[object]'
    foreach ($link in $sourceLinks) {
        $a = $candidate.rectangles.PSObject.Properties[$link.a].Value
        $b = $candidate.rectangles.PSObject.Properties[$link.b].Value
        if ($null -eq $a -or $null -eq $b) { [void]$bad.Add("missing rectangle $($link.a) or $($link.b)"); continue }
        $leftA=[double]$a.x_ft; $rightA=$leftA+[double]$a.width_ft
        $bottomA=[double]$a.y_ft; $topA=$bottomA+[double]$a.depth_ft
        $leftB=[double]$b.x_ft; $rightB=$leftB+[double]$b.width_ft
        $bottomB=[double]$b.y_ft; $topB=$bottomB+[double]$b.depth_ft
        $segment = $null
        $lo=[Math]::Max($bottomA,$bottomB); $hi=[Math]::Min($topA,$topB)
        if (($hi-$lo) -gt $tol) {
            if ($rightA -le $leftB+$tol) { $gap=[Math]::Max(0.0,$leftB-$rightA); $faceA=$rightA; $faceB=$leftB }
            elseif ($rightB -le $leftA+$tol) { $gap=[Math]::Max(0.0,$leftA-$rightB); $faceA=$rightB; $faceB=$leftA }
            else { $gap=-1 }
            if ($gap -ge 0) { $segment=[ordered]@{orientation='vertical';face_a_coordinate_ft=[Math]::Round($faceA,6);face_b_coordinate_ft=[Math]::Round($faceB,6);start_ft=[Math]::Round($lo,6);end_ft=[Math]::Round($hi,6);span_ft=[Math]::Round(($hi-$lo),6);gap_ft=[Math]::Round($gap,6)} }
        }
        $lo=[Math]::Max($leftA,$leftB); $hi=[Math]::Min($rightA,$rightB)
        if ($null -eq $segment -and ($hi-$lo) -gt $tol) {
            if ($topA -le $bottomB+$tol) { $gap=[Math]::Max(0.0,$bottomB-$topA); $faceA=$topA; $faceB=$bottomB }
            elseif ($topB -le $bottomA+$tol) { $gap=[Math]::Max(0.0,$bottomA-$topB); $faceA=$topB; $faceB=$bottomA }
            else { $gap=-1 }
            if ($gap -ge 0) { $segment=[ordered]@{orientation='horizontal';face_a_coordinate_ft=[Math]::Round($faceA,6);face_b_coordinate_ft=[Math]::Round($faceB,6);start_ft=[Math]::Round($lo,6);end_ft=[Math]::Round($hi,6);span_ft=[Math]::Round(($hi-$lo),6);gap_ft=[Math]::Round($gap,6)} }
        }
        if ($null -eq $segment) { [void]$bad.Add("no positive face-overlap interval for $($link.id) in $($verified.layout_key)"); continue }
        $row=[ordered]@{
            layout_key=$verified.layout_key; link_id=$link.id; room_a=$link.a; room_b=$link.b
            interface_orientation=$segment.orientation; room_a_face_coordinate_ft=$segment.face_a_coordinate_ft; room_b_face_coordinate_ft=$segment.face_b_coordinate_ft
            segment_start_ft=$segment.start_ft; segment_end_ft=$segment.end_ft; face_overlap_span_ft=$segment.span_ft; interstitial_gap_ft=$segment.gap_ft
            route_qualified=$true; layout_selected=$false; door_width_assumed=$false
        }
        [void]$rows.Add([pscustomobject]$row)
        [void]$linkRows.Add([pscustomobject]$row)
    }
    $spans=@($linkRows | ForEach-Object { [double]$_.face_overlap_span_ft } | Sort-Object)
    $gaps=@($linkRows | ForEach-Object { [double]$_.interstitial_gap_ft } | Sort-Object)
    if ($spans.Count -ne 6) { [void]$bad.Add("expected six interfaces in $($verified.layout_key); got $($spans.Count)"); continue }
    $median=($spans[2]+$spans[3])/2.0
    $hallSides=[ordered]@{}
    foreach ($roomId in @('U-01','U-02','U-04')) {
        $sides=@($candidate.hall_reachability.reachable_room_sides.$roomId | Sort-Object -Unique)
        $hallSides[$roomId]=$sides
    }
    [void]$candidateSummaries.Add([pscustomobject][ordered]@{
        layout_key=$verified.layout_key; links=@($linkRows.ToArray());
        minimum_face_overlap_span_ft=[Math]::Round($spans[0],6); median_face_overlap_span_ft=[Math]::Round($median,6); total_face_overlap_span_ft=[Math]::Round((($spans | Measure-Object -Sum).Sum),6); maximum_interstitial_gap_ft=[Math]::Round($gaps[-1],6)
        public_hall_grid_reached_rooms=@($candidate.public_rooms_reached | Sort-Object); sampled_reachable_room_sides=$hallSides
        u03_public_side_reachable=[bool]$candidate.hall_reachability.u03_hall_side_reachable
        interpretation='projected face-overlap interval across the source-defined nominal wall allowance; not an authored wall, opening, clear width, privacy, egress, or code result'
    })
}

$uniqueKeys=@($routeCandidates.layout_key | Sort-Object -Unique)
$u02EastNorth=@($candidateSummaries | Where-Object { $_.sampled_reachable_room_sides.'U-02' -contains 'east' -and $_.sampled_reachable_room_sides.'U-02' -contains 'north' })
$u02South=@($candidateSummaries | Where-Object { $_.sampled_reachable_room_sides.'U-02' -contains 'south' })
$u01East=@($candidateSummaries | Where-Object { $_.sampled_reachable_room_sides.'U-01' -contains 'east' })
$u04East=@($candidateSummaries | Where-Object { $_.sampled_reachable_room_sides.'U-04' -contains 'east' })
$u03Public=@($candidateSummaries | Where-Object { $_.sampled_reachable_room_sides.'U-03'.Count -gt 0 })
$checks=[ordered]@{
    archive_hash_matches_independent_audit=($archiveHash -eq $auditArchiveHash)
    search_hash_matches_independent_audit=($searchHash -eq $auditSearchHash)
    archive_binds_search=(([string]$archive.source_search_sha256) -eq $searchHash)
    selected_d_matches_independent_audit=($selectedDHash -eq [string]$audit.hashes_sha256.selected_d)
    owner_followup_study_matches_generator_manifest=($ownerFollowupHash -eq [string]$audit.hashes_sha256.owner_followup)
    expected_m164_candidate_count=($archive.candidate_count -eq 120 -and $routeCandidates.Count -eq 48)
    route_candidate_keys_are_unique=($uniqueKeys.Count -eq $routeCandidates.Count)
    every_route_candidate_maps_once_to_source_archive=($candidateSummaries.Count -eq $routeCandidates.Count)
    six_positive_face_overlap_intervals_per_candidate=($rows.Count -eq ($routeCandidates.Count*6) -and $bad.Count -eq 0)
    all_six_links_use_documented_half_foot_wall_allowance=(@($rows | Where-Object { [Math]::Abs([double]$_.interstitial_gap_ft-0.5) -gt $tol }).Count -eq 0)
    generator_matches_independent_audit=($generatorHash -eq [string]$audit.hashes_sha256.generator)
    owner_private_topology_kept=(@($candidateSummaries | Where-Object { $_.public_hall_grid_reached_rooms -contains 'U-01' -and $_.public_hall_grid_reached_rooms -contains 'U-02' -and $_.public_hall_grid_reached_rooms -contains 'U-04' -and -not $_.u03_public_side_reachable }).Count -eq $routeCandidates.Count)
    u02_east_and_north_sides_reachable_in_all_candidates=($u02EastNorth.Count -eq 48)
    u02_south_side_reachable_in_24_candidates=($u02South.Count -eq 24)
    u01_and_u04_east_side_reachable_in_all_candidates=($u01East.Count -eq 48 -and $u04East.Count -eq 48)
    u03_has_no_public_hall_side_reach=($u03Public.Count -eq 0)
    no_door_widths_or_layout_selections_inferred=(@($rows | Where-Object { $_.door_width_assumed -or $_.layout_selected }).Count -eq 0)
}
$failed=@($checks.Keys | Where-Object { -not $checks[$_] })
if ($failed.Count) { throw "M171 validation failed: $($failed -join ', '); geometry issues: $($bad -join '; ')" }

$candidateSummary=@($candidateSummaries | Sort-Object @{Expression='minimum_face_overlap_span_ft';Descending=$true}, @{Expression='median_face_overlap_span_ft';Descending=$true}, @{Expression='total_face_overlap_span_ft';Descending=$true}, @{Expression='maximum_interstitial_gap_ft';Descending=$false}, @{Expression='layout_key';Descending=$false} | ForEach-Object -Begin {$rank=0} -Process {$rank++; $_ | Add-Member -NotePropertyName geometric_interface_rank -NotePropertyValue $rank -PassThru})
$hallSideSummary=New-Object 'System.Collections.Generic.List[object]'
foreach ($roomId in @('U-01','U-02','U-03','U-04')) {
    $sets=@($candidateSummaries | ForEach-Object { $sides=@($_.sampled_reachable_room_sides.$roomId | Sort-Object -Unique); [pscustomobject]@{key=($sides -join ',');sides=$sides} })
    foreach ($group in @($sets | Group-Object key | Sort-Object Name)) { [void]$hallSideSummary.Add([pscustomobject][ordered]@{room_id=$roomId;reachable_sides=@($group.Group[0].sides);layout_count=$group.Count}) }
}
$report=[ordered]@{
    schema='forever-home.m171-upper-suite-interface-options.v1'; milestone='M171'
    status='pass'; title='Shared room-block interface segments for route-qualified upper-suite proposals'
    interpretation='Geometric interface inventory only; measured projected room-face overlap spans across a documented nominal wall allowance are not wall openings or door clear widths.'
    owner_direction=@('U-02 direct shared-hall arrival','U-03 private route only through U-02','U-04 independent guest hall access','both U-06 Jack-and-Jill links')
    test_shell='38.333333 x 40 ft exploration case only; not selected house dimensions'
    route_qualified_layout_count=$candidateSummaries.Count; interface_rows=$rows.Count; sampled_hall_side_summary=@($hallSideSummary.ToArray())
    ranking='Descending minimum, median, then total of six face-overlap spans; then lower maximum nominal wall allowance. Ties are ordered by layout key. Descriptive geometry ranking only.'
    selected=$false; checks=$checks; failures=@();
    source_sha256=[ordered]@{candidate_archive=$archiveHash;search=$searchHash;independent_audit=(Get-FileHash -Algorithm SHA256 -LiteralPath $auditPath).Hash.ToLowerInvariant();selected_d=$selectedDHash;owner_followup_study=$ownerFollowupHash;generator=$generatorHash}
    limitations=@('Finite-grid M164 candidates and sampled 4 ft public-route evidence only.','The M37 source defines a 0.5 ft nominal wall allowance; the measured gap and face-overlap interval do not establish an authored wall or suitable wall assembly.','Interface spans are not door clear widths and do not establish opening position, swing, privacy, egress, accessibility or usable circulation.','No room layout, M-06 fixture, wall assembly, floor/eave datum, roof assembly, structural condition, or code pass/fail is selected or evaluated. Selected-D remains unchanged.')
    candidates=$candidateSummary
}
$jsonPath=Join-Path $out 'm171-upper-suite-interface-options.json'
$csvPath=Join-Path $out 'm171-upper-suite-interface-segments.csv'
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
$rows | Sort-Object layout_key,link_id | Select-Object layout_key,link_id,room_a,room_b,interface_orientation,room_a_face_coordinate_ft,room_b_face_coordinate_ft,segment_start_ft,segment_end_ft,face_overlap_span_ft,interstitial_gap_ft,route_qualified,layout_selected,door_width_assumed | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
Write-Output "M171 interface checks passed: $($checks.Count)/$($checks.Count); $($candidateSummaries.Count) route-qualified layouts, $($rows.Count) face-overlap intervals."
Write-Output "JSON: $jsonPath"
Write-Output "CSV: $csvPath"
