# Walkthrough shell wireframe study

Date: 2026-11-02

Status: **historical M298 wireframe; runtime verified in Revit 2027.3 and preserved. The 8/9/10-ft vertical-spacing interpretation is superseded by the owner's later clear-ceiling direction; do not use these levels as active building datums.**

## Owner-selected study inputs

The owner requested a clearly labeled 8–10 ft ceiling comparison and approved re-spacing study floors across that range. The command creates 8, 9 and 10 ft interval cases in one separate model, with 50 ft plan offsets between cases. It reads only the hash-pinned selected-D source and preserves its room blocks/IDs and documented plan-frame offsets. Comparative shell rectangles are 40 × 42 ft for Main and 36 × 32 ft for each rear wing. These are study envelopes, not accepted final exterior dimensions.

The study uses bottom/top room rectangles and vertical corner model curves to show the room volumes as wireframes. It does not create walls, floors, assemblies, doors, windows, stairs, roofs, structure or MEP. The intervals are zero-assembly visualization proxies, not a claim that clear ceiling and floor-to-floor dimensions are equal. The 8/9/10 ft cases are not selected.

## Implementation and validation state

`Tools/RevitPilot/WalkthroughShellStudyCommand.cs` adds a separate Revit command and an isometric comparison view. It creates a new project document, reuses that template's single seed level and creates the other eight labeled comparison datums, generates the source-derived room/shell outlines, then closes the disposable document before hashing it. Outputs are saved under ignored `.local/revit-pilot/walkthrough-shell/<timestamp>/`. The checked-in selected-D source is read-only.

The RevitPilot compiles against the installed Revit 2027 API with **0 errors and 2 MSB3277 reference-conflict warnings** (Microsoft.VisualBasic 10.0 versus 10.1 through Revit references). Project-local assembly SHA256: `86F3440736FE6D47F679E0F670194AAC2C307BAFD225564BC952AB800FAFE5EB`. The authorized per-user manifest keeps AddInId `096B0D51-8883-4B3D-BD31-E9622201E785` and points inside this checkout to that exact DLL. This run did not replace the manifest.

Revit 2027.3 loaded the authorized ribbon and ran the command in a new Imperial Multi-discipline template document. No trust prompt appeared in this session, so no trust choice was made. Run `20261101T170505234Z` produced `FH_Walkthrough_Shell_Study.rvt` and a JSON manifest. Manifest checks passed: selected-D source SHA256 `516D6D17E5B6ED6C8EC8CBF7A925CC67C5CC1C0ADA194C22EA3FA124E2BB72BB` matches; saved-RVT SHA256 `7E6B632C89DF3808A9B595B4D56237D7B9987CE04BC3DE0718D804E45FC24483` matches; exactly 9 levels; 63 records representing all 21 source space IDs across 8/9/10-ft cases; 828 vertical corner model curves; zero walls, floors, stairs, or roofs. The RVT was reopened in Revit and the named isometric comparison view was visually checked. Revit was closed before the independent RVT hash check.

Reproduction: build with the local SDK using `& '.local/dotnet/dotnet.exe' build 'Tools/RevitPilot/RevitPilot.csproj' -c Release -p:BaseOutputPath='<absolute-checkout>\.local\revit-pilot\walkthrough-shell\' -clp:ErrorsOnly`; verify the per-user manifest AddInId/path and DLL SHA256; in Revit 2027.3 create a new Imperial Multi-discipline project and run **Forever Home Pilot → Build walkthrough shell study**. Parse the generated JSON with PowerShell `ConvertFrom-Json`; use `Get-FileHash` to confirm source/RVT hashes; assert 9 levels, case values `[8,9,10]`, 21 distinct IDs/63 records, 828 curves and zero native building elements; reopen the RVT and inspect its named 3D view.

## Open requirements before a real walkthrough

The source has no actual door/window openings, floor assemblies, stair geometry, roof assembly, or MEP. The material schedule records living-room skylights with diffuse light and TV-glare avoidance, but count, location, size, product and roof openings are not designed. The wireframe command is an inspection scaffold only; it is not a navigable finished-house model or an architect-review package. It does not validate code, clearances, structure, or construction readiness.

## Supersession note

The owner later clarified that 8, 9 and 10 ft are clear-ceiling alternatives and left floor-to-floor spacing unresolved. M298's spaced 8/9/10-ft datums therefore remain historical wireframe evidence only. The active geometry basis and replacement comparison are tracked in `Architecture/Dimension_Register.md` and [`M311 clear-ceiling comparison`](../M311_Clear_Ceiling_Wall_Height_Study/README.md).
