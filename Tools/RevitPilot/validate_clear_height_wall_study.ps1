param(
    [Parameter(Mandatory = $true)]
    [string]$StudyDirectory
)

$ErrorActionPreference = 'Stop'
$study = (Resolve-Path -LiteralPath $StudyDirectory).Path
$checks = New-Object System.Collections.Generic.List[object]

function Add-Check([string]$Name, [bool]$Passed, [string]$Evidence) {
    $checks.Add([pscustomobject]@{ name = $Name; passed = $Passed; evidence = $Evidence })
}

function Hash([string]$Path) { (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant() }

$indexPath = Join-Path $study 'comparison-index.json'
if (!(Test-Path -LiteralPath $indexPath -PathType Leaf)) { throw "M311 comparison index not found: $indexPath" }
$index = Get-Content -LiteralPath $indexPath -Raw | ConvertFrom-Json
$expectedSource = '516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB'
Add-Check 'schema_and_status' ($index.schema -eq 'forever-home-clear-ceiling-wall-height-index-v1' -and [string]$index.status -like 'three isolated*') "schema=$($index.schema); status=$($index.status)"
Add-Check 'selected_d_source_pinned' ([string]::Equals([string]$index.source_sha256, $expectedSource, [StringComparison]::OrdinalIgnoreCase)) "source_sha256=$($index.source_sha256)"
Add-Check 'three_cases_declared' (@($index.cases).Count -eq 3) "cases=$(@($index.cases).Count)"

$caseChecks = $true
$caseEvidence = New-Object System.Collections.Generic.List[string]
foreach ($case in @($index.cases)) {
    $jsonPath = Join-Path $study ([string]$case.manifest)
    $rvtPath = Join-Path $study ([string]$case.model)
    $jsonExists = Test-Path -LiteralPath $jsonPath -PathType Leaf
    $rvtExists = Test-Path -LiteralPath $rvtPath -PathType Leaf
    $json = if ($jsonExists) { Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json } else { $null }
    $rvtHash = if ($rvtExists) { Hash $rvtPath } else { '' }
    $hashOk = $rvtExists -and [string]::Equals($rvtHash, [string]$case.model_sha256, [StringComparison]::OrdinalIgnoreCase)
    $envelopeOk = $null -ne $json -and (@($json.shell_envelope_ft) -join ',') -eq (@($case.envelope_ft) -join ',')
    $wallOk = $null -ne $json -and [int]$json.native_wall_count -eq 12 -and [int]$json.per_case_wall_count -eq 4 -and [int]$json.level_count -eq 1
    $heightsOk = $null -ne $json -and (@($json.case_clear_height_reference_ft) -join ',') -eq '8,9,10'
    $emptyOk = $null -ne $json -and @('floors','ceilings','doors','windows','stairs','roofs' | ForEach-Object { [int]$json.$_ }) -notcontains $null -and (@('floors','ceilings','doors','windows','stairs','roofs' | ForEach-Object { [int]$json.$_ }) | Where-Object { $_ -ne 0 }).Count -eq 0
    $caseOk = $jsonExists -and $rvtExists -and $hashOk -and $envelopeOk -and $wallOk -and $heightsOk -and $emptyOk
    $caseChecks = $caseChecks -and $caseOk
    $caseEvidence.Add("$($case.shell) json=$jsonExists rvt=$rvtExists hash=$hashOk envelope=$envelopeOk walls_levels=$wallOk heights=$heightsOk empty_construction=$emptyOk")
}
Add-Check 'case_manifests_and_rvts' $caseChecks ($caseEvidence -join '; ')

$passed = @($checks | Where-Object passed).Count
foreach ($check in $checks) {
    $verdict = if ($check.passed) { 'PASS' } else { 'FAIL' }
    Write-Output ("{0} {1}: {2}" -f $verdict, $check.name, $check.evidence)
}
Write-Output "SUMMARY $passed/$($checks.Count) M311 clear-height study checks passed"
if ($passed -ne $checks.Count) { exit 1 }
Write-Output 'LIMIT: validates the command manifest, per-model JSON, saved RVT hashes and declared native inventory; it does not independently reopen RVTs or establish assemblies, stairs, code, accessibility, structural adequacy or construction readiness.'
