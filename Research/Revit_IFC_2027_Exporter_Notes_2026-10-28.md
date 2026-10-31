# Revit 2027 IFC exporter and selected-D geometry validation

Updated: 2026-10-29 (dated recheck added below)
Scope: identify the IFC exporter recorded by the selected-D IFC and tighten the independent check of exported room footprints. This is project-validation research, not a Revit update or an architectural design change.

## Verified local exporter identity

- Autodesk Revit's installed `Revit.IFC.Export.dll` at `C:\Program Files\Autodesk\Revit 2027\Revit.IFC.Export.dll` reports file/product version **27.3.0.28** and SHA256 `17D59EE118221B96D42A94BCF42E648BC870A28ED631D30906A2D2C0F231B292`.
- The selected-D IFC header independently records `Autodesk - Revit 27.3.0.28 (ENU) - 27.3.0.28`, preprocessor `ODA SDAI 25.12`, and schema `IFC2X3`.
- Autodesk support documents the IFC header as a way to identify the exporter version. Autodesk's separately published open-source IFC extension release page lists a Revit 2027 package **27.3.0.12**, whose notes include corrections for shifted/incorrectly placed room geometry and other IFC defects. The package number and Revit application build number are different version identifiers; the public release page alone does not prove which standalone extension is installed. No extension was installed or changed.

## Geometry validation added

The previous selected-D IFC validator checked IFC parse/schema, room IDs, areas, storeys/levels, source fingerprints and intentionally empty construction categories. Area equality alone could not detect a space whose footprint had moved while retaining its area.

The validator now independently decodes every `IfcSpace` body and compares its world-coordinate XY bounds, converted from IfcOpenShell's SI-metre vertices to feet, with the corresponding room rectangle in the checked-in source. It applies the source's documented main/upper/lower plan-frame offsets and a **0.02 ft numeric export tolerance**. It records per-space expected and observed bounds and records the exporter identity from the IFC header. This checks only 2D room footprints; it does not verify room heights, walls, doors, stairs, services, site coordinates, or building coordination.

The IFC body-profile gate now also requires each source room to have exactly one `Body` swept-solid representation containing one rectangular extrusion whose profile area matches that room's source rectangle within **0.1 sf**. This is checked independently of `Dimensions.Area`, which could otherwise report a plausible quantity while the body profile differs. This profile-area check does not validate extrusion height or other vertical geometry.

Autodesk's Revit 2027 [IFC Export Setup Options](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-DocumentPresent/files/GUID-E029E3AD-1639-4446-A935-C9796BC34C95.htm) describe IFC2x3's default as Revit-calculated room geometry; the optional “Use 2D room boundaries for room volume” setting uses simplified extruded boundaries. The inspected IFC's actual body is therefore checked from its serialized geometry rather than inferred from an export setting that this run's manifest does not record. Autodesk's [Revit 2027 IFC API guide](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Advanced_Topics/Export/Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Export_IFC_Export_html.html) documents API export options and exporter extension behavior. The official [Revit API SDK/tools page](https://aps.autodesk.com/developer/overview/revit-api) currently lists SDKs and API samples through Revit 2027.3.

### Evidence

- Added unit coverage for source-frame offsets, metre-to-foot conversion, and rejection of a compound room Body profile.
- The first exploratory recheck exposed a double unit conversion in the new checker, producing 21 false mismatches in `.local/revalidation/selected-d-ifc-coordinate-20261028T024106625/ifc-validation-coordinate.json`. The checker was corrected to use IfcOpenShell's documented SI-metre geometry vertices directly; the initial diagnostic report is preserved and superseded by the passing report below. This was a validator defect, not a changed IFC or model.
- On an isolated copy of Revit run `20261028T021345099Z`, replaced only the copied named RVT with the byte-identical `.0001.rvt` backup whose SHA matches the run manifest. The enhanced selected-D IFC validator passes **24/24** checks, including all 21 IFC room XY footprints, source areas/IDs/levels, three storeys, IFC2X3 schema, export hash, exact copied-RVT lineage, and empty physical-construction categories. Maximum absolute difference among all checked XY bounds is approximately `7.2e-15 ft` (floating-point serialization noise). Machine report: `.local/revalidation/selected-d-ifc-coordinate-20261028T024129523/ifc-validation-coordinate.json`.
- After adding the independent Body-profile-area gate, the same IFC and exact backup pass **25/25** in disposable copy `.local/revalidation/ifc-body-profile-20261028T025642/exact-backup-rvt/validation.json`; the original named-RVT copy fails only the expected stale fingerprint (**24/25**). All 21 profile areas match the source. The IFC hash remains unchanged.
- The preserved IFC itself is unchanged (SHA256 `05a529999c08bde5695af87ec6e62e9cab86a8686a85d04d739e163861dac849`). The currently named RVT in the original run remains a different hash from its manifest, so the original run must still fail exact lineage until a fresh Revit export is generated from a verified saved model.

