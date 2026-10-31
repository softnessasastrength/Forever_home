param(
    [string]$OutputDirectory = 'Architecture/M34_Upper_Suite_Private_Link_2026-10-28'
)

$ErrorActionPreference='Stop'
$root=Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$resolvedRoot=[System.IO.Path]::GetFullPath($root)
$target=[System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $OutputDirectory))
$prefix=$resolvedRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar)+[System.IO.Path]::DirectorySeparatorChar
if(-not $target.StartsWith($prefix,[System.StringComparison]::OrdinalIgnoreCase)){throw 'OutputDirectory must resolve inside the repository root.'}

$sourcePath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
foreach($path in @($sourcePath,$proposalPath)){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Required source missing: $path"}}
$source=Get-Content -Raw -LiteralPath $sourcePath|ConvertFrom-Json
$proposal=Get-Content -Raw -LiteralPath $proposalPath|ConvertFrom-Json
$sourceHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash.ToLowerInvariant()
$proposalHash=(Get-FileHash -Algorithm SHA256 -LiteralPath $proposalPath).Hash.ToLowerInvariant()
if($proposal.source_selected_D_sha256 -ne $sourceHash){throw 'Owner-follow-up proposal no longer matches selected-D source fingerprint.'}

$upper=@($source.plans.upper)
$u02=$upper|Where-Object id -eq 'U-02'
$u03=$upper|Where-Object id -eq 'U-03'
$hall=$upper|Where-Object id -eq 'C-UPPER'
$lift=$source.stair_core_test.lift
$upperShell=$source.shells.rear_upper
$wingWidth=[double]$upperShell[0]
$wingDepth=[double]$upperShell[1]
$offsetY=[double]$source.plan_frame_offsets_ft.upper[1]
$westAllowance=[double]$hall.x-([double]$u02.x+[double]$u02.w)
$eastAllowance=[double]$u03.x-([double]$hall.x+[double]$hall.w)
$wallAllowance=$westAllowance # inherited nominal allowance; not a measured wall thickness
$candidate=[ordered]@{id='U-03 direct-link position candidate';x_ft=([double]$u02.x+[double]$u02.w+$wallAllowance);y_ft=[double]$u03.y;width_ft=[double]$u03.w;depth_ft=[double]$u03.d}
$current=[ordered]@{id='U-03 current position';x_ft=[double]$u03.x;y_ft=[double]$u03.y;width_ft=[double]$u03.w;depth_ft=[double]$u03.d}
$coreLift=[ordered]@{id='vertical lift reservation in shared frame';x_ft=[double]$lift.origin_ft[0];y_ft=[double]$lift.origin_ft[1];width_ft=[double]$lift.width_ft;depth_ft=[double]$lift.depth_ft}
$hallRect=[ordered]@{id='existing C-UPPER';x_ft=[double]$hall.x;y_ft=[double]$hall.y;width_ft=[double]$hall.w;depth_ft=[double]$hall.d}

function Get-Intersection($a,$b,$aOffsetY=0){
    $dx=[Math]::Min(($a.x_ft+$a.width_ft),($b.x_ft+$b.width_ft))-[Math]::Max($a.x_ft,$b.x_ft)
    $ay=$a.y_ft+$aOffsetY
    $dy=[Math]::Min(($ay+$a.depth_ft),($b.y_ft+$b.depth_ft))-[Math]::Max($ay,$b.y_ft)
    [ordered]@{overlap=($dx -gt 0.000001 -and $dy -gt 0.000001);width_ft=[Math]::Max(0.0,[double]$dx);depth_ft=[Math]::Max(0.0,[double]$dy);area_sf=[Math]::Round(([Math]::Max(0.0,[double]$dx)*[Math]::Max(0.0,[double]$dy)),4)}
}
function Test-InUpperShell($rect){($rect.x_ft -ge -0.000001 -and $rect.y_ft -ge -0.000001 -and ($rect.x_ft+$rect.width_ft) -le ($wingWidth+0.000001) -and ($rect.y_ft+$rect.depth_ft) -le ($wingDepth+0.000001))}

$currentGap=[double]$u03.x-([double]$u02.x+[double]$u02.w)
$candidateU02Gap=$candidate.x_ft-([double]$u02.x+[double]$u02.w)
$candidateHallHit=Get-Intersection $candidate $hallRect
$candidateLiftHit=Get-Intersection $candidate $coreLift $offsetY
$currentLiftHit=Get-Intersection $current $coreLift $offsetY
$checks=[ordered]@{
    selected_D_source_matches_owner_followup=($proposal.source_selected_D_sha256 -eq $sourceHash)
    direct_candidate_keeps_U03_source_dimensions=($candidate.width_ft -eq [double]$u03.w -and $candidate.depth_ft -eq [double]$u03.d)
    candidate_U03_inside_36x32_upper_wing_test_plate=(Test-InUpperShell $candidate)
    U02_U03_direct_candidate_retains_nominal_6in_wall_allowance=([Math]::Abs($candidateU02Gap-$wallAllowance) -lt 0.000001)
    selected_D_hall_has_matching_nominal_half_ft_wall_allowances=([Math]::Abs($westAllowance-0.5) -lt 0.000001 -and [Math]::Abs($eastAllowance-0.5) -lt 0.000001)
    existing_U02_U03_gap_is_5ft=([Math]::Abs($currentGap-5.0) -lt 0.000001)
    upper_room_frame_offset_is_source_derived=($offsetY -eq 6.0)
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
if($failed.Count -gt 0){throw "M34 source/arithmetic checks failed: $($failed -join ', ')"}

$report=[ordered]@{
    schema='forever-home.m34-upper-suite-private-link-screen.v1'
    title='M34 — upper suite direct-link spatial screen'
    status='design gate; one room shift is insufficient to realize the owner-directed private sequence'
    source_fingerprints_sha256=[ordered]@{'selected_D_study.json'=$sourceHash;'owner_followup_study.json'=$proposalHash}
    coordinate_basis='Upper room blocks use the source-documented wing-local shell; translate upper y by its recorded plan_frame_offsets_ft value only when comparing with shared-frame core geometry.'
    upper_wing_test_shell_ft=[ordered]@{width=$wingWidth;depth=$wingDepth}
    assumptions=@('The selected-D 0.5 ft block separation is retained as a nominal wall allowance, not a verified wall thickness.','The current 4 ft C-UPPER and 8x8 ft lift reservation are treated as comparison geometry, not approved construction dimensions.','A private direct connection is represented by U-02 and U-03 meeting across the nominal 0.5 ft wall zone; no door or opening is modeled.')
    baseline=[ordered]@{U02=[ordered]@{x_ft=[double]$u02.x;y_ft=[double]$u02.y;width_ft=[double]$u02.w;depth_ft=[double]$u02.d};U03=$current;C_UPPER=$hallRect;U03_to_lift_projected_overlap_sf=$currentLiftHit.area_sf;U02_to_U03_gap_ft=$currentGap}
    direct_link_candidate=[ordered]@{U03=$candidate;U02_to_U03_nominal_wall_allowance_ft=$candidateU02Gap;U02_U03_y_overlap_ft=[Math]::Round(([Math]::Min(($candidate.y_ft+$candidate.depth_ft),([double]$u02.y+[double]$u02.d))-[Math]::Max($candidate.y_ft,[double]$u02.y)),4);overlap_with_existing_C_UPPER=$candidateHallHit;overlap_with_lift_reservation=$candidateLiftHit}
    checks=$checks
    failures=$failed
    open_findings=@('Current U-03 overlaps the shared-frame lift reservation in plan projection after applying the documented +6 ft upper-frame offset. Confirm whether the reservation is intended to persist at this location before resolving the upper plan.','Moving U-03 west to align with U-02 across the nominal wall zone occupies part of existing C-UPPER and overlaps the projected lift reservation; this is a diagnostic, not a proposed approved placement.','Preserving a private U-02-to-U-03 route, guest access, U-03/U-04 Jack-and-Jill connection, the 4 ft public hall and lift reservation requires a broader upper-floor/core re-layout. No room-size, core or shell change is authorized by this screen.')
    limitations=@('No feasible alternate packing is asserted. The test establishes that the single direct shift does not work with current corridor/lift rectangles.','No wall, door, door swing, furniture, headroom, floor opening, shaft, stair, service or life-safety geometry is modeled.','No Revit or IFC action was performed; no code, accessibility, structural or construction claim is made.')
}

if(-not(Test-Path -LiteralPath $target)){New-Item -ItemType Directory -Path $target|Out-Null}
$jsonPath=Join-Path $target 'screen.json'
$checksPath=Join-Path $target 'checks.json'
$report|ConvertTo-Json -Depth 24|Set-Content -LiteralPath $jsonPath -Encoding utf8
$checkOutput=[ordered]@{passed=@($checks.Keys|Where-Object{$checks[$_]});failed=@();count=$checks.Count;open_findings=$report.open_findings;checks=$checks}
$checkOutput|ConvertTo-Json -Depth 16|Set-Content -LiteralPath $checksPath -Encoding utf8

$scale=18.0;$sx=40.0;$sy=60.0
$svg=@('<svg xmlns="http://www.w3.org/2000/svg" width="900" height="850" viewBox="0 0 900 850">','<style>text{font-family:Arial,sans-serif;fill:#302b25}.title{font-size:21px;font-weight:bold}.sub{font-size:13px;fill:#5b554d}.room{fill:#eadfce;stroke:#74695d;stroke-width:2}.hall{fill:#d7dce4;stroke:#5f6977;stroke-width:2}.lift{fill:#e7aaa2;fill-opacity:.4;stroke:#a7463c;stroke-width:2;stroke-dasharray:7 4}.candidate{fill:#a8c7a9;fill-opacity:.55;stroke:#43684a;stroke-width:3;stroke-dasharray:8 5}.label{font-size:12px}.warn{font-size:13px;fill:#8e3f35}</style>','<text class="title" x="40" y="30">M34 — private upper-suite link screen</text>','<text class="sub" x="40" y="49">Upper wing local coordinates; lift shown after documented +6 ft frame translation</text>')
$svg+=('<rect class="room" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">U-02 Boutique</text>' -f ($sx+[double]$u02.x*$scale),($sy+[double]$u02.y*$scale),([double]$u02.w*$scale),([double]$u02.d*$scale),($sx+[double]$u02.x*$scale+5),($sy+[double]$u02.y*$scale+18))
foreach($r in $upper|Where-Object{$_.id -in @('U-01','U-05','U-04','U-06')}){$svg+=('<rect class="room" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">{6}</text>' -f ($sx+[double]$r.x*$scale),($sy+[double]$r.y*$scale),([double]$r.w*$scale),([double]$r.d*$scale),($sx+[double]$r.x*$scale+5),($sy+[double]$r.y*$scale+18),$r.id)}
$svg+=('<rect class="hall" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">current C-UPPER</text>' -f ($sx+$hallRect.x_ft*$scale),($sy+$hallRect.y_ft*$scale),($hallRect.width_ft*$scale),($hallRect.depth_ft*$scale),($sx+$hallRect.x_ft*$scale+5),($sy+$hallRect.y_ft*$scale+18))
$svg+=('<rect class="room" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">current U-03</text>' -f ($sx+$current.x_ft*$scale),($sy+$current.y_ft*$scale),($current.width_ft*$scale),($current.depth_ft*$scale),($sx+$current.x_ft*$scale+5),($sy+$current.y_ft*$scale+18))
$svg+=('<rect class="lift" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">lift reservation (shared frame)</text>' -f ($sx+$coreLift.x_ft*$scale),($sy+($coreLift.y_ft-$offsetY)*$scale),($coreLift.width_ft*$scale),($coreLift.depth_ft*$scale),($sx+$coreLift.x_ft*$scale+5),($sy+($coreLift.y_ft-$offsetY)*$scale+18))
$svg+=('<rect class="candidate" x="{0}" y="{1}" width="{2}" height="{3}"/><text class="label" x="{4}" y="{5}">U-03 direct-link test</text>' -f ($sx+$candidate.x_ft*$scale),($sy+$candidate.y_ft*$scale),($candidate.width_ft*$scale),($candidate.depth_ft*$scale),($sx+$candidate.x_ft*$scale+5),($sy+$candidate.y_ft*$scale+18))
$svg+=('<text class="warn" x="40" y="790">One shift overlaps both the existing hall and projected lift reservation.</text>','<text class="sub" x="40" y="812">It is a diagnostic candidate only; room, corridor, core and door re-layout is unresolved.</text>','</svg>')
$svgPath=Join-Path $target 'upper-suite-screen.svg'
$svg -join "`n"|Set-Content -LiteralPath $svgPath -Encoding utf8
$manifest=[ordered]@{generator='Tools/test_m34_upper_suite_private_link.ps1';source_fingerprints=$report.source_fingerprints_sha256;output_hashes=[ordered]@{screen_json=(Get-FileHash $jsonPath -Algorithm SHA256).Hash.ToLowerInvariant();checks_json=(Get-FileHash $checksPath -Algorithm SHA256).Hash.ToLowerInvariant();svg=(Get-FileHash $svgPath -Algorithm SHA256).Hash.ToLowerInvariant()}}
$manifest|ConvertTo-Json -Depth 10|Set-Content -LiteralPath (Join-Path $target 'manifest.json') -Encoding utf8
Write-Output("M34 source/arithmetic checks passed: {0}/{1}" -f $checks.Count,$checks.Count)
Write-Output("Existing U02/U03 gap: {0} ft. Direct-link shift collides with C-UPPER by {1} sf and lift reservation by {2} sf." -f [Math]::Round($currentGap,3),$candidateHallHit.area_sf,$candidateLiftHit.area_sf)
Write-Output("Current U03/lift projected overlap: {0} sf." -f $currentLiftHit.area_sf)
