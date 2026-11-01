# M279 — Integrated kitchen / dining / porch orientation screen

**Status:** reproducible coordinate comparison; no kitchen, island, pantry, dining, or room placement selected. Selected-D is unchanged.

## Finding

M279 brings M193's owner-directed 14 × 12 ft / 168 sf clear-kitchen target and flexible 7 × 3 ft / 6 × 3 ft island cases into M215's source-local dining, porch, and 36-in route coordinate study. It compares both orthogonal room orientations at the M178 local origin and retains M193's 12.5-ft perimeter run, 24-in cabinet body, 12-in seating overhang, two 42-in aisle proxies, 6-in half-wall outside the clear-room face, and an explicit 36-in stool-use rectangle.

| Candidate | Pantry overlap | Perimeter-run reserve | Island end reserve | Cross aisles | Unassigned kitchen-to-dining band | Result |
|---|---:|---:|---:|---:|---:|---|
| 14 × 12 ft; 7 × 3 island | 3 sf | 18 in | 0 in | 42 in each | 8 ft | Reject this coordinate orientation: overlaps the inherited M-04 proxy |
| 14 × 12 ft; 6 × 3 island | 3 sf | 18 in | 12 in | 42 in each | 8 ft | Reject this coordinate orientation: overlaps the inherited M-04 proxy |
| 12 × 14 ft; 3 × 7 island | 0 sf | 18 in | 0 in | 42 in each | 6 ft | Clears the bounded fixed-block overlay; adjacency/opening unresolved |
| 12 × 14 ft; 3 × 6 island | 0 sf | 18 in | 12 in | 42 in each | 6 ft | Clears the bounded fixed-block overlay; adjacency/opening unresolved |

The first orientation overlaps the M186/M215 **5 × 6 ft** pantry proxy by 3 sf. That is the inherited size in this route case; other project records specify a different pantry size. The second orientation avoids that block, the protected west-A reservation, east B, M-05, dining, and porch rectangles in this bounded overlay. Neither candidate establishes a buildable plan: the 12 × 14 orientation leaves a 6-ft coordinate band to dining, and the 14 × 12 orientation leaves 8 ft. These are unassigned coordinate bands, not selected circulation widths or proven open connections.

The M215 route is retained at 34 ft long and 36 in wide, with its recorded 3-in minimum modeled obstacle gap. In this overlay it does not intersect the proposed kitchen rectangle, island, or 36-in stool-use proxy; it intentionally traverses the dining/porch connection. This does not verify a kitchen-to-living opening, real door/leaf/swing, occupied movement, kitchen workflow, actual stools, appliance operation, finishes, tolerance, or site fit. The overhang and seating-use areas remain proxies, not product geometry.

## Provenance and replay

The input reports and compact static-obstacle snapshot are fingerprinted in `m279-report.json`. The tracked `m186-fixed-obstacle-snapshot.json` preserves the four rectangles used for M-05, the 5 × 6 ft M-04 case, west A and east B from the M186 route report underlying M215 (original report SHA256 `871B876F15F0950D68EF4667D89D37B63155E24B868D7C04E6D6E0B3C6C45684`). It avoids a dependency on that report's ignored `.local` output. The snapshot does not convert those study rectangles into approved room boundaries.

| Input | SHA256 |
|---|---|
| M193 compact island report | `975C348B380CF45229C492F939D89B4427073F4D21DB717DFB376023C0E9A2C8` |
| M215 route report | `F2F6A66DEDA2A9C48A991E36B986683FE1F5B1C1D361FBF3E43BE2A2E1A053B1` |
| M186 obstacle snapshot | `03E6D2BACC6A6167105651747869CB82AFB16515FADF691CFE8CE7695F1A1DA7` |
| M178 half-wall study | `E49487E62CE1A17CDFA055A5386524DB378077213E5DB7435A841723A47614C0` |
| M172 social-space constraints | `140B742535376DA59A8A89A06D5CFC10B95CEE3C8AFF5056F9A2DD95250B3B98` |
| Selected-D source | `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` |

The package-free C# generator builds with .NET 10.0.403: **0 warnings, 0 errors**. It verifies every upstream fingerprint recorded by M193 and M215, pins both source report hashes and the obstacle-snapshot hash, and confirms the island body/overhang dimensions and route values. Two isolated executions pass **20/20** checks and produce byte-identical output; both SVGs parse as XML.

| Artifact | SHA256 |
|---|---|
| `m279-report.json` | `5F15A39116AD56C6B53CAC502427460DAC2727853C9334F0096ADBF9B30D1431` |
| `m279-checks.json` | `15FF1FCF43CE539DFC73038C5E1E6231A0FB565DDB5EFAD43804C63557032070` |
| `m279-plan.svg` | `60BA7597D66B7E1124366C318E3D63364BE89446A06CF343453FB8EB873C729C` |

From the repository root, use fresh output paths; the generator writes or replaces named files in its output directory.

```powershell
.local/dotnet/dotnet.exe build Tools/M279Generator/M279Generator.csproj --configuration Release --output .local/revalidation/m279-build --ignore-failed-sources
.local/dotnet/dotnet.exe .local/revalidation/m279-build/M279Generator.dll Architecture/M193_Compact_Island_Fit_2026-10-31/artifacts-v2/m193-compact-island-fit.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Architecture/M279_Integrated_Kitchen_Porch_Orientation_Study_2026-11-01/m186-fixed-obstacle-snapshot.json .local/revalidation/m279-replay-a
.local/dotnet/dotnet.exe .local/revalidation/m279-build/M279Generator.dll Architecture/M193_Compact_Island_Fit_2026-10-31/artifacts-v2/m193-compact-island-fit.json Architecture/M215_Porch_Approach_Reserve_2026-10-31/artifacts/m215-porch-approach-clearance.json Architecture/M279_Integrated_Kitchen_Porch_Orientation_Study_2026-11-01/m186-fixed-obstacle-snapshot.json .local/revalidation/m279-replay-b
```

## Limits and next gate

M279 only screens four rectangles against existing source-study blocks and one inherited route. It does not create Revit geometry, revise selected-D, resolve the M-04 size discrepancy, or select either island counter split. Native wall/opening details, the full kitchen/living relation, room-to-room adjacency, dining furniture movement, site fit and the approved shell remain open. M-06/A/B remain unassigned; west A remains protected. No code-compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows.

Next: integrate the candidate with the actual kitchen/living connection and M-05 arrangement after owner direction; then carry only a route-qualified proposal into a disposable Revit derivative using the authorized exact-hash RevitPilot workflow.
