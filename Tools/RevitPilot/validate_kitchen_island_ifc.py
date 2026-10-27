"""Validate a Revit furnishing-study IFC against the selected-D kitchen brief.

This is an IFC inspection gate, not a geometry authoring or design tool. It
checks saved-model evidence identity, IFC2X3 serialization, room/level inventory,
and a named island's exported bounds against the current selected-D sources.
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
import ifcopenshell.util.element
import ifcopenshell.util.unit
import ifcopenshell.validate
import numpy as np

# Architecture/Kitchen_Dining_Porch_Specs.md: island counter height is 36 in AFF.
NOMINAL_COUNTER_HEIGHT_FT = 3.0
DOCUMENTED_BASE_CABINET_HEIGHT_FT = 34.5 / 12.0
DOCUMENTED_COUNTERTOP_THICKNESS_FT = 1.25 / 12.0
DOCUMENTED_COUNTERTOP_TOP_FT = DOCUMENTED_BASE_CABINET_HEIGHT_FT + DOCUMENTED_COUNTERTOP_THICKNESS_FT
# Numeric tolerance is solely for IFC unit conversion/serialization noise; it
# is not a design tolerance or a construction allowance.
SERIALIZATION_TOLERANCE_FT = 0.01
FT_PER_METRE = 1.0 / 0.3048


def _json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def _space_id(space: Any) -> str:
    identity = ifcopenshell.util.element.get_psets(space).get("Identity Data", {})
    return str(identity.get("Number") or space.Name or "").strip()


def _expected_island(study: dict[str, Any]) -> dict[str, float]:
    selection = study["selection"]
    kitchen = selection["kitchen"]
    room = next(block for block in study["plans"]["main"] if block["id"] == "M-02")
    offset_x, offset_y = study["plan_frame_offsets_ft"]["main"]
    local_x, local_y = kitchen["island_origin_local_ft"]
    length, depth = kitchen["island_ft"]
    return {
        "x_min_ft": float(room["x"] + offset_x + local_x),
        "x_max_ft": float(room["x"] + offset_x + local_x + length),
        "y_min_ft": float(room["y"] + offset_y + local_y),
        "y_max_ft": float(room["y"] + offset_y + local_y + depth),
        "z_min_ft": float(next(level["elevation_ft"] for level in selection["levels"] if level["id"] == "Main FF")),
        "z_max_ft": float(next(level["elevation_ft"] for level in selection["levels"] if level["id"] == "Main FF"))
        + DOCUMENTED_BASE_CABINET_HEIGHT_FT,
        "length_ft": float(length),
        "depth_ft": float(depth),
        "height_ft": DOCUMENTED_BASE_CABINET_HEIGHT_FT,
    }


def _expected_countertop(study: dict[str, Any]) -> dict[str, float]:
    island = _expected_island(study)
    base_elevation = island["z_min_ft"]
    return {
        "x_min_ft": island["x_min_ft"],
        "x_max_ft": island["x_max_ft"],
        "y_min_ft": island["y_min_ft"],
        "y_max_ft": island["y_max_ft"],
        "z_min_ft": base_elevation + DOCUMENTED_BASE_CABINET_HEIGHT_FT,
        "z_max_ft": base_elevation + DOCUMENTED_COUNTERTOP_TOP_FT,
        "length_ft": island["length_ft"],
        "depth_ft": island["depth_ft"],
        "height_ft": DOCUMENTED_COUNTERTOP_THICKNESS_FT,
    }


def _product_bounds_ft(product: Any, settings: Any) -> dict[str, float]:
    shape = ifcopenshell.geom.create_shape(settings, product)
    vertices = np.asarray(shape.geometry.verts, dtype=float).reshape(-1, 3)
    if not len(vertices) or not np.isfinite(vertices).all():
        raise ValueError("product geometry has no finite vertices")
    low = vertices.min(axis=0) * FT_PER_METRE
    high = vertices.max(axis=0) * FT_PER_METRE
    return {
        "x_min_ft": float(low[0]),
        "x_max_ft": float(high[0]),
        "y_min_ft": float(low[1]),
        "y_max_ft": float(high[1]),
        "z_min_ft": float(low[2]),
        "z_max_ft": float(high[2]),
        "length_ft": float(high[0] - low[0]),
        "depth_ft": float(high[1] - low[1]),
        "height_ft": float(high[2] - low[2]),
    }


def _expected_module_bounds(study: dict[str, Any], module_count: int) -> list[dict[str, float]]:
    target = _expected_island(study)
    if module_count == 1:
        return [target]
    if module_count != 4:
        raise ValueError("Only a single island family or the documented four-module 4 x 2 ft layout is supported.")
    x_mid = (target["x_min_ft"] + target["x_max_ft"]) / 2
    y_mid = (target["y_min_ft"] + target["y_max_ft"]) / 2
    rows = []
    for x_min, x_max in ((target["x_min_ft"], x_mid), (x_mid, target["x_max_ft"])):
        for y_min, y_max in ((target["y_min_ft"], y_mid), (y_mid, target["y_max_ft"])):
            rows.append({
                "x_min_ft": x_min,
                "x_max_ft": x_max,
                "y_min_ft": y_min,
                "y_max_ft": y_max,
                "z_min_ft": target["z_min_ft"],
                "z_max_ft": target["z_max_ft"],
                "length_ft": x_max - x_min,
                "depth_ft": y_max - y_min,
                "height_ft": target["z_max_ft"] - target["z_min_ft"],
            })
    return rows


def _combine_bounds(items: list[dict[str, float]]) -> dict[str, float]:
    bounds = {
        key: (min if key.endswith("min_ft") else max)(item[key] for item in items)
        for key in ("x_min_ft", "x_max_ft", "y_min_ft", "y_max_ft", "z_min_ft", "z_max_ft")
    }
    bounds["length_ft"] = bounds["x_max_ft"] - bounds["x_min_ft"]
    bounds["depth_ft"] = bounds["y_max_ft"] - bounds["y_min_ft"]
    bounds["height_ft"] = bounds["z_max_ft"] - bounds["z_min_ft"]
    return bounds


def _bounds_match(actual: dict[str, float] | None, expected: dict[str, float]) -> bool:
    return actual is not None and all(
        math.isfinite(actual[key]) and abs(actual[key] - value) <= SERIALIZATION_TOLERANCE_FT
        for key, value in expected.items()
    )


def validate(
    export_dir: Path,
    audit_dir: Path,
    study_path: Path,
    family_match: str,
    expected_module_count: int,
    countertop_match: str,
) -> dict[str, Any]:
    export_dir, audit_dir, study_path = export_dir.resolve(), audit_dir.resolve(), study_path.resolve()
    export = _json(export_dir / "export-results.json")
    audit = _json(audit_dir / "audit.json")
    study = _json(study_path)
    checks: dict[str, bool] = {}
    observations: dict[str, Any] = {}
    errors: list[str] = []

    audit_fp = audit.get("model_fingerprint", {})
    export_fp = export.get("model_fingerprint", {})
    checks["export completed"] = export.get("status", "").startswith("executed; all configured exports")
    checks["audit and export identify the same saved RVT"] = bool(audit_fp.get("sha256")) and audit_fp == export_fp
    if not checks["export completed"]:
        errors.append("Revit export report does not record successful configured exports.")
    if not checks["audit and export identify the same saved RVT"]:
        errors.append("Read-only audit and IFC export do not share an exact saved-RVT fingerprint.")

    ifc_entries = export.get("exports", {}).get("ifc2x3", {}).get("files", [])
    if len(ifc_entries) != 1:
        errors.append(f"Expected one IFC file entry, found {len(ifc_entries)}.")
        checks["IFC hash matches Revit export record"] = False
        checks["IFC2X3 schema and validation"] = False
        checks["room and storey inventory"] = False
        checks["island geometry decoded"] = False
        checks["island bounds match documented geometry"] = False
        observations["ifc"] = {"status": "unavailable"}
    else:
        entry = ifc_entries[0]
        ifc_path = export_dir / entry["file"]
        ifc_hash = _sha256(ifc_path) if ifc_path.is_file() else None
        checks["IFC hash matches Revit export record"] = bool(ifc_hash) and ifc_hash == entry.get("sha256")
        if not checks["IFC hash matches Revit export record"]:
            errors.append("IFC file is missing or its SHA256 differs from the Revit export report.")

        model = ifcopenshell.open(str(ifc_path))
        logger = ifcopenshell.validate.json_logger()
        ifcopenshell.validate.validate(model, logger)
        checks["IFC2X3 schema and validation"] = model.schema.upper() == "IFC2X3" and not logger.statements
        if not checks["IFC2X3 schema and validation"]:
            errors.append(f"IFC schema validation produced {len(logger.statements)} issue(s) or an unexpected schema.")

        expected_ids = {
            str(block["id"])
            for floor in study["plans"].values()
            for block in floor
            if block.get("kind") in {"room", "circulation"}
        }
        actual_ids = {_space_id(space) for space in model.by_type("IfcSpace")}
        level_rows = audit.get("levels", [])
        expected_levels = {str(level["name"]): float(level["elevation_ft"]) for level in level_rows}
        scale = ifcopenshell.util.unit.calculate_unit_scale(model)
        actual_levels = {
            str(level.Name or ""): float(level.Elevation or 0.0) * scale * FT_PER_METRE
            for level in model.by_type("IfcBuildingStorey")
        }
        levels_match = set(actual_levels) == set(expected_levels) and all(
            abs(actual_levels[name] - elevation) <= SERIALIZATION_TOLERANCE_FT
            for name, elevation in expected_levels.items()
        )
        spaces_match = actual_ids == expected_ids
        checks["room and storey inventory"] = spaces_match and levels_match
        if not checks["room and storey inventory"]:
            errors.append("IFC space IDs or storeys differ from the selected-D source and matching Revit audit.")

        settings = ifcopenshell.geom.settings()
        settings.set(settings.USE_WORLD_COORDS, True)
        all_products = [p for p in model.by_type("IfcProduct") if getattr(p, "Representation", None)]
        geometry_errors: list[dict[str, str]] = []
        annotation_errors: list[dict[str, str]] = []
        for product in all_products:
            try:
                shape = ifcopenshell.geom.create_shape(settings, product)
                vertices = np.asarray(shape.geometry.verts, dtype=float).reshape(-1, 3)
                if not len(vertices) or not np.isfinite(vertices).all():
                    raise ValueError("no finite geometry vertices")
            except Exception as exc:
                issue = {"class": product.is_a(), "name": str(product.Name or ""), "error": str(exc)}
                (annotation_errors if product.is_a("IfcAnnotation") else geometry_errors).append(issue)
        checks["all non-annotation IFC product geometry decodes"] = not geometry_errors
        if geometry_errors:
            errors.append(f"{len(geometry_errors)} non-annotation IFC product(s) failed geometry decoding.")

        found = [
            product for product in model.by_type("IfcProduct")
            if family_match.casefold() in str(product.Name or "").casefold()
        ]
        family_bounds_list: list[dict[str, float]] = []
        family_decode_errors: list[dict[str, str]] = []
        for product in found:
            try:
                family_bounds_list.append(_product_bounds_ft(product, settings))
            except Exception as exc:
                family_decode_errors.append({"name": str(product.Name or ""), "error": str(exc)})
        family_bounds = _combine_bounds(family_bounds_list) if family_bounds_list else None
        checks["island geometry decoded"] = (
            len(found) == expected_module_count
            and len(family_bounds_list) == expected_module_count
            and not family_decode_errors
        )
        if not checks["island geometry decoded"]:
            errors.append(
                f"Expected {expected_module_count} IFC product(s) matching '{family_match}' with decodable geometry; "
                f"found {len(found)} with {len(family_bounds_list)} decodable."
            )

        expected_bounds = _expected_island(study)
        expected_countertop_bounds = _expected_countertop(study)
        expected_modules = _expected_module_bounds(study, expected_module_count)
        candidate_module_bounds = sorted(
            family_bounds_list, key=lambda item: (item["x_min_ft"], item["y_min_ft"])
        )
        expected_modules = sorted(expected_modules, key=lambda item: (item["x_min_ft"], item["y_min_ft"]))
        modules_match = (
            len(candidate_module_bounds) == len(expected_modules)
            and all(_bounds_match(actual, expected) for actual, expected in zip(candidate_module_bounds, expected_modules))
        )
        checks["casework module bounds match documented base"] = bool(modules_match)
        if not checks["casework module bounds match documented base"]:
            errors.append("One or more casework modules do not match their source-derived plan cell and documented 34.5 in base height.")

        countertop_products = [
            product for product in model.by_type("IfcProduct")
            if countertop_match.casefold() in str(product.Name or "").casefold()
        ]
        countertop_bounds_list: list[dict[str, float]] = []
        countertop_decode_errors: list[dict[str, str]] = []
        for product in countertop_products:
            try:
                countertop_bounds_list.append(_product_bounds_ft(product, settings))
            except Exception as exc:
                countertop_decode_errors.append({"name": str(product.Name or ""), "error": str(exc)})
        countertop_bounds = countertop_bounds_list[0] if len(countertop_bounds_list) == 1 else None
        checks["countertop placeholder decoded"] = (
            len(countertop_products) == 1 and len(countertop_bounds_list) == 1 and not countertop_decode_errors
        )
        if not checks["countertop placeholder decoded"]:
            errors.append(
                f"Expected one decodable IFC product matching '{countertop_match}'; "
                f"found {len(countertop_products)} with {len(countertop_bounds_list)} decodable."
            )

        countertop_matches = _bounds_match(countertop_bounds, expected_countertop_bounds)
        checks["countertop matches documented thickness and plan bounds"] = bool(countertop_matches)
        if not checks["countertop matches documented thickness and plan bounds"]:
            errors.append("Countertop placeholder does not match the 8 x 4 ft footprint, 1.25 in thickness and cabinet top elevation.")

        assembly_bounds = _combine_bounds(family_bounds_list + countertop_bounds_list) if family_bounds_list and countertop_bounds_list else None
        expected_assembly_bounds = dict(expected_bounds)
        expected_assembly_bounds["z_max_ft"] = expected_bounds["z_min_ft"] + DOCUMENTED_COUNTERTOP_TOP_FT
        expected_assembly_bounds["height_ft"] = DOCUMENTED_COUNTERTOP_TOP_FT
        bounds_match = (
            _bounds_match(assembly_bounds, expected_assembly_bounds)
            and modules_match
            and countertop_matches
        )
        checks["island assembly bounds match documented geometry"] = bool(bounds_match)
        if not checks["island assembly bounds match documented geometry"]:
            errors.append("Island assembly does not match the source-derived 8 x 4 ft base and the documented nominal 36 in countertop build-up.")

        observations["ifc"] = {
            "file": ifc_path.name,
            "schema": model.schema,
            "sha256": ifc_hash,
            "validation_issue_count": len(logger.statements),
            "validation_issues": logger.statements,
            "space_count": len(actual_ids),
            "expected_space_ids": sorted(expected_ids),
            "actual_space_ids": sorted(actual_ids),
            "storeys": actual_levels,
            "represented_product_count": len(all_products),
            "non_annotation_geometry_failures": geometry_errors,
            "annotation_geometry_exceptions": annotation_errors,
            "candidate_count": len(found),
            "candidate_class": found[0].is_a() if len(found) == 1 else None,
            "candidate_classes": sorted({product.is_a() for product in found}),
            "candidate_names": [str(product.Name or "") for product in found],
            "candidate_bounds_ft": assembly_bounds,
            "candidate_module_bounds_ft": candidate_module_bounds,
            "expected_module_bounds_ft": expected_modules,
            "countertop_count": len(countertop_products),
            "countertop_names": [str(product.Name or "") for product in countertop_products],
            "countertop_bounds_ft": countertop_bounds,
            "expected_countertop_bounds_ft": expected_countertop_bounds,
            "countertop_decode_errors": countertop_decode_errors,
            "nominal_height_inches": NOMINAL_COUNTER_HEIGHT_FT * 12,
            "source_derived_actual_height_inches": DOCUMENTED_COUNTERTOP_TOP_FT * 12,
            "accepted_nominal_height_variance_inches": (NOMINAL_COUNTER_HEIGHT_FT - DOCUMENTED_COUNTERTOP_TOP_FT) * 12,
            "expected_bounds_ft": expected_bounds,
            "candidate_decode_errors": family_decode_errors,
        }

    summary = audit.get("summary", {})
    checks["saved Revit study has three levels and 21 rooms"] = (
        summary.get("level_count") == 3 and summary.get("enclosed_room_count") == 21
    )
    checks["saved Revit study has the expected casework count and no warnings"] = (
        next((int(row["count"]) for row in audit.get("category_counts", []) if row.get("category") == "Casework"), 0) == expected_module_count
        and summary.get("warning_count") == 0
    )
    if not checks["saved Revit study has three levels and 21 rooms"]:
        errors.append("Read-only Revit audit does not record the expected three levels and 21 rooms.")
    if not checks["saved Revit study has the expected casework count and no warnings"]:
        errors.append(f"Read-only Revit audit does not record exactly {expected_module_count} Casework instance(s) and zero warnings.")

    passed = all(checks.values())
    return {
        "schema": "forever-home.kitchen-island-ifc-validation.v1",
        "status": "pass" if passed else "fail",
        "checks": checks,
        "observations": observations,
        "errors": errors,
        "lineage": {
            "document_title": export.get("document_title"),
            "model_fingerprint": export_fp,
            "study_sha256": _sha256(study_path),
            "family_match": family_match,
        },
        "limitations": [
            "The documented 42 in kitchen clearances cannot be checked until perimeter counters and other obstacles are modeled.",
            "The documented 36 in height is nominal; the specified 34.5 in cabinet plus 1.25 in countertop yields 35.75 in, accepted by the owner as nominally 36 in on 2026-10-27. This test does not resolve the material seam or fabrication detail.",
            "The result is a family-fit and IFC consistency check, not architectural approval, engineering, accessibility, code or construction certification.",
            "The IFC export cannot establish family licensing or reuse rights.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("export_dir", type=Path)
    parser.add_argument("audit_dir", type=Path)
    parser.add_argument("study_json", type=Path)
    parser.add_argument("--family-match", default="island_cabinet_Generic_7216")
    parser.add_argument("--expected-module-count", type=int, choices=(1, 4), default=4)
    parser.add_argument("--countertop-match", default="M-02 countertop thickness test")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        report = validate(
            args.export_dir,
            args.audit_dir,
            args.study_json,
            args.family_match,
            args.expected_module_count,
            args.countertop_match,
        )
    except Exception as exc:
        report = {
            "schema": "forever-home.kitchen-island-ifc-validation.v1",
            "status": "error",
            "checks": {},
            "observations": {},
            "errors": [f"Validation could not complete: {exc}"],
            "limitations": [],
        }
    output = args.report or (args.export_dir / "kitchen-island-validation.json")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2, default=str) + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "report": str(output), "checks": report["checks"], "errors": report["errors"]}, indent=2))
    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
