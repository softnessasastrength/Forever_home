# Solar photovoltaic and battery backup design basis

Date: 2026-10-25
Status: owner-required systems; implementation/site engineering pending.

## Non-negotiable owner requirements
- Include an on-site solar photovoltaic system and battery energy storage/backup in the base Forever Home design, not as optional future upgrades.
- **Target at least 50% of annual household electrical energy consumption supplied by on-site solar generation.** For early modeling, measure annual solar production against annual household kWh consumption; separately report self-consumed solar, exports, imports, and battery losses. Final definition of “comes from the sun” must be agreed before claiming compliance.
- Design remains site-dependent: solar resource, shade, orientation, available roof/ground area, local rules, tariffs and actual electrical loads.
- System implementation, product selection, battery capacity and array placement remain open for discussion.

## Preliminary engineering approach
1. Model 8,760-hour load profile or appropriate hourly approximations, including HVAC, pellet heating auxiliaries, electric cooking, water heating, laundry, AV/hi-fi, networking, future EV charging and seasonal occupancy.
2. Assess rooftop vs ground-mounted PV, roof pitch/orientation, structural loads, shade, snow, maintenance and cable routing.
3. Size PV against at least 50% annual production-to-load goal, with derates and seasonal variability; distinguish generation from actual on-site consumption.
4. Size batteries based on explicit outage-duration and critical-load goals; reserve capacity for refrigeration, network, lighting, heating controls/circulators, communications and medically essential loads if any are later identified.
5. Compare AC-coupled vs DC-coupled/hybrid architectures, inverter capacity, islanding/automatic transfer, black-start and solar recharging during grid outages.
6. Provide replaceable equipment bay, code-compliant clearances, fire safety, thermal conditions, utility interconnection and accessible service disconnects.
7. Evaluate generator-ready interface as an option only, without assuming a generator is approved.

## Important distinctions
- 50% annual solar generation is **not** 50% daily independence or guaranteed winter output.
- Battery backup capacity (kWh) and maximum output (kW) are separate design criteria.
- Grid-tied PV without suitable islanding equipment ordinarily shuts down during outages.
- Solar generation, self-consumption and utility-bill offset are different metrics, especially with export tariffs and net metering.
- Whole-home backup capability may be desirable, but prioritize a critical-load strategy and load shedding to preserve reserve.

## Open design decisions
- Final definition of 50% solar contribution: gross PV generation vs actual on-site self-consumed solar energy.
- Backup target: critical circuits only, whole-home with load management, and hours/days of autonomy.
- Roof-integrated vs ground-mounted arrays and visual integration into New England architecture.
- Battery placement, chemistry, capacity, inverter topology and expansion plan.
- Whether pellet heating, EV charging, hot water and other major loads are included in annual baseline.
- Local permitting, interconnection, incentive and fire-code review once site selected.
