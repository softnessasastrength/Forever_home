# M184 - Retained social-route overlay against the pantry and M-06

**Disposition:** M173's retained route is not a complete solution for the bath-first room-block arrangement. No alternative route or room layout is selected. M-06/B remains unassigned.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m184_social_route_pantry_overlay.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m184_social_route_pantry_overlay.ps1 -OutputDirectory .local\revalidation\M184-replay-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\audit_m184_social_route_pantry_overlay.ps1 -OutputDirectory .local\revalidation\M184-replay-b
```

All runs should pass 10/10 checks. Compare the three generated files in the retained package and both scratch directories byte-for-byte. The script refuses to overwrite a nonempty output directory.

## Findings

M173 binds to the same bath-first room-block study that M181/M182 use. Its 36-in swept route intersects:

| Source rectangle | Route rectangle pairs with positive area | Raw pair sum | Union overlap |
|---|---:|---:|---:|
| M-04 pantry | 3 | 26.750 sf | **17.750 sf** |
| West M-06 diagnostic (already blocked) | 3 | 31.250 sf | **22.250 sf** |
| East M-06/B search window (unassigned) | 0 | 0 sf | **0 sf** |

The pair sum counts shared elbow area more than once. The union measure clips route rectangles to the target and merges overlaps before totaling area. This is why the report carries both values.

M173's zero-collision result remains valid for the kitchen/dining furniture and modules it checked. The new overlay adds the relocated pantry and M-06 diagnostic rectangles, exposing room-block conflicts beyond that original obstacle set. It does not show physical pantry walls or prove how a route would be built; it shows that the retained route cannot be reused unchanged in this bath-first block arrangement.

## Limits

All geometry is schematic and source-coordinate based. Door leaves, actual openings, wall finishes, people, furniture movement, privacy, services, tolerances, Revit and IFC are unverified. The west search window is a blocked diagnostic shape, not a physical bath or fixture. No room assignment or route is selected; B remains unassigned. No code-compliance, accessibility, structural-safety, professional, permit or construction-readiness finding is made.
