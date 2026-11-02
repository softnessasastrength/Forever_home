param(
    [string]$StudyDirectory = '.local/revit-pilot/m06-proxy-study/20261102T122827829Z',
    [string]$PairReport = '.local/revalidation/m06-current-pair-20261102-replay.json',
    [string]$SelectedD = 'Architecture/Selected_Design_Iteration_2026-10-27/study.json',
    [string]$Output = '.local/revalidation/m351-m06-proxy-clearance-approach.json'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
function Resolve-RepoPath([string]$Path) {
    if ([IO.Path]::IsPathRooted($Path)) { return [IO.Path]::GetFullPath($Path) }
    return [IO.Path]::GetFullPath((Join-Path $root $Path))
}
function Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Assert([bool]$Condition, [string]$Message) { if (-not $Condition) { throw $Message } }

$manifestPath = Join-Path (Resolve-RepoPath $StudyDirectory) 'm06-proxy-study-manifest.json'
$pairPath = Resolve-RepoPath $PairReport
$selectedPath = Resolve-RepoPath $SelectedD
Assert (Test-Path $manifestPath) "Missing M-06 proxy manifest: $manifestPath"
Assert (Test-Path $pairPath) "Missing current-SKU pair report: $pairPath"
Assert (Test-Path $selectedPath) "Missing Selected-D source: $selectedPath"

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$pair = Get-Content $pairPath -Raw | ConvertFrom-Json
$selected = Get-Content $selectedPath -Raw | ConvertFrom-Json
$selectedHash = Hash $selectedPath
$expectedSelectedHash = '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
Assert ($selectedHash -eq $expectedSelectedHash) 'Selected-D source fingerprint changed.'
Assert ($manifest.schema -eq 'forever-home-m06-proxy-study-v1') 'Unexpected proxy manifest schema.'
Assert ($manifest.status -eq 'disposable proxy comparison; not selected and B unassigned') 'Proxy study is not explicitly unselected.'
Assert ($manifest.gates.exact_owner_product_geometry -eq $false -and $manifest.gates.room_B_assignment -eq $false) 'Proxy gates must remain closed.'
Assert ($pair.schema -eq 'forever-home-m06-current-sku-toilet-sink-gross-pair-screen-v1') 'Unexpected current-SKU pair screen schema.'
Assert ($pair.zone.gross_width_in -eq 158 -and $pair.zone.gross_depth_in -eq 84) 'Current pair screen no longer uses the Selected-D B window.'
Assert ($pair.gates.m06_assigned -eq $false -and $pair.gates.door_and_approach -eq $false -and $pair.gates.water_waste_and_vent_route -eq $false) 'Current pair screen unexpectedly promoted an M-06 gate.'

$checks = [ordered]@{
    selected_d_preserved = ($selectedHash -eq $expectedSelectedHash)
    proxy_manifest_unselected = ($manifest.status -eq 'disposable proxy comparison; not selected and B unassigned')
    proxy_families_hash_pinned = ($manifest.toilet_proxy.rfa_sha256.Length -eq 64 -and $manifest.lavatory_evidence.rfa_sha256.Length -eq 64)
    selected_d_B_gross_window = ($pair.zone.gross_width_in -eq 158 -and $pair.zone.gross_depth_in -eq 84)
    current_pair_screen_passed = ($pair.result -like 'PASS:*' -and $pair.fixture_pairs.Count -eq 16)
    exact_owner_product_geometry_open = ($manifest.gates.exact_owner_product_geometry -eq $false)
    door_and_approach_open = ($manifest.gates.door_and_approach -eq $false)
    service_route_open = ($manifest.gates.service_route -eq $false)
    room_B_assignment_open = ($manifest.gates.room_B_assignment -eq $false)
}
if (@($checks.GetEnumerator() | Where-Object { $_.Value -ne $true }).Count -gt 0) { throw 'M351 proxy clearance/approach checks failed.' }

$report = [ordered]@{
    schema = 'forever-home-m06-proxy-clearance-approach-screen-v1'
    status = 'PASS: proxy and current-SKU gross evidence are source-pinned; no room fit or assignment established.'
    source_hashes_sha256 = [ordered]@{ selected_d = $selectedHash; proxy_manifest = (Hash $manifestPath); current_pair_report = (Hash $pairPath) }
    gross_window = [ordered]@{ id = 'east_of_core'; width_in = 158; depth_in = 84; remains_unassigned = $true }
    proxy_inputs = [ordered]@{
        toilet = [ordered]@{ sku = $manifest.toilet_proxy.sku; measured_plan_in = $manifest.toilet_proxy.measured_plan_in; exact_owner_sku = $false }
        lavatory = [ordered]@{ sku = $manifest.lavatory_evidence.sku; measured_envelope_in = $manifest.lavatory_evidence.measured_envelope_in; selected = $false }
    }
    screening_basis = [ordered]@{ wc_side_in = 15; adjacent_fixture_centers_in = 30; front_clearance_in = 21; applicability_confirmed = $false }
    checks = $checks
    gates = [ordered]@{ exact_owner_product_geometry = $false; finished_face_clearance = $false; door_and_approach = $false; service_route = $false; room_B_assignment = $false }
    limitations = @(
        'The proxy bodies are measured family evidence, not the owner-selected Champion PRO or a selected lavatory.',
        'The 15/30/21-in values are a preliminary residential screening basis only; project applicability is unresolved.',
        'The report does not model finished wall faces, a door leaf/swing, arrival approach, or water/waste/vent routing.',
        'A passing gross-screen result does not establish a room fit or authorize M-06/B assignment.'
    )
}
$outputPath = Resolve-RepoPath $Output
[IO.Directory]::CreateDirectory((Split-Path $outputPath -Parent)) | Out-Null
[IO.File]::WriteAllText($outputPath, (ConvertTo-Json $report -Depth 16) + "`r`n", [Text.UTF8Encoding]::new($false))
Write-Output "PASS: M351 proxy clearance/approach screen; exact product, door/approach, service route and B assignment remain open."
