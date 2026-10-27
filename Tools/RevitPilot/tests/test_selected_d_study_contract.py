import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
STUDY_PATH = ROOT / "Architecture" / "Selected_Design_Iteration_2026-10-27" / "study.json"
COMMAND_PATH = ROOT / "Tools" / "RevitPilot" / "Pilot.cs"


class SelectedDStudyContractTests(unittest.TestCase):
    def test_room_block_schema_is_consumed_by_revit_command(self):
        study = json.loads(STUDY_PATH.read_text(encoding="utf-8-sig"))
        command = COMMAND_PATH.read_text(encoding="utf-8")
        room_blocks = [room for level in ("main", "upper", "lower") for room in study["plans"][level]]

        self.assertEqual(len(room_blocks), 21)
        self.assertEqual(len({room["id"] for room in room_blocks}), 21)
        self.assertEqual(study["plan_frame_offsets_ft"], {
            "main": [0.0, 0.0],
            "upper": [0.0, 6.0],
            "lower": [0.0, 10.0],
        })
        for room in room_blocks:
            self.assertTrue({"id", "name", "x", "y", "w", "d", "kind"}.issubset(room))
            self.assertGreater(room["w"], 0)
            self.assertGreater(room["d"], 0)

        # Guard the boundary between the checked-in schematic and the native
        # command: the source rectangle encoding must be explicitly supported
        # and used for both boundary edges and room placement.
        for property_name in ("x", "y", "w", "d"):
            self.assertIn(f'TryGetProperty("{property_name}"', command)
        self.assertIn("AddRectangleEdges(room,horizontal,vertical,offsetX,offsetY)", command)
        self.assertIn("Rectangle(roomSpec,offsetX,offsetY)", command)
        self.assertIn("if(ka==kb) return;", command)
        self.assertIn('Numbers(study.GetProperty("plan_frame_offsets_ft"),floor.key)', command)
        self.assertIn('"D-S1-LOWER-LANDING",r[0]+frame[0],r[1]+frame[1]', command)


if __name__ == "__main__":
    unittest.main()
