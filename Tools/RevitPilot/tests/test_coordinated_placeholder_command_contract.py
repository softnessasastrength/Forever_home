from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMMAND = (ROOT / "NativeCoordinatedPlaceholderStudyCommand.cs").read_text(encoding="utf-8")
PILOT = (ROOT / "Pilot.cs").read_text(encoding="utf-8")
VALIDATOR = (ROOT / "validate_coordinated_placeholder_study.ps1").read_text(encoding="utf-8")


class CoordinatedPlaceholderCommandContractTests(unittest.TestCase):
    def test_uses_only_recorded_coordination_dimensions(self):
        self.assertIn("5.5 / 12.0", COMMAND)
        self.assertIn("1.5 / 12.0", COMMAND)
        self.assertIn("NominalOpeningFt = 3.0", COMMAND)
        self.assertIn("not a selected elevation", COMMAND)

    def test_creates_native_floor_walls_and_doors_in_a_disposable_study(self):
        self.assertIn("Floor.Create", COMMAND)
        self.assertIn("Wall.Create", COMMAND)
        self.assertIn("NewFamilyInstance", COMMAND)
        self.assertIn("disposable documented coordination placeholders; not selected-D", COMMAND)
        self.assertIn("IFCVersion.IFC2x3CV2", COMMAND)

    def test_is_registered_and_independently_validated(self):
        self.assertIn("FHCoordinatedPlaceholders", PILOT)
        self.assertIn("NativeCoordinatedPlaceholderStudyCommand", PILOT)
        self.assertIn("forever-home-coordinated-placeholder-study-v1", VALIDATOR)
        self.assertIn("IFCDOOR", VALIDATOR)


if __name__ == "__main__":
    unittest.main()
