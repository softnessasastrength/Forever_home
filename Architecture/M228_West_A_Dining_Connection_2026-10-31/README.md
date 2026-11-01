# M228 - West A dining connection proposal

**Status:** bounded schematic adjacency proposal; not selected and not a room assignment.

## Purpose

M227 found that protected west window A touches the selected-D dining block but not living or the public hall. The owner later protected A for M-06 and authorized moving the 11 x 10 ft dining and 12 x 10 ft porch study footprints within the hypothetical shell. M228 tests one derived dining position that directly touches both A and living while preserving A, B, and the separately tested M215 porch-route corridor.

## Candidate and result

The 11 x 10 ft dining proposal is `[1, 15.666667, 11, 10]` ft in selected-D global plan coordinates (110 sf). It is derived by aligning its east edge to A's west edge and its north edge to M-01's south edge. Relative to M215's local-frame dining block after translation into selected-D global coordinates, this moves dining 4 in east and 5 ft north. The movement is within the owner's authorized study scope; the position is not selected.

- Dining shares a 9.5 ft block edge with west A and an 11 ft edge with living. It overlaps neither.
- It stays inside the 40 x 42 ft test shell and clears the M215 36 in route swept rectangles by at least 2.25 ft in this proxy comparison.
- The transformed M215 route swept rectangles have zero positive-area overlap with protected A, unassigned B, or the proposed dining block.
- The living and M-05 hall blocks still have a 0.5 ft gap across a 12 ft projected edge. No door, wall opening, or walkable public path from hall through living/dining to A is modeled.

The M215 route waypoints are stored in the M186 local coordinate frame. M228 reads the pinned BathFirst study's M-02 coordinate origin `(0.666667, 0.666667)` ft and adds it before comparing that route with selected-D global room blocks. This explicit frame conversion avoids treating local M186 coordinates as global coordinates.

## Reproduction and evidence

Run from the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m228_west_a_dining_connection.ps1 `
  -OutputDirectory Architecture/M228_West_A_Dining_Connection_2026-10-31/artifacts

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m228_west_a_dining_connection.ps1 `
  -OutputDirectory .local/revalidation/M228-replay-1

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m228_west_a_dining_connection.ps1 `
  -OutputDirectory .local/revalidation/M228-replay-2
```

All three runs pass **12/12** checks. JSON, checks JSON, and SVG are byte-identical across the retained run and two independent replays. The SVG parses as XML.

| Artifact | SHA256 |
|---|---|
| `m228-west-a-dining-connection.json` | `F4AB50FD02E4D71E434C4E4C83D63FE8D20B580810D7118A234BC4B2DA8119FF` |
| `m228-checks.json` | `4AE678CF83990737099D71A16F2B07FBFE169F6ACF0FBD0AD6D0BBA09BDB7743` |
| `m228-west-a-dining-connection.svg` | `3AD3A99E35C1BD4D83D8326051C85E6DE8B3F29D874DE87482819E4BD4D7FE42` |

The report pins selected-D, the owner dining/movement decision, west-A protection, M215, the BathFirst coordinate origin source, and the M186 generator. It writes only to its output directory.

## Limits and next gate

M-06 and both search windows remain unassigned. The owner has since directed that west A remain the primary search area. The study does not place the toilet or lavatory, establish product solids or rough-in, size/locate a door, test a bath approach, or route plumbing/services. Edge contact does not mean an opening. In particular, the remaining living-to-hall gap prevents this from proving the intended hall access. Next, resolve the public opening/path connection for the A-primary option, then evaluate actual M-06 fixture geometry, applicable clearance basis, door/approach, and service routing in an isolated Revit derivative. No selected-D, RVT, IFC, or Incoming RFA was changed. No code-compliance, accessibility, structural, professional, permit, or construction-readiness conclusion follows.
