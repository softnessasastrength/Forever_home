from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "NativeRoofShellStudyCommand.cs").read_text(encoding="utf-8")


class NativeRoofShellCommandContractTests(unittest.TestCase):
    def test_uses_native_footprint_roof_and_three_documented_cases(self):
        self.assertIn("NewFootPrintRoof", SOURCE)
        self.assertIn('("8:12", 8, 12)', SOURCE)
        self.assertIn('("10:12", 10, 12)', SOURCE)
        self.assertIn('("12:12", 12, 12)', SOURCE)

    def test_binds_selected_d_and_documented_basis(self):
        self.assertIn("Selected_Design_Iteration_2026-10-27/study.json", SOURCE)
        self.assertIn("M38_Steep_Roof_Pitch_Options_2026-10-28/README.md", SOURCE)
        self.assertIn("ExpectedSourceHash", SOURCE)

    def test_exports_inside_rollback_transaction(self):
        self.assertIn('new(doc, "Export native roof IFC2x3")', SOURCE)
        self.assertIn("exportTx.RollBack()", SOURCE)
        self.assertIn("IFCVersion.IFC2x3CV2", SOURCE)

    def test_keeps_selection_and_compliance_limits_explicit(self):
        self.assertIn("selected = false", SOURCE)
        self.assertIn("does not establish code compliance", SOURCE)
        self.assertIn("no pitch or roof assembly selected", SOURCE)


if __name__ == "__main__":
    unittest.main()
