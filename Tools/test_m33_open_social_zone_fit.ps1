param(
    [string]$OutputDirectory = 'Architecture/M33_Open_Social_Zone_Fit_2026-10-28'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$resolvedRoot = [System.IO.Path]::GetFullPath($root)
$target = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $OutputDirectory))
$rootPrefix = $resolvedRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $target.StartsWith($rootPrefix,[System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputDirectory must resolve inside the repository root.'
}

$proposalPath = Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$selectedDPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$kitchenSpecPath = Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
foreach($p in @($proposalPath,$selectedDPath,$kitchenSpecPath)){
    if(-not (Test-Path -LiteralPath $p -PathType Leaf)){throw "Required source missing: $p"}
}
$proposal = Get-Content -Raw -LiteralPath $proposalPath | ConvertFrom-Json
$selectedD = Get-Content -Raw -LiteralPath $selectedDPath | ConvertFrom-Json
$kitchenSpec = Get-Content -Raw -LiteralPath $kitchenSpecPath
$proposalHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $proposalPath).Hash.ToLowerInvariant()
$selectedDHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $selectedDPath).Hash.ToLowerInvariant()
$kitchenSpecHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $kitchenSpecPath).Hash.ToLowerInvariant()
if($proposal.source_selected_D_sha256 -ne $selectedDHash){throw 'Owner-follow-up proposal no longer matches selected-D source fingerprint.'}

