# Architectural BIM pipeline requirements

Updated: 2026-10-27  
Status: working acceptance baseline mapped from approved project direction and the proposed Compact-Core C test. C remains a study, not a selected house plan.

This file makes the existing project requirements executable. It does not approve the C geometry, add dimensions, or claim structural/code compliance. When an accepted design decision changes, update its source decision first, then revise the applicable requirement and validation evidence.

## Sources of authority

- [Professional design discipline](Project/Professional_Design_Discipline_And_Digital_Deliverable.md)
- [Code and merge gate](Project/Code_Compliance_And_Merge_Gate.md)
- [Coordinated room program](Requirements/Room_Program.md)
- [Compact-Core C implementation brief](Project/Revit_Compact_Core_Brief_2026-10-25.md)
- [Compact-Core execution checklist](Project/Compact_Core_C_Execution_Checklist_2026-10-26.md)
- [RevitPilot instructions](Tools/RevitPilot/README.md)

## Requirements

| ID | Requirement | Acceptance evidence | Boundary |
|---|---|---|---|
| BIM-01 | Revit 2027 is the authoritative authoring environment; generation creates a distinct, reopenable native RVT and preserves timestamped prior runs. | Revit host run record, RVT in a unique `.local/revit-pilot/compact-core/<run>/` directory, manifest and warning report. | C is a proposed study; never overwrite the fixture or claim a selected house plan. |
| BIM-02 | The C study uses the documented level targets: `C Lower -5 ft`, `C Main 0 ft`, `C Upper +5 ft`. | Native audit and independent IFC storey inventory, including elevations. | Proposed study datums; no site/grade relationship is established. |
| BIM-03 | The C study includes exactly the 17 stable room IDs in `Tools/RevitPilot/compact-study-config.json`; each is a native enclosed Revit Room with positive area and retains its ID through IFC2X3 and CSV export. | Manifest validator, native audit/Geometry QA, CSV comparison, IFC `IfcSpace` Number/Comments property check. | Study program only. Room area is not an approved construction dimension or bedroom/code qualification. |
| BIM-04 | The study checks the documented 40 x 40 ft main shell, 36 x 32 ft rear wings and 8 x 8 ft lift reservation, with three native floor markers and their documented target profile areas (2,752 / 1,410 / 1,152 sq ft). | Config/manifest validators, native floor inventory, IFC slab and geometry inventory. | Shell and lift figures are test targets. Floor type is still the template 1 ft `Floor 1`; it is not an assembly selection. |
| BIM-05 | The current generator regression inventory remains traceable: 78 walls, 2 native stairs, 5 nominal doors, and 3 floors. | Read-only Revit audit/Geometry QA and IFC class counts. A deliberate, approved geometry edit may update these baseline counts with evidence. | Counts characterize this generator version; they are not architectural design requirements. Doors are nominal instances, not verified clear openings, swings, or egress. |
| BIM-06 | The export workflow produces IFC2X3 CV2.0 and records export status and file hashes; IFC validation checks schema, expected levels, stable spaces, required major product classes, and decodable physical geometry. | Revit export result plus independent IfcOpenShell validator report linked into the review packet. | The existing single `IfcAnnotation` decode exception is reported separately; it does not excuse geometry failures for physical products. |
| BIM-07 | Every automated PASS is specific to the check performed; known open coordination items remain visible. | Review packet and `PROGRESS.md` list the stair/upper-floor gap, floor/opening/support, accessibility, MEP, code, DWG/PDF visual review and Revit 2018 import limits. | No claim of architectural/engineering certification, construction readiness, permit approval, or code compliance. |
| BIM-08 | Compare IFC room areas against every documented room-program allowance and proposed C target; report variances without silently changing geometry or treating preliminary values as approved dimensions. | `validate_compact_ifc.py` reports the source range/target and observed IFC area for each documented room; out-of-reference results remain open coordination findings. | The room program labels most areas preliminary; the C bath and main flex sizes are proposed test targets, and the main-bath owner decision remains open. |
| BIM-09 | The checked-in Compact-Core JSON is the authoritative source for generated architectural coordinates and study geometry parameters, so operators do not maintain a second copy in C# source. | RevitPilot reads the config at run time, preserves an adjacent input snapshot, records its SHA256 in the manifest, and emits a separate timestamped RVT; offline preflight and manifest validation compare the snapshot to generated IDs and targets. | The configuration reproduces existing proposal values; it does not approve them. Any future coordinate change remains subject to project decisions and owner review. |

## IFC export baseline for this study

The latest end-to-end study run is recorded in `PROGRESS.md` and `Project/Revit_Compact_Core_Study_2026-10-26.md`. It parsed as `IFC2X3`, had zero IfcOpenShell schema-validation statements, contained 3 storeys at -5/0/+5 ft, 17 `IfcSpace`, 78 `IfcWall`, 3 `IfcSlab`, 2 `IfcStair`, 5 `IfcDoor`, and one `IfcAnnotation`. Geometry decoded for 120 of 121 represented products; the sole exception was an annotation generated from model lines. The independent validator also compares documented room area allowances and proposed C targets, reporting variances as open findings. These counts and targets are study baselines, not approved building design.

The 5.62 ft plan gap between the main-to-upper stair flight and upper slab is a known geometry failure and remains open under [CO-001](Project/Coordination_Register.md). Automated IFC validity does not close that issue.
