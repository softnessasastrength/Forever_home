# M30 — Upper-suite adjacency audit

**Status:** reproducible audit complete; an unresolved private-suite topology conflict is recorded. No room, door or selected-D baseline geometry was changed.

## Finding

The owner-approved room program describes a `Primary ↔ boutique ↔ hybrid` sequence, calls for internal suite connections, and the selected-direction record retains a private connector. The current selected-D door matrix connects U-01 to U-02 through C-PRIVATE, but gives U-03 only nominal doors to shared C-UPPER and shared bath U-06. If “suite connection” means a route that does not pass through the public/shared hall or Jack-and-Jill bath, the private sequence stops at the boutique. The upper-level drawing also gives U-02 a nominal door edge to C-UPPER.

Other recorded relationships are represented topologically: U-04 has a direct nominal edge to C-UPPER, U-03 and U-04 each have an edge to U-06, and U-05's only nominal neighbor is U-01. These are graph relationships from the study's door matrix, not verified built openings.

The interpretation is intentionally explicit. The documents do not say whether the hybrid must share the private connector or may be reached separately from C-UPPER while sharing U-06 with the guest. That distinction changes privacy, access and room layout. Until it is decided, do not silently describe the current scheme as demonstrating the complete private primary/boutique/hybrid chain.

## Reproduction

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m30_upper_suite_adjacency.ps1
```

The script writes `upper-suite-adjacency-audit.json` here. On 2026-10-28, two independent scratch runs passed **11/11** source-contract and graph checks and produced byte-identical JSON, SHA256 `A966DBBE086DF29B2B1F8909715A5566CD4C7E38AF245E758A93560E8ECB3B67`. The audit pins the selected-D study, room program and direction decision hashes.

## Next design gate

Choose between retaining independent hybrid-to-hall access with no private primary-suite continuity, or testing a derivative that connects U-03 to the private sequence. A derivative would need to preserve U-04's independent hall access and U-03/U-04 shared-bath relationship, then check actual walls, door leaves/swings, furniture, privacy and routes. Neither option is selected here. Keep the selected-D study and Revit/IFC baseline untouched pending the design choice.

The nominal 3.5 ft reservation values are not clear-opening dimensions. This audit does not establish code compliance, privacy acoustics, egress, accessibility, structural adequacy, Revit geometry or construction readiness.
