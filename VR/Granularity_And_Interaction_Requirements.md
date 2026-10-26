# VR granularity and interaction requirements

Date: 2026-10-25
Status: proposed implementation strategy based on owner's request for detailed VR; not a completed model or benchmark.

## Goal
Make a navigable, accurate virtual Forever Home using Revit as the BIM/source-of-truth and an optimized real-time engine (candidate: Unreal Engine/OpenXR) for interactive VR.

## Detail tiers
1. **Whole-house walkthrough:** true room geometry, accurate dimensions and circulation, lighting, finishes, furniture, performant collision and navigation.
2. **Room inspection:** detailed cabinetry, hardware, materials, appliance footprints, doors/drawers and maintenance clearances.
3. **Component inspection:** high-detail hero objects, equipment metadata, optional exploded views and linked schedules. Desktop-only inspection permitted for expensive detail.

## Interactive examples
- Open doors/cabinets; simulate light switching.
- Inspect Mitsubishi rear-projection television and Kenwood-style component hi-fi.
- Simulate the manual generator transfer lever and visualize safe switching states; simulation is not electrical certification.
- Systems mode: toggle architectural surfaces to reveal conduits, plumbing, HVAC, DIRECTV coax/SWM/DECA pathways, solar/battery equipment, and equipment IDs.
- Secure firearms closet: visualize footprint, safe anchorage zone, door swings, humidity control and service access. Do not include real codes, keys, combinations, or sensitive security credentials.

## Performance strategy
- User's RX 6600 XT (8 GB VRAM) is a development baseline, not a guarantee of full-quality VR.
- Aim for stable headset-appropriate refresh rates (often 72–90 FPS), measured on actual target hardware.
- Use LOD meshes, culling, instancing, optimized materials and texture budgets; baked lighting where practical.
- Keep BIM source geometry separate from optimized runtime meshes and asset libraries.
- Do not require individual hidden fasteners/brick geometry in whole-house runtime scenes when texture or metadata conveys the detail.

## Accuracy and safety
- BIM model carries construction dimensions and schedules; VR is a visualization and coordination tool, not a substitute for signed drawings or code review.
- Record whether an object is as-designed, provisional or manufacturer-verified.
- Keep public VR exports free of access credentials, sensitive equipment identifiers and personal security data.

## Open decisions
Headset/runtime target, interaction hardware, visual style, lighting workflow, source-to-engine pipeline, room-by-room asset budget, and which components warrant fully animated digital twins.
