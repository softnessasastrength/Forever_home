param(
    [string]$ProposalPath = (Join-Path $PSScriptRoot '../Architecture/House_Design_Iteration_2026-10-28/study.json'),
    [string]$TargetEnvelopePath = (Join-Path $PSScriptRoot '../Research/M06_610AA001_020_Retail_Reported_Envelope_2026-10-28.json'),
    [string]$PairRecheckPath = (Join-Path $PSScriptRoot '../Research/M06_Followup_Window_Pair_Recheck_2026-10-28.json'),
    [string]$CodeScreenPath = (Join-Path $PSScriptRoot '../Research/2026-10-28_Connecticut_M06_Clearance_Screen.md'),
    [string]$BathroomSpecPath = (Join-Path $PSScriptRoot '../Architecture/Bathrooms_Specs.md'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '../Research/M06_Approach_Depth_Sensitivity_2026-10-29.json')
)

$ErrorActionPreference = 'Stop'
$proposalFile = (Resolve-Path -LiteralPath $ProposalPath).Path
$targetFile = (Resolve-Path -LiteralPath $TargetEnvelopePath).Path
$pairFile = (Resolve-Path -LiteralPath $PairRecheckPath).Path
$codeScreenFile = (Resolve-Path -LiteralPath $CodeScreenPath).Path
$bathroomSpecFile = (Resolve-Path -LiteralPath $BathroomSpecPath).Path
$proposal = Get-Content -LiteralPath $proposalFile -Raw | ConvertFrom-Json
$target = Get-Content -LiteralPath $targetFile -Raw | ConvertFrom-Json
$pairs = Get-Content -LiteralPath $pairFile -Raw | ConvertFrom-Json
$codeScreen = Get-Content -LiteralPath $codeScreenFile -Raw
$bathroomSpec = Get-Content -LiteralPath $bathroomSpecFile -Raw

if ($proposal.M06.status -ne 'unassigned; no footprint, position, fixture or service route' -or
    $proposal.M06.first_fit_window.status -ne 'unassigned search window only; not M-06 geometry' -or
    $proposal.M06.first_fit_window.id -ne 'M06-B') {
    throw 'Expected pantry-side B to remain an unassigned search window.'
}
if ($target.target_sku -ne '610AA001.020' -or
    $target.evaluation.manufacturer_verified_current_product_geometry -ne $false -or
    $target.evaluation.m06_assignment -ne $false) {
    throw 'Expected the seller-reported exact-SKU plan envelope with current manufacturer geometry and assignment unresolved.'
}
if ($pairs.code_screen_basis.preliminary_sections -notmatch '21 in clear in front' -or
    $pairs.evaluated.code_compliance_or_accessibility -ne $false) {
    throw 'Expected the dated preliminary 2021 IRC front-clearance screen, not a compliance finding.'
}
if ($codeScreen -notmatch '21 in clear in front' -or
    $codeScreen -notmatch 'municipality' -or
    $codeScreen -notmatch 'not a code-compliance determination') {
    throw 'Expected the documented conditional M-06 code-screen basis and unresolved local applicability.'
}
if ($bathroomSpec -notmatch '30".{0,3}48" clear where practical at toilet and shower' -or
    $bathroomSpec -notmatch 'Do not borrow full-bath clearances as powder-room criteria') {
    throw 'Bathroom source no longer contains the 30-by-48 aspiration and its explicit exclusion from M-06 criteria.'
}

$window = $proposal.M06.first_fit_window
$grossWidthIn = [Math]::Round(([double]$window.width_ft * 12.0), 3)
$grossDepthIn = [Math]::Round(([double]$window.depth_ft * 12.0), 3)
$toiletDepthIn = [double]$target.retailer_reported_overall_dimensions_in.depth
$codeFrontClearanceIn = 21.0
$optionalFrontClearanceIn = 48.0
$codeTotalDepthIn = [Math]::Round(($toiletDepthIn + $codeFrontClearanceIn), 3)
$optionalTotalDepthIn = [Math]::Round(($toiletDepthIn + $optionalFrontClearanceIn), 3)

$sourceHashes = [ordered]@{
    owner_followup_proposal = (Get-FileHash -LiteralPath $proposalFile -Algorithm SHA256).Hash.ToLowerInvariant()
    target_sku_retail_envelope = (Get-FileHash -LiteralPath $targetFile -Algorithm SHA256).Hash.ToLowerInvariant()
    code_screened_pair_recheck = (Get-FileHash -LiteralPath $pairFile -Algorithm SHA256).Hash.ToLowerInvariant()
    M06_code_screen_note = (Get-FileHash -LiteralPath $codeScreenFile -Algorithm SHA256).Hash.ToLowerInvariant()
    bathroom_design_spec = (Get-FileHash -LiteralPath $bathroomSpecFile -Algorithm SHA256).Hash.ToLowerInvariant()
}

