"""Run with blender --background --python Tools/blender_smoke.py."""
from pathlib import Path
import bpy

root = Path(__file__).resolve().parents[1]
out = root / '.local' / 'smoke'
out.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=str(out / 'study-island.glb'))
meshes = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
assert len(meshes) == 1
actual = sorted(meshes[0].dimensions)
expected = sorted([2.4384, 1.2192, 0.9144])
assert all(abs(a-b) < 1e-5 for a, b in zip(actual, expected)), actual
bpy.ops.wm.save_as_mainfile(filepath=str(out / 'smoke.blend'))
print('PASS: Blender imported GLB dimensions and saved smoke.blend')
