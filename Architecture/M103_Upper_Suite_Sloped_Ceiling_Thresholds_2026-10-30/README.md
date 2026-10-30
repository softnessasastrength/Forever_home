# M103 - Parametric sloped-ceiling thresholds for the upper-suite study

Status: geometric sensitivity only. The 38⅓ × 40 ft shell is still an exploration case. No room classification, effective eave ceiling height, roof pitch or ridge direction is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m103_upper_suite_sloped_ceiling_thresholds.ps1
```

The script hash-binds M78's search and manifest, M83's roof options, the current selected-D source, the room program and the Connecticut research note. It produces JSON provenance/checks and a CSV with 24 rows for U-01 through U-04 across six hypothetical roof cases. Outputs are deterministic; output paths outside the repository are refused.

## Method and results

The reference is Connecticut's 2022 CSBC amended IRC R305.1 sloped-room exception: 5 ft across required floor area and 7 ft across at least 50% of required floor area. For this geometric screen only, the complete M78 room-block rectangle stands in for required floor area. The calculation reports the effective finished-ceiling height at the eave datum, relative to finished floor, needed to meet both generic height bands if they apply to that room. It uses the minimum and median ideal roof-plane rise over the rectangle. The effective eave value includes unknown floor/eave elevation and roof-to-ceiling build-down; it is an output threshold, not an assumed datum.

| Gable option | Most demanding candidate room | Effective eave ceiling threshold |
|---|---|---:|
| 8:12, ridge X | U-03 | -0.444 ft |
| 10:12, ridge X | U-03 | -1.806 ft |
| 12:12, ridge X | U-03 | -3.167 ft |
| 8:12, ridge Y | U-04 | 5.000 ft |
| 10:12, ridge Y | U-04 | 5.000 ft |
| 12:12, ridge Y | U-04 | 5.000 ft |

Two independent PowerShell runs pass **10/10 checks** and match the checked-in artifacts: JSON SHA256 `4B74367B5F111271B6B171FFBF3AF8B2F0438024A8EF87C2428F8C0AEDC3391C`; CSV SHA256 `F7D70A521EAD5934B15D85C5B603389014BBF1C2D75FEC79FBEE852E66FB5910`.

With these room blocks, ridge X needs a lower effective eave threshold under the generic 5/7 ft arithmetic than ridge Y. Negative thresholds are algebraic results relative to the room's finished floor; they do not imply a below-floor eave is buildable or acceptable. This is an orientation sensitivity of this room-block arrangement, not a recommendation: daylight, views, structure, roof form and the actual finished section remain unknown. U-02 is included as geometry only while its room classification is unresolved.

## Exclusions and limitations

- U-05/U-06 bathrooms are excluded pending fixture locations and the separate fixture-use height review; no showerhead area is tested.
- C-PRIVATE is excluded because its hallway/circulation treatment is not resolved in this screen.
- The entire room rectangle is used as the area basis; this may differ from code-defined required floor area and is a conservative modeling assumption.
- The model has no wall/eave offsets, roof thickness, framing, finish ceiling, floor datum, dormers or structure. No code applicability or compliance is determined.
- Connecticut's current edition and delayed 2026 adoption are documented in `Research/Connecticut_Roof_Code_Research_2026-10-28.md`; local jurisdiction and future permit timing remain unknown.
