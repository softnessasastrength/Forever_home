# Main Floor Schematic — Dimensions for Revit

**Status:** Schematic layout intent (not a construction drawing)  
**Level:** Main living floor (`Main Living FF` = 0'-0")  
**Related:** [Kitchen_Dining_Porch_Specs.md](Kitchen_Dining_Porch_Specs.md), [Stairs_Half_Story.md](Stairs_Half_Story.md), [Building_Program.md](Building_Program.md)

Scale for export when drawn: **1/4" = 1'-0"**.

---

## 1. Level datums (raised-ranch half stories)

| Level name | Elevation (baseline) | Notes |
|---|---:|---|
| `Lower FF` | **−3'-7 1/2"** | Finished basement; S1 up 6×7-1/4" |
| `Main Living FF` | **0'-0"** | Kitchen, dining, living, porch FF preferred match |
| `Main Living CLG` | **+9'-0"** | Kitchen / dining / living |
| `Porch CLG` | **+8'-0"** | Three-season porch |
| `Upper FF` | **+3'-7 1/2"** | Private suite; S2 up 6×7-1/4" from main |
| `Upper CLG` | **+12'-7 1/2"** | Adjust to actual upper ceiling height |

If structure changes floor-to-floor, keep **5–7 risers** per half-story and equalize riser height (max 7-3/4").

---

## 2. Open social volume — key dimensions

| Space | Width | Depth | Area | Ceiling |
|---|---:|---:|---:|---:|
| Kitchen | 14'-0" | 12'-0" | 168 sf | 9'-0" |
| Dining | 11'-0" | 10'-0" | 110 sf | 9'-0" |
| Living (from program) | ~14–16' | ~12–14' | 180–220 sf | 9'-0" |
| Three-season porch | 12'-0" | 10'-0" | 120 sf | 8'-0" |
| Pantry | 5'-0" | 6'-0" | 30 sf | 9'-0" |

Porch area is **semi-conditioned** — exclude from 1,500 sf above-grade living target unless upgraded.

---

## 3. Plan diagram (schematic)

Orientation is **illustrative** — rotate to site. North arrow = garden / porch side for this diagram.

```text
                         GARDEN / YARD
    ┌─────────────────────────────────────────────┐
    │         THREE-SEASON PORCH                  │
    │              12'-0" × 10'-0"                │
    │     [ext. door 3'-0"]    ceiling 8'-0"      │
    └──────────────┬──────────────────────────────┘
                   │ French doors D-01
                   │ 5'-0" or 6'-0" × 6'-8"
    ┌──────────────┴──────────┬───────────────────┐
    │   DINING                │  hutch 18" d      │
    │   11'-0" × 10'-0"       │  optional         │
    │   table 36"×60"         │                   │
    │                         │                   │
    ├─────────────────────────┘                   │
    │  half wall 8'-0" L × 42" H ────► living     │
    │                                             │
    │   KITCHEN 14'-0" × 12'-0"                   │
    │  ┌──────── island 8'-0" × 4'-0" ─────────┐  │
    │  │  30" range  | stools on dining face   │  │
    │  └───────────────────────────────────────┘  │
    │  42"–48" aisles                             │
    │  sink wall + 36" fridge + pantry 2'-6" door │
    └──────────────────┬──────────────────────────┘
                       │ open / half wall to
    ┌──────────────────┴──────────────────────────┐
    │  LIVING  (hearth media wall: TV + faux fire)│
    │  loveseat + La-Z-Boy                        │
    │  front entry with grand arch                │
    └──────────────────┬──────────────────────────┘
                       │
              half-story stair S1/S2 zone
              (do not invade island aisle)
```

---

## 4. Dimension strings to place in Revit

### Kitchen

1. Overall room 14'-0" × 12'-0"  
2. Island 8'-0" × 4'-0"; centerline `CL-Island`  
3. Aisle island ↔ perimeter **42" min / 48" pref**  
4. Range 30" centered on island; 12" landing each side  
5. Seating overhang 12" toward dining  
6. Half wall length 8'-0"; height 42" to cap  
7. Sink window rough opening  

### Dining / porch

1. Dining 11'-0" × 10'-0"  
2. Table clearances 36–42" to walls/doors  
3. Door centerline `CL-Porch-Doors` aligned to dining axis  
4. Porch 12'-0" × 10'-0"  
5. Threshold dining–porch: prefer **0"** level change  

### Stairs

1. Clear width ≥ 36"  
2. Riser 7-1/4" × 6; tread 10-1/2"  
3. Landings 36" min in direction of travel  
4. Handrail 36" above nosing  
5. Keep out of kitchen 42" work aisle  

---

## 5. Adjacency matrix (main floor)

| From | To | Connection |
|---|---|---|
| Kitchen | Dining | Open concept, continuous F-01 floor |
| Dining | Three-season porch | French doors D-01 |
| Kitchen | Living | Half wall / wide opening |
| Kitchen | Pantry | Door D-03 |
| Kitchen | Mudroom | Preferred short path (mudroom size per program) |
| Living | Front entry | Grand arch / decorative trim |
| Main hall | Lower / upper | Half-story stairs S1 / S2 |

---

## 6. Drawing set (minimum schematic sheets)

When exporting from Revit or drafting:

| Sheet | Content |
|---|---|
| A-101 | Main floor plan @ 1/4" = 1'-0" with rooms, doors, dimensions |
| A-102 | Lower floor plan (reference) |
| A-103 | Upper suite plan (reference) |
| A-201 | Building section through kitchen–dining–porch |
| A-202 | Section through half-story stairs |
| A-301 | Kitchen elevations (sink wall, island) |
| A-401 | Stair plan + section with railing callouts |
| I-101 | Finish plan with material codes from [Material_Schedule.md](Material_Schedule.md) |

Renders live in `/Renderings` until true sheet exports exist in `/Exports`.
