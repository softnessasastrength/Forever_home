param([string]$ResultPath='.local/revalidation/M189-candidate-family-validator-tests.json')
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$validator=Join-Path $PSScriptRoot 'validate_candidate_family_geometry.ps1'
$source=Join-Path $repo '.local/revit-pilot/family-intake/candidates/m174-mien-tauri-stool/TAURI-STL-24-N-N.rfa'
$expected=(Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
$fixtures=Join-Path $repo '.local/revit-pilot/validation-fixtures'
$valid=Join-Path $fixtures 'e6c563159a0d45efb907402ff8f44d1e/candidate-family-geometry.json'
$missingBounds=Join-Path $fixtures '20261031T124500Z/candidate-family-geometry.json'
$checks=New-Object System.Collections.Generic.List[object]

function QuoteArg([string]$value) { return '"' + $value.Replace('"','\"') + '"' }
function InvokeValidator([string]$Name,[string]$Report,[string]$Hash,[int]$ExpectedExit,[string]$ExpectedText) {
    $psi=New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName=(Get-Command powershell.exe).Source
    $psi.Arguments=('-NoProfile -ExecutionPolicy Bypass -File {0} -ReportPath {1} -ExpectedSourcePath {2} -ExpectedSourceSHA256 {3}' -f (QuoteArg $validator),(QuoteArg $Report),(QuoteArg $source),(QuoteArg $Hash))
    $psi.UseShellExecute=$false
    $psi.CreateNoWindow=$true
    $psi.RedirectStandardOutput=$true
    $psi.RedirectStandardError=$true
    $process=New-Object System.Diagnostics.Process
    $process.StartInfo=$psi
    if(-not$process.Start()){throw "Could not start validator child process for $Name"}
    $stdout=$process.StandardOutput.ReadToEnd()
    $stderr=$process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $all=$stdout+"`n"+$stderr
    $exit=$process.ExitCode
    $passed=($exit-eq$ExpectedExit)-and($all.Contains($ExpectedText))
    $checks.Add([pscustomobject]@{id=$Name;pass=$passed;exit_code=$exit;expected_exit_code=$ExpectedExit;expected_text=$ExpectedText;output_tail=($all -split "`r?`n"|Select-Object -Last 5)})
}

InvokeValidator 'valid_synthetic_report_passes_all_checks' $valid $expected 0 'SUMMARY 11/11 checks passed'
InvokeValidator 'source_hash_mismatch_is_rejected' $valid ('0'*64) 1 'FAIL source_path_and_hash'
InvokeValidator 'incomplete_solid_bounds_are_rejected' $missingBounds $expected 1 'FAIL every_type_has_finite_positive_solid_bounds'

$passed=@($checks|Where-Object pass).Count
$status=if($passed-eq$checks.Count){'pass'}else{'fail'}
$result=[ordered]@{schema='forever-home-candidate-family-validator-tests-v1';status=$status;checked_source_sha256=$expected;cases=$checks.ToArray();passed=$passed;total=$checks.Count}
$full=Join-Path $repo $ResultPath
$parent=Split-Path $full -Parent
if(-not(Test-Path -LiteralPath $parent)){New-Item -ItemType Directory -Path $parent|Out-Null}
$json=$result|ConvertTo-Json -Depth 12
[IO.File]::WriteAllText($full,($json+"`n"),(New-Object Text.UTF8Encoding($false)))
foreach($check in $checks){$verdict=if($check.pass){'PASS'}else{'FAIL'};Write-Output ("{0} {1}: exit={2}; expected={3}; {4}" -f $verdict,$check.id,$check.exit_code,$check.expected_exit_code,$check.expected_text)}
Write-Output "SUMMARY $passed/$($checks.Count) candidate family validator fixture tests passed"
if($status-ne'pass'){throw 'Candidate family validator fixture tests failed.'}
