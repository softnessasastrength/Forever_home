"""Validate a selected-direction-D Revit room-study IFC2X3 export.

This checks source identity, saved-model/export fingerprints, storeys, spaces,
room areas and the intentionally empty construction categories. It does not
certify architectural coordination, engineering, code or construction readiness.
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

AREA_TOLERANCE_SQFT = 0.1
ELEVATION_TOLERANCE_FT = 0.02
PLAN_BOUNDS_TOLERANCE_FT = 0.02
FT_PER_METRE = 1.0 / 0.3048
EXPECTED_EMPTY_CLASSES = ("IfcWall", "IfcSlab", "IfcStair", "IfcStairFlight", "IfcDoor", "IfcWindow")
PLAN_LEVEL_NAMES = {"main": "Main FF", "upper": "Upper FF", "lower": "Lower FF"}


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def _space_id(space: Any) -> str:
    psets = ifcopenshell.util.element.get_psets(space)
    identity = psets.get("Identity Data", {})
    return str(identity.get("Number") or space.Name or "").strip()


def _space_area(space: Any, unit_scale: float = 1.0) -> float | None:
    """Read the exported area quantity, falling back to the room's IFC footprint.

    The Revit IFC exporter may omit Dimensions.Area even when the space has a
    valid swept-solid representation. Direction D's source blocks are
    rectangular, so accept a rectangular swept profile and convert its IFC
    length units to square feet.
    """
    dimensions = ifcopenshell.util.element.get_psets(space).get("Dimensions", {})
    try:
        area = float(dimensions["Area"])
    except (KeyError, TypeError, ValueError):
        area = None
    if area is not None and math.isfinite(area) and area > 0:
        return area

    shape = getattr(space, "Representation", None)
    if shape is None:
        return None
    profile_areas: list[float] = []
    unsupported_profiles = False
    for representation in getattr(shape, "Representations", None) or []:
        for item in getattr(representation, "Items", None) or []:
            if not item.is_a("IfcExtrudedAreaSolid"):
                continue
            profile = item.SweptArea
            if not profile.is_a("IfcRectangleProfileDef"):
                unsupported_profiles = True
                continue
            length_ft_per_ifc_unit = unit_scale * FT_PER_METRE
            width_ft = float(profile.XDim) * length_ft_per_ifc_unit
            depth_ft = float(profile.YDim) * length_ft_per_ifc_unit
            footprint_area = width_ft * depth_ft
            if math.isfinite(footprint_area) and footprint_area > 0:
                profile_areas.append(footprint_area)
    # Direction D's current source encodes one rectangular footprint per room.
    # Refuse compound/unsupported representations instead of summing areas that
    # may overlap or silently omitting an unrecognized profile.
    if unsupported_profiles or len(profile_areas) != 1:
        return None
    return profile_areas[0]


def _space_body_profile_area(space: Any, unit_scale: float) -> float | None:
    """Return the area of the single rectangular Body profile, in square feet.

    The selected-D source defines each room as one rectangular block. Inspect
    the IFC body independently of quantity properties so a plausible
    Dimensions.Area cannot conceal an unrelated or compound body profile.
    """
    shape = getattr(space, "Representation", None)
    if shape is None:
        return None
    body_representations = [
        representation
        for representation in getattr(shape, "Representations", None) or []
        if getattr(representation, "RepresentationIdentifier", None) == "Body"
    ]
    if len(body_representations) != 1:
        return None
    body = body_representations[0]
    items = getattr(body, "Items", None) or []
    if getattr(body, "RepresentationType", None) != "SweptSolid" or len(items) != 1:
        return None
    solid = items[0]
    if not solid.is_a("IfcExtrudedAreaSolid"):
        return None
    profile = solid.SweptArea
    if not profile.is_a("IfcRectangleProfileDef"):
        return None
    try:
        scale = float(unit_scale) * FT_PER_METRE
        width_ft = float(profile.XDim) * scale
        depth_ft = float(profile.YDim) * scale
        area_sf = width_ft * depth_ft
    except (AttributeError, TypeError, ValueError):
        return None
    if not all(math.isfinite(value) and value > 0 for value in (scale, width_ft, depth_ft, area_sf)):
        return None
    return area_sf


def _space_level_names(model: Any) -> dict[str, str]:
    result: dict[str, str] = {}

    def add_spaces(structure: Any, spaces: Any) -> None:
        if not structure or not structure.is_a("IfcBuildingStorey"):
            return
        for space in spaces or []:
            if space.is_a("IfcSpace"):
                result[_space_id(space)] = str(structure.Name or "")

    # IFC2X3 exports from this Revit workflow aggregate IfcSpaces under
    # IfcBuildingStorey, rather than using IfcRelContainedInSpatialStructure.
    for relation in model.by_type("IfcRelContainedInSpatialStructure"):
        add_spaces(relation.RelatingStructure, relation.RelatedElements)
    for relation in model.by_type("IfcRelAggregates"):
        add_spaces(relation.RelatingObject, relation.RelatedObjects)
    return result


def _expected_blocks(study: dict[str, Any]) -> dict[str, dict[str, Any]]:
    blocks: dict[str, dict[str, Any]] = {}
    offsets = study.get("plan_frame_offsets_ft", {})
    for level, rooms in study.get("plans", {}).items():
        offset = offsets.get(level, [0.0, 0.0])
        for room in rooms:
            identifier = str(room.get("id", "")).strip()
            if not identifier or identifier in blocks:
                continue
            blocks[identifier] = {
                "name": str(room.get("name", "")),
                "level_key": level,
                "area_sf": round(float(room["w"]) * float(room["d"]), 2),
                "plan_bounds_ft": {
                    "min_x": float(room["x"]) + float(offset[0]),
                    "min_y": float(room["y"]) + float(offset[1]),
                    "max_x": float(room["x"]) + float(offset[0]) + float(room["w"]),
                    "max_y": float(room["y"]) + float(offset[1]) + float(room["d"]),
                },
            }
    return blocks


def _space_plan_bounds_ft(space: Any, settings: Any) -> dict[str, float] | None:
    """Return world-coordinate XY bounds; IfcOpenShell geometry vertices use SI metres."""
    try:
        shape = ifcopenshell.geom.create_shape(settings, space)
        vertices = shape.geometry.verts
    except Exception:
        return None
    if not vertices or len(vertices) < 6 or len(vertices) % 3:
        return None
    scale = FT_PER_METRE
    xs = [float(value) * scale for value in vertices[0::3]]
    ys = [float(value) * scale for value in vertices[1::3]]
    if not all(math.isfinite(value) for value in xs + ys):
        return None
    return {"min_x": min(xs), "min_y": min(ys), "max_x": max(xs), "max_y": max(ys)}


def validate(run_dir: Path, source_study: Path, report_path: Path | None = None) -> dict[str, Any]:
    run_dir = run_dir.resolve()
    source_study = source_study.resolve()
    report_path = (report_path or run_dir / "ifc-validation.json").resolve()
    checks: dict[str, bool] = {}
    observations: dict[str, Any] = {}
    errors: list[str] = []
    limitations = [
        "This is a room-boundary study, not a coordinated building model.",
        "Walls, doors, floor solids, native stairs, guards, structure and a lift product are intentionally absent.",
        "Room area checks validate the serialized study geometry only; room-program allowances remain preliminary.",
        "Passing IFC/schema checks do not establish code compliance, accessibility, structural safety or construction readiness.",
    ]
    study_path = run_dir / "study.json"
    manifest_path = run_dir / "study-manifest.json"
    export_result_path = run_dir / "export-result.json"
    inventory_path = run_dir / "room-inventory.csv"
    ifc_path = run_dir / "FH_Selected_D_Space_Study.ifc"

    required = {
        "run_study_present": study_path,
        "study_manifest_present": manifest_path,
        "export_result_present": export_result_path,
        "room_inventory_present": inventory_path,
        "ifc_present": ifc_path,
        "checked_in_source_present": source_study,
    }
    for name, path in required.items():
        checks[name] = path.is_file() and (path.stat().st_size > 0 if path.suffix.lower() == ".ifc" else True)
        if not checks[name]:
            errors.append(f"required file missing or empty: {path}")
    if errors:
        result = {"schema": "forever-home.selected-d-ifc-validation.v1", "status": "fail", "checks": checks, "observations": observations, "errors": errors, "limitations": limitations}
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(result, indent=2), encoding="utf-8")
        return result

    study = _json(study_path)
    source_bytes = source_study.read_bytes()
    run_study_bytes = study_path.read_bytes()
    source_hash = hashlib.sha256(source_bytes).hexdigest()
    run_study_hash = hashlib.sha256(run_study_bytes).hexdigest()
    checks["run_study_matches_checked_in_source"] = source_bytes == run_study_bytes
    observations["study_source"] = {"path": source_study.name, "sha256": source_hash, "run_copy_sha256": run_study_hash}
    if not checks["run_study_matches_checked_in_source"]:
        errors.append("retained study.json differs from the checked-in selected-D source")

    manifest = _json(manifest_path)
    checks["manifest_source_hash_matches"] = manifest.get("source_sha256") == source_hash
    if not checks["manifest_source_hash_matches"]:
        errors.append("study manifest source SHA256 differs from the checked-in selected-D source")
    model_identity = manifest.get("model_fingerprint")
    model_name = model_identity.get("file_name") if isinstance(model_identity, dict) else None
    rvt_path = run_dir / model_name if isinstance(model_name, str) and Path(model_name).name == model_name else None
    rvt_matches = bool(
        rvt_path and rvt_path.is_file()
        and model_identity.get("algorithm") == "sha256-of-saved-rvt-bytes-v1"
        and model_identity.get("bytes") == rvt_path.stat().st_size
        and model_identity.get("sha256") == _sha256(rvt_path)
    )
    checks["saved_rvt_fingerprint_matches"] = rvt_matches
    if not rvt_matches:
        errors.append("study model fingerprint does not match the retained RVT bytes")

    export_record = _json(export_result_path)
    checks["revit_ifc_export_succeeded"] = export_record.get("ifc2x3_api_result") is True
    export_model = export_record.get("model_fingerprint")
    checks["ifc_export_uses_same_rvt_fingerprint"] = bool(
        isinstance(model_identity, dict) and isinstance(export_model, dict)
        and export_model == model_identity
    )
    if not checks["revit_ifc_export_succeeded"]:
        errors.append("Revit did not report a successful IFC2X3 export")
    if not checks["ifc_export_uses_same_rvt_fingerprint"]:
        errors.append("IFC export fingerprint differs from the study RVT fingerprint")

    ifc_hash = _sha256(ifc_path)
    checks["ifc_hash_matches_export_record"] = bool(
        export_record.get("ifc_file") == ifc_path.name
        and export_record.get("ifc_bytes") == ifc_path.stat().st_size
        and export_record.get("ifc_sha256") == ifc_hash
    )
    observations["ifc_file"] = {"path": ifc_path.name, "bytes": ifc_path.stat().st_size, "sha256": ifc_hash}
    if not checks["ifc_hash_matches_export_record"]:
        errors.append("IFC byte length or SHA256 differs from Revit's export-result record")

    blocks = _expected_blocks(study)
    observations["expected_block_count"] = len(blocks)
    checks["study_has_21_unique_blocks"] = len(blocks) == 21
    if not checks["study_has_21_unique_blocks"]:
        errors.append(f"selected-D source must contain 21 unique room/circulation IDs; found {len(blocks)}")

    expected_levels = {
        "D " + str(level["id"]): float(level["elevation_ft"])
        for level in study.get("selection", {}).get("levels", [])
    }
    try:
        model = ifcopenshell.open(str(ifc_path))
        logger = ifcopenshell.validate.json_logger()
        ifcopenshell.validate.validate(model, logger)
    except Exception as exc:
        checks["ifc_parseable"] = False
        errors.append(f"IFC parse or validation raised: {exc}")
        model = None

    if model is not None:
        checks["ifc_parseable"] = True
        checks["ifc2x3_schema"] = model.schema == "IFC2X3"
        checks["ifc_schema_validation_clean"] = not logger.statements
        observations["schema"] = model.schema
        observations["schema_issue_count"] = len(logger.statements)
        if not checks["ifc2x3_schema"]:
            errors.append(f"expected IFC2X3; found {model.schema}")
        if logger.statements:
            errors.append(f"IFC schema validation returned {len(logger.statements)} issue(s)")

        unit_scale = ifcopenshell.util.unit.calculate_unit_scale(model)
        header = model.header.file_name
        observations["ifc_provenance"] = {
            "originating_system": str(header.originating_system or ""),
            "preprocessor_version": str(header.preprocessor_version or ""),
            "file_timestamp": str(header.time_stamp or ""),
        }
        storeys = model.by_type("IfcBuildingStorey")
        observed_levels = {
            str(storey.Name or ""): float(storey.Elevation or 0.0) * unit_scale * FT_PER_METRE
            for storey in storeys
        }
        observations["expected_storeys"] = [
            {"name": name, "elevation_ft": round(elevation, 4)}
            for name, elevation in sorted(expected_levels.items())
        ]
        levels_match = set(observed_levels) == set(expected_levels) and all(
            abs(observed_levels[name] - elevation) <= ELEVATION_TOLERANCE_FT
            for name, elevation in expected_levels.items()
        )
        checks["ifc_storeys_match_source"] = levels_match
        observations["storeys"] = [
            {"name": name, "elevation_ft": round(elevation, 4)}
            for name, elevation in sorted(observed_levels.items())
        ]
        if not levels_match:
            missing_storeys = sorted(set(expected_levels) - set(observed_levels))
            unexpected_storeys = sorted(set(observed_levels) - set(expected_levels))
            elevation_mismatches = sorted(
                name for name in set(expected_levels) & set(observed_levels)
                if abs(observed_levels[name] - expected_levels[name]) > ELEVATION_TOLERANCE_FT
            )
            observations["storey_mismatch"] = {
                "missing": missing_storeys,
                "unexpected": unexpected_storeys,
                "elevation_mismatches": elevation_mismatches,
            }
            errors.append(
                "IFC storeys differ from selected-D source: "
                f"missing={missing_storeys}, unexpected={unexpected_storeys}, "
                f"elevation_mismatches={elevation_mismatches}"
            )

        spaces = model.by_type("IfcSpace")
        space_ids = [_space_id(space) for space in spaces]
        space_id_set = set(space_ids)
        checks["ifc_spaces_match_source_ids"] = (
            len(spaces) == 21 and len(space_id_set) == len(space_ids) and space_id_set == set(blocks)
        )
        if not checks["ifc_spaces_match_source_ids"]:
            errors.append("IFC IfcSpace IDs are missing, duplicated or differ from the 21 source block IDs")

        containment = _space_level_names(model)
        area_errors: list[dict[str, Any]] = []
        level_errors: list[str] = []
        plan_bounds_errors: list[dict[str, Any]] = []
        body_profile_errors: list[dict[str, Any]] = []
        area_observations: list[dict[str, Any]] = []
        geometry_settings = ifcopenshell.geom.settings()
        geometry_settings.set(geometry_settings.USE_WORLD_COORDS, True)
        for space in spaces:
            identifier = _space_id(space)
            expected = blocks.get(identifier)
            area = _space_area(space, unit_scale)
            body_profile_area = _space_body_profile_area(space, unit_scale)
            bounds = _space_plan_bounds_ft(space, geometry_settings)
            observed_level = containment.get(identifier)
            if observed_level is None:
                psets = ifcopenshell.util.element.get_psets(space)
                observed_level = str(psets.get("Constraints", {}).get("Level", ""))
            expected_level = "D " + PLAN_LEVEL_NAMES.get(expected["level_key"], "") if expected else ""
            if expected is None or area is None or abs(area - expected["area_sf"]) > AREA_TOLERANCE_SQFT:
                area_errors.append({"id": identifier, "expected_area_sf": expected["area_sf"] if expected else None, "ifc_area": area})
            if expected is None or body_profile_area is None or abs(body_profile_area - expected["area_sf"]) > AREA_TOLERANCE_SQFT:
                body_profile_errors.append({"id": identifier, "expected_area_sf": expected["area_sf"] if expected else None, "body_profile_area_sf": body_profile_area})
            if observed_level != expected_level:
                level_errors.append(identifier or "<unnumbered>")
            expected_bounds = expected.get("plan_bounds_ft") if expected else None
            if bounds is None or expected_bounds is None or any(
                abs(bounds[key] - expected_bounds[key]) > PLAN_BOUNDS_TOLERANCE_FT
                for key in ("min_x", "min_y", "max_x", "max_y")
            ):
                plan_bounds_errors.append({"id": identifier, "expected_ft": expected_bounds, "observed_ft": bounds})
            area_observations.append({"id": identifier, "expected_area_sf": expected["area_sf"] if expected else None, "ifc_area": area, "ifc_body_profile_area_sf": body_profile_area, "level": observed_level, "expected_plan_bounds_ft": expected_bounds, "ifc_plan_bounds_ft": bounds})
        checks["ifc_space_areas_match_source"] = not area_errors
        checks["ifc_space_levels_match_source"] = not level_errors
        checks["ifc_space_plan_bounds_match_source"] = not plan_bounds_errors
        checks["ifc_space_body_profile_areas_match_source"] = not body_profile_errors
        observations["spaces"] = {"count": len(spaces), "areas_and_levels": sorted(area_observations, key=lambda item: item["id"])}
        if area_errors:
            errors.append(f"{len(area_errors)} IFC space area(s) differ from source by more than {AREA_TOLERANCE_SQFT:g} sf or are missing")
            observations["space_area_errors"] = area_errors
        if level_errors:
            errors.append("IFC spaces are not assigned to their expected D storeys: " + ", ".join(level_errors))
        if plan_bounds_errors:
            errors.append(f"{len(plan_bounds_errors)} IFC space plan footprint(s) differ from selected-D coordinates by more than {PLAN_BOUNDS_TOLERANCE_FT:g} ft or have undecodable geometry")
            observations["space_plan_bounds_errors"] = plan_bounds_errors
        if body_profile_errors:
            errors.append(f"{len(body_profile_errors)} IFC space body profile area(s) differ from selected-D source by more than {AREA_TOLERANCE_SQFT:g} sf or use unsupported geometry")
            observations["space_body_profile_area_errors"] = body_profile_errors

        physical_counts = {name: len(model.by_type(name)) for name in EXPECTED_EMPTY_CLASSES}
        checks["construction_categories_remain_empty"] = all(count == 0 for count in physical_counts.values())
        observations["intentionally_empty_construction_categories"] = physical_counts
        if not checks["construction_categories_remain_empty"]:
            errors.append("space-only D export contains an unapproved wall/slab/stair/door/window category")

    with inventory_path.open(encoding="utf-8-sig", newline="") as stream:
        inventory = list(csv.DictReader(stream))
    inventory_ids = [str(row.get("id", "")).strip() for row in inventory]
    inventory_matches = len(inventory) == 21 and len(set(inventory_ids)) == 21 and set(inventory_ids) == set(blocks)
    checks["revit_room_inventory_ids_match_source"] = inventory_matches
    if not inventory_matches:
        errors.append("Revit room-inventory.csv IDs differ from the 21 source block IDs")
    inventory_errors: list[str] = []
    for row in inventory:
        identifier = str(row.get("id", "")).strip()
        expected = blocks.get(identifier)
        try:
            expected_area = float(row["expected_area_sf"])
            revit_area = float(row["revit_area_sf"])
            if expected is None or abs(expected_area - expected["area_sf"]) > AREA_TOLERANCE_SQFT or abs(revit_area - expected_area) > AREA_TOLERANCE_SQFT:
                inventory_errors.append(identifier)
        except (KeyError, TypeError, ValueError):
            inventory_errors.append(identifier or "<missing ID>")
    checks["revit_room_inventory_areas_match_source"] = not inventory_errors
    observations["revit_room_inventory"] = {"row_count": len(inventory), "invalid_rows": inventory_errors}
    if inventory_errors:
        errors.append("Revit room-inventory.csv contains missing or mismatched room areas")

    program_review = run_dir.parent.parent.parent.parent / "Architecture" / "Selected_Design_Iteration_2026-10-27" / "program-area-review.csv"
    if program_review.is_file():
        with program_review.open(encoding="utf-8-sig", newline="") as stream:
            variances = [row for row in csv.DictReader(stream) if row.get("status") == "above study reference" or row.get("status") == "below study reference"]
        observations["documented_room_program_variances"] = variances

    result = {
        "schema": "forever-home.selected-d-ifc-validation.v1",
        "status": "pass" if all(checks.values()) and not errors else "fail",
        "checks": checks,
        "observations": observations,
        "errors": errors,
        "limitations": limitations,
    }
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(result, indent=2), encoding="utf-8")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run_dir", type=Path, help="Timestamped .local/revit-pilot/selected-d run folder")
    parser.add_argument("--source-study", type=Path, help="Checked-in source study.json; defaults to this repository's selected-D study")
    parser.add_argument("--report", type=Path, help="Report path; defaults to run_dir/ifc-validation.json")
    args = parser.parse_args()
    repository = Path(__file__).resolve().parents[2]
    source = args.source_study or repository / "Architecture" / "Selected_Design_Iteration_2026-10-27" / "study.json"
    result = validate(args.run_dir, source, args.report)
    print(json.dumps({"status": result["status"], "checks": result["checks"], "errors": result["errors"]}, indent=2))
    return 0 if result["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
