# Render-to-model reference map

Updated: 2026-11-02

This note keeps Revit materials, room geometry and visible furnishings aligned with the repository's visual direction. Renderings are concept references, not construction specifications. When a rendering conflicts with a newer owner-approved decision, the newer decision governs and the rendering remains a mood reference only.

## Reference priority

1. Newer owner-approved decisions in `Decisions/`.
2. Current room/assembly specifications and `Architecture/Material_Schedule.md`.
3. Concept renderings under `Renderings/`, used for composition, warmth and traditional character where they do not conflict with items 1–2.
4. Any unsourced appearance is a labeled proposal; do not silently turn it into a selected finish.

`Renderings/README.md` explicitly says the living concept's TV/faux-fire stack and island range are superseded. The current living direction is a large cabinet rear-projection television and a separate rustic brick pellet-stove hearth (`Decisions/Living_Room_Rear_Projection_TV.md`, `Decisions/Living_Room_Projection_Concept.md`). The owner selected a separate tub and tiled rain shower for the primary bath, informed by the MGM Springfield suite image; this supersedes the older tub/shower-combo depiction/spec (`Decisions/2026-11-01_Primary_Bath_MGM_Springfield_Shower_Reference.md`). Do not copy these superseded objects from old images into the current model.

## Current material cues supported by the repository

| Area | Model direction | Evidence |
|---|---|---|
| Main interior walls | Warm cream / soft butter eggshell (W-01); interior ceilings soft white (W-02) | `Architecture/Material_Schedule.md`; living concept rendering |
| Living daylight | Skylights are desired for diffuse light while avoiding TV glare; count, orientation, product, roof opening and exact placement remain unselected | `Architecture/Material_Schedule.md` V-03; living concept rendering (intent only) |
| Porch | Soft white/cream paint; optional 36-in beadboard wainscot and soft-white beadboard/V-groove ceiling | `Architecture/Material_Schedule.md`; detailed kitchen/dining/porch rendering |
| Kitchen perimeter | Warm ivory/cream shaker cabinets, not stark white | `Decisions/Kitchen_Autumn_Palette.md`; detailed kitchen rendering |
| Kitchen island | Muted sage/olive with brown-gray undertone; no bright mint or vivid green | `Decisions/Kitchen_Autumn_Palette.md` (newer owner direction takes precedence over the image's all-cream island) |
| Social floors / wood | Warm natural oak; honey/walnut butcher block without orange stain | `Architecture/Material_Schedule.md`; `Decisions/Kitchen_Autumn_Palette.md`; kitchen rendering |
| Metals / tile | Aged brass or antique bronze; warm ivory/biscuit backsplash; cream subway tile in bath wet areas | `Architecture/Material_Schedule.md`; palette decision; bath rendering is mood only |
| Primary bath | Separate tub plus tiled rain shower, black-grid glass as a visual reference; final product, exact sizes and finish remain open | Owner-approved MGM reference decision and its cited image/source |

## Not yet specified

The current renderings are interior concepts. They do not establish an exterior siding, trim, roof, foundation, or site palette. No exterior wall color/material should be selected from inference. Before a rendering-matched exterior materials pass, identify a current approved exterior reference or ask the owner for the missing palette choices. Product-specific materials, sample colors under real lighting, exact wall finish build-ups and final Revit appearance assets still require confirmation.

The M299 native wall-shell derivative is deliberately uncolored and uses a blank-template wall type only as a geometry placeholder. It does not yet visually match the interior renderings; it establishes native wall geometry for subsequent coordinated studies. Apply room-specific finishes only after room boundaries, wall faces, openings and assemblies are supported. Keep rendering comparison views and material assignments labeled as design intent, not a compliance or construction result.
