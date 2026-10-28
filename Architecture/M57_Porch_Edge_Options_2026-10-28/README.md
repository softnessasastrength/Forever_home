# M57 — porch attachment and dining-to-porch route screen

Status: **four comparison options evaluated; no porch location or route selected**.

This PowerShell 5.1 screen compares the project specification's 12 × 10 ft clear-interior porch against all four edges of the current owner-follow-up dining room block. At north/south edges, the porch's 12 ft side is centered along the 11 ft dining edge. At east/west edges, its 10 ft side matches the 10 ft dining edge and its 12 ft dimension projects outward. It includes the current M33 table candidate and a centered, straight 36 in route proxy from the table body to the corresponding dining boundary. It checks overlap against every named owner-follow-up room plus the separate, unassigned M-06-B search window.

## Reproduce

From the repository root, refresh M33 into ignored scratch output, then run M57 twice:

1. powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m33_open_social_zone_fit.ps1 -OutputDirectory .local/revalidation/M57-m33-a
2. powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m33_open_social_zone_fit.ps1 -OutputDirectory .local/revalidation/M57-m33-b
3. powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m57_porch_edge_options.ps1 -OutputDirectory .local/revalidation/M57-a -M33FitPath .local/revalidation/M57-m33-a/fit.json
4. powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m57_porch_edge_options.ps1 -OutputDirectory .local/revalidation/M57-b -M33FitPath .local/revalidation/M57-m33-a/fit.json

Compare fit.json, checks.json, manifest.json, and open-social-zone.svg between the two M33 runs; compare porch-options.json and m33-fit-input.json between the two M57 runs. The retained m33-fit-input.json is the exact intermediate consumed by this report. M57 checks its M33 source fingerprints against the current proposal and selected-D source and refuses stale inputs.

## Result

M33 passed **14/14** checks on both refreshes. Its four outputs were byte-identical across runs:

- fit.json: C0DDF94965A00ECFE609E31D753D1A03DFF3F38E391EE169EE2685205837E3F1
- checks.json: EBE9337B6A4839EAEEE1B93E64384ABB9475C88C428459A6EC77E7DF9FADC691
- manifest.json: EC083F316604D9934743BE3AD0B4BD724ECF04312C84375D69B487FFD7DC66E7
- open-social-zone.svg: D1EDBFCF5FD8B038C6E905BC6075C26B0C15717A963AA42455719D576ECE2F8A

M57 passed **5/5** source and contract checks on both runs. The corrected report SHA256 is 3B5E6B993B2A9C1A43282B76687D6A89AADA4A0709F991FD3F53DFD3B01BF6; its paired M33 input SHA256 is C0DDF94965A00ECFE609E31D753D1A03DFF3F38E391EE169EE2685205837E3F1.

| Attachment edge | Room-block overlap | Inside 40 × 42 ft comparison shell | Route proxy intersects M33 table pull-back envelope |
|---|---|---:|---:|
| North | Pantry 14 sf; M-06-B 70 sf | Yes | Yes, 9 sf |
| East | None among current room blocks | No; 50 sf lies beyond the shell | Yes, 9 sf |
| South | Kitchen 109.25 sf | Yes | Yes, 9 sf |
| West | Living room 28.75 sf | Yes | Yes, 9 sf |

The east option is the only tested attachment that clears the current room blocks, but 50 sf projects outside the unapproved shell. That makes it a comparison candidate for owner/site coordination, not an adopted location. The north option places a porch where the pantry and separate M-06-B window are reserved. The south option substantially overlaps the kitchen; the west option overlaps living. These are unresolved coordination conflicts, not permission to move rooms or enlarge the house. Every centered route proxy intersects the table's 36 in pull-back envelope, so none demonstrates a route that stays clear when chairs are occupied. A nominal 5 or 6 ft door width can contain the 36 in proxy geometrically; door swing, clear opening, walls and threshold are not modeled.

This is a room-block screen only. Porch location, entry direction, door arrangement, chair positions, door swings, wall build-ups, actual approach, site orientation, exterior grade and porch furniture remain unresolved. The 40 × 42 ft shell remains an unapproved comparison envelope. No Revit or IFC geometry changed. M-06-B remains unassigned; selected D and the Incoming RFAs remain untouched. No code, accessibility, structural or construction-readiness finding follows.
