"""Validate the complete Compact-Core generator input without requiring Revit."""
import json
import sys
from pathlib import Path


EXPECTED_ROOM_IDS = {
    "M-01", "M-02", "M-03", "M-06", "L-02", "U-01", "U-02", "U-03",
    "U-04", "U-05", "U-06", "L-01", "L-03", "L-04", "L-05", "L-06", "L-07",
}
EXPECTED_DOOR_IDS = {
    "D-MAIN-ENTRY", "D-MAIN-BATH", "D-MAIN-FLEX", "D-PRIMARY-BATH", "D-TECH-SERVICE",
}
EXPECTED_FLOORS = {
    "FH-C-FLOOR-LOWER": ("FH-C-LEVEL-LOWER", 2752, 2752),
    "FH-C-FLOOR-MAIN": ("FH-C-LEVEL-MAIN", 1600, 1410),
    "FH-C-FLOOR-UPPER": ("FH-C-LEVEL-UPPER", 1152, 1152),
}


def _polygon_area(points: list[list[float]]) -> float:
    return abs(sum(
        points[i][0] * points[(i + 1) % len(points)][1]
        - points[(i + 1) % len(points)][0] * points[i][1]
        for i in range(len(points))
    )) / 2


def validate(data: dict) -> list[str]:
    errors: list[str] = []
    if data.get("schema") != "forever-home.compact-study-config.v2":
        errors.append("unsupported or missing compact-study config schema")
    levels = data.get("levels", [])
    level_ids = [item.get("id") for item in levels]
    if len(level_ids) != 3 or len(set(level_ids)) != 3 or any(not item.get("name") for item in levels):
        errors.append("three uniquely identified and named levels are required")
    level_by_id = {item.get("id"): item for item in levels}
    expected_elevations = {"FH-C-LEVEL-LOWER": -5, "FH-C-LEVEL-MAIN": 0, "FH-C-LEVEL-UPPER": 5}
    if {key: level_by_id.get(key, {}).get("elevation_ft") for key in expected_elevations} != expected_elevations:
        errors.append("level IDs/elevations must remain the documented -5/0/+5 ft study datums")

    shell = data.get("shell", {})
    if (len(shell.get("main_origin_ft", [])) != 2 or len(shell.get("rear_origin_ft", [])) != 2
            or shell.get("wall_level_id") not in {item.get("id") for item in levels}
            or shell.get("wall_height_ft", 0) <= 0):
        errors.append("shell origin, wall level, or wall height is invalid")
    if (shell.get("main_width_ft"), shell.get("main_depth_ft")) != (40, 40):
        errors.append("main shell target drifted from 40 x 40 ft")
    if (shell.get("rear_width_ft"), shell.get("rear_depth_ft")) != (36, 32):
        errors.append("rear wing target drifted from 36 x 32 ft")
    lift = data.get("lift_reservation", {})
    if (lift.get("width_ft"), lift.get("depth_ft")) != (8, 8):
        errors.append("lift target drifted from 8 x 8 ft")
    if lift.get("wall_level_id") not in {item.get("id") for item in levels} or lift.get("wall_height_ft", 0) <= 0:
        errors.append("lift reservation wall level/height is invalid")
    if len(lift.get("origin_ft", [])) != 2:
        errors.append("lift reservation origin must contain two plan coordinates")

    rooms = data.get("rooms", [])
    room_specs = data.get("room_specs", [])
    room_ids = [item.get("id") for item in room_specs]
    if set(rooms) != EXPECTED_ROOM_IDS or len(rooms) != len(EXPECTED_ROOM_IDS):
        errors.append("stable room ID list differs from the 17-room study baseline")
    if set(room_ids) != set(rooms) or len(room_ids) != len(rooms):
        errors.append("room geometry definitions must cover each stable room ID exactly once")

    generated_wall_markers: set[str] = set()
    # Shell and lift wall marker numbering follows the authored polygon edge order.
    generated_wall_markers.update(f"FH-C-SHELL-{i:02d}" for i in range(1, 5))
    generated_wall_markers.update(f"FH-C-LIFT-RES-{i:02d}" for i in range(1, 5))
    generated_wall_markers.update(f"FH-C-STACKED-SHELL-{i:02d}" for i in (2, 3, 4))
    for spec in room_specs:
        if spec.get("level_id") not in level_by_id:
            errors.append(f"{spec.get('id')} references an unknown level")
        origin = spec.get("origin_ft", [])
        width, depth = spec.get("width_ft"), spec.get("depth_ft")
        seed = spec.get("room_seed_ft", [])
        if len(origin) != 2 or not isinstance(width, (int, float)) or not isinstance(depth, (int, float)):
            errors.append(f"{spec.get('id')} has incomplete rectangular boundary geometry")
            continue
        if width <= 0 or depth <= 0 or len(seed) != 2 or not (origin[0] < seed[0] < origin[0] + width and origin[1] < seed[1] < origin[1] + depth):
            errors.append(f"{spec.get('id')} boundary or room placement point is invalid")
        if not spec.get("name") or not spec.get("wall_marker") or spec.get("wall_height_ft", 0) <= 0:
            errors.append(f"{spec.get('id')} has incomplete room label or wall identity/height")
        skipped = spec.get("skipped_edges", [])
        if len(skipped) != len(set(skipped)) or any(edge not in range(4) for edge in skipped):
            errors.append(f"{spec.get('id')} has invalid skipped wall edges")
        for edge in range(4):
            if edge not in skipped:
                generated_wall_markers.add(f"{spec.get('wall_marker')}-{edge + 1:02d}")

    for wall in data.get("shared_walls", []):
        generated_wall_markers.add(wall.get("marker"))
        if wall.get("level_id") not in level_by_id or len(wall.get("start_ft", [])) != 3 or len(wall.get("end_ft", [])) != 3:
            errors.append("a shared wall has an unknown level or malformed endpoint")

    doors = data.get("doors", [])
    door_ids = [item.get("id") for item in doors]
    if set(door_ids) != EXPECTED_DOOR_IDS or len(door_ids) != len(EXPECTED_DOOR_IDS):
        errors.append("nominal door placement IDs differ from the five-door study baseline")
    for door in doors:
        if door.get("level_id") not in level_by_id or door.get("wall_marker") not in generated_wall_markers or len(door.get("point_ft", [])) != 3:
            errors.append(f"{door.get('id')} has an invalid host wall, level, or insertion point")

    for stair in data.get("stairs", []):
        if stair.get("from_level_id") not in level_by_id or stair.get("to_level_id") not in level_by_id:
            errors.append(f"{stair.get('marker')} references an unknown level")
        if len(stair.get("start_ft", [])) != 3 or len(stair.get("end_ft", [])) != 3 or stair.get("desired_risers", 0) <= 0:
            errors.append(f"{stair.get('marker')} has incomplete run geometry")

    overlays = data.get("overlays", {})
    for box in overlays.get("boxes", []):
        origin = box.get("origin_ft", [])
        if len(origin) != 2 or box.get("width_ft", 0) <= 0 or box.get("depth_ft", 0) <= 0:
            errors.append("a furniture/fixture overlay box has invalid plan geometry")
    for line in overlays.get("lines", []):
        if len(line.get("start_ft", [])) != 3 or len(line.get("end_ft", [])) != 3:
            errors.append("a model-line overlay has malformed endpoints")
    note_specs = [overlays.get("route_note", {}), *overlays.get("plan_notes", []), *overlays.get("floor_notes", [])]
    for note in note_specs:
        if note.get("level_id") not in level_by_id or len(note.get("point_ft", [])) != 3 or not note.get("text"):
            errors.append("a study annotation has an unknown level, malformed insertion point, or blank text")

    floors = data.get("floors", [])
    if {item.get("marker") for item in floors} != set(EXPECTED_FLOORS) or len(floors) != len(EXPECTED_FLOORS):
        errors.append("the three lower/main/upper floor profiles are required")
    for floor in floors:
        marker = floor.get("marker")
        level_id, gross_area, profile_area = EXPECTED_FLOORS.get(marker, (None, None, None))
        if floor.get("level_id") != level_id or floor.get("gross_footprint_sqft") != gross_area:
            errors.append(f"{marker} level or gross footprint differs from its study target")
        loops = floor.get("loops", [])
        if not loops or any(len(loop) < 3 for loop in loops):
            errors.append(f"{marker} requires closed polygon loops with at least three vertices")
            continue
        if any(len(point) != 2 for loop in loops for point in loop):
            errors.append(f"{marker} has a malformed XY vertex")
            continue
        computed_area = _polygon_area(loops[0]) - sum(_polygon_area(loop) for loop in loops[1:])
        if abs(computed_area - floor.get("profile_area_sqft", -1)) > 0.01 or floor.get("profile_area_sqft") != profile_area:
            errors.append(f"{marker} polygon geometry does not match its declared profile-area target")
    if not data.get("unresolved"):
        errors.append("unresolved-review flags are missing")
    if data.get("roof", {}).get("status") != "not modeled":
        errors.append("roof must remain unmodeled pending approved design input")
    if data.get("stair_floor_coordination", {}).get("status") != "open":
        errors.append("stair/floor coordination must remain open")
    return errors


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name("compact-study-config.json")
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        errors = validate(data)
    except (OSError, json.JSONDecodeError) as exc:
        errors = [str(exc)]
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print(f"PASS: {path.name}; 3 levels, 17 room boundaries, 5 nominal doors, 3 polygon-checked floor plates")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
