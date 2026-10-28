param(
    [string]$OutputDirectory = 'Architecture/House_Design_Iteration_2026-10-28'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$resolvedRoot = [System.IO.Path]::GetFullPath($root)
$target = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $OutputDirectory))
$rootPrefix = $resolvedRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $target.StartsWith($rootPrefix,[System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputDirectory must resolve inside the repository root.'
}
$sourcePath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$programPath = Join-Path $root 'Requirements/Room_Program.md'
$decisionPath = Join-Path $root 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
if (-not (Test-Path -LiteralPath $decisionPath -PathType Leaf)) { throw "Owner decision record is missing: $decisionPath" }
$source = Get-Content -Raw -LiteralPath $sourcePath | ConvertFrom-Json
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash.ToLowerInvariant()
$programHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $programPath).Hash.ToLowerInvariant()
$decisionHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $decisionPath).Hash.ToLowerInvariant()

function New-Block($id,$name,$x,$y,$w,$d) {
    [ordered]@{id=$id;name=$name;x_ft=[double]$x;y_ft=[double]$y;width_ft=[double]$w;depth_ft=[double]$d;area_sf=[Math]::Round(([double]$w*[double]$d),2);status='proposed room-block placement; not wall geometry'}
}
function Get-Overlap($a,$b) {
    $dx=[Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft)
    $dy=[Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($a.y_ft,$b.y_ft)
    [ordered]@{overlap=($dx -gt 0.000001 -and $dy -gt 0.000001);area_sf=if($dx -gt 0.000001 -and $dy -gt 0.000001){[Math]::Round(($dx*$dy),4)}else{0}}
}
function Test-AdjacentGap($a,$b,$gap=0.5) {
    $eps=0.000001
    $yOverlap=([Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($a.y_ft,$b.y_ft)) -gt $eps
    $xOverlap=([Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft)) -gt $eps
    $xGap=[Math]::Abs([Math]::Max($a.x_ft,$b.x_ft)-[Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft)))
    $yGap=[Math]::Abs([Math]::Max($a.y_ft,$b.y_ft)-[Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft)))
    (($yOverlap -and [Math]::Abs($xGap-$gap) -lt $eps) -or ($xOverlap -and [Math]::Abs($yGap-$gap) -lt $eps))
}

# Coordinates are a proposal in the selected-D local frame (x right, y rear),
# not surveyed/site orientation or finished wall faces. The 0.5 ft separations
# carry forward the existing nominal wall allowance solely for block testing.
$rooms=@(
    (New-Block 'M-01' 'Living room' 5.5 (2.0/3.0) 16 15),
    (New-Block 'M-02' 'Kitchen' 22 (2.0/3.0) 14 12),
    (New-Block 'M-03' 'Dining' 22 (79.0/6.0) 11 10),
    (New-Block 'M-04' 'Pantry' 31.5 (71.0/3.0) 5 7),
    (New-Block 'M-05' 'Entry / hall' (2.0/3.0) (32.0/3.0) (13.0/3.0) 12)
)
$shell=[ordered]@{width_ft=40.0;depth_ft=42.0;status='existing selected-D test envelope; not approved house footprint'}
$stair=$source.stair_core_test
$liftX=[double]$stair.lift.origin_ft[0]
$liftY=[double]$stair.lift.origin_ft[1]
$coreRects=@(
    [ordered]@{id='lower_to_main_run';x_ft=[double]$stair.lower_to_main.run_ft[0];y_ft=[double]$stair.lower_to_main.run_ft[1];width_ft=[double]$stair.lower_to_main.run_ft[2];depth_ft=[double]$stair.lower_to_main.run_ft[3]},
    [ordered]@{id='lower_to_main_landing';x_ft=[double]$stair.lower_to_main.main_landing_ft[0];y_ft=[double]$stair.lower_to_main.main_landing_ft[1];width_ft=4.0;depth_ft=4.0},
    [ordered]@{id='main_to_upper_run';x_ft=[double]$stair.main_to_upper.run_ft[0];y_ft=[double]$stair.main_to_upper.run_ft[1];width_ft=[double]$stair.main_to_upper.run_ft[2];depth_ft=[double]$stair.main_to_upper.run_ft[3]},
    [ordered]@{id='main_to_upper_landing';x_ft=[double]$stair.main_to_upper.main_landing_ft[0];y_ft=[double]$stair.main_to_upper.main_landing_ft[1];width_ft=4.0;depth_ft=4.0},
    [ordered]@{id='lift_reservation';x_ft=$liftX;y_ft=$liftY;width_ft=8.0;depth_ft=8.0}
)
$coreHits=[System.Collections.Generic.List[object]]::new()
foreach($r in $rooms){foreach($c in $coreRects){$o=Get-Overlap $r $c;if($o.overlap){$coreHits.Add([ordered]@{room=$r.id;core=$c.id;overlap_sf=$o.area_sf})}}}
$roomOverlaps=[System.Collections.Generic.List[object]]::new()
for($i=0;$i -lt $rooms.Count;$i++){for($j=$i+1;$j -lt $rooms.Count;$j++){$o=Get-Overlap $rooms[$i] $rooms[$j];if($o.overlap){$roomOverlaps.Add([ordered]@{a=$rooms[$i].id;b=$rooms[$j].id;overlap_sf=$o.area_sf})}}}

