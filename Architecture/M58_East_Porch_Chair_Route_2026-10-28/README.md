# M58 — east porch route with a four-chair body arrangement

Status: **one unselected table/chair/route candidate; porch and door remain unselected**.

This follow-up takes the east-attached porch option from M57 and tests its dining-side 36 in path proxy against four chair-body rectangles derived from the project’s dining furniture specification.

## Reproduce

From the repository root, run twice, changing only the output directory:

1. powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m58_east_porch_chair_route.ps1 -OutputDirectory .local/revalidation/M58-a
2. powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m58_east_porch_chair_route.ps1 -OutputDirectory .local/revalidation/M58-b

Compare east-porch-chair-route.json across both runs. The generator requires the reviewed M57 report hash and current source fingerprints.

## Result

Both runs pass **9/9** checks and produce identical JSON with SHA256 7F3589AB80021FBA736A2736937E9BA142A01C9340775D41D5554D93A573B42E.

The 60 × 36 in table remains at the M33 candidate location. Four 18 × 20 in chair-body rectangles are placed two on each long side, centered at one-quarter and three-quarters of the table length; there are no end chairs. The proposed straight route is 36 in wide and 36 in long, from the table’s east end to the east dining boundary. It stays inside the dining room block and has no area overlap with the four chair-body rectangles, with the chairs stationary. The route also fits within both source-listed nominal 5 ft and 6 ft door-unit intervals centered on the dining wall.

M57’s 36 in uniform table pull-back buffer still overlaps the path by 9 sf. This screen shows why that buffer result need not mean an end chair occupies the path: this candidate leaves both table ends without chairs. It does not model moving chairs, seated people, an occupied-person envelope, door leaf/stop clear width, wall build-up, threshold, turning, porch furniture or exterior approach. Nominal door width is not the same as clear opening.

The east porch remains a proposal that extends 50 sf beyond the unapproved 40 × 42 ft comparison shell. Site boundary, orientation, door type/swing, porch placement and furniture remain unresolved. No Revit or IFC geometry changed; M-06-B and selected D remain unchanged. This is not an accessibility or code-compliance finding, nor a construction-clearance determination.
