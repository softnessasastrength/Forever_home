# M235 — Revalidate the selected-D geometry and IFC baseline

**Status:** source and retained space-study export reproduced and validated; native construction geometry remains absent.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/validate_architectural_bim_baseline.ps1 -OutputDirectory .local/revalidation/M235-baseline
```

The validator runs selected-D generation twice into separate ignored directories, compares the seven generated artifacts, parses all three SVGs per run, validates the retained Revit 2027.3 RVT/IFC2X3 package against the source, and confirms the protected inputs did not change.

## Evidence

The retained report is `.local/revalidation/M235-baseline/baseline-validation.json`.

| Check | Result |
|---|---:|
| Selected-D geometry checks | 43/43 in each of two runs |
| Generated artifacts | 7 per run, all byte-identical |
| Plan SVGs | 3 per run, XML-valid |
| IFC2X3 checks | 26/26; zero errors |
| Source / RVT / IFC unchanged | Yes |

SHA256 fingerprints: selected-D source `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`; retained space-study RVT `C6CED6ACD0E59E49EA0E9821153204FC81ED6CEDE2FCD4F4D7E387C0ACEFD6D0`; IFC `56251F4754567C78EBB657EC2B99894958C15EF73663F737742F3F36A8472F6F`.

## Limits

This validates the schematic room-block source and retained space-study RVT/IFC. It does not establish physical construction geometry: native construction categories remain empty. The result is not a code-compliance, accessibility, structural-safety, professional-approval, permit, or construction-readiness determination.
