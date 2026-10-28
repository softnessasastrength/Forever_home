# M43 — Early public-route pruning study

**Status: opt-in search refinement tested; no room layout adopted.** This study modifies only the PowerShell search implementation and generated study artifacts. Selected D, RVT/IFC files and incoming RFAs remain unchanged.

## Purpose and rule

M42 enumerated complete room-block packings before checking the public corridor. M43 adds an opt-in partial-state check for U-01, U-02 and U-04. The mode is restricted to `-LandingAlignedRootSeeds`, which holds the corridor start and the sampled room-goal frame fixed. If a currently placed required public room has no reachable sampled corridor-side goal, adding more room rectangles can only remove walkable grid cells; it cannot restore the failed route. Such a branch is pruned. Any completed layouts still pass through the existing full corridor check.

This is a sampled plan-grid reachability rule. It does not establish door locations, openings, clearances, room feasibility, code compliance, accessibility, structure or construction readiness.

## Reproduce the retained 6,000-node run

Run from the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -EarlyPublicRoutePrune -RootSearchScope U-02-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -NodeLimit 6000 -LayoutLimit 5000 -OutputDirectory 'Architecture/M43_Early_Public_Route_Prune_Study_2026-10-28'
```

The run passes **30/30** integrity checks. It expands 4,500 nodes across valid seeds and checks reachability at each node; 2,432 partial states are pruned. No complete layout is recorded, so no final corridor route is tested. Search is incomplete: the valid seeds reach their per-orientation node cap and the fourth seed is rejected. The zero-layout result is not a proof of infeasibility.

## Compatibility and repeatability

With `-EarlyPublicRoutePrune` omitted, the same M42 U-02-first invocation produced byte-identical `search.json`, `checks.json`, SVG and manifest to the checked-in M42 artifacts. The default path therefore retains its previous output schema and behavior for this baseline.

Two clean 1,000-node capped runs of the opt-in mode each pass **30/30** integrity checks and reproduce byte-for-byte. Their common SHA256 values are:

| File | SHA256 |
|---|---|
| `search.json` | `3FF3FC7941FD359A9E9A2D1C8E5554AAFD255228C7454929276056353F0BD8AE` |
| `checks.json` | `0952BDF164769D6E85C47724460EE0528BAF597F99D7060561830C6E45C2AFA8` |
| `upper-suite-search.svg` | `AC7F1CA30E0075CEAE97851109A57F791109D0439764C0DCB80020F85CA78E9A` |
| `manifest.json` | `98BCDAAE0F145E733A7ED0DF48CED7AA6B9952A77F0D07F3A623FB3014DEAF8F` |

That capped run expands 750/1,000 nodes, prunes 442 states, and produces no complete packing or route. It demonstrates deterministic reporting, not design feasibility.

## Retained 6,000-node artifact hashes

| File | SHA256 |
|---|---|
| `search.json` | `4910CC714A72CF8A436C0D606142AAFAC1C310E799C2665481439555AFE428C0` |
| `checks.json` | `26A406184634AF1EA3835DB2BB4F5DF5F11D0B0A28C009BABE95C3ED3B64F011` |
| `upper-suite-search.svg` | `9A9E7D333DD8F207EE718A53ECCC3894AB4873CDD47FA91528C5BDF1C0F80541` |
| `manifest.json` | `F78C15E04662764A67AF34C4B6E2D8062CEF903F5D600C8C83205DAAEDC896CA` |

The 6,000-node JSON and SVG parse successfully. The manifest SHA256 above is verified against the retained file; all four hashes are also recorded in `PROGRESS.md`.

## Assessment and next work

The opt-in rule works and leaves the legacy output unchanged, but the first larger run yields less useful evidence than M42: it generates no complete packings, whereas M42 produced 12 and tested 12 routes. Route checking at every partial node is also computationally expensive. Improve candidate ordering or cache/incrementally update the reachability grid before another equal-budget comparison. Retain the mode only as an explicit diagnostic until it demonstrates better useful search yield.

Owner-directed topology remains U-01 → C-PRIVATE → U-02 → U-03 private-only; U-04 retains guest hall access; both Jack-and-Jill links through U-06 and primary-only U-05 remain. The owner requested Connecticut as the jurisdiction for code research and a steep traditional gable concept. Exact site/town, adopted code path, pitch, eave, assembly and structural dimensions remain unresolved. No code-compliance determination is made. M-06 B remains unassigned, and selected D is unchanged.
