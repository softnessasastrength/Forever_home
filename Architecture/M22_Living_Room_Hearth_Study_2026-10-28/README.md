# M22 — Living-room hearth and viewing-wall comparison

Status: **unapproved wall relationship study**. The owner-approved aesthetic remains a separate traditional pellet-stove hearth and a large legacy rear-projection TV. Neither product, focal wall, wall assembly nor site orientation is selected by this package.

## Reproduce

From the repository root in Windows PowerShell 5.1:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File Tools/build_m22_living_room_hearth_study.ps1
```

The script reads the selected-D room-space study, M-01 area program, the unresolved TV decision, and the source-pinned [Harman P43-C manual data](../../Research/M22_Pellet_Stove_Envelope_2026-10-28.json). It generates [two wall relationship options](wall-options.svg), [`study.json`](study.json), and [`checks.json`](checks.json). It does not modify a Revit or IFC file.

## What the arithmetic supports

M-01 remains a 16 × 15 ft (240 sf) selected-D room-space block, 20 sf above the preliminary 180–220 sf living-room range. Its two 16 ft edges are 15 ft apart. One long edge faces the dining block across a nominal 6 in room-block gap, sharing 11 ft 4 in; the opposite edge has no room block directly across it. The 15 ft edge toward M-05 also has a nominal 6 in gap and 12 ft of shared span. These are test-block relationships, not wall faces.

The manufacturer-documented P43-C gross plan envelope, calculated as body width plus side clearances and body depth plus rear/front combustible separation, fits within the M-01 rectangle by arithmetic with and without side shields. This is a coarse envelope screen only. Manufacturer minimums leave little cleaning/service room; no operating, furniture, entry, vent, alcove, mantel, egress or floor-structure fit is verified.

Option A puts a proposed hearth and TV on opposite 16 ft edges. Option B swaps them. No available evidence establishes which edge should be the viewing wall: the Mitsubishi WS-65815 is a visual reference, and the exact TV model/size remains unselected. The sketch therefore draws wall bands only, not appliances. Choose a wall arrangement only after site-facing openings, the M-05 route, TV dimensions/viewing position and stove vent/service path have been reconciled.

## Open gates

- The Harman P43-C is a research candidate, not an owner-selected product. No exact public RFA was located in the searched results; that does not prove none exists.
- Current manufacturer manuals do not document a mantel clearance or a stove recess/alcove assembly for this candidate. The optional recess in the aesthetic decision remains unverified.
- A measured TV size, owner-approved viewing wall, selected stove, wall build-up, vent route, outlet location, service area, floor support and qualified installation review remain outstanding.
- This study makes no safety, code-compliance, professional certification or construction-readiness claim.