$report = [ordered]@{
    schema = 'forever-home-m06-approach-depth-sensitivity-v1'
    status = 'Sensitivity only; no optional clear-floor target adopted for M-06.'
    checked_on = '2026-10-29'
    current_code_status = [ordered]@{
        confirmed_on = '2026-10-29'
        current_code = '2022 Connecticut State Building Code for permits filed from 2022-10-01; based on the 2021 International Codes.'
        next_code_cycle = 'The planned 2026 Connecticut code effective date remains delayed pending Legislative Regulation Review Committee approval.'
        project_site_permit_classification_and_applicability_known = $false
    }
    window = [ordered]@{
        id = [string]$window.id
        gross_width_in = $grossWidthIn
        gross_depth_in = $grossDepthIn
        gross_area_sf = [double]$window.area_sf
        remains_unassigned = $true
        status = [string]$window.status
    }
    product_input = [ordered]@{
        sku = '610AA001.020'
        depth_in = $toiletDepthIn
        source = [string]$target.retailer_source
        source_quality = 'Retailer-reported; plan dimensions match the predecessor proxy but are not manufacturer-verified geometry.'
        current_product_geometry_verified = $false
    }
    scenarios = @(
        [ordered]@{
            id = 'conditional-2021-IRC-front-clearance'
            basis = 'Preliminary 2021 IRC P2705.1 / R307.1 screening basis under an assumed detached one-family scope; applicability remains unconfirmed.'
            front_clearance_in = $codeFrontClearanceIn
            fixture_plus_front_clearance_depth_in = $codeTotalDepthIn
            residual_gross_depth_in = [Math]::Round(($grossDepthIn - $codeTotalDepthIn), 3)
            compliance_determination = $false
        }
        [ordered]@{
            id = 'optional-full-bath-clear-floor-sensitivity'
            basis = 'Optional usability sensitivity only: Bathrooms_Specs.md section 9 mentions 30 by 48 in where practical, while section 1.1 explicitly says not to borrow full-bath clearances as M-06 criteria.'
            clear_floor_width_in = 30.0
            front_clearance_in = $optionalFrontClearanceIn
            fixture_plus_front_clearance_depth_in = $optionalTotalDepthIn
            residual_gross_depth_in = [Math]::Round(($grossDepthIn - $optionalTotalDepthIn), 3)
            adopted_for_M06 = $false
            compliance_determination = $false
        }
    )
    evaluation = [ordered]@{
        any_room_fit_established = $false
        wall_build_up_modeled = $false
        lavatory_layout_or_overlap_modeled = $false
        door_leaf_swing_or_clear_opening_modeled = $false
        public_hall_approach_modeled = $false
        water_drain_or_vent_route_modeled = $false
        accessibility_scope_determined = $false
        code_compliance_determined = $false
        M06_assignment = $false
    }
    limitations = @(
        'The 84 in depth is a gross unassigned room-block search window, not finished clear interior dimension.',
        'The 30.25 in toilet projection is retailer-reported for the selected SKU; the current manufacturer dimension drawing and matching RFA remain unavailable.',
        'The 21 in scenario is a conditional code-research screen, not an applicable-code determination for this site or permit.',
        'The 30 by 48 in scenario is an optional sensitivity only and is expressly not adopted for M-06; the bathroom source says not to borrow full-bath clearances as powder-room criteria.',
        'Residual gross depth is not allowable wall thickness or a proof that a layout fits; it excludes wall build-up, door operation, lavatory geometry and circulation.',
        'No room, fixture, clearance preference, door, approach, service route or code conclusion is selected by this report.'
    )
    sources = [ordered]@{
        Connecticut_current_code = 'https://portal.ct.gov/en/das/office-of-state-building-inspector/connecticut-state-building-code/regulations'
        Connecticut_2026_adoption_status = 'https://portal.ct.gov/das/office-of-state-building-inspector/building-and-fire-code-adoption-process'
        M06_code_screen_note = 'Research/2026-10-28_Connecticut_M06_Clearance_Screen.md'
        owner_bath_spec = 'Architecture/Bathrooms_Specs.md sections 1.1 and 9'
    }
    source_fingerprints_sha256 = $sourceHashes
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputPath)) { [System.IO.Path]::GetFullPath($OutputPath) } else { [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath)) }
$outputDir = Split-Path -Parent $resolvedOutput
if (-not (Test-Path -LiteralPath $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }
$json = ConvertTo-Json -InputObject $report -Depth 12
[System.IO.File]::WriteAllText($resolvedOutput, $json + "`r`n", [System.Text.UTF8Encoding]::new($false))
Write-Output "Sensitivity saved: B is $grossDepthIn in gross; selected-SKU retailer depth plus conditional IRC front clearance requires $codeTotalDepthIn in, while optional 48 in comparison requires $optionalTotalDepthIn in. No fit or assignment is established."
