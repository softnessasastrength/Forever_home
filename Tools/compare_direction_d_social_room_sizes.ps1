param(
    [string]$OutputDirectory = 'Architecture/Room_Size_Comparison_2026-10-27'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out = Join-Path $root $OutputDirectory
$sourcePath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$requirementsPath = Join-Path $root 'Requirements/Room_Program.md'
$specPath = Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
$gatesPath = Join-Path $root 'Architecture/Direction_D_Main_Floor_Design_Gates_2026-10-27.md'
$decisionPath = Join-Path $root 'Decisions/2026-10-27_Selected_Architectural_Direction_D.md'
$source = Get-Content -Raw -LiteralPath $sourcePath | ConvertFrom-Json
$requirementText = Get-Content -Raw -LiteralPath $requirementsPath
$specText = Get-Content -Raw -LiteralPath $specPath
$decisionText = Get-Content -Raw -LiteralPath $decisionPath
$dKitchen = $source.plans.main | Where-Object id -eq 'M-02'
$dDining = $source.plans.main | Where-Object id -eq 'M-03'

function Get-Sha256([string]$path) { (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant() }
function Get-ClearanceScreen([double]$width, [double]$depth) {
    # Published spec chain: 24-in perimeter base + 42-in aisle + 48-in island +
    # 42-in aisle + 6-in half wall. This is one cross-section, not a room layout.
    $chainIn = 24 + 42 + 48 + 42 + 6
    $preferredChainIn = 24 + 48 + 48 + 48 + 6
    $longAxis = [Math]::Max($width, $depth) * 12
    $shortAxis = [Math]::Min($width, $depth) * 12
    [ordered]@{
        documented_opposing_counter_island_half_wall_chain_in = $chainIn
        chain_ft = [Math]::Round($chainIn / 12, 3)
        documented_preferred_aisle_chain_in = $preferredChainIn
        preferred_chain_ft = [Math]::Round($preferredChainIn / 12, 3)
        long_axis_in = [Math]::Round($longAxis, 2)
        long_axis_remainder_in = [Math]::Round($longAxis - $chainIn, 2)
        long_axis_preferred_remainder_in = [Math]::Round($longAxis - $preferredChainIn, 2)
        short_axis_in = [Math]::Round($shortAxis, 2)
        short_axis_remainder_in = [Math]::Round($shortAxis - $chainIn, 2)
        short_axis_preferred_remainder_in = [Math]::Round($shortAxis - $preferredChainIn, 2)
        chain_fits_long_axis = ($longAxis -ge $chainIn)
        chain_fits_short_axis = ($shortAxis -ge $chainIn)
        preferred_chain_fits_long_axis = ($longAxis -ge $preferredChainIn)
        preferred_chain_fits_short_axis = ($shortAxis -ge $preferredChainIn)
        scope = 'Arithmetic envelope only; does not place/coordinate the half wall, appliance doors, stools, finishes, tolerance, or independent route.'
    }
}
function Get-DiningScreen([double]$width, [double]$depth) {
    # Table 36x60 in; published chair pull-out/path clearance is 36 in min,
    # 42 in preferred. Expand the table envelope by clearance on each side.
    $minW = 3 + 2 * 3
    $minD = 5 + 2 * 3
    $prefW = 3 + 2 * 3.5
    $prefD = 5 + 2 * 3.5
    $roomW = [Math]::Max($width, $depth)
    $roomD = [Math]::Min($width, $depth)
    [ordered]@{
        table_ft = @(3, 5)
        minimum_table_plus_chair_clearance_ft = @($minW, $minD)
        preferred_table_plus_chair_clearance_ft = @($prefW, $prefD)
        room_long_axis_ft = $roomW
        room_short_axis_ft = $roomD
        minimum_envelope_fits = (($roomW -ge $minD) -and ($roomD -ge $minW))
        preferred_envelope_fits = (($roomW -ge $prefD) -and ($roomD -ge $prefW))
        minimum_residual_ft = @([Math]::Round($roomW - $minD, 2), [Math]::Round($roomD - $minW, 2))
        preferred_residual_ft = @([Math]::Round($roomW - $prefD, 2), [Math]::Round($roomD - $prefW, 2))
        route_to_porch = 'Not verified: door location, leaf swing, table/chair occupancy and a connected 36-in path are not represented.'
    }
}
function New-Svg([object]$data) {
    $rows = @()
    $index = 0
    foreach ($scheme in $data.schemes) {
        $y = 62 + ($index * 184)
        $rows += "<text x='24' y='$y' class='title'>$($scheme.name)</text>"
        $rows += "<text x='24' y='$($y+24)' class='body'>Kitchen: $($scheme.kitchen.width_ft) × $($scheme.kitchen.depth_ft) ft ($($scheme.kitchen.area_sf) sf) | Dining: $($scheme.dining.width_ft) × $($scheme.dining.depth_ft) ft ($($scheme.dining.area_sf) sf)</text>"
        $k = $scheme.kitchen.clearance_screen
        $rows += "<text x='24' y='$($y+49)' class='body'>Kitchen chain: 13 ft 6 in minimum / 14 ft 6 in preferred; min-axis remainders $($k.long_axis_remainder_in) / $($k.short_axis_remainder_in) in.</text>"
        $d = $scheme.dining.clearance_screen
        $rows += "<text x='24' y='$($y+74)' class='body'>Dining table envelope: minimum $($d.minimum_table_plus_chair_clearance_ft[0]) × $($d.minimum_table_plus_chair_clearance_ft[1]) ft; preferred $($d.preferred_table_plus_chair_clearance_ft[0]) × $($d.preferred_table_plus_chair_clearance_ft[1]) ft.</text>"
        $rows += "<text x='24' y='$($y+99)' class='body'>Table envelope fits: minimum $($d.minimum_envelope_fits), preferred $($d.preferred_envelope_fits). 8-ft half wall + 6-ft opening needs a 14-ft edge.</text>"
        $rows += "<text x='24' y='$($y+119)' class='body'>Independent 36-in route to porch remains unverified.</text>"
        $rows += "<text x='24' y='$($y+142)' class='note'>Comparison only. Room dimensions do not establish clear interior dimensions or a selected layout.</text>"
        $index++
    }
    @"
<?xml version='1.0' encoding='UTF-8'?>
<svg xmlns='http://www.w3.org/2000/svg' width='1100' height='440' viewBox='0 0 1100 440'>
<style>text{font-family:Arial,sans-serif;fill:#29251f}.title{font-size:21px;font-weight:bold}.body{font-size:16px}.note{font-size:14px;fill:#7a4d34}rect{fill:#f5efe2;stroke:#785f45;stroke-width:2}</style>
<rect x='8' y='8' width='1084' height='424' rx='8'/>
$($rows -join "`n")
<text x='24' y='418' class='note'>No candidate selected. No walls, doors, floors, service routes or construction geometry are implied.</text>
</svg>
"@
}
function New-SchemePlanSvg([object]$scheme) {
    $scale = 28.0
    $k = $scheme.kitchen
    $d = $scheme.dining
    $kw = [Math]::Max($k.width_ft,$k.depth_ft); $kd = [Math]::Min($k.width_ft,$k.depth_ft)
    $dw = [Math]::Max($d.width_ft,$d.depth_ft); $dd = [Math]::Min($d.width_ft,$d.depth_ft)
    $x0=80.0; $y0=135.0; $roomW=$kw*$scale; $roomD=$kd*$scale
    $islandX=$x0+(($kw-4)/2)*$scale; $islandY=$y0+(($kd-8)/2)*$scale
    $tableOuterX=$x0+$roomW+150; $tableRoomY=$y0
    $tableScale=$scale; $minBoxW=11*$tableScale; $minBoxH=9*$tableScale; $prefBoxW=12*$tableScale; $prefBoxH=10*$tableScale
    $drawW=$dw*$scale; $drawD=$dd*$scale
    $preferredStyle=if($dw -ge 12 -and $dd -ge 10){'preferred fits'}else{'preferred envelope exceeds room'}
    $minStyle=if($dw -ge 11 -and $dd -ge 9){'minimum fits'}else{'minimum does not fit'}
    @"
<?xml version='1.0' encoding='UTF-8'?>
<svg xmlns='http://www.w3.org/2000/svg' width='1180' height='650' viewBox='0 0 1180 650'>
<style>text{font-family:Arial,sans-serif;fill:#29251f}.h{font-size:23px;font-weight:bold}.label{font-size:15px}.small{font-size:13px}.room{fill:#fffdf7;stroke:#423a31;stroke-width:3}.island{fill:#dbe4cf;stroke:#58654e;stroke-width:2}.min{fill:#edbda2;fill-opacity:.45;stroke:#a75c37;stroke-width:2;stroke-dasharray:7 5}.pref{fill:none;stroke:#45758a;stroke-width:2;stroke-dasharray:5 5}.warn{fill:#8e4f31;font-weight:bold}</style>
<text x='40' y='42' class='h'>$($scheme.name) — schematic envelope study</text>
<text x='40' y='70' class='label'>Rooms drawn as independent test rectangles; their relationship to each other and the porch is deliberately not positioned.</text>
<text x='$x0' y='105' class='h'>Kitchen $($k.width_ft) × $($k.depth_ft) ft</text>
<rect x='$x0' y='$y0' width='$roomW' height='$roomD' class='room'/>
<rect x='$islandX' y='$islandY' width='$(4*$scale)' height='$(8*$scale)' class='island'/>
<text x='$($islandX+8)' y='$($islandY+($scale*4))' class='small'>8 × 4 ft island</text>
<text x='$x0' y='$($y0+$roomD+25)' class='label'>Island shown as an illustrative placement. Main check: 13 ft 6 in chain = $([Math]::Round($kw,2)) ft long-axis remainder $([Math]::Round(($kw*12)-162,1)) in.</text>
<text x='$x0' y='$($y0+$roomD+48)' class='small'>Preferred 14 ft 6 in chain remainder: $([Math]::Round(($kw*12)-174,1)) in. 8-ft half wall + 6-ft clear opening needs a 14-ft shared edge.</text>
<text x='$tableOuterX' y='105' class='h'>Dining $($d.width_ft) × $($d.depth_ft) ft</text>
<rect x='$tableOuterX' y='$tableRoomY' width='$drawW' height='$drawD' class='room'/>
<rect x='$($tableOuterX+(($drawW-$minBoxW)/2))' y='$($tableRoomY+(($drawD-$minBoxH)/2))' width='$minBoxW' height='$minBoxH' class='min'/>
<rect x='$($tableOuterX+(($drawW-$prefBoxW)/2))' y='$($tableRoomY+(($drawD-$prefBoxH)/2))' width='$prefBoxW' height='$prefBoxH' class='pref'/>
<rect x='$($tableOuterX+(($drawW-(5*$tableScale))/2))' y='$($tableRoomY+(($drawD-(3*$tableScale))/2))' width='$(5*$tableScale)' height='$(3*$tableScale)' class='island'/>
<text x='$($tableOuterX+8)' y='$($tableRoomY+$drawD+25)' class='label'>36 × 60 in table; orange = min 9 × 11 ft envelope ($minStyle); blue dash = preferred 10 × 12 ft ($preferredStyle).</text>
<text x='$($tableOuterX+8)' y='$($tableRoomY+$drawD+48)' class='small'>Centered furniture is a test position, not a selection. Independent 36-in porch route is unverified.</text>
<text x='40' y='610' class='warn'>COMPARISON ONLY — no room-size decision, adjacency, porch-door location, walls, openings, floors or buildable layout is implied.</text>
</svg>
"@
}

$schemes = @(
    [ordered]@{ id='selected_d_test_blocks'; name='Current selected-D test-block sizes'; kitchen=[ordered]@{ width_ft=[Math]::Round([double]$dKitchen.w,3); depth_ft=[Math]::Round([double]$dKitchen.d,3); area_sf=[Math]::Round(([double]$dKitchen.w * [double]$dKitchen.d),2) }; dining=[ordered]@{ width_ft=[Math]::Round([double]$dDining.w,3); depth_ft=[Math]::Round([double]$dDining.d,3); area_sf=[Math]::Round(([double]$dDining.w * [double]$dDining.d),2) } },
    [ordered]@{ id='older_documented_targets'; name='Older DD-012 / kitchen-dining target sizes'; kitchen=[ordered]@{ width_ft=14; depth_ft=12; area_sf=168 }; dining=[ordered]@{ width_ft=11; depth_ft=10; area_sf=110 } }
)
foreach ($scheme in $schemes) {
    $scheme.kitchen.clearance_screen = Get-ClearanceScreen $scheme.kitchen.width_ft $scheme.kitchen.depth_ft
    $scheme.dining.clearance_screen = Get-DiningScreen $scheme.dining.width_ft $scheme.dining.depth_ft
}
$data = [ordered]@{
    schema = 'forever-home-room-size-comparison-v1'
    title = 'Direction D kitchen and dining room-size comparison'
    status = 'comparison only; neither room-size scheme is newly selected or adopted'
    generated_utc = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
    source_fingerprints_sha256 = [ordered]@{
        'Architecture/Selected_Design_Iteration_2026-10-27/study.json' = Get-Sha256 $sourcePath
        'Requirements/Room_Program.md' = Get-Sha256 $requirementsPath
        'Architecture/Kitchen_Dining_Porch_Specs.md' = Get-Sha256 $specPath
        'Architecture/Direction_D_Main_Floor_Design_Gates_2026-10-27.md' = Get-Sha256 $gatesPath
        'Decisions/2026-10-27_Selected_Architectural_Direction_D.md' = Get-Sha256 $decisionPath
    }
    inputs = [ordered]@{
        island_ft = @(8,4)
        perimeter_base_depth_in = 24
        minimum_aisle_in = 42
        preferred_aisle_in = 48
        half_wall_length_ft = 8
        half_wall_thickness_in = 6
        dining_table_in = @(36,60)
        chair_pullout_min_in = 36
        chair_clearance_preferred_in = 42
        porch_path_min_in = 36
    }
    schemes = $schemes
    findings = @(
        'D dimensions are existing schematic room blocks, not approved clear interior sizes.',
        'Older dimensions are documented targets; the selected-D decision did not reconcile or supersede them explicitly.',
        'The 13 ft 6 in kitchen chain is a one-axis arithmetic screen from the older spec and D design-gate brief.',
        'Table-and-chair envelopes screen a centered table with clearance on each side; furniture position, hutch, doors and actual path are not modeled.',
        'The documented 8 ft half-wall length, 6 in thickness and 6 ft opening relationship have no assigned location/orientation; only their aggregate edge requirement can be compared.',
        'No house geometry, walls, doors, floors, appliances, plumbing, site orientation or structural specification is authored by this comparison.'
    )
}
foreach ($scheme in $schemes) {
    $scheme.kitchen.half_wall_edge_screen = [ordered]@{
        documented_half_wall_length_ft = 8
        documented_minimum_opening_ft = 6
        required_contiguous_edge_ft = 14
        room_long_axis_ft = [Math]::Max($scheme.kitchen.width_ft, $scheme.kitchen.depth_ft)
        edge_length_arithmetic_fits = ([Math]::Max($scheme.kitchen.width_ft, $scheme.kitchen.depth_ft) -ge 14)
        caveat = 'Only arithmetic along a potential shared edge; no living-room adjacency, wall position, bearing, finish or opening is established.'
    }
}
New-Item -ItemType Directory -Force -Path $out | Out-Null
$json = $data | ConvertTo-Json -Depth 12
Set-Content -LiteralPath (Join-Path $out 'comparison.json') -Value $json -Encoding UTF8
Set-Content -LiteralPath (Join-Path $out 'comparison.svg') -Value (New-Svg $data) -Encoding UTF8
Set-Content -LiteralPath (Join-Path $out 'selected-d-test-block-plan.svg') -Value (New-SchemePlanSvg $schemes[0]) -Encoding UTF8
Set-Content -LiteralPath (Join-Path $out 'older-target-plan.svg') -Value (New-SchemePlanSvg $schemes[1]) -Encoding UTF8

$checks = @(
    @{ id='source_room_dims'; pass=([Math]::Abs($schemes[0].kitchen.width_ft - 17.3333333333) -lt 0.001 -and [Math]::Abs($schemes[0].dining.depth_ft - 14) -lt 0.001) },
    @{ id='legacy_room_dims'; pass=($schemes[1].kitchen.area_sf -eq 168 -and $schemes[1].dining.area_sf -eq 110) },
    @{ id='documented_inputs_present'; pass=($specText -match '168.*14.*12' -and $specText -match '110.*11.*10' -and $specText -match '42"? min' -and $specText -match '48"? preferred' -and $specText.Contains('8''-0"') -and $requirementText -match '150–185' -and $requirementText -match '90–120' -and $decisionText -match '8 x 4 ft') },
    @{ id='chain_math'; pass=($schemes[0].kitchen.clearance_screen.documented_opposing_counter_island_half_wall_chain_in -eq 162 -and $schemes[0].kitchen.clearance_screen.documented_preferred_aisle_chain_in -eq 174 -and $schemes[1].kitchen.clearance_screen.short_axis_remainder_in -eq -18 -and $schemes[1].kitchen.clearance_screen.long_axis_remainder_in -eq 6 -and $schemes[1].kitchen.clearance_screen.long_axis_preferred_remainder_in -eq -6) },
    @{ id='half_wall_span'; pass=($schemes[1].kitchen.half_wall_edge_screen.required_contiguous_edge_ft -eq 14 -and $schemes[1].kitchen.half_wall_edge_screen.edge_length_arithmetic_fits) },
    @{ id='dining_envelopes'; pass=($schemes[1].dining.clearance_screen.minimum_envelope_fits -and -not $schemes[1].dining.clearance_screen.preferred_envelope_fits -and $schemes[0].dining.clearance_screen.preferred_envelope_fits) },
    @{ id='porch_route_not_overclaimed'; pass=($schemes[1].dining.clearance_screen.route_to_porch -like 'Not verified:*') },
    @{ id='no_baseline_write'; pass=((Get-Sha256 $sourcePath) -eq $data.source_fingerprints_sha256['Architecture/Selected_Design_Iteration_2026-10-27/study.json']) }
)
$checkDoc = [ordered]@{ status=if (@($checks | Where-Object { -not $_.pass }).Count -eq 0) {'pass'} else {'fail'}; passed=@($checks | Where-Object pass).Count; total=$checks.Count; checks=$checks; scope='Source/provenance and documented arithmetic screens only; no architectural fit approval.' }
Set-Content -LiteralPath (Join-Path $out 'checks.json') -Value ($checkDoc | ConvertTo-Json -Depth 6) -Encoding UTF8
if ($checkDoc.status -ne 'pass') { throw 'Room-size comparison checks failed.' }
Write-Output "Room-size comparison: $($checkDoc.passed)/$($checkDoc.total) checks passed."
Write-Output "Output: $OutputDirectory"
