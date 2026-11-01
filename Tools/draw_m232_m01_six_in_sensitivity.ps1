param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M233_M01_Six_In_Translation_Study_2026-10-31/artifacts')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$studyPath = Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$m228Path = Join-Path $repoRoot 'Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts/m228-west-a-dining-connection.json'
$m215Path = Join-Path $repoRoot 'Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json'
$m232Path = Join-Path $repoRoot 'Architecture/M232_West_A_Hall_Adjacency_Sensitivity_2026-10-31/artifacts/m232-report.json'
$decisionPath = Join-Path $repoRoot 'Decisions/2026-10-31_M01_Living_Translation_Test.md'
$expected = @{
    selected_d = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
    m228 = 'f4ab50fd02e4d71e434c4e4c83d63fe8d20b580810d7118a234bc4b2da8119ff'
    m215 = 'f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
    m232 = '41adf2b56df9a6b2ff318dc98609dd1dd9636445bb1c6dcdce0c864c05100651'
    decision = 'ef07fc60f94ec61a62a0cae486fbd18be040a02c1659fa1be35f341be369ec99'
}
function Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
$sourceHashes = @{
    selected_d = Hash $studyPath
    m228 = Hash $m228Path
    m215 = Hash $m215Path
    m232 = Hash $m232Path
    decision = Hash $decisionPath
}
foreach ($key in $expected.Keys) {
    if ($sourceHashes[$key] -ne $expected[$key]) { throw "Pinned $key SHA256 mismatch: $($sourceHashes[$key])" }
}
$study = Get-Content -LiteralPath $studyPath -Raw | ConvertFrom-Json
$m228 = Get-Content -LiteralPath $m228Path -Raw | ConvertFrom-Json
$m232 = Get-Content -LiteralPath $m232Path -Raw | ConvertFrom-Json
$decision = Get-Content -LiteralPath $decisionPath -Raw
if ($decision -notmatch 'Test 6 in east move' -or $m232.selected_d_modified -ne $false -or
    [double]$m232.candidate.living_translation_east_ft -ne 0.5 -or [double]$m232.candidate.living_area_sf -ne 240) {
    throw 'Owner-authorized 6-in study scope does not match the pinned M232 result.'
}
$rooms = @{}
foreach ($r in $study.plans.main) { $rooms[[string]$r.id] = $r }
$scale = 18.0; $ox = 100.0; $oy = 140.0
function Px([double]$x) { $script:ox + $x*$script:scale }
function Py([double]$y) { $script:oy + $y*$script:scale }
function Box($r, [string]$class, [string]$label) {
    $x=[double]$r.x; $y=[double]$r.y; $w=[double]$r.w; $h=if($r.d){[double]$r.d}else{[double]$r.h}
    $script:svg.Add("<rect class=`"$class`" x=`"$(Px $x)`" y=`"$(Py $y)`" width=`"$($w*$script:scale)`" height=`"$($h*$script:scale)`"/>")
    $script:svg.Add("<text class=`"room`" x=`"$(Px ($x+0.25))`" y=`"$(Py ($y+0.7))`">$label</text>")
}
$svg = New-Object System.Collections.Generic.List[string]
$svg.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1120" height="980" viewBox="0 0 1120 980">')
$svg.Add('<title>M232 owner-authorized six-inch living-room translation comparison</title>')
$svg.Add('<desc>Selected-D room blocks in pale gray with the six-inch east M-01 sensitivity in blue. It is not a selected design and shared edges do not show doors or circulation.</desc>')
$svg.Add('<rect width="1120" height="980" fill="#fbfaf7"/>')
$svg.Add('<style>text{font-family:Segoe UI,Arial,sans-serif;fill:#242424}.title{font-size:25px;font-weight:700}.sub{font-size:14px}.room{font-size:12px;font-weight:600}.base{fill:#e5e7eb;stroke:#4b5563;stroke-width:2}.livingbase{fill:#cbd5e1;stroke:#334155;stroke-width:2;stroke-dasharray:8 5}.livingtest{fill:#bfdbfe;stroke:#1d4ed8;stroke-width:3}.proposal{fill:#fef3c7;stroke:#b45309;stroke-width:2;stroke-dasharray:5 4}.window{fill:#dcfce7;stroke:#15803d;stroke-width:2;stroke-dasharray:7 4}.route{fill:none;stroke:#7c3aed;stroke-width:4;stroke-dasharray:9 6}.edge{stroke:#111827;stroke-width:1.5}</style>')
$svg.Add('<text class="title" x="45" y="42">M-01 Living — 6 in east translation study</text>')
$svg.Add('<text class="sub" x="45" y="68">Owner requested this analysis. Gray dashed = source M-01; blue = unselected sensitivity. Selected-D is unchanged.</text>')
$shellW=40.0; $shellH=42.0
$svg.Add("<rect x=`"$ox`" y=`"$oy`" width=`"$($shellW*$scale)`" height=`"$($shellH*$scale)`" fill=`"none`" stroke=`"#6b7280`" stroke-width=`"2`" stroke-dasharray=`"4 5`"/>")
foreach ($id in @('M-05','M-02','M-04')) { $r=$rooms[$id]; $rObj=[pscustomobject]@{x=$r.x;y=$r.y;w=$r.w;d=$r.d}; Box $rObj 'base' $id }
$a = @($study.selection.main_public_bath.search_windows | Where-Object id -eq 'west_of_core')[0]
$b = @($study.selection.main_public_bath.search_windows | Where-Object id -eq 'east_of_core')[0]
Box ([pscustomobject]@{x=$a.x;y=$a.y;w=$a.w;d=$a.d}) 'window' 'West A — primary, unassigned'
Box ([pscustomobject]@{x=$b.x;y=$b.y;w=$b.w;d=$b.d}) 'base' 'East B — unassigned'
$din=@($m228.dining_candidate.rect_ft)
Box ([pscustomobject]@{x=$din[0];y=$din[1];w=$din[2];h=$din[3]}) 'proposal' 'M228 dining proposal'
$living=$rooms['M-01']; $baseLiving=[pscustomobject]@{x=$living.x;y=$living.y;w=$living.w;d=$living.d}
Box $baseLiving 'livingbase' 'M-01 source block'
$proposed=$m232.candidate.proposed_living_rect_ft
$moveLiving=[pscustomobject]@{x=$proposed[0];y=$proposed[1];w=$proposed[2];d=$proposed[3]}
Box $moveLiving 'livingtest' 'M-01 + 6 in east (study only)'
$routeFrom=@($m228.coordinate_frames.m215_origin_source_ft)
$m215=Get-Content $m215Path -Raw | ConvertFrom-Json
$points=@($m215.route_waypoints_ft)
for($i=0;$i -lt $points.Count;$i++){
    $px=Px ([double]$points[$i].x+[double]$routeFrom[0]); $py=Py ([double]$points[$i].y+[double]$routeFrom[1])
    if($i -eq 0){$d="M $px $py"}else{$d+=" L $px $py"}
}
$svg.Add("<path class=`"route`" d=`"$d`"/>")
$svg.Add('<text x="45" y="925" class="sub">Hall—Living—Dining—west A is block adjacency only; no door, wall opening, clear path, fixture fit, or service route is shown.</text>')
$svg.Add('<text x="45" y="950" class="sub">Test-shell/block geometry only. No compliance, accessibility, structural, or construction-readiness conclusion.</text>')
$svg.Add('</svg>')
$svgText=$svg -join "`n"; [xml]$null=$svgText
$checks=[ordered]@{schema='forever-home.m233-m01-six-inch-translation-diagram-checks.v1';result='pass';check_count=10;checks=[ordered]@{
    selected_d_hash_matches=($sourceHashes.selected_d -eq $expected.selected_d)
    m228_hash_matches=($sourceHashes.m228 -eq $expected.m228)
    m215_hash_matches=($sourceHashes.m215 -eq $expected.m215)
    m232_hash_matches=($sourceHashes.m232 -eq $expected.m232)
    owner_test_scope_recorded=($decision -match 'Test 6 in east move')
    move_is_exactly_six_inches=([double]$m232.candidate.living_translation_east_ft -eq 0.5)
    living_area_preserved=([double]$m232.candidate.living_area_sf -eq 240)
    selected_d_unchanged=($m232.selected_d_modified -eq $false -and (Hash $studyPath) -eq $expected.selected_d)
    windows_remain_unassigned=($a.status -like 'Unassigned*' -and $b.status -like 'Unassigned*')
    svg_parses_as_xml=$true
}}
if(@($checks.checks.Values | Where-Object {$_ -ne $true}).Count -gt 0){$checks.result='fail';throw "M233 checks failed: $(ConvertTo-Json $checks -Depth 10)"}
$output=if([IO.Path]::IsPathRooted($OutputDirectory)){[IO.Path]::GetFullPath($OutputDirectory)}else{[IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory))}
[IO.Directory]::CreateDirectory($output)|Out-Null
[IO.File]::WriteAllText((Join-Path $output 'm233-m01-six-inch-sensitivity.svg'),$svgText,[Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText((Join-Path $output 'm233-checks.json'),(ConvertTo-Json -InputObject $checks -Depth 12)+"`r`n",[Text.UTF8Encoding]::new($false))
Write-Output "PASS: M233 $($checks.check_count)/$($checks.check_count); owner-directed M-01 translation shown as an unselected sensitivity; selected-D unchanged."
