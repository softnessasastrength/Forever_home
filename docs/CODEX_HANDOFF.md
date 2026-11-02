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
- Latest pushed commit: `274e0e7 docs: make ButlerGPT handoff discoverable`
- `main` and `design/vr-tech-bom-roadmap` are not the sandbox working branch.
- The worktree may contain intentionally ignored `.local/` Revit outputs and per-user pilot builds; do not treat them as portable Git source.
- The incoming Evolution RFA is a separately preserved, hash-pinned local input and must not be overwritten, upgraded, or committed casually.

## BIM state and next action

- M353 native walkthrough composition is runtime-verified in Revit 2027.3 and IFC2x3-validated at `.local/revit-pilot/walkthrough-composition/20261102T161721219Z/`.
- M353 is disposable comparison geometry only: no roof pitch, floor-to-floor datum, assemblies, structure, MEP, code/accessibility review, or M-06 assignment is selected.
- M354 `NativeStairLandingCoordinationCommand.cs` and `validate_stair_landing_coordination.ps1` are present and build-verified in the pushed commit. Revit runtime validation was not completed before the handoff pause.
- Next authorized action: rebuild the exact project-local RevitPilot DLL, verify AddInId/path/SHA256, preserve the existing per-user manifest, use **Load Once** only for that exact DLL, run M354 in a disposable `FH_Compact_Core_Study`, and validate RVT/IFC lineage. Do not open or modify Selected-D.
- Keep M-06/B unassigned until exact product geometry, finished-face clearance, door/approach, and plausible service routing are all supported by evidence.

## Portability note

Git contains the source, instructions, decisions, scripts, and committed evidence. Ignored `.local/` outputs, per-user Revit registration, machine caches, and the Evolution RFA are not guaranteed to exist after a fresh clone; rebuild or transfer those separately and verify hashes before use.
