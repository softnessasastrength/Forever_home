param([Parameter(Mandatory=$true)][string]$InputDirectory,[Parameter(Mandatory=$true)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$out=[IO.Path]::GetFullPath((Join-Path $root $OutputDirectory))
if(-not $out.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)-or(Test-Path $out)){throw 'Require new output inside checkout'}
$inputPath=Join-Path $root "$InputDirectory/front-entry-shared-interfaces.json"
$cases=@(Get-Content $inputPath -Raw|ConvertFrom-Json)
$sourcePath=Join-Path $root 'Architecture/M178_Halfwall_Seating_Candidate_2026-10-31/m178-study.json'
$source=Get-Content $sourcePath -Raw|ConvertFrom-Json
$mPath=Join-Path $root 'Architecture/M312_Source_Pantry_Sensitivity/artifacts/m312-kitchen-margin-sensitivity.json'
$m=Get-Content $mPath -Raw|ConvertFrom-Json
$width=[double]$m.route_contract.width_in/12
function Rect($x,$y,$w,$d){[pscustomobject]@{x=$x;y=$y;w=$w;d=$d}}
function Overlap($a,$b){([math]::Min($a.x+$a.w,$b.x+$b.w)-[math]::Max($a.x,$b.x)-gt1e-6)-and([math]::Min($a.y+$a.d,$b.y+$b.d)-[math]::Max($a.y,$b.y)-gt1e-6)}
function Portals($a,$b,$obstacles){
 $x=if([math]::Abs($a.x+$a.w-$b.x)-lt1e-6){$b.x}elseif([math]::Abs($b.x+$b.w-$a.x)-lt1e-6){$a.x}else{return @()}
 $lo=[math]::Max($a.y,$b.y)+$width/2;$hi=[math]::Min($a.y+$a.d,$b.y+$b.d)-$width/2
 $result=@();for($y=$lo;$y-le$hi+1e-7;$y+=.25){$patch=Rect ($x-$width/2) ($y-$width/2) $width $width;$blocked=$false;foreach($o in $obstacles){if(Overlap $patch $o){$blocked=$true}};if(-not$blocked){$result+=,[pscustomobject]@{x=$x;y=$y;patch=$patch}}};return $result
}
$results=@();$index=0
foreach($c in $cases){$index++;foreach($mirror in @($false,$true)){
 $k=$c.kitchen
 $local=@((Rect 0 (($k.d-12.5)/2) 2 12.5))
 foreach($key in @('island_rect_ft','assumed_stool_rect_ft')){$r=$source.candidate.$key;$local+=Rect $r[0] $r[1] $r[2] $r[3]}
 $obs=@();foreach($r in $local){$x=if($mirror){$k.w-$r.x-$r.w}else{$r.x};$obs+=Rect ($k.x+$x) ($k.y+$r.y) $r.w $r.d}
 $social=if($c.entry_adjacent_to-eq'M-01'){$c.living}else{$k}
 $entryPortals=@(Portals $c.entry $social $obs);$livingPortals=@(Portals $k $c.living $obs)
 $results+=,[pscustomobject]@{candidate=$index;mirrored=$mirror;living=$c.living;kitchen=$k;entry=$c.entry;entry_adjacent_to=$c.entry_adjacent_to;obstacles=$obs;entry_clear_patch_count=$entryPortals.Count;living_clear_patch_count=$livingPortals.Count;both_interfaces_clear=($entryPortals.Count-gt0-and$livingPortals.Count-gt0);entry_portals=$entryPortals;living_portals=$livingPortals}
}}
New-Item -ItemType Directory $out|Out-Null
$report=[ordered]@{status='furnished interface proxy screen; no continuous route selected';input_sha256=(Get-FileHash $inputPath).Hash;proxy_source_sha256=(Get-FileHash $sourcePath).Hash;kitchen_source_sha256=(Get-FileHash $mPath).Hash;patch_width_ft=$width;tested=$results.Count;both_clear=@($results|Where-Object both_interfaces_clear).Count;results=$results;limitations=@('Square approach patches straddle abstract shared boundaries; door widths/swings and wall thickness unresolved.','Living and entry furnishings omitted; separate clear interfaces do not establish a continuous connecting route.','Source countertop/island/stool proxies only; no appliance-open, plumbing, site, code or construction result.')}
$report|ConvertTo-Json -Depth 15|Set-Content (Join-Path $out 'furnished-interfaces.json')
Write-Output "$($report.both_clear)/$($report.tested) orientation cases clear both interface patches"
