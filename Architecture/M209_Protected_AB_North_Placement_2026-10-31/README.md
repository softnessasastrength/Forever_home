# M209 protected-A/B northward dining and porch search

**Status:** Reproducible route sensitivity; no placement selected.

## Scope

The owner directed the search to protect west window A for the unresolved M-06 half bath. M209 tests eleven quarter-foot northward translations of the 11 × 10 ft dining block and 12 × 10 ft porch, from 4.0 to 6.5 ft, in the hypothetical 40 × 42 ft shell. It retains the M178 13.5 × 14 ft kitchen proposal, 8 × 4 ft island, 5 × 6 ft east/south pantry position, four-chair proxy and east porch-door sample. The kitchen/living connection is fully open per the owner’s preference. Both A and B remain route obstacles; B remains unassigned.

This is a schematic reachability study. The dining and porch translate together; their specified areas remain 110 and 120 sf. No placement is selected, and this is not an exhaustive placement search.

## Results

The retained Windows PowerShell 5.1 run and two independent replays each pass 9/9 wrapper checks. Each embedded M186 route run passes its own checks. JSON, checks and CSV match byte-for-byte across the retained run and both replays.

Five of eleven offsets find a sampled 36-in route, first at 5.5 ft north. At that first passing offset, the route is 33.5 ft long with four turns. Its minimum modeled gap to A is 0 ft: it is tangent to A, and none of the five passing cases meets the 3-in proxy reserve threshold. A tangent route is not a fit-ready circulation solution. The porch’s north edge reaches y=30 ft at the first passing offset and remains within the hypothetical shell; wall construction and door/opening details are not modeled.

The finding demonstrates reachability under this proxy setup only. It does not establish a usable route, room fit, a selected design, or code/accessibility compliance.

## Reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m209_protected_ab_north_placement.ps1 `
  -OutputDirectory .local/revalidation/M209-replay-1 `
  -ScratchPrefix M209-r1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m209_protected_ab_north_placement.ps1 `
  -OutputDirectory .local/revalidation/M209-replay-2 `
  -ScratchPrefix M209-r2
```

The script refuses nonempty output directories and fails if source-bound acceptance checks do not pass. Retained results are in `artifacts-v4/`:

| Artifact | SHA256 |
|---|---|
| `m209-protected-ab-north-placement.json` | `D966DE2868724712D030B750E17184A0818D53625577DAF4FE57A4F8563BCEF8` |
| `m209-checks.json` | `0B5EE52F8C28FC385A84B842AC8B02559D3FC05CFAB1958F11E9080D0B95E083` |
| `m209-candidates.csv` | `CAE782076ED44D8796017AA801276327E9E8AB4A71CFBB8A6E2D5CE049A687D8` |

## Limits

The 24-in stool depth and chair/use rectangles are assumptions/proxies, not measured product or occupant geometry. Porch walls, rough opening, door leaf/swing, threshold, exterior enclosure, services and site fit are absent. Appliance operation and construction tolerances are untested. The 13.5 × 14 ft kitchen and translated dining/porch are exploration proposals only. Selected-D remains SHA256 `516d6d17e5b6ed6c8ec8cbf7a925cc67c5cc1c0ada194c22ea3fa124e2bb72bb`; Revit, IFC, Incoming RFAs and remote state were not changed. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
