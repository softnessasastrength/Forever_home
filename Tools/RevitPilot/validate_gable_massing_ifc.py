"""Validate an M83 Revit IFC2X3 roof-surface comparison export.

Checks exact saved-RVT/IFC lineage, source-bound option inputs, IFC schema,
six Generic Model proxy meshes, world-coordinate bounds, triangulated plane
area, and intentional absence of native building construction entities. It
does not evaluate code, loads, roof assemblies, or building suitability.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
from typing import Any

import ifcopenshell
import ifcopenshell.geom
import ifcopenshell.validate
import numpy as np
import ifcopenshell.util.unit

FT_PER_METRE = 1.0 / 0.3048
BOUNDS_TOLERANCE_FT = 0.02
AREA_TOLERANCE_SQFT = 0.1
ABSENT_BUILDING_CLASSES = ("IfcRoof", "IfcWall", "IfcSlab", "IfcDoor", "IfcWindow", "IfcStair", "IfcStairFlight")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def geometry_metrics(product: Any, settings: Any, unit_scale: float) -> dict[str, Any] | None:
    try:
        shape = ifcopenshell.geom.create_shape(settings, product).geometry
        vertices = np.asarray(shape.verts, dtype=float).reshape((-1, 3)) * unit_scale * FT_PER_METRE
        faces = np.asarray(shape.faces, dtype=int).reshape((-1, 3))
    except Exception:
        return None
    if len(vertices) < 3 or len(faces) < 1 or not np.isfinite(vertices).all():
        return None
    triangles = vertices[faces]
    triangle_areas = 0.5 * np.linalg.norm(
        np.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0]), axis=1
    )
    if not np.isfinite(triangle_areas).all():
        return None
    mins, maxs = vertices.min(axis=0), vertices.max(axis=0)
    return {
        "vertex_count": int(len(vertices)),
        "triangle_count": int(len(faces)),
        "bounds_ft": {
            "min_x": float(mins[0]), "min_y": float(mins[1]), "min_z": float(mins[2]),
            "max_x": float(maxs[0]), "max_y": float(maxs[1]), "max_z": float(maxs[2]),
        },
        "triangulated_area_sqft": float(triangle_areas.sum()),
    }


def expected_bounds(option: dict[str, Any], width: float, depth: float, rise: float) -> dict[str, float]:
    offset = option["display_offset_ft"]
    x, y = float(offset["x"]), float(offset["y"])
    return {
        "min_x": x, "min_y": y, "min_z": 0.0,
        "max_x": x + width, "max_y": y + depth, "max_z": rise,
    }


def validate(run_directory: Path, report_path: Path | None = None) -> dict[str, Any]:
    run_directory = run_directory.resolve()
    report_path = (report_path or run_directory / "ifc-validation.json").resolve()
    paths = {
        "roof_options": run_directory / "roof-options.json",
        "roof_options_manifest": run_directory / "roof-options-manifest.json",
        "study_manifest": run_directory / "study-manifest.json",
        "export_result": run_directory / "export-result.json",
        "rvt": run_directory / "FH_M83_Gable_Massing_Comparison.rvt",
        "ifc": run_directory / "FH_M83_Gable_Massing_Comparison.ifc",
    }
    checks = {name + "_present": path.is_file() and path.stat().st_size > 0 for name, path in paths.items()}
    errors = [f"missing or empty artifact: {path}" for name, path in paths.items() if not checks[name + "_present"]]
    observations: dict[str, Any] = {}
    limitations = [
        "The six IFC entities are generic proxy meshes representing two open roof planes per option.",
        "No Revit Roof element, thickness, wall, gable end, overhang, opening, framing or material specification is represented.",
        "The 38.333333 x 40 ft shell and all pitch/direction variants remain hypothetical, unselected comparison inputs.",
        "No code applicability, snow/wind load, structural adequacy, accessibility, professional certification or construction-readiness finding is made.",
    ]
    if errors:
        result = {"schema": "forever-home.m83-gable-massing-ifc-validation.v1", "status": "fail", "checks": checks, "observations": observations, "errors": errors, "limitations": limitations}
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(result, indent=2), encoding="utf-8")
        return result

    options = read_json(paths["roof_options"])
    source_manifest = read_json(paths["roof_options_manifest"])
    study_manifest = read_json(paths["study_manifest"])
    export_result = read_json(paths["export_result"])
    checks["option_source_matches_its_manifest"] = (
        options.get("schema") == "forever-home.m83-gable-massing-options.v1"
        and source_manifest.get("output_hashes_sha256", {}).get("roof_options") == sha256(paths["roof_options"])
    )
    model_fingerprint = study_manifest.get("model_fingerprint") or {}
    checks["saved_rvt_fingerprint_matches"] = (
        model_fingerprint.get("algorithm") == "sha256-of-saved-rvt-bytes-v1"
        and model_fingerprint.get("file_name") == paths["rvt"].name
        and model_fingerprint.get("bytes") == paths["rvt"].stat().st_size
        and model_fingerprint.get("sha256") == sha256(paths["rvt"])
    )
    checks["export_records_same_saved_rvt"] = export_result.get("model_fingerprint") == model_fingerprint
    checks["ifc_export_api_succeeded"] = export_result.get("ifc2x3_api_result") is True
    checks["ifc_hash_matches_export_record"] = (
        export_result.get("ifc_file") == paths["ifc"].name
        and export_result.get("ifc_bytes") == paths["ifc"].stat().st_size
        and export_result.get("ifc_sha256") == sha256(paths["ifc"])
    )
    geometry_settings = ifcopenshell.geom.settings()
    geometry_settings.set(geometry_settings.USE_WORLD_COORDS, True)
    model_ifc = None
    logger = None
    try:
        model_ifc = ifcopenshell.open(str(paths["ifc"]))
        logger = ifcopenshell.validate.json_logger()
        ifcopenshell.validate.validate(model_ifc, logger)
    except Exception as exc:
        errors.append(f"IFC parse/schema validation raised: {exc}")
    checks["ifc2x3_schema"] = bool(model_ifc and model_ifc.schema == "IFC2X3")
    checks["ifc_schema_validation_clean"] = bool(logger is not None and not logger.statements)

    options_basis = options.get("coordinate_basis", {})
    width, depth = float(options_basis.get("shell_width_ft", 0)), float(options_basis.get("shell_depth_ft", 0))
    checks["hypothetical_shell_matches_M78"] = (
        math.isclose(width, 38.333333, abs_tol=1e-6)
        and math.isclose(depth, 40.0, abs_tol=1e-6)
        and "hypothetical" in str(options_basis.get("shell_status", "")).lower()
    )
    expected_options = {str(option.get("case_id")): option for option in options.get("results", [])}
    checks["six_unique_unselected_roof_options"] = (
        len(expected_options) == 6
        and len(options.get("results", [])) == 6
        and all("not owner-selected" in str(option.get("selection_status", "")).lower() for option in expected_options.values())
    )
    checks["study_inventory_contains_six_open_meshes"] = (
        study_manifest.get("schema") == "forever-home.m83-gable-massing-revit.v1"
        and study_manifest.get("counts", {}).get("option_count") == 6
        and study_manifest.get("counts", {}).get("roofs") == 0
        and len(study_manifest.get("geometry", [])) == 6
        and all(row.get("positive_volume_solid_count") == 0 and row.get("mesh_count", 0) > 0 for row in study_manifest.get("geometry", []))
    )

    proxy_records: list[dict[str, Any]] = []
    geometry_errors: list[str] = []
    entity_counts: dict[str, int] = {}
    schema_issue_count = None
    if model_ifc:
        proxies = model_ifc.by_type("IfcBuildingElementProxy")
        entities_by_name: dict[str, Any] = {}
        for proxy in proxies:
            label_fields = [getattr(proxy, name, None) for name in ("Name", "Tag", "Description", "ObjectType")]
            label = " | ".join(str(value or "") for value in label_fields)
            matches = [case_id for case_id in expected_options if case_id in label]
            if len(matches) != 1:
                geometry_errors.append(f"Proxy label is missing a unique M83 case ID: {label!r}")
                continue
            case_id = matches[0]
            if case_id in entities_by_name:
                geometry_errors.append(f"Duplicate IFC proxy for {case_id}")
                continue
            entities_by_name[case_id] = proxy
        checks["six_named_generic_model_proxies"] = len(proxies) == 6 and set(entities_by_name) == set(expected_options)

        unit_scale = ifcopenshell.util.unit.calculate_unit_scale(model_ifc)
        bounds_errors, area_errors = [], []
        for case_id, option in expected_options.items():
            proxy = entities_by_name.get(case_id)
            metrics = geometry_metrics(proxy, geometry_settings, unit_scale) if proxy is not None else None
            target_rise = float(option["rise_above_relative_eave_ft"])
            target_bounds = expected_bounds(option, width, depth, target_rise)
            target_area = float(option["two_plane_surface_area_sf"])
            if metrics is None:
                geometry_errors.append(f"Missing or invalid triangulated geometry for {case_id}")
                continue
            bounds = metrics["bounds_ft"]
            if any(abs(bounds[key] - value) > BOUNDS_TOLERANCE_FT for key, value in target_bounds.items()):
                bounds_errors.append(case_id)
            if not math.isfinite(metrics["triangulated_area_sqft"]) or abs(metrics["triangulated_area_sqft"] - target_area) > AREA_TOLERANCE_SQFT:
                area_errors.append(case_id)
            proxy_records.append({
                "case_id": case_id,
                "ifc_name": str(proxy.Name or ""),
                "ifc_type": proxy.is_a(),
                "global_id": proxy.GlobalId,
                "bounds_ft": bounds,
                "expected_bounds_ft": target_bounds,
                "triangulated_area_sqft": metrics["triangulated_area_sqft"],
                "expected_area_sqft": target_area,
                "triangle_count": metrics["triangle_count"],
            })
        checks["proxy_bounds_match_expected"] = not bounds_errors
        checks["proxy_surface_areas_match_expected"] = not area_errors
        physical = {name: len(model_ifc.by_type(name)) for name in ABSENT_BUILDING_CLASSES}
        checks["no_native_roof_or_building_elements"] = all(count == 0 for count in physical.values())
        entity_counts = {name: len(model_ifc.by_type(name)) for name in ("IfcBuildingElementProxy", "IfcRoof", "IfcWall", "IfcSlab", "IfcDoor", "IfcWindow", "IfcStair")}
        schema_issue_count = len(logger.statements) if logger else None
        observations.update({
            "ifc_schema": model_ifc.schema,
            "schema_issue_count": schema_issue_count,
            "entity_counts": entity_counts,
            "roof_options": sorted(proxy_records, key=lambda row: row["case_id"]),
        })
        if bounds_errors or area_errors or geometry_errors:
            errors.append(f"IFC geometry mismatches: bounds={bounds_errors}, area={area_errors}, geometry={geometry_errors}")
    else:
        for key in ("six_named_generic_model_proxies", "proxy_bounds_match_expected", "proxy_surface_areas_match_expected", "no_native_roof_or_building_elements"):
            checks[key] = False
    checks["source_m78_shell_fingerprint_present"] = bool(options.get("source_fingerprints_sha256", {}).get("m78_search"))
    errors.extend(f"failed check: {name}" for name, passed in checks.items() if not passed)
    result = {
        "schema": "forever-home.m83-gable-massing-ifc-validation.v1",
        "status": "pass" if not errors else "fail",
        "checks": checks,
        "passed_count": sum(bool(value) for value in checks.values()),
        "check_count": len(checks),
        "observations": observations,
        "errors": errors,
        "limitations": limitations,
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(result, indent=2, sort_keys=True), encoding="utf-8")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run_directory", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = validate(args.run_directory, args.report)
    print(f"{result['status'].upper()}: {result['passed_count']}/{result['check_count']} checks passed.")
    for error in result["errors"]:
        print(f"- {error}")
    print("Roof-surface IFC checks only; no code, structural-safety, or construction-readiness determination.")
    return 0 if result["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
