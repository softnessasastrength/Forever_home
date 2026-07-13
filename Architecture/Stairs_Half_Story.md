# Half-Story Stairs — Revit Modeling Specs

**Status:** Schematic owner specs for modeling (not permit-ready)  
**Building form:** Raised-ranch / split-level inspired ([DD-002](../Decisions/Design_Decisions.md))  
**Related:** [Kitchen_Dining_Porch_Specs.md](Kitchen_Dining_Porch_Specs.md), [Interior/Flooring_Options.md](../Interior/Flooring_Options.md)  
**Aesthetic:** Warm grandma home — soft underfoot, traditional railings  
**Concept render:** [Renderings/Stairs_Half_Story_Concept.jpg](../Renderings/Stairs_Half_Story_Concept.jpg)

> Stair geometry must be verified against actual floor-to-floor heights from structure. Local IRC (or adopted code) governs. This document sets **owner design intent** for half-story runs of **five to seven steps**.

---

## 1. Design intent

The house uses **short half-story stair runs** rather than long full-flight stairs between every level. That matches a raised-ranch / split organization:

| Run | From | To | Design step count |
|---|---|---|---|
| **S1** | Lower level (finished basement) | Main living floor | **6 risers** preferred (range **5–7**) |
| **S2** | Main living floor | Upper private floor (suite) | **6 risers** preferred (range **5–7**) |

Each run feels intimate and house-like — not a grand hotel stair. Carpeted treads (baseline) add quiet and soft underfoot; see flooring alternatives if carpet is declined.

**Entry mid-level option:** If the front entry lands on a split foyer between lower and main, model **S1** and **S2** from that intermediate landing with the same 5–7 step rule each direction. Confirm in schematic plans.

---

## 2. Geometry (baseline: 6-riser half story)

### 2.1 Total rise targets

| Risers (steps) | Riser height | Total rise | Approx. level change |
|---:|---:|---:|---|
| **5** | **7-1/4"** | **36-1/4"** | ~3'-0" |
| **6** (preferred) | **7-1/4"** | **43-1/2"** | ~3'-7 1/2" |
| **7** | **7-1/4"** | **50-3/4"** | ~4'-2 3/4" |

**Baseline for Revit families:** **6 risers @ 7-1/4"** = **43-1/2"** floor-to-floor for each half-story.

If structural floor-to-floor differs, **adjust riser height uniformly** (all risers equal) within code max (typically **7-3/4"** IRC R311) and keep step count in the **5–7** band when the level change is a true half-story. If rise exceeds ~51", add a landing and second short flight rather than exceeding 7 steps without re-evaluating the split geometry.

### 2.2 Treads and width

| Parameter | Value | Notes |
|---|---|---|
| Riser height | **7-1/4"** preferred; **max 7-3/4"** | All risers equal within **3/8"** tolerance |
| Tread depth (nosing to nosing) | **10-1/2"** preferred; **min 10"** | Uniform |
| Nosing projection | **3/4" to 1-1/4"** | Consistent; closed risers preferred |
| Number of treads (straight run) | **Risers − 1** | e.g. 6 risers → **5 treads** + top landing floor |
| Clear width (inside stringers/handrails) | **36" min**; **38" preferred** | Comfortable furniture path |
| Headroom | **6'-8" min** | Anywhere on stair |
| Max variation | Riser/tread uniformity per code | |

### 2.3 Plan length (straight run, baseline)

For **6 risers / 5 treads @ 10-1/2"**:

| Segment | Calculation | Length |
|---|---|---|
| Run (tread band) | 5 × 10-1/2" | **4'-4 1/2"** |
| Top landing depth | **36" min** in direction of travel | **3'-0"** min |
| Bottom landing depth | **36" min** | **3'-0"** min |

**Total stair well length (straight):** ~ **4'-4 1/2"** + landings beyond.

**L-shaped option:** 3 + 3 risers with **36" × 36"** intermediate landing if plan needs a turn near kitchen/living. Prefer not to dump the stair into the island **42"** work aisle ([Kitchen specs](Kitchen_Dining_Porch_Specs.md)).

### 2.4 Section diagram (baseline S2 or S1)

```text
Upper / Main FF ──────────────────────────────  (top)
         ║  riser 7-1/4"
      ┌──╨──┐
      │     │ tread 10-1/2"   } × 5 treads
      └──╥──┘
         ║
         … 6 equal risers total rise 43-1/2"
         ║
Lower / Main FF ──────────────────────────────  (bottom)

Handrail: 34"–38" above tread nosing line (model 36")
Guard: where drop > 30", guard 36" min (IRC); integrate with rail style
```

---

## 3. Construction type

| Element | Spec |
|---|---|
| Framing | Conventional wood stair stringers (or engineered) per structural |
| Subfloor / tread substrate | Plywood/OSB or stair tread blanks suitable for finish |
| Closed vs open risers | **Closed risers** (safer, more traditional, better for carpet) |
| Skirt boards | **9-1/4"–11-1/4"** painted each side against wall |
| Under-stair | Closet or open to lower hall — optional storage; maintain headroom |

---

## 4. Tread & riser finish — baseline carpet

### 4.1 Carpeted treads (owner baseline)

| Parameter | Spec |
|---|---|
| Application | Carpet on treads + risers **or** treads only with painted risers |
| Carpet type | **Stair-rated** nylon or wool-blend, dense low pile or patterned loop |
| Pad | Stair-appropriate thin pad or rubber; avoid thick pad (slip/code) |
| Installation | **Waterfall** or **cap-and-band**; tightly wrapped nosings; no loose edges |
| Color | Warm neutral — soft taupe, mushroom, or gentle rose-beige (not cool gray) |
| Pattern | Subtle traditional pattern optional (helps hide wear; grandma character) |
| Nosing | Clear, firmly wrapped; consider metal or wood stair nosing under carpet for wear |

**Why carpet here:** Quieter between levels, softer underfoot, warmer visually with the grandma aesthetic.

### 4.2 If carpet is declined

Use the **stair column** in [Interior/Flooring_Options.md](../Interior/Flooring_Options.md). Preferred non-carpet stair finishes for this house:

1. **Hardwood treads + painted risers** + stair runner (best hybrid)  
2. **Engineered wood treads** full width  
3. **LVP stair kits** only if manufacturer stair system is used (not floating planks alone)

---

## 5. Railing style (grandma traditional)

### 5.1 Selected style — **painted traditional with turned balusters**

| Parameter | Spec |
|---|---|
| Style name | **Traditional turned-baluster rail** |
| Aesthetic | Classic, soft, residential — not cable, not glass, not industrial pipe |
| Handrail profile | **Oval or traditional grip** (e.g. 2-5/8" wide Oval or similar), continuous graspable |
| Handrail height | **36"** above tread nosing (range **34–38"** code) |
| Handrail finish | **Painted soft white** **or** stained warm oak — pick one house-wide |
| Balusters | **Turned wood**, **1-1/4" to 1-3/4"** diameter; spacing **< 4"** clear (4" sphere rule) |
| Baluster finish | Painted soft white (matches trim) **or** contrast stained oak with white rail |
| Newel posts | **3-1/2" to 5-1/2"** square or turned newels at top, bottom, and direction changes |
| Newel style | Simple box newel with cap **or** modest turned newel — avoid oversized formal foyer posts |
| Wall-side rail | Continuous handrail on wall with returns into wall; same profile as open side |
| Guard height | **36" min** at landings where required |
| Mounting | Newel-to-floor/blocking solid; no wobble |

