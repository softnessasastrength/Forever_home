param([string]$OutputDirectory='Architecture/M57_Porch_Edge_Options_2026-10-28',[string]$M33FitPath='Architecture/M33_Open_Social_Zone_Fit_2026-10-28/fit.json')

$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$rootPath=[IO.Path]::GetFullPath($root)
$target=[IO.Path]::GetFullPath((Join-Path $rootPath $OutputDirectory))
$prefix=$rootPath.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if(-not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside the repository.'}
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$specPath=Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
$m33Path=[IO.Path]::GetFullPath((Join-Path $root $M33FitPath))
$prefixM33=$rootPath.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if(-not $m33Path.StartsWith($prefixM33,[StringComparison]::OrdinalIgnoreCase)){throw 'M33FitPath must resolve inside the repository.'}
foreach($path in @($proposalPath,$selectedPath,$specPath,$m33Path)){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required source missing: $path"}}
$proposal=Get-Content -Raw $proposalPath|ConvertFrom-Json
$selected=Get-Content -Raw $selectedPath|ConvertFrom-Json
$m33=Get-Content -Raw $m33Path|ConvertFrom-Json
$spec=Get-Content -Raw $specPath
$hashes=[ordered]@{
  owner_followup_study_json=(Get-FileHash $proposalPath -Algorithm SHA256).Hash.ToLowerInvariant()
  selected_D_study_json=(Get-FileHash $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
  kitchen_dining_porch_specs=(Get-FileHash $specPath -Algorithm SHA256).Hash.ToLowerInvariant()
  M33_fit_json=(Get-FileHash $m33Path -Algorithm SHA256).Hash.ToLowerInvariant()
}
if($m33.source_fingerprints_sha256.'owner_followup_study.json' -ne $hashes.owner_followup_study_json){throw 'M33 owner-followup source fingerprint is stale.'}
if($m33.source_fingerprints_sha256.'selected_D_study.json' -ne $hashes.selected_D_study_json){throw 'M33 selected-D source fingerprint is stale.'}
function Rect($name,$x,$y,$w,$h){[ordered]@{name=$name;x_ft=[double]$x;y_ft=[double]$y;width_ft=[double]$w;depth_ft=[double]$h}}
function Overlap($a,$b){$dx=[Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft);$dy=[Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($a.y_ft,$b.y_ft);$hit=($dx -gt 0.000001 -and $dy -gt 0.000001);[ordered]@{overlap=$hit;area_sf=if($hit){[Math]::Round($dx*$dy,4)}else{0}}}
function Inside($a,$b){$a.x_ft -ge ($b.x_ft-0.000001) -and $a.y_ft -ge ($b.y_ft-0.000001) -and ($a.x_ft+$a.width_ft) -le ($b.x_ft+$b.width_ft+0.000001) -and ($a.y_ft+$a.depth_ft) -le ($b.y_ft+$b.depth_ft+0.000001)}
$porchMatch=[regex]::Match($spec,'(?m)^\| Clear interior \| \*\*(\d+)\x27-\d+"\s*×\s*(\d+)\x27-\d+"\*\*')
if(-not $porchMatch.Success){throw 'Could not parse porch dimensions from project specification.'}
$porchW=[double]$porchMatch.Groups[1].Value;$porchD=[double]$porchMatch.Groups[2].Value
$doorLine=[regex]::Match($spec,'(?m)^\| Pair width \| .*').Value
$doorMatches=[regex]::Matches($doorLine,'(\d+)\x27-(\d+)"')
if($doorMatches.Count -lt 2){throw 'Could not parse nominal porch-door pair widths from project specification.'}
$doorWidths=@(([double]$doorMatches[0].Groups[1].Value+[double]$doorMatches[0].Groups[2].Value/12.0),([double]$doorMatches[$doorMatches.Count-1].Groups[1].Value+[double]$doorMatches[$doorMatches.Count-1].Groups[2].Value/12.0))
$dining=$proposal.main_rooms|Where-Object id -eq 'M-03'
$m06=$proposal.M06.first_fit_window
$table=$m33.furniture_inputs.table_absolute_rect
$tableClear=$m33.clearance_envelopes.table_36in
$shell=Rect '40x42 ft comparison envelope' 0 0 $proposal.shell.width_ft $proposal.shell.depth_ft
$rooms=@($proposal.main_rooms|ForEach-Object{Rect ("{0} {1}" -f $_.id,$_.name) $_.x_ft $_.y_ft $_.width_ft $_.depth_ft})
$rooms+=,(Rect 'M06-B unassigned search window' $m06.x_ft $m06.y_ft $m06.width_ft $m06.depth_ft)
$directions=@(
  @{name='north';x=$dining.x_ft+($dining.width_ft-$porchW)/2.0;y=$dining.y_ft+$dining.depth_ft;w=$porchW;h=$porchD;wall='north';doorCenter=$dining.x_ft+$dining.width_ft/2.0},
  @{name='east';x=$dining.x_ft+$dining.width_ft;y=$dining.y_ft;w=$porchW;h=$porchD;wall='east';doorCenter=$dining.y_ft+$dining.depth_ft/2.0},
  @{name='south';x=$dining.x_ft+($dining.width_ft-$porchW)/2.0;y=$dining.y_ft-$porchD;w=$porchW;h=$porchD;wall='south';doorCenter=$dining.x_ft+$dining.width_ft/2.0},
  @{name='west';x=$dining.x_ft-$porchW;y=$dining.y_ft;w=$porchW;h=$porchD;wall='west';doorCenter=$dining.y_ft+$dining.depth_ft/2.0}
)
$options=@()
foreach($d in $directions){
  $porch=Rect ("{0}-attached 12x10 ft porch proposal" -f $d.name) $d.x $d.y $d.w $d.h
  $collisions=@(foreach($room in $rooms){$o=Overlap $porch $room;if($o.overlap){[ordered]@{room=$room.name;overlap_sf=$o.area_sf}}})
  $route=if($d.name -eq 'north'){
    Rect '36in centered table-edge to north threshold path proxy' ($d.doorCenter-1.5) ($table.y_ft+$table.depth_ft) 3.0 ($dining.y_ft+$dining.depth_ft-($table.y_ft+$table.depth_ft))
  }elseif($d.name -eq 'east'){
    Rect '36in centered table-edge to east threshold path proxy' ($table.x_ft+$table.width_ft) ($d.doorCenter-1.5) ($dining.x_ft+$dining.width_ft-($table.x_ft+$table.width_ft)) 3.0
  }elseif($d.name -eq 'south'){
    Rect '36in centered table-edge to south threshold path proxy' ($d.doorCenter-1.5) $dining.y_ft 3.0 ($table.y_ft-$dining.y_ft)
  }else{
    Rect '36in centered table-edge to west threshold path proxy' $dining.x_ft ($d.doorCenter-1.5) ($table.x_ft-$dining.x_ft) 3.0
  }
  $routePullback=Overlap $route $tableClear
  $doorFit=@(foreach($width in $doorWidths){[ordered]@{nominal_opening_width_ft=$width;path_width_fits_nominal_opening=($width -ge 3.0);centered_opening_interval_ft=@([Math]::Round($d.doorCenter-$width/2.0,4),[Math]::Round($d.doorCenter+$width/2.0,4))}})
  $diningRect=Rect 'M-03 dining block' $dining.x_ft $dining.y_ft $dining.width_ft $dining.depth_ft
  $contact=Overlap $porch $diningRect
  $sharesEdge=$false
  switch($d.name){
    'north' {$sharesEdge=([Math]::Abs($porch.y_ft-($dining.y_ft+$dining.depth_ft)) -lt 0.000001)}
    'south' {$sharesEdge=([Math]::Abs(($porch.y_ft+$porch.depth_ft)-$dining.y_ft) -lt 0.000001)}
    'east' {$sharesEdge=([Math]::Abs($porch.x_ft-($dining.x_ft+$dining.width_ft)) -lt 0.000001)}
    'west' {$sharesEdge=([Math]::Abs(($porch.x_ft+$porch.width_ft)-$dining.x_ft) -lt 0.000001)}
  }
  $wallSpan=if($d.name -in @('north','south')){[Math]::Min(($porch.x_ft+$porch.width_ft),($dining.x_ft+$dining.width_ft))-[Math]::Max($porch.x_ft,$dining.x_ft)}else{[Math]::Min(($porch.y_ft+$porch.depth_ft),($dining.y_ft+$dining.depth_ft))-[Math]::Max($porch.y_ft,$dining.y_ft)}
  $options+=,[ordered]@{edge=$d.name;porch=$porch;door_wall=$d.wall;shares_edge_with_dining=$sharesEdge;door_span_overlap_with_dining_wall_ft=$wallSpan;porch_dining_body_overlap_area_sf=$contact.area_sf;nominal_door_options=$doorFit;route_proxy=$route;route_overlaps_M33_36in_chair_pullback_envelope=$routePullback.overlap;route_pullback_overlap_area_sf=$routePullback.area_sf;overlaps_room_blocks=$collisions;contained_in_unapproved_main_shell=(Inside $porch $shell);shell_overlap=(Overlap $porch $shell)}
}
$checks=[ordered]@{
  source_M33_fingerprints_match_current_studies=($m33.source_fingerprints_sha256.'owner_followup_study.json' -eq $hashes.owner_followup_study_json -and $m33.source_fingerprints_sha256.'selected_D_study.json' -eq $hashes.selected_D_study_json)
  source_porch_dimensions_are_12x10=($porchW -eq 12.0 -and $porchD -eq 10.0)
  all_four_edge_attachments_share_a_dining_boundary=($options.Count -eq 4 -and @($options|Where-Object{-not $_.shares_edge_with_dining -or ($_.edge -in @('east','west') -and $_.door_span_overlap_with_dining_wall_ft -lt ($dining.depth_ft-0.000001)) -or ($_.edge -in @('north','south') -and $_.door_span_overlap_with_dining_wall_ft -lt ($dining.width_ft-0.000001))}).Count -eq 0)
  all_options_allow_a_nominal_5ft_or_6ft_door_for_36in_proxy=(@($options|Where-Object{-not($_.nominal_door_options|Where-Object{$_.path_width_fits_nominal_opening}).Count}).Count -eq 0)
  selected_D_and_followup_source_fingerprints_unchanged=($hashes.selected_D_study_json -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb' -and $proposal.source_selected_D_sha256 -eq $hashes.selected_D_study_json)
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
$report=[ordered]@{
  schema='forever-home.m57-porch-edge-options.v1'
  title='M57 — porch attachment and dining-to-porch route screen'
  status='schematic options only; porch placement and route are not selected'
  source_fingerprints_sha256=$hashes
  source_paths=[ordered]@{owner_followup='Architecture/House_Design_Iteration_2026-10-28/study.json';selected_D='Architecture/Selected_Design_Iteration_2026-10-27/study.json';spec='Architecture/Kitchen_Dining_Porch_Specs.md';M33_fit='m33-fit-input.json'}
  source_dimensions=[ordered]@{porch_ft=@($porchW,$porchD);nominal_door_widths_ft=$doorWidths;route_width_ft=3.0;dining_block=[ordered]@{x_ft=$dining.x_ft;y_ft=$dining.y_ft;width_ft=$dining.width_ft;depth_ft=$dining.depth_ft};M06_search_window=[ordered]@{x_ft=$m06.x_ft;y_ft=$m06.y_ft;width_ft=$m06.width_ft;depth_ft=$m06.depth_ft;status='unassigned search window'}}
  assumptions=@('Each option attaches a 12x10 ft porch flush to one of the four dining room-block edges; this is a comparison proposal derived from the project specification, not selected design.','At north/south edges, the porch 12 ft side is centered along the 11 ft dining edge; at east/west edges, its 10 ft side matches the 10 ft dining edge and its 12 ft side projects outward.','A 36 in-wide straight route proxy runs from the corresponding edge of the M33 table body to the matching dining block boundary, centered on that edge.','The path proxy does not represent chair locations/occupancy, door swing, wall thickness, threshold, approach maneuvering, porch furniture or exterior grade.','Room-block overlaps are geometric conflicts within the owner-follow-up comparison plan only; no unmodeled rooms are inferred.')
  options=$options
  checks=$checks
  failures=$failed
  limitations=@('Candidate porch locations are not owner-selected and the 40x42 ft shell is an unapproved comparison envelope.','An overlap with M-06 B or another room block identifies a plan conflict; it does not authorize moving the room or expanding the shell.','No route is proven clear with occupied chairs; the centered 36 in path proxy intersects the dining table pull-back envelope by construction.','The proxy tests room-block rectangles, not native Revit walls, openings, doors, clear widths, code or accessibility requirements.','No Revit or IFC geometry was changed or validated.')
}
New-Item -ItemType Directory -Force -Path $target|Out-Null
$m33Snapshot=Join-Path $target 'm33-fit-input.json'
Copy-Item -LiteralPath $m33Path -Destination $m33Snapshot -Force
$reportPath=Join-Path $target 'porch-options.json'
$report|ConvertTo-Json -Depth 30|Set-Content -LiteralPath $reportPath -Encoding utf8
if($failed.Count){throw ("M57 source/contract checks failed: {0}" -f ($failed -join ', '))}
Write-Output ("M57 source/contract checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
foreach($option in $options){$names=@($option.overlaps_room_blocks|ForEach-Object{$_.room});Write-Output ("{0}: porch ({1:N3},{2:N3}) {3:N0}x{4:N0} ft; room-block overlaps={5}; shell-contained={6}; route overlaps chair envelope={7}" -f $option.edge,$option.porch.x_ft,$option.porch.y_ft,$option.porch.width_ft,$option.porch.depth_ft,($(if($names.Count){$names -join '; '}else{'none'})),$option.contained_in_unapproved_main_shell,$option.route_overlaps_M33_36in_chair_pullback_envelope)}
