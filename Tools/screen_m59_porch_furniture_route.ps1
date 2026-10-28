param([string]$OutputDirectory='Architecture/M59_Porch_Furniture_Route_2026-10-28',[string]$M58ReportPath='Architecture/M58_East_Porch_Chair_Route_2026-10-28/east-porch-chair-route.json')

$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$rootPath=[IO.Path]::GetFullPath($root)
$target=[IO.Path]::GetFullPath((Join-Path $rootPath $OutputDirectory))
$prefix=$rootPath.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if(-not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside the repository.'}
$m58Path=[IO.Path]::GetFullPath((Join-Path $root $M58ReportPath))
if(-not $m58Path.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'M58ReportPath must resolve inside the repository.'}
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$specPath=Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
$m58=Get-Content -Raw $m58Path|ConvertFrom-Json
$proposal=Get-Content -Raw $proposalPath|ConvertFrom-Json
$spec=Get-Content -Raw $specPath
$hashes=[ordered]@{
  M58_report=(Get-FileHash $m58Path -Algorithm SHA256).Hash.ToLowerInvariant()
  owner_followup_study=(Get-FileHash $proposalPath -Algorithm SHA256).Hash.ToLowerInvariant()
  kitchen_dining_porch_specs=(Get-FileHash $specPath -Algorithm SHA256).Hash.ToLowerInvariant()
}
if($hashes.M58_report -ne '7f3589ab80021fba736a2736937e9ba142a01c9340775d41d5554d93a573b42e'){throw 'M58 report is not the reviewed east-porch chair-route candidate.'}
if($m58.failures.Count -ne 0 -or $m58.source_fingerprints_sha256.owner_followup_study -ne $hashes.owner_followup_study -or $m58.source_fingerprints_sha256.kitchen_dining_porch_specs -ne $hashes.kitchen_dining_porch_specs){throw 'M58 report source fingerprints do not match current sources.'}
if($proposal.source_selected_D_sha256 -ne (Get-FileHash (Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json') -Algorithm SHA256).Hash.ToLowerInvariant()){throw 'Owner-follow-up selected-D source fingerprint is stale.'}
$furnitureLine=[regex]::Match($spec,'(?m)^\| Furniture zone \| .*').Value
$tableMatch=[regex]::Match($furnitureLine,'\*\*(\d+)\s*×\s*(\d+)\"\*\*')
$pathMatch=[regex]::Match($furnitureLine,'leave \*\*(\d+)\"')
$chairMatch=[regex]::Match($spec,'(?m)^\| Chairs \| \*\*(\d+)\" × (\d+)\"\*\* seat')
$doorLine=[regex]::Match($spec,'(?m)^\| Pair width \| .*').Value
$doorMatches=[regex]::Matches($doorLine,'(\d+)\x27-(\d+)\"')
$exitMatch=[regex]::Match($spec,'(?m)^\| Exterior door or screen door \| \*\*(\d+)\x27-(\d+)\"')
if(-not $tableMatch.Success -or -not $pathMatch.Success -or -not $chairMatch.Success -or $doorMatches.Count -lt 2 -or -not $exitMatch.Success){throw 'Could not parse porch furniture, chair, or door dimensions from the project specification.'}
$tableShortIn=[double]$tableMatch.Groups[1].Value;$tableLongIn=[double]$tableMatch.Groups[2].Value;$pathW=[double]$pathMatch.Groups[1].Value/12.0
$chairX=[double]$chairMatch.Groups[1].Value/12.0;$chairY=[double]$chairMatch.Groups[2].Value/12.0
$exitFeet=[double]$exitMatch.Groups[1].Value
$exitInches=[double]$exitMatch.Groups[2].Value
$exitDoorW=$exitFeet+($exitInches/12.0)
$porchW=[double]$m58.geometry.porch.width_ft;$porchD=[double]$m58.geometry.porch.depth_ft
function Rect($name,$x,$y,$w,$h){[ordered]@{name=$name;x_ft=[double]$x;y_ft=[double]$y;width_ft=[double]$w;depth_ft=[double]$h}}
function Overlap($a,$b){$dx=[Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft);$dy=[Math]::Min(($a.y_ft+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($a.y_ft,$b.y_ft);$hit=($dx -gt 0.000001 -and $dy -gt 0.000001);[ordered]@{overlap=$hit;area_sf=if($hit){[Math]::Round($dx*$dy,5)}else{0}}}
$tableLong=$tableLongIn/12.0;$tableShort=$tableShortIn/12.0
$table=Rect '30x48in porch table, long side east-west' (($porchW-$tableLong)/2.0) ($porchD-$tableShort) $tableLong $tableShort
$quarterCenter=[double]$table['x_ft']+([double]$table['width_ft']/4.0)
$threeQuarterCenter=[double]$table['x_ft']+(3.0*[double]$table['width_ft']/4.0)
$chairCenters=@($quarterCenter,$threeQuarterCenter)
$chairs=@()
foreach($cx in $chairCenters){$chairs+=,(Rect ("porch chair body at x={0:N3}ft" -f $cx) ($cx-$chairX/2.0) ($table.y_ft-$chairY) $chairX $chairY)}
$routeY=($porchD-$pathW)/2.0
$route=@(
  (Rect 'west door connector' 0 $routeY $pathW $pathW),
  (Rect '30in cross-porch lane' 0 ($routeY-$pathW) $porchW $pathW),
  (Rect 'east garden-door connector' ($porchW-$pathW) $routeY $pathW $pathW)
)
$routeFurniture=@(foreach($segment in $route){foreach($item in @($table)+$chairs){$o=Overlap $segment $item;if($o.overlap){[ordered]@{segment=$segment.name;item=$item.name;overlap_sf=$o.area_sf}}}})
$doorCenter=$porchD/2.0
$frenchWidths=@(foreach($d in $m58.geometry.door_options){[double]$d.nominal_door_width_ft})
$porchOriginY=[double]$m58.geometry.porch.y_ft
$frenchFits=@(foreach($w in $frenchWidths){$globalOpening=@(($m58.geometry.door_options|Where-Object{$_.nominal_door_width_ft -eq $w})[0].centered_opening_interval_ft);$opening=@(([double]$globalOpening[0]-$porchOriginY),([double]$globalOpening[1]-$porchOriginY));[ordered]@{nominal_width_ft=$w;opening_interval_local_ft=$opening;entry_connector_fits=(($routeY -ge $opening[0]-0.000001)-and ($routeY+$pathW) -le ($opening[1]+0.000001))}})
$halfExitWidth=[double]$exitDoorW/2.0
$exitStart=[double]$doorCenter-$halfExitWidth
$exitEnd=[double]$doorCenter+$halfExitWidth
$exitInterval=@($exitStart,$exitEnd)
$exitFits=(($routeY -ge $exitInterval[0]-0.000001)-and ($routeY+$pathW) -le ($exitInterval[1]+0.000001))
$checks=[ordered]@{
  source_fingerprints_match=($m58.source_fingerprints_sha256.owner_followup_study -eq $hashes.owner_followup_study -and $m58.source_fingerprints_sha256.kitchen_dining_porch_specs -eq $hashes.kitchen_dining_porch_specs -and $proposal.source_selected_D_sha256 -eq (Get-FileHash (Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json') -Algorithm SHA256).Hash.ToLowerInvariant())
  furniture_table_matches_30x48_spec=([Math]::Abs($table.width_ft-4.0) -lt 0.000001 -and [Math]::Abs($table.depth_ft-2.5) -lt 0.000001)
  two_spec_derived_chair_proxies_fit_inside_porch=($chairs.Count -eq 2 -and @($chairs|Where-Object{$_.x_ft -lt 0 -or $_.y_ft -lt 0 -or ($_.x_ft+$_.width_ft) -gt $porchW -or ($_.y_ft+$_.depth_ft) -gt $porchD}).Count -eq 0)
  table_and_chairs_do_not_overlap=(@(foreach($chair in $chairs){if((Overlap $table $chair).overlap){$chair.name}}).Count -eq 0)
  all_route_segments_fit_inside_porch=(@($route|Where-Object{$_.x_ft -lt 0 -or $_.y_ft -lt 0 -or ($_.x_ft+$_.width_ft) -gt $porchW -or ($_.y_ft+$_.depth_ft) -gt $porchD}).Count -eq 0)
  route_segments_connect_as_a_continuous_30in_path=([Math]::Abs(($route[0].y_ft)-($route[1].y_ft+$route[1].depth_ft)) -lt 0.000001 -and [Math]::Abs(($route[2].y_ft)-($route[1].y_ft+$route[1].depth_ft)) -lt 0.000001)
  route_has_no_overlap_with_table_or_chair_bodies=($routeFurniture.Count -eq 0)
  west_french_door_nominal_intervals_contain_entry_path=(@($frenchFits|Where-Object{-not $_.entry_connector_fits}).Count -eq 0)
  east_3ft_exterior_door_nominal_interval_contains_exit_path=$exitFits
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
$report=[ordered]@{
 schema='forever-home.m59-porch-furniture-route.v1'
 title='M59 — porch table and garden-door route screen'
 status='one unselected furniture and route arrangement'
 source_fingerprints_sha256=$hashes
 source_paths=[ordered]@{M58_report=$M58ReportPath;owner_followup='Architecture/House_Design_Iteration_2026-10-28/study.json';spec='Architecture/Kitchen_Dining_Porch_Specs.md'}
 geometry=[ordered]@{porch_local_bounds_ft=[ordered]@{width=$porchW;depth=$porchD};coordinate_note='Local origin is the west/south inside corner of the proposed east-attached porch; west is the dining opening and east is the garden-side opening.';furniture=[ordered]@{table=$table;chair_dimensions_in=@([double]$chairMatch.Groups[1].Value,[double]$chairMatch.Groups[2].Value);chairs=$chairs;arrangement='30x48 table with two 18x20 chair-body proxies on its north long side; all dimensions from project specs, seating pattern and placement are proposals.'};route_segments=$route;route_width_in=$pathW*12.0;nominal_french_door_options=$frenchFits;nominal_exterior_door=[ordered]@{width_ft=$exitDoorW;centered_interval_ft=$exitInterval;route_connector_fits=$exitFits}}
 checks=$checks
 failures=$failed
 assumptions=@('The M58 east porch candidate is used as a 12x10 ft clear-interior rectangle; 50 sf remains beyond the unapproved test shell.','Both openings are assumed centered on opposing 10 ft end walls, with no threshold or wall build-up; actual door locations, products and swings remain unselected.','A 30in-wide path is assembled from three rectangles: the centered west connector, a cross-porch lane, and a centered east connector. They share full-width boundaries but the turning shape is not a turning-clearance or accessibility claim.','The 30x48 table and two 18x20 chair rectangles are generic source-dimension proxies, not selected outdoor products. Chairs are stationary; people and chair movement are omitted.','Nominal opening intervals do not establish clear width with door leaves, stops, hardware or swing.')
 limitations=@('This checks one geometric arrangement and not actual door maneuvering, furniture usability, weather exposure, drainage, grade, egress, code, accessibility or site constraints.','The project specification allows different porch-table choices; the 30x48 rectangle is an unselected option.','No Revit or IFC geometry was changed or validated; selected D and M-06-B remain untouched.')
}
New-Item -ItemType Directory -Force -Path $target|Out-Null
$reportPath=Join-Path $target 'porch-furniture-route.json'
$report|ConvertTo-Json -Depth 30|Set-Content -LiteralPath $reportPath -Encoding utf8
if($failed.Count){throw ("M59 source/geometry checks failed: {0}" -f ($failed -join ', '))}
Write-Output ("M59 source/geometry checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output ("Porch furniture route segments: {0}; overlaps with furniture: {1}" -f $route.Count,$routeFurniture.Count)