# Retain the selected-D B search-zone convention. Pantry-side B remains only a
# gross empty block; it is not assigned to the half bath.
$eastCore=[double]$stair.main_to_upper.main_landing_ft[0]+4.0
$pantry=$rooms|Where-Object id -eq 'M-04'
$windowB=[ordered]@{id='M06-B';x_ft=$eastCore;y_ft=[double]$pantry.y_ft;width_ft=([double]$pantry.x_ft-$eastCore);depth_ft=[double]$pantry.depth_ft;area_sf=[Math]::Round((([double]$pantry.x_ft-$eastCore)*[double]$pantry.depth_ft),2);status='unassigned search window only; not M-06 geometry'}
$m06RoomHits=[System.Collections.Generic.List[object]]::new()
foreach($r in $rooms){$o=Get-Overlap $windowB $r;if($o.overlap){$m06RoomHits.Add([ordered]@{room=$r.id;overlap_sf=$o.area_sf})}}
$m06CoreHits=[System.Collections.Generic.List[object]]::new()
foreach($c in $coreRects){$o=Get-Overlap $windowB $c;if($o.overlap){$m06CoreHits.Add([ordered]@{core=$c.id;overlap_sf=$o.area_sf})}}

$privateEdges=@(
    [ordered]@{a='U-01';b='C-PRIVATE';status='existing nominal edge; actual door unresolved'},
    [ordered]@{a='C-PRIVATE';b='U-02';status='existing nominal edge; actual door unresolved'},
    [ordered]@{a='U-02';b='U-03';status='owner-directed new private-suite link; route, corridor and door geometry TBD'}
)
$retainedEdges=@(
    [ordered]@{a='U-01';b='U-05';status='retain primary-only bath access; door geometry TBD'},
    [ordered]@{a='U-01';b='C-UPPER';status='retain nominal hall access'},
    [ordered]@{a='U-02';b='C-UPPER';status='existing nominal access retained for comparison; privacy boundary to review'},
    [ordered]@{a='U-03';b='C-UPPER';status='existing nominal hybrid hall edge carried forward provisionally; final privacy access policy TBD'},
    [ordered]@{a='U-04';b='C-UPPER';status='retain guest independent shared-hall access'},
    [ordered]@{a='U-03';b='U-06';status='retain hybrid Jack-and-Jill access'},
    [ordered]@{a='U-04';b='U-06';status='retain guest Jack-and-Jill access'}
)