## Interpretation and next action

This independent geometry gate materially strengthens the room-space export check and remains applicable regardless of whether Revit uses its built-in exporter or the separately packaged open-source extension. On the next available host run, regenerate the isolated D study from the current named source, record the IFC header's exact exporter version, then rerun this validator against that exact saved RVT. A passing result validates only this room-boundary study and its exported footprints; it is not a coordinated architectural model or professional approval.

## Sources

- [Autodesk Support: identify the IFC exporter version](https://help.autodesk.com/view/RVT/2026/ENU/?caas=caas%2Fsfdcarticles%2Fsfdcarticles%2FHow-to-view-the-IFC-exporter-version-in-Revit.html)
- [Autodesk Revit IFC exporter releases](https://github.com/Autodesk/revit-ifc/releases) — Revit 2027 package 27.3.0.12 release notes, including room-geometry placement fixes.
- [Autodesk Revit 2027 IFC export documentation](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-DocumentPresent/files/GUID-6EB68CEC-6C17-4B16-A509-30537F666C1F.htm)
- [Autodesk Revit 2027 IFC Export Setup Options](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-DocumentPresent/files/GUID-E029E3AD-1639-4446-A935-C9796BC34C95.htm)
- [Autodesk Revit 2027 IFC API guide](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Advanced_Topics/Export/Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Export_IFC_Export_html.html)
- [Autodesk Revit API SDK and tools](https://aps.autodesk.com/developer/overview/revit-api)
- [Autodesk Revit 2027 IFC parameter mapping](https://help.autodesk.com/view/rvt/2027/enu//?guid=GUID-C057D715-1571-4D11-8F02-417F3B385577)

## Reproducible export-setup recheck (2026-10-29)

- Autodesk's Revit 2026 IFC instructions state that custom named export setups created or duplicated in the IFC dialog are saved with the project, while changes to `<In-Session Setup>` are not saved between sessions. Reproducible future exports should therefore record and use a named setup in a disposable RVT derivative, rather than relying on transient dialog state.
- Autodesk support's 2026-05-19 compatibility note says Revit 2025, 2026 and 2027 can select Exchange Requirements for the certified IFC4 Reference View after the latest Revit updates and latest IFC add-in are installed. Autodesk lists Architectural, Structural and MEP Reference Exchange; this availability does not establish that this workstation has the required update/add-in or that IFC4 is the project's required exchange format.
- The preserved selected-D export and current validator use IFC2X3. No IFC setup, add-in, Revit installation, source RVT, or export was changed. IFC4 is an optional future side-by-side compatibility test only; it does not replace the validated IFC2X3 baseline without an explicit project requirement and fresh exact-lineage validation.

Sources for this recheck:

- Autodesk [Customize the IFC Setup](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-DocumentPresent/files/GUID-587E3CB5-CA76-4F06-B8E6-08F0C71945F6.htm)
- Autodesk [Export a Model to IFC](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-DocumentPresent/files/GUID-14037C31-EBAD-41A8-9099-E6DD65BB626E.htm)
- Autodesk support [IFC Model View Definition compatibility for Revit](https://help.autodesk.com/view/RVT/2025/ENU/?caas=caas%2Fsfdcarticles%2Fsfdcarticles%2FCompatibility-and-availability-of-IFC-with-the-Revit-Model-View-Definition-MVD-for-MEP.html)
