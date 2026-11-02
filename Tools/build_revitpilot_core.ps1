[CmdletBinding()]
param([string]$BuildDirectory = 'core-standalone')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$dotnet = Join-Path $root '.local/dotnet/dotnet.exe'
if (-not (Test-Path -LiteralPath $dotnet)) { $dotnet = 'dotnet' }
$env:DOTNET_CLI_HOME = Join-Path $root '.local/dotnet-home'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$project = Join-Path $PSScriptRoot 'RevitPilot/Core/RevitPilot.Core.csproj'
& $dotnet build $project -c Release "-p:BaseOutputPath=../../.local/revit-pilot/$BuildDirectory/" --ignore-failed-sources
if ($LASTEXITCODE -ne 0) { throw 'UI-neutral core build failed.' }
Write-Output "Built UI-neutral core at .local/revit-pilot/$BuildDirectory/Release/net10.0/RevitPilot.Core.dll"
