"""Independently validate a Compact-Core IFC2X3 export against its study manifest.

This validates serialized IFC data and physical-product geometry. It does not open
Revit, change a model, or certify architecture, engineering, accessibility, or code.
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
import ifcopenshell.validate
import numpy as np

from validate_compact_manifest import validate as validate_manifest

EXPECTED_LEVELS = {
    "C Lower -5 ft": -5.0,
    "C Main 0 ft": 0.0,
    "C Upper +5 ft": 5.0,
}
EXPECTED_CLASS_COUNTS = {
    "IfcWall": 78,
    "IfcSlab": 3,
    "IfcStair": 2,
    "IfcDoor": 5,
}
EXPECTED_FLOOR_AREAS = {
    "FH-C-FLOOR-LOWER": 2752.0,
    "FH-C-FLOOR-MAIN": 1410.0,
    "FH-C-FLOOR-UPPER": 1152.0,
}
# Reference areas are intentionally advisory: the room program calls these
# preliminary allowances, and Compact-Core C has not been selected or frozen.
# Fixed C targets come from the proposed implementation brief, not an owner
# approval. Variance is reported for review and never changes generated geometry.
ROOM_AREA_REFERENCES = {
    "U-01": (150.0, 170.0, "preliminary room-program allowance", "Requirements/Room_Program.md"),
    "U-02": (110.0, 160.0, "preliminary room-program allowance", "Requirements/Room_Program.md"),
    "U-03": (120.0, 150.0, "preliminary room-program allowance", "Requirements/Room_Program.md"),
    "U-04": (100.0, 120.0, "preliminary room-program allowance", "Requirements/Room_Program.md"),
    "U-05": (90.0, 90.0, "schematic room-program size", "Requirements/Room_Program.md"),
    "U-06": (120.0, 120.0, "schematic room-program size", "Requirements/Room_Program.md"),
    "M-01": (180.0, 220.0, "preliminary room-program allowance", "Requirements/Room_Program.md"),
    "M-02": (150.0, 185.0, "preliminary room-program allowance", "Requirements/Room_Program.md"),
    "M-03": (90.0, 120.0, "preliminary room-program allowance", "Requirements/Room_Program.md"),
    "L-02": (110.0, 110.0, "proposed C test target (11 x 10 ft)", "Project/Revit_Compact_Core_Brief_2026-10-25.md"),
    "M-06": (90.0, 90.0, "proposed C bath target (9 x 10 ft; owner decision open)", "Project/Revit_Compact_Core_Brief_2026-10-25.md"),
}
AREA_TOLERANCE_SQFT = 0.02
ELEVATION_TOLERANCE_FT = 0.01
FT_PER_METRE = 1.0 / 0.3048


def _identity(product: Any) -> dict[str, Any]:
    return ifcopenshell.util.element.get_psets(product).get("Identity Data", {})


def _dimensions(product: Any) -> dict[str, Any]:
    return ifcopenshell.util.element.get_psets(product).get("Dimensions", {})


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _room_id(product: Any) -> str:
    identity = _identity(product)
    return str(identity.get("Number") or product.Name or "").strip()


def _geometry_inventory(model: Any) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    settings = ifcopenshell.geom.settings()
    settings.set(settings.USE_WORLD_COORDS, True)
    decoded = 0
    annotation_exceptions: list[dict[str, Any]] = []
    failures: list[dict[str, Any]] = []
    represented = [p for p in model.by_type("IfcProduct") if p.Representation]
    for product in represented:
        try:
            shape = ifcopenshell.geom.create_shape(settings, product)
            vertices = np.asarray(shape.geometry.verts, dtype=float).reshape(-1, 3)
            if not len(vertices) or not np.isfinite(vertices).all():
                raise ValueError("geometry returned no finite vertices")
            decoded += 1
        except Exception as exc:  # IfcOpenShell reports product-specific geometry failures here.
            issue = {"class": product.is_a(), "name": product.Name, "guid": product.GlobalId, "error": str(exc)}
            (annotation_exceptions if product.is_a("IfcAnnotation") else failures).append(issue)
    return {
        "represented_product_count": len(represented),
        "decoded_product_count": decoded,
        "physical_product_decode_failure_count": len(failures),
        "annotation_decode_exception_count": len(annotation_exceptions),
        "annotation_decode_exceptions": annotation_exceptions,
    }, failures


def _stair_gap(model: Any) -> dict[str, Any]:
    """Measure the known upper flight/slab plan gap from decoded world geometry.

    IfcOpenShell returns world geometry in metres for this IFC; report in feet.
    A bounding-box result is a coordination flag only, never proof of a landing.
    """
    settings = ifcopenshell.geom.settings()
    settings.set(settings.USE_WORLD_COORDS, True)
    upper_slabs = [
        p for p in model.by_type("IfcSlab")
        if "FH-C-FLOOR-UPPER" in str(_identity(p).get("Comments", ""))
    ]
    if len(upper_slabs) != 1:
        return {"status": "not measured", "reason": "expected one upper floor marker"}
    try:
        slab_shape = ifcopenshell.geom.create_shape(settings, upper_slabs[0])
        slab_vertices = np.asarray(slab_shape.geometry.verts, dtype=float).reshape(-1, 3)
        slab_min = slab_vertices.min(axis=0)
        slab_zmin_ft = float(slab_min[2] * FT_PER_METRE)
        flights = []
        for flight in model.by_type("IfcStairFlight"):
            shape = ifcopenshell.geom.create_shape(settings, flight)
            vertices = np.asarray(shape.geometry.verts, dtype=float).reshape(-1, 3)
            if len(vertices) and float(vertices[:, 2].max() * FT_PER_METRE) > 0:
                flights.append((flight, vertices))
        if not flights:
            return {"status": "not measured", "reason": "no upper stair flight geometry decoded"}
        flight, vertices = max(flights, key=lambda item: item[1][:, 2].max())
        stair_y_max_ft = float(vertices[:, 1].max() * FT_PER_METRE)
        slab_y_min_ft = float(slab_min[1] * FT_PER_METRE)
        gap_ft = slab_y_min_ft - stair_y_max_ft
        status = "open gap" if gap_ft > 0.01 else "bounding boxes touch or overlap; landing still requires native review"
        return {
            "status": status,
            "flight_name": flight.Name,
            "upper_slab_name": upper_slabs[0].Name,
            "stair_end_y_ft": round(stair_y_max_ft, 4),
            "upper_slab_start_y_ft": round(slab_y_min_ft, 4),
            "plan_gap_ft": round(gap_ft, 4),
            "limitation": "Bounding boxes do not prove a landing, clear headroom, or solid intersection.",
        }
    except Exception as exc:
        return {"status": "not measured", "reason": str(exc)}


def validate(export_dir: Path, study_dir: Path) -> dict[str, Any]:
    export_dir = export_dir.resolve()
    study_dir = study_dir.resolve()
    checks: dict[str, bool] = {}
    observations: dict[str, Any] = {}
    errors: list[str] = []
    open_findings: list[dict[str, Any]] = []
    manifest_path = study_dir / "study-manifest.json"
    export_results_path = export_dir / "export-results.json"
    ifc_path = export_dir / "FH_Compact_Core_Study.ifc"
    csv_path = export_dir / "FH_Compact_Core_Room_Inventory.csv"

    manifest_errors = validate_manifest(manifest_path) if manifest_path.is_file() else ["study manifest missing"]
    checks["study_manifest_valid"] = not manifest_errors
    if manifest_errors:
        errors.extend(f"study manifest: {item}" for item in manifest_errors)
    study = json.loads(manifest_path.read_text(encoding="utf-8")) if manifest_path.is_file() else {}
    expected_rooms = set(study.get("rooms", []))

    export_results = json.loads(export_results_path.read_text(encoding="utf-8")) if export_results_path.is_file() else {}
    ifc_export = export_results.get("exports", {}).get("ifc2x3", {})
    export_record = next((item for item in ifc_export.get("files", []) if item.get("file") == ifc_path.name), {})
    checks["export_recorded_success"] = bool(
        export_results.get("schema") == "forever-home.revit-export-results.v1"
        and export_results.get("document_title") == "FH_Compact_Core_Study"
        and ifc_export.get("success") is True
        and export_record
    )
    if not checks["export_recorded_success"]:
        errors.append("IFC export result is missing, failed, or names a different active document")

    checks["ifc_file_present"] = ifc_path.is_file() and ifc_path.stat().st_size > 0
    if not checks["ifc_file_present"]:
        errors.append("nonempty IFC export missing")
        return _result(export_dir, study_dir, checks, observations, errors)
    digest = _sha256(ifc_path)
    observations["ifc_file"] = {"path": ifc_path.name, "bytes": ifc_path.stat().st_size, "sha256": digest}
    checks["ifc_hash_matches_export_record"] = bool(
        export_record and export_record.get("bytes") == ifc_path.stat().st_size and export_record.get("sha256") == digest
    )
    if not checks["ifc_hash_matches_export_record"]:
        errors.append("IFC size or SHA256 does not match export-results.json")

    try:
        model = ifcopenshell.open(str(ifc_path))
        logger = ifcopenshell.validate.json_logger()
        ifcopenshell.validate.validate(model, logger)
    except Exception as exc:
        checks["ifc_parseable"] = False
        errors.append(f"IFC parse/validation failed: {exc}")
        return _result(export_dir, study_dir, checks, observations, errors)
    checks["ifc_parseable"] = True
    checks["ifc2x3_schema"] = model.schema == "IFC2X3"
    checks["ifc_schema_validation_clean"] = not logger.statements
    observations["schema"] = model.schema
    observations["schema_issue_count"] = len(logger.statements)
    if not checks["ifc2x3_schema"]:
        errors.append(f"unexpected IFC schema: {model.schema}")
    if logger.statements:
        errors.extend(f"IFC schema: {item.get('message', item)}" for item in logger.statements)

    storeys = model.by_type("IfcBuildingStorey")
    storey_map = {str(item.Name): item for item in storeys}
    checks["storeys_match_expected_levels"] = (
        set(storey_map) == set(EXPECTED_LEVELS)
        and all(abs(float(storey_map[name].Elevation) - elevation) <= ELEVATION_TOLERANCE_FT for name, elevation in EXPECTED_LEVELS.items())
    )
    observations["storeys"] = [{"name": item.Name, "elevation_ft": item.Elevation} for item in storeys]
    if not checks["storeys_match_expected_levels"]:
        errors.append("IFC storey names/elevations do not match the three documented C levels")

    spaces = model.by_type("IfcSpace")
    space_ids = [_room_id(item) for item in spaces]
    space_id_set = set(space_ids)
    area_errors: list[str] = []
    level_errors: list[str] = []
    for space in spaces:
        identifier = _room_id(space)
        area = _dimensions(space).get("Area")
        if area is None or not math.isfinite(float(area)) or float(area) <= 0:
            area_errors.append(identifier or "<unnumbered>")
        level = str(ifcopenshell.util.element.get_psets(space).get("Constraints", {}).get("Level", ""))
        if level not in EXPECTED_LEVELS:
            level_errors.append(identifier or "<unnumbered>")
    checks["spaces_match_manifest_ids"] = len(spaces) == len(expected_rooms) and len(space_ids) == len(space_id_set) and space_id_set == expected_rooms
    checks["spaces_have_positive_areas"] = not area_errors
    checks["spaces_use_expected_levels"] = not level_errors
    observations["space_count"] = len(spaces)
    observations["space_ids"] = sorted(space_id_set)
    observations["spaces_without_positive_area"] = area_errors
    observations["spaces_with_unexpected_level"] = level_errors
    if not checks["spaces_match_manifest_ids"]:
        errors.append("IFC IfcSpace identifiers do not match the study manifest exactly")
    if area_errors:
        errors.append("one or more IFC spaces have no positive area")
    if level_errors:
        errors.append("one or more IFC spaces have an unexpected level")

    area_comparisons = []
    for space in spaces:
        identifier = _room_id(space)
        reference = ROOM_AREA_REFERENCES.get(identifier)
        area = _dimensions(space).get("Area")
        if reference is None or area is None:
            continue
        low, high, reference_type, source = reference
        observed = float(area)
        variance = "within reference" if low - AREA_TOLERANCE_SQFT <= observed <= high + AREA_TOLERANCE_SQFT else "below reference" if observed < low else "above reference"
        item = {
            "room_id": identifier,
            "ifc_area_sqft": round(observed, 2),
            "reference_min_sqft": low,
            "reference_max_sqft": high,
            "reference_type": reference_type,
            "source": source,
            "status": variance,
        }
        area_comparisons.append(item)
        if variance != "within reference":
            open_findings.append({
                "issue": "BIM-AREA-" + identifier,
                "severity": "review before geometry freeze",
                "detail": f"{identifier} is {item['ifc_area_sqft']:.2f} sq ft, {variance} of {low:g}–{high:g} sq ft reference.",
                "evidence": item,
            })
    observations["room_area_program_comparison"] = {
        "source": "REQUIREMENTS.md / Room_Program.md and the proposed Compact-Core C brief",
        "reference_count": len(ROOM_AREA_REFERENCES),
        "compared_count": len(area_comparisons),
        "outside_reference_count": sum(item["status"] != "within reference" for item in area_comparisons),
        "areas_are_provisional": True,
        "results": sorted(area_comparisons, key=lambda item: item["room_id"]),
    }
    checks["all_documented_room_areas_compared"] = len(area_comparisons) == len(ROOM_AREA_REFERENCES)
    if not checks["all_documented_room_areas_compared"]:
        errors.append("one or more rooms with documented area references were not compared")

    counts = {class_name: len(model.by_type(class_name)) for class_name in ["IfcSpace", *EXPECTED_CLASS_COUNTS]}
    observations["ifc_class_counts"] = counts
    checks["major_class_counts_match_baseline"] = all(counts[name] == expected for name, expected in EXPECTED_CLASS_COUNTS.items()) and counts["IfcSpace"] == len(expected_rooms)
    if not checks["major_class_counts_match_baseline"]:
        errors.append("IFC major product counts differ from the current documented generator baseline")

    slab_map: dict[str, Any] = {}
    for slab in model.by_type("IfcSlab"):
        comments = str(_identity(slab).get("Comments", ""))
        marker = next((key for key in EXPECTED_FLOOR_AREAS if key in comments), None)
        if marker:
            slab_map[marker] = slab
    floor_errors: list[str] = []
    for marker, expected_area in EXPECTED_FLOOR_AREAS.items():
        slab = slab_map.get(marker)
        area = _dimensions(slab).get("Area") if slab else None
        if area is None or abs(float(area) - expected_area) > AREA_TOLERANCE_SQFT:
            floor_errors.append(marker)
    checks["floor_markers_and_areas_match"] = not floor_errors and set(slab_map) == set(EXPECTED_FLOOR_AREAS)
    observations["floor_profile_areas_sqft"] = {
        marker: _dimensions(slab_map[marker]).get("Area") for marker in sorted(slab_map)
    }
    if floor_errors:
        errors.append("IFC floor markers or profile areas differ from the documented targets: " + ", ".join(floor_errors))

    csv_observations: dict[str, Any] = {"present": csv_path.is_file(), "row_count": 0, "ids_match_ifc": False, "areas_match_ifc": False}
    csv_errors: list[str] = []
    if csv_path.is_file():
        with csv_path.open(encoding="utf-8-sig", newline="") as stream:
            rows = list(csv.DictReader(stream))
        csv_ids = [row.get("number", "").strip() for row in rows]
        csv_observations["row_count"] = len(rows)
        csv_observations["ids_match_ifc"] = len(rows) == len(expected_rooms) and len(set(csv_ids)) == len(csv_ids) and set(csv_ids) == space_id_set
        space_by_id = {_room_id(space): space for space in spaces}
        areas_match = True
        for row in rows:
            identifier = row.get("number", "").strip()
            try:
                csv_area = float(row.get("area_sqft", ""))
                if identifier not in space_by_id or abs(csv_area - float(_dimensions(space_by_id[identifier])["Area"])) > AREA_TOLERANCE_SQFT:
                    areas_match = False
            except (KeyError, ValueError, TypeError):
                areas_match = False
        csv_observations["areas_match_ifc"] = areas_match
        if not csv_observations["ids_match_ifc"]:
            csv_errors.append("room CSV IDs do not match IFC spaces")
        if not areas_match:
            csv_errors.append("room CSV areas do not match IFC space areas")
    else:
        csv_errors.append("room inventory CSV missing")
    observations["room_csv"] = csv_observations
    checks["room_csv_matches_ifc"] = not csv_errors
    if csv_errors:
        errors.extend(csv_errors)

    geometry, geometry_failures = _geometry_inventory(model)
    observations["geometry"] = geometry
    checks["all_represented_physical_geometry_decodes"] = not geometry_failures
    if geometry_failures:
        observations["physical_geometry_failures"] = geometry_failures
        errors.append(f"{len(geometry_failures)} represented non-annotation product(s) failed geometry decoding")

    gap = _stair_gap(model)
    observations["upper_stair_to_floor"] = gap
    if gap.get("status") == "open gap":
        open_findings.append({
            "issue": "CO-001",
            "severity": "open coordination issue",
            "detail": f"Upper stair bounding box ends {gap['plan_gap_ft']:.4f} ft before the upper slab in plan.",
            "evidence": gap,
        })
    elif gap.get("status") == "not measured":
        open_findings.append({"issue": "CO-001", "severity": "not measured", "detail": gap.get("reason")})
    observations["annotation_decode_exceptions_are_informational"] = True
    return _result(export_dir, study_dir, checks, observations, errors, open_findings)


def _result(
    export_dir: Path,
    study_dir: Path,
    checks: dict[str, bool],
    observations: dict[str, Any],
    errors: list[str],
    open_findings: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    hard_pass = bool(checks) and all(checks.values()) and not errors
    return {
        "schema": "forever-home.compact-ifc-validation.v1",
        "status": "PASS with open coordination findings" if hard_pass and open_findings else "PASS" if hard_pass else "FAIL",
        "passed": hard_pass,
        "inputs": {
            "export_dir": export_dir.name,
            "study_dir": study_dir.name,
            "lineage_basis": "content validated against the supplied study manifest; Revit export record identifies the C study title",
        },
        "checks": checks,
        "observations": observations,
        "errors": errors,
        "open_findings": open_findings or [],
        "limitations": [
            "IFC validity and decoded geometry do not prove architectural coordination or design intent.",
            "Stair/floor comparison uses bounding boxes; a landing, headroom, solid fit, and accessible route require native review.",
            "IfcAnnotation geometry decode exceptions are reported separately from represented physical-product failures.",
            "No structural, MEP, accessibility, fire/life-safety, code, permit, or construction approval is claimed.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("export_dir", type=Path, help="timestamped Revit export directory")
    parser.add_argument("study_dir", type=Path, help="matching generated Compact-Core study directory")
    parser.add_argument("--report", type=Path, help="optional JSON report path")
    args = parser.parse_args()
    report = validate(args.export_dir, args.study_dir)
    payload = json.dumps(report, indent=2) + "\n"
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(payload, encoding="utf-8")
    print(payload, end="")
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
