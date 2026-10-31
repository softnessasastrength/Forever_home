# M187 - One-at-a-time route proxy sensitivity

**Status:** sensitivity run complete; one independent replay has confirmed the results. This package removes one M186 obstacle proxy at a time and records whether that single relaxation restores any route on the same quarter-foot analysis grid. These are tradeoff probes, not layout decisions.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\search_m187_route_sensitivity.ps1 -ScratchPrefix M187-replay-01 -OutputDirectory .local\revalidation\M187-summary-01
```

The script refuses to overwrite a nonempty output folder. Use a fresh output directory and unique `-ScratchPrefix` for each replay. It creates a temporary generated M186 runner beside the source script, removes it in a `finally` block, and stores the nine individual M186 reports under ignored `.local/revalidation/`.

## First retained run

PowerShell 5.1 completed all nine runs and the summary passes **14/14 checks**. Removing only the assumed stool-use proxy, only the west diagnostic rectangle, or only the dining set restored a sampled path. Removing the dining set produced a 54.5-ft, five-turn path; stool and west diagnostic removals each produced a 28.5-ft, five-turn path. The entry-block relaxation did not restore a path. Those paths intersect the omitted proxy by construction and therefore cannot be treated as candidates while that reservation remains applicable.

The result isolates three sensitive constraints: a seating envelope that has not been measured from selected product geometry; a west M-06 diagnostic area already blocked by the bath-first layout; and the assumed dining table/chair arrangement. It does not recommend deleting stools, using the blocked diagnostic, or removing dining furniture. The east/B search window remains reserved and unassigned. Relaxing it alone did not restore a path.

## Scope and limits

This replays the M186 deterministic breadth-first search against the owner-selected 40 x 42 ft test envelope with a 36-in swept-route proxy and quarter-foot grid resolution. Relaxed shapes are analysis rectangles, not design dimensions. A restored path is an unconstrained route through the omitted proxy, not a route that is clear of it. No continuous path impossibility, functional circulation, furniture operation, door fit, accessibility, code compliance, structural safety, professional approval, permit approval, or construction readiness is established. Selected-D, Revit, IFC and source RFAs are not edited.

M-06/B remains unassigned pending fixture-specific dimensions, a cited applicable clearance basis, approach/door operation and plausible service routing. Revit host verification and real door/opening geometry remain outstanding.

## Outputs

- `artifacts/m187-route-sensitivity.json` - source-bound results, checks and limitations.
- `artifacts/m187-checks.json` - machine-readable integrity checks.
- `artifacts/m187-route-sensitivity.csv` - compact scenario summary.

Retained output plus an independent run with a separate scratch prefix match byte-for-byte. SHA256: JSON `A0B85796769921F54F7657BA63BBBABCA4A539011A586F391EA88D19C5A7D904`; checks `150BE9EB9D80954C48B597FDF5AAD5E27BD6C8AC5DA0FB54B8A12ECEB9DE5B83`; CSV `52D04D694E93236CC13F371A0A1BD0AAE1544590A902C8B78C794B22BDF91596`. CSV's nine rows and labels were cross-checked against the JSON scenario list.
