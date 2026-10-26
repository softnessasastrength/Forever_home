# First coordinated schematic study

Date: 2026-10-25. Status: **two proposals for review; neither selected**. Room blocks and arithmetic checks only; not a coordinated architectural floor plan, native Revit house model, engineering or code review completion.

## Scope and acceptance

Compare the same room inventory in two explicit footprint/level arrangements. Preserve both personal rooms, primary/guest/hybrid bedroom intent, private primary bath, true Jack & Jill, porch, separate laundry, lower flexible living, technology and mechanical spaces. Show room areas, a kitchen fit, suite-door matrix, route strategies, section arithmetic and deviations. Pass only the limited automated checks actually implemented; keep furniture, door, stair, lift, site and engineering issues open.

Reproduce using `./.venv/Scripts/python.exe Tools/schematic_study.py`. The script generates [study.json](study.json), [room-area CSV](room_areas.csv), [checks.json](checks.json), and eleven SVG drawings under [Exports](../../Exports/Schematic_Study_2026-10-25/README.md). Geometry is in feet with an assumed 8 in exterior-wall reservation and nominal 6 in partitions. These are space allowances, not selected assemblies.

[drawing_manifest.json](drawing_manifest.json) records hashes of the visually reviewed drawings in this revision. It is a review snapshot, not an automatic visual check; a changed drawing requires renewed rendering/review and an updated snapshot.

## The two alternatives

| Feature | A — retain short flights | B — main-level daily living |
|---|---|---|
| Main/front shell | 40 x 36 ft | 40 x 42 ft |
| Rear wing, lower and upper overlapping | 36 x 32 ft per level | Same |
| Total front-to-rear shell depth | 68 ft | 74 ft |
| Lower / main / upper test datums | -4.5 / 0 / +4.5 ft | -5 / 0 / +5 ft |
| Each flight | 7 risers at 7.7143 in; 6 treads at 11 in | 8 risers at 7.5 in; 7 treads at 11 in |
| Straight stair reservation incl. two 4 ft landings | 13.5 ft long; 4 ft wide per flight | 14.4167 ft long; 4 ft wide per flight |
| Lower-to-upper separation | 9 ft | 10 ft |
| Assumed floor assembly | 12 in | 15 in |
| Resulting lower clear-height arithmetic | 8 ft | 8 ft 9 in |
| Main / upper ceiling study | 9 ft / 9 ft | Same |
| L-02 bedroom-capable flex room | Lower, 11 x 10 ft | Relocated to main, 11 x 10 ft |
| M-06 public bathroom | Proposed 9 x 10 ft full bath | Same |
| Future step-free daily route | Requires a selected, installed lift for sleeping from main | Entry/living/kitchen/dining/sleeping/bath can be on main, subject to clearance and threshold tests |
| Main drawback | Steep risers and tight assumed structural depth; lift dependence | Larger shell; dining-adjacent flex room; 110 sf lower allowance becomes unassigned |

The main wing and the rear stacked wing occupy different plan zones. Their connection is a reserved multi-height stair/lift core within the rear part of the main wing. No habitable lower room is placed under the main landing. An 8 x 8 ft lift enclosure reservation is **not proof that a selected car, doors, pit, overrun or minimum landing separation fits**. The core uses differing landing orientations; obtain a product-specific layout before relying on it.

