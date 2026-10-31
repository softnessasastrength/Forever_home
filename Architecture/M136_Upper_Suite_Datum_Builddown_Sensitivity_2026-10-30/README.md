# M136 - Upper-suite datum/build-down sensitivity

Status: source-bound geometric relationships only. The hypothetical 38 1/3 x 40 ft shell remains unchanged. No eave/floor datum, ceiling build-down, roof assembly, room classification, roof option, or compliance result is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m136_upper_suite_datum_builddown_sensitivity.ps1
```

The script binds M78 search geometry and manifest, M83 roof options, M103 thresholds, the Connecticut research note, room program, and selected-D source. It writes JSON provenance/checks and a 12-row CSV for U-01 through U-04 across three comparison cases: 12:12/ridge X, 12:12/ridge Y, and 10:12/ridge X. Output paths outside the repository are refused.

Two independent PowerShell 5.1 runs to ignored scratch paths pass **8/8 checks** and produce byte-identical JSON and CSV. JSON SHA256: `6893DB2355A2FA2BA0E21F95FCBE589D5C5BDEC2D5E1680311C81E7F04663772`; CSV SHA256: `7827D4E2EA7274960806D124DD4CC9F681564DAE53EF8723D53D9B099C2992E7`.

## Method and reading the results

M103 supplies each room/case's minimum and median rise above an ideal, zero-thickness roof plane's relative eave. M136 carries forward its generic 5 ft full-modeled-block and 7 ft half-modeled-block thresholds as conditional arithmetic. For effective finished-ceiling height at the eave:

```text
H_eff = (z_eave - z_finished_floor) - b_eave
```

Here `z_eave`, `z_finished_floor`, and scalar eave build-down `b_eave` remain unknown. For a given M103 threshold `T`, the equivalent relation is:

```text
z_eave - z_finished_floor >= T + b_eave
```

The most demanding combined geometric threshold among the candidate blocks is -3.166667 ft for 12:12/ridge X (U-03), -1.805556 ft for 10:12/ridge X (U-03), and 5 ft for 12:12/ridge Y (U-01/U-04). These are relative algebraic thresholds only. Negative numbers do not select a below-floor eave or demonstrate a viable section. Without actual datum/build-down values, the inequalities are not evaluated and none of the cases passes or fails.

The most useful next section inputs are the measured or owner-selected finished-floor-to-geometric-eave elevation difference and the roof/eave-to-finished-ceiling build-up. If the ceiling build-down varies spatially, a scalar `b_eave` is inadequate; a defined finished ceiling surface is needed before calculating room-area fractions.

## Limitations

- Connecticut's 2022 CSBC amended 2021 IRC R305.1 is only a preliminary research basis; municipality, permit code cycle, classification and applicability remain unresolved. The official source and local caveats are recorded in `Research/Connecticut_Roof_Code_Research_2026-10-28.md`.
- The entire schematic M78 room rectangle is a proxy for code-defined required floor area. This is not established to be the applicable legal area.
- U-02 is geometry-only because its classification is unresolved. Bathrooms, fixture-use heights and showerhead zones are excluded pending exact geometry and locations.
- Roof faces omit framing, thickness, finished ceiling, wall/eave offsets, dormers and structure. 38 1/3 x 40 ft is an exploration envelope only.
- No selected-D geometry, Revit model, IFC export, source family, or M-06 assignment is changed. M-06/B remains unassigned pending physical fixture geometry, applicable clearance basis, door/approach and plausible service routing.

This study makes no code-compliance, structural-safety, professional-certification, permit-approval, or construction-readiness claim.
