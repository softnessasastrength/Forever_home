param(
    [string]$M115PackageDirectory = 'Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30',
    [string]$M116PackageDirectory = 'Architecture/M116_U03_EERO_Wall_Zone_2026-10-30',
    [string]$M83PackageDirectory = 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30',
    [string]$OutputDirectory = 'Architecture/M117_U03_Gable_EERO_Height_Screen_2026-10-30'
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$prefix=$root.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
function Resolve-InRoot([string]$path,[string]$label){$resolved=[IO.Path]::GetFullPath((Join-Path $root $path));if(-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw "$label must resolve inside the repository."};return $resolved}
$m115=Resolve-InRoot $M115PackageDirectory 'M115PackageDirectory'
$m116=Resolve-InRoot $M116PackageDirectory 'M116PackageDirectory'
$m83=Resolve-InRoot $M83PackageDirectory 'M83PackageDirectory'
$output=Resolve-InRoot $OutputDirectory 'OutputDirectory'
$m115ArchivePath=Join-Path $m115 'all-route-tested-candidates.json';$m115AuditPath=Join-Path $m115 'm115-audit.json'
$m116ReportPath=Join-Path $m116 'm116-report.json';$m83RoofPath=Join-Path $m83 'roof-options.json';$m83ManifestPath=Join-Path $m83 'manifest.json'
foreach($path in @($m115ArchivePath,$m115AuditPath,$m116ReportPath,$m83RoofPath,$m83ManifestPath)){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing M117 source: $path"}}
$m115Archive=Get-Content -Raw -LiteralPath $m115ArchivePath|ConvertFrom-Json
$m115Audit=Get-Content -Raw -LiteralPath $m115AuditPath|ConvertFrom-Json
$m116Report=Get-Content -Raw -LiteralPath $m116ReportPath|ConvertFrom-Json
$m83Roof=Get-Content -Raw -LiteralPath $m83RoofPath|ConvertFrom-Json
$m83Manifest=Get-Content -Raw -LiteralPath $m83ManifestPath|ConvertFrom-Json
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$selected=Get-Content -Raw -LiteralPath $selectedPath|ConvertFrom-Json
$proposal=Get-Content -Raw -LiteralPath $proposalPath|ConvertFrom-Json
$tol=0.00001;$shellW=38.333333;$shellD=40.0
function Edges($r){$e=@();if([Math]::Abs($r.x_ft)-le $tol){$e+='west'};if([Math]::Abs($r.y_ft)-le $tol){$e+='north'};if([Math]::Abs($r.x_ft+$r.width_ft-$shellW)-le $tol){$e+='east'};if([Math]::Abs($r.y_ft+$r.depth_ft-$shellD)-le $tol){$e+='south'};return (@($e|Sort-Object)-join ',')}
$all=@($m115Archive.candidates)
$privacy=@($all|Where-Object{$_.public_rooms_reached_count -eq 3 -and -not $_.hall_reachability.u03_hall_side_reachable})
$northeast=@($privacy|Where-Object{(Edges $_.rectangles.'U-03') -eq 'east,north'})
if($northeast.Count -eq 0){throw 'No M115 northeast privacy candidates available.'}
$orientationGroups=@($northeast|Group-Object { '{0:F4}x{1:F4}' -f $_.rectangles.'U-03'.width_ft,$_.rectangles.'U-03'.depth_ft } | Sort-Object Name)
if($orientationGroups.Count -ne 2){throw "Expected two northeast U-03 orientations; found $($orientationGroups.Count)."}
$windowWidthIn=[double]$m116Report.code_basis.minimum_clear_width_in
$windowHeightIn=[double]$m116Report.EERO_threshold_arithmetic.height_at_20_in_clear_width_in
$sillMaxIn=[double]$m116Report.code_basis.maximum_bottom_of_clear_opening_in
$openingTopIn=$sillMaxIn+$windowHeightIn
$windowWidthFt=$windowWidthIn/12.0
$rows=[System.Collections.Generic.List[object]]::new()
foreach($group in $orientationGroups){
  $u03=$group.Group[0].rectangles.'U-03'
  foreach($roof in @($m83Roof.results|Sort-Object ridge_axis,pitch_rise_units)){
    $ratio=[double]$roof.pitch_ratio
    if($roof.ridge_axis -eq 'X'){$side='east';$openingSpanStart=$u03.y_ft+$u03.depth_ft-$windowWidthFt;$openingSpanEnd=$u03.y_ft+$u03.depth_ft;$minRise=$openingSpanStart*$ratio}
    elseif($roof.ridge_axis -eq 'Y'){$side='north';$openingSpanStart=$u03.x_ft;$openingSpanEnd=$u03.x_ft+$windowWidthFt;$minRise=($shellW-$openingSpanEnd)*$ratio}
    else{throw "Unexpected M83 ridge axis: $($roof.ridge_axis)"}
    $requiredEaveAboveFloorRaw=($openingTopIn/12.0)-$minRise
    $requiredEaveAboveFloorNonnegative=[Math]::Max(0.0,$requiredEaveAboveFloorRaw)
    $rows.Add([ordered]@{
        orientation_group=$group.Name;orientation_candidate_count=$group.Count;U03_x_ft=[double]$u03.x_ft;U03_y_ft=[double]$u03.y_ft;U03_width_ft=[double]$u03.width_ft;U03_depth_ft=[double]$u03.depth_ft
        case_id=$roof.case_id;pitch_label=$roof.pitch_label;pitch_rise_units=[double]$roof.pitch_rise_units;pitch_run_units=[double]$roof.pitch_run_units
        ridge_axis=$roof.ridge_axis;U03_gable_wall_side=$side;U03_gable_wall_contact_length_ft=if($side -eq 'east'){[double]$u03.depth_ft}else{[double]$u03.width_ft}
        hypothetical_opening_clear_width_in=$windowWidthIn;hypothetical_opening_clear_height_in=$windowHeightIn;hypothetical_sill_bottom_in=$sillMaxIn;opening_top_above_floor_in=$openingTopIn
        opening_span_start_ft=$openingSpanStart;opening_span_end_ft=$openingSpanEnd;nearest_roof_plane_rise_above_eave_ft=$minRise
        raw_floor_to_eave_threshold_ft=$requiredEaveAboveFloorRaw;nonnegative_floor_to_eave_threshold_ft=$requiredEaveAboveFloorNonnegative
        assumption='20in clear width and 41.04in clear height are an area-threshold geometry proxy, not a selected window; ideal M83 roof plane only; eave-to-floor datum remains unknown'
        selection_status='orientation and pitch remain unselected'
    })
  }
}
$m115ArchiveHash=(Get-FileHash $m115ArchivePath -Algorithm SHA256).Hash.ToLowerInvariant()
$m115AuditHash=(Get-FileHash $m115AuditPath -Algorithm SHA256).Hash.ToLowerInvariant()
$m116Hash=(Get-FileHash $m116ReportPath -Algorithm SHA256).Hash.ToLowerInvariant()
$m83Hash=(Get-FileHash $m83RoofPath -Algorithm SHA256).Hash.ToLowerInvariant()
$m83ManifestHash=(Get-FileHash $m83ManifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
$selectedHash=(Get-FileHash $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
$proposalHash=(Get-FileHash $proposalPath -Algorithm SHA256).Hash.ToLowerInvariant()
$m37Path=Join-Path $root 'Tools/test_m37_upper_suite_pack_and_route.ps1'
$m115ScriptPath=Join-Path $root 'Tools/audit_m115_u03_all_edge_search.ps1'
$m116ScriptPath=Join-Path $root 'Tools/analyze_m116_u03_eero_wall_zone.ps1'
$m83ScriptPath=Join-Path $root 'Tools/build_m83_gable_massing_options.ps1'
$sourceHashes=[ordered]@{M115_archive=$m115ArchiveHash;M115_audit=$m115AuditHash;M116_report=$m116Hash;M83_roof_options=$m83Hash;M83_manifest=$m83ManifestHash;selected_D=$selectedHash;owner_proposal=$proposalHash;M37_generator=(Get-FileHash $m37Path -Algorithm SHA256).Hash.ToLowerInvariant();M115_audit_script=(Get-FileHash $m115ScriptPath -Algorithm SHA256).Hash.ToLowerInvariant();M116_analyzer=(Get-FileHash $m116ScriptPath -Algorithm SHA256).Hash.ToLowerInvariant();M83_generator=(Get-FileHash $m83ScriptPath -Algorithm SHA256).Hash.ToLowerInvariant();analyzer=(Get-FileHash $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()}
$allNorthEast=$true;$orientationCounts=@{}
foreach($c in $northeast){if((Edges $c.rectangles.'U-03') -ne 'east,north'){$allNorthEast=$false};$key='{0:F4}x{1:F4}' -f $c.rectangles.'U-03'.width_ft,$c.rectangles.'U-03'.depth_ft;if(-not $orientationCounts.ContainsKey($key)){$orientationCounts[$key]=0};$orientationCounts[$key]++}
$checks=[ordered]@{
    M115_archive_and_audit_are_hash_linked=($m115ArchiveHash -eq $m115Audit.source_hashes_sha256.archive -and @($m115Audit.checks.PSObject.Properties|Where-Object{-not $_.Value}).Count -eq 0)
    M116_report_is_bound_to_same_selected_D=($m116Report.source_hashes_sha256.selected_D -eq $selectedHash)
    owner_keeps_U03_private_only=($proposal.owner_inputs.u03_shared_hall_access -eq $false)
    M115_ne_privacy_subset_count_is_64=($northeast.Count -eq 64)
    northeast_privacy_candidates_have_two_documented_orientations=($allNorthEast -and $orientationGroups.Count -eq 2 -and $orientationCounts['13.6667x9.1667'] -eq 44 -and $orientationCounts['9.1667x13.6667'] -eq 20)
    both_orientations_match_selected_D_source_dimensions=(@($orientationGroups|Where-Object{$w=[double]$_.Group[0].rectangles.'U-03'.width_ft;$d=[double]$_.Group[0].rectangles.'U-03'.depth_ft;$src=$selected.plans.upper|Where-Object{$_.id -eq 'U-03'}; -not (([Math]::Abs($w-[double]$src.w)-lt $tol -and [Math]::Abs($d-[double]$src.d)-lt $tol) -or ([Math]::Abs($w-[double]$src.d)-lt $tol -and [Math]::Abs($d-[double]$src.w)-lt $tol))}).Count -eq 0)
    M83_roof_hash_matches_manifest=($m83Manifest.output_hashes_sha256.roof_options -eq $m83Hash)
    M83_shell_matches_M115_exploration=([Math]::Abs($m83Roof.coordinate_basis.shell_width_ft-$shellW)-lt $tol -and [Math]::Abs($m83Roof.coordinate_basis.shell_depth_ft-$shellD)-lt $tol)
    all_twelve_orientation_pitch_axis_cases_are_covered=($rows.Count -eq 12 -and (@($rows.pitch_rise_units|Sort-Object -Unique)-join ',') -eq '8,10,12' -and (@($rows.ridge_axis|Sort-Object -Unique)-join ',') -eq 'X,Y' -and @($rows.orientation_group|Sort-Object -Unique).Count -eq 2)
    all_M83_options_remain_unselected=(@($m83Roof.results|Where-Object{$_.selection_status -ne 'comparison option only; not owner-selected'}).Count -eq 0)
    code_thresholds_match_M116=(($windowWidthIn -eq 20) -and [Math]::Abs($windowHeightIn-41.04)-lt $tol -and $sillMaxIn -eq 44 -and [Math]::Abs($m116Report.code_basis.minimum_net_clear_area_sq_ft-5.7)-lt $tol)
    minimum_area_opening_proxy_satisfies_area_and_minimum_dimensions=([Math]::Abs(($windowWidthIn*$windowHeightIn/144.0)-5.7)-lt 0.001 -and $windowHeightIn -ge [double]$m116Report.code_basis.minimum_clear_height_in)
    orientation_specific_gable_contact_matches_room_dimensions=(@($rows|Where-Object{($_.U03_gable_wall_side -eq 'east' -and [Math]::Abs($_.U03_gable_wall_contact_length_ft-$_.U03_depth_ft)-gt $tol) -or ($_.U03_gable_wall_side -eq 'north' -and [Math]::Abs($_.U03_gable_wall_contact_length_ft-$_.U03_width_ft)-gt $tol)}).Count -eq 0)
    ridge_X_places_U03_east_edge_on_gable_end=(@($rows|Where-Object{$_.ridge_axis -eq 'X' -and $_.U03_gable_wall_side -ne 'east'}).Count -eq 0)
    ridge_Y_places_U03_north_edge_on_gable_end=(@($rows|Where-Object{$_.ridge_axis -eq 'Y' -and $_.U03_gable_wall_side -ne 'north'}).Count -eq 0)
    gable_rise_matches_orientation_axis_and_pitch_geometry=(@(foreach($r in $rows){$spanFt=$windowWidthFt;$expected=if($r.ridge_axis -eq 'X'){($r.U03_depth_ft-$spanFt)*($r.pitch_rise_units/$r.pitch_run_units)}else{($shellW-($r.U03_x_ft+$spanFt))*($r.pitch_rise_units/$r.pitch_run_units)};[Math]::Abs($expected-$r.nearest_roof_plane_rise_above_eave_ft)-lt $tol}).Count -eq 12)
    all_eave_thresholds_are_relative_not_selected=(@($rows|Where-Object{$_.selection_status -ne 'orientation and pitch remain unselected' -or $_.assumption -notmatch 'eave-to-floor datum remains unknown'}).Count -eq 0)
    selected_D_baseline_is_unchanged=($selectedHash -eq $m115Audit.source_hashes_sha256.selected_D_study)
    no_code_compliance_or_window_product_claim=($m116Report.code_basis.code_compliance_claimed -eq $false -and $m116Report.status -match 'no window')
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
if($failed.Count -gt 0){throw "M117 gable EERO screen failed: $($failed -join ', ')"}
$report=[ordered]@{
    schema='forever-home.m117-u03-gable-eero-height-screen.v1'
    status='conditional gable-plane comparison only; no pitch, ridge axis, window product, eave height or room layout selected'
    shell=[ordered]@{width_ft=$shellW;depth_ft=$shellD;status='M115 exploration only'}
    room=[ordered]@{id='U-03';role='hybrid bedroom/office, sleeping-room status unverified';route_candidate_count=$northeast.Count;orientation_distribution=@($orientationGroups|ForEach-Object{$r=$_.Group[0].rectangles.'U-03';[ordered]@{width_ft=[double]$r.width_ft;depth_ft=[double]$r.depth_ft;candidate_count=$_.Count;north_contact_in=([double]$r.width_ft*12);east_contact_in=([double]$r.depth_ft*12)}});status='schematic source-preserved rectangles, not finished inside dimensions'}
    opening_proxy=[ordered]@{clear_width_in=$windowWidthIn;clear_height_in=$windowHeightIn;bottom_above_floor_in=$sillMaxIn;top_above_floor_in=$openingTopIn;clear_area_sq_ft=($windowWidthIn*$windowHeightIn/144.0);status='derived threshold envelope only, not a product or selected opening'}
    gable_orientation_semantics=[ordered]@{ridge_X=[ordered]@{U03_gable_end='east';reason='opening proxy occupies the southernmost 20in segment of the east wall, where this north-corner room is nearest the X-ridge'};ridge_Y=[ordered]@{U03_gable_end='north';reason='opening proxy occupies the westernmost 20in segment of the north wall, where this northeast room is nearest the Y-ridge'}}
    cases=@($rows)
    interpretation='The northeast privacy sample has two source-preserved room orientations: 44 north-long and 20 east-long. The 12 cases retain both. For each orientation and each gable axis, the proxy opening is placed at the segment nearest that axis ridge along the touching gable wall, and the ideal roof plane is sampled at the least favorable edge of that segment. The resulting heights depend on room orientation, ridge axis and pitch; none is selected. Eave datum, thickness, wall construction, actual opening product and exterior discharge remain unresolved.'
    limitations=@('Opening proxy is derived from code minimum area and dimensions, not a manufacturer product.','The shell roof uses ideal zero-thickness planes with no framing, overhang, dormer, wall or gable end construction.','The calculated floor-to-eave threshold is conditional arithmetic; no actual eave height or finished-floor elevation is selected.','Window opening operation, sill, yard/court, grade, path to public way, U-03 sleeping-room status and local permit basis remain unverified.','This compares only a U-03 opening zone, not whole-suite headroom, structure, drainage or code compliance.','The 38 1/3 x 40 ft shell and all ridge/pitch combinations remain unselected; no Revit/IFC/selected-D/RFA/remote change is made.')
    source_hashes_sha256=$sourceHashes
    checks=$checks
    failed=@()
}
if(-not(Test-Path -LiteralPath $output)){New-Item -ItemType Directory -Path $output|Out-Null}
$report|ConvertTo-Json -Depth 16|Set-Content -LiteralPath (Join-Path $output 'm117-report.json') -Encoding utf8
$checksOut=[ordered]@{schema='forever-home.m117-u03-gable-eero-checks.v1';passed=$checks.Count;failed=@();checks=$checks;source_hashes_sha256=$sourceHashes}
$checksOut|ConvertTo-Json -Depth 12|Set-Content -LiteralPath (Join-Path $output 'm117-checks.json') -Encoding utf8
$rows|Export-Csv -LiteralPath (Join-Path $output 'm117-cases.csv') -NoTypeInformation -Encoding UTF8
Write-Output ("M117 conditional gable EERO screen passed: {0}/{1}; both U-03 orientations are represented across all pitch/axis combinations." -f $checks.Count,$checks.Count)
