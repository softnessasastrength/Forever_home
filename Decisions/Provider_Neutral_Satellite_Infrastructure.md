# Provider-neutral satellite distribution infrastructure

Date: 2026-10-25
Status: owner-approved design direction; detailed engineering and quantities pending.

## Intent
Owner is willing to pay a premium to restore and preserve an existing DIRECTV HR24 system, even if not the least expensive TV option. **Do not make the building dependent on DIRECTV:** preserve a practical future switch to DISH without opening finished walls.

## Design principle
Building infrastructure stays; provider-specific equipment swaps. DIRECTV SWM and DISH distribution are **not directly interchangeable**. A switch may require replacing the dish/LNB, switches, power supplies, splitters, receivers and some terminations, and reconfiguring cabling. Provider service eligibility and site line-of-sight must be confirmed.

## Preliminary rough-in
- Central, accessible, ventilated low-voltage satellite distribution bay with labeled home-run terminations, adequate power, equipment clearance and bonding.
- Accessible dish mounting zone with verified sky view for both potential services; conduit route from dish location to equipment bay, sized after fill/bend-radius calculation with spare capacity, pull string, service loops, outdoor-rated cabling and weatherproof entry.
- At least **three RG-6 home runs to the primary media wall** and **two RG-6 home runs to each secondary television position** as a preliminary minimum, all home-run to central distribution and labeled at both ends. Keep one or more spare pathways.
- Separate Cat6A home runs for IP devices and receivers. Do not treat Ethernet as a substitute for satellite coax or bridge HR24 directly to Ethernet when using internal DECA.
- Keep OTA/cable and provider satellite/DECA systems segregated unless a qualified designer establishes compatible filtering and topology.
- Install satellite distribution equipment as replaceable mounted assemblies, not inaccessible behind finishes.

## Phase strategy
1. Inventory and bench-test existing family HR24, and confirm authorization on the grandfathered approximately $65/month account.
2. Recover any reusable SWM hardware and document exact dish/LNB, power inserter and splitters before connecting.
3. Restore DIRECTV if technically feasible and account-authorized.
4. Preserve physical migration path to DISH through provider-bay replacement rather than structural alterations.

## Engineering cautions
- DIRECTV SWM and DISH Hybrid/DPH/DPP hardware use different topology, power, and signaling; no guarantee that one existing splitter or coax configuration works with both.
- Satellite line of sight, structural mounting, grounding/bonding, surge/weatherproofing and equipment voltage requirements are provider- and site-specific.
- Cable count, lengths, approved cable type, connectors and number of tuners/hoppers must be validated against actual hardware and service requirements.
- Future DISH service may have provider-specific installation rules; verify before final rough-in.
