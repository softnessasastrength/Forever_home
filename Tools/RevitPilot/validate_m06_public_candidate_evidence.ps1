[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$ProvenancePath,[Parameter(Mandatory=$true)][string]$ReportPath,[Parameter(Mandatory=$true)][string]$Output)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$p=Get-Content (Resolve-Path $ProvenancePath) -Raw | ConvertFrom-Json
$r=Get-Content (Resolve-Path $ReportPath) -Raw | ConvertFrom-Json
$checks=@(); function C($n,$ok,$d){$script:checks+=[pscustomobject]@{name=$n;pass=[bool]$ok;detail=$d}}
$source=Join-Path $repo (Join-Path '.local/revit-pilot/family-intake/candidates' ($p.family.path -replace '/','\'))
$actual=(Get-FileHash $source -Algorithm SHA256).Hash
$t=@($r.types)[0]; $bounds=$t.bounds; $solid=$t.solid_metrics; $connectors=@($r.family_connectors.connectors)
C 'source_exists' (Test-Path $source) $source
C 'source_hash_stable' ($actual -eq $p.family.sha256 -and $r.source.sha256_before -eq $actual -and $r.source.sha256_after -eq $actual) $actual
C 'public_no_auth' ($p.account_or_authentication_used -eq $false) 'account_or_authentication_used=false'
C 'isolated_scope' ($r.project_scope.selected_d_opened -eq $false -and [int]$r.project_scope.family_instances_placed -eq 0) ($r.project_scope|ConvertTo-Json -Compress)
C 'positive_geometry' ([int]$solid.positive_volume_solid_count -gt 0 -and [double]$bounds.width_x -gt 0 -and [double]$bounds.depth_y -gt 0 -and [double]$bounds.height_z -gt 0) ($bounds|ConvertTo-Json -Compress)
C 'sanitary_connector' ($connectors.Count -ge 1 -and @($connectors|Where-Object {$_.domain -eq 'DomainPiping' -and $_.system_classification -eq 'Sanitary'}).Count -ge 1) 'at least one sanitary connector'
C 'unselected_status' ($r.status -like 'pass;*not placed*' -and $p.selection_status -like 'unselected*') 'candidate remains unselected'
C 'B_unassigned' ($p.selection_status -like 'unselected*') 'M-06/B assignment remains outside this evidence study'
$result=[ordered]@{schema='forever-home-m06-public-candidate-evidence-v1';candidate=$p.product;source_sha256=$actual;report_sha256=(Get-FileHash (Resolve-Path $ReportPath) -Algorithm SHA256).Hash;pass=(@($checks|Where-Object {-not $_.pass}).Count -eq 0);checks=$checks;limitations=@('Geometry and connector evidence do not prove room fit, clearances, door/approach, services, code compliance or product approval.','B remains unassigned.')}
$result|ConvertTo-Json -Depth 10|Set-Content $Output -Encoding utf8
$checks|Format-Table -AutoSize; Write-Host "pass : $($result.pass); checks : $(@($checks|Where-Object pass).Count)/$($checks.Count)"; if(-not $result.pass){exit 1}
