param(
    [string]$M115PackageDirectory = 'Architecture/M115_U03_All_Edge_Spread_Search_2026-10-30',
    [string]$CodeBasisPath = 'Research/M116_CT_EERO_and_U03_Exploratory_Wall_Zone_2026-10-30.md',
    [string]$OutputDirectory = 'Architecture/M116_U03_EERO_Wall_Zone_2026-10-30'
)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$prefix=$root.TrimEnd([IO.Path]::DirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
function Resolve-InRoot([string]$path,[string]$label){$resolved=[IO.Path]::GetFullPath((Join-Path $root $path));if(-not $resolved.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)){throw "$label must resolve inside the repository."};return $resolved}
$package=Resolve-InRoot $M115PackageDirectory 'M115PackageDirectory'
$codePath=Resolve-InRoot $CodeBasisPath 'CodeBasisPath'
$output=Resolve-InRoot $OutputDirectory 'OutputDirectory'
$archivePath=Join-Path $package 'all-route-tested-candidates.json'
$m115AuditPath=Join-Path $package 'm115-audit.json'
foreach($path in @($archivePath,$m115AuditPath,$codePath)){if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing M116 source: $path"}}
$archive=Get-Content -Raw -LiteralPath $archivePath|ConvertFrom-Json
$m115Audit=Get-Content -Raw -LiteralPath $m115AuditPath|ConvertFrom-Json
$codeNote=Get-Content -Raw -LiteralPath $codePath
$selectedPath=Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$proposalPath=Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$programPath=Join-Path $root 'Requirements/Room_Program.md'
$selected=Get-Content -Raw -LiteralPath $selectedPath|ConvertFrom-Json
$proposal=Get-Content -Raw -LiteralPath $proposalPath|ConvertFrom-Json
$program=Get-Content -Raw -LiteralPath $programPath
$tol=0.00001;$shellW=38.333333;$shellD=40.0
function Room-Edges($r){$edges=@();if([Math]::Abs($r.x_ft)-le $tol){$edges+='west'};if([Math]::Abs($r.y_ft)-le $tol){$edges+='north'};if([Math]::Abs($r.x_ft+$r.width_ft-$shellW)-le $tol){$edges+='east'};if([Math]::Abs($r.y_ft+$r.depth_ft-$shellD)-le $tol){$edges+='south'};return (@($edges|Sort-Object)-join ',')}
$all=@($archive.candidates)
$privacy=@($all|Where-Object{$_.public_rooms_reached_count -eq 3 -and -not $_.hall_reachability.u03_hall_side_reachable})
$northeast=@($privacy|Where-Object{(Room-Edges $_.rectangles.'U-03') -eq 'east,north'})
$northwest=@($privacy|Where-Object{(Room-Edges $_.rectangles.'U-03') -eq 'north,west'})
$u03=$northeast[0].rectangles.'U-03'
$northeastNorthLong=@($northeast|Where-Object{[double]$_.rectangles.'U-03'.width_ft -gt [double]$_.rectangles.'U-03'.depth_ft})
$northeastEastLong=@($northeast|Where-Object{[double]$_.rectangles.'U-03'.depth_ft -gt [double]$_.rectangles.'U-03'.width_ft})
$u03Area=[double]$u03.width_ft*[double]$u03.depth_ft
$northWallIn=[double]$u03.width_ft*12.0
$eastWallIn=[double]$u03.depth_ft*12.0
$minClearAreaSqFt=5.7;$minClearAreaSqIn=$minClearAreaSqFt*144.0
$minClearWidthIn=20.0;$minClearHeightIn=24.0;$maxSillIn=44.0
$heightAtMinWidthIn=$minClearAreaSqIn/$minClearWidthIn
$widthAtMinHeightIn=$minClearAreaSqIn/$minClearHeightIn
$dimensionsMatch=$true;$allNEContacts=$true;$allNWContacts=$true;$allPublic=$true;$allU02North=$true
foreach($c in $privacy){$r=$c.rectangles.'U-03';$same=([Math]::Abs($r.width_ft-[double]$selected.plans.upper.Where({$_.id -eq 'U-03'}).w)-le $tol -and [Math]::Abs($r.depth_ft-[double]$selected.plans.upper.Where({$_.id -eq 'U-03'}).d)-le $tol);$rotated=([Math]::Abs($r.width_ft-[double]$selected.plans.upper.Where({$_.id -eq 'U-03'}).d)-le $tol -and [Math]::Abs($r.depth_ft-[double]$selected.plans.upper.Where({$_.id -eq 'U-03'}).w)-le $tol);if(-not($same -or $rotated)){$dimensionsMatch=$false};if($c.public_rooms_reached_count -ne 3){$allPublic=$false};if(@($c.hall_reachability.reachable_room_sides.'U-02') -notcontains 'north'){$allU02North=$false}}
foreach($c in $northeast){if((Room-Edges $c.rectangles.'U-03') -ne 'east,north'){$allNEContacts=$false}}
foreach($c in $northwest){if((Room-Edges $c.rectangles.'U-03') -ne 'north,west'){$allNWContacts=$false}}
$sourceHashes=[ordered]@{M115_archive=(Get-FileHash $archivePath -Algorithm SHA256).Hash.ToLowerInvariant();M115_audit=(Get-FileHash $m115AuditPath -Algorithm SHA256).Hash.ToLowerInvariant();selected_D=(Get-FileHash $selectedPath -Algorithm SHA256).Hash.ToLowerInvariant();owner_proposal=(Get-FileHash $proposalPath -Algorithm SHA256).Hash.ToLowerInvariant();room_program=(Get-FileHash $programPath -Algorithm SHA256).Hash.ToLowerInvariant();code_basis_note=(Get-FileHash $codePath -Algorithm SHA256).Hash.ToLowerInvariant();analyzer=(Get-FileHash $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()}
$checks=[ordered]@{
    M115_archive_hash_matches_independent_audit=($sourceHashes.M115_archive -eq $m115Audit.source_hashes_sha256.archive)
    all_M115_audit_checks_pass=(@($m115Audit.checks.PSObject.Properties|Where-Object{-not $_.Value}).Count -eq 0)
    selected_D_hash_matches_archived_exploration=($m115Audit.source_hashes_sha256.selected_D_study -eq $sourceHashes.selected_D)
    current_owner_private_only_direction_is_preserved=($proposal.owner_inputs.u03_shared_hall_access -eq $false)
    U03_program_remains_hybrid_bedroom_office=($program -match 'U-03\s*\|\s*Branden''s hybrid bedroom/office')
    M115_privacy_subset_has_73_candidates=($privacy.Count -eq 73)
    privacy_subset_reaches_all_three_public_room_samples=$allPublic
    privacy_subset_keeps_sampled_north_side_U02_arrival=$allU02North
    northeast_privacy_subset_has_64_candidates=($northeast.Count -eq 64)
    northeast_orientation_counts_are_44_north_long_20_east_long=($northeastNorthLong.Count -eq 44 -and $northeastEastLong.Count -eq 20)
    northwest_privacy_subset_has_9_candidates=($northwest.Count -eq 9)
    northeast_candidates_touch_north_and_east_test_edges=$allNEContacts
    northwest_candidates_touch_north_and_west_test_edges=$allNWContacts
    U03_room_blocks_match_source_dimensions_allowing_rotation=$dimensionsMatch
    gross_U03_room_rectangle_is_125_28_sf_within_programmed_120_to_150_sf=([Math]::Abs($u03Area-125.2777777778)-lt 0.01 -and $u03Area -ge 120 -and $u03Area -le 150)
    both_ne_orientations_have_source_preserved_area_and_edge_lengths=([Math]::Abs($u03Area-125.2777777778)-lt 0.01 -and @($northeastNorthLong|Where-Object{[Math]::Abs($_.rectangles.'U-03'.width_ft-13.6666666667)-gt $tol -or [Math]::Abs($_.rectangles.'U-03'.depth_ft-9.1666666667)-gt $tol}).Count -eq 0 -and @($northeastEastLong|Where-Object{[Math]::Abs($_.rectangles.'U-03'.width_ft-9.1666666667)-gt $tol -or [Math]::Abs($_.rectangles.'U-03'.depth_ft-13.6666666667)-gt $tol}).Count -eq 0)
    code_note_records_current_2022_basis_and_2026_delay=($codeNote -match '2022 Connecticut State Building Code' -and $codeNote -match 'effective date was delayed')
    code_note_cites_EERO_requirements_and_open_limitations=($codeNote -match 'R310\.1' -and $codeNote -match '5\.7 square feet' -and $codeNote -match '44 inches' -and $codeNote -match 'not a code review')
    minimum_area_arithmetic_is_consistent=([Math]::Abs($minClearAreaSqIn-820.8)-lt 0.001 -and [Math]::Abs($heightAtMinWidthIn-41.04)-lt 0.001 -and [Math]::Abs($widthAtMinHeightIn-34.2)-lt 0.001)
    grade_floor_exception_is_not_assumed=($codeNote -match 'grade-floor exception is not assumed')
    selected_D_baseline_remains_identical_to_M115_source=($sourceHashes.selected_D -eq $m115Audit.source_hashes_sha256.selected_D_study)
}
$failed=@($checks.Keys|Where-Object{-not $checks[$_]})
if($failed.Count -gt 0){throw "M116 EERO wall-zone screen failed: $($failed -join ', ')"}
$report=[ordered]@{
    schema='forever-home.m116-u03-eero-wall-zone.v1'
    status='conditional code-basis and perimeter-zone screen; no window or wall is modeled and no compliance result is determined'
    code_basis=[ordered]@{as_of='2026-10-30';current_code='2022 Connecticut State Building Code based on 2021 IRC';'2026_code_status'='DAS reports expected effective date delayed pending LRRC approval';conditional_sleeping_room_requirement='one operable emergency escape and rescue opening per sleeping room, to a public way or qualifying yard/court';minimum_net_clear_area_sq_ft=$minClearAreaSqFt;grade_floor_exception_sq_ft=5.0;minimum_clear_width_in=$minClearWidthIn;minimum_clear_height_in=$minClearHeightIn;maximum_bottom_of_clear_opening_in=$maxSillIn;grade_floor_exception_assessed=$false;code_compliance_claimed=$false}
    study=[ordered]@{selected_D_shell_unchanged='36 x 32 ft test wing';M115_shell=[ordered]@{width_ft=$shellW;depth_ft=$shellD;status='exploration only'};privacy_candidates=$privacy.Count;northeast_privacy_candidates=$northeast.Count;northwest_privacy_candidates=$northwest.Count;public_route_all_three=$true;U02_north_side_sample_all=$true;U03_hall_side_sample_all=$false}
    U03_geometry=[ordered]@{gross_rectangle_area_sq_ft=$u03Area;northeast_orientation_distribution=@([ordered]@{count=$northeastNorthLong.Count;source_preserved_width_ft=13.6666666667;source_preserved_depth_ft=9.1666666667;north_test_edge_length_in=164.0;east_test_edge_length_in=110.0},[ordered]@{count=$northeastEastLong.Count;source_preserved_width_ft=9.1666666667;source_preserved_depth_ft=13.6666666667;north_test_edge_length_in=110.0;east_test_edge_length_in=164.0});north_edge_length_range_in=@(110.0,164.0);east_edge_length_range_in=@(110.0,164.0);status='schematic gross block dimensions, not finished interior dimensions or clear wall/opening dimensions'}
    EERO_threshold_arithmetic=[ordered]@{minimum_net_area_sq_in=$minClearAreaSqIn;height_at_20_in_clear_width_in=$heightAtMinWidthIn;width_at_24_in_clear_height_in=$widthAtMinHeightIn;interpretation='area arithmetic only; actual opening must meet area, both minimum dimensions, operability, sill and applicable location/path requirements'}
    interpretation='The M115 northeast privacy subset provides two candidate perimeter lines for future wall/opening study. It does not demonstrate a wall, opening, qualifying exterior discharge, roof clearance or code compliance.'
    limitations=@('U-03 remains a hybrid bedroom/office with sleeping-room status unresolved.','Exact town, site, grade, permit date, occupancy/code path and local official interpretation are unknown.','No exterior wall, framing, egress window product, net-clear opening, operating hardware, sill, well/guard, roof/eave, structure, yard/court or public-way route is modeled.','The 38 1/3 x 40 ft shell is unselected; room rectangles exclude no wall thickness and gross area is not net usable area.','No Revit/IFC or selected-D geometry changed; no code-compliance, accessibility, structural or construction-readiness claim is made.')
    source_hashes_sha256=$sourceHashes
    checks=$checks
    failed=@()
}
if(-not(Test-Path -LiteralPath $output)){New-Item -ItemType Directory -Path $output|Out-Null}
$report|ConvertTo-Json -Depth 16|Set-Content -LiteralPath (Join-Path $output 'm116-report.json') -Encoding utf8
$checksOut=[ordered]@{schema='forever-home.m116-u03-eero-wall-zone-checks.v1';passed=$checks.Count;failed=@();checks=$checks;source_hashes_sha256=$sourceHashes}
$checksOut|ConvertTo-Json -Depth 12|Set-Content -LiteralPath (Join-Path $output 'm116-checks.json') -Encoding utf8
Write-Output ("M116 conditional EERO wall-zone screen passed: {0}/{1}; 64 northeast privacy candidates and 9 northwest." -f $checks.Count,$checks.Count)
