import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from Tools.RevitPilot.validate_gable_massing_ifc import (
    case_id_for_proxy,
    expected_bounds,
    geometry_metrics,
    make_geometry_settings,
    validate,
)


class M83GableIfcValidatorTests(unittest.TestCase):
    def test_geometry_settings_return_project_units_and_world_coordinates(self):
        class FakeSettings:
            USE_WORLD_COORDS = "world"
            CONVERT_BACK_UNITS = "project-units"

            def __init__(self):
                self.values = {}

            def set(self, key, value):
                self.values[key] = value

        settings = FakeSettings()
        with patch("Tools.RevitPilot.validate_gable_massing_ifc.ifcopenshell.geom.settings", return_value=settings):
            self.assertIs(make_geometry_settings(), settings)
        self.assertEqual(settings.values, {"world": True, "project-units": True})

    def test_proxy_is_bound_to_direct_shape_by_saved_revit_element_id(self):
        proxy = SimpleNamespace(Tag="2794", Name="12 - Conceptual Gable Surfaces:2794")
        rows = [{"case_id": "M83-X-8:12", "direct_shape_unique_id": "e2ba5e72-6b64-4724-a2c6-db2cb927bed8-00000aea"}]

        self.assertEqual(case_id_for_proxy(proxy, rows), "M83-X-8:12")
        self.assertIsNone(case_id_for_proxy(SimpleNamespace(Tag="2795", Name="Generic proxy"), rows))

    def test_expected_bounds_include_display_offset_and_relative_rise(self):
        option = {"display_offset_ft": {"x": 50.0, "y": 100.0}}

        actual = expected_bounds(option, width=38.333333, depth=40.0, rise=20.0)
        expected = {
            "min_x": 50.0,
            "min_y": 100.0,
            "min_z": 0.0,
            "max_x": 88.333333,
            "max_y": 140.0,
            "max_z": 20.0,
        }
        self.assertEqual(actual.keys(), expected.keys())
        for key, value in expected.items():
            self.assertAlmostEqual(actual[key], value)

    def test_geometry_metrics_convert_metres_and_sum_triangle_areas(self):
        shape = SimpleNamespace(
            geometry=SimpleNamespace(
                verts=[
                    0.0, 0.0, 0.0,
                    3.048, 0.0, 0.0,
                    3.048, 3.048, 0.0,
                    0.0, 3.048, 0.0,
                ],
                faces=[0, 1, 2, 0, 2, 3],
            )
        )

        with patch("Tools.RevitPilot.validate_gable_massing_ifc.ifcopenshell.geom.create_shape", return_value=shape):
            metrics = geometry_metrics(object(), object(), unit_scale=1.0)

        self.assertIsNotNone(metrics)
        self.assertEqual(metrics["vertex_count"], 4)
        self.assertEqual(metrics["triangle_count"], 2)
        expected_bounds_ft = {
            "min_x": 0.0, "min_y": 0.0, "min_z": 0.0,
            "max_x": 10.0, "max_y": 10.0, "max_z": 0.0,
        }
        for key, value in expected_bounds_ft.items():
            self.assertAlmostEqual(metrics["bounds_ft"][key], value)
        self.assertAlmostEqual(metrics["triangulated_area_sqft"], 100.0)

    def test_geometry_metrics_reject_nonfinite_vertices(self):
        shape = SimpleNamespace(
            geometry=SimpleNamespace(
                verts=[0.0, 0.0, 0.0, float("nan"), 0.0, 0.0, 0.0, 1.0, 0.0],
                faces=[0, 1, 2],
            )
        )

        with patch("Tools.RevitPilot.validate_gable_massing_ifc.ifcopenshell.geom.create_shape", return_value=shape):
            self.assertIsNone(geometry_metrics(object(), object(), unit_scale=1.0))

    def test_geometry_metrics_treat_engine_failure_as_missing_geometry(self):
        with patch(
            "Tools.RevitPilot.validate_gable_massing_ifc.ifcopenshell.geom.create_shape",
            side_effect=RuntimeError("invalid IFC representation"),
        ):
            self.assertIsNone(geometry_metrics(object(), object(), unit_scale=1.0))

    def test_missing_host_artifacts_write_machine_readable_failure(self):
        with tempfile.TemporaryDirectory() as temporary:
            run_directory = Path(temporary) / "missing-m83-run"
            run_directory.mkdir()
            report_path = run_directory / "validation.json"

            result = validate(run_directory, report_path)

            self.assertEqual(result["status"], "fail")
            self.assertEqual(result["passed_count"], 0)
            self.assertEqual(result["check_count"], 6)
            self.assertTrue(all(not passed for passed in result["checks"].values()))
            self.assertTrue(any(".ifc" in error for error in result["errors"]))
            self.assertEqual(json.loads(report_path.read_text(encoding="utf-8")), result)


if __name__ == "__main__":
    unittest.main()
