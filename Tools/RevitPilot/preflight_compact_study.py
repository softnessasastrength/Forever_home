"""Fast preflight for the C study; does not require Revit."""
import json
import sys
from pathlib import Path


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name("compact-study-config.json")
    data = json.loads(path.read_text(encoding="utf-8"))
    errors = []
    for key in ("levels", "rooms", "doors", "unresolved"):
        values = data.get(key, [])
        ids = [item.get("id") if isinstance(item, dict) else item for item in values]
        if not ids or len(ids) != len(set(ids)):
            errors.append(f"{key} missing or duplicated")
    shell = data.get("shell", {})
    if (shell.get("main_width_ft"), shell.get("main_depth_ft")) != (40, 40):
        errors.append("main shell target drifted from 40 x 40 ft")
    lift = data.get("lift_reservation", {})
    if (lift.get("width_ft"), lift.get("depth_ft")) != (8, 8):
        errors.append("lift target drifted from 8 x 8 ft")
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print(f"PASS: {path.name}; {len(data['rooms'])} rooms, {len(data['doors'])} doors, {len(data['levels'])} levels")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
