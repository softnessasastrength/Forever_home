# M242 — Close the hall/kitchen block gap: porch-route sensitivity

**Status:** analysis-only candidate, not selected. This tests a westward M-02 shift equal to the measured 6-in gap in M241. Kitchen gross area is preserved; selected-D remains unchanged.

## Reproduce

Run from the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m242_hall_kitchen_gap_vs_porch_route.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m242_hall_kitchen_gap_vs_porch_route.ps1 -OutputDirectory .local/revalidation/M242-replay-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m242_hall_kitchen_gap_vs_porch_route.ps1 -OutputDirectory .local/revalidation/M242-replay-2
```

The PowerShell 5.1 script pins selected-D, M215 route, M228 coordinate-frame origin and M241 interfaces. It translates the candidate kitchen and M215 route into the same selected-D coordinate frame, then measures distance from the route centerline to the candidate block and subtracts half the documented 36-in route width. The route consists of axis-aligned segments; the script rejects nonorthogonal input rather than silently approximating it.

## Result

All three runs pass **13/13** checks; report/check JSON match byte-for-byte. Checks SHA256: `44b68032dd98186920373ac4bd4b82fd204c15bc979094a44ab877d81eb0c5b3`. Report SHA256: `54c197565569919636ea0fa851e86fcb05fccc5b11a6b4841a09e7f6dbdb8711`.

| Measure | Selected-D M-02 block | Candidate M-02, 6 in west |
|---|---:|---:|
| Gross room block | 17 ft 4 in × 16 ft = 277.333 sf | Preserved |
| M-05 / M-02 gap | 6 in | 0 in; 12-ft shared block edge |
| Nearest M215 route-centerline distance | 22 in | 16 in |
| Net clearance to 36-in route proxy | +4 in | −2 in (2-in intrusion) |
| Overlap with checked room blocks / A / B / dining proposal / M-04 | — | 0 sf each |

This one candidate closes the schematic hall/kitchen gap without overlapping the other checked room rectangles, but it conflicts with the fixed M215 route proxy at the kitchen edge. The owner-directed M-01 east sensitivity also touches M-05; this still proves no actual wall opening, continuous walk path, or visually open connection.

## Limits and next evidence

M215 is one schematic route candidate. Its conflict with this test does not prove every route alignment fails. The 36-in width is an analysis proxy, not a claim of Connecticut code compliance. Rectangular room bounds are not wall faces or finished clear dimensions. No kitchen location, opening, door, route, room assignment or design is selected; west A remains protected and B/M-06 unassigned. Re-route search, furniture/appliance operation, services, and Revit wall/opening geometry are not included. No professional, accessibility, structural, permit or construction-readiness conclusion follows.
