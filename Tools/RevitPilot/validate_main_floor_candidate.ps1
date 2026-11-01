param([Parameter(Mandatory=$true)][string]$RunDirectory,[Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference='Stop';if(Test-Path $Output){throw 'Output exists'}
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$dir=(Resolve-Path $RunDirectory).Path
if(-not$dir.StartsWith((Join-Path $root '.local/revit-pilot/main-floor-candidate')+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Require isolated main-floor run directory'}
$m=Get-Content (Join-Path $dir 'manifest.json') -Raw|ConvertFrom-Json
if($m.schema-ne'forever-home-main-floor-candidate-revit-v1'){throw 'Wrong schema'}
$inputPath=Join-Path $root $m.input
if((Get-FileHash $inputPath).Hash-ne$m.input_sha256){throw 'Input hash mismatch'}
$input=Get-Content $inputPath -Raw|ConvertFrom-Json
foreach($pin in $input.source_sha256.PSObject.Properties){if((Get-FileHash (Join-Path $root $pin.Name)).Hash-ne$pin.Value){throw 'Upstream input hash mismatch'}}
$saved=[IO.Path]::GetFullPath((Join-Path $dir $m.saved_rvt));if(-not$saved.StartsWith($dir+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'RVT outside run'}
if((Get-FileHash $saved).Hash-ne$m.saved_rvt_sha256){throw 'RVT hash mismatch'}
if($m.wall_count-ne42-or$m.records.Count-ne42-or$m.native_wall_inventory.Count-ne42-or$m.model_curve_count-ne252-or$m.wall_type_selected-ne$false){throw 'Unexpected counts or selected wall type'}
$deviations=@();$collisions=@();$tested=0
foreach($wall in $m.native_wall_inventory){
 $expected=@($m.records|Where-Object element_id -eq $wall.element_id);if($expected.Count-ne1){throw 'Missing/duplicate native element ID'};$expected=$expected[0]
 foreach($side in @('start_ft','end_ft')){for($axis=0;$axis-lt3;$axis++){if([math]::Abs($wall.$side[$axis]-$expected.$side[$axis])-gt1e-6){$deviations+=[pscustomobject]@{id=$wall.element_id;side=$side;axis=$axis}}}}
 if(@(8,9,10)-notcontains$wall.unconnected_height_ft-or$wall.width_ft-le0){throw 'Invalid wall height/width'}
 for($axis=0;$axis-lt3;$axis++){if([double]::IsNaN($wall.bounds_min_ft[$axis])-or[double]::IsInfinity($wall.bounds_max_ft[$axis])-or$wall.bounds_max_ft[$axis]-lt$wall.bounds_min_ft[$axis]){throw 'Invalid native bounds'}}
 $offset=($wall.unconnected_height_ft-8)*60;$h=$input.route_width_ft/2
 $paths=@(@{name='main';points=$input.main_route},@{name='pantry';points=@($input.pantry_spur.from_route_ft,$input.pantry_spur.to_pantry_ft)})
 foreach($path in $paths){for($i=0;$i-lt$path.points.Count;$i++){$a=$path.points[$i];$b=if($i-eq0){$a}else{$path.points[$i-1]};$xmin=[math]::Min($a[0],$b[0])-$h+$offset;$xmax=[math]::Max($a[0],$b[0])+$h+$offset;$ymin=[math]::Min($a[1],$b[1])-$h;$ymax=[math]::Max($a[1],$b[1])+$h
  $dx=[math]::Min($xmax,$wall.bounds_max_ft[0])-[math]::Max($xmin,$wall.bounds_min_ft[0]);$dy=[math]::Min($ymax,$wall.bounds_max_ft[1])-[math]::Max($ymin,$wall.bounds_min_ft[1]);$tested++
  if($dx-gt1e-6-and$dy-gt1e-6){$collisions+=[pscustomobject]@{wall=$wall.element_id;case_height_ft=$wall.unconnected_height_ft;path=$path.name;segment=$i;bounding_overlap_sf=$dx*$dy}}
 }}
}
$status=if($deviations.Count-eq0-and$collisions.Count-eq0){'pass'}else{'fail'}
[ordered]@{status=$status;manifest_sha256=(Get-FileHash (Join-Path $dir 'manifest.json')).Hash;saved_rvt_sha256=$m.saved_rvt_sha256;native_wall_count=42;curve_deviations=$deviations;route_bound_collisions=$collisions;comparisons=$tested;limitations='Native axis-aligned wall bounds are conservative; collision requires diagnosis. No reopened inventory, door clear width/swing, IFC, code or construction approval.'}|ConvertTo-Json -Depth 8|Set-Content $Output
Write-Output "$status : $($deviations.Count) curve deviations; $($collisions.Count) route/wall bound collisions; $tested comparisons"
if($status-ne'pass'){throw 'Native candidate validation failed; inspect output evidence'}
