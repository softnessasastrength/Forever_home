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


def validate(path: Path) -> list[str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    errors = []
    levels = {item["id"] for item in data.get("levels", [])}
    rooms = set(data.get("rooms", []))
    if levels != EXPECTED_LEVELS:
        errors.append(f"levels mismatch: {sorted(levels)}")
    if rooms != EXPECTED_ROOMS or len(data.get("rooms", [])) != len(EXPECTED_ROOMS):
        errors.append(f"room IDs mismatch or duplicated: {sorted(rooms)}")
    shell = data.get("shell", {})
    if shell.get("main_width_ft") != 40 or shell.get("main_depth_ft") != 40:
        errors.append("main shell target is not 40 x 40 ft")
    lift = data.get("lift_reservation", {})
    if lift.get("width_ft") != 8 or lift.get("depth_ft") != 8:
        errors.append("lift reservation target is not 8 x 8 ft")
    if not data.get("unresolved"):
        errors.append("unresolved-review flags are missing")
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
    print(f"PASS: compact manifest schema and {len(EXPECTED_ROOMS)} room IDs validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
