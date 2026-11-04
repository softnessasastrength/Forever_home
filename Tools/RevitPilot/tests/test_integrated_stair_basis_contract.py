import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2].parent


class IntegratedStairBasisContractTests(unittest.TestCase):
    def test_owner_b_basis_is_explicit_and_disposable(self):
        decision = (ROOT / "Decisions" / "2026-11-03_Integrated_Candidate_Stair_Decision_Gate.md").read_text(encoding="utf-8")
        validator = (ROOT / "Tools" / "validate_integrated_stair_basis.ps1").read_text(encoding="utf-8")
        self.assertIn("owner selected **B**", decision)
        self.assertIn("60 in per half-story", decision)
        self.assertIn("not a final floor-to-floor", decision)
        self.assertIn("basis='B'", validator)
        self.assertIn("total_rise_in=60", validator)


if __name__ == "__main__":
    unittest.main()
