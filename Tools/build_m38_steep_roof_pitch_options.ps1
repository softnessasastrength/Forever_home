param(
    [string]$OutputDirectory = 'Architecture/M38_Steep_Roof_Pitch_Options_2026-10-28'
)

$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$repo=[System.IO.Path]::GetFullPath($root)
$target=[System.IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))
$prefix=$repo.TrimEnd([System.IO.Path]::DirectorySeparatorChar)+[System.IO.Path]::DirectorySeparatorChar
if(-not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside the repository root.'}

$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$decisionPath=Join-Path $root 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
$codePath=Join-Path $root 'Research/Connecticut_Roof_Code_Research_2026-10-28.md'
foreach($path in @($selectedPath,$proposalPath,$decisionPath,$codePath)){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required source missing: $path"}}
$selected=Get-Content -Raw $selectedPath|ConvertFrom-Json
$proposal=Get-Content -Raw $proposalPath|ConvertFrom-Json
$decision=Get-Content -Raw $decisionPath
$code=Get-Content -Raw $codePath
$hashes=[ordered]@{
    selected_D_study_json=(Get-FileHash -Algorithm SHA256 $selectedPath).Hash.ToLowerInvariant()
    owner_followup_study_json=(Get-FileHash -Algorithm SHA256 $proposalPath).Hash.ToLowerInvariant()
    owner_decision=(Get-FileHash -Algorithm SHA256 $decisionPath).Hash.ToLowerInvariant()
    Connecticut_code_research=(Get-FileHash -Algorithm SHA256 $codePath).Hash.ToLowerInvariant()
}

$shellW=[double]$proposal.shell.width_ft
$shellD=[double]$proposal.shell.depth_ft
if($proposal.source_selected_D_sha256 -ne $hashes.selected_D_study_json){throw 'Owner-follow-up proposal no longer matches selected-D source.'}
$options=@(
    [ordered]@{id='A';ridge_direction='parallel to 42 ft test-envelope side';ridge_length_ft=$shellD;transverse_span_ft=$shellW;half_run_ft=($shellW/2.0)},
    [ordered]@{id='B';ridge_direction='parallel to 40 ft test-envelope side';ridge_length_ft=$shellW;transverse_span_ft=$shellD;half_run_ft=($shellD/2.0)}
)
$pitchCases=@(
    [ordered]@{label='Illustrative 8:12';rise_units=8.0;run_units=12.0;selection_status='comparison option only; not owner-selected'},
    [ordered]@{label='Illustrative 10:12';rise_units=10.0;run_units=12.0;selection_status='comparison option only; not owner-selected'},
    [ordered]@{label='Illustrative 12:12';rise_units=12.0;run_units=12.0;selection_status='comparison option only; not owner-selected'}
)
$cases=[System.Collections.Generic.List[object]]::new()
foreach($orientation in $options){foreach($pitch in $pitchCases){
    $ratio=[double]$pitch.rise_units/[double]$pitch.run_units
    $rise=[double]$orientation.half_run_ft*$ratio
    $slope=[Math]::Sqrt([Math]::Pow([double]$orientation.half_run_ft,2)+[Math]::Pow($rise,2))
    $planArea=2.0*[double]$orientation.ridge_length_ft*[double]$orientation.half_run_ft
    $roofArea=2.0*[double]$orientation.ridge_length_ft*$slope
    $cases.Add([ordered]@{
        orientation_id=$orientation.id
        ridge_direction=$orientation.ridge_direction
        ridge_length_ft=$orientation.ridge_length_ft
        transverse_span_ft=$orientation.transverse_span_ft
        half_run_ft=$orientation.half_run_ft
        pitch_label=$pitch.label
        pitch_rise_units=$pitch.rise_units
        pitch_run_units=$pitch.run_units
        pitch_ratio=$ratio
        pitch_angle_degrees=([Math]::Atan($ratio)*180.0/[Math]::PI)
        rise_above_eave_ft=$rise
        sloped_rafter_length_ft=$slope
        projected_plan_area_sf=$planArea
        two_plane_area_sf=$roofArea
        roof_area_factor=($roofArea/$planArea)
        selection_status=$pitch.selection_status
    })
}}
$halfRunA=[double]$options[0].half_run_ft
$halfRunB=[double]$options[1].half_run_ft
$monotonicRise=([double]$pitchCases[0].rise_units/[double]$pitchCases[0].run_units -lt [double]$pitchCases[1].rise_units/[double]$pitchCases[1].run_units -and [double]$pitchCases[1].rise_units/[double]$pitchCases[1].run_units -lt [double]$pitchCases[2].rise_units/[double]$pitchCases[2].run_units -and $halfRunA -gt 0 -and $halfRunB -gt 0)
$samePitchRiseFivePercent=@($pitchCases|Where-Object{$ratio=[double]$_.rise_units/[double]$_.run_units;[Math]::Abs((($halfRunB*$ratio)/($halfRunA*$ratio))-1.05) -gt 0.000001}).Count -eq 0
$checks=[ordered]@{
    owner_selected_steep_gable_concept_is_present=($proposal.roof.type -match 'steep.*gable')
    jurisdiction_is_connecticut=($proposal.owner_inputs.jurisdiction -match '^Connecticut')
    selected_D_provenance_matches_proposal=($proposal.source_selected_D_sha256 -eq $hashes.selected_D_study_json)
    test_envelope_is_source_followup_40_by_42=([Math]::Abs($shellW-40.0) -lt 0.000001 -and [Math]::Abs($shellD-42.0) -lt 0.000001)
    both_ridge_orientations_preserve_projected_plan_area=(@($cases|Where-Object{[Math]::Abs($_.projected_plan_area_sf-($shellW*$shellD)) -gt 0.000001}).Count -eq 0)
    pitch_options_are_explicitly_unselected=(@($cases|Where-Object{$_.selection_status -ne 'comparison option only; not owner-selected'}).Count -eq 0 -and @($cases).Count -eq 6)
    rise_follows_half_run_times_pitch_ratio=(@($cases|Where-Object{[Math]::Abs($_.rise_above_eave_ft-($_.half_run_ft*([double]$_.pitch_rise_units/[double]$_.pitch_run_units))) -gt 0.000001}).Count -eq 0)
    steeper_options_raise_ridge_monotonically=$monotonicRise
    same_pitch_rise_increases_by_five_percent_for_42ft_span=$samePitchRiseFivePercent
    absolute_ridge_and_eave_datums_remain_unassigned=($proposal.roof.'ridge/eave elevations' -eq 'TBD')
    no_code_compliance_or_structural_claim=($decision -match 'No code-compliance, structural-safety' -and $code -match 'not a code review or engineering design')
    selected_D_file_unchanged_during_run=((Get-FileHash -Algorithm SHA256 $selectedPath).Hash.ToLowerInvariant() -eq $hashes.selected_D_study_json)
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
if($failed.Count -gt 0){throw "M38 checks failed: $($failed -join ', ')"}

$report=[ordered]@{
    schema='forever-home.m38-steep-gable-pitch-screen.v1'
    title='M38 - illustrative steep-gable pitch comparison'
    status='parametric massing comparison only; pitches are illustrative proposals and none is selected'
    source_fingerprints_sha256=$hashes
    coordinate_basis='40 x 42 ft selected-D-derived owner-follow-up test envelope; no site orientation, survey or approved house footprint'
    geometry_assumptions=@('Simple symmetric gable with zero modeled overhang','Rise is measured above a future eave datum, which remains unspecified','Roof area is two sloped planes only; excludes overhangs, gables, dormers, intersections, openings, waste and assemblies')
    pitch_cases=@($pitchCases)
    ridge_orientations=@($options)
    results=@($cases)
    comparison=[ordered]@{span_40ft_half_run_ft=$halfRunA;span_42ft_half_run_ft=$halfRunB;relative_rise_increase_at_same_pitch=0.05;pitch_selection='none'}
    Connecticut_context='See Research/Connecticut_Roof_Code_Research_2026-10-28.md. Code edition/path, site loads, snow drifting, wind exposure, roof intersections and professional design remain unresolved. This is not code compliance.'
    checks=$checks
    failures=$failed
    limitations=@('8:12, 10:12 and 12:12 are illustrative comparison inputs, not adopted design dimensions or code minima.','The rise values do not establish total building height; eave datum, story heights, wall plates, floor build-ups and roof assemblies are unassigned.','No Revit solids, structure, snow/wind calculations, drainage, attic/headroom, code/accessibility review, IFC or construction-readiness assessment is performed.','Connecticut jurisdiction is state-level only; municipality, parcel and permit timing are unknown.')
}
if(-not(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target|Out-Null}
$jsonPath=Join-Path $target 'pitch-options.json';$checkPath=Join-Path $target 'checks.json';$svgPath=Join-Path $target 'steep-gable-options.svg'
$report|ConvertTo-Json -Depth 16|Set-Content -LiteralPath $jsonPath -Encoding utf8
[ordered]@{count=$checks.Count;passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@();checks=$checks;source_fingerprints_sha256=$hashes}|ConvertTo-Json -Depth 10|Set-Content -LiteralPath $checkPath -Encoding utf8
$svg=[System.Collections.Generic.List[string]]::new();$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="960" height="600" viewBox="0 0 960 600">')
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:21px;font-weight:bold}.label{font-size:13px}.note{font-size:12px;fill:#5b554d}.axis{stroke:#74695d;stroke-width:2}.a{fill:#7f9d84}.b{fill:#b78f66}</style>')
$svg.Add('<text class="title" x="40" y="32">M38 - steep-gable rise options</text><text class="note" x="40" y="54">Illustrative pitch cases on the 40 x 42 ft test envelope; eave datum and pitch unselected</text><text class="note" x="40" y="74">Bars show rise; labels add two-plane geometric area versus the 1,680 sf projected test footprint.</text>')
$barX=180.0;$barScale=10.0;$baseY=455.0
foreach($case in $cases){$row=if($case.orientation_id -eq 'A'){0}else{1};$pitchRow=[int]($case.pitch_rise_units/2)-4;$y=120.0+($row*180.0)+($pitchRow*42.0);$w=[double]$case.rise_above_eave_ft*$barScale;$rectY=$y-18.0;$class=if($case.orientation_id -eq 'A'){'a'}else{'b'}
    $shortPitch='{0}:12' -f [int]$case.pitch_rise_units
    $roofArea=[Math]::Round([double]$case.two_plane_area_sf,0).ToString('N0',[Globalization.CultureInfo]::InvariantCulture)
    $areaIncrease=([double]$case.roof_area_factor-1.0)*100.0
    $svg.Add(('<text class="label" x="40" y="{0}">{1} / {2}</text><rect class="{3}" x="{4}" y="{5}" width="{6}" height="24"/><text class="label" x="400" y="{0}">{7:N2} ft rise; {8} sf planes (+{9:N1}%)</text>' -f ($y+4),$case.orientation_id,$shortPitch,$class,$barX,$rectY,$w,$case.rise_above_eave_ft,$roofArea,$areaIncrease))
}
$svg.Add(('<line class="axis" x1="{0}" y1="{1}" x2="{2}" y2="{1}"/>' -f $barX,$baseY,($barX+210)))
$svg.Add('<text class="note" x="40" y="520">A: ridge along 42 ft side, 20 ft half-run. B: ridge along 40 ft side, 21 ft half-run.</text><text class="note" x="40" y="542">Plane area excludes overhangs, gables, dormers, intersections, openings, waste and assemblies.</text><text class="note" x="40" y="564">Geometric comparison only; it is not a roofing takeoff, cost estimate, roof solid or code/structural review.</text>')
$svg.Add('</svg>');$svg -join "`n"|Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest=[ordered]@{generator='Tools/build_m38_steep_roof_pitch_options.ps1';source_fingerprints_sha256=$hashes;output_hashes_sha256=[ordered]@{pitch_options=(Get-FileHash $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks=(Get-FileHash $checkPath -Algorithm SHA256).Hash.ToLowerInvariant();svg=(Get-FileHash $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
$manifest|ConvertTo-Json -Depth 10|Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output("M38 checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output("Illustrative gable pitches: {0}; pitch selected: none." -f ($pitchCases.label -join ', '))
