# Revit Python tooling assessment

Updated: 2026-10-27
Scope: pyRevit, its optional agent runtime, and Python.NET for the Revit 2027 BIM workflow.

## Findings

| Tool | What it adds | Revit 2027 fit | Assessment for Forever Home |
|---|---|---|---|
| pyRevit 7.0 | A Revit add-in host for Python, C# and VB.NET commands; extensions and an interactive shell. | The project site lists Revit 2021–2027 support. The project development instructions specify .NET 10 for Revit 2027. Python engines include IronPython 2.7.12, IronPython 3.4.2 and CPython 3.12.3, with availability dependent on installation/configuration. | Best candidate for future interactive Revit commands. It can package a small owner-specific extension without replacing the existing RevitPilot build pipeline. No local pyRevit installation was found in the usual per-user locations checked on this machine. |
| pyRevit agent runtime (MCP) | Lets an MCP client inspect and run Python against a live Revit document; includes query, modify, context, selection and view-capture tools. The documented default `ask` policy presents edits in Revit for Keep/Discard and records approved edits as one undo item. | pyRevit 7.0 release notes include the agent host, but the agent-runtime documentation labels it experimental/off by default and says its in-Revit host validation was on Revit 2024/2025 while CLI/MCP work was in progress. The official pages therefore do not establish reliable Revit 2027 support for the agent runtime specifically. | Promising way to improve live-model inspection and command execution, but test it only on a sanitized disposable model after verifying the exact installed build. Keep policy at `ask`; do not use `auto`. |
| Python.NET (`pythonnet`) | Embeds CPython in .NET so Python can use CLR types and native CPython packages. It is a bridge, not a Python-to-IL compiler or Revit add-in framework. | Its documentation describes .NET/Mono CLR integration and CPython support; it does not provide Revit-specific document lifecycle, main-thread dispatch, transaction safety, ribbon registration or add-in deployment. Python object access requires correct GIL/thread-state handling. | Do not embed it directly into RevitPilot for this milestone. It adds another interpreter, runtime packaging and threading boundary where the current .NET 10 C# add-in already has a working Revit API path. Revisit only if an essential CPython-only library must run inside Revit. |

## Data and security considerations

The pyRevit agent-runtime documentation says model data read by an agent is sent to that agent's model provider. It also records scripts, requests, responses, large results and captured images as plaintext under `%APPDATA%\pyRevit\agent` for up to 14 days. That is material for an owner-specific home model. Do not enable the runtime against the actual home model until the owner has reviewed that data flow and the local run-record handling.

The older `revit-mcp-python` Routes-based extension is not the preferred route: its own repository describes the Routes API as draft and says it has no built-in authentication. pyRevit's bundled agent runtime is architecturally preferable, but its Revit 2027 readiness remains unverified in the official material reviewed here.

## Recommended tooling split

1. Keep dimensioned schematic source, deterministic generation and geometry checks in the existing PowerShell/JSON pipeline.
2. Keep the Revit 2027 authoring adapter in the existing C#/.NET 10 RevitPilot for now; it already builds against the installed API and keeps geometry generation explicit.
3. Use Python where it is the practical boundary: independent IFC parsing with the existing IfcOpenShell environment. Do not use Python to fit or silently resize architectural blocks.
4. If pyRevit is adopted, start with a per-user install and a sanitized copy of a disposable Revit fixture. Test read-only inspection, screenshots, one separate-document generation run and an undo/Discard path before connecting it to a real project. Confirm pyRevit agent-runtime Revit 2027 support and review the provider/logging flow first.

No installer, extension, CLI registration or MCP server was installed or enabled during this assessment.

## Autodesk API confirmation — 2026-10-28

Autodesk's Revit 2027 developer guide and API references reinforce the existing split rather than making an embedded Python runtime more attractive:

- Revit API add-ins run in-process as DLLs, and API calls are single-threaded on Revit's main thread. The documented `ExternalEvent` pattern is the supported bridge for work initiated outside the normal command callback; arbitrary Python background threads are not an alternative Revit execution context.
- `TransactionMode.ReadOnly` prohibits transactions and document changes. A `Manual` command must manage its transaction lifecycle. The Autodesk Revit API 26.4 reference states `Document.Regenerate()` normally requires an open transaction, commit already triggers regeneration, and a regeneration failure puts the document into a failure state that callers must abort/clean up rather than suppress.
- A work-plane-based family is hosted by the active work plane. Its local axes cannot be treated as project-world height/projection until a disposable hosted-instance test confirms the orientation.
- Autodesk's APS Revit API page currently lists the Revit 2027.3 SDK. This is reference material only; no SDK, pyRevit package or extension was downloaded or installed for this note.

