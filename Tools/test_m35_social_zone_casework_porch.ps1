param(
    [string]$OutputDirectory = 'Architecture/M35_Social_Zone_Casework_Porch_2026-10-28'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$resolvedRoot = [System.IO.Path]::GetFullPath($root)
$target = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $OutputDirectory))
$prefix = $resolvedRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $target.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputDirectory must resolve inside the repository root.'
}

$selectedPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath = Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$specPath = Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
foreach ($path in @($selectedPath, $proposalPath, $specPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source missing: $path" }
}
$selected = Get-Content -Raw -LiteralPath $selectedPath | ConvertFrom-Json
$proposal = Get-Content -Raw -LiteralPath $proposalPath | ConvertFrom-Json
$spec = Get-Content -Raw -LiteralPath $specPath
$selectedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $selectedPath).Hash.ToLowerInvariant()
$proposalHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $proposalPath).Hash.ToLowerInvariant()
$specHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $specPath).Hash.ToLowerInvariant()
if ($proposal.source_selected_D_sha256 -ne $selectedHash) { throw 'Owner-follow-up study no longer fingerprints selected-D source.' }

function New-Rect([string]$name, [double]$x, [double]$y, [double]$w, [double]$d) {
    [ordered]@{ name=$name; x_ft=$x; y_ft=$y; width_ft=$w; depth_ft=$d }
}
function Get-Intersection($a, $b) {
    $dx = [Math]::Max(0.0, [Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft))
    $dy = [Math]::Max(0.0, [Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($a.y_ft,$b.y_ft))
    [ordered]@{ overlap=($dx -gt 0.000001 -and $dy -gt 0.000001); width_ft=$dx; depth_ft=$dy; area_sf=[Math]::Round(($dx*$dy),6) }
}
function Test-Contains($outer, $inner) {
    ($inner.x_ft -ge ($outer.x_ft-0.000001) -and $inner.y_ft -ge ($outer.y_ft-0.000001) -and
     ($inner.x_ft+$inner.width_ft) -le ($outer.x_ft+$outer.width_ft+0.000001) -and
     ($inner.y_ft+$inner.depth_ft) -le ($outer.y_ft+$outer.depth_ft+0.000001))
}
function Assert-SourcePhrase([string]$pattern, [string]$label) {
    if ($spec -notmatch $pattern) { throw "Kitchen/porch spec no longer contains the expected $label source value." }
}

Assert-SourcePhrase '14\x27-0\x22 × 12\x27-0\x22' '14×12 kitchen target'
Assert-SourcePhrase '11\x27-0\x22 × 10\x27-0\x22' '11×10 dining target'
Assert-SourcePhrase '24\x22 deep' '24-inch cabinet depth'
Assert-SourcePhrase '33\x22 wide double-bowl or \*\*33\x22\*\* farmhouse option|\*\*36\x22 wide\*\* double-bowl' 'sink base width'
Assert-SourcePhrase '\*\*24\x22 wide\*\*' 'dishwasher width'
Assert-SourcePhrase '\*\*36\x22 wide\*\* counter-depth preferred' 'refrigerator width'
Assert-SourcePhrase '\*\*30\x22 wide\*\*' 'range width'
Assert-SourcePhrase '\*\*12\x22 min\*\* clear counter each side' 'range landing width'
Assert-SourcePhrase '\*\*6\x22\*\*' 'half-wall thickness'
Assert-SourcePhrase '\*\*8\x27-0\x22\*\* \(adjust ±12\x22' 'half-wall length range'
Assert-SourcePhrase '\*\*5\x27-0\x22\*\* unit' 'porch French-door width'
Assert-SourcePhrase '\*\*3\x27-0\x22 × 6\x27-8\x22\*\*' 'porch exterior-door size'
Assert-SourcePhrase '\*\*36\x22 min\*\* chair pull-out; \*\*42\x22 preferred\*\*' 'table clearance values'
Assert-SourcePhrase '\*\*18\x22 × 20\x22\*\* seat' 'dining chair footprint'

$main = @($proposal.main_rooms)
$kitchen = $main | Where-Object id -eq 'M-02'
$dining = $main | Where-Object id -eq 'M-03'
$pantry = $main | Where-Object id -eq 'M-04'
$living = $main | Where-Object id -eq 'M-01'
$shell = New-Rect 'main shell test envelope' 0 0 ([double]$proposal.shell.width_ft) ([double]$proposal.shell.depth_ft)
$sourceKitchen = $selected.selection.kitchen
$islandW = [double]$sourceKitchen.island_ft[0]
$islandD = [double]$sourceKitchen.island_ft[1]
$islandX = [double]$kitchen.x_ft + [double]$sourceKitchen.island_origin_local_ft[0]
$islandYBaseline = [double]$kitchen.y_ft + [double]$sourceKitchen.island_origin_local_ft[1]
$islandShiftSouthFt = 0.5
$island = New-Rect 'M35 shifted appliance-free island candidate' $islandX ($islandYBaseline-$islandShiftSouthFt) $islandW $islandD
$clearance42Ft = 3.5
$islandClear = New-Rect 'island 42in clear-floor envelope' ($island.x_ft-$clearance42Ft) ($island.y_ft-$clearance42Ft) ($island.width_ft+2*$clearance42Ft) ($island.depth_ft+2*$clearance42Ft)
$cabinetDepthFt = 2.0
$cabinetRun = New-Rect '24in-deep south-wall cabinet run candidate' ([double]$kitchen.x_ft) ([double]$kitchen.y_ft) ([double]$kitchen.width_ft) $cabinetDepthFt
$halfWallLengthFt = 6.0
$halfWallThicknessFt = 0.5
$halfWall = New-Rect '6ft x 6in half-wall candidate' ([double]$living.x_ft+[double]$living.width_ft) ([double]$kitchen.y_ft) $halfWallThicknessFt $halfWallLengthFt

# Explicitly proposed width schedule from owner-spec component widths.
# The 36in sink base is the larger of the two listed options, not a selection.
$applianceSchedule = @(
    [ordered]@{id='refrigerator width reservation';x_ft=[double]$kitchen.x_ft;width_in=36;source='counter-depth preferred width; depth/opening unresolved'},
    [ordered]@{id='sink-base width reservation';x_ft=([double]$kitchen.x_ft+3.0);width_in=36;source='one listed 33in or 36in option; 36in used for stress screen'},
    [ordered]@{id='dishwasher width reservation';x_ft=([double]$kitchen.x_ft+6.0);width_in=24;source='listed 24in width; adjacent to sink'},
    [ordered]@{id='range plus two landing reservations';x_ft=([double]$kitchen.x_ft+8.0);width_in=(30+12+12);source='listed 30in range with 12in clear counter each side'}
)
$applianceTotalIn = [double]$applianceSchedule[0].width_in + [double]$applianceSchedule[1].width_in + [double]$applianceSchedule[2].width_in + [double]$applianceSchedule[3].width_in
$cabinetRunLengthIn = [double]$kitchen.width_ft*12
$applianceResidualIn = $cabinetRunLengthIn-[double]$applianceTotalIn

# Table candidate uses the source-derived 36in chair pull-back to M-03's rear edge.
$tableW = 5.0; $tableD = 3.0
$table = New-Rect '36x60in table candidate' ([double]$dining.x_ft+([double]$dining.width_ft-$tableW)/2.0) ([double]$dining.y_ft+[double]$dining.depth_ft-$tableD-3.0) $tableW $tableD
$table36 = New-Rect '36in table pull-back envelope' ($table.x_ft-3.0) ($table.y_ft-3.0) ($table.width_ft+6.0) ($table.depth_ft+6.0)
$table42 = New-Rect '42in preferred table envelope' ($table.x_ft-3.5) ($table.y_ft-3.5) ($table.width_ft+7.0) ($table.depth_ft+7.0)
$chairs = @(
    (New-Rect 'north chair (no east-side chair)' ($table.x_ft+($table.width_ft-1.5)/2.0) ($table.y_ft+$table.depth_ft) 1.5 (20.0/12.0)),
    (New-Rect 'south chair A' ($table.x_ft+0.5) ($table.y_ft-(20.0/12.0)) 1.5 (20.0/12.0)),
    (New-Rect 'south chair B' ($table.x_ft+2.5) ($table.y_ft-(20.0/12.0)) 1.5 (20.0/12.0)),
    (New-Rect 'west end chair' ($table.x_ft-(20.0/12.0)) ($table.y_ft+$table.depth_ft/2.0-0.75) (20.0/12.0) 1.5)
)
$diningEastRoute = New-Rect '36in table-to-French-door route; east side kept chair-free' ($table.x_ft+$table.width_ft) $table.y_ft ([double]$dining.x_ft+[double]$dining.width_ft-($table.x_ft+$table.width_ft)) $table.depth_ft

# Compare a porch attached north of dining with a side porch. The east-side
# candidate is intentionally allowed to project beyond the conditioned-shell test envelope.
$porchW=12.0; $porchD=10.0; $nominalWall=0.5
$porchNorth=New-Rect 'north porch candidate (12x10)' ([double]$dining.x_ft+([double]$dining.width_ft-$porchW)/2.0) ([double]$dining.y_ft+[double]$dining.depth_ft+$nominalWall) $porchW $porchD
$porchEast=New-Rect 'east porch candidate (12x10)' ([double]$dining.x_ft+[double]$dining.width_ft+$nominalWall) ([double]$dining.y_ft+$nominalWall) $porchW $porchD
$doorPairWidthFt=5.0
$frenchDoorY=$table.y_ft+$table.depth_ft/2.0-$doorPairWidthFt/2.0
$frenchDoor=New-Rect 'proposed 5ft French-door opening at east wall' ([double]$dining.x_ft+[double]$dining.width_ft) $frenchDoorY $nominalWall $doorPairWidthFt
$porchExteriorDoorWidthFt=3.0
$porchExteriorDoor=New-Rect 'proposed 3ft porch exterior door opening' ($porchEast.x_ft+$porchEast.width_ft) ($table.y_ft+$table.depth_ft/2.0-$porchExteriorDoorWidthFt/2.0) $nominalWall $porchExteriorDoorWidthFt
$porchRoute=New-Rect '36in through-porch route candidate' $porchEast.x_ft ($table.y_ft) $porchEast.width_ft $table.depth_ft
$porchXGap=[double]$porchEast.x_ft-([double]$dining.x_ft+[double]$dining.width_ft)
$porchYStartGap=[double]$porchEast.y_ft-[double]$dining.y_ft
$porchSharedY=[Math]::Min(([double]$porchEast.y_ft+$porchEast.depth_ft),([double]$dining.y_ft+$dining.depth_ft))-[Math]::Max([double]$porchEast.y_ft,[double]$dining.y_ft)
$islandClearExtension=[ordered]@{
    east_ft=[Math]::Max(0.0,([double]$islandClear.x_ft+[double]$islandClear.width_ft-([double]$kitchen.x_ft+[double]$kitchen.width_ft)))
    north_past_M02_ft=[Math]::Max(0.0,([double]$islandClear.y_ft+[double]$islandClear.depth_ft-([double]$kitchen.y_ft+[double]$kitchen.depth_ft)))
    into_M03_ft=[Math]::Max(0.0,([double]$islandClear.y_ft+[double]$islandClear.depth_ft-[double]$dining.y_ft))
}

$core=$selected.stair_core_test
$m06=New-Rect 'M06-B unassigned pantry-side search window' ([double]$proposal.M06.first_fit_window.x_ft) ([double]$proposal.M06.first_fit_window.y_ft) ([double]$proposal.M06.first_fit_window.width_ft) ([double]$proposal.M06.first_fit_window.depth_ft)
$northPorchM06=Get-Intersection $porchNorth $m06
$eastPorchM06=Get-Intersection $porchEast $m06
$islandTable36=Get-Intersection $islandClear $table36
$islandTable42=Get-Intersection $islandClear $table42
$eastPorchIsland=Get-Intersection $porchEast $islandClear
$northPorchIsland=Get-Intersection $porchNorth $islandClear
$porchPantryEast=Get-Intersection $porchEast $pantry
$eastPorchDining=Get-Intersection $porchEast $dining
$cabinetIslandBody=Get-Intersection $cabinetRun $island
$cabinetIslandClear=Get-Intersection $cabinetRun $islandClear
$halfWallIslandBody=Get-Intersection $halfWall $island
$halfWallIslandClear=Get-Intersection $halfWall $islandClear
$eastChairRouteHits=@(foreach($chair in $chairs){$hit=Get-Intersection $diningEastRoute $chair;if($hit.overlap){$chair.name}})
$porchRouteM06=Get-Intersection $porchRoute $m06
$core=$selected.stair_core_test
$coreRects=@(
    (New-Rect 'lower-to-main stair run' $core.lower_to_main.run_ft[0] $core.lower_to_main.run_ft[1] $core.lower_to_main.run_ft[2] $core.lower_to_main.run_ft[3]),
    (New-Rect 'lower-to-main main landing' $core.lower_to_main.main_landing_ft[0] $core.lower_to_main.main_landing_ft[1] 4 4),
    (New-Rect 'main-to-upper stair run' $core.main_to_upper.run_ft[0] $core.main_to_upper.run_ft[1] $core.main_to_upper.run_ft[2] $core.main_to_upper.run_ft[3]),
    (New-Rect 'main-to-upper main landing' $core.main_to_upper.main_landing_ft[0] $core.main_to_upper.main_landing_ft[1] 4 4),
    (New-Rect 'future lift reservation' $core.lift.origin_ft[0] $core.lift.origin_ft[1] $core.lift.width_ft $core.lift.depth_ft)
)
$coreHits=[System.Collections.Generic.List[object]]::new()
foreach($c in $coreRects){foreach($named in @([ordered]@{rect=$islandClear;name='island42'},[ordered]@{rect=$table42;name='table42'},[ordered]@{rect=$porchEast;name='eastPorch'},[ordered]@{rect=$porchRoute;name='porchRoute'})){$hit=Get-Intersection $named.rect $c;if($hit.overlap){$coreHits.Add([ordered]@{candidate=$named.name;core=$c.name;overlap_sf=$hit.area_sf})}}}
$baselineIsland=New-Rect 'M33 island body position' $islandX $islandYBaseline $islandW $islandD
$baselineIslandClear=New-Rect 'M33 island 42in envelope' ($baselineIsland.x_ft-$clearance42Ft) ($baselineIsland.y_ft-$clearance42Ft) ($baselineIsland.width_ft+2*$clearance42Ft) ($baselineIsland.depth_ft+2*$clearance42Ft)
$baselineIslandTable42=Get-Intersection $baselineIslandClear $table42
$applianceRects=@(foreach($item in $applianceSchedule){New-Rect $item.id ([double]$item.x_ft) ([double]$cabinetRun.y_ft) ([double]$item.width_in/12.0) $cabinetRun.depth_ft})
$applianceOutOfRun=@($applianceRects|Where-Object{-not(Test-Contains $cabinetRun $_)})
$frenchWithinWallOverlap=($frenchDoor.y_ft -ge ($porchEast.y_ft-0.000001) -and ($frenchDoor.y_ft+$frenchDoor.depth_ft) -le ([Math]::Min(($dining.y_ft+$dining.depth_ft),($porchEast.y_ft+$porchEast.depth_ft))+0.000001))
$frenchYContainsRoute=($diningEastRoute.y_ft -ge ($frenchDoor.y_ft-0.000001) -and ($diningEastRoute.y_ft+$diningEastRoute.depth_ft) -le ($frenchDoor.y_ft+$frenchDoor.depth_ft+0.000001))

$checks=[ordered]@{
    selected_D_fingerprint_matches_owner_followup=($proposal.source_selected_D_sha256 -eq $selectedHash)
    source_room_targets_remain_14x12_and_11x10=($kitchen.width_ft -eq 14 -and $kitchen.depth_ft -eq 12 -and $dining.width_ft -eq 11 -and $dining.depth_ft -eq 10)
    owner_appliance_widths_fit_14ft_linear_run=($applianceTotalIn -le $cabinetRunLengthIn -and $applianceResidualIn -eq 18)
    sink_and_dishwasher_are_adjacent_in_candidate_sequence=($applianceSchedule[1].width_in -eq 36 -and $applianceSchedule[2].width_in -eq 24)
    appliance_width_reservations_fit_candidate_perimeter_run=($applianceOutOfRun.Count -eq 0)
    island_body_remains_inside_kitchen_after_half_ft_south_shift=(Test-Contains $kitchen $island)
    island_42in_envelope_remains_inside_main_shell=(Test-Contains $shell $islandClear)
    south_cabinet_run_remains_inside_kitchen=(Test-Contains $kitchen $cabinetRun)
    island_42in_body_envelope_does_not_overlap_south_cabinet_run=(-not $cabinetIslandClear.overlap)
    south_cabinet_to_island_body_gap_is_exactly_42in=([Math]::Abs(([double]$island.y_ft-[double]$cabinetRun.y_ft-[double]$cabinetRun.depth_ft)-3.5) -lt 0.000001)
    proposed_halfwall_uses_6in_gap_and_leaves_6ft_opening=([Math]::Abs(($kitchen.depth_ft-$halfWallLengthFt)-6.0) -lt 0.000001 -and [Math]::Abs($halfWall.x_ft+$halfWall.width_ft-[double]$kitchen.x_ft) -lt 0.000001)
    halfwall_candidate_clears_island_42in_envelope=(-not $halfWallIslandClear.overlap)
    island_42in_and_table_36in_envelopes_do_not_overlap=(-not $islandTable36.overlap)
    island_42in_and_table_42in_preferred_envelopes_do_not_overlap=(-not $islandTable42.overlap)
    four_spec_sized_chairs_fit_dining_block=(@($chairs|Where-Object{-not(Test-Contains $dining $_)}).Count -eq 0)
    four_chair_bodies_do_not_overlap_table_or_each_other=($true)
    east_side_route_is_36in_and_free_of_candidate_chairs=([Math]::Abs($diningEastRoute.width_ft-3.0) -lt 0.000001 -and $eastChairRouteHits.Count -eq 0)
    east_porch_is_adjacent_to_dining_with_a_5ft_door_zone=([Math]::Abs($porchXGap-$nominalWall) -lt 0.000001 -and [Math]::Abs($porchYStartGap-$nominalWall) -lt 0.000001 -and [Math]::Abs($porchSharedY-9.5) -lt 0.000001 -and $doorPairWidthFt -eq 5.0)
    east_porch_candidate_does_not_overlap_unassigned_M06_B=(-not $eastPorchM06.overlap)
    east_porch_36in_route_clears_unassigned_M06_B=(-not $porchRouteM06.overlap)
    east_porch_candidate_clears_island_42in_envelope=(-not $eastPorchIsland.overlap)
    east_porch_5ft_door_fits_dining_porch_shared_wall_band=$frenchWithinWallOverlap
    east_porch_french_door_aligns_with_36in_table_route=$frenchYContainsRoute
    east_porch_exterior_door_is_3ft_and_centred_on_route=([Math]::Abs($porchExteriorDoor.depth_ft-3.0) -lt 0.000001 -and [Math]::Abs((($porchExteriorDoor.y_ft+$porchExteriorDoor.depth_ft/2.0)-($porchRoute.y_ft+$porchRoute.depth_ft/2.0))) -lt 0.000001)
    social_zone_and_porch_route_clear_comparison_core=($coreHits.Count -eq 0)
    M33_preferred_clearance_candidate_overlap_is_source_derived_5_166667sf=([Math]::Abs($baselineIslandTable42.area_sf-5.166667) -lt 0.000001)
    south_shift_removes_M33_preferred_envelope_overlap=([Math]::Abs($islandTable42.area_sf) -lt 0.000001)
    north_porch_conflict_is_quantified_against_M06_B=([Math]::Abs($northPorchM06.area_sf-70.0) -lt 0.000001)
    M06_B_remains_unassigned=($proposal.M06.status -like 'unassigned*' -and $proposal.M06.first_fit_window.status -like 'unassigned*')
}

# Explicitly validate chair disjointness; touching edges are allowed.
$chairBodyFailures=[System.Collections.Generic.List[string]]::new()
for($i=0;$i -lt $chairs.Count;$i++){
    if((Get-Intersection $table $chairs[$i]).overlap){$chairBodyFailures.Add("$($chairs[$i].name) overlaps table")}
    for($j=$i+1;$j -lt $chairs.Count;$j++){if((Get-Intersection $chairs[$i] $chairs[$j]).overlap){$chairBodyFailures.Add("$($chairs[$i].name) overlaps $($chairs[$j].name)")}}
}
$checks['four_chair_bodies_do_not_overlap_table_or_each_other']=($chairBodyFailures.Count -eq 0)
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
if($failed.Count -gt 0){throw "M35 checks failed: $($failed -join ', ')"}

$report=[ordered]@{
    schema='forever-home.m35-social-zone-casework-porch.v1'
    title='M35 — social-zone casework, occupied chairs and porch route screen'
    status='two explicit porch candidates; east-side candidate passes schematic room/casework/chair-route checks, pending product operation and owner/site review'
    source_fingerprints_sha256=[ordered]@{'selected_D_study.json'=$selectedHash;'owner_followup_study.json'=$proposalHash;'Kitchen_Dining_Porch_Specs.md'=$specHash}
    assumptions=@(
        'The source-defined kitchen and dining room blocks are clear-room targets, not verified wall faces.',
        'The south kitchen edge is a proposed 24in-deep continuous counter run; appliance products, depths, handles, door swings and exact clearances are not represented.',
        'The 36in sink-base option, appliance sequence, half-wall location, 6ft half-wall length and 0.5ft island shift are proposals chosen for this fit screen, not owner selections.',
        'The east porch is a site-unoriented proposal outside the current 40x42ft conditioned-shell test boundary; porch projection is allowed because X-01 is exterior/semi-conditioned.',
        'The nominal 0.5ft room-block separators represent wall allowance in source studies, not modeled wall construction.',
        'The east dining side is kept chair-free to test a distinct 36in route; French-door swing and exterior landing/grade are not modeled.'
    )
    room_blocks=[ordered]@{M02=$kitchen;M03=$dining;M04=$pantry;M01=$living;shell=$shell;M06_B=$m06}
    casework=[ordered]@{south_wall_run=$cabinetRun;depth_in=24;appliance_width_schedule=$applianceSchedule;combined_width_in=$applianceTotalIn;source_run_length_in=$cabinetRunLengthIn;unassigned_residual_width_in=$applianceResidualIn;sequence_note='Fridge, 36in sink base, adjacent 24in dishwasher, and 30in range with 12in counter landings each side; no product model or operating envelope.';halfwall=$halfWall;halfwall_source_length_range_in=@(72,108);halfwall_clear_opening_ft=6}
    island=[ordered]@{source_body=([ordered]@{x_ft=$islandX;y_ft=$islandYBaseline;width_ft=$islandW;depth_ft=$islandD});candidate_body=$island;south_shift_ft=$islandShiftSouthFt;clearance_42in=$islandClear;clearance_envelope_extension_beyond_M02=$islandClearExtension;south_run_to_body_clearance_ft=([double]$island.y_ft-[double]$cabinetRun.y_ft-[double]$cabinetRun.depth_ft);halfwall_to_body_clearance_ft=([double]$island.x_ft-([double]$halfWall.x_ft+[double]$halfWall.width_ft));source_split_and_stools='6ft/2ft surface split remains unresolved; two stools are required by source spec but stool envelopes and occupied positions are unmodeled.'}
    dining=[ordered]@{table=$table;table_clearance_36in=$table36;table_clearance_42in_preferred=$table42;chairs=$chairs;chair_free_side='east';porch_route_36in=$diningEastRoute;French_door_width_ft=$doorPairWidthFt;French_door_opening=$frenchDoor}
    porch_candidates=[ordered]@{
        north=[ordered]@{rectangle=$porchNorth;overlap_with_unassigned_M06_B_sf=$northPorchM06.area_sf;overlap_with_island_42in_sf=$northPorchIsland.area_sf;status='not preferred for this layout; occupies 70sf of the gross M-06 B search window'}
        east=[ordered]@{rectangle=$porchEast;French_door_opening=$frenchDoor;exterior_door_opening=$porchExteriorDoor;route_36in=$porchRoute;overlap_with_M06_B_sf=$eastPorchM06.area_sf;overlap_with_island_42in_sf=$eastPorchIsland.area_sf;overlap_with_M04_sf=$porchPantryEast.area_sf;projection_beyond_main_shell_east_ft=[Math]::Max(0.0,($porchEast.x_ft+$porchEast.width_ft-$shell.width_ft));status='schematic candidate; clear of B, island envelope and comparison core; extends beyond shell test boundary and meets M-04 at an edge without area overlap'}
    }
    measured_findings=[ordered]@{M33_current_candidate_island_to_table_42in_envelope_overlap_sf=$baselineIslandTable42.area_sf;M35_candidate_island_shift_south_ft=$islandShiftSouthFt;M35_island_42in_to_table_42in_envelopes_overlap_sf=$islandTable42.area_sf;M35_cabinet_appliance_width_sum_in=$applianceTotalIn;M35_cabinet_run_residual_width_in=$applianceResidualIn;east_porch_candidate_to_M06_B_overlap_sf=$eastPorchM06.area_sf;north_porch_candidate_to_M06_B_overlap_sf=$northPorchM06.area_sf;east_route_chair_collisions=$eastChairRouteHits;comparison_core_collisions=$coreHits.ToArray()}
    checks=$checks
    failures=$failed
    limitations=@(
        'This is a plan-envelope study, not a Revit model, IFC export, permit layout or selected design.',
        'The east porch location/orientation is not georeferenced; the 40x42ft main-shell test rectangle is not a surveyed building boundary.',
        'The 36in refrigerator width is source-derived, but depth, door opening, manufacturer installation clearances, sink plumbing, range cutout and hood duct route are not checked.',
        'The two island stools, occupied users, cabinetry door/drawer sweeps, refrigerator and dishwasher open envelopes, actual wall faces and French-door leaf/swing are not modeled.',
        'The 36in dining-to-porch route is a rectangle clear of the four candidate chairs, not a code or accessibility determination; porch grade, landing and outside route remain unknown.',
        'The east porch touches the proposed pantry block along an edge and projects 5.5ft beyond the main-shell test rectangle. Site, foundation, roof intersection and exterior circulation remain open.',
        'The island 42in clear-floor envelope extends 2.167ft east beyond M-02 and 0.5ft north into M-03; these portions must remain genuinely open and unobstructed.',
        'M-06 B remains an unassigned gross search window. The north porch candidate occupies 70sf of it; no M-06 geometry, fixture, door, service route or clearance has been assigned.',
        'No code, accessibility, structural, professional certification, permit or construction-readiness claim is made.'
    )
}

if(-not(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target|Out-Null}
$jsonPath=Join-Path $target 'fit.json'; $checksPath=Join-Path $target 'checks.json'; $svgPath=Join-Path $target 'social-zone-casework-porch.svg'
$report|ConvertTo-Json -Depth 28|Set-Content -LiteralPath $jsonPath -Encoding utf8
$checkReport=[ordered]@{count=$checks.Count;passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@();checks=$checks;source_fingerprints_sha256=$report.source_fingerprints_sha256;interpretation='Passing checks verify one measured schematic candidate and quantify a rejected north-porch/B conflict. They do not validate appliance operation, code or construction.'}
$checkReport|ConvertTo-Json -Depth 18|Set-Content -LiteralPath $checksPath -Encoding utf8

$scale=22.0;$sx=30.0;$sy=80.0
$svg=[System.Collections.Generic.List[string]]::new()
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1180" height="1120" viewBox="0 0 1180 1120">')
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:22px;font-weight:bold}.room{fill:#eadfce;stroke:#716456;stroke-width:2}.porch{fill:#dbe8ed;stroke:#557989;stroke-width:2}.cabinet{fill:#b49a77;stroke:#6b563c;stroke-width:2}.island{fill:#829d85;stroke:#3e6046;stroke-width:2}.clear{fill:#98b4a2;fill-opacity:.22;stroke:#52705e;stroke-width:2;stroke-dasharray:8 5}.tableclear{fill:#c3b4d8;fill-opacity:.18;stroke:#705b8c;stroke-width:2;stroke-dasharray:7 5}.chair{fill:#b29b7c;stroke:#6d5740;stroke-width:2}.wall{fill:#6e675d}.route{fill:#63a6be;fill-opacity:.22;stroke:#27728b;stroke-width:2;stroke-dasharray:5 4}.door{fill:#f5cf72;stroke:#8b6516;stroke-width:2}.b{fill:#eaa19a;fill-opacity:.55;stroke:#a7463c;stroke-width:2;stroke-dasharray:7 4}.label{font-size:12px}.note{font-size:13px;fill:#5b554d}.warn{font-size:13px;fill:#9b3d34}.shell{fill:#fcfaf5;stroke:#4e463d;stroke-width:3}</style>')
$svg.Add('<text class="title" x="30" y="32">M35 — casework, occupied-chair and porch-route candidate</text>')
$svg.Add('<text class="note" x="30" y="54">East porch is a proposal; shell edges are test bounds. Dashed regions show screened clearances.</text>')
$svg.Add(('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $sx,$sy,($shell.width_ft*$scale),($shell.depth_ft*$scale)))
foreach($r in @($living,$kitchen,$dining,$pantry)){$svg.Add(('<rect class="room" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">{6}</text>' -f ($sx+$r.x_ft*$scale),($sy+$r.y_ft*$scale),($r.width_ft*$scale),($r.depth_ft*$scale),($sx+$r.x_ft*$scale+5),($sy+$r.y_ft*$scale+17),$r.id))}
$svg.Add(('<rect class="porch" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">X-01 east porch candidate</text>' -f ($sx+$porchEast.x_ft*$scale),($sy+$porchEast.y_ft*$scale),($porchEast.width_ft*$scale),($porchEast.depth_ft*$scale),($sx+$porchEast.x_ft*$scale+5),($sy+$porchEast.y_ft*$scale+17)))
$svg.Add(('<rect class="cabinet" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">24in perimeter run: fridge / sink / DW / range+landings</text>' -f ($sx+$cabinetRun.x_ft*$scale),($sy+$cabinetRun.y_ft*$scale),($cabinetRun.width_ft*$scale),($cabinetRun.depth_ft*$scale),($sx+$cabinetRun.x_ft*$scale+5),($sy+$cabinetRun.y_ft*$scale+16)))
$svg.Add(('<rect class="wall" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">6ft half wall</text>' -f ($sx+$halfWall.x_ft*$scale),($sy+$halfWall.y_ft*$scale),($halfWall.width_ft*$scale),($halfWall.depth_ft*$scale),($sx+$halfWall.x_ft*$scale+4),($sy+$halfWall.y_ft*$scale+16)))
$svg.Add(('<rect class="clear" x="{0}" y="{1}" width="{2}" height="{3}"/><rect class="tableclear" x="{4}" y="{5}" width="{6}" height="{7}"/>' -f ($sx+$islandClear.x_ft*$scale),($sy+$islandClear.y_ft*$scale),($islandClear.width_ft*$scale),($islandClear.depth_ft*$scale),($sx+$table42.x_ft*$scale),($sy+$table42.y_ft*$scale),($table42.width_ft*$scale),($table42.depth_ft*$scale)))
$svg.Add(('<rect class="island" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">8×4 island, shifted 6in south</text>' -f ($sx+$island.x_ft*$scale),($sy+$island.y_ft*$scale),($island.width_ft*$scale),($island.depth_ft*$scale),($sx+$island.x_ft*$scale+5),($sy+$island.y_ft*$scale+17)))
$svg.Add(('<rect class="tableclear" x="{0}" y="{1}" width="{2}" height="{3}"/><rect class="chair" x="{4}" y="{5}" width="{6}" height="{7}"/><text class="label" x="{8}" y="{9}">36×60 table</text>' -f ($sx+$table.x_ft*$scale),($sy+$table.y_ft*$scale),($table.width_ft*$scale),($table.depth_ft*$scale),($sx+$table.x_ft*$scale),($sy+$table.y_ft*$scale),($table.width_ft*$scale),($table.depth_ft*$scale),($sx+$table.x_ft*$scale+5),($sy+$table.y_ft*$scale+17)))
foreach($c in $chairs){$svg.Add(('<rect class="chair" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f ($sx+$c.x_ft*$scale),($sy+$c.y_ft*$scale),($c.width_ft*$scale),($c.depth_ft*$scale)))}
$svg.Add(('<rect class="route" x="{0}" y="{1}" width="{2}" height="{3}"/><rect class="door" x="{4}" y="{5}" width="{6}" height="{7}"/><text class="label" x="{8}" y="{9}">5ft French pair</text>' -f ($sx+$diningEastRoute.x_ft*$scale),($sy+$diningEastRoute.y_ft*$scale),($diningEastRoute.width_ft*$scale),($diningEastRoute.depth_ft*$scale),($sx+$frenchDoor.x_ft*$scale),($sy+$frenchDoor.y_ft*$scale),([Math]::Max(3,($frenchDoor.width_ft*$scale))),($frenchDoor.depth_ft*$scale),($sx+$frenchDoor.x_ft*$scale+5),($sy+$frenchDoor.y_ft*$scale+16)))
$svg.Add(('<rect class="route" x="{0}" y="{1}" width="{2}" height="{3}"/><rect class="door" x="{4}" y="{5}" width="{6}" height="{7}"/><text class="label" x="{8}" y="{9}">3ft exterior door</text>' -f ($sx+$porchRoute.x_ft*$scale),($sy+$porchRoute.y_ft*$scale),($porchRoute.width_ft*$scale),($porchRoute.depth_ft*$scale),($sx+$porchExteriorDoor.x_ft*$scale),($sy+$porchExteriorDoor.y_ft*$scale),([Math]::Max(3,($porchExteriorDoor.width_ft*$scale))),($porchExteriorDoor.depth_ft*$scale),($sx+$porchExteriorDoor.x_ft*$scale+5),($sy+$porchExteriorDoor.y_ft*$scale+16)))
$svg.Add(('<rect class="b" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="warn" x="{4}" y="{5}">M-06 B stays unassigned</text>' -f ($sx+$m06.x_ft*$scale),($sy+$m06.y_ft*$scale),($m06.width_ft*$scale),($m06.depth_ft*$scale),($sx+$m06.x_ft*$scale+4),($sy+$m06.y_ft*$scale+17)))
$svg.Add('<text class="note" x="30" y="1010">North porch comparison overlaps B by 70sf. East porch clears B but projects outside the main-shell test boundary.</text>')
$svg.Add('<text class="note" x="30" y="1032">No Revit walls, appliance open envelopes, door swings, site orientation or code/structural checks are represented.</text>')
$svg.Add('</svg>')
$svg -join "`n" | Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest=[ordered]@{generator='Tools/test_m35_social_zone_casework_porch.ps1';source_fingerprints_sha256=$report.source_fingerprints_sha256;output_hashes_sha256=[ordered]@{fit_json=(Get-FileHash $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks_json=(Get-FileHash $checksPath -Algorithm SHA256).Hash.ToLowerInvariant();svg=(Get-FileHash $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
$manifest|ConvertTo-Json -Depth 10|Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output("M35 checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output("Appliance width: {0}in of {1}in run; residual {2}in. Island shift clears both 42in envelopes: {3}." -f $applianceTotalIn,$cabinetRunLengthIn,$applianceResidualIn,(-not $islandTable42.overlap))
Write-Output("North porch / M-06 B overlap: {0}sf. East porch / B overlap: {1}sf; east porch projects {2}ft beyond main-shell test boundary." -f $northPorchM06.area_sf,$eastPorchM06.area_sf,$report.porch_candidates.east.projection_beyond_main_shell_east_ft)
