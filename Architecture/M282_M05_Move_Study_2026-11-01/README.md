# M282 — M-05 move-only envelope screen

**Status:** deterministic static-block study; no M-05 location, entry, or reshape selected.

## Scope and result

The owner authorized a separate analysis-only M-05 move/reshape study, with entry/mudroom function retained as a requirement. M282 tests only **move-only** alternatives, preserving the source block's 4 ft 4 in × 12 ft envelope and 52 sf area. It holds M-01 and M-02 at M256's documented ±6 in comparison positions, uses Selected-D source positions for M-03/M-04/M-05 and the A/B search reservations, and keeps the 40 × 42 ft envelope as a test shell.

On the original M-05 source row, the only screened-clear placement is the existing M-05 block. The 0.25 ft location grid finds 95 north-edge translations and 24 east-edge translations that fit the shell and avoid the six listed room/A/B blocks. Examples are north `(12, 30)` ft and east `(35.6667, 24.25)` ft. Both preserve the exact M-05 footprint and touch a shell edge, but they move away from the presumed front side; no door or entry approach is present. The east example sits **1 in** from the source 5 × 7 ft M-04 block.

Moving M-05 alone leaves the **4 ft 4 in unassigned band** between the M-01 and M-02 room blocks. It does not create shared-edge adjacency or demonstrate the owner's fully open connection. The shell-edge counts are geometric possibilities only: the M05 use, entry orientation, access route, A/B clearance beyond non-overlap, and route through the new positions have not been validated. M-06 remains unassigned; selected-D/RVT/IFC/RFAs are unchanged.

## Reproduction

```powershell
.local/dotnet/dotnet.exe build Tools/M282Generator/M282Generator.csproj --configuration Release --output .local/revalidation/m282-build --ignore-failed-sources
.local/dotnet/dotnet.exe .local/revalidation/m282-build/M282Generator.dll Architecture/M282_M05_Move_Study_2026-11-01/source-block-snapshot.json Decisions/2026-11-01_M05_Move_Reshape_Study_Authorization.md .local/revalidation/m282-a
.local/dotnet/dotnet.exe .local/revalidation/m282-build/M282Generator.dll Architecture/M282_M05_Move_Study_2026-11-01/source-block-snapshot.json Decisions/2026-11-01_M05_Move_Reshape_Study_Authorization.md .local/revalidation/m282-b
```

The package-free generator uses the repository-local .NET 10.0.403 SDK, pins the source-block snapshot, selected-D, M-05 authorization, and A-protection decision, and refuses output outside the repository. Build: 0 warnings/errors. Two independent runs pass 15/15 with byte-identical outputs. An independent PowerShell review verified both example blocks stay inside the 40 × 42 ft shell and avoid M-01, M-02, M-03, M-04, A, and B.

| Artifact | SHA256 |
|---|---|
| `m282-m05-move-screen.json` | `14638214F80EA59DC5ABB6EC2D71788BDD5E8821257D5301174C46A55E40428B` |
| `m282-checks.json` | `A288CF964F8535E2ABE08CCA1CB704C18CAAEA0E6DDC91DB621279F1BE64FDFE` |
| `source-block-snapshot.json` | `12145EBDF1C065804179242750ABE3D80917F8F23B8DA71B256495B387122910` |

## Design question exposed

The existing model labels M-05 “Front arrival / hall,” but no front elevation, exterior entry door, or approach is dimensioned in this source set. The north/east alternatives therefore cannot yet be judged to preserve that function. The move-only block also does not solve the remaining 4 ft 4 in social-room gap. The next study needs the owner's direction on front-side entry versus a side/rear entry, or authorization to move M-01/M-02 as well. No architectural or code-compliance claim follows from this screen.
