# M301 — L-turn full-rise stair spatial-envelope screen

Date: 2026-11-02

Status: **validated bounded negative result; no stair, room, or level geometry selected.**

## Direction and study boundary

This analysis carries forward the owner's direction to move/reshape L-01 while keeping the 60-in stair transition, and the later instruction to use judgment in making the vision work. It preserves L-01's selected-D area (250.5556 sq ft), other lower rooms including C-LOWER, the 36 × 32 ft comparison shell and both protected, unassigned M-06 windows. Authorization and assumptions are recorded in `Decisions/2026-11-02_M301_Alternative_Stair_Envelope_Study.md`.

The spatial proxy uses the M295 comparison values of 8 aggregate risers, 7 aggregate tread runs and a 4-ft width. It arranges orthogonal 3+4 tread-run proxies around one 4 × 4 ft internal platform. This split is an unverified spatial hypothesis, not a Revit stair schedule. End landings, access/approach, doors, headroom/opening, rails, guards, wall thickness, tolerances and route to C-LOWER are omitted. The study is useful only as an early blocking screen.

## Result and verification

`Tools/M301Generator` builds with the repository-local .NET 10 SDK: **0 warnings, 0 errors**. Two independent runs pass **7/7 checks** and reproduce report/check/SVG outputs byte-for-byte; the SVG parses as XML.

The generator tested **71** same-area L-01 placements that clear the fixed lower room and circulation blocks. Across rotations and quarter-foot placement positions, it evaluated **2,964,960** L-turn spatial proxy placements. **2,389,860** hit fixed rooms, **554,581** crossed protected M-06 windows and **20,519** overlapped L-01; none fit. This bounded result does not establish impossibility. It says the current 36 × 32 ft shell and preserved room blocks cannot host this particular unverified footprint proxy in the tested arrangement.

## Reproduction

Run from the repository root in PowerShell, with new or empty output folders:

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M301Generator/M301Generator.csproj' --configuration Release --output '.local/revalidation/m301-build' --ignore-failed-sources
& '.local/dotnet/dotnet.exe' '.local/revalidation/m301-build/M301Generator.dll' 'Architecture/Selected_Design_Iteration_2026-10-27/study.json' 'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json' 'Decisions/2026-11-02_M301_Alternative_Stair_Envelope_Study.md' '.local/revalidation/m301-replay1'
& '.local/dotnet/dotnet.exe' '.local/revalidation/m301-build/M301Generator.dll' 'Architecture/Selected_Design_Iteration_2026-10-27/study.json' 'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json' 'Decisions/2026-11-02_M301_Alternative_Stair_Envelope_Study.md' '.local/revalidation/m301-replay2'
$a='.local/revalidation/m301-replay1'; $b='.local/revalidation/m301-replay2'; 'm301-l-turn-stair-envelope-study.json','m301-checks.json','m301-options.svg' | ForEach-Object { (Get-FileHash (Join-Path $a $_)).Hash -eq (Get-FileHash (Join-Path $b $_)).Hash }
[xml]$svg=Get-Content (Join-Path $a 'm301-options.svg') -Raw
```

Inputs are fingerprint-pinned in the source; output paths must remain inside the repository and be empty. Successful replays: `.local/revalidation/m301-run3/` and `run4/`.

## Artifact hashes

| File | SHA256 |
|---|---|
| `m301-l-turn-stair-envelope-study.json` | `18EC7A4457F6AA1CDF5453600AE2DE147D9995904FB75F8479350900ECF7FCA7` |
| `m301-checks.json` | `D6B57DB0993F13941CBCF0C3FA4A53ED138AD08ED3D7C1DC364BF2A010798C3B` |
| `m301-options.svg` | `9086D6DC7D85C8D2B03EA231302471AC9CA3168DAF6080EA046A39D660251130` |

## Next

M297 and M300 show that moving either flex room alone does not clear the long straight stair proxy; M301's L-turn proxy also does not fit with this shell/layout. The next analysis should compare a shell sensitivity case already documented by the owner (38⅓ × 40 ft) with all source room blocks held fixed, while labeling the shell as hypothetical and unselected. If that opens spatial fits, access routes and a real stair/riser allocation still require separate work and design review.

No selected-D, Revit, IFC, family or remote state changed. No code compliance, accessibility, structural safety, professional, permit or construction-readiness claim follows.
