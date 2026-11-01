# M245 — RevitPilot isolated build preflight

**Status:** current C# add-in source builds in a fresh ignored directory. The build is not registered or loaded; no Revit document was changed.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/build.ps1 `
  -Dotnet '.local/dotnet/dotnet.exe' -BuildDirectory m244-isolated-build
```

The output is isolated under `.local/revit-pilot/m244-isolated-build/`; the build directory must be absent before running the command because the script writes its workspace marker and manifest there.

## Result

The build exits successfully with **0 errors** and **2 MSB3277 reference-conflict warning groups** involving `Microsoft.VisualBasic` reference versions. The output DLL SHA256 is `DAA178628A94057B9DA6A3F66175FD2CE4F58F4F496E92192369A27C16C4B0EC`. Its generated manifest parses, carries the authorized AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`, and resolves to this checkout's ignored `.local/revit-pilot/m244-isolated-build/Release/net10.0-windows/RevitPilot.dll`.

The existing per-user manifest SHA256 is `514F8C24B75E1594E1DAC9A4EB85855F3FCA703D23A922301C7B7F0A1CB168B6`; its AddInId matches, and it points to the existing project-local M234 DLL with SHA256 `FF5578C1CB386114260FBF08F59A421A7B04A24F3E2DFF3CF81CD6C4BE2B01BF`. That registration was left untouched. No new AddInId, security setting, or trust-wide permission was created or changed.

## Limits and next host step

Revit is listed as running, but the supported Computer Use bridge twice returned `Accessibility state unavailable` for its window. No Revit command could be inspected, no trust prompt was handled, and the new build was not loaded. The current generated build is a verified preflight artifact, not evidence that a native house model was generated or that the current host ran the command. Once Revit UI access is restored, inspect the exact project/local AddInId and DLL hash in the Load Once prompt before execution; save any new house work to a disposable derivative. No selected-D, RVT, IFC, Incoming RFA, user manifest or remote branch was changed by this preflight.
