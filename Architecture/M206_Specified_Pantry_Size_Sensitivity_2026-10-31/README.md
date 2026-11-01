# M206 specified pantry-size sensitivity

**Status:** reproducible 5 × 6 ft pantry sensitivity; no location or plan selected.

## Method

M206 repeats M205's three pantry positions using the **5 × 6 ft (30 sf)** target stated in `Architecture/Kitchen_Dining_Porch_Specs.md`. The bath-first source route model still records M-04 as 5 × 7 ft (35 sf); M206 binds and reports both sources without editing either. It retains the open kitchen/living start, east x=9 ft porch door, island, stool-use and dining/chair-use proxies, and protects unassigned M-06/B. The second north-edge case shifts the 11 × 10 ft dining package 6 in west.

## Results

Two independent Windows PowerShell 5.1 runs each pass **6/6** wrapper checks. Their M186 searches pass **29/29**, **31/31** and **31/31**; JSON, checks and CSV match byte-for-byte.

| Case | Pantry local rectangle (ft) | Shared kitchen north wall (ft) | Dining shift | Pantry + route use of west A | Route |
|---|---:|---:|---:|---:|---|
| Current position | (11.833, 16.5, 5, 6) | 0 | 0 | 28.00 sf | None; nearest point 4 ft away |
| North edge, nominal 30-in share | (11, 14, 5, 6) | 2.5 | 0 | 38.75 sf | 28 ft, four turns |
| North edge, nominal 36-in share | (10.5, 14, 5, 6) | 3 | 6 in west | 38.75 sf | 28 ft, four turns |

The west-A diagnostic window is 58.99 sf. Either passing sensitivity uses **65.7%** of that area between pantry and route. This improves on the 5 × 7 ft test proxy's 74.5%, but still represents a large circulation-versus-M-06/A trade-off. In the 36-in-share case the shifted dining block has only **2 in** to the hypothetical shell edge, before walls or tolerances. Neither shared-wall length establishes door fit: rough opening, jambs, swing and approach remain unmodeled. The route passes through A; A remains unassigned. B remains blocked and unassigned.

## Reproduction

From the repository root in Windows PowerShell 5.1, use two new empty output directories and scratch prefixes:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m206_specified_pantry_size_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M206-reproduction-1 `
  -ScratchPrefix M206-reproduction-1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/search_m206_specified_pantry_size_sensitivity.ps1 `
  -OutputDirectory .local/revalidation/M206-reproduction-2 `
  -ScratchPrefix M206-reproduction-2
```

Retained artifacts and hashes:

| Artifact | SHA256 |
|---|---|
| `m206-pantry-location-sensitivity.json` | `892AD76D2632060F8EC2D279BEC7F2B275028E1D63F761789237829A5C84C95E` |
| `m206-checks.json` | `BE6C1D476E0C8EA4FE1882CC0FAE7D0EB11255797E81DD3E7A31BA5A431AD10C` |
| `m206-cases.csv` | `844DB6A761735CCCDF1302FC70E75848EDB678B29907B3BD2F7ECFF8BCF7F0CE` |

## Limits and next decision

These three positions are schematic samples in the 40 × 42 ft test envelope, not a selected layout or an exhaustive search. Door fit, pantry storage, room finishes, occupied movement, site conditions, services, code, accessibility and structural coordination are not established. Selected-D, RVT, IFC and RFAs are unchanged. There is no code, permit, professional or construction-readiness conclusion.

The next plan decision is whether the route may consume west A as an explicit trade-off, or whether A should remain available for the unresolved M-06 half bath while circulation is searched elsewhere. Do not treat this route result as approval to assign A.
