# Bathrooms — Revit Modeling Specs

**Status:** Schematic owner specs for modeling (not permit-ready)  
**Aesthetic:** Warm whimsical grandma home — traditional fixtures, soft light, cream millwork  
**Related:** [Interior/Bathrooms.md](../Interior/Bathrooms.md), [Material_Schedule.md](Material_Schedule.md), [Requirements/Room_Program.md](../Requirements/Room_Program.md)  
**Renders:** [Master](../Renderings/Bathroom_Master_Concept.jpg) · [Jack & Jill](../Renderings/Bathroom_Jack_and_Jill_Concept.jpg)

> Validate clearances, exhaust, waterproofing, and accessibility against IRC/local code and licensed design professionals before construction.

---

## 1. Bathroom program summary

| Bath | Revit room name | Serves | Type | Clear footprint | Area | Ceiling |
|---|---|---|---|---|---:|---:|
| **Primary (master) full bath** | `Bath-Primary` | Primary bedroom only | Private full bath | **9'-0" × 10'-0"** | **90 sf** | **9'-0"** |
| **Jack & Jill full bath** | `Bath-JackJill` | Two secondary bedrooms (see §2) | Shared full bath, dual entry | **10'-0" × 12'-0"** | **120 sf** | **9'-0"** |

Both baths are **full baths** (toilet + lavatory + bathing). Guest powder on main floor (if provided later) is **out of scope** of this document.

---

## 2. Bedroom adjacencies

### 2.1 Primary bath

```text
[ Primary bedroom ] ── door 2'-8" ── [ Bath-Primary ]
         │
         └── suite doors to boutique / hybrid rooms
```

- **One door only** from primary bedroom (privacy lockset).
- Optional second linen closet door from suite hall — **not baseline**.
- Stack plumbing with Jack & Jill or lower-level bath when plan allows.

### 2.2 Jack & Jill bath (open, spacious)

Shared between **two secondary bedrooms**:

| Door | Connects |
|---|---|
| **D-JJ-A** | Bedroom A — baseline: **Branden's hybrid bedroom/office** |
| **D-JJ-B** | Bedroom B — baseline: **Guest / third bedroom** |

```text
[ Bedroom A ]                              [ Bedroom B ]
 (hybrid/office)                            (guest/flex)
      │  D-JJ-A 2'-8"                          │  D-JJ-B 2'-8"
      └────────────►  BATH-JACKJILL  ◄─────────┘
                      10'-0" × 12'-0"
                 dual vanity | open floor
                 toilet zone | walk-in shower
```

- Each bedroom door: **privacy lock** so one occupant can secure the bath.
- **No hall door** in baseline (true Jack & Jill). Hall access can be added later if plan needs guest route without entering a bedroom.
- Open layout: **no full-height walls** splitting the wet room into tiny compartments except optional **toilet half-wall or 42" screen** (see §4). Prefer one generous volume.

---

## 3. Primary (master) full bath — dimensions

### 3.1 Room

| Parameter | Value |
|---|---|
| Clear interior | **9'-0" W × 10'-0" D** |
| Area | **90 sf** |
| Ceiling | **9'-0"** AFF |
| Floor | **F-10** porcelain tile (see materials) |
| Base | **T-01** or tile cove base 4–6" |

### 3.2 Fixture layout (baseline plan)

```text
     9'-0"
  ┌────────────────────────────┐
  │  vanity 60"    │  toilet   │  10'-0"
  │  double or     │  30" zone │
  │  single 48–60" │           │
  │────────────────┤           │
  │                            │
  │   tub 60"  OR  shower 36×48│
  │   (baseline: tub/shower    │
  │    combo 60" alcove)       │
  └────────────────────────────┘
        door from primary →
```

| Zone | Size / clearance |
|---|---|
| Entry door | **2'-8" × 6'-8"** (32" clear preferred long-term) |
| Vanity | **60" W × 22" D** furniture-style double **or** **48" W** single with storage |
| Vanity counter height | **34"** AFF (comfort) or **36"** if matching kitchen language |
| Mirror | Full width of vanity; optional medicine cabinets recessed |
| Toilet clear | **30" W** min zone; **15"** min from centerline to wall/obstruction each side; **21"** clear in front |
| Bathing | **60" alcove tub/shower** baseline **or** **36"×48"** walk-in shower if tub declined |
| Circulation | **30" min** path; **36"** preferred at vanity face |

### 3.3 Primary fixtures

