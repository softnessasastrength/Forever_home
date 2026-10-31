param(
    [string]$OutputDirectory = 'Architecture/M112_Stair_Rise_Code_Basis_2026-10-30'
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sourcePaths = [ordered]@{
    selected_d_study = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
    half_story_stair_spec = Join-Path $root 'Architecture/Stairs_Half_Story.md'
    selected_direction = Join-Path $root 'Decisions/2026-10-27_Selected_Architectural_Direction_D.md'
    connecticut_stair_basis = Join-Path $root 'Research/Connecticut_Stair_Code_Research_2026-10-30.md'
    analyzer_script = $PSCommandPath
}
foreach ($path in $sourcePaths.Values) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing source: $path" } }
$study = [IO.File]::ReadAllText($sourcePaths.selected_d_study) | ConvertFrom-Json
$stairSpec = [IO.File]::ReadAllText($sourcePaths.half_story_stair_spec)
$decision = [IO.File]::ReadAllText($sourcePaths.selected_direction)
$codeNote = [IO.File]::ReadAllText($sourcePaths.connecticut_stair_basis)
$levels = @($study.selection.levels | Sort-Object elevation_ft)
if ($levels.Count -ne 3 -or $levels[0].id -ne 'Lower FF' -or $levels[1].id -ne 'Main FF' -or $levels[2].id -ne 'Upper FF') { throw 'Selected-D level inventory does not match the documented lower/main/upper test datums.' }
$stairs = $study.selection.vertical_core
$ctMaxRiserIn = 8.25
$ctMinTreadIn = 9.0
$maxRiserUniformityIn = 0.375
if ($codeNote -notmatch 'R311\.7\.5\.1' -or $codeNote -notmatch '8 1/4' -or $codeNote -notmatch 'R311\.7\.5\.2' -or $codeNote -notmatch '9 in') { throw 'Connecticut code note does not contain the pinned stair basis.' }
if ($stairSpec -notmatch '6 risers' -or $stairSpec -notmatch '43-1/2' -or $stairSpec -notmatch '5.{0,2}7') { throw 'Owner stair-intent source changed; review the audit assumptions.' }
if ($decision -notmatch 'eight-riser arithmetic as a \*\*comparison baseline\*\*' -and $decision -notmatch 'eight-riser arithmetic as a comparison baseline') { throw 'Selected-direction document no longer records the eight-riser comparison baseline.' }
$adjacent = @()
for ($i=0; $i -lt $levels.Count - 1; $i++) {
    $rise = [math]::Round((($levels[$i+1].elevation_ft - $levels[$i].elevation_ft) * 12.0), 6)
    $adjacent += [ordered]@{ from=$levels[$i].id; to=$levels[$i+1].id; rise_in=$rise }
}
if (@($adjacent | Where-Object { $_.rise_in -ne 60.0 }).Count -gt 0) { throw 'This analysis is intentionally bounded to two 60-inch selected-D transitions; source elevations changed.' }
$comparisonRisers = [int]$stairs.comparison_risers_per_half_flight
$comparisonRiser = [double]$stairs.comparison_riser_in
$comparisonTread = [double]$stairs.comparison_tread_in
$comparisonTreads = $comparisonRisers - 1
$riseIn = [double]$adjacent[0].rise_in
$minimumRisers = [int][math]::Ceiling($riseIn / $ctMaxRiserIn)
$options = @()
foreach ($count in 5..8) {
    $riser = [math]::Round($riseIn / $count, 6)
    $options += [ordered]@{
        riser_count = $count
        equal_riser_in = $riser
        max_riser_in = $ctMaxRiserIn
        within_preliminary_CT_max = ($riser -le $ctMaxRiserIn)
        owner_half_story_preference_count = ($count -ge 5 -and $count -le 7)
        tread_count_for_straight_run = ($count - 1)
        plan_run_at_D_comparison_tread_in = [math]::Round(($count - 1) * $comparisonTread, 6)
    }
}
$sourceFingerprints = [ordered]@{}
foreach ($key in $sourcePaths.Keys) { $sourceFingerprints[$key] = (Get-FileHash -LiteralPath $sourcePaths[$key] -Algorithm SHA256).Hash.ToLowerInvariant() }
$report = [ordered]@{
    status = 'source-bound arithmetic sensitivity; not a stair selection or code-compliance finding'
    sources_sha256 = $sourceFingerprints
    selected_d_levels = @($levels | ForEach-Object { [ordered]@{id=$_.id; elevation_ft=[double]$_.elevation_ft} })
    adjacent_level_rises = $adjacent
    owner_half_story_intent = [ordered]@{ preferred_risers=6; preferred_equal_riser_in=7.25; preferred_total_rise_in=43.5; preferred_count_range=@(5,7); source='Architecture/Stairs_Half_Story.md' }
    selected_d_comparison = [ordered]@{ risers_per_flight=$comparisonRisers; equal_riser_in=$comparisonRiser; treads_per_flight=$comparisonTreads; tread_depth_in=$comparisonTread; run_depth_in=[math]::Round($comparisonTreads*$comparisonTread,6); total_rise_in=[math]::Round($comparisonRisers*$comparisonRiser,6); status='comparison baseline only; final stair count and geometry unselected' }
    preliminary_connecticut_basis = [ordered]@{ adopted_code='2022 Connecticut State Building Code, amendments to 2021 IRC'; section_riser='R311.7.5.1'; max_riser_in=$ctMaxRiserIn; section_tread='R311.7.5.2'; min_tread_in=$ctMinTreadIn; max_within_flight_riser_variation_in=$maxRiserUniformityIn; applicability='municipality, permit timing and code scope remain unconfirmed' }
    arithmetic = [ordered]@{ minimum_uniform_riser_count_for_60_in_at_CT_max=$minimumRisers; max_total_rise_with_seven_at_CT_max_in=[math]::Round(7*$ctMaxRiserIn,6); owner_preferred_six_riser_shortfall_in=[math]::Round($riseIn-6*7.25,6); options=$options }
    interpretation = @(
        'Both adjacent selected-D level pairs are 60 in apart in the source room-study datums.',
        'At the preliminary Connecticut amended maximum of 8.25 in, at least eight equal risers are required for a 60 in rise; eight equal risers are 7.5 in each.',
        'The inherited eight-riser/11-in tread plan arithmetic spans 60 in and uses a 77 in straight tread run, but remains a comparison, not a selected stair.',
        'The owner half-story spec prefers six risers at 7.25 in (43.5 in total) and a 5-7 riser range. This preference and the selected-D 60 in adjacent level datums do not align as a single-flight count without changing a datum, dividing the rise among flights, or revising the layout.',
        'No floor assembly, actual floor-to-floor structural dimension, landing section, headroom, guard, support, egress, finish tolerance, project jurisdiction or permit path is resolved by this arithmetic.'
    )
}
$checks = @(
    [ordered]@{id='source_files_present';passed=($sourcePaths.Values | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }).Count -eq $sourcePaths.Count;detail='All source files, including the analyzer script, exist.'},
    [ordered]@{id='three_selected_d_test_levels';passed=$levels.Count -eq 3;detail='Lower, Main and Upper test levels are present.'},
    [ordered]@{id='both_adjacent_rises_60_in';passed=@($adjacent | Where-Object { $_.rise_in -ne 60.0 }).Count -eq 0;detail='The source elevations imply 60 in per adjacent pair.'},
    [ordered]@{id='selected_d_eight_riser_arithmetic_matches';passed=($comparisonRisers -eq 8 -and $comparisonRiser -eq 7.5 -and ($comparisonRisers*$comparisonRiser) -eq $riseIn);detail='Eight equal 7.5 in risers sum to the 60 in comparison rise.'},
    [ordered]@{id='selected_d_tread_arithmetic_matches';passed=($comparisonTreads -eq 7 -and $comparisonTread -eq 11 -and ($comparisonTreads*$comparisonTread) -eq 77);detail='Seven 11 in treads produce a 77 in straight plan run.'},
    [ordered]@{id='ct_amended_riser_basis_present';passed=($ctMaxRiserIn -eq 8.25 -and $codeNote -match 'R311\.7\.5\.1');detail='Current preliminary Connecticut source note identifies amended R311.7.5.1 and 8.25 in.'},
    [ordered]@{id='ct_tread_basis_present';passed=($ctMinTreadIn -eq 9 -and $codeNote -match 'R311\.7\.5\.2');detail='Current preliminary Connecticut source note identifies amended R311.7.5.2 and 9 in.'},
    [ordered]@{id='eight_risers_minimum_for_60_in';passed=$minimumRisers -eq 8;detail='Ceiling(60 / 8.25) = 8.'},
    [ordered]@{id='seven_risers_cannot_span_60_in_at_ct_max';passed=(7*$ctMaxRiserIn -lt $riseIn);detail='Seven maximum-height risers sum to 57.75 in, less than 60 in.'},
    [ordered]@{id='owner_six_riser_preference_recorded';passed=($stairSpec -match '6 risers' -and $stairSpec -match '43-1/2' -and $riseIn - 6*7.25 -eq 16.5);detail='Six preferred 7.25 in risers total 43.5 in, 16.5 in short of the source transition.'},
    [ordered]@{id='design_and_compliance_claims_limited';passed=($report.status -match 'not a stair selection or code-compliance finding' -and ($report.interpretation -join ' ') -match 'not a selected stair');detail='The report retains explicit design and applicability limitations.'}
)
$failed = @($checks | Where-Object { -not $_.passed })
if ($failed.Count) { throw ('M112 checks failed: ' + (($failed | ForEach-Object id) -join ', ')) }
if ([IO.Path]::IsPathRooted($OutputDirectory)) { $target=[IO.Path]::GetFullPath($OutputDirectory) } else { $target=[IO.Path]::GetFullPath((Join-Path $root $OutputDirectory)) }
$prefix=$root.TrimEnd([IO.Path]::DirectorySeparatorChar,[IO.Path]::AltDirectorySeparatorChar)+[IO.Path]::DirectorySeparatorChar
if (-not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'OutputDirectory must remain inside the repository.' }
New-Item -ItemType Directory -Force -Path $target | Out-Null
$utf8=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $target 'stair-rise-options.json'),($report | ConvertTo-Json -Depth 20),$utf8)
[IO.File]::WriteAllText((Join-Path $target 'checks.json'),(@{passed=($checks.Count-$failed.Count);failed=$failed.Count;checks=$checks} | ConvertTo-Json -Depth 10),$utf8)
"M112 stair-rise arithmetic checks passed: $($checks.Count)/$($checks.Count)"
"Output: $target"
