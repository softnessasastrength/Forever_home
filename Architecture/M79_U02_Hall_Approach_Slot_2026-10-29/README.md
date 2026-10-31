# M79 - U-02 nominal hall approach slot (schematic)

Status: source-derived door-reservation alignment study only; no door, clear opening, or shell dimension is selected.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/screen_m79_u02_hall_approach_slot.ps1
```

The script reads the archived M78 candidate and selected-D study, checks their fingerprints, verifies that the M78 winner has a north-side U-02 public route sample and retains no U-03 public-side access, then writes `u02-approach-slot.json` and `u02-approach-slot.svg`.

## Result

- M79 passes **10/10** checks. Two independent Windows PowerShell 5.1 output directories produce identical JSON (SHA256 `75DB4DE197CD3E8B479208C3F751CC397D56315106343CCA26F8A8309EF145D5`) and SVG (`8D2C798635AE05DD9B6618BCB5009BD9E25B3CB3E8C511243542AEA53A77341E`). SVG XML parsing passes.
- M78's U-02 north edge is x=11.166667..27.166667 ft at y=27.5 ft. The selected-D door matrix supplies a 3.5 ft *nominal contact reservation*; centering that test interval over the approach axis yields x=17.416667..20.916667 ft. The 4 x 4 ft reserved approach center is (19.166667, 30) ft, aligned with the interval centerline. The M78 validator independently found a north-side hall sample at the same centerline.
- The interval leaves 6.25 ft of nominal room-edge length on either side. The approach box begins 0.5 ft beyond the room-block edge; its center is 2.5 ft beyond that edge.

## Limits

The source value is not a verified clear opening, door-leaf width, accessibility clearance, or selected door size. The diagram has no wall thickness, jamb/frame, door swing, latch/privacy control, or actual corridor geometry. The stair approach is a selected-D plan proxy, and the 38.333333 x 40 ft envelope remains a hypothetical test. A separate M78 Revit room-boundary derivative now exists, but it contains no wall or door; an actual opening and approach study remains outstanding. This is not a code, accessibility, fire/life-safety, structural, or construction-readiness finding.
