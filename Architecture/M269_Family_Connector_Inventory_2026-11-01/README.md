# M269 — Family connector inventory implementation

Date: 2026-11-01
Branch: `codex/house-design-sandbox` (local only)
Status: **compiled; Revit runtime inspection pending**

## Scope

Extend the existing quarantined-family RevitPilot inspector to enumerate actual `Autodesk.Revit.DB.ConnectorElement` objects from the exact source `FamilyDocument`. For each element, the report records its Revit ID, category, domain, system classification, direction, profile shape, primary flag, family-coordinate origin and axes, and available radius/width/height values. This is separate from similarly named family type parameters such as Waste/Vent/CW/HW flags.

Autodesk documents `ConnectorElement` as the base class for connector elements in families and exposes domain, classification, direction, origin, coordinate system, shape and dimensions: [Revit API ConnectorElement reference](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/cd7d7579-1058-e8ca-d55a-c3a914843667.htm). The command reads those properties before loading the family into a new disposable Imperial project. It does not place an instance, modify the source family or selected-D, or create a service route.

## Build and registration evidence

- Revit 2027.3 / .NET SDK 10.0.403; build completed with **0 errors** and **2 MSB3277 reference-conflict warnings**.
- Reproducible build from repository root:

  ```powershell
  $env:DOTNET_CLI_HOME = '.local/dotnet-home'
  .local/dotnet/dotnet.exe build Tools/RevitPilot/RevitPilot.csproj -c Release '-p:BaseOutputPath=../../.local/revit-pilot/m269-family-connectors/' --ignore-failed-sources
  ```

- DLL: `.local/revit-pilot/m269-family-connectors/Release/net10.0-windows/RevitPilot.dll`
- DLL SHA256: `2F6D153B3BB53B1E3C953F76F57DC6781734B8E31C381113921DE5AA752ABA4E`.
- Candidate request targets only the quarantined KOHLER Tresham RFA with expected SHA256 `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949` and a new ignored derivative path.
- The per-user manifest was checked for AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`; new assembly path resolves inside this checkout. Previous manifest backup: `.local/revit-pilot/registration-backups/20261101T074145202/ForeverHome.Pilot.addin`. Full hashes and registration path are in ignored `registration-evidence.json` beside the DLL.

## Runtime blocker and remaining checks

Revit restarted, but its trial intro overlay blocks access to the unsigned-add-in prompt. The supported computer-use bridge refuses the overlay click because the surface belongs to an untargeted WebView child; after reselecting Revit, it also returned `Accessibility state unavailable`. The journal records a generic unsigned-file prompt without assembly identity. No trust choice was made and the family inspection command did not run. Do not use Load Once until the prompt itself identifies the exact path and the DLL SHA256 matches the value above.

Once accessible, run **Inspect quarantined family geometry**. Then check that the report is tied to the exact source hash, that the connector count and geometry/domain fields are internally consistent, and that the source hash remains unchanged after the family is closed without saving. Keep the sink a candidate only; this inventory cannot establish connector alignment in a room, a constructible plumbing network, product fit, code compliance or M-06 assignment.
