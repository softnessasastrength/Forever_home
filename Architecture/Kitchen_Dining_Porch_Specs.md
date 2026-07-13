# Kitchen, Dining & Three-Season Porch — Revit Modeling Specs

**Status:** Schematic owner specs for modeling (not permit-ready)  
**Parent concepts:** [Interior/Kitchen_Dining.md](../Interior/Kitchen_Dining.md), [Requirements/Room_Program.md](../Requirements/Room_Program.md)  
**Aesthetic:** Whimsical grandma home — warm, traditional, welcoming  
**Level:** Main living floor (raised-ranch main level)  
**Units:** Imperial (ft-in). Use these as **Type / Instance** parameters and dimension strings in Revit.  
**Renders:** [Detailed](../Renderings/Kitchen_Dining_Porch_Detailed.jpg) · [Earlier concept](../Renderings/Kitchen_Dining_Concept.jpg)

> Validate all dimensions against structure, HVAC, code (IRC/local), manufacturer cut sheets, and accessibility goals before construction.

---

## 1. Zone summary (modeled areas)

| Zone | Revit room name | Target floor area | Plan footprint (clear interior) | Ceiling height |
|---|---|---:|---|---|
| Kitchen | `Kitchen` | **168 sf** | **14'-0" × 12'-0"** | **9'-0"** AFF |
| Dining | `Dining` | **110 sf** | **11'-0" × 10'-0"** | **9'-0"** AFF |
| Combined open volume | (no wall between) | **278 sf** | see layout | continuous plane |
| Three-season porch | `Porch-3Season` | **120 sf** | **12'-0" × 10'-0"** | **8'-0"** AFF (porch) |
| Pantry (adjacent) | `Pantry` | **30 sf** | **5'-0" × 6'-0"** | **9'-0"** AFF |

Areas are **clear interior** to finish face of wall. Wall thickness not included in room area.

**Conditioned vs semi-conditioned**

| Space | Conditioning |
|---|---|
| Kitchen + dining | Fully conditioned main floor |
| Three-season porch | Semi-conditioned / unconditioned — **exclude from 1,500 sf above-grade living target** unless later upgraded |
| Pantry | Conditioned |

---

## 2. Overall layout (plan notes for Revit)

### 2.1 Conceptual plan organization

Model as one open-plan room volume with **room separation lines** (not full-height walls) between kitchen and dining for area schedules.

```text
                    N (garden / porch side — adjust to site)
    ┌──────────────────────────────────────────────────┐
    │                  THREE-SEASON PORCH              │
    │                   12'-0" × 10'-0"                 │
    │         [steps / grade as site requires]         │
    └───────────────┬──────── French doors ────────────┘
                    │  5'-0" pair (clear)  
    ┌───────────────┴──────────────────────────────────┐
    │  DINING 11'-0" × 10'-0"     │  optional hutch    │
    │  table 36"×60" + chairs     │  18" deep           │
    ├─────────────────────────────┤                    │
    │         open floor (no full-height wall)         │
    │  ◄── half wall 8'-0" long @ 42" high ──►         │
    │                                                  │
    │   sink wall (N or W)     ISLAND 8'-0"×4'-0"      │
    │   [base + wall cabs]     [30" range + hood]      │
    │                          stools on dining face   │
    │   fridge 36"   pantry door 2'-6"                 │
    │                                                  │
    │            KITCHEN 14'-0" × 12'-0"                │
    └──────────────────────────────────────────────────┘
              open to living (half wall / wide opening)
```

**Primary axis:** Kitchen work zone → dining table → porch doors (one continuous social axis).  
**Living connection:** Kitchen long side opens to living with half wall; keep **min 6'-0"** clear opening width if not fully open.

### 2.2 Grid / reference planes (suggested)

