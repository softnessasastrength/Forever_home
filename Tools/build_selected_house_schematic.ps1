param(
    [string]$OutputDirectory = "Architecture/Selected_Design_Iteration_2026-10-27"
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sourcePath = Join-Path $root 'Architecture/Schematic_Study_2026-10-25/study.json'
$checksPath = Join-Path $root 'Architecture/Schematic_Study_2026-10-25/checks.json'
$target = Join-Path $root $OutputDirectory
$source = Get-Content -Raw -LiteralPath $sourcePath | ConvertFrom-Json
$sourceChecks = Get-Content -Raw -LiteralPath $checksPath | ConvertFrom-Json
$sourceFingerprints = [ordered]@{
    'Architecture/Schematic_Study_2026-10-25/study.json' = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash.ToLowerInvariant()
    'Architecture/Schematic_Study_2026-10-25/checks.json' = (Get-FileHash -Algorithm SHA256 -LiteralPath $checksPath).Hash.ToLowerInvariant()
    'Requirements/Room_Program.md' = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $root 'Requirements/Room_Program.md')).Hash.ToLowerInvariant()
    'Decisions/Kitchen_Island_Finish.md' = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $root 'Decisions/Kitchen_Island_Finish.md')).Hash.ToLowerInvariant()
    'Decisions/2026-10-27_Selected_Architectural_Direction_D.md' = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $root 'Decisions/2026-10-27_Selected_Architectural_Direction_D.md')).Hash.ToLowerInvariant()
}

function Copy-Rooms($rooms) {
    @($rooms | ForEach-Object {
        [ordered]@{ id=$_.id; name=$_.name; x=[double]$_.x; y=[double]$_.y; w=[double]$_.w; d=[double]$_.d; kind=$_.kind }
    })
}

$main = @(Copy-Rooms $source.alternatives.B.plans.main | Where-Object { $_.id -notin @('M-06','L-02') })
$upper = @(Copy-Rooms $source.alternatives.B.plans.upper)
$lower = @(Copy-Rooms $source.alternatives.A.plans.lower | Where-Object { $_.id -ne 'S-01' })

# Reconcile the existing 6 in gap between guest and Jack-and-Jill blocks:
# keep a 6 in wall/service allowance, retain the 10 x 12 ft bath, and keep
# the 11 x 10 ft lower flex room clear of the bath projection. U-04 remains
# within its documented 100-120 sf study range.
$guest = $upper | Where-Object id -eq 'U-04'
$guest.d = 8.0
$jill = $upper | Where-Object id -eq 'U-06'
$jill.y = 55.0 / 6.0
$upperDoors = @($source.upper_door_matrix | ForEach-Object {
    [ordered]@{id=$_.id; a=$_.a; b=$_.b; x=[double]$_.x; y=[double]$_.y; axis=$_.axis; nominal_reservation_ft=$_.nominal_reservation_ft}
})
($upperDoors | Where-Object id -eq 'D-U08').y = 107.0 / 12.0
($upperDoors | Where-Object id -eq 'D-U09').y = 65.0 / 3.0

# Retain the documented 8 x 8 ft technology-room test block, moved into the
# lower plan area outside the projected Jack-and-Jill footprint. This is a
# proposed location; service route and acoustic review remain open.
$tech = $lower | Where-Object id -eq 'L-06'
$tech.x = 52.0 / 3.0
$tech.y = 2.0 / 3.0

