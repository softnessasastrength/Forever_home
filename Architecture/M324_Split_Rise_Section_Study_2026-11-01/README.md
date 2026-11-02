# M324 — split-rise section sensitivity

This analysis carries the owner-authorized “compare a split-rise arrangement” direction forward without selecting a floor-to-floor datum. It compares the documented 8 × 7½ in / 60 in Selected-D arithmetic with a 4+4 equal-riser split and records a separate DD-013 6+2 remainder sensitivity. The cases are arithmetic proposals only; no native stair, opening, landing, route, assembly, or Revit model is created.

```powershell
pwsh -NoProfile -File Tools/analyze_split_rise_section.ps1 `
  -Output .local/revalidation/split-rise-section.json
```

The 4+4 case preserves eight total 7½ in risers and therefore the 60 in comparison rise, but it still requires a real landing, headroom, opening, wall/finish coordination and route. The DD-013 preference remains 43½ in total; adding a two-riser remainder is deliberately labelled a sensitivity, not an approved stair.
