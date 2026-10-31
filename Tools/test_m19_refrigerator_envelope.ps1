param(
    [string]$InputStudy = 'Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json',
    [string]$OutputDirectory = 'Architecture/M19_Refrigerator_Envelope_Study_2026-10-28'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$inputPath = Join-Path $root $InputStudy
$out = Join-Path $root $OutputDirectory
if (-not (Test-Path -LiteralPath $inputPath -PathType Leaf)) { throw "M19 input study not found: $inputPath" }
$source = Get-Content -LiteralPath $inputPath -Raw | ConvertFrom-Json
$fit = $source.geometry.kitchen_fit_study
$refrigeratorModule = $fit.perimeter_modules | Where-Object id -eq 'refrigerator'
if (@($refrigeratorModule).Count -ne 1) { throw 'Expected one refrigerator module in the M19 fit study.' }
$run = $fit.perimeter_run_world_rect_ft
$island = $source.geometry.island_world_rect_ft
$counterDepthIn = [double]$run[3] * 12.0
$moduleWidthIn = [double]$refrigeratorModule.width_ft * 12.0
$nominalAisleIn = [double]$fit.island_to_perimeter_counter_clearance_in
$documentedMinimumAisleIn = 42.0
$documentedPreferredAisleIn = 48.0
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $inputPath).Hash.ToLowerInvariant()

# GE manufacturer-published dimensions. These discontinued SKUs are retained
# strictly as representative fit envelopes, not current product recommendations.
$candidates = @(
    [ordered]@{
        id = 'GWE19JMLES'
        family = '33-in counter-depth French-door refrigerator'
        discontinued = $true
        width_in = 32.75
        overall_depth_in = 31.0
        depth_with_door_open_90_in = 42.0
        side_air_clearance_in = 0.125
        rear_air_clearance_in = 2.0
        open_width_including_handles_90_in = 40.5
        source_url = 'https://www.geappliances.com/appliance/GE-ENERGY-STAR-18-6-Cu-Ft-Counter-Depth-French-Door-Refrigerator-GWE19JMLES'
    },
    [ordered]@{
        id = 'GZS22IMNES'
        family = '36-in counter-depth side-by-side refrigerator'
        discontinued = $true
        width_in = 35.75
        overall_depth_in = 30.75
        depth_with_door_open_90_in = 46.5
        side_air_clearance_in = 0.125
        rear_air_clearance_in = 2.0
        open_width_including_handles_90_in = 42.25
        source_url = 'https://www.geappliances.com/appliance/GE-21-8-Cu-Ft-Counter-Depth-Side-By-Side-Refrigerator-GZS22IMNES'
    }
)

$rows = foreach ($candidate in $candidates) {
    $closedInstalledProjectionIn = [double]$candidate.overall_depth_in + [double]$candidate.rear_air_clearance_in
    $openInstalledProjectionIn = [double]$candidate.depth_with_door_open_90_in + [double]$candidate.rear_air_clearance_in
    $closedAisleIn = $nominalAisleIn - ($closedInstalledProjectionIn - $counterDepthIn)
    $openAisleIn = $nominalAisleIn - ($openInstalledProjectionIn - $counterDepthIn)
    $requiredSlotWidthIn = [double]$candidate.width_in + (2.0 * [double]$candidate.side_air_clearance_in)
    [ordered]@{
        model = $candidate
        refrigerator_module_world_rect_ft = @([Math]::Round([double]$refrigeratorModule.x, 3), [Math]::Round([double]$refrigeratorModule.y, 3), [Math]::Round([double]$refrigeratorModule.width_ft, 3), [Math]::Round([double]$refrigeratorModule.depth_ft, 3))
        nominal_case_width_fit = [double]$candidate.width_in -le $moduleWidthIn
        slot_width_with_listed_side_air_clearance_in = [Math]::Round($requiredSlotWidthIn, 3)
        nominal_module_width_in = $moduleWidthIn
        residual_width_after_side_air_clearance_in = [Math]::Round(($moduleWidthIn - $requiredSlotWidthIn), 3)
        aisle_closed_including_listed_rear_clearance_in = [Math]::Round($closedAisleIn, 2)
        closed_state_meets_documented_42_in_minimum = ($closedAisleIn -ge $documentedMinimumAisleIn)
        closed_state_meets_documented_48_in_preference = ($closedAisleIn -ge $documentedPreferredAisleIn)
        aisle_door_open_90_including_listed_rear_clearance_in = [Math]::Round($openAisleIn, 2)
        open_state_below_36_in_plan_route_target_by_in = [Math]::Round([Math]::Max([double]0, 36.0 - $openAisleIn), 2)
        open_width_exceeds_refrigerator_module_in = [Math]::Round([Math]::Max([double]0, ([double]$candidate.open_width_including_handles_90_in - $moduleWidthIn)), 2)
        assessment = 'Dimensional comparison only; model is discontinued and the door-open envelope is not an accessible-route, code, ergonomic, hinge-sweep, or installation approval.'
    }
}

