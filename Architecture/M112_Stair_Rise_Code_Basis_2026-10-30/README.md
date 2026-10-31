# M112 - Connecticut stair-rise arithmetic and selected-D section gap

Date: 2026-10-30. Status: **reproducible source-bound sensitivity analysis; no stair or code-compliance approval**.

## Verified inputs

- The selected-D room-study source places Lower FF at -5 ft, Main FF at 0 ft and Upper FF at +5 ft: both adjacent test-level transitions are 60 in.
- Selected D's inherited B comparison is 8 risers at 7.5 in, 7 treads at 11 in: 60 in total rise and a 77 in straight tread run. This is a plan/arithmetic baseline; final stair count and geometry remain unselected.
- The separate owner-intent stair document prefers 6 risers at 7.25 in (43.5 in total) and a count range of 5 to 7. It does not match a single 60 in flight.
- The Connecticut 2022 CSBC amendments to IRC R311.7.5.1 and R311.7.5.2 publish 8.25 in maximum riser and 9 in minimum tread depth, respectively. At 60 in, seven equal risers would be 8.5714 in and exceed that published maximum; eight equal risers at 7.5 in are the minimum count under this one-parameter screen. This explains the eight-riser comparison but does not select it.

This clarifies the existing CO-021 vertical-stair gate. Structural floor-to-floor dimensions, floor assembly, finish datum, landing section, openings, headroom, guards, support, egress, site and permit applicability remain unresolved. A possible follow-up is to compare retaining the 8-riser option, revising the test-level datum, or dividing the rise among multiple short flights and a landing. None is selected or treated as feasible here.

## Reproduction

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m112_stair_rise_code_basis.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m112_stair_rise_code_basis.ps1 -OutputDirectory .local/revalidation/M112-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m112_stair_rise_code_basis.ps1 -OutputDirectory .local/revalidation/M112-b
```

All runs pass **11/11**. The two independent scratch runs reproduce byte-for-byte: `stair-rise-options.json` SHA256 `32D818FDEBA289EBF423EED7377F0B5A90EC772ECA679286A743EA68D2AF01AF`; `checks.json` SHA256 `AE00F1DEDDBF8C912410BB8C467782CF798B0882E6C18E2B7CC8E3FBCD982D50`. The generator fingerprints the selected-D study, decision, owner stair spec, cited CT research note and its own script. Outputs default to this package and paths outside the current repository are rejected.

## Limits and authoritative basis

The relevant published provision is conditional on the code edition, occupancy and permit path that apply to a future project. Connecticut DAS states that the 2022 CSBC applies to permit applications filed on or after October 1, 2022; the eventual municipality and permit timing are unknown. The 8.25 in and 9 in values are cited design-screen inputs, not a compliance determination. See [Research/Connecticut_Stair_Code_Research_2026-10-30.md](../../Research/Connecticut_Stair_Code_Research_2026-10-30.md) and CO-021 in the coordination register. No Revit model, IFC, selected-D source or RFA was changed.