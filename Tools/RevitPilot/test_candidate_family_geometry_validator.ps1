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

function NewHostProbeFixture([string]$Name) {
    $folder=Join-Path $fixtures ('m215-host-probe-'+$Name+'-'+[guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $folder|Out-Null
    $report=Get-Content -LiteralPath $valid -Raw|ConvertFrom-Json
    $report.schema='forever-home-candidate-family-host-probe-v1'
    $report.status='pass; synthetic host-probe validator fixture only'
    $report.project_scope.family_instances_placed=1
    $report.project_scope|Add-Member -NotePropertyName synthetic_host_probe_only -NotePropertyValue $true
    $report.limitations=@($report.limitations)+@(
        'The synthetic wall-face center is an orientation probe, not an installation height or room placement.',
        'The project contains no door, approach, finished-room boundaries, plumbing network, or service route.',
        'A family connector inventory does not establish connector alignment, constructible piping, code applicability, or fixture fit.'
    )
    $report|Add-Member -NotePropertyName host_probe -NotePropertyValue ([pscustomobject]@{
        status='pass; exact type placed on synthetic wall in a disposable project'
        family_type='Synthetic type'
        host_element_id=1001
        instance_host_element_id=1001
        host_face_element_id=1001
        positive_volume_solid_count=1
        instance_bounds_project_in=[pscustomobject]@{
            min=@(0.0,0.0,0.0);max=@(20.0,18.0,24.0)
            width_x=20.0;depth_y=18.0;height_z=24.0
        }
        connectors=[pscustomobject]@{
            status='no_mep_connector_manager';count=0;connectors=@()
            connected_connector_count=0;any_connectors_connected=$false
            external_service_network_modelled=$false
        }
    })
    $path=Join-Path $folder 'candidate-family-host-probe.json'
    [IO.File]::WriteAllText($path,(($report|ConvertTo-Json -Depth 30)+"`n"),(New-Object Text.UTF8Encoding($false)))
    return $path
}

InvokeValidator 'valid_synthetic_report_passes_all_checks' $valid $expected 0 'SUMMARY 11/11 checks passed'
InvokeValidator 'source_hash_mismatch_is_rejected' $valid ('0'*64) 1 'FAIL source_path_and_hash'
InvokeValidator 'incomplete_solid_bounds_are_rejected' $missingBounds $expected 1 'FAIL every_type_has_finite_positive_solid_bounds'
$validHost=NewHostProbeFixture 'valid'
InvokeValidator 'valid_synthetic_wall_host_probe_passes_all_checks' $validHost $expected 0 'SUMMARY 14/14 checks passed'
$wrongHost=Get-Content -LiteralPath $validHost -Raw|ConvertFrom-Json
$wrongHost.host_probe.instance_host_element_id=1002
$wrongHostPath=[IO.Path]::ChangeExtension($validHost,'.wrong-host.json')
[IO.File]::WriteAllText($wrongHostPath,(($wrongHost|ConvertTo-Json -Depth 30)+"`n"),(New-Object Text.UTF8Encoding($false)))
InvokeValidator 'wrong_synthetic_host_identity_is_rejected' $wrongHostPath $expected 1 'FAIL synthetic_wall_host_identity'
$serviceClaim=Get-Content -LiteralPath $validHost -Raw|ConvertFrom-Json
$serviceClaim.host_probe.connectors.external_service_network_modelled=$true
$serviceClaimPath=[IO.Path]::ChangeExtension($validHost,'.false-service-claim.json')
[IO.File]::WriteAllText($serviceClaimPath,(($serviceClaim|ConvertTo-Json -Depth 30)+"`n"),(New-Object Text.UTF8Encoding($false)))
InvokeValidator 'synthetic_fixture_cannot_claim_service_network' $serviceClaimPath $expected 1 'FAIL connector_report_does_not_claim_service_network'

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
