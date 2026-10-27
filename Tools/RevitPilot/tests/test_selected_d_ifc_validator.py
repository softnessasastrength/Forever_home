import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

import ifcopenshell.util.element

from validate_selected_d_ifc import PLAN_LEVEL_NAMES, _expected_blocks, _space_area, validate


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
        self.assertEqual(
            {key: "D " + name for key, name in PLAN_LEVEL_NAMES.items()},
            {"main": "D Main FF", "upper": "D Upper FF", "lower": "D Lower FF"},
        )

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

    def test_space_area_falls_back_to_rectangular_ifc_body_geometry(self):
        profile = SimpleNamespace(
            XDim=16.0,
            YDim=15.0,
            is_a=lambda entity=None: entity == "IfcRectangleProfileDef",
        )
        solid = SimpleNamespace(
            SweptArea=profile,
            is_a=lambda entity=None: entity == "IfcExtrudedAreaSolid",
        )
        representation = SimpleNamespace(Items=[solid])
        shape = SimpleNamespace(Representations=[representation])
        space = SimpleNamespace(Representation=shape)
        with patch.object(ifcopenshell.util.element, "get_psets", return_value={}):
            self.assertAlmostEqual(_space_area(space, unit_scale=0.3048), 240.0)

    def test_storey_aggregation_provides_space_levels(self):
        from validate_selected_d_ifc import _space_level_names

        space = SimpleNamespace(Name="M-01", is_a=lambda entity=None: entity == "IfcSpace")
        storey = SimpleNamespace(Name="D Main FF", is_a=lambda entity=None: entity == "IfcBuildingStorey")
        relation = SimpleNamespace(RelatingObject=storey, RelatedObjects=[space])

        class Model:
            def by_type(self, entity):
                return {"IfcRelContainedInSpatialStructure": [], "IfcRelAggregates": [relation]}[entity]

        with patch.object(ifcopenshell.util.element, "get_psets", return_value={}):
            self.assertEqual(_space_level_names(Model()), {"M-01": "D Main FF"})


if __name__ == "__main__":
    unittest.main()
