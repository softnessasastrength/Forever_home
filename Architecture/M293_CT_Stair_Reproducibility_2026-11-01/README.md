# M293 — Joint lower stair replay and Connecticut screening basis

Date: 2026-11-01

Status: **analysis-only verification; owner preference for one M289 reference followed this replay, without selecting a physical stair, level, or route.**

## Owner direction and scope

The owner's latest direction is a joint same-area move/reshape of lower flex living `L-01` and lower arrival/circulation `C-LOWER`. That exact analysis-only study already exists as M289, authorized by `Decisions/2026-11-01_M289_Joint_Lower_Stair_Circulation_Authorization.md`. No second geometry model is warranted. This milestone replays M289 and its M290 residual partition against the current checkout, then replays the upstream M285 section/stair envelope.

M289 holds other lower room blocks and the 36 × 32 ft source shell fixed, preserves both source areas, and protects the two unassigned M-06 windows for the stair and C-LOWER screens. It tests the owner-derived 38-in / five 10½-in-tread / two 36-in-landing-depth proxy and the separate 36-in M215 path precedent. M289's candidates remain unselected; that study's route proxy is not a code or accessibility conclusion.

The owner subsequently preferred M289's least-layout-change option and accepted its schematic tangency for continued analysis. This follow-up preference is recorded in `Decisions/2026-11-01_M294_Lower_Stair_Analysis_Reference_Preference.md`. It does not convert M289's abstract rectangles into selected-D or native Revit geometry.

## Reproducibility defect found and fixed

The checkout's `core.autocrlf=true` materializes `Research/Connecticut_Stair_Code_Research_2026-10-30.md` with CRLF. M285's pin was captured from LF text, so raw-byte hashing made M285 fail on this checkout even though the source text was unchanged. `Tools/M285Generator/Program.cs` now normalizes Markdown line endings to LF and encodes UTF-8 without a BOM for the CT-note hash. JSON source bytes and the other historic file hash remain byte-based. No pinned research document or original output was edited.

The CT note's canonical-text hash remains `65250B9F68A8674B2BF361F99B76C35C63A97E85EC75304F1F4E77681CC26EE6`. The selected-D source remains pinned by the existing M285/M289 checks at `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`.

## Validation

All outputs were written under ignored `.local/revalidation/m293-*` folders; no tracked output or selected-D/RVT/IFC was overwritten.

- M285 .NET 10 Release build: **0 warnings, 0 errors**; two independent runs **17/17**; all four outputs match the retained artifacts byte-for-byte; both SVGs parse as XML.
- M289 .NET 10 Release build: **0 warnings, 0 errors**; two runs **15/15**; JSON, checks and SVG match retained artifacts byte-for-byte; SVG parses as XML.
- M290 .NET 10 Release build: **0 warnings, 0 errors**; two runs **9/9**; JSON, checks and SVG match retained artifacts byte-for-byte; SVG parses as XML.
- M290 still reports one abstract connected residual component for each reference: 78.4306 sq ft (minimum-change/tangent) and 74.3889 sq ft (greater-change/26.644-in measured separation). These are geometric residuals, not usable circulation findings.

The current M289 candidate counts and headline result are unchanged: 1,208 L-01 candidates, 2,912 C-LOWER candidates, 6,707 disjoint room pairs, 52,432 stair envelopes, 320 doglegs and two straight route proxies. The minimum-change dogleg remains tangent to L-01; the separate straight option preserves a 26.644-in measured gap. The owner now prefers the former as an analytical reference; no physical model geometry is selected.

## Connecticut stair screening

`Research/CT_Stair_Geometry_Checklist_2026-11-01.md` records the authoritative state-code source, its relevant published screening values, and what remains unmeasured. M285's 38-in preferred width and 10½-in treads are nominal design inputs, not measured Revit clear dimensions. Its 36-in landing values describe depth only; required landing width, headroom, finish geometry, door interference, guards, handrails, and transitions are not verified.

The selected-D source still places adjacent levels 60 in apart. The owner's separate six-riser × 7¼-in preference spans 43½ in, leaving a 16½-in mismatch against that source transition. Neither is changed or silently reconciled. Resolve the section and floor-opening arrangement before native stair modeling.

## Reproduction commands

Run in PowerShell from the repository root; all output directories must be new or empty.

```powershell
.local\dotnet\dotnet.exe build Tools/M285Generator/M285Generator.csproj --configuration Release --output .local/revalidation/m293-m285-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m293-m285-build/M285Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Decisions/2026-11-01_DD013_Vertical_Section_Study_Basis.md .local/revalidation/m293-m285-run1
.local\dotnet\dotnet.exe .local/revalidation/m293-m285-build/M285Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Decisions/2026-11-01_DD013_Vertical_Section_Study_Basis.md .local/revalidation/m293-m285-run2
.local\dotnet\dotnet.exe build Tools/M289Generator/M289Generator.csproj --configuration Release --output .local/revalidation/m293-m289-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m293-m289-build/M289Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M289_Joint_Lower_Stair_Circulation_Authorization.md .local/revalidation/m293-m289-run1
.local\dotnet\dotnet.exe .local/revalidation/m293-m289-build/M289Generator.dll Architecture/Selected_Design_Iteration_2026-10-27/study.json Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/artifacts/m285-vertical-section-screen.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Decisions/2026-11-01_M289_Joint_Lower_Stair_Circulation_Authorization.md .local/revalidation/m293-m289-run2
.local\dotnet\dotnet.exe build Tools/M290Generator/M290Generator.csproj --configuration Release --output .local/revalidation/m293-m290-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m293-m290-build/M290Generator.dll Architecture/M289_Joint_Lower_Stair_Circulation_Study_2026-11-01/artifacts/m289-joint-lower-stair-study.json .local/revalidation/m293-m290-run1
.local\dotnet\dotnet.exe .local/revalidation/m293-m290-build/M290Generator.dll Architecture/M289_Joint_Lower_Stair_Circulation_Study_2026-11-01/artifacts/m289-joint-lower-stair-study.json .local/revalidation/m293-m290-run2
```

For each pair, compare SHA256 by filename and parse generated SVG files as XML. M285/M289/M290 each refuse non-empty output directories.

## Limits

This milestone adds no Revit, IFC, wall, floor, stair, door, handrail, guard, or opening geometry. It does not establish a usable route, code compliance, accessibility, structure, professional approval, permit approval, or construction readiness. M-06/A/B remain unassigned and west A protected. Revit's M270 runtime remains blocked by the untargetable visible trial intro overlay; no UI bypass or trust/security change was made.
