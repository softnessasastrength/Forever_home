"""Validate a disposable M78 hypothetical upper-suite Revit/IFC2X3 study.

The validator checks source and saved-model lineage, seven Revit/IFC spaces,
their areas and world-coordinate plan bounds, one upper storey, clean IFC2X3
schema validation, and intentionally absent construction categories. It does
not assess architecture, code compliance, accessibility, structure, or fit.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
from pathlib import Path
from typing import Any

import ifcopenshell
import ifcopenshell.geom
import ifcopenshell.util.element
import ifcopenshell.util.unit
import ifcopenshell.validate

FT_PER_METRE = 1.0 / 0.3048
AREA_TOLERANCE_SQFT = 0.1
BOUNDS_TOLERANCE_FT = 0.02
SHELL_TOLERANCE_FT = 1e-6
EMPTY_CLASSES = ("IfcWall", "IfcSlab", "IfcStair", "IfcStairFlight", "IfcDoor", "IfcWindow")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def read_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def ifc_space_id(space: Any) -> str:
    psets = ifcopenshell.util.element.get_psets(space)
    identity = psets.get("Identity Data", {})
    return str(identity.get("Number") or space.Name or "").strip()


def plan_bounds_ft(space: Any, settings: Any) -> dict[str, float] | None:
    try:
        vertices = ifcopenshell.geom.create_shape(settings, space).geometry.verts
    except Exception:
        return None
    if not vertices or len(vertices) < 6 or len(vertices) % 3:
        return None
    xs = [float(value) * FT_PER_METRE for value in vertices[0::3]]
    ys = [float(value) * FT_PER_METRE for value in vertices[1::3]]
    if not all(math.isfinite(value) for value in xs + ys):
        return None
    return {"min_x": min(xs), "min_y": min(ys), "max_x": max(xs), "max_y": max(ys)}


def room_blocks_within_shell(rectangles: dict[str, Any], width_ft: float, depth_ft: float) -> bool:
    """Check source room rectangles in the shell's local coordinate frame."""
    if not math.isfinite(width_ft) or not math.isfinite(depth_ft) or width_ft <= 0 or depth_ft <= 0:
        return False
    if not rectangles:
        return False
    for rect in rectangles.values():
        try:
            x, y = float(rect["x_ft"]), float(rect["y_ft"])
            width, depth = float(rect["width_ft"]), float(rect["depth_ft"])
        except (KeyError, TypeError, ValueError):
            return False
        if not all(math.isfinite(value) for value in (x, y, width, depth)) or width <= 0 or depth <= 0:
            return False
        if x < -SHELL_TOLERANCE_FT or y < -SHELL_TOLERANCE_FT:
            return False
        if x + width > width_ft + SHELL_TOLERANCE_FT or y + depth > depth_ft + SHELL_TOLERANCE_FT:
            return False
    return True


