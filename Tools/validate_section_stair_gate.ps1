param([string]$Output = '.local/revalidation/section-stair-gate.json')

$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
function Json([string]$Path) { Get-Content -LiteralPath (Join-Path $root $Path) -Raw | ConvertFrom-Json }
$m112 = Json 'Architecture/M112_Stair_Rise_Code_Basis_2026-10-30/stair-rise-options.json'
$m285 = Json 'Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json'
$checks = @()
function Check([string]$Name, [bool]$Pass, [string]$Detail) { $script:checks += [pscustomobject]@{name=$Name;pass=$Pass;detail=$Detail} }

$levels = @($m112.selected_d_levels)
$rises = @($m112.adjacent_level_rises)
Check 'm112_source_status' ($m112.status -match 'not a stair selection') 'M112 remains arithmetic sensitivity only'
Check 'selected_d_three_levels' ($levels.Count -eq 3 -and (@($levels | Where-Object { $_.elevation_ft -in @(-5,0,5) }).Count -eq 3)) 'Lower/Main/Upper at -5/0/+5 ft'
Check 'selected_d_60in_rises' ($rises.Count -eq 2 -and @($rises | Where-Object { [double]$_.rise_in -eq 60 }).Count -eq 2) 'both adjacent comparison rises are 60 in'
Check 'dd013_preferred_rise' ([double]$m112.owner_half_story_intent.preferred_total_rise_in -eq 43.5) 'six 7.25 in risers equal 43.5 in'
Check 'm112_no_native_claim' (@($m112.interpretation | Where-Object { $_ -match 'floor assembly|landing|headroom|support' }).Count -gt 0) 'vertical construction inputs remain unresolved'
Check 'm285_status' ($m285.status -match 'analysis-only') 'M285 is analysis only'
Check 'm285_60_and_435' ([double]$m285.owner_selected_basis.total_rise_in -eq 43.5 -and @($m285.selected_d_current.adjacent_deltas_in | Where-Object { $_ -eq 60 }).Count -eq 2) 'M285 records 43.5 in study basis and 60 in source deltas'
Check 'm285_no_revit_stair' (@($m285.limitations | Where-Object { $_ -match 'No Revit stair' }).Count -gt 0) 'no native stair or floor opening was created'

$failed = @($checks | Where-Object { -not $_.pass })
$out = if ([IO.Path]::IsPathRooted($Output)) { [IO.Path]::GetFullPath($Output) } else { [IO.Path]::GetFullPath((Join-Path $root $Output)) }
$parent = Split-Path -Parent $out; if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$report = [pscustomobject]@{schema='forever-home-section-stair-gate-v1';status=if($failed.Count -eq 0){'pass'}else{'fail'};passed=@($checks|Where-Object pass).Count;total=$checks.Count;checks=$checks;limitations=@('This is a source-bound arithmetic/section gate only.','No floor-to-floor assembly, landing, opening, headroom, structure, route or code determination is established.')}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $out -Encoding UTF8
if ($failed.Count -gt 0) { $failed | Format-Table | Out-String | Write-Error; exit 1 }
Write-Output "PASS: $($report.passed)/$($report.total) section/stair gate checks."
