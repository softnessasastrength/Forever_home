# M169 — Conditional eave-threshold ranking for M168 ridge options

**Status:** comparative arithmetic only. The 38 1/3 × 40 ft envelope is an owner-authorized exploration case, not a selected house dimension. No room-block layout, ridge axis, roof pitch, floor/eave elevation, or ceiling build-down is selected.

## Reproduce

The PowerShell 5.1 analyzer joins M164's current 12:12 room exposure to M168's ridge-contact report. It verifies both reports' current M83 and selected-D fingerprints, unique candidate/axis keys, every room's eave-edge labels, and the contact-count agreement. It writes only to the requested repository-local directory.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m169_m168_ceiling_thresholds.ps1 `
  -OutputDirectory .local/revalidation/M169-a

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m169_m168_ceiling_thresholds.ps1 `
  -OutputDirectory .local/revalidation/M169-b

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m169_m168_ceiling_thresholds.ps1
```

Each run passes **17/17** source and geometry checks across 96 candidate/axis rows. The first two JSON outputs match byte-for-byte (SHA256 `016FF1360B8FF025055E1FBC5E1743CC13B35BE49E587D1A4A57AE4086302F2D`) and their CSV outputs match (SHA256 `A3207822586BF2FE5D774961D1C548DD8BB2C4C81CD040C49D4D179C004A9373`). The documented package contains the same hashes.

## Finding

At 12:12, the number of bedroom-capable room blocks whose conditional full-block proxy reaches the 5 ft threshold agrees with the number touching an ideal eave in every candidate/axis case:

| Ridge axis | One block at the 5 ft proxy | Two blocks at the 5 ft proxy |
|---|---:|---:|
| X | 0 / 48 | 48 / 48 |
| Y | 24 / 48 | 24 / 48 |

For the 24 ridge-Y layouts with one limiting block, U-03 is the 5 ft proxy limiter. U-04's own conditional threshold is 4.166667 ft in 16 layouts and 3.333334 ft in 8. Ridge Y therefore reduces the count of blocks at the full-block 5 ft proxy in half the sampled cases, while placing that boundary condition on U-03. This is a candidate-ranking trade-off, not a recommendation to select that ridge.

The source calculations retain the relation `effective_eave_ceiling = (z_eave - z_finished_floor) - b_eave`; for a whole modeled rectangle treated as required floor area, the threshold is `max(5 ft - minimum ideal rise, 7 ft - median ideal rise) + b_eave`. Floor/eave separation and the ceiling build-down remain symbolic. The 5 ft and 7 ft arithmetic is a preliminary Connecticut 2022 CSBC / amended 2021 IRC R305.1 screen and is subject to applicable room/use classification, required-area interpretation, municipality, and permit cycle. It is not evaluated as a code pass/fail result.

## Limits and next work

The room rectangles are full-block area proxies on ideal, zero-thickness roof planes. The analysis omits walls, roof assembly thickness, ceiling framing, dormers, openings, real floor/eave datums, and continuous layout alternatives. It does not model final headroom, doors, EERO, framing, loads, or actual room-use classification. The M83 Revit exports are generic open-surface comparison meshes, not a roof assembly. Selected-D, IFC, and source RFAs were not altered by M169; M-06/B remains unassigned.

The new Revit session was restarted during this work, but the introductory trial overlay remains open and RevitPilot has not been confirmed loaded. The previous active disposable M83 RVT was saved before closing. That save changed the current primary RVT in host run `20261031T104806592Z`, making its primary file fail the recorded saved-model fingerprint. The original `.0001.rvt` backup still matches the export manifest (`DEE49362175AA94B63E67C08A227C0F2DD269FD1B7957F87AE7BEB6718562204`) and its IFC2X3 independently passes 21/21 when copied into a separate scratch run directory. The changed primary and subsequent `.0002.rvt` backup are preserved; no file was overwritten to conceal the mismatch. See the latest M169 entry in `PROGRESS.md`.
