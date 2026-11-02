param([string]$PantryReport,[string]$Routes,[string]$Interfaces,[string]$Output)
$ErrorActionPreference='Stop';if(Test-Path $Output){throw 'Output exists'}
$p=Get-Content $PantryReport -Raw|ConvertFrom-Json;$r=Get-Content $Routes -Raw|ConvertFrom-Json;$f=Get-Content $Interfaces -Raw|ConvertFrom-Json
if($p.route_sha256-ne(Get-FileHash $Routes).Hash-or$p.interface_sha256-ne(Get-FileHash $Interfaces).Hash){throw 'Source hash mismatch'}
function Area($a,$b){[math]::Max(0.0,[math]::Min($a.x+$a.w,$b.x+$b.w)-[math]::Max($a.x,$b.x))*[math]::Max(0.0,[math]::Min($a.y+$a.d,$b.y+$b.d)-[math]::Max($a.y,$b.y))}
$checked=0
foreach($row in $p.placements){
 if($row.connector_spur_count-le0){continue};$case=@($r.results|Where-Object candidate -eq $row.candidate)[0];$layout=@($f.results|Where-Object {$_.candidate-eq$row.candidate-and$_.mirrored-eq$case.mirrored})[0]
 if([math]::Abs($row.pantry.w*$row.pantry.d-35)-gt1e-6){throw 'Pantry area mismatch'}
 $spur=$row.connector_spur_example[0];$a=$spur.from_route_ft;$b=$spur.to_pantry_ft;$h=$r.width_ft/2
 if(@($case.path|Where-Object {[math]::Abs($_[0]-$a[0])-lt1e-6-and[math]::Abs($_[1]-$a[1])-lt1e-6}).Count-eq0){throw 'Spur not joined to route'}
 if([math]::Abs($a[1]-$b[1])-gt1e-6){throw 'Unexpected non-horizontal spur'}
 $q=[pscustomobject]@{x=[math]::Min($a[0],$b[0])-$h;y=$a[1]-$h;w=[math]::Abs($b[0]-$a[0])+$r.width_ft;d=$r.width_ft}
 foreach($key in @('x','y','w','d')){if([math]::Abs($q.$key-$spur.swept_rect.$key)-gt1e-6){throw 'Swept rectangle mismatch'}}
 $bridge=[pscustomobject]@{x=$case.bridge.X;y=$case.bridge.Y;w=$case.bridge.W;d=$case.bridge.D}
 if([math]::Abs((Area $q $bridge)-$q.w*$q.d)-gt1e-6){throw 'Spur outside connector'}
 $end=[pscustomobject]@{x=$b[0]-$h;y=$b[1]-$h;w=$r.width_ft;d=$r.width_ft}
 if([math]::Abs((Area $end $row.pantry)-$end.w*$end.d)-gt1e-6){throw 'Endpoint not fully inside pantry'}
 foreach($o in $layout.obstacles){if((Area $q $o)-gt1e-6){throw 'Kitchen obstacle collision'}}
 $checked++
}
[ordered]@{status='pass';placements_checked=$checked;report_sha256=(Get-FileHash $PantryReport).Hash;limitations='Validates stored example spur only; no shelving, door leaf/swing or clear opening verified'}|ConvertTo-Json|Set-Content $Output
Write-Output "PASS $checked example pantry spurs"