Seven risers in A preserve the historical 5–7-riser preference, but 7.7143 in is only 0.0357 in below the 7.75 in limit in the **2021 IRC reference**. That is too little nominal margin to treat as a finished design amid structural/finish uncertainty. B explicitly trades the historical seven-riser maximum for lower risers and more floor/ceiling allowance. Neither alternative establishes adopted-code compliance; jurisdiction and actual assemblies are unknown. [ICC 2021 reference](https://codes.iccsafe.org/s/IRC2021P3/chapter-3-building-planning/IRC2021P3-Pt03-Ch03-SecR311.7.5.1) was located on 2026-10-25; only its searchable riser excerpt was available, and the full page returned 403. No broader code-section verification is claimed.

## Step-by-step design rationale

1. **Test the section before decorating the plan.** Historical six-riser offsets total 87 in between lower and upper floors. Subtracting even a 12 in placeholder assembly leaves 75 in of lower clear height. Both new alternatives increase that separation; neither selects a structural system. Main rooms cannot simply be stacked under upper rooms at a 43.5 in offset.
2. **Preserve the island and expose its area cost.** A 12 ft short room axis cannot contain 2 ft counter + 3.5 ft aisle + 4 ft island + 3.5 ft aisle = 13 ft. The proposed 17 ft 4 in x 16 ft kitchen gives a 4 ft work aisle, 8 x 4 ft island, 2 ft occupied-seat allowance and separate 4 ft route. Its 277.33 sf is 109.33 sf above the historical 168 sf. One straight perimeter run is assumed; no second end-wall cabinet run is hidden in the end aisles. Appliance-open operation remains untested.
3. **Protect porch access when chairs are occupied.** Dining grows to approximately 11 ft 4 in x 14 ft. A 5 x 3 ft table plus 3 ft chair envelopes on both sides and a separate 4 ft route consumes 13 ft in the short chain. French doors swing toward the porch; actual active-leaf clear opening and weather threshold remain unresolved.
4. **Separate public circulation from private bath use.** Guest, hybrid and primary have hall connections; the primary alone enters its bath; Jack & Jill connects only hybrid and guest. A proposed main full bath supplies a daytime toilet without bedroom entry. Personal rooms remain internally connected through private circulation, rather than forcing a bathroom to serve as a corridor.
5. **Test daily living with and without a lift.** A reserves lift access from main to lower sleeping/full bath or upper suite. B moves the existing additional flex sleeping room to main and retains the lower full bath and upper suite. B reduces reliance on a lift for daily essentials, but laundry and garage remain lower; it does not provide a step-free garage route without a lift or a site-designed alternative. A lift reservation alone provides no usable access today.
6. **Expose area inefficiency before authoring a detailed house model.** The first blocks are deliberately conservative. B adds shell area while leaving a lower allowance unassigned; that is an identified inefficiency, not an accepted feature. Compact the core/distribution and investigate structural spans before approving any total area.

## Suite door matrix — proposed

All drawn orange door segments are nominal 3.5 ft reservations, not a statement of clear opening, finished leaf size, swing or accessible hardware.

| ID | Connection | Purpose / limit |
|---|---|---|
| D-U01 | Upper hall ↔ primary | Primary has independent circulation |
| D-U02 | Primary ↔ primary bath | Only baseline entry to this bath |
| D-U03 | Primary ↔ private connector | Internal private route |
| D-U04 | Private connector ↔ boutique | Does not pass through primary bath |
| D-U05 | Boutique ↔ rear hall | Personal-room connection; privacy boundary to refine |
| D-U06 | Rear hall ↔ hybrid | Independent sleeping/work access |
| D-U07 | Public hall ↔ guest | No primary/boutique/bath transit |
| D-U08 | Guest ↔ Jack & Jill | Privacy hardware / swings untested |
| D-U09 | Hybrid ↔ Jack & Jill | Bath is not required circulation |

The central hall's public and rear/private portions need a refined privacy-door location and acoustic study. Guest arrival does not require crossing that rear suite boundary. These indirect personal-room connections are a proposal for owner review, not approval to replace the original internal-door intent.

## Routes and detailed fit limits

| Route / fit | Study result | Still unresolved |
|---|---|---|
| Main entry → kitchen/dining/living → main bath | Same floor in A/B | Site approach, thresholds, actual door clearances, all turns and furniture |
| B main entry → dining-side passage → L-02 | Same floor; 11 x 10 ft room shown | Dining-adjacent privacy/acoustics, bedroom qualification, complete furniture and maneuvering |
| Garage → lower arrival/storage → hall → core | Same lower datum; separate from laundry | Garage separation/door, stored goods, vehicle/EVSE positions, actual lift route |
| Main → porch | Occupied-chair route reserved | French-door active leaf, threshold/drainage and screened porch construction |
| Upper landing → guest / primary / hybrid | Hall paths avoid baths | Door swings, furniture, turning, egress and privacy boundary |
| Main full bath | Fixture footprints avoid a 5 ft turn reservation | Toilet transfer zone, shower approach, door maneuvering, waterproofing and actual fixture selection |
| Living | Loveseat and extended recliner avoid a 4 ft rear lane | Exact furniture, TV dimensions, delivery turns, service and thermal separation |

Living rooms grow to 256 sf in A / 240 sf in B versus the earlier 180–220 sf allowance. A 4 x 7 ft TV/service envelope and 5 x 5 ft hearth reservation are **not product measurements or listed combustible clearances**. Stove manual, TV measurements, structural loading and heat/service envelopes are blockers to final arrangement. Component hi-fi furniture and speaker locations remain unfitted; do not infer the room is fully furnished from this test.

Primary/Jack & Jill retain the intended 90 / 120 sf blocks, but their complete fixture layouts and door conflicts are not tested in these alternatives. Only the proposed main full bath has the new nominal fixture/turn study. Storage S-01 is a movable 30 sf program reservation; no security location, anchorage or safe specification is selected.

**Wet-stack conflict found:** the Jack & Jill block sits above the lower technology-room reservation. Plumbing, leak protection, drain noise and access are uncoordinated. Relocate the technology room or wet routes before freezing either plan; do not treat that lower-room placement as acceptable MEP coordination. The main bath also needs a real underfloor drain/service route because the main wing is not over the lower occupied wing. Coat storage, hi-fi furniture and equipment service layouts still need fitting.

## Area accounting — comparison only

| Quantity | A | B |
|---|---:|---:|
| Main shell plate | 1,440 sf | 1,680 sf |
| Upper shell plate | 1,152 sf | 1,152 sf |
| Lower shell plate | 1,152 sf | 1,152 sf |
| Sum of base shell plates | **3,744 sf** | **3,984 sf** |
| Scheduled main program blocks, incl. entry | 869.00 sf | 963.00 sf |
| Scheduled upper program blocks | 766.11 sf | 766.11 sf |
| Scheduled lower program blocks | 825.06 sf | 715.06 sf |
| Total scheduled program blocks | 2,460.17 sf | 2,444.17 sf |
| Shell plate minus program blocks | 1,283.83 sf | 1,539.83 sf |
| Identified B unassigned lower allowance | — | 110 sf, included in residual |
| Garage, separate | 576 sf | 576 sf |
| Three-season porch, separate | 120 sf | 120 sf |
| Measured conditioned area | TBD | TBD |
| Above/below-grade classification | Site-dependent / TBD | Site-dependent / TBD |

The residual includes explicit hall/core reservations, walls and unallocated/distribution space; it is not all usable circulation or an automatically justified allowance. Base shell plate sums exclude reconciliation of actual connector floor projections, stair/shaft voids and measurement convention. They are not certified gross floor area, conditioned area, a quantity takeoff or a cost estimate. Do not compare them directly with the old above-grade 1,500 sf placeholder. Overall combined ground shell footprint is 2,592 sf A / 2,832 sf B before garage/porch; site setbacks and street massing remain untested.

## Verification and next recommendation

37 implemented checks pass: shared-frame room-wing nonoverlap, room-block containment/nonoverlap, inventory preservation, main blocks avoiding stair/lift reservations, section and stair arithmetic, kitchen/dining allowance arithmetic, suite graph rules, living-envelope/route nonoverlap and the main-bath turn reservation avoiding fixture footprints. SVGs were parsed as XML, rendered and visually inspected. These checks do not validate door swings, full route continuity, stairs/headroom, product fit, roofs, structure, site or applicable codes. No native Revit house model was created in this pass.

**Recommended next iteration:** retain B's main-level sleeping/bathing strategy and the common private-suite inventory, then compact the footprint/core and resolve the dining-side bedroom access before proposing a preferred plan. Do not adopt B's current 3,984 sf plate allowance simply because the blocks fit. A remains a comparison showing the cost of preserving the seven-riser preference. Neither is ready for geometry freeze, cost commitment or review completion.

Before detailed Revit authoring: resolve a realistic stair/core section with headroom, lift manufacturer layout and floor assemblies; then test furniture, doors and approach clearances at full scale. Site/jurisdiction, roof/PV, actual equipment and professional review remain required. [Savaria's planning/specification resources](https://www.savaria.com/professionals/generic-specifications?lang=en) illustrate the product-specific dependency; no Savaria product is selected or represented as fitting this reservation.
