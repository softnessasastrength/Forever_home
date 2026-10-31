param([string]$OutputDirectory='Architecture/M183_Route_Option_Gate_2026-10-31/artifacts')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$out=Join-Path $root $OutputDirectory
$m181Rel='Architecture/M181_All_Room_Interface_Audit_2026-10-31/artifacts/m181-study.json'
$m182Rel='Architecture/M182_Pantry_Bypass_Route_Audit_2026-10-31/artifacts/m182-study.json'
$selectedRel='Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$socialRel='Architecture/Direction_D_Social_Route_Study_2026-10-27/study.json'
$incoming=@{
 'Revit/Family_Intake/Incoming/american-standard-champion-pro-211AA104-020-predecessor.rfa'='37D3E56962B81F4B0ACE3D36D25BAFC03B7DEE1232E7DE7BBF9B95E4B0B75F63'
 'Revit/Family_Intake/Incoming/american-standard-champion-pro-3195A101020-bowl.rfa'='F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393'
 'Revit/Family_Intake/Incoming/american-standard-evolution-0467004.020.rfa'='39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA'
}
function Hash183([string]$relative){$path=Join-Path $root $relative;if(-not(Test-Path -LiteralPath $path -PathType Leaf)){throw "Missing input $relative"};(Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()}
if((Test-Path -LiteralPath $out)-and @(Get-ChildItem -LiteralPath $out -Force).Count -gt 0){throw "Refusing to overwrite non-empty output directory $out"}
if(-not(Test-Path -LiteralPath $out)){New-Item -ItemType Directory -Path $out -Force|Out-Null}
$m181=Get-Content -LiteralPath (Join-Path $root $m181Rel) -Raw|ConvertFrom-Json
$m182=Get-Content -LiteralPath (Join-Path $root $m182Rel) -Raw|ConvertFrom-Json
$selectedHash=Hash183 $selectedRel
$social=Get-Content -LiteralPath (Join-Path $root $socialRel) -Raw|ConvertFrom-Json
$checks=New-Object System.Collections.Generic.List[object]
function Add183([string]$id,[bool]$pass,[string]$detail){$script:checks.Add([pscustomobject]@{id=$id;pass=$pass;detail=$detail})}
Add183 'expected_source_schemas' (($m181.schema -eq 'forever-home-m181-all-room-interface-v1')-and($m182.schema -eq 'forever-home-m182-pantry-bypass-route-v1')) 'Both route options are consumed from their retained versioned study outputs.'
Add183 'selected_d_fingerprint' (($selectedHash -eq '516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb')-and($m182.source_fingerprints_sha256.PSObject.Properties[$selectedRel].Value -eq $selectedHash)) 'Current selected-D source equals the recorded baseline fingerprint.'
Add183 'm181_sources_current' (($m181.source_fingerprints_sha256.PSObject.Properties[$selectedRel].Value -eq $selectedHash)-and($m181.source_fingerprints_sha256.PSObject.Properties[$socialRel].Value -eq (Hash183 $socialRel))) 'M181 selected-D and social-route fingerprints match current sources.'
Add183 'm182_is_bound_to_m181' ($m182.source_fingerprints_sha256.PSObject.Properties['Architecture/M181_All_Room_Interface_Audit_2026-10-31/artifacts/m181-study.json'].Value -eq (Hash183 $m181Rel)) 'M182 consumes the retained M181 result currently on disk.'
Add183 'm06_b_remains_unassigned' ($social.geometry.m06_window_b_remains_unassigned -eq $true) 'The source social-route study still declares M-06/B unassigned.'
Add183 'm181_option_retains_subinch_constraints' (([double]$m181.revised_route.stool_clearance_in -lt 1)-and([double]$m181.revised_route.west_search_window_clearance_in -lt 0.5)-and([double]$m181.revised_route.table_clearance_in -le 2)) 'The diagonal route has under 1 in at the assumed stools, under 0.5 in at the blocked west search proxy, and 2 in at the dining table.'
Add183 'm182_option_retains_source_conflicts' (([double]$m182.pantry_to_m06b_unassigned_throat_in -eq 44)-and([double]$m182.clearance_to_pantry_in -eq 4)-and([double]$m182.clearance_to_m06b_window_in -eq 4)-and($m182.blocked_west_search_window_intersections.Count -gt 0)-and([double]$m182.corridor_intrusion_into_source_M02_in -eq 2)) 'The bypass route retains its 44 in throat, 4 in side gaps, blocked diagnostic overlap and source M-02 intrusion.'
Add183 'incoming_families_preserved' $true 'Three pre-existing untracked manufacturer RFAs retain their checkpoint SHA256 values.'
foreach($entry in $incoming.GetEnumerator()){try{$observed=Hash183 $entry.Key;$ok=$observed.ToUpperInvariant() -eq $entry.Value;Add183 ('incoming_sha256_'+[IO.Path]::GetFileName($entry.Key)) $ok ("Observed {0}; expected {1}." -f $observed,$entry.Value.ToLowerInvariant())}catch{Add183 ('incoming_sha256_'+[IO.Path]::GetFileName($entry.Key)) $false $_.Exception.Message}}
Add183 'no_route_is_selectable_from_current_evidence' (($m181.revised_route.stool_clearance_in -lt 1)-and($m182.clearance_to_pantry_in -le 4)-and($m182.clearance_to_m06b_window_in -le 4)-and($m182.blocked_west_search_window_intersections.Count -gt 0)) 'Both alternatives retain material conflicts or unvalidated clearances; the report must make no selection.'
$rows=@(
 [ordered]@{option='M181 diagonal kitchen-side route';width_in=[double]$m181.route_width_in;key_measure='minimum proxy margins';finding=('stools {0:F2} in; table {1:F2} in; blocked west search window {2:F2} in' -f [double]$m181.revised_route.stool_clearance_in,[double]$m181.revised_route.table_clearance_in,[double]$m181.revised_route.west_search_window_clearance_in);unresolved='sub-inch static margins; no people, movement, door leaf, threshold or tolerance';status='not selected'},
 [ordered]@{option='M182 pantry-side bypass';width_in=[double]$m182.route_width_in;key_measure='44-in unassigned throat';finding=('side gaps {0:F2}/{1:F2} in; blocked west proxy overlap {2:F3} sf; source M-02 intrusion {3:F2} in' -f [double]$m182.clearance_to_pantry_in,[double]$m182.clearance_to_m06b_window_in,[double]$m182.blocked_west_search_window_intersections[0].area_sf,[double]$m182.corridor_intrusion_into_source_M02_in);unresolved='new M-01 south opening; throat assignment; B approach/door/services';status='not selected'}
)
$passed=@($checks|Where-Object pass).Count;$status='fail';if($passed -eq $checks.Count){$status='pass'}
$sourceMap=[ordered]@{};foreach($r in @($m181Rel,$m182Rel,$selectedRel,$socialRel)){$sourceMap[$r]=Hash183 $r}
$report=[ordered]@{schema='forever-home-m183-route-option-gate-v1';status='comparison only; no circulation or room option selected';source_fingerprints_sha256=$sourceMap;selected_d_sha256=$selectedHash;m06_b_assigned=$false;route_options=$rows;decision='Neither candidate is ready for selection. The M181 diagonal path has sub-inch static clearances. M182 avoids the table/stool pinch but occupies a 44-in unassigned strip beside B, leaves 4-in side gaps, overlaps the blocked west diagnostic search window, intrudes into source M-02 and requires a new M-01 opening.';next_gate='Resolve room-block interfaces and the M-01 south transition, then rerun route geometry with actual door and wall/finish inputs. Reopen B fit only when exact product assembly geometry, applicable clearance, approach and plausible service route are evidenced.';limitations=@('All compared geometry is a schematic coordinate proxy; no route establishes an operable circulation path.','Blocked M-06 west search-window overlap is a diagnostic proxy, not an occupied physical fixture.','No room assignment, door, wall finish, construction tolerance, fixture assembly, service route, Revit or IFC geometry is validated.','No code-compliance, accessibility, structural, professional, permit or construction-readiness finding.');checks=[ordered]@{status=$status;passed=$passed;total=$checks.Count;items=$checks.ToArray()}}
$json=$report|ConvertTo-Json -Depth 30
[IO.File]::WriteAllText((Join-Path $out 'm183-route-option-gate.json'),$json+"`n",(New-Object System.Text.UTF8Encoding($false)))
$csv=($rows|ConvertTo-Csv -NoTypeInformation)-join "`n"
[IO.File]::WriteAllText((Join-Path $out 'm183-route-options.csv'),$csv+"`n",(New-Object System.Text.UTF8Encoding($false)))
$checkJson=$report.checks|ConvertTo-Json -Depth 20
[IO.File]::WriteAllText((Join-Path $out 'm183-checks.json'),$checkJson+"`n",(New-Object System.Text.UTF8Encoding($false)))
Write-Output ("M183: {0}/{1}; candidates={2}; no selection={3}; selected-D={4}" -f $passed,$checks.Count,$rows.Count,($report.m06_b_assigned -eq $false),$selectedHash)
if($passed -ne $checks.Count){exit 1}
