param([string]$ResultPath='.local/revalidation/M219-m218-revit-validator-tests.json')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$validator = Join-Path $PSScriptRoot 'validate_m218_revit_study.ps1'
$fixtureRoot = Join-Path $repo ('.local/revit-pilot/validation-fixtures/m218-study-' + [guid]::NewGuid().ToString('N'))
$checks = New-Object System.Collections.Generic.List[object]
New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null

function QuoteArg([string]$value) { return '"' + $value.Replace('"','\"') + '"' }
function InvokeValidator([string]$Name, [string]$Directory, [int]$ExpectedExit, [string]$ExpectedText) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = (Get-Command powershell.exe).Source
    $psi.Arguments = '-NoProfile -ExecutionPolicy Bypass -File {0} -StudyDirectory {1}' -f (QuoteArg $validator), (QuoteArg $Directory)
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    if (-not $process.Start()) { throw "Could not start validator for $Name" }
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $all = $stdout + "`n" + $stderr
    $passed = $process.ExitCode -eq $ExpectedExit -and $all.Contains($ExpectedText)
    $checks.Add([pscustomobject]@{ id=$Name; pass=$passed; exit_code=$process.ExitCode; expected_exit_code=$ExpectedExit; expected_text=$ExpectedText; output_tail=@($all -split "`r?`n" | Select-Object -Last 5) })
}

function WriteFixture([string]$Name, [scriptblock]$Mutation = {}) {
    $directory = Join-Path $fixtureRoot $Name
    New-Item -ItemType Directory -Path $directory | Out-Null
    $kitchen = Join-Path $directory 'FH_M218_Pantry_Swing_Into_Kitchen.rvt'
    $pantry = Join-Path $directory 'FH_M218_Pantry_Swing_Into_Pantry.rvt'
    [IO.File]::WriteAllBytes($kitchen, [byte[]](1,2,3,4,5))
    [IO.File]::WriteAllBytes($pantry, [byte[]](6,7,8,9,10))
    $report = [pscustomobject]@{
        schema='forever-home-m218-revit-pantry-door-study-v1'
        status='pass; two separate disposable Revit comparison files generated'
        project_scope=[pscustomobject]@{ derivative_type='fresh imperial project per swing'; selected_d_opened=$false; selected_d_modified=$false }
        source_sha256=[pscustomobject]@{
            selected_d='516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb'
            m215='f2f6a66deda2a9c48a991e36b986683fe1f5b1c1d361fbf3e43be2a2e1a053b1'
            m217='7e436b9a7d805e2803a1148fbd2bdacad017f86b7d444f7cbe77cbde30226853'
            m218='946aaf98fc44fa67cd5546168feecd896d4c36543bc097553c75c7389385a3d43'
        }
        files=@(
            [pscustomobject]@{ swing_into='kitchen'; file_name=[IO.Path]::GetFileName($kitchen); sha256=(Get-FileHash $kitchen -Algorithm SHA256).Hash; bytes=(Get-Item $kitchen).Length; wall_count=13; model_curve_count=48 }
            [pscustomobject]@{ swing_into='pantry'; file_name=[IO.Path]::GetFileName($pantry); sha256=(Get-FileHash $pantry -Algorithm SHA256).Hash; bytes=(Get-Item $pantry).Length; wall_count=13; model_curve_count=48 }
        )
        limitations=@('West A remains protected and east B remains unassigned.')
    }
    & $Mutation $report $directory
    $manifest = Join-Path $directory 'm218-revit-study-manifest.json'
    [IO.File]::WriteAllText($manifest, (($report | ConvertTo-Json -Depth 20) + "`n"), (New-Object Text.UTF8Encoding($false)))
    return $directory
}

$valid = WriteFixture 'valid'
InvokeValidator 'valid_pair_and_hashes_pass' $valid 0 'SUMMARY 8/8 M218 Revit study integrity checks passed'
$wrongHash = WriteFixture 'wrong-hash' { param($r,$d) $r.files[0].sha256 = ('0' * 64) }
InvokeValidator 'tampered_rvt_fingerprint_rejected' $wrongHash 1 'FAIL both_rvt_hashes_sizes_and_recorded_counts'
$missingAlternative = WriteFixture 'missing-alternative' { param($r,$d) $r.files = @($r.files | Where-Object swing_into -eq 'kitchen') }
InvokeValidator 'missing_swing_alternative_rejected' $missingAlternative 1 'FAIL both_swing_alternatives_present_once'
$selectedOpened = WriteFixture 'selected-d-scope' { param($r,$d) $r.project_scope.selected_d_opened = $true }
InvokeValidator 'selected-d-open_claim_rejected' $selectedOpened 1 'FAIL selected_design_not_opened_or_modified'
$badCounts = WriteFixture 'bad-counts' { param($r,$d) $r.files[1].model_curve_count = 47 }
InvokeValidator 'unexpected_element_count_rejected' $badCounts 1 'FAIL both_rvt_hashes_sizes_and_recorded_counts'

$passed = @($checks | Where-Object pass).Count
$status = if ($passed -eq $checks.Count) { 'pass' } else { 'fail' }
$result = [ordered]@{ schema='forever-home-m218-revit-validator-tests-v1'; status=$status; fixture_directory=$fixtureRoot; cases=$checks.ToArray(); passed=$passed; total=$checks.Count; note='RVT bytes are synthetic validator fixtures and are not Revit models.' }
$resultFull = Join-Path $repo $ResultPath
$parent = Split-Path $resultFull -Parent
if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
[IO.File]::WriteAllText($resultFull, (($result | ConvertTo-Json -Depth 16) + "`n"), (New-Object Text.UTF8Encoding($false)))
foreach ($check in $checks) {
    $verdict = if ($check.pass) { 'PASS' } else { 'FAIL' }
    Write-Output ("{0} {1}: exit={2}; expected={3}; {4}" -f $verdict, $check.id, $check.exit_code, $check.expected_exit_code, $check.expected_text)
}
Write-Output "SUMMARY $passed/$($checks.Count) M218 Revit validator fixture tests passed"
Write-Output "FIXTURES $fixtureRoot"
if ($status -ne 'pass') { throw 'M218 Revit validator fixture tests failed.' }
