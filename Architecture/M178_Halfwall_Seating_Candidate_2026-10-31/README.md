# M178 - Half-wall, island seating and route candidate

**Status:** unapproved, source-bound dimensional proposal. No kitchen or house layout is selected.

M178 rotates the compact kitchen test envelope to 13.5 x 14 ft (189 sf) and places the documented components in a coordinated cross-section: 24 in perimeter cabinets, 42 in work aisle, 4 ft island, 42 in island-to-half-wall aisle, and a 6 in half-wall. The 12.5 ft source-sized perimeter run lies along the separate 14 ft axis. Dining remains 11 x 10 ft and the porch 12 x 10 ft.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\build_m178_halfwall_seating_candidate.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\build_m178_halfwall_seating_candidate.ps1 -OutputDirectory .local\revalidation\M178-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\build_m178_halfwall_seating_candidate.ps1 -OutputDirectory .local\revalidation\M178-replay-b
```

The process-scoped execution-policy argument was needed because this machine refuses direct script-file execution under its default policy. No persistent Windows or security setting was changed. The two scratch runs should produce identical output files.

## Candidate geometry

- The 13.5 ft cross-section is exactly 2 + 3.5 + 4 + 3.5 + 0.5 ft. The 12.5 ft cabinet run has 1.5 ft total end reserve along the 14 ft axis.
- Island-to-counter and island-to-half-wall distances both measure 42 in. The 36 in route uses the side aisle with 3 in geometric margins on each side.
- A 7 ft half-wall, 6 ft opening and 1 ft return occupy the proposed 14 ft living-side edge. The route enters from the living-side test area through the opening, passes the island and dining furniture proxies, crosses the nominal 5 ft door reservation, then extends 3 ft into the porch.
- Two 24 in stool-occupancy proxies are placed against the 4 ft island end toward dining. Together they consume all 48 in and leave no side allowance. This is a geometric assumption, not a measured stool product or confirmed seating orientation.
- The candidate kitchen exceeds the 168 sf program-area target by **21 sf**. It retains the 110 sf dining target. These are program targets, not approval for the candidate room shape.
- The dining-route corridor projects **21 in east** of the dining test-zone edge into unassigned space. M04/pantry and other adjacent room conflicts are not included in M178.

## Verification and limits

The retained package and two scratch runs pass **26/26** checks. Their JSON, CSV and SVG artifacts match byte-for-byte; the SVG parses as XML. The check covers source fingerprints, arithmetic, candidate bounds, aisle dimensions, route obstacle intersections, dining furniture proxies and the unassigned-area spill.

Appliance-open envelopes, real chair/stool occupied movement, physical wall construction, door swing and clear width, threshold, overall shell, adjacent rooms, M-06 fixture/service route, Revit host execution and IFC export remain unverified. The study does not change selected-D or assign M-06/B. It establishes no accessibility or code compliance, structural safety, professional certification, permit approval or construction readiness.
