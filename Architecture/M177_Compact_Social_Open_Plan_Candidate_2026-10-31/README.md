# M177 - Compact social open-plan route candidate

**Status:** unapproved plan-coordinate proposal. This is a test layout, not the house plan.

M177 tests a connected living-to-porch route while retaining the documented 168 sf kitchen and 110 sf dining program areas as area targets. It uses a 14 x 13.5 ft kitchen test envelope (189 sf, +21 sf) and an 11 x 10 ft dining envelope (110 sf). The 12 x 10 ft porch remains a 120 sf test rectangle. The owner has not selected these room rectangles or this furniture layout.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\build_m177_compact_social_candidate.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\build_m177_compact_social_candidate.ps1 -OutputDirectory .local\revalidation\M177-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\build_m177_compact_social_candidate.ps1 -OutputDirectory .local\revalidation\M177-replay-b
```

The two scratch directories should produce byte-identical files. `-ExecutionPolicy Bypass` is supplied to each short-lived PowerShell process because this machine's default policy refuses direct script-file execution; no persistent policy or Windows security setting was changed. The script refuses to overwrite a nonempty output folder unless explicitly passed `-OverwriteGenerated`.

## Results

The retained package passes **27/27** checks. Two isolated replays also pass **27/27** and match each other byte-for-byte. The four outputs are `m177-study.json`, `m177-checks.json`, `m177-checks.csv`, and `m177-plan.svg`; the SVG parses as XML.

The candidate places the 8 x 4 ft island with its 4 ft end toward dining, a 12.5 ft perimeter run composed of the documented cabinet modules, two assumed 24 in-deep stool-occupancy proxies, a 36 x 60 in table with four explicit chair proxies, a nominal 6 ft living-side opening reservation, and a nominal 5 ft porch-door reservation. A 36 in route corridor follows the 42 in modeled island-to-counter aisle, leaving 3 in on each side, continues through dining, bends above the table, and reaches 3 ft into the porch. It has no positive-area overlap with the closed-state obstacle rectangles in this candidate.

## Trade-offs and limits

- Kitchen area is 21 sf above the 168 sf program target. The additional area is an explicit proposal; no room-size change is approved.
- The route corridor extends **9 in east** of the 11 ft dining test zone into unassigned open-plan space.
- The candidate does not establish the separate documented **42 in island-to-half-wall clearance**. The 36 in route's 3 in margins apply only to its modeled counter aisle.
- Two stools occupy the 4 ft island end with no side allowance. Their body, pull-back and occupied envelope are unverified; 24 in is a plan-depth assumption.
- Appliance door/open-use envelopes, physical walls, swing arcs, thresholds and clear door widths are not modeled. Route passage with an appliance open is unknown.
- The table/chair arrangement is a geometric proposal. The route avoids stationary chair proxies, not moving occupants or pulled-back chairs.
- No site/shell fit, service route, M-06 fixture fit, roof, structure, Revit model, IFC, accessibility review, code review or professional review is included.

The study does not modify selected-D, assign M-06/B, or establish accessibility, code compliance, structural safety, professional certification, permit approval or construction readiness. Source hashes and check details are in `m177-study.json` and `m177-checks.json`.
