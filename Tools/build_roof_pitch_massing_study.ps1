param(
    [string]$StudyPath = (Join-Path $PSScriptRoot '../Architecture/House_Design_Iteration_2026-10-28/study.json'),
    [string]$OutputJsonPath = (Join-Path $PSScriptRoot '../Architecture/House_Design_Iteration_2026-10-28/roof-pitch-options.json'),
    [string]$OutputSvgPath = (Join-Path $PSScriptRoot '../Architecture/House_Design_Iteration_2026-10-28/roof-pitch-options.svg')
)

$ErrorActionPreference = 'Stop'
$studyFile = (Resolve-Path -LiteralPath $StudyPath).Path
$study = Get-Content -LiteralPath $studyFile -Raw | ConvertFrom-Json
if ($study.schema -ne 'forever-home.owner-followup-design-study.v1' -or
    $study.shell.status -ne 'existing selected-D test envelope; not approved house footprint' -or
    [double]$study.shell.width_ft -ne 40 -or [double]$study.shell.depth_ft -ne 42) {
    throw 'Expected the documented, unapproved 40 x 42 ft follow-up test envelope.'
}
if ($study.roof.pitch -ne 'TBD' -or $study.roof.ridge_orientation -ne 'TBD') {
    throw 'Roof pitch or ridge orientation is already assigned in the source proposal; stop and reconcile first.'
}
$sourceHash = (Get-FileHash -LiteralPath $studyFile -Algorithm SHA256).Hash.ToLowerInvariant()

# Illustrative design proposals only; no option is selected or treated as a specification.
$pitchOptions = @(10, 12, 14)
$orientations = @(
    [ordered]@{ridge_parallel_axis='42-ft shell depth';ridge_length_ft=[double]$study.shell.depth_ft;span_axis='40-ft shell width';span_ft=[double]$study.shell.width_ft},
    [ordered]@{ridge_parallel_axis='40-ft shell width';ridge_length_ft=[double]$study.shell.width_ft;span_axis='42-ft shell depth';span_ft=[double]$study.shell.depth_ft}
)
$options = @()
foreach ($pitch in $pitchOptions) {
    foreach ($orientation in $orientations) {
        $halfRunFt = [double]$orientation.span_ft / 2.0
        $riseFt = $halfRunFt * ([double]$pitch / 12.0)
        $rafterLengthFt = [Math]::Sqrt(($halfRunFt * $halfRunFt) + ($riseFt * $riseFt))
        $options += [ordered]@{
            pitch_rise_in_12_run_in = [int]$pitch
            ridge_parallel_axis = [string]$orientation.ridge_parallel_axis
            ridge_length_ft = [double]$orientation.ridge_length_ft
            span_axis = [string]$orientation.span_axis
            full_span_ft = [double]$orientation.span_ft
            half_run_ft = [Math]::Round($halfRunFt, 3)
            rise_above_eave_ft = [Math]::Round($riseFt, 3)
            schematic_rafter_line_length_ft = [Math]::Round($rafterLengthFt, 3)
            unselected_proposal = $true
        }
    }
}

$report = [ordered]@{
    schema = 'forever-home-proposed-gable-pitch-massing-v1'
    result = 'PASS: six formula-derived, unselected gable massing comparisons generated from the existing unapproved test envelope.'
    source = [ordered]@{
        study_file = [System.IO.Path]::GetFileName($studyFile)
        study_sha256 = $sourceHash
        shell_width_ft = [double]$study.shell.width_ft
        shell_depth_ft = [double]$study.shell.depth_ft
        shell_status = [string]$study.shell.status
        owner_roof_request = [string]$study.owner_inputs.roof_concept
        source_pitch_remains_tbd = $true
        source_ridge_orientation_remains_tbd = $true
    }
    design_proposal_inputs = [ordered]@{
        illustrative_pitch_ratios = @('10:12','12:12','14:12')
        ridge_directions = @('parallel to 42-ft shell depth','parallel to 40-ft shell width')
        selected_pitch = $null
        selected_ridge_direction = $null
    }
    options = $options
    evaluated = [ordered]@{
        formula_based_massing_only = $true
        shell_is_an_approved_house_footprint = $false
        overhangs_or_gable_projections = $false
        roof_plan_shape_or_wing_intersections = $false
        finished_eave_or_ridge_elevations = $false
        roof_assemblies_or_openings = $false
        snow_wind_or_drainage_design = $false
        structural_members_or_connections = $false
        revit_roof_or_ifc_geometry = $false
        code_compliance_or_construction_readiness = $false
    }
    limitations = @(
        'Pitch values and ridge directions are illustrative proposals for comparing steep-gable proportions; none is owner-selected.',
        'The 40 x 42 ft outline is an unapproved selected-D test envelope, not an approved house footprint or roof plan.',
        'Rise is calculated from half the rectangular test-shell span and is measured above a hypothetical eave datum; floor/storey elevations are not included.',
        'A single full-span rectangle ignores the actual room-wing profile, intersections, overhangs, gable projections, dormers, openings, drainage and site orientation.',
        'The schematic line length is geometric only and does not size, specify or validate a rafter, truss, connection, roof assembly, snow/wind resistance, or construction method.',
        'Connecticut code research warns that a steep profile does not itself establish a reduced snow load; site and permit inputs remain unknown.'
    )
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolveOutput = {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) { [System.IO.Path]::GetFullPath($Path) }
    else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $Path)) }
}
$jsonPath = & $resolveOutput $OutputJsonPath
$svgPath = & $resolveOutput $OutputSvgPath
foreach ($path in @($jsonPath,$svgPath)) {
    $directory = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
}
$json = ConvertTo-Json -InputObject $report -Depth 16
[System.IO.File]::WriteAllText($jsonPath, $json + "`r`n", [System.Text.UTF8Encoding]::new($false))

