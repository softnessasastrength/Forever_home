import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2].parent


class IntegratedStairSectionContractTests(unittest.TestCase):
    def test_command_and_validator_share_basis_and_schema(self):
        command = (ROOT / "Tools" / "RevitPilot" / "IntegratedStairSectionStudyCommand.cs").read_text(encoding="utf-8")
        validator = (ROOT / "Tools" / "validate_integrated_stair_section_study.ps1").read_text(encoding="utf-8")
        self.assertIn('schema = "forever-home-integrated-stair-section-v1"', command)
        self.assertIn('basis = "B"', command)
        self.assertIn('total_rise_in = 60.0', command)
        self.assertIn("forever-home-integrated-stair-section-v1", validator)
        self.assertIn("$m.basis -eq 'B'", validator)
        self.assertIn("$m.section_count -eq 1", validator)


if __name__ == "__main__":
    unittest.main()
