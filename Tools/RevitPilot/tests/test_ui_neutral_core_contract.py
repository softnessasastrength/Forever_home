from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[3]
CORE = ROOT / "Tools" / "RevitPilot" / "Core" / "StudyArtifactContract.cs"
COMMAND = ROOT / "Tools" / "RevitPilot" / "NativeM06TreshamBStudyCommand.cs"


class UiNeutralCoreContractTests(unittest.TestCase):
    def test_core_has_no_revit_dependency(self):
        text = CORE.read_text(encoding="utf-8")
        self.assertNotIn("using Autodesk.", text)
        self.assertIn("StudyArtifactContract", text)
        self.assertIn("Sha256File", text)
        self.assertIn("WriteJson", text)

    def test_native_command_consumes_core_helpers(self):
        text = COMMAND.read_text(encoding="utf-8")
        self.assertIn("using ForeverHome.Pilot.Core;", text)
        self.assertGreaterEqual(text.count("StudyArtifactContract."), 4)
        self.assertNotIn("SHA256.HashData", text)


if __name__ == "__main__":
    unittest.main()
