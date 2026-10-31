param(
    [string]$RunDirectory = '.local/revalidation/M157-U01',
    [string]$OutputDirectory = 'Architecture/M157_U01_Perimeter_Root_Search_2026-10-30'
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
function Resolve-RepoPath([string]$Path) {
    $resolved = if ([IO.Path]::IsPathRooted($Path)) { [IO.Path]::GetFullPath($Path) } else { [IO.Path]::GetFullPath((Join-Path $repo $Path)) }
    $prefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw "Path must resolve inside repository: $Path" }
    return $resolved
}
function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-Overlap([double]$A0,[double]$A1,[double]$B0,[double]$B1) { [Math]::Max(0.0,[Math]::Min($A1,$B1)-[Math]::Max($A0,$B0)) }

$run = Resolve-RepoPath $RunDirectory
$paths = [ordered]@{
    search = Join-Path $run 'search.json'; checks = Join-Path $run 'checks.json'; svg = Join-Path $run 'upper-suite-search.svg'; manifest = Join-Path $run 'manifest.json'; archive = Join-Path $run 'all-route-tested-candidates.json'
    selected_d = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
    room_program = Join-Path $repo 'Requirements/Room_Program.md'
    generator = Join-Path $repo 'Tools/test_m37_upper_suite_pack_and_route.ps1'
}
foreach ($p in $paths.Values) { if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw "Required input missing: $p" } }
$search = Get-Content -LiteralPath $paths.search -Raw | ConvertFrom-Json
$checksFile = Get-Content -LiteralPath $paths.checks -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $paths.manifest -Raw | ConvertFrom-Json
$archive = Get-Content -LiteralPath $paths.archive -Raw | ConvertFrom-Json
$selectedHash = Get-Sha256 $paths.selected_d
$programHash = Get-Sha256 $paths.room_program
$hashes = [ordered]@{}
foreach ($name in $paths.Keys) { $hashes[$name] = Get-Sha256 $paths[$name] }

