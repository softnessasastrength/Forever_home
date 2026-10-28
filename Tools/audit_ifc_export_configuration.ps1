$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$pilotPath = Join-Path $root 'Tools/RevitPilot/Pilot.cs'
$manifestPath = Join-Path $root 'Tools/RevitPilot/export-manifest.json'
$selectedManifestPath = Join-Path $root 'Tools/RevitPilot/export-manifest-selected-d-7216-fit-test.json'
$validationPath = Join-Path $root '.local/revit-pilot/selected-d/exact-backup-validation-m22-20261028/ifc-validation.json'
$exportPath = Join-Path $root '.local/revit-pilot/selected-d/20261028T021345099Z/export-result.json'
$studyManifestPath = Join-Path $root '.local/revit-pilot/selected-d/20261028T021345099Z/study-manifest.json'
$outputPath = Join-Path $root 'Research/M24_Revit_2027_IFC_Settings_Audit.json'

foreach ($path in @($pilotPath, $manifestPath, $selectedManifestPath, $validationPath, $exportPath, $studyManifestPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required IFC audit input is missing: $path"
    }
}

$pilot = Get-Content -LiteralPath $pilotPath -Raw
$selectedStart = $pilot.IndexOf('public class SelectedDCommand', [StringComparison]::Ordinal)
$selectedEnd = $pilot.IndexOf('public class CompactCoreCommand', $selectedStart, [StringComparison]::Ordinal)
if ($selectedStart -lt 0 -or $selectedEnd -le $selectedStart) {
    throw 'Could not isolate SelectedDCommand in Pilot.cs.'
}
$selectedCommand = $pilot.Substring($selectedStart, $selectedEnd - $selectedStart)
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$selectedManifest = Get-Content -LiteralPath $selectedManifestPath -Raw | ConvertFrom-Json
$validation = Get-Content -LiteralPath $validationPath -Raw | ConvertFrom-Json
$export = Get-Content -LiteralPath $exportPath -Raw | ConvertFrom-Json
$studyManifest = Get-Content -LiteralPath $studyManifestPath -Raw | ConvertFrom-Json

$validationChecks = @($validation.checks.PSObject.Properties)
$passedChecks = @($validationChecks | Where-Object { $_.Value -eq $true }).Count
$schemaIssues = [int]$validation.observations.schema_issue_count
$source = $studyManifest.source_sha256
$ifcHash = $export.ifc_sha256
$selectedHasFileVersion = $selectedCommand -match 'FileVersion\s*=\s*IFCVersion\.IFC2x3CV2'
$selectedHasBaseQuantities = $selectedCommand -match 'ExportBaseQuantities\s*=\s*true'
$selectedSetsFilter = $selectedCommand -match '\.FilterViewId\s*='
$selectedSetsInternalProperties = $selectedCommand -match 'ExportInternalRevitPropertySets'
$selectedSetsFamilyMap = $selectedCommand -match 'FamilyMappingFile'
$selectedSetsMappingTemplate = $selectedCommand -match 'IFCParameterTemplate'
$manifestConfigurationExplicit =
    $manifest.ifc.export_base_quantities -eq $true -and
    $manifest.ifc.export_internal_property_sets -eq $true -and
    $null -eq $manifest.ifc.filter_view_name -and
    $selectedManifest.ifc.export_base_quantities -eq $true -and
    $selectedManifest.ifc.export_internal_property_sets -eq $true -and
    $null -eq $selectedManifest.ifc.filter_view_name
$ifcPresentAndMatched = $validation.status -eq 'pass' -and
    $validation.observations.ifc_file.sha256 -eq $ifcHash -and
    (Get-FileHash -LiteralPath (Join-Path (Split-Path $exportPath) $export.ifc_file) -Algorithm SHA256).Hash.ToLowerInvariant() -eq $ifcHash
$allValidationChecksPass = $passedChecks -eq $validationChecks.Count -and $validationChecks.Count -eq 25

