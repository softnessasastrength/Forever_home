# Revit API tooling roadmap

Date: 2026-10-26  
Status: read-only inventory and geometry-QA bridges implemented and host-verified

## Goal

Move repeatable inspection, inventory and evidence capture into the Revit API so computer use is reserved for actions that genuinely require visual judgment, owner interaction or host-only review.

## Implemented in this increment

The RevitPilot add-in now exposes **Audit active document**. It runs as a read-only external command against the active document and writes a timestamped audit package under `.local/revit-pilot/audits/`:

The final end-to-end host verification completed in Revit 2027 on the generated compact-core study. Audit package: `.local/revit-pilot/audits/20261026T205556399Z/`. It recorded 17 enclosed rooms, 78 walls, 5 openings and 0 warnings; the command did not modify or save the active document. The preceding study package `.local/revit-pilot/compact-core/20261026T205526500Z/` also contains an empty `study-warnings.json`, confirming the stair warning correction in the host.

- `audit.json`: Revit version/build, document title, levels, category counts, rooms, walls, openings and warnings;
- `rooms.csv`: room identity, area and level schedule;
- `openings.csv`: door/window identity, family/type, host and marker;
- `README.txt`: scope and limitations.

The command does not save, modify, export or close the active model. It intentionally does not write the document path, credentials or private project identifiers beyond native element IDs needed for traceability.

The add-in now also exposes **Run geometry QA**. It writes `.local/revit-pilot/geometry-qa/<timestamp>/geometry-qa.json` and checks native room enclosure, duplicate wall centerlines, stair elevation/riser presence, door hosts, required compact-core markers and native warnings. Final host verification on `.local/revit-pilot/geometry-qa/20261026T210524751Z/` returned 0 issues across 17 rooms, 78 walls, 2 stairs, 5 doors and 0 warnings. The report is a read-only heuristic review, not a code or engineering approval.

An offline `compile_review_packet.py` tool now gathers the latest study warnings, API audit, Geometry QA and compact-core manifest validation into `review-packet.json` and a human-readable `review-packet.html`. The final compiled packet passed all four checks and was written under `.local/revit-pilot/review-packets/20261026T222002582410Z/`. This makes the evidence handoff repeatable without another Revit session.

## Acceptance test

1. Build with the installed Revit 2027 API.
2. Install the generated per-user add-in manifest.
3. Open a disposable test project or the separate Compact-Core study.
4. Run **Audit active document**.
5. Confirm the audit directory contains all four files and that the JSON counts match the visible test model.
6. Confirm the active document remains open and unchanged.
7. Compare room/opening rows against native schedules and record any discrepancies.

Host execution is required before claiming this tool works. Compilation alone is not evidence of API behavior.

## Next API increments

1. **Manifest-driven export command implemented and host-executed.** `Tools/RevitPilot/export-manifest.json` configures IFC2x3, DWG plan views, a combined PDF, and a direct native Room inventory CSV. The initial Revit 2027 run at `.local/revit-pilot/exports/20261027T005253025Z/` produced IFC2x3, three plan DWGs and a combined PDF; native schedule CSV failed because `C Room Area Schedule` has no columns or data. The revised command was host-run at `.local/revit-pilot/exports/20261027T011547441Z/`; all four exports reported success, and the CSV contains 17 unique room rows with nonblank areas. IfcOpenShell inspection found valid IFC2X3, zero validation issues, 17 IfcSpaces across three C levels, and decoded geometry for 120/121 represented products; the one exception is model-line IfcAnnotation `Model Lines:3924`. DWGs are nonempty with AC1024 headers, but binary content was not independently inspected. The PDF header is valid; page rendering was unavailable, so visual review remains open. Revit 2018 import remains open.
2. Expand Geometry QA with solid-intersection checks, route-marker continuity, reserved-core dimensions and machine-readable issue screenshots.
3. Add a non-destructive schedule writer for stable program IDs and coordination-register evidence.
4. Add a controlled transaction command for applying only explicitly approved manifest changes, with preview and rollback behavior.
5. Keep computer use for visual QA, warnings that require judgment, licensing/security prompts, 2018 import review and owner approval.

## Floor inventory increment — 2026-10-26

The compact-core study now includes three native floor plates. A fresh Revit audit at `.local/revit-pilot/audits/20261026T223917252Z/` confirmed 3 levels, 3 Floors, 17 enclosed rooms, 78 walls, 5 openings and 0 warnings. A duplicate template datum was fixed by reusing the 0 ft level as `C Main 0 ft`; the corrected study is `.local/revit-pilot/compact-core/20261026T223829109Z/`.

Geometry QA has been extended to inventory every native Floor by stable comment marker, level/elevation, Revit-computed area, floor type and compound width; it flags missing IDs and nonpositive native areas. The review-packet compiler now reports level/floor totals and requires the expected three-floor inventory before marking inventory and geometry QA as passing. The increment compiled successfully against Revit 2027 with 0 errors and 2 existing reference warnings. **The floor-aware command was host-verified on 2026-10-27** against `FH_Compact_Core_Study`: `.local/revit-pilot/geometry-qa/20261027T004729569Z/geometry-qa.json` reports 17 enclosed rooms, 78 walls, 2 stairs, 5 doors, 3 floors, 0 native warnings, 0 issues and 0 errors. Floor inventory is 2,752 / 1,410 / 1,152 sq ft; each uses the template `Floor 1` type with 1 ft compound width. The offline packet at `.local/revit-pilot/review-packets/20261027T004753549365Z/` passes all four recorded checks. This remains inventory and heuristic evidence only; floor profile/opening fit, structural support, stair landing, foundation and roof coordination are open.

## Boundaries

The API bridge does not certify code compliance, accessibility, structural adequacy, MEP design, product fit, permit readiness or professional review. All model-changing commands must remain separate from read-only audits and require an explicit, reviewable input manifest.

## Manifest export increment — 2026-10-27

The new **Run manifest exports** ribbon command checks the exact active-document title, reads the checked-in export manifest, and writes each configured result independently under ignored `.local/revit-pilot/exports/<timestamp>/`. It records API result, generated file size and SHA256 for IFC2x3, DWG, PDF and CSV outputs. It does not save or modify the active model; IFC uses a transaction that is rolled back after export. The final host run created IFC2X3, three DWGs, a combined PDF and a 17-row native Room inventory CSV. The earlier empty native schedule export remains documented as the reason the CSV source was changed. IFC semantic/schema and geometry-decoding inspection is now recorded above. Independent DWG/PDF visual review and Revit 2018 import remain pending. The manifest is specific to the C study, not a general house export preset.
