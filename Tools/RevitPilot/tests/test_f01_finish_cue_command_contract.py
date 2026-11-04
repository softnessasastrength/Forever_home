from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMMAND = (ROOT / "NativeFinishCueStudyCommand.cs").read_text(encoding="utf-8")
PILOT = (ROOT / "Pilot.cs").read_text(encoding="utf-8")
VALIDATOR = (ROOT / "validate_f01_finish_cue.ps1").read_text(encoding="utf-8")


class F01FinishCueCommandContractTests(unittest.TestCase):
    def test_material_name_is_revit_safe_and_display_only(self):
        self.assertIn('private const string MaterialName = "FH-F-01-EngHardwood-OakWarm - DISPLAY ONLY - owner-selected finish direction";', COMMAND)
        self.assertNotIn('MaterialName = "FH-F-01-EngHardwood-OakWarm |', COMMAND)
        self.assertIn("assembly_selected = false", COMMAND)

    def test_creates_one_labelled_floor_and_exports_ifc2x3(self):
        self.assertIn("floorCount != 1", COMMAND)
        self.assertIn("IFCVersion.IFC2x3CV2", COMMAND)
        self.assertIn('new Transaction(doc, "Export F-01 finish cue IFC2x3")', COMMAND)
        self.assertIn("f01-finish-cue-manifest.json", COMMAND)

    def test_ribbon_registration_and_validator_are_present(self):
        self.assertIn("FHNativeFinishCueStudy", PILOT)
        self.assertIn("NativeFinishCueStudyCommand", PILOT)
        self.assertIn("forever-home-f01-finish-cue-v1", VALIDATOR)
        self.assertIn("assembly_selected", VALIDATOR)


if __name__ == "__main__":
    unittest.main()
