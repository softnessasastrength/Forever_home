# M83 — steep-gable massing comparison

Status: **six Revit/IFC comparison options are planned on a hypothetical upper-shell outline; no pitch, ridge direction, roof datum, assembly, or building dimension is selected.** The owner requested a steep traditional gable and selected Connecticut as the research jurisdiction. The M76/M78 38.333333 × 40 ft envelope is only an owner-authorized comparison test; it is 33.1% larger than the selected-D 36 × 32 ft upper test wing and is not a proposed building size.

## Reproduce the source geometry

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1 -OutputDirectory '.local/revalidation/M83-a'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1 -OutputDirectory '.local/revalidation/M83-b'
```

The generator binds the archived M78 search, its manifest, current selected-D study, M38 pitch options and manifest, and Connecticut roof-research note by SHA256. It emits six combinations of the documented 8:12, 10:12 and 12:12 comparisons and two ridge directions. Each option keeps the same 38.333333 × 40 ft projected outline. The script records relative eave rise and idealized two-plane area, with no overhang or thickness.

The 50 ft diagram offsets separate all six options inside one comparison document. They are not building coordinates. A local z=0 reference is not a wall plate or floor level. The options are open, zero-thickness surfaces and do not include gable walls, framing, roof build-up or drainage.

## Revit 2027 and IFC2X3 host run

1. Build an isolated local pilot using `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/RevitPilot/build.ps1 -BuildDirectory 'build-m83'`.
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

## Source refresh after later Connecticut research

After subsequent edits to the Connecticut research note, the four M83 artifacts were regenerated. Three PowerShell 5.1 runs (the checked-in destination and two isolated outputs) pass **13/13** checks and match byte-for-byte: `roof-options.json` SHA256 `DB8BD3EB591CB936B8811332F34EE1FA86745D3F167CA4480E44A871DA803ED2`, `checks.json` `1E23B0C7C7AD0B2300BAE21034BB29CE628153C920AA42C98875BC7D18384976`, `manifest.json` `1A877A2823FB07805B15A3AA8DE3C247C211FE0A87CE781C52BF5A64FC0A5BFB`, and unchanged SVG `9C5EA4DBBB297A530463774C610CE8D1C81E18E7FA1135A414BCDBC632981219`. Geometry remains the same six hypothetical comparisons; only source provenance changed.

## Revit bounds-evaluation repair and M165 host validation

The first M83 host invocation stopped at `M83 DirectShape has no bounds: M83 X 8:12.` The command read `DirectShape.get_BoundingBox(null)` immediately after `SetShape` while still inside the open transaction. The isolated source fix calls `doc.Regenerate()` after each shape assignment and before validating its bounding box; a contract test guards this ordering. The currently registered and loaded DLL is `.local/revit-pilot/build-m83-regenerate-bounds-v1/Release/net10.0-windows/RevitPilot.dll`, SHA256 `042BD6A602B6E970A2E7FBFA9C1DC08C22580AD2015A9227DEA85F13B30D5EC3`.

Two disposable Revit 2027.3 host runs now pass the repaired bounds check and complete the IFC2X3 export: `20261031T104347203Z` and `20261031T104806592Z`. Each contains six Generic Model DirectShapes with one open mesh per case, verified Revit bounds, no positive-volume solids, and zero native roof, wall, floor, door, window or stair elements. The independent validator passes **21/21** on both runs. It reports IFC2X3 with zero schema issues, six proxy meshes, expected world-coordinate extents and triangulated areas within 0.02 ft / 0.1 sq ft tolerances. The two normalized geometry records match; RVT/IFC bytes differ because Revit writes run-specific identities. The paired IFC validation report SHA256 values are `F0EAAC76625EAA898BA6E22FCFAF693C91D6BE4BB8169C31D4E82CF584938F59` and `B4A3239F653DC0FD2F220453E87B6977436D265D4C28981BD3EA21EC10E2743F`.

The M83 IFC validator was repaired after the first actual export exposed two mismatches between its assumptions and Revit/IfcOpenShell behavior. IfcOpenShell geometry defaults to SI even when the IFC uses project units; the validator now requests `CONVERT_BACK_UNITS` before applying the declared unit scale. Revit exports the DirectShape's numeric element ID in `IfcBuildingElementProxy.Tag` and uses a category/ID name, so the validator now binds that tag to the exact DirectShape UniqueId recorded in `study-manifest.json`, rather than expecting the case ID in IFC display text. Unit tests cover both contracts. The full offline suite passes **49/49** after the repair.

The Revit security prompt named the verified worktree-local DLL, and **Load Once** was selected under the repository authorization. No Always Load choice, trust-wide setting, selected-D edit or remote operation occurred. The host checks validate the comparative mesh representation only; they do not create native Revit roof elements or establish code compliance, structural adequacy or construction readiness.

Autodesk's [Revit API reference for `Document.Regenerate`](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/22468e2c-9772-8478-0816-c9759aa43428.htm) says it updates document elements to reflect changes; its example reads modified instance state only after regeneration. The M83 command places regeneration between `DirectShape.SetShape` and the in-transaction bounds query, and the two host runs confirm the repaired check in Revit 2027.3. Autodesk's [Revit 2027 IFC export guide](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Advanced_Topics/Export/Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Export_IFC_Export_html.html) documents `Document.Export(String, String, IFCExportOptions)` and application of export-dialog settings through the API. The M83 command selects `IFC2x3CV2`; both exported files pass the documented independent validator.
