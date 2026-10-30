import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
COMMAND_PATH = ROOT / "Tools" / "RevitPilot" / "Pilot.cs"


class M83GableCommandContractTests(unittest.TestCase):
    def test_relative_datum_preserves_template_levels(self):
        command = COMMAND_PATH.read_text(encoding="utf-8")
        start = command.index("public class GableMassingCommand")
        end = command.index("public class CompactCoreCommand", start)
        gable_command = command[start:end]

        self.assertIn("seedLevels.Length > 0", gable_command)
        self.assertIn("seedLevels.OrderBy(level => level.Elevation).First()", gable_command)
        self.assertIn('Level.Create(doc, 0)', gable_command)
        self.assertNotIn("doc.Delete(", gable_command)
        self.assertIn("levels = new FilteredElementCollector(doc).OfClass(typeof(Level)).GetElementCount()", gable_command)


if __name__ == "__main__":
    unittest.main()
