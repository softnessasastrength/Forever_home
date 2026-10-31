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

## Source refresh after M102

The Connecticut roof research note was extended with the R305.1 sloped-ceiling basis on 2026-10-30. Because the M83 generator records that note's SHA256, its four source artifacts were regenerated against the revised note. Three PowerShell 5.1 runs (checked-in destination and two isolated outputs) pass **13/13** checks and match byte-for-byte. This refresh changes only source provenance; roof pitches, ridge cases and geometry remain the same. M101 and M103 downstream analyses were regenerated against the refreshed M83 report.

## Revit bounds-evaluation repair (M121; host validation pending)

The first M83 host invocation stopped at `M83 DirectShape has no bounds: M83 X 8:12.` The command read `DirectShape.get_BoundingBox(null)` immediately after `SetShape` while still inside the open transaction. The isolated source fix now calls `doc.Regenerate()` after each shape assignment and before validating its bounding box; a contract test guards this ordering. The code compiles in `.local/revit-pilot/build-m83-regenerate-bounds-v1/Release/net10.0-windows/RevitPilot.dll` (SHA256 `32B3AB18B33ECC12704FAE292F704FF4775799485AD34A12F582FADC969D0CD8`).

**The repair has not yet passed in Revit.** The still-running Revit process produced an unsigned-add-in dialog for the old `build-m83-level-safe` DLL, not this build. That mismatched prompt was not accepted. The new build may be loaded once only after Revit is fully restarted and the prompt path is verified against the new manifest/build hash. Then rerun all six cases and the independent IFC validator; preserve both the old failed run and new result.

Autodesk's [Revit API reference for `Document.Regenerate`](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/22468e2c-9772-8478-0816-c9759aa43428.htm) says it updates document elements to reflect changes; its example reads modified instance state only after regeneration. This supports placing the explicit regeneration between `DirectShape.SetShape` and the in-transaction bounds query. It does not establish that this command succeeds in the installed Revit build; that remains the outstanding host test. Autodesk's [Revit 2027 IFC export guide](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Advanced_Topics/Export/Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Export_IFC_Export_html.html) documents `Document.Export(String, String, IFCExportOptions)` and application of export-dialog settings through the API. The M83 command selects `IFC2x3CV2`; the actual exported file must still pass the independent validator before this milestone is complete.
