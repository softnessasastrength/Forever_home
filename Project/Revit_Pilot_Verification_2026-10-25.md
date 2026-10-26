# Revit automation and export pilot — 2026-10-25

Status: executed in Revit 2027; partial compatibility milestone. **Revit 2018 import and independent DWG fidelity review remain pending.** No house geometry or design decision approved by this test.

## Scope and evidence

Built a C# Revit-hosted add-in and ran a separate fixture in Revit 2027.3, build `27.3.0.28`. Final run: `20261026T020031443Z` (October 25 local time). The earlier run `20261026T015459634Z` was retained; PDF review prompted a view-only correction before the final run. Source: [pilot implementation and reproduction instructions](../Tools/RevitPilot/README.md).

Nine tagged fixtures: four basic walls, one wall-hosted door, one wall-hosted window, one enclosed room, one mechanical-equipment envelope and one stair. Door/window/equipment families were generated from installed English-Imperial templates. Arbitrary test dimensions are not a proposed house layout. Native IDs and stable `FH-PILOT-*` IDs are recorded in JSON/CSV.

Generated binaries, exports and local paths remain under ignored `.local/revit-pilot/`. A small [final-run manifest](../Revit/Pilot_Evidence/20261026T020031443Z/manifest.json) and execution report are retained in Git; native RVT/RFA are not committed pending the project's binary-storage strategy. The manifest hashes outputs; it is not a substitute for retaining the local files.

## Checks actually performed

| Check | Result | Limits |
|---|---|---|
| C# compilation against installed 2027 API | Pass, zero errors | Two MSB3277 warnings: Microsoft.VisualBasic 10.0/10.1 and System.Drawing 4.0/10.0 dependency conflicts; host execution succeeded, broader API usage untested |
| In-Revit execution | Pass, two fixture runs | Existing house files were not edited; no house model created |
| Fixture IDs and CSV/JSON consistency | Pass, nine unique IDs | CSV is a model-derived fixture inventory, not full production room/door schedules |
| Door/window native hosting | Pass | Tested on one basic wall with simple template families |
| Native source and same-disk backup reopen | Pass, nine UniqueIds found in each | Identity/existence check; not full native geometry comparison or off-device disaster recovery |
| IFC export | Pass, IFC2x3 Coordination View 2.0 | Revit export call plus independent IfcOpenShell inspection |
| IFC schema validation | Pass, zero reported issues | Minimal fixture, not general exporter certification |
| IFC geometry parsing | Pass, all represented products parsed | Not a complete dimensional or visual equivalence audit |
| IFC categories | Four walls, door, window, space, stair/flight present | Equipment is exported as a generic proxy |
| IFC relationships | Two void and two fill relationships present | Relationship counts checked; complete hosted/parametric equivalence unproven |
| IFC stable metadata | All nine fixture IDs found | Explicit Revit internal property-set export enabled |
| IFC room-area property | 404.44444444444446 sf matches native inventory | Raw Revit property uses sf; IFC world geometry is decoded in metres |
| DWG export | Pass; AC1024 / AutoCAD 2010 header | Independent viewer and 2018 import not tested |
| PDF export and visual review | Pass, both pages rendered and inspected | Fixture plan and 3D view, not a dimensioned construction sheet set |
| Revit 2018 | Not tested | Owner confirmed working installation is on another computer |

PDF review used the bundled runtime's PDFium renderer. The first 3D export was overwhelmed by default level datums; the final implementation hides those datums and section-box graphics. Both final pages show legible, unclipped fixture geometry; the plan carries a clear test-only label. No PDF presentation-readiness claim applies to the house.

## Environment and preservation

- Installed API runtime configuration targets .NET 10. Downloaded the portable Microsoft SDK 10.0.100 and verified SHA512 against Microsoft's official release metadata before extracting under ignored `.local/dotnet/`; no system SDK installation or purchase.
- Registered a per-user `ForeverHome.Pilot.addin` pointing to the repository-local build. The add-in creates a ribbon button; moving the repository requires rebuilding its path marker/manifest. No Revit security settings were changed.
- Existing pinned Python environment supplies IfcOpenShell and NumPy. Independent validator records export status, property retention, geometry results and SHA256 artifact hashes.
- Revit displayed 30 trial days remaining. Exact account expiration remains unverified.
- IFC has three storeys because the default project level is retained alongside the two test levels. This is a fixture artifact, not a building-section decision.
- No spending, external upload, push or merge performed. No professional/code/design approval claimed.

## Remaining work and handoff

1. Use the local `FH_Compatibility_Pilot_2018_Review.zip` transfer package on the other computer; follow the [2018 checklist](../Tools/RevitPilot/2018_REVIEW.md). Record geometry, metadata, category and editability losses before closing CO-013.
2. Inspect the DWG in a compatible viewer / 2018 and compare measured geometry. Export success and format headers alone do not establish fidelity.
3. Select durable native-model storage and test off-device recovery before production modeling.
4. Begin the coordinated footprint/section alternatives and kitchen/accessibility studies from the room program. Reconcile older conflicting modeling instructions before using them.

The pilot demonstrates a working native automation path and portable export generation. It does not establish the entire 2027-to-2018 fallback path or justify freezing unresolved architectural geometry.
