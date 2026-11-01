# M296 — Integrate full-rise stair landing with lower circulation

Date: 2026-11-01

Status: **bounded geometry screen complete; no layout or route selected.**

## Owner direction

The owner authorized analysis of M295's least-change full 60-in stair option with its landing treated as part of C-LOWER circulation. The authorization is recorded in `Decisions/2026-11-01_M296_Stair_Landing_Circulation_Integration_Authorization.md`.

## Result

The candidate preserves the source positions and areas of L-01 and C-LOWER. Its landing directly overlaps C-LOWER by **15.3333 sq ft**, so the rectangles form a shared proposed zone. Measuring the complete 4 × 14.4167-ft stair envelope separately gives **18.8472 sq ft** of overlap with C-LOWER and **60.0417 sq ft** outside the stair footprint. These are different quantities: the M295 landing-interface measure is not the full stair footprint.

Across the stair's band through C-LOWER, only a **21-in west-side gap** remains; the stair extends to and beyond C-LOWER's east edge, leaving **no east-side bypass**. The lone 21-in bypass is narrower than M215's 36-in project route-screen precedent. Thus the proposed landing/circulation rectangles connect, while the geometry does not retain a 36-in path past the stair. M215's 36-in value is a study precedent here, not a code or accessibility determination.

This does not prove that an integrated landing/circulation layout cannot work. Doors, openings, real wall boundaries, approach, floor opening, headroom, structure, finish thickness, tolerances, and route beyond C-LOWER are absent. No physical stair, room, route, level, or Revit/IFC change follows. M-06/A/B remain unassigned; west A stays protected.

## Reproduction

From the repository root in PowerShell, using new or empty output folders:

```powershell
.local\dotnet\dotnet.exe build Tools/M296Generator/M296Generator.csproj --configuration Release --output .local/revalidation/m296-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local/revalidation/m296-build/M296Generator.dll Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json Decisions/2026-11-01_M296_Stair_Landing_Circulation_Integration_Authorization.md .local/revalidation/m296-replay1
.local\dotnet\dotnet.exe .local/revalidation/m296-build/M296Generator.dll Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json Decisions/2026-11-01_M296_Stair_Landing_Circulation_Integration_Authorization.md .local/revalidation/m296-replay2
```

The package-free .NET 10 build succeeds with zero warnings/errors. Both runs pass **9/9 checks** and produce identical JSON/check/SVG files; the SVG parses as XML. The tool pins the M295 source report (`65A84006158D4352D282D3FA32EDBA3E93F327D31584F19B6C1C9C5BD081CE04`) and M296 authorization (`C2A69B83F77652E0F8F3FBF1B687A578D98C4F878932B9D9900454305B983092`).

## Artifact hashes

| Artifact | SHA256 |
|---|---|
| `m296-integration-screen.json` | `F58326683B4B8563D4C21968E84D2239BBB48A6A1DFEC468042D8F10BD8F3FDC` |
| `m296-checks.json` | `C28D4037D48402417E307F64A4E8E55C1A4D76F0B252C76C7964CCC2D8156CCF` |
| `m296-plan.svg` | `B5F53D1CB908AAC62786F34F4F04ED851BF0A476E0327ED3459135981F96D638` |
