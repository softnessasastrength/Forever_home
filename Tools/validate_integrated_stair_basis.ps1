param(
    [string]$CompositionManifest = '.local/revit-pilot/multi-level-composition/20261103T150109911Z/multi-level-composition-manifest.json',
    [string]$NativeStairManifest = '.local/revit-pilot/split-rise-native-stair/20261101T225749874Z/study-manifest.json',
    [string]$DecisionFile = 'Decisions/2026-11-03_Integrated_Candidate_Stair_Decision_Gate.md',
    [string]$Output = '.local/revalidation/integrated-stair-basis.json'
)
$ErrorActionPreference='Stop'
$root=(Get-Location).Path
$c=Get-Content (Join-Path $root $CompositionManifest) -Raw|ConvertFrom-Json
$s=Get-Content (Join-Path $root $NativeStairManifest) -Raw|ConvertFrom-Json
$d=Get-Content (Join-Path $root $DecisionFile) -Raw
$checks=@()
function Check([string]$Name,[bool]$Pass,[string]$Detail){$script:checks+=[pscustomobject]@{name=$Name;pass=$Pass;detail=$Detail}}
Check 'owner_b_selected' ($d -match 'owner selected \*\*B\*\*' -and $d -match '60 in per half-story') 'Decision B recorded for disposable study'
Check 'composition_60in_proxy' ($c.stair_study.risers_per_flight -eq 8 -and [double]$c.stair_study.riser_in -eq 7.5 -and $c.stair_study.status -like '*comparison proxies*') 'composition carries eight 7.5-in risers as comparison'
Check 'native_stair_60in' ([double]$s.total_rise_in -eq 60 -and $s.native_stair_count -eq 2) 'native stair study carries 60-in total rise'
Check 'no_selected_promotion' ($c.status -match 'not selected-D' -and $s.status -match 'no selected-D promotion') 'both artifacts remain disposable'
$out=if([IO.Path]::IsPathRooted($Output)){$Output}else{Join-Path $root $Output}; New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out)|Out-Null
[ordered]@{schema='forever-home-integrated-stair-basis-v1';status=if(@($checks|Where-Object{-not $_.pass}).Count -eq 0){'pass'}else{'fail'};basis='B';total_rise_in=60;checks=$checks;limitations=@('B is an owner-authorized disposable comparison basis, not a final floor-to-floor or construction datum.','Landing, headroom, openings, route, structure, MEP, accessibility and code remain unresolved.')}|ConvertTo-Json -Depth 8|Set-Content $out -Encoding UTF8
if(@($checks|Where-Object{-not $_.pass}).Count){throw 'Integrated stair basis validation failed.'}; Write-Output "PASS: $($checks.Count)/$($checks.Count) integrated stair basis checks."
