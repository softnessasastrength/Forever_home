# Revit Workspace

Use this directory for Revit models (`.rvt`), families, templates, and export notes. Binary models are optional in git; **source-of-truth dimensions and materials live in `/Architecture`**.

## Modeling order (recommended)

1. **Levels & grids** — [Main_Floor_Schematic.md](../Architecture/Main_Floor_Schematic.md)  
2. **Main floor walls** — open kitchen + dining volume; porch as semi-exterior room  
3. **Casework** — island, perimeter, pantry per [Kitchen_Dining_Porch_Specs.md](../Architecture/Kitchen_Dining_Porch_Specs.md)  
4. **Stairs & railings** — [Stairs_Half_Story.md](../Architecture/Stairs_Half_Story.md)  
5. **Doors / windows** — French doors dining–porch; sink window  
6. **Materials** — apply codes from [Material_Schedule.md](../Architecture/Material_Schedule.md)  
7. **Rooms & areas** — Kitchen, Dining, Porch-3Season, Living, Pantry  
8. **Views** — plans 1/4"=1'-0", kitchen elevations, stair section  
9. **Export** — PDF/DWG/IFC to `/Exports` when ready  

## Spec index

| Topic | Document |
|---|---|
| Building program | [Architecture/Building_Program.md](../Architecture/Building_Program.md) |
| Kitchen / dining / porch dimensions | [Architecture/Kitchen_Dining_Porch_Specs.md](../Architecture/Kitchen_Dining_Porch_Specs.md) |
| Main floor schematic | [Architecture/Main_Floor_Schematic.md](../Architecture/Main_Floor_Schematic.md) |
| Stairs | [Architecture/Stairs_Half_Story.md](../Architecture/Stairs_Half_Story.md) |
| Material list | [Architecture/Material_Schedule.md](../Architecture/Material_Schedule.md) |
| Bathrooms | [Architecture/Bathrooms_Specs.md](../Architecture/Bathrooms_Specs.md) |
| Flooring decisions | [Interior/Flooring_Options.md](../Interior/Flooring_Options.md) |
| Room program | [Requirements/Room_Program.md](../Requirements/Room_Program.md) |
| Concept renders | [Renderings/](../Renderings/README.md) |

## Naming

- Project: `FH_ForeverHome_Schematic.rvt` (suggested)  
- Materials: `FH-` prefix per Material Schedule  
- Views: `A-101 Main Floor Plan`, etc.

## Disclaimer

Owner-development model only until reviewed by licensed design professionals and coordinated with structure, MEP, and local code.
