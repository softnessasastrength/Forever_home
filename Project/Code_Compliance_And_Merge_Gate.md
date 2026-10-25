# Code compliance and merge gate

Approved direction: 2026-10-25
Status: project review policy; actual site, jurisdiction, permit date and adopted codes TBD.

## Goal
Design Forever Home with applicable code requirements considered throughout development, and conduct a formal documented code review before requesting owner approval to merge the design branch into `main`.

## Three review stages
1. **Continuous design review:** Identify likely code issues and dependencies when design choices are proposed. Maintain a register with issue, applicable provision (when verified), impact, proposed resolution, status, and responsible reviewer.
2. **Pre-merge review:** Audit architectural, structural, electrical, plumbing, mechanical, energy, fire/life safety, site and accessibility objectives against applicable jurisdiction-specific adopted codes and amendments. Document sources, assumptions, calculations, exceptions and unresolved items. Treat unresolved safety-critical concerns as **merge blockers**. Owner approval remains required for any merge into `main`.
3. **Pre-permit / pre-construction:** Obtain required review, design, sign-off, permits and inspections from qualified professionals and authorities having jurisdiction. An assistant audit is not legal certification or an approved permit set.

## Specific project checks
- Stair and guard geometry, egress, emergency escape openings, smoke/CO alarms, accessibility and reserved lift route.
- Structural loading and attachments for roof/ground PV, ground satellite mast, battery and heavy CRT television.
- Pellet stove listing, hearth protection, clearances, combustion air, venting and CO protection.
- PV and battery system electrical/fire requirements, equipment clearances, disconnects, rapid shutdown as applicable, interconnection and islanding.
- Generator manual transfer switch listing, backfeed prevention, neutral/bonding design, outdoor location and carbon monoxide separation.
- Electrical panel/circuit schedules, GFCI/AFCI, receptacle placements, low-voltage separation, grounding and bonding.
- Mechanical ventilation, insulation/energy compliance, water heating, plumbing fixtures, site drainage, zoning and setbacks.
- Technology room heat rejection, service access, satellite cabling and underground conduit requirements.

## Limitations and controls
- No blanket assertion of code compliance without jurisdiction, adopted code editions, complete coordinated drawings, specifications and calculations.
- Cite exact verified code provisions and note where interpretation or authority approval is needed.
- Mark proposed solutions as unverified until checked; maintain a change log so later modifications trigger re-review.
- Compliance review is a prerequisite to a merge proposal, **not** automatic permission to merge or a substitute for professional review.
