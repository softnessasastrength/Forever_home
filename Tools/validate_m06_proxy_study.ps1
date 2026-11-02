param(
    [Parameter(Mandatory = $true)]
    [string]$StudyDirectory
)

$ErrorActionPreference = 'Stop'
$sha256 = {
    param([string]$Path)
    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete)
    try { (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash } finally { $stream.Dispose() }
}
$manifestPath = Join-Path $StudyDirectory 'm06-proxy-study-manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath)) { throw "Missing manifest: $manifestPath" }

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$checks = [ordered]@{}
$checks.schema = $manifest.schema -eq 'forever-home-m06-proxy-study-v1'
$checks.status = $manifest.status -eq 'disposable proxy comparison; not selected and B unassigned'
$checks.owner_intent = $manifest.owner_intent -eq 'American Standard Champion PRO 610AA001.020'
$checks.proxy_hashes_present = ($manifest.toilet_proxy.rfa_sha256.Length -eq 64 -and $manifest.lavatory_evidence.rfa_sha256.Length -eq 64)
$checks.gross_window = ($manifest.gross_window_in[0] -eq 158 -and $manifest.gross_window_in[1] -eq 84)
$checks.two_records = ($manifest.records.Count -eq 2)
$checks.records_unselected = @($manifest.records | Where-Object { $_.selected -ne $false }).Count -eq 0
$checks.gates_unassigned = @($manifest.gates.PSObject.Properties | Where-Object { $_.Value -ne $false }).Count -eq 0

$rvtPath = Join-Path $StudyDirectory $manifest.saved_rvt
$ifcPath = Join-Path $StudyDirectory $manifest.ifc.file
$checks.rvt_present = Test-Path -LiteralPath $rvtPath
$checks.ifc_present = Test-Path -LiteralPath $ifcPath
if ($checks.rvt_present) { $checks.rvt_hash = (& $sha256 $rvtPath) -eq $manifest.saved_rvt_sha256 } else { $checks.rvt_hash = $false }
if ($checks.ifc_present) {
    $ifcHash = & $sha256 $ifcPath
    $ifcText = Get-Content -LiteralPath $ifcPath -Raw
    $checks.ifc_hash = $ifcHash -eq $manifest.ifc.sha256
    $checks.ifc2x3 = $ifcText -match "FILE_SCHEMA\s*\(\s*\(\s*'IFC2X3"
    $checks.ifc_walls = ([regex]::Matches($ifcText, '#\d+=IFCWALL(?:STANDARDCASE)?\b', 'IgnoreCase')).Count -ge 4
    $checks.ifc_proxy_products = ($ifcText -match 'toto-nexus-ms442124cefg' -and $ifcText -match 'american-standard-evolution-0467004.020')
} else {
    $checks.ifc_hash = $false; $checks.ifc2x3 = $false; $checks.ifc_walls = $false; $checks.ifc_proxy_products = $false
}

$failed = @($checks.GetEnumerator() | Where-Object { $_.Value -ne $true })
[pscustomobject]@{ StudyDirectory = (Resolve-Path -LiteralPath $StudyDirectory).Path; Checks = $checks; Failed = $failed.Name; Status = if ($failed.Count -eq 0) { 'PASS' } else { 'FAIL' } } | ConvertTo-Json -Depth 6
if ($failed.Count -gt 0) { exit 1 }
