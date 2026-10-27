"""Offline regression tests for the Compact-Core generation input and manifest provenance."""
from __future__ import annotations

import copy
import hashlib
import json
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
PILOT_DIR = REPO_ROOT / "Tools" / "RevitPilot"
sys.path.insert(0, str(PILOT_DIR))

from preflight_compact_study import validate as validate_config  # noqa: E402
from validate_compact_manifest import validate as validate_manifest  # noqa: E402


class CompactStudyConfigTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.config = json.loads((PILOT_DIR / "compact-study-config.json").read_text(encoding="utf-8"))

    def test_checked_in_config_passes(self) -> None:
        self.assertEqual(validate_config(self.config), [])

    def test_invalid_room_seed_is_rejected(self) -> None:
        config = copy.deepcopy(self.config)
        config["room_specs"][0]["room_seed_ft"] = [999, 999]
        self.assertTrue(validate_config(config))

    def test_unknown_door_host_is_rejected(self) -> None:
        config = copy.deepcopy(self.config)
        config["doors"][0]["wall_marker"] = "FH-C-NOT-A-WALL"
        self.assertTrue(validate_config(config))

    def test_floor_polygon_area_drift_is_rejected(self) -> None:
        config = copy.deepcopy(self.config)
        config["floors"][1]["loops"][0][1][0] += 1
        self.assertTrue(validate_config(config))

    def test_manifest_matches_preserved_config_snapshot(self) -> None:
        config_bytes = json.dumps(self.config, ensure_ascii=False, indent=2).encode("utf-8")
        level_names = {item["id"]: item["name"] for item in self.config["levels"]}
        manifest = {
            "config_schema": self.config["schema"],
            "config_file": "compact-study-config.json",
            "config_sha256": hashlib.sha256(config_bytes).hexdigest(),
            "levels": self.config["levels"],
            "rooms": self.config["rooms"],
            "doors": [item["id"] for item in self.config["doors"]],
            "shell": {key: self.config["shell"][key] for key in ("main_width_ft", "main_depth_ft", "rear_width_ft", "rear_depth_ft")},
            "lift_reservation": {"width_ft": self.config["lift_reservation"]["width_ft"], "depth_ft": self.config["lift_reservation"]["depth_ft"]},
            "floors": [
                {
                    "marker": floor["marker"],
                    "level": level_names[floor["level_id"]],
                    "gross_footprint_sqft": floor["gross_footprint_sqft"],
                    "profile_area_sqft": floor["profile_area_sqft"],
                    "selected_assembly": False,
                    "finish_material_selected": False,
                }
                for floor in self.config["floors"]
            ],
            "unresolved": self.config["unresolved"],
            "roof": self.config["roof"],
            "stair_floor_coordination": self.config["stair_floor_coordination"],
        }
        with tempfile.TemporaryDirectory(prefix="fh-compact-config-") as temp:
            folder = Path(temp)
            manifest_path = folder / "study-manifest.json"
            manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
            (folder / "compact-study-config.json").write_bytes(config_bytes)
            self.assertEqual(validate_manifest(manifest_path), [])

            altered_config = copy.deepcopy(self.config)
            altered_config["room_specs"][0]["origin_ft"][0] += 1
            (folder / "compact-study-config.json").write_text(json.dumps(altered_config), encoding="utf-8")
            errors = validate_manifest(manifest_path)
            self.assertTrue(any("SHA256" in error for error in errors), errors)


if __name__ == "__main__":
    unittest.main()