| Reference plane | Use |
|---|---|
| `CL-Island` | Centerline of island (range center on this line) |
| `CL-Porch-Doors` | Center of French door pair aligned to dining axis |
| `FF-Main` | Finished floor main living level (0'-0") |
| `CLG-Main` | Ceiling 9'-0" AFF |
| `HW-Kitchen` | Face of half wall toward living/dining |

---

## 3. Kitchen — exact dimensions

### 3.1 Room

| Parameter | Value |
|---|---|
| Clear width | **14'-0"** |
| Clear depth | **12'-0"** |
| Area | **168 sf** |
| Ceiling | **9'-0"** AFF gypsum, flat |
| Baseboard | **5-1/4"** traditional profile, painted |
| Wall finish | Paint — warm cream (see finishes) |

### 3.2 Island

| Parameter | Value | Revit notes |
|---|---|---|
| Overall length | **8'-0"** | Family: casework island or in-place mass + counters |
| Overall depth | **4'-0"** | Includes counter overhangs as noted |
| Counter height | **36"** AFF | Standard |
| Counter thickness | **1-1/4"** | Quartz |
| Base cabinet depth (body) | **24"** each side of structure or single 24" + false panel as modeled | Prefer continuous look |
| Overhang — seating side (toward dining) | **12"** | Knee space for stools |
| Overhang — range / ends | **1"** typical | |
| Clearance island ↔ perimeter counters | **42" min**, **48" preferred** | Dimension in plan |
| Clearance island ↔ half wall | **42" min** | |
| Range cutout | **30" wide** freestanding or slide-in range | Centered on island length |
| Range fuel (baseline) | **Electric induction** preferred; gas alternate if utility allows | |
| Landing each side of range | **12" min** clear counter each side | IRC/kitchen planning |
| Island electrical | **2 duplex** receptacles in seating-side knee wall or end panel; GFCI as required | |
| Stools | **2**, 24"–26" seat height; park on dining-facing overhang | |

### 3.3 Island range hood

| Parameter | Value |
|---|---|
| Type | Island chimney or soft traditional island canopy (not pure industrial) |
| Width | **30"–36"** (match or exceed range) |
| Mounting height | **30"–36"** above cooktop (per manufacturer; model **36"** to bottom of hood as default) |
| Duct | Vertical to roof or horizontal to exterior — coordinate structure |
| CFM | Per range manufacturer; plan **400 CFM** class for 30" electric/induction; higher if gas |

### 3.4 Perimeter cabinetry

| Element | Spec |
|---|---|
| Base cabinets | **24" deep**, **34-1/2" high** + **1-1/4"** counter = **36"** AFF |
| Wall cabinets | **12" deep**, **30" or 36" high**; bottom **54"** AFF typical (18" above counter) |
| Upper height to ceiling | Fill to **9'-0"** with stacked cabinets or crown + bulkhead for grandma finished look |
| Sink base | **36" wide** double-bowl or **33"** farmhouse option |
| Dishwasher | **24" wide**, immediately adjacent to sink |
| Refrigerator | **36" wide** counter-depth preferred; rough opening per model; water line if filtered |
| Pantry door from kitchen | **2'-6" × 6'-8"** hinged, swings out of cook path |
| Toe kick | **4" high × 3" deep** |
| Style | **Shaker** painted doors/drawers |
| Hardware | **Aged brass** knobs on doors, **3"–4" pulls** on drawers |

### 3.5 Sink wall

| Parameter | Value |
|---|---|
| Sink | **33" × 22"** undermount stainless **or** 30" apron-front fireclay (owner pick) |
| Faucet | Classic bridge or high-arc pull-down, aged brass / polished nickel |
| Window over sink | **36" W × 42" H** min double-hung or casement; sill **42"** AFF above counter splash |
| Backsplash height | **18"** counter to wall cab; full height if open to window casing |

### 3.6 Half wall (kitchen ↔ living / dining)

| Parameter | Value |
|---|---|
| Length | **8'-0"** (adjust ±12" to align millwork) |
| Height to cap top | **42"** AFF |
| Wall thickness | **6"** (2×4 + finish both sides) or **3-1/2"** stud + finishes |
| Cap / shelf | **11-1/4" deep × 1-1/2" thick** wood or painted MDF; 1/2" overhang each side |
| Finish | Painted both faces to match trim; optional beadboard dining face |
| Electrical | Optional duplex on living face for lamps; coordinate |
| Structural | Non-bearing preferred; if bearing, engineer |

---

## 4. Dining — exact dimensions

### 4.1 Room

| Parameter | Value |
|---|---|
| Clear width | **11'-0"** |
| Clear depth | **10'-0"** |
| Area | **110 sf** |
| Ceiling | **9'-0"** AFF continuous with kitchen |
| Floor finish | Continuous with kitchen (see flooring) |

### 4.2 Furniture clearances (model as generic models / entourage)

| Element | Size | Clearances |
|---|---|---|
| Dining table | **36" W × 60" L × 30" H** (seats 4; leaf to 72–84" optional) | **36" min** chair pull-out; **42" preferred** to walls/porch doors |
| Chairs | **18" × 20"** seat, traditional | Store 2 extras in closet if leaf used |
| Sideboard / hutch (optional) | **48"–60" W × 18" D × 36"–80" H** | On wall opposite porch or flanking doors |
| Circulation to porch | Continuous **36" min** path table edge → door clear | Do not place chairs blocking French doors |

### 4.3 Lighting (dining)

| Fixture | Spec |
|---|---|
| Table pendant or semi-flush | Centered on table; bottom **30"–34"** above tabletop |
| Recessed ambient | **4"** LED, **2700K**, dimmable; **2–3** cans clear of fan/pendant |
| Switch | 3-way possible if porch path used at night |

---

## 5. Three-season porch — exact dimensions

### 5.1 Room / space

| Parameter | Value |
|---|---|
| Clear interior | **12'-0" × 10'-0"** |
| Area | **120 sf** |
| Ceiling height | **8'-0"** AFF porch finish floor |
| Floor elevation | **Same as main FF** preferred (no step) **or** single **1-1/2"–2"** threshold max for accessibility |
| Roof | Extension of main roof or shed/hip porch roof; insulated roof assembly recommended |
| Enclosure | **Glazed + screened operable units** (baseline): windows that open fully + screens for three-season use |
| Heating | None in baseline (three-season); optional electric radiant mat or mini-split later |
| Floor structure | Treated framing / PT or composite decking over structure; slope exterior grade away |

### 5.2 Doors: dining ↔ porch

| Parameter | Value |
|---|---|
| Type | **French doors**, outswing or in-swing per egress/weather |
| Pair width | **5'-0"** unit (**2'-6" + 2'-6"**) or **6'-0"** if wall allows |
| Height | **6'-8"** |
| Glass | Clear tempered where required; traditional divided-lite **or** simulated SDL for grandma look |
| Hardware | Traditional lever or knob, aged brass; multi-point lock preferred |
| Sill | Low-profile accessible sill; weather barrier continuous |
| Flanking windows | Optional **18"–24"** sidelights or **3'-0" × 4'-0"** windows each side for light |

### 5.3 Porch exterior / garden exit

| Parameter | Value |
|---|---|
| Exterior door or screen door | **3'-0" × 6'-8"** to grade/steps |
| Exterior steps | Per grade; max riser **7-3/4"**, min tread **10"**; handrail if ≥4 risers |
| Landing outside door | **3'-0" × 3'-0" min** |

### 5.4 Porch finishes

| Element | Spec |
|---|---|
| Floor | **Porcelain tile** 12×24 wood-look **or** composite deck boards — wet-location rated (see flooring matrix) |
| Walls | Painted wood/composite trim; lower **beadboard wainscot 36" high** optional |
| Ceiling | Beadboard or V-groove, painted soft white; **ceiling fan** rough-in center |
| Lighting | **2** damp-rated wall sconces + **1** ceiling flush or fan light; **2700K** |
| Receptacles | GFCI, weather-resistant where exposed |
| Furniture zone | Small table **30" round** or **30×48"** + 2 chairs; leave **30"** path |

---

## 6. Material specifications (finish schedule)

### 6.1 Kitchen & dining (interior)

| Code | Element | Material / product direction | Color / note |
|---|---|---|---|
| F-01 | Main floor (kitchen + dining) | **Engineered hardwood** 5–7" wide plank, oak, matte/low-sheen **OR** LVP alternative A2 | Warm honey/natural oak — **not gray** |
| F-02 | Porch floor | Porcelain wood-look tile or composite decking | Coordinate tone with F-01 |
| W-01 | Walls | Latex paint, eggshell | Warm cream (e.g. soft butter/cream family) |
| W-02 | Ceiling | Flat paint | Soft white |
| T-01 | Trim / casing / base | Paint-grade wood or MDF, traditional profiles | Soft white or same as T |
| T-02 | Half-wall cap | Hardwood or paint-grade | Stain warm oak **or** paint |
| C-01 | Cabinets | Paint-grade shaker | Cream / warm white |
| C-02 | Cabinet hardware | Solid metal knobs/pulls | Aged brass |
| Q-01 | Counters | Quartz | Warm white / soft cream with subtle movement |
| Q-02 | Island accent (optional) | Butcher block section **or** full quartz | If block: oil-finished maple/walnut |
| B-01 | Backsplash | Ceramic subway **3" × 6"** or **4" × 12"** | Glossy cream/white; soft patterned accent optional |
| G-01 | Grout | Sanded/unsanded per tile | Warm gray-beige, not cool charcoal |

### 6.2 Appliances (baseline for rough-ins)

| Appliance | Size | Notes |
|---|---|---|
| Range | **30" W** | Island; induction preferred |
| Hood | **30–36" W** | Ducted |
| Refrigerator | **36" W** counter-depth | Water line optional |
| Dishwasher | **24" W** | Hardwire or cord per local |
| Microwave | Drawer **or** counter | Avoid dominating uppers; drawer under island landing preferred |

### 6.3 Lighting schedule (electric)

| Tag | Type | Spec | Control |
|---|---|---|---|
| L-K1 | Recessed | 4" LED, **2700K**, 90+ CRI, dimmable | Dimmer |
| L-K2 | Under-cabinet | LED tape or puck, **2700–3000K** | Separate switch/dimmer |
| L-K3 | Island pendants | **2** traditional glass/ceramic pendants | Dimmer |
| L-D1 | Dining pendant | 1 traditional fixture | Dimmer |
| L-P1 | Porch | Damp-rated sconces + ceiling | Switch at dining + porch |

---

## 7. Clearances & accessibility notes

| Item | Requirement |
|---|---|
| Kitchen work aisle | **42" min**, **48"** preferred at island |
| Door clear width (critical) | **32" min clear** (34–36" doors preferred long-term) |
| French door leaf clear | At least one leaf provides **32"+ clear** when open |
| Reach / seating | Island stool knee space 12" deep overhang |
| Future mobility | Continuous floor kitchen→dining→porch preferred (no steps) |
| Stair connection | See [Stairs_Half_Story.md](Stairs_Half_Story.md) — do not place stair run into island clearances |

