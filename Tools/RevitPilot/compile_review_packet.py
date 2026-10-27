"""Compile the latest RevitPilot evidence into one offline review packet.

This script never opens Revit and never edits a model. It only reads timestamped
artifacts already produced by the add-in and the compact-core preflight.
"""
from __future__ import annotations

import argparse
import html
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent))
from validate_compact_manifest import validate as validate_manifest


def latest_dir(root: Path, relative: str) -> Path | None:
    folder = root / relative
    if not folder.is_dir():
        return None
    candidates = sorted((p for p in folder.iterdir() if p.is_dir()), reverse=True)
    return candidates[0] if candidates else None


def read_json(path: Path | None) -> dict[str, Any] | list[Any] | None:
    if path is None or not path.is_file():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def relative_artifact(root: Path, path: Path | None) -> str | None:
    if path is None:
        return None
    return path.relative_to(root).as_posix()


def build_packet(root: Path) -> dict[str, Any]:
    compact = latest_dir(root, ".local/revit-pilot/compact-core")
    audit = latest_dir(root, ".local/revit-pilot/audits")
    qa = latest_dir(root, ".local/revit-pilot/geometry-qa")

    warnings = read_json(compact / "study-warnings.json" if compact else None)
    audit_data = read_json(audit / "audit.json" if audit else None)
    qa_data = read_json(qa / "geometry-qa.json" if qa else None)
    manifest_path = compact / "study-manifest.json" if compact else None
    manifest_data = read_json(manifest_path)
    manifest_errors = validate_manifest(manifest_path) if manifest_path and isinstance(manifest_data, dict) else ["No study manifest found"]

    warning_count = len(warnings) if isinstance(warnings, list) else None
    audit_summary = audit_data.get("summary", {}) if isinstance(audit_data, dict) else {}
    qa_summary = qa_data.get("summary", {}) if isinstance(qa_data, dict) else {}
    audit_categories = {
        item.get("category"): item.get("count")
        for item in audit_data.get("category_counts", [])
    } if isinstance(audit_data, dict) else {}
    audit_floor_count = audit_categories.get("Floors")
    audit_level_count = audit_summary.get("level_count")

    checks = [
        {
            "name": "Compact-core native Revit warnings",
            "status": "PASS" if warning_count == 0 else "OPEN" if warning_count is not None else "NOT FOUND",
            "detail": f"{warning_count} warning(s) in study-warnings.json" if warning_count is not None else "No study warning report found",
            "artifact": relative_artifact(root, compact / "study-warnings.json" if compact else None),
        },
        {
            "name": "Read-only API inventory",
            "status": "PASS" if audit_summary.get("warning_count") == 0 and audit_floor_count == 3 and audit_level_count == 3 else "OPEN" if audit_summary else "NOT FOUND",
            "detail": (
                f"{audit_level_count if audit_level_count is not None else '?'} levels, "
                f"{audit_floor_count if audit_floor_count is not None else '?'} floors, "
                f"{audit_summary.get('enclosed_room_count', '?')} rooms, "
                f"{audit_summary.get('wall_count', '?')} walls, "
                f"{audit_summary.get('opening_count', '?')} openings, "
                f"{audit_summary.get('warning_count', '?')} warnings"
            ) if audit_summary else "No API audit found",
            "artifact": relative_artifact(root, audit / "audit.json" if audit else None),
        },
        {
            "name": "Read-only Geometry QA",
            "status": "PASS" if qa_summary.get("issue_count") == 0 and qa_summary.get("floor_count") == 3 else "OPEN" if qa_summary else "NOT FOUND",
            "detail": (
                f"{qa_summary.get('issue_count', '?')} issues; "
                f"{qa_summary.get('room_count', '?')} rooms, "
                f"{qa_summary.get('wall_count', '?')} walls, "
                f"{qa_summary.get('stair_count', '?')} stairs, "
                f"{qa_summary.get('door_count', '?')} doors, "
                f"{qa_summary.get('floor_count', '?')} floors"
            ) if qa_summary else "No Geometry QA found",
            "artifact": relative_artifact(root, qa / "geometry-qa.json" if qa else None),
        },
        {
            "name": "Compact-core manifest presence",
            "status": "PASS" if not manifest_errors else "OPEN",
            "detail": "Schema, IDs and dimensional targets validated" if not manifest_errors else "; ".join(manifest_errors),
            "artifact": relative_artifact(root, manifest_path),
        },
    ]

    open_items: list[dict[str, Any]] = []
    if isinstance(warnings, list):
        open_items.extend({"source": "study-warnings.json", **item} for item in warnings)
    if isinstance(qa_data, dict) and isinstance(qa_data.get("issues"), list):
        open_items.extend({"source": "geometry-qa.json", **item} for item in qa_data["issues"])

    return {
        "schema": "forever-home.revit-review-packet.v1",
        "status": "compiled offline from timestamped evidence; no Revit model changes",
        "utc": datetime.now(timezone.utc).isoformat(),
        "root_relative": ".",
        "latest_artifacts": {
            "compact_core": relative_artifact(root, compact),
            "api_audit": relative_artifact(root, audit),
            "geometry_qa": relative_artifact(root, qa),
        },
        "checks": checks,
        "open_items": open_items,
        "limitations": [
            "This packet summarizes recorded evidence; it does not rerun Revit or validate unseen model state.",
            "PASS means the specific recorded check returned no findings, not code, accessibility, structural, engineering or permit approval.",
            "Visual review, export fidelity, Revit 2018 interoperability and professional review remain separate gates.",
        ],
    }


