param(
    [Parameter(Mandatory = $true)][string]$StudyDirectory,
    [string]$Output = '.local/revalidation/documented-opening-assembly.json'
)
$ErrorActionPreference = 'Stop'; $repo = (Get-Location).Path; $study = (Resolve-Path -LiteralPath $StudyDirectory).Path
$manifestPath = Join-Path $study 'documented-opening-assembly-manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "Missing opening assembly manifest: $manifestPath" }
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json; $checks = [System.Collections.Generic.List[object]]::new()
function Check([string]$Name,[bool]$Pass,[string]$Detail){$checks.Add([pscustomobject]@{name=$Name;pass=$Pass;detail=$Detail})}
function Hash([string]$Path){(Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()}
Check 'schema' ($manifest.schema -eq 'forever-home-documented-opening-assembly-v1') 'documented opening assembly schema'
Check 'status' ($manifest.status -eq 'disposable documented opening assembly comparison; not selected-D') 'disposable status retained'
Check 'source_hashes' (@($manifest.source_files).Count -eq 2 -and @($manifest.source_files | Where-Object { $p=Join-Path $repo $_.path; (Test-Path -LiteralPath $p -PathType Leaf) -and (Hash $p) -eq $_.sha256 }).Count -eq 2) 'source schedule and schematic hashes match'
Check 'case_count' (@($manifest.cases).Count -eq 2) 'two documented pantry cases present'
Check 'counts' (@($manifest.cases | Where-Object { $_.wall_count -eq 16 -and $_.door_count -eq 4 -and $_.opening_count -eq 4 -and @($_.door_records).Count -eq 4 }).Count -eq 2) 'split jamb and host walls with four openings per case'
Check 'unselected' (@($manifest.cases | Where-Object { $_.selected -eq $false -and @($_.door_records | Where-Object { $_.selected -ne $false -or $_.opening_modeled -ne $true }).Count -eq 0 }).Count -eq 2) 'opening records remain comparison-only'
Check 'pantry_widths' (@($manifest.cases | Where-Object { $_.pantry_width_ft -in @(2.5,3.0) }).Count -eq 2) '30-in and 36-in pantry cases retained'
$files=@(); foreach($case in @($manifest.cases)){ $r=Join-Path $study $case.saved_rvt; $i=Join-Path $study $case.ifc; $it=if(Test-Path -LiteralPath $i){Get-Content -LiteralPath $i -Raw}else{''}; $files += [pscustomobject]@{case_id=$case.case_id;rvt=((Test-Path -LiteralPath $r -PathType Leaf) -and (Hash $r)-eq$case.saved_rvt_sha256 -and (Get-Item $r).Length -gt 0);ifc=((Test-Path -LiteralPath $i -PathType Leaf) -and (Hash $i)-eq$case.ifc_sha256 -and (Get-Item $i).Length -gt 0 -and $it.Contains("FILE_SCHEMA(('IFC2X3'))") -and $it.Contains('IFCDOOR'))} }
Check 'files' (@($files|Where-Object{$_.rvt -and $_.ifc}).Count -eq 2) 'RVT and IFC2x3 files hash and contain door entities'
$outPath=if([IO.Path]::IsPathRooted($Output)){$Output}else{Join-Path $repo $Output}; New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outPath)|Out-Null; $failed=@($checks|Where-Object{-not$_.pass}); $report=[ordered]@{schema='forever-home-documented-opening-assembly-validation-v1';status=if($failed.Count-eq 0){'pass'}else{'fail'};passed=@($checks|Where-Object pass).Count;total=$checks.Count;checks=$checks;files=$files;limitations=@('Nominal documented openings are comparison geometry only.','Wall/floor assemblies, frame, swing, threshold, clear width, code, accessibility, structural, MEP, professional, permit and construction conclusions remain unresolved.')}; $report|ConvertTo-Json -Depth 12|Set-Content -LiteralPath $outPath -Encoding UTF8; if($failed.Count){$failed|Format-Table|Out-String|Write-Error;exit 1}; Write-Output "PASS: $($report.passed)/$($report.total) documented opening assembly checks."