$study = [ordered]@{
    schema = 'forever-home.selected-house-schematic.v1'
    title = 'Selected direction D â€” lower flex room / B-sized main shell'
    status = 'owner-selected design direction; schematic blocks only; not a coordinated or approved house plan'
    source = 'Derived from the existing A/B schematic study; source alternatives remain unchanged.'
    source_fingerprints_sha256 = $sourceFingerprints
    units = 'feet; local x right, local y toward rear; no site orientation or georeference'
    selection = [ordered]@{
        bedroom_flex_level = 'lower (A strategy)'
        main_shell = '40 x 42 ft (B test envelope)'
        levels = @(@{id='Lower FF'; elevation_ft=-5},@{id='Main FF'; elevation_ft=0},@{id='Upper FF'; elevation_ft=5})
        vertical_core = [ordered]@{ comparison_risers_per_half_flight=8; comparison_riser_in=7.5; comparison_tread_in=11; floor_assembly_placeholder_in=15; lift_reservation_ft=@(8,8); status='B stair arithmetic is a comparison baseline, not a selected stair specification; landing, opening, final riser count, headroom, structure and product fit remain unresolved' }
        main_public_bath = [ordered]@{ type='half bath'; id='M-06'; footprint='TBD'; position='TBD'; status='owner-selected room type; size and exact location not yet specified' }
        suite_strategy = 'Retain the proposed private primary suite, primary-only primary bath, independent guest hall access, and hybrid/guest Jack-and-Jill pair.'
        kitchen = [ordered]@{ perimeter_induction=$true; perimeter_sink_and_dishwasher=$true; island_appliance_free=$true; island_ft=@(8,4); island_origin_local_ft=@([double]$source.kitchen_test.island.x,[double]$source.kitchen_test.island.y); counter_finish='approximately 6 ft cream quartz + 2 ft butcher block'; plan_test='17 ft 4 in x 16 ft room block inherited from the documented fit test; area is not approved' }
    }
    shells = [ordered]@{ main=@(40,42); rear_lower=@(36,32); rear_upper=@(36,32); garage_sf=576; porch_ft=@(12,10) }
    plans = [ordered]@{
        main = $main
        upper = $upper
        lower = $lower
    }
    upper_door_matrix = $upperDoors
    unplaced_program = @(
        @{id='M-06'; name='Main half bath'; reason='Owner selected room type; footprint and location TBD.'},
        @{id='M-05'; name='Coat storage / mudroom fit'; reason='Current source block is an entry/hall reservation; storage and garage arrival are not resolved.'},
        @{id='S-01'; name='Secure storage'; reason='Discreet conditioned location remains TBD; omitted from geometric blocks.'},
        @{id='C-01'; name='Stair, landings and lift route'; reason='Core geometry and connected upper landing require a native section and plan iteration.'}
    )
}

function Test-Overlap($a,$b) {
    $dx = [Math]::Min(($a.x+$a.w),($b.x+$b.w)) - [Math]::Max($a.x,$b.x)
    $dy = [Math]::Min(($a.y+$a.d),($b.y+$b.d)) - [Math]::Max($a.y,$b.y)
    if ($dx -gt 0.000001 -and $dy -gt 0.000001) { return [ordered]@{overlap=$true; area_sf=[Math]::Round($dx*$dy,4)} }
    return [ordered]@{overlap=$false; area_sf=0}
}

$planChecks = [ordered]@{}
$overlaps = [System.Collections.Generic.List[object]]::new()
foreach ($level in @('main','upper','lower')) {
    $rooms = @($study.plans[$level] | Where-Object { $_.kind -eq 'room' })
    $shell = if ($level -eq 'main') { @(40,42) } else { @(36,32) }
    $inside = $true
    $positive = $true
    foreach ($room in $rooms) {
        if ($room.w -le 0 -or $room.d -le 0) { $positive = $false }
        if ($room.x -lt 2/3 -or $room.y -lt 2/3 -or $room.x+$room.w -gt $shell[0]-2/3+0.000001 -or $room.y+$room.d -gt $shell[1]-2/3+0.000001) { $inside = $false }
    }
    for ($i=0; $i -lt $rooms.Count; $i++) {
        for ($j=$i+1; $j -lt $rooms.Count; $j++) {
            $hit = Test-Overlap $rooms[$i] $rooms[$j]
            if ($hit.overlap) { $overlaps.Add(@{level=$level; a=$rooms[$i].id; b=$rooms[$j].id; area_sf=$hit.area_sf}) }
        }
    }
    $planChecks["${level}_room_blocks_inside_shell"] = $inside
    $planChecks["${level}_positive_room_dimensions"] = $positive
    $planChecks["${level}_no_room_block_overlap"] = -not (@($overlaps | Where-Object level -eq $level).Count)
}

$lowerFlex = $lower | Where-Object id -eq 'L-02'
$lowerTech = $lower | Where-Object id -eq 'L-06'
$wetStack = Test-Overlap $jill $lowerFlex
$techStack = Test-Overlap $jill $lowerTech
$planChecks['upper_jack_jill_and_lower_technology_do_not_overlap'] = -not $techStack.overlap
$planChecks['upper_jack_jill_and_lower_flex_do_not_overlap'] = -not $wetStack.overlap
$planChecks['guest_room_remains_within_documented_100_to_120_sf_allowance'] = (($guest.w*$guest.d) -ge 100 -and ($guest.w*$guest.d) -le 120)
$mainCounts = @($main | Where-Object kind -eq 'room').Count
$planChecks['main_full_bath_and_main_flex_removed_from_selected_levels'] = -not (@($main | Where-Object id -in @('M-06','L-02')).Count)
$planChecks['selected_lower_flex_room_present'] = [bool]$lowerFlex
$planChecks['main_half_bath_not_given_invented_footprint'] = -not (@($main | Where-Object id -eq 'M-06').Count)
$planChecks['documented_kitchen_fit_reference_checks_pass'] = [bool]($sourceChecks.checks.old_kitchen_12_ft_short_axis_fails_13_ft_counter_aisle_island_aisle_chain -and $sourceChecks.checks.new_kitchen_has_4_ft_work_aisle -and $sourceChecks.checks.new_kitchen_8_ft_island_has_end_clearances -and $sourceChecks.checks.kitchen_has_seat_allowance_plus_4_ft_route)

