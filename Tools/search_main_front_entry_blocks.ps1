param([Parameter(Mandatory=$true)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$out=[IO.Path]::GetFullPath((Join-Path $root $OutputDirectory))
if(-not $out.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Output must stay in checkout'}
if(Test-Path $out){throw 'Output already exists'}
$source=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
if((Get-FileHash $source).Hash-ne'516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB'){throw 'Selected-D changed'}
$s=Get-Content $source -Raw|ConvertFrom-Json
$kpath=Join-Path $root 'Architecture/M312_Source_Pantry_Sensitivity/artifacts/m312-kitchen-margin-sensitivity.json'
$k=Get-Content $kpath -Raw|ConvertFrom-Json
function NewStudyRect($id,$x,$y,$w,$d){[pscustomobject]@{id=$id;x=[double]$x;y=[double]$y;w=[double]$w;d=[double]$d}}
function Hit($a,$b){([math]::Min($a.x+$a.w,$b.x+$b.w)-[math]::Max($a.x,$b.x)-gt1e-6)-and([math]::Min($a.y+$a.d,$b.y+$b.d)-[math]::Max($a.y,$b.y)-gt1e-6)}
$living=$s.plans.main|Where-Object id -eq 'M-01'
$entry=$s.plans.main|Where-Object id -eq 'M-05'
$fixed=@($s.plans.main|Where-Object {$_.id-in@('M-03','M-04')})+@($s.selection.main_public_bath.search_windows)
$margin=2.0/3.0;$y=$entry.y
$candidates=[Collections.Generic.List[object]]::new()
$interfaces=[Collections.Generic.List[object]]::new()
$tested=0
for($i=0;$i-le160;$i++){
 $lx=$margin+$i*.25
 foreach($side in @('east','west')){
  $kx=if($side-eq'east'){$lx+$living.w}else{$lx-$k.kitchen_test.tested_cross_section_ft}
  $l=NewStudyRect 'M-01' $lx $y $living.w $living.d
  $kr=NewStudyRect 'M-02' $kx $y $k.kitchen_test.tested_cross_section_ft $k.kitchen_test.tested_depth_ft
  if($l.x-lt$margin-or$kr.x-lt$margin-or$l.x+$l.w-gt40-$margin-or$kr.x+$kr.w-gt40-$margin){continue}
  $blocked=$false;foreach($r in @($l,$kr)){foreach($b in $fixed){if(Hit $r $b){$blocked=$true}}};if($blocked){continue}
  for($j=0;$j-le160;$j++){
   $e=NewStudyRect 'M-05' ($margin+$j*.25) $y $entry.w $entry.d
   if($e.x+$e.w-gt40-$margin){continue};$tested++
   $blocked=$false;foreach($b in (@($l,$kr)+$fixed)){if(Hit $e $b){$blocked=$true}};if($blocked){continue}
   $movement=[math]::Abs($l.x-$living.x)+[math]::Abs($e.x-$entry.x)
   $candidates.Add([pscustomobject]@{living=$l;kitchen=$kr;entry=$e;kitchen_side=$side;living_entry_translation_ft=$movement;shared_boundary_ft=[math]::Min($l.d,$kr.d)})
   foreach($social in @($l,$kr)){
    $touch=[math]::Abs($e.x+$e.w-$social.x)-lt1e-6-or[math]::Abs($social.x+$social.w-$e.x)-lt1e-6
    $span=[math]::Min($e.y+$e.d,$social.y+$social.d)-[math]::Max($e.y,$social.y)
    if($touch-and$span-ge([double]$k.route_contract.width_in/12)){$interfaces.Add([pscustomobject]@{living=$l;kitchen=$kr;entry=$e;entry_adjacent_to=$social.id;shared_span_ft=$span;living_entry_translation_ft=$movement;kitchen_side=$side})}
   }
  }
 }
}
New-Item -ItemType Directory $out|Out-Null
$interfaces|Sort-Object living_entry_translation_ft,kitchen_side|ConvertTo-Json -Depth 10|Set-Content (Join-Path $out 'front-entry-shared-interfaces.json')
Write-Output "Direct entry/social shared-interface candidates: $($interfaces.Count); 3-ft project route proxy only, no doorway or approach verified"
$report=[ordered]@{status='bounded static block search; no route or layout selected';source_sha256=(Get-FileHash $source).Hash;kitchen_input_sha256=(Get-FileHash $kpath).Hash;grid_ft=.25;shell_ft=@(40,42);pantry='source 5x7 fixed';front_entry='source south row; exterior door/approach unresolved';tested=$tested;passing=$candidates.Count;examples=@($candidates|Sort-Object living_entry_translation_ft,kitchen_side|Select-Object -First 12);limitations=@('Living/source area retained; kitchen uses unselected M312 envelope. Dining/pantry held fixed in this first screen.','No furniture mapping, door/approach, route, floor/stair, wall thickness or structural test.','No code compliance or construction readiness established; A protected and B unassigned.')}
$report|ConvertTo-Json -Depth 12|Set-Content (Join-Path $out 'front-entry-blocks.json')
Write-Output "Tested $tested; static candidates $($candidates.Count)"