$checks = @(
    [ordered]@{ id = 'input_is_m19_schematic'; pass = ($source.status -match 'unapproved' -and $fit.status -match 'not owner-selected') },
    [ordered]@{ id = 'source_refrigerator_module_matches_36_in_spec'; pass = ([Math]::Abs($moduleWidthIn - 36.0) -lt 0.001) },
    [ordered]@{ id = 'source_counter_depth_matches_24_in_spec'; pass = ([Math]::Abs($counterDepthIn - 24.0) -lt 0.001) },
    [ordered]@{ id = 'source_island_aisle_is_48_in'; pass = ([Math]::Abs($nominalAisleIn - 48.0) -lt 0.001) },
    [ordered]@{ id = 'two_reference_models_present'; pass = ($rows.Count -eq 2) },
    [ordered]@{ id = 'all_reference_models_marked_discontinued'; pass = (@($rows | Where-Object { -not $_.model.discontinued }).Count -eq 0) },
    [ordered]@{ id = 'manufacturer_dimensions_recorded'; pass = (@($rows | Where-Object { $_.model.source_url -like 'https://www.geappliances.com/*' -and $_.model.width_in -gt 0 -and $_.model.overall_depth_in -gt 0 -and $_.model.depth_with_door_open_90_in -gt 0 }).Count -eq 2) },
    [ordered]@{ id = 'gwe19jmles_values_match_reviewed_ge_data'; pass = (@($rows | Where-Object { $_.model.id -eq 'GWE19JMLES' -and $_.model.width_in -eq 32.75 -and $_.model.overall_depth_in -eq 31.0 -and $_.model.depth_with_door_open_90_in -eq 42.0 -and $_.model.open_width_including_handles_90_in -eq 40.5 -and $_.model.discontinued }).Count -eq 1) },
    [ordered]@{ id = 'gzs22imnes_values_match_reviewed_ge_data'; pass = (@($rows | Where-Object { $_.model.id -eq 'GZS22IMNES' -and $_.model.width_in -eq 35.75 -and $_.model.overall_depth_in -eq 30.75 -and $_.model.depth_with_door_open_90_in -eq 46.5 -and $_.model.open_width_including_handles_90_in -eq 42.25 -and $_.model.discontinued }).Count -eq 1) },
    [ordered]@{ id = 'door_open_width_excess_calculates_fractional_inches'; pass = ((@($rows | Where-Object { $_.model.id -eq 'GWE19JMLES' })[0].open_width_exceeds_refrigerator_module_in -eq 4.5) -and (@($rows | Where-Object { $_.model.id -eq 'GZS22IMNES' })[0].open_width_exceeds_refrigerator_module_in -eq 6.25)) },
    [ordered]@{ id = 'open_gap_shortfall_preserves_fractional_inches'; pass = ((@($rows | Where-Object { $_.model.id -eq 'GWE19JMLES' })[0].open_state_below_36_in_plan_route_target_by_in -eq 8.0) -and (@($rows | Where-Object { $_.model.id -eq 'GZS22IMNES' })[0].open_state_below_36_in_plan_route_target_by_in -eq 12.5)) },
    [ordered]@{ id = 'closed_state_reduces_documented_aisle_below_42_in'; pass = (@($rows | Where-Object { $_.closed_state_meets_documented_42_in_minimum }).Count -eq 0) },
    [ordered]@{ id = 'open_state_reduces_available_gap'; pass = (@($rows | Where-Object { $_.aisle_door_open_90_including_listed_rear_clearance_in -lt $_.aisle_closed_including_listed_rear_clearance_in }).Count -eq 2) },
    [ordered]@{ id = 'refrigerator_model_not_promoted_to_selected_product'; pass = (@($rows | Where-Object { $_.assessment -match 'Dimensional comparison only' }).Count -eq 2) },
    [ordered]@{ id = 'no_code_or_accessibility_claim'; pass = (@($rows | Where-Object { $_.assessment -match 'not an accessible-route, code' }).Count -eq 2) },
    [ordered]@{ id = 'source_fingerprint_recorded'; pass = ($sourceHash -match '^[0-9a-f]{64}$') }
)
$failed = @($checks | Where-Object { -not $_.pass })
$checksOut = [ordered]@{
    status = if ($failed.Count -eq 0) { 'pass' } else { 'fail' }
    passed = $checks.Count - $failed.Count
    total = $checks.Count
    checks = $checks
    interpretation = 'Passing checks validate source identity, arithmetic, product provenance and non-claims. They do not indicate that any refrigerator fits the selected architectural design.'
}
$report = [ordered]@{
    schema = 'forever-home-m19-refrigerator-envelope-v1'
    status = 'unapproved dimensional stress test; hold product-specific Revit placement pending a current selected refrigerator and coordinated alcove/aisle'
    source = [ordered]@{
        m19_study = $InputStudy
        m19_study_sha256 = $sourceHash
        counter_depth_in = $counterDepthIn
        nominal_counter_face_to_island_clearance_in = $nominalAisleIn
        documented_island_counter_minimum_in = $documentedMinimumAisleIn
        documented_island_counter_preferred_in = $documentedPreferredAisleIn
        refrigerator_module_width_in = $moduleWidthIn
        island_world_rect_ft = @($island)
        interpretation = 'The M19 48-in measurement is to the 24-in counter-front line. The product screens extend the appliance from the back of that 24-in counter depth and add the GE-listed 2-in rear clearance as a screening assumption; confirm the installation drawing and measurement datums for any selected live SKU.'
    }
    candidates = @($rows)
    limitations = @(
        'Both manufacturer reference SKUs are discontinued; dimensions are historical reference envelopes and are not purchase recommendations.',
        'No refrigerator family was imported, no Revit document was edited, and no IFC was produced.',
        'The door-open depth is represented as a forward projection only; exact hinge-side swing, adjacent return collision, user standing space, drawers, shelves, and loading use are not modeled.',
        'Dishwasher and range doors remain untested because the repository has no selected live product models with verified plan operating envelopes.',
        'The 42-in room specification is a schematic kitchen-planning metric, not a code or accessibility determination.'
    )
    checks = $checksOut
}

