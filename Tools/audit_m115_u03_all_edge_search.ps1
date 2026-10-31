param(
    [string]$PackageDirectory = '.local/revalidation/M115-all-edge',
    [string]$OutputDirectory = ''
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$prefix=$root.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
$package=[IO.Path]::GetFullPath((Join-Path $root $PackageDirectory))
if(-not $package.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'PackageDirectory must resolve inside the repository.'}
if([string]::IsNullOrWhiteSpace($OutputDirectory)){$output=$package}else{$output=[IO.Path]::GetFullPath((Join-Path $root $OutputDirectory))}
if(-not $output.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside the repository.'}
$paths=[ordered]@{search=(Join-Path $package 'search.json');checks=(Join-Path $package 'checks.json');manifest=(Join-Path $package 'manifest.json');archive=(Join-Path $package 'all-route-tested-candidates.json');svg=(Join-Path $package 'upper-suite-search.svg')}
foreach($path in $paths.Values){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing M115 artifact: $path"}}
$search=[IO.File]::ReadAllText($paths.search)|ConvertFrom-Json
$checks=[IO.File]::ReadAllText($paths.checks)|ConvertFrom-Json
$manifest=[IO.File]::ReadAllText($paths.manifest)|ConvertFrom-Json
$archive=[IO.File]::ReadAllText($paths.archive)|ConvertFrom-Json
$svg=[xml][IO.File]::ReadAllText($paths.svg)
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$programPath=Join-Path $root 'Requirements/Room_Program.md'
$selected=Get-Content -Raw -LiteralPath $selectedPath|ConvertFrom-Json
$proposal=Get-Content -Raw -LiteralPath $proposalPath|ConvertFrom-Json
$tol=0.00001;$shellW=38.333333;$shellD=40.0
function Gap([double]$a0,[double]$a1,[double]$b0,[double]$b1){if($a1 -le $b0){return $b0-$a1};if($b1 -le $a0){return $a0-$b1};return 0.0}
function Overlap([double]$a0,[double]$a1,[double]$b0,[double]$b1){[Math]::Max(0.0,[Math]::Min($a1,$b1)-[Math]::Max($a0,$b0))}
function HasContact($a,$b){$gx=Gap $a.x_ft ($a.x_ft+$a.width_ft) $b.x_ft ($b.x_ft+$b.width_ft);$gy=Gap $a.y_ft ($a.y_ft+$a.depth_ft) $b.y_ft ($b.y_ft+$b.depth_ft);$ox=Overlap $a.x_ft ($a.x_ft+$a.width_ft) $b.x_ft ($b.x_ft+$b.width_ft);$oy=Overlap $a.y_ft ($a.y_ft+$a.depth_ft) $b.y_ft ($b.y_ft+$b.depth_ft);(($gx -le 0.50001 -and $gy -le $tol -and $oy -ge 3.49999)-or($gy -le 0.50001 -and $gx -le $tol -and $ox -ge 3.49999))}
$selectedHash=(Get-FileHash $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
$proposalHash=(Get-FileHash $proposalPath -Algorithm SHA256).Hash.ToLowerInvariant()
$programHash=(Get-FileHash $programPath -Algorithm SHA256).Hash.ToLowerInvariant()
$programHash=(Get-FileHash $programPath -Algorithm SHA256).Hash.ToLowerInvariant()
$generatorPath=Join-Path $root 'Tools/test_m37_upper_suite_pack_and_route.ps1'
$generatorHash=(Get-FileHash $generatorPath -Algorithm SHA256).Hash.ToLowerInvariant()
$searchHash=(Get-FileHash $paths.search -Algorithm SHA256).Hash.ToLowerInvariant()
$checksHash=(Get-FileHash $paths.checks -Algorithm SHA256).Hash.ToLowerInvariant()
$archiveHash=(Get-FileHash $paths.archive -Algorithm SHA256).Hash.ToLowerInvariant()
$svgHash=(Get-FileHash $paths.svg -Algorithm SHA256).Hash.ToLowerInvariant()
$candidates=@($archive.candidates)
$roomIds=@('U-01','C-PRIVATE','U-02','U-03','U-05','U-06','U-04')
$links=@(@('U-01','C-PRIVATE'),@('C-PRIVATE','U-02'),@('U-02','U-03'),@('U-03','U-06'),@('U-06','U-04'),@('U-01','U-05'))
$contained=$true;$dimensions=$true;$separated=$true;$topology=$true;$routesReconstruct=$true
$edgeCounts=@{north=0;east=0;south=0;west=0};$edgePairs=@{}
$fullRoute=0;$U02North=0;$U03Side=0;$fullNoU03Side=0
$routeCounts=[ordered]@{'0'=0;'1'=0;'2'=0;'3'=0}
foreach($candidate in $candidates){
    $rects=$candidate.rectangles
    foreach($id in $roomIds){$r=$rects.$id;if($null -eq $r){$contained=$false;$dimensions=$false;continue};if($r.x_ft -lt -$tol -or $r.y_ft -lt -$tol -or $r.x_ft+$r.width_ft -gt $shellW+$tol -or $r.y_ft+$r.depth_ft -gt $shellD+$tol){$contained=$false};$sourceRoom=$selected.plans.upper|Where-Object id -eq $id|Select-Object -First 1;if($sourceRoom){$same=([Math]::Abs($r.width_ft-[double]$sourceRoom.w)-le $tol -and [Math]::Abs($r.depth_ft-[double]$sourceRoom.d)-le $tol);$rotated=([Math]::Abs($r.width_ft-[double]$sourceRoom.d)-le $tol -and [Math]::Abs($r.depth_ft-[double]$sourceRoom.w)-le $tol);if(-not($same -or $rotated)){$dimensions=$false}}}
    for($i=0;$i -lt $roomIds.Count;$i++){for($j=$i+1;$j -lt $roomIds.Count;$j++){$a=$rects.($roomIds[$i]);$b=$rects.($roomIds[$j]);$gx=Gap $a.x_ft ($a.x_ft+$a.width_ft) $b.x_ft ($b.x_ft+$b.width_ft);$gy=Gap $a.y_ft ($a.y_ft+$a.depth_ft) $b.y_ft ($b.y_ft+$b.depth_ft);if(-not($gx -ge 0.49999 -or $gy -ge 0.49999)){$separated=$false}}}
    foreach($link in $links){if(-not(HasContact $rects.($link[0]) $rects.($link[1]))){$topology=$false}}
    $u=$rects.'U-03';$edges=@();if([Math]::Abs($u.x_ft)-le $tol){$edgeCounts.west++;$edges+='west'};if([Math]::Abs($u.y_ft)-le $tol){$edgeCounts.north++;$edges+='north'};if([Math]::Abs($u.x_ft+$u.width_ft-$shellW)-le $tol){$edgeCounts.east++;$edges+='east'};if([Math]::Abs($u.y_ft+$u.depth_ft-$shellD)-le $tol){$edgeCounts.south++;$edges+='south'};if($edges.Count -eq 0){$topology=$false};$key=(@($edges|Sort-Object)-join '+');if(-not $edgePairs.ContainsKey($key)){$edgePairs[$key]=0};$edgePairs[$key]++
    $sides=$candidate.hall_reachability.reachable_room_sides;$reached=@(@('U-01','U-02','U-04')|Where-Object{@($sides.$_).Count -gt 0});if(($reached -join ',') -ne (@($candidate.public_rooms_reached|Sort-Object)-join ',')){$routesReconstruct=$false};$routeCounts[$reached.Count]++
    if($reached.Count -eq 3){$fullRoute++;if(@($sides.'U-02') -contains 'north'){$U02North++};if(-not $candidate.hall_reachability.u03_hall_side_reachable){$fullNoU03Side++}}
    if($candidate.hall_reachability.u03_hall_side_reachable){$U03Side++}
}
$seedExpected=$true;$expectedLabels=@();$expectedRunCounts=@{}
foreach($edge in @('north','east','south','west')){foreach($fraction in @(0.0,0.5,1.0)){$expectedLabels+=('{0}@{1}' -f $edge,$fraction.ToString('F1',[Globalization.CultureInfo]::InvariantCulture))}}
foreach($run in @($search.search.root_orientation_runs)){$parts=$run.seed -split '@';$edge=$parts[0];$fraction=[double]::Parse($parts[1],[Globalization.CultureInfo]::InvariantCulture);$expectedX=0.0;$expectedY=0.0;if($edge -in @('north','south')){$expectedX=$fraction*($shellW-$run.anchor_width_ft);$expectedY=if($edge -eq 'north'){0.0}else{$shellD-$run.anchor_depth_ft}}elseif($edge -in @('east','west')){$expectedX=if($edge -eq 'east'){$shellW-$run.anchor_width_ft}else{0.0};$expectedY=$fraction*($shellD-$run.anchor_depth_ft)}else{$seedExpected=$false;continue};if([Math]::Abs($expectedX-$run.root_x_ft)-gt $tol -or [Math]::Abs($expectedY-$run.root_y_ft)-gt $tol){$seedExpected=$false};if(-not $expectedRunCounts.ContainsKey($run.seed)){$expectedRunCounts[$run.seed]=0};$expectedRunCounts[$run.seed]++}
$allSeedRunsPresent=($expectedRunCounts.Count -eq $expectedLabels.Count -and @($expectedRunCounts.Values|Where-Object{$_ -ne 2}).Count -eq 0)
$seedLabels=@($search.search.landing_root_seed_sides)
$auditChecks=[ordered]@{
    selected_D_fingerprint_matches_current_source=($search.source_fingerprints_sha256.'selected_D_study.json' -eq $selectedHash)
    proposal_and_program_fingerprints_match_current_sources=($search.source_fingerprints_sha256.'owner_followup_study.json' -eq $proposalHash -and $search.source_fingerprints_sha256.'Requirements/Room_Program.md' -eq $programHash)
    owner_keeps_U03_private_route_only=($proposal.owner_inputs.u03_shared_hall_access -eq $false -and @($proposal.upper_suite.excluded_access_edges|Where-Object{$_.a -eq 'U-03' -and $_.b -eq 'C-UPPER'}).Count -eq 1)
    all_four_spread_seed_edges_and_scope_match=(($seedLabels -join ',') -eq ($expectedLabels -join ',') -and $search.search.u03_perimeter_seed_edge -eq 'all' -and $search.search.u03_perimeter_spread_seeds -eq $true -and $search.search.root_search_scope -eq 'U-03-only' -and [string]$search.search.search_root_rooms -eq 'U-03')
    all_24_seed_runs_have_expected_coordinates=($seedExpected -and $allSeedRunsPresent -and $search.search.root_orientation_runs.Count -eq 24)
    generator_integrity_checks_pass=($checks.failed.Count -eq 0)
    manifest_search_checks_archive_and_svg_hashes_match=($archive.source_search_sha256 -eq $searchHash -and $manifest.output_hashes_sha256.search -eq $searchHash -and $manifest.output_hashes_sha256.checks -eq $checksHash -and $manifest.output_hashes_sha256.svg -eq $svgHash -and $manifest.optional_route_tested_candidate_archive.sha256 -eq $archiveHash)
    SVG_parses_as_XML=($svg.DocumentElement.LocalName -eq 'svg')
    archive_inventory_matches_search=($candidates.Count -eq $archive.candidate_count -and $candidates.Count -eq $search.search.routes_with_clear_stair_approach)
    search_is_bounded_and_reports_incomplete=($search.search.search_complete -eq $false -and $search.search.nodes_expanded -le $search.search.node_limit)
    all_room_blocks_within_hypothetical_shell=($contained -and $candidates.Count -gt 0)
    all_room_dimensions_match_selected_D_allowing_rotation=$dimensions
    all_room_blocks_keep_half_foot_proxy_separation=$separated
    all_six_required_private_and_JJ_links_have_contact_proxy=$topology
    route_records_reconstruct_from_side_samples=$routesReconstruct
    full_public_route_count_matches_search=($fullRoute -eq $search.route_cases_reaching_U01_U02_U04 -and $fullRoute -gt 0)
    every_full_public_route_candidate_has_north_U02_sample=($U02North -eq $fullRoute)
    U03_side_sample_count_matches_generator=($search.route_access_counts_by_room.'U-03' -eq $U03Side)
    all_route_tested_U03_blocks_touch_north_edge=($edgeCounts.north -eq $candidates.Count)
    privacy_screen_subset_count_matches_archive=($fullNoU03Side -eq 73 -and $fullRoute -eq 80)
    selected_D_file_unchanged=($selectedHash -eq $search.source_fingerprints_sha256.'selected_D_study.json')
}
$failed=@($auditChecks.Keys|Where-Object{-not $auditChecks[$_]})
if($failed.Count -gt 0){throw "M115 independent audit failed: $($failed -join ', ')"}
$audit=[ordered]@{
    schema='forever-home.m115-u03-all-edge-audit.v1'
    interpretation='A bounded room-block sensitivity search found route-proxy candidates on north shell edge positions; none is a modeled or selected house layout.'
    shell=[ordered]@{width_ft=$shellW;depth_ft=$shellD;status='hypothetical exploration only'}
    search=[ordered]@{nodes_expanded=$search.search.nodes_expanded;node_limit=$search.search.node_limit;layouts_recorded=$search.search.layouts_recorded;search_complete=$search.search.search_complete;root_seed_labels=$seedLabels;root_seed_runs=$search.search.root_orientation_runs.Count;route_tested=$candidates.Count;route_reach_distribution=$routeCounts;full_public_route_candidates=$fullRoute;full_route_candidates_without_U03_hall_side_sample=$fullNoU03Side;U03_hall_side_sample_candidates=$U03Side}
    U03_shell_edge_contacts=$edgeCounts
    U03_edge_pair_distribution=$edgePairs
    best_route_candidate=[ordered]@{rectangles=$search.best_candidate.rectangles;public_room_samples=$search.best_candidate.public_rooms_reached;U02_hall_side_samples=@($search.best_candidate.hall_reachability.reachable_room_sides.'U-02');U03_hall_side_samples=@($search.best_candidate.hall_reachability.reachable_room_sides.'U-03');status='generator-ranked test candidate only; not owner-selected'}
    source_hashes_sha256=[ordered]@{selected_D_study=$selectedHash;owner_followup_study=$proposalHash;room_program=$programHash;search=$searchHash;checks=$checksHash;manifest=(Get-FileHash $paths.manifest -Algorithm SHA256).Hash.ToLowerInvariant();archive=$archiveHash;svg=$svgHash;M37_generator=$generatorHash;audit_script=(Get-FileHash $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()}
    checks=$auditChecks
    failed=@()
}
if(-not(Test-Path -LiteralPath $output)){New-Item -ItemType Directory -Path $output|Out-Null}
$audit|ConvertTo-Json -Depth 20|Set-Content -LiteralPath (Join-Path $output 'm115-audit.json') -Encoding utf8
$summary=[ordered]@{route_reach_distribution=$routeCounts;full_public_route_candidates=$fullRoute;full_route_without_U03_hall_side_sample=$fullNoU03Side;full_route_with_U03_hall_side_sample=($fullRoute-$fullNoU03Side);U03_shell_edge_contacts=$edgeCounts;U03_edge_pair_distribution=$edgePairs}
$summary|ConvertTo-Json -Depth 12|Set-Content -LiteralPath (Join-Path $output 'm115-audit-summary.json') -Encoding utf8
Write-Output ("M115 independent audit passed: {0}/{1}; {2}/{3} full public-route candidates, {4} without sampled U03 hall-side reach." -f $auditChecks.Count,$auditChecks.Count,$fullRoute,$candidates.Count,$fullNoU03Side)
