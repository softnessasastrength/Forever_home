# Toolchain verification — 2026-10-25

- Python 3.12.14 isolated venv created; pinned dependencies installed; pip check passed.
- IfcOpenShell 0.9.0.post1: minimal IFC2X3 project serialized, reopened and schema validated with no reported issues.
- trimesh 5.2.0 / NumPy 2.5.4: GLB study box dimensions roundtrip passed.
- ezdxf 1.4.5: R2010 DXF closed polyline roundtrip and audit passed.
- Blender 5.2.3 LTS: WinGet installation completed; headless GLB import dimension assertions passed; smoke.blend saved; exit code 0.
- Tools/setup.ps1 rerun passed using the existing environment.
- Revit 2027 executable found. Revit was not launched, API access was not tested, and no RVT or 2018 compatibility test was performed.

Generated fixtures and machine-specific report are ignored under .local/smoke/. No full building, design verification or VR benchmark is represented by these checks. See Tools/README.md for reproduction commands. Unreal/OpenXR remains pending target selection.
