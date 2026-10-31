param(
    [string]$OutputDirectory = 'Architecture/M172_Compact_Social_Space_Constraints_2026-10-31'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out = [System.IO.Path]::GetFullPath((Join-Path $root $OutputDirectory))
$rootPrefix = $root.TrimEnd([System.IO.Path]::DirectorySeparatorChar,[System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if (-not $out.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Output must remain inside the current checkout: $out"
}
$sources = [ordered]@{
    'Requirements/Room_Program.md' = Join-Path $root 'Requirements/Room_Program.md'
    'Architecture/Kitchen_Dining_Porch_Specs.md' = Join-Path $root 'Architecture/Kitchen_Dining_Porch_Specs.md'
    'Decisions/2026-10-28_House_Design_Direction_Followup.md' = Join-Path $root 'Decisions/2026-10-28_House_Design_Direction_Followup.md'
    'Decisions/Kitchen_Island_Finish.md' = Join-Path $root 'Decisions/Kitchen_Island_Finish.md'
    'Architecture/Selected_Design_Iteration_2026-10-27/study.json' = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
}
foreach ($p in $sources.Values) { if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw "Missing required source: $p" } }

function Sha([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }
function Assert-Source([string]$Key, [string]$Pattern, [string]$Description) {
    $text = Get-Content -LiteralPath $sources[$Key] -Raw
    if ($text -notmatch $Pattern) { throw "Source assertion failed for $Key ($Description)" }
}

$roomText = Get-Content -LiteralPath $sources['Requirements/Room_Program.md'] -Raw
$specText = Get-Content -LiteralPath $sources['Architecture/Kitchen_Dining_Porch_Specs.md'] -Raw
$directionText = Get-Content -LiteralPath $sources['Decisions/2026-10-28_House_Design_Direction_Followup.md'] -Raw
$finishText = Get-Content -LiteralPath $sources['Decisions/Kitchen_Island_Finish.md'] -Raw
$selected = Get-Content -LiteralPath $sources['Architecture/Selected_Design_Iteration_2026-10-27/study.json'] -Raw | ConvertFrom-Json

# These are transcribed only from the owner-directed study targets and the existing specs.
Assert-Source 'Requirements/Room_Program.md' 'M-02\s*\|\s*Kitchen\s*\|[^\r\n]*14\s*\S+\s*12\s*ft' 'M-02 target is 14 x 12 ft'
Assert-Source 'Requirements/Room_Program.md' 'M-03\s*\|\s*Dining\s*\|[^\r\n]*11\s*\S+\s*10\s*ft' 'M-03 target is 11 x 10 ft'
Assert-Source 'Decisions/2026-10-28_House_Design_Direction_Followup.md' '(?s)14\s*\S+\s*12\s*ft.{0,180}11\s*\S+\s*10\s*ft' 'owner follow-up retains both study targets'
Assert-Source 'Decisions/Kitchen_Island_Finish.md' '8\s*ft\s*x\s*4\s*ft' 'island target is 8 x 4 ft'
Assert-Source 'Architecture/Kitchen_Dining_Porch_Specs.md' '42"\s*min.*48"\s*preferred' '42/48-in aisle values are documented'
Assert-Source 'Architecture/Kitchen_Dining_Porch_Specs.md' '24"\s*deep' '24-in cabinet depth is documented'
Assert-Source 'Architecture/Kitchen_Dining_Porch_Specs.md' '36"\s*W\s*\S+\s*60"\s*L' 'dining table size is documented'
Assert-Source 'Architecture/Kitchen_Dining_Porch_Specs.md' '18"\s*\S+\s*20"' 'chair proxy size is documented'

$m02 = [ordered]@{ width_ft = 14.0; depth_ft = 12.0; area_sf = 168.0 }
$m03 = [ordered]@{ width_ft = 11.0; depth_ft = 10.0; area_sf = 110.0 }
$island = [ordered]@{ long_ft = 8.0; short_ft = 4.0; area_sf = 32.0 }
$counterRunIn = 36 + 24 + 12 + 30 + 12 + 36
$counterRunFt = $counterRunIn / 12.0
$crossSectionIn = 24 + 42 + 48 + 42 + 6
$crossSectionFt = $crossSectionIn / 12.0
$minimumDining = [ordered]@{ width_ft = 3 + 2 * 3; length_ft = 5 + 2 * 3 }
$preferredDining = [ordered]@{ width_ft = 3 + 2 * 3.5; length_ft = 5 + 2 * 3.5 }
$islandEndAisleFt = 3.5
$islandLongClearSpanFt = $island.long_ft + 2 * $islandEndAisleFt

$orientations = @(
    [ordered]@{
        id = 'cross-section-on-14ft-axis'
        cross_section_axis_ft = $m02.width_ft
        appliance_run_axis_ft = $m02.depth_ft
        cross_section_residual_in = [Math]::Round(($m02.width_ft - $crossSectionFt) * 12, 2)
        appliance_run_residual_in = [Math]::Round(($m02.depth_ft - $counterRunFt) * 12, 2)
        cross_section_fits = ($m02.width_ft -ge $crossSectionFt)
        appliance_run_fits = ($m02.depth_ft -ge $counterRunFt)
        strict_orthogonal_fit = (($m02.width_ft -ge $crossSectionFt) -and ($m02.depth_ft -ge $counterRunFt))
    },
    [ordered]@{
        id = 'cross-section-on-12ft-axis'
        cross_section_axis_ft = $m02.depth_ft
        appliance_run_axis_ft = $m02.width_ft
        cross_section_residual_in = [Math]::Round(($m02.depth_ft - $crossSectionFt) * 12, 2)
        appliance_run_residual_in = [Math]::Round(($m02.width_ft - $counterRunFt) * 12, 2)
        cross_section_fits = ($m02.depth_ft -ge $crossSectionFt)
        appliance_run_fits = ($m02.width_ft -ge $counterRunFt)
        strict_orthogonal_fit = (($m02.depth_ft -ge $crossSectionFt) -and ($m02.width_ft -ge $counterRunFt))
    }
)

$sourceHashes = [ordered]@{}
foreach ($key in $sources.Keys) { $sourceHashes[$key] = Sha $sources[$key] }
$selectedKitchen = $selected.plans.main | Where-Object id -eq 'M-02' | Select-Object -First 1
$selectedDining = $selected.plans.main | Where-Object id -eq 'M-03' | Select-Object -First 1
$selectedKitchenCrossFit = ([double]$selectedKitchen.w -ge $crossSectionFt -and [double]$selectedKitchen.d -ge $counterRunFt)
$selectedKitchenEndFit = ([double]$selectedKitchen.w -ge $islandLongClearSpanFt -and [double]$selectedKitchen.d -ge $islandLongClearSpanFt)
$selectedDiningPreferredFit = ([Math]::Max([double]$selectedDining.w,[double]$selectedDining.d) -ge $preferredDining.length_ft -and [Math]::Min([double]$selectedDining.w,[double]$selectedDining.d) -ge $preferredDining.width_ft)
$assertions = @(
    [ordered]@{ id='target-m02-source'; pass=($roomText -match 'M-02\s*\|\s*Kitchen\s*\|[^\r\n]*14\s*\S+\s*12\s*ft'); evidence='Room_Program M-02 target 14 x 12 ft' },
    [ordered]@{ id='target-m03-source'; pass=($roomText -match 'M-03\s*\|\s*Dining\s*\|[^\r\n]*11\s*\S+\s*10\s*ft'); evidence='Room_Program M-03 target 11 x 10 ft' },
    [ordered]@{ id='owner-followup-source'; pass=($directionText -match '(?s)14\s*\S+\s*12\s*ft.{0,180}11\s*\S+\s*10\s*ft'); evidence='Owner follow-up repeats both targets' },
    [ordered]@{ id='island-owner-source'; pass=($finishText -match '8\s*ft\s*x\s*4\s*ft'); evidence='Kitchen island decision retains 8 x 4 ft target' },
    [ordered]@{ id='aisle-source'; pass=($specText -match '42"\s*min.*48"\s*preferred'); evidence='Kitchen spec publishes 42 in minimum, 48 in preferred' },
    [ordered]@{ id='cabinet-depth-source'; pass=($specText -match '24"\s*deep'); evidence='Kitchen spec publishes 24 in base depth' },
    [ordered]@{ id='table-size-source'; pass=($specText -match '36"\s*W\s*\S+\s*60"\s*L'); evidence='Dining table is 36 x 60 in' },
    [ordered]@{ id='chair-size-source'; pass=($specText -match '18"\s*\S+\s*20"'); evidence='Chair proxy is 18 x 20 in' },
    [ordered]@{ id='counter-run-arithmetic'; pass=($counterRunIn -eq 150 -and [Math]::Abs($counterRunFt-12.5) -lt 0.000001); evidence='36 + 24 + 12 + 30 + 12 + 36 = 150 in = 12 ft 6 in' },
    [ordered]@{ id='cross-section-arithmetic'; pass=($crossSectionIn -eq 162 -and [Math]::Abs($crossSectionFt-13.5) -lt 0.000001); evidence='24 + 42 + 48 + 42 + 6 = 162 in = 13 ft 6 in' },
    [ordered]@{ id='both-orientations-screened'; pass=($orientations.Count -eq 2 -and @($orientations | Where-Object strict_orthogonal_fit).Count -eq 0); evidence='Neither orthogonal orientation fits both coupled dimensions in 14 x 12 ft' },
    [ordered]@{ id='long-axis-end-clearance'; pass=([Math]::Abs($islandLongClearSpanFt - 15.0) -lt 0.000001); evidence='8 ft island + two documented-minimum 42 in ends = 15 ft' },
    [ordered]@{ id='end-clearance-deficit-14'; pass=([Math]::Abs(($islandLongClearSpanFt-$m02.width_ft)*12 - 12) -lt 0.000001); evidence='15 ft exceeds 14 ft axis by 12 in' },
    [ordered]@{ id='end-clearance-deficit-12'; pass=([Math]::Abs(($islandLongClearSpanFt-$m02.depth_ft)*12 - 36) -lt 0.000001); evidence='15 ft exceeds 12 ft axis by 36 in' },
    [ordered]@{ id='dining-min-envelope'; pass=($minimumDining.width_ft -eq 9 -and $minimumDining.length_ft -eq 11); evidence='36 x 60 in table + 36 in around all sides = 9 x 11 ft envelope' },
    [ordered]@{ id='dining-min-orientation-fits'; pass=($m03.width_ft -ge $minimumDining.length_ft -and $m03.depth_ft -ge $minimumDining.width_ft); evidence='11 x 10 ft target fits only the 11 x 9 ft minimum rectangle orientation' },
    [ordered]@{ id='preferred-dining-does-not-fit'; pass=($m03.width_ft -lt $preferredDining.length_ft -or $m03.depth_ft -lt $preferredDining.width_ft); evidence='Preferred 10 x 12 ft table envelope does not fit 11 x 10 ft' },
    [ordered]@{ id='selected-d-control-preserved'; pass=($sourceHashes['Architecture/Selected_Design_Iteration_2026-10-27/study.json'] -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb' -and $null -ne $selectedKitchen -and $null -ne $selectedDining); evidence='Read-only selected-D study matches its previously verified source SHA256' },
    [ordered]@{ id='selected-d-kitchen-envelope-control'; pass=$selectedKitchenCrossFit; evidence='Current larger selected-D test block numerically contains the coupled 13 ft 6 in by 12 ft 6 in envelope' },
    [ordered]@{ id='selected-d-island-end-span-control'; pass=$selectedKitchenEndFit; evidence='Current larger selected-D test block dimensions exceed the 15 ft island/end-clearance screen' },
    [ordered]@{ id='selected-d-dining-control'; pass=$selectedDiningPreferredFit; evidence='Current larger selected-D dining test block numerically contains the 12 x 10 ft preferred table envelope' },
    [ordered]@{ id='proposal-nonclaim'; pass=$true; evidence='No placement, adjacency, wall, door, route, code, accessibility, structure or construction approval is asserted' }
)
if (@($assertions | Where-Object { -not $_.pass }).Count -gt 0) { throw 'One or more M172 assertions failed.' }

$report = [ordered]@{
    schema = 'forever-home-m172-compact-social-space-constraints-v1'
    status = 'verified dimensional constraints; unapproved layout proposal; not selected-D or Revit geometry'
    source_fingerprints_sha256 = $sourceHashes
    targets = [ordered]@{
        M02_kitchen_ft = @($m02.width_ft,$m02.depth_ft)
        M02_kitchen_area_sf = $m02.area_sf
        M03_dining_ft = @($m03.width_ft,$m03.depth_ft)
        M03_dining_area_sf = $m03.area_sf
        combined_target_area_sf = ($m02.area_sf+$m03.area_sf)
        island_ft = @($island.long_ft,$island.short_ft)
        island_area_sf = $island.area_sf
        perimeter_run_required_ft = [Math]::Round($counterRunFt,3)
        perimeter_run_modules_in = @(36,24,12,30,12,36)
        opposing_counter_island_halfwall_section_required_ft = [Math]::Round($crossSectionFt,3)
        island_end_clearance_screen_ft = [Math]::Round($islandLongClearSpanFt,3)
        dining_table_ft = @(3,5)
        chair_proxy_in = @(18,20)
        minimum_table_and_clearance_envelope_ft = @($minimumDining.width_ft,$minimumDining.length_ft)
        preferred_table_and_clearance_envelope_ft = @($preferredDining.width_ft,$preferredDining.length_ft)
    }
    coupled_kitchen_orientations = $orientations
    derived = [ordered]@{
        minimum_kitchen_orthogonal_envelope_ft = @([Math]::Round($counterRunFt,3),[Math]::Round($crossSectionFt,3))
        minimum_kitchen_envelope_area_sf = [Math]::Round($counterRunFt*$crossSectionFt,3)
        target_kitchen_area_sf = $m02.area_sf
        strict_rectangle_area_difference_sf = [Math]::Round(($counterRunFt*$crossSectionFt)-$m02.area_sf,3)
        dining_min_short_axis_reserve_in = [Math]::Round(($m03.depth_ft-$minimumDining.width_ft)*12,2)
        dining_min_long_axis_reserve_in = [Math]::Round(($m03.width_ft-$minimumDining.length_ft)*12,2)
        dining_preferred_short_axis_deficit_in = [Math]::Round(($preferredDining.width_ft-$m03.depth_ft)*12,2)
        dining_preferred_long_axis_deficit_in = [Math]::Round(($preferredDining.length_ft-$m03.width_ft)*12,2)
        selected_d_control_blocks_ft = [ordered]@{
            M02 = @([double]$selectedKitchen.w,[double]$selectedKitchen.d)
            M03 = @([double]$selectedDining.w,[double]$selectedDining.d)
        }
        selected_d_numeric_controls = [ordered]@{
            M02_coupled_orthogonal_envelope_fits = $selectedKitchenCrossFit
            M02_15ft_island_end_span_fits = $selectedKitchenEndFit
            M03_preferred_table_envelope_fits = $selectedDiningPreferredFit
            interpretation = 'Room-block dimension controls only; wall thickness, interior faces, exact placement and route are not established.'
        }
    }
    limits = @(
        'The coupled kitchen dimensions are an orthogonal envelope screen: perimeter module run and opposing counter/island/half-wall section are not placed relative to real openings or adjacent rooms.',
        'The dining envelope is the documented table plus 36-in pull-out/path clearance on each side; it does not establish occupied-chair circulation or a route to a porch door.',
        'No room adjacency, door, porch position, 36-in continuous route, cabinet/appliance operating envelope, finish thickness, tolerance, site, service route or Revit placement is tested.',
        'The selected-D study is read only; the figures do not choose room sizes, island orientation, half-wall location, or a design revision.'
    )
    assertions = $assertions
}
$csvRows = foreach ($o in $orientations) {
    [pscustomobject]@{
        orientation = $o.id
        cross_section_axis_ft = $o.cross_section_axis_ft
        cross_section_required_ft = [Math]::Round($crossSectionFt,3)
        cross_section_residual_in = $o.cross_section_residual_in
        appliance_run_axis_ft = $o.appliance_run_axis_ft
        appliance_run_required_ft = [Math]::Round($counterRunFt,3)
        appliance_run_residual_in = $o.appliance_run_residual_in
        both_fit = $o.strict_orthogonal_fit
    }
}

function New-Svg {
    $width=1100; $height=570
    $rows=@()
    $rows += "<text x='30' y='42' class='title'>M172 compact kitchen / dining constraint screen</text>"
    $rows += "<text x='30' y='70' class='sub'>Documented target envelopes only; no room adjacency or selected layout is implied.</text>"
    $sx=31.0; $sy=120.0; $scale=24.0
    $rows += "<rect x='$sx' y='$sy' width='$($m02.width_ft*$scale)' height='$($m02.depth_ft*$scale)' class='kitchen'/>"
    $rows += "<text x='$($sx+10)' y='$($sy+25)' class='label'>M-02 14 x 12 ft target</text>"
    $dx=$sx+$m02.width_ft*$scale+28; $dy=$sy+($m02.depth_ft*$scale-$m03.depth_ft*$scale)/2
    $rows += "<rect x='$dx' y='$dy' width='$($m03.width_ft*$scale)' height='$($m03.depth_ft*$scale)' class='dining'/>"
    $rows += "<text x='$($dx+10)' y='$($dy+25)' class='label'>M-03 11 x 10 ft target</text>"
    $rows += "<text x='30' y='455' class='body'>Coupled kitchen screen: 12 ft 6 in appliance run x 13 ft 6 in counter/island/half-wall section.</text>"
    $rows += "<text x='30' y='481' class='body'>14-ft axis orientation: section fits by 6 in; run misses the other axis by 6 in.</text>"
    $rows += "<text x='30' y='507' class='body'>Rotated: run fits by 18 in; section misses the other axis by 18 in.</text>"
    $rows += "<text x='30' y='533' class='note'>Dining minimum table envelope fits with 12 in short-axis reserve; preferred envelope does not. Route remains untested.</text>"
    @"
<?xml version='1.0' encoding='UTF-8'?>
<svg xmlns='http://www.w3.org/2000/svg' width='$width' height='$height' viewBox='0 0 $width $height'>
<style>text{font-family:Arial,sans-serif;fill:#29251f}.title{font-size:24px;font-weight:bold}.sub{font-size:16px;fill:#62594e}.label{font-size:18px;font-weight:bold}.body{font-size:16px}.note{font-size:14px;fill:#7a4d34}rect{stroke-width:2}.kitchen{fill:#f4e4b7;stroke:#8c6a2d}.dining{fill:#e1ebd9;stroke:#54734b}</style>
$($rows -join "`n")
<text x='30' y='558' class='note'>Schematic illustration of target rectangles only; not a coordinated plan or construction geometry.</text>
</svg>
"@
}

New-Item -ItemType Directory -Force -Path $out | Out-Null
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $out 'm172-compact-social-space-constraints.json') -Encoding UTF8
$csvRows | Export-Csv -LiteralPath (Join-Path $out 'm172-kitchen-axis-coupling.csv') -NoTypeInformation -Encoding UTF8
New-Svg | Set-Content -LiteralPath (Join-Path $out 'm172-compact-social-space-constraints.svg') -Encoding UTF8
$assertions | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $out 'm172-checks.json') -Encoding UTF8
Write-Output "M172: $(@($assertions | Where-Object pass).Count)/$($assertions.Count) checks passed."
Write-Output "M-02 strict orthogonal kitchen fit: $(@($orientations | Where-Object strict_orthogonal_fit).Count)/$($orientations.Count) orientations."
Write-Output "M-03 minimum dining envelope reserve: $([Math]::Round(($m03.depth_ft-$minimumDining.width_ft)*12,2)) in on short axis."
