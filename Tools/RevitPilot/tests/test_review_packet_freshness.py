"""Regression tests preventing stale Revit reports from passing a newer study."""
from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

PILOT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PILOT_DIR))

from compile_review_packet import assess_config_source, assess_freshness, assess_model_fingerprint, build_packet  # noqa: E402


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

    def test_checked_in_config_hash_matches_snapshot(self) -> None:
        with tempfile.TemporaryDirectory(prefix="fh-config-freshness-") as temp:
            root = Path(temp)
            study = root / ".local/revit-pilot/compact-core/20261027T025740849Z"
            source = root / "Tools/RevitPilot/compact-study-config.json"
            study.mkdir(parents=True)
            source.parent.mkdir(parents=True)
            content = b'{"schema":"test"}\n'
            source.write_bytes(content)
            (study / "compact-study-config.json").write_bytes(content)
            import hashlib
            manifest = {"config_file": "compact-study-config.json", "config_sha256": hashlib.sha256(content).hexdigest()}
            result = assess_config_source(root, study, manifest)
            self.assertEqual(result["status"], "CURRENT")

    def test_config_snapshot_difference_is_stale(self) -> None:
        with tempfile.TemporaryDirectory(prefix="fh-config-freshness-") as temp:
            root = Path(temp)
            study = root / ".local/revit-pilot/compact-core/20261027T025740849Z"
            source = root / "Tools/RevitPilot/compact-study-config.json"
            study.mkdir(parents=True)
            source.parent.mkdir(parents=True)
            source.write_text("current", encoding="utf-8")
            (study / "config.json").write_text("older", encoding="utf-8")
            import hashlib
            manifest = {"config_file": "config.json", "config_sha256": hashlib.sha256(b"older").hexdigest()}
            result = assess_config_source(root, study, manifest)
            self.assertEqual(result["status"], "STALE")

    def test_missing_config_snapshot_is_unverified(self) -> None:
        result = assess_config_source(Path("/no-such-root"), Path("study"), {"config_file": "config.json", "config_sha256": "0" * 64})
        self.assertEqual(result["status"], "UNVERIFIED")

    def test_matching_saved_model_fingerprint_is_current_even_when_run_is_older(self) -> None:
        import hashlib
        with tempfile.TemporaryDirectory(prefix="fh-model-fingerprint-") as temp:
            study = Path(temp)
            rvt = study / "study.rvt"
            rvt.write_bytes(b"exact saved RVT bytes")
            digest = hashlib.sha256(rvt.read_bytes()).hexdigest()
            identity = {"algorithm": "sha256-of-saved-rvt-bytes-v1", "sha256": digest,
                        "file_name": rvt.name, "bytes": rvt.stat().st_size}
            result = assess_model_fingerprint({"model_fingerprint": identity},
                                              {"model_fingerprint": identity}, study)
            self.assertEqual(result["status"], "CURRENT")
            timestamp = assess_freshness(Path("20261027T021506070Z"), Path("20261027T025740849Z"))
            self.assertEqual(timestamp["status"], "STALE")

    def test_different_fingerprint_is_stale_even_when_evidence_run_is_newer(self) -> None:
        import hashlib
        with tempfile.TemporaryDirectory(prefix="fh-model-fingerprint-") as temp:
            study = Path(temp)
            rvt = study / "study.rvt"
            rvt.write_bytes(b"current saved RVT")
            digest = hashlib.sha256(rvt.read_bytes()).hexdigest()
            study_identity = {"algorithm": "sha256-of-saved-rvt-bytes-v1", "sha256": digest,
                              "file_name": rvt.name, "bytes": rvt.stat().st_size}
            result = assess_model_fingerprint({"model_fingerprint": {**study_identity, "sha256": "0" * 64}},
                                              {"model_fingerprint": study_identity}, study)
            self.assertEqual(result["status"], "STALE")

    def test_missing_fingerprint_is_unverified(self) -> None:
        result = assess_model_fingerprint({}, {"model_fingerprint": {"sha256": "0" * 64}}, Path("study"))
        self.assertEqual(result["status"], "UNVERIFIED")

    def test_retained_rvt_mutation_invalidates_matching_report_hash(self) -> None:
        import hashlib
        with tempfile.TemporaryDirectory(prefix="fh-model-fingerprint-") as temp:
            study = Path(temp)
            rvt = study / "study.rvt"
            rvt.write_bytes(b"original model")
            digest = hashlib.sha256(rvt.read_bytes()).hexdigest()
            identity = {"algorithm": "sha256-of-saved-rvt-bytes-v1", "sha256": digest,
                        "file_name": rvt.name, "bytes": rvt.stat().st_size}
            rvt.write_bytes(b"modified model")
            result = assess_model_fingerprint({"model_fingerprint": identity},
                                              {"model_fingerprint": identity}, study)
            self.assertEqual(result["status"], "STALE")

    def test_packet_marks_all_evidence_current_for_matching_saved_model(self) -> None:
        import hashlib
        with tempfile.TemporaryDirectory(prefix="fh-review-current-model-") as temp:
            root = Path(temp)
            study = root / ".local/revit-pilot/compact-core/20261027T025740849Z"
            audit = root / ".local/revit-pilot/audits/20261027T021437402Z"
            qa = root / ".local/revit-pilot/geometry-qa/20261027T021454801Z"
            export = root / ".local/revit-pilot/exports/20261027T021506070Z"
            for folder in (study, audit, qa, export):
                folder.mkdir(parents=True)
            model_file = study / "FH_Compact_Core_Study.rvt"
            model_file.write_bytes(b"same saved model across all evidence")
            identity = {
                "algorithm": "sha256-of-saved-rvt-bytes-v1",
                "sha256": hashlib.sha256(model_file.read_bytes()).hexdigest(),
                "file_name": model_file.name,
                "bytes": model_file.stat().st_size,
            }
            (study / "study-manifest.json").write_text(json.dumps({"model_fingerprint": identity}), encoding="utf-8")
            (study / "study-warnings.json").write_text("[]", encoding="utf-8")
            (audit / "audit.json").write_text(json.dumps({"model_fingerprint": identity, "summary": {"warning_count": 0, "level_count": 3, "enclosed_room_count": 17, "wall_count": 78, "opening_count": 5}, "category_counts": [{"category": "Floors", "count": 3}]}), encoding="utf-8")
            (qa / "geometry-qa.json").write_text(json.dumps({"model_fingerprint": identity, "summary": {"issue_count": 0, "floor_count": 3, "room_count": 17, "wall_count": 78, "stair_count": 2, "door_count": 5}}), encoding="utf-8")
            (export / "export-results.json").write_text(json.dumps({"model_fingerprint": identity}), encoding="utf-8")
            (export / "FH_Compact_Core_Study.ifc").write_text("test IFC placeholder", encoding="utf-8")

            packet = build_packet(root)
            for name in ("study_model", "api_audit", "geometry_qa", "ifc_export"):
                self.assertEqual(packet["source_freshness"][name]["status"], "CURRENT", name)
            self.assertIsNotNone(packet["ifc_validation"])

    def test_packet_does_not_validate_prior_ifc_against_newer_study(self) -> None:
        with tempfile.TemporaryDirectory(prefix="fh-review-packet-") as temp:
            root = Path(temp)
            study = root / ".local/revit-pilot/compact-core/20261027T025740849Z"
            audit = root / ".local/revit-pilot/audits/20261027T021437402Z"
            qa = root / ".local/revit-pilot/geometry-qa/20261027T021454801Z"
            export = root / ".local/revit-pilot/exports/20261027T021506070Z"
            for folder in (study, audit, qa, export):
                folder.mkdir(parents=True)
            import hashlib
            model_file = study / "FH_Compact_Core_Study.rvt"
            model_file.write_bytes(b"current study model")
            current_hash = hashlib.sha256(model_file.read_bytes()).hexdigest()
            model_identity = {"algorithm": "sha256-of-saved-rvt-bytes-v1", "sha256": current_hash,
                              "file_name": model_file.name, "bytes": model_file.stat().st_size}
            mismatched_identity = {**model_identity, "sha256": "1" * 64}
            (study / "study-warnings.json").write_text("[]", encoding="utf-8")
            (audit / "audit.json").write_text(json.dumps({"model_fingerprint": mismatched_identity, "summary": {"warning_count": 0, "level_count": 3, "enclosed_room_count": 17, "wall_count": 78, "opening_count": 5}, "category_counts": [{"category": "Floors", "count": 3}]}), encoding="utf-8")
            (qa / "geometry-qa.json").write_text(json.dumps({"model_fingerprint": mismatched_identity, "summary": {"issue_count": 0, "floor_count": 3, "room_count": 17, "wall_count": 78, "stair_count": 2, "door_count": 5}}), encoding="utf-8")
            manifest = {"model_fingerprint": model_identity}
            (study / "study-manifest.json").write_text(json.dumps(manifest), encoding="utf-8")
            (export / "export-results.json").write_text(json.dumps({"model_fingerprint": mismatched_identity}), encoding="utf-8")
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
