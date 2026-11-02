from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
CORE_PROJECT = ROOT / "Tools" / "RevitPilot" / "Core" / "RevitPilot.Core.csproj"
SPEC = ROOT / "Tools" / "RevitPilot" / "Core" / "M06CoordinationStudySpec.cs"


class CoreProjectContractTests(unittest.TestCase):
    def test_standalone_core_targets_net10_without_revit_references(self):
        project = CORE_PROJECT.read_text(encoding="utf-8")
        self.assertIn("net10.0", project)
        self.assertNotIn("RevitAPI", project)

    def test_m06_spec_keeps_assignment_and_fit_gates_closed(self):
        text = SPEC.read_text(encoding="utf-8")
        for value in ("unassigned", "west-A", "east-B", "into-bath", "same-wet-wall", "lower-MEP-reservation"):
            self.assertIn(value, text)
        self.assertIn("FitGatesClosed", text)


if __name__ == "__main__":
    unittest.main()
