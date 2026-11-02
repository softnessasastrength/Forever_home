param([string]$Routes,[string]$Interfaces,[string]$Output,[string]$PantryReport)
$ErrorActionPreference='Stop'
if(Test-Path $Output){throw 'Output exists'}
Add-Type -AssemblyName System.Drawing
$r=Get-Content $Routes -Raw|ConvertFrom-Json;$f=Get-Content $Interfaces -Raw|ConvertFrom-Json
$c=@($r.results|Where-Object route_found)[0];$l=@($f.results|Where-Object {$_.candidate-eq$c.candidate-and$_.mirrored-eq$c.mirrored})[0]
$bmp=[Drawing.Bitmap]::new(1100,1000);$g=[Drawing.Graphics]::FromImage($bmp);$g.Clear([Drawing.Color]::Ivory)
$g.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
$font=[Drawing.Font]::new('Arial',11);$pen=[Drawing.Pen]::new([Drawing.Color]::DimGray,1)
function Box($q,$color,$label){$x=[single](40+15*$q.x);$y=[single](90+15*(52-$q.y-$q.d));$w=[single](15*$q.w);$d=[single](15*$q.d);$brush=[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($color));$g.FillRectangle($brush,$x,$y,$w,$d);$g.DrawRectangle($pen,$x,$y,$w,$d);$g.DrawString($label,$font,[Drawing.Brushes]::Black,$x+4,$y+4);$brush.Dispose()}
$g.DrawString("Main-floor proposal: candidate $($c.candidate)",$font,[Drawing.Brushes]::Black,40,20)
$g.DrawString('Front at bottom; dimensions in feet; no site orientation. Unselected study.',$font,[Drawing.Brushes]::Black,40,45)
Box ([pscustomobject]@{x=0;y=0;w=40;d=42}) '#fffdf6' '40 x 42 shell'
Box $l.living '#ebdcc0' 'Living 16 x 15'
Box $l.kitchen '#bed2af' 'Kitchen 13.5 x 13.25'
Box $l.entry '#edcdb2' 'Arrival'
foreach($key in @('bridge','dining','porch')){$q=$c.$key;Box ([pscustomobject]@{x=$q.X;y=$q.Y;w=$q.W;d=$q.D}) '#d3e6eb' $key}
$s=Get-Content Architecture/Selected_Design_Iteration_2026-10-27/study.json -Raw|ConvertFrom-Json
foreach($q in $s.selection.main_public_bath.search_windows){Box $q '#edb5ae' 'Bath reserve'}
if($PantryReport){$p=Get-Content $PantryReport -Raw|ConvertFrom-Json;$pantry=@($p.placements|Where-Object {$_.candidate-eq$c.candidate-and$_.connector_spur_count-gt0})[0];Box $pantry.pantry '#d7c7aa' 'Pantry proposal'}else{Box ($s.plans.main|Where-Object id -eq 'M-04') '#d7c7aa' 'Pantry 5 x 7'}
foreach($q in $l.obstacles){Box $q '#a49177' ''}
foreach($q in $c.diningObstacles){Box ([pscustomobject]@{x=$q.X;y=$q.Y;w=$q.W;d=$q.D}) '#b8a4bf' ''}
foreach($q in $c.livingObstacles){Box ([pscustomobject]@{x=$q.X;y=$q.Y;w=$q.W;d=$q.D}) '#d9ac88' ''}
$points=[Drawing.PointF[]]@($c.path|ForEach-Object {[Drawing.PointF]::new([single](40+15*$_[0]),[single](90+15*(52-$_[1])))})
$routePen=[Drawing.Pen]::new([Drawing.Color]::FromArgb(85,20,120,145),45);$g.DrawLines($routePen,$points)
$line=[Drawing.Pen]::new([Drawing.Color]::DarkSlateGray,2);$g.DrawLines($line,$points)
$g.DrawString("Blue: 36-in swept proxy`nPurple: dining bodies/use zones`nBrown: kitchen proxies`nPink: A/B reservations`n`nNominal porch opening: 5 ft`nDoor swing/clear width TBD`nLiving furniture omitted`nCore/assemblies/site unresolved",$font,[Drawing.Brushes]::Black,690,140)
$g.DrawString('Study geometry only; no code, structural or construction approval.',$font,[Drawing.Brushes]::Black,40,940)
$bmp.Save([IO.Path]::GetFullPath($Output),[Drawing.Imaging.ImageFormat]::Png)
$line.Dispose();$routePen.Dispose();$font.Dispose();$pen.Dispose();$g.Dispose();$bmp.Dispose()
