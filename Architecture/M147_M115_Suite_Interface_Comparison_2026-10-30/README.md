# M147 — M115 route-compatible suite interface comparison

Status: completed as an arithmetic comparison of hypothetical room blocks. No layout is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m147_m115_suite_interfaces.ps1
```

The analyzer binds the full 331-candidate M115 archive to its independent audit and source fingerprints, then filters the 73 candidates with sampled U-01/U-02/U-04 hall reach and no sampled U-03 public-side reach. It verifies the six owner-directed room links in each candidate. Two isolated scratch runs pass **13/13** checks and produce identical JSON/CSV output. The retained package replay also passes 13/13 twice.

Retained output SHA256:

- JSON report: `F5F06C0D5FC2FFD6DA5339F342F1620E7CA9C68A7AE342A03BFAF9B335256DCC`
- Candidate summary CSV: `7E92299A10F471434937A1224184FD00174970D1C9EF1C88790B68BCACEB4DEB`
- Room-link CSV: `92E414D2D9FCA4DD470A191E9C8AE1BB25F02EE7A4FB3B81E077CEAB8A0FBEAB`

## Result

All 73 candidates contain the six expected 0.5 ft wall-band-separated room contacts. Each contact is at least as long as the selected-D source's 3.5 ft nominal reservation, treated here as an arithmetic proxy only.

| U-03 sampled shell-edge group | Candidates | All six reservations fit | Candidates with a zero minimum centered end margin |
|---|---:|---:|---:|
| East + north | 64 | 64 | 44 |
| North + west | 9 | 9 | 3 |

In the east+north group, the 3.5 ft minimum occurs at U-01/C-PRIVATE in 16 layouts, C-PRIVATE/U-02 in 10, U-03/U-06 in 20, U-06/U-04 in 20, and U-01/U-05 in two; U-02/U-03 remains at least 9.166667 ft. Counts overlap because a layout can have more than one boundary at the minimum. In the north+west group, only U-01/C-PRIVATE reaches the 3.5 ft minimum, in three layouts. This highlights a boundary-length tradeoff; it does not rank a preferred plan.

For the specific U-01/C-PRIVATE pinch point, 48/64 east+north layouts have at least 6.5 ft of block contact: 32 match the M145 NE-19 comparison and 16 provide 10 ft. The other 16 have only 3.5 ft, matching the M145 NE-24 tight case. In the north+west group, six layouts provide 6.5 ft and three provide 3.5 ft. Thus many route-compatible arrangements preserve or improve the 6.5 ft contact, while the all-interface margin screen still finds zero reserve at some other boundary in 44 of the east+north cases. Candidate-level details and route-side samples are in the CSV files; none is selected.

## Limits

- 38 1/3 x 40 ft is an exploration-only shell, and M115 is an incomplete bounded search.
- The 3.5 ft number comes from the selected-D upper-door reservation matrix. It is not an approved opening width, verified clear width, wall/jamb allowance or code clearance for these proposals.
- Boundary arithmetic does not model doors, jambs, leaf swings, approach, privacy, circulation conflicts, assemblies, egress or finished dimensions.
- Hall evidence is sampled-grid reachability, not an actual public door or route. No roof, stair, ceiling, service, fixture, Revit/IFC or applicable-code finding follows.
- No candidate, room arrangement, opening or shell dimension is selected. Selected-D source, RVT/IFC and incoming RFAs were not changed.

This milestone makes no accessibility, code-compliance, structural-safety, professional-certification, permit or construction-readiness claim.
