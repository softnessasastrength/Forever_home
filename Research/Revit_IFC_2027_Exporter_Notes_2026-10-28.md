# Revit 2027 IFC exporter and selected-D geometry validation

Updated: 2026-10-28 02:42 EDT
Scope: identify the IFC exporter recorded by the selected-D IFC and tighten the independent check of exported room footprints. This is project-validation research, not a Revit update or an architectural design change.

## Verified local exporter identity

- Autodesk Revit's installed `Revit.IFC.Export.dll` at `C:\Program Files\Autodesk\Revit 2027\Revit.IFC.Export.dll` reports file/product version **27.3.0.28** and SHA256 `17D59EE118221B96D42A94BCF42E648BC870A28ED631D30906A2D2C0F231B292`.
- The selected-D IFC header independently records `Autodesk - Revit 27.3.0.28 (ENU) - 27.3.0.28`, preprocessor `ODA SDAI 25.12`, and schema `IFC2X3`.
- Autodesk support documents the IFC header as a way to identify the exporter version. Autodesk's separately published open-source IFC extension release page lists a Revit 2027 package **27.3.0.12**, whose notes include corrections for shifted/incorrectly placed room geometry and other IFC defects. The package number and Revit application build number are different version identifiers; the public release page alone does not prove which standalone extension is installed. No extension was installed or changed.

## Geometry validation added

The previous selected-D IFC validator checked IFC parse/schema, room IDs, areas, storeys/levels, source fingerprints and intentionally empty construction categories. Area equality alone could not detect a space whose footprint had moved while retaining its area.

The validator now independently decodes every `IfcSpace` body and compares its world-coordinate XY bounds, converted from IfcOpenShell's SI-metre vertices to feet, with the corresponding room rectangle in the checked-in source. It applies the source's documented main/upper/lower plan-frame offsets and a **0.02 ft numeric export tolerance**. It records per-space expected and observed bounds and records the exporter identity from the IFC header. This checks only 2D room footprints; it does not verify room heights, walls, doors, stairs, services, site coordinates, or building coordination.

### Evidence

- Added unit coverage for source-frame offsets and metre-to-foot bound conversion.
- On an isolated copy of Revit run `20261028T021345099Z`, replaced only the copied named RVT with the byte-identical `.0001.rvt` backup whose SHA matches the run manifest. The enhanced selected-D IFC validator passes **24/24** checks, including all 21 IFC room XY footprints, source areas/IDs/levels, three storeys, IFC2X3 schema, export hash, exact copied-RVT lineage, and empty physical-construction categories. Machine report: `.local/revalidation/selected-d-ifc-coordinate-20261028T024106625/ifc-validation-coordinate.json`.
- The preserved IFC itself is unchanged (SHA256 `05a529999c08bde5695af87ec6e62e9cab86a8686a85d04d739e163861dac849`). The currently named RVT in the original run remains a different hash from its manifest, so the original run must still fail exact lineage until a fresh Revit export is generated from a verified saved model.

## Interpretation and next action

This independent geometry gate materially strengthens the room-space export check and remains applicable regardless of whether Revit uses its built-in exporter or the separately packaged open-source extension. On the next available host run, regenerate the isolated D study from the current named source, record the IFC header's exact exporter version, then rerun this validator against that exact saved RVT. A passing result validates only this room-boundary study and its exported footprints; it is not a coordinated architectural model or professional approval.

## Sources

- [Autodesk Support: identify the IFC exporter version](https://help.autodesk.com/view/RVT/2026/ENU/?caas=caas%2Fsfdcarticles%2Fsfdcarticles%2FHow-to-view-the-IFC-exporter-version-in-Revit.html)
- [Autodesk Revit IFC exporter releases](https://github.com/Autodesk/revit-ifc/releases) — Revit 2027 package 27.3.0.12 release notes, including room-geometry placement fixes.
- [Autodesk Revit 2027 IFC export documentation](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-DocumentPresent/files/GUID-6EB68CEC-6C17-4B16-A509-30537F666C1F.htm)
- [Autodesk Revit 2027 IFC parameter mapping](https://help.autodesk.com/view/rvt/2027/enu//?guid=GUID-C057D715-1571-4D11-8F02-417F3B385577)
