# Terminal design toolchain

## Quick start
From the repository root, use PowerShell:

```powershell
# Requires Python 3.12; pass its executable if python is a Windows Store alias.
./Tools/setup.ps1 -Python 'C:/path/to/python.exe'
./.venv/Scripts/python.exe Tools/toolchain.py
```

Setup creates a local virtual environment and installs pinned Python dependencies. It does not activate a shell environment or change global Python. The initial bootstrap used the desktop app's bundled Python 3.12. That runtime must remain present for this particular venv; recreate with your own Python when moving machines.

## Components
- Python / IfcOpenShell: IFC2x3 parsing and schema validation; future model inspection and schedules.
- trimesh / NumPy: measured geometric studies and GLB exchange.
- ezdxf: DXF drafting and audit; does not author native DWG.
- Blender: installed separately through WinGet, for headless mesh preparation and later scene authoring.
- Revit 2027: authoritative installed BIM authoring application. These Python tools do not create native RVT files or execute the Revit API.
- Git: design branch history; no automatic push or merge.

IfcOpenShell installation reference: https://docs.ifcopenshell.org/ifcopenshell-python/installation.html

## Verification and generated files
`toolchain.py` writes disposable artifacts into ignored `.local/smoke/`: an 8 x 4 x 3 ft box in GLB (metres), a DXF footprint, a minimal IFC2x3 project and a JSON report. These are toolchain fixtures, not an architectural model, approved island height or Revit export. It reloads geometry to check dimensions, audits DXF, and validates the IFC project schema. It fails on assertion or parser error.

`requirements.lock.txt` pins the complete installed environment. `.venv`, caches and generated local files are excluded from Git. Native BIM and large assets need a deliberate storage strategy before addition to the repository.

## Still pending
- [Revit API pilot](RevitPilot/README.md) executed successfully; [verification and limits](../Project/Revit_Pilot_Verification_2026-10-25.md). Exact trial/account expiry and representative 2018 import tests remain pending.
- A coordinated building model, export manifest and actual model-derived schedules.
- Unreal/OpenXR installation and headset selection; defer large engine setup until pipeline/hardware targets are selected.
- No professional design/code validation is implied by software checks.

## Blender headless check
After running the Python smoke test:

```powershell
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --python Tools/blender_smoke.py
```

This checks imported GLB dimensions and saves a disposable `.blend`. Blender 5.2.3 was installed through WinGet on 2026-10-25. PATH may require a new terminal; use the full executable path above in the current session.