$findings = @(
    @{id='D-OPEN-01'; priority='P1'; status='open'; issue='The selected 8-riser concept has no connected, checked upper landing in the existing native model; coordinate stair, floor opening, headroom and structure.'},
    @{id='D-OPEN-02'; priority='P1'; status='open'; issue='M-06 is now a half bath by owner direction, but no footprint or position is specified; keep out of geometry and area totals pending fit study.'},
    @{id='D-OPEN-03'; priority='P1'; status='open'; issue='Kitchen fit uses the existing 17 ft 4 in x 16 ft test block; room area and appliance-open clearances remain unapproved.'},
    @{id='D-OPEN-04'; priority='P2'; status='open'; issue='Technology block is moved outside the Jack-and-Jill footprint; confirm hall access, ventilation, equipment service and acoustic separation.'},
    @{id='D-OPEN-05'; priority='P2'; status='open'; issue='Entry storage, secure storage, garage transfer, site access, porch thresholds and the full accessible route remain unplaced or unverified.'}
)
$checks = [ordered]@{
    status = 'schematic geometry checks only; unresolved design items remain'
    checks = $planChecks
    measurements = [ordered]@{ lower_L02_vs_upper_U06_overlap_sf=$wetStack.area_sf; lower_L06_vs_upper_U06_overlap_sf=$techStack.area_sf; placed_main_room_count=$mainCounts; lower_L02_net_sf=[Math]::Round($lowerFlex.w*$lowerFlex.d,2); selected_bath_area_sf=$null }
    room_block_overlaps = @($overlaps)
    findings = $findings
    exclusions = @('Door swings and clear openings','Furniture-complete route checks','Stair/landing/headroom/guard/floor-edge coordination','Lift product fit','Structure, foundation, roof, site and code','Detailed MEP and kitchen appliance-open tests','Native Revit house model and IFC export for this design iteration')
}

