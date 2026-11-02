param(
    [Parameter(Mandatory = $true)][string]$StudyDirectory,
    [string]$Output = '.local/revalidation/documented-door-study.json'
)

$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
$study = (Resolve-Path -LiteralPath $StudyDirectory).Path
$manifestPath = Join-Path $study 'documented-door-study-manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "Missing documented door manifest: $manifestPath" }
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$checks = [System.Collections.Generic.List[object]]::new()
function Check([string]$Name, [bool]$Pass, [string]$Detail) { $checks.Add([pscustomobject]@{ name=$Name; pass=$Pass; detail=$Detail }) }
function Hash-Shared([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Resolve-StudyFile([string]$Name) { Join-Path $study $Name }

Check 'schema' ($manifest.schema -eq 'forever-home-documented-door-study-v1') 'documented nominal door study schema'
Check 'status' ($manifest.status -eq 'disposable nominal door-family comparison; not selected-D') 'disposable status retained'
Check 'source_hashes' (@($manifest.source_files).Count -eq 2 -and @($manifest.source_files | Where-Object {
    $path = Join-Path $repo $_.path
    (Test-Path -LiteralPath $path -PathType Leaf) -and (Hash-Shared $path) -eq $_.sha256
}).Count -eq 2) 'Material Schedule and Main Floor Schematic hashes match'
Check 'case_count' (@($manifest.cases).Count -eq 2) 'baseline and wider pantry cases present'
Check 'case_ids' (@($manifest.cases.case_id | Sort-Object) -join ',' -eq 'documented-baseline,pantry-wider-comparison') 'expected case identifiers'
Check 'wall_counts' (@($manifest.cases | Where-Object { $_.wall_count -eq 8 }).Count -eq 2) 'eight native host walls per case'
Check 'door_counts' (@($manifest.cases | Where-Object { $_.door_count -eq 4 -and @($_.door_records).Count -eq 4 }).Count -eq 2) 'four nominal door-family records per case'
Check 'unselected' (@($manifest.cases | Where-Object { @($_.door_records | Where-Object { $_.selected -ne $false }).Count -eq 0 }).Count -eq 2) 'all door records remain unselected'
Check 'pantry_widths' (@($manifest.cases | Where-Object { $_.pantry_width_ft -in @(2.5, 3.0) }).Count -eq 2) 'documented 30-in versus wider pantry comparison'

$fileChecks = @()
foreach ($case in @($manifest.cases)) {
    $rvtPath = Resolve-StudyFile $case.saved_rvt
    $ifcPath = Resolve-StudyFile $case.ifc
    $rvtPass = (Test-Path -LiteralPath $rvtPath -PathType Leaf) -and (Hash-Shared $rvtPath) -eq $case.saved_rvt_sha256 -and (Get-Item -LiteralPath $rvtPath).Length -gt 0
    $ifcText = if (Test-Path -LiteralPath $ifcPath -PathType Leaf) { Get-Content -LiteralPath $ifcPath -Raw } else { '' }
    $ifcPass = (Test-Path -LiteralPath $ifcPath -PathType Leaf) -and (Hash-Shared $ifcPath) -eq $case.ifc_sha256 -and (Get-Item -LiteralPath $ifcPath).Length -gt 0 -and $ifcText.Contains("FILE_SCHEMA(('IFC2X3'))") -and $ifcText.Contains('IFCDOOR')
    $fileChecks += [pscustomobject]@{ case_id=$case.case_id; rvt=$rvtPass; ifc=$ifcPass }
}
Check 'files' (@($fileChecks | Where-Object { $_.rvt -and $_.ifc }).Count -eq 2) 'RVT and IFC2x3 hashes, non-empty files and IFC door entities'

$outPath = if ([IO.Path]::IsPathRooted($Output)) { [IO.Path]::GetFullPath($Output) } else { Join-Path $repo $Output }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outPath) | Out-Null
$failed = @($checks | Where-Object { -not $_.pass })
$report = [ordered]@{ schema='forever-home-documented-door-study-validation-v1'; status=if ($failed.Count -eq 0) { 'pass' } else { 'fail' }; passed=@($checks | Where-Object pass).Count; total=$checks.Count; checks=$checks; files=$fileChecks; limitations=@('Nominal generic door families are comparison proxies only.', 'No clear opening, frame, swing, threshold, assembly, code, accessibility, structural, professional, permit or construction conclusion follows.') }
$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $outPath -Encoding UTF8
if ($failed.Count -gt 0) { $failed | Format-Table | Out-String | Write-Error; exit 1 }
Write-Output "PASS: $($report.passed)/$($report.total) documented door study checks."
