
## Machine-readable acceptance gate

Run the consolidated evidence check from the repository root:

```powershell
pwsh -NoProfile -File Tools/validate_verified_bim_milestone.ps1 `
  -Output .local/revalidation/verified-bim-milestone.json
```

It checks the current Selected-D baseline, M318 wall/plate chain, M317 public family evidence, M320 M-06 gross-envelope screen, M321 kitchen IFC, and M83 comparative roof IFC. A pass validates the evidence chain only; it does not turn the disposable studies into a selected or construction-ready house.
