# Revit headless automation review — 2026-11-02

This is a bounded public-source review. No repository was cloned, no account was created, no credentials were entered, and no software was installed.

## Findings

### Autodesk Platform Services Design Automation for Revit

Autodesk's supported headless route is APS Design Automation for Revit. Autodesk describes it as the Revit engine running in the cloud, with access to the Revit DB API for creating, modifying, extracting and documenting RVT/RTE/RFA files. Autodesk also states that a standalone `RevitCoreConsole.exe` is not shipped with current Revit; the supported unattended route is APS rather than a local console executable.

Relevant references:

- https://aps.autodesk.com/automation-apis
- https://aps.autodesk.com/apis-and-services/revit-automation-api
- https://github.com/autodesk-platform-services/aps-design-automation-dotnet
- https://github.com/autodesk-platform-services/revit-cursor-plugin-debug

This is genuine headless execution, but it requires APS application credentials, cloud file transfer and a suitable Autodesk service/account arrangement. It is therefore a future option, not an unattended local change to this project.

### RevitBatchProcessor

`bvn-architecture/RevitBatchProcessor` is useful for batch opening files and running scripts, and its public README lists Revit 2027 support. It is not a true headless Revit engine: its own documentation notes that Dynamo task execution opens the document in the Revit UI and remains subject to Revit API limitations.

Reference: https://github.com/bvn-architecture/RevitBatchProcessor

It could improve repeatable local batch validation, but it would not remove the need for a desktop Revit process or eliminate modal-dialog risk.

### Local MCP bridges

Several public projects expose the Revit API through a localhost bridge:

- `rui-branco/revit-mcp`: C# bridge add-in plus MCP server; requires a running Revit session and restart after installing the bridge. It documents unattended dialog handling, but remains in-process desktop Revit and is unsigned.
- `Sam-AEC/aec-model-bridge`: local Revit 2024–2027 bridge with approval plans and a mock mode. The mock mode is headless but does not touch a real model; live edits still require Revit and the add-in.
- `bimwright/rvt-mcp` / `LuDattilo/RevitCortex`: local MCP/server-plus-add-in designs that marshal work into Revit's main thread. They are useful interaction patterns, not standalone headless engines.
- `danlion333/revit_mcp`: pyRevit bridge for a running Revit session; it explicitly requires a restart to load the extension.

These may improve live-session ergonomics, but they introduce another unsigned add-in, another trust surface and another local listener. None should be installed here without a separate security review and explicit authorization.

## Compatibility conclusion for Forever Home

The current project-local RevitPilot pattern is already the safest local approach for this repository: deterministic C# commands, disposable derivative RVTs, explicit manifests, IFC exports and independent validators. The next useful architectural improvement is to split geometry logic into a UI-neutral core that can be called by both the existing desktop `IExternalCommand` and a future APS Design Automation AppBundle.

That refactor can be done without installing a bridge or changing Revit trust settings. It would let us continue local validation now and preserve a credible path to true unattended cloud execution later.

## Constraints and trade-offs

- APS is the only source reviewed that is genuinely headless and Autodesk-supported for Revit, but it requires cloud credentials and introduces service/account/cost considerations.
- Local bridges still depend on Revit's single-threaded in-process API and can be stranded by modal dialogs.
- `RevitCoreConsole.exe` should not be treated as an available local Revit 2027 executable.
- No reviewed project removes the need for design decisions, product evidence, code interpretation or professional review.
