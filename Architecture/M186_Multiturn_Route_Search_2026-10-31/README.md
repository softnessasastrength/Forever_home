# M186 — Bounded multi-turn public-route search

**Status:** no candidate found on the declared analysis grid. No route, room, or furniture arrangement is selected. M-06/B remains unassigned.

## Reproduce

From the repository root in Windows PowerShell 5.1, run into two empty scratch folders:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\search_m186_public_route.ps1 -OutputDirectory .local\revalidation\M186-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\search_m186_public_route.ps1 -OutputDirectory .local\revalidation\M186-replay-b
```

Compare `m186-route-search.json`, `m186-checks.json`, `m186-route-summary.csv`, and `m186-route-search.svg` against the retained `artifacts/` folder and each other. Each run passes **29/29** integrity and search-contract checks. All four outputs match byte-for-byte; the SVG parses as XML. The script refuses to overwrite a nonempty output folder.

## Search setup

The deterministic breadth-first search uses quarter-foot centerline nodes within the translated owner-selected 40 x 42 ft main-shell test envelope. The quarter-foot value is only the search resolution. A swept 36-in corridor is checked against M-04 pantry, both source M-06 search windows, M-05 entry, the M178 casework/island/stool/half-wall proxies, dining table/chairs, and porch-wall segments. The route starts at M180's point inside M-01, crosses the M178 nominal 6-ft opening at `(13.5, 10) ft`, and must reach the nominal 5-ft porch-door center at `(8.5, 24.5) ft` before extending 3 ft into the porch. The search cannot enter the porch by any other edge.

## Result

No path reaches the porch-door center under those combined constraints. The search exhausts its connected region: **5,299 of 23,088** grid nodes are reachable. The nearest reachable centerline point is `(18.5, 24.5) ft`, still **10 ft** away by Manhattan distance. The most frequent blocked frontier edges meet the reserved east/B window (140), island (113), half-wall (73), M-05 entry (70), pantry (40), assumed stool-use proxy (37), and blocked west diagnostic (19). These are search-edge counts, not a measure of physical severity. The SVG shows the test blocks and no route line.

The earlier M179 dogleg is not the answer: it starts outside M-01 and has both M-06 and stool-proxy conflicts (M185). M186 does not prove that every continuous route is impossible; it shows that the current bounded room/furniture proxy arrangement offers no sampled 36-in route under the stated keep-out regions. A route may require a room/furniture adjustment or a different, owner-approved space tradeoff.

## Provenance and limits

The report fingerprints M172, M173, bath-first blocks, M178–M180, M185, the M179 generator source, and selected-D. It records all five current Incoming RFA hashes. Selected-D remains SHA256 `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`; no selected-D, Revit, IFC, or RFA file was changed.

M-06/B is reserved in the search only to protect the owner's first-fit candidate; it remains an unassigned 92.17-sf room-block gap, not a bath. The west search area is already blocked by other candidate room blocks and is only a diagnostic. The 24-in stool-use depth is assumed, not measured family geometry. The 13.5 x 14 ft kitchen is still an unapproved 189-sf proposal, 21 sf above the 168-sf target. This is not a physical wall/door/furniture-movement model and establishes no usable or accessible route, code compliance, structural safety, professional approval, permit approval, or construction readiness.

| Artifact | SHA256 |
|---|---|
| `m186-route-search.json` | `5E3C5CCDC5ABF45F147666CA461E3AEC79669A77B577E2783C441A50403234CA` |
| `m186-checks.json` | `5A706FD403AB141A9E1A242DF4CAABBD13075CC6C868ABC90C37AA02ACF25E15` |
| `m186-route-summary.csv` | `451FE7006D4B169E860A740AAC7F8C26C51CA3D3AA8015AE5BAF5A2C20579569` |
| `m186-route-search.svg` | `43BBED3C437C412AEAF36B933B6AE4020002B83FCAA24F0140242379CE7D454A` |
