# M183 - Competing social-route option gate

**Disposition:** comparison only. Neither route nor any room layout is selected. M-06/B remains unassigned.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m183_route_option_gate.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m183_route_option_gate.ps1 -OutputDirectory .local\revalidation\M183-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m183_route_option_gate.ps1 -OutputDirectory .local\revalidation\M183-replay-b
```

Each run should pass 12/12 checks. Compare `m183-route-option-gate.json`, `m183-route-options.csv` and `m183-checks.json` byte-for-byte across the retained package and both scratch outputs. The script refuses to overwrite a nonempty output directory.

## What the comparison says

| Candidate | Measured screen | Outstanding constraint |
|---|---|---|
| M181 diagonal kitchen-side route | 0.60 in at assumed stools, 2 in at dining table, 0.38 in at blocked west M-06 search-window proxy | Fragile static margins. People, movement, thresholds, door operation and tolerance are absent. |
| M182 pantry-side bypass | 44 in unassigned throat; 36 in corridor leaves 4 in at either side | Overlaps 4.736 sf of blocked west diagnostic proxy, intrudes 2 in into source M-02 and needs a new, undocumented opening at M-01's south edge. It also spends circulation space immediately beside B. |

The blocked west search-window shape is only a diagnostic rectangle and must not be treated as an occupied fixture. The M182 4-in side gaps are boundary distances, not clearances for use. Both routes remain coordinate overlays built from unapproved blocks and furniture proxies.

## Gate and next work

Neither candidate can be promoted from this evidence. Resolve the room-block interface and M-01 south transition, then rerun the route with actual wall/finish and door geometry. Reopen M-06/B only when exact assembled fixture geometry, applicable clearance, hall approach/door operation and a plausible water/waste/vent route can be evaluated together. Keep the selected-D source unchanged.

The code-status research was rechecked on 2026-10-31: Connecticut DAS still lists the 2022 CSBC based on the 2021 IRC as current and says the 2026 effective date is delayed pending legislative approval. This is a statewide status observation, not a project-specific applicability or compliance finding. The project town, permit date, occupancy and accessibility scope remain unknown; see `Research/M06_Clearance_Basis_2026-10-30.md`.

No Revit or IFC model was edited. No RFA source was opened or altered by this milestone. No accessibility, code-compliance, structural-safety, certification, permit or construction-readiness claim is made.
