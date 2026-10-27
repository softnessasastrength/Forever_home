"""Regression tests preventing stale Revit reports from passing a newer study."""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

PILOT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PILOT_DIR))

from compile_review_packet import assess_freshness, build_packet  # noqa: E402


class ReviewPacketFreshnessTests(unittest.TestCase):
    def test_run_timestamp_precision_variants(self) -> None:
        with_ms = assess_freshness(Path("20261027T025740849Z"), Path("20261027T025740Z"))
        with_us = assess_freshness(Path("20261027T022256699507Z"), Path("20261027T021506070Z"))
        self.assertEqual(with_ms["status"], "CURRENT")
        self.assertEqual(with_us["status"], "CURRENT")

    def test_older_evidence_is_stale(self) -> None:
        result = assess_freshness(Path("20261027T021506070Z"), Path("20261027T025740849Z"))
        self.assertEqual(result["status"], "STALE")

    def test_unparseable_run_names_are_unverified(self) -> None:
        result = assess_freshness(Path("latest"), Path("study"))
        self.assertEqual(result["status"], "UNVERIFIED")

    def test_missing_study_cannot_make_evidence_current(self) -> None:
        result = assess_freshness(Path("20261027T025740849Z"), None)
        self.assertEqual(result["status"], "UNKNOWN")

    def test_packet_does_not_validate_prior_ifc_against_newer_study(self) -> None:
        with tempfile.TemporaryDirectory(prefix="fh-review-packet-") as temp:
            root = Path(temp)
            study = root / ".local/revit-pilot/compact-core/20261027T025740849Z"
            audit = root / ".local/revit-pilot/audits/20261027T021437402Z"
            qa = root / ".local/revit-pilot/geometry-qa/20261027T021454801Z"
            export = root / ".local/revit-pilot/exports/20261027T021506070Z"
            for folder in (study, audit, qa, export):
                folder.mkdir(parents=True)
            (study / "study-warnings.json").write_text("[]", encoding="utf-8")
            (audit / "audit.json").write_text(json.dumps({"summary": {"warning_count": 0, "level_count": 3, "enclosed_room_count": 17, "wall_count": 78, "opening_count": 5}, "category_counts": [{"category": "Floors", "count": 3}]}), encoding="utf-8")
            (qa / "geometry-qa.json").write_text(json.dumps({"summary": {"issue_count": 0, "floor_count": 3, "room_count": 17, "wall_count": 78, "stair_count": 2, "door_count": 5}}), encoding="utf-8")
            (export / "FH_Compact_Core_Study.ifc").write_text("older export", encoding="utf-8")

            packet = build_packet(root)
            checks = {item["name"]: item for item in packet["checks"]}
            self.assertEqual(checks["Read-only API inventory"]["status"], "STALE")
            self.assertEqual(checks["Read-only Geometry QA"]["status"], "STALE")
            self.assertEqual(checks["Independent Compact-Core IFC validation"]["status"], "STALE")
            self.assertIsNone(packet["ifc_validation"])
            self.assertEqual(packet["source_freshness"]["ifc_export"]["status"], "STALE")


if __name__ == "__main__":
    unittest.main()