$tol = 0.00001
$width = [double]$search.coordinate_basis.width_ft
$depth = [double]$search.coordinate_basis.depth_ft
$expectedIds = @('U-01','C-PRIVATE','U-02','U-03','U-04','U-05','U-06')
$links = @(@('U-01','C-PRIVATE'),@('C-PRIVATE','U-02'),@('U-02','U-03'),@('U-03','U-06'),@('U-06','U-04'),@('U-01','U-05'))
$roomLabels = [ordered]@{'U-01'='Primary bedroom';'U-03'='Hybrid bedroom/office';'U-04'='Guest / third bedroom'}
$candidateRows = [System.Collections.Generic.List[object]]::new()
$geometryValidCount = 0
$contactValidCount = 0
$allThreeExteriorCount = 0
$routeCompatible = @($archive.candidates | Where-Object {
    $_.public_rooms_reached_count -eq 3 -and $_.hall_reachability.required_public_rooms_reached -and
    -not $_.hall_reachability.u03_hall_side_reachable -and
    @($_.hall_reachability.reachable_room_sides.'U-01').Count -gt 0 -and
    @($_.hall_reachability.reachable_room_sides.'U-02').Count -gt 0 -and
    @($_.hall_reachability.reachable_room_sides.'U-04').Count -gt 0 -and
    @($_.hall_reachability.reachable_room_sides.'U-03').Count -eq 0
})
$u03HallReachCount = @($archive.candidates | Where-Object { $_.hall_reachability.u03_hall_side_reachable }).Count
$perimeterCounts = [ordered]@{'U-01'=0;'U-03'=0;'U-04'=0}
foreach ($candidate in $archive.candidates) {
    $translationX = [double]$candidate.translation_ft.x
    $translationY = [double]$candidate.translation_ft.y
    $rects = $candidate.rectangles
    $idsMatch = ((Compare-Object ($expectedIds | Sort-Object) (@($rects.PSObject.Properties.Name) | Sort-Object)).Count -eq 0)
    $inside = $idsMatch; $noOverlap = $idsMatch; $sourceSizes = $idsMatch; $contactsValid = $idsMatch
    if ($idsMatch) {
        foreach ($id in $expectedIds) {
            $r = $rects.$id; $src = $search.source_dimensions_ft.$id
            $same = ([Math]::Abs([double]$r.width_ft-[double]$src.width_ft) -le $tol -and [Math]::Abs([double]$r.depth_ft-[double]$src.depth_ft) -le $tol)
            $rotated = ([Math]::Abs([double]$r.width_ft-[double]$src.depth_ft) -le $tol -and [Math]::Abs([double]$r.depth_ft-[double]$src.width_ft) -le $tol)
            if (-not ($same -or $rotated)) { $sourceSizes = $false }
            $x0 = [double]$r.x_ft + $translationX; $x1 = $x0 + [double]$r.width_ft
            $y0 = [double]$r.y_ft + $translationY; $y1 = $y0 + [double]$r.depth_ft
            if ($x0 -lt -$tol -or $y0 -lt -$tol -or $x1 -gt ($width+$tol) -or $y1 -gt ($depth+$tol)) { $inside = $false }
            if ($id -in $roomLabels.Keys) {
                $touch = ([Math]::Abs($x0) -le $tol -or [Math]::Abs($x1-$width) -le $tol -or [Math]::Abs($y0) -le $tol -or [Math]::Abs($y1-$depth) -le $tol)
                if ($touch) { $perimeterCounts[$id]++ }
            }
        }
        for ($i=0; $i -lt $expectedIds.Count; $i++) {
            for ($j=$i+1; $j -lt $expectedIds.Count; $j++) {
                $a=$rects.($expectedIds[$i]); $b=$rects.($expectedIds[$j])
                $ox=Get-Overlap ([double]$a.x_ft) ([double]$a.x_ft+[double]$a.width_ft) ([double]$b.x_ft) ([double]$b.x_ft+[double]$b.width_ft)
                $oy=Get-Overlap ([double]$a.y_ft) ([double]$a.y_ft+[double]$a.depth_ft) ([double]$b.y_ft) ([double]$b.y_ft+[double]$b.depth_ft)
                if ($ox -gt $tol -and $oy -gt $tol) { $noOverlap = $false }
            }
        }
        foreach ($link in $links) {
            $a=$rects.($link[0]); $b=$rects.($link[1])
            $overlapY=Get-Overlap ([double]$a.y_ft) ([double]$a.y_ft+[double]$a.depth_ft) ([double]$b.y_ft) ([double]$b.y_ft+[double]$b.depth_ft)
            $overlapX=Get-Overlap ([double]$a.x_ft) ([double]$a.x_ft+[double]$a.width_ft) ([double]$b.x_ft) ([double]$b.x_ft+[double]$b.width_ft)
            $xGap=[Math]::Min([Math]::Abs(([double]$b.x_ft)-([double]$a.x_ft+[double]$a.width_ft)),[Math]::Abs(([double]$a.x_ft)-([double]$b.x_ft+[double]$b.width_ft)))
            $yGap=[Math]::Min([Math]::Abs(([double]$b.y_ft)-([double]$a.y_ft+[double]$a.depth_ft)),[Math]::Abs(([double]$a.y_ft)-([double]$b.y_ft+[double]$b.depth_ft)))
            $contact=(($overlapY -ge (3.5-$tol) -and [Math]::Abs($xGap-0.5) -le $tol) -or ($overlapX -ge (3.5-$tol) -and [Math]::Abs($yGap-0.5) -le $tol))
            if (-not $contact) { $contactsValid = $false }
        }
    }
    if ($idsMatch -and $inside -and $noOverlap -and $sourceSizes) { $geometryValidCount++ }
    if ($idsMatch -and $contactsValid) { $contactValidCount++ }
    $perimFlags=[ordered]@{}
    foreach($id in $roomLabels.Keys){$r=$rects.$id;$x0=[double]$r.x_ft+$translationX;$x1=$x0+[double]$r.width_ft;$y0=[double]$r.y_ft+$translationY;$y1=$y0+[double]$r.depth_ft;$perimFlags[$id]=([Math]::Abs($x0)-le $tol -or [Math]::Abs($x1-$width)-le $tol -or [Math]::Abs($y0)-le $tol -or [Math]::Abs($y1-$depth)-le $tol)}
    if ($perimFlags['U-01'] -and $perimFlags['U-03'] -and $perimFlags['U-04']) { $allThreeExteriorCount++ }
    $candidateRows.Add([pscustomobject][ordered]@{
        layout_key=[string]$candidate.layout_key; all_room_ids_match=$idsMatch; source_dimensions_match=$sourceSizes; shell_contained=$inside; no_room_overlap=$noOverlap; six_source_contact_links_match=$contactsValid
        u01_test_outline_contact=$perimFlags['U-01']; u03_test_outline_contact=$perimFlags['U-03']; u04_test_outline_contact=$perimFlags['U-04']
        all_three_bedroom_candidates_touch_test_outline=($perimFlags['U-01'] -and $perimFlags['U-03'] -and $perimFlags['U-04'])
        required_sampled_public_routes=$candidate.hall_reachability.required_public_rooms_reached; u03_public_side_reachable=$candidate.hall_reachability.u03_hall_side_reachable
    })
}
$m37ChecksPass = (@($checksFile.checks.PSObject.Properties).Count -eq [int]$checksFile.count -and @($checksFile.passed).Count -eq [int]$checksFile.count -and @($checksFile.failed).Count -eq 0 -and @($search.failures).Count -eq 0)
$m37HashMatch = ($hashes.search -eq [string]$manifest.output_hashes_sha256.search -and $hashes.checks -eq [string]$manifest.output_hashes_sha256.checks -and $hashes.svg -eq [string]$manifest.output_hashes_sha256.svg -and $hashes.archive -eq [string]$manifest.optional_route_tested_candidate_archive.sha256 -and @($archive.candidates).Count -eq [int]$manifest.optional_route_tested_candidate_archive.candidate_count)
$expectedInputs = $search.source_fingerprints_sha256
$checks = [ordered]@{
    m37_artifacts_match_manifest=$m37HashMatch
    m37_internal_checks_all_pass=$m37ChecksPass
    expected_u01_perimeter_seed_configuration=($manifest.search_parameters.root_search_scope -eq 'U-01-only' -and $manifest.search_parameters.u01_perimeter_root_seeds -and $manifest.search_parameters.u01_perimeter_seed_edge -eq 'all' -and $manifest.search_parameters.u01_perimeter_spread_seeds)
    source_hashes_match_current_selected_d=($expectedInputs.'selected_D_study.json' -eq $selectedHash)
    source_hashes_match_current_room_program=($expectedInputs.'Requirements/Room_Program.md' -eq $programHash)
    shell_is_owner_authorized_exploration_case=([Math]::Abs($width-38.333333)-le $tol -and [Math]::Abs($depth-40)-le $tol -and $search.coordinate_basis.shell_case -match 'owner-authorized exploration only')
    route_archive_contains_766_records=(@($archive.candidates).Count -eq 766 -and $archive.candidate_count -eq 766)
    every_route_record_has_seven_source_rooms=(@($candidateRows | Where-Object { -not $_.all_room_ids_match }).Count -eq 0)
    every_route_record_matches_source_dimensions=(@($candidateRows | Where-Object { -not $_.source_dimensions_match }).Count -eq 0)
    every_route_record_is_shell_contained=(@($candidateRows | Where-Object { -not $_.shell_contained }).Count -eq 0)
    every_route_record_has_no_room_overlap=(@($candidateRows | Where-Object { -not $_.no_room_overlap }).Count -eq 0)
    every_route_record_preserves_six_contact_links=($contactValidCount -eq $candidateRows.Count)
    every_u01_rooted_record_keeps_u01_outline_contact=($perimeterCounts['U-01'] -eq $candidateRows.Count)
    u03_has_no_outline_contact_in_route_archive=($perimeterCounts['U-03'] -eq 0)
    u04_outline_count_matches_replay=($perimeterCounts['U-04'] -eq 20)
    no_full_public_route_private_u03_candidate_exists=(@($candidateRows | Where-Object { $_.required_sampled_public_routes -and -not $_.u03_public_side_reachable }).Count -eq 0)
    u03_public_side_count_matches_search_report=($u03HallReachCount -eq [int]$search.route_access_counts_by_room.'U-03')
    no_candidate_has_outline_contact_for_all_three_bedroom_spaces=($allThreeExteriorCount -eq 0)
    no_candidate_or_shell_selected=($null -eq $search.best_candidate -and $allThreeExteriorCount -ge 0)
    selected_d_unchanged=((Get-Sha256 $paths.selected_d) -eq $selectedHash)
}
$failures=@($checks.Keys|Where-Object{-not $checks[$_]})
$report=[ordered]@{
    milestone='M157'; title='U-01 hypothetical perimeter-rooted suite search audit'
    status='bounded, incomplete room-block search; no viable full-route/private-only layout found and no design selected'
    shell='38.333333 x 40 ft owner-authorized exploration case only'; candidate_count=$candidateRows.Count; search_complete=[bool]$search.search.search_complete
    route_compatible_full_public_and_private_count=0; u03_public_side_reachable_count=$u03HallReachCount
    bedroom_candidate_outline_contacts=[ordered]@{'U-01'=$perimeterCounts['U-01'];'U-03'=$perimeterCounts['U-03'];'U-04'=$perimeterCounts['U-04']}
    candidates_with_all_three_bedroom_outline_contacts=$allThreeExteriorCount
    checks=$checks; failures=$failures; hashes_sha256=$hashes; candidates=$candidateRows
    limitations=@('Test-shell outline contact is not an exterior wall or an EERO.','No opening dimensions, sill, well, grade, qualifying yard/court, route to public way, actual wall, door, swing, roof, stairs, services, Revit or IFC geometry is modeled.','M37 is bounded and incomplete; this run uses only U-01 perimeter roots and sampled 4-ft hall goals.','Connecticut code applicability and final sleeping-room classifications are unresolved. No code-compliance, accessibility, structural-safety, certification, permit or construction-readiness finding is made.')
}
if($failures.Count){throw "M157 audit failed checks: $($failures -join ', ')"}
$out=Resolve-RepoPath $OutputDirectory
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out -Force|Out-Null}
$json=Join-Path $out 'm157-audit.json';$csv=Join-Path $out 'm157-candidate-audit.csv'
ConvertTo-Json -InputObject $report -Depth 14 | Set-Content -LiteralPath $json -Encoding utf8
$candidateRows | Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
Write-Output "M157 independent audit passed $($checks.Count)/$($checks.Count); route records=$($candidateRows.Count); full public/private candidates=0; U-01/U-03/U-04 perimeter=$($perimeterCounts['U-01'])/$($perimeterCounts['U-03'])/$($perimeterCounts['U-04']); report SHA256=$(Get-Sha256 $json)"
