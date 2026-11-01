param(
    [string]$OutputDirectory = 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
)

$ErrorActionPreference = 'Stop'
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$projectPath = Join-Path $repoRoot 'Tools/M83Generator/M83Generator.csproj'
$localDotnet = Join-Path $repoRoot '.local/dotnet/dotnet.exe'
$dotnetCommand = Get-Command dotnet -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath $localDotnet -PathType Leaf) {
    $dotnetPath = $localDotnet
} elseif ($null -ne $dotnetCommand) {
    $dotnetPath = $dotnetCommand.Source
} else {
    throw 'The M83 generator needs a .NET 10 SDK. Use the repository-local SDK or install nothing; ask the owner before adding tools.'
}

& $dotnetPath run --project $projectPath --configuration Release --no-launch-profile -- $OutputDirectory
if ($LASTEXITCODE -ne 0) {
    throw "M83 generator exited with status $LASTEXITCODE."
}
