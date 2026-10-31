# M176 — Audit the compact social-route test scope

Status: complete source-bound audit; no plan or room is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m176_social_route_target_scope.ps1
```

The audit reads the M172 compact program-target report, M173 route report and check file, the bath-first comparison, and selected-D. It verifies each upstream source fingerprint and writes `m176-social-route-target-scope.json`, `m176-checks.json`, and `m176-area-comparison.csv`. To compare runs without touching the retained output:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m176_social_route_target_scope.ps1 -OutputDirectory .local/revalidation/M176-scope-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m176_social_route_target_scope.ps1 -OutputDirectory .local/revalidation/M176-scope-b
```

## Finding

M173's 29/29 route pass uses the unapproved bath-first alternative's M-02 block at 17 ft 4 in x 16 ft (277.33 sf) and M-03 at 11 ft 4 in x 14 ft (158.67 sf). The owner-directed program targets are 14 x 12 ft / 168 sf and 11 x 10 ft / 110 sf. Thus the tested blocks exceed those targets by 109.33 sf (65.08%) and 48.67 sf (44.24%); combined, they exceed 278 sf by 158 sf (56.83%). The route result is valid for its source geometry, but it is not evidence of fit at the compact target areas.

The retained audit and two isolated replays each pass 13/13 checks and produce byte-identical JSON, checks, and CSV. SHA256: report `B4378F8C7B0C07B9AB3273794A22E33F80B024EDE14044EE1E342CE55DF1BD63`; checks `DCD17B6AAE7B72DA55459EE11BC60B653D65B6FD8542C3AA5660C1A855799A2D`; CSV `FE946323FD49AFA998D9FC126363327B6FF85791C5D26870B2D79A62B8B23FED`.

## Limits and next design gate

This is a source-scope and area-arithmetic audit, not an integrated compact-plan test. M173 checks living-to-porch travel in the larger candidate and does not verify an island-work-face route. The next study must bind the 168 sf and 110 sf program areas, distinguish area zones from fixed rectangles, and test the documented island, perimeter modules, dining furniture, half-wall/opening, porch reservation, and a connected route. Any overlap between conceptual kitchen and dining zones must be reported explicitly. Keep selected-D unchanged and M-06/B unassigned. No code, accessibility, structural-safety, certification, permit, or construction-readiness conclusion follows.