| Fixture | Style | Spec |
|---|---|---|
| **Toilet** | Traditional **two-piece**, elongated bowl, **comfort height** (~16-1/2" rim) | Soft-close seat; dual-flush or 1.28 gpf; **white**; skirted trapway preferred for cleaning |
| **Lavatory** | Undermount oval **or** classic drop-in in quartz top | Double bowl if 60" vanity; single if 48" |
| **Faucets** | Widespread or centerset **traditional** | **Aged brass** or polished nickel; cross or lever handles |
| **Tub/shower** | Cast-iron or acrylic **60" alcove** with shower trim on wall | Traditional telephone-style or rain + handheld; cream tile surround |
| **Accessories** | Towel bars, TP holder, robe hooks | Match faucet finish |

### 3.4 Primary vanity

| Parameter | Spec |
|---|---|
| Type | **Furniture-style** freestanding look **or** built-in shaker |
| Width | **60"** (double) preferred; **48"** min |
| Depth | **22"** |
| Doors/drawers | Soft-close; drawers preferred for daily use |
| Finish | Painted **cream / soft white** (match kitchen C-01 family) |
| Hardware | **Aged brass** knobs/pulls |
| Counter | **Q-01** warm quartz 1-1/4" |
| Backsplash | 4" quartz **or** tile to 48" with mirror |
| Lighting | **2** wall sconces flanking mirror **or** bar light; **2700K** |

---

## 4. Jack & Jill bath — dimensions (open & spacious)

### 4.1 Room

| Parameter | Value |
|---|---|
| Clear interior | **10'-0" W × 12'-0" D** |
| Area | **120 sf** |
| Ceiling | **9'-0"** AFF |
| Character | **Open plan wet room** — dual vanity as focal wall, generous floor, large shower, toilet lightly screened not boxed in a closet |

### 4.2 Fixture layout (baseline)

```text
                    12'-0"
  ┌──────────────────────────────────────────┐
  │ D-JJ-A          open floor           D-JJ-B │
  │  →                                      ←  │
  │                                            │  10'-0"
  │   ┌──── dual vanity 72" ────┐              │
  │   │ sink     │     sink     │   linen 18"  │
  │   └─────────────────────────┘              │
  │                                            │
  │   toilet          │     walk-in shower     │
  │   (half-wall 42"  │     48" × 36" min      │
  │    optional)      │     60" × 36" preferred│
  └──────────────────────────────────────────┘
```

| Zone | Size / clearance |
|---|---|
| Doors D-JJ-A / D-JJ-B | Each **2'-8" × 6'-8"**, swings into bedrooms **or** into bath if clearances allow; privacy locks |
| Dual vanity | **72" W × 22" D** (two sinks) |
| Vanity knee/clear | **30" min**, **36" preferred** in front of vanity |
| Toilet | Same clearances as primary; place on side wall with **optional 42" half-wall** toward shower for privacy without shrinking the room |
| Walk-in shower | **48" × 36" min**; **60" × 36"** preferred; curb-less preferred for aging-in-place if waterproofing allows |
| Linen / storage | **18"–24" deep** cabinet or niche between vanity and shower |
| Open floor | Keep center of room free — no freestanding tub required in J&J (shower is primary bathing) |

### 4.3 Jack & Jill fixtures

| Fixture | Style | Spec |
|---|---|---|
| **Toilet** | Same family as primary: **two-piece, elongated, comfort height, white** | Soft-close; 1.28 gpf; match primary brand family for maintenance |
| **Lavatories** | **Two** undermount ovals in shared top | Equal left/right for fair sharing |
| **Faucets** | Pair of traditional widespread/centerset | **Aged brass** or polished nickel — **match primary bath metal** |
| **Shower** | Frameless or semi-frameless glass; traditional trim | Handheld + fixed head; niche 12"×24"; bench optional 15" deep |
| **Accessories** | Dual towel bars or hooks (one zone per bedroom side) | Match metal finish |

### 4.4 Jack & Jill vanity

| Parameter | Spec |
|---|---|
| Type | Built-in **shaker** double vanity (more storage for two users) |
| Width | **72"** |
| Depth | **22"** |
| Configuration | Stack of drawers under each sink + shared center doors **or** full drawer banks |
| Finish | Painted **cream / soft white** |
| Hardware | **Aged brass** |
| Counter | **Q-01** warm quartz continuous |
| Mirrors | **Two** separate mirrors **or** one long mirror with soft center break; optional dual recessed medicine cabinets |
| Lighting | **Sconces** between/beside mirrors; **2700K**; night-light option |

### 4.5 Why this is “open and spacious”

- **120 sf** clear — larger than a minimum code full bath  
- Dual vanity on one wall keeps floor open  
- Walk-in shower with glass (not a tiny tub closet)  
- Toilet not in a separate locked water closet unless owners later request  
- 9'-0" ceiling and warm light reinforce airiness without cold modern minimalism  

---

## 5. Finishes (both baths — grandma warm)

| Code | Element | Spec |
|---|---|---|
| **F-10** | Bath floors | Porcelain tile **12×24** or **hex mosaic** 2"; warm white / soft cream / pale clay — **not cool gray** |
| **F-11** | Shower floor | Mosaic 2" or non-slip small format; slope to drain 1/4"/ft |
| **W-10** | Bath walls (dry) | Paint moisture-resistant; soft cream or pale blush |
| **W-11** | Wet walls / tub-shower | Ceramic subway **3×6** or **4×12** to **84"** min; full height in shower preferred |
| **W-12** | Accent (optional) | Soft floral / traditional pattern tile band or hex accent — used sparingly |
| **G-10** | Grout | Warm beige / light taupe |
| **T-10** | Bath trim | Soft white traditional casing; moisture-rated where needed |
| **Q-01** | Counters | Warm white / cream quartz (same family as kitchen) |
| **M-10** | Metals | **Aged brass** baseline (polished nickel alternate house-wide) |
| **GL-10** | Shower glass | Clear tempered; polished or brushed metal hardware matching M-10 |

---

## 6. Toilet style standard (house-wide)

Lock one toilet **type** for both baths (and future baths):

| Attribute | Specification |
|---|---|
| Configuration | **Two-piece** (easier service than one-piece; classic look) |
| Bowl | **Elongated** |
| Height | **Comfort / chair height** (~16-1/2" to rim, excluding seat) |
| Flush | **1.28 gpf** WaterSense or dual-flush |
| Color | **White** |
| Seat | Soft-close, matching white |
| Trapway | Skirted preferred |
| Rough-in | **12"** standard |
| Style notes | Soft traditional lines — no square ultra-modern cube toilets |

**Alternate (if owners prefer):** one-piece comfort-height elongated white — still traditional skirted form.

---

## 7. Vanity standard summary

| Bath | Width | Style | Sinks | Height | Finish |
|---|---|---|---|---|---|
| Primary | **60"** (or 48") | Furniture-style or shaker | 1–2 | 34–36" | Cream paint + quartz + aged brass |
| Jack & Jill | **72"** | Built-in shaker | **2** | 34–36" | Cream paint + quartz + aged brass |

---

## 8. MEP notes (schematic)

| System | Requirement |
|---|---|
| Exhaust | Dedicated bath fans ducted outdoors; **J&J** sized for larger room (or dual intake); humidity-sensing preferred |
| GFCI | All receptacles; vanity circuits per code |
| Lighting | Wet-location rated in shower; dimmable ambient + task at mirrors; **2700K** |
| Plumbing stacks | Align primary + J&J vertically with lower bath when possible |
| Water | Hot/cold to all fixtures; mixing valves in showers (scald protection) |
| Floor heat | Optional electric mat under F-10 in both baths (comfort; grandma luxury) |

---

## 9. Accessibility & long-term

| Item | Intent |
|---|---|
| Door width | 2'-8" min; plan for 32"+ clear |
| Shower | J&J curb-less preferred; blocking for future grab bars in both baths |
| Toilet | Comfort height baseline |
| Clear floor | Maintain 30"×48" clear where practical at toilet and shower |
| Future | Blocking in walls at tub/shower and toilet for grab bars |

---

## 10. Revit modeling checklist

- [ ] Rooms: `Bath-Primary` (90 sf), `Bath-JackJill` (120 sf)  
- [ ] Levels: place on **Upper FF** with private suite (or as plan dictates)  
- [ ] Primary: door from primary bedroom only  
- [ ] J&J: two doors to Bedroom A / Bedroom B with privacy locks  
- [ ] Vanity casework 60" + 72"; quartz counters  
- [ ] Toilets: elongated comfort-height two-piece white  
- [ ] Primary: 60" tub/shower alcove **or** shower family  
- [ ] J&J: 60"×36" shower with glass; optional 42" half-wall at toilet  
- [ ] Tile floors F-10; wet wall types W-11  
- [ ] Exhaust fans, GFCI, lighting fixtures  
- [ ] Dimensions: room overall, vanity widths, toilet centers (15" to walls), shower interior  
- [ ] Elevations: vanity walls both baths  
- [ ] Materials: `FH-` codes from Material Schedule  

---

## 11. Success criteria

1. Master has a **private full bath** not shared with other bedrooms  
2. Jack & Jill is **open and spacious** (10'×12') with dual vanity and dual bedroom access  
3. Toilet and vanity styles are **specified and consistent**, warm traditional grandma finish  
4. Dimensions and clearances are modelable in Revit without guesswork  
5. Aesthetic matches cream millwork, warm metals, soft tile — not spa-gray modern  
