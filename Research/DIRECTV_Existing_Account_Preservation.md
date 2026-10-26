# Existing family DIRECTV account — preservation and verification

Date: 2026-10-25
Status: owner-reported account context; receiver models, account status, and operation unverified.

## New information
Owner continues paying a small monthly amount to maintain an old DIRECTV account inherited/retained from parents. Owner has **not recently checked whether receivers still function**. This is not evidence that any specific receiver is currently activated or usable.

## Design implication
Prioritize assessment and potential preservation of any already-authorized HR22/HR24 receivers before attempting procurement or new activation. Do not presume that a paid account guarantees receiver authorization or future relocation eligibility.

## Non-destructive verification checklist
1. Review account status and billing description: active satellite programming, suspended service, equipment charges, or other status.
2. Inventory receivers: exact model, receiver ID and access-card identifiers kept privately (do NOT commit identifying IDs to public repository), and provider-reported active/inactive status.
3. Power on receivers and note boot, diagnostics, error codes and output to compatible TV; power-on alone does not prove authorization.
4. Verify dish/LNB/coax connection, signal levels and channel authorization where safe and feasible.
5. Confirm with DIRECTV whether existing activated receivers can remain on account and move to future address, and whether HR22/HR24 support/reauthorization will continue.
6. Do not voluntarily deactivate, replace, return, or remove legacy receivers before understanding consequences; avoid unapproved account or equipment modifications.

## Risks
- Old equipment may fail, be inactive, have outdated authorization, or lack currently required satellite/format support.
- Current billing may not constitute active satellite programming.
- Receiver/account transfer or relocation may be restricted by provider policy and changing satellite infrastructure.

## Architecture
Keep flexible SWM-ready RG-6 distribution and separate Ethernet; defer fixed equipment selection until account and receiver inventory is verified.
