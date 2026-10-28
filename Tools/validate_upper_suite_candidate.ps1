param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$RunDirectory,
    [string]$CandidateField = 'best_candidate'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = [System.IO.Path]::GetFullPath((Join-Path $root '..'))
$run = (Resolve-Path -LiteralPath $RunDirectory).Path
$errors = New-Object System.Collections.Generic.List[string]
$checksRun = 0

function Assert-Check([bool]$Condition, [string]$Message) {
    $script:checksRun++
    if (-not $Condition) { $script:errors.Add($Message) }
}

function Get-OverlapLength([double]$A0, [double]$A1, [double]$B0, [double]$B1) {
    [Math]::Max(0.0, [Math]::Min($A1, $B1) - [Math]::Max($A0, $B0))
}

function Get-AxisGap([double]$A0, [double]$A1, [double]$B0, [double]$B1) {
    if ($A1 -le $B0) { return ($B0 - $A1) }
    if ($B1 -le $A0) { return ($A0 - $B1) }
    return 0.0
}

function Test-BoxesOverlap($A, $B) {
    ((Get-OverlapLength $A.x_ft ($A.x_ft + $A.width_ft) $B.x_ft ($B.x_ft + $B.width_ft)) -gt 0.000001 -and
        (Get-OverlapLength $A.y_ft ($A.y_ft + $A.depth_ft) $B.y_ft ($B.y_ft + $B.depth_ft)) -gt 0.000001)
}

function Test-RequiredContact($A, $B, [double]$WallGap, [double]$DoorReservation) {
    $gx = Get-AxisGap $A.x_ft ($A.x_ft + $A.width_ft) $B.x_ft ($B.x_ft + $B.width_ft)
    $gy = Get-AxisGap $A.y_ft ($A.y_ft + $A.depth_ft) $B.y_ft ($B.y_ft + $B.depth_ft)
    $overlapY = Get-OverlapLength $A.y_ft ($A.y_ft + $A.depth_ft) $B.y_ft ($B.y_ft + $B.depth_ft)
    $overlapX = Get-OverlapLength $A.x_ft ($A.x_ft + $A.width_ft) $B.x_ft ($B.x_ft + $B.width_ft)
    (($gx -le ($WallGap + 0.000001) -and $gy -lt 0.000001 -and $overlapY -ge ($DoorReservation - 0.000001)) -or
        ($gy -le ($WallGap + 0.000001) -and $gx -lt 0.000001 -and $overlapX -ge ($DoorReservation - 0.000001)))
}

$searchPath = Join-Path $run 'search.json'
$checksPath = Join-Path $run 'checks.json'
$manifestPath = Join-Path $run 'manifest.json'
$svgPath = Join-Path $run 'upper-suite-search.svg'
foreach ($path in @($searchPath, $checksPath, $manifestPath, $svgPath)) {
    Assert-Check (Test-Path -LiteralPath $path -PathType Leaf) "Missing run artifact: $path"
}
if ($errors.Count -gt 0) { throw ($errors -join [Environment]::NewLine) }

$report = Get-Content -LiteralPath $searchPath -Raw | ConvertFrom-Json
$generatorChecks = Get-Content -LiteralPath $checksPath -Raw | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$selectedPath = Join-Path $root 'Architecture/Selected_Design_Iteration_2026-10-27/study.json'
$followupPath = Join-Path $root 'Architecture/House_Design_Iteration_2026-10-28/study.json'
$programPath = Join-Path $root 'Requirements/Room_Program.md'

Assert-Check ($generatorChecks.failed.Count -eq 0 -and $generatorChecks.count -gt 0) 'Generator integrity checks include failures or no checks.'
foreach ($property in $generatorChecks.checks.PSObject.Properties) {
    Assert-Check ([bool]$property.Value) "Generator check failed: $($property.Name)"
}
Assert-Check ([string]$manifest.generator -eq 'Tools/test_m37_upper_suite_pack_and_route.ps1') 'Unexpected generator recorded in manifest.'

$sourcePaths = [ordered]@{
    'selected_D_study.json' = $selectedPath
    'owner_followup_study.json' = $followupPath
    'Requirements/Room_Program.md' = $programPath
}
foreach ($key in $sourcePaths.Keys) {
    $expected = [string]$manifest.source_fingerprints_sha256.$key
    $actual = (Get-FileHash -LiteralPath $sourcePaths[$key] -Algorithm SHA256).Hash.ToLowerInvariant()
    Assert-Check ($expected -eq $actual) "Source fingerprint changed or mismatched: $key"
}

$artifactMap = [ordered]@{
    search = $searchPath
    checks = $checksPath
    svg = $svgPath
}
foreach ($key in $artifactMap.Keys) {
    $expected = [string]$manifest.output_hashes_sha256.$key
    $actual = (Get-FileHash -LiteralPath $artifactMap[$key] -Algorithm SHA256).Hash.ToLowerInvariant()
    Assert-Check ($expected -eq $actual) "Output hash mismatched: $key"
}
[xml](Get-Content -LiteralPath $svgPath -Raw) | Out-Null
Assert-Check ($report.failures.Count -eq 0) 'Search report records failed checks.'
Assert-Check (-not [string]::IsNullOrWhiteSpace([string]$report.coordinate_basis.shell_case)) 'Coordinate basis is missing a shell-case label.'
Assert-Check ($report.coordinate_basis.shell_case -match 'unselected proposal|unapproved') 'Exploratory upper shell is not explicitly labelled as unapproved.'

