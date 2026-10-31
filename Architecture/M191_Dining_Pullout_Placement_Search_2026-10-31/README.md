# M191 — Test dining-set moves with chair pull-out envelopes reserved

**Status:** search and checks pass; none of three tested furniture placements restores the sampled porch route. No arrangement is selected.

## Scope and method

M191 takes three rigid placements from the earlier M188 comparison: baseline, one foot east and one foot north. It preserves the documented 36 × 60 in dining table and four 18 × 20 in chair bodies in the 11 × 10 ft dining study block. For each chair, it adds a seat-width rectangle extending 36 in outward from the corresponding table edge, following the explicitly labeled interpretation in M190. It then reruns the same M186 PowerShell route search at 0.25-ft grid resolution with a 36-in swept centerline and the existing room, kitchen, porch and M-06 proxies.

All bodies and pull-out rectangles fit the study block in all three cases. **Zero of three** cases reaches the nominal porch door. The nearest reachable grid points remain **10 ft** away by Manhattan distance; this describes the sampled grid only. The M188 north shift no longer restores a path when the chair-use envelopes are reserved.

This narrows the issue to the current dining arrangement and its route constraints; it does not establish that no other table orientation, chair placement, shell, or route can work. A broader search or a designer's revised furniture/door inputs is required before selecting a plan.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m191_dining_placement_with_pullouts.ps1 -OutputDirectory .local/revalidation/M191-replay-01 -ScratchPrefix M191-replay-01
```

Use a fresh output folder and unique prefix. The runner creates and removes one guarded M186 derivative per case; all route reports remain in ignored `.local/revalidation/`. The retained package plus an independent replay pass **7/7** source, chair-dimension, program, grid, selected-D and M-06 invariants. JSON, checks and CSV match byte-for-byte. Output SHA256 values:

- `m191-dining-pullout-search.json`: `214D397A7C6AFB2E0EC6EEBBC7CFDD4DF0CB22DACD9F93CAA78461D7EBB69C88`
- `m191-checks.json`: `4E6E117779554DD73E50F945F1B2A60D6DCB60C04658538632128251C1206EF8`
- `m191-options.csv`: `E620BC2F13988E98CAA9DF73FE3661BCF949EA033FA60433A88B796F92106277`

## Limits

- The 36-in-from-table-edge rectangle is a study interpretation of the project specification. The wording does not define a selected chair, occupant envelope, swept motion, or measurement convention.
- The 42-in preferred wall/porch-door distance remains untested; physical wall and clear-opening geometry do not exist in this study.
- This is a finite comparison of three placements on a bounded grid, not proof of universal infeasibility. It does not test chair motion, table leaves, occupants or field tolerances.
- The test shell, kitchen candidate, route, table position and door reservations are unapproved. M-06/B remains unassigned; selected-D, Revit/IFC, Incoming RFAs and remote state are unchanged.
- No code-compliance, accessibility, structural-safety, professional, permit or construction-readiness conclusion follows.
