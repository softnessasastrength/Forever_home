# Walkthrough shell wireframe study

Date: 2026-11-02

Status: **command compiled; Revit runtime not verified; no RVT created by this command yet.**

## Owner-selected study inputs

The owner requested a clearly labeled 8–10 ft ceiling comparison and approved re-spacing study floors across that range. The command creates 8, 9 and 10 ft interval cases in one separate model, with 50 ft plan offsets between cases. It reads only the hash-pinned selected-D source and preserves its room blocks/IDs and documented plan-frame offsets. Comparative shell rectangles are 40 × 42 ft for Main and 36 × 32 ft for each rear wing. These are study envelopes, not accepted final exterior dimensions.

The study uses bottom/top room rectangles and vertical corner model curves to show the room volumes as wireframes. It does not create walls, floors, assemblies, doors, windows, stairs, roofs, structure or MEP. The intervals are zero-assembly visualization proxies, not a claim that clear ceiling and floor-to-floor dimensions are equal. The 8/9/10 ft cases are not selected.

## Implementation and validation state

`Tools/RevitPilot/WalkthroughShellStudyCommand.cs` adds a separate Revit command and an isometric comparison view. It creates a new project document, removes only the new template's seed levels, creates exactly nine labeled comparison datums, generates the source-derived room/shell outlines, and saves under ignored `.local/revit-pilot/walkthrough-shell/<timestamp>/`. The checked-in selected-D source is read-only.

The RevitPilot compiles against the installed Revit 2027 API with **0 errors and 2 existing reference-conflict warnings**. Final project-local assembly SHA256: `4218E9C1A84943E30255CDBBBB95099F6B36AC77B6D0F89EC802E9C0D37800FD`. The authorized per-user manifest keeps AddInId `096B0D51-8883-4B3D-BD31-E9622201E785`, points inside this checkout to that exact DLL, and its prior manifest was preserved under ignored `.local/revit-pilot/registration-backups/20261101T163813099Z/`.

Revit restarted to Home, but no trust prompt identifying the final DLL appeared. Therefore the new command was **not run**, no wireframe RVT/report exists, and no Revit geometry/runtime behavior is claimed. Continue only if Revit exposes the trust prompt for the exact project-local path/hash; choose Load Once only in that case. Never use Always Load or broad trust/security changes.

## Open requirements before a real walkthrough

The source has no actual door/window openings, floor assemblies, stair geometry, roof assembly, or MEP. The material schedule records living-room skylights with diffuse light and TV-glare avoidance, but location, size, product and roof openings are not designed. The first wireframe command is an inspection scaffold only; it is not a navigable finished-house model or an architect-review package.
