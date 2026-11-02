param(
    [Parameter(Mandatory = $true)][string]$StudyDirectory,
    [string]$Output = '.local/revalidation/integrated-main-floor-assembly.json'
)
$ErrorActionPreference = 'Stop'; $repo = (Get-Location).Path; $study = (Resolve-Path -LiteralPath $StudyDirectory).Path
$manifestPath = Join-Path $study 'integrated-main-floor-assembly-manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "Missing integrated assembly manifest: $manifestPath" }
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json; $checks = [System.Collections.Generic.List[object]]::new()
function Check([string]$Name,[bool]$Pass,[string]$Detail){$checks.Add([pscustomobject]@{name=$Name;pass=$Pass;detail=$Detail})}
function Hash([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
Check 'schema' ($manifest.schema -eq 'forever-home-integrated-main-floor-assembly-v1') 'integrated main-floor assembly schema'
Check 'status' ($manifest.status -eq 'disposable integrated assembly comparison; not selected-D') 'disposable status retained'
Check 'input_hash' ((Hash (Join-Path $repo $manifest.input)) -eq $manifest.input_sha256) 'candidate input hash matches'
Check 'case_count' (@($manifest.cases).Count -eq 3) '8/9/10-ft cases present'
Check 'inventory' ($manifest.wall_count -eq 57 -and $manifest.door_count -eq 12) '19 native walls and four door instances per case'
Check 'cases' (@($manifest.cases | Where-Object { $_.wall_count -eq 19 -and $_.door_count -eq 4 -and $_.selected -eq $false -and @($_.door_records).Count -eq 4 -and @($_.door_records | Where-Object { $_.selected -ne $false -or $_.opening_modeled -ne $true }).Count -eq 0 }).Count -eq 3) 'all cases remain unselected with four documented openings'
$r=Join-Path $study $manifest.saved_rvt; $i=Join-Path $study $manifest.ifc; $it=if(Test-Path -LiteralPath $i){Get-Content -LiteralPath $i -Raw}else{''}
Check 'files' ((Test-Path -LiteralPath $r -PathType Leaf) -and (Hash $r) -eq $manifest.saved_rvt_sha256 -and (Get-Item $r).Length -gt 0 -and (Test-Path -LiteralPath $i -PathType Leaf) -and (Hash $i) -eq $manifest.ifc_sha256 -and (Get-Item $i).Length -gt 0 -and $manifest.ifc2x3 -eq $true -and $it.Contains('IFCDOOR') -and $it.Contains('IFCWALL')) 'RVT and IFC2x3 hashes and entities'
$outPath=if([IO.Path]::IsPathRooted($Output)){$Output}else{Join-Path $repo $Output}; New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outPath)|Out-Null; $failed=@($checks|Where-Object{-not$_.pass}); $report=[ordered]@{schema='forever-home-integrated-main-floor-assembly-validation-v1';status=if($failed.Count-eq 0){'pass'}else{'fail'};passed=@($checks|Where-Object pass).Count;total=$checks.Count;checks=$checks;limitations=@('This is a disposable candidate-21 assembly comparison only.','No code, accessibility, structural, MEP, professional, permit or construction conclusion follows.')}; $report|ConvertTo-Json -Depth 12|Set-Content -LiteralPath $outPath -Encoding UTF8; if($failed.Count){$failed|Format-Table|Out-String|Write-Error;exit 1}; Write-Output "PASS: $($report.passed)/$($report.total) integrated main-floor assembly checks."
