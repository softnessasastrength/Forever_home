# Forever Home — Codex handoff

This note is for a fresh Codex session opened from the repository. It supplements, but does not replace, the root `AGENTS.md`.

## Start here

1. Read `AGENTS.md`.
2. Read `docs/BUTLERGPT_PERSONALITY.md` and use that voice in every owner-facing response.
3. Read `Project/AI_Handoff.md`, `PLAN.md`, and the most recent section of `PROGRESS.md`.
4. Verify the branch, status, remotes, and recent history before editing:

```powershell
git status --short --branch
git branch -vv
git remote -v
git log --oneline --decorate -8
```

## Personality bootstrap

Address the owner as “sir”. Write as a competent, impeccably mannered Victorian English butler: concise, concrete, dryly witty, and quietly impatient with badly designed software. Take initiative on authorized work, avoid routine permission loops, and report evidence, trade-offs, assumptions, limitations, and blockers plainly. This affects communication only; it never changes safety checks, technical correctness, privacy, or validation standards.

## Repository checkpoint

- Repository: `softnessasastrength/Forever_home`
- Active sandbox branch: `codex/house-design-sandbox`
- Latest repository commit: verify with `git log`; local M354 runtime evidence is recorded below. Do not assume ignored `.local/` outputs are portable.
- `main` and `design/vr-tech-bom-roadmap` are not the sandbox working branch.
- The worktree may contain intentionally ignored `.local/` Revit outputs and per-user pilot builds; do not treat them as portable Git source.
- The incoming Evolution RFA is a separately preserved, hash-pinned local input and must not be overwritten, upgraded, or committed casually.
- Owner override recorded 2026-11-02: **Always Load** is permitted only for the exact hash-checked project-local Forever Home DLL under the authorized AddInId, never for unknown add-ins or trust-wide/security changes. Record the DLL SHA256 and preserve the prior manifest before registration.
- M363 records the owner’s coordination bundle: 43½-in split rise, 5½-in non-structural partitions, 1½-in generic floor build-up beneath engineered oak, 36-in nominal openings, 10:12 working roof with 8:12 comparison, living-only skylight zone, M-06 proxy/SKU expansion, lower-MEP route and hall-edge approach. See `Decisions/2026-11-02_Coordination_Gate_Bundle.md`.

## BIM state and next action

- M353 native walkthrough composition is runtime-verified in Revit 2027.3 and IFC2x3-validated at `.local/revit-pilot/walkthrough-composition/20261102T161721219Z/`.
- M353 is disposable comparison geometry only: no roof pitch, floor-to-floor datum, assemblies, structure, MEP, code/accessibility review, or M-06 assignment is selected.
- M354 `NativeStairLandingCoordinationCommand.cs` and `validate_stair_landing_coordination.ps1` are runtime-verified in Revit 2027.3. The retained study is `.local/revit-pilot/stair-landing-coordination/20261102T192620005Z/`; its independent validator passes 13/13, with RVT SHA256 `691D0BAB211066179521F2A2E7CEC7C57463FFF838F56CC4DCD40F7A9453663A` and IFC2X3 stair/slab evidence.
- Next authorized action: advance to the documented placeholder-replacement gates, beginning only with categories supported by source inputs. Do not open or modify Selected-D; keep M-06/B unassigned.
- M355 revalidated the retained integrated main-floor comparison at `.local/revit-pilot/integrated-main-floor-assembly/20261102T141223011Z/`; `validate_integrated_main_floor_assembly.ps1` passes 7/7. It contains 57 provisional walls and 12 nominal openings across three unselected ceiling-height cases. This is coordination evidence, not promotion of wall/floor/door assemblies.
- M356 replayed the retained roof and M-06 evidence: the native roof shell passes 13/13 for 8:12, 10:12 and 12:12, while the M-06 proxy/clearance/coordination validators pass only as a fit-blocked evidence chain. No roof pitch is selected and B remains unassigned.
- M357 replayed `Tools/run_verified_bim_sequence.ps1` after the coordination updates; all 12 retained stages pass. This remains a regression replay, not a fresh Selected-D generation or placeholder promotion.
- M358 independently revalidated the documented native opening comparison: `validate_documented_door_study.ps1` passes 10/10 and `validate_native_main_floor_openings.ps1` passes 13/13 for the 30-in/36-in pantry cases and nominal front/porch reservations. Door families, clear leaves and thresholds remain unselected.
- M359 reran the offline RevitPilot contract suite: 53 tests pass. This is a source/validator regression check, not host-side Revit generation.
- M360 records the owner-approved F-01 direction: engineered oak for kitchen, dining, living and halls. Product, thickness, substrate and structural floor build-up remain open; use only a labelled display material in the next disposable study.
- M361 adds the build-verified `NativeFinishCueStudyCommand` and validator for that labelled display material. DLL SHA256 is `8671F907B58FE22BA0179E8C4794B11ADB97FCE98018F31BF99F030AFE5867CD`; runtime is pending because the Revit trial WebView again blocked the supported UI bridge. Do not claim an RVT/IFC output until the exact DLL runs.
- M364 corrected the Revit-invalid pipe characters in the F-01 material name. The v2 DLL SHA256 is `5E93AA964ED9B650CC8E44E6098D6C7C519019D145CAF293B6F9FE03D97C9F6A`; the exact manifest is registered and backed up, but runtime remains pending on manual/host-side dismissal of the trial WebView.
- M365 retried the F-01 runtime path. Revit created `.local/revit-pilot/finish-cue-study/20261102T195238491Z/` but wrote no RVT/IFC/manifest before Computer Use was interrupted by the physical Escape key; treat the directory as an incomplete attempt and do not claim validation.
- M366 replayed the retained coordination evidence: `run_verified_bim_sequence.ps1` passes **12/12** and `validate_verified_bim_milestone.ps1` passes **15/15**. These are regression reports only; F-01 runtime remains pending and no placeholder is promoted.
- M367 added the F-01 source contract test; the offline RevitPilot suite now passes **56/56**. This covers command wiring and safety labels but is not runtime RVT/IFC evidence.
- M368 completed the F-01 runtime gate in Revit 2027.3. Output `.local/revit-pilot/finish-cue-study/20261102T200546656Z/` passes `validate_f01_finish_cue.ps1` **6/6**; RVT SHA256 `cf9b1d43b3f78563e889ab0f0dd6747c4fd2a9fe14298406dcf476f03d06f523`; IFC2X3 SHA256 `328ccf47dd6167d282467064ac8145f3694162adc2696cf0ec96732d014196af`. The retained sequence is 12/12, consolidated gate 15/15, and offline suite 56/56. This is still a display-only finish cue, not a selected assembly.
- Keep M-06/B unassigned until exact product geometry, finished-face clearance, door/approach, and plausible service routing are all supported by evidence.

