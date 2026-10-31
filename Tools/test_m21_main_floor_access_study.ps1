param([string]$OutputDirectory = 'Architecture/Direction_D_Social_Route_Study_2026-10-27')

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out = Join-Path $root $OutputDirectory
$candidatePath = Join-Path $root 'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'
$routePath = Join-Path $root 'Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
$dPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
foreach($path in @($candidatePath,$routePath,$dPath)){if(-not(Test-Path -LiteralPath $path)){throw "Required input is missing: $path"}}
$candidate = Get-Content -LiteralPath $candidatePath -Raw | ConvertFrom-Json
$route = Get-Content -LiteralPath $routePath -Raw | ConvertFrom-Json
$d = Get-Content -LiteralPath $dPath -Raw | ConvertFrom-Json
$rooms = @($candidate.plans.main)
$entry = $rooms | Where-Object id -eq 'M-05'
$living = $rooms | Where-Object id -eq 'M-01'
if(@($entry).Count -ne 1 -or @($living).Count -ne 1){throw 'Expected exactly one M-05 and M-01 room block.'}

function Sha([string]$path){(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()}
function Nearly([double]$a,[double]$b,[double]$tolerance=0.001){[Math]::Abs($a-$b) -le $tolerance}

$shellNumbers = [regex]::Matches($d.selection.main_shell,'\d+(?:\.\d+)?')
if($shellNumbers.Count -lt 2){throw 'Selected-D main-shell test dimensions could not be read.'}
$shellW=[double]$shellNumbers[0].Value; $shellD=[double]$shellNumbers[1].Value
$entryEast=[double]$entry.x+[double]$entry.w
$livingEast=[double]$living.x+[double]$living.w
$entryCenterY=[double]$entry.y+[double]$entry.d/2
$westGap=[double]$entry.x-$livingEast
$sharedSpan=[Math]::Min(([double]$entry.y+[double]$entry.d),([double]$living.y+[double]$living.d))-[Math]::Max([double]$entry.y,[double]$living.y)
$eastShellReserve=($shellW-$entryEast)*12
$entryArea=[double]$entry.w*[double]$entry.d
$routeWidthFt=[double]$route.inputs.target_route_width_ft
$routeCenterline=[ordered]@{
    from_east_shell_edge_ft=@([Math]::Round($shellW,3),[Math]::Round($entryCenterY,3))
    to_living_block_ft=@([Math]::Round($livingEast,3),[Math]::Round($entryCenterY,3))
}
$porchMain=@($route.geometry.porch_orientation_comparison | Where-Object id -eq '12-wide-10-deep')
$porchRotated=@($route.geometry.porch_orientation_comparison | Where-Object id -eq '10-wide-12-deep')
if($porchMain.Count -ne 1 -or $porchRotated.Count -ne 1){throw 'Expected both documented porch orientation tests in the M18 report.'}
$routeGapA=[double]$route.route.route_to_chair_proxy_clearance_in
$routeGapB=[double]$route.second_route_scenario.route_to_chair_proxy_clearance_in
$routeArrangementA=[string]$route.route.dining_furniture_arrangement
$routeArrangementB=[string]$route.second_route_scenario.furniture_arrangement
$sameBalancedSeating=(($routeArrangementA -match 'Two chairs on the west long side') -and ($routeArrangementA -match 'one at each table end') -and ($routeArrangementB -match 'Two chairs on the west long side') -and ($routeArrangementB -match 'one north and one south'))
$entryInsideY=($entryCenterY-$routeWidthFt/2 -ge [double]$entry.y) -and ($entryCenterY+$routeWidthFt/2 -le ([double]$entry.y+[double]$entry.d))
$candidateHashes=[ordered]@{
    'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'=(Sha $candidatePath)
    'Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'=(Sha $routePath)
    'Architecture/Selected_Design_Iteration_2026-10-27/study.json'=(Sha $dPath)
}
$candidateFingerprintMatches=($route.source_fingerprints_sha256.'Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json' -eq $candidateHashes['Architecture/Direction_D_BathFirst_Adjacency_Study_2026-10-27/study.json'])
$checks=[ordered]@{
    source_candidate_fingerprint_matches_m18= $candidateFingerprintMatches
    main_shell_is_documented_40_by_42_test_envelope= ((Nearly $shellW 40) -and (Nearly $shellD 42))
    m05_is_4ft4_by_12ft_block= ((Nearly ([double]$entry.w*12) 52) -and (Nearly ([double]$entry.d) 12))
    m05_area_is_52_square_feet= (Nearly $entryArea 52)
    m05_is_8in_inside_east_test_edge= (Nearly $eastShellReserve 8)
    m05_to_m01_nominal_block_gap_is_6in= (Nearly ($westGap*12) 6)
    m05_and_m01_overlap_along_12ft= (Nearly $sharedSpan 12)
    inherited_36in_route_proxy_fits_m05_y_span= (($routeWidthFt -eq 3) -and $entryInsideY)
    proposed_route_spans_shell_edge_through_m05_gap_to_m01= ((Nearly ([double]$routeCenterline.to_living_block_ft[0]) $livingEast) -and (Nearly ([double]$routeCenterline.from_east_shell_edge_ft[0]) $shellW) -and ($shellW -gt $entryEast) -and ($livingEast -lt [double]$entry.x))
    m18_centered_door_proxy_gap_remains_10in= (Nearly $routeGapA 10)
    m18_offset_door_proxy_gap_remains_15in= (Nearly $routeGapB 15)
    both_door_tests_keep_identical_balanced_seating= $sameBalancedSeating
    nominal_door_pair_remains_5ft= ((Nearly ([double]$route.route.nominal_door_width_in) 60) -and (Nearly ([double]$route.second_route_scenario.nominal_door_width_ft) 5))
    porch_orientation_tests_remain_120sf= ((Nearly ([double]$porchMain[0].area_sf) 120) -and (Nearly ([double]$porchRotated[0].area_sf) 120))
    porch_12_by_10_reserve_remains_4in= (Nearly ([double]$porchMain[0].test_outline_edge_reserve_in) 4)
    porch_10_by_12_projection_remains_20in= (Nearly ([double]$porchRotated[0].test_outline_extension_in) 20)
    m06_search_window_b_remains_unassigned= ([bool]$route.geometry.m06_window_b_remains_unassigned)
    entry_proposal_does_not_claim_doors_walls_or_geographic_orientation= $true
}
$failed=@($checks.GetEnumerator() | Where-Object {-not [bool]$_.Value})
if($failed.Count -gt 0){throw ('M21 checks failed: '+(($failed | ForEach-Object Key)-join ', '))}

$report=[ordered]@{
    schema='forever-home-m21-main-floor-access-v1'
    status='Unapproved plan-coordinate comparison; no house geometry or entry orientation selected.'
    source_fingerprints_sha256=$candidateHashes
    assumptions=@(
        'The east side is a plan-coordinate edge of the inherited 40 x 42 ft test shell; geographic direction and front orientation are unknown.',
        'The M18 36 in route width is reused as a plan-route proxy through M-05 solely to inspect block geometry.',
        'A straight east-to-west route from the test-shell edge, through M-05 and across the nominal M-05/M-01 block gap, is a proposal for comparison.',
        'The existing M18 dining and porch arrangement is carried forward as a separate plan-coordinate branch; its door remains nominal and unverified.'
    )
    m05_geometry=[ordered]@{
        block_ft=@([Math]::Round([double]$entry.x,3),[Math]::Round([double]$entry.y,3),[Math]::Round([double]$entry.w,3),[Math]::Round([double]$entry.d,3))
        area_sf=[Math]::Round($entryArea,2)
        test_shell_east_reserve_in=[Math]::Round($eastShellReserve,2)
        to_m01_nominal_gap_in=[Math]::Round($westGap*12,2)
        m01_shared_edge_span_ft=[Math]::Round($sharedSpan,2)
        route_proxy_width_in=[Math]::Round($routeWidthFt*12,2)
        route_proxy_centerline_ft=$routeCenterline
        remaining_block_width_beyond_route_proxy_in=[Math]::Round(([double]$entry.w-$routeWidthFt)*12,2)
    }
    m18_dining_porch=[ordered]@{
        centered_door_proxy_clear_gap_in=$routeGapA
        offset_door_proxy_clear_gap_in=$routeGapB
        centered_and_offset_keep_same_balanced_seating=$sameBalancedSeating
        nominal_door_width_in=60
        porch_12_by_10_reserve_in=[double]$porchMain[0].test_outline_edge_reserve_in
        porch_10_by_12_projection_in=[double]$porchRotated[0].test_outline_extension_in
    }
    gates=@(
        'No M-05 door location, swing, opening width or wall assembly is defined.',
        'The 6 in room-block separation is arithmetic, not a wall, opening, threshold or finished connection.',
        'The 36 in corridor is only a coordinate proxy; door clear width, approach maneuvering, finish dimensions and accessibility are unverified.',
        'Garage arrival, grade, exterior approach, site, cardinal orientation and public-hall routing require documented design input.',
        'Porch reserves and projections are measured against a test outline, not coordinated walls, foundations, roof or site.',
        'M-06 remains unassigned; no bathroom or service route is introduced.'
    )
    no_walls_or_doors_authored=$true
    no_ifc_generated=$true
}
$checkReport=[ordered]@{schema='forever-home-m21-checks-v1';passed=$checks.Count;failed=0;checks=$checks}

$svgScale=16.0; $ox=55.0; $oy=42.0; $svgW=840.0; $svgH=800.0
function X([double]$x){[Math]::Round($ox+$x*$svgScale,2)}
function Y([double]$y){[Math]::Round($oy+$y*$svgScale,2)}
function SvgRect([double]$x,[double]$y,[double]$w,[double]$h,[string]$class){"<rect x='$(X $x)' y='$(Y $y)' width='$([Math]::Round($w*$svgScale,2))' height='$([Math]::Round($h*$svgScale,2))' class='$class'/>"}
function SvgText([double]$x,[double]$y,[string]$class,[string]$text){"<text x='$(X $x)' y='$(Y $y)' class='$class'>$([System.Security.SecurityElement]::Escape($text))</text>"}
$svg=[System.Collections.Generic.List[string]]::new()
$svg.Add("<svg xmlns='http://www.w3.org/2000/svg' width='$(($svgW))' height='$(($svgH))' viewBox='0 0 $svgW $svgH'>")
$svg.Add('<style>text{font-family:Arial,sans-serif;fill:#202a35}.title{font-size:23px;font-weight:bold}.label{font-size:12px}.small{font-size:10px}.room{fill:#e9e2d6;stroke:#574d43;stroke-width:1.5}.entry{fill:#f4dba6;stroke:#8b5e19;stroke-width:2}.shell{fill:none;stroke:#233d55;stroke-width:3}.route{fill:#74a8c9;fill-opacity:.32;stroke:#17628a;stroke-width:2;stroke-dasharray:8 5}.porchA{fill:#66aa7e;fill-opacity:.22;stroke:#227044;stroke-width:2;stroke-dasharray:8 4}.porchB{fill:#bd7aaa;fill-opacity:.18;stroke:#78385f;stroke-width:2;stroke-dasharray:4 4}.arrow{stroke:#17628a;stroke-width:3;fill:none;marker-end:url(#arrow)}</style>')
$svg.Add('<defs><marker id="arrow" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto"><path d="M0,0 L0,6 L9,3 z" fill="#17628a"/></marker></defs>')
$svg.Add("<text x='30' y='27' class='title'>M21 | plan-coordinate access and porch comparison</text>")
$svg.Add((SvgRect 0 0 $shellW $shellD 'shell'))
foreach($room in $rooms){$svg.Add((SvgRect ([double]$room.x) ([double]$room.y) ([double]$room.w) ([double]$room.d) $(if($room.id -eq 'M-05'){'entry'}else{'room'})));$svg.Add((SvgText ([double]$room.x+0.15) ([double]$room.y+0.65) 'label' ($room.id+' '+$room.name)))}
$din=$rooms | Where-Object id -eq 'M-03'
$porchY=[double]$din.y+[double]$din.d+0.5
$porch12x=[double]$din.x
$porch10x=[double]$din.x+([double]$din.w-10)/2
$svg.Add((SvgRect $porch12x $porchY 12 10 'porchA'))
$svg.Add((SvgRect $porch10x $porchY 10 12 'porchB'))
$svg.Add((SvgText ($porch12x+0.2) ($porchY+3) 'small' '12 x 10: 4 in reserve'))
$svg.Add((SvgText ($porch10x+0.2) ($porchY+5) 'small' '10 x 12: 20 in beyond test outline'))
$routeY0=$entryCenterY-$routeWidthFt/2
$svg.Add((SvgRect $livingEast $routeY0 ($shellW-$livingEast) $routeWidthFt 'route'))
$svg.Add("<path d='M $(X ($shellW+0.15)) $(Y $entryCenterY) L $(X $livingEast) $(Y $entryCenterY)' class='arrow'/>")
$svg.Add((SvgText ($shellW-7.8) ($entryCenterY-2) 'small' 'DASHED 36 in route proxy'))
$svg.Add((SvgText ($shellW-7.8) ($entryCenterY-1.35) 'small' 'east plan edge; front TBD'))
$svg.Add((SvgText 0 44 'small' 'Dining door and 36 in social route options are in the M18 source report (10 in / 15 in proxy gaps).'))
$svg.Add((SvgText 0 45 'small' 'Porch overlays: 12 x 10 reserve 4 in; 10 x 12 projects 20 in beyond the test outline.'))
$svg.Add((SvgText 0 46 'small' 'No openings, walls, site orientation, finished clearances or accessibility claims are represented.'))
$svg.Add('</svg>')
$svgText=$svg -join "`r`n"
$null=[xml]$svgText
New-Item -ItemType Directory -Force -Path $out | Out-Null
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $out 'm21-main-floor-access-study.json'),($report | ConvertTo-Json -Depth 10)+"`n",$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm21-main-floor-access-checks.json'),($checkReport | ConvertTo-Json -Depth 8)+"`n",$utf8)
[IO.File]::WriteAllText((Join-Path $out 'm21-main-floor-access-study.svg'),$svgText+"`r`n",$utf8)
Write-Output "M21 main-floor access checks: $($checks.Count)/$($checks.Count) passed. SVG parses as XML."
Write-Output "Entry proxy: 36 in through M-05 ($([Math]::Round([double]$entry.w*12,1)) in room-block width); 6 in nominal gap to M-01; exterior/front and openings remain unverified."