def render_html(packet: dict[str, Any]) -> str:
    def esc(value: Any) -> str:
        return html.escape(str(value))

    rows = "\n".join(
        f"<tr><td>{esc(c['name'])}</td><td class=\"{esc(c['status']).lower().replace(' ', '-') }\">{esc(c['status'])}</td>"
        f"<td>{esc(c['detail'])}</td><td><code>{esc(c.get('artifact') or '')}</code></td></tr>"
        for c in packet["checks"]
    )
    items = packet["open_items"]
    issue_html = "<p>None recorded in the latest evidence.</p>" if not items else "<ul>" + "".join(
        f"<li><strong>{esc(item.get('source'))}</strong>: {esc(item.get('description') or item.get('detail') or item)}</li>"
        for item in items
    ) + "</ul>"
    limitations = "".join(f"<li>{esc(item)}</li>" for item in packet["limitations"])
    return f"""<!doctype html>
<html lang=\"en\"><head><meta charset=\"utf-8\"><title>Forever Home Revit review packet</title>
<style>body{{font:15px Segoe UI,Arial,sans-serif;max-width:1100px;margin:32px auto;padding:0 24px;color:#222}}h1{{margin-bottom:4px}}.meta{{color:#666}}table{{border-collapse:collapse;width:100%;margin:20px 0}}th,td{{border:1px solid #ccc;padding:9px;text-align:left;vertical-align:top}}th{{background:#eee}}.pass{{color:#176b31;font-weight:700}}.open{{color:#9b2c2c;font-weight:700}}.not-found{{color:#765b00;font-weight:700}}code{{font-size:12px}}</style></head>
<body><h1>Forever Home Revit review packet</h1><p class=\"meta\">Compiled {esc(packet['utc'])}. Offline summary of timestamped evidence; no model changes.</p>
<h2>Checks</h2><table><thead><tr><th>Check</th><th>Status</th><th>Observed result</th><th>Evidence</th></tr></thead><tbody>{rows}</tbody></table>
<h2>Open items</h2>{issue_html}<h2>Limitations</h2><ul>{limitations}</ul>
<h2>Latest artifact directories</h2><pre>{esc(json.dumps(packet['latest_artifacts'], indent=2))}</pre></body></html>"""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--output", type=Path, help="Explicit output directory")
    args = parser.parse_args()
    root = args.root.resolve()
    packet = build_packet(root)
    output = (args.output or root / ".local/revit-pilot/review-packets" / datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S%fZ")).resolve()
    output.mkdir(parents=True, exist_ok=False)
    (output / "review-packet.json").write_text(json.dumps(packet, indent=2) + "\n", encoding="utf-8")
    (output / "review-packet.html").write_text(render_html(packet), encoding="utf-8")
    print(f"PASS: review packet written to {output.relative_to(root)}")
    for check in packet["checks"]:
        print(f"{check['status']}: {check['name']} — {check['detail']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