### M369 native coordinated placeholder study

The v3 project-local RevitPilot DLL (`11A56B447BE43E94EC56700893C0340569ACFBC1BB2B10DC851337FF4080D72C`) ran successfully in Revit 2027.3 after the prior manifest was backed up at `.local/revit-pilot/registration-backups/20261102-151524663/`. Output `.local/revit-pilot/coordinated-placeholder-study/20261102T201702862Z/` passes `validate_coordinated_placeholder_study.ps1` **8/8**, with 11 native wall segments, one floor, three hosted nominal doors, RVT SHA256 `3b4c756492219a516105b0c3252b078c541fecf1161140c7d7f7a7aa0ba84e34`, and IFC2X3 SHA256 `f3d056015c96a3cbe33ced7fbbb3d301b99ed6368c2b850f928d59d0c631322e`. The study records the 5½-in/1½-in dimensions as coordination notes while retaining template-native host layers; it is not a construction assembly or Selected-D promotion. Offline suite is now **59/59**; retained gates remain **12/12** and **15/15**.

### M370 M-06 Tresham family evidence

The quarantined KOHLER Tresham K-2844-4 RFA was inspected read-only in Revit 2027.3. `validate_candidate_family_geometry.ps1` passes **11/11** against `.local/revit-pilot/family-intake/derivatives/M370-Kohler-Tresham-Inspection-20261102/candidate-family-geometry.json`. Source SHA256 is stable at `3b1cbdaa844d35bd462f6e59a828b82f7870fde4ee7397bac09f4ca0c2f9b949`; derivative RVT SHA256 is `0dd0ff380331b74b2b03d2bd9f64533060ce3d47879fcc9010abf1a02dcde55b`. The family is Plumbing Fixtures / WorkPlaneBased with ten finish types, three positive-volume solids per type, measured bounds about 24.13 × 19.56 × 34.69 in, and one primary sanitary round connector with ⅝-in radius. This is stronger candidate evidence, not a selection or room fit. M-06/B remains unassigned pending the owner’s lavatory direction and the combined toilet, clearance, door/approach and service-route gate.

## Portability note

Git contains the source, instructions, decisions, scripts, and committed evidence. Ignored `.local/` outputs, per-user Revit registration, machine caches, and the Evolution RFA are not guaranteed to exist after a fresh clone; rebuild or transfer those separately and verify hashes before use.
