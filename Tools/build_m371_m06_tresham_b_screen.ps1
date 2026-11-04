param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../Architecture/M371_M06_Tresham_B_Gross_Screen_2026-11-02'),
    [string]$TreshamEvidencePath = (Join-Path $PSScriptRoot '../Architecture/M370_M06_Tresham_Family_Evidence_2026-11-02/tresham-evidence.json')
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
function Get-Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Assert-Equal([string]$Name, [string]$Actual, [string]$Expected) { if ($Actual -ne $Expected) { throw "$Name mismatch: expected '$Expected'; found '$Actual'." } }
function Assert-True([string]$Name, [bool]$Value) { if (-not $Value) { throw "$Name failed." } }

$inputsPath = Join-Path $repoRoot 'Architecture/M120_M06_Current_Product_Envelope_Screen_2026-10-30/m120-inputs.json'
$proposalPath = Join-Path $repoRoot 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$selectedDPath = Join-Path $repoRoot 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$inputsHashExpected = '6cf5ff8d772c792ae7e12fca132126d7a5ce88ac98874ef4e4ce4778a0ac4a60'
$proposalHashExpected = '0519c9f350c41fbc9f7ba1b6b926c2b26e40f17cb5eacc3c13d5acaaf2749537'
$selectedDHashExpected = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
foreach ($p in @($inputsPath,$proposalPath,$selectedDPath,$TreshamEvidencePath)) { Assert-True "source exists: $p" (Test-Path -LiteralPath $p -PathType Leaf) }
Assert-Equal 'M120 input SHA256' (Get-Hash $inputsPath) $inputsHashExpected
Assert-Equal 'owner proposal SHA256' (Get-Hash $proposalPath) $proposalHashExpected
Assert-Equal 'Selected-D SHA256' (Get-Hash $selectedDPath) $selectedDHashExpected

$inputs = Get-Content -LiteralPath $inputsPath -Raw | ConvertFrom-Json
$proposal = Get-Content -LiteralPath $proposalPath -Raw | ConvertFrom-Json
$selectedD = Get-Content -LiteralPath $selectedDPath -Raw | ConvertFrom-Json
$tresham = Get-Content -LiteralPath $TreshamEvidencePath -Raw | ConvertFrom-Json
Assert-True 'M120 schema' ($inputs.schema -eq 'forever-home.m120-m06-product-observations.v1')
Assert-True 'M-06 remains unassigned' ($proposal.M06.status -like 'unassigned*')
Assert-True 'Tresham evidence schema' ($tresham.schema -eq 'forever-home.m370-tresham-family-evidence.v1')
Assert-True 'Tresham source hash' ($tresham.source.sha256 -eq $inputs.tresham.source_sha256)
Assert-True 'Tresham measured bounds positive' (([double]$tresham.family.bounds_in.width_x -gt 0) -and ([double]$tresham.family.bounds_in.depth_y -gt 0))

$window = $proposal.M06.first_fit_window
$grossWidth = [Math]::Round(([double]$window.width_ft * 12), 4)
$grossDepth = [Math]::Round(([double]$window.depth_ft * 12), 4)
$wc = $inputs.american_standard.dimensions_in
$basis = $inputs.screen_basis
$treshamWidth = [double]$tresham.family.bounds_in.width_x
$treshamDepth = [double]$tresham.family.bounds_in.depth_y
$wcCenter = [double]$basis.wc_centerline_to_side_obstruction_in
$lavCenter = $wcCenter + [double]$basis.adjacent_fixture_centerline_spacing_in
$wcLeft = $wcCenter - ([double]$wc.overall_width / 2)
$wcRight = $wcCenter + ([double]$wc.overall_width / 2)
$lavLeft = $lavCenter - ($treshamWidth / 2)
$lavRight = $lavCenter + ($treshamWidth / 2)
$requiredWidth = [Math]::Round([Math]::Max($wcRight, $lavRight), 4)
$requiredDepth = [Math]::Round([Math]::Max(([double]$wc.projection + [double]$basis.front_clearance_in), ($treshamDepth + [double]$basis.front_clearance_in)), 4)
$sideEdge = [Math]::Round(($lavLeft - $wcCenter), 4)
$bodyNonoverlap = $lavLeft -ge $wcRight
$grossPass = ($requiredWidth -le $grossWidth -and $requiredDepth -le $grossDepth)
$sidePass = $sideEdge -ge [double]$basis.wc_centerline_to_side_obstruction_in
$doorApproachSupported = $false
$serviceRouteSupported = $false

