param([string]$Python = 'python')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not (Test-Path '.venv/Scripts/python.exe')) {
    & $Python -m venv .venv
    if ($LASTEXITCODE -ne 0) { throw 'Python 3.12 required; pass -Python with its full executable path.' }
}
& ./.venv/Scripts/python.exe -m pip install -r Tools/requirements.lock.txt
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
& ./.venv/Scripts/python.exe Tools/toolchain.py
if ($LASTEXITCODE -ne 0) { throw 'Toolchain verification failed.' }
