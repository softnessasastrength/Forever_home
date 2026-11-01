# M316 — Section/stair constraint register

Date: 2026-11-01

Status: **coordination gate recorded; no stair or level geometry selected.** This register consolidates existing owner directions and source-based screens before any native stair placement. It introduces no new architectural dimensions.

## Fixed inputs carried forward

| Item | Value | Evidence |
|---|---:|---|
| Active plan basis | Selected-D: main 40 × 42 ft; lower/upper 36 × 32 ft | `Architecture/Dimension_Register.md`, `Architecture/Selected_Design_Iteration_2026-10-27/study.json` |
| Ceiling study | 8 / 9 / 10 ft clear-height alternatives | Owner direction; M311 runtime study |
| Selected-D comparison transition | 60 in between stored −5 / 0 / +5 ft test levels | `Research/CT_Stair_Geometry_Checklist_2026-11-01.md` |
| DD-013 preference | 6 × 7¼ in = 43½ in half-story reference | `Architecture/M285_DD013_Vertical_Section_Study_2026-11-01/README.md` |
| Full-rise comparison | 8 × 7½ in, 7 × 11 in, 4 ft width and 4 ft landing-depth references | `Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/README.md` |
| Route screen precedent | 36 in swept-path proxy | M215/M295; analysis precedent only |
| M-06 / A / B | M-06 unassigned; west A protected; B unassigned | current owner direction and main-floor candidate input |

## Gate before native stair geometry

1. Choose a coherent floor-to-floor relationship; do not treat the 60-in comparison or the 43½-in preference as silently interchangeable.
2. Provide a section envelope covering floor construction, stair opening, top/bottom landings, headroom, and continuation to the target circulation.
3. Check door approaches and actual clear width against the applicable Connecticut provisions and the licensed design team's interpretation. The current research note records 36 in width, 6 ft 8 in headroom, 8¼ in maximum riser, 9 in minimum tread, and landing provisions as source-based screening criteria only.
4. Only after those inputs pass a labeled analysis screen may a disposable native stair be created. Selected-D remains unchanged.

## Current evidence and limitation

M295's reproducible full-rise screen passes 19/19 in two runs and finds 5,065 landing interfaces but zero separate 36-in routes to C-LOWER under its fixed-room constraints. M289/M294 provide a least-change analytical reference with tangent geometry, but it is not a physical stair. M311/M314/M315 provide native wall, provisional floor, and IFC evidence only; they do not close this section gate.

This register is not a code-compliance determination, accessibility review, structural design, professional approval, permit approval, or construction-ready instruction.
