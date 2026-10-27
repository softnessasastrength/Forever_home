param(
    [ValidateSet('OwnerSelectedD','AdjacencyCandidate','BathFirstAdjacencyCandidate')]
    [string]$LayoutVariant = 'OwnerSelectedD',
    [string]$OutputDirectory = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = if ($LayoutVariant -eq 'AdjacencyCandidate') { 'Architecture/Direction_D_Adjacency_Study_2026-10-27' } elseif ($LayoutVariant -eq 'BathFirstAdjacencyCandidate') { 'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27' } else { 'Architecture/Selected_Design_Iteration_2026-10-27' }
}
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
$baseMain = @(Copy-Rooms $source.alternatives.B.plans.main | Where-Object { $_.id -notin @('M-06','L-02') })
$upper = @(Copy-Rooms $source.alternatives.B.plans.upper)
$lower = @(Copy-Rooms $source.alternatives.A.plans.lower | Where-Object { $_.id -ne 'S-01' })
$isAdjacencyCandidate = $LayoutVariant -eq 'AdjacencyCandidate'
$isBathFirstAdjacencyCandidate = $LayoutVariant -eq 'BathFirstAdjacencyCandidate'
if ($isAdjacencyCandidate) {
    # Preserve all owner-selected room areas and use only the documented
    # six-inch wall zone to derive a main-floor adjacency alternative.
    $living = $main | Where-Object id -eq 'M-01'
    $kitchen = $main | Where-Object id -eq 'M-02'
    $dining = $main | Where-Object id -eq 'M-03'
    $pantry = $main | Where-Object id -eq 'M-04'
    $entry = $main | Where-Object id -eq 'M-05'
    $living.x = $kitchen.x - 0.5 - $living.w
    $entry.x = 2.0 / 3.0
    $dining.x = $kitchen.x
    $dining.y = $kitchen.y + $kitchen.d + 0.5
    $pantry.x = $dining.x + $dining.w + 0.5
    $pantry.y = $dining.y
}
elseif ($isBathFirstAdjacencyCandidate) {
    # Keep the owner's pantry-side M-06 search window clear while connecting
    # the main social rooms. The east-side entry position is only a proposal.
    $living = $main | Where-Object id -eq 'M-01'
    $kitchen = $main | Where-Object id -eq 'M-02'
    $dining = $main | Where-Object id -eq 'M-03'
    $pantry = $main | Where-Object id -eq 'M-04'
    $entry = $main | Where-Object id -eq 'M-05'
    $kitchen.x = 2.0 / 3.0
    $kitchen.y = 2.0 / 3.0
    $living.x = $kitchen.x + $kitchen.w + 0.5
    $living.y = $kitchen.y
    $dining.x = $kitchen.x
    $dining.y = $kitchen.y + $kitchen.d + 0.5
    $pantry.x = $dining.x + $dining.w + 0.5
    $pantry.y = $dining.y
    $entry.x = 35.0
    $entry.y = 2.0 / 3.0
}

# Read room allowances directly from the documented program, rather than
# copying ranges into this generator. These are study references, not hard
# fit/pass requirements.
$programPath = Join-Path $root 'Requirements/Room_Program.md'
$programById = @{}
foreach ($line in [System.IO.File]::ReadAllLines($programPath)) {
    if ($line -match '^\|\s*(?<id>[A-Z]-\d{2})\s*\|[^|]*\|[^|]*\|\s*(?<allowance>[^|]*)\|') {
        $id = $Matches.id
        $allowanceText = $Matches.allowance.Trim()
        $sfCell = [regex]::Match($allowanceText,'(?i)^(?<area>.*?)\bsf\b')
        $areaNumbers = @([regex]::Matches($sfCell.Groups['area'].Value,'\d+(?:\.\d+)?') | ForEach-Object { [double]::Parse($_.Value,[Globalization.CultureInfo]::InvariantCulture) })
        if ($areaNumbers.Count -ge 2) { $programById[$id] = [ordered]@{minimum_sf=$areaNumbers[0];maximum_sf=$areaNumbers[1];source_text=$allowanceText} }
        elseif ($areaNumbers.Count -eq 1) { $programById[$id] = [ordered]@{minimum_sf=$areaNumbers[0];maximum_sf=$areaNumbers[0];source_text=$allowanceText} }
        else { $programById[$id] = [ordered]@{minimum_sf=$null;maximum_sf=$null;source_text=$allowanceText} }
    }
}

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

# D-core comparison, using B's existing 8-riser arithmetic, 11 in treads,
# and 4 ft landing/flight reservations. The stair count and lift remain
# unselected; these blocks test whether the plan can be made continuous.
$coreXUpper = 103.0 / 6.0
$coreXLower = 12.5
$runLength = 7.0 * 11.0 / 12.0
$mainDepth = 42.0
$upperWingStartY = 42.0
$upperRunStartY = [double]$source.alternatives.B.core.stair_run_y
$upperRunEndY = $upperRunStartY + $runLength
# Align the rear edges of the 32 ft lower wing and 42 ft main shell for this
# comparison only. Lower local y=28..32 therefore maps to main y=38..42.
# Both flights then share a 6 ft 5 in plan run from y=31 ft 7 in to y=38 ft,
# with four-foot landings at each end. This is not a native section check.
$lowerWingOffsetY = $mainDepth - 32.0
$upperWingOffsetY = $upperRunEndY - 32.0
$planFrameOffsets = [ordered]@{
    main = @(0.0,0.0)
    upper = @(0.0,$upperWingOffsetY)
    lower = @(0.0,$lowerWingOffsetY)
}
$lowerLandingLocalY = 28.0
$lowerLandingMainY = $lowerLandingLocalY + $lowerWingOffsetY
$lowerRunStartY = [double]$source.alternatives.B.core.stair_run_y
$lowerRunEndY = $lowerRunStartY + $runLength
$lowerTopLandingY = [double]$source.alternatives.B.core.stair_front_y
$liftX = $coreXUpper + 4.0
$stairCore = [ordered]@{
    status='proposed plan coordination using inherited B comparison dimensions; stair count and lift product remain unselected'
    comparison_risers_per_flight=8
    comparison_treads_per_flight=7
    comparison_riser_in=7.5
    comparison_tread_in=11
    flight_and_landing_width_ft=4
    landing_depth_ft=4
    run_length_ft=$runLength
    lower_to_main=[ordered]@{
        x_ft=$coreXLower; lower_landing_ft=@($coreXLower,$lowerLandingMainY,4,4)
        lower_landing_local_ft=@($coreXLower,$lowerLandingLocalY,4,4)
        run_ft=@($coreXLower,$lowerRunStartY,4,$runLength)
        main_landing_ft=@($coreXLower,$lowerTopLandingY,4,4)
        main_floor_opening_ft=@($coreXLower,$lowerRunStartY,4,$runLength)
    }
    main_to_upper=[ordered]@{
        x_ft=$coreXUpper; main_landing_ft=@($coreXUpper,([double]$source.alternatives.B.core.stair_front_y),4,4)
        run_ft=@($coreXUpper,$upperRunStartY,4,$runLength)
        upper_landing_ft=@($coreXUpper,$upperRunEndY,4,4)
        main_floor_opening_ft=@($coreXUpper,$upperRunStartY,4,$runLength)
        upper_floor_extension_ft=@($coreXUpper,$upperRunEndY,4,($upperWingStartY-$upperRunEndY))
    }
    lift=[ordered]@{origin_ft=@($liftX,34);width_ft=8;depth_ft=8;status='reservation only; product, pit, overrun and door side unselected'}
    main_shell_rear_edge_openings=@(
        @{use='lower-to-main stair passage';x_interval_ft=@($coreXLower,($coreXLower+4));elevation_scope='lower/main; wall opening size and fire separation TBD'},
        @{use='upper stair bridge';x_interval_ft=@($coreXUpper,($coreXUpper+4));elevation_scope='main/upper; wall opening size and fire separation TBD'}
    )
    main_floor_profile_sf=[Math]::Round(40*42 - 8*$runLength - 64,3)
    upper_floor_profile_sf=1152+4*($upperWingStartY-$upperRunEndY)
}