$checks=[ordered]@{}
$checks['all_main_blocks_inside_40x42_test_envelope']=@($rooms|Where-Object{$_.x_ft -lt 0 -or $_.y_ft -lt 0 -or ($_.x_ft+$_.width_ft) -gt $shell.width_ft -or ($_.y_ft+$_.depth_ft) -gt $shell.depth_ft}).Count -eq 0
$checks['no_main_room_block_overlaps']=$roomOverlaps.Count -eq 0
$checks['main_room_blocks_clear_comparison_stair_lift']=$coreHits.Count -eq 0
$checks['kitchen_target_is_exactly_14x12']=((($rooms|Where-Object id -eq 'M-02').width_ft -eq 14) -and (($rooms|Where-Object id -eq 'M-02').depth_ft -eq 12))
$checks['dining_target_is_exactly_11x10']=((($rooms|Where-Object id -eq 'M-03').width_ft -eq 11) -and (($rooms|Where-Object id -eq 'M-03').depth_ft -eq 10))
$checks['kitchen_adjoins_living_across_nominal_6in_gap']=Test-AdjacentGap ($rooms|Where-Object id -eq 'M-01') ($rooms|Where-Object id -eq 'M-02')
$checks['kitchen_adjoins_dining_across_nominal_6in_gap']=Test-AdjacentGap ($rooms|Where-Object id -eq 'M-02') ($rooms|Where-Object id -eq 'M-03')
$checks['dining_adjoins_pantry_across_nominal_6in_gap']=Test-AdjacentGap ($rooms|Where-Object id -eq 'M-03') ($rooms|Where-Object id -eq 'M-04')
$checks['entry_adjoins_living_across_nominal_6in_gap']=Test-AdjacentGap ($rooms|Where-Object id -eq 'M-05') ($rooms|Where-Object id -eq 'M-01')
$checks['pantry_side_M06_window_is_positive']=($windowB.width_ft -gt 0 -and $windowB.depth_ft -gt 0)
$checks['M06_B_search_window_inside_test_envelope']=($windowB.x_ft -ge 0 -and $windowB.y_ft -ge 0 -and ($windowB.x_ft+$windowB.width_ft) -le $shell.width_ft -and ($windowB.y_ft+$windowB.depth_ft) -le $shell.depth_ft)
$checks['M06_B_remains_unassigned_and_clear_of_room_blocks']=($m06RoomHits.Count -eq 0)
$checks['M06_B_clear_of_stair_lift_comparison_blocks']=($m06CoreHits.Count -eq 0)
$checks['private_chain_has_owner_directed_U02_to_U03_link']=@($privateEdges|Where-Object{$_.a -eq 'U-02' -and $_.b -eq 'U-03'}).Count -eq 1
$checks['hybrid_and_guest_keep_hall_and_JandJ_links']=(@($retainedEdges|Where-Object{$_.a -eq 'U-03' -and $_.b -eq 'C-UPPER'}).Count -eq 1 -and @($retainedEdges|Where-Object{$_.a -eq 'U-04' -and $_.b -eq 'C-UPPER'}).Count -eq 1 -and @($retainedEdges|Where-Object{$_.a -eq 'U-03' -and $_.b -eq 'U-06'}).Count -eq 1 -and @($retainedEdges|Where-Object{$_.a -eq 'U-04' -and $_.b -eq 'U-06'}).Count -eq 1)

$fitWidthAisles=8.0+(2.0*42.0/12.0)
$fitDepthAisles=8.0+(2.0*42.0/12.0)
$kitchenFit=[ordered]@{
    room_ft=@(14,12); island_ft=@(8,4); modeled_clearance_test_each_side_in=42;
    eight_foot_island_axis_required_ft=$fitWidthAisles;
    orientations=[ordered]@{
        island_8ft_axis_across_14ft_room= [ordered]@{required_ft=$fitWidthAisles;available_ft=14;fits=($fitWidthAisles -le 14)};
        island_8ft_axis_across_12ft_room= [ordered]@{required_ft=$fitDepthAisles;available_ft=12;fits=($fitDepthAisles -le 12)}
    };
    conclusion='Within the M-02 14 x 12 ft block, neither orientation fits the full 8 ft island axis with 42 in clearance at both ends (15 ft required), before cabinet depth, half wall, seating, appliances or tolerance. Extension into adjacent open dining/living areas has not been tested. This is a room-block screen, not a code ruling.'
}
$checks['14x12_room_cannot_fit_8ft_island_with_42in_both_end_clearances']=$kitchenFit.orientations.island_8ft_axis_across_14ft_room.fits -eq $false -and $kitchenFit.orientations.island_8ft_axis_across_12ft_room.fits -eq $false

