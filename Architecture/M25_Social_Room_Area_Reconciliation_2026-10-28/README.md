# M25 — Social-room area reconciliation

Status: **source-checked comparison; neither area strategy selected**. This prepares the room-size decision before the next coordinated main-floor layout study.

## Reproduce

From the repository root, run Windows PowerShell 5.1:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m25_social_room_area_reconciliation.ps1
```

The script reads the owner-selected D study, its generated area-review CSV, the coordinated room program, the D decision, the main-floor design-gate note, and the earlier `Architecture/Kitchen_Dining_Porch_Specs.md` dimensions. It writes `area-reconciliation.json`. The output fingerprints all six inputs and checks block area arithmetic against the review, cross-checks current ranges against `Requirements/Room_Program.md`, and confirms the historical kitchen/dining dimension strings are still present in their source document.

Verified with Windows PowerShell 5.1 on 2026-10-28: **16/16 checks passed**. Two fresh scratch-directory runs and the documented run produced byte-identical JSON, SHA256 `72547E8C15C09C9476193DBCF045897B93EC93C036FA3A0DA336CCB1E1DE60C6`.

## Measured comparison

| Room | Selected-D study block | Current study area | Program range | Above program maximum |
|---|---:|---:|---:|---:|
| M-01 Living | 16 × 15 ft | 240 sf | 180–220 sf | 20 sf (9.1%) |
| M-02 Kitchen | 17 ft 4 in × 16 ft | 277.33 sf | 150–185 sf | 92.33 sf (49.9%) |
| M-03 Dining | 11 ft 4 in × 14 ft | 158.67 sf | 90–120 sf | 38.67 sf (32.2%) |
| **Combined** | — | **676 sf** | **420–525 sf** | **151 sf above combined maxima** |

Reaching all three upper bounds together would reduce the current study total by 151 sf, or 22.3%. Reaching all three lower bounds would reduce it by 256 sf, or 37.9%. These totals are arithmetic boundaries of the existing room-program ranges, not recommendations or proposed room sizes.

## Historical documented room-size option

The project also records earlier dimensions of a **14 × 12 ft kitchen (168 sf)** and **11 × 10 ft dining room (110 sf)** in `Architecture/Kitchen_Dining_Porch_Specs.md` and the room program. Keeping selected-D living at 240 sf gives a partial social-room subtotal of **518 sf**, inside the combined 420–525 sf range; the living room still exceeds its individual upper reference by 20 sf.

This option is a source-derived comparison, not an adopted scheme. The existing [fit comparison](../Room_Size_Comparison_2026-10-27/README.md) records that the 14 × 12 ft kitchen leaves only 6 in beyond the minimum aisle chain along its long axis and is 6 in short of the preferred chain there; the short axis is 18 in short of the minimum chain and 30 in short of preferred. The 11 × 10 ft dining block fits only the minimum 9 × 11 ft table envelope in its matching orientation and not the preferred 10 × 12 ft envelope. These constraints mean the historical dimensions are not automatically a better fit merely because their areas align with the program.

## Choices for the next layout study

1. **Retain the current blocks for one furnished fit test.** Keep D's selected room areas while testing the hearth/TV, kitchen work zones, island, dining seats, routes and storage. Carry the three program variances explicitly; this does not accept them as final.
2. **Retarget the social rooms within their documented ranges.** Choose each room's target from the existing ranges, then make a separately labelled placement study. The exact target and resulting coordinates remain undecided. No dimension is inferred from the combined reduction alone.
3. **Re-test the earlier documented kitchen and dining dimensions.** This is the only lower-area option here with exact historical dimensions in the repository: M-02 14 × 12 ft and M-03 11 × 10 ft, with M-01 held at its current D area for comparison. It totals 518 sf but carries the specific kitchen-aisle and dining-table shortfalls above. Any new placement study would remain separate and unselected.

The room program calls these values preliminary allowances. This comparison creates no replacement geometry and changes no source study. The 40 × 42 ft shell remains a test envelope; wall thickness, circulation, finished clearances, site, and gross conditioned area are not calculated. M-06 remains unassigned and is excluded from the subtotal. No code, accessibility, engineering, or construction-readiness claim follows.
