# M130 - Primary-bath roof exposure across U-03 privacy layouts

Status: bounded room-block comparison only. The 38 1/3 x 40 ft shell, room layout, roof pitch, ridge axis, eave and fixture plan remain unselected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m130_upper_suite_roof_exposure.ps1
```

The analyzer binds the M115 route-tested candidate archive and audit, M83 six-option roof report and manifest, selected-D source, owner proposal, and its own script by SHA256. It selects the 64 northeast-corner U-03 candidates with all three sampled public-room routes, north-side U-02 arrival, and no sampled U-03 public-hall reach. For each candidate, it checks seven room-block areas and containment/non-overlap, then evaluates the whole U-05 rectangle against all six ideal M83 roof planes.

The command passes **15/15 checks**, producing 64 candidate summaries and 384 room-roof rows. A second run into `.local/revalidation/M130-replay/` also passes 15/15; all four artifacts match byte-for-byte:

| Artifact | SHA256 |
|---|---|
| `m130-candidate-summary.csv` | `039A91FA693DBC5C32434EBB02CD72C9458CF201A0171097195C71E1445ADADF` |
| `m130-checks.json` | `D33C05869387057D30FF2DC1FCDB14F904C9EB9D657AB5E895A9EF93EE79DF79` |
| `m130-report.json` | `16D95D9E002FAA4D6527039971D81D750F18164A3A393B62C88087A8C9187A4F` |
| `m130-roof-exposure.csv` | `E57F411B37D72612EDBE2064B408833E839C43DE1BB67EBE5BF9AF218A1D3369` |

## Finding

For each pitch, the sampled layout with the largest minimum ideal roof rise across U-05 is M130-NE-24 with ridge X, and M130-NE-19 with ridge Y. At 12:12, their U-05 minimum rises are 10 ft and 8.166666 ft respectively. They are different room-block arrangements: NE-24 uses a 10 x 9 ft U-05 at (7.166666, 21) ft; NE-19 uses 9 x 10 ft at (8.166666, 21) ft. The sampled 12:12 minimum-rise ranges across all 64 layouts are 0.333333-10 ft for ridge X and 1.166666-8.166666 ft for ridge Y.

These are relative to an unassigned eave plane. The result says only that room-block placement changes how much ideal roof plane lies above the whole U-05 rectangle. It does not give finished headroom, identify fixture zones, or prove that a layout works. No winner is recommended: U-05 fixture geometry, shower/tub use, door swing, wall construction, ceiling build-down and services have not been coordinated. The 12:12 case is a steep arithmetic comparison requested for exploration, not a selected pitch or structural specification.

## Limits

- M115 is an incomplete bounded search; these 64 layouts are a sampled subset, not an exhaustive solution space.
- M83 consists of ideal zero-thickness planes. It does not include framing, overhang, walls, ceiling, dormers, structure, drainage or openings.
- Connecticut sloped-ceiling requirements cannot be checked without a finished floor/eave datum, ceiling build-down, room classification and fixture locations. M116/M117 remain conditional code research, not a code review.
- No Revit, IFC, selected-D source, incoming family or remote state changed. No structural, compliance, professional certification or construction-readiness claim follows.
