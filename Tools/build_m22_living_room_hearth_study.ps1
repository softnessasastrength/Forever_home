param([string]$OutputDirectory = 'Architecture/M22_Living_Room_Hearth_Study_2026-10-28')

$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sourcePath=Join-Path $root 'Research/M22_Pellet_Stove_Envelope_2026-10-28.json'
$dPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$programPath=Join-Path $root 'Requirements/Room_Program.md'
$tvDecisionPath=Join-Path $root 'Decisions/Living_Room_Rear_Projection_TV.md'
foreach($p in @($sourcePath,$dPath,$programPath,$tvDecisionPath)){if(-not(Test-Path -LiteralPath $p)){throw "Required input is missing: $p"}}
$source=Get-Content -LiteralPath $sourcePath -Raw|ConvertFrom-Json
$d=Get-Content -LiteralPath $dPath -Raw|ConvertFrom-Json
$program=Get-Content -LiteralPath $programPath -Raw
$tvDecision=Get-Content -LiteralPath $tvDecisionPath -Raw
$rooms=@($d.plans.main)
$living=$rooms|Where-Object id -eq 'M-01'
$dining=$rooms|Where-Object id -eq 'M-03'
$entry=$rooms|Where-Object id -eq 'M-05'
if(@($living).Count -ne 1 -or @($dining).Count -ne 1 -or @($entry).Count -ne 1){throw 'Expected one each of M-01, M-03, and M-05 in selected-D main plan.'}
$rangeMatch=[regex]::Match($program,'(?m)^\|\s*M-01\s*\|\s*Living room\s*\|\s*Main\s*\|[^\d]*(\d+)[^\d]+(\d+)\s*sf')
if(-not $rangeMatch.Success){throw 'Could not parse the M-01 area range from Requirements/Room_Program.md.'}
if($tvDecision -notmatch 'model, size, and exact technology not selected' -or $tvDecision -notmatch 'exact physical specifications before dimensioning'){throw 'TV source no longer records the unresolved model/size gate; review this study before regeneration.'}