$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
$study=[ordered]@{
    schema='forever-home.owner-followup-design-study.v1'
    title='Owner follow-up: target social rooms, private hybrid connection, steep gable concept'
    status='proposal for design development; selected-D baseline preserved; not coordinated house geometry'
    source_selected_D_sha256=$sourceHash
    input_decision_path='Decisions/2026-10-28_House_Design_Direction_Followup.md'
    source_fingerprints_sha256=[ordered]@{'selected_D_study.json'=$sourceHash;'Requirements/Room_Program.md'=$programHash;'owner_followup_decision.md'=$decisionHash}
    coordinate_frame='Selected-D schematic frame: feet, x right and y toward rear; no site orientation or georeference.'
    shell=$shell
    owner_inputs=[ordered]@{private_primary_boutique_hybrid_sequence=$true;kitchen_target_ft=@(14,12);dining_target_ft=@(11,10);roof_concept='steep traditional gable, pitch and ridge orientation TBD';jurisdiction='Connecticut; municipality and parcel TBD'}
    main_rooms=$rooms
    room_areas=[ordered]@{M02_kitchen_sf=168;M03_dining_sf=110;source='Requirements/Room_Program.md and owner follow-up; study targets, not wall-face areas'}
    M06=[ordered]@{status='unassigned; no footprint, position, fixture or service route';first_fit_window=$windowB;room_conflicts=@($m06RoomHits.ToArray());core_conflicts=@($m06CoreHits.ToArray())}
    upper_suite=[ordered]@{private_route_edges=$privateEdges;retained_shared_access_edges=$retainedEdges;geometry_status='topology direction only; upper room-block rearrangement, connector width, wall, doors and swings not yet tested'}
    roof=[ordered]@{type='steep traditional gable concept';pitch='TBD';ridge_orientation='TBD';'ridge/eave elevations'='TBD';assemblies='TBD';status='massing idea only; no dimensions, loads or construction geometry'}
    kitchen_fit_screen=$kitchenFit
    checks=$checks
    failures=$failed
    limitations=@('Room blocks use existing test-shell dimensions and a nominal 6 in separation; they are not walls or usable-room surveys.','Kitchen island and 42 in aisle requirements conflict with the owner-selected 14 x 12 ft target; no island size or aisle requirement was changed.','Upper-suite route is an adjacency requirement, not a geometrically placed route.','Roof type is conceptual; pitch, ridge, site orientation, snow/wind exposure, structure, assemblies, dormers and drainage are unresolved.','M-06 B is only a search window; keep it unassigned.','No permit, code-compliance, structural-safety, professional-review or construction-readiness claim.')
}