function New-Rect($name,$x,$y,$w,$d){
    [ordered]@{name=$name;x_ft=[double]$x;y_ft=[double]$y;width_ft=[double]$w;depth_ft=[double]$d;area_sf=[Math]::Round(([double]$w*[double]$d),4)}
}
function Get-Overlap($a,$b){
    $dx=[Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft)
    $dy=[Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($a.y_ft,$b.y_ft)
    [ordered]@{overlap=($dx -gt 0.000001 -and $dy -gt 0.000001);area_sf=if($dx -gt 0.000001 -and $dy -gt 0.000001){[Math]::Round(($dx*$dy),4)}else{0};x_gap_ft=if($dx -lt 0){[Math]::Round(-$dx,6)}else{0};y_gap_ft=if($dy -lt 0){[Math]::Round(-$dy,6)}else{0}}
}
function Test-Inside($a,$b,$eps=0.000001){
    ($a.x_ft -ge ($b.x_ft-$eps) -and $a.y_ft -ge ($b.y_ft-$eps) -and ($a.x_ft+$a.width_ft) -le ($b.x_ft+$b.width_ft+$eps) -and ($a.y_ft+$a.depth_ft) -le ($b.y_ft+$b.depth_ft+$eps))
}

$row = [regex]::Match($kitchenSpec,'(?m)^\| Dining table \| \*\*(\d+)" W × (\d+)" L × (\d+)" H\*\*.*?\| \*\*(\d+)" min\*\* chair pull-out; \*\*(\d+)" preferred\*\*')
if(-not $row.Success){throw 'Could not parse dining-table dimensions and clearances from Kitchen_Dining_Porch_Specs.md.'}
$tableWidthIn=[double]::Parse($row.Groups[1].Value,[Globalization.CultureInfo]::InvariantCulture)
$tableLengthIn=[double]::Parse($row.Groups[2].Value,[Globalization.CultureInfo]::InvariantCulture)
$tableHeightIn=[double]::Parse($row.Groups[3].Value,[Globalization.CultureInfo]::InvariantCulture)
$tableMinClearIn=[double]::Parse($row.Groups[4].Value,[Globalization.CultureInfo]::InvariantCulture)
$tablePreferredClearIn=[double]::Parse($row.Groups[5].Value,[Globalization.CultureInfo]::InvariantCulture)
$tableWidthFt=$tableWidthIn/12.0
$tableLengthFt=$tableLengthIn/12.0
$tableMinClearFt=$tableMinClearIn/12.0
$tablePreferredClearFt=$tablePreferredClearIn/12.0
$islandClearFt=42.0/12.0

$mainRooms=@($proposal.main_rooms)
$kitchen=$mainRooms|Where-Object id -eq 'M-02'
$dining=$mainRooms|Where-Object id -eq 'M-03'
$shell=New-Rect '40x42 ft main-shell test envelope' 0 0 ([double]$proposal.shell.width_ft) ([double]$proposal.shell.depth_ft)
$sourceIsland=$selectedD.selection.kitchen
$islandWidth=[double]$sourceIsland.island_ft[0]
$islandDepth=[double]$sourceIsland.island_ft[1]
$islandX=[double]$kitchen.x_ft+[double]$sourceIsland.island_origin_local_ft[0]
$islandY=[double]$kitchen.y_ft+[double]$sourceIsland.island_origin_local_ft[1]
$island=New-Rect 'appliance-free kitchen island' $islandX $islandY $islandWidth $islandDepth
$islandClear=New-Rect 'island 42in clear-floor envelope' ($island.x_ft-$islandClearFt) ($island.y_ft-$islandClearFt) ($island.width_ft+2*$islandClearFt) ($island.depth_ft+2*$islandClearFt)

# Table center is derived from the dining block; its north/rear edge keeps the
# documented minimum chair pull-back to the rear room-block boundary. This is
# one inspectable placement candidate, not an owner-selected furniture layout.
$tableX=[double]$dining.x_ft+([double]$dining.width_ft-$tableLengthFt)/2.0
$tableY=[double]$dining.y_ft+[double]$dining.depth_ft-$tableWidthFt-$tableMinClearFt
$table=New-Rect '36x60in dining table (long axis along x)' $tableX $tableY $tableLengthFt $tableWidthFt
$tableMinClear=New-Rect 'table 36in chair pull-back envelope' ($table.x_ft-$tableMinClearFt) ($table.y_ft-$tableMinClearFt) ($table.width_ft+2*$tableMinClearFt) ($table.depth_ft+2*$tableMinClearFt)
$tablePreferredClear=New-Rect 'table 42in preferred wall/door clearance envelope' ($table.x_ft-$tablePreferredClearFt) ($table.y_ft-$tablePreferredClearFt) ($table.width_ft+2*$tablePreferredClearFt) ($table.depth_ft+2*$tablePreferredClearFt)

$core=$selectedD.stair_core_test
$coreRects=@(
    (New-Rect 'lower-to-main stair run' $core.lower_to_main.run_ft[0] $core.lower_to_main.run_ft[1] $core.lower_to_main.run_ft[2] $core.lower_to_main.run_ft[3]),
    (New-Rect 'lower-to-main main landing' $core.lower_to_main.main_landing_ft[0] $core.lower_to_main.main_landing_ft[1] 4 4),
    (New-Rect 'main-to-upper stair run' $core.main_to_upper.run_ft[0] $core.main_to_upper.run_ft[1] $core.main_to_upper.run_ft[2] $core.main_to_upper.run_ft[3]),
    (New-Rect 'main-to-upper main landing' $core.main_to_upper.main_landing_ft[0] $core.main_to_upper.main_landing_ft[1] 4 4),
    (New-Rect 'future lift reservation' $core.lift.origin_ft[0] $core.lift.origin_ft[1] $core.lift.width_ft $core.lift.depth_ft)
)
$selectedM06=$proposal.M06.first_fit_window

$islandOutsideKitchen=[ordered]@{
    west_ft=[Math]::Max(0.0,[double]$kitchen.x_ft-$islandClear.x_ft)
    east_ft=[Math]::Max(0.0,($islandClear.x_ft+$islandClear.width_ft)-($kitchen.x_ft+$kitchen.width_ft))
    south_ft=[Math]::Max(0.0,[double]$kitchen.y_ft-$islandClear.y_ft)
    north_ft=[Math]::Max(0.0,($islandClear.y_ft+$islandClear.depth_ft)-($kitchen.y_ft+$kitchen.depth_ft))
}
$tablePreferredOutsideDining=[ordered]@{
    west_ft=[Math]::Max(0.0,[double]$dining.x_ft-$tablePreferredClear.x_ft)
    east_ft=[Math]::Max(0.0,($tablePreferredClear.x_ft+$tablePreferredClear.width_ft)-($dining.x_ft+$dining.width_ft))
    south_ft=[Math]::Max(0.0,[double]$dining.y_ft-$tablePreferredClear.y_ft)
    north_ft=[Math]::Max(0.0,($tablePreferredClear.y_ft+$tablePreferredClear.depth_ft)-($dining.y_ft+$dining.depth_ft))
}
$islandTableBodyOverlap=Get-Overlap $island $table
$islandMinOverlap=Get-Overlap $islandClear $tableMinClear
$islandM06Overlap=Get-Overlap $islandClear $selectedM06
$tableM06Overlap=Get-Overlap $tablePreferredClear $selectedM06
$islandCoreHits=[System.Collections.Generic.List[object]]::new()
$tableCoreHits=[System.Collections.Generic.List[object]]::new()
foreach($c in $coreRects){$o=Get-Overlap $islandClear $c;if($o.overlap){$islandCoreHits.Add([ordered]@{core=$c.name;overlap_sf=$o.area_sf})};$o=Get-Overlap $tablePreferredClear $c;if($o.overlap){$tableCoreHits.Add([ordered]@{core=$c.name;overlap_sf=$o.area_sf})}}

$checks=[ordered]@{}
$checks['selected_D_source_fingerprint_matches_owner_proposal']=($proposal.source_selected_D_sha256 -eq $selectedDHash)
$checks['kitchen_and_dining_targets_are_14x12_and_11x10']=($kitchen.width_ft -eq 14 -and $kitchen.depth_ft -eq 12 -and $dining.width_ft -eq 11 -and $dining.depth_ft -eq 10)
$checks['island_body_inside_M02']=Test-Inside $island $kitchen
$checks['table_body_inside_M03']=Test-Inside $table $dining
$checks['36in_table_clearance_inside_M03']=Test-Inside $tableMinClear $dining
$checks['island_42in_envelope_inside_main_shell']=Test-Inside $islandClear $shell
$checks['table_42in_preferred_envelope_inside_main_shell']=Test-Inside $tablePreferredClear $shell
$checks['island_and_table_bodies_do_not_overlap']=(-not $islandTableBodyOverlap.overlap)
$checks['island_and_table_minimum_clear_envelopes_do_not_overlap']=(-not $islandMinOverlap.overlap)
$checks['island_42in_envelope_clear_of_comparison_core']=($islandCoreHits.Count -eq 0)
$checks['table_42in_envelope_clear_of_comparison_core']=($tableCoreHits.Count -eq 0)
$checks['island_42in_envelope_clear_of_unassigned_M06_B']=(-not $islandM06Overlap.overlap)
$checks['table_42in_preferred_envelope_clear_of_unassigned_M06_B']=(-not $tableM06Overlap.overlap)
$checks['table_minimum_clearance_is_source_derived']=($tableMinClearIn -eq 36 -and $tableWidthIn -eq 36 -and $tableLengthIn -eq 60)

$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
if($failed.Count -gt 0){throw "M33 screening checks failed: $($failed -join ', ')"}

$report=[ordered]@{
    schema='forever-home.m33-open-social-zone-fit.v1'
    title='M33 — open kitchen/dining furniture and clearance screen'
    status='one schematic fit candidate; no cabinets, partitions, doors, porch route or construction geometry'
    source_fingerprints_sha256=[ordered]@{'owner_followup_study.json'=$proposalHash;'selected_D_study.json'=$selectedDHash;'Architecture/Kitchen_Dining_Porch_Specs.md'=$kitchenSpecHash}
    assumptions=@('M-02 and M-03 are treated as one open social zone across their nominal 6 in room-block separator.','The existing selected-D island origin is retained relative to the new M-02 target; no island position was newly approved.','Dining table is a placement candidate centered in M-03, with its rear edge positioned to preserve the documented 36 in minimum chair pull-back to the rear room-block edge.','The main shell test envelope remains a room-block boundary, not surveyed interior face geometry.')
    room_blocks=[ordered]@{M02=$kitchen;M03=$dining;shell=$shell}
    furniture_inputs=[ordered]@{island_source_dimensions_ft=@($islandWidth,$islandDepth);island_local_origin_ft=@([double]$sourceIsland.island_origin_local_ft[0],[double]$sourceIsland.island_origin_local_ft[1]);island_absolute_rect=$island;dining_table_size_in=[ordered]@{width=$tableWidthIn;length=$tableLengthIn;height=$tableHeightIn};dining_table_source='Architecture/Kitchen_Dining_Porch_Specs.md §4.2';table_absolute_rect=$table;chair_pullback_minimum_in=$tableMinClearIn;wall_door_clearance_preferred_in=$tablePreferredClearIn}
    clearance_envelopes=[ordered]@{island_42in=$islandClear;table_36in=$tableMinClear;table_42in_preferred=$tablePreferredClear}
    open_zone_fit=[ordered]@{island_42in_extension_beyond_M02_ft=$islandOutsideKitchen;table_42in_preferred_extension_beyond_M03_ft=$tablePreferredOutsideDining;island_and_minimum_table_envelope_overlap=$islandMinOverlap.overlap;gap_between_envelopes_ft=$islandMinOverlap.y_gap_ft;separate_36in_path_to_porch='UNVERIFIED: porch, door location and non-overlapping route are not modeled';counter_and_halfwall_clearances='UNVERIFIED: perimeter cabinets, half wall, sink, range, hood, refrigerator, dishwasher and appliance-open envelopes are not placed'}
    M06=[ordered]@{status='unassigned; no fixture, footprint, door or service route';B=$selectedM06;island_envelope_overlap_sf=$islandM06Overlap.area_sf;table_preferred_envelope_overlap_sf=$tableM06Overlap.area_sf}
    checks=$checks
    failures=$failed
    limitations=@('Passing rectangles screen only a proposed island body and dining-table body plus cited clear-floor envelopes.','The island 42 in envelope extends outside M-02 into otherwise unassigned shell space; room blocks do not prove that space remains open after walls, cabinets, doors and circulation are designed.','The 42 in table clearance is preferred by the project specification and extends beyond M-03; the 36 in minimum chair pull-back fits exactly within M-03.','A separate continuous path from table to porch that remains clear with chairs occupied is not demonstrated.','No Revit, IFC, wall, slab, porch, structure, code, accessibility or construction validation is made.')
}

if(-not(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target|Out-Null}
$jsonPath=Join-Path $target 'fit.json'
$checksPath=Join-Path $target 'checks.json'
$svgPath=Join-Path $target 'open-social-zone.svg'
$report|ConvertTo-Json -Depth 30|Set-Content -LiteralPath $jsonPath -Encoding utf8
$checkOutput=[ordered]@{passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@();count=$checks.Count;source_fingerprints_sha256=$report.source_fingerprints_sha256;checks=$checks;interpretation='Passing checks validate this one schematic body/clearance candidate. They do not validate continuous circulation or cabinetry/appliance operation.'}
$checkOutput|ConvertTo-Json -Depth 20|Set-Content -LiteralPath $checksPath -Encoding utf8

$svg=@('<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1050" viewBox="0 0 1000 1050">','<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:22px;font-weight:bold}.room{fill:#eadfce;stroke:#716456;stroke-width:2}.island-zone{fill:#98b4a2;fill-opacity:.2;stroke:#52705e;stroke-width:2;stroke-dasharray:8 5}.table-min{fill:#c3b4d8;fill-opacity:.22;stroke:#705b8c;stroke-width:2;stroke-dasharray:7 5}.table-pref{fill:none;stroke:#a56f23;stroke-width:2;stroke-dasharray:3 5}.body{fill:#77987d;stroke:#3e6046;stroke-width:2}.table-body{fill:#b29b7c;stroke:#6d5740;stroke-width:2}.core{fill:#f4ddc9;fill-opacity:.55;stroke:#a65f2b;stroke-width:2;stroke-dasharray:7 5}.label{font-size:13px}.note{font-size:13px;fill:#5b554d}.shell{fill:#fcfaf5;stroke:#4e463d;stroke-width:3}</style>','<text class="title" x="50" y="32">M33 — open social zone furniture clearance candidate</text>','<text class="note" x="50" y="54">Clearance envelopes may extend outside room blocks; all geometry is schematic and unverified</text>')
$sx=20.0;$sy=90.0;$scale=20.0
$svg+=('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $sx,$sy,($shell.width_ft*$scale),($shell.depth_ft*$scale))
foreach($r in $mainRooms){$svg+=('<rect class="room" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">{6}</text>' -f ($sx+$r.x_ft*$scale),($sy+$r.y_ft*$scale),($r.width_ft*$scale),($r.depth_ft*$scale),($sx+$r.x_ft*$scale+6),($sy+$r.y_ft*$scale+18),$r.id)}
$svg+=('<rect class="island-zone" x="{0}" y="{1}" width="{2}" height="{3}"/><rect class="table-min" x="{4}" y="{5}" width="{6}" height="{7}"/><rect class="table-pref" x="{8}" y="{9}" width="{10}" height="{11}"/>' -f ($sx+$islandClear.x_ft*$scale),($sy+$islandClear.y_ft*$scale),($islandClear.width_ft*$scale),($islandClear.depth_ft*$scale),($sx+$tableMinClear.x_ft*$scale),($sy+$tableMinClear.y_ft*$scale),($tableMinClear.width_ft*$scale),($tableMinClear.depth_ft*$scale),($sx+$tablePreferredClear.x_ft*$scale),($sy+$tablePreferredClear.y_ft*$scale),($tablePreferredClear.width_ft*$scale),($tablePreferredClear.depth_ft*$scale))
$svg+=('<rect class="body" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">8×4 island</text><rect class="table-body" x="{6}" y="{7}" width="{8}" height="{9}"/><text class="label" x="{10}" y="{11}">36×60 table</text>' -f ($sx+$island.x_ft*$scale),($sy+$island.y_ft*$scale),($island.width_ft*$scale),($island.depth_ft*$scale),($sx+$island.x_ft*$scale+5),($sy+$island.y_ft*$scale+18),($sx+$table.x_ft*$scale),($sy+$table.y_ft*$scale),($table.width_ft*$scale),($table.depth_ft*$scale),($sx+$table.x_ft*$scale+5),($sy+$table.y_ft*$scale+18))
foreach($c in $coreRects){$svg+=('<rect class="core" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f ($sx+$c.x_ft*$scale),($sy+$c.y_ft*$scale),($c.width_ft*$scale),($c.depth_ft*$scale))}
$svg+=('<text class="note" x="20" y="925">Green: 42in island envelope. Purple: 36in table pull-back. Amber dash: 42in preferred table clearance.</text>','<text class="note" x="20" y="948">Table minimum and island envelopes meet at a boundary; separate porch route and counters remain untested.</text>','</svg>')
$svg -join "`n"|Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest=[ordered]@{generator='Tools/test_m33_open_social_zone_fit.ps1';source_hashes=$report.source_fingerprints_sha256;output_hashes=[ordered]@{fit_json=(Get-FileHash $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks_json=(Get-FileHash $checksPath -Algorithm SHA256).Hash.ToLowerInvariant();svg=(Get-FileHash $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
$manifest|ConvertTo-Json -Depth 10|Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output("M33 fit screen checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output("Island body {0}×{1} ft; 42in envelope extends east {2} ft and north {3} ft beyond M-02." -f $island.width_ft,$island.depth_ft,$islandOutsideKitchen.east_ft,$islandOutsideKitchen.north_ft)
Write-Output("Dining table {0}×{1} ft; 36in pull-back fits M-03: {2}; 42in preferred envelope spill to rear: {3} ft." -f $table.width_ft,$table.depth_ft,(Test-Inside $tableMinClear $dining),$tablePreferredOutsideDining.north_ft)
Write-Output('Separate chair-independent route to porch remains unverified.')
