param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M147_M115_Suite_Interface_Comparison_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$m115 = Join-Path $repo 'Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30'
$archivePath = Join-Path $m115 'all-route-tested-candidates.json'
$auditPath = Join-Path $m115 'm115-audit.json'
$selectedDPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$ownerDecisionPath = Join-Path $repo 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
$roomProgramPath = Join-Path $repo 'Requirements/Room_Program.md'
$tolerance = 0.00001

function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-Contact($A, $B, [double]$WallBand) {
    $ax0=[double]$A.x_ft; $ay0=[double]$A.y_ft; $ax1=$ax0+[double]$A.width_ft; $ay1=$ay0+[double]$A.depth_ft
    $bx0=[double]$B.x_ft; $by0=[double]$B.y_ft; $bx1=$bx0+[double]$B.width_ft; $by1=$by0+[double]$B.depth_ft
    $v=[Math]::Min($ay1,$by1)-[Math]::Max($ay0,$by0); $h=[Math]::Min($ax1,$bx1)-[Math]::Max($ax0,$bx0)
    if ($v -gt $tolerance -and [Math]::Abs(($bx0-$ax1)-$WallBand) -le $tolerance) { return [pscustomobject]@{axis='vertical'; gap=[Math]::Round($bx0-$ax1,6); length=[Math]::Round($v,6)} }
    if ($v -gt $tolerance -and [Math]::Abs(($ax0-$bx1)-$WallBand) -le $tolerance) { return [pscustomobject]@{axis='vertical'; gap=[Math]::Round($ax0-$bx1,6); length=[Math]::Round($v,6)} }
    if ($h -gt $tolerance -and [Math]::Abs(($by0-$ay1)-$WallBand) -le $tolerance) { return [pscustomobject]@{axis='horizontal'; gap=[Math]::Round($by0-$ay1,6); length=[Math]::Round($h,6)} }
    if ($h -gt $tolerance -and [Math]::Abs(($ay0-$by1)-$WallBand) -le $tolerance) { return [pscustomobject]@{axis='horizontal'; gap=[Math]::Round($ay0-$by1,6); length=[Math]::Round($h,6)} }
    return $null
}

