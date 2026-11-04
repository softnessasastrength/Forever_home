import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2].parent


class ArchitectReviewContractTests(unittest.TestCase):
    def test_requirement_matrix_is_wired_into_sequence(self):
        sequence = (ROOT / "Tools" / "run_verified_bim_sequence.ps1").read_text(encoding="utf-8")
        matrix = (ROOT / "Tools" / "validate_architect_review_requirements.ps1").read_text(encoding="utf-8")
        bundle = (ROOT / "Tools" / "validate_architect_review_bundle.ps1").read_text(encoding="utf-8")
        self.assertIn("architect_review_requirements", sequence)
        self.assertIn("pass-with-open-gates", matrix)
        for label in ("native walls", "floor candidates", "roof candidates", "circulation", "kitchen", "baths", "patio/porch", "skylights"):
            self.assertIn(label, matrix)
        self.assertIn("open_gates", bundle)
        self.assertIn("artifacts", bundle)


if __name__ == "__main__":
    unittest.main()
