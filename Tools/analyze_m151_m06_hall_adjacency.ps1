param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M151_M06_Hall_Adjacency_Screen_2026-10-30')
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$proposalPath = Join-Path $repo 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$selectedDPath = Join-Path $repo 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$roomProgramPath = Join-Path $repo 'Requirements/Room_Program.md'
$ownerDecisionPath = Join-Path $repo 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
$m120ReportPath = Join-Path $repo 'Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30/m120-report.json'
$tolerance = 0.000001

function Get-Sha256([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function New-Box([string]$Id,[string]$Name,[double]$X,[double]$Y,[double]$W,[double]$D,[string]$Kind) {
    [pscustomobject]@{ id=$Id; name=$Name; x=$X; y=$Y; w=$W; d=$D; kind=$Kind }
}
function Get-Contact($A,$B) {
    $ax1=[double]$A.x+[double]$A.w; $ay1=[double]$A.y+[double]$A.d
    $bx1=[double]$B.x+[double]$B.w; $by1=[double]$B.y+[double]$B.d
    $vertical=[Math]::Min($ay1,[double]$B.y+[double]$B.d)-[Math]::Max([double]$A.y,[double]$B.y)
    $horizontal=[Math]::Min($ax1,$bx1)-[Math]::Max([double]$A.x,[double]$B.x)
    $gaps=@(
        [pscustomobject]@{axis='x';gap=[double]$B.x-$ax1;overlap=$vertical},
        [pscustomobject]@{axis='x';gap=[double]$A.x-$bx1;overlap=$vertical},
        [pscustomobject]@{axis='y';gap=[double]$B.y-$ay1;overlap=$horizontal},
        [pscustomobject]@{axis='y';gap=[double]$A.y-$by1;overlap=$horizontal}
    )
    foreach($g in $gaps){
        if($g.overlap -gt $tolerance -and ($g.gap -ge -$tolerance) -and ([Math]::Abs($g.gap) -le 0.5+$tolerance)){
            return [pscustomobject]@{axis=$g.axis;gap_ft=[Math]::Round([double]$g.gap,6);contact_ft=[Math]::Round([double]$g.overlap,6)}
        }
    }
    return $null
}

$sourcePaths=@($proposalPath,$selectedDPath,$roomProgramPath,$ownerDecisionPath,$m120ReportPath)
foreach($path in $sourcePaths){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required M151 source is missing: $path"}}
$proposal=Get-Content -LiteralPath $proposalPath -Raw|ConvertFrom-Json
$selected=Get-Content -LiteralPath $selectedDPath -Raw|ConvertFrom-Json
$m120=Get-Content -LiteralPath $m120ReportPath -Raw|ConvertFrom-Json
$program=Get-Content -LiteralPath $roomProgramPath -Raw
$decision=Get-Content -LiteralPath $ownerDecisionPath -Raw
$sourceHashes=[ordered]@{
    owner_followup_study=Get-Sha256 $proposalPath; selected_d_study=Get-Sha256 $selectedDPath
    room_program=Get-Sha256 $roomProgramPath; owner_direction=Get-Sha256 $ownerDecisionPath
    m120_gross_envelope_report=Get-Sha256 $m120ReportPath
}
$boxes=@()
foreach($room in $proposal.main_rooms){
    $boxes+=New-Box ([string]$room.id) ([string]$room.name) ([double]$room.x_ft) ([double]$room.y_ft) ([double]$room.width_ft) ([double]$room.depth_ft) 'proposed room block'
}
$window=$proposal.M06.first_fit_window
$boxes+=New-Box ([string]$window.id) 'M-06 pantry-side search window' ([double]$window.x_ft) ([double]$window.y_ft) ([double]$window.width_ft) ([double]$window.depth_ft) 'unassigned search window'
$boxMap=@{}; foreach($box in $boxes){$boxMap[$box.id]=$box}
$contacts=@()
for($i=0;$i -lt $boxes.Count;$i++){
    for($j=$i+1;$j -lt $boxes.Count;$j++){
        $contact=Get-Contact $boxes[$i] $boxes[$j]
        if($null -ne $contact){
            $contacts += [pscustomobject][ordered]@{
                block_a=$boxes[$i].id; block_b=$boxes[$j].id; room_or_window_a=$boxes[$i].name; room_or_window_b=$boxes[$j].name
                axis=$contact.axis; schematic_gap_ft=$contact.gap_ft; shared_edge_length_ft=$contact.contact_ft
                contact_kind=if($contact.gap_ft -eq 0){'coincident block edges'}else{'0.5 ft schematic separation; adjacency proxy'}
                actual_wall_or_opening_modeled=$false; selected=$false
            }
        }
    }
}
$graph=@{}; foreach($box in $boxes){$graph[$box.id]=New-Object System.Collections.Generic.List[string]}
foreach($contact in $contacts){$graph[$contact.block_a].Add($contact.block_b);$graph[$contact.block_b].Add($contact.block_a)}
$start='M-05';$goal='M06-B';$queue=New-Object System.Collections.Generic.Queue[string];$queue.Enqueue($start);$previous=@{$start=$null}
while($queue.Count -gt 0 -and -not $previous.ContainsKey($goal)){
    $current=$queue.Dequeue()
    foreach($next in $graph[$current]){if(-not $previous.ContainsKey($next)){$previous[$next]=$current;$queue.Enqueue($next)}}
}
$chain=@()
if($previous.ContainsKey($goal)){$node=$goal;while($null -ne $node){$chain=@($node)+$chain;$node=$previous[$node]}}
$directHallContact=@($contacts|Where-Object {($_.block_a -eq $start -and $_.block_b -eq $goal)-or($_.block_a -eq $goal -and $_.block_b -eq $start)}).Count -gt 0
$m03Window=@($contacts|Where-Object {($_.block_a -eq 'M-03' -and $_.block_b -eq 'M06-B')-or($_.block_a -eq 'M06-B' -and $_.block_b -eq 'M-03')})
$pantryWindow=@($contacts|Where-Object {($_.block_a -eq 'M-04' -and $_.block_b -eq 'M06-B')-or($_.block_a -eq 'M06-B' -and $_.block_b -eq 'M-04')})
$checks=[ordered]@{
    proposal_binds_current_selected_d=($proposal.source_selected_D_sha256 -eq $sourceHashes.selected_d_study)
    proposal_preserves_unassigned_m06=([string]$proposal.M06.status -match '^unassigned' -and [string]$window.status -match '^unassigned')
    m120_window_matches_proposal=( [Math]::Abs([double]$m120.fit_window.gross_width_in-([double]$window.width_ft*12)) -lt 0.001 -and [Math]::Abs([double]$m120.fit_window.gross_depth_in-([double]$window.depth_ft*12)) -lt 0.001 -and -not [bool]$m120.fit_window.assigned )
    room_program_identifies_arrival_hall_zone_and_pantry_first=($program -match 'arrival / hall edge' -and $program -match 'pantry-side search window B selected first')
    owner_direction_keeps_m06_in_search_only=($decision -match 'M-06.*unassigned search window' -or $decision -match 'M-06 B remains a gross unassigned search window')
    seven_block_adjacencies_reconstructed=($contacts.Count -eq 7)
    no_direct_entry_hall_to_m06_block_contact=(-not $directHallContact)
    m06_window_adjoins_dining_and_pantry=($m03Window.Count -eq 1 -and $pantryWindow.Count -eq 1)
    adjacency_chain_exists_from_entry_block_to_m06=($chain.Count -gt 0)
    chain_crosses_living_and_dining_blocks=($chain -join '>' -eq 'M-05>M-01>M-03>M06-B')
    all_contacts_remain_schematic_not_doors=@($contacts|Where-Object actual_wall_or_opening_modeled).Count -eq 0
}
$failures=@($checks.Keys|Where-Object{-not $checks[$_]})
$report=[ordered]@{
    milestone='M151';title='Pantry-side M-06 search-window adjacency to the arrival/hall block'
    status='room-block adjacency only; no M-06 room, door or circulation path selected'
    design_context='Owner-followup 40 x 42 ft test envelope; the 124 x 84 in M06-B area is an unassigned pantry-side search window. The room program calls for an arrival/hall-edge first-fit zone.'
    result='M06-B has no direct shared edge with M-05 Entry / hall in the current proposal. Its schematic shortest adjacency chain is M-05 -> M-01 Living room -> M-03 Dining -> M06-B. The window also shares a block edge with M-04 Pantry. This is a block-topology observation, not a walkable route.'
    direct_entry_hall_contact=$directHallContact; shortest_room_block_adjacency_chain=$chain
    shell=$proposal.shell; m06_window=$window; checks=$checks; failures=$failures
    source_hashes_sha256=$sourceHashes; contacts=$contacts
    limitations=@(
        'Room blocks and the M06-B rectangle are schematic; none represents finished wall faces or an assigned room.',
        'Adjacency edges do not establish a door, clear opening, privacy, leaf swing, approach, passage width or a walkable path. The chain passes through proposed living and dining blocks.',
        'No corridor, furniture or circulation strip, wall assembly, plumbing fixture, rough-in or service route is modeled.',
        'The 40 x 42 ft shell is a selected-D test envelope, not an approved house footprint. This screen makes no code, accessibility, egress, structure or construction claim.'
    )
}
if($failures.Count){throw "M151 failed checks: $($failures -join ', ')"}
$resolved=if([IO.Path]::IsPathRooted($OutputDirectory)){[IO.Path]::GetFullPath($OutputDirectory)}else{[IO.Path]::GetFullPath((Join-Path $repo $OutputDirectory))}
$repoPrefix=$repo.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if(-not $resolved.StartsWith($repoPrefix,[StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside repository root.'}
if(-not(Test-Path -LiteralPath $resolved)){New-Item -ItemType Directory -Path $resolved -Force|Out-Null}
$json=Join-Path $resolved 'm151-m06-hall-adjacency.json';$csv=Join-Path $resolved 'm151-block-contacts.csv';$svg=Join-Path $resolved 'm151-adjacency-diagram.svg'
ConvertTo-Json -InputObject $report -Depth 12|Set-Content -LiteralPath $json -Encoding utf8
$contacts|Export-Csv -LiteralPath $csv -NoTypeInformation -Encoding UTF8
$scale=15.0;$offset=55.0;$svgWidth=760;$svgHeight=790
$lines=New-Object System.Collections.Generic.List[string]
$lines.Add("<svg xmlns=`"http://www.w3.org/2000/svg`" width=`"$svgWidth`" height=`"$svgHeight`" viewBox=`"0 0 $svgWidth $svgHeight`">")
$lines.Add('<rect width="100%" height="100%" fill="#fffdf8"/>')
$lines.Add('<text x="24" y="30" font-family="Arial,sans-serif" font-size="20" font-weight="bold">M-06 pantry-side window: block adjacency only</text>')
$shellW=[double]$proposal.shell.width_ft;$shellD=[double]$proposal.shell.depth_ft
$lines.Add(('<rect x="{0}" y="{1}" width="{2}" height="{3}" fill="none" stroke="#333" stroke-width="2"/>' -f $offset,$offset,[Math]::Round($shellW*$scale),[Math]::Round($shellD*$scale)))
foreach($box in $boxes){
    $x=$offset+[double]$box.x*$scale;$y=$offset+$shellD*$scale-([double]$box.y+[double]$box.d)*$scale;$w=[double]$box.w*$scale;$h=[double]$box.d*$scale
    $fill=if($box.id -eq 'M06-B'){'#e6ddf5'}elseif($box.id -eq 'M-05'){'#d8e9f5'}else{'#ece9df'}
    $dash=if($box.id -eq 'M06-B'){' stroke-dasharray="8 5"'}else{''}
    $lines.Add(('<rect x="{0:F1}" y="{1:F1}" width="{2:F1}" height="{3:F1}" fill="{4}" stroke="#4b4944" stroke-width="1.5"{5}/>' -f $x,$y,$w,$h,$fill,$dash))
    $label=if($box.id -eq 'M06-B'){'M06-B  unassigned'}else{$box.id+'  '+$box.name}
    $lines.Add(('<text x="{0:F1}" y="{1:F1}" font-family="Arial,sans-serif" font-size="12" text-anchor="middle">{2}</text>' -f ($x+$w/2),($y+$h/2),[Security.SecurityElement]::Escape($label)))
}
$lines.Add('<text x="24" y="745" font-family="Arial,sans-serif" font-size="13">Shortest block chain: M-05 -&gt; M-01 -&gt; M-03 -&gt; M06-B; it is not a walkable route or door plan.</text>')
$lines.Add('</svg>')
$lines|Set-Content -LiteralPath $svg -Encoding utf8
$svgXml=[xml](Get-Content -LiteralPath $svg -Raw)
if($svgXml.DocumentElement.LocalName -ne 'svg'){throw 'M151 diagram root is not SVG.'}
Write-Output "M151 checks passed: $($checks.Count)/$($checks.Count); $($contacts.Count) block contacts; direct entry/hall adjacency: $directHallContact; shortest adjacency chain: $($chain -join ' -> '); report SHA256 $(Get-Sha256 $json)."
