# DIRECTV SWM / HR22 / HR24 research and design basis

Date: 2026-10-25
Status: researched concept, **NOT activation confirmation** or final installation diagram.

## Owner preference
Prioritize standalone DIRECTV HR24 HD DVRs, allow HR22 where practical; Genie only as fallback. Specifically do not default to HS17 Genie 2. Preserve compatibility with Mitsubishi WS-65815 CRT rear-projection TV and Kenwood-style component hi-fi.

## Technical findings
- SWM is satellite distribution, not a receiver. On a compatible SWM network, each HR22/HR24 dual-tuner DVR occupies **two SWM tuner channels** but normally uses **one coax input**.
- SWM8 accommodates eight tuner channels; example 2x HR24 + 1x HR22 = six channels. SWM16 provides two banks of eight channels and requires correctly designed distribution/power.
- HR24 includes internal DECA for Whole-Home coax networking. HR22 needs an external DECA adapter for this use.
- For Whole-Home DVR with HR24, **do not attach direct Ethernet to HR24**: doing so disables its internal DECA. Connect home LAN via Broadband DECA/Cinema Connection Kit instead. HR22 uses Ethernet from its own DECA adapter.
- Use compatible DIRECTV-approved green-label splitters, correct terminators and band filters where applicable. Avoid arbitrary CATV/OTA diplexing into the DECA coax network.
- Power inserter voltage, orientation, port selection, LNB, and switch model are configuration-specific. Wrong connections can damage receivers. Confirm diagram against actual manufacturer manual and have installer verify bonding, grounding, and signal levels.
- HR22/HR24 are HD MPEG-4 capable, but account/service activation is a distinct issue.

## Critical availability/activation risk
- Current DIRECTV support documents still discuss replacement non-Genie activation, but do NOT promise acceptance of newly sourced HR22/HR24 on a new account.
- 2024–2025 user reports suggest obtaining and activating HR24s is difficult, especially previously deactivated/leased used boxes.
- Require provider or authorized retailer confirmation of exact model and activation eligibility for the specific account/order before purchasing. Do not assume eBay boxes can be activated.

## Fallback preference
1. Independent HR24 DVRs (HR22 optional) on compatible SWM if authorized.
2. HR54 Genie with independent legacy HD DVRs if authorized.
3. HS17 Genie 2/client architecture only if unavoidable; generally not compatible with independent HR24s on same system.

## Example conceptual topology
Compatible dish/LNB -> bonded service entry -> matched SWM switch/LNB power topology -> approved splitter -> independent RG-6 runs -> HR24/HR22.
Broadband DECA connects the coax DECA network to home router. External DECA is required for HR22.
This omits exact inserter placement and wiring intentionally; those depend on actual LNB/SWM hardware.

## Mitsubishi WS-65815
2004 service and user manuals confirm HDMI input, component inputs, 480i/480p/1080i HDMI support and approximately 300 W rated power. Direct HR24 HDMI to Mitsubishi at compatible resolution may work, subject to actual HDCP handshake and receiver configuration. Audio can be routed separately to hi-fi using verified outputs.

## Building rough-in
- Two RG-6 home runs per major TV location (satellite and spare/alternative), labeled and separately terminated.
- Accessible central satellite distribution space with replacement access, appropriate power and bonding provisions.
- Dedicated Cat6A networking separate from SWM coax; broadband DECA bridge point.
- Practical service path and coax replacement conduit, plus verified dish sightline.
- Receiver and Mitsubishi delivery/service clearances and ventilated equipment furniture.

## Sources
- DIRECTV non-Genie replacement support: https://www.directv.com/support/article/000015045
- DIRECTV Cinema Connection Kit support: https://www.directv.com/support/article/000072083
- DIRECTV Whole-Home technical tips: https://prod-content-care-community-cdn.sprinklr.com/d80f176d-2bd5-487b-b539-b24b3ede5ed6/WholeHomeDVRTroubleshootingTip-6f702ccc-cf96-4768-b690-966d33a9108f-775466095.pdf
- KVH HR22/HR24 DECA matrix: https://defender.com/assets/legacy-defender/pdf/260145AppNote.pdf
- Solid Signal SWM overview: https://www.solidsignal.com/directv-installation-equipment-guide-swm-deca-and-mrv
- HR24 activation reports: https://forums.directv.com/conversations/satellite-equipment/adding-a-legacy-hd-dvr-receiver-to-a-swm-with-a-genie-on-it/66b8f18da16f4b1343d4f2df
- Mitsubishi WS-65815 service manual: https://www.lost-manuals.com/pdf/mitsubishi--ws-55815--service--ID1346.pdf
- Mitsubishi WS-65815 user manual: https://manuzoid.com/manuals/rGxgM-Mitsubishi%20Electric%20WS-65815%20User%20manual

## Open questions
- Existing DIRECTV account vs new account, and whether HR22/HR24 units are already activated.
- Number of independent DVRs and TV locations.
- Final dish/LNB and switch model; satellite sightline.
- Whole-Home DVR subscription and sharing requirements.
- Exact Mitsubishi set, HDMI/HDCP test, and Kenwood receiver input selection.