function Xml-Escape([string]$text) { [System.Security.SecurityElement]::Escape($text) }
function New-PlanSvg([string]$level,[object[]]$rooms,[double]$width,[double]$depth,[string[]]$notes) {
    $scale=10; $left=54; $top=64; $canvasWidth=[Math]::Max(660,($width*$scale)+$left+310); $canvasHeight=($depth*$scale)+$top+75
    $items=[System.Collections.Generic.List[string]]::new()
    $items.Add("<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$canvasWidth`" height=`"$canvasHeight`" viewBox=`"0 0 $canvasWidth $canvasHeight`">")
    $items.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:20px;font-weight:bold}.label{font-size:11px}.small{font-size:10px}.shell{fill:#fcfaf5;stroke:#4e463d;stroke-width:3}.room{fill:#eadfce;stroke:#716456;stroke-width:1.4}.circulation{fill:#f3eee5;stroke:#9a8d7d;stroke-width:1;stroke-dasharray:4 3}.island{fill:#dce7db;stroke:#667963;stroke-width:1.6;stroke-dasharray:6 3}.header{font-size:12px;fill:#6b6257}</style>')
    $items.Add(('<text class="title" x="{0}" y="28">D - {1} plan - schematic room blocks</text>' -f $left,$level))
    $items.Add(('<text class="header" x="{0}" y="47">Local x right; rear at top - shell reservation only - no site orientation</text>' -f $left))
    $items.Add("<rect class=`"shell`" x=`"$left`" y=`"$top`" width=`"$($width*$scale)`" height=`"$($depth*$scale)`" />")
    foreach ($room in $rooms) {
        $x=$left+$room.x*$scale; $y=$top+($depth-$room.y-$room.d)*$scale; $w=$room.w*$scale; $h=$room.d*$scale
        $class=if($room.kind -eq 'circulation'){'circulation'}else{'room'}
        $items.Add("<rect class=`"$class`" x=`"$([Math]::Round($x,2))`" y=`"$([Math]::Round($y,2))`" width=`"$([Math]::Round($w,2))`" height=`"$([Math]::Round($h,2))`" />")
        $lines=@($room.id,$room.name,"$([Math]::Round($room.w,2)) x $([Math]::Round($room.d,2)) ft")
        $lineY=$y+[Math]::Max(13,($h/2)-10)
        foreach ($line in $lines) { $items.Add("<text class=`"label`" x=`"$([Math]::Round($x+4,2))`" y=`"$([Math]::Round($lineY,2))`">$(Xml-Escape $line)</text>"); $lineY+=13 }
    }
    if ($level -eq 'main') {
        $kitchen=$main | Where-Object id -eq 'M-02'
        $k=$study.selection.kitchen
        $ix=$left+($kitchen.x+$k.island_origin_local_ft[0])*$scale
        $iy=$top+($depth-$kitchen.y-$k.island_origin_local_ft[1]-$k.island_ft[1])*$scale
        $items.Add("<rect class=`"island`" x=`"$([Math]::Round($ix,2))`" y=`"$([Math]::Round($iy,2))`" width=`"$($k.island_ft[0]*$scale)`" height=`"$($k.island_ft[1]*$scale)`" />")
        $items.Add(('<text class="label" x="{0}" y="{1}">8 x 4 ft island test</text>' -f [Math]::Round($ix+4,2),[Math]::Round($iy+23,2)))
    }
    $noteX=$left+$width*$scale+22; $noteY=$top+12
    foreach ($note in $notes) {
        foreach ($line in ($note -split '(?<=.{1,42})')) { if ($line) { $items.Add("<text class=`"small`" x=`"$noteX`" y=`"$noteY`">$(Xml-Escape $line)</text>"); $noteY+=14 } }
        $noteY+=8
    }
    $items.Add('</svg>')
    return ($items -join "`n")
}

New-Item -ItemType Directory -Path $target -Force | Out-Null
$jsonPath=Join-Path $target 'study.json'
$checksPathOut=Join-Path $target 'checks.json'
$study | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$checks | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $checksPathOut -Encoding utf8
$csvRows=foreach($level in @('main','upper','lower')) { foreach($room in $study.plans[$level]) { [pscustomobject]@{level=$level;id=$room.id;name=$room.name;kind=$room.kind;width_ft=$room.w;depth_ft=$room.d;area_sf=[Math]::Round($room.w*$room.d,2)} } }
$csvRows | Export-Csv -LiteralPath (Join-Path $target 'room-area.csv') -NoTypeInformation -Encoding utf8
$notesByLevel=@{
    main=@('Main shell test: 40 x 42 ft.','M-06 half bath: size and location TBD; not drawn.','Stair/lift core and connected landing: review gate, not fitted.','Kitchen block retains the prior fit-study size; not approved.')
    upper=@('Rear upper plate: 36 x 32 ft.','Primary bath private to U-01.','Jack-and-Jill serves U-03 and U-04.','Doors, privacy boundary, stair landing and headroom need review.')
    lower=@("Rear lower plate: 36 x 32 ft. Lower L-02 is the A-strategy block.","L-06 moved outside upper U-06 projection; overlap = $($techStack.area_sf) sf.","L-02/U-06 projected overlap = $($wetStack.area_sf) sf after the upper-room adjustment.",'Secure storage is not located in this study.')
}
foreach($level in @('main','upper','lower')) {
    $wh=if($level -eq 'main'){@(40,42)}else{@(36,32)}
    $svg=New-PlanSvg $level $study.plans[$level] $wh[0] $wh[1] $notesByLevel[$level]
    Set-Content -LiteralPath (Join-Path $target "$level-plan.svg") -Value $svg -Encoding utf8
}

$xmlValid=$true
foreach($file in Get-ChildItem -LiteralPath $target -Filter '*-plan.svg') { try { [xml](Get-Content -Raw -LiteralPath $file.FullName) | Out-Null } catch { $xmlValid=$false; throw } }
$allPass=(@($planChecks.Values | Where-Object { $_ -ne $true }).Count -eq 0)
$checks | Add-Member -NotePropertyName all_geometry_checks_pass -NotePropertyValue $allPass
$checks | Add-Member -NotePropertyName all_svg_files_parse_as_xml -NotePropertyValue $xmlValid
$checks | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $checksPathOut -Encoding utf8
Write-Output ("Generated selected design D: {0}" -f $target)
Write-Output ("Room block checks passed: {0}/{1}; SVG XML valid: {2}" -f @($planChecks.Values | Where-Object { $_ -eq $true }).Count, $planChecks.Count, $xmlValid)
Write-Output ("Open stacked L-02/U-06 overlap: {0} sf; bath footprint remains TBD." -f $wetStack.area_sf)
if (-not $allPass -or -not $xmlValid) { exit 1 }
