# Revit 2027 compact-core implementation brief

Date: 2026-10-25
Status: **implementation proposal; not an approved geometry freeze**

This brief turns the schematic recommendation into the next native-Revit test. It retains Option B's main-level sleeping/bathing strategy, but does not accept B's 40 x 42 ft main plate or its unassigned lower allowance as final. The target is a compact, auditable core that can be rejected without losing the two schematic alternatives.

## Target study (C — compact B strategy)

| Item | Test target | Why it is a target, not a decision |
|---|---:|---|
| Main/front shell | 40 x 40 ft | Removes 80 sf from B while preserving the 40 ft frontage and main-level L-02 concept |
| Rear lower/upper shell | 36 x 32 ft each | Retains the stacked private-room inventory for comparison |
| Main-level L-02 | 11 x 10 ft | Preserves the relocated flex sleeping-room program; dining-side privacy remains a live test |
| Main full bath | 9 x 10 ft | Retains the proposed daytime bath; fixture transfer/approach is not yet verified |
| Core reservation | 8 x 8 ft lift shaft plus two 4 ft stair flights and 4 ft landings | Reservation only; product car, doors, pit, overrun, structure and fire separation remain unselected |
| Vertical study | 8 risers per half flight, 7.5 in nominal, 11 in treads | Carries B's lower-rise tradeoff; native headroom and finish buildup must pass |
| Lower/upper separation | 10 ft datum-to-datum with 15 in placeholder assembly | Produces 8 ft 9 in arithmetic clear height only; not a structural or code result |
| Technology room | Move out of the footprint below Jack & Jill wet routes | Prevents the identified wet-stack/noise/service conflict; exact lower location is a native-layout test |

The compact target is intentionally a **test envelope**. If rooms, landings, door maneuvering or a selected lift cannot fit, record the failed dimension and return to B/A rather than silently shrinking clearances.

## Native Revit acceptance checks

Create a separate study model or detached working copy. Do not replace the compatibility fixture or imply that this is the finished house model.

1. Establish shared levels and named grids for lower, main and upper datums. Record actual floor assemblies separately from the 15 in placeholder.
2. Model the stair as native runs with landings, rail/guard placeholders and a visible headroom check. The 7.5 in rise is a starting constraint, not a compliance claim.
3. Place a product-neutral lift shaft and a clearly labelled `LIFT_RESERVATION_NOT_PRODUCT`. Add a parameter or note for pit, overrun, door side, landing depth and minimum stop separation. Do not call the shaft accessible until a selected product layout passes.
4. Put main-level entry, living, kitchen, dining, L-02 and M-06 in one route test. Check door clear openings, approach rectangles, furniture and the dining-side privacy door without using the bath as a corridor.
5. Move the lower technology room so no Jack & Jill plumbing route is directly above it. Reserve a dry service chase, leak-protection zone, equipment replacement path and low-voltage route. Record the chosen location and the reason in the coordination register.
6. Test the main-bath underfloor drain/service route because the main wing is not vertically stacked over the lower occupied wing.
7. Add room/asset IDs matching the schematic (`M-01`…`M-06`, `L-01`…`L-07`, `U-01`…`U-06`, `S-01`, `C-LIFT`). Export a schedule and verify IDs survive IFC2x3 and CSV.
8. Save a native RVT and backup, then run the existing Revit Pilot export checklist. This study is successful only if the source reopens and the export evidence identifies any semantic loss.

## Explicit reject/hold conditions

- Any stair headroom, landing, guard, floor-edge or structural clash is unresolved.
- The selected lift's pit/overrun/doors or landing cannot be represented without reducing the target clearances.
- L-02 access requires crossing the dining table/chair envelope, or privacy cannot be separated from the public hall.
- Technology equipment cannot be serviced without passing through wet areas or the main route.
- The main bath drain/service route requires an unmodeled ceiling chase or an unreviewed lower-room penetration.
- A room is made smaller only to make the compact plate appear to fit.

## Current decision boundary

C is the recommended **next test**, not the selected house plan. B remains the comparison parent and A remains the seven-riser comparison. After the native checks, the owner can select C, retain B, or reopen A; all rejected geometry and tradeoffs must remain documented.
