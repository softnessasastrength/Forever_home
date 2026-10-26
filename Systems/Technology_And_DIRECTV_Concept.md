# Technology and DIRECTV — schematic infrastructure brief

Status: conceptual; exact DIRECTV hardware and service architecture unconfirmed.

## Objectives
- Dedicated ventilated, accessible technology closet, preferably lower level near but suitably separated from electrical and dusty mechanical spaces.
- Structured star topology with labeled home runs, service loops, patch panels, spare pathways, and a maintainable cable register.
- Include wired Ethernet (Cat6A design option), Wi-Fi AP locations, optional fiber pathways, TV/media outlets, camera PoE, audio, UPS, and equipment power/thermal budgets.
- Model DIRECTV **satellite** reception and distribution only after confirming dish/LNB, SWM/multiswitch generation, receivers/Genie clients, coax compatibility, power inserter requirements, and provider installation rules. Do not assume a generic splitter works.
- Include a route for exterior service entry, weatherproofing, grounding/bonding, and surge protection designed to applicable electrical codes and provider requirements.
- Coordinate equipment access, rack units, cooling, noise, circuit capacity, and UPS loads with MEP.

## Example conceptual signal path
Dish/LNB -> exterior service entry and code-compliant bonding -> compatible DIRECTV distribution equipment -> labeled RG-6 home runs / receiver positions -> TVs. Networking is a separate topology with possible interconnections depending on the receiver generation.

## Model and data detail
Maintain each asset's ID, manufacturer/model (TBD), size, mass, mounting, electrical draw, thermal output, interfaces, room/rack location, service clearances, purchase/replace cost, and status.
Maintain each cable's ID, endpoints, type, connector, pathway, estimated/measured length, spare capacity, test result, and label. Cable and connection records may live in CSV/JSON rather than Revit alone.

Example IDs (NOT as-built):
- SAT-001 exterior satellite service to distribution location (RG-6, topology TBD)
- SAT-002 distribution to living TV (RG-6, if required by actual DIRECTV system)
- DATA-001 patch panel to living TV (Cat6A)
- DATA-002 patch panel to hybrid office (Cat6A)
- DATA-003 PoE switch to exterior camera (Cat6A)

## Revit deliverables
Technology closet plan and rack elevation; device families; electrical load and ventilation schedule; telecom floor plans; cable/conduit routing diagrams; port map; BOM; service/maintenance documentation.

## Questions to resolve
Exact DIRECTV equipment models; number and location of TVs/receivers; satellite vs streaming services; internet provider/service entry; rack size; preferred networking ecosystem; camera and audio zones; generator/UPS goals.

Safety: electrical work, antenna mounting, bonding, penetrations, and load calculations require appropriate qualified review.
