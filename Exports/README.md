# Exports and Visualization

This directory is reserved for portable outputs derived from the working design model.

Potential contents include:

- PDF drawing sets
- dimensioned SVG plans
- IFC or other open-BIM exports
- OBJ, FBX, DAE, or glTF geometry for visualization workflows
- rendered images and walkthroughs
- simplified meshes prepared for virtual-world viewing

## Second Life concept

A future workflow may export a simplified version of the house for import into Second Life or a comparable virtual environment. The purpose would be experiential review: walking through rooms, testing sightlines, understanding scale, and sharing the design with others.

Any virtual-world model should be treated as a visualization derivative rather than the authoritative architectural model. Geometry may need simplification, triangulation, UV mapping, material baking, scale verification, collision models, and platform-specific optimization before import.

The repository should preserve the source model and document each conversion step so exports remain reproducible as software and formats change.
