param(
    [string]$OutputDirectory = '.local/revalidation/M190-first-run',
    [string]$ScratchPrefix = 'M190'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out = Join-Path $root $OutputDirectory
if ((Test-Path -LiteralPath $out) -and @(Get-ChildItem -LiteralPath $out -Force).Count -gt 0) { throw "Refusing to overwrite nonempty output: $out" }
if (-not (Test-Path -LiteralPath $out)) { New-Item -ItemType Directory -Path $out | Out-Null }

function Get-Hash190([string]$relative) { (Get-FileHash -LiteralPath (Join-Path $root $relative) -Algorithm SHA256).Hash.ToLowerInvariant() }
function New-Rect190([string]$id,[double]$x,[double]$y,[double]$w,[double]$d) { [pscustomobject]@{id=$id;x=$x;y=$y;w=$w;d=$d} }
function Get-Overlap190($a,$b) {
    $dx = [Math]::Min(($a.x+$a.w),($b.x+$b.w)) - [Math]::Max($a.x,$b.x)
    $dy = [Math]::Min(($a.y+$a.d),($b.y+$b.d)) - [Math]::Max($a.y,$b.y)
    if ($dx -gt 1e-8 -and $dy -gt 1e-8) { return [pscustomobject]@{x=[Math]::Max($a.x,$b.x);y=[Math]::Max($a.y,$b.y);w=$dx;d=$dy;area=$dx*$dy} }
    return $null
}
function Get-UnionArea190([object[]]$rectangles) {
    if ($rectangles.Count -eq 0) { return 0.0 }
    $xs = @($rectangles | ForEach-Object { [double]$_.x; [double]($_.x+$_.w) } | Sort-Object -Unique)
    $ys = @($rectangles | ForEach-Object { [double]$_.y; [double]($_.y+$_.d) } | Sort-Object -Unique)
    $area = 0.0
    for ($i=0; $i -lt $xs.Count-1; $i++) { for ($j=0; $j -lt $ys.Count-1; $j++) {
        $cx = ($xs[$i]+$xs[$i+1])/2; $cy = ($ys[$j]+$ys[$j+1])/2
        if (@($rectangles | Where-Object { $cx -gt $_.x-1e-8 -and $cx -lt $_.x+$_.w+1e-8 -and $cy -gt $_.y-1e-8 -and $cy -lt $_.y+$_.d+1e-8 }).Count -gt 0) { $area += ($xs[$i+1]-$xs[$i])*($ys[$j+1]-$ys[$j]) }
    }}
    return [Math]::Round($area,8)
}

$m188Script = 'Tools/search_m188_dining_set_placement.ps1'
$m186Script = 'Tools/search_m186_public_route.ps1'
$spec = 'Architecture/Kitchen_Dining_Porch_Specs.md'
$selected = 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$bath = 'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$sourceHashes = [ordered]@{}
foreach ($p in @($m188Script,$m186Script,$spec,$selected,$bath)) { $sourceHashes[$p] = Get-Hash190 $p }
if ($sourceHashes[$selected] -ne '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb') { throw 'Selected-D source fingerprint changed; refusing this derivative audit.' }

# Recreate the exact M188 north-shift case directly in ignored scratch. M188's full five-case
# replay is needlessly expensive here; this applies its same guarded M186 transformation once.
$prefix = $ScratchPrefix + '-' + [guid]::NewGuid().ToString('N')
$m186Source = [IO.File]::ReadAllText((Join-Path $root $m186Script))
$needle = '$obstacles=@($entry,$pantry,$west,$east,$counter,$island,$stools,$halfwall,$wallReturn,$table)+$chairs+$porchWalls'
if (([regex]::Matches($m186Source,[regex]::Escape($needle))).Count -ne 1) { throw 'M186 obstacle declaration changed; refusing an unreviewed text transformation.' }
$snippet = @'
$table=NewRect186 3 18.5 5 3 'dining-table'
$chairs=@((NewRect186 3.5 16.8333333333 1.5 1.6666666667 'south-chair-1'),(NewRect186 6 16.8333333333 1.5 1.6666666667 'south-chair-2'),(NewRect186 1.3333333333 18.5 1.6666666667 1.5 'west-chair-1'),(NewRect186 1.3333333333 20 1.6666666667 1.5 'west-chair-2'))
$obstacles=@($entry,$pantry,$west,$east,$counter,$island,$stools,$halfwall,$wallReturn,$table)+$chairs+$porchWalls
'@
$temp = Join-Path (Split-Path (Join-Path $root $m186Script) -Parent) ('m190-generated-' + [guid]::NewGuid().ToString('N') + '.ps1')
$routeOut = '.local/revalidation/' + $prefix + '-north_1ft'
if ((Test-Path -LiteralPath (Join-Path $root $routeOut)) -and @(Get-ChildItem -LiteralPath (Join-Path $root $routeOut) -Force).Count -gt 0) { throw "Refusing to overwrite scratch directory: $routeOut" }
try {
    [IO.File]::WriteAllText($temp,$m186Source.Replace($needle,$snippet.TrimEnd()),(New-Object Text.UTF8Encoding($false)))
    & $temp -OutputDirectory $routeOut
} finally { if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Force } }
$routePath = Join-Path $root ($routeOut + '/m186-route-search.json')
if (-not (Test-Path -LiteralPath $routePath -PathType Leaf)) { throw "M188 did not produce its expected north-case route: $routePath" }
$routeReport = Get-Content -LiteralPath $routePath -Raw | ConvertFrom-Json
if (-not $routeReport.search.path_found) { throw 'The reproducible M188 north-shift route is no longer present.' }

