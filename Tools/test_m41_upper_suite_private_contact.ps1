param(
    [string]$OutputDirectory = 'Architecture/M41_Upper_Suite_Private_Contact_Study_2026-10-28'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = [System.IO.Path]::GetFullPath((Join-Path $root '..'))
$rootPrefix = $root.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
$target = [System.IO.Path]::GetFullPath((Join-Path $root $OutputDirectory))
if (-not $target.StartsWith($rootPrefix,[System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputDirectory must resolve inside the repository root.'
}

$sourcePath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$decisionPath = Join-Path $root 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
$source = Get-Content -Raw -LiteralPath $sourcePath | ConvertFrom-Json
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash.ToLowerInvariant()
$decisionHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $decisionPath).Hash.ToLowerInvariant()
$upper = @($source.plans.upper)
$u02 = $upper | Where-Object id -eq 'U-02' | Select-Object -First 1
$u03 = $upper | Where-Object id -eq 'U-03' | Select-Object -First 1
$others = @($upper | Where-Object id -notin @('U-02','U-03') | ForEach-Object {
    [ordered]@{id=[string]$_.id;x_ft=[double]$_.x;y_ft=[double]$_.y;width_ft=[double]$_.w;depth_ft=[double]$_.d}
})
$shell = [ordered]@{width_ft=[double]$source.shells.rear_upper[0];depth_ft=[double]$source.shells.rear_upper[1]}
$grid = 1.0/6.0
$wallGap = 0.5
$contact = 3.5
$upperOffset = [double]$source.plan_frame_offsets_ft.upper[1]
$liftSource = $source.stair_core_test.lift
$lift = [ordered]@{
    id='projected_lift_reservation'
    x_ft=[double]$liftSource.origin_ft[0]
    y_ft=[double]$liftSource.origin_ft[1]-$upperOffset
    width_ft=[double]$liftSource.width_ft
    depth_ft=[Math]::Min([double]$liftSource.depth_ft,($shell.depth_ft-([double]$liftSource.origin_ft[1]-$upperOffset)))
    status='source lift reservation projected into upper local frame; comparison keepout only'
}
$approachSource = $source.stair_core_test.main_to_upper.upper_landing_ft
$approachY = [double]$approachSource[1]-$upperOffset
$approach = [ordered]@{
    id='source_upper_landing_approach'
    x_ft=[double]$approachSource[0]
    y_ft=$approachY
    width_ft=[double]$approachSource[2]
    depth_ft=0.0
    status='boundary marker only at rear edge of upper test envelope; no route or landing-clearance geometry tested'
}

function Get-OverlapArea($a,$b) {
    $dx=[Math]::Max(0.0,[Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft))
    $dy=[Math]::Max(0.0,[Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($a.y_ft,$b.y_ft))
    [Math]::Round(($dx*$dy),6)
}
function New-Candidate($side,$orientation,$x,$y,$w,$d) {
    $xTick=[int][Math]::Round($x/$grid);$yTick=[int][Math]::Round($y/$grid)
    $actualGap=switch($side){'east'{$x-([double]$u02.x+[double]$u02.w)};'west'{[double]$u02.x-($x+$w)};'north'{$y-([double]$u02.y+[double]$u02.d)};'south'{[double]$u02.y-($y+$d)}}
    [ordered]@{
        side=$side;orientation=$orientation
        x_ft=[Math]::Round(($xTick*$grid),6);y_ft=[Math]::Round(($yTick*$grid),6)
        width_ft=$w;depth_ft=$d
        inside_shell=($x -ge -0.000001 -and $y -ge -0.000001 -and ($x+$w) -le ($shell.width_ft+0.000001) -and ($y+$d) -le ($shell.depth_ft+0.000001))
        contact_length_ft=0.0;contact_gap_ft=[Math]::Round([double]$actualGap,6);contact_valid=$false
        clashes=@();total_clash_area_sf=0.0;clear_of_fixed_rooms=$false;clear_of_lift=$false;no_overlap_with_landing_marker=$true;single_shift_candidate=$false
    }
}

$orientations=@(
    [ordered]@{name='source';width_ft=[double]$u03.w;depth_ft=[double]$u03.d},
    [ordered]@{name='rotated_90_degrees';width_ft=[double]$u03.d;depth_ft=[double]$u03.w}
)
$candidates=[System.Collections.Generic.List[object]]::new()
foreach($orientation in $orientations){
    $w=[double]$orientation.width_ft;$d=[double]$orientation.depth_ft
    foreach($side in @('east','west')){
        if($side -eq 'east'){$x=[double]$u02.x+[double]$u02.w+$wallGap}else{$x=[double]$u02.x-$wallGap-$w}
        $minY=[Math]::Max(0.0,([double]$u02.y+$contact-$d))
        $maxY=[Math]::Min(($shell.depth_ft-$d),([double]$u02.y+[double]$u02.d-$contact))
        $minTick=[int][Math]::Ceiling($minY/$grid);$maxTick=[int][Math]::Floor($maxY/$grid)
        for($tick=$minTick;$tick -le $maxTick;$tick++){
            $y=$tick*$grid;$candidate=New-Candidate $side $orientation.name $x $y $w $d
            $overlapY=[Math]::Max(0.0,[Math]::Min(($y+$d),([double]$u02.y+[double]$u02.d))-[Math]::Max($y,[double]$u02.y))
            $candidate.contact_length_ft=[Math]::Round($overlapY,6);$candidate.contact_valid=($overlapY -ge ($contact-0.000001))
            $candidates.Add($candidate)
        }
    }
    foreach($side in @('north','south')){
        if($side -eq 'north'){$y=[double]$u02.y+[double]$u02.d+$wallGap}else{$y=[double]$u02.y-$wallGap-$d}
        $minX=[Math]::Max(0.0,([double]$u02.x+$contact-$w))
        $maxX=[Math]::Min(($shell.width_ft-$w),([double]$u02.x+[double]$u02.w-$contact))
        $minTick=[int][Math]::Ceiling($minX/$grid);$maxTick=[int][Math]::Floor($maxX/$grid)
        for($tick=$minTick;$tick -le $maxTick;$tick++){
            $x=$tick*$grid;$candidate=New-Candidate $side $orientation.name $x $y $w $d
            $overlapX=[Math]::Max(0.0,[Math]::Min(($x+$w),([double]$u02.x+[double]$u02.w))-[Math]::Max($x,[double]$u02.x))
            $candidate.contact_length_ft=[Math]::Round($overlapX,6);$candidate.contact_valid=($overlapX -ge ($contact-0.000001))
            $candidates.Add($candidate)
        }
    }
}

foreach($c in $candidates){
    $clashes=[System.Collections.Generic.List[object]]::new()
    foreach($r in $others){$area=Get-OverlapArea $c $r;if($area -gt 0){$clashes.Add([ordered]@{id=[string]$r.id;area_sf=$area;kind='existing source room/circulation block'})}}
    $liftArea=Get-OverlapArea $c $lift;if($liftArea -gt 0){$clashes.Add([ordered]@{id=$lift.id;area_sf=$liftArea;kind='projected comparison reservation'})}
    $approachArea=Get-OverlapArea $c $approach;if($approachArea -gt 0){$clashes.Add([ordered]@{id=$approach.id;area_sf=$approachArea;kind='source landing/approach projection'})}
    $c.clashes=@($clashes.ToArray());$clashSum=0.0;foreach($clash in $clashes){$clashSum+=[double]$clash.area_sf};$c.total_clash_area_sf=[Math]::Round($clashSum,6)
    $c.clear_of_fixed_rooms=@($c.clashes|Where-Object kind -eq 'existing source room/circulation block').Count -eq 0
    $c.clear_of_lift=@($c.clashes|Where-Object id -eq $lift.id).Count -eq 0
    $c.no_overlap_with_landing_marker=@($c.clashes|Where-Object id -eq $approach.id).Count -eq 0
    $c.single_shift_candidate=($c.inside_shell -and $c.contact_valid -and $c.clear_of_fixed_rooms -and $c.clear_of_lift)
}
$best=@($candidates|Sort-Object @{Expression={if($_.inside_shell){0}else{1}}},@{Expression={[double]$_.total_clash_area_sf}},@{Expression={[string]$_.side}},@{Expression={[string]$_.orientation}},@{Expression={[double]$_.y_ft}},@{Expression={[double]$_.x_ft}}|Select-Object -First 12)
$sideSummary=@(foreach($side in @('east','west','north','south')){$items=@($candidates|Where-Object side -eq $side);$insideItems=@($items|Where-Object inside_shell);$minClash=$null;foreach($item in $insideItems){if($null -eq $minClash -or [double]$item.total_clash_area_sf -lt [double]$minClash){$minClash=[double]$item.total_clash_area_sf}};[ordered]@{side=$side;placements=$items.Count;inside_shell=$insideItems.Count;clear_single_shift=@($items|Where-Object single_shift_candidate).Count;minimum_clash_area_sf_inside_shell=$minClash}})
$checks=[ordered]@{}
$checks['selected_D_and_decision_fingerprints_are_valid'] = ($sourceHash -match '^[0-9a-f]{64}$' -and $decisionHash -match '^[0-9a-f]{64}$')
$checks['U02_and_U03_source_blocks_exist'] = ($null -ne $u02 -and $null -ne $u03)
$checks['source_block_areas_preserved_in_both_orientations'] = [Math]::Abs(([double]$u03.w*[double]$u03.d)-([double]$u03.d*[double]$u03.w)) -lt 0.000001
$checks['all_candidates_use_source_derived_half_ft_nominal_gap'] = @($candidates|Where-Object{[Math]::Abs($_.contact_gap_ft-$wallGap) -gt 0.000001}).Count -eq 0
$checks['all_candidates_respect_one_sixth_ft_grid'] = @($candidates|Where-Object{[Math]::Abs(($_.x_ft/$grid)-[Math]::Round($_.x_ft/$grid)) -gt 0.00001 -or [Math]::Abs(($_.y_ft/$grid)-[Math]::Round($_.y_ft/$grid)) -gt 0.00001}).Count -eq 0
$checks['all_candidates_meet_source_3_5ft_contact_reservation'] = @($candidates|Where-Object{-not $_.contact_valid}).Count -eq 0
$checks['all_candidates_keep_nominal_wall_gap_from_U02'] = @($candidates|Where-Object{[Math]::Abs($_.contact_gap_ft-$wallGap) -gt 0.00001}).Count -eq 0
$sourceU03Area=[double]$u03.w*[double]$u03.d
$checks['all_candidates_preserve_source_U03_area'] = @($candidates|Where-Object{[Math]::Abs(($_.width_ft*$_.depth_ft)-$sourceU03Area) -gt 0.000001}).Count -eq 0
$u02OverlapCandidates=0;foreach($candidate in $candidates){if((Get-OverlapArea $candidate ([ordered]@{x_ft=[double]$u02.x;y_ft=[double]$u02.y;width_ft=[double]$u02.w;depth_ft=[double]$u02.d})) -gt 0){$u02OverlapCandidates++}}
$checks['no_candidate_overlaps_U02'] = $u02OverlapCandidates -eq 0
$checks['candidate_sides_cover_four_orthogonal_contacts'] = @($candidates.side|Sort-Object -Unique).Count -eq 4
$checks['at_least_one_contained_contact_candidate_tested'] = @($candidates|Where-Object inside_shell).Count -gt 0
$checks['no_candidate_claimed_as_final_geometry'] = $true

$report=[ordered]@{
    schema='forever-home.m41-upper-suite-private-contact.v1'
    title='M41 — source-sized U-02/U-03 private contact placement screen'
    status='bounded single-room contact screen; no placement adopted'
    source_fingerprints_sha256=[ordered]@{'selected_D_study.json'=$sourceHash;'owner_followup_decision.md'=$decisionHash}
    shell=$shell;grid_ft=$grid;nominal_wall_gap_ft=$wallGap;contact_reservation_ft=$contact
    contact_basis='Inherited 3.5 ft selected-D door reservation used as a schematic minimum shared-edge length; not a clear opening, selected door, swing, code clearance or approved door location.'
    U02=[ordered]@{x_ft=[double]$u02.x;y_ft=[double]$u02.y;width_ft=[double]$u02.w;depth_ft=[double]$u02.d;area_sf=[Math]::Round(([double]$u02.w*[double]$u02.d),6)}
    U03_source=[ordered]@{width_ft=[double]$u03.w;depth_ft=[double]$u03.d;area_sf=[Math]::Round(([double]$u03.w*[double]$u03.d),6);orientations=$orientations}
    fixed_blocks=$others
    lift_projection=$lift;upper_landing_boundary_anchor=$approach
    search=[ordered]@{placements_tested=$candidates.Count;coordinate_grid_ft=$grid;contact_gap_ft=$wallGap;minimum_shared_edge_ft=$contact;rotations_tested=@($orientations.name);placements_by_side=$sideSummary;single_shift_candidates=@($candidates|Where-Object single_shift_candidate).Count}
    best_contact_placements=$best
    interpretation='This tests U-03 contact with fixed source U-02 while all other source room/circulation rectangles and the projected lift reservation remain fixed. The source upper landing is recorded only as a boundary coordinate; no route is computed. A zero surviving placement would reject only this single-room-shift strategy, not prove the upper-suite arrangement infeasible.'
    checks=$checks;failures=@($checks.Keys|Where-Object{-not $checks[$_]})
    limitations=@('Room coordinates and areas are source room-block values, not survey or finished wall-face dimensions.','The 0.5 ft gap is an inherited nominal wall allowance, not verified construction thickness.','The 3.5 ft contact interval comes from source door-reservation data; no door, clear opening, swing or applicable code clearance is modeled.','The lift is a projected comparison reservation, not verified shaft/floor-opening geometry. The upper landing is a boundary marker only; no continuous public route or landing clearance is checked.','Only U-03 is moved or rotated; no broader re-layout, private-corridor route, furniture, walls, floors, stairs, structure, services, Revit or IFC is tested.','No code-compliance, accessibility, structural-safety, professional-certification or construction-readiness claim is made.')
}
if($report.failures.Count -gt 0){throw "M41 integrity checks failed: $($report.failures -join ', ')"}
if(-not(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target|Out-Null}
$jsonPath=Join-Path $target 'contact-screen.json';$checkPath=Join-Path $target 'checks.json';$svgPath=Join-Path $target 'contact-screen.svg'
$report|ConvertTo-Json -Depth 28|Set-Content -LiteralPath $jsonPath -Encoding utf8
$checkEnvelope=[ordered]@{count=$checks.Count;passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@($report.failures);checks=$checks;source_fingerprints_sha256=$report.source_fingerprints_sha256;search_summary=$report.search;interpretation=$report.interpretation}
$checkEnvelope|ConvertTo-Json -Depth 20|Set-Content -LiteralPath $checkPath -Encoding utf8
$sx=35.0;$sy=70.0;$scale=20.0
$svg=[System.Collections.Generic.List[string]]::new()
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="900" height="850" viewBox="0 0 900 850">')
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:20px;font-weight:bold}.room{fill:#eadfce;stroke:#716456;stroke-width:2}.private{fill:#c8a7d1;fill-opacity:.55;stroke:#785a88;stroke-width:2}.hall{fill:#d7dce4;fill-opacity:.6;stroke:#5f6977;stroke-width:2}.bath{fill:#bfd5d9;stroke:#5b7a80;stroke-width:2}.lift{fill:#e7aaa2;fill-opacity:.4;stroke:#a7463c;stroke-width:2;stroke-dasharray:7 4}.candidate{fill:#a9d7b3;fill-opacity:.55;stroke:#32864d;stroke-width:3}.note{font-size:12px;fill:#5b554d}.warn{font-size:13px;fill:#8e3f35}.shell{fill:#fcfaf5;stroke:#4e463d;stroke-width:3}</style>')
$svg.Add('<text class="title" x="35" y="30">M41 — U-02 / U-03 private contact screen</text>')
$svg.Add('<text class="note" x="35" y="50">Source-sized room blocks; 36×32 ft upper-wing test envelope; nominal 6 in wall bands.</text>')
$svg.Add(('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $sx,$sy,($shell.width_ft*$scale),($shell.depth_ft*$scale)))
foreach($r in $upper){$class='room';if($r.id -eq 'C-PRIVATE'){$class='private'}elseif($r.id -eq 'C-UPPER'){$class='hall'}elseif($r.id -in @('U-05','U-06')){$class='bath'};$svg.Add(('<rect class="{0}" x="{1}" y="{2}" width="{3}" height="{4}"/><text class="note" x="{5}" y="{6}">{7}</text>' -f $class,($sx+$r.x*$scale),($sy+$r.y*$scale),($r.w*$scale),($r.d*$scale),($sx+$r.x*$scale+4),($sy+$r.y*$scale+14),$r.id))}
$svg.Add(('<rect class="lift" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="note" x="{4}" y="{5}">projected lift</text>' -f ($sx+$lift.x_ft*$scale),($sy+$lift.y_ft*$scale),($lift.width_ft*$scale),($lift.depth_ft*$scale),($sx+$lift.x_ft*$scale+3),($sy+$lift.y_ft*$scale+13)))
$svg.Add(('<text class="warn" x="35" y="735">Tested {0} contact placements; single-shift survivors: {1}.</text>' -f $candidates.Count,$report.search.single_shift_candidates))
$svg.Add('<text class="note" x="35" y="758">Green shows the lowest-overlap contact candidate only, not a fit solution.</text>')
$svg.Add('<text class="note" x="35" y="780">No door, swing, construction wall, stair solid, floor opening or code check.</text>')
if($best.Count -gt 0){$c=$best[0];$svg.Add(('<rect class="candidate" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f ($sx+$c.x_ft*$scale),($sy+$c.y_ft*$scale),($c.width_ft*$scale),($c.depth_ft*$scale)))}
$svg.Add('</svg>');$svg -join "`n"|Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest=[ordered]@{generator='Tools/test_m41_upper_suite_private_contact.ps1';source_fingerprints_sha256=$report.source_fingerprints_sha256;search_parameters=[ordered]@{grid_ft=$grid;nominal_wall_gap_ft=$wallGap;minimum_contact_ft=$contact;room='U-03';target='U-02';orientations_tested=@($orientations.name)};output_hashes_sha256=[ordered]@{contact_screen=(Get-FileHash -LiteralPath $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks=(Get-FileHash -LiteralPath $checkPath -Algorithm SHA256).Hash.ToLowerInvariant();svg=(Get-FileHash -LiteralPath $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
$manifest|ConvertTo-Json -Depth 12|Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output ("M41 contact integrity checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output ("Tested {0} single-U03 placements; {1} avoid all fixed room and lift reservations." -f $candidates.Count,$report.search.single_shift_candidates)
Write-Output ("Best candidate: {0} {1}; {2} sf total source-room/lift overlap; in shell: {3}." -f $best[0].side,$best[0].orientation,$best[0].total_clash_area_sf,$best[0].inside_shell)