These points match RevitPilot's current architecture: deterministic source and envelope checks remain in PowerShell/JSON; Revit document access and transactions stay in the C#/.NET add-in; Python remains outside Revit for independent IFC inspection. The past intake failure caused by calling `Document.Regenerate()` outside a transaction was repaired and host-verified in run `20261028T015956023Z`; the official transaction guidance supports that repair. It does **not** validate family hosting or a placed fit. The Evolution sink's work-plane axes still require an isolated placed-instance check before interpreting them as installation dimensions.

## Sources reviewed

- [pyRevit 7.0 release notes](https://github.com/pyrevitlabs/pyRevit/releases): Revit support, agent-runtime feature list, guarded runs and default in-Revit approval policy.
- [pyRevit compatibility and project instructions](https://github.com/pyrevitlabs/pyRevit/blob/develop/AGENTS.md): Revit 2027/.NET 10 target and available Python engines.
- [pyRevit agent-runtime documentation](https://docs.pyrevitlabs.io/agent-runtime/): experimental status, setup, policy, data flow, run records, API contract and stated validation versions.
- [pyRevit CPython command guide](https://pyrevitlabs.notion.site/Create-Your-First-CPython-Command-b8a7718c554645d1a18454c0b363e3c9): CPython engine and native-package purpose.
- [Python.NET documentation](https://pythonnet.github.io/pythonnet/): CLR/CPython integration scope and GIL/threading requirements.
- [revit-mcp-python repository](https://github.com/mcp-servers-for-revit/mcp-server-for-revit-python): Routes-based MCP implementation and its stated authentication limitation.
- [Autodesk Revit 2027 deployment options](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Introduction/Getting_Started/Using_the_Autodesk_Revit_API/Revit_API_Revit_API_Developers_Guide_Introduction_Getting_Started_Using_the_Autodesk_Revit_API_Deployment_Options_html.html): in-process DLL and single-thread API execution model.
- [Autodesk Revit 2027 transaction attributes](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Introduction/Add_In_Integration/Revit_API_Revit_API_Developers_Guide_Introduction_Add_In_Integration_Attributes_html.html): `Manual` and `ReadOnly` command behavior.
- [Autodesk `ExternalEvent`](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/05089477-4612-35b2-81a2-89c4f44370ea.htm): Revit-queued callback mechanism for supported work initiated outside an active API callback.
- [Autodesk `Document.Regenerate`](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/22468e2c-9772-8478-0816-c9759aa43428.htm): transaction requirement and regeneration-failure handling.
- [Autodesk work-plane-based families](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-Customize/files/GUID-70F24230-D596-4AA3-A425-91B1E560BC53.htm): host-plane behavior and `Always Vertical` distinction.
- [Autodesk Revit API SDK page](https://aps.autodesk.com/developer/overview/revit-api): current Revit 2027.3 SDK listing.

## Revit 2027 IFC export reference (2026-10-28)

The existing C# export command uses Revit `Document.Export` with `IFCExportOptions` and requests IFC2x3 Coordination View 2.0; independent project validators parse and inspect the resulting IFC. Autodesk's Revit 2027 API export guide describes document export and registered custom exporters. Autodesk's 2027 IFC setup documentation describes phase, space-boundary level, visibility, property mapping, base quantities, and related export options. Keep the current IFC2x3 compatibility target unless a documented receiving-workflow requirement motivates a deliberate change. Parameter/property-set mapping is available for configuring output but does not by itself prove a correct semantic mapping. Revit's own successful export call is not the independent validation gate.

Sources: [Autodesk Revit API export guide](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-API/files/Revit_API_Developers_Guide/Advanced_Topics/Revit_API_Revit_API_Developers_Guide_Advanced_Topics_Export_html.html); [Autodesk IFC export setup options](https://help.autodesk.com/cloudhelp/2027/ENU/Revit-DocumentPresent/files/GUID-E029E3AD-1639-4446-A935-C9796BC34C95.htm); [Autodesk IFC parameter mapping](https://help.autodesk.com/cloudhelp/2027/ENU/RevitLT-DocumentPresent/files/GUID-0968B3FF-832B-4155-8B36-E848ACC97B95.htm).

Observed project correction: `.local/revit-pilot/family-intake/20261028T060040906Z/` failed its disposable Evolution host probe because the command explicitly regenerated after committing. The fixed command now relies on commit's regeneration and the output gate requires a successful pinned-source host result. Autodesk API reference: [Document.Regenerate](https://help.autodesk.com/cloudhelp/2026/ENU/Revit-API-MainReference/files/html/22468e2c-9772-8478-0816-c9759aa43428.htm). Corrected host execution remains pending; build success alone is not host verification.
