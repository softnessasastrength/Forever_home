# Revit 2027 to Revit 2018 compatibility

Research date: 2026-10-25
Status: verified Autodesk guidance; test results pending.

## Critical finding
Revit has no native backward-save. RVT projects, RFA families and RTE templates saved in 2027 cannot be opened in Revit 2018. Opening and saving a 2018 file in 2027 upgrades that copy; keep a separate untouched 2018 master if native editability in 2018 is essential.

## Interchange options
- IFC: geometry and some BIM metadata; **not** a fully editable native model in 2018. Expect loss of parametric behavior, hosted relations and other elements; linking may be preferable to opening IFC. Test IFC2x3 Coordination View first.
- DWG/DXF: 2D plans, sections, elevations and selected 3D reference geometry; choose an older compatible AutoCAD export version.
- SAT: geometric reference exchange, not native BIM.
- PDF: sheets for human review.
- CSV: room, door, window and equipment schedules and design parameters; cannot preserve native Revit relationships alone.
- RVT/RFA: archive 2027 originals for later 2027 access, but never imply 2018 can load them.

## Recommended approach
1. Decide whether 2018 will be the long-term editing master before deep 2027 modeling.
2. If so, create and protect a native 2018 master; use 2027 only on disposable upgraded copies.
3. Keep a version-neutral project specification (room IDs, levels, dimensions, wall definitions, materials, equipment envelopes and coordinates) to enable future rebuilds via version-specific scripts.
4. During the trial, export IFC2x3, DWG, PDF and CSV plus RVT, and verify imports in 2018 on a small representative test model: walls, doors, windows, stairs, room properties and one complex family.
5. Record geometry discrepancies, lost metadata and reconstructability. Do not call an IFC-linked model fully editable.
6. Back up all files and dependencies before Revit 2027 trial expiration.

## Autodesk sources
- https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Backwards-compatibility-of-Revit-with-earlier-releases-of-the-software.html
- https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Considerations-when-transferring-model-data-between-different-versions-of-Revit.html
- https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Convertion-or-downgrade-of-file-into-older-former-version-of-Revit.html
- https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/How-to-restore-model-that-was-upgraded-to-newer-version-in-Revit.html
