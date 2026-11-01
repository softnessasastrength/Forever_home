# Native wall shell study

Date: 2026-11-02

Status: **historical M299 derivative; runtime verified in Revit 2027.3 and preserved. Superseded for active vertical design by the owner's later direction to treat 8/9/10 ft as clear-ceiling alternatives and leave floor-to-floor spacing unresolved.**

## Scope

This is the first step from the M298 room-volume wireframe toward native Revit building geometry. It uses the selected-D source only as a hash-pinned schematic reference and preserves the documented lower/main/upper plan offsets. The 40 × 42 ft Main and 36 × 32 ft rear-level rectangles, and the 8/9/10-ft vertical intervals, are comparative study inputs, not selected final exterior dimensions or floor-to-floor specifications.

The command creates four native perimeter Basic Wall elements for each of three story envelopes in each interval case (36 walls total), reuses the template seed level and creates the eight remaining datums, then saves a new model and JSON manifest under ignored `.local/revit-pilot/native-wall-shell/<timestamp>/`. It records the Basic Wall type and width read from the blank Imperial Multi-discipline template. Runtime selected `Wall 1`, width 0.6667 ft (8 in). That type/width is a visualization placeholder only, not an owner-approved assembly.

## Build and runtime evidence

Build with the repository-local SDK and expected data files:

```powershell
& 'Tools/RevitPilot/build.ps1' -BuildDirectory 'native-wall-shell'
```

The successful project-local DLL SHA256 is `1C60CF4A1DF8EAF78CB2D3071F46C233F410ED3E9CB6357A4F88DD9975585A78`. Before launch, the per-user RevitPilot manifest was verified to use AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`, the repository-local assembly path and this DLL hash; its previous copy was preserved at `.local/revit-pilot/registration-backups/20261101T121331269/`. Revit showed the unsigned-add-in prompt; **Load Once** was selected only after rechecking the exact path/hash. No broad trust setting was changed.

Revit 2027.3 created a new Imperial Multi-discipline project and **Forever Home Pilot → Build native wall shell study** generated run `20261101T172354034Z`. PowerShell `ConvertFrom-Json`/`Get-FileHash` checks passed for the selected-D source SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`, shell-study basis SHA256 `8961064955BB4036749931119883D00A80BE62706F69F64447F8BC2298A239B8`, and saved-RVT SHA256 `75D3D0400AAFAD33870217BFB2CD88337C574DD789F657C8313E997BBFB02453`. Manifest checks: 36 wall instances and 36 centerline records; 9 levels; 8/9/10-ft cases; `Wall 1` width 8 in; zero doors, windows, floors, stairs, or roofs. The RVT reopened; its named isometric view was inspected; after Revit closed, the RVT hash was independently confirmed against the manifest.

The first runtime attempt saved an RVT but left a zero-byte manifest when the code queried the Revit `WallType` after closing its document. That failed run, `.local/revit-pilot/native-wall-shell/20261101T172028419Z/`, is retained as evidence; the corrected command snapshots the type name/width before closing. A preceding launch also exposed the missing `workspace.txt` build handoff; using the repository's `build.ps1` created it. Neither failure changed the selected-D source/RVT/IFC.

## Deliberately unresolved

No room partitions, doors, windows, floors, stairs, roofs, structure, MEP, or site context are added. Openings, actual wall assemblies/thickness, floor assemblies, stair geometry, grade, and final shell dimensions remain unresolved. The model is not a navigable, coordinated, code-checked, structurally evaluated, professionally approved, permitted, or construction-ready building.

The walls are intentionally uncolored. Before assigning Revit finishes or appearance assets, follow [`Architecture/Render_to_Model_Reference_Map.md`](../Render_to_Model_Reference_Map.md): current owner decisions and the material schedule supersede conflicting details in concept images. In particular, do not copy the old faux-fire/TV stack or island range, and do not infer an exterior palette from interior renderings.

## Validation record

This is a native perimeter-wall massing check, not the house model. The successful derivative remains ignored under `.local`; no source RVT/IFC export was modified. Before treating it as architectural design, resolve exterior dimensions, wall assembly, openings/door positions, floor assemblies, stair route/section, roof and site orientation with the owner/design team. No code, clearance, structural, accessibility, professional, permit, or construction-readiness review is established.

## Supersession note

The owner later clarified that 8, 9 and 10 ft refer to clear-ceiling alternatives, not floor-to-floor intervals. Therefore the three 8/9/10-ft level-spacing cases in this historical M299 RVT must not be used as building elevations or as the active vertical design. Its original evidence remains intact. The replacement command and separate runtime record are tracked under `Architecture/M311_Clear_Ceiling_Wall_Height_Study/README.md`.
