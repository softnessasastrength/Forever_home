# M193 — compact island fit screen

**Status:** unapproved, source-bound plan arithmetic. Selected-D is unchanged.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\analyze_m193_compact_island_fit.ps1 -OutputDirectory .local\revalidation\M193-replay
```

The script refuses to overwrite a nonempty output directory. The retained current package is under `artifacts-v2/`; the initial 9-check package remains preserved in `artifacts/`.

## Inputs and finding

Inputs are fingerprinted from M172, `Kitchen_Dining_Porch_Specs.md`, `Kitchen_Island_Finish.md` and the owner-selected-D source. The test applies the owner-directed 14 × 12 ft / 168 sf **clear-interior** kitchen, the 12 ft 6 in perimeter run, 24 in counter/base depth, 42 in minimum aisle proxies, 12 in seating overhang and a 6 in half-wall. The room specification defines its dimensions to clear interior faces, excluding wall thickness. M193 places the half-wall face at the 12 ft clear-room boundary and its thickness outside that clear depth; counting it inside the clear dimension would mix gross wall thickness with the specified clear room size.

The unchanged 8 × 4 ft island does not fit the 14 × 12 ft clear rectangle under those aisle proxies: the clear cross-section is 13 ft, and 42 in end allowances plus the 8 ft island span 15 ft. Two flexible study alternatives meet the arithmetic:

| Proposal | Counter split | Island area | Clear-axis reserve | Trade-off |
|---|---|---:|---|---|
| 7 × 3 ft | 5 ft quartz + 2 ft butcher block | 21 sf | 0 in crosswise; 0 in at ends | Preserves the 2 ft butcher section; no geometric allowance at the tested limits |
| 6 × 3 ft | 4 ft quartz + 2 ft butcher block | 18 sf | 0 in crosswise; 12 in total at ends | More end reserve; gives up another foot of quartz length |

Both 3 ft depths derive from a 24 in body plus the selected 12 in seating-side overhang. The 7 ft length derives from the 14 ft room axis less two 42 in end allowances; the 6 ft comparison leaves 12 in total. The run leaves 18 in total along that 14 ft axis. A 7 × 2.5 ft stress case is rejected because it would reduce the body to 18 in, below the documented 24 in body-depth input.

M193 passes **10/10** checks in two independent scratch runs and the retained Windows PowerShell 5.1 package. The additional gate verifies every upstream fingerprint recorded by M172 still matches the current repository. The owner-reference island's body/overhang decomposition is explicitly left unknown. JSON, checks, CSV and SVG match byte-for-byte between the retained `artifacts-v2/` package and both scratch runs, and the SVG parses as XML.

## Open design gates

Neither alternative has real stool-family widths, side margins, occupied-use motion, appliance-open envelopes, installation tolerances or a coordinated door/route. The 7 × 3 ft option uses the entire arithmetic envelope; even the 6 × 3 ft option has no cross-section reserve. The half-wall face, 7 ft wall / 6 ft opening / 1 ft return, dining adjacency and circulation are not yet positioned as a coordinated plan. The revised countertop splits preserve the desired 2 ft butcher section but alter the prior 6 ft quartz intent, so the owner has not selected either.

The next geometry gate is one integrated candidate with this 14 × 12 ft kitchen, island, documented dining table and four chair-use proxies, the 36 in route, proposed openings and the 12 × 10 ft porch. Only a route-qualified plan should advance to a disposable Revit wall/opening study. M-06/B remains unassigned. No Revit/IFC, selected-D, source RFA or remote state changed. No code, accessibility, structural-safety, certification, permit or construction-readiness result is claimed.
