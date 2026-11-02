param(
    [Parameter(Mandatory = $true)]
    [string]$StudyDirectory,
    [string]$ExpectedSourceSHA256 = '3b1cbdaa844d35bd462f6e59a828b82f7870fde4ee7397bac09f4ca0c2f9b949'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$study = [IO.Path]::GetFullPath($StudyDirectory)
function Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Check([string]$Name, [bool]$Pass, [string]$Evidence) { [pscustomobject]@{ name=$Name; passed=$Pass; evidence=$Evidence } }
function Require([string]$Name, [bool]$Pass, [string]$Evidence) { if (-not $Pass) { throw "M372 validation failed: $Name; $Evidence" } }

$manifestPath = Join-Path $study 'm06-tresham-b-study-manifest.json'
$rvtPath = Join-Path $study 'FH_M06_Tresham_B_Study.rvt'
$ifcPath = Join-Path $study 'FH_M06_Tresham_B_Study.ifc'
foreach ($p in @($manifestPath,$rvtPath,$ifcPath)) { Require "required file $p" (Test-Path -LiteralPath $p -PathType Leaf) 'missing' }
$m = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$checks = @(
    (Check 'schema' ($m.schema -eq 'forever-home-m372-m06-tresham-b-study-v1') $m.schema),
    (Check 'source_hash' ([string]$m.source_sha256 -eq $ExpectedSourceSHA256) "reported=$($m.source_sha256)"),
    (Check 'one_family_instance' ([int]$m.family_instances -eq 1) "family_instances=$($m.family_instances)"),
    (Check 'owner_direction' ([string]$m.family -eq 'kohler-tresham-k-2844-4-0') "family=$($m.family)"),
    (Check 'toilet_proxy_dimensions' ([double]$m.toilet_proxy.width_in -eq 19.0 -and [double]$m.toilet_proxy.projection_in -eq 30.25) ($m.toilet_proxy | ConvertTo-Json -Compress)),
    (Check 'door_gate_false' ($m.door_approach_supported -eq $false) "door=$($m.door_approach_supported)"),
    (Check 'service_gate_false' ($m.service_route_supported -eq $false) "service=$($m.service_route_supported)"),
    (Check 'unselected' ($m.selected -eq $false) "selected=$($m.selected)"),
    (Check 'rvt_hash' ((Hash $rvtPath) -eq [string]$m.saved_rvt_sha256) "reported=$($m.saved_rvt_sha256)"),
    (Check 'ifc_hash' ((Hash $ifcPath) -eq [string]$m.ifc_sha256) "reported=$($m.ifc_sha256)"),
    (Check 'ifc2x3_schema' ($m.ifc2x3 -eq $true -and (Get-Content -LiteralPath $ifcPath -Raw).Contains("FILE_SCHEMA(('IFC2X3'))")) "ifc2x3=$($m.ifc2x3)"),
    (Check 'limitations_present' (@($m.limitations).Count -ge 4) "count=$(@($m.limitations).Count)")
)
$failed = @($checks | Where-Object { -not $_.passed })
$checks | ForEach-Object { '{0} {1}: {2}' -f ($(if ($_.passed) { 'PASS' } else { 'FAIL' }), $_.name, $_.evidence) }
Write-Output "SUMMARY $(@($checks | Where-Object passed).Count)/$($checks.Count) checks passed"
if ($failed.Count -gt 0) { throw "M372 validation failed: $($failed.Count) check(s) failed." }