$svg = New-Object System.Collections.Generic.List[string]
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1120" height="980" viewBox="0 0 1120 980">')
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:25px;font-weight:bold}.sub{font-size:16px}.panel{fill:#fbf8f1;stroke:#c8baa3;stroke-width:1.5}.paneltitle{font-size:17px;font-weight:bold}.label{font-size:14px}.roof{fill:#947358;fill-opacity:.22;stroke:#594638;stroke-width:4}.base{stroke:#6b6257;stroke-width:2}.note{font-size:14px;fill:#514b43}</style>')
$svg.Add('<text class="title" x="36" y="38">Steep gable proportions — proposal comparison</text>')
$svg.Add('<text class="sub" x="36" y="66">Unapproved 40 × 42 ft test envelope; common drawing scale 6 px/ft; rise shown above a hypothetical eave datum.</text>')
$svg.Add('<text class="sub" x="36" y="91">Pitch and ridge direction remain TBD. No roof assembly, wings, openings, loads or structure are modeled.</text>')
$panelWidth = 520.0
$panelHeight = 258.0
$scale = 6.0
for ($index = 0; $index -lt $options.Count; $index++) {
    $option = $options[$index]
    $column = $index % 2
    $row = [Math]::Floor($index / 2.0)
    $px = 36 + ($column * 536)
    $py = 112 + ($row * 272)
    $spanPx = [double]$option.full_span_ft * $scale
    $risePx = [double]$option.rise_above_eave_ft * $scale
    $cx = $px + ($panelWidth / 2.0)
    $baseY = $py + 224
    $leftX = $cx - ($spanPx / 2.0)
    $rightX = $cx + ($spanPx / 2.0)
    $ridgeY = $baseY - $risePx
    $pitchText = '{0}:12 | ridge parallel to {1}' -f $option.pitch_rise_in_12_run_in, $option.ridge_parallel_axis
    $metricText = 'span {0} ft | rise {1} ft above eave | proposal only' -f $option.full_span_ft, $option.rise_above_eave_ft
    $svg.Add(('<rect class="panel" x="{0}" y="{1}" width="{2}" height="{3}" rx="8"/>' -f $px,$py,$panelWidth,$panelHeight))
    $svg.Add(('<text class="paneltitle" x="{0}" y="{1}">{2}</text>' -f ($px+16),($py+28),$pitchText))
    $svg.Add(('<text class="label" x="{0}" y="{1}">{2}</text>' -f ($px+16),($py+52),$metricText))
    $svg.Add(('<line class="base" x1="{0}" y1="{1}" x2="{2}" y2="{1}"/>' -f ($px+48),$baseY,($px+$panelWidth-48)))
    $svg.Add(('<path class="roof" d="M {0} {1} L {2} {3} L {4} {1} Z"/>' -f $leftX,$baseY,$cx,$ridgeY,$rightX))
    $svg.Add(('<line class="base" x1="{0}" y1="{1}" x2="{0}" y2="{2}"/>' -f $leftX,$baseY,($baseY+20)))
    $svg.Add(('<line class="base" x1="{0}" y1="{1}" x2="{0}" y2="{2}"/>' -f $rightX,$baseY,($baseY+20)))
    $svg.Add(('<text class="label" x="{0}" y="{1}" text-anchor="middle">{2} ft</text>' -f $cx,($baseY+38),$option.full_span_ft))
    $svg.Add(('<text class="label" x="{0}" y="{1}" text-anchor="middle">{2} ft rise</text>' -f ($cx+48),($ridgeY+20),$option.rise_above_eave_ft))
}
$svg.Add('<text class="note" x="36" y="944">Illustrative geometry only. Steep pitch does not establish lower snow load or structural suitability; consult site-specific code path and qualified design.</text>')
$svg.Add('</svg>')
[System.IO.File]::WriteAllText($svgPath, ($svg -join "`r`n") + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "PASS: six unselected steep-gable proposals saved to $jsonPath and $svgPath"
