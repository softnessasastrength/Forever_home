# M302 — Hypothetical lower-shell stair spatial sensitivity

Date: 2026-11-02

Status: **envelope fits found in a documented hypothetical shell; not a design selection or an access/route result.**

## Direction and trade-off

M302 carries the owner's prior exploration of a **38.333333 × 40 ft** shell into a lower-plan sensitivity only. That shell was previously used for an upper-suite comparison; applying it to the lower plan here is explicitly hypothetical and unselected. Its plan area is 1,533.33 sq ft versus the current 36 × 32 ft wing test at 1,152 sq ft: **381.33 sq ft (33.1%) more plan area**. Selected-D is not changed.

The test holds all source lower-room coordinates, C-LOWER and protected M-06 windows fixed; L-01 can move/reshape but keeps its 250.5556-sq-ft area. The stair remains M301's unverified spatial proxy using the M295 60-in transition, 8 aggregate risers, 7 aggregate tread runs and 4-ft width. The run split and one 4 × 4 ft internal turn platform remain an assumption, not a stair schedule. West A is protected; M-06 and B remain unassigned.

## Result and verification

`Tools/M302Generator` builds with repository-local .NET 10: **0 warnings, 0 errors**. Two independent final runs pass **7/7 checks**, reproduce report/check/SVG byte-for-byte and parse the SVG.

The search examines **5,025** same-area L-01 placements and **303,801,450** combined rotated stair/L-01 placements. **3,850,039** clear the fixed room blocks, the protected windows and same-area L-01. The displayed least-L-01-movement examples keep L-01 essentially at source position and place the stair proxy in the added north-side band near y=31.17 ft. Those examples leave only about **1 in** to L-01. The result establishes only that this assumed envelope can occupy some plan locations inside the larger rectangle; it has no end landings, access approach or route to C-LOWER. It does not show that the enlarged plan works as a house.

## Reproduction

From the repository root in PowerShell, use new or empty output folders:

```powershell
& '.local/dotnet/dotnet.exe' build 'Tools/M302Generator/M302Generator.csproj' --configuration Release --output '.local/revalidation/m302-build' --ignore-failed-sources
& '.local/dotnet/dotnet.exe' '.local/revalidation/m302-build/M302Generator.dll' 'Architecture/Selected_Design_Iteration_2026-10-27/study.json' 'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json' 'Decisions/2026-11-02_M302_Hypothetical_Lower_Shell_Stair_Sensitivity.md' '.local/revalidation/m302-replay1'
& '.local/dotnet/dotnet.exe' '.local/revalidation/m302-build/M302Generator.dll' 'Architecture/Selected_Design_Iteration_2026-10-27/study.json' 'Architecture/M295_Full_Rise_Stair_Fit_Study_2026-11-01/artifacts/m295-full-rise-stair-study.json' 'Decisions/2026-11-02_M302_Hypothetical_Lower_Shell_Stair_Sensitivity.md' '.local/revalidation/m302-replay2'
$a='.local/revalidation/m302-replay1'; $b='.local/revalidation/m302-replay2'; 'm302-l-turn-stair-envelope-study.json','m302-checks.json','m302-options.svg' | ForEach-Object { (Get-FileHash (Join-Path $a $_)).Hash -eq (Get-FileHash (Join-Path $b $_)).Hash }
[xml]$svg=Get-Content (Join-Path $a 'm302-options.svg') -Raw
```

The generator pins selected-D, M295 and this authorization. It refuses nonempty output folders and uses the 38.333333 × 40 ft shell values in code. Successful replays: `.local/revalidation/m302-run3/` and `run4/`. The canonical report, checks and SVG are retained under this study folder in `artifacts/` for review and downstream reproducibility.

## Artifact hashes

| File | SHA256 |
|---|---|
| `m302-l-turn-stair-envelope-study.json` | `73D8ACDC85DF307ADF9782444281C3C7144A30C67DDF7D2F8CACD46F715BF03A` |
| `m302-checks.json` | `D6B57DB0993F13941CBCF0C3FA4A53ED138AD08ED3D7C1DC364BF2A010798C3B` |
| `m302-options.svg` | `84EF3E6C39EC1329C8DEF99A40A7A2B6081A0EDA5CAED42E1555FD88D8B0E2E0` |

## Next

Test lower-level approach and route continuity only for explicitly labeled sample fits, then quantify the room/route conflicts. A geometric envelope fit alone is insufficient to proceed to a native Revit stair. Owner review is required before treating the 38⅓ × 40 ft lower-shell case as preferred; it is over one-third more plan area than the selected-D wing comparison.

No selected-D, Revit, IFC, family or remote state changed. This is not code compliance, accessibility, structural safety, professional approval, permit approval or construction readiness.
