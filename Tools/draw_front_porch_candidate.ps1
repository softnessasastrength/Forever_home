param([string]$Routes,[string]$Interfaces,[string]$Output)
$ErrorActionPreference='Stop'
if(Test-Path $Output){throw 'Output exists'}
$r=Get-Content $Routes -Raw|ConvertFrom-Json;$f=Get-Content $Interfaces -Raw|ConvertFrom-Json
$c=@($r.results|Where-Object route_found)[0];if($null-eq$c){throw 'No passing candidate'}
$layout=@($f.results|Where-Object {$_.candidate-eq$c.candidate-and$_.mirrored-eq$c.mirrored})[0]
$svg=[Collections.Generic.List[string]]::new()
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 690"><rect width="740" height="690" fill="#fffdf6"/><g font-family="sans-serif" font-size="12">')
$svg.Add('<text x="30" y="25" font-size="18">Main-floor proposal — candidate '+$c.candidate+'</text><text x="30" y="45">Schematic feet; front at bottom. No site orientation. Unselected.</text>')
function DrawRect($q,$fill,$label){$x=40+10*$q.x;$y=80+10*(52-$q.y-$q.d);$w=10*$q.w;$d=10*$q.d;$svg.Add("<rect x='$x' y='$y' width='$w' height='$d' fill='$fill' fill-opacity='.4' stroke='#555'/>");if($label){$safe=[Security.SecurityElement]::Escape($label);$svg.Add("<text x='$($x+4)' y='$($y+16)'>$safe</text>")}}
DrawRect ([pscustomobject]@{x=0;y=0;w=40;d=42}) 'none' '40 x 42 ft shell'
DrawRect $layout.living '#e9d9bb' 'Living 16 x 15'
DrawRect $layout.kitchen '#b4c8a0' 'Kitchen 13.5 x 13.25'
DrawRect $layout.entry '#e8caaa' 'Front arrival'
foreach($key in @('bridge','dining','porch')){$q=$c.$key;DrawRect ([pscustomobject]@{x=$q.X;y=$q.Y;w=$q.W;d=$q.D}) '#c9e2e7' $key}
foreach($q in $layout.obstacles){DrawRect $q '#847461' ''}
foreach($q in $c.diningObstacles){DrawRect ([pscustomobject]@{x=$q.X;y=$q.Y;w=$q.W;d=$q.D}) '#947f9d' ''}
$s=Get-Content Architecture/Selected_Design_Iteration_2026-10-27/study.json -Raw|ConvertFrom-Json
foreach($q in $s.selection.main_public_bath.search_windows){DrawRect $q '#f2b6ae' 'Unassigned bath reserve'}
DrawRect ($s.plans.main|Where-Object id -eq 'M-04') '#d3c5a8' 'Pantry 5 x 7'
$points=($c.path|ForEach-Object {"$(40+10*$_[0]),$(80+10*(52-$_[1]))"})-join' '
$svg.Add("<polyline points='$points' fill='none' stroke='#378b98' stroke-opacity='.28' stroke-width='30' stroke-linejoin='miter'/><polyline points='$points' fill='none' stroke='#175364' stroke-width='1.5'/>")
$svg.Add('<text x="470" y="100">Blue band: 36-in swept proxy</text><text x="470" y="125">Purple: dining body/use zones</text><text x="470" y="150">Brown: kitchen proxies</text><text x="470" y="175">Pink: protected/unassigned A/B</text><text x="470" y="210">No actual doors or wall assemblies.</text><text x="470" y="235">Living/entry furnishings omitted.</text><text x="470" y="260">Core and site remain unresolved.</text><text x="30" y="660">Nominal 5-ft porch-door reservation; swing, clear width and threshold unresolved.</text></g></svg>')
[IO.File]::WriteAllText([IO.Path]::GetFullPath($Output),($svg-join"`n"),[Text.UTF8Encoding]::new($false))
[xml]$parsed=Get-Content $Output -Raw
Write-Output "SVG parsed: candidate $($c.candidate)"
