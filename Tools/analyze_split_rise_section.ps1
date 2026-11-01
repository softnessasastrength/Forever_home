param([string]$Output = '.local/revalidation/split-rise-section.json')

$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$m112 = Get-Content (Join-Path $root 'Architecture/M112_Stair_Rise_Code_Basis_2026-10-30/stair-rise-options.json') -Raw | ConvertFrom-Json
$source60 = [double]$m112.selected_d_comparison.total_rise_in
$ctMax = 8.25
$cases = @(
    [ordered]@{ id='selected-d-full-rise'; label='Selected-D comparison baseline'; risers=@(8); rise_each_in=7.5; total_rise_in=60; tread_runs=@(7); tread_each_in=11; run_total_in=77; status='comparison only; not selected' },
    [ordered]@{ id='split-4-plus-4'; label='Two-flight split-rise sensitivity'; risers=@(4,4); rise_each_in=7.5; total_rise_in=60; tread_runs=@(3,4); tread_each_in=11; run_total_in=77; status='analysis-only proposal; landing and route unresolved' },
    [ordered]@{ id='dd013-plus-remainder'; label='DD-013 preference plus remainder sensitivity'; risers=@(6,2); rise_each_in=$null; total_rise_in=60; tread_runs=@(5,1); tread_each_in=$null; run_total_in=$null; status='analysis-only sensitivity; unequal flight risers require a separate design' }
)
$checks = @()
function Check([string]$Name, [bool]$Pass, [string]$Detail) { $script:checks += [pscustomobject]@{name=$Name;pass=$Pass;detail=$Detail} }
Check 'source_60_in' ($source60 -eq 60) 'Selected-D comparison rise is 60 in'
Check 'split_case_sums' (($cases[0].risers.Count -eq 1 -and $cases[0].risers[0] -eq 8) -and ($cases[1].risers.Count -eq 2 -and ($cases[1].risers[0] + $cases[1].risers[1]) -eq 8)) 'the full-rise and split 4+4 cases contain eight total risers'
Check 'split_case_equal_rise' ([double]$cases[1].rise_each_in * 8 -eq $source60) '4+4 at 7.5 in retains the 60 in total'
Check 'ct_screen_visible' ($ctMax -eq 8.25) 'preliminary CT screening maximum retained as a source value'
Check 'no_native_claim' (@($cases | Where-Object { $_.status -eq 'selected' }).Count -eq 0) 'all cases remain comparative or analysis-only'
$failed = @($checks | Where-Object { -not $_.pass })
$out = if ([IO.Path]::IsPathRooted($Output)) { [IO.Path]::GetFullPath($Output) } else { [IO.Path]::GetFullPath((Join-Path $root $Output)) }
$parent = Split-Path -Parent $out; if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$report = [pscustomobject]@{schema='forever-home-split-rise-section-study-v1';status=if($failed.Count -eq 0){'pass'}else{'fail'};source_selected_d_rise_in=$source60;preliminary_ct_max_riser_in=$ctMax;cases=$cases;passed=@($checks|Where-Object pass).Count;total=$checks.Count;checks=$checks;limitations=@('This is arithmetic only; it does not create a native Revit stair.','Landing, headroom, floor assembly, opening, wall thickness, route, structure and code applicability remain unresolved.')}
$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $out -Encoding UTF8
if ($failed.Count -gt 0) { $failed | Format-Table | Out-String | Write-Error; exit 1 }
Write-Output "PASS: $($report.passed)/$($report.total) split-rise section checks."
