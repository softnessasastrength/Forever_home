[CmdletBinding()]
param([string]$InputPath = "Architecture/M373_Draft_Coordination_Choices_2026-11-02/draft-coordination.json")
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$doc = Get-Content -LiteralPath (Join-Path $root $InputPath) -Raw | ConvertFrom-Json
$checks = @()
function Check([string]$Name, [bool]$Pass, [string]$Detail) { $script:checks += [pscustomobject]@{ name = $Name; pass = $Pass; detail = $Detail } }
Check 'schema' ($doc.schema -eq 'forever-home-m373-draft-coordination-v1') $doc.schema
Check 'draft_status' ($doc.status -eq 'draft-study-inputs') $doc.status
Check 'selected_d_protected' ($doc.selected_d_modified -eq $false) 'Selected-D remains untouched.'
Check 'm06_unassigned' ($doc.m06.assignment -eq 'unassigned' -and $doc.m06.fit_gates.room_assignment_authorized -eq $false) 'M-06 remains unassigned.'
Check 'm06_windows_protected' ($doc.m06.protected_search_windows.Count -eq 2 -and $doc.m06.protected_search_windows -contains 'west-A' -and $doc.m06.protected_search_windows -contains 'east-B') 'Both search windows retained.'
Check 'm06_preferences' ($doc.m06.door_swing_preference -eq 'into-bath' -and $doc.m06.fixture_relationship_preference -eq 'same-wet-wall') 'Draft door and wet-wall preferences recorded.'
Check 'm06_gates_closed' (($doc.m06.fit_gates.PSObject.Properties.Value | Where-Object { $_ -eq $true }).Count -eq 0) 'No M-06 fit gate is falsely promoted.'
Check 'primary_bath_source' ($doc.primary_bath.source_block -eq 'U-05' -and $doc.primary_bath.source_area_sf -eq 90.0 -and ($doc.primary_bath.source_envelope_ft -join 'x') -eq '9x10') 'Source U-05 block preserved.'
Check 'primary_bath_direction' ($doc.primary_bath.arrangement -eq 'separate-tub-plus-tiled-rain-shower' -and $doc.primary_bath.fixture_product_selected -eq $false) 'Bath direction recorded without product selection.'
Check 'reversible' ($doc.reversibility.selected_d_overwrite -eq $false -and $doc.reversibility.existing_rvt_overwrite -eq $false -and $doc.reversibility.remote_state_changed -eq $false) 'Only new draft files are in scope.'
$failed = @($checks | Where-Object { -not $_.pass })
$checks | ForEach-Object { "{0}: {1} - {2}" -f ($(if ($_.pass) { 'PASS' } else { 'FAIL' }), $_.name, $_.detail) }
"SUMMARY $(@($checks | Where-Object pass).Count)/$($checks.Count) checks passed"
if ($failed.Count -gt 0) { exit 1 }
