# M25 — Social-room area reconciliation

Status: **source-checked comparison; neither area strategy selected**. This prepares the room-size decision before the next coordinated main-floor layout study.

## Reproduce

From the repository root, run Windows PowerShell 5.1:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m25_social_room_area_reconciliation.ps1
```

The script reads the owner-selected D study, its generated area-review CSV, the coordinated room program, the D decision, and the main-floor design-gate note. It writes `area-reconciliation.json`. The output fingerprints all five inputs and checks block area arithmetic against the review, then cross-checks the three stated ranges against `Requirements/Room_Program.md`.

Verified with Windows PowerShell 5.1 on 2026-10-28: **11/11 checks passed**. Two fresh scratch-directory runs and the documented run produced byte-identical JSON, SHA256 `4A828984CC93FE7B793DBD122CBE49B5A0A018788BEBA285CD3B02A0BECE82A7`.

## Measured comparison

| Room | Selected-D study block | Current study area | Program range | Above program maximum |
|---|---:|---:|---:|---:|
| M-01 Living | 16 × 15 ft | 240 sf | 180–220 sf | 20 sf (9.1%) |
| M-02 Kitchen | 17 ft 4 in × 16 ft | 277.33 sf | 150–185 sf | 92.33 sf (49.9%) |
| M-03 Dining | 11 ft 4 in × 14 ft | 158.67 sf | 90–120 sf | 38.67 sf (32.2%) |
| **Combined** | — | **676 sf** | **420–525 sf** | **151 sf above combined maxima** |

Reaching all three upper bounds together would reduce the current study total by 151 sf, or 22.3%. Reaching all three lower bounds would reduce it by 256 sf, or 37.9%. These totals are arithmetic boundaries of the existing room-program ranges, not recommendations or proposed room sizes.

## Choices for the next layout study

1. **Retain the current blocks for one furnished fit test.** Keep D's selected room areas while testing the hearth/TV, kitchen work zones, island, dining seats, routes and storage. Carry the three program variances explicitly; this does not accept them as final.
2. **Retarget the social rooms within their documented ranges.** Choose each room's target from the existing ranges, then make a separately labelled placement study. The exact target and resulting coordinates remain undecided. No dimension is inferred from the combined reduction alone.

The room program calls these values preliminary allowances. This comparison creates no replacement geometry and changes no source study. The 40 × 42 ft shell remains a test envelope; wall thickness, circulation, finished clearances, site, and gross conditioned area are not calculated. M-06 remains unassigned and is excluded from the subtotal. No code, accessibility, engineering, or construction-readiness claim follows.