if($failed.Count -gt 0){throw "Design-study checks failed: $($failed -join ', ')"}
if(!(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target | Out-Null}
$jsonPath=Join-Path $target 'study.json'
$checkPath=Join-Path $target 'checks.json'
$planPath=Join-Path $target 'main-plan.svg'
$roofPath=Join-Path $target 'roof-concept.svg'
$study | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$checkEnvelope=[ordered]@{passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@();count=$checks.Count;source_selected_D_sha256=$sourceHash;room_overlaps=@($roomOverlaps.ToArray());stair_lift_overlaps=@($coreHits.ToArray());checks=$checks;interpretation='Passing checks establish only schematic rectangle arithmetic, required adjacencies, an unassigned search gap and an explicit kitchen-fit failure. They do not validate a building.'}
$checkEnvelope | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $checkPath -Encoding utf8

$svg=@('<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1050" viewBox="0 0 1000 1050">','<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:22px;font-weight:bold}.room{fill:#eadfce;stroke:#716456;stroke-width:2}.search{fill:#f3e5bd;fill-opacity:.8;stroke:#9c6f1c;stroke-width:2;stroke-dasharray:8 5}.core{fill:#f4ddc9;fill-opacity:.65;stroke:#a65f2b;stroke-width:2;stroke-dasharray:8 5}.label{font-size:14px}.note{font-size:13px;fill:#5b554d}.shell{fill:#fcfaf5;stroke:#4e463d;stroke-width:3}</style>','<text class="title" x="50" y="32">Owner follow-up — main-floor room-block proposal</text>','<text class="note" x="50" y="54">40 × 42 ft test envelope; schematic local axes; not site-oriented or wall geometry</text>')
$sx=20.0;$sy=90.0;$scale=20.0
$svg+=('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $sx,$sy,($shell.width_ft*$scale),($shell.depth_ft*$scale))
foreach($r in $rooms){$x=$sx+$r.x_ft*$scale;$y=$sy+$r.y_ft*$scale;$w=$r.width_ft*$scale;$h=$r.depth_ft*$scale;$svg+=('<rect class="room" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">{6}</text><text class="label" x="{4}" y="{7}">{8} × {9} ft / {10} sf</text>' -f $x,$y,$w,$h,($x+8),($y+23),$r.id,($y+42),$r.width_ft,$r.depth_ft,$r.area_sf)}
$m06X=$sx+$windowB.x_ft*$scale;$m06Y=$sy+$windowB.y_ft*$scale
$svg+=('<rect class="search" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">M-06 B — unassigned search window</text><text class="label" x="{4}" y="{6}">{7} × {8} ft / {9} sf gross</text>' -f $m06X,$m06Y,($windowB.width_ft*$scale),($windowB.depth_ft*$scale),($m06X+8),($m06Y+22),($m06Y+40),[Math]::Round($windowB.width_ft,2),$windowB.depth_ft,$windowB.area_sf)
foreach($c in $coreRects){$svg+=('<rect class="core" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="note" x="{4}" y="{5}">{6}</text>' -f ($sx+$c.x_ft*$scale),($sy+$c.y_ft*$scale),($c.width_ft*$scale),($c.depth_ft*$scale),($sx+$c.x_ft*$scale+4),($sy+$c.y_ft*$scale+14),$c.id)}
$svg+=('<text class="note" x="20" y="925">Kitchen 14×12 and 8×4 island retained as inputs; 42 in two-sided island clearances fail both orientations.</text>','<text class="note" x="20" y="948">Roof, doors, walls, porch and M-06 are unplaced.</text>','</svg>')
$svg -join "`n" | Set-Content -LiteralPath $planPath -Encoding utf8

$roofSvg=@('<svg xmlns="http://www.w3.org/2000/svg" width="900" height="500" viewBox="0 0 900 500">','<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:22px;font-weight:bold}.note{font-size:15px}.roof{fill:#7a6250;fill-opacity:.18;stroke:#594638;stroke-width:8}.wall{fill:#f2e8d6;stroke:#716456;stroke-width:4}</style>','<text class="title" x="42" y="42">Steep gable — conceptual section only</text>','<rect class="wall" x="170" y="220" width="560" height="210"/>','<path class="roof" d="M140 220 L450 70 L760 220 Z"/>','<text class="note" x="42" y="466">Not to scale. Pitch, ridge orientation/elevation, spans, assemblies, loads, openings and site response: TBD.</text>','<text class="note" x="42" y="490">This is a massing prompt, not a roof design or structural check.</text>','</svg>')
$roofSvg -join "`n" | Set-Content -LiteralPath $roofPath -Encoding utf8

$manifest=[ordered]@{generator='Tools/build_owner_followup_design.ps1';source_selected_D_sha256=$sourceHash;room_program_sha256=$programHash;decision_sha256=$decisionHash;output_hashes=[ordered]@{study_json=(Get-FileHash $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks_json=(Get-FileHash $checkPath -Algorithm SHA256).Hash.ToLowerInvariant();main_plan_svg=(Get-FileHash $planPath -Algorithm SHA256).Hash.ToLowerInvariant();roof_concept_svg=(Get-FileHash $roofPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
$manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output ("Checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output ("M-02/M-03 test areas: {0} sf / {1} sf; B unassigned: {2} sf" -f 168,110,$windowB.area_sf)
Write-Output ("Kitchen fit result: {0}" -f $kitchenFit.conclusion)
