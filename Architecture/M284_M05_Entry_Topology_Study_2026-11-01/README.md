# M284 — M-05 entry topology and open-room comparison

Date: 2026-11-01
Status: **Analysis-only comparison; no layout, entry orientation, or room dimensions selected.**

The owner authorized comparison of all three paths: keep the current room-block baseline, test a presumed south/front M-05 row while moving M-01/M-02 into shared-edge adjacency, and test north/rear or east/side M-05 alternatives while also connecting M-01/M-02. This scope is recorded in `Decisions/2026-11-01_M05_Entry_Topology_Study_Scope.md`.

## Source and method

`Tools/M284Generator` pins the M282 source-block snapshot and selected-D source by SHA256, binds the prior M-05 analysis authorization, west-A protection decision, and owner-approved comparison scope, and fails closed if the source changes. It preserves M-01/M-02/M-05 orientation, size, and area; translates the M-01/M-02 blocks on their existing Y row in 0.25-ft increments; holds M-03/M-04 and protected-A/unassigned-B fixed; and checks positive-area overlaps using a 0.000001-ft per-axis tolerance. That tolerance filters the source's approximately 0.000004-sf floating-point edge sliver between M-01 and M-05.

The connected-pair search found 20 M-01/M-02 translations that fit the 40 × 42-ft test shell and avoid the fixed rectangles. Candidate examples are ranked by the sum of the blocks' origin translations, then the largest individual translation, with deterministic coordinate tie-breaks. The metric is a search rule only; it does not express design quality or occupant preference.

## Reproduction

From the repository root:

```powershell
./.local/dotnet/dotnet.exe build Tools/M284Generator/M284Generator.csproj `
  --configuration Release --output .local/revalidation/m284-build --ignore-failed-sources
./.local/dotnet/dotnet.exe .local/revalidation/m284-build/M284Generator.dll `
  Architecture/M282_M05_Move_Study_2026-11-01/source-block-snapshot.json `
  Decisions/2026-11-01_M05_Entry_Topology_Study_Scope.md .local/revalidation/m284-a
./.local/dotnet/dotnet.exe .local/revalidation/m284-build/M284Generator.dll `
  Architecture/M282_M05_Move_Study_2026-11-01/source-block-snapshot.json `
  Decisions/2026-11-01_M05_Entry_Topology_Study_Scope.md .local/revalidation/m284-b
```

Build completed with 0 warnings/errors. Both independent executions passed 15/15 checks and reproduced all three artifacts byte-for-byte. The retained SVG parses as XML.

| Tracked artifact | SHA256 |
|---|---|
| `artifacts/m284-entry-topology-screen.json` | `A7D8055B6E9A7F2983404C4089090CABEBD45385F3FD8BD8CF987309D782DF6B` |
| `artifacts/m284-checks.json` | `A6F65C1B8DE2A1545CB25AAC92B22C5477FB86B9B164DB6EFF201714B4EEEFC0` |
| `artifacts/m284-entry-topology.svg` | `3292C7B7D17E2B44F2611818649711102E65B33D04569390C9FE1939E894EFE8` |

## Comparison

The baseline keeps the M-01/M-02 gap at **4 ft 4 in** and makes no kitchen/living adjacency claim. A source-edge precision sliver between M-01 and M-05 is treated as contact within the stated tolerance.

The least-total-translation south-row example places M-05 at `(0.9167, 0.6667)` ft, M-01 at `(5.4167, 0.6667)` ft, and M-02 at `(21.4167, 0.6667)` ft. M-01 and M-02 have a 15-ft shared boundary; M-05 and M-01 retain a 2-in block gap. This keeps M-05 on the source Y row but does not verify a front door, foyer, arrival route, or exterior orientation.

For the side/rear path, the north/rear example places M-05 at `(17.25, 30)` ft and shares a 15-ft M-01/M-02 boundary. The east/side example places M-05 at `(35.6667, 0.75)` ft and likewise shares a 15-ft M-01/M-02 boundary. Both avoid fixed positive-area rectangle overlaps in this screen. The east example has 53 in to M-04 and 55.362 in to B by the rectangle-gap metric; those are schematic gaps, not verified circulation or clearance. These are candidate shell-edge contacts only, not actual door locations.

| Path | M-01/M-02 shared edge | M-05 position (ft) | Total translation (ft) | Door/approach/route |
|---|---:|---:|---:|---|
| Source baseline | 0 ft | `(17.1667, 0.6667)` | 0 | Not modeled |
| South-row/front hypothesis | 15 ft | `(0.9167, 0.6667)` | 20.5833 | Not modeled |
| North/rear edge | 15 ft | `(17.25, 30)` | 33.75 | Not modeled |
| East/side edge | 15 ft | `(35.6667, 0.75)` | 22.9167 | Not modeled |

All positions preserve room areas: M-01 240 sf, M-02 277.333 sf, M-05 52 sf. A shared edge indicates only a block adjacency opportunity. No wall opening width, door, landing, approach, exterior threshold, circulation route, furniture, wall thickness, structure, utilities, site, or code criterion is included. M-06 remains unassigned; A remains protected and B unassigned.

## Connecticut code cycle check

On 2026-11-01, Connecticut DAS's adoption-process page reported that the planned 2026 code effective date had been delayed pending Legislative Regulation Review Committee approval. It lists the proposed 2024 IRC and 2017 ICC A117.1 as expected model-code bases, not as adopted requirements. The current regulations page still identifies the 2022 CSBC, based on the 2021 IRC, as applicable to permit applications filed from 2022-10-01. This confirms M273's 2021 IRC fixture-spacing screen is the current statewide starting point as of this check; project applicability still depends on site, permit timing, building classification, adopted amendments, and the authority having jurisdiction. This is not a compliance review.

Sources: [Connecticut DAS adoption-process update](https://portal.ct.gov/das/office-of-state-building-inspector/building-and-fire-code-adoption-process) and [Connecticut DAS current-code regulations](https://portal.ct.gov/en/das/office-of-state-building-inspector/connecticut-state-building-code/regulations).

## Limits and next gates

The south/front and north/rear labels use schematic coordinate axes, not surveyed site orientation. The 0.25-ft search and source rectangles do not model room finish faces or circulation. The east alternative's location near the M-04/pantry and B search area needs detailed clearance review before any development. No alternative is selected. Before a disposable Revit opening study, establish the entry façade, door and approach, actual room opening geometry, site/porch relation, and vertical-section constraints. Keep M-06/B unassigned until exact product, applicable clearance, door/approach, and plausible services support a fit. No code-compliance, accessibility, structural-safety, professional-approval, permit, or construction-readiness conclusion follows.
