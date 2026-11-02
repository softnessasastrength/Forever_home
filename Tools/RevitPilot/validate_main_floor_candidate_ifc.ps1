param(
    [Parameter(Mandatory = $true)] [string] $RunDirectory,
    [Parameter(Mandatory = $true)] [string] $Output
)

$ErrorActionPreference = 'Stop'
$run = (Resolve-Path $RunDirectory).Path
$manifestPath = Join-Path $run 'ifc-manifest.json'
if (-not (Test-Path $manifestPath)) { throw "Missing IFC manifest: $manifestPath" }
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$ifcPath = Join-Path $repo ($manifest.ifc -replace '/', '\')
if (-not (Test-Path $ifcPath)) { throw "Missing IFC file: $ifcPath" }
$bytes = [IO.File]::ReadAllBytes($ifcPath)
$text = [Text.Encoding]::ASCII.GetString($bytes)
$hash = (Get-FileHash $ifcPath -Algorithm SHA256).Hash
$wallCount = ([regex]::Matches($text, '(?m)#\d+=IFCWALL(STANDARDCASE)?\(')).Count
$checks = @(
    [pscustomobject]@{ name = 'manifest_ifc_hash'; pass = ($hash -eq $manifest.ifc_sha256); detail = "$hash" },
    [pscustomobject]@{ name = 'non_empty'; pass = ($bytes.Length -gt 0); detail = "$($bytes.Length) bytes" },
    [pscustomobject]@{ name = 'step_header'; pass = $text.StartsWith('ISO-10303-21;'); detail = $text.Substring(0, [Math]::Min(15, $text.Length)) },
    [pscustomobject]@{ name = 'ifc2x3_schema'; pass = ($text -match "FILE_SCHEMA\('\('IFC2X3'\)\)" -or $text -match "FILE_SCHEMA\(\('IFC2X3'\)\)"); detail = 'IFC2X3' },
    [pscustomobject]@{ name = 'wall_entities_present'; pass = ($wallCount -ge 42); detail = "$wallCount IFCWALL/IFCWALLSTANDARDCASE entities" }
)
$result = [pscustomobject]@{
    schema = 'forever-home-main-floor-candidate-ifc-validation-v1'
    run_directory = $run
    ifc = $ifcPath
    manifest_ifc_sha256 = $manifest.ifc_sha256
    actual_ifc_sha256 = $hash
    checks = $checks
    pass = [bool]($checks.pass -notcontains $false)
    limitations = @('This checks export integrity and entity presence only; it is not code, structural, professional or construction approval.')
}
$json = $result | ConvertTo-Json -Depth 6
New-Item -ItemType Directory -Force (Split-Path $Output) | Out-Null
Set-Content -Path $Output -Value $json -Encoding UTF8
if (-not $result.pass) { throw "Candidate IFC validation failed: $Output" }
$result | Format-List
