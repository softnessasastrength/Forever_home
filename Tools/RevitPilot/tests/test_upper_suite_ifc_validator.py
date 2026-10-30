import unittest

from Tools.RevitPilot.validate_upper_suite_ifc import room_blocks_within_shell


class UpperSuiteIfcValidatorTests(unittest.TestCase):
    def test_all_room_blocks_inside_shell(self):
        rooms = {
            "U-01": {"x_ft": 0, "y_ft": 2, "width_ft": 10, "depth_ft": 16},
            "C-PRIVATE": {"x_ft": 4.6666667, "y_ft": 28, "width_ft": 10, "depth_ft": 6.5},
        }
        self.assertTrue(room_blocks_within_shell(rooms, 38.333333, 40))

    def test_rejects_room_extending_past_shell_edge(self):
        rooms = {"C-PRIVATE": {"x_ft": 4, "y_ft": 34, "width_ft": 10, "depth_ft": 6.5}}
        self.assertFalse(room_blocks_within_shell(rooms, 38.333333, 40))

    def test_rejects_missing_nonfinite_and_invalid_room_dimensions(self):
        self.assertFalse(room_blocks_within_shell({}, 38.333333, 40))
        self.assertFalse(room_blocks_within_shell({"U-01": {}}, 38.333333, 40))
        rooms = {"U-01": {"x_ft": 0, "y_ft": float("nan"), "width_ft": 10, "depth_ft": 16}}
        self.assertFalse(room_blocks_within_shell(rooms, 38.333333, 40))
        rooms = {"U-01": {"x_ft": 0, "y_ft": 0, "width_ft": 0, "depth_ft": 16}}
        self.assertFalse(room_blocks_within_shell(rooms, 38.333333, 40))


if __name__ == "__main__":
    unittest.main()
