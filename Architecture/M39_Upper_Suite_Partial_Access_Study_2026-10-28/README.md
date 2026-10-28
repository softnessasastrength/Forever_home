# M39 — upper-suite partial hall-access layout study

Status: **unselected room-block diagnostic**. This study visualizes the highest-ranked partial public-access layout found by the bounded M37 search. It does not meet the required U-01/U-02/U-04 combination and is not a proposed door schedule or Revit model.

## Reproduce

From the repository root in Windows PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope balanced -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory 'Architecture/M39_Upper_Suite_Partial_Access_Study_2026-10-28'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m37_upper_suite_pack_and_route.ps1 -RootSearchScope balanced -U02RootPlanVariant guest-branch-first -AdditionalContactSamples 8 -PublicDoorEdgeSamples 9 -LandingAlignedRootSeeds -NodeLimit 12000 -LayoutLimit 10000 -OutputDirectory '.local/revalidation/m37-m39-partial-access-repeat'
```

Both runs pass **27/27** checks and match byte-for-byte: `search.json` SHA256 `176750E5A7BB6B1F93348D07A8BBBCB855685CA0AF211B53721CF9DDB61AD4A2`, `checks.json` `EE31CEBE9AA81E1DE8C119E6775513041B8EB4F17876628445D2041D11EB24F8`, SVG `5FEC488E0C51DCA4CDEBC74B1033AFFBAED9C1169F9D5B5F4B5D8A6002FBDB19`, and manifest `E8F75126E30F98307A21673EE8EB07F13C42BC740658573D5BF77044248704A2`. JSON and SVG/XML parse in both runs.

## Result

The search expands **9,000 of 12,000** permitted nodes over the valid balanced root seeds and records **25** complete room-block layouts with approach-clear route checks. Across these layouts, sampled edge goals are reachable for U-01 in 19, U-02 in 6, U-03 in 6 and U-04 in 12. These counts overlap across different layouts. No single layout reaches U-01, U-02 and U-04 together. The ranked partial visualization marks U-01 and U-04, the best observed combination at **2/3** required public rooms; U-02 is not reachable in that layout. This is a trade-off study, not a solution.

## Geometry and limitations

Room dimensions, the 36×32 ft test envelope, upper-frame offset, lift projection and nominal 3.5 ft contact reservation are source-derived from selected D and the owner-follow-up proposal. Extra packing contacts and edge goal samples are search hypotheses. Edge goals are points for a 4 ft swept-square route screen, not doors or openings. The diagram shows room rectangles, not partitions or actual building geometry.

No selected-D source file, room dimensions, incoming RFA, Revit model or IFC was changed. There are no modeled door leaves/swings, wall thicknesses, stairs, floor openings, headroom, furniture, finish, structure, services, fire/life-safety provisions, code checks or accessibility checks. A disposable Revit derivative and owner-reviewed door/landing choices remain necessary before this can become a design candidate. No compliance, structural-safety, professional-certification or construction-readiness claim is made.
