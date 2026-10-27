"""Validate a Revit compact-core study manifest without opening Revit."""
import json
import sys
from pathlib import Path

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
