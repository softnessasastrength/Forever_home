[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$StudyDirectory)
$ErrorActionPreference = 'Stop'
$study = (Resolve-Path $StudyDirectory).Path
function Hash([string]$p) { (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant() }
$manifestPath = Join-Path $study 'interior-design-study-manifest.json'
$rvtPath = Join-Path $study 'FH_Interior_Design_Study.rvt'
$ifcPath = Join-Path $study 'FH_Interior_Design_Study.ifc'
foreach ($p in @($manifestPath,$rvtPath,$ifcPath)) { if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw "Missing required output: $p" } }
$m = Get-Content $manifestPath -Raw | ConvertFrom-Json
$checks = @(
    [pscustomobject]@{name='schema'; pass=($m.schema -eq 'forever-home-interior-design-study-v1'); evidence=$m.schema},
    [pscustomobject]@{name='selected_d_protected'; pass=($m.status -like '*not Selected-D*'); evidence=$m.status},
    [pscustomobject]@{name='three_cases'; pass=(@($m.cases).Count -eq 3); evidence="cases=$(@($m.cases).Count)"},
    [pscustomobject]@{name='wall_count'; pass=([int]$m.wall_count -eq 72); evidence="walls=$($m.wall_count)"},
    [pscustomobject]@{name='floor_count'; pass=([int]$m.floor_count -eq 3); evidence="floors=$($m.floor_count)"},
    [pscustomobject]@{name='island_count'; pass=([int]$m.kitchen_island_count -eq 3); evidence="islands=$($m.kitchen_island_count)"},
    [pscustomobject]@{name='bath_vignette_count'; pass=([int]$m.primary_bath_vignette_count -eq 3); evidence="baths=$($m.primary_bath_vignette_count)"},
    [pscustomobject]@{name='rvt_hash'; pass=((Hash $rvtPath) -eq [string]$m.saved_rvt_sha256); evidence=$m.saved_rvt_sha256},
    [pscustomobject]@{name='ifc_hash'; pass=((Hash $ifcPath) -eq [string]$m.ifc_sha256); evidence=$m.ifc_sha256},
    [pscustomobject]@{name='ifc2x3'; pass=($m.ifc2x3 -eq $true -and (Get-Content $ifcPath -Raw).Contains("FILE_SCHEMA(('IFC2X3'))")); evidence=$m.ifc2x3},
    [pscustomobject]@{name='limitations'; pass=(@($m.limitations).Count -ge 4); evidence="count=$(@($m.limitations).Count)"}
)
$checks | ForEach-Object { '{0} {1}: {2}' -f ($(if ($_.pass) {'PASS'} else {'FAIL'}),$_.name,$_.evidence) }
$failed=@($checks | Where-Object {-not $_.pass}); "SUMMARY $(@($checks | Where-Object pass).Count)/$($checks.Count) checks passed"; if ($failed.Count) { exit 1 }