function Sha([string]$p){(Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()}
function Near([double]$a,[double]$b,[double]$tol=0.001){[Math]::Abs($a-$b) -le $tol}
$w=[double]$living.w; $depth=[double]$living.d
$area=$w*$depth
$minimumArea=[double]$rangeMatch.Groups[1].Value
$maximumArea=[double]$rangeMatch.Groups[2].Value
$diningGap=([double]$dining.y-([double]$living.y+[double]$living.d))*12
$diningShared=[Math]::Min(([double]$dining.x+[double]$dining.w),([double]$living.x+$w))-[Math]::Max([double]$dining.x,[double]$living.x)
$entryGap=([double]$entry.x-([double]$living.x+$w))*12
$entryShared=[Math]::Min(([double]$entry.y+[double]$entry.d),([double]$living.y+$depth))-[Math]::Max([double]$entry.y,[double]$living.y)
$body=$source.candidate.dimensions_in
$cl=$source.clearances_in
$envelopes=@(
    [ordered]@{id='side_shields';side_clearance_in=[double]$cl.side_with_shields;width_in=([double]$body.width+2*[double]$cl.side_with_shields);depth_in=([double]$body.depth+[double]$cl.rear_to_combustible+[double]$cl.front_combustible_separation_diagram)}
    [ordered]@{id='no_side_shields';side_clearance_in=[double]$cl.side_without_shields;width_in=([double]$body.width+2*[double]$cl.side_without_shields);depth_in=([double]$body.depth+[double]$cl.rear_to_combustible+[double]$cl.front_combustible_separation_diagram)}
)
foreach($e in $envelopes){$e['fits_inside_gross_m01_rectangle_by_arithmetic']=($e.width_in -le ($w*12) -and $e.depth_in -le ($depth*12))}
$sourceHashes=[ordered]@{
    'Research/M22_Pellet_Stove_Envelope_2026-10-28.json'=(Sha $sourcePath)
    'Architecture/Selected_Design_Iteration_2026-10-27/study.json'=(Sha $dPath)
    'Requirements/Room_Program.md'=(Sha $programPath)
    'Decisions/Living_Room_Rear_Projection_TV.md'=(Sha $tvDecisionPath)
}
$options=@(
    [ordered]@{id='A';hearth_wall='opposite 16 ft edge from dining-facing edge';tv_wall='dining-facing 16 ft edge';separation_ft=$depth;selected=$false}
    [ordered]@{id='B';hearth_wall='dining-facing 16 ft edge';tv_wall='opposite 16 ft edge from dining-facing edge';separation_ft=$depth;selected=$false}
)
$gates=@('Gross rectangular clearance arithmetic is not a placement, site fit or safe installation.','The manufacturer minimum clearances do not include extra service/cleaning room, furniture, vent routes, outside air or egress.','No P43-C mantel or architectural recess clearance was located in the manufacturer manual.','No wall assembly, door/window, hearth material/support, product family, TV model dimensions or site orientation is defined.','M-01 remains a 240 sf schematic block, 20 sf over its preliminary 220 sf program ceiling; no area is approved by this study.','No Revit or IFC file was modified or generated.')
$optionsAreSwaps=($options.Count -eq 2 -and $options[0].hearth_wall -eq $options[1].tv_wall -and $options[0].tv_wall -eq $options[1].hearth_wall -and (Near $options[0].separation_ft 15) -and (Near $options[1].separation_ft 15) -and -not $options[0].selected -and -not $options[1].selected)
$optionsAvoidCompass=(@($options|Where-Object{$_.hearth_wall -match '\b(north|south|east|west)\b' -or $_.tv_wall -match '\b(north|south|east|west)\b'}).Count -eq 0)
$gatesPreserved=($gates -contains 'No P43-C mantel or architectural recess clearance was located in the manufacturer manual.' -and $gates -contains 'No wall assembly, door/window, hearth material/support, product family, TV model dimensions or site orientation is defined.')
$checks=[ordered]@{
    exact_expected_source_files_present=($source.candidate.model -eq 'P43-C' -and $source.manuals.Count -eq 2)
    selected_d_m01_block_is_16_by_15_ft=(Near $w 16 -and (Near $depth 15))
    selected_d_m01_block_area_is_240_sf=(Near $area 240)
    m01_area_is_20_sf_above_preliminary_program_max=(Near ($area-$maximumArea) 20)
    preliminary_program_range_is_180_to_220_sf=(Near $minimumArea 180 -and (Near $maximumArea 220))
    dining_facing_long_edge_is_16_ft=(Near $w 16)
    dining_block_is_separated_by_nominal_6_in=(Near $diningGap 6)
    dining_shares_11ft4in_of_m01_edge=(Near ($diningShared*12) 136)
    opposite_long_edge_is_16_ft=(Near $w 16)
    opposing_long_edges_are_15_ft_apart=(Near $depth 15)
    entry_facing_short_edge_has_nominal_6_in_gap=(Near $entryGap 6)
    entry_shares_12_ft_of_m01_edge=(Near $entryShared 12)
    p43c_body_is_22_by_28_3125_by_33_5_in=((Near ([double]$body.width) 22) -and (Near ([double]$body.depth) 28.3125) -and (Near ([double]$body.height) 33.5))
    manufacturer_clearance_screen_with_shields_fits_gross_room=([bool]$envelopes[0].fits_inside_gross_m01_rectangle_by_arithmetic)
    manufacturer_clearance_screen_without_shields_fits_gross_room=([bool]$envelopes[1].fits_inside_gross_m01_rectangle_by_arithmetic)
    side_shield_envelope_is_wider_by_12_in=(Near ([double]$envelopes[1].width_in-[double]$envelopes[0].width_in) 12)
    both_options_keep_stove_and_tv_on_separate_opposing_edges=$optionsAreSwaps
    neither_option_claims_geographic_orientation=$optionsAvoidCompass
    tv_remains_unselected_and_undimensioned=($tvDecision -match 'model, size, and exact technology not selected' -and $tvDecision -match 'exact physical specifications before dimensioning')
    report_preserves_open_wall_assembly_and_alcove_gates=$gatesPreserved
}
$failed=@($checks.GetEnumerator()|Where-Object{-not[bool]$_.Value})
if($failed.Count){throw ('M22 checks failed: '+(($failed|ForEach-Object Key)-join ', '))}
$report=[ordered]@{
    schema='forever-home-m22-hearth-wall-study-v1'
    status='Unapproved wall relationship comparison; no stove, TV, wall, or hearth selected or placed.'
    source_fingerprints_sha256=$sourceHashes
    room=[ordered]@{id='M-01';block_ft=@([double]$living.x,[double]$living.y,$w,$depth);area_sf=$area;program_range_sf=@($minimumArea,$maximumArea);over_program_max_sf=($area-$maximumArea);edges=[ordered]@{dining_facing_long_edge_ft=$w;opposite_long_edge_ft=$w;long_edge_separation_ft=$depth;entry_facing_short_edge_ft=$depth;entry_nominal_gap_in=$entryGap;entry_shared_edge_span_ft=$entryShared;dining_nominal_gap_in=$diningGap;dining_shared_edge_span_ft=[Math]::Round($diningShared,3)}}
    pellet_stove_candidate=[ordered]@{model=$source.candidate.model;owner_selected=$false;source_dimensions_in=$body;manufacturer_minimum_clearance_screen_envelopes=$envelopes;gross_block_screen_only=$true;floor_protection_minimum_in=[ordered]@{width=[double]$cl.floor_protection_minimum_rectangular_width;depth=[double]$cl.floor_protection_minimum_rectangular_depth};revit_family_located=[bool]$source.model_family_file.exact_p43c_revit_rfa_located}
    wall_options=$options
    television=[ordered]@{reference='Mitsubishi WS-65815';status='Owner-selected visual reference only; exact unit, dimensions and viewing wall unselected.';placeholder_dimensioned_or_placed=$false}
    gates=$gates
    no_physical_products_placed=$true
    no_walls_or_hearth_geometry_authored=$true
}
$checkReport=[ordered]@{schema='forever-home-m22-checks-v1';passed=$checks.Count;failed=0;checks=$checks}

$svgScale=17.0; $oy=73.0; $panelX=@(55.0,520.0); $svg=[System.Collections.Generic.List[string]]::new()
$svg.Add("<svg xmlns='http://www.w3.org/2000/svg' width='1000' height='480' viewBox='0 0 1000 480'>")
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#243140}.title{font-size:22px;font-weight:bold}.subtitle{font-size:15px;font-weight:bold}.label{font-size:11px}.note{font-size:10px}.living{fill:#efe7dc;stroke:#4c443d;stroke-width:2}.adjacent{fill:#e1e9e6;stroke:#586a61;stroke-width:1.5}.entry{fill:#f3dfb7;stroke:#86632b;stroke-width:1.5}.kitchen{fill:#e4ead7;stroke:#65734d;stroke-width:1.5}.stove{stroke:#984c32;stroke-width:8}.tv{stroke:#466d9b;stroke-width:8}.shell{fill:none;stroke:#293b4d;stroke-width:2}</style>')
$svg.Add("<text x='30' y='31' class='title'>M22 | living-room focal-wall relationships</text>")
$svg.Add(("<text x='30' y='50' class='note'>Two 16 ft opposing edges; 15 ft apart. Product envelopes are documented separately, not placed here.</text>"))
for($i=0;$i -lt 2;$i++){
    $x0=$panelX[$i]; $rw=$w*$svgScale; $rh=$depth*$svgScale; $x1=$x0+$rw; $y0=$oy; $y1=$y0+$rh
    $svg.Add("<text x='$x0' y='67' class='subtitle'>Option $($options[$i].id): stove and TV swap opposing edges</text>")
    $svg.Add("<rect x='$x0' y='$y0' width='$rw' height='$rh' class='living'/>")
    # M-03 lies beyond the dining-facing long edge; M-05 meets the east short edge in the selected-D block arrangement.
    $diningW=$diningShared*$svgScale; $svg.Add("<rect x='$x0' y='$([Math]::Round($y1+9,2))' width='$diningW' height='28' class='adjacent'/>")
    $svg.Add("<text x='$([Math]::Round($x0+4,2))' y='$([Math]::Round($y1+27,2))' class='label'>M-03 Dining test block</text>")
    $entryY=$y0; $entryH=$entryShared*$svgScale; $svg.Add("<rect x='$([Math]::Round($x1+9,2))' y='$entryY' width='54' height='$entryH' class='entry'/>")
    $svg.Add("<text x='$([Math]::Round($x1+12,2))' y='$([Math]::Round($y0+20,2))' class='note'>M-05</text>")
    $svg.Add("<rect x='$([Math]::Round($x1+72,2))' y='$y0' width='63' height='$entryH' class='kitchen'/>")
    $svg.Add("<text x='$([Math]::Round($x1+75,2))' y='$([Math]::Round($y0+20,2))' class='note'>M-02</text>")
    $svg.Add("<text x='$([Math]::Round($x0+6,2))' y='$([Math]::Round($y0+23,2))' class='label'>M-01 16 x 15 ft</text>")
    if($i -eq 0){$svg.Add("<line x1='$x0' y1='$y0' x2='$x1' y2='$y0' class='stove'/>");$svg.Add("<line x1='$x0' y1='$y1' x2='$x1' y2='$y1' class='tv'/>")}
    else{$svg.Add("<line x1='$x0' y1='$y0' x2='$x1' y2='$y0' class='tv'/>");$svg.Add("<line x1='$x0' y1='$y1' x2='$x1' y2='$y1' class='stove'/>")}
    $svg.Add("<text x='$x0' y='$([Math]::Round($y1+54,2))' class='note'>Red: proposed pellet-hearth wall | Blue: proposed rear-projection-TV wall</text>")
    $svg.Add("<text x='$x0' y='$([Math]::Round($y1+69,2))' class='note'>No products, openings, finishes, compass direction or wall assembly assigned.</text>")
}
$svg.Add('</svg>')
$svgText=$svg -join "`r`n"; $null=[xml]$svgText
$out=Join-Path $root $OutputDirectory; New-Item -ItemType Directory -Force -Path $out|Out-Null
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'study.json'),($report|ConvertTo-Json -Depth 10)+"`n",$utf8)
[IO.File]::WriteAllText((Join-Path $out 'checks.json'),($checkReport|ConvertTo-Json -Depth 8)+"`n",$utf8)
[IO.File]::WriteAllText((Join-Path $out 'wall-options.svg'),$svgText+"`r`n",$utf8)
Write-Output "M22 checks: $($checks.Count)/$($checks.Count) passed. SVG parses as XML."
Write-Output "P43-C source envelope fits the 16 x 15 ft M-01 gross rectangle arithmetically in both shield cases; no product placement or wall selection is claimed."
