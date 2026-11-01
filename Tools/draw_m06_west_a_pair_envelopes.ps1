param(
    [string]$ReportPath = (Join-Path $PSScriptRoot '../Architecture/M230_West_A_Toilet_Lavatory_Envelopes_2026-10-31/artifacts/m230-report.json'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M231_West_A_Pair_Envelope_Diagram_2026-10-31/artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$reportFull = (Resolve-Path -LiteralPath $ReportPath).Path
$reportHash = (Get-FileHash -LiteralPath $reportFull -Algorithm SHA256).Hash.ToLowerInvariant()
$expectedReportHash = '1859ced601e1982d41baee58a191f2766771729921fbcd8ac3a59dc590b0e686'
if ($reportHash -ne $expectedReportHash) { throw "M230 report hash mismatch: $reportHash" }
$report = Get-Content -LiteralPath $reportFull -Raw | ConvertFrom-Json
if ($report.schema -ne 'forever-home.m06-west-a-toilet-lavatory-pair-envelopes.v1' -or
    $report.west_a.remains_unassigned -ne $true -or
    $report.gross_containment_count -ne 16 -or
    $report.cases.Count -ne 16) {
    throw 'Expected the complete unassigned-A M230 comparison report.'
}
$tresham = @($report.cases | Where-Object { $_.sink_id -eq 'kohler-tresham-k-2844-4-0' -and $_.sink_rotation_deg -eq 0 })
$widest = @($report.cases | Where-Object { $_.sink_id -eq 'toto-clayton-lpt780' -and $_.sink_rotation_deg -eq 0 })
if ($tresham.Count -ne 1 -or $widest.Count -ne 1 -or
    $tresham[0].contained_in_gross_west_a -ne $true -or
    $widest[0].contained_in_gross_west_a -ne $true -or
    [double]$widest[0].remaining_gross_width_in -ne 3.5) {
    throw 'Expected the nominal Tresham example and the verified widest-envelope example.'
}

$scale = 5.0
$panelX = @(85.0, 650.0)
$panelY = 150.0
$panelW = [double]$report.west_a.gross_width_in * $scale
$panelH = [double]$report.west_a.gross_depth_in * $scale
$toiletW = [double]$report.toilet.plan_width_in * $scale
$toiletD = [double]$report.toilet.plan_projection_in * $scale
$wcCenterX = [double]$report.assumed_same_wall_screen.wc_centerline_to_side_boundary_in
$sinkCenterX = $wcCenterX + [double]$report.assumed_same_wall_screen.wc_centerline_to_adjacent_fixture_centerline_in
$frontStrip = [double]$report.assumed_same_wall_screen.front_clear_strip_in
$cases = @($tresham[0], $widest[0])
$panelTitles = @('Example: KOHLER Tresham K-2844-4-0', 'Widest screened body: TOTO Clayton LPT780')
$svg = New-Object System.Collections.Generic.List[string]
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1180" height="980" viewBox="0 0 1180 980">')
$svg.Add('<title>West A hypothetical same-wall M-06 fixture envelope comparison</title>')
$svg.Add('<desc>Two labeled rectangular envelope examples inside unassigned west A. Neither fixture pair is selected or installed. The front-depth screen is a planning proxy only.</desc>')
$svg.Add('<rect width="1180" height="980" fill="#fbfaf7"/>')
$svg.Add('<style>text{font-family:Segoe UI,Arial,sans-serif;fill:#262626}.title{font-size:25px;font-weight:700}.subtitle{font-size:14px}.paneltitle{font-size:16px;font-weight:700}.label{font-size:12px}.small{font-size:11px}.dimension{stroke:#4b5563;stroke-width:1.4;fill:none}.boundary{stroke:#1f2937;stroke-width:2;fill:#fff}.toilet{fill:#cfe8f3;stroke:#216b8c;stroke-width:2}.sink{fill:#e8d8bd;stroke:#805d32;stroke-width:2}.centerline{stroke:#6b7280;stroke-width:1;stroke-dasharray:5 4}.frontline{stroke:#b45309;stroke-width:1.5;stroke-dasharray:7 5}</style>')
$svg.Add('<text x="50" y="44" class="title">M-06 west A - same-wall envelope examples</text>')
$svg.Add('<text x="50" y="70" class="subtitle">62 x 137 in gross search window; candidate rectangles use the M230 assumptions. No room is assigned.</text>')

for ($i = 0; $i -lt $cases.Count; $i++) {
    $case = $cases[$i]
    $x = $panelX[$i]
    $y = $panelY
    $panelTitle = [string]$panelTitles[$i]
    $sinkW = [double]$case.sink_plan_body_width_along_shared_wall_in * $scale
    $sinkD = [double]$case.sink_plan_body_depth_from_shared_back_line_in * $scale
    $toiletX = $x + ($wcCenterX - ([double]$report.toilet.plan_width_in / 2.0)) * $scale
    $sinkX = $x + ($sinkCenterX - ([double]$case.sink_plan_body_width_along_shared_wall_in / 2.0)) * $scale
    $frontY = $y + ([Math]::Max([double]$report.toilet.plan_projection_in, [double]$case.sink_plan_body_depth_from_shared_back_line_in) + $frontStrip) * $scale
    $sinkLabel = if ($i -eq 0) { 'Tresham candidate' } else { 'Research candidate' }
    $svg.Add("<text x=`"$x`" y=`"112`" class=`"paneltitle`">$panelTitle - unselected</text>")
    $svg.Add("<text x=`"$x`" y=`"132`" class=`"small`">Sink plan envelope $([double]$case.sink_plan_body_width_along_shared_wall_in) x $([double]$case.sink_plan_body_depth_from_shared_back_line_in) in ($sinkLabel)</text>")
    $svg.Add("<rect x=`"$x`" y=`"$y`" width=`"$panelW`" height=`"$panelH`" class=`"boundary`"/>")
    $svg.Add("<line x1=`"$($x + $wcCenterX * $scale)`" y1=`"$y`" x2=`"$($x + $wcCenterX * $scale)`" y2=`"$($y + $panelH)`" class=`"centerline`"/>")
    $svg.Add("<line x1=`"$($x + $sinkCenterX * $scale)`" y1=`"$y`" x2=`"$($x + $sinkCenterX * $scale)`" y2=`"$($y + $panelH)`" class=`"centerline`"/>")
    $svg.Add("<rect x=`"$toiletX`" y=`"$y`" width=`"$toiletW`" height=`"$toiletD`" rx=`"5`" class=`"toilet`"/>")
    $svg.Add("<rect x=`"$sinkX`" y=`"$y`" width=`"$sinkW`" height=`"$sinkD`" rx=`"5`" class=`"sink`"/>")
    $svg.Add("<text x=`"$($toiletX + 5)`" y=`"$($y + 34)`" class=`"small`">610AA</text>")
    $svg.Add("<text x=`"$($sinkX + 5)`" y=`"$($y + 34)`" class=`"small`">Sink</text>")
    $svg.Add("<line x1=`"$x`" y1=`"$frontY`" x2=`"$($x + $panelW)`" y2=`"$frontY`" class=`"frontline`"/>")
    $svg.Add("<text x=`"$($x + 4)`" y=`"$($frontY - 6)`" class=`"small`">51.25 in body + front-strip depth screen</text>")
    $svg.Add("<line x1=`"$x`" y1=`"$($y + $panelH + 24)`" x2=`"$($x + $panelW)`" y2=`"$($y + $panelH + 24)`" class=`"dimension`"/>")
    $svg.Add("<text x=`"$($x + 130)`" y=`"$($y + $panelH + 43)`" class=`"label`">62 in gross width</text>")
    $remaining = [double]$case.remaining_gross_width_in
    $svg.Add("<text x=`"$x`" y=`"$($y + $panelH + 67)`" class=`"label`">Screen width used: $([double]$case.required_gross_width_in) in; gross remainder: $remaining in</text>")
}
$svg.Add('<text x="50" y="920" class="label">Illustrative rectangles only: shared back line; WC centerline 15 in from side; fixture centerlines 30 in apart; front strip 21 in.</text>')
$svg.Add('<text x="50" y="944" class="label">No walls/finishes, door, hall approach, privacy, faucet zone, services or installed clearances are shown. A and B remain unassigned.</text>')
$svg.Add('</svg>')
$svgText = $svg -join "`n"
try { [xml]$null = $svgText } catch { throw "Generated SVG is not well-formed XML: $($_.Exception.Message)" }

$checks = [ordered]@{
    schema = 'forever-home.m06-west-a-pair-envelope-diagram-checks.v1'
    result = 'pass'
    checks = [ordered]@{
        m230_report_hash_matches = ($reportHash -eq $expectedReportHash)
        report_is_expected_schema = ($report.schema -eq 'forever-home.m06-west-a-toilet-lavatory-pair-envelopes.v1')
        all_source_pair_cases_present = ($report.cases.Count -eq 16)
        west_a_remains_unassigned = ($report.west_a.remains_unassigned -eq $true)
        m06_is_not_assigned = ($report.owner_protection_scope -match 'B remains unassigned' -and $report.west_a.remains_unassigned -eq $true)
        unselected_tresham_example_found = ($tresham.Count -eq 1)
        widest_example_found_with_3_5_in_margin = ($widest.Count -eq 1 -and [double]$widest[0].remaining_gross_width_in -eq 3.5)
        svg_parses_as_xml = $true
    }
}
if (@($checks.checks.Values | Where-Object { $_ -ne $true }).Count -gt 0) { throw "M231 checks failed: $($checks | ConvertTo-Json -Depth 8)" }

$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) { [System.IO.Path]::GetFullPath($OutputDirectory) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory)) }
[System.IO.Directory]::CreateDirectory($resolvedOutput) | Out-Null
[System.IO.File]::WriteAllText((Join-Path $resolvedOutput 'm231-west-a-pair-envelopes.svg'), $svgText + "`n", [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $resolvedOutput 'm231-checks.json'), (ConvertTo-Json -InputObject $checks -Depth 12) + "`n", [System.Text.UTF8Encoding]::new($false))
Write-Output 'PASS: M231 8/8 diagram checks; SVG is well-formed XML. Examples are unselected; A/B remain unassigned.'
