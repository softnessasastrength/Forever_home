# M185 — Test the pantry dogleg against both M-06 search regions

**Status:** route-constraint study only. No room, route, kitchen size, or fixture location is selected. M-06/B remains unassigned.

## Reproduce

From the repository root in Windows PowerShell 5.1, run into two empty scratch directories:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m185_dogleg_m06_overlay.ps1 -OutputDirectory .local\revalidation\M185-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m185_dogleg_m06_overlay.ps1 -OutputDirectory .local\revalidation\M185-replay-b
```

Compare `m185-dogleg-m06-overlay.json`, `m185-checks.json`, `m185-route-comparison.csv`, and `m185-plan.svg` byte-for-byte between the retained `artifacts/` directory and both replays. The generator refuses to overwrite nonempty destinations. The `-ExecutionPolicy Bypass` argument applies only to these PowerShell processes; it does not change the machine's persistent policy.

## Result

M179's 36-in dogleg avoids the pantry and its listed kitchen/dining furniture proxies, but its full-width elbow overlaps the already-blocked west M-06 diagnostic by **0.708333 sf union area**. The owner-selected east/pantry-side B window remains clear.

Moving the dogleg turn one foot earlier, to local `y = 13.5 ft`, clears the west diagnostic and the pantry, but overlaps the assumed stool-occupancy rectangle by **1.5 sf**. It passes only 4 in from the west diagnostic at its nearest point. A 13.00–15.00 ft single-elbow sweep at 3-in steps has **no sampled location** that clears both the stool proxy and west diagnostic. At `y = 14.25 ft`, the sampled route overlaps both (0.375 sf stool and 0.354167 sf diagnostic); at the lowest sampled combined overlap, `y = 14.5 ft`, the west diagnostic still overlaps by 0.708333 sf. This is evidence that the existing simple dogleg is not a resolved route, not proof that all possible routes are infeasible.

There is a prior interface gap as well: M179 starts at `(14.5, 10) ft`, outside the source M-01 living block. The M-02 candidate edge is at `x = 13.5 ft`, and the living block begins at `x = 17.833 ft`, leaving a **4 ft 4 in unassigned band**. M180 had already corrected its route origin and flagged this band. M185's M179-derived doglegs do not connect living to kitchen and must not be described as continuous public circulation.

The candidate kitchen remains 13.5 x 14 ft / 189 sf, **21 sf above** the owner-directed 168-sf area target. Its room shape is unapproved. No room-size tradeoff is inferred from this route test.

## Evidence and scope

`Tools/audit_m185_dogleg_m06_overlay.ps1` verifies the M179 source lineage, the route start against M-01, selected-D SHA256, M-06/B unassigned status, and SHA256 values for all five RFAs currently in `Revit/Family_Intake/Incoming`. The retained output and two independent PowerShell 5.1 replays pass **21/21**; JSON, checks, CSV, and SVG match byte-for-byte, and the SVG parses as XML.

| Artifact | SHA256 |
|---|---|
| `m185-dogleg-m06-overlay.json` | `C6344F9BDA51EF6FA45DA18C6FC2F336FD301E0D4828E4A89B6164567FD74FFE` |
| `m185-checks.json` | `9477D3A2595F02FA47D624A53682FA2ECAD82427551425F140BBCB8365CAEF80` |
| `m185-route-comparison.csv` | `9201BC3ACF7756671D27B34FA67D68A2A550EA9786D8146038E9811B8984DDDC` |
| `m185-plan.svg` | `3208BFA943E4F0978CD378A71A17F7BC7AAC29C2D1FC5B275044C407C7B8D474` |

The selected-D source remains SHA256 `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`. All five Incoming RFAs remain byte-identical to the fingerprints recorded in the JSON. No Revit, IFC, selected-D, or remote state changed.

These are schematic axis-aligned rectangles, route-width proxies, and one explicitly assumed 24-in stool-use depth. No physical walls or openings, door operation, pulled-back occupants, product seating envelope, service routing, whole-shell fit, Revit host placement, or IFC export is tested. The blocked west rectangle is a diagnostic, not a bath. This report establishes no accessibility, code-compliance, structural-safety, professional, permit, or construction-readiness conclusion.
