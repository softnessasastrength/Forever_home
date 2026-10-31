# M41 — upper-suite private contact screen

Status: **bounded single-room placement diagnostic; no candidate adopted**. This is a first geometric test of the owner-directed U-02 ↔ U-03 private link. It moves or rotates only U-03 while keeping the selected-D U-02 block, other room/circulation blocks and projected lift reservation fixed. The source upper-landing location is recorded as a boundary marker only; no route or landing clearance is tested.

## Owner direction carried forward

- Private sequence: U-01 → C-PRIVATE → U-02 → U-03.
- U-03 has no direct shared-hall door.
- U-04 retains independent guest-hall access; U-03 ↔ U-06 ↔ U-04 Jack-and-Jill connections remain required.
- U-05 remains primary-only.
- Room sizes and the selected-D source are unchanged. The 36×32 ft upper-wing box, +6 ft plan-frame relation, nominal 0.5 ft wall gap, source 3.5 ft door reservation and lift reservation are inherited schematic inputs, not construction dimensions or approved door clearances. The upper-landing coordinate is only a reference marker for later route testing.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m41_upper_suite_private_contact.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m41_upper_suite_private_contact.ps1 -OutputDirectory '.local/revalidation/m41-contact-replay'
```

The generator checks an output path remains inside the repository. It emits `contact-screen.json`, `checks.json`, `contact-screen.svg`, and `manifest.json`; hashes below make the pair of clean scratch replays auditable.

## Result

The PowerShell 5.1 screen enumerates **486** one-room placements on the inherited 1/6 ft grid: two U-03 orientations against four sides of fixed U-02, with at least the source-derived 3.5 ft nominal contact reservation. **243** placements are contained in the 36×32 ft test envelope. **Zero** contained placements avoid all unchanged room/circulation rectangles and the projected lift reservation. The upper-landing marker is not a route or clearance test.

Among placements inside the test envelope, moving U-03 east of U-02 gives the smallest recorded intersection: **49.5 sf**, comprising **36.6667 sf** with C-UPPER and **12.8333 sf** with U-06. This is an interference score, not floor area to remove or a feasible plan. It shows that the direct U-02 contact can be tested without overlapping the current lift projection in one arrangement, but doing so requires relocating/replanning the shared hall and Jack-and-Jill bath. The best overall single-room shift is therefore **not** a complete upper-suite layout; public-route continuity, U-03/U-06 door contact and U-04/U-06 access are not solved by it.

Per-side results:

| U-03 side relative to U-02 | Placements | Inside envelope | Clear of all fixed blocks/lift | Minimum intersection among contained placements |
|---|---:|---:|---:|---:|
| East | 83 | 83 | 0 | 49.50 sf |
| West | 83 | 0 | 0 | N/A |
| North | 160 | 0 | 0 | N/A |
| South | 160 | 160 | 0 | 82.50 sf |

Two independent scratch runs pass **12/12** integrity checks and match byte-for-byte. `contact-screen.json` SHA256: `E28B62F163DA91C0FEFF9177B6E9EA419D9095E32D16250521931CC92D0227F1`; `checks.json`: `5EA873CEB82E523123AE868C6B6CB44AA18531D3A6B1F6E7DA48FE0AAE392981`; SVG: `72BEE02F9AF5B5A0A29702D453E0858EF0AB8A7CE0D9F026C77DCF2D7423E5D9`; manifest: `A3AB9E7EC4AD566732C38E7D0ABCF5588785F69189E3BBB2365A335E7DC33F20`. JSON and SVG/XML parse successfully.

## Design implication and limits

This excludes only the simplest strategy of moving U-03 alone while the rest of the upper plan stays fixed; it does **not** establish that a broader upper-floor re-layout is infeasible. The next legitimate comparison must co-place U-03, U-06, U-04 and C-UPPER around the fixed private chain and lift reservation, then test a continuous public 4 ft route to the upper landing. If no candidate preserves those inputs, the owner will need to choose which reservation or room placement may change before any corresponding selected-D edit.

No actual door, wall, stair, floor opening, headroom, furniture, service, roof or Revit/IFC geometry is authored. There is no accessibility, code, engineering, structural-safety or construction-readiness conclusion. M-06 B and the selected-D source remain unchanged.
