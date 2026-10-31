param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M153_M06_Hall_Adjacent_Window_Sensitivity_2026-10-30')
)

$ErrorActionPreference='Stop'
$repo=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$proposalPath=Join-Path $repo 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$selectedPath=Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$programPath=Join-Path $repo 'Requirements/Room_Program.md'
$decisionPath=Join-Path $repo 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
$m120Path=Join-Path $repo 'Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30/m120-report.json'
$tol=0.000001
function Hash([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Rect([string]$Id,[double]$X,[double]$Y,[double]$W,[double]$D,[string]$Kind){[pscustomobject]@{id=$Id;x=$X;y=$Y;w=$W;d=$D;kind=$Kind}}
function AreaOverlap($A,$B){$w=[Math]::Max(0,[Math]::Min([double]$A.x+[double]$A.w,[double]$B.x+[double]$B.w)-[Math]::Max([double]$A.x,[double]$B.x));$d=[Math]::Max(0,[Math]::Min([double]$A.y+[double]$A.d,[double]$B.y+[double]$B.d)-[Math]::Max([double]$A.y,[double]$B.y));return [Math]::Round($w*$d,9)}
function Contact($A,$B){
    $ax1=[double]$A.x+[double]$A.w;$ay1=[double]$A.y+[double]$A.d;$bx1=[double]$B.x+[double]$B.w;$by1=[double]$B.y+[double]$B.d
    foreach($c in @(
        [pscustomobject]@{axis='x';gap=[double]$B.x-$ax1;overlap=[Math]::Min($ay1,$by1)-[Math]::Max([double]$A.y,[double]$B.y)},
        [pscustomobject]@{axis='x';gap=[double]$A.x-$bx1;overlap=[Math]::Min($ay1,$by1)-[Math]::Max([double]$A.y,[double]$B.y)},
        [pscustomobject]@{axis='y';gap=[double]$B.y-$ay1;overlap=[Math]::Min($ax1,$bx1)-[Math]::Max([double]$A.x,[double]$B.x)},
        [pscustomobject]@{axis='y';gap=[double]$A.y-$by1;overlap=[Math]::Min($ax1,$bx1)-[Math]::Max([double]$A.x,[double]$B.x)}
    )){if($c.overlap -gt $tol -and $c.gap -ge -$tol -and [Math]::Abs($c.gap) -le 0.5+$tol){return [pscustomobject]@{axis=$c.axis;gap_ft=[Math]::Round($c.gap,6);projected_contact_ft=[Math]::Round($c.overlap,6)}}}
    return $null
}
foreach($p in @($proposalPath,$selectedPath,$programPath,$decisionPath,$m120Path)){if(-not(Test-Path -LiteralPath $p -PathType Leaf)){throw "Required source missing: $p"}}
$proposal=Get-Content -LiteralPath $proposalPath -Raw|ConvertFrom-Json
$selected=Get-Content -LiteralPath $selectedPath -Raw|ConvertFrom-Json
$m120=Get-Content -LiteralPath $m120Path -Raw|ConvertFrom-Json
$program=Get-Content -LiteralPath $programPath -Raw
$decision=Get-Content -LiteralPath $decisionPath -Raw
$rooms=@(foreach($r in $proposal.main_rooms){Rect ([string]$r.id) ([double]$r.x_ft) ([double]$r.y_ft) ([double]$r.width_ft) ([double]$r.depth_ft) ([string]$r.name)})
$roomById=@{};foreach($r in $rooms){$roomById[$r.id]=$r}
$b=$proposal.M06.first_fit_window
$original=Rect 'M06-B' ([double]$b.x_ft) ([double]$b.y_ft) ([double]$b.width_ft) ([double]$b.depth_ft) 'owner-selected pantry-side search window; unassigned'
$hall=$roomById['M-05'];$living=$roomById['M-01'];$gap=0.5
# Derive an alternative position from current block edges, not from an assigned room or product fit.
$candidate=Rect 'M06-H' ([double]$hall.x+[double]$hall.w+$gap) ([double]$living.y+[double]$living.d+$gap) ([double]$original.w) ([double]$original.d) 'derived hall-edge sensitivity; unassigned'
$shellW=[double]$proposal.shell.width_ft;$shellD=[double]$proposal.shell.depth_ft
$stair=$selected.stair_core_test;$liftX=[double]$stair.lift.origin_ft[0];$liftY=[double]$stair.lift.origin_ft[1]
$core=@(
    (Rect 'lower_to_main_run' ([double]$stair.lower_to_main.run_ft[0]) ([double]$stair.lower_to_main.run_ft[1]) ([double]$stair.lower_to_main.run_ft[2]) ([double]$stair.lower_to_main.run_ft[3]) 'comparison stair reservation'),
    (Rect 'lower_to_main_landing' ([double]$stair.lower_to_main.main_landing_ft[0]) ([double]$stair.lower_to_main.main_landing_ft[1]) 4 4 'comparison landing reservation'),
    (Rect 'main_to_upper_run' ([double]$stair.main_to_upper.run_ft[0]) ([double]$stair.main_to_upper.run_ft[1]) ([double]$stair.main_to_upper.run_ft[2]) ([double]$stair.main_to_upper.run_ft[3]) 'comparison stair reservation'),
    (Rect 'main_to_upper_landing' ([double]$stair.main_to_upper.main_landing_ft[0]) ([double]$stair.main_to_upper.main_landing_ft[1]) 4 4 'comparison landing reservation'),
    (Rect 'lift_reservation' $liftX $liftY 8 8 'comparison lift reservation')
)
$roomHits=@(foreach($r in $rooms){$a=AreaOverlap $candidate $r;if($a -gt 0){[pscustomobject]@{id=$r.id;overlap_sf=$a}}})
$coreHits=@(foreach($c in $core){$a=AreaOverlap $candidate $c;if($a -gt 0){[pscustomobject]@{id=$c.id;overlap_sf=$a}}})
$hallContact=Contact $hall $candidate
$contacts=@(foreach($r in $rooms){$c=Contact $candidate $r;if($null -ne $c){[pscustomobject]@{candidate=$candidate.id;block=$r.id;axis=$c.axis;gap_ft=$c.gap_ft;projected_contact_ft=$c.projected_contact_ft;kind='schematic adjacency proxy; not a wall or opening'}}})
$checks=[ordered]@{
    proposal_binds_current_selected_d=($proposal.source_selected_D_sha256 -eq (Hash $selectedPath))
    existing_B_stays_unassigned=([string]$proposal.M06.status -match '^unassigned' -and [string]$b.status -match '^unassigned')
    current_B_matches_M120_gross_window=([Math]::Abs([double]$m120.fit_window.gross_width_in-([double]$original.w*12)) -lt 0.001 -and [Math]::Abs([double]$m120.fit_window.gross_depth_in-([double]$original.d*12)) -lt 0.001 -and -not [bool]$m120.fit_window.assigned)
    room_program_keeps_arrival_hall_priority_and_pantry_B_first=($program -match 'arrival / hall edge' -and $program -match 'pantry-side search window B selected first')
    owner_decision_keeps_M06_unassigned=($decision -match 'M-06.*unassigned search window' -or $decision -match 'M-06 B remains a gross unassigned search window')
    alternative_uses_same_gross_size=([Math]::Abs($candidate.w-$original.w) -lt $tol -and [Math]::Abs($candidate.d-$original.d) -lt $tol)
    alternative_within_test_shell=($candidate.x -ge 0 -and $candidate.y -ge 0 -and $candidate.x+$candidate.w -le $shellW+$tol -and $candidate.y+$candidate.d -le $shellD+$tol)
    alternative_directly_adjoins_entry_hall=($null -ne $hallContact -and [Math]::Abs($hallContact.gap_ft-0.5) -lt $tol)
    alternative_clear_of_current_room_blocks=($roomHits.Count -eq 0)
    alternative_clear_of_stair_lift_comparison_blocks=($coreHits.Count -eq 0)
    alternative_remains_distinct_from_owner_selected_B=([Math]::Abs($candidate.x-$original.x) -gt $tol -or [Math]::Abs($candidate.y-$original.y) -gt $tol)
    no_native_wall_or_opening_is_claimed=@($contacts|Where-Object {$_.kind -ne 'schematic adjacency proxy; not a wall or opening'}).Count -eq 0
}
$failures=@($checks.Keys|Where-Object {-not $checks[$_]})
$hashes=[ordered]@{owner_followup_study=Hash $proposalPath;selected_d_study=Hash $selectedPath;room_program=Hash $programPath;owner_direction=Hash $decisionPath;m120_report=Hash $m120Path}
$report=[ordered]@{
    milestone='M153';title='Hall-edge M-06 gross-window alternative sensitivity'
    status='alternative unassigned location passes schematic room/core overlap and block-adjacency checks; not a fixture or bathroom fit'
    owner_selected_B=$original;alternative_hall_window=$candidate
    derivation='Keep the current B gross dimensions; set candidate X to M-05 east edge plus the existing 0.5 ft schematic block separation, and candidate Y to M-01 north edge plus that same separation.'
    hall_contact=$hallContact;other_room_contacts=$contacts;room_overlaps=$roomHits;core_overlaps=$coreHits;checks=$checks;failures=$failures;source_hashes_sha256=$hashes
    tradeoff='The alternative directly adjoins the entry/hall block and clears current room/core rectangles but abandons the owner-selected pantry-side B location. Keep pantry-side B as first research area; this sensitivity does not select or assign the alternative.'
    limitations=@('The alternative is derived from schematic blocks, not approved dimensions or walls.','A 0.5 ft gap and projected edge overlap do not establish a door, clear width, approach or walkable route.','No product geometry, fixture orientation, applicable clearance basis, plumbing connection, rough-in or service route is tested.','The test shell and inherited stair/lift rectangles are comparison inputs only; no code, accessibility, egress, structural or construction determination follows.')
}
if($failures.Count){throw "M153 failed: $($failures -join ', ')"}
$resolved=if([IO.Path]::IsPathRooted($OutputDirectory)){[IO.Path]::GetFullPath($OutputDirectory)}else{[IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))}
$prefix=$repo.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if(-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside repository root.'}
if(-not(Test-Path -LiteralPath $resolved)){New-Item -ItemType Directory -Path $resolved -Force|Out-Null}
$json=Join-Path $resolved 'm153-m06-hall-window.json';$csv=Join-Path $resolved 'm153-window-room-contacts.csv';$svg=Join-Path $resolved 'm153-window-comparison.svg'
ConvertTo-Json -InputObject $report -Depth 12|Set-Content -LiteralPath $json -Encoding utf8
$contacts|Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
$scale=13.0;$panelW=500;$panelH=600;$svgLines=New-Object System.Collections.Generic.List[string]
$svgLines.Add('<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="650" viewBox="0 0 1000 650"><rect width="100%" height="100%" fill="#fffdf8"/>')
foreach($panel in @([pscustomobject]@{offset=20;window=$original;title='Owner-selected pantry-side B'},[pscustomobject]@{offset=510;window=$candidate;title='Unassigned hall-edge sensitivity'})){
    $o=[double]$panel.offset;$baseY=45;$svgLines.Add(('<text x="{0}" y="24" font-family="Arial" font-size="16" font-weight="bold">{1}</text>' -f $o,[Security.SecurityElement]::Escape($panel.title)))
    $svgLines.Add(('<rect x="{0}" y="{1}" width="{2}" height="{3}" fill="none" stroke="#333" stroke-width="2"/>' -f ($o+20),$baseY,($shellW*$scale),($shellD*$scale)))
    foreach($r in $rooms){$x=$o+20+$r.x*$scale;$y=$baseY+($shellD-$r.y-$r.d)*$scale;$fill=if($r.id -eq 'M-05'){'#d8e9f5'}else{'#ece9df'};$svgLines.Add(('<rect x="{0:F1}" y="{1:F1}" width="{2:F1}" height="{3:F1}" fill="{4}" stroke="#555"/><text x="{5:F1}" y="{6:F1}" font-family="Arial" font-size="10" text-anchor="middle">{7}</text>' -f $x,$y,($r.w*$scale),($r.d*$scale),$fill,($x+$r.w*$scale/2),($y+$r.d*$scale/2),[Security.SecurityElement]::Escape($r.id))) }
    $w=$panel.window;$x=$o+20+$w.x*$scale;$y=$baseY+($shellD-$w.y-$w.d)*$scale;$svgLines.Add(('<rect x="{0:F1}" y="{1:F1}" width="{2:F1}" height="{3:F1}" fill="#e6ddf5" fill-opacity="0.8" stroke="#5d4080" stroke-width="2" stroke-dasharray="7 4"/><text x="{4:F1}" y="{5:F1}" font-family="Arial" font-size="10" text-anchor="middle">{6} unassigned</text>' -f $x,$y,($w.w*$scale),($w.d*$scale),($x+$w.w*$scale/2),($y+$w.d*$scale/2),$w.id))
}
$svgLines.Add('<text x="24" y="635" font-family="Arial" font-size="12">40 × 42 ft test envelope; rectangles are schematic blocks, not walls, rooms or routes.</text></svg>')
$svgLines|Set-Content -LiteralPath $svg -Encoding utf8
if(([xml](Get-Content -LiteralPath $svg -Raw)).DocumentElement.LocalName -ne 'svg'){throw 'M153 SVG root is invalid.'}
Write-Output "M153 passed $($checks.Count)/$($checks.Count) checks; hall contact $($hallContact.projected_contact_ft) ft across a $($hallContact.gap_ft) ft schematic gap; no room/core overlap; M-06 remains unassigned."
