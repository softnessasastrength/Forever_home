"""Inspect a real pilot run, preserving failures; never fabricates Revit evidence."""
import argparse
import csv
import hashlib
import json
from collections import Counter
from pathlib import Path

import ifcopenshell
import ifcopenshell.geom
import ifcopenshell.util.element
import ifcopenshell.validate
import numpy as np


def validate(folder):
    run = json.loads((folder / 'run.json').read_text(encoding='utf-8-sig'))
    records = json.loads((folder / 'elements.json').read_text(encoding='utf-8-sig'))
    with (folder / 'elements.csv').open(encoding='utf-8-sig', newline='') as stream:
        rows = list(csv.DictReader(stream))
    ids = [r['id'] for r in records]
    checks = {
        'fixture_count_is_nine': len(records) == 9,
        'stable_ids_unique': len(ids) == len(set(ids)),
        'csv_matches_json': rows == [
            {key: '' if value is None else str(value) for key, value in record.items()}
            for record in records
        ],
        'source_reopened': run['reopen_checks']['source'],
        'backup_reopened': run['reopen_checks']['backup'],
        'all_export_calls_succeeded': all(v['success'] for v in run['exports'].values()),
    }
    observations = {}
    ifc_path = folder / 'FH_Compatibility_Pilot.ifc'
    if ifc_path.exists():
        model = ifcopenshell.open(ifc_path)
        logger = ifcopenshell.validate.json_logger()
        ifcopenshell.validate.validate(model, logger)
        checks['ifc2x3_schema'] = model.schema == 'IFC2X3'
        checks['ifc_schema_validation'] = not logger.statements
        counts = Counter(e.is_a() for e in model.by_type('IfcProduct'))
        observations['ifc_product_counts'] = dict(sorted(counts.items()))
        observations['ifc_schema_issue_count'] = len(logger.statements)
        observed_ids = set()
        for product in model.by_type('IfcProduct'):
            text = json.dumps(ifcopenshell.util.element.get_psets(product), default=str)
            observed_ids.update(id_ for id_ in ids if id_ in text)
        observations['stable_ids_found_in_ifc_properties'] = sorted(observed_ids)
        observations['stable_ids_missing_from_ifc_properties'] = sorted(set(ids) - observed_ids)
        checks['all_stable_ids_in_ifc_properties'] = observed_ids == set(ids)
        checks['ifc_has_two_hosted_openings'] = len(model.by_type('IfcRelVoidsElement')) == 2
        checks['ifc_has_door_and_window_fills'] = len(model.by_type('IfcRelFillsElement')) == 2
        space = model.by_type('IfcSpace')
        source_room_area = next(r['room_area_sf'] for r in records if r['id'] == 'FH-PILOT-ROOM-01')
        exported_area = (ifcopenshell.util.element.get_psets(space[0]).get('Dimensions', {}).get('Area')
                         if space else None)
        checks['ifc_revit_room_area_property_matches_sf'] = (
            exported_area is not None and abs(exported_area - source_room_area) < 1e-6)
        observations['room_area_sf'] = source_room_area
        observations['ifc_room_area_revit_property_sf'] = exported_area
        for label, ifc_class, minimum in [('walls', 'IfcWall', 4), ('door', 'IfcDoor', 1),
                                        ('window', 'IfcWindow', 1), ('stair', 'IfcStair', 1),
                                        ('room', 'IfcSpace', 1)]:
            checks['ifc_has_' + label] = len(model.by_type(ifc_class)) >= minimum
        settings = ifcopenshell.geom.settings()
        settings.set(settings.USE_WORLD_COORDS, True)
        bounds = []
        geometry_errors = []
        for product in model.by_type('IfcProduct'):
            if not product.Representation:
                continue
            try:
                shape = ifcopenshell.geom.create_shape(settings, product)
                points = np.array(shape.geometry.verts).reshape(-1, 3)
                if len(points):
                    bounds.append((points.min(axis=0), points.max(axis=0)))
            except Exception:
                geometry_errors.append({'class': product.is_a(), 'guid': product.GlobalId})
        checks['ifc_geometry_present'] = bool(bounds)
        checks['ifc_geometry_decoded'] = not geometry_errors
        observations['ifc_geometry_errors'] = geometry_errors
        if bounds:
            observations['ifc_world_bounds_metres'] = [
                np.min([b[0] for b in bounds], axis=0).tolist(),
                np.max([b[1] for b in bounds], axis=0).tolist(),
            ]
    else:
        checks['ifc_present'] = False
    dwgs = list(folder.glob('*.dwg'))
    checks['dwg_2010_header'] = bool(dwgs) and all(p.read_bytes()[:6] == b'AC1024' for p in dwgs)
    pdf = folder / 'FH_Compatibility_Pilot.pdf'
    checks['pdf_header'] = pdf.exists() and pdf.read_bytes().startswith(b'%PDF-')
    manifest = {
        'schema_version': 1, 'fixture_only': True, 'revit_version': run['revit_version'],
        'revit_build': run['revit_build'], 'checks': checks, 'observations': observations,
        'files': [dict(path=p.relative_to(folder).as_posix(), bytes=p.stat().st_size,
                       sha256=hashlib.sha256(p.read_bytes()).hexdigest())
                  for p in sorted(folder.rglob('*')) if p.is_file() and p.name != 'manifest.json'],
        'limitations': [
            'Revit 2018 import/editability remains untested until explicitly recorded.',
            'DWG header is not an independent drawing-fidelity check.',
            'PDF header is not visual layout verification.',
            'Fixture geometry and equipment are not approved house design or engineering.',
        ],
    }
    (folder / 'manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    print(json.dumps({'checks': checks, 'observations': observations}, indent=2))
    return all(checks.values())


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('run_folder', type=Path)
    args = parser.parse_args()
    raise SystemExit(0 if validate(args.run_folder.resolve()) else 1)
