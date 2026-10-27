import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import ifcopenshell.util.element

from validate_selected_d_ifc import _expected_blocks, _space_area, validate


ROOT = Path(__file__).resolve().parents[3]
STUDY_PATH = ROOT / "Architecture" / "Selected_Design_Iteration_2026-10-27" / "study.json"


class SelectedDIfcValidatorTests(unittest.TestCase):
    def test_expected_block_inventory_and_areas_come_from_source(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        blocks = _expected_blocks(study)

        self.assertEqual(len(blocks), 21)
        self.assertEqual(blocks["M-01"]["area_sf"], 240.0)
        self.assertEqual(blocks["U-01"]["area_sf"], 160.0)
        self.assertEqual(blocks["L-02"]["area_sf"], 110.0)

    def test_missing_host_run_fails_and_writes_a_machine_readable_report(self):
        with tempfile.TemporaryDirectory() as temporary:
            run_dir = Path(temporary) / "selected-d-run"
            run_dir.mkdir()
            report_path = run_dir / "ifc-validation.json"

            result = validate(run_dir, STUDY_PATH, report_path)

            self.assertEqual(result["status"], "fail")
            self.assertFalse(result["checks"]["ifc_present"])
            self.assertTrue(any("FH_Selected_D_Space_Study.ifc" in item for item in result["errors"]))
            self.assertEqual(json.loads(report_path.read_text(encoding="utf-8")), result)

    def test_space_area_must_be_finite_and_positive(self):
        space = object()
        with patch.object(ifcopenshell.util.element, "get_psets", return_value={"Dimensions": {"Area": float("inf")}}):
            self.assertIsNone(_space_area(space))
        with patch.object(ifcopenshell.util.element, "get_psets", return_value={"Dimensions": {"Area": -1}}):
            self.assertIsNone(_space_area(space))
        with patch.object(ifcopenshell.util.element, "get_psets", return_value={"Dimensions": {"Area": "240.0"}}):
            self.assertEqual(_space_area(space), 240.0)


if __name__ == "__main__":
    unittest.main()
