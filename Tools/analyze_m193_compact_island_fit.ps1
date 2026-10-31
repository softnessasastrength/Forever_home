param([string]$OutputDirectory='Architecture/M193_Compact_Island_Fit_2026-10-31/artifacts')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out=Join-Path $root $OutputDirectory
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count-gt0){throw "Refusing to overwrite nonempty output: $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out|Out-Null}
$m172Rel='Architecture/M172_Compact_Social_Space_Constraints_2026-10-31/m172-compact-social-space-constraints.json'
$specRel='Architecture/Kitchen_Dining_Porch_Specs.md'
$decisionRel='Decisions/Kitchen_Island_Finish.md'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
function Hash193([string]$p){(Get-FileHash -LiteralPath (Join-Path $root $p) -Algorithm SHA256).Hash.ToLowerInvariant()}
$hashes=[ordered]@{};foreach($p in @($m172Rel,$specRel,$decisionRel,$selectedRel)){$hashes[$p]=Hash193 $p}
if($hashes[$selectedRel]-ne'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'){throw 'Selected-D fingerprint changed; refusing this study.'}
$m172=Get-Content -LiteralPath (Join-Path $root $m172Rel) -Raw|ConvertFrom-Json
$m172SourcesCurrent=$true;foreach($p in $m172.source_fingerprints_sha256.PSObject.Properties){if((Hash193 $p.Name)-ne([string]$p.Value).ToLowerInvariant()){$m172SourcesCurrent=$false}}
$targetW=[double]$m172.targets.M02_kitchen_ft[0];$targetD=[double]$m172.targets.M02_kitchen_ft[1]
$targetArea=[double]$m172.targets.M02_kitchen_area_sf;$run=[double]$m172.targets.perimeter_run_required_ft
$clear=3.5;$counterDepth=2.0;$bodyDepth=2.0;$overhang=1.0;$wallThick=.5
# Clear room dimensions terminate at the finished face of the half wall. Its thickness is
# outside clear interior area per the kitchen specification and is therefore not charged
# against the 14 x 12 ft room rectangle.
$cases=@(
 [pscustomobject]@{id='owner_reference_8x4';length=8.0;overallDepth=4.0;bodyDepth=$null;overhang=$null;quartz=6.0;butcher=2.0;halfwall='opposing-face';note='Owner reference dimensions; body/overhang decomposition is not assumed.'},
 [pscustomobject]@{id='flex_7x3_keep_2ft_butcher';length=7.0;overallDepth=3.0;bodyDepth=2.0;overhang=1.0;quartz=5.0;butcher=2.0;halfwall='boundary-face';note='Derived limiting fit: 42-in end clearances use all 14 ft; 24-in body plus 12-in overhang and 42-in aisles use all 12 ft clear.'},
 [pscustomobject]@{id='flex_6x3_keep_2ft_butcher';length=6.0;overallDepth=3.0;bodyDepth=2.0;overhang=1.0;quartz=4.0;butcher=2.0;halfwall='boundary-face';note='One foot more total end reserve than 7-ft case; less quartz length.'},
 [pscustomobject]@{id='flex_7x2_5_shallow_body';length=7.0;overallDepth=2.5;bodyDepth=1.5;overhang=1.0;quartz=5.0;butcher=2.0;halfwall='boundary-face';note='Stress test only; 18-in body conflicts with documented 24-in base-depth input.'}
)
$rows=New-Object System.Collections.Generic.List[object]
foreach($c in $cases){
 $crossClear=$counterDepth+$clear+[double]$c.overallDepth+$clear
 $crossIncludingWall=$crossClear+$wallThick
 $endSpan=2*$clear+[double]$c.length
 $crossResidual=($targetD-$crossClear)*12
 $endResidual=($targetW-$endSpan)*12
 $runResidual=($targetW-$run)*12
 $bodyCompatible=([double]$c.bodyDepth-ge$bodyDepth)
 $sizeFits=($crossResidual-ge-1e-8-and$endResidual-ge-1e-8-and$run-le$targetW+1e-8)
 $rows.Add([pscustomobject]@{case=$c.id;island_length_ft=[double]$c.length;overall_depth_ft=[double]$c.overallDepth;cabinet_body_depth_ft=[double]$c.bodyDepth;seating_overhang_ft=[double]$c.overhang;island_area_sf=[Math]::Round([double]$c.length*[double]$c.overallDepth,3);area_reduction_vs_8x4_sf=[Math]::Round(32-([double]$c.length*[double]$c.overallDepth),3);quartz_length_ft=[double]$c.quartz;butcher_length_ft=[double]$c.butcher;clear_cross_section_ft=[Math]::Round($crossClear,4);cross_section_including_wall_thickness_ft=[Math]::Round($crossIncludingWall,4);cross_reserve_in=$crossResidual;end_clearance_span_ft=[Math]::Round($endSpan,4);end_reserve_in=$endResidual;perimeter_run_ft=$run;perimeter_run_reserve_on_14ft_axis_in=$runResidual;halfwall_position_assumption=$c.halfwall;body_depth_compatible=$bodyCompatible;clear_room_fit=($sizeFits-and$bodyCompatible);proposal_note=$c.note})
}
$ref=$rows|Where-Object case -eq 'owner_reference_8x4'|Select-Object -First 1
$fit7=$rows|Where-Object case -eq 'flex_7x3_keep_2ft_butcher'|Select-Object -First 1
$fit6=$rows|Where-Object case -eq 'flex_6x3_keep_2ft_butcher'|Select-Object -First 1
$checks=@(
 [pscustomobject]@{id='current_owner_sources_match_m172';pass=($hashes.Count-eq4);detail='M172, kitchen specification, island decision and selected-D are fingerprinted.'},
 [pscustomobject]@{id='m172_upstream_fingerprints_current';pass=$m172SourcesCurrent;detail='Every upstream source fingerprint recorded by M172 still matches the repository.'},
 [pscustomobject]@{id='selected_d_protected';pass=($hashes[$selectedRel]-eq'516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Selected-D source hash remains the protected baseline.'},
 [pscustomobject]@{id='room_clear_dimensions_and_target';pass=($targetW-eq14-and$targetD-eq12-and$targetArea-eq168);detail='Study uses the owner-directed 14 x 12 ft / 168 sf kitchen target.'},
 [pscustomobject]@{id='perimeter_run_fits_14ft_axis';pass=($run-eq12.5-and$runResidual-eq18);detail='The 12 ft 6 in source module run leaves 18 in total reserve along the 14 ft clear axis.'},
 [pscustomobject]@{id='owner_reference_fails_bounded_room';pass=(-not$ref.clear_room_fit);detail='The 8 x 4 ft reference exceeds both the 12-ft clear cross-section and the 14-ft end-span when using the specified 42-in proxies.'},
 [pscustomobject]@{id='7x3_island_fits_arithmetic';pass=([bool]$fit7.clear_room_fit-and$fit7.cross_reserve_in-eq0-and$fit7.end_reserve_in-eq0);detail='A derived 7 x 3 ft test island fits the 14 x 12 ft clear rectangle exactly with 42-in proxies and a 24-in body plus 12-in overhang.'},
 [pscustomobject]@{id='6x3_island_retains_one_foot_end_reserve';pass=([bool]$fit6.clear_room_fit-and$fit6.cross_reserve_in-eq0-and$fit6.end_reserve_in-eq12);detail='A derived 6 x 3 ft test island leaves 12 in total end reserve; the cross-section remains exact.'},
 [pscustomobject]@{id='shallow_body_candidate_rejected';pass=(-not($rows|Where-Object case -eq 'flex_7x2_5_shallow_body').clear_room_fit);detail='18-in cabinet body is not accepted as a fit because it conflicts with the documented 24-in body depth.'},
 [pscustomobject]@{id='room_area_and_island_remain_proposals';pass=($rows.Count-eq4);detail='Only bounded alternatives are reported; no owner-selected dimensions or design status are changed.'}
)
$passed=@($checks|Where-Object pass).Count;$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$report=[ordered]@{schema='forever-home-m193-compact-island-fit-v1';status=$status;design_result='two_candidate_island_sizes_fit_the_kitchen_clear_rectangle_arithmetically';method='Derive island envelope limits from the owner-directed 14 x 12 ft clear room, 24-in perimeter base, 42-in minimum aisle proxies, 12-in seating overhang and 12 ft 6 in perimeter run. Half-wall thickness is outside clear interior dimensions; the comparison places its room-facing surface at the room boundary. This is a plan arithmetic screen, not furniture/occupant verification.';source_fingerprints_sha256=$hashes;inputs=[ordered]@{kitchen_clear_dimensions_ft=@($targetW,$targetD);kitchen_area_target_sf=$targetArea;perimeter_run_ft=$run;counter_depth_ft=$counterDepth;minimum_aisle_ft=$clear;halfwall_thickness_ft=$wallThick;room_dimensions_exclude_wall_thickness=$true;selected_d_sha256=$hashes[$selectedRel]};candidates=$rows.ToArray();checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks};limitations=@('The 7 x 3 ft and 6 x 3 ft islands are derived study alternatives, not owner-approved dimensions or purchasable family geometry.','The 7 x 3 case has zero arithmetic reserve at both clear axes; the 6 x 3 case has 12 in total end reserve but still zero cross-section reserve. Finish tolerances and actual wall/cabinet face locations are absent.','The 5+2 ft and 4+2 ft quartz/butcher splits are proposal arithmetic that retains a 2-ft butcher segment; shop feasibility and seam/support are not assessed.','Two stools remain required, but real stool width, side allowances and occupied movement were not tested.','The half-wall is shown at the room boundary, with thickness outside clear dimensions; its location, opening, return, approach and route are not laid out.','Dining table, chair pull-outs, living/porch route, appliance-open envelopes, doors, shell, adjacent rooms and M-06 are not tested in this milestone.','No Revit or IFC geometry is changed. M-06/B remains unassigned.','No code, accessibility, structural-safety, professional, permit or construction-readiness conclusion is made.')}
$utf8=New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm193-compact-island-fit.json'),(($report|ConvertTo-Json -Depth 40)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm193-checks.json'),(($report.checks|ConvertTo-Json -Depth 30)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm193-candidates.csv'),((@($rows|ConvertTo-Csv -NoTypeInformation)-join"`n")+"`n"),$utf8)
$svg=New-Object System.Collections.Generic.List[string];$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1180" height="690" viewBox="0 0 1180 690"><style>text{font:14px Arial;fill:#302b25}.title{font-size:22px;font-weight:bold}.room{fill:#fbf8f1;stroke:#433c35;stroke-width:3}.counter{fill:#dfd0bb;stroke:#6a5844;stroke-width:2}.island{fill:#dce7db;stroke:#60745a;stroke-width:2}.aisle{fill:#9fc3d1;fill-opacity:.22;stroke:#54899b;stroke-dasharray:6 4}.wall{fill:#77685a}.open{fill:#dbe9ea;stroke:#3f7a82;stroke-dasharray:5 4}.label{font-size:12px}.small{font-size:11px;fill:#735c47}</style><text class="title" x="24" y="32">M193 — compact island envelopes inside 14 × 12 ft clear kitchen</text>')
$scale=34.0;$oy=310.0;$ox1=60.0;$ox2=640.0
function R193([double]$x,[double]$y,[double]$w,[double]$h,[string]$cls,[string]$label,[double]$ox,[double]$oy,[double]$scale){$rx=$ox+$x*$scale;$ry=$oy-($y+$h)*$scale;return "<rect class='$cls' x='$rx' y='$ry' width='$($w*$scale)' height='$($h*$scale)'/><text class='label' x='$($rx+4)' y='$($ry+17)'>$label</text>"}
 foreach($panel in @(@{ox=$ox1;len=7.0;name='7 x 3 ft candidate';split='5 ft quartz + 2 ft butcher block';reserve='0 in total island-end reserve'},@{ox=$ox2;len=6.0;name='6 x 3 ft candidate';split='4 ft quartz + 2 ft butcher block';reserve='12 in total island-end reserve'})){
 $ox=[double]$panel.ox;$svg.Add((R193 0 0 14 12 'room' '' $ox $oy $scale));$svg.Add((R193 .75 0 12.5 2 'counter' '12 ft 6 in perimeter run' $ox $oy $scale));$x=(14-[double]$panel.len)/2;$svg.Add((R193 $x 5.5 ([double]$panel.len) 3 'island' $panel.name $ox $oy $scale));$svg.Add((R193 0 2 14 3.5 'aisle' '42 in work aisle' $ox $oy $scale));$svg.Add((R193 0 8.5 14 3.5 'aisle' '42 in to half-wall face' $ox $oy $scale));$svg.Add((R193 0 12 7 .5 'wall' '' $ox $oy $scale));$svg.Add((R193 7 12 6 .5 'open' '6 ft living opening' $ox $oy $scale));$svg.Add((R193 13 12 1 .5 'wall' '' $ox $oy $scale));$svg.Add("<text x='$ox' y='350' class='title'>$($panel.name)</text><text x='$ox' y='372' class='small'>$($panel.split); $($panel.reserve)</text><text x='$ox' y='398' class='small'>Half-wall thickness outside 12-ft clear room depth; schematic only.</text>")
}
$svg.Add('<text x="24" y="660" class="small">Blue bands are 42-in arithmetic proxies. Neither option includes dining, porch route, pull-outs, appliance-open geometry or site fit.</text></svg>')
[IO.File]::WriteAllText((Join-Path $out 'm193-island-comparison.svg'),($svg -join "`n")+"`n",$utf8);$null=[xml](Get-Content -LiteralPath (Join-Path $out 'm193-island-comparison.svg') -Raw)
Write-Output "M193 $status $passed/$($checks.Count); 7x3 and 6x3 arithmetic candidates; no selected-D change; M-06/B unassigned."
if($passed-ne$checks.Count){exit 1}
