# M218 — Pantry door and approach sensitivity

**Status:** six static proxy cases reproduced; door direction and opening position remain unselected.

## Scope

M218 takes the M217 y=1.25 ft pantry comparison `(13.5, 1.25, 5, 7)` as a proposal and uses the documented 2 ft 6 in pantry-door reservation from `Architecture/Kitchen_Dining_Porch_Specs.md`. It compares lower, centered and upper opening positions on the assumed kitchen-facing shared edge, with the swing envelope placed into either the kitchen or pantry.

For this screen, the door leaf is **assumed** to be 2 ft 6 in wide, its 90-degree swing is bounded by a 30 × 30 in rectangle, and the kitchen-side approach is a 36 × 36 in rectangle centered at the opening. The latter uses the same width as the M215 circulation route only as an analysis proxy; it is not a code or accessibility requirement. M213/M186 and M215 are regenerated as inputs, and all cases are tested against their modeled obstacles, the protected west A region, unassigned east B and the porch route.

## Result

The retained package and two independent Windows PowerShell 5.1 replays each pass **6/6** checks and reproduce JSON, checks and CSV byte-for-byte. All six static options (3 opening positions × 2 swing directions) clear the modeled furniture, fixture proxies, A/B reservations and M215 route.

The direction changes the tradeoff, not the current static fit result:

- **Swing into the kitchen:** the 30 × 30 in swing envelope overlaps **6.25 sf** of the assumed 3 × 3 ft kitchen-side approach for every opening position. That overlap exists only while the door is open in this simplified check.
- **Swing into the pantry:** no overlap with the assumed kitchen-side approach is reported, but the same 6.25 sf door-swing box is inside the pantry. Shelving and storage have not been modeled, so this does not establish a workable pantry interior.

Lower, centered and upper opening positions have identical aggregate obstacle results in the current proxy model. The study therefore does not support choosing a door position or handing one direction to the native model as settled design.

## Reproduction

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m218_pantry_door_approach.ps1 `
  -OutputDirectory Architecture/M218_Pantry_Door_Approach_2026-10-31/artifacts `
  -ScratchPrefix M218verified

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m218_pantry_door_approach.ps1 `
  -OutputDirectory .local/revalidation/M218-verified-replay-1 `
  -ScratchPrefix M218verr1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m218_pantry_door_approach.ps1 `
  -OutputDirectory .local/revalidation/M218-verified-replay-2 `
  -ScratchPrefix M218verr2
```

| Retained artifact | SHA256 |
|---|---|
| `m218-pantry-door-approach.json` | `946AAF98FC44FA67CD5546168FECD896D4C36543BC097553C75C7389385A3D43` |
| `m218-checks.json` | `B2BAA9EB4FFA8D869BF660C3FD5970481E3F1A37D167088A5037E7BA962231B6` |
| `m218-door-options.csv` | `5B11754164A9E4C2552B0F55219AFC4552439054C1C6E97EE7B25456506FCADD` |

## Limits and next gate

The room-program studies use a 5 × 7 ft pantry while the kitchen specification says 5 × 6 ft; M218 follows the owner-authorized 5 × 7 ft sensitivity and edits neither source. No wall build-up, rough opening, clear width, jamb, threshold, hardware, exact hinge behavior, shelves, stocked items, occupant maneuvering or plumbing/service route is modeled. The swing boxes and approach rectangles are screening proxies, not product geometry or a code determination. M-06/B remains unassigned, west A remains protected, and no selected-D, RVT, IFC or source RFA changed. No code, accessibility, structural, professional, permit or construction-readiness conclusion follows.
