from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
COMMAND = (ROOT / "NativeM06TreshamBStudyCommand.cs").read_text(encoding="utf-8")
PILOT = (ROOT / "Pilot.cs").read_text(encoding="utf-8")


class M372M06TreshamBContractTests(unittest.TestCase):
    def test_pins_tresham_source_and_preserves_isolated_scope(self):
        self.assertIn("kohler-tresham-k-2844-4-0.rfa", COMMAND)
        self.assertIn("3b1cbdaa844d35bd462f6e59a828b82f7870fde4ee7397bac09f4ca0c2f9b949", COMMAND)
        self.assertIn("m06-tresham-b-study", COMMAND)
        self.assertIn("Selected-D and the Evolution RFA are untouched", COMMAND)

    def test_keeps_door_and_service_gates_false(self):
        self.assertIn("door_approach_supported = false", COMMAND)
        self.assertIn("service_route_supported = false", COMMAND)
        self.assertIn("lower-MEP route marker only", COMMAND)
        self.assertIn("IFCVersion.IFC2x3CV2", COMMAND)

    def test_is_registered(self):
        self.assertIn("FHM372M06TreshamB", PILOT)
        self.assertIn("NativeM06TreshamBStudyCommand", PILOT)


if __name__ == "__main__":
    unittest.main()