# M188's retained arrangement translated one foot north: source-sized four chair bodies and a 36-in edge-to-edge pull-out study envelope.
$table = New-Rect190 'table' 3 18.5 5 3
$chairs = @(
    (New-Rect190 'south-chair-1' 3.5 16.8333333333 1.5 1.6666666667),
    (New-Rect190 'south-chair-2' 6 16.8333333333 1.5 1.6666666667),
    (New-Rect190 'west-chair-1' 1.3333333333 18.5 1.6666666667 1.5),
    (New-Rect190 'west-chair-2' 1.3333333333 20 1.6666666667 1.5)
)
$pullouts = @(
    (New-Rect190 'south-chair-1-use-36in-from-table-edge' 3.5 15.5 1.5 3),
    (New-Rect190 'south-chair-2-use-36in-from-table-edge' 6 15.5 1.5 3),
    (New-Rect190 'west-chair-1-use-36in-from-table-edge' 0 18.5 3 1.5),
    (New-Rect190 'west-chair-2-use-36in-from-table-edge' 0 20 3 1.5)
)
# Reconstruct the 36-in swept path from compressed centerline waypoints. M186's serialized
# route_rectangles also places a corner square at every 3-in-grid node, including collinear
# nodes; those redundant squares can distort downstream overlap areas.
$routeRects = New-Object System.Collections.Generic.List[object]
$points = @($routeReport.search.compressed_waypoints_ft)
$halfWidth = 1.5
for ($i=0; $i -lt $points.Count-1; $i++) {
    $a=$points[$i];$b=$points[$i+1]
    if ([Math]::Abs([double]$a.y-[double]$b.y) -lt 1e-8) { $routeRects.Add((New-Rect190 "segment-$i" ([Math]::Min([double]$a.x,[double]$b.x)) ([double]$a.y-$halfWidth) ([Math]::Abs([double]$b.x-[double]$a.x)) 3)) }
    elseif ([Math]::Abs([double]$a.x-[double]$b.x) -lt 1e-8) { $routeRects.Add((New-Rect190 "segment-$i" ([double]$a.x-$halfWidth) ([Math]::Min([double]$a.y,[double]$b.y)) 3 ([Math]::Abs([double]$b.y-[double]$a.y)))) }
    else { throw 'M186 route contains a non-orthogonal waypoint.' }
}
for ($i=0; $i -lt $points.Count; $i++) {
    $isEndpoint = ($i -eq 0 -or $i -eq $points.Count-1)
    $isTurn = $false
    if (-not $isEndpoint) {
        $before=$points[$i-1];$at=$points[$i];$after=$points[$i+1]
        $isTurn = ([Math]::Abs([double]$before.x-[double]$at.x) -lt 1e-8) -ne ([Math]::Abs([double]$at.x-[double]$after.x) -lt 1e-8)
    }
    if ($isEndpoint -or $isTurn) { $routeRects.Add((New-Rect190 "node-$i" ([double]$points[$i].x-$halfWidth) ([double]$points[$i].y-$halfWidth) 3 3)) }
}
$allRouteRects = $routeRects.ToArray()
$allIntersections = New-Object System.Collections.Generic.List[object]
$intersectionCells = New-Object System.Collections.Generic.List[object]
foreach ($r in $allRouteRects) { foreach ($p in $pullouts) {
    $hit = Get-Overlap190 $r $p
    if ($null -ne $hit) { $allIntersections.Add([pscustomobject]@{route_rect=$r.id;chair_use_envelope=$p.id;overlap_sf=[Math]::Round($hit.area,8)}); $intersectionCells.Add($hit) }
}}
$unionOverlap = Get-UnionArea190 $intersectionCells.ToArray()
$fixture = Get-Content (Join-Path $root $bath) -Raw | ConvertFrom-Json
$bWindow = @($fixture.selection.main_public_bath.search_windows | Where-Object id -eq 'east_of_core')[0]
$checks = @(
    [pscustomobject]@{id='source_hashes_bound';pass=($sourceHashes.Count -eq 5);detail='M188/M186/spec/selected-D/bath-first inputs are fingerprinted.'},
    [pscustomobject]@{id='north_route_replays';pass=([bool]$routeReport.search.path_found -and [double]$routeReport.search.route_length_ft -eq 56.5);detail='The same documented one-foot north shift reproduces the 56.5-ft M188 route.'},
    [pscustomobject]@{id='four_documented_chair_bodies';pass=($chairs.Count -eq 4 -and @($chairs | Where-Object { -not (([Math]::Abs($_.w-1.5) -lt 1e-6 -and [Math]::Abs($_.d-1.6666666667) -lt 1e-6) -or ([Math]::Abs($_.w-1.6666666667) -lt 1e-6 -and [Math]::Abs($_.d-1.5) -lt 1e-6)) }).Count -eq 0);detail='Four 18 x 20-in chair-body envelopes retain the M188 arrangement.'},
    [pscustomobject]@{id='documented_36in_pullout_depth';pass=(@($pullouts | Where-Object { [Math]::Abs([Math]::Max($_.w,$_.d)-3) -gt 1e-6 }).Count -eq 0);detail='Each pull-out study envelope extends 36 in from its corresponding table edge.'},
    [pscustomobject]@{id='pullout_envelopes_inside_dining_target';pass=(@($pullouts | Where-Object { $_.x -lt 0 -or $_.y -lt 14 -or $_.x+$_.w -gt 11 -or $_.y+$_.d -gt 24 }).Count -eq 0);detail='The pull-out proxies fit the 11 x 10-ft study block.'},
    [pscustomobject]@{id='through_route_conflict_is_reported';pass=($unionOverlap -gt 0 -and $allIntersections.Count -gt 0);detail='The audit must flag any positive-area route conflict with the explicit chair-use proxy; a conflict rejects this candidate, not the audit.'},
    [pscustomobject]@{id='selected_d_preserved';pass=($sourceHashes[$selected] -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb');detail='Protected selected-D baseline remains unchanged.'},
    [pscustomobject]@{id='m06_b_unassigned';pass=([string]$bWindow.status -match 'Unassigned');detail='East/pantry-side B remains an unassigned search window.'}
)
$passed = @($checks | Where-Object pass).Count
$report = [ordered]@{
    schema='forever-home-m190-dining-pullout-route-audit-v1'
    status=if($passed -eq $checks.Count){'pass'}else{'fail'}
    candidate_screen_result=if($unionOverlap -gt 0){'candidate_rejected_route_overlaps_chair_use_proxy'}else{'candidate_has_no_positive_area_overlap_with_chair_use_proxy'}
    interpretation='Audit of M188 north-shift route against a schematic 36-in chair pull-out/use envelope. This does not choose the layout or establish operational circulation.'
    source_fingerprints_sha256=$sourceHashes
    selected_d_sha256=$sourceHashes[$selected]
    route=[ordered]@{source_case='M188 north_1ft';found=[bool]$routeReport.search.path_found;length_ft=$routeReport.search.route_length_ft;turns=$routeReport.search.route_turn_count;centerline_waypoints_ft=$points;swept_rectangles_ft=$allRouteRects;sweep_method='36-in segment rectangles with 36-in square caps at endpoints and actual direction changes only.';m186_serialized_rect_count=[int]$routeReport.search.route_rectangles_ft.Count}
    dining=[ordered]@{test_block_ft=@(0,14,11,10);table_rect_ft=$table;chair_body_rectangles_ft=$chairs;pullout_use_rectangles_ft=$pullouts;pullout_depth_from_table_edge_in=36;pullout_clearance_meaning='A rectangular study envelope measured outward from the table edge to 36 in; project wording does not define chair model, human occupancy, chair swept path, or whether this dimension is measured to a wall or an occupied chair.'}
    route_pullout_intersections=$allIntersections.ToArray()
    route_pullout_union_overlap_sf=$unionOverlap
    interpretation_of_overlap='Positive-area overlap is an incompatibility under this static proxy screen. The 36-in envelope definition remains a design assumption pending interpretation by the owner/designer.'
    checks=[ordered]@{status=if($passed -eq $checks.Count){'pass'}else{'fail'};passed=$passed;total=$checks.Count;items=$checks}
    limitations=@('The 36-in dining pull-out value comes from Architecture/Kitchen_Dining_Porch_Specs.md; the rectangular interpretation is an explicitly labeled study assumption.','Chair-use envelopes extend from table edges and do not model individual product geometry, occupant body/swing, accessibility, or real chair motion.','M188 north-shift route already has zero additional table-edge gap and crosses 6.5 ft of unassigned area; this audit tests its intersection with separate chair-use rectangles.','42-in preferred wall/porch-door clearance from the same source is not validated because physical wall and clear-door positions are absent.','The 40 x 42-ft shell, 13.5 x 14-ft kitchen and room blocks are unapproved comparisons.','M-06/B remains unassigned; selected-D, RVT/IFC, Incoming RFAs and remote state are unchanged.','No code-compliance, accessibility, structural-safety, professional, permit, or construction-readiness conclusion is made.')
}
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm190-dining-pullout-route.json'),(($report | ConvertTo-Json -Depth 40)+"`n"),$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm190-checks.json'),(($report.checks | ConvertTo-Json -Depth 30)+"`n"),$utf8)
$csv = @($allIntersections | ForEach-Object { [pscustomobject]@{record_type='route pullout intersection';route_rect=$_.route_rect;chair_use_envelope=$_.chair_use_envelope;overlap_sf=$_.overlap_sf} })
if ($csv.Count -eq 0) { $csv = @([pscustomobject]@{record_type='summary';route_rect='';chair_use_envelope='';overlap_sf=0}) }
[IO.File]::WriteAllText((Join-Path $out 'm190-intersections.csv'),((@($csv | ConvertTo-Csv -NoTypeInformation) -join "`n")+"`n"),$utf8)
$svg = Join-Path $out 'm190-dining-pullout-route.svg'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('<svg xmlns="http://www.w3.org/2000/svg" width="900" height="780" viewBox="0 0 900 780"><title>M190 dining pull-out and route audit</title><desc>North-shift M188 dining layout with 36-inch schematic chair-use envelopes and sampled route overlay.</desc><g font-family="Arial,sans-serif" font-size="12">')
$scale=22.0;$ox=150.0;$oy=620.0
function SvgR190($r,$fill,$stroke) { $x=$script:ox+[double]$r.x*$script:scale;$y=$script:oy-([double]$r.y+[double]$r.d)*$script:scale;return ('<rect x="{0:F2}" y="{1:F2}" width="{2:F2}" height="{3:F2}" fill="{4}" fill-opacity=".35" stroke="{5}" stroke-width="1.5"/>' -f $x,$y,([double]$r.w*$script:scale),([double]$r.d*$script:scale),$fill,$stroke) }
$lines.Add((SvgR190 (New-Rect190 'dining-block' 0 14 11 10) '#e8f0f7' '#56708d'))
foreach ($p in $pullouts) { $lines.Add((SvgR190 $p '#efb64b' '#946112')) }
$lines.Add((SvgR190 $table '#9fb18d' '#52614a'))
foreach ($c in $chairs) { $lines.Add((SvgR190 $c '#c9b8a7' '#665447')) }
if ($routeReport.search.path_found) { $pts=@();foreach($p in $routeReport.search.compressed_waypoints_ft){$pts+=('{0:F2},{1:F2}' -f ($ox+[double]$p.x*$scale),($oy-[double]$p.y*$scale))};$lines.Add(('<polyline points="{0}" fill="none" stroke="#216d8c" stroke-width="66" stroke-linecap="square" stroke-linejoin="round" opacity=".7"/>' -f ($pts -join ' ')));$lines.Add(('<polyline points="{0}" fill="none" stroke="#16455b" stroke-width="3"/>' -f ($pts -join ' '))) }
$lines.Add(('<text x="30" y="30">M190 — north-shift route/pull-out proxy overlap: {0:F3} sf</text>' -f $unionOverlap))
$lines.Add('<text x="30" y="52">Amber: 36-in-from-table-edge study envelopes; blue: 36-in swept route. Diagram is schematic.</text></g></svg>')
[IO.File]::WriteAllText($svg,($lines -join "`n")+"`n",$utf8)
$null=[xml](Get-Content -LiteralPath $svg -Raw)
if ($passed -ne $checks.Count) { throw "M190 validation failed $passed/$($checks.Count); see $out" }
Write-Output "M190 pass $passed/$($checks.Count); route/pull-out union overlap $unionOverlap sf; M-06/B remains unassigned."
