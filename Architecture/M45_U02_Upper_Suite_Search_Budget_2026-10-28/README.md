# M45 — U-02-first search-budget stress run

**Status: not a complete upper-suite layout.** This run doubles M44's deterministic node cap while preserving the current room program, direct shared-hall approach proxy to U-02, private-only U-03 route, guest access to U-04, both Jack-and-Jill links, source stair-landing seed and projected lift reservation. It does not modify selected D.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -EarlyPublicRoutePrune -DeferredEarlyRouteChecks -RootSearchScope U-02-only -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 5000 -OutputDirectory 'Architecture/M45_U02_Upper_Suite_Search_Budget_2026-10-28'
```

## Result

- The PowerShell search-integrity gate passed **32/32** checks. The selected-D source fingerprint stayed unchanged during the run.
- It expanded **9,000/12,000** nodes across three valid root/orientation/seed cases, with the fourth seed rejected by the existing source approach/shell rule. The run hit its node budget and remains incomplete.
- Deferred pruning performed **3,916** sampled reachability checks, skipped **5,084** non-public checkpoints and rejected **3,094** states. It produced **zero** complete room packings, zero final corridor tests and no candidate layout.
- Runtime was approximately 18 minutes on the current workstation. Increasing the search budget from M44's 6,000 to 12,000 did not improve candidate yield; the large cost comes from repeated PowerShell grid reachability checks. The search does **not** establish that the room program or shell is infeasible.

## Retained evidence

| File | SHA256 |
|---|---|
| `search.json` | `2918F3242CBDD1FFC5D0BAB73BBD458AD23963EA4AB3D483F2960BDEAECDDA2B` |
| `checks.json` | `C8FE9794C5C15784C19C746AE9F05E22B6D561FE069C629D2BB452AB37693E52` |
| `upper-suite-search.svg` | `A02E07B0DDE8C0648572543E69C32CD6D57138C688B0A0A6BD9891E79CBC6128` |
| `manifest.json` | `230FC3DB1C01D3C5999141D0EAFC6112D9AB16653DBDFB161B4C348AAE5786C2` |

The retained search and checks JSON parse; the SVG parses as XML. The output is a bounded route search only. It models neither actual doors nor clear openings, wall assemblies, stair geometry, privacy treatment, headroom, structure, services, accessibility or code compliance. Connecticut remains a research jurisdiction; exact municipality and permit path are unresolved. Do not promote any layout or change a room/core reservation from this run.
