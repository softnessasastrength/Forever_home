# M190 — Recheck the north-shift dining route against chair pull-out use

**Status:** audit passes; the unapproved M188 route candidate fails the chair-use proxy. No furniture, room arrangement, or route is selected.

## Finding

M188's only route-restoring one-foot translation moves the table and four documented 18 × 20 in chair bodies one foot north inside the 11 × 10 ft dining study block. Its 56.5 ft, seven-turn route has zero extra geometric gap at the table edge and 6.5 ft of travel in unassigned space.

The dining specification asks for 36 in minimum chair pull-out and says seated chairs must not block through-circulation. M190 tests an explicitly limited interpretation: for each chair, a rectangle the width of the chair seat extending 36 in outward from the table edge. Against that proxy, the north-shift route intersects the south-chair use zones by **1.5 sf union area**: 0.5 sf at chair 1 and 0.75 sf at chair 2, with 0.75 sf of additional raw overlap at the corner already included in the union. This is a geometric conflict in an unapproved study, not proof of universal infeasibility.

The script reconstructs the swept corridor from the compressed route centerline: 36 in segment rectangles plus 36 in square caps at endpoints and actual turns. M186's serialized form contains 383 overlapping rectangles for this path because it emits a corner square at each grid node, including collinear nodes. The simplified union is used for M190 overlap arithmetic; M186 itself remains unchanged.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m190_dining_pullout_route.ps1 -OutputDirectory .local/revalidation/M190-replay-01 -ScratchPrefix M190-replay-01
```

Use an empty output directory and a unique scratch prefix. The script makes one guarded M186 north-shift runner in the tool directory, runs it under `.local/revalidation/`, removes the temporary script in `finally`, and writes JSON, checks, CSV and an SVG. It refuses to overwrite a nonempty output folder and binds the relevant M186/M188, room specification, selected-D and bath-first sources by SHA256.

The retained run and independent replay both pass **8/8** method/invariant checks; four output files match byte-for-byte. SVG XML parses. Retained hashes:

| File | SHA256 |
|---|---|
| `m190-dining-pullout-route.json` | `8D30758B40CC4D8CB6AF855350E20E666074A7D9D21BBA166A87E4BD7E964667` |
| `m190-checks.json` | `FD83F16D15B17EB9A130AE1FACB9A5410F636C45314DC0B2EA5114CCF37635BF` |
| `m190-intersections.csv` | `F7557A9E6056CC9F5E743C366C4DBE874FC027FF4E26C2D59D14D4261705452A` |
| `m190-dining-pullout-route.svg` | `DE07810A6F0DDD774CE6D2C31037D2B4916CC4F8CDEBAE8CA57BC92301570256` |

## Limits

- The repository specifies 36 in pull-out but does not define an exact chair product, occupant envelope, swept motion, or measurement convention. The rectangular interpretation is a labeled study assumption.
- The preferred 42 in wall/porch-door distance cannot be checked without coordinated walls and clear door geometry.
- The route, 40 × 42 ft test shell, 13.5 × 14 ft kitchen candidate, and furniture position are unapproved comparisons. No physical Revit/IFC geometry is established.
- Selected-D and all Incoming RFAs remain untouched. M-06/B remains unassigned. No code, accessibility, structural-safety, professional, permit, or construction-readiness conclusion follows.
