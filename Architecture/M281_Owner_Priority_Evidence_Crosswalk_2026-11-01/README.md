# M281 — Reconcile the owner-priority kitchen studies

**Status:** reproducible evidence crosswalk; no plan or kitchen dimension selected.

## Finding

M213 remains the closest existing full-shell study to the owner's stated priorities: smallest-area search, 8 × 4 ft island, fully open kitchen/living preference, movable dining/porch test blocks, protected A, and unassigned B. Its 13.5 × 13.25 ft / 178.875 sf sample has a 33.5 ft, four-turn route and a 3 in gap to the original A boundary, but the route touches another expanded modeled obstacle (0 in minimum gap) and is explicitly marked fragile. It is one quarter-foot-grid sample, not a global minimum or a fit-ready layout.

M279 answers a different question: four compact 6/7 × 3 ft island orientations against a fixed-block overlay and inherited route. Two cases clear those bounded screens, but neither implements the owner's 8 × 4 ft island priority. Its routes and gaps must not be compared as though they were M213's full-shell search. Both studies use a 5 × 6 ft pantry proxy, while Selected-D source records 5 × 7 ft; that discrepancy remains open.

## Reproduction

Build and generate the source-bound M279 report, then run M281 into two clean directories:

```powershell
.local/dotnet/dotnet.exe build Tools/M279Generator/M279Generator.csproj --configuration Release --output .local/revalidation/m279-build --ignore-failed-sources
.local/dotnet/dotnet.exe .local/revalidation/m279-build/M279Generator.dll Architecture/M193_Compact_Island_Fit_2026-10-31/artifacts-v2/m193-compact-island-fit.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Architecture/M279_Integrated_Kitchen_Porch_Orientation_Study_2026-11-01/m186-fixed-obstacle-snapshot.json .local/revalidation/m281-m279-input
.local/dotnet/dotnet.exe build Tools/M281Generator/M281Generator.csproj --configuration Release --output .local/revalidation/m281-build --ignore-failed-sources
.local/dotnet/dotnet.exe .local/revalidation/m281-build/M281Generator.dll Architecture/M213_Kitchen_Margin_Sensitivity_2026-10-31/artifacts-v2/m213-kitchen-margin-sensitivity.json .local/revalidation/m281-m279-input/m279-report.json Architecture/M279_Integrated_Kitchen_Porch_Orientation_Study_2026-11-01/m186-fixed-obstacle-snapshot.json .local/revalidation/m281-a
.local/dotnet/dotnet.exe .local/revalidation/m281-build/M281Generator.dll Architecture/M213_Kitchen_Margin_Sensitivity_2026-10-31/artifacts-v2/m213-kitchen-margin-sensitivity.json .local/revalidation/m281-m279-input/m279-report.json Architecture/M279_Integrated_Kitchen_Porch_Orientation_Study_2026-11-01/m186-fixed-obstacle-snapshot.json .local/revalidation/m281-b
```

The M279 report and selected-D/snapshot inputs are SHA256-pinned; M281 refuses changed source evidence and outputs outside the repository. The repository-local .NET 10.0.403 build has 0 warnings/errors. Two M281 runs pass 15/15 and match the retained JSON/checks byte-for-byte.

| Artifact | SHA256 |
|---|---|
| `m281-layout-crosswalk.json` | `8499AE39E0785FC838C5E88BD3DAA344604277F530D8CDB53308EA3B402C56E8` |
| `m281-checks.json` | `CE71B9310FA69DEE8744C482EEA2196C07834C1B10BDAE8D9A1BA42D9A74C6BA` |

## Limits and next gate

M281 reconciles reports; it does not recompute either route. The owner has now authorized a separate M-05 move/reshape study, preserving entry/mudroom function. M-05 remains fixed in both source screens; its move alternatives are recorded in M282. The M-04 pantry size conflict, exact kitchen/living opening, appliances, finishes, physical routes, site fit, and construction assemblies remain unresolved. M-06/A/B assignment remains open. No code, accessibility, structural, professional, permit, or construction-readiness conclusion follows.