### 5.2 Alternates (if turned balusters feel too busy)

| Option | Description | Use when |
|---|---|---|
| **A — Square balusters** | 1-1/4" square painted balusters, same rail/newel | Cleaner traditional |
| **B — Half-wall + rail** | 36–42" knee wall with cap + top handrail (fewer balusters) | Along stair open to living; more “built-in grandma” |
| **C — Craftsman** | Square newels, simple square balusters, flat cap | If exterior goes craftsman |

**Baseline to model in Revit:** Option primary — **turned balusters, painted soft white, oak or white oval handrail, modest box newels**.

### 5.3 Revit railing type parameters

| Parameter | Value |
|---|---|
| `Handrail Height` | **3'-0"** |
| `Baluster Placement` | Equal spacing, clear opening **≤ 4"** |
| `Baluster Family` | Turned baluster |
| `Top Rail` | Continuous oval handrail |
| `Posts` | Box newel at ends / turns |
| `Rail Width (clear stair)` | Maintain **36"+** clear |

---

## 6. Location & adjacency rules

| Rule | Intent |
|---|---|
| Do not land S2 inside kitchen island work aisle | Protect **42–48"** cook clearances |
| Prefer stair near entry / living edge | Raised-ranch foyer logic |
| Upper run S2 delivers to suite corridor or shared landing | Feeds connected three-bedroom suite |
| Lower run S1 near garage connection | Supports in-law / guest independence |
| Provide **36"×36"** min landings | Furniture and future stair-lift study |
| Future stair lift | Keep one straight wall along S1 or S2 free of windows/obstructions where possible ([Accessibility](../Accessibility/README.md)) |

---

## 7. Lighting & safety

| Item | Spec |
|---|---|
| Illumination | Stair lighting per code; **2700K** warm LED |
| Control | **3-way** switches top and bottom each run |
| Night | Optional low night-light LED at skirt or recessed step lights (warm, dim) |
| Contrast | Nosing slightly visible; if full carpet, use patterned carpet or edge definition |
| Handrails both sides | Required/preferred when width allows; **at least one** continuous rail always |

---

## 8. Revit modeling checklist

- [ ] Levels: `Lower FF`, `Main Living FF`, `Upper FF` with half-story offsets (**43-1/2"** baseline each)  
- [ ] Stair component: **6 risers**, **7-1/4"**, tread **10-1/2"**, width **3'-2"** (38" clear target)  
- [ ] Support **5- and 7-riser** types as alternates  
- [ ] Railing system: turned balusters + newels + wall rail  
- [ ] Skirt boards, closed risers  
- [ ] Carpet finish material on treads/risers (baseline)  
- [ ] Landings 36" min; dimension headroom 6'-8"  
- [ ] Plan export showing clearances to kitchen half wall and living seating  
- [ ] Section through S1 and S2  

---

## 9. Code & professional review (mandatory later)

- Confirm riser/tread with actual construction depths and finish stack-ups  
- Guards, handrails, landings, illumination, smoke/CO near sleeping levels  
- Egress from upper and lower levels  
- Carpet flame/smoke ratings where required  
- Stair lift structural backing if pursued  

---

## 10. Success criteria

1. Each half-story run is **5–7 steps** with equal risers  
2. Preferred model is **6 × 7-1/4"** rise, **10-1/2"** tread, **36"+** clear width  
3. Treads read soft and quiet (**carpet baseline**) with documented hard-surface alternates  
4. Railing is **traditional turned baluster**, graspable, code-spacing, grandma-warm — not modern cable/glass  
5. Stairs do not break kitchen work clearances or suite hotel-style room connections  
