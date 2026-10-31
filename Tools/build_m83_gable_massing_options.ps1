param(
    [string]$OutputDirectory = 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$repo = [System.IO.Path]::GetFullPath($root)
$target = [System.IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))
$prefix = $repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $target.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'OutputDirectory must resolve inside the repository root.'
}

$m78Dir = Join-Path $repo 'Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29'
$m78Path = Join-Path $m78Dir 'search.json'
$m78ManifestPath = Join-Path $m78Dir 'manifest.json'
$selectionPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m38Path = Join-Path $repo 'Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/pitch-options.json'
$m38ManifestPath = Join-Path $repo 'Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28/manifest.json'
$researchPath = Join-Path $repo 'Research/Connecticut_Roof_Code_Research_2026-10-28.md'
foreach ($path in @($m78Path, $m78ManifestPath, $selectionPath, $m38Path, $m38ManifestPath, $researchPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required source missing: $path" }
}

$m78 = Get-Content -LiteralPath $m78Path -Raw | ConvertFrom-Json
$m78Manifest = Get-Content -LiteralPath $m78ManifestPath -Raw | ConvertFrom-Json
$selection = Get-Content -LiteralPath $selectionPath -Raw | ConvertFrom-Json
$m38 = Get-Content -LiteralPath $m38Path -Raw | ConvertFrom-Json
$m38Manifest = Get-Content -LiteralPath $m38ManifestPath -Raw | ConvertFrom-Json
$research = Get-Content -LiteralPath $researchPath -Raw
$hashes = [ordered]@{
    m78_search = (Get-FileHash -LiteralPath $m78Path -Algorithm SHA256).Hash.ToLowerInvariant()
    m78_manifest = (Get-FileHash -LiteralPath $m78ManifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
    selected_d_study = (Get-FileHash -LiteralPath $selectionPath -Algorithm SHA256).Hash.ToLowerInvariant()
    m38_pitch_options = (Get-FileHash -LiteralPath $m38Path -Algorithm SHA256).Hash.ToLowerInvariant()
    m38_manifest = (Get-FileHash -LiteralPath $m38ManifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
    Connecticut_roof_research = (Get-FileHash -LiteralPath $researchPath -Algorithm SHA256).Hash.ToLowerInvariant()
}

$coordinateBasis = $m78.coordinate_basis
$width = [double]$coordinateBasis.width_ft
$depth = [double]$coordinateBasis.depth_ft
$tolerance = 0.000001
if ($m78.schema -ne 'forever-home.m37-upper-suite-pack-route.v2') { throw 'Unexpected M78 search schema.' }
if ($m78Manifest.output_hashes_sha256.search -ne $hashes.m78_search) { throw 'M78 search does not match its archive manifest.' }
if ($m78Manifest.source_fingerprints_sha256.'selected_D_study.json' -ne $hashes.selected_d_study) { throw 'M78 manifest does not match the current selected-D source.' }
if ($m78Manifest.search_parameters.shell_width_override_ft -ne $width -or $m78Manifest.search_parameters.shell_depth_override_ft -ne $depth) { throw 'M78 shell values do not match its archived search parameters.' }
if ([Math]::Abs($width - 38.333333) -gt $tolerance -or [Math]::Abs($depth - 40.0) -gt $tolerance) { throw 'M83 only accepts the documented hypothetical 38.333333 x 40 ft shell.' }
if ($m38.schema -ne 'forever-home.m38-steep-gable-pitch-screen.v1' -or $m38Manifest.output_hashes_sha256.pitch_options -ne $hashes.m38_pitch_options) { throw 'M38 pitch source is unsupported or does not match its manifest.' }
if (@($m38.pitch_cases).Count -ne 3 -or (@($m38.pitch_cases | ForEach-Object { [int]$_.rise_units }) -join ',') -ne '8,10,12') { throw 'Expected the documented 8:12, 10:12, and 12:12 pitch options.' }

$pitches = @($m38.pitch_cases | ForEach-Object {
    [ordered]@{
        label = [string]$_.label
        rise_units = [double]$_.rise_units
        run_units = [double]$_.run_units
        status = 'massing comparison only; not selected'
    }
})
$orientations = @(
    [ordered]@{ id = 'ridge-x'; axis = 'X'; ridge_length_ft = $width; transverse_span_ft = $depth },
    [ordered]@{ id = 'ridge-y'; axis = 'Y'; ridge_length_ft = $depth; transverse_span_ft = $width }
)
$cases = [System.Collections.Generic.List[object]]::new()
$index = 0
foreach ($orientation in $orientations) {
    foreach ($pitch in $pitches) {
        $ratio = [double]$pitch.rise_units / [double]$pitch.run_units
        $run = [double]$orientation.transverse_span_ft / 2.0
        $rise = $run * $ratio
        $slope = [Math]::Sqrt(($run * $run) + ($rise * $rise))
        $planeArea = [double]$orientation.ridge_length_ft * $slope
        $index++
        $cases.Add([ordered]@{
            case_id = ('M83-{0}-{1}:12' -f $orientation.axis, [int]$pitch.rise_units)
            pitch_label = [string]$pitch.label
            pitch_rise_units = [double]$pitch.rise_units
            pitch_run_units = [double]$pitch.run_units
            pitch_ratio = $ratio
            ridge_axis = [string]$orientation.axis
            ridge_length_ft = [double]$orientation.ridge_length_ft
            transverse_span_ft = [double]$orientation.transverse_span_ft
            half_run_ft = $run
            rise_above_relative_eave_ft = $rise
            sloped_run_ft = $slope
            projected_plan_area_sf = $width * $depth
            two_plane_surface_area_sf = 2.0 * $planeArea
            display_offset_ft = [ordered]@{ x = (($index - 1) % 3) * 50.0; y = [Math]::Floor(($index - 1) / 3.0) * 50.0 }
            roof_face_count = 2
            physical_thickness_ft = $null
            selection_status = 'comparison option only; not owner-selected'
        })
    }
}

$expectedAreas = @($cases | ForEach-Object { [double]$_.two_plane_surface_area_sf })
$expectedPlanArea = $width * $depth
$riseOrderChecks = foreach ($axis in @('X', 'Y')) {
    $axisCases = @($cases | Where-Object { $_.ridge_axis -eq $axis } | Sort-Object { [double]$_.pitch_rise_units })
    $axisCases.Count -eq 3 -and
        [double]$axisCases[0].rise_above_relative_eave_ft -lt [double]$axisCases[1].rise_above_relative_eave_ft -and
        [double]$axisCases[1].rise_above_relative_eave_ft -lt [double]$axisCases[2].rise_above_relative_eave_ft
}
$checks = [ordered]@{
    selected_D_source_matches_archived_M78 = ($m78Manifest.source_fingerprints_sha256.'selected_D_study.json' -eq $hashes.selected_d_study)
    M78_shell_is_owner_authorized_hypothetical_case = ([Math]::Abs($width - 38.333333) -lt $tolerance -and [Math]::Abs($depth - 40.0) -lt $tolerance -and $coordinateBasis.shell_case -match 'hypothetical')
    M38_pitch_source_is_manifest_bound = ($m38Manifest.output_hashes_sha256.pitch_options -eq $hashes.m38_pitch_options)
    six_pitch_and_orientation_options_generated = ($cases.Count -eq 6 -and @($cases.case_id | Select-Object -Unique).Count -eq 6)
    all_pitch_options_remain_unselected = (@($cases | Where-Object { $_.selection_status -ne 'comparison option only; not owner-selected' }).Count -eq 0)
    each_projected_roof_footprint_matches_test_shell = (@($cases | Where-Object { [Math]::Abs($_.projected_plan_area_sf - $expectedPlanArea) -gt $tolerance }).Count -eq 0)
    rise_equals_half_run_times_pitch_ratio = (@($cases | Where-Object { [Math]::Abs($_.rise_above_relative_eave_ft - ($_.half_run_ft * $_.pitch_ratio)) -gt $tolerance }).Count -eq 0)
    roof_area_equals_two_idealized_slope_planes = (@($cases | Where-Object { [Math]::Abs($_.two_plane_surface_area_sf - (2.0 * $_.ridge_length_ft * $_.sloped_run_ft)) -gt $tolerance }).Count -eq 0)
    rise_increases_with_pitch_for_each_ridge_axis = (@($riseOrderChecks | Where-Object { -not $_ }).Count -eq 0)
    display_offsets_keep_comparison_instances_separate = (@($cases | ForEach-Object { '{0}:{1}' -f $_.display_offset_ft.x, $_.display_offset_ft.y } | Select-Object -Unique).Count -eq 6)
    no_roof_thickness_or_absolute_eave_datum_invented = (@($cases | Where-Object { $null -ne $_.physical_thickness_ft }).Count -eq 0 -and $cases.Count -eq 6)
    source_mentions_no_code_or_structural_design_claim = ($research -match 'not a code review or engineering design')
    selected_D_unchanged_during_generation = ((Get-FileHash -LiteralPath $selectionPath -Algorithm SHA256).Hash.ToLowerInvariant() -eq $hashes.selected_d_study)
}
$failed = @($checks.Keys | Where-Object { -not $checks[$_] })
if ($failed.Count -gt 0) { throw "M83 checks failed: $($failed -join ', ')" }

$report = [ordered]@{
    schema = 'forever-home.m83-gable-massing-options.v1'
    title = 'M83 - conceptual gable surface comparison on hypothetical upper-shell test'
    status = 'six isolated roof-surface massing comparisons; no pitch, ridge direction, eave datum, thickness, or house geometry selected'
    source_fingerprints_sha256 = $hashes
    coordinate_basis = [ordered]@{
        shell_width_ft = $width
        shell_depth_ft = $depth
        source = 'M78 owner-authorized hypothetical upper-shell test'
        absolute_eave_elevation = 'unassigned; each option uses local relative z=0'
        shell_status = 'hypothetical comparison only; not an approved house dimension'
    }
    geometry_representation = 'two open planar roof-face meshes per option; zero overhang; zero thickness; relative eave z=0; non-design display offsets are diagram spacing only'
    pitch_cases = @($pitches)
    results = @($cases)
    Connecticut_code_status = 'See dated Connecticut roof-code research; no project site/permit applicability or load calculation is established.'
    checks = $checks
    failures = @()
    limitations = @(
        'Roof faces are zero-thickness comparison surfaces, not a roof assembly, material takeoff, Revit Roof element, or construction geometry.',
        'Display offsets place six alternatives apart in one disposable comparison model and have no relationship to the house plan.',
        'No walls, floors, gables, dormers, openings, overhangs, structure, snow/wind loads, drainage, attic, headroom, or MEP are modeled.',
        'Pitch and ridge direction are proposals only; the relative eave datum is not tied to a building level.',
        'Connecticut is a research jurisdiction only; site, municipality, permit date, applicable code path, and professional design remain unresolved.'
    )
}

if (-not (Test-Path -LiteralPath $target)) { New-Item -ItemType Directory -Path $target | Out-Null }
$jsonPath = Join-Path $target 'roof-options.json'
$checksPath = Join-Path $target 'checks.json'
$svgPath = Join-Path $target 'roof-options.svg'
$report | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $jsonPath -Encoding utf8
[ordered]@{ count = $checks.Count; passed = @($checks.Keys | Where-Object { $checks[$_] }); failed = @(); checks = $checks; source_fingerprints_sha256 = $hashes } |
    ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $checksPath -Encoding utf8

$svg = [System.Collections.Generic.List[string]]::new()
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1100" height="520" viewBox="0 0 1100 520">')
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:22px;font-weight:bold}.label{font-size:14px}.note{font-size:12px;fill:#5b554d}.axis{stroke:#74695d;stroke-width:1.4}.roof{fill:none;stroke:#533e30;stroke-width:3}.ridge{stroke:#302b25;stroke-width:1.5;stroke-dasharray:5 4}</style>')
$svg.Add('<text class="title" x="34" y="34">M83 - steep-gable massing options</text>')
$svg.Add('<text class="note" x="34" y="56">38.333333 x 40 ft hypothetical test outline; six comparison cases, not a selected house roof.</text>')
$left = 70.0; $top = 105.0; $panelW = 305.0; $panelH = 150.0
for ($i = 0; $i -lt $cases.Count; $i++) {
    $case = $cases[$i]
    $column = $i % 3; $row = [Math]::Floor($i / 3.0)
    $x = $left + ($column * $panelW); $y = $top + ($row * $panelH)
    $scale = 3.3; $span = [double]$case.transverse_span_ft * $scale
    $h = [Math]::Min(65.0, [double]$case.rise_above_relative_eave_ft * 3.2)
    $cx = $x + 105.0; $by = $y + 87.0; $leftEave = $cx - $span / 2; $rightEave = $cx + $span / 2; $ridgeY = $by - $h
    $svg.Add(('<polyline class="roof" points="{0},{1} {2},{3} {4},{1}"/><line class="ridge" x1="{5}" y1="{6}" x2="{7}" y2="{6}"/>' -f $leftEave,$by,$cx,$ridgeY,$rightEave,$cx,$ridgeY,$cx+1))
    $svg.Add(('<line class="axis" x1="{0}" y1="{1}" x2="{2}" y2="{1}"/>' -f $leftEave,$by,$rightEave))
    $area = [Math]::Round([double]$case.two_plane_surface_area_sf).ToString('N0', [Globalization.CultureInfo]::InvariantCulture)
    $svg.Add(('<text class="label" x="{0}" y="{1}">{2} - {3}</text><text class="note" x="{0}" y="{4}">{5:N2} ft rise above local eave; {6} sf two-plane area</text>' -f $x,($y+15),$case.case_id,('ridge '+$case.ridge_axis),($y+137),$case.rise_above_relative_eave_ft,$area))
}
$svg.Add('<line class="axis" x1="34" y1="414" x2="1060" y2="414"/>')
$svg.Add('<text class="note" x="34" y="438">Profiles show span and rise only; roof faces are zero-thickness open surfaces. Option spacing is diagram-only.</text>')
$svg.Add('<text class="note" x="34" y="458">No walls, roof assembly, framing, snow/wind analysis, code decision, or construction geometry.</text>')
$svg.Add('<text class="note" x="34" y="478">Local relative datum only; absolute eave/ridge elevations, site, and shell remain unresolved.</text>')
$svg.Add('</svg>')
$svg -join "`n" | Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest = [ordered]@{
    generator = 'Tools/build_m83_gable_massing_options.ps1'
    source_fingerprints_sha256 = $hashes
    output_hashes_sha256 = [ordered]@{
        roof_options = (Get-FileHash -LiteralPath $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant()
        checks = (Get-FileHash -LiteralPath $checksPath -Algorithm SHA256).Hash.ToLowerInvariant()
        svg = (Get-FileHash -LiteralPath $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}
$manifest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output ("M83 checks passed: {0}/{0}" -f $checks.Count)
Write-Output ('Generated {0} roof massing options on the hypothetical {1} x {2} ft outline.' -f $cases.Count, $width, $depth)
