from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
VALIDATOR = (ROOT / "validate_m372_m06_tresham_b_study.ps1").read_text(encoding="utf-8")


class M372ValidatorContractTests(unittest.TestCase):
    def test_requires_native_outputs_and_hashes(self):
        self.assertIn("FH_M06_Tresham_B_Study.rvt", VALIDATOR)
        self.assertIn("FH_M06_Tresham_B_Study.ifc", VALIDATOR)
        self.assertIn("saved_rvt_sha256", VALIDATOR)
        self.assertIn("saved_rvt_sha256", VALIDATOR)
        self.assertIn("FILE_SCHEMA(('IFC2X3'))", VALIDATOR)

    def test_preserves_unresolved_gates(self):
        self.assertIn("door_approach_supported", VALIDATOR)
        self.assertIn("service_route_supported", VALIDATOR)
        self.assertIn("selected", VALIDATOR)


if __name__ == "__main__":
    unittest.main()
