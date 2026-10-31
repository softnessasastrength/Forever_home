# M156 — M115 bedroom-candidate perimeter contact screen

**Status:** bounded, proposal-only geometry screen. The owner-authorized 38 1/3 × 40 ft shell is an exploration case. No room layout, shell dimension, exterior wall, opening, sleeping-room classification or code result is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m156_m115_sleeping_room_perimeter.ps1
```

The script verifies the M115 search, candidate archive and independent audit fingerprints, applies M147's 73-candidate sampled-route/privacy filter, and measures U-01/U-03/U-04 rectangle contact with the hypothetical test-shell boundary. It emits JSON and two CSVs. The geometry is expressed in the generator's translated shell coordinate frame.

## Result

The analyzer passes **16/16** integrity, reproduced-result and non-claim checks. Its 73 retained M115 candidates produce 219 room rows:

| Program space | Candidates touching hypothetical outline | Without outline contact |
|---|---:|---:|
| U-01 primary bedroom | 0/73 | 73/73 |
| U-03 hybrid bedroom/office | 73/73 | 0/73 |
| U-04 guest / third bedroom | 28/73 | 45/73 |

U-03 contact is east in 64 candidates and west in nine; its other shell-edge contact in these candidates is south. U-04 contacts east in 25 candidates and west in three. U-01 is interior in every route-compatible candidate. This is a consequential limitation of the U-03-perimeter-rooted M115 search: the documented primary-bedroom block has no possible exterior-wall zone in this subset. M157 should explore primary-room perimeter roots while preserving U-02 direct hall arrival, private-only U-03 hall access, and the private/J&J room links.

## Evidence

Two isolated Windows PowerShell 5.1 runs pass **16/16** and match all three generated files byte-for-byte. Tracked-package hashes:

| File | SHA256 |
|---|---|
| `m156-perimeter-screen.json` | `CF72CC799FFE7EA5A2EC6C27F37078068D8634F6A73BC868AA1F396E9508F38D` |
| `m156-candidate-summary.csv` | `8B585B9BCADE5C05CCDFF9ACBBC6F2D0D6EFF984BFFFE3817F3CFDBF54DD7078` |
| `m156-room-perimeter.csv` | `38F078E745B1B1C96BC09C017185F43A7BA76310EB247142F143775729204AA5` |

The report binds the analyzer, M115 archive/audit/search, selected-D source, room program and existing Connecticut R310 research note by SHA256. Selected-D and source RFAs are unchanged.

## Limits

- Test-shell edge contact is a possible wall zone only. No exterior wall or emergency escape and rescue opening (EERO) is authored.
- Clear opening area/height/width, sill, well, grade, qualifying yard/court and path to public way are not tested.
- U-01/U-03/U-04 are bedroom-capable program spaces; final sleeping-room classification and permit applicability remain open.
- M115 is a bounded incomplete search. Counts describe its retained subset and do not establish design feasibility.
- No roof, walls, floors, doors, stairs, services, Revit placement or IFC validation is established. This is not a code-compliance, accessibility, safety or construction-readiness finding.
