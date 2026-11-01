# M214 — M213 route-tangency diagnosis

**Status:** reproducible failure diagnosis; no route or room layout selected.

## Question

M213 reports a 33.5-ft route and a 3-in reserve to protected west A, but flags `route_nonfragile: false`. This note identifies the boundaries that set that result before any route candidate is advanced to Revit.

## Method and evidence

The 13.25-ft M213 candidate was regenerated twice in separate ignored scratch directories using the documented PowerShell command. Both runs passed 13/13 M213 checks and their three retained M213 outputs matched byte-for-byte. Each run also regenerated its M186 route report and obstacle-clearance CSV; the two files matched byte-for-byte:

| M186 diagnostic output | SHA256 |
|---|---|
| `m186-route-search.json` | `871B876F15F0950D68EF4667D89D37B63155E24B868D7C04E6D6E0B3C6C45684` |
| `m186-route-summary.csv` | `D8E0CBD1C91DE4543D2A36A7760AB2F5C89549B909DD1A0E5633E86F679FC9D1` |

The route centerline is `(19.5,10) → (18.25,10) → (18.25,28.5) → (9,28.5) → (9,33)` in the study coordinate frame. It is 33.5 ft long with four turns. The per-obstacle clearance table reports **0 ft** to both `west_of_core` and `porch-wall-east-of-door`. The first is the analytically expanded A reservation: the original A boundary remains 0.25 ft (3 in) from the route, exactly the study buffer. The second is a tangency to the porch-face wall adjacent to the nominal door opening. The other recorded obstacle gaps are positive.

Thus the path passes the M186's no-positive-area-overlap contract, but it has no reserve at two modeled obstacle boundaries. A zero-area touch is not evidence of a robust physical opening or circulation layout.

## Reproduction

Run twice with separate empty destinations:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m213_kitchen_margin_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M214-m213-replay-1 `
  -ScratchPrefix M214-r1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m213_kitchen_margin_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M214-m213-replay-2 `
  -ScratchPrefix M214-r2
```

For each run, inspect `.local/revalidation/M214-r1-depth13_25_proxy_margin/m186-route-summary.csv` (substitute `M214-r2` for the second run). The generated source route reports and M213 packages should match the hashes above and the committed M213 package hashes.

## Limits and next gate

This diagnosis inherits M213's hypothetical 40 × 42 ft test shell, 13.25 × 13.5 ft kitchen comparison, assumed furniture/stool rectangles, 36-in axis-aligned path, nominal 5-ft porch opening and 3-in A-search buffer. These values do not define a selected design, finished opening, door leaf/swing, or applicable code clearance. M-06/A remains protected and M-06/B remains unassigned. Selected-D, Revit, IFC, RFAs and remote refs were not changed.

Before a disposable Revit placement, a new bounded route study must show positive separation from the protected-A reservation and porch-face wall while preserving the owner's open kitchen/living preference, pantry comparison and table-use proxies. That study remains schematic until physical wall, door, approach, product and site geometry are known. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
