param([string]$Dotnet = 'dotnet')
$ErrorActionPreference = 'Stop'
$pilotRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$env:DOTNET_CLI_HOME = Join-Path $pilotRoot '.local/dotnet-home'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = '1'
$env:DOTNET_GENERATE_ASPNET_CERTIFICATE = 'false'
$env:DOTNET_ADD_GLOBAL_TOOLS_TO_PATH = 'false'
& $Dotnet build (Join-Path $PSScriptRoot 'RevitPilot.csproj') -c Release --ignore-failed-sources
if ($LASTEXITCODE -ne 0) { throw 'Pilot build failed' }
$pilotDll = Join-Path $pilotRoot '.local/revit-pilot/build/Release/net10.0-windows/RevitPilot.dll'
Set-Content -LiteralPath (Join-Path (Split-Path $pilotDll) 'workspace.txt') -Value $pilotRoot -Encoding utf8
$pilotEscapedDll = [System.Security.SecurityElement]::Escape($pilotDll)
@"
<?xml version="1.0" encoding="utf-8"?>
<RevitAddIns>
  <AddIn Type="Application">
    <Name>Forever Home Compatibility Pilot</Name>
    <Assembly>$pilotEscapedDll</Assembly>
    <AddInId>096B0D51-8883-4B3D-BD31-E9622201E785</AddInId>
    <FullClassName>ForeverHome.Pilot.App</FullClassName>
    <VendorId>FHOM</VendorId>
    <VendorDescription>Local compatibility fixture; not house design</VendorDescription>
  </AddIn>
</RevitAddIns>
"@ | Set-Content -LiteralPath (Join-Path (Split-Path $pilotDll) 'ForeverHome.Pilot.addin') -Encoding utf8
Write-Output "Built $pilotDll"
Write-Output 'Manifest generated beside DLL. Install in the per-user Revit 2027 Addins folder, restart Revit, then use Add-Ins > Forever Home Pilot.'
