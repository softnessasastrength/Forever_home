param(
    [string]$OutputDirectory = 'Architecture/M36_Roof_Orientation_Study_2026-10-28'
)

$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$resolvedRoot=[System.IO.Path]::GetFullPath($root)
$target=[System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $OutputDirectory))
$prefix=$resolvedRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar)+[System.IO.Path]::DirectorySeparatorChar
if(-not $target.StartsWith($prefix,[System.StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside the repository root.'}

$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$decisionPath=Join-Path $root 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
$researchPath=Join-Path $root 'Research/Connecticut_Roof_Code_Research_2026-10-28.md'
foreach($path in @($proposalPath,$decisionPath,$researchPath)){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required source missing: $path"}}
$proposal=Get-Content -Raw -LiteralPath $proposalPath|ConvertFrom-Json
$decision=Get-Content -Raw -LiteralPath $decisionPath
$research=Get-Content -Raw -LiteralPath $researchPath
$proposalHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $proposalPath).Hash.ToLowerInvariant()
$decisionHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $decisionPath).Hash.ToLowerInvariant()
$researchHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $researchPath).Hash.ToLowerInvariant()

if($proposal.owner_inputs.roof_concept -notmatch 'steep traditional gable'){throw 'Owner-directed steep-gable concept is absent from the source study.'}
foreach($phrase in @('2022 Connecticut State Building Code','October 1, 2022','1608.1.2','R301.6','Roof pitch','structure remain unassigned')){if(($decision+$research) -notmatch [regex]::Escape($phrase)){throw "Required roof/code evidence is missing: $phrase"}}

$width=[double]$proposal.shell.width_ft
$depth=[double]$proposal.shell.depth_ft
$pitchRatio=$null
$ridgeAlongDepth=[ordered]@{id='A';ridge_direction='parallel to 42ft test-envelope depth';ridge_length_ft=$depth;transverse_span_ft=$width;half_run_ft=($width/2.0);pitch_ratio_vertical_per_horizontal=$pitchRatio;ridge_rise_formula='half_run_ft × pitch_ratio; pitch not assigned'}
$ridgeAlongWidth=[ordered]@{id='B';ridge_direction='parallel to 40ft test-envelope width';ridge_length_ft=$width;transverse_span_ft=$depth;half_run_ft=($depth/2.0);pitch_ratio_vertical_per_horizontal=$pitchRatio;ridge_rise_formula='half_run_ft × pitch_ratio; pitch not assigned'}
$relativeRiseIncrease=($ridgeAlongWidth.half_run_ft/$ridgeAlongDepth.half_run_ft)-1.0
$checks=[ordered]@{
    owner_roof_request_is_steep_traditional_gable=($proposal.owner_inputs.roof_concept -like 'steep traditional gable*')
    study_footprint_is_source_derived_40x42=($width -eq 40 -and $depth -eq 42)
    ridge_option_A_uses_40ft_transverse_span=($ridgeAlongDepth.transverse_span_ft -eq 40 -and $ridgeAlongDepth.half_run_ft -eq 20)
    ridge_option_B_uses_42ft_transverse_span=($ridgeAlongWidth.transverse_span_ft -eq 42 -and $ridgeAlongWidth.half_run_ft -eq 21)
    same_pitch_option_B_has_5_percent_larger_half_run=([Math]::Abs($relativeRiseIncrease-0.05) -lt 0.000001)
    no_roof_pitch_or_rise_is_invented=($null -eq $ridgeAlongDepth.pitch_ratio_vertical_per_horizontal -and $null -eq $ridgeAlongWidth.pitch_ratio_vertical_per_horizontal)
    code_path_is_not_assumed_from_statewide_research=($research -match 'eventual code path depends on building classification and jurisdiction')
    municipality_and_site_remain_open=($research -match 'Town/municipality, site, permit-application timing')
    source_states_2022_code_applies_from_2022_10_01=($research -match 'on or after October 1, 2022')
    source_records_2026_adoption_delay=($research -match 'effective date has been delayed')
    no_compliance_or_structural_claim=($research -match 'No code-compliance, structural-safety')
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
if($failed.Count -gt 0){throw "M36 roof-study checks failed: $($failed -join ', ')"}

$report=[ordered]@{
    schema='forever-home.m36-roof-orientation-screen.v1'
    title='M36 — steep gable ridge orientation screen'
    status='two parametric ridge orientations compared on the source test envelope; pitch, roof geometry and code path remain unassigned'
    source_fingerprints_sha256=[ordered]@{'owner_followup_study.json'=$proposalHash;'house_design_decision.md'=$decisionHash;'Connecticut_Roof_Code_Research_2026-10-28.md'=$researchHash}
    coordinate_basis='Owner-follow-up schematic coordinates: x follows the 40ft envelope dimension; y follows the 42ft envelope dimension. This is not site orientation or surveyed footprint geometry.'
    main_shell_test_envelope_ft=[ordered]@{width_x=$width;depth_y=$depth;status='comparison envelope only; not approved building footprint'}
    owner_input=$proposal.owner_inputs.roof_concept
    pitch_ratio_vertical_per_horizontal=$pitchRatio
    options=@($ridgeAlongDepth,$ridgeAlongWidth)
    same_pitch_comparison=[ordered]@{half_run_difference_ft=($ridgeAlongWidth.half_run_ft-$ridgeAlongDepth.half_run_ft);relative_half_run_and_rise_increase=$relativeRiseIncrease;interpretation='At any identical selected pitch ratio, the 42ft transverse span creates a 1ft larger half-run and 5 percent greater rise than the 40ft transverse span. No actual rise can be computed until pitch is selected.'}
    code_research=[ordered]@{jurisdiction='Connecticut statewide research only';checked_date='2026-10-28';code_path='unassigned; evaluate IRC/IBC path with municipality and design professional';code_2022_status='current adopted code per DAS as checked; 2026 effective date delayed pending legislative review';roof_load_implication='A steep gable still requires site- and code-path-specific roof snow/wind design; the IBC snow provisions and IRC amendment are distinguished in the cited research note.';research_note='Research/Connecticut_Roof_Code_Research_2026-10-28.md'}
    unassigned_inputs=@('pitch ratio','ridge direction relative to site','ridge/eave elevations','roof overhangs','main/rear-wing intersection','porch roof geometry','roof assembly and drainage','openings/chimneys/ducts','municipality and permit date','site snow/wind/terrain inputs','framing, connections, supports and engineering')
    checks=$checks
    failures=$failed
    limitations=@('The 40×42ft rectangle is a source-derived test envelope, not an approved footprint or site orientation.','Only ridge direction relative to this test rectangle is compared. No roof surface, pitch, height, eave, overhang or intersection solid is generated.','Code research identifies current statewide sources and selected roof-load topics; it does not establish project applicability, local requirements or compliance.','No structural, professional certification, permit or construction-readiness claim is made.')
}

if(-not(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target|Out-Null}
$jsonPath=Join-Path $target 'roof-study.json';$checksPath=Join-Path $target 'checks.json';$svgPath=Join-Path $target 'ridge-orientations.svg'
$report|ConvertTo-Json -Depth 18|Set-Content -LiteralPath $jsonPath -Encoding utf8
$checkReport=[ordered]@{count=$checks.Count;passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@();checks=$checks;source_fingerprints_sha256=$report.source_fingerprints_sha256;interpretation='Passing checks validate source-derived comparison arithmetic and explicitly unassigned roof/code inputs; not a roof design.'}
$checkReport|ConvertTo-Json -Depth 12|Set-Content -LiteralPath $checksPath -Encoding utf8

$scale=4.0;$shellX=40.0;$shellY=42.0
$svg=[System.Collections.Generic.List[string]]::new()
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1050" height="580" viewBox="0 0 1050 580">')
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:23px;font-weight:bold}.sub{font-size:14px;fill:#5b554d}.shell{fill:#fcfaf5;stroke:#4e463d;stroke-width:3}.ridgeA{stroke:#a86632;stroke-width:5}.ridgeB{stroke:#557989;stroke-width:5}.dim{stroke:#8c847a;stroke-width:1.5;stroke-dasharray:5 4}.label{font-size:14px}.formula{font-size:13px;fill:#5b554d}.badge{font-weight:bold;font-size:16px}</style>')
$svg.Add('<text class="title" x="30" y="34">M36 — gable ridge orientation on the test envelope</text>')
$svg.Add('<text class="sub" x="30" y="58">Plan comparison only. Ridge direction is relative to x/y, not north or the site.</text>')
$panels=@([ordered]@{x=60;y=120;label='A — ridge parallel to 42ft side';ridge='y';rise='20ft × pitch ratio';span='40ft span / 20ft half-run'},[ordered]@{x=550;y=120;label='B — ridge parallel to 40ft side';ridge='x';rise='21ft × pitch ratio';span='42ft span / 21ft half-run'})
foreach($panel in $panels){
    $px=[double]$panel.x;$py=[double]$panel.y;$sw=$shellX*$scale;$sh=$shellY*$scale
    $svg.Add(('<text class="badge" x="{0}" y="{1}">{2}</text>' -f $px,($py-18),$panel.label))
    $svg.Add(('<rect class="shell" x="{0}" y="{1}" width="{2}" height="{3}"/>' -f $px,$py,$sw,$sh))
    if($panel.ridge -eq 'y'){
        $ridgeLine='<line class="ridgeA" x1="{0}" y1="{1}" x2="{0}" y2="{2}"/>' -f ($px+$sw/2),$py,($py+$sh)
    } else {
        $ridgeLine='<line class="ridgeB" x1="{0}" y1="{1}" x2="{2}" y2="{1}"/>' -f $px,($py+$sh/2),($px+$sw)
    }
    $svg.Add($ridgeLine)
    $svg.Add(('<text class="label" x="{0}" y="{1}">{2}</text>' -f $px,($py+$sh+24),$panel.span))
    $svg.Add(('<text class="formula" x="{0}" y="{1}">ridge rise = {2}; pitch not selected</text>' -f $px,($py+$sh+46),$panel.rise))
}
$svg.Add('<text class="sub" x="30" y="520">At the same pitch, B has a 1ft greater half-run (5%). No pitch, roof height, snow load or framing is assigned.</text>')
$svg.Add('</svg>')
$svg -join "`n"|Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest=[ordered]@{generator='Tools/build_m36_roof_orientation_study.ps1';source_fingerprints_sha256=$report.source_fingerprints_sha256;output_hashes_sha256=[ordered]@{roof_study=(Get-FileHash $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks=(Get-FileHash $checksPath -Algorithm SHA256).Hash.ToLowerInvariant();svg=(Get-FileHash $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
$manifest|ConvertTo-Json -Depth 10|Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output("M36 checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output('The 42ft transverse orientation has a 21ft half-run versus 20ft for 40ft; same-pitch rise differs by 5%. Pitch remains unassigned.')
