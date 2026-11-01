param([Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference='Stop';if(Test-Path $Output){throw 'Output exists'}
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$base=Join-Path $root 'Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts'
$routePath=Join-Path $base 'living-furnished-route-report.json';$interfacePath=Join-Path $base 'furnished-interfaces.json';$pantryPath=Join-Path $base 'pantry-options.json'
$routes=Get-Content $routePath -Raw|ConvertFrom-Json;$interfaces=Get-Content $interfacePath -Raw|ConvertFrom-Json;$pantries=Get-Content $pantryPath -Raw|ConvertFrom-Json
if($routes.input_sha256-ne(Get-FileHash $interfacePath).Hash-or$pantries.route_sha256-ne(Get-FileHash $routePath).Hash){throw 'Candidate source lineage mismatch'}
$c=@($routes.results|Where-Object {$_.candidate-eq21-and$_.route_found})
if($c.Count-ne1){throw 'Require exactly one candidate21 route'};$c=$c[0]
$l=@($interfaces.results|Where-Object {$_.candidate-eq21-and$_.mirrored-eq$c.mirrored})[0]
$p=@($pantries.placements|Where-Object {$_.candidate-eq21-and$_.connector_spur_count-gt0}|Sort-Object {[double]$_.pantry.x} -Descending)[0]
if($null-eq$p){throw 'No connected pantry'}
# The shortest spur is not sufficient: the first north-adjacent placement
# grazes the main swept route once native wall thickness is applied.  Prefer
# the furthest east candidate in this analysis-only family, which leaves the
# route corridor clear while preserving the 35 sf pantry area.
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json';$s=Get-Content $selectedPath -Raw|ConvertFrom-Json
if((Get-FileHash $selectedPath).Hash-ne$routes.selected_d_sha256){throw 'Selected-D changed'}
$fingerprints=[ordered]@{};foreach($path in @($routePath,$interfacePath,$pantryPath,$selectedPath)){$fingerprints[$path.Substring($root.Length+1).Replace('\','/')]=(Get-FileHash $path).Hash}
$result=[ordered]@{
 schema='forever-home-main-floor-candidate-input-v1';status='unselected coordinated proxy proposal for disposable Revit comparison';candidate=21
 source_sha256=$fingerprints;units='feet; schematic Selected-D axes; no site orientation'
 main_envelope_ft=$s.shells.main;clear_ceiling_cases_ft=@(8,9,10);floor_to_floor='TBD';stair='TBD'
 room_blocks=@($l.entry,$l.living,$l.kitchen,[pscustomobject]@{id='M-03';x=$c.dining.X;y=$c.dining.Y;w=$c.dining.W;d=$c.dining.D},[pscustomobject]@{id='M-04';x=$p.pantry.x;y=$p.pantry.y;w=$p.pantry.w;d=$p.pantry.d})
 porch=$c.porch;connector_search_envelope=$c.bridge;main_route=$c.path;route_width_ft=$routes.width_ft;pantry_spur=$p.connector_spur_example[0]
 kitchen_proxies=$l.obstacles;dining_proxies=$c.diningObstacles;living_proxies=$c.livingObstacles
 bathroom_reservations=$s.selection.main_public_bath.search_windows;M06='unassigned';B='unassigned';A='protected'
 inherited_core=$s.stair_core_test;porch_nominal_door_reservation_ft=$c.door_reservation_ft
 pantry_door='unselected; older nominal30in conflicts with 36in route proxy; owner comparison pending'
 walls='unselected assembly/thickness; template type may be used only as labeled derivative placeholder'
 limitations=@('Room envelopes are schematic clear rectangles; no finish/wall offset is approved.','TV/hearth and furniture proxies are historical reservations, not selected products or thermal clearances.','No native Revit, IFC or source-baseline modification is performed by this packager.','Doors, appliances, shelving, threshold, structure, MEP, final core and site remain unresolved; no compliance or construction approval.')
}
$full=[IO.Path]::GetFullPath((Join-Path $root $Output));if(-not$full.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Output outside checkout'}
[IO.Directory]::CreateDirectory((Split-Path $full))|Out-Null
[IO.File]::WriteAllText($full,($result|ConvertTo-Json -Depth 30)+[Environment]::NewLine,[Text.UTF8Encoding]::new($false))
Write-Output 'Packaged five proposed room blocks, exterior porch, furnished route and pantry spur; all source hashes match'
