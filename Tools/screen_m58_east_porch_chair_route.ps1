param([string]$OutputDirectory='Architecture/M58_East_Porch_Chair_Route_2026-10-28',[string]$M57ReportPath='Architecture/M57_Porch_Edge_Options_2026-10-28/porch-options.json')

$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$rootPath=[IO.Path]::GetFullPath($root)
$target=[IO.Path]::GetFullPath((Join-Path $rootPath $OutputDirectory))
$prefix=$rootPath.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if(-not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside the repository.'}
$m57Path=[IO.Path]::GetFullPath((Join-Path $root $M57ReportPath))
if(-not $m57Path.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'M57ReportPath must resolve inside the repository.'}
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$specPath=Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
$m57=Get-Content -Raw $m57Path|ConvertFrom-Json
$proposal=Get-Content -Raw $proposalPath|ConvertFrom-Json
$selected=Get-Content -Raw $selectedPath|ConvertFrom-Json
$spec=Get-Content -Raw $specPath
$sourceHashes=[ordered]@{
  M57_report=(Get-FileHash $m57Path -Algorithm SHA256).Hash.ToLowerInvariant()
  owner_followup_study=(Get-FileHash $proposalPath -Algorithm SHA256).Hash.ToLowerInvariant()
  selected_D_study=(Get-FileHash $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant()
  kitchen_dining_porch_specs=(Get-FileHash $specPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
if($sourceHashes.M57_report -ne '436d558c28c1c1ba00f1fa06cadc989efd3d79956fc4a9c689d8d326f21f7eca'){throw 'M57 report is not the reviewed east/west-corrected result.'}
if($m57.source_fingerprints_sha256.owner_followup_study_json -ne $sourceHashes.owner_followup_study -or $m57.source_fingerprints_sha256.selected_D_study_json -ne $sourceHashes.selected_D_study){throw 'M57 input fingerprints do not match current studies.'}
if($proposal.source_selected_D_sha256 -ne $sourceHashes.selected_D_study){throw 'Owner-follow-up study selected-D fingerprint is stale.'}
$m58East=@($m57.options|Where-Object{$_.edge -eq 'east'})[0]
if(-not $m58East -or $m58East.overlaps_room_blocks.Count -ne 0){throw 'M57 east porch candidate no longer clears current room blocks.'}
$m33Path=Join-Path (Split-Path -Parent $m57Path) 'm33-fit-input.json'
if(-not(Test-Path -LiteralPath $m33Path -PathType Leaf)){throw 'M57 retained M33 input snapshot is missing.'}
$m33=Get-Content -Raw $m33Path|ConvertFrom-Json
$m33Hash=(Get-FileHash $m33Path -Algorithm SHA256).Hash.ToLowerInvariant()
if($m33Hash -ne $m57.source_fingerprints_sha256.M33_fit_json){throw 'M57 retained M33 input fingerprint is stale.'}
function Rect($name,$x,$y,$w,$h){[ordered]@{name=$name;x_ft=[double]$x;y_ft=[double]$y;width_ft=[double]$w;depth_ft=[double]$h}}
function Overlap($a,$b){$dx=[Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft);$dy=[Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($a.y_ft,$b.y_ft);$hit=($dx -gt 0.000001 -and $dy -gt 0.000001);[ordered]@{overlap=$hit;area_sf=if($hit){[Math]::Round($dx*$dy,5)}else{0}}}
$table=$m33.furniture_inputs.table_absolute_rect
$tableSpec=[regex]::Match($spec,'(?m)^\| Dining table \| \*\*(\d+)\" W × (\d+)\" L × (\d+)\" H\*\*')
$chairSpec=[regex]::Match($spec,'(?m)^\| Chairs \| \*\*(\d+)\" × (\d+)\"\*\* seat')
if(-not $tableSpec.Success -or -not $chairSpec.Success){throw 'Could not parse dining table and chair body dimensions from project specifications.'}
$tableW=[double]$tableSpec.Groups[1].Value/12.0;$tableL=[double]$tableSpec.Groups[2].Value/12.0
$chairW=[double]$chairSpec.Groups[1].Value/12.0;$chairD=[double]$chairSpec.Groups[2].Value/12.0
if([Math]::Abs($table.width_ft-$tableL) -gt 0.000001 -or [Math]::Abs($table.depth_ft-$tableW) -gt 0.000001){throw 'M33 table orientation/dimensions no longer match the source-spec candidate.'}
$routeWidth=3.0
$route=Rect '36in path along table east end to east dining threshold' ($table.x_ft+$table.width_ft) (($table.y_ft+$table.depth_ft/2.0)-$routeWidth/2.0) ($m58East.porch.x_ft-($table.x_ft+$table.width_ft)) $routeWidth
$quarter=$table.x_ft+$table.width_ft/4.0
$threeQuarter=$table.x_ft+3.0*$table.width_ft/4.0
$chairCenters=@($quarter,$threeQuarter)
$chairs=@()
foreach($cx in $chairCenters){
  $chairs+=,(Rect ("north occupied chair body proxy at x={0:N3}ft" -f $cx) ($cx-$chairW/2.0) ($table.y_ft+$table.depth_ft) $chairW $chairD)
  $chairs+=,(Rect ("south occupied chair body proxy at x={0:N3}ft" -f $cx) ($cx-$chairW/2.0) ($table.y_ft-$chairD) $chairW $chairD)
}
$doorWidths=@(foreach($door in $m58East.nominal_door_options){[double]$door.nominal_opening_width_ft})
$doorFit=@(foreach($width in $doorWidths){$interval=@($m58East.nominal_door_options|Where-Object nominal_opening_width_ft -eq $width)[0].centered_opening_interval_ft;$routeInDoor=($route.y_ft -ge $interval[0]-0.000001 -and ($route.y_ft+$route.depth_ft) -le $interval[1]+0.000001);[ordered]@{nominal_door_width_ft=$width;centered_opening_interval_ft=$interval;route_width_ft=$routeWidth;route_fits_nominal_interval=$routeInDoor}})
$chairRoutes=@(foreach($chair in $chairs){$o=Overlap $route $chair;[ordered]@{chair=$chair.name;overlaps_route=$o.overlap;overlap_area_sf=$o.area_sf}})
$chairTableOverlaps=@(foreach($chair in $chairs){$o=Overlap $chair $table;if($o.overlap){$chair.name}})
$chairPairOverlaps=@()
for($i=0;$i -lt $chairs.Count;$i++){for($j=$i+1;$j -lt $chairs.Count;$j++){$o=Overlap $chairs[$i] $chairs[$j];if($o.overlap){$chairPairOverlaps+=,"$($chairs[$i].name) / $($chairs[$j].name)"}}}
$checks=[ordered]@{
  all_source_fingerprints_match=($m57.source_fingerprints_sha256.owner_followup_study_json -eq $sourceHashes.owner_followup_study -and $m57.source_fingerprints_sha256.selected_D_study_json -eq $sourceHashes.selected_D_study -and $m57.source_fingerprints_sha256.kitchen_dining_porch_specs -eq $sourceHashes.kitchen_dining_porch_specs -and $m33Hash -eq $m57.source_fingerprints_sha256.M33_fit_json)
  selected_table_matches_documented_60x36_orientation=([Math]::Abs($table.width_ft-5.0) -lt 0.000001 -and [Math]::Abs($table.depth_ft-3.0) -lt 0.000001)
  four_chairs_created_from_18x20_spec=($chairs.Count -eq 4 -and $chairW -eq 1.5 -and $chairD -eq (20.0/12.0))
  route_36in_is_continuous_from_table_body_to_east_dining_boundary=([Math]::Abs($route.x_ft+$route.width_ft-$m58East.porch.x_ft) -lt 0.000001 -and [Math]::Abs($route.width_ft-3.0) -lt 0.000001 -and [Math]::Abs($route.depth_ft-3.0) -lt 0.000001)
  route_has_no_overlap_with_four_chair_body_proxies=(@($chairRoutes|Where-Object overlaps_route).Count -eq 0)
  chair_body_proxies_clear_table_and_each_other=($chairTableOverlaps.Count -eq 0 -and $chairPairOverlaps.Count -eq 0)
  route_is_contained_in_dining_block=($route.x_ft -ge $m33.room_blocks.M03.x_ft -and $route.y_ft -ge $m33.room_blocks.M03.y_ft -and ($route.y_ft+$route.depth_ft) -le ($m33.room_blocks.M03.y_ft+$m33.room_blocks.M03.depth_ft) -and ($route.x_ft+$route.width_ft) -le ($m33.room_blocks.M03.x_ft+$m33.room_blocks.M03.width_ft))
  route_fits_both_nominal_door_opening_intervals=(@($doorFit|Where-Object{-not $_.route_fits_nominal_interval}).Count -eq 0)
  east_porch_remains_unselected_and_outside_shell_area_is_50_sf=($m58East.contained_in_unapproved_main_shell -eq $false -and [Math]::Abs((120.0-$m58East.shell_overlap.area_sf)-50.0) -lt 0.00001)
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
$report=[ordered]@{
  schema='forever-home.m58-east-porch-chair-route.v1'
  title='M58 — east porch route with a four-chair body arrangement'
  status='one unselected furniture-route candidate; owner/site coordination remains open'
  source_fingerprints_sha256=$sourceHashes
  source_paths=[ordered]@{M57_report=$M57ReportPath;owner_followup='Architecture/House_Design_Iteration_2026-10-28/study.json';selected_D='Architecture/Selected_Design_Iteration_2026-10-27/study.json';spec='Architecture/Kitchen_Dining_Porch_Specs.md'}
  geometry=[ordered]@{porch=$m58East.porch;dining_table=$table;chair_body_dimensions_in=@([double]$chairSpec.Groups[1].Value,[double]$chairSpec.Groups[2].Value);chair_arrangement_assumption='Four 18x20 in chair bodies, two on each 60 in long side, equally spaced by centers at 1/4 and 3/4 table length; no chairs at table ends.';chairs=$chairs;chair_table_overlaps=$chairTableOverlaps;chair_pair_overlaps=$chairPairOverlaps;chairs_overlapping_route=@($chairRoutes|Where-Object{$_.overlaps_route});route=$route;door_options=$doorFit;M57_clearance_note='The route is inside the broad 36 in table pull-back envelope, but does not overlap these four discrete chair-body proxies.'}
  checks=$checks
  failures=$failed
  assumptions=@('The east porch option is only a room-block candidate; 50 sf projects beyond the unapproved 40x42 ft test shell and the site boundary/orientation are unknown.','Chair count and 18x20 in body size come from the project specification; the two-per-long-side arrangement and exact positions are proposed solely for this screen.','Occupied chair body is represented by its 18x20 in rectangular footprint. Human body reach, occupied-person envelope, chair pull-out motion, wall thickness, door leaf/stop clear width, maneuvering and porch furniture are not represented.','The 5 ft and 6 ft door widths are nominal product-unit dimensions from the project specification, not measured clear openings.','This is not a code, accessibility, ergonomics, or construction clearance determination.')
  limitations=@('The screen shows a 36 in geometric strip between the table end and the dining room-block boundary without overlap against the four assumed chair rectangles. It does not prove the path clear of seated people, moving chairs, a door leaf, wall build-up, threshold or porch furniture.','The route overlaps the M33 uniform table pull-back envelope; this candidate relies on leaving the table end unoccupied by chairs.','Porch, furniture and door locations remain proposals. No Revit or IFC geometry was changed or validated; M-06-B and selected D remain unchanged.')
}
New-Item -ItemType Directory -Force -Path $target|Out-Null
$reportPath=Join-Path $target 'east-porch-chair-route.json'
$report|ConvertTo-Json -Depth 30|Set-Content -LiteralPath $reportPath -Encoding utf8
if($failed.Count){throw ("M58 source/geometry checks failed: {0}" -f ($failed -join ', '))}
Write-Output ("M58 source/geometry checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output ("36in route overlaps chair-body proxies: {0}; nominal door options fit: {1}" -f @($chairRoutes|Where-Object overlaps_route).Count,(@($doorFit|Where-Object route_fits_nominal_interval).Count -eq $doorFit.Count))
