# M269 — Family connector inventory implementation

Date: 2026-11-01
Branch: `codex/house-design-sandbox` (local only)
Status: **first Revit runtime inspection and M270 shape-specific replay passed**

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

## Runtime evidence and remaining checks

The owner cleared the visible Revit trial intro overlay. Revit 2027.3 started the exact manifest-registered M269 assembly from this worktree (`.local/revit-pilot/m269-family-connectors/Release/net10.0-windows/RevitPilot.dll`); the journal records the full assembly path, vendor `FHOM`, AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`, and `NoError`. The agent did not click a trust choice. The command **Inspect quarantined family geometry** ran against the exact quarantined KOHLER source in a new disposable project.

Runtime report: `.local/revit-pilot/family-intake/derivatives/M269-Kohler-Tresham-Connector-Inspection-20261101/candidate-family-geometry.json`; report SHA256 `A9B396221B90FF54DE773CCB80C02E6D9B6B26CA81EEEFFA0A504F33DF60F3C2`; derivative RVT SHA256 `443358F1F004A78E9DF1CA80603845C94D22A1E6C84CF7CB91C2E440DE3259E6`. Inline report assertions passed 6/6: schema/status, source hash before/after/current, isolated-project/no-selected-D/no-instance scope, ten types with positive-volume geometry and finite positive bounds, a primary round sanitary piping connector with 5/8 in radius, and derivative file hash. The source hash is `3B1CBDAA844D35BD462F6E59A828B82F7870FDE4EE7397BAC09F4CA0C2F9B949`; it was closed without saving and remains unchanged. No sink instance or service route was created.

The first report also exposed a Revit API edge case: `ConnectorElement.Width` and `.Height` return `-12 in` for this round profile, where those dimensions do not apply. The code now emits radius only for round connectors and width/height only for rectangular connectors. The corrected build is `.local/revit-pilot/m270-connector-dimensions-v2/Release/net10.0-windows/RevitPilot.dll` (SHA256 `7D42C49F92B7CB20FACCBB1840C097C7E47FFBDBD3BA89733A05EDE09A507975`, 0 errors, 2 existing `MSB3277` warnings). The exact AddInId manifest was registered with a preserved backup under `.local/revit-pilot/registration-backups/20261101163828/`.

On 2026-11-01 the exact corrected M270 manifest/DLL pair was launched in Revit 2027.3 after dismissing only the visible trial overlay. The **Inspect quarantined family geometry** command ran against the exact SHA-pinned KOHLER Cimarron RFA in a new disposable project. Runtime report: `.local/revit-pilot/family-intake/derivatives/20261101T220500Z-kohler-cimarron-m270/candidate-family-geometry.json`; report SHA256 `EA69870A6E3EC7A42ED636F4AE2F0E9FFF3DA18EFF3A353CE42CCCE8399250F2`; derivative RVT SHA256 `2D8648BD4C259A8D1612722DCD847EFE98D960E9F77A4AC3C4CF277B2A3B34FE`. The independent validator passes **11/11**. It records one primary `DomainPiping` / `Sanitary` / `Round` connector with radius `0.625 in` and `null` width/height, confirming the shape-specific correction. The source RFA hash remains `3E5FD99648DE9CB384A8269F82896A2684C52F6E6C46A098F2A16DCE34A08979`; no instance, service network, selected-D model, or source-family edit was made.

Keep the sink a candidate only; this inventory cannot establish connector alignment in a room, a constructible plumbing network, product fit, code compliance or M-06 assignment. Preserve the M266 selected-D baseline and the locked Evolution RFA.
