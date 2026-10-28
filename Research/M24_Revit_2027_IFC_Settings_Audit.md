# M24 — Revit 2027 IFC settings audit

Updated: 2026-10-28

Status: source/configuration audit complete; active-host mapping capture pending.

## Reproduction

From the repository root, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/audit_ifc_export_configuration.ps1
```

The script reads the checked-in RevitPilot source and export manifests plus the retained selected-D source/export/IFC validation evidence. It writes `Research/M24_Revit_2027_IFC_Settings_Audit.json`. The audit passes **11/11** checks. Two consecutive runs produced the same JSON SHA256: `ba2b62bf316772420bc142147db3eed247aaf491565f1ada29e020faf8f47a1a`.

## Verified source configuration

The selected-D command in `Tools/RevitPilot/Pilot.cs` directly supplies `IFCVersion.IFC2x3CV2` and `ExportBaseQuantities=true` to `IFCExportOptions`, calls `Document.Export` within a transaction, and rolls the transaction back. It does not explicitly set `FilterViewId`, `ExportInternalRevitPropertySets`, `FamilyMappingFile`, or a named IFC parameter-mapping template. Autodesk documents `FilterViewId` as defaulting to `InvalidElementId`, which means no special view filter; the other absent options are not assigned an inferred value here ([API reference](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/927884ac-60b2-fe93-faac-8212d26ebd6a.htm)).

The separate manifest exporter explicitly sets IFC2x3CV2, base quantities, internal Revit property sets, and an optional named view filter. Both checked-in manifests set quantities and internal property sets to `true` and set no filter view. Neither path selects a named parameter-mapping template or carries a project mapping file in its manifest.

The retained current-source selected-D export was produced by Revit 27.3.0.28. Its exact backup validation passes **25/25**: IFC2X3 parses with zero schema issues, all 21 room-space records match the source across three storeys, and physical construction categories remain empty. This validates IFC identity and the room-space export contract; it does not establish the complete property mapping applied by Revit.

## Mapping-template evidence gap

Autodesk’s Revit 2027 UI help describes saved mapping templates and import/export of mapping files. Autodesk’s Revit 2027 API guide documents `IFCParameterTemplate` operations for listing, retrieving and exporting templates, and the API reference says that a null active template implies in-session template use. The original selected-D export report contains no active-template observation. A later audit of the currently open document could record current settings but could not prove the settings used for the historical export.

Autodesk references:

- [Revit 2027 IFC parameter mapping](https://help.autodesk.com/view/rvt/2027/enu//?guid=GUID-C057D715-1571-4D11-8F02-417F3B385577)
- [Manage IFC export parameter mapping settings](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-DocumentPresent/files/GUID-97F362CD-BB45-4609-8EC6-1CCBDE854542.htm)
- [Revit 2027 API IFC export guide](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Advanced_Topics/Export/Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Export_IFC_Export_html.html)
- [IFCParameterTemplate API reference](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/dc942a54-38a9-2036-c82d-b7b689f3f81b.htm)
- [IFCParameterTemplate.GetActiveTemplate](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/132c18c5-70b3-41f6-b966-47aed0879ddf.htm)

## Build and host limitations

The host audit command was not added because the available portable .NET SDK archive failed the required SHA-512 match against Microsoft’s release metadata. The installed machine-wide `dotnet` reports no SDK. The Revit 2027 window is running and its unsigned-add-in prompt identifies the registered project-local v2 DLL with SHA256 `25c89e269f4be7effdabc3faa1e140f020c352d420cfd84b526e8fcc122fb534`; the per-user manifest has the authorized AddInId and is backed up. The trial welcome WebView covers the workspace and owns the UI input surface, so the Load Once click could not be delivered to the trust dialog. No add-in was loaded, no software was downloaded or installed, no manifest was replaced, and no Revit document was changed. The unverified SDK must not be used to build or load a new DLL.

Next M24 action, when a verified SDK is available: build a read-only RevitPilot command, confirm the exact project-local DLL hash and per-user AddInId under `AGENTS.md`, then inspect the intended saved study in Revit 2027 without saving it. Export and hash the active named mapping template if one exists; report in-session use as such. A separate verified export is required to claim the export has adopted any changed settings.

This milestone does not imply architectural coordination, code compliance, accessibility, structural safety, certification, or construction readiness. The selected-D IFC remains a room-boundary study without walls, openings, floors, stairs, structure, or MEP.
