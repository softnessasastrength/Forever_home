param(
    [string]$OutputPath = '.local/revalidation/m06-proxy-setup.json',
    [string]$ToiletFamilyPath = '.local/revit-pilot/family-intake/candidates/toto-nexus-ms442124cefg.rfa',
    [string]$SinkFamilyPath = '.local/revit-pilot/family-intake/candidates/american-standard-evolution-0467004.020.rfa'
)

$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
function Full([string]$p) { if ([IO.Path]::IsPathRooted($p)) { $p } else { Join-Path $repo $p } }
function Check([string]$name, [bool]$pass, [string]$detail) { $script:checks += [pscustomobject]@{ name=$name; pass=$pass; detail=$detail } }

$checks = @()
$toilet = Full $ToiletFamilyPath
$sink = Full $SinkFamilyPath
$toiletHash = (Get-FileHash -LiteralPath $toilet -Algorithm SHA256).Hash.ToUpperInvariant()
$sinkHash = (Get-FileHash -LiteralPath $sink -Algorithm SHA256).Hash.ToUpperInvariant()
$toiletSource = Get-Content -LiteralPath (Join-Path $repo '.local/revit-pilot/family-intake/candidates/toto-nexus-ms442124cefg.source.json') -Raw | ConvertFrom-Json
$sinkReport = Get-Content -LiteralPath (Join-Path $repo 'Research/M06_Evolution_Family_Envelope_Screen_2026-10-28.json') -Raw | ConvertFrom-Json

Check 'toilet_proxy_hash' ($toiletHash -eq 'ACA931BF657DB567B4A45DC47F6CB526C6F701969ABDCF99EEE29FAF38BE72A0') 'TOTO Nexus RFA is the hash-pinned inspected proxy.'
Check 'toilet_proxy_source' ($toiletSource.sku -eq 'MS442124CEFG' -and $toiletSource.status -like '*research*' -and $toiletSource.account_or_login_used -eq $false) 'Proxy identity and research-only disposition are recorded.'
Check 'sink_family_hash' ($sinkHash -eq '39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA') 'Evolution RFA remains the preserved hash-pinned lavatory candidate.'
Check 'sink_geometry_evidence' ($sinkReport.result -eq 'PASS' -and $sinkReport.check_count -ge 17) 'Measured Evolution family envelope report is present.'
Check 'selected_champion_not_replaced' ($toiletSource.sku -ne '610AA001.020') 'The proxy is not silently represented as the owner-selected Champion.'

$failed = @($checks | Where-Object { -not $_.pass })
$report = [ordered]@{
    schema = 'forever-home-m06-proxy-setup-v1'
    status = if ($failed.Count -eq 0) { 'pass-proxy-only' } else { 'fail' }
    owner_intent = [ordered]@{ sku='610AA001.020'; status='unverified exact current-SKU; retained as design intent only' }
    proxy_setup = [ordered]@{
        toilet = [ordered]@{ sku='MS442124CEFG'; product='TOTO Nexus two-piece toilet'; rfa_sha256=$toiletHash; measured_plan_in=[ordered]@{ width=18.5; depth=28.625 }; status='proxy comparison only' }
        lavatory = [ordered]@{ sku='0467400.020'; product='American Standard Evolution 4-in centerset pedestal sink combination'; rfa_sha256=$sinkHash; status='verified family evidence; not assigned' }
    }
    coordination_gates = [ordered]@{ exact_owner_product_geometry=$false; finished_face_clearance=$false; door_and_approach=$false; service_route=$false; room_B_assignment=$false }
    checks = $checks
    limitations = @('TOTO Nexus is a different manufacturer/product and is not a substitute selection.', 'Evolution is discontinued research evidence and its hosted assembly/orientation remains limited.', 'No room, wall faces, door, approach, plumbing route or IFC placement is created by this contract.', 'B remains unassigned; no code-compliance, accessibility, structural, professional, permit or construction-readiness conclusion follows.')
}
$out = Full $OutputPath
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out) | Out-Null
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $out -Encoding UTF8
if ($failed.Count -gt 0) { throw "M-06 proxy setup failed $($failed.Count) checks." }
Write-Output "PASS: M-06 proxy setup contract passed $($checks.Count) checks; B remains unassigned. Report: $out"
