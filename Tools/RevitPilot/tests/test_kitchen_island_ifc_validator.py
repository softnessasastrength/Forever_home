import json
import unittest
from pathlib import Path

from validate_kitchen_island_ifc import _bounds_match, _combine_bounds, _expected_island, _expected_module_bounds


ROOT = Path(__file__).resolve().parents[3]
STUDY_PATH = ROOT / "Architecture" / "Selected_Design_Iteration_2026-10-27" / "study.json"


class KitchenIslandIfcValidatorTests(unittest.TestCase):
    def test_four_modules_cover_source_derived_island_bounds_without_gaps(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        expected = _expected_island(study)
        modules = _expected_module_bounds(study, 4)

        self.assertEqual(len(modules), 4)
        for row in modules:
            self.assertAlmostEqual(row["length_ft"], 4.0)
            self.assertAlmostEqual(row["depth_ft"], 2.0)
            self.assertAlmostEqual(row["height_ft"], 3.0)
        self.assertEqual(
            {(round(row["x_min_ft"], 6), round(row["y_min_ft"], 6)) for row in modules},
            {
                (round(expected["x_min_ft"], 6), round(expected["y_min_ft"], 6)),
                (round(expected["x_min_ft"], 6), round((expected["y_min_ft"] + expected["y_max_ft"]) / 2, 6)),
                (round((expected["x_min_ft"] + expected["x_max_ft"]) / 2, 6), round(expected["y_min_ft"], 6)),
                (round((expected["x_min_ft"] + expected["x_max_ft"]) / 2, 6), round((expected["y_min_ft"] + expected["y_max_ft"]) / 2, 6)),
            },
        )
        combined = _combine_bounds(modules)
        for key, value in {**expected, "height_ft": 3.0}.items():
            self.assertAlmostEqual(combined[key], value)

    def test_single_family_mode_retains_whole_island_bounds(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        self.assertEqual(_expected_module_bounds(study, 1), [_expected_island(study)])

    def test_unsupported_module_count_fails_explicitly(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        with self.assertRaisesRegex(ValueError, "four-module"):
            _expected_module_bounds(study, 2)

    def test_34_5_in_base_cabinet_does_not_satisfy_36_in_counter_height(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        target = _expected_module_bounds(study, 4)[0]
        measured = dict(target)
        measured["z_max_ft"] = 34.5 / 12
        measured["height_ft"] = 34.5 / 12

        self.assertFalse(_bounds_match(measured, target))


if __name__ == "__main__":
    unittest.main()
