param(
    [string]$OutputPath = '.local/revalidation/verified-bim-sequence.json'
)

$ErrorActionPreference = 'Stop'
$repo = (Get-Location).Path
$steps = [System.Collections.Generic.List[object]]::new()

function Run-Step([string]$Name, [scriptblock]$Action) {
    $output = @()
    $exitCode = 0
    $global:LASTEXITCODE = 0
    try {
        $output = @(& $Action 2>&1)
        $exitCode = if ($null -eq $LASTEXITCODE) { 0 } else { [int]$LASTEXITCODE }
    } catch {
        $output += $_.Exception.Message
        $exitCode = 1
    }
    $text = ($output | ForEach-Object { $_.ToString() }) -join "`n"
    $passed = $exitCode -eq 0
    $steps.Add([pscustomobject]@{ name=$Name; pass=$passed; exit_code=$exitCode; tail=(($text -split "`n") | Select-Object -Last 8) })
    if (-not $passed) { throw "Sequence step failed: $Name" }
}

Run-Step 'm218_native_pantry_doors' { & .\Tools\RevitPilot\validate_m218_revit_study.ps1 -StudyDirectory .local/revit-pilot/m218-pantry-door-study/20261101T212718036Z }
Run-Step 'm333_native_roof' { & .\Tools\RevitPilot\validate_native_roof_shell.ps1 -StudyDirectory .local/revit-pilot/native-roof-shell/20261103T122806425Z }
Run-Step 'm328_native_landing' { & .\Tools\RevitPilot\validate_compact_landing_ifc.ps1 -StudyDirectory .local/revit-pilot/compact-core-landing/20261102T033153576Z }
Run-Step 'm06_coordination_contract' { & .\Tools\validate_m06_coordination_gate.ps1 -OutputPath .local/revalidation/m06-coordination-gate-sequence.json }
Run-Step 'm344_native_m06_proxy' { & .\Tools\validate_m06_proxy_study.ps1 -StudyDirectory .local/revit-pilot/m06-proxy-study/20261102T122827829Z }
Run-Step 'm346_native_main_floor_openings' { & .\Tools\RevitPilot\validate_native_main_floor_openings.ps1 -StudyDirectory .local/revit-pilot/main-floor-openings/20261102T125705634Z -Output .local/revalidation/native-openings-sequence.json }
Run-Step 'm347_documented_door_study' { & .\Tools\RevitPilot\validate_documented_door_study.ps1 -StudyDirectory .local/revit-pilot/documented-door-study/20261102T133842605Z -Output .local/revalidation/documented-door-study-sequence.json }
Run-Step 'm348_documented_opening_assembly' { & .\Tools\RevitPilot\validate_documented_opening_assembly.ps1 -StudyDirectory .local/revit-pilot/documented-opening-assembly/20261102T135857068Z -Output .local/revalidation/documented-opening-assembly-sequence.json }
Run-Step 'm349_integrated_main_floor_assembly' { & .\Tools\RevitPilot\validate_integrated_main_floor_assembly.ps1 -StudyDirectory .local/revit-pilot/integrated-main-floor-assembly/20261102T141223011Z -Output .local/revalidation/integrated-main-floor-assembly-sequence.json }
Run-Step 'm395_unified_native_composition' { & .\Tools\RevitPilot\validate_multi_level_composition.ps1 -StudyDirectory .local/revit-pilot/multi-level-composition/20261103T140103091Z }
Run-Step 'main_floor_coordination_chain' { & .\Tools\RevitPilot\validate_main_floor_coordination_chain.ps1 -CandidateManifestPath .local/revit-pilot/main-floor-candidate/20261101T215346325Z/manifest.json -FloorPlateManifestPath .local/revit-pilot/main-floor-floor-plate/20261101T220743680Z/floor-plate-manifest.json -Output .local/revalidation/main-floor-chain-sequence.json }
Run-Step 'consolidated_bim_gate' { & .\Tools\validate_verified_bim_milestone.ps1 -Output .local/revalidation/verified-bim-milestone-sequence.json -MainFloorCoordinationReport .local/revalidation/main-floor-chain-sequence.json }
Run-Step 'offline_revitpilot_tests' { & .venv\Scripts\python.exe -m unittest discover -s Tools/RevitPilot/tests -q }

$out = if ([IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path $repo $OutputPath }
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $out) | Out-Null
$report = [ordered]@{
    schema = 'forever-home-verified-bim-sequence-v1'
    status = 'pass'
    steps = $steps
    limitations = @(
        'This sequence validates retained evidence and offline contracts; it does not open Revit or regenerate a new RVT.',
        'M-06 remains explicitly fit-blocked and B remains unassigned.',
        'No code-compliance, structural-safety, professional, permit or construction-readiness conclusion follows.'
    )
}
$report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $out -Encoding UTF8
Write-Output "PASS: verified BIM sequence completed $($steps.Count) steps; report $out"