---

## 8. Revit modeling checklist

- [ ] Create levels: `Main Living FF`, `Main Living CLG` (9'-0"), `Porch FF`, `Porch CLG` (8'-0")
- [ ] Room objects + areas for Kitchen, Dining, Porch-3Season, Pantry
- [ ] Casework families: base, wall, island, pantry shelving
- [ ] Island with 30" range + hood + electrical receptacles
- [ ] Half wall as wall type or generic model with cap
- [ ] French door type 5'-0" or 6'-0" × 6'-8"
- [ ] Windows: sink + dining + porch glazing
- [ ] Floor finishes by room (split porch)
- [ ] Ceiling finishes; porch beadboard
- [ ] Lighting fixtures + switches
- [ ] Dimension strings: island clearances, door centers, half-wall height
- [ ] Tags: rooms, doors, windows, finishes
- [ ] Export plan at 1/4" = 1'-0" and interior elevation of sink wall + island

---

## 9. Coordination

| Discipline | Coordinate |
|---|---|
| Structure | Island footing/blocking if needed; porch foundation; roof over porch; half wall non-bearing |
| Mechanical | Range hood duct; kitchen exhaust makeup air if required; porch optional heat later |
| Electrical | Island circuit(s), GFCI, under-cab, receptacles per code spacing, porch WR/GFCI |
| Plumbing | Sink, DW, fridge water, future pot filler (optional — not baseline) |
| Living room | Half wall alignment, continuous floor transition, shared grandma palette |
| Stairs | Landing clearances — [Stairs_Half_Story.md](Stairs_Half_Story.md) |

---

## 10. Success criteria (modeling)

1. Kitchen 14×12 and dining 11×10 read as one open volume with half wall definition  
2. Island range faces dining; 42"+ aisles dimensioned  
3. French doors on dining–porch axis; porch 12×10 modeled semi-exterior  
4. Finish types assigned and non-gray warm palette  
5. Schedules export areas consistent with Room Program targets  
