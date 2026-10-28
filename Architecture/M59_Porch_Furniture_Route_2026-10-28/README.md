# M59 — porch table and garden-door route

Status: **one unselected porch-furniture and circulation arrangement**.

This PowerShell 5.1 screen continues the east-attached porch candidate from M57/M58. It uses the written 12 × 10 ft porch, 30 × 48 in table option, 30 in path, 3 ft exterior door, 5/6 ft nominal French-door alternatives, and 18 × 20 in chair-body proxy dimensions from the project specifications.

## Reproduce

Run twice from the repository root, changing only the output directory:

1. powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m59_porch_furniture_route.ps1 -OutputDirectory .local/revalidation/M59-a
2. powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m59_porch_furniture_route.ps1 -OutputDirectory .local/revalidation/M59-b

Compare porch-furniture-route.json. The generator requires the reviewed M58 source hash and current proposal/specification fingerprints.

## Result

Both runs pass **9/9** checks and produce identical JSON, SHA256 FA29D73EAA7274B524D3CA4AED7AA7EB499E1644646B10A363F3AA4AA927BD27.

In local porch coordinates, west is the assumed dining opening and east is the garden-side exit. The proposed table sits in the northeast corner with two stationary chair-body proxies on its north long side. A 30 in wide route uses three connected clear rectangles: a 30 × 30 in connector from the dining opening, a cross-porch lane along the north side, and a 30 × 30 in connector to the east exterior door. The route stays inside the porch, fits the nominal 5 ft and 6 ft French-door intervals and the nominal 3 ft exterior-door interval, and has zero modeled area overlap with the table or either chair proxy.

The table and chair positions, doors, door swings, porch orientation, and route are proposals. The rectangles do not represent seated people, chair movement, leaf/stop clear width, thresholds, corner maneuvering, porch furniture beyond the two chairs, weather protection, grade or site constraints. The route has two right-angle turns and is not an accessibility determination. The east porch still extends 50 sf beyond the unapproved 40 × 42 ft comparison shell. No Revit or IFC geometry changed; selected D and M-06-B remain unchanged.
