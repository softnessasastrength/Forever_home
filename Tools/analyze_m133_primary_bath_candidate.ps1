param(
    [string]$OutputDirectory = 'Architecture/M133_Primary_Bath_Product_Fit_2026-10-30'
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$outputPath = [IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))
$repoPrefix = $repo.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if (-not $outputPath.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must resolve inside the repository root.' }

$selectedPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m132LayoutsPath = Join-Path $repo 'Architecture/M132_Primary_Bath_Interface_2026-10-30/m132-layouts.json'
$m132ReportPath = Join-Path $repo 'Architecture/M132_Primary_Bath_Interface_2026-10-30/m132-report.json'
$m132RoutePath = Join-Path $repo 'Architecture/M132_Primary_Bath_Interface_2026-10-30/m132-route-validation.json'
$sinkSourcePath = Join-Path $repo 'Research/M06_Sink_Gross_Body_Screen_2026-10-28.json'
$clearanceSourcePath = Join-Path $repo 'Research/M06_Clearance_Basis_2026-10-30.md'
$productSourcesPath = Join-Path $repo 'Research/Upper_Suite_Bath_Product_Options_2026-10-30.md'
$study = Get-Content -LiteralPath $selectedPath -Raw | ConvertFrom-Json
$m132LayoutDocument = Get-Content -LiteralPath $m132LayoutsPath -Raw | ConvertFrom-Json
$m132Layouts = @($m132LayoutDocument)
$m132Report = Get-Content -LiteralPath $m132ReportPath -Raw | ConvertFrom-Json
$m132Route = Get-Content -LiteralPath $m132RoutePath -Raw | ConvertFrom-Json
$sinkSource = Get-Content -LiteralPath $sinkSourcePath -Raw | ConvertFrom-Json
$m132CheckProperties = @($m132Report.checks.PSObject.Properties)
$m132PassedChecks = @($m132CheckProperties | Where-Object { $_.Value -eq $true }).Count

function Get-Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function New-Rect([string]$Id, [double]$X, [double]$Y, [double]$W, [double]$H) {
    [pscustomobject][ordered]@{ id = $Id; x_in = $X; y_in = $Y; width_in = $W; depth_in = $H }
}
function Test-Contains($Room, $Rect, [double]$Tol = 0.000001) {
    return ($Rect.x_in -ge -$Tol -and $Rect.y_in -ge -$Tol -and ($Rect.x_in + $Rect.width_in) -le ($Room.width_in + $Tol) -and ($Rect.y_in + $Rect.depth_in) -le ($Room.depth_in + $Tol))
}
function Get-Overlap($A, $B) {
    $x = [Math]::Min(($A.x_in + $A.width_in), ($B.x_in + $B.width_in)) - [Math]::Max($A.x_in, $B.x_in)
    $y = [Math]::Min(($A.y_in + $A.depth_in), ($B.y_in + $B.depth_in)) - [Math]::Max($A.y_in, $B.y_in)
    return ($x -gt 0.000001 -and $y -gt 0.000001)
}

$hashes = [ordered]@{
    selected_D = Get-Hash $selectedPath
    m132_layouts = Get-Hash $m132LayoutsPath
    m132_report = Get-Hash $m132ReportPath
    m132_route_validation = Get-Hash $m132RoutePath
    sink_sources = Get-Hash $sinkSourcePath
    clearance_source = Get-Hash $clearanceSourcePath
    product_sources = Get-Hash $productSourcesPath
    analyzer = Get-Hash $PSCommandPath
}

$wc = [ordered]@{ id = 'American Standard Champion PRO 610AA001.020 comparison envelope'; width_in = 19.0; depth_in = 30.25; basis = 'Selected product infographic envelope as recorded in M06 research; no exact Revit solids.' }
$sink = [ordered]@{ id = 'KOHLER Tresham K-2844-4-0'; width_in = 24.0; depth_in = 19.5; height_in = 34.625; basis = 'Manufacturer nominal overall dimensions; direct source RFA is quarantined but not yet inspected.' }
$tub = [ordered]@{ id = 'KOHLER Entity K-26108-LA-0'; width_in = 60.0; depth_in = 32.0; height_in = 15.75; basis = 'Manufacturer overall dimensions; nominal plan envelope only, no local RFA geometry.' }
$doorReservationIn = 42.0
$wallBandIn = 6.0
$wcFrontClearIn = 21.0
$wcSideCenterlineClearIn = 15.0
$wcSinkCenterlineAssumptionIn = 30.0
$candidates = [System.Collections.Generic.List[object]]::new()
$checks = [ordered]@{
    selected_D_matches_reviewed_source = ($hashes.selected_D -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb')
    exact_M132_layout_source_is_unchanged = ($hashes.m132_layouts -eq 'c9868179d98ab132209e34cacf44d05dbd732fc889801a02289d3411c6b00853')
    M132_analysis_and_route_reports_are_passed = ($m132PassedChecks -eq 25 -and $m132CheckProperties.Count -eq 25 -and $m132Route.checks.passed_count -eq 4 -and $m132Route.checks.check_count -eq 4)
    required_manufacturer_sources_are_recorded = ((Test-Path -LiteralPath $productSourcesPath) -and $sinkSource.schema -eq 'forever-home-m06-sink-gross-body-screen-v1')
    two_M130_upper_bath_blocks_are_tested = ($m132Layouts.Count -eq 2 -and @($m132Layouts.candidate_id | Sort-Object -Unique).Count -eq 2)
    all_nominal_fixture_bodies_fit_inside_each_room = $true
    fixture_bodies_do_not_overlap = $true
    WC_15in_side_clearance_screen_is_unobstructed = $true
    WC_21in_front_strip_screen_is_unobstructed = $true
    WC_to_sink_centerline_assumption_is_met = $true
    centered_nominal_door_reservation_fits_contact_band = $true
    fixture_bodies_do_not_cross_south_entry_wall_line = $true
}

foreach ($layout in $m132Layouts) {
    $room = [pscustomobject]@{ width_in = [double]$layout.u05.w * 12.0; depth_in = [double]$layout.u05.d * 12.0 }
    $wcRect = New-Rect 'toilet_body' 0.0 20.0 $wc.depth_in $wc.width_in
    $sinkRect = New-Rect 'lavatory_body' 0.0 47.5 $sink.depth_in $sink.width_in
    $tubX = ($room.width_in - $tub.width_in) / 2.0
    $tubY = $room.depth_in - $tub.depth_in
    $tubRect = New-Rect 'alcove_bath_body' $tubX $tubY $tub.width_in $tub.depth_in
    $doorX = ($room.width_in - $doorReservationIn) / 2.0
    $doorLine = [pscustomobject]@{ x_in = $doorX; width_in = $doorReservationIn; wall_band_in = $wallBandIn }
    $wcSideBand = New-Rect 'WC_side_clearance_screen' 0.0 (29.5 - $wcSideCenterlineClearIn) $wc.depth_in (2.0 * $wcSideCenterlineClearIn)
    $wcFrontBand = New-Rect 'WC_front_clearance_screen' ($wc.depth_in) 20.0 $wcFrontClearIn $wc.width_in
    $fixtures = @($wcRect, $sinkRect, $tubRect)
    if (@($fixtures | Where-Object { -not (Test-Contains $room $_) }).Count -gt 0) { $checks.all_nominal_fixture_bodies_fit_inside_each_room = $false }
    for ($i = 0; $i -lt $fixtures.Count; $i++) {
        for ($j = $i + 1; $j -lt $fixtures.Count; $j++) {
            if (Get-Overlap $fixtures[$i] $fixtures[$j]) { $checks.fixture_bodies_do_not_overlap = $false }
        }
    }
    foreach ($other in @($sinkRect, $tubRect)) {
        if (Get-Overlap $wcSideBand $other) { $checks.WC_15in_side_clearance_screen_is_unobstructed = $false }
        if (Get-Overlap $wcFrontBand $other) { $checks.WC_21in_front_strip_screen_is_unobstructed = $false }
    }
    $wcCenterlineAlongWall = $wcRect.y_in + ($wcRect.depth_in / 2.0)
    $sinkCenterlineAlongWall = $sinkRect.y_in + ($sinkRect.depth_in / 2.0)
    if ([Math]::Abs([Math]::Abs($sinkCenterlineAlongWall - $wcCenterlineAlongWall) - $wcSinkCenterlineAssumptionIn) -gt 0.000001) { $checks.WC_to_sink_centerline_assumption_is_met = $false }
    if ($room.width_in -lt $doorReservationIn -or $doorX -lt 0.0 -or ($doorX + $doorReservationIn) -gt $room.width_in) { $checks.centered_nominal_door_reservation_fits_contact_band = $false }
    foreach ($fixture in $fixtures) {
        if ([Math]::Abs($fixture.y_in) -le 0.000001) { $checks.fixture_bodies_do_not_cross_south_entry_wall_line = $false }
    }
    if ($wcSideBand.y_in -lt 0.0 -or ($wcSideBand.y_in + $wcSideBand.depth_in) -gt $room.depth_in) { $checks.WC_15in_side_clearance_screen_is_unobstructed = $false }
    if (-not (Test-Contains $room $wcFrontBand)) { $checks.WC_21in_front_strip_screen_is_unobstructed = $false }
    $candidates.Add([pscustomobject][ordered]@{
        candidate_id = "M133-$($layout.candidate_id)-TB01"
        source_layout_id = [string]$layout.candidate_id
        status = 'proposal-only; not selected'
        room = $room
        nominal_wc_body = $wcRect
        nominal_sink_body = $sinkRect
        nominal_tub_body = $tubRect
        WC_side_clearance_screen = $wcSideBand
        WC_front_clearance_screen = $wcFrontBand
        primary_bath_entry_reservation = [pscustomobject]@{ south_wall_x_in = $doorLine.x_in; width_in = $doorLine.width_in; source_width_ft = 3.5; source_interface_wall_band_ft = 0.5; door_geometry_modeled = $false }
        WC_centerline_from_south_in = $wcCenterlineAlongWall
        sink_centerline_from_south_in = $sinkCenterlineAlongWall
        WC_sink_centerline_spacing_in = [Math]::Abs($sinkCenterlineAlongWall - $wcCenterlineAlongWall)
        tub_access_area = 'not modeled'
        service_route = 'not assessed'
    })
}

$failed = @($checks.Keys | Where-Object { -not $checks[$_] })
$report = [ordered]@{
    schema = 'forever-home.m133-primary-bath-fit.v1'
    status = if ($failed.Count) { 'FAIL' } else { 'proposal-only pass; no design selected' }
    shell = [ordered]@{ width_ft = 38.333333; depth_ft = 40.0; selected = $false }
    source_hashes_sha256 = $hashes
    product_envelopes = [ordered]@{ toilet = $wc; sink = $sink; bathtub = $tub }
    assumptions_in = [ordered]@{ nominal_door_reservation = $doorReservationIn; M37_wall_band_convention = $wallBandIn; WC_front_clearance_screen = $wcFrontClearIn; WC_centerline_to_side_obstruction = $wcSideCenterlineClearIn; WC_to_sink_centerline_spacing = $wcSinkCenterlineAssumptionIn }
    candidates = @($candidates)
    checks = [ordered]@{ passed_count = $checks.Count - $failed.Count; check_count = $checks.Count; failed = $failed; results = $checks }
    limitations = @('Product nominal rectangles, not verified Revit solids.', 'The 0.5 ft interface is the existing M37 wall-band convention, not a modeled wall.', 'The 3.5 ft south-edge reservation is not an opening or door.', 'Door leaf, swing, approach and internal route are not modeled.', 'Tub access/use envelope is not modeled.', 'Rough-in, water/waste/vent routing and shared-service coordination are not checked.', 'The 15 in side and 21 in front screens come from preliminary project research; local adoption/applicability and finished-face measurement remain unconfirmed.', 'The 30 in WC-to-sink centerline spacing is an explicit study assumption, not a cited code requirement.', 'No headroom, structural, code-compliance, Revit-placement or IFC result is claimed.')
}

$null = New-Item -ItemType Directory -Path $outputPath -Force
$jsonPath = Join-Path $outputPath 'm133-report.json'
$checksPath = Join-Path $outputPath 'm133-checks.json'
$csvPath = Join-Path $outputPath 'm133-fixture-layouts.csv'
$svgPath = Join-Path $outputPath 'm133-plan.svg'
[IO.File]::WriteAllText($jsonPath, (ConvertTo-Json -InputObject $report -Depth 16) + "`n", [Text.UTF8Encoding]::new($false))
$checkDoc = [ordered]@{ schema = 'forever-home.m133-checks.v1'; status = if ($failed.Count) { 'FAIL' } else { 'PASS' }; passed_count = $checks.Count - $failed.Count; check_count = $checks.Count; failed = $failed; results = $checks; source_hashes_sha256 = $hashes }
[IO.File]::WriteAllText($checksPath, (ConvertTo-Json -InputObject $checkDoc -Depth 8) + "`n", [Text.UTF8Encoding]::new($false))
$csvRows = foreach ($candidate in $candidates) {
    [pscustomobject][ordered]@{ candidate_id = $candidate.candidate_id; source_layout_id = $candidate.source_layout_id; room_width_in = $candidate.room.width_in; room_depth_in = $candidate.room.depth_in; wc_x_in = $candidate.nominal_wc_body.x_in; wc_y_in = $candidate.nominal_wc_body.y_in; sink_x_in = $candidate.nominal_sink_body.x_in; sink_y_in = $candidate.nominal_sink_body.y_in; tub_x_in = $candidate.nominal_tub_body.x_in; tub_y_in = $candidate.nominal_tub_body.y_in; door_reservation_x_in = $candidate.primary_bath_entry_reservation.south_wall_x_in; door_reservation_width_in = $candidate.primary_bath_entry_reservation.width_in; WC_sink_CL_spacing_in = $candidate.WC_sink_centerline_spacing_in }
}
$csvRows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

$svgWidth = 800; $svgHeight = 500; $scale = 3.0; $panels = [System.Text.StringBuilder]::new()
for ($i = 0; $i -lt $candidates.Count; $i++) {
    $c = $candidates[$i]; $originX = 40 + ($i * 370); $originY = 72; $rw = $c.room.width_in * $scale; $rh = $c.room.depth_in * $scale
    $null = $panels.AppendLine("<text x=`"$originX`" y=`"28`" font-size=`"16`" font-family=`"Arial`">$($c.source_layout_id): $([Math]::Round($c.room.width_in,0)) x $([Math]::Round($c.room.depth_in,0)) in</text>")
    $null = $panels.AppendLine("<rect x=`"$originX`" y=`"$originY`" width=`"$rw`" height=`"$rh`" fill=`"#fffdf7`" stroke=`"#222`" stroke-width=`"2`"/>")
    $convert = { param($r) $x = $originX + ($r.x_in * $scale); $y = $originY + ($rh - (($r.y_in + $r.depth_in) * $scale)); $w = $r.width_in * $scale; $h = $r.depth_in * $scale; [pscustomobject]@{x=$x;y=$y;w=$w;h=$h} }
    $wcSvg = & $convert $c.nominal_wc_body; $sinkSvg = & $convert $c.nominal_sink_body; $tubSvg = & $convert $c.nominal_tub_body; $frontSvg = & $convert $c.WC_front_clearance_screen; $sideSvg = & $convert $c.WC_side_clearance_screen
    foreach ($rect in @(@{name='WC frontal 21 in screen';data=$frontSvg;fill='#f2d887';opacity='0.42';stroke='#9b7623';dash='stroke-dasharray="5 3"'},@{name='WC side 15 in CL band';data=$sideSvg;fill='#aad5e8';opacity='0.26';stroke='#397c97';dash='stroke-dasharray="3 3"'},@{name='Toilet nominal body';data=$wcSvg;fill='#ddd8cf';opacity='1';stroke='#403b34';dash=''},@{name='Tresham lavatory nominal body';data=$sinkSvg;fill='#c7e2cf';opacity='1';stroke='#28623c';dash=''},@{name='Entity bath nominal body';data=$tubSvg;fill='#cbd9f4';opacity='1';stroke='#304d83';dash=''})) {
        $d=$rect.data; $null=$panels.AppendLine("<rect x=`"$($d.x)`" y=`"$($d.y)`" width=`"$($d.w)`" height=`"$($d.h)`" fill=`"$($rect.fill)`" fill-opacity=`"$($rect.opacity)`" stroke=`"$($rect.stroke)`" stroke-width=`"1.5`" $($rect.dash)/><title>$($rect.name)</title>")
        $null=$panels.AppendLine("<text x=`"$($d.x + 3)`" y=`"$($d.y + 15)`" font-size=`"10`" font-family=`"Arial`">$($rect.name)</text>")
    }
    $doorX = $originX + ($c.primary_bath_entry_reservation.south_wall_x_in * $scale); $doorW = $c.primary_bath_entry_reservation.width_in * $scale; $doorY = $originY + $rh
    $null = $panels.AppendLine("<line x1=`"$doorX`" y1=`"$doorY`" x2=`"$($doorX+$doorW)`" y2=`"$doorY`" stroke=`"#a43b32`" stroke-width=`"5`"/><text x=`"$doorX`" y=`"$($doorY+18)`" font-size=`"10`" font-family=`"Arial`">3.5 ft nominal interface reservation</text>")
}
$svg = "<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$svgWidth`" height=`"$svgHeight`" viewBox=`"0 0 $svgWidth $svgHeight`"><rect width=`"100%`" height=`"100%`" fill=`"white`"/><text x=`"20`" y=`"482`" font-size=`"11`" font-family=`"Arial`">Proposal geometry from nominal product envelopes; door swing, tub use area, wall finish and service routes are not shown.</text>$($panels.ToString())</svg>"
[IO.File]::WriteAllText($svgPath, $svg, [Text.UTF8Encoding]::new($false))
if ($failed.Count) { throw "M133 failed: $($failed -join ', ')" }
Write-Output ("M133 PASS: {0}/{1} checks; {2} proposal layouts" -f ($checks.Count - $failed.Count), $checks.Count, $candidates.Count)
Write-Output "Proposal report: $jsonPath"
Write-Output 'No room/fixture selection, code, Revit, IFC, service or construction result is claimed.'
