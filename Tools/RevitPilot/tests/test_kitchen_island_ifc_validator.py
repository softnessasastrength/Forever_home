import json
import unittest
from pathlib import Path

from validate_kitchen_island_ifc import (
    DOCUMENTED_COUNTERTOP_THICKNESS_FT,
    DOCUMENTED_COUNTERTOP_TOP_FT,
    _bounds_match,
    _combine_bounds,
    _expected_countertop,
    _expected_island,
    _expected_module_bounds,
)


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
            self.assertAlmostEqual(row["height_ft"], 34.5 / 12)
            self.assertAlmostEqual(row["z_max_ft"], 34.5 / 12)
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
        for key, value in {**expected, "height_ft": 34.5 / 12}.items():
            self.assertAlmostEqual(combined[key], value)

    def test_countertop_uses_documented_thickness_and_owner_accepted_nominal_height(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        countertop = _expected_countertop(study)

        self.assertAlmostEqual(countertop["height_ft"], 1.25 / 12)
        self.assertAlmostEqual(countertop["z_min_ft"], 34.5 / 12)
        self.assertAlmostEqual(countertop["z_max_ft"], 35.75 / 12)
        self.assertAlmostEqual(DOCUMENTED_COUNTERTOP_THICKNESS_FT, 1.25 / 12)
        self.assertAlmostEqual(DOCUMENTED_COUNTERTOP_TOP_FT * 12, 35.75)
        self.assertAlmostEqual(36 - DOCUMENTED_COUNTERTOP_TOP_FT * 12, 0.25)

    def test_single_family_mode_retains_whole_island_bounds(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        self.assertEqual(_expected_module_bounds(study, 1), [_expected_island(study)])

    def test_unsupported_module_count_fails_explicitly(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        with self.assertRaisesRegex(ValueError, "four-module"):
            _expected_module_bounds(study, 2)

    def test_34_5_in_base_cabinet_is_not_misreported_as_nominal_counter_height(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        measured = _expected_island(study)
        nominal_36_in = dict(measured)
        nominal_36_in["z_max_ft"] = 3.0
        nominal_36_in["height_ft"] = 3.0

        self.assertFalse(_bounds_match(measured, nominal_36_in))


if __name__ == "__main__":
    unittest.main()
