param(
    [string]$PackageDirectory = 'Architecture/M113_U03_Perimeter_Root_Search_2026-10-30',
    [string]$OutputDirectory = ''
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$package = [IO.Path]::GetFullPath((Join-Path $root $PackageDirectory))
$prefix = $root.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $package.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'PackageDirectory must resolve inside the repository.' }
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) { $output = $package }
else { $output = [IO.Path]::GetFullPath((Join-Path $root $OutputDirectory)) }
if (-not $output.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository.' }
$searchPath = Join-Path $package 'search.json'
$archivePath = Join-Path $package 'all-route-tested-candidates.json'
$checksPath = Join-Path $package 'checks.json'
$manifestPath = Join-Path $package 'manifest.json'
$svgPath = Join-Path $package 'upper-suite-search.svg'
foreach ($path in @($searchPath,$archivePath,$checksPath,$manifestPath,$svgPath)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing M113 source artifact: $path" } }
$search = [IO.File]::ReadAllText($searchPath) | ConvertFrom-Json
$archive = [IO.File]::ReadAllText($archivePath) | ConvertFrom-Json
$checks = [IO.File]::ReadAllText($checksPath) | ConvertFrom-Json
$manifest = [IO.File]::ReadAllText($manifestPath) | ConvertFrom-Json
$svg = [xml][IO.File]::ReadAllText($svgPath)
$selectedPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath = Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$roomProgramPath = Join-Path $root 'Requirements/Room_Program.md'
$program = [IO.File]::ReadAllText($selectedPath) | ConvertFrom-Json
$proposalHash=(Get-FileHash -LiteralPath $proposalPath -Algorithm SHA256).Hash.ToLowerInvariant()
$roomProgramHash=(Get-FileHash -LiteralPath $roomProgramPath -Algorithm SHA256).Hash.ToLowerInvariant()
$tol = 0.00001
function Gap([double]$a0,[double]$a1,[double]$b0,[double]$b1) { if ($a1 -le $b0) { return $b0-$a1 }; if ($b1 -le $a0) { return $a0-$b1 }; return 0.0 }
function Overlap([double]$a0,[double]$a1,[double]$b0,[double]$b1) { [Math]::Max(0.0,[Math]::Min($a1,$b1)-[Math]::Max($a0,$b0)) }
function HasContact($a,$b) {
    $gx=Gap $a.x_ft ($a.x_ft+$a.width_ft) $b.x_ft ($b.x_ft+$b.width_ft)
    $gy=Gap $a.y_ft ($a.y_ft+$a.depth_ft) $b.y_ft ($b.y_ft+$b.depth_ft)
    $ox=Overlap $a.x_ft ($a.x_ft+$a.width_ft) $b.x_ft ($b.x_ft+$b.width_ft)
    $oy=Overlap $a.y_ft ($a.y_ft+$a.depth_ft) $b.y_ft ($b.y_ft+$b.depth_ft)
    (($gx -le 0.50001 -and $gy -le $tol -and $oy -ge 3.49999) -or ($gy -le 0.50001 -and $gx -le $tol -and $ox -ge 3.49999))
}
$searchHash=(Get-FileHash -LiteralPath $searchPath -Algorithm SHA256).Hash.ToLowerInvariant()
$checksHash=(Get-FileHash -LiteralPath $checksPath -Algorithm SHA256).Hash.ToLowerInvariant()
$archiveHash=(Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
$svgHash=(Get-FileHash -LiteralPath $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()
$selectedHash=(Get-FileHash -LiteralPath $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
$generatorHash=(Get-FileHash -LiteralPath (Join-Path $root 'Tools/test_m37_upper_suite_pack_and_route.ps1') -Algorithm SHA256).Hash.ToLowerInvariant()
$candidateRecords=@($archive.candidates)
$expectedRooms=@('U-01','C-PRIVATE','U-02','U-03','U-05','U-06','U-04')
$requiredLinks=@(@('U-01','C-PRIVATE'),@('C-PRIVATE','U-02'),@('U-02','U-03'),@('U-03','U-06'),@('U-06','U-04'),@('U-01','U-05'))
$containment=$true; $nonOverlap=$true; $dimensions=$true; $links=$true; $u03Edge=$true; $routesReconstruct=$true
$routes=@{'0'=0;'1'=0;'2'=0;'3'=0}; $edgeCounts=@{north=0;east=0;south=0;west=0}; $u03EdgeCount=0; $u02ReachCount=0; $u03HallSideCount=0
foreach ($candidate in $candidateRecords) {
    $rects=$candidate.rectangles
    foreach($id in $expectedRooms){
        $r=$rects.$id
        if($null -eq $r){$containment=$false;$dimensions=$false;continue}
        if($r.x_ft -lt -$tol -or $r.y_ft -lt -$tol -or $r.x_ft+$r.width_ft -gt 38.333333+$tol -or $r.y_ft+$r.depth_ft -gt 40+$tol){$containment=$false}
        $source=$program.plans.upper|Where-Object id -eq $id|Select-Object -First 1
        if($source){$same=([Math]::Abs($r.width_ft-[double]$source.w) -le $tol -and [Math]::Abs($r.depth_ft-[double]$source.d) -le $tol);$rotated=([Math]::Abs($r.width_ft-[double]$source.d) -le $tol -and [Math]::Abs($r.depth_ft-[double]$source.w) -le $tol);if(-not($same -or $rotated)){$dimensions=$false}}
    }
    for($i=0;$i -lt $expectedRooms.Count;$i++){for($j=$i+1;$j -lt $expectedRooms.Count;$j++){$a=$rects.($expectedRooms[$i]);$b=$rects.($expectedRooms[$j]);if($null -eq $a -or $null -eq $b){continue};$gx=Gap $a.x_ft ($a.x_ft+$a.width_ft) $b.x_ft ($b.x_ft+$b.width_ft);$gy=Gap $a.y_ft ($a.y_ft+$a.depth_ft) $b.y_ft ($b.y_ft+$b.depth_ft);if(-not($gx -ge 0.49999 -or $gy -ge 0.49999)){$nonOverlap=$false}}}
    foreach($edge in $requiredLinks){if(-not(HasContact $rects.($edge[0]) $rects.($edge[1]))){$links=$false}}
    $u=$rects.'U-03';$touch=([Math]::Abs($u.x_ft) -le $tol -or [Math]::Abs($u.y_ft) -le $tol -or [Math]::Abs($u.x_ft+$u.width_ft-38.333333) -le $tol -or [Math]::Abs($u.y_ft+$u.depth_ft-40) -le $tol)
    if(-not $touch){$u03Edge=$false}else{$u03EdgeCount++}
    if([Math]::Abs($u.x_ft) -le $tol){$edgeCounts.west++};if([Math]::Abs($u.y_ft) -le $tol){$edgeCounts.north++};if([Math]::Abs($u.x_ft+$u.width_ft-38.333333) -le $tol){$edgeCounts.east++};if([Math]::Abs($u.y_ft+$u.depth_ft-40) -le $tol){$edgeCounts.south++}
    $sides=$candidate.hall_reachability.reachable_room_sides
    $reached=@(@('U-01','U-02','U-04')|Where-Object{@($sides.$_).Count -gt 0})
    if(($reached -join ',') -ne (@($candidate.public_rooms_reached|Sort-Object) -join ',')){$routesReconstruct=$false}
    $routes[[string]$reached.Count]++
    if(@($sides.'U-02').Count -gt 0){$u02ReachCount++}
    if(@($sides.'U-03').Count -gt 0){$u03HallSideCount++}
}
$checksOut=[ordered]@{
    source_selected_D_hash_matches=$archive.source_fingerprints_sha256.'selected_D_study.json' -eq $selectedHash
    M37_proposal_and_program_sources_match_current_files=($search.source_fingerprints_sha256.'owner_followup_study.json' -eq $proposalHash -and $search.source_fingerprints_sha256.'Requirements/Room_Program.md' -eq $roomProgramHash)
    search_archive_checks_svg_and_manifest_hashes_match=($archive.source_search_sha256 -eq $searchHash -and $manifest.output_hashes_sha256.search -eq $searchHash -and $manifest.output_hashes_sha256.checks -eq $checksHash -and $manifest.output_hashes_sha256.svg -eq $svgHash -and $manifest.optional_route_tested_candidate_archive.sha256 -eq $archiveHash)
    bounded_U03_only_four_edge_root_mode=($search.search.root_search_scope -eq 'U-03-only' -and [string]$search.search.search_root_rooms -eq 'U-03' -and $search.search.u03_perimeter_root_seeds -eq $true -and @($search.search.landing_root_seed_sides).Count -eq 4)
    generator_integrity_checks_pass=$checks.failed.Count -eq 0
    SVG_parses_as_XML=($svg.DocumentElement.LocalName -eq 'svg')
    archive_count_matches_generator=($candidateRecords.Count -eq $archive.candidate_count -and $archive.candidate_count -eq $search.search.routes_with_clear_stair_approach)
    all_seven_source_room_blocks_present_inside_hypothetical_shell=($containment -and $candidateRecords.Count -gt 0)
    room_dimensions_match_source_allowing_rotation=$dimensions
    all_room_pairs_keep_half_foot_proxy_separation=$nonOverlap
    all_six_private_and_jack_and_jill_links_have_contact_proxy=$links
    every_U03_block_touches_hypothetical_shell_edge=($u03Edge -and $u03EdgeCount -eq $candidateRecords.Count -and $candidateRecords.Count -gt 0)
    public_route_counts_reconstruct_from_archived_side_samples=$routesReconstruct
    zero_candidates_reach_all_three_required_public_rooms=$routes['3'] -eq 0
    zero_candidates_reach_U02_hall_sample=$u02ReachCount -eq 0
    selected_D_source_unchanged=(($selectedHash -eq $search.source_fingerprints_sha256.'selected_D_study.json'))
}
$failed=@($checksOut.Keys|Where-Object{-not $checksOut[$_]})
if($failed.Count -gt 0){throw "M113 independent checks failed: $($failed -join ', ')"}
$report=[ordered]@{
    schema='forever-home.m113-u03-perimeter-search-audit.v1'
    interpretation='A bounded room-block search only; shell-edge contact is a possible exterior-wall zone, not a wall or opening. No route-valid upper-suite candidate was found in this sample.'
    shell=[ordered]@{width_ft=38.333333;depth_ft=40;status='hypothetical owner-authorized exploration only'}
    search=[ordered]@{nodes_expanded=$search.search.nodes_expanded;node_limit=$search.search.node_limit;layouts_recorded=$search.search.layouts_recorded;route_tested=$candidateRecords.Count;search_complete=$search.search.search_complete;root_seed_sides=@($search.search.landing_root_seed_sides)}
    result=[ordered]@{U03_perimeter_contact_candidates=$u03EdgeCount;U03_edge_distribution=$edgeCounts;route_reach_count_distribution=$routes;U02_hall_sample_count=$u02ReachCount;U03_hall_side_sample_count=$u03HallSideCount;all_required_public_rooms_count=$routes['3'];public_route_proxy='sampled 4 ft hall grid to U-01/U-02/U-04; not door or clearance geometry'}
    source_hashes_sha256=[ordered]@{selected_D_study=$selectedHash;owner_followup_study=$proposalHash;room_program=$roomProgramHash;search=$searchHash;generator_checks=$checksHash;candidate_archive=$archiveHash;M37_generator=$generatorHash;audit_script=(Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()}
    checks=$checksOut
    failed=@()
}
if(-not(Test-Path -LiteralPath $output)){New-Item -ItemType Directory -Path $output|Out-Null}
$report|ConvertTo-Json -Depth 16|Set-Content -LiteralPath (Join-Path $output 'm113-audit.json') -Encoding utf8
$report.result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $output 'm113-audit-summary.json') -Encoding utf8
Write-Output ("M113 independent perimeter audit passed: {0}/{1}; U03 edge candidates {2}; U02 hall samples {3}; all-public candidates {4}." -f $checksOut.Count,$checksOut.Count,$u03EdgeCount,$u02ReachCount,$routes['3'])
