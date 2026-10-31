# M158 - Joint bedroom-capable room-block perimeter search

**Status:** reproducible, bounded topology diagnostic. The 38 1/3 x 40 ft shell is an owner-authorized exploration case only; no shell, room layout, wall, window, roof or house dimension is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 `
  -ShellWidthOverrideFt 38.333333 -ShellDepthOverrideFt 40 `
  -RootSearchScope U-01-only -U02RootPlanVariant guest-branch-first `
  -AdditionalContactSamples 0 -PublicDoorEdgeSamples 5 `
  -LandingAlignedRootSeeds -U01PerimeterRootSeeds -U01PerimeterSeedEdge all `
  -U01PerimeterSpreadSeeds -RequiredPerimeterContactRooms 'U-01,U-03,U-04' `
  -NodeLimit 4800 -LayoutLimit 10000 -ExportAllRouteTestedCandidates `
  -OutputDirectory Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/audit_m158_joint_perimeter_search.ps1 `
  -RunDirectory Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31 `
  -OutputDirectory Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31

powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_upper_suite_candidate.ps1 `
  -RunDirectory Architecture/M158_Joint_Bedroom_Perimeter_Search_2026-10-31 `
  -TestShellWidthFt 38.333333 -TestShellDepthFt 40
```

M37's new `-RequiredPerimeterContactRooms` option is opt-in and accepts U-01/U-03/U-04 only. It requires landing-aligned coordinates; requiring U-01 additionally requires the U-01 perimeter-root mode. Default M37 output remains unchanged.

## Result

The updated default M37 replay passes 28/28 and matches the pre-M157 default search, checks, SVG and manifest byte-for-byte. The joint-contact run passes 31/31, expands 2,865/4,800 aggregate nodes, reaches the per-root/orientation node caps, and records two complete route-tested layouts. It is bounded and incomplete. Two generator runs match all five artifacts. The independent M158 audit passes 16/16 on both runs and produces identical JSON/CSV audits. The independently recomputed M37 candidate validator passes 115/115 for the best candidate.

Both archived layouts keep U-01, U-03 and U-04 on the hypothetical outline, clear the shell, preserve the seven-room source inventory and all six nominal room-contact links, avoid the lift/stair-approach proxy rectangles and do not overlap. In both, U-01 touches the south outline, U-03 the west outline, and U-04 the west and north outline. One reaches all sampled public goals for U-01/U-02/U-04 while U-03 has no sampled public-side reach. The other fails the public-route condition. The best candidate's U-02 north sample is 0.5 ft from the landing-approach grid start; it is a sampled route proxy, not a door.

These are room-block contacts with a hypothetical boundary, not exterior walls or openings. The study provides no window product, net-clear opening, sill/grade relation, qualifying yard/court, egress route, actual doors, partitions, roof, stair, floor, service routing, Revit placement or IFC export. The search is bounded and incomplete. No layout or design dimension is selected; no code-compliance, structural-safety, certification, permit or construction-readiness finding is made.

## Evidence hashes

| Artifact | SHA256 |
|---|---|
| `search.json` | `E0E9C4F4046956BE045D2848D236669D9DFC371BDC8CD28389DCF0830622F8D6` |
| `checks.json` | `0F2A0AB5789C1048D26A7CD7111DDE1020727B3485477332DCB420313B8E3852` |
| `upper-suite-search.svg` | `0094315CA67301955776F5CF60B8E4F9B7D41FB136BB696CC2EB9FD586E5DD2E` |
| `manifest.json` | `2F950E75B333FE24333E2E249594DC5C694D730CE967AA33C28E1FA6DD03057D` |
| `all-route-tested-candidates.json` | `676C8F3D2CB6B7D7F032B515351749900FFB38D5342F8B7E2AB90F62DDE40892` |
| `m158-joint-perimeter-audit.json` | `92F7DE85D0E0C9DB873E3AE2B2A6F3E10BF5DD7E9581867C92B927B9032826A9` |

The audit CSV is separately retained and bound by the audit report. Input fingerprints are recorded in both M37's search manifest and the audit report.
