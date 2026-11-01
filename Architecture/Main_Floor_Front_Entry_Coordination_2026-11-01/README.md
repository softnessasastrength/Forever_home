# Main-floor front-entry coordination

Rotated dining independent audit passes: reconstructs every table/chair/use-zone rectangle from fingerprinted M192 input and stated rotation/centring transform; checks source dining, arrival/dining-rear endpoints, disjoint domain coverage and obstacle exclusion. 19 routes/4511 swept patches pass in each of two independent audits. Packaged artifacts under Architecture/Main_Floor_Front_Entry_Coordination_2026-11-01/artifacts. Still proposed: no porch connection, door swing, appliance-open zones, living furniture or vertical-core reconciliation. No selected-D or native model changes.

## Reproduction

1. Run Tools/search_main_front_entry_blocks.ps1 with a fresh -OutputDirectory.
2. Run Tools/screen_front_entry_furnished_interfaces.ps1 with that -InputDirectory and a fresh -OutputDirectory.
3. Build Tools/FrontRoute/FrontRoute.csproj using the repository-local .NET SDK into ignored scratch output.
4. Run FrontRoute.dll with the furnished-interfaces.json, new output JSON, Selected-D study.json, M192 rotated-dining-candidate.json and rotate-dining arguments, in that order.
5. Run Tools/validate_front_routes.ps1 with -Routes, -Interfaces, -SelectedD, -DiningFurniture and a new -Output.

The 19 sampled passes are related placements, not independent complete house designs. The current source dining footprint is retained, with a whole-set furniture rotation and centring proposal. B is unassigned and A protected. No code, structural, professional or construction approval is established.

Visual review completed using System.Drawing-rendered candidate 21 plan. Route band and dining furniture agree with report; drawing reveals large unallocated main-shell area, remote pantry and unfurnished living traverse. Candidate remains route-tested analysis, not selected house layout. Next jointly relocate full 5x7 pantry within authorized study scope and test furnished living/arrival routes; preserve A/B and future core. PNG/SVG and porch-route/independent report now archived with study. Tools/FrontRoute ignores generated obj/bin; no generated binaries staged. No source/Revit/IFC change or remote operation.
