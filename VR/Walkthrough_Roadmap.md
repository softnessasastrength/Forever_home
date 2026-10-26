# Forever Home interactive walkthrough and VR roadmap

Status: future capability, not yet implemented.

## Goal
A navigable human-scale digital Forever Home that supports architectural review before construction, including a desktop mode first and VR later.

## Suggested asset pipeline
1. Author dimensioned architecture and asset identifiers in Revit.
2. Export interoperable geometry (IFC and/or supported mesh exchange formats), retaining stable asset IDs and a version manifest.
3. Prepare geometry, UVs, materials, LODs, collision meshes, and baked-lighting assets in Blender.
4. Import into Unreal Engine and implement desktop first-person movement; evaluate OpenXR headset support later.
5. Test frame times on actual target hardware and headset; optimize scene complexity, lighting, textures, and draw calls.

## Review modes
- Furnished mode: room scale, circulation, sightlines, furniture, daylight scenarios.
- Systems mode: selectable cable pathways, rack equipment, circuits, ducts, and service clearances, with simplified visibility toggles.
- Finish comparison: switch among documented materials without changing source design intent.
- Accessibility review: door clearances, stairs, routes, furniture clearances; VR experience is not a substitute for code compliance.

## Minimum viable walkthrough
- One dimensioned main-floor slice including kitchen, dining, living, and porch.
- Human-height camera, collision, doors, simple lighting, teleport/keyboard controls as appropriate.
- Stable Revit-to-engine import process and asset manifest.
- Desktop performance target established before headset-specific optimization.

## Hardware note
AMD RX 6600 XT can be used for Blender/desktop prototyping with optimization. VR suitability depends on headset resolution, engine version, graphics settings, scene load, and tested frame time. Do not promise a particular frame rate.

## Repository outputs
Revit sources (subject to license), IFC, Blender sources, Unreal project source/assets as permitted, documented dependencies, screenshots, versioned exports, and optional binaries/releases. Check rights to all third-party models and textures before public redistribution.
