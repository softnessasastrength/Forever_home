# M83 — steep-gable massing comparison

Status: **six source comparisons and a current Revit/IFC2X3 run exist on a hypothetical upper-shell outline; no house pitch, ridge direction, roof datum, assembly, or building dimension is technically selected.** On 2026-11-01 the owner named 12:12 the visual favorite for continued comparison; 8:12 and 10:12 remain available. This is not a feasibility, structural, or code approval. Connecticut is the research jurisdiction. The M76/M78 38.333333 × 40 ft envelope is only an owner-authorized comparison test; it is 33.1% larger than the selected-D 36 × 32 ft upper test wing and is not a proposed building size.

## Reproduce the source geometry

The source generator is a package-free .NET 10 C# console tool. From the repository root:

```powershell
$env:DOTNET_CLI_HOME = '.local/dotnet-home'
.local/dotnet/dotnet.exe build Tools/M83Generator/M83Generator.csproj -c Release --ignore-failed-sources
.local/dotnet/dotnet.exe run --no-build --project Tools/M83Generator/M83Generator.csproj -c Release --no-launch-profile -- 'Architecture/M83_Gable_Massing_38_333333x40_2026-10-30'
.local/dotnet/dotnet.exe run --no-build --project Tools/M83Generator/M83Generator.csproj -c Release --no-launch-profile -- '.local/revalidation/M83-a'
.local/dotnet/dotnet.exe run --no-build --project Tools/M83Generator/M83Generator.csproj -c Release --no-launch-profile -- '.local/revalidation/M83-b'
```

The generator binds the archived M78 search, its manifest, current selected-D study, M38 pitch options and manifest, and Connecticut roof-research note by SHA256. It emits six combinations of the documented 8:12, 10:12 and 12:12 comparisons and two ridge directions. Each option keeps the same 38.333333 × 40 ft projected outline. It records relative eave rise and idealized two-plane area, with no overhang or thickness. `Tools/build_m83_gable_massing_options.ps1` remains a Windows PowerShell 5.1 wrapper for this C# source generator.

The 50 ft diagram offsets separate all six options inside one comparison document. They are not building coordinates. A local z=0 reference is not a wall plate or floor level. The options are open, zero-thickness surfaces and do not include gable walls, framing, roof build-up or drainage.

## Revit 2027 and IFC2X3 host run

