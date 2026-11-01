# M256 — Integrated living/kitchen route sensitivity

**Status:** reproducible schematic coordination check; no room position, route, or opening selected.

## Scope

M256 composes three existing, source-pinned studies: the owner-directed 6 in east translation of M-01 Living (M232), the measured 6 in west translation of M-02 Kitchen (M242), and M243's 6 in west route-start adjustment. It uses the existing M215 36 in route proxy and the M228 coordinate origin. It does not edit selected-D or add dimensions beyond those documented inputs.

## Result

`Tools/verify_m256_living_kitchen_route_integration.ps1` passes **21/21** checks in two independent Windows PowerShell 5.1 runs. Both generate byte-identical reports and checks:

| Artifact | SHA256 |
|---|---|
| M256 report | `8124b2b232b14132d575350eb2a4a6a6ab998583e2b68d24e1099c449ec39ae0` |
| M256 checks | `76b94025373aa8e0ad2efafb39af9c08cba47b2115ff66e99ffcd3c52b7d5be0` |
| Generator | `2650890a5c93e08d1a34c74112008702b9005dc5cf3d2c371879b0eb42cdd96d` |

The combined comparison retains M-01 at 240 sf gross and the M-02 block at 277.333 sf gross. M-01 and M-02 do not overlap; each shares a 12 ft block edge with M-05. The shifted 36 in route is 33.5 ft long, clears M-01 by 6 in and the shifted M-02 by 4 in, and retains M243's 3 in minimum reserve to its previously checked proxy set. Neither candidate room block overlaps protected A or unassigned B. M-06 remains TBD.

The owner-preferred fully open living/kitchen connection is **not demonstrated**: the blocks have no direct shared edge and M-05 intervenes across a 4 ft 4 in horizontal band. No physical walls or openings are modeled. This is a viable no-overlap coordination sensitivity, not an overall layout pass.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/verify_m256_living_kitchen_route_integration.ps1 -OutputDirectory .local/revalidation/M256-integrated-room-route-run7
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/verify_m256_living_kitchen_route_integration.ps1 -OutputDirectory .local/revalidation/M256-integrated-room-route-run8
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_architectural_bim_baseline.ps1 -OutputDirectory .local/revalidation/M256-baseline
```

The two M256 report hashes match between runs. The selected-D baseline replay also passes: two **43/43** room-block generations, seven identical outputs per replay, three valid SVGs per replay, and retained IFC2X3 **26/26** with zero schema errors. Baseline report SHA256: `EC7190C778E05930C81DA427E7AE54E156A65636DC8B011A504F60ED01F23E62`.

## Limits and next gate

These are room-block and swept-rectangle screens, not a floor plan with finished faces. Wall build-ups, actual openings and doors, thresholds, furniture operation, services, site fit, floor/story elevations and code applicability are absent. The M215 36 in width and 3 in reserve are analysis proxies, not code or accessibility findings. Connecticut research is recorded separately in M238; permit date, municipality and project classification remain unresolved.

Revit was not running or exposed as a targetable window during this check. No native RVT or IFC was generated from M256. The selected-D and retained RVT/IFC remain unchanged; the incoming Evolution RFA remains present and hash-stable at `39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA`. Next design gate: choose whether the fully open living/kitchen preference remains a hard requirement that warrants a separate hall/topology study, or whether the hall-separated case remains an allowed comparison. No decision is implied by this report.

No code-compliance, accessibility, structural-safety, professional-certification, permit-approval, or construction-readiness conclusion follows.
