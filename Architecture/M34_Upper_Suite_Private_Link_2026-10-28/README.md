# M34 — upper-suite direct-link spatial screen

Status: **design gate; the simplest direct-link adjustment conflicts with existing circulation/core blocks**.

The owner directed a private primary → boutique → hybrid sequence while retaining guest hall access and the hybrid/guest Jack-and-Jill relationship. This screen tests one minimal way to turn the U-02 → U-03 topology edge into room adjacency without changing either room's source dimensions: move U-03 west until it is separated from U-02 by the inherited nominal 6 in wall allowance. It does not revise the selected-D study.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools/test_m34_upper_suite_private_link.ps1
```

The script checks source fingerprints and arithmetic, then writes `screen.json`, `checks.json`, `upper-suite-screen.svg` and `manifest.json` here. Repeat into two fresh `.local` directories and compare all four output hashes to test determinism. The script rejects destinations outside the repository.

## Findings

- In selected D, U-02 ends at x=16.667 ft and U-03 begins at x=21.667 ft: a 5 ft gap occupied by a 4 ft C-UPPER corridor plus nominal 6 in allowances at each side.
- A test move places U-03 at x=17.167 ft, retaining its 13.667 × 9.167 ft source size and leaving 0.5 ft between U-02 and U-03. Their y-ranges overlap 9.167 ft, enough to test a shared-wall opening in a later plan.
- That move occupies **36.667 sf** of existing C-UPPER.
- Applying the documented +6 ft upper-frame offset, current U-03 has a **25 sf plan-projection overlap** with the 8 × 8 ft lift reservation. The direct-link test position has a **26.667 sf projected overlap** with the same reservation. Confirming the source frame shows this as an existing coordination issue, not an approval to ignore the lift.
- This single move does not preserve a continuous 4 ft public path from the upper stair landing, guest hall access and a clear lift reservation. No alternate room/core packing is asserted.

The measured overlaps are rectangle intersections in the source study's shared plan frame. They are screening evidence only; actual shaft, floor opening and room boundaries have not been authored in Revit.

## Design gate

Realizing the private sequence while retaining guest access, U-03/U-04 Jack-and-Jill access, the comparison hall and lift reservation requires a broader upper-floor/core arrangement. The owner must choose which inherited test constraints may move if a complete candidate cannot preserve all of them: room-block placement, 4 ft hall route, lift reservation, or rear-wing/connector envelope. No room dimensions are changed by this screen. Door locations, clear widths, swings, furniture, floor openings, headroom, services and site/code checks remain open.

No Revit or IFC operation was performed. This is not code, accessibility, structural or construction validation.