1. Build an isolated local pilot using `Tools/RevitPilot/build.ps1 -BuildDirectory 'build-m83'` under the repository's configured PowerShell policy.
2. Verify the per-user manifest retains AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`, its assembly path is inside this worktree, and record the DLL SHA256. Back up the current manifest under ignored `.local/revit-pilot/registration-backups/<timestamp>/` before replacing it.
3. Restart Revit 2027. For the exact verified project-local DLL only, select **Load Once** at its trust prompt. Do not enable Always Load or change global trust settings.
4. In Revit, run **Add-Ins → Forever Home Pilot → Build M83 gable massing options**. The command creates a separate blank project at `.local/revit-pilot/roof-massing/<timestamp>/`, saves the RVT first, then exports IFC2X3 and checks that the saved RVT fingerprint did not change during export.
5. Run the independent validator:

```powershell
./.venv/Scripts/python.exe Tools/RevitPilot/validate_gable_massing_ifc.py '.local/revit-pilot/roof-massing/<timestamp>'
```

Autodesk documents `TessellatedShapeBuilder` as a way to build connected planar faces into mesh geometry and `DirectShape.SetShape` as the storage path for that geometry ([builder reference](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/a144b0e3-c997-eac1-5c00-51c56d9e66f2.htm), [DirectShape guide](https://help.autodesk.com/cloudhelp/2024/ENU/Revit-API/files/Revit_API_Developers_Guide/Revit_Geometric_Elements/Revit_API_Revit_API_Developers_Guide_Revit_Geometric_Elements_DirectShape_html.html)). The M83 command uses the mesh representation for comparative surfaces. It does not create native Revit roof elements.

## Review limits

- Connecticut's official current-code and adoption pages are rechecked in `Research/Connecticut_Roof_Code_Research_2026-10-28.md`; state selection alone does not establish the municipality, permit date, code scope, snow exposure or design criteria.
- No pitch or ridge direction is recommended by the script. The 12:12 option is merely the steepest of three requested comparisons.
- No roof loads, snow drift, wind design, structure, member sizing, fire performance, insulation, ventilation, egress, attic/headroom, drainage or construction details are evaluated.
- IFC validation covers schema, saved-model/export lineage, six generic proxy entities, world-coordinate bounding extents, and triangulated surface areas. It cannot establish professional approval, code compliance, structural safety or construction readiness.

## Earlier source refresh (2026-10-31)

After the 2026-10-31 Connecticut adoption-status recheck, the four M83 artifacts were regenerated. Three PowerShell 5.1 runs passed 13/13 checks and matched byte-for-byte. Those historical hashes are retained in Git history; the next section records the current C# generation.

## Current source refresh and deterministic generation (2026-11-01)

The current research note changed after the 2026-10-31 artifacts were generated. The C# generator was built with the repository-local .NET 10.0.403 SDK (0 warnings, 0 errors) and run twice into separate ignored directories. Both runs passed **13/13** and all four outputs matched byte-for-byte. A line-ending defect in the first C# output pass was corrected; generated text now uses UTF-8 without BOM and normalized LF. The checked-in artifacts were regenerated; current hashes are:

- `checks.json`: `AA933972997934D6005E85651CB08C871B037BF003BFFFD76964BB2AB2F618F8`
- `manifest.json`: `3483A5C481BCD990CFE134253092A58E68849BF9FC14BFABF72A5DE1D706066A`
- `roof-options.json`: `06CB5B290BD31D866C5EB45DF0A688C5CD1184A9C1DED6CD6435E5011A7E6248`
- `roof-options.svg`: `856BEDCA1DEB995E866000D6D668291983EFEB0646DDA93FD23CA69C857C1D05`

The updated manifest binds Connecticut research SHA256 `D77510CA50A463E57B49EA5B18193416FA7C6461DF79CD8695D2931B1B0A84BF`. The new geometry data keep the six prior hypothetical cases and source dimensions. They still contain no selected roof, absolute eave datum, thickness, overhang or full roof assembly. Source generation did not open or modify selected-D.

## Current Revit 2027.3 disposable comparison and IFC2X3 validation (2026-11-01)

RevitPilot generated `.local/revit-pilot/roof-massing/20261101T130016669Z/` from a separate blank project. The saved RVT SHA256 is `B9AABF42209405030677B75ED0BA0FC5FE311B9B92632654898D415EEDC72AE`; the IFC2X3 SHA256 is `EFF2F2AFE7F2917763213964DC60CD7F46D5C9C07C85FC49A538BFCA527DCF12`. The independent validator passes **21/21**. Revit reports six generic mesh surfaces, zero positive-volume solids, one level, and zero native roof/wall/floor/door/window/stair elements. The IFC checks cover export lineage, schema, proxy identity, bounds and triangulated surface area. This disposable comparison validates software output only, not a house roof design.

## Revit bounds-evaluation repair and M165 host validation

The first M83 host invocation stopped at `M83 DirectShape has no bounds: M83 X 8:12.` The command read `DirectShape.get_BoundingBox(null)` immediately after `SetShape` while still inside the open transaction. The isolated source fix calls `doc.Regenerate()` after each shape assignment and before validating its bounding box; a contract test guards this ordering. The currently registered and loaded DLL is `.local/revit-pilot/build-m83-regenerate-bounds-v1/Release/net10.0-windows/RevitPilot.dll`, SHA256 `042BD6A602B6E970A2E7FBFA9C1DC08C22580AD2015A9227DEA85F13B30D5EC3`.

Two disposable Revit 2027.3 host runs now pass the repaired bounds check and complete the IFC2X3 export: `20261031T104347203Z` and `20261031T104806592Z`. Each contains six Generic Model DirectShapes with one open mesh per case, verified Revit bounds, no positive-volume solids, and zero native roof, wall, floor, door, window or stair elements. The independent validator passes **21/21** on both runs. It reports IFC2X3 with zero schema issues, six proxy meshes, expected world-coordinate extents and triangulated areas within 0.02 ft / 0.1 sq ft tolerances. The two normalized geometry records match; RVT/IFC bytes differ because Revit writes run-specific identities. The paired IFC validation report SHA256 values are `F0EAAC76625EAA898BA6E22FCFAF693C91D6BE4BB8169C31D4E82CF584938F59` and `B4A3239F653DC0FD2F220453E87B6977436D265D4C28981BD3EA21EC10E2743F`.

The M83 IFC validator was repaired after the first actual export exposed two mismatches between its assumptions and Revit/IfcOpenShell behavior. IfcOpenShell geometry defaults to SI even when the IFC uses project units; the validator now requests `CONVERT_BACK_UNITS` before applying the declared unit scale. Revit exports the DirectShape's numeric element ID in `IfcBuildingElementProxy.Tag` and uses a category/ID name, so the validator now binds that tag to the exact DirectShape UniqueId recorded in `study-manifest.json`, rather than expecting the case ID in IFC display text. Unit tests cover both contracts. The full offline suite passes **49/49** after the repair.

The Revit security prompt named the verified worktree-local DLL, and **Load Once** was selected under the repository authorization. No Always Load choice, trust-wide setting, selected-D edit or remote operation occurred. The host checks validate the comparative mesh representation only; they do not create native Revit roof elements or establish code compliance, structural adequacy or construction readiness.

Autodesk's [Revit API reference for `Document.Regenerate`](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/22468e2c-9772-8478-0816-c9759aa43428.htm) says it updates document elements to reflect changes; its example reads modified instance state only after regeneration. The M83 command places regeneration between `DirectShape.SetShape` and the in-transaction bounds query, and the two host runs confirm the repaired check in Revit 2027.3. Autodesk's [Revit 2027 IFC export guide](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Advanced_Topics/Export/Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Export_IFC_Export_html.html) documents `Document.Export(String, String, IFCExportOptions)` and application of export-dialog settings through the API. The M83 command selects `IFC2x3CV2`; both exported files pass the documented independent validator.
