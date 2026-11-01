# M261 — Identify, without substituting, the selected Adirondack chair source

**Research date:** 2026-10-31
**Status:** public-source inventory only; owner-selected model remains unidentified.

## Scope and method

Searched public manufacturer and Revit-family catalog pages for Adirondack chair model references. Read-only page inspection only; no account creation, sign-in, gated download, purchase, or family placement. The project instruction says to carry forward the already-selected Adirondack model and not choose a substitute.

## Findings

- RevitCity exposes several distinct records, not one uniquely identifiable family: [“Adirondack chair” object 13489](https://www.revitcity.com/downloads.php?action=view&object_id=13489) says it is based on Popular Mechanics outdoor-furniture instructions and lists Revit Architecture 2010; [“Adirondack Chair” object 12230](https://www.revitcity.com/downloads.php?action=view&object_id=12230) lists Revit Architecture 2012 and its author describes it as larger than average; [“Adirondack Chair and Table – Chair” object 16611](https://www.revitcity.com/downloads.php?action=view&object_id=16611) lists Revit Architecture 2014 and a matching table. Each page says login or join is required to download. No gated action was attempted.
- Public manufacturer libraries also list different families: [NewTechWood's resource library](https://www.newtechwood.com/library/) labels a “NewTechWood Adirondack Chair” resource as RFA, and [Loll Contract's Adirondack Chair (Flat)](https://lollcontract.com/products/adirondack-chair-flat) lists an RFA resource. These are separate products and are not evidence of the owner's earlier selection. Their family geometry, dimensions, license and Revit compatibility were not inspected.
- A recursive read-only filename scan of `C:\Users\brand\Downloads` and the repository's family-intake trees found no Adirondack-named RFA/RVT/IFC/ZIP. This does not identify the model that was previously selected in a browser.

## Decision and next input

No candidate was downloaded, changed, approved, or placed. Do not treat the manufacturer families or any RevitCity record as the selected chair. To proceed with fit/placement, recover the exact selected model's public URL, RevitCity object page, downloaded filename, or a screenshot that identifies it. After source identification, record URL and SHA256 in the authorized intake area, inspect the exact source read-only in Revit, and keep all placement trials in a disposable derivative.

No patio dimensions, furniture count, clearances, location, or site geometry are inferred here. No code, accessibility, structural, professional, permit, or construction-readiness conclusion is made.
