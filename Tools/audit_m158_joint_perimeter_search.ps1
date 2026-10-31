param(
    [string]$RunDirectory = '.local/revalidation/M158-joint-a',
    [string]$OutputDirectory = 'Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31'
)

$ErrorActionPreference='Stop'
$repo=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
function Resolve-RepoPath([string]$Path){
    $p=if([IO.Path]::IsPathRooted($Path)){[IO.Path]::GetFullPath($Path)}else{[IO.Path]::GetFullPath((Join-Path $repo $Path))}
    $prefix=$repo.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
    if(-not $p.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw "Path must resolve inside the repository: $Path"}
    return $p
}
function Get-Sha256([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Get-Overlap([double]$a0,[double]$a1,[double]$b0,[double]$b1){[Math]::Max(0.0,[Math]::Min($a1,$b1)-[Math]::Max($a0,$b0))}
function Test-ShellContact($r,[double]$w,[double]$d,[double]$dx,[double]$dy){$x=[double]$r.x_ft+$dx;$x1=$x+[double]$r.width_ft;$y=[double]$r.y_ft+$dy;$y1=$y+[double]$r.depth_ft;([Math]::Abs($x)-le 0.00001 -or [Math]::Abs($x1-$w)-le 0.00001 -or [Math]::Abs($y)-le 0.00001 -or [Math]::Abs($y1-$d)-le 0.00001)}

$run=Resolve-RepoPath $RunDirectory
$paths=[ordered]@{
    search=(Join-Path $run 'search.json'); checks=(Join-Path $run 'checks.json'); svg=(Join-Path $run 'upper-suite-search.svg'); manifest=(Join-Path $run 'manifest.json'); archive=(Join-Path $run 'all-route-tested-candidates.json')
    selected_d=(Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json')
    owner_followup=(Join-Path $repo 'Architecture/House_Design_Iteration_2026-10-28/study.json')
    room_program=(Join-Path $repo 'Requirements/Room_Program.md')
    generator=(Join-Path $repo 'Tools/test_m37_upper_suite_pack_and_route.ps1')
}
foreach($p in $paths.Values){if(-not(Test-Path -LiteralPath $p -PathType Leaf)){throw "Required input missing: $p"}}
$search=Get-Content $paths.search -Raw|ConvertFrom-Json
$generatorChecks=Get-Content $paths.checks -Raw|ConvertFrom-Json
$manifest=Get-Content $paths.manifest -Raw|ConvertFrom-Json
$archive=Get-Content $paths.archive -Raw|ConvertFrom-Json
$selectedHash=Get-Sha256 $paths.selected_d
$proposalHash=Get-Sha256 $paths.owner_followup
$programHash=Get-Sha256 $paths.room_program
$hashes=[ordered]@{}
foreach($key in $paths.Keys){$hashes[$key]=Get-Sha256 $paths[$key]}
$w=[double]$search.coordinate_basis.width_ft;$d=[double]$search.coordinate_basis.depth_ft;$tol=0.00001
$ids=@('U-01','C-PRIVATE','U-02','U-03','U-04','U-05','U-06')
$bedrooms=@('U-01','U-03','U-04')
$links=@(@('U-01','C-PRIVATE'),@('C-PRIVATE','U-02'),@('U-02','U-03'),@('U-03','U-06'),@('U-06','U-04'),@('U-01','U-05'))
$expectedInputs=$search.source_fingerprints_sha256
$archiveRows=[System.Collections.Generic.List[object]]::new()
$routeFullPrivate=0;$allThreeOutline=0;$u03PublicCount=0
foreach($c in $archive.candidates){
    $rects=$c.rectangles;$dx=[double]$c.translation_ft.x;$dy=[double]$c.translation_ft.y
    $inventory=((Compare-Object ($ids|Sort-Object) (@($rects.PSObject.Properties.Name)|Sort-Object)).Count -eq 0)
    $sizes=$inventory;$contained=$inventory;$noOverlap=$inventory;$noKeepout=$inventory;$contacts=$inventory
    $edges=[ordered]@{}
    foreach($id in $ids){
        $r=$rects.$id;$source=$search.source_dimensions_ft.$id
        $normal=([Math]::Abs([double]$r.width_ft-[double]$source.width_ft)-le $tol -and [Math]::Abs([double]$r.depth_ft-[double]$source.depth_ft)-le $tol)
        $rotated=([Math]::Abs([double]$r.width_ft-[double]$source.depth_ft)-le $tol -and [Math]::Abs([double]$r.depth_ft-[double]$source.width_ft)-le $tol)
        if(-not($normal -or $rotated)){$sizes=$false}
        $x0=[double]$r.x_ft+$dx;$x1=$x0+[double]$r.width_ft;$y0=[double]$r.y_ft+$dy;$y1=$y0+[double]$r.depth_ft
        if($x0 -lt -$tol -or $y0 -lt -$tol -or $x1 -gt ($w+$tol) -or $y1 -gt ($d+$tol)){$contained=$false}
        if($id -in $bedrooms){
            $roomEdges=[System.Collections.Generic.List[string]]::new()
            if([Math]::Abs($x0)-le $tol){$roomEdges.Add('west')};if([Math]::Abs($x1-$w)-le $tol){$roomEdges.Add('east')};if([Math]::Abs($y0)-le $tol){$roomEdges.Add('south')};if([Math]::Abs($y1-$d)-le $tol){$roomEdges.Add('north')}
            $edges[$id]=$roomEdges.ToArray()
        }
        foreach($keepout in @($search.local_lift_keepout,$search.reserved_stair_approach)){
            $ox=Get-Overlap $x0 $x1 ([double]$keepout.x_ft) ([double]$keepout.x_ft+[double]$keepout.width_ft)
            $oy=Get-Overlap $y0 $y1 ([double]$keepout.y_ft) ([double]$keepout.y_ft+[double]$keepout.depth_ft)
            if($ox-gt $tol -and $oy-gt $tol){$noKeepout=$false}
        }
    }
    for($i=0;$i-lt $ids.Count;$i++){for($j=$i+1;$j-lt $ids.Count;$j++){$a=$rects.($ids[$i]);$b=$rects.($ids[$j]);$ox=Get-Overlap ([double]$a.x_ft) ([double]$a.x_ft+[double]$a.width_ft) ([double]$b.x_ft) ([double]$b.x_ft+[double]$b.width_ft);$oy=Get-Overlap ([double]$a.y_ft) ([double]$a.y_ft+[double]$a.depth_ft) ([double]$b.y_ft) ([double]$b.y_ft+[double]$b.depth_ft);if($ox-gt $tol -and $oy-gt $tol){$noOverlap=$false}}}
    foreach($link in $links){
        $a=$rects.($link[0]);$b=$rects.($link[1])
        $oy=Get-Overlap ([double]$a.y_ft) ([double]$a.y_ft+[double]$a.depth_ft) ([double]$b.y_ft) ([double]$b.y_ft+[double]$b.depth_ft)
        $ox=Get-Overlap ([double]$a.x_ft) ([double]$a.x_ft+[double]$a.width_ft) ([double]$b.x_ft) ([double]$b.x_ft+[double]$b.width_ft)
        $gx=[Math]::Min([Math]::Abs([double]$b.x_ft-([double]$a.x_ft+[double]$a.width_ft)),[Math]::Abs([double]$a.x_ft-([double]$b.x_ft+[double]$b.width_ft)))
        $gy=[Math]::Min([Math]::Abs([double]$b.y_ft-([double]$a.y_ft+[double]$a.depth_ft)),[Math]::Abs([double]$a.y_ft-([double]$b.y_ft+[double]$b.depth_ft)))
        if(-not(($oy-ge (3.5-$tol)-and [Math]::Abs($gx-0.5)-le $tol)-or($ox-ge (3.5-$tol)-and [Math]::Abs($gy-0.5)-le $tol))){$contacts=$false}
    }
    $allEdge=(@($bedrooms|Where-Object{@($edges[$_]).Count-gt 0}).Count-eq 3);if($allEdge){$allThreeOutline++}
    $u03Reach=[bool]$c.hall_reachability.u03_hall_side_reachable;if($u03Reach){$u03PublicCount++}
    $public=[bool]$c.hall_reachability.required_public_rooms_reached
    $sides=$c.hall_reachability.reachable_room_sides
    $publicRoomIds=@('U-01','U-02','U-04')
    $allPublicSides=(@($publicRoomIds|Where-Object{@($sides.$_).Count-gt 0}).Count-eq 3)
    $fullPrivate=($public-and $allPublicSides-and -not $u03Reach-and @($sides.'U-03').Count-eq 0)
    if($fullPrivate){$routeFullPrivate++}
    $archiveRows.Add([pscustomobject][ordered]@{
        layout_key=[string]$c.layout_key;room_inventory_valid=$inventory;source_dimensions_valid=$sizes;shell_contained=$contained;pairwise_non_overlap=$noOverlap;lift_and_approach_clear=$noKeepout;six_source_contact_links_valid=$contacts
        u01_outline_edges=(@($edges['U-01'])-join ';');u03_outline_edges=(@($edges['U-03'])-join ';');u04_outline_edges=(@($edges['U-04'])-join ';');all_three_bedroom_outline_contacts=$allEdge
        u01_u02_u04_public_samples_reached=$public;u03_public_side_reachable=$u03Reach;all_public_and_private_only=$fullPrivate
    })
}
$checks=[ordered]@{
    generator_artifacts_match_manifest=($hashes.search-eq[string]$manifest.output_hashes_sha256.search-and $hashes.checks-eq[string]$manifest.output_hashes_sha256.checks-and $hashes.svg-eq[string]$manifest.output_hashes_sha256.svg-and $hashes.archive-eq[string]$manifest.optional_route_tested_candidate_archive.sha256-and @($archive.candidates).Count-eq[int]$manifest.optional_route_tested_candidate_archive.candidate_count)
    generator_integrity_checks_pass_31_of_31=([int]$generatorChecks.count-eq 31-and @($generatorChecks.passed).Count-eq 31-and @($generatorChecks.failed).Count-eq 0-and @($search.failures).Count-eq 0)
    exact_joint_perimeter_search_mode_recorded=(@($search.search.required_test_shell_perimeter_contact_rooms|Sort-Object)-join ',' -eq 'U-01,U-03,U-04'-and $manifest.search_parameters.root_search_scope-eq 'U-01-only'-and $manifest.search_parameters.u01_perimeter_root_seeds-and $manifest.search_parameters.u01_perimeter_spread_seeds)
    shell_matches_owner_authorized_exploration=([Math]::Abs($w-38.333333)-le $tol-and [Math]::Abs($d-40)-le $tol-and $search.coordinate_basis.shell_case-match 'owner-authorized exploration only')
    selected_d_and_owner_followup_hashes_match_current=($expectedInputs.'selected_D_study.json'-eq $selectedHash-and $expectedInputs.'owner_followup_study.json'-eq $proposalHash)
    room_program_hash_matches_current=($expectedInputs.'Requirements/Room_Program.md'-eq $programHash)
    two_complete_route_tested_layouts_archived=(@($archiveRows).Count-eq 2-and $archive.candidate_count-eq 2)
    every_candidate_has_exact_room_inventory_and_source_sizes=(@($archiveRows|Where-Object{-not $_.room_inventory_valid-or-not $_.source_dimensions_valid}).Count-eq 0)
    every_candidate_is_shell_contained_and_nonoverlapping=(@($archiveRows|Where-Object{-not $_.shell_contained-or-not $_.pairwise_non_overlap}).Count-eq 0)
    every_candidate_clears_lift_and_approach=(@($archiveRows|Where-Object{-not $_.lift_and_approach_clear}).Count-eq 0)
    every_candidate_preserves_all_six_source_contact_links=(@($archiveRows|Where-Object{-not $_.six_source_contact_links_valid}).Count-eq 0)
    all_three_bedroom_capable_blocks_touch_outline_in_every_candidate=($allThreeOutline-eq $archiveRows.Count)
    all_candidates_keep_u03_private_from_sampled_public_side=($u03PublicCount-eq 0-and @($archiveRows|Where-Object u03_public_side_reachable).Count-eq 0)
    at_least_one_candidate_reaches_all_public_samples_and_keeps_u03_private=($routeFullPrivate-ge 1-and @($archiveRows|Where-Object all_public_and_private_only).Count-eq $routeFullPrivate)
    best_candidate_matches_audited_route_candidate=(@($archiveRows|Where-Object{$_.layout_key-eq[string]$search.best_candidate.layout_key-and $_.all_public_and_private_only}).Count-eq 1)
    selected_d_unchanged=((Get-Sha256 $paths.selected_d)-eq $selectedHash)
}
$failures=@($checks.Keys|Where-Object{-not $checks[$_]})
$report=[ordered]@{
    milestone='M158';title='Joint bedroom-capable room-block perimeter and route audit'
    status='two bounded, sampled-route-compatible room-block candidates found; neither is an owner-selected layout or an authored house model'
    shell='38.333333 x 40 ft owner-authorized exploration case only';candidate_count=$archiveRows.Count;full_public_and_private_only_count=$routeFullPrivate
    all_three_bedroom_outline_contact_count=$allThreeOutline;u03_sampled_public_side_count=$u03PublicCount
    perimeter_outline_contact_counts=[ordered]@{'U-01'=$archiveRows.Count;'U-03'=$archiveRows.Count;'U-04'=$archiveRows.Count}
    checks=$checks;failures=$failures;hashes_sha256=$hashes;candidates=$archiveRows
    limitations=@('Perimeter contact is with a hypothetical shell outline, not an exterior wall or EERO.','No window product, net-clear opening, sill, grade, well, qualifying yard/court or route to a public way is represented.','Hall reach is an M37 sampled 4-ft grid proxy, not a door, passage width, accessibility or egress validation.','The deterministic M37 search is bounded and incomplete; two route-compatible candidates do not establish feasibility or exhaust alternatives.','Roof, actual walls, floors, stair geometry, doors, services, Revit placement, IFC, site and permit applicability remain unverified. No code-compliance, structural-safety, certification, permit or construction-readiness finding is made.')
}
if($failures.Count){throw "M158 independent audit failed checks: $($failures -join ', ')"}
$out=Resolve-RepoPath $OutputDirectory
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out -Force|Out-Null}
$json=Join-Path $out 'm158-joint-perimeter-audit.json';$csv=Join-Path $out 'm158-candidate-audit.csv'
ConvertTo-Json -InputObject $report -Depth 12|Set-Content -LiteralPath $json -Encoding utf8
$archiveRows|Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
Write-Output "M158 independent audit passed $($checks.Count)/$($checks.Count); candidates=$($archiveRows.Count); full public/private=$routeFullPrivate; all-three-perimeter=$allThreeOutline; report SHA256=$(Get-Sha256 $json)"
