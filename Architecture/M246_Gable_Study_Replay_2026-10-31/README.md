# M246 — Replay the steep-gable massing comparison

**Status:** reproducibility check of the existing M83 analysis; no pitch, ridge direction, house dimension, or roof geometry is selected.

## Reproduction

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1 -OutputDirectory .local/revalidation/M83-resume-a
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/build_m83_gable_massing_options.ps1 -OutputDirectory .local/revalidation/M83-resume-b
```

Both runs pass **13/13** generator checks. The retained M83 artifacts and both isolated replays match byte-for-byte:

| Artifact | SHA256 |
|---|---|
| `roof-options.json` | `39A54E0660F2C206634B4D0921F015870FA0DF4A39A71CFE7EA71799AB383550` |
| `checks.json` | `0498973FE03FF7D80EE4CCCCBEEC99995AE6AC1C757FAC96D479D8CE9C20DFD6` |
| `roof-options.svg` | `9C5EA4DBBB297A530463774C610CE8D1C81E18E7FA1135A414BCDBC632981219` |

The repository's offline RevitPilot regression suite also passes **49/49** with `.\.venv\Scripts\python.exe -m unittest discover -s Tools\RevitPilot\tests -v`. This exercises command/validator contracts and does not replace Revit host execution.

The JSON parses with six cases on the source-bound hypothetical **38.333333 × 40 ft** upper-shell outline. The SVG parses as XML. The 12:12 comparison rises 20 ft above the relative eave for ridge-X and 19.1667 ft for ridge-Y; these are idealized half-span calculations, not building heights. Selected-D remains SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB`.

## Retained Revit/IFC host evidence

The independent M83 IFC validator was freshly run against both retained Revit exports, writing reports outside their source directories:

```powershell
.\.venv\Scripts\python.exe Tools\RevitPilot\validate_gable_massing_ifc.py .local\revit-pilot\roof-massing\20261031T104347203Z --report .local\revalidation\M246-host-a-validation.json
.\.venv\Scripts\python.exe Tools\RevitPilot\validate_gable_massing_ifc.py .local\revalidation\M169-m83-b-exact-backup --report .local\revalidation\M246-host-b-exact-backup-validation.json
```

Both pass **21/21**, with zero schema errors and `saved_rvt_fingerprint_matches: true`. Report SHA256 values are `F0EAAC76625EAA898BA6E22FCFAF693C91D6BE4BB8169C31D4E82CF584938F59` (M83-A) and `B4A3239F653DC0FD2F220453E87B6977436D265D4C28981BD3EA21EC10E2743F` (M83-B exact backup). The second report validates the preserved `.0001.rvt` copy whose hash matches its export manifest. The later-saved primary M83-B RVT is a different file and must not be paired with that IFC.
## Limits

This replay verifies deterministic files and arithmetic; the separate host checks validate only six open, zero-thickness proxy meshes per IFC. They do not create native Revit Roof elements, roof assemblies, framing, gable walls, overhangs, or an occupied roof/attic. No site, eave datum, structural criteria, code applicability, or professional design is established.