$candidate = $report.$CandidateField
Assert-Check ($null -ne $candidate -and $null -ne $candidate.rectangles) "Candidate field '$CandidateField' is empty."
if ($null -eq $candidate -or $null -eq $candidate.rectangles) {
    $failed = $errors.Count
    foreach ($item in $errors) { Write-Error "FAIL: $item" -ErrorAction Continue }
    Write-Output ("FAILED: {0} of {1} independent checks." -f $failed, $checksRun)
    exit 1
}

$rectangles = $candidate.rectangles
$expectedIds = @('U-01', 'C-PRIVATE', 'U-02', 'U-03', 'U-04', 'U-05', 'U-06')
Assert-Check ((Compare-Object ($expectedIds | Sort-Object) (@($rectangles.PSObject.Properties.Name) | Sort-Object)).Count -eq 0) 'Candidate room/connector inventory differs from the source upper-suite graph.'

$doorValues = @(Get-Content -LiteralPath $selectedPath -Raw | ConvertFrom-Json).upper_door_matrix | ForEach-Object { [double]$_.nominal_reservation_ft } | Sort-Object -Unique
$doorReservation = $doorValues | Where-Object { [Math]::Abs($_ - 3.5) -lt 0.000001 } | Select-Object -First 1
Assert-Check ($null -ne $doorReservation) 'Source 3.5-ft nominal contact reservation was not found.'
$wallGap = 0.5
$shellWidth = [double]$report.coordinate_basis.width_ft
$shellDepth = [double]$report.coordinate_basis.depth_ft

foreach ($id in $expectedIds) {
    $rect = $rectangles.$id
    $source = $report.source_dimensions_ft.$id
    $sameOrientation = [Math]::Abs([double]$rect.width_ft - [double]$source.width_ft) -le 0.000001 -and
        [Math]::Abs([double]$rect.depth_ft - [double]$source.depth_ft) -le 0.000001
    $rotatedOrientation = [Math]::Abs([double]$rect.width_ft - [double]$source.depth_ft) -le 0.000001 -and
        [Math]::Abs([double]$rect.depth_ft - [double]$source.width_ft) -le 0.000001
    Assert-Check ($sameOrientation -or $rotatedOrientation) "$id dimensions differ from documented source dimensions in either allowed orientation."
    Assert-Check ([double]$rect.x_ft -ge -0.000001 -and [double]$rect.y_ft -ge -0.000001 -and
        ([double]$rect.x_ft + [double]$rect.width_ft) -le ($shellWidth + 0.000001) -and
        ([double]$rect.y_ft + [double]$rect.depth_ft) -le ($shellDepth + 0.000001)) "$id lies outside the labelled exploratory shell."
    Assert-Check (-not (Test-BoxesOverlap $rect $report.local_lift_keepout)) "$id overlaps projected lift reservation."
    Assert-Check (-not (Test-BoxesOverlap $rect $report.reserved_stair_approach)) "$id overlaps reserved stair approach."
}

for ($i = 0; $i -lt $expectedIds.Count; $i++) {
    for ($j = $i + 1; $j -lt $expectedIds.Count; $j++) {
        $a = $rectangles.($expectedIds[$i])
        $b = $rectangles.($expectedIds[$j])
        Assert-Check (-not (Test-BoxesOverlap $a $b)) "Room blocks overlap: $($expectedIds[$i]) / $($expectedIds[$j])"
    }
}

$requiredContacts = @(
    @('U-01', 'C-PRIVATE'),
    @('C-PRIVATE', 'U-02'),
    @('U-02', 'U-03'),
    @('U-03', 'U-06'),
    @('U-06', 'U-04'),
    @('U-01', 'U-05')
)
foreach ($edge in $requiredContacts) {
    Assert-Check (Test-RequiredContact $rectangles.($edge[0]) $rectangles.($edge[1]) $wallGap $doorReservation) `
        "Required nominal contact is absent: $($edge[0]) / $($edge[1])"
}

$hall = $candidate.hall_reachability
$publicReached = @($candidate.public_rooms_reached | Sort-Object)
Assert-Check ([bool]$hall.required_public_rooms_reached -and
    (@($publicReached | Where-Object { $_ -in @('U-01', 'U-02', 'U-04') }).Count -eq 3)) 'Candidate does not reach all required public rooms in the sampled hall-route proxy.'
Assert-Check ($report.preserved_constraints -contains 'owner-directed U-02 to U-03 private route only; no direct U-03 to C-UPPER door') 'U-03 private-only constraint is not recorded.'
Assert-Check ($report.preserved_constraints -contains 'owner-required direct U-02 shared-hall arrival; actual opening remains unmodeled') 'U-02 direct hall-arrival requirement is not recorded.'
Assert-Check ($report.preserved_constraints -contains '4ft-wide hall route from source upper landing to U-01, U-02 and U-04; sampled side goals do not establish doors') 'Public route is not labelled as the 4-ft sampled proxy.'

if ($errors.Count -gt 0) {
    foreach ($item in $errors) { Write-Error "FAIL: $item" -ErrorAction Continue }
    Write-Output ("FAILED: {0} of {1} independent checks." -f $errors.Count, $checksRun)
    exit 1
}

Write-Output ("PASS: {0} independent checks. Candidate {1}; shell {2} x {3} ft is explicitly exploratory/unapproved; sampled public hall route reaches U-01, U-02 and U-04. No actual doors, code compliance or room approval are established." -f $checksRun, $candidate.layout_key, $shellWidth, $shellDepth)
