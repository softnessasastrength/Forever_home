# M290 — Partition the remaining C-LOWER geometry after the stair/path screen

**Date:** 2026-11-01

**Status:** complete as an analysis-only exact rectangle partition. No C-LOWER layout, stair, or route is selected.

## Purpose and scope

M289 left an owner review between a minimum-change dogleg and a higher-change positive-gap connector. Before that review, M290 checks whether the stair and 36-in swept-route proxies split the remaining C-LOWER block into disconnected geometric pieces. It evaluates only the two representative M289 options: the minimum block-change positive-length route, and the largest reported positive stair/path-to-L-01 gap.

M289's existing authorization covers analysis-only joint, exact-area L-01/C-LOWER move/reshape comparison. M290 makes no additional design selection or model change. It pins and reads the committed M289 report; selected-D, Revit, IFC, and M-06 remain untouched/unassigned.

## Results

The package-free C#/.NET 10 generator builds with **0 warnings and 0 errors**. Two independent runs each pass **9/9 checks**, reproduce the JSON, check file and SVG byte-for-byte, and parse the SVG as XML.

| M289 reference | Combined change metric | Stair/path gap to L-01 | Path | C-LOWER area occupied by the screened union | Residual C-LOWER area | Residual connected components |
|---|---:|---:|---:|---:|---:|---:|
| Minimum-change dogleg | 1.1193 ft | 0 in | 9.25 ft, 2 turns | 0.4583 sq ft | 78.4306 sq ft | 1 |
| Largest-gap straight connector | 5.9221 ft | 26.644 in | 0.25 ft, 0 turns | 4.5000 sq ft | 74.3889 sq ft | 1 |

In both cases the remainder is a single edge-connected component in the exact coordinate-compressed rectangle partition; it is not fragmented into isolated scraps by the modeled proxy. The first partition has three free rectangular tiles and the second seven. The green region in the SVG shows the free partition. Component bounding boxes cover the C-LOWER extent but may include notches; the tile layout, not the bounding box, is the actual computed remainder.

This removes one narrow uncertainty from the owner comparison: both examples preserve one connected residual region in the abstract block. It does **not** demonstrate that residual circulation is usable, furnishable, compliant, accessible, or constructible. Actual stair geometry, doors, walls, approaches, floor openings, route continuity, finished faces, furniture, headroom, structure, MEP, and applicable project requirements remain absent. M289's 36-in route proxy is a project screening precedent, not an adopted code or accessibility criterion.

## Reproduction

Run from the repository root in PowerShell; use new or empty output directories:

```powershell
.local\dotnet\dotnet.exe build Tools/M290Generator/M290Generator.csproj --configuration Release --output .local/revalidation/m290-build --ignore-failed-sources
.local\dotnet\dotnet.exe .local\revalidation\m290-build\M290Generator.dll Architecture/M289_Joint_Lower_Stair_Circulation_Study_2026-11-01/artifacts/m289-joint-lower-stair-study.json .local/revalidation/m290-run1
.local\dotnet\dotnet.exe .local\revalidation\m290-build\M290Generator.dll Architecture/M289_Joint_Lower_Stair_Circulation_Study_2026-11-01/artifacts/m289-joint-lower-stair-study.json .local/revalidation/m290-run2
```

Compare all three output files by SHA256 across runs and parse `m290-residual-components.svg` as XML. The generator refuses a changed M289 input hash, nonempty output directory, or output outside this repository.

## Pinned source and outputs

| File | SHA256 |
|---|---|
| M289 joint study | `00000094823867028C728501AFA26B88A569376AB920B4AFAF00FC7F4ECCD4D1` |
| `m290-circulation-residual-study.json` | `0BB86C0187B4276A9EF13939CF4CCD53A23647B29BABACC0EAFB172BD881C343` |
| `m290-checks.json` | `464248E632C6DF931AB15B9E7D32E83E80CCB47B016CBD0DF6DE9D0A3DC6EF50` |
| `m290-residual-components.svg` | `730A685CF254525666488DD48E0ED0A1EA104839ECD5DCE2807134260F595856` |

## Next gate

The owner has been asked whether to prioritize the least layout change despite tangency, the larger measured gap with additional room reshaping, or parallel comparison. Until that choice, M290's two references remain comparative. A later explicit authorization is required before promoting either option into selected design geometry or Revit. No code-compliance, accessibility, structural-safety, professional-approval, permit, or construction-readiness conclusion is made.
