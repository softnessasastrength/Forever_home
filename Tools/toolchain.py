"""Repeatable local geometry/interchange smoke test; not a house or Revit test."""
import importlib.metadata
import json
import shutil
import sys
from pathlib import Path

import ezdxf
import ifcopenshell
import ifcopenshell.validate
import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / '.local' / 'smoke'
OUT.mkdir(parents=True, exist_ok=True)

# Real serialized geometry, reloaded independently of the source object.
box = trimesh.creation.box(extents=[2.4384, 1.2192, 0.9144])
box.export(OUT / 'study-island.glb')
loaded = trimesh.load(OUT / 'study-island.glb', force='mesh')
assert np.allclose(loaded.extents, box.extents, atol=1e-6)

dxf = ezdxf.new('R2010')
dxf.units = 6  # metres
msp = dxf.modelspace()
msp.add_lwpolyline([(0, 0), (2.4384, 0), (2.4384, 1.2192), (0, 1.2192)], close=True)
dxf.saveas(OUT / 'study-island.dxf')
reloaded = ezdxf.readfile(OUT / 'study-island.dxf')
assert not reloaded.audit().has_errors
assert len(reloaded.modelspace().query('LWPOLYLINE')) == 1

# Minimal schema-valid IFC project tests writer/parser, not Revit compatibility.
ifc = ifcopenshell.file(schema='IFC2X3')
person = ifc.create_entity('IfcPerson', FamilyName='Toolchain')
org = ifc.create_entity('IfcOrganization', Name='Forever Home')
actor = ifc.create_entity('IfcPersonAndOrganization', ThePerson=person, TheOrganization=org)
app = ifc.create_entity('IfcApplication', ApplicationDeveloper=org, Version='1', ApplicationFullName='FH smoke test', ApplicationIdentifier='FH')
owner = ifc.create_entity('IfcOwnerHistory', OwningUser=actor, OwningApplication=app, ChangeAction='ADDED', CreationDate=0)
origin = ifc.create_entity('IfcCartesianPoint', Coordinates=(0., 0., 0.))
axis = ifc.create_entity('IfcAxis2Placement3D', Location=origin)
context = ifc.create_entity('IfcGeometricRepresentationContext', ContextType='Model', CoordinateSpaceDimension=3, Precision=1e-5, WorldCoordinateSystem=axis)
unit = ifc.create_entity('IfcSIUnit', UnitType='LENGTHUNIT', Name='METRE')
units = ifc.create_entity('IfcUnitAssignment', Units=[unit])
ifc.create_entity('IfcProject', GlobalId=ifcopenshell.guid.new(), OwnerHistory=owner, Name='Toolchain smoke test only', RepresentationContexts=[context], UnitsInContext=units)
ifc.write(str(OUT / 'smoke.ifc'))
read = ifcopenshell.open(str(OUT / 'smoke.ifc'))
logger = ifcopenshell.validate.json_logger()
ifcopenshell.validate.validate(read, logger)
assert not logger.statements, logger.statements
assert read.schema == 'IFC2X3'

report = {
    'python': sys.version.split()[0],
    'packages': {name: importlib.metadata.version(name) for name in ['ifcopenshell', 'trimesh', 'ezdxf', 'numpy']},
    'checks': ['GLB box dimensions roundtrip', 'DXF polyline roundtrip and audit', 'IFC2X3 project schema validation'],
    'revit_2027_installed': Path('C:/Program Files/Autodesk/Revit 2027/Revit.exe').exists(),
    'blender_executable': shutil.which('blender') or next((str(p) for p in Path('C:/Program Files/Blender Foundation').glob('*/blender.exe')), None),
    'limitations': ['No Revit API execution or 2018 import tested', 'No architectural model generated', 'No VR benchmark performed'],
}
(OUT / 'report.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
print(json.dumps(report, indent=2))
