# M106 - Conditional sleeping-room escape-opening perimeter screen

Status: schematic perimeter-contact audit only. No window or emergency escape opening is modeled, and no room classification or compliance result is determined.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m106_upper_suite_sleeping_room_perimeter.ps1
```

The script binds the M78 search and manifest, current selected-D source, room program and cited CT code note by SHA256. It checks U-01/U-03/U-04 in all five archived route-ranked M78 layouts, producing 15 rows, a JSON evidence packet and [a plan SVG](sleeping-room-perimeter.svg).

## Result

All five layouts keep sampled public hall access to U-01/U-02/U-04, north-side U-02 access and no U-03 public-side reach. The three bedroom-capable room blocks retain the same perimeter relationships in all five:

| Room | M78 program label | Test-shell contact | Nearest shell edge |
|---|---|---|---:|
| U-01 | Primary bedroom | West edge along a 16 ft block side | 0 ft |
| U-03 | Hybrid bedroom/office | None | 8.166667 ft, south |
| U-04 | Guest / third bedroom | East edge along a 13.666667 ft block side | 0 ft |

The official Connecticut 2022 CSBC amended IRC R310.1 says each sleeping room requires an operable emergency escape and rescue opening that opens directly to a public way or qualifying yard/court. R310.2.1 gives a 5.7 sf minimum net clear area (with a grade-floor/below-grade exception); R310.2.3 gives a 44 in maximum sill height, subject to its platform exception. If U-03 is intended for sleeping, this M78 packing shows no perimeter wall segment for a conventional exterior-wall opening. The room/shell layout needs further study or a separately documented opening path; this screen does not assume a roof window qualifies.

Two independent PowerShell 5.1 runs pass **15/15 checks**, including source-program label and R310-note checks, parse the SVG as XML and match the checked-in JSON/CSV/SVG. SHA256: JSON `20F7F98D2FD8A4321AF3BCADAEFD72073A98357920BAA1A58B6BDBC89F1AEC39`; CSV `6B33957F62C3962B32F9555C2BE98EE49AF3BDE2840847F3D92781B03D07F46B`; SVG `D1EE610546D22A162F1539A14D9270305B942E13656FB3CFB64E6B5851B121CE`.

## Limits

- The shell outline is a hypothetical envelope, not an actual exterior wall. Contact indicates only a possible wall zone.
- Clear opening size, operation, sill, guard/well, exterior grade, qualifying yard/court and route to public way are not modeled.
- U-03's sleeping-room status, applicable code cycle, town and permit path remain unresolved.
- M78's five candidates are a retained subset from a bounded 457-packing search. No code compliance, safety or construction-readiness conclusion follows.
