
## Machine-readable acceptance gate

Run the consolidated evidence check from the repository root:

```powershell
pwsh -NoProfile -File Tools/validate_verified_bim_milestone.ps1 `
  -Output .local/revalidation/verified-bim-milestone.json
```

It checks the current Selected-D baseline, M318 wall/plate chain, M317 public family evidence, M320 M-06 gross-envelope screen, M321 kitchen IFC, and M83 comparative roof IFC. A pass validates the evidence chain only; it does not turn the disposable studies into a selected or construction-ready house.

## Current architect-review bundle

For the current sandbox evidence set, run the consolidated sequence first:

```powershell
pwsh -NoProfile -File Tools/run_verified_bim_sequence.ps1 `
  -OutputPath .local/revalidation/verified-bim-sequence-current.json
```

The sequence includes the direct IFC composition, interior 8/9/10-ft comparison, roof/skylight study, native split-rise stair evidence, M-06 boundary gate, and the architect-review bundle validator. The bundle can also be run directly:

```powershell
pwsh -NoProfile -File Tools/validate_architect_review_bundle.ps1 `
  -Output .local/revalidation/architect-review-bundle-current.json
```

The current bundle is a disposable review index, not a selected design. It deliberately preserves the pinned Selected-D lineage, keeps M-06/B unassigned or fit-blocked, and leaves assemblies, floor-to-floor/stair section, product openings, MEP, accessibility, site fit and applicable Connecticut interpretation for manual review. No result is a code-compliance, structural-safety, professional, permit or construction-readiness claim.

For a category-by-category audit of what the current evidence does and does not establish, run:

```powershell
pwsh -NoProfile -File Tools/validate_architect_review_requirements.ps1 `
  -BundleReport .local/revalidation/architect-review-bundle-sequence.json `
  -Output .local/revalidation/architect-review-requirements.json
```

The matrix reports `pass-with-open-gates` when the requested categories have evidence but unresolved design decisions remain. Its classifications distinguish native comparison geometry, proxies, reservations, direction markers and intentionally open requirements.
