"""Validate a Revit compact-core study manifest without opening Revit."""
import hashlib
import json
import re
import sys
from pathlib import Path

from preflight_compact_study import validate as validate_config

EXPECTED_LEVELS = {"FH-C-LEVEL-LOWER", "FH-C-LEVEL-MAIN", "FH-C-LEVEL-UPPER"}
EXPECTED_ROOMS = {
    "M-01", "M-02", "M-03", "M-06", "L-02",
    "U-01", "U-02", "U-03", "U-04", "U-05", "U-06",
    "L-01", "L-03", "L-04", "L-05", "L-06", "L-07",
}
EXPECTED_DOORS = {"D-MAIN-ENTRY", "D-MAIN-BATH", "D-MAIN-FLEX", "D-PRIMARY-BATH", "D-TECH-SERVICE"}
EXPECTED_FLOORS = {
    "FH-C-FLOOR-LOWER": ("C Lower -5 ft", 2752, 2752),
    "FH-C-FLOOR-MAIN": ("C Main 0 ft", 1600, 1410),
    "FH-C-FLOOR-UPPER": ("C Upper +5 ft", 1152, 1152),
}


def validate(path: Path) -> list[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    errors = []
    config_schema = data.get("config_schema")
    config_hash = data.get("config_sha256")
    model_identity = data.get("model_fingerprint")
    if not isinstance(model_identity, dict):
        errors.append("study manifest must include the saved RVT content fingerprint")
    else:
        model_name = model_identity.get("file_name")
        model_path = path.parent / model_name if isinstance(model_name, str) and Path(model_name).name == model_name else None
        if (model_identity.get("algorithm") != "sha256-of-saved-rvt-bytes-v1"
                or not isinstance(model_identity.get("sha256"), str)
                or re.fullmatch(r"[0-9a-f]{64}", model_identity.get("sha256", "")) is None
                or model_path is None or not model_path.is_file()):
            errors.append("study model fingerprint is malformed or its RVT file is missing")
        elif model_identity.get("bytes") != model_path.stat().st_size or model_identity.get("sha256") != hashlib.sha256(model_path.read_bytes()).hexdigest():
            errors.append("study model fingerprint does not match the retained RVT bytes")
    if config_schema is not None:
        if config_schema not in {"forever-home.compact-study-config.v2", "forever-home.compact-study-config.v3"}:
            errors.append(f"unsupported generator config schema: {config_schema}")
        if not isinstance(config_hash, str) or re.fullmatch(r"[0-9a-f]{64}", config_hash) is None:
            errors.append("config-driven manifest must include a lowercase SHA256 fingerprint")
        config_file = data.get("config_file")
        config_path = path.parent / config_file if isinstance(config_file, str) and Path(config_file).name == config_file else None
        if config_path is None or not config_path.is_file():
            errors.append("config-driven manifest must retain its adjacent configuration snapshot")
        else:
            config_bytes = config_path.read_bytes()
            if hashlib.sha256(config_bytes).hexdigest() != config_hash:
                errors.append("configuration snapshot SHA256 does not match the manifest")
            try:
                config_data = json.loads(config_bytes.decode("utf-8"))
                errors.extend(f"configuration snapshot: {item}" for item in validate_config(config_data))
                config_level_ids = {item["id"] for item in config_data["levels"]}
                manifest_level_ids = {item["id"] for item in data.get("levels", [])}
                if config_level_ids != manifest_level_ids:
                    errors.append("manifest levels differ from the configuration snapshot")
                config_levels = {item["id"]: item for item in config_data["levels"]}
                manifest_levels = {item["id"]: item for item in data.get("levels", [])}
                for level_id in config_level_ids & manifest_level_ids:
                    if (manifest_levels[level_id].get("name") != config_levels[level_id]["name"]
                            or manifest_levels[level_id].get("elevation_ft") != config_levels[level_id]["elevation_ft"]):
                        errors.append(f"manifest level {level_id} name/elevation differs from the configuration snapshot")
                if set(config_data.get("rooms", [])) != set(data.get("rooms", [])):
                    errors.append("manifest room IDs differ from the configuration snapshot")
                if {item["id"] for item in config_data.get("doors", [])} != set(data.get("doors", [])):
                    errors.append("manifest door IDs differ from the configuration snapshot")
                config_floors = {item["marker"]: item for item in config_data.get("floors", [])}
                manifest_floors = {item["marker"]: item for item in data.get("floors", [])}
                if set(config_floors) != set(manifest_floors):
                    errors.append("manifest floor markers differ from the configuration snapshot")
                for marker in config_floors.keys() & manifest_floors.keys():
                    source, generated = config_floors[marker], manifest_floors[marker]
                    if generated.get("gross_footprint_sqft") != source.get("gross_footprint_sqft") or generated.get("profile_area_sqft") != source.get("profile_area_sqft"):
                        errors.append(f"manifest floor profile for {marker} differs from the configuration snapshot")
                    if generated.get("level") != config_levels.get(source.get("level_id"), {}).get("name"):
                        errors.append(f"manifest floor level for {marker} differs from the configuration snapshot")
                if data.get("shell") != {key: config_data["shell"][key] for key in ("main_width_ft", "main_depth_ft", "rear_width_ft", "rear_depth_ft")}:
                    errors.append("manifest shell targets differ from the configuration snapshot")
                lift = config_data["lift_reservation"]
                if data.get("lift_reservation", {}).get("width_ft") != lift["width_ft"] or data.get("lift_reservation", {}).get("depth_ft") != lift["depth_ft"]:
                    errors.append("manifest lift reservation differs from the configuration snapshot")
                if config_schema == "forever-home.compact-study-config.v3":
                    door_family = config_data["nominal_door_family"]
                    manifest_door_family = data.get("nominal_door_family", {})
                    for key in ("width_ft", "depth_ft", "height_ft", "clear_opening_selected", "status"):
                        if manifest_door_family.get(key) != door_family.get(key):
                            errors.append(f"manifest nominal door-family {key} differs from the configuration snapshot")
                    if data.get("rear_shell_skipped_edges") != config_data["shell"]["rear_skipped_edges"]:
                        errors.append("manifest rear-shell wall topology differs from the configuration snapshot")
            except (UnicodeDecodeError, json.JSONDecodeError, KeyError, TypeError) as exc:
                errors.append(f"configuration snapshot is invalid: {exc}")
    levels = {item["id"] for item in data.get("levels", [])}
    rooms = set(data.get("rooms", []))
    if levels != EXPECTED_LEVELS:
        errors.append(f"levels mismatch: {sorted(levels)}")
    if rooms != EXPECTED_ROOMS or len(data.get("rooms", [])) != len(EXPECTED_ROOMS):
        errors.append(f"room IDs mismatch or duplicated: {sorted(rooms)}")
    doors = set(data.get("doors", []))
    if doors != EXPECTED_DOORS or len(data.get("doors", [])) != len(EXPECTED_DOORS):
        errors.append(f"door IDs mismatch or duplicated: {sorted(doors)}")
    shell = data.get("shell", {})
    if shell.get("main_width_ft") != 40 or shell.get("main_depth_ft") != 40:
        errors.append("main shell target is not 40 x 40 ft")
    lift = data.get("lift_reservation", {})
    if lift.get("width_ft") != 8 or lift.get("depth_ft") != 8:
        errors.append("lift reservation target is not 8 x 8 ft")
    if not data.get("unresolved"):
        errors.append("unresolved-review flags are missing")
    floors = data.get("floors", [])
    floor_by_marker = {item.get("marker"): item for item in floors}
    if set(floor_by_marker) != set(EXPECTED_FLOORS) or len(floors) != len(EXPECTED_FLOORS):
        errors.append("three stable lower/main/upper floor markers are required")
    for marker, (level, gross_area, profile_area) in EXPECTED_FLOORS.items():
        floor = floor_by_marker.get(marker, {})
        if floor.get("level") != level:
            errors.append(f"{marker} is assigned to the wrong level")
        if floor.get("gross_footprint_sqft") != gross_area:
            errors.append(f"{marker} gross footprint mismatch")
        if floor.get("profile_area_sqft") != profile_area:
            errors.append(f"{marker} profile area mismatch")
        if floor.get("selected_assembly") is not False or floor.get("finish_material_selected") is not False:
            errors.append(f"{marker} must remain explicitly unselected")
    if data.get("roof", {}).get("status") != "not modeled":
        errors.append("roof must remain explicitly unmodeled pending an approved design input")
    if data.get("stair_floor_coordination", {}).get("status") != "open":
        errors.append("stair/floor coordination must remain an open issue")
    return errors


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_compact_manifest.py path/to/study-manifest.json")
        return 2
    errors = validate(Path(sys.argv[1]))
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print(f"PASS: compact manifest; {len(EXPECTED_ROOMS)} rooms, {len(EXPECTED_FLOORS)} floor plates, roof/stair issues retained")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
