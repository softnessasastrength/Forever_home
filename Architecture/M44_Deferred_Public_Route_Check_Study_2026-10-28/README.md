# M44 — Deferred public-route pruning checkpoints

**Status: search-cost refinement tested; no upper-suite room layout adopted.** This study preserves M43's every-node mode and adds `-DeferredEarlyRouteChecks` as a separate opt-in mode. Selected D, Revit files, IFC files and incoming RFAs remain unchanged.

## Search rule

Run the existing M37 PowerShell room-block search with both `-EarlyPublicRoutePrune` and `-DeferredEarlyRouteChecks`. The route proxy is checked after the root, after a required-public room (U-01/U-02/U-04) is placed, and before recording a complete layout. Checks are deferred across intervening private/primary/JJ connector blocks. This is safe within the fixed landing-aligned frame: each additional room rectangle only removes walkable grid cells, so it cannot restore a route already lost to an existing required-public room. Completed layouts still receive the full route test.

The mode refuses to run unless the route-pruning switch and landing-aligned seeds are also enabled. `-EarlyPublicRoutePrune` alone keeps M43's original every-node policy and output format.

## Reproduce the retained 6,000-node run

Run from the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -EarlyPublicRoutePrune -DeferredEarlyRouteChecks -RootSearchScope U-02-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -NodeLimit 6000 -LayoutLimit 5000 -OutputDirectory 'Architecture/M44_Deferred_Public_Route_Check_Study_2026-10-28'
```

The current owner proposal fingerprint is `0519C9F350C41FBC9F7BA1B6B926C2B26E40F17CB5EACC3C13D5ACAAF2749537`. The run passes **32/32** generator checks. It expands **4,500/6,000** nodes, defers **2,274** route checks across non-public placements, performs **2,226** sampled reachability checks, and prunes **1,900** states. It records **zero** complete layouts and performs zero final corridor tests. A fourth landing-aligned seed is rejected by the existing approach/shell check; valid seeds reach their per-orientation node budget. The search remains incomplete. These results do not prove infeasibility.

Deferral approximately halves the route-check count compared with M43's 4,500 checks at the same node budget, but it still produces no room blocks or route-tested candidates. The optimization improves computational selectivity, not design feasibility or candidate yield. Do not promote any room positions or revise any requirement based on this search.

## Deterministic capped replay

Two clean 1,000-node runs against the same current owner proposal each pass **32/32** checks and match byte-for-byte:

| File | SHA256 |
|---|---|
| `search.json` | `B7C3EE8114BD38A77CAE788F72B839FAA338FF7B896C3E576845B98BF4A150E2` |
| `checks.json` | `ED0E594D11E2D10135DF3F96E97EEDFE6635B7C5C64CB750B5C81A25C1BBDEEA` |
| `upper-suite-search.svg` | `AC7F1CA30E0075CEAE97851109A57F791109D0439764C0DCB80020F85CA78E9A` |
| `manifest.json` | `FE81473DDCD4C741143BFD03A3996271291C08053B7BFC6192494E1C09BFD897` |

Those capped runs expand 750 nodes, perform 466 route checks, defer 284 checkpoints and prune 442 states. They create no layouts/routes. The SVG parses as XML and the JSON reports parse successfully.

## Current-input M37 baseline smoke

The current owner proposal also passes the ordinary M37 path with early pruning disabled:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope U-02-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -NodeLimit 1000 -LayoutLimit 5000 -OutputDirectory '.local/revalidation/m44-current-inputs-default-1k'
```

It passes **28/28** checks, expands 750 nodes, records six layouts and tests six route samples. U-02's sampled hall-side goal is reachable in **6/6**; U-01 and U-04 are reachable in **0/6**; the required U-01/U-02/U-04 trio occurs in zero layouts. U-03 corridor-side proximity is not public access. This confirms that the search explicitly tracks U-02's requested direct hall approach proxy, while leaving actual door geometry unverified. The bounded result is incomplete and does not invalidate any room target or topology requirement.

## Retained 6,000-node artifact hashes

| File | SHA256 |
|---|---|
| `search.json` | `9DB2FA1255976B8AD5AC354DE7D643211D16F76327C22BF59B15B0A7959671A6` |
| `checks.json` | `CDEFB22CEB415057CEF71CA32CD9DA2A5C78ADE2484E77FC0DF5BF610E323687` |
| `upper-suite-search.svg` | `9A9E7D333DD8F207EE718A53ECCC3894AB4873CDD47FA91528C5BDF1C0F80541` |
| `manifest.json` | `B01B8EE6F0D12655528527B00C5DE1856909E061FF87EC4A8CD64939724FF9B5` |

## Current owner-directed access inputs

U-02 must have direct arrival from the upper shared hall while retaining private links to C-PRIVATE and U-03. U-03 remains private-route-only; U-04 retains guest hall access, and both Jack-and-Jill links remain. The updated owner proposal generator passes **18/18** checks and reproduces byte-for-byte in two clean runs. The M37 integrity suite now fails if the owner proposal omits the required U-02 hall edge.

The route goal samples represent possible hall-side approach locations only; they do not model a door, clear opening, door swing, privacy screen, landing maneuvering or accessible route. Those details remain unresolved for a disposable Revit derivative. M-06 B remains unassigned. Connecticut remains the requested research jurisdiction, but the municipality, site and permit path are unknown, so no code-compliance conclusion is made.
