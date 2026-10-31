# M213 quarter-foot kitchen proxy-margin sensitivity

**Status:** One reproducible comparison case; no kitchen size selected.

## Scope

M212's 13-ft envelope contains the current casework/island/stool proxies with zero margin. M213 tests one intermediate 13.25-ft depth, using the existing quarter-foot analysis increment. It holds the 13.5-ft cross-section, 8 × 4 ft island, 12.5-ft casework run, 5.5-ft north dining/porch position, x=9-ft porch door, open kitchen/living connection and M211 3-in A-search reserve fixed. The casework run is centered in the tested depth.

The 13.25-ft depth is a sensitivity between M212's 13 and 13.5 ft cases. It is not an owner-selected room dimension, product dimension or code requirement.

## Results

The retained run and two independent PowerShell 5.1 replays pass 13/13 checks, and the embedded M186 route run passes 31/31. JSON, checks and CSV reproduce byte-for-byte.

At 13.25 × 13.5 ft, the test area is **178.875 sf**, or **10.875 sf above** the 168-sf program target. The assumed 12.5-ft casework run, 8 × 4 ft island and stool-use proxy all fit in the envelope; the stool proxy has 3 in of edge margin. The route passes at 33.5 ft and retains a 3-in modeled gap to A. This is arithmetic containment in schematic proxies, not a product-fit conclusion.

## Reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m213_kitchen_margin_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M213-replay-1 `
  -ScratchPrefix M213-r1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m213_kitchen_margin_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M213-replay-2 `
  -ScratchPrefix M213-r2
```

Retained results are under `artifacts-v2/`:

| Artifact | SHA256 |
|---|---|
| `m213-kitchen-margin-sensitivity.json` | `893EDCC4E0B836E83DE2516EB834F55B5CADF08BD8E8B75B1F737C833BF5F303` |
| `m213-checks.json` | `3D6B6B133456ECA48C7BB73766CCEDC4AFC82E1A19D8DACBCBDB54CC7B2ECFDC` |
| `m213-candidates.csv` | `BC1BE1F5EE03F044242FFC986B38C83B1A74017C5ACAA11C6C168E0F8EB5C1A1` |

## Limits

The stool depth remains an assumed rectangle. Three inches is the quarter-foot grid increment, not a required furniture or code clearance. Actual cabinets, appliances, doors, walls, utilities, finished dimensions, site fit and tolerances are unmodeled. No dimension is selected; M-06/B remains unassigned, west A remains protected, and selected-D/Revit/IFC/RFAs are unchanged. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