def validate(run_dir: Path, m78_source: Path, selected_d_source: Path, report: Path | None = None) -> dict[str, Any]:
    run_dir, m78_source, selected_d_source = map(Path.resolve, (run_dir, m78_source, selected_d_source))
    report = (report or run_dir / "ifc-validation.json").resolve()
    paths = {
        "search": run_dir / "m78-search.json",
        "selected_d": run_dir / "selected-d-study.json",
        "study_manifest": run_dir / "study-manifest.json",
        "export_result": run_dir / "export-result.json",
        "inventory": run_dir / "room-inventory.csv",
        "rvt": run_dir / "FH_M78_Upper_Suite_Test.rvt",
        "ifc": run_dir / "FH_M78_Upper_Suite_Test.ifc",
        "m78_source": m78_source,
        "selected_d_source": selected_d_source,
    }
    checks = {name + "_present": path.is_file() and path.stat().st_size > 0 for name, path in paths.items()}
    errors = [f"missing or empty artifact: {path}" for name, path in paths.items() if not checks[name + "_present"]]
    observations: dict[str, Any] = {}
    limitations = [
        "The Revit model contains only an upper-level room-boundary study and a model-line shell outline.",
        "The 38.333333 x 40 ft envelope is a hypothetical comparison and does not amend selected D.",
        "Walls, actual doors/openings, floor solids, stairs, roof, structure, MEP and lift product are absent.",
        "M78 corridor-grid samples are not measured clear routes or code findings.",
        "Passing validation does not establish code compliance, accessibility, structural safety or construction readiness.",
    ]
    if errors:
        result = {"schema": "forever-home.m78-upper-suite-ifc-validation.v1", "status": "fail", "checks": checks, "observations": observations, "errors": errors, "limitations": limitations}
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, indent=2), encoding="utf-8")
        return result

    m78_bytes, selected_bytes = m78_source.read_bytes(), selected_d_source.read_bytes()
    study, selected = read_json(paths["search"]), read_json(paths["selected_d"])
    study_manifest, export = read_json(paths["study_manifest"]), read_json(paths["export_result"])
    search_hash, selected_hash = hashlib.sha256(m78_bytes).hexdigest(), hashlib.sha256(selected_bytes).hexdigest()
    checks["copied_m78_source_matches"] = paths["search"].read_bytes() == m78_bytes
    checks["copied_selected_d_source_matches"] = paths["selected_d"].read_bytes() == selected_bytes
    checks["m78_source_hash_matches_archive_manifest"] = read_json(m78_source.parent / "manifest.json").get("output_hashes_sha256", {}).get("search") == search_hash
    archived = read_json(m78_source.parent / "manifest.json").get("source_fingerprints_sha256", {})
    checks["selected_d_source_hash_matches_m78_manifest"] = archived.get("selected_D_study.json") == selected_hash
    checks["study_manifest_source_hashes_match"] = study_manifest.get("source_sha256") == {"m78_search": search_hash, "selected_d_study": selected_hash}
    model = study_manifest.get("model_fingerprint") or {}
    checks["saved_rvt_fingerprint_matches"] = (
        model.get("algorithm") == "sha256-of-saved-rvt-bytes-v1"
        and model.get("file_name") == paths["rvt"].name
        and model.get("bytes") == paths["rvt"].stat().st_size
        and model.get("sha256") == sha256(paths["rvt"])
    )
    checks["export_api_succeeded"] = export.get("ifc2x3_api_result") is True
    checks["ifc_uses_same_saved_rvt_fingerprint"] = export.get("model_fingerprint") == model
    checks["ifc_hash_matches_export_record"] = (
        export.get("ifc_file") == paths["ifc"].name
        and export.get("ifc_bytes") == paths["ifc"].stat().st_size
        and export.get("ifc_sha256") == sha256(paths["ifc"])
    )

    candidate = study.get("best_candidate", {})
    rectangles = candidate.get("rectangles", {})
    frame = selected.get("plan_frame_offsets_ft", {}).get("upper", [0.0, 0.0])
    source_rooms = {str(room["id"]): room for room in selected.get("plans", {}).get("upper", [])}
    expected = {}
    for identifier, rect in rectangles.items():
        source = source_rooms.get(identifier, {})
        expected[identifier] = {
            "name": source.get("name", ""),
            "area_sf": float(rect["width_ft"]) * float(rect["depth_ft"]),
            "bounds": {
                "min_x": float(rect["x_ft"]) + float(frame[0]),
                "min_y": float(rect["y_ft"]) + float(frame[1]),
                "max_x": float(rect["x_ft"]) + float(frame[0]) + float(rect["width_ft"]),
                "max_y": float(rect["y_ft"]) + float(frame[1]) + float(rect["depth_ft"]),
            },
        }
    checks["seven_unique_source_rooms"] = len(expected) == 7 and len(set(expected)) == 7 and all(item["name"] for item in expected.values())
    shell = study.get("coordinate_basis", {})
    checks["hypothetical_shell_case_is_exact"] = (
        math.isclose(float(shell.get("width_ft", 0)), 38.333333, abs_tol=1e-6)
        and math.isclose(float(shell.get("depth_ft", 0)), 40.0, abs_tol=1e-6)
        and "hypothetical" in str(shell.get("shell_case", "")).lower()
    )
    checks["candidate_room_blocks_within_shell"] = room_blocks_within_shell(rectangles, 38.333333, 40.0)
    checks["owner_access_graph_is_retained"] = (
        bool(candidate.get("hall_reachability", {}).get("required_public_rooms_reached"))
        and set(candidate.get("public_rooms_reached", [])) >= {"U-01", "U-02", "U-04"}
        and "U-03" not in set(candidate.get("public_rooms_reached", []))
    )
    checks["rvt_inventory_matches_source_areas"] = False
    try:
        with paths["inventory"].open(encoding="utf-8-sig", newline="") as stream:
            inventory_rows = list(csv.DictReader(stream))
        inv = {row["id"]: row for row in inventory_rows}
        checks["rvt_inventory_matches_source_areas"] = set(inv) == set(expected) and len(inventory_rows) == 7 and all(
            abs(float(inv[key]["area_sf"]) - item["area_sf"]) <= AREA_TOLERANCE_SQFT
            and abs(float(inv[key]["expected_area_sf"]) - item["area_sf"]) <= AREA_TOLERANCE_SQFT
            for key, item in expected.items()
        )
    except (OSError, KeyError, ValueError):
        pass

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
    if model_ifc:
        unit_scale = ifcopenshell.util.unit.calculate_unit_scale(model_ifc)
        storeys = model_ifc.by_type("IfcBuildingStorey")
        expected_elevation = float(study_manifest.get("level", {}).get("elevation_ft", 5.0))
        storey_records = [{"name": str(level.Name or ""), "elevation_ft": float(level.Elevation or 0) * unit_scale * FT_PER_METRE} for level in storeys]
        checks["single_upper_storey_matches_source"] = len(storeys) == 1 and storey_records[0]["name"] == "M78 Upper FF (Hypothetical Test)" and abs(storey_records[0]["elevation_ft"] - expected_elevation) <= 0.02
        spaces = model_ifc.by_type("IfcSpace")
        checks["ifc_space_ids_match_source"] = len(spaces) == 7 and len({ifc_space_id(item) for item in spaces}) == 7 and {ifc_space_id(item) for item in spaces} == set(expected)
        containment = {}
        for relation in model_ifc.by_type("IfcRelContainedInSpatialStructure") + model_ifc.by_type("IfcRelAggregates"):
            structure = getattr(relation, "RelatingStructure", None) or getattr(relation, "RelatingObject", None)
            if not structure or not structure.is_a("IfcBuildingStorey"):
                continue
            for space in getattr(relation, "RelatedElements", None) or getattr(relation, "RelatedObjects", None) or []:
                if space.is_a("IfcSpace"):
                    containment[ifc_space_id(space)] = str(structure.Name or "")
        geometry = ifcopenshell.geom.settings()
        geometry.set(geometry.USE_WORLD_COORDS, True)
        area_errors, name_errors, level_errors, bounds_errors = [], [], [], []
        area_records = []
        for space in spaces:
            identifier = ifc_space_id(space)
            target = expected.get(identifier)
            if not target:
                continue
            long_name = str(getattr(space, "LongName", None) or "").strip()
            if long_name != target["name"]:
                name_errors.append(identifier)
            quantity = ifcopenshell.util.element.get_psets(space).get("Dimensions", {}).get("Area")
            try:
                area = float(quantity) if quantity is not None else None
            except (TypeError, ValueError):
                area = None
            bounds = plan_bounds_ft(space, geometry)
            if area is None and bounds is not None:
                area = (bounds["max_x"] - bounds["min_x"]) * (bounds["max_y"] - bounds["min_y"])
            if area is None or not math.isfinite(area) or abs(area - target["area_sf"]) > AREA_TOLERANCE_SQFT:
                area_errors.append(identifier)
            if containment.get(identifier) != "M78 Upper FF (Hypothetical Test)":
                level_errors.append(identifier)
            if bounds is None or any(abs(bounds[key] - target["bounds"][key]) > BOUNDS_TOLERANCE_FT for key in target["bounds"]):
                bounds_errors.append(identifier)
            area_records.append({"id": identifier, "name": long_name, "area_sf": area, "expected_area_sf": target["area_sf"], "bounds_ft": bounds})
        checks["ifc_space_names_match_source"] = not name_errors
        checks["ifc_space_areas_match_source"] = not area_errors
        checks["ifc_space_storey_assignment_matches"] = not level_errors and len(containment) == 7
        checks["ifc_space_plan_bounds_match_source"] = not bounds_errors
        physical = {name: len(model_ifc.by_type(name)) for name in EMPTY_CLASSES}
        checks["construction_elements_remain_absent"] = all(value == 0 for value in physical.values())
        observations.update({"schema": model_ifc.schema, "schema_issue_count": len(logger.statements) if logger else None, "storeys": storey_records, "space_count": len(spaces), "spaces": sorted(area_records, key=lambda item: item["id"]), "construction_entity_counts": physical})
        if area_errors or name_errors or level_errors or bounds_errors:
            errors.append(f"IFC space mismatches: area={area_errors}, name={name_errors}, level={level_errors}, bounds={bounds_errors}")
    else:
        for key in ("single_upper_storey_matches_source", "ifc_space_ids_match_source", "ifc_space_names_match_source", "ifc_space_areas_match_source", "ifc_space_storey_assignment_matches", "ifc_space_plan_bounds_match_source", "construction_elements_remain_absent"):
            checks[key] = False

    errors.extend(f"failed check: {key}" for key, passed in checks.items() if not passed)
    result = {
        "schema": "forever-home.m78-upper-suite-ifc-validation.v1",
        "status": "pass" if not errors else "fail",
        "checks": checks,
        "passed_count": sum(checks.values()),
        "check_count": len(checks),
        "observations": observations,
        "errors": errors,
        "limitations": limitations,
    }
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, indent=2), encoding="utf-8")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run_directory", type=Path)
    parser.add_argument("--m78-source", type=Path, default=Path("Architecture/M78_Upper_Suite_38_333333x40_Hypothetical_Test_2026-10-29/search.json"))
    parser.add_argument("--selected-d-source", type=Path, default=Path("Architecture/Selected_Design_Iteration_2026-10-27/study.json"))
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    result = validate(args.run_directory, args.m78_source, args.selected_d_source, args.report)
    print(f"{result['status'].upper()}: {result['passed_count']}/{result['check_count']} checks passed.")
    for error in result["errors"]:
        print(f"- {error}")
    print("Room-space/export validation only; no compliance, structural-safety or construction-readiness determination.")
    return 0 if result["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