$layoutTitle = if ($isAdjacencyCandidate) { 'Direction D adjacency candidate - main social sequence study' } elseif ($isBathFirstAdjacencyCandidate) { 'Direction D bath-first adjacency candidate' } else { 'Selected direction D - lower flex room / B-sized main shell' }
$layoutStatus = if ($isAdjacencyCandidate) { 'Unapproved adjacency alternative; room areas preserved; schematic blocks only' } elseif ($isBathFirstAdjacencyCandidate) { 'Unapproved bath-first adjacency alternative; room areas preserved; schematic blocks only' } else { 'owner-selected design direction; schematic blocks only; not a coordinated or approved house plan' }
$m06FirstFitCandidate = if ($isAdjacencyCandidate) { 'west_of_core' } else { 'east_of_core' }
$m06BlockedCandidateIds = if ($isAdjacencyCandidate) { @('east_of_core') } elseif ($isBathFirstAdjacencyCandidate) { @('west_of_core') } else { @() }
$m06Status = if ($isAdjacencyCandidate) { 'Unapproved adjacency layout test: pantry-side B conflicts with relocated dining/pantry; dining-side A is shown as fallback. Exact position, footprint and service route remain unresolved.' } elseif ($isBathFirstAdjacencyCandidate) { 'Unapproved bath-first comparison: pantry-side B remains clear in the room-block plan; dining-side A is blocked by relocated kitchen/pantry blocks. B is still only a search window, not a bath fit; exact position, footprint and service route remain unresolved.' } else { 'owner-selected room type and test zone; pantry-side search window selected for first fit study; exact location, footprint and service route remain unresolved' }
$study = [ordered]@{
    schema = 'forever-home.selected-house-schematic.v1'
    title = $layoutTitle
    status = $layoutStatus
    layout_variant = $LayoutVariant
    source = 'Derived from the existing A/B schematic study; source alternatives remain unchanged.'
    source_fingerprints_sha256 = $sourceFingerprints
    units = 'feet; local x right, local y toward rear; no site orientation or georeference'
    plan_frame_offsets_ft = $planFrameOffsets
    selection = [ordered]@{
        bedroom_flex_level = 'lower (A strategy)'
        main_shell = '40 x 42 ft (B test envelope)'
        levels = @(@{id='Lower FF'; elevation_ft=-5},@{id='Main FF'; elevation_ft=0},@{id='Upper FF'; elevation_ft=5})
        vertical_core = [ordered]@{ comparison_risers_per_half_flight=8; comparison_riser_in=7.5; comparison_tread_in=11; floor_assembly_placeholder_in=15; lift_reservation_ft=@(8,8); status='B stair arithmetic is a comparison baseline, not a selected stair specification; see proposed connected D core plan; final riser count, wall openings, headroom, structure and product fit remain unresolved' }
        main_public_bath = [ordered]@{ type='half bath'; id='M-06'; test_zone='arrival / hall edge'; owner_selected_first_fit_candidate='east_of_core'; first_fit_candidate=$m06FirstFitCandidate; blocked_candidate_ids=$m06BlockedCandidateIds; footprint='TBD'; position='TBD'; service_route='TBD'; status=$m06Status }
        suite_strategy = 'Retain the proposed private primary suite, primary-only primary bath, independent guest hall access, and hybrid/guest Jack-and-Jill pair.'
        kitchen = [ordered]@{ perimeter_induction=$true; perimeter_sink_and_dishwasher=$true; island_appliance_free=$true; island_ft=@(8,4); island_origin_local_ft=@([double]$source.kitchen_test.island.x,[double]$source.kitchen_test.island.y); counter_finish='approximately 6 ft cream quartz + 2 ft butcher block'; plan_test='17 ft 4 in x 16 ft room block inherited from the documented fit test; area is not approved' }
    }
    shells = [ordered]@{ main=@(40,42); rear_lower=@(36,32); rear_upper=@(36,32); garage_sf=576; porch_ft=@(12,10) }
    plans = [ordered]@{
        main = $main
        upper = $upper
        lower = $lower
    }
    stair_core_test = $stairCore
    upper_door_matrix = $upperDoors
    unplaced_program = @(
        @{id='M-06'; name='Main half bath'; reason='Owner selected the arrival / hall edge as the test zone and pantry-side search window as the first fit candidate; exact location, footprint and service route remain TBD.'},
        @{id='M-05'; name='Coat storage / mudroom fit'; reason='Current source block is an entry/hall reservation; storage and garage arrival are not resolved.'},
        @{id='S-01'; name='Secure storage'; reason='Discreet conditioned location remains TBD; omitted from geometric blocks.'},
        @{id='C-01'; name='Stair, landings and lift route'; reason='D now has a connected room-block/core comparison and a 4 x 4 ft upper floor extension; native landings, wall openings, headroom, structure and lift product still require review.'}
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
$planChecks['selected_m06_test_zone_is_arrival_hall_edge'] = ($study.selection.main_public_bath.test_zone -eq 'arrival / hall edge')
$planChecks['owner_selected_m06_first_fit_candidate_is_pantry_side_window'] = ($study.selection.main_public_bath.owner_selected_first_fit_candidate -eq 'east_of_core')
$planChecks['m06_location_footprint_and_service_route_remain_tbd'] = ($study.selection.main_public_bath.position -eq 'TBD' -and $study.selection.main_public_bath.footprint -eq 'TBD' -and $study.selection.main_public_bath.service_route -eq 'TBD')
$planChecks['documented_kitchen_fit_reference_checks_pass'] = [bool]($sourceChecks.checks.old_kitchen_12_ft_short_axis_fails_13_ft_counter_aisle_island_aisle_chain -and $sourceChecks.checks.new_kitchen_has_4_ft_work_aisle -and $sourceChecks.checks.new_kitchen_8_ft_island_has_end_clearances -and $sourceChecks.checks.kitchen_has_seat_allowance_plus_4_ft_route)
$placedRoomIds = @($main + $upper + $lower | Where-Object kind -eq 'room' | ForEach-Object id)
$planChecks['placed_rooms_have_program_allowance_review_record'] = (@($placedRoomIds | Where-Object { -not $programById.ContainsKey($_) }).Count -eq 0)
$programAreaReview = @($main + $upper + $lower | Where-Object kind -eq 'room' | ForEach-Object {
    $room = $_
    $reference = $programById[$room.id]
    $area = [Math]::Round($room.w*$room.d,2)
    $status = if ($null -eq $reference.minimum_sf) {'no numeric area reference'} elseif ($area -lt $reference.minimum_sf) {'below study reference'} elseif ($area -gt $reference.maximum_sf) {'above study reference'} else {'within study reference'}
    [ordered]@{level=if($room.id -like 'M-*'){'main'}elseif($room.id -like 'U-*'){'upper'}else{'lower'};id=$room.id;name=$room.name;area_sf=$area;minimum_sf=$reference.minimum_sf;maximum_sf=$reference.maximum_sf;status=$status;reference_text=$reference.source_text}
})
$mainRoomBlocks = @($main | Where-Object kind -eq 'room')
$coreRects = @(
    @{id='lower_to_main_run'; x=$coreXLower; y=$lowerRunStartY; w=4.0; d=$runLength},
    @{id='lower_to_main_main_landing'; x=$coreXLower; y=$lowerTopLandingY; w=4.0; d=4.0},
    @{id='main_to_upper_main_landing'; x=$coreXUpper; y=[double]$source.alternatives.B.core.stair_front_y; w=4.0; d=4.0},
    @{id='main_to_upper_run'; x=$coreXUpper; y=$upperRunStartY; w=4.0; d=$runLength},
    @{id='main_to_upper_top_landing'; x=$coreXUpper; y=$upperRunEndY; w=4.0; d=4.0},
    @{id='lift'; x=$liftX; y=34.0; w=8.0; d=8.0}
)
$coreRoomHits=[System.Collections.Generic.List[object]]::new()
foreach($coreRect in $coreRects){foreach($room in $mainRoomBlocks){$hit=Test-Overlap $coreRect $room;if($hit.overlap){$coreRoomHits.Add(@{core=$coreRect.id;room=$room.id;overlap_sf=$hit.area_sf})}}}
$dining=$main | Where-Object id -eq 'M-03'
$pantry=$main | Where-Object id -eq 'M-04'
$s1Landing=$stairCore.lower_to_main.main_landing_ft
$s2Landing=$stairCore.main_to_upper.main_landing_ft
$baseDining = $baseMain | Where-Object id -eq 'M-03'
$basePantry = $baseMain | Where-Object id -eq 'M-04'
$westSearchX=$baseDining.x+$baseDining.w
$westSearchY=$baseDining.y
$westSearchW=$s2Landing[0]-$westSearchX
$westSearchD=$s1Landing[1]-$westSearchY
$eastSearchX=$s2Landing[0]+$s2Landing[2]
$searchPantry = if ($isBathFirstAdjacencyCandidate) { $basePantry } else { $pantry }
$eastSearchY=$searchPantry.y
$eastSearchW=$searchPantry.x-$eastSearchX
$eastSearchD=$searchPantry.d
$westSearchStatus = if ($isBathFirstAdjacencyCandidate) { 'Blocked by relocated kitchen/pantry room blocks in the bath-first adjacency candidate; not an available M-06 search gap.' } else { 'Unassigned room-block gap only; not a bath footprint.' }
$eastSearchStatus = if ($isAdjacencyCandidate) { 'Blocked by proposed dining/pantry placement in the adjacency candidate; not an available M-06 search gap.' } else { 'Unassigned room-block gap only; not a bath footprint.' }
$m06SearchWindows=@(
    [ordered]@{id='west_of_core'; label='Dining-side search window'; x=$westSearchX; y=$westSearchY; w=$westSearchW; d=$westSearchD; gross_area_sf=[Math]::Round($westSearchW*$westSearchD,2); status=$westSearchStatus},
    [ordered]@{id='east_of_core'; label='Pantry-side search window'; x=$eastSearchX; y=$eastSearchY; w=$eastSearchW; d=$eastSearchD; gross_area_sf=[Math]::Round($eastSearchW*$eastSearchD,2); status=$eastSearchStatus}
)
$selectedM06Window = $m06SearchWindows | Where-Object id -eq $study.selection.main_public_bath.first_fit_candidate
$upperBathProjected = [ordered]@{x=[double]$jill.x; y=([double]$jill.y+[double]$planFrameOffsets.upper[1]); w=[double]$jill.w; d=[double]$jill.d}
$m06UpperBathProjection = Test-Overlap $selectedM06Window $upperBathProjected
$projectionX = [Math]::Max([double]$selectedM06Window.x,[double]$upperBathProjected.x)
$projectionY = [Math]::Max([double]$selectedM06Window.y,[double]$upperBathProjected.y)
$projectionW = if ($m06UpperBathProjection.overlap) { [Math]::Min(([double]$selectedM06Window.x+[double]$selectedM06Window.w),([double]$upperBathProjected.x+[double]$upperBathProjected.w))-$projectionX } else { 0 }
$projectionD = if ($m06UpperBathProjection.overlap) { [Math]::Min(([double]$selectedM06Window.y+[double]$selectedM06Window.d),([double]$upperBathProjected.y+[double]$upperBathProjected.d))-$projectionY } else { 0 }
$projectionX = if ($m06UpperBathProjection.overlap) { $projectionX } else { [double]$selectedM06Window.x }
$projectionY = if ($m06UpperBathProjection.overlap) { $projectionY } else { [double]$selectedM06Window.y }
$study.selection.main_public_bath['cross_level_comparison'] = [ordered]@{
    candidate_window_id=$selectedM06Window.id
    upper_room_id='U-06'
    projected_overlap_sf=$m06UpperBathProjection.area_sf
    projected_bounds_ft=@($projectionX,$projectionY,$projectionW,$projectionD)
    status='Plan projection only; no fixture wet wall, drain, vent or service route is established.'
}
$study.selection.main_public_bath['search_windows']=$m06SearchWindows
$m06SearchRoomHits=[System.Collections.Generic.List[object]]::new()
foreach($window in $m06SearchWindows){foreach($room in $mainRoomBlocks){$hit=Test-Overlap $window $room;if($hit.overlap){$m06SearchRoomHits.Add(@{window=$window.id;room=$room.id;overlap_sf=$hit.area_sf})}}}
$availableM06Windows = @($m06SearchWindows | Where-Object id -eq $study.selection.main_public_bath.first_fit_candidate)
$blockedM06Conflicts = @($m06SearchRoomHits | Where-Object { $study.selection.main_public_bath.blocked_candidate_ids -contains $_.window })
$study.selection.main_public_bath['blocked_candidate_conflicts'] = $blockedM06Conflicts
$study.selection.main_public_bath['candidate_layout_status'] = if($isAdjacencyCandidate){'Unapproved room-placement alternative; pantry-side B is blocked and dining-side A is the fallback search window.'}elseif($isBathFirstAdjacencyCandidate){'Unapproved room-placement alternative; pantry-side B remains clear; dining-side A is blocked.'}else{'Owner-selected room placement; pantry-side B remains the first search candidate.'}
$m06SearchCoreHits=[System.Collections.Generic.List[object]]::new()
foreach($window in $m06SearchWindows){foreach($coreRect in $coreRects){$hit=Test-Overlap $window $coreRect;if($hit.overlap){$m06SearchCoreHits.Add(@{window=$window.id;core=$coreRect.id;overlap_sf=$hit.area_sf})}}}
$m06SearchInside=@($m06SearchWindows | Where-Object { $_.x -lt 0 -or $_.y -lt 0 -or ($_.x+$_.w) -gt 40 -or ($_.y+$_.d) -gt 42 }).Count -eq 0
$planChecks['m06_search_windows_inside_main_shell'] = $m06SearchInside
$planChecks['m06_available_search_window_clear_of_placed_rooms'] = (@($m06SearchRoomHits | Where-Object { @($availableM06Windows.id) -contains $_.window }).Count -eq 0)
$planChecks['m06_search_windows_clear_of_stair_and_lift_comparison_blocks'] = ($m06SearchCoreHits.Count -eq 0)
$planChecks['m06_search_windows_are_not_placed_as_bath_geometry'] = (-not (@($main | Where-Object id -eq 'M-06').Count) -and $study.selection.main_public_bath.footprint -eq 'TBD')
$planChecks['m06_first_fit_candidate_is_defined_search_window'] = (@($m06SearchWindows | Where-Object id -eq $study.selection.main_public_bath.first_fit_candidate).Count -eq 1)
$planChecks['m06_first_fit_candidate_is_not_placed_room_geometry'] = (-not (@($main | Where-Object id -eq 'M-06').Count))
$m06FixtureFitTest = $null
if ($isBathFirstAdjacencyCandidate) {
    $windowB = $m06SearchWindows | Where-Object id -eq 'east_of_core'
    $vanityFixture = [ordered]@{x=[double]$windowB.x;y=([double]$windowB.y+[double]$windowB.d-(22.0/12.0));w=4.0;d=(22.0/12.0)}
    $vanityFaceClearance = [ordered]@{x=[double]$vanityFixture.x;y=([double]$vanityFixture.y-3.0);w=4.0;d=3.0}
    $toiletClearance = [ordered]@{x=([double]$windowB.x+4.0);y=[double]$vanityFaceClearance.y;w=2.5;d=(21.0/12.0)}
    $vanityInside = ($vanityFixture.x -ge $windowB.x -and $vanityFixture.y -ge $windowB.y -and ($vanityFixture.x+$vanityFixture.w) -le ($windowB.x+$windowB.w) -and ($vanityFixture.y+$vanityFixture.d) -le ($windowB.y+$windowB.d))
    $vanityClearInside = ($vanityFaceClearance.x -ge $windowB.x -and $vanityFaceClearance.y -ge $windowB.y -and ($vanityFaceClearance.x+$vanityFaceClearance.w) -le ($windowB.x+$windowB.w) -and ($vanityFaceClearance.y+$vanityFaceClearance.d) -le ($windowB.y+$windowB.d))
    $toiletClearInside = ($toiletClearance.x -ge $windowB.x -and $toiletClearance.y -ge $windowB.y -and ($toiletClearance.x+$toiletClearance.w) -le ($windowB.x+$windowB.w) -and ($toiletClearance.y+$toiletClearance.d) -le ($windowB.y+$windowB.d))
    $clearanceOverlap = Test-Overlap $vanityFaceClearance $toiletClearance
    $planChecks['m06_reference_vanity_and_36in_approach_fit_inside_B'] = ($vanityInside -and $vanityClearInside)
    $planChecks['m06_documented_toilet_clearance_fits_inside_B'] = $toiletClearInside
    $planChecks['m06_reference_fixture_clearances_do_not_overlap'] = -not $clearanceOverlap.overlap
    $m06FixtureFitTest = [ordered]@{
        status='Clearance-zone arrangement inside the unassigned B search window only; not a room or fixture-fit approval.'
        owner_selected_window='east_of_core'
        source='Architecture/Bathrooms_Specs.md §§3.2–3.4; full-bath fixture references only, not M-06 requirements.'
        vanity_fixture_ft=$vanityFixture
        vanity_front_clearance_ft=$vanityFaceClearance
        vanity_front_clearance_reference='36 in preferred; 30 in minimum is also documented.'
        toilet_clearance_ft=$toiletClearance
        toilet_clearance_reference='30 in clear zone, 15 in each side of centerline, and 21 in clear in front.'
        clearances_overlap=$clearanceOverlap.overlap
        omitted=@('M-06 room footprint and wall thickness','toilet body dimensions/product','lavatory/casework product','door, swing and approach','vent/plumbing route','M-06-specific clearance basis')
        owner_approval='Not selected; reference geometry only.'
    }
}
$expectedM06Projection = if($study.selection.main_public_bath.first_fit_candidate -eq 'east_of_core'){63.0}else{0.0}
$planChecks['m06_selected_window_vertical_projection_matches_derived_layout'] = ([Math]::Abs($m06UpperBathProjection.area_sf-$expectedM06Projection) -lt 0.001 -and $study.selection.main_public_bath.cross_level_comparison.status -like 'Plan projection only;*')
if ($isAdjacencyCandidate) {
    $planChecks['m06_b_candidate_conflict_is_explicit'] = (@($m06SearchRoomHits | Where-Object window -eq 'east_of_core').Count -gt 0 -and $study.selection.main_public_bath.first_fit_candidate -eq 'west_of_core')
}
if ($isBathFirstAdjacencyCandidate) {
    $planChecks['m06_owner_selected_B_window_remains_clear'] = (@($m06SearchRoomHits | Where-Object window -eq 'east_of_core').Count -eq 0 -and $study.selection.main_public_bath.first_fit_candidate -eq 'east_of_core')
    $planChecks['m06_alternate_A_conflict_is_explicit'] = (@($m06SearchRoomHits | Where-Object window -eq 'west_of_core').Count -gt 0 -and $study.selection.main_public_bath.blocked_candidate_ids -contains 'west_of_core')
}
$adjacencyReview = $null
if ($isAdjacencyCandidate -or $isBathFirstAdjacencyCandidate) {
    $living = $main | Where-Object id -eq 'M-01'
    $kitchen = $main | Where-Object id -eq 'M-02'
    $dining = $main | Where-Object id -eq 'M-03'
    $pantry = $main | Where-Object id -eq 'M-04'
    $entry = $main | Where-Object id -eq 'M-05'
    $livingIsLeft = [double]$living.x -le [double]$kitchen.x
    $livingKitchenGap = if($livingIsLeft){[Math]::Round([double]$kitchen.x-([double]$living.x+[double]$living.w),3)}else{[Math]::Round([double]$living.x-([double]$kitchen.x+[double]$kitchen.w),3)}
    $livingKitchenShared = [Math]::Min(($living.y+$living.d),($kitchen.y+$kitchen.d))-[Math]::Max($living.y,$kitchen.y)
    $halfWallLength = 8.0
    $clearOpening = [Math]::Round($livingKitchenShared-$halfWallLength,3)
    $kitchenDiningGap = [Math]::Round([double]$dining.y-([double]$kitchen.y+[double]$kitchen.d),3)
    $kitchenDiningShared = [Math]::Min(($kitchen.x+$kitchen.w),($dining.x+$dining.w))-[Math]::Max($kitchen.x,$dining.x)
    $kitchenPantryGap = [Math]::Round([double]$pantry.y-([double]$kitchen.y+[double]$kitchen.d),3)
    $kitchenPantryShared = [Math]::Min(($kitchen.x+$kitchen.w),($pantry.x+$pantry.w))-[Math]::Max($kitchen.x,$pantry.x)
    $entryIsLeft = [double]$entry.x -le [double]$living.x
    $entryLivingGap = if($entryIsLeft){[Math]::Round([double]$living.x-([double]$entry.x+[double]$entry.w),3)}else{[Math]::Round([double]$entry.x-([double]$living.x+[double]$living.w),3)}
    $entryLivingShared = [Math]::Min(($living.y+$living.d),($entry.y+$entry.d))-[Math]::Max($living.y,$entry.y)
    $m06BConflictSf = 0.0
    foreach($conflict in @($m06SearchRoomHits | Where-Object window -eq 'east_of_core')){$m06BConflictSf += [double]$conflict.overlap_sf}
    $m06BConflictSf = [Math]::Round($m06BConflictSf,2)
    $m06AConflictSf = 0.0
    foreach($conflict in @($m06SearchRoomHits | Where-Object window -eq 'west_of_core')){$m06AConflictSf += [double]$conflict.overlap_sf}
    $m06AConflictSf = [Math]::Round($m06AConflictSf,2)
    $candidateRoomAreaSum = 0.0
    foreach($room in $main){if($room.id -in @('M-01','M-02','M-03','M-04','M-05')){$candidateRoomAreaSum += [double]$room.w*[double]$room.d}}
    $blockedBWindow = $m06SearchWindows | Where-Object id -eq 'east_of_core'
    $blockedBUpperBathProjection = Test-Overlap $blockedBWindow $upperBathProjected
    $planChecks['candidate_halfwall_and_six_foot_clear_opening_fit_shared_edge'] = ($livingKitchenGap -eq 0.5 -and $livingKitchenShared -ge $halfWallLength+6.0)
    $planChecks['candidate_kitchen_and_dining_are_directly_adjacent'] = ($kitchenDiningGap -eq 0.5 -and $kitchenDiningShared -ge 8.0)
    $planChecks['candidate_pantry_edge_can_host_documented_door_reservation'] = ($kitchenPantryGap -eq 0.5 -and $kitchenPantryShared -ge 2.5)
    $planChecks['candidate_entry_hall_and_living_share_edge'] = ($entryLivingGap -eq 0.5 -and $entryLivingShared -ge 6.0)
    $planChecks['candidate_keeps_original_room_areas'] = ([Math]::Abs($candidateRoomAreaSum-763.0) -lt 0.001)
    $adjacencyReview = [ordered]@{
        status='Unapproved room-placement option; same room areas and documented test dimensions retained.'
        kitchen_to_living=[ordered]@{nominal_wall_gap_ft=$livingKitchenGap;shared_edge_ft=[Math]::Round($livingKitchenShared,3);documented_half_wall_ft=$halfWallLength;remaining_opening_ft=$clearOpening;minimum_opening_ft=6;wall_segment_location='TBD'}
        kitchen_to_dining=[ordered]@{nominal_wall_gap_ft=$kitchenDiningGap;shared_edge_ft=[Math]::Round($kitchenDiningShared,3);status='Direct plan adjacency candidate; actual opening/floor/porch interface not modeled.'}
        kitchen_to_pantry=[ordered]@{nominal_wall_gap_ft=$kitchenPantryGap;shared_edge_ft=[Math]::Round($kitchenPantryShared,3);documented_door_width_ft=2.5;door_swing='TBD'}
        entry_to_living=[ordered]@{nominal_wall_gap_ft=$entryLivingGap;shared_edge_ft=[Math]::Round($entryLivingShared,3);entry_side=if($isBathFirstAdjacencyCandidate){'East exterior wall; front orientation and approach unverified.'}else{'Front / hall edge; exterior approach unverified.'};entry_door='Not modeled.'}
        m06_owner_selected_B_conflict_sf=$m06BConflictSf
        m06_alternate_A_conflict_sf=$m06AConflictSf
        m06_B_vs_upper_U06_projection_sf=$blockedBUpperBathProjection.area_sf
        m06_A_status=if($m06AConflictSf -gt 0){"Blocked by candidate room rectangles ($m06AConflictSf sf overlap); no bath fit tested."}else{'Search gap is clear of candidate room/core rectangles; no bath fit, door or fixture clearance established.'}
        m06_B_status=if($m06BConflictSf -gt 0){"Blocked by candidate room rectangles ($m06BConflictSf sf overlap); no bath fit tested."}else{'Owner-selected search window remains clear of candidate room/core rectangles; no bath fit, door or fixture clearance established.'}
        owner_approval='Not selected; compare with the owner-selected D placement before replacing it.'
    }
}
$upperHall = $upper | Where-Object id -eq 'C-UPPER'
$planChecks['proposed_main_stair_and_lift_blocks_clear_placed_main_rooms'] = ($coreRoomHits.Count -eq 0)
$planChecks['upper_landing_reaches_rear_wing_edge'] = ([Math]::Abs(($stairCore.main_to_upper.upper_landing_ft[1]+$stairCore.main_to_upper.upper_landing_ft[3])-$upperWingStartY) -lt 0.000001)
$planChecks['upper_connector_aligns_with_upper_hall'] = ([Math]::Abs($stairCore.main_to_upper.upper_floor_extension_ft[0]-$upperHall.x) -lt 0.000001 -and [Math]::Abs($stairCore.main_to_upper.upper_floor_extension_ft[2]-$upperHall.w) -lt 0.000001)
$planChecks['lift_west_face_aligns_with_upper_core_hall'] = ([Math]::Abs($stairCore.lift.origin_ft[0]-($upperHall.x+$upperHall.w)) -lt 0.000001)
$planChecks['lower_stair_landing_and_run_are_edge_adjacent'] = ([Math]::Abs($stairCore.lower_to_main.lower_landing_ft[1]-($stairCore.lower_to_main.run_ft[1]+$stairCore.lower_to_main.run_ft[3])) -lt 0.000001)
$planChecks['lower_plan_landing_maps_to_rear_aligned_wing_edge'] = ([Math]::Abs(($stairCore.lower_to_main.lower_landing_local_ft[1]+$lowerWingOffsetY)-$stairCore.lower_to_main.lower_landing_ft[1]) -lt 0.000001 -and [Math]::Abs(($stairCore.lower_to_main.lower_landing_local_ft[1]+4)-32) -lt 0.000001)
$planChecks['upper_wing_frame_meets_upper_connector'] = ([Math]::Abs($planFrameOffsets.upper[1]+32-$stairCore.main_to_upper.upper_floor_extension_ft[1]) -lt 0.000001)
$planChecks['lower_wing_frame_meets_main_landing'] = ([Math]::Abs($planFrameOffsets.lower[1]+$stairCore.lower_to_main.lower_landing_local_ft[1]-$stairCore.lower_to_main.lower_landing_ft[1]) -lt 0.000001)
$planChecks['main_stair_landings_and_run_are_edge_adjacent'] = ([Math]::Abs(($stairCore.main_to_upper.main_landing_ft[1]+$stairCore.main_to_upper.main_landing_ft[3])-$stairCore.main_to_upper.run_ft[1]) -lt 0.000001 -and [Math]::Abs(($stairCore.main_to_upper.run_ft[1]+$stairCore.main_to_upper.run_ft[3])-$stairCore.main_to_upper.upper_landing_ft[1]) -lt 0.000001)
$planChecks['main_floor_profile_matches_two_stair_runs_and_lift_void'] = ([Math]::Abs($stairCore.main_floor_profile_sf-(40*42-2*4*$runLength-64)) -lt 0.001)
$planChecks['main_stair_openings_match_flight_reservations'] = ([Math]::Abs($stairCore.lower_to_main.main_floor_opening_ft[1]-$stairCore.lower_to_main.run_ft[1]) -lt 0.000001 -and [Math]::Abs($stairCore.lower_to_main.main_floor_opening_ft[3]-$runLength) -lt 0.000001 -and [Math]::Abs($stairCore.main_to_upper.main_floor_opening_ft[3]-$runLength) -lt 0.000001)
$planChecks['rear_edge_opening_intervals_have_two_ordered_endpoints'] = (@($stairCore.main_shell_rear_edge_openings | Where-Object {$_.x_interval_ft.Count -ne 2 -or $_.x_interval_ft[1] -le $_.x_interval_ft[0]}).Count -eq 0)
$planChecks['upper_floor_profile_includes_only_4x4_connector_extension'] = ([Math]::Abs($stairCore.upper_floor_profile_sf-1168) -lt 0.000001)

$findings = @(
    @{id='D-OPEN-01'; priority='P1'; status='open'; issue='D now has a connected plan-level stair comparison and 4 x 4 ft upper landing extension. Native Revit must verify stair runs, the main/rear shared-wall openings, clear landing space, floor edges, headroom and structure.'},
    @{id='D-OPEN-02'; priority='P1'; status='open'; issue='M-06 is a half bath by owner direction and the arrival/hall edge is selected as its test zone; exact position, footprint, fixtures and service route remain unresolved. Keep the room out of geometry and area totals until fit is supported.'},
    @{id='D-OPEN-03'; priority='P1'; status='open'; issue='Kitchen fit uses the existing 17 ft 4 in x 16 ft test block; room area and appliance-open clearances remain unapproved.'},
    @{id='D-OPEN-04'; priority='P2'; status='open'; issue='Technology block is moved outside the Jack-and-Jill footprint; confirm hall access, ventilation, equipment service and acoustic separation.'},
    @{id='D-OPEN-05'; priority='P2'; status='open'; issue='Entry storage, secure storage, garage transfer, site access, porch thresholds and the full accessible route remain unplaced or unverified.'},
    @{id='D-OPEN-06'; priority='P1'; status='open'; issue='The lift reservation shifts 4 in west to meet the upper core hall in plan; door side, landing maneuvering, pit, overrun, product fit and lower/upper stopping geometry remain unverified.'}
)
$checks = [ordered]@{
    status = if($isAdjacencyCandidate){'unapproved adjacency candidate; geometry checks only; owner selection required before replacement'}else{'schematic geometry checks only; unresolved design items remain'}
    layout_variant = $LayoutVariant
    checks = $planChecks
    measurements = [ordered]@{ lower_L02_vs_upper_U06_overlap_sf=$wetStack.area_sf; lower_L06_vs_upper_U06_overlap_sf=$techStack.area_sf; selected_M06_vs_U06_projected_overlap_sf=$m06UpperBathProjection.area_sf; placed_main_room_count=$mainCounts; lower_L02_net_sf=[Math]::Round($lowerFlex.w*$lowerFlex.d,2); selected_bath_area_sf=$null; comparison_stair_run_ft=$runLength; lift_shift_from_B_origin_in=4; main_floor_profile_sf=$stairCore.main_floor_profile_sf; upper_floor_with_connector_sf=$stairCore.upper_floor_profile_sf }
    adjacency_review = $adjacencyReview
    m06_fixture_clearance_study = $m06FixtureFitTest
    room_block_overlaps = @($overlaps)
    stair_core_room_block_overlaps = @($coreRoomHits)
    program_area_review = $programAreaReview
    findings = $findings
    exclusions = @('Door swings and clear openings','Furniture-complete route checks','Stair/landing/headroom/guard/floor-edge coordination','Lift product fit','Structure, foundation, roof, site and code','Detailed MEP and kitchen appliance-open tests','Native Revit house model and IFC export for this design iteration')
}

function Xml-Escape([string]$text) { [System.Security.SecurityElement]::Escape($text) }
function New-PlanSvg([string]$level,[object[]]$rooms,[double]$width,[double]$depth,[string[]]$notes) {
    $scale=10; $left=54; $top=64; $extraFront=if($level -eq 'upper'){4.0}else{0.0}; $canvasWidth=[Math]::Max(660,($width*$scale)+$left+310)
    $noteLineCount=0
    foreach($note in $notes){$noteLineCount += [Math]::Ceiling($note.Length/42)+1}
    $canvasHeight=(($depth+$extraFront)*$scale)+$top+75+($noteLineCount*14)
    $items=[System.Collections.Generic.List[string]]::new()
    $items.Add("<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$canvasWidth`" height=`"$canvasHeight`" viewBox=`"0 0 $canvasWidth $canvasHeight`">")
    $items.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:20px;font-weight:bold}.label{font-size:11px}.small{font-size:10px}.shell{fill:#fcfaf5;stroke:#4e463d;stroke-width:3}.room{fill:#eadfce;stroke:#716456;stroke-width:1.4}.circulation{fill:#f3eee5;stroke:#9a8d7d;stroke-width:1;stroke-dasharray:4 3}.island{fill:#dce7db;stroke:#667963;stroke-width:1.6;stroke-dasharray:6 3}.core{fill:#f4ddc9;fill-opacity:.75;stroke:#a65f2b;stroke-width:1.6;stroke-dasharray:5 3}.bath-search{fill:#e7e0f2;fill-opacity:.48;stroke:#74519a;stroke-width:2;stroke-dasharray:4 4}.bath-search-selected{fill:#f3e5bd;fill-opacity:.65;stroke:#9c6f1c;stroke-width:2.4;stroke-dasharray:4 4}.bath-search-blocked{fill:#d9665e;fill-opacity:.28;stroke:#a83732;stroke-width:2.4;stroke-dasharray:5 3}.crosslevel{fill:#8998c4;fill-opacity:.2;stroke:#44598d;stroke-width:2;stroke-dasharray:3 2}.header{font-size:12px;fill:#6b6257}</style>')
    $items.Add(('<text class="title" x="{0}" y="28">D - {1} plan - schematic room blocks</text>' -f $left,$level))
    $items.Add(('<text class="header" x="{0}" y="47">Local x right; rear at top - shell reservation only - no site orientation</text>' -f $left))
    $shellTop=$top+$extraFront*$scale
    $items.Add("<rect class=`"shell`" x=`"$left`" y=`"$shellTop`" width=`"$($width*$scale)`" height=`"$($depth*$scale)`" />")
    foreach ($room in $rooms) {
        $x=$left+$room.x*$scale; $y=$top+($depth+$extraFront-$room.y-$room.d)*$scale; $w=$room.w*$scale; $h=$room.d*$scale
        $class=if($room.kind -eq 'circulation'){'circulation'}else{'room'}
        $items.Add("<rect class=`"$class`" x=`"$([Math]::Round($x,2))`" y=`"$([Math]::Round($y,2))`" width=`"$([Math]::Round($w,2))`" height=`"$([Math]::Round($h,2))`" />")
        $lines=@($room.id,$room.name,"$([Math]::Round($room.w,2)) x $([Math]::Round($room.d,2)) ft")
        $lineY=$y+[Math]::Max(13,($h/2)-10)
        foreach ($line in $lines) { $items.Add("<text class=`"label`" x=`"$([Math]::Round($x+4,2))`" y=`"$([Math]::Round($lineY,2))`">$(Xml-Escape $line)</text>"); $lineY+=13 }
    }
    if ($level -eq 'main') {
        foreach($window in $study.selection.main_public_bath.search_windows){
            $zx=$left+$window.x*$scale; $zy=$top+($depth-$window.y-$window.d)*$scale; $zw=$window.w*$scale; $zh=$window.d*$scale
            $zoneClass=if($study.selection.main_public_bath.blocked_candidate_ids -contains $window.id){'bath-search-blocked'}elseif($window.id -eq $study.selection.main_public_bath.first_fit_candidate){'bath-search-selected'}else{'bath-search'}
            $zoneTag=if($study.selection.main_public_bath.blocked_candidate_ids -contains $window.id){'B blocked'}elseif($window.id -eq 'west_of_core'){'A'}else{'B'}
            $items.Add("<rect class=`"$zoneClass`" x=`"$([Math]::Round($zx,2))`" y=`"$([Math]::Round($zy,2))`" width=`"$([Math]::Round($zw,2))`" height=`"$([Math]::Round($zh,2))`" />")
            $items.Add(('<text class="label" x="{0}" y="{1}">M-06 {2}</text>' -f [Math]::Round($zx+4,2),[Math]::Round($zy+16,2),$zoneTag))
        }
        $projection=$study.selection.main_public_bath.cross_level_comparison.projected_bounds_ft
        if ($projection[2] -gt 0 -and $projection[3] -gt 0) {
            $px=$left+$projection[0]*$scale; $py=$top+($depth-$projection[1]-$projection[3])*$scale
            $pw=$projection[2]*$scale; $ph=$projection[3]*$scale
            $items.Add("<rect class=`"crosslevel`" x=`"$([Math]::Round($px,2))`" y=`"$([Math]::Round($py,2))`" width=`"$([Math]::Round($pw,2))`" height=`"$([Math]::Round($ph,2))`" />")
            $items.Add(('<text class="small" x="{0}" y="{1}">U-06 above: {2} sf</text>' -f [Math]::Round($px+4,2),[Math]::Round($py+35,2),$study.selection.main_public_bath.cross_level_comparison.projected_overlap_sf))
        }
    }
    if ($level -eq 'main') {
        $kitchen=$main | Where-Object id -eq 'M-02'
        $k=$study.selection.kitchen
        $ix=$left+($kitchen.x+$k.island_origin_local_ft[0])*$scale
        $iy=$top+($depth-$kitchen.y-$k.island_origin_local_ft[1]-$k.island_ft[1])*$scale
        $items.Add("<rect class=`"island`" x=`"$([Math]::Round($ix,2))`" y=`"$([Math]::Round($iy,2))`" width=`"$($k.island_ft[0]*$scale)`" height=`"$($k.island_ft[1]*$scale)`" />")
        $items.Add(('<text class="label" x="{0}" y="{1}">8 x 4 ft island test</text>' -f [Math]::Round($ix+4,2),[Math]::Round($iy+23,2)))
    }
    $coreBoxes=@()
    if($level -eq 'main'){
        $coreBoxes=@(
            @{id='S1 lower-to-main main landing'; rect=$stairCore.lower_to_main.main_landing_ft},
            @{id='S1 lower-to-main run'; rect=$stairCore.lower_to_main.main_floor_opening_ft},
            @{id='S2 main-to-upper landing'; rect=$stairCore.main_to_upper.main_landing_ft},
            @{id='S2 upper flight and opening'; rect=$stairCore.main_to_upper.main_floor_opening_ft},
            @{id='8 x 8 ft lift reservation'; rect=@($liftX,34,8,8)}
        )
    }elseif($level -eq 'lower'){
        $coreBoxes=@(@{id='S1 lower landing';rect=$stairCore.lower_to_main.lower_landing_local_ft})
    }elseif($level -eq 'upper'){
        $coreBoxes=@(@{id='S2 upper landing bridge';rect=@($coreXUpper,-4,4,4)})
    }
    foreach($box in $coreBoxes){
        $bx=$left+$box.rect[0]*$scale; $by=$top+($depth+$extraFront-$box.rect[1]-$box.rect[3])*$scale
        $items.Add("<rect class=`"core`" x=`"$([Math]::Round($bx,2))`" y=`"$([Math]::Round($by,2))`" width=`"$($box.rect[2]*$scale)`" height=`"$($box.rect[3]*$scale)`" />")
        $items.Add(('<text class="small" x="{0}" y="{1}">{2}</text>' -f [Math]::Round($bx+3,2),[Math]::Round($by+13,2),(Xml-Escape $box.id)))
    }
    $noteX=$left+$width*$scale+22; $noteY=$top+12
    foreach ($note in $notes) {
        for($offset=0;$offset -lt $note.Length;$offset+=42){$line=$note.Substring($offset,[Math]::Min(42,$note.Length-$offset));$items.Add("<text class=`"small`" x=`"$noteX`" y=`"$noteY`">$(Xml-Escape $line)</text>");$noteY+=14}
        $noteY+=8
    }
    $items.Add('</svg>')
    # Match the checked-in Windows UTF-8/BOM, CRLF SVG convention explicitly;
    # otherwise Windows PowerShell leaves embedded LF bytes untouched and
    # regenerating a plan dirties it solely through line endings.
    return ($items -join "`r`n")
}

New-Item -ItemType Directory -Path $target -Force | Out-Null
$jsonPath=Join-Path $target 'study.json'
$checksPathOut=Join-Path $target 'checks.json'
$study | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $jsonPath -Encoding utf8
$checks | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $checksPathOut -Encoding utf8
$csvRows=foreach($level in @('main','upper','lower')) { foreach($room in $study.plans[$level]) { [pscustomobject]@{level=$level;id=$room.id;name=$room.name;kind=$room.kind;width_ft=$room.w;depth_ft=$room.d;area_sf=[Math]::Round($room.w*$room.d,2)} } }
$csvRows | Export-Csv -LiteralPath (Join-Path $target 'room-area.csv') -NoTypeInformation -Encoding utf8
$programAreaReview | ForEach-Object { [pscustomobject]@{level=$_.level;id=$_.id;name=$_.name;area_sf=$_.area_sf;minimum_sf=$_.minimum_sf;maximum_sf=$_.maximum_sf;status=$_.status;reference_text=$_.reference_text} } | Export-Csv -LiteralPath (Join-Path $target 'program-area-review.csv') -NoTypeInformation -Encoding utf8
$m06PlanNote = if($isAdjacencyCandidate){'Owner-selected B conflicts in this unapproved layout; A is shown as a fallback search gap only.'}elseif($isBathFirstAdjacencyCandidate){'Owner-selected B remains clear; alternate A is blocked by room blocks in this unapproved layout.'}else{'M-06 B pantry-side search window is selected for the first fit test; A remains the dining-side alternative.'}
$notesByLevel=@{
    main=@('Main shell test: 40 x 42 ft.','S1/S2 and lift are comparison blocks; wall openings and native landings TBD.','M-06 test zone: arrival / hall edge selected; no footprint or service route assigned.',$m06PlanNote,'Dashed M-06 A/B windows are unassigned search extents, not bath footprints.','Kitchen block retains the prior fit-study size; not approved.')
    upper=@('Rear upper plate: 36 x 32 ft.','Dashed 4 x 4 ft connector joins S2 landing to shell edge.','Primary bath private to U-01; J&J serves U-03/U-04.','Native stair, wall opening, headroom and structure remain open.')
    lower=@("Rear lower plate: 36 x 32 ft. Lower L-02 is the A-strategy block.",'S1 lower landing touches the shared shell edge; opening offset is a native review item.',"L-06 moved outside upper U-06 projection; overlap = $($techStack.area_sf) sf.",'Secure storage is not located in this study.')
}
if($isAdjacencyCandidate){$notesByLevel.main += @('ADJACENCY CANDIDATE ONLY; M-06 B conflicts with relocated dining; A fallback is unassigned.','Kitchen/living edge fits 8 ft half-wall plus 7 ft open span by plan arithmetic; wall not placed.')}
if($isBathFirstAdjacencyCandidate){$notesByLevel.main += @('BATH-FIRST ADJACENCY CANDIDATE ONLY; owner-selected M-06 B search window remains clear; A is blocked by relocated kitchen/pantry.','Published full-bath vanity/WC clear-zone references fit inside B; this does not establish a bath boundary or fixture fit.','M-05 entry/hall moved to east wall; front orientation, exterior approach and porch connection are unverified.','Kitchen/living edge fits 8 ft half-wall plus 7 ft open span by plan arithmetic; wall not placed.')}
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