$checks = @(
    [ordered]@{ name = 'selected_d_ifc_version_explicit_ifc2x3cv2'; passed = $selectedHasFileVersion },
    [ordered]@{ name = 'selected_d_base_quantities_explicit_true'; passed = $selectedHasBaseQuantities },
    [ordered]@{ name = 'selected_d_no_explicit_view_filter'; passed = -not $selectedSetsFilter },
    [ordered]@{ name = 'selected_d_no_explicit_internal_property_set_option'; passed = -not $selectedSetsInternalProperties },
    [ordered]@{ name = 'selected_d_no_explicit_family_mapping_file'; passed = -not $selectedSetsFamilyMap },
    [ordered]@{ name = 'selected_d_no_explicit_parameter_mapping_template'; passed = -not $selectedSetsMappingTemplate },
    [ordered]@{ name = 'manifest_export_controls_are_explicit'; passed = $manifestConfigurationExplicit },
    [ordered]@{ name = 'selected_d_exact_backup_ifc_validation_passes_25_of_25'; passed = $allValidationChecksPass },
    [ordered]@{ name = 'selected_d_ifc_hash_matches_export_record_and_file'; passed = $ifcPresentAndMatched },
    [ordered]@{ name = 'selected_d_ifc_schema_has_zero_issues'; passed = $schemaIssues -eq 0 },
    [ordered]@{ name = 'selected_d_source_fingerprint_matches_current_source'; passed = $source -eq (Get-FileHash -LiteralPath (Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json') -Algorithm SHA256).Hash.ToLowerInvariant() }
)

$report = [ordered]@{
    schema = 'forever-home.revit-ifc-export-configuration-audit.v1'
    status = if (@($checks | Where-Object { -not $_.passed }).Count -eq 0) { 'pass' } else { 'fail' }
    checks_passed = @($checks | Where-Object { $_.passed }).Count
    checks_total = $checks.Count
    checks = $checks
    source_fingerprints = [ordered]@{
        revit_pilot_source_sha256 = (Get-FileHash -LiteralPath $pilotPath -Algorithm SHA256).Hash.ToLowerInvariant()
        audit_script_sha256 = (Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToLowerInvariant()
        compact_core_manifest_sha256 = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
        selected_d_m02_manifest_sha256 = (Get-FileHash -LiteralPath $selectedManifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
        selected_d_source_sha256 = $source
        selected_d_saved_rvt_sha256 = $export.model_fingerprint.sha256
        selected_d_ifc_sha256 = $ifcHash
        ifc_validation_report_sha256 = (Get-FileHash -LiteralPath $validationPath -Algorithm SHA256).Hash.ToLowerInvariant()
    }
    selected_d_api_export = [ordered]@{
        revit_ifc_schema = 'IFC2X3 Coordination View 2.0 (IFC2x3CV2)'
        export_base_quantities = $true
        filter_view_id_explicitly_set = $selectedSetsFilter
        export_internal_revit_property_sets_explicitly_set = $selectedSetsInternalProperties
        family_mapping_file_explicitly_set = $selectedSetsFamilyMap
        parameter_mapping_template_explicitly_selected = $selectedSetsMappingTemplate
        mapping_template_for_original_export = 'unverified; source code does not record it, and a later host audit cannot retroactively establish it'
    }
    manifest_api_export = [ordered]@{
        export_base_quantities = $manifest.ifc.export_base_quantities
        export_internal_revit_property_sets = $manifest.ifc.export_internal_property_sets
        filter_view_name = $manifest.ifc.filter_view_name
        selected_d_m02_manifest_has_same_values = $selectedManifest.ifc.export_base_quantities -eq $manifest.ifc.export_base_quantities -and $selectedManifest.ifc.export_internal_property_sets -eq $manifest.ifc.export_internal_property_sets -and $selectedManifest.ifc.filter_view_name -eq $manifest.ifc.filter_view_name
    }
    validated_export = [ordered]@{
        revit_originating_system = $validation.observations.ifc_provenance.originating_system
        ifc_schema = $validation.observations.schema
        validation_checks_passed = $passedChecks
        validation_checks_total = $validationChecks.Count
        schema_issue_count = $schemaIssues
        storey_count = @($validation.observations.expected_storeys).Count
        space_count = $validation.observations.expected_block_count
        has_physical_construction_categories = -not $validation.checks.construction_categories_remain_empty
        validation_working_copy = 'exact RVT backup copied into an ignored disposable folder; original run outputs preserved'
    }
    interpretation = @(
        'The selected-D command passes IFC2x3CV2 and ExportBaseQuantities=true directly to IFCExportOptions, then rolls back its export transaction.',
        'It does not explicitly select a view, set internal Revit property-set export, provide a family mapping file, or select an IFC parameter-mapping template in source.',
        'The separate manifest exporter does explicitly configure base quantities, internal Revit property sets, and an optional filter view; both checked-in manifests request quantities and internal property sets and use no filter view.',
        'The exact current-source IFC independently passes its 25-check gate; this verifies IFC lineage, schema, levels, spaces and empty physical construction categories, not every exported property mapping.',
        'The active named or in-session mapping setup used at the original host export is not recorded. Autodesk documents a Revit 2027 API for querying and exporting mapping templates, so this can be captured during a future matching Revit host run.'
    )
    limitations = @(
        'This static audit does not inspect a live Revit document or prove which IFC mapping template was active when an earlier IFC was generated.',
        'The selected-D model remains a 21-space room-boundary study with no walls, openings, floors, stairs, structure or MEP.',
        'IFC schema and geometry validation do not establish architectural coordination, code compliance, accessibility, structural safety, professional certification or construction readiness.'
    )
}

$json = ConvertTo-Json -InputObject $report -Depth 12
Set-Content -LiteralPath $outputPath -Value $json -Encoding utf8
Write-Output "IFC source configuration audit: $($report.checks_passed)/$($report.checks_total) checks passed."
Write-Output $outputPath
if ($report.status -ne 'pass') { exit 1 }