$inputPaths=@($archivePath,$auditPath,$selectedDPath,$ownerDecisionPath,$roomProgramPath)
foreach($path in $inputPaths){ if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required source missing: $path"} }
$archive=Get-Content -LiteralPath $archivePath -Raw | ConvertFrom-Json
$audit=Get-Content -LiteralPath $auditPath -Raw | ConvertFrom-Json
$selected=Get-Content -LiteralPath $selectedDPath -Raw | ConvertFrom-Json
$owner=Get-Content -LiteralPath $ownerDecisionPath -Raw
$sourceHashes=[ordered]@{
    m115_archive=Get-Sha256 $archivePath; m115_audit=Get-Sha256 $auditPath
    selected_d_study=Get-Sha256 $selectedDPath; owner_direction=Get-Sha256 $ownerDecisionPath
    room_program=Get-Sha256 $roomProgramPath
}
$expectedArchiveHash=[string]$audit.source_hashes_sha256.archive
$expectedSearchHash=[string]$audit.source_hashes_sha256.search
$searchPath=Join-Path $m115 'search.json'
$wallBand=0.5
$reservationValues=@($selected.upper_door_matrix | ForEach-Object {[double]$_.nominal_reservation_ft} | Select-Object -Unique)
$reservation=if($reservationValues.Count -eq 1){[double]$reservationValues[0]}else{[double]::NaN}
$links=@(
    [pscustomobject]@{a='U-01';b='C-PRIVATE';type='private suite'},
    [pscustomobject]@{a='C-PRIVATE';b='U-02';type='private suite'},
    [pscustomobject]@{a='U-02';b='U-03';type='private suite'},
    [pscustomobject]@{a='U-03';b='U-06';type='Jack-and-Jill'},
    [pscustomobject]@{a='U-06';b='U-04';type='Jack-and-Jill'},
    [pscustomobject]@{a='U-01';b='U-05';type='primary-only bath'}
)
$routeCandidates=@($archive.candidates | Where-Object {
    $_.public_rooms_reached_count -eq 3 -and $_.hall_reachability.required_public_rooms_reached -and -not $_.hall_reachability.u03_hall_side_reachable -and
    @($_.hall_reachability.reachable_room_sides.'U-01').Count -gt 0 -and @($_.hall_reachability.reachable_room_sides.'U-02').Count -gt 0 -and @($_.hall_reachability.reachable_room_sides.'U-04').Count -gt 0 -and @($_.hall_reachability.reachable_room_sides.'U-03').Count -eq 0
})
$rows=@(); $layouts=@()
foreach($candidate in $routeCandidates){
    $rects=$candidate.rectangles
    $layoutRows=@()
    foreach($link in $links){
        $a=$rects.($link.a); $b=$rects.($link.b)
        if($null -eq $a -or $null -eq $b){throw "Candidate $($candidate.layout_key) is missing $($link.a) or $($link.b)."}
        $contact=Get-Contact $a $b $wallBand
        $fits=($null -ne $contact -and $reservation -le [double]$contact.length+$tolerance)
        $row=[pscustomobject][ordered]@{
            layout_key=$candidate.layout_key; room_a=$link.a; room_b=$link.b; interface_type=$link.type
            contact_found=($null -ne $contact); shared_boundary_ft=if($null -ne $contact){$contact.length}else{$null}
            wall_band_ft=$wallBand; comparison_reservation_ft=$reservation
            centered_end_margin_each_ft=if($null -ne $contact){[Math]::Round(([double]$contact.length-$reservation)/2,6)}else{$null}
            reservation_fits_boundary_arithmetic=$fits; opening_or_door_modeled=$false; selected=$false
        }
        $rows += $row; $layoutRows += $row
    }
    $sides=$candidate.hall_reachability.reachable_room_sides
    $u03=$rects.'U-03'; $tx=[double]$candidate.translation_ft.x; $ty=[double]$candidate.translation_ft.y
    $u03x=[double]$u03.x_ft+$tx; $u03y=[double]$u03.y_ft+$ty
    $east=[Math]::Abs(($u03x+[double]$u03.width_ft)-38.333333) -lt 0.001
    $west=[Math]::Abs($u03x) -lt 0.001
    $north=[Math]::Abs($u03y) -lt 0.001
    $corner=if($north -and $east){'east+north'}elseif($north -and $west){'north+west'}else{'other shell edge'}
    $layouts += [pscustomobject][ordered]@{
        layout_key=$candidate.layout_key; layout_bounds_width_ft=[Math]::Round([double]$candidate.layout_bounds_ft.width,6)
        layout_bounds_depth_ft=[Math]::Round([double]$candidate.layout_bounds_ft.depth,6)
        u03_x_ft=[Math]::Round($u03x,6); u03_y_ft=[Math]::Round($u03y,6); u03_edge_position_label=$corner
        public_room_samples=[ordered]@{U01=(@($sides.'U-01'|Select-Object -Unique)-join ';');U02=(@($sides.'U-02'|Select-Object -Unique)-join ';');U04=(@($sides.'U-04'|Select-Object -Unique)-join ';');U03=(@($sides.'U-03'|Select-Object -Unique)-join ';')}
        six_contacts_found=(@($layoutRows|Where-Object contact_found).Count -eq 6)
        six_reservations_fit=(@($layoutRows|Where-Object reservation_fits_boundary_arithmetic).Count -eq 6)
        minimum_shared_boundary_ft=if(@($layoutRows|Where-Object contact_found).Count -eq 6){[Math]::Round([double](($layoutRows|Measure-Object shared_boundary_ft -Minimum).Minimum),6)}else{$null}
        minimum_centered_end_margin_ft=if(@($layoutRows|Where-Object reservation_fits_boundary_arithmetic).Count -eq 6){[Math]::Round([double](($layoutRows|Measure-Object centered_end_margin_each_ft -Minimum).Minimum),6)}else{$null}
        topology_links_checked=6; selected=$false
    }
}
$checks=[ordered]@{
    archive_hash_matches_independent_m115_audit=($sourceHashes.m115_archive -eq $expectedArchiveHash)
    m115_search_hash_matches_independent_audit=((Get-Sha256 $searchPath) -eq $expectedSearchHash)
    m115_independent_audit_passes_21_of_21=(@($audit.checks.PSObject.Properties).Count -eq 21 -and @($audit.checks.PSObject.Properties | Where-Object { -not [bool]$_.Value }).Count -eq 0 -and @($audit.failed).Count -eq 0)
    archive_declares_331_candidates=($archive.candidate_count -eq 331 -and @($archive.candidates).Count -eq 331)
    owner_topology_explicitly_recorded=($owner -match 'U-01.*C-PRIVATE.*U-02.*U-03' -and $owner -match 'private route only' -and $owner -match 'direct arrival from the upper shared hall to U-02' -and $owner -match 'U-03.*U-06.*U-06.*U-04')
    selected_d_source_reservation_is_3_5_ft=($reservationValues.Count -eq 1 -and [Math]::Abs($reservation-3.5) -lt $tolerance)
    '73_route_candidates_have_required_sampled_sides'=($routeCandidates.Count -eq 73)
    every_candidate_has_all_six_room_blocks=($rows.Count -eq $routeCandidates.Count*6)
    comparison_values_not_door_dimensions=$true
    no_layout_selected=(@($layouts|Where-Object selected).Count -eq 0)
}
$complete=@($layouts|Where-Object six_contacts_found)
$allFit=@($complete|Where-Object six_reservations_fit)
$subsetSummaries=@()
foreach($edgeName in @('east+north','north+west')){
    $subset=@($layouts|Where-Object u03_edge_position_label -eq $edgeName)
    $keys=@($subset|ForEach-Object layout_key)
    $subsetRows=@($rows|Where-Object {$keys -contains $_.layout_key})
    $linkStats=@()
    foreach($link in $links){
        $lr=@($subsetRows|Where-Object {$_.room_a -eq $link.a -and $_.room_b -eq $link.b})
        $minimum=if($lr.Count){[double](($lr|Measure-Object shared_boundary_ft -Minimum).Minimum)}else{$null}
        $atThreshold=@($lr|Where-Object {[Math]::Abs([double]$_.shared_boundary_ft-$reservation) -lt $tolerance}).Count
        $linkStats += [pscustomobject]@{room_a=$link.a;room_b=$link.b;minimum_shared_boundary_ft=$minimum;layouts_at_exact_reservation=$atThreshold;layout_count=$lr.Count}
    }
    $zeroMargin=@($subset|Where-Object {[Math]::Abs([double]$_.minimum_centered_end_margin_ft) -lt $tolerance}).Count
    $subsetSummaries += [pscustomobject][ordered]@{
        u03_edge_position=$edgeName;candidate_count=$subset.Count;all_six_reservations_fit=(@($subset|Where-Object six_reservations_fit).Count -eq $subset.Count)
        candidates_with_zero_minimum_centered_margin=$zeroMargin
        minimum_of_candidate_minimum_boundary_ft=if($subset.Count){[double](($subset|Measure-Object minimum_shared_boundary_ft -Minimum).Minimum)}else{$null}
        minimum_of_candidate_minimum_margin_ft=if($subset.Count){[double](($subset|Measure-Object minimum_centered_end_margin_ft -Minimum).Minimum)}else{$null}
        interface_statistics=$linkStats
    }
}
$checks.six_shared_boundaries_found_for_each_route_candidate=($complete.Count -eq $routeCandidates.Count)
$checks.all_six_comparison_reservations_fit_all_candidates=($allFit.Count -eq $complete.Count)
$checks.edge_subsets_match_m115_readme_counts=(@($layouts|Where-Object u03_edge_position_label -eq 'east+north').Count -eq 64 -and @($layouts|Where-Object u03_edge_position_label -eq 'north+west').Count -eq 9)
$failures=@($checks.Keys|Where-Object{-not $checks[$_]})
$report=[ordered]@{
    milestone='M147'; title='M115 route-compatible upper-suite interface contact comparison'
    status='bounded hypothetical room-block comparison; no candidate selected and no door geometry modeled'
    comparison_basis='73 of the 331 M115 archive candidates reach sampled U-01/U-02/U-04 public sides and have no sampled U-03 public side. Six owner-directed room links are checked against the selected-D 3.5 ft nominal reservation as a comparison proxy.'
    reservation_basis='Selected-D upper_door_matrix nominal reservation; not a clear opening, owner-approved dimension, code clearance or door schedule for these hypothetical layouts.'
    search_is_incomplete=$true; shell='38.333333 x 40 ft exploration-only shell'; selected_d_modified=$false
    route_compatible_candidate_count=$routeCandidates.Count; candidates_with_six_contacts=$complete.Count
    candidates_with_all_six_comparison_reservations_fitting=$allFit.Count
    source_hashes_sha256=$sourceHashes; checks=$checks; failures=$failures
    edge_subsets=$subsetSummaries; summary=$layouts; room_links=$rows
    limitations=@(
        'M115 is an incomplete room-block search over an explicitly hypothetical shell; no candidate is an approved house dimension or selected layout.',
        'A 3.5 ft nominal reservation is compared only with schematic shared-boundary length. No wall thickness, jambs, opening, leaf, swing, privacy, approach or usable clearance is modeled.',
        'Public reachability is a sampled grid proxy, not an actual door location or route validation.',
        'No ceiling, roof, stairs, egress, code applicability, fixture fit, service route, accessibility, structure, Revit placement or IFC result is established.'
    )
}
if($failures.Count){throw "M147 failed checks: $($failures -join ', ')"}
$resolved=if([IO.Path]::IsPathRooted($OutputDirectory)){[IO.Path]::GetFullPath($OutputDirectory)}else{[IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))}
$prefix=$repo.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if(-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside repository root.'}
if(-not(Test-Path -LiteralPath $resolved)){New-Item -ItemType Directory -Path $resolved -Force|Out-Null}
$json=Join-Path $resolved 'm147-suite-interface-comparison.json'; $csv=Join-Path $resolved 'm147-room-link-contacts.csv'; $summaryCsv=Join-Path $resolved 'm147-candidate-summary.csv'
ConvertTo-Json -InputObject $report -Depth 12 | Set-Content -LiteralPath $json -Encoding utf8
$rows|Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
$layouts|Export-Csv -LiteralPath $summaryCsv -NoTypeInformation -Encoding UTF8
Write-Output "M147 checks passed: $($checks.Count)/$($checks.Count); route candidates $($routeCandidates.Count); six contacts $($complete.Count); all six reservations fit $($allFit.Count); report SHA256 $(Get-Sha256 $json)."
