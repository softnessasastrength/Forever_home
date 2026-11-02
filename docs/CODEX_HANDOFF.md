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

## BIM state and next action

- M353 native walkthrough composition is runtime-verified in Revit 2027.3 and IFC2x3-validated at `.local/revit-pilot/walkthrough-composition/20261102T161721219Z/`.
- M353 is disposable comparison geometry only: no roof pitch, floor-to-floor datum, assemblies, structure, MEP, code/accessibility review, or M-06 assignment is selected.
- M354 `NativeStairLandingCoordinationCommand.cs` and `validate_stair_landing_coordination.ps1` are runtime-verified in Revit 2027.3. The retained study is `.local/revit-pilot/stair-landing-coordination/20261102T192620005Z/`; its independent validator passes 13/13, with RVT SHA256 `691D0BAB211066179521F2A2E7CEC7C57463FFF838F56CC4DCD40F7A9453663A` and IFC2X3 stair/slab evidence.
- Next authorized action: advance to the documented placeholder-replacement gates, beginning only with categories supported by source inputs. Do not open or modify Selected-D; keep M-06/B unassigned.
- M355 revalidated the retained integrated main-floor comparison at `.local/revit-pilot/integrated-main-floor-assembly/20261102T141223011Z/`; `validate_integrated_main_floor_assembly.ps1` passes 7/7. It contains 57 provisional walls and 12 nominal openings across three unselected ceiling-height cases. This is coordination evidence, not promotion of wall/floor/door assemblies.
- M356 replayed the retained roof and M-06 evidence: the native roof shell passes 13/13 for 8:12, 10:12 and 12:12, while the M-06 proxy/clearance/coordination validators pass only as a fit-blocked evidence chain. No roof pitch is selected and B remains unassigned.
- M357 replayed `Tools/run_verified_bim_sequence.ps1` after the coordination updates; all 12 retained stages pass. This remains a regression replay, not a fresh Selected-D generation or placeholder promotion.
- Keep M-06/B unassigned until exact product geometry, finished-face clearance, door/approach, and plausible service routing are all supported by evidence.

## Portability note

Git contains the source, instructions, decisions, scripts, and committed evidence. Ignored `.local/` outputs, per-user Revit registration, machine caches, and the Evolution RFA are not guaranteed to exist after a fresh clone; rebuild or transfer those separately and verify hashes before use.
