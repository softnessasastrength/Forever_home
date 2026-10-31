# M250 — Integrated route replay and Revit family preflight

**Status:** offline route/baseline verification complete; native family geometry inspection prepared but blocked at Revit's visible introductory overlay. No design or selected-D changes.

## Owner direction and scope

The owner answered “Test 6 in east move.” M233/M241 already record and reproduce the exact 0.5-ft east translation of M-01 as an unselected schematic comparison. This milestone carries the comparison through the latest living/kitchen interface and porch-route screens. It also prepares a fresh Revit measurement of the quarantined American Standard Champion PRO `3195A101.020` bowl-only predecessor. That RFA is not the selected `610AA001.020` complete toilet and does not authorize a bathroom assignment.

## Reproduce the analysis

Run from the repository root in Windows PowerShell 5.1; use new output and M243 scratch prefixes for each replay:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m241_living_kitchen_interface.ps1 -OutputDirectory .local/revalidation/M250-M241-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m241_living_kitchen_interface.ps1 -OutputDirectory .local/revalidation/M250-M241-2
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m242_hall_kitchen_gap_vs_porch_route.ps1 -OutputDirectory .local/revalidation/M250-M242-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/analyze_m242_hall_kitchen_gap_vs_porch_route.ps1 -OutputDirectory .local/revalidation/M250-M242-2
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m243_route_start_sensitivity.ps1 -OutputDirectory .local/revalidation/M250-M243-1 -ScratchPrefix M250-M243-r1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m243_route_start_sensitivity.ps1 -OutputDirectory .local/revalidation/M250-M243-replay-2 -ScratchPrefix M250-M243-r2x
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_architectural_bim_baseline.ps1 -OutputDirectory .local/revalidation/M250-baseline
```

All runs succeed. M241 passes 12/12; its report/check SHA256 values are `9D1DD046749C5187836E96F1C3692DD7816EE6E209AC55EC08344F8F16BE9098` and `85249001D7A2B57DE98E44FAA7505FD2B5B4E86DDECF936AE55A524B9A3A9399`. M242 passes 13/13; hashes are `54C197565569919636EA0FA851E86FCB05FCCC5B11A6B4841A09E7F6DBDB8711` and `44B68032DD98186920373AC4BD4B82FD204C15BC979094A44AB877D81EB0C5B3`. M243 passes 14/14; hashes are `30309C0BF4C4A478B67E3F1D183D75E8DE09EA3C5B19F2C301D66CEB6EA29AC8` and `05A442256502A5652D03E6D6AE614641858C6B3F4C6FA6790990B4563DDAE21B`. In each replay pair the output files match byte-for-byte.

M241 closes the M-01/M-05 six-inch room-block gap but leaves M-01 and M-02 4 ft 10 in apart in x. M242's separate six-inch west kitchen shift closes M-05/M-02 contact but intrudes 2 in into the fixed M215 36-in route proxy. M243 tests route start adjustments against that hypothetical shift: 3 in west leaves only 1 in at the kitchen, while 6 in west leaves 4 in at the kitchen and 3 in minimum to other screened proxies; route-centerline length is 33.5 ft. The 36-in route and 3-in reserve are analytical proxies. These results do not establish walls/openings, installed dimensions, code applicability, or continuous circulation. None of the candidates is selected.

The fresh baseline report `.local/revalidation/M250-baseline/baseline-validation.json` (SHA256 `26A629BD6B6A92B1E55D05602C896118D50242D21CC21FCAD1552BB4E15887DE`) passes two 43/43 selected-D geometry generations, seven identical artifacts per generation, all six SVG parses, and the retained IFC2x3's 26/26 checks with zero errors. Selected-D source/RVT/IFC hashes remain `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`, `C6CED6ACD0E59E49EA0E9821153204FC81ED6CEDE2FCD4F4D7E387C0ACEFD6D0`, and `56251F4754567C78EBB657EC2B99894958C15EF73663F737742F3F36A8472F6F`. Native construction categories remain empty; this is still a space-study baseline, not a complete physical house.

## Revit preflight and current blocker

The current checked-out RevitPilot build is isolated at `.local/revit-pilot/m244-isolated-build/Release/net10.0-windows/`. Its DLL SHA256 is `DAA178628A94057B9DA6A3F66175FD2CE4F58F4F496E92192369A27C16C4B0EC`. The generated manifest has the authorized AddInId `096B0D51-8883-4B3D-BD31-E9622201E785` and resolves to that DLL inside this checkout. Before replacing the live per-user manifest, the prior file was copied and hash-verified at `.local/revit-pilot/registration-backups/20261031T212052948Z/ForeverHome.Pilot.addin`, SHA256 `514F8C24B75E1594E1DAC9A4EB85855F3FCA703D23A922301C7B7F0A1CB168B6`. The live manifest now matches the generated one (SHA256 `F62A7B32E4C94411CAE3C55162AFD198026363EBEF2450A1D5EE516FC1D71436`). No Revit/Windows-wide trust settings were changed.

Revit was at Home with no owner document open. After restart, a trial-introduction panel appeared. The supported Computer Use bridge shows its close target but rejects input because the target is owned by `msedgewebview2.exe`, outside the Revit window. Its current window inventory exposes Revit and GitHub Desktop only, with no separate overlay window to target. No Load Once prompt was confirmed; the M244 DLL was **not** loaded and no Revit command or derivative file was created.

The staged ignored request is `.local/revit-pilot/m244-isolated-build/Release/net10.0-windows/candidate-family-request.json`. It pins source `.local/revit-pilot/family-intake/candidates/american-standard-champion-pro-3195A101020-bowl.rfa` to SHA256 `F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393`, uses a new empty derivative path under `.local/revit-pilot/family-intake/derivatives/M250-champion-pro-bowl-geometry/`, and sets `vertical_wall_host_probe=false`. It instructs the add-in to load and measure this source in a new blank imperial project with zero placed instances. The source remained unchanged; no derivative path was created. Once supported UI access returns, confirm the prompt matches the exact M244 DLL/hash, choose Load Once, run “Inspect quarantined family geometry,” then independently validate the report with `Tools/RevitPilot/validate_candidate_family_geometry.ps1`. This predecessor cannot stand in for the selected 610AA001.020 assembly or establish bath fit.

No code-compliance, accessibility, structural-safety, professional-certification, permit-approval or construction-readiness conclusion follows.