$scale = 3.0
$slotWpx = $moduleWidthIn * $scale
$islandYpx = 120 + (24 + $nominalAisleIn) * $scale
$svg = @(
    "<svg xmlns='http://www.w3.org/2000/svg' width='1120' height='760' viewBox='0 0 1120 760'>",
    "<style>text{font-family:Arial,sans-serif;fill:#29251f}.title{font-size:23px;font-weight:bold}.head{font-size:16px;font-weight:bold}.label{font-size:12px}.note{font-size:11px;fill:#5b5145}.wall{stroke:#4b4037;stroke-width:4}.counter{fill:#d4c6ad;stroke:#71634e;stroke-width:2}.fridge{fill:#dbe5e8;stroke:#486d78;stroke-width:2}.open{fill:#e7b6a0;fill-opacity:.62;stroke:#a34c32;stroke-width:2;stroke-dasharray:7 4}.island{fill:#e5e4da;stroke:#6c6b5d;stroke-width:2}.fail{fill:#a53527;font-weight:bold}</style>",
    "<rect width='1120' height='760' fill='#fbf9f3'/>",
    "<text x='32' y='36' class='title'>M19 refrigerator envelope screen - dimensional comparison, not product selection</text>",
    "<text x='32' y='60' class='note'>Plan depth from wall: counter 24 in; nominal aisle 48 in; island front at 72 in. Manufacturer rear clearance added as a screening assumption.</text>"
)
$rowTop = 100.0
foreach ($row in $rows) {
    $model = $row.model
    $panelStart = 40.0
    $panelWidth = 505.0
    $panelGap = 30.0
    $svg += "<text x='$panelStart' y='$($rowTop+16)' class='head'>$($model.id) - closed: $($row.aisle_closed_including_listed_rear_clearance_in) in aisle</text>"
    $svg += "<text x='$($panelStart+$panelWidth+$panelGap)' y='$($rowTop+16)' class='head'>$($model.id) - open at 90 degrees: $($row.aisle_door_open_90_including_listed_rear_clearance_in) in aisle</text>"
    for ($panel = 0; $panel -lt 2; $panel++) {
        $px = $panelStart + ($panel * ($panelWidth + $panelGap))
        $backY = $rowTop + 34
        $bodyDepth = ([double]$model.overall_depth_in + [double]$model.rear_air_clearance_in) * $scale
        $openDepth = ([double]$model.depth_with_door_open_90_in + [double]$model.rear_air_clearance_in) * $scale
        $frontDepth = if ($panel -eq 0) { $bodyDepth } else { $openDepth }
        $islandY = $backY + (24 + $nominalAisleIn) * $scale
        $fridgeWidthPx = [double]$model.width_in * $scale
        $fridgeX = $px + (($slotWpx - $fridgeWidthPx) / 2)
        $svg += "<line x1='$($px-4)' y1='$backY' x2='$($px+$slotWpx+4)' y2='$backY' class='wall'/><text x='$px' y='$($backY-7)' class='label'>back-of-appliance datum</text>"
        $svg += "<rect x='$px' y='$backY' width='$slotWpx' height='$(24*$scale)' class='counter'/><text x='$($px+4)' y='$($backY+($scale*12))' class='label'>24 in counter-depth zone</text>"
        if ($panel -eq 0) {
            $svg += "<rect x='$fridgeX' y='$backY' width='$fridgeWidthPx' height='$frontDepth' class='fridge'/><text x='$($px+2)' y='$($backY+$frontDepth+16)' class='label'>closed appliance + 2 in rear clearance</text>"
        } else {
            $svg += "<rect x='$fridgeX' y='$backY' width='$fridgeWidthPx' height='$bodyDepth' class='fridge'/><rect x='$fridgeX' y='$backY' width='$fridgeWidthPx' height='$frontDepth' class='open'/><text x='$($px+2)' y='$($backY+$frontDepth+16)' class='label'>90 degree open depth + 2 in rear clearance</text>"
        }
        $svg += "<line x1='$($px-4)' y1='$islandY' x2='$($px+$slotWpx+4)' y2='$islandY' class='island'/><text x='$px' y='$($islandY+17)' class='label'>island front / 72 in from datum</text>"
        $remaining = if ($panel -eq 0) { $row.aisle_closed_including_listed_rear_clearance_in } else { $row.aisle_door_open_90_including_listed_rear_clearance_in }
        $midY = $backY + ($frontDepth + (24 + $nominalAisleIn)) * $scale / 2
        $svg += "<text x='$($px+6)' y='$midY' class='fail'>remaining: $remaining in</text>"
    }
    $rowTop += 250
}
$svg += "<text x='32' y='708' class='note'>Muted blue = appliance body; dashed terracotta = manufacturer 90 degree depth envelope. This is a side projection, not the true door-swing footprint.</text>"
$svg += "<text x='32' y='731' class='note'>Neither candidate passes the documented 42 in closed aisle in this north-run position. Exact current model, alcove and door-swing geometry remain an owner/design gate.</text>"
$svg += '</svg>'

New-Item -ItemType Directory -Force -Path $out | Out-Null
$report | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $out 'study.json') -Encoding UTF8
$checksOut | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $out 'checks.json') -Encoding UTF8
Set-Content -LiteralPath (Join-Path $out 'refrigerator-envelope-comparison.svg') -Value ($svg -join "`r`n") -Encoding UTF8
try { [xml](Get-Content -LiteralPath (Join-Path $out 'refrigerator-envelope-comparison.svg') -Raw) | Out-Null } catch { throw 'Generated refrigerator-envelope SVG is not valid XML.' }
if ($failed.Count -gt 0) { throw "Refrigerator-envelope provenance/arithmetic checks failed: $($failed.id -join ', ')" }
Write-Output "M19 refrigerator envelope screen: $($checksOut.passed)/$($checksOut.total) provenance, arithmetic and non-claim checks passed."
foreach ($row in $rows) {
    Write-Output ("{0}: {1:N2} in closed / {2:N2} in door-open aisle; product status: discontinued reference only." -f $row.model.id, $row.aisle_closed_including_listed_rear_clearance_in, $row.aisle_door_open_90_including_listed_rear_clearance_in)
}
