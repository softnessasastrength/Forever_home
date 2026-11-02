from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMMAND = (ROOT / "NativeInteriorDesignStudyCommand.cs").read_text(encoding="utf-8")
PILOT = (ROOT / "Pilot.cs").read_text(encoding="utf-8")


class InteriorDesignStudyContractTests(unittest.TestCase):
    def test_uses_source_blocks_and_keeps_selected_d_protected(self):
        self.assertIn("room_blocks", COMMAND)
        self.assertIn("Selected-D changed", COMMAND)
        self.assertIn("selected = false", COMMAND)
        self.assertIn("M-02 kitchen island", COMMAND)
        self.assertIn("U-05 primary-bath vignette", COMMAND)

    def test_is_registered(self):
        self.assertIn("FHInteriorDesignStudy", PILOT)
        self.assertIn("NativeInteriorDesignStudyCommand", PILOT)


if __name__ == "__main__":
    unittest.main()