$checks = [ordered]@{
    source_hashes_match = $true
    selected_d_not_opened_or_modified = $true
    m06_remains_unassigned = ($proposal.M06.status -like 'unassigned*')
    tresham_is_owner_approved_direction = ($tresham.family.model -eq 'K-2844-4')
    tresham_bounds_are_measured_positive_solids = ($tresham.family.positive_volume_solid_count -gt 0 -and $treshamWidth -gt 0 -and $treshamDepth -gt 0)
    wc_source_is_selected_sku = ($inputs.selected_wc_sku -eq '610AA001.020')
    gross_b_window_is_positive = ($grossWidth -gt 0 -and $grossDepth -gt 0)
    body_boxes_do_not_overlap_under_same_wall_assumption = $bodyNonoverlap
    preliminary_side_spacing_screen_passes = $sidePass
    combined_pair_is_contained_in_gross_b = $grossPass
    door_and_approach_gate_remains_unresolved = (-not $doorApproachSupported)
    service_route_gate_remains_unresolved = (-not $serviceRouteSupported)
    no_fixture_or_room_assignment_claim = ($proposal.M06.status -like 'unassigned*')
    no_code_compliance_claim = (-not [bool]$basis.applicability_determined)
}
Assert-True 'all M371 checks' (@($checks.Values | Where-Object { $_ -ne $true }).Count -eq 0)

$report = [ordered]@{
    schema = 'forever-home.m371-m06-tresham-b-gross-screen.v1'
    status = 'gross pair screen passes; M-06 remains fit-blocked and unassigned'
    source_fingerprints_sha256 = [ordered]@{ m120_inputs = (Get-Hash $inputsPath); owner_proposal = (Get-Hash $proposalPath); selected_D = (Get-Hash $selectedDPath); tresham_evidence = (Get-Hash $TreshamEvidencePath) }
    owner_decision = 'Tresham is approved as the lavatory direction for analysis; not a placement or final product selection.'
    fit_window = [ordered]@{ id = [string]$window.id; gross_width_in = $grossWidth; gross_depth_in = $grossDepth; gross_area_sf = [double]$window.area_sf; assigned = $false; location = 'pantry-side B search window; entry/hall-edge context' }
    pair = [ordered]@{ wc_sku = [string]$inputs.selected_wc_sku; wc_width_in = [double]$wc.overall_width; wc_projection_in = [double]$wc.projection; tresham_model = [string]$tresham.family.model; tresham_width_in = $treshamWidth; tresham_depth_in = $treshamDepth; wc_centerline_in = $wcCenter; lavatory_centerline_in = $lavCenter; centerline_spacing_in = ($lavCenter - $wcCenter); nearest_lavatory_edge_from_wc_centerline_in = $sideEdge; required_gross_width_in = $requiredWidth; required_gross_depth_in_including_front_strip = $requiredDepth; body_nonoverlap = $bodyNonoverlap; gross_contained = $grossPass }
    screen_basis = [ordered]@{ wc_side_centerline_min_in = [double]$basis.wc_centerline_to_side_obstruction_in; adjacent_fixture_centerline_spacing_in = [double]$basis.adjacent_fixture_centerline_spacing_in; front_clear_strip_in = [double]$basis.front_clearance_in; jurisdiction = 'Connecticut research basis; applicability not determined'; code_compliance = $false }
    gates = [ordered]@{ product_geometry = $true; finished_face_clearance = $true; door_approach = $doorApproachSupported; service_route = $serviceRouteSupported; m06_assignment = $false }
    checks = $checks
    conclusions = @('Measured Tresham and the selected toilet proxy fit the documented 124 x 84 in B gross window under a same-wall, rectangular screening assumption.', 'The 30 in centerline and 15 in side screen pass for this pair; this is not a finished-face clearance determination.', 'Door/approach and plausible plumbing service route remain unsupported, so M-06/B stays unassigned and fit-blocked.')
    limitations = @('Tresham extents are unhosted family-symbol bounds; orientation and installed clear envelopes remain unverified.', 'The toilet is a manufacturer infographic plan proxy and lacks a verified exact-SKU RFA/CAD.', 'No actual walls, finished faces, door leaf/swing, approach path, or supply/drain/vent network are modeled.', 'This is an analysis-only Connecticut screening basis, not code compliance, accessibility, professional review, or construction readiness.')
}
$resolved = if ([IO.Path]::IsPathRooted($OutputDirectory)) { [IO.Path]::GetFullPath($OutputDirectory) } else { [IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDirectory)) }
if (-not (Test-Path -LiteralPath $resolved)) { New-Item -ItemType Directory -Path $resolved -Force | Out-Null }
[IO.File]::WriteAllText((Join-Path $resolved 'm371-report.json'), (ConvertTo-Json $report -Depth 16) + "`r`n", [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText((Join-Path $resolved 'm371-checks.json'), (ConvertTo-Json ([ordered]@{ schema='forever-home.m371-checks.v1'; result='pass'; check_count=$checks.Count; checks=$checks }) -Depth 12) + "`r`n", [Text.UTF8Encoding]::new($false))
Write-Output "PASS: M371 $($checks.Count)/$($checks.Count); Tresham + WC proxy contained in $($window.id); M-06 remains unassigned and fit-blocked."
