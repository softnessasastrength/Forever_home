"""Validate known family-intake candidates before a Revit run."""
import csv
import sys
from hashlib import sha256
from pathlib import Path

INCOMING = {
    "M-06": "Solid_Surface_Vanity_Counter_w_Faucet_22366.rfa",
    "M-01": "Sony_Flat_LED_TV_face_based_17584.rfa",
}
MANUFACTURER_INCOMING = {
    "M-06": {
        "filename": "american-standard-champion-pro-3195A101020-bowl.rfa",
        "sha256": "F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393",
    },
}
REJECTED = {
    "M-02": "Island_Cabinet_or_Countertop_19967.rfa",
}


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    incoming = root / "Revit" / "Family_Intake" / "Incoming"
    rejected = root / "Revit" / "Family_Intake" / "Rejected"
    manifest = root / "Revit" / "Family_Intake" / "intake_manifest.csv"
    errors: list[str] = []
    with manifest.open(newline="", encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))
    for filename in INCOMING.values():
        path = incoming / filename
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing or empty family: {filename}")
    for room_id, filename in INCOMING.items():
        # Multiple alternatives may be logged for one room (e.g. the kitchen
        # island). Link each source by its own filename rather than assuming
        # one manifest row per room ID.
        matches = [row for row in rows if row.get("room_id") == room_id and filename in (row.get("notes") or "")]
        if len(matches) != 1:
            errors.append(f"manifest linkage mismatch for {room_id}: {filename}")
        else:
            row = matches[0]
            status = row.get("status")
            if status == "received" and row.get("test_run") != "queued":
                errors.append(f"received family is not queued for {room_id}: {filename}")
            elif status == "tested-unapproved" and not (row.get("test_run") or "").strip():
                errors.append(f"tested family has no evidence path for {room_id}: {filename}")
            elif status not in {"received", "tested-unapproved"}:
                errors.append(f"incoming manifest state is not received or tested-unapproved for {room_id}: {filename}")
    for room_id, candidate in MANUFACTURER_INCOMING.items():
        filename = candidate["filename"]
        path = incoming / filename
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing or empty manufacturer family: {filename}")
            continue
        digest = sha256(path.read_bytes()).hexdigest().upper()
        if digest != candidate["sha256"]:
            errors.append(f"source hash mismatch for manufacturer family: {filename}")
        matches = [row for row in rows if row.get("room_id") == room_id and filename in (row.get("notes") or "")]
        if len(matches) != 1:
            errors.append(f"manifest linkage mismatch for {room_id}: {filename}")
        else:
            row = matches[0]
            if row.get("status") != "received" or row.get("test_run") != "queued":
                errors.append(f"manufacturer family is not queued for isolated intake: {filename}")
            if candidate["sha256"] not in (row.get("notes") or ""):
                errors.append(f"manifest source hash mismatch for manufacturer family: {filename}")
    for room_id, filename in REJECTED.items():
        path = rejected / filename
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing or empty archived rejected family: {filename}")
        matches = [row for row in rows if row.get("room_id") == room_id and filename in (row.get("notes") or "")]
        if len(matches) != 1:
            errors.append(f"rejected manifest linkage mismatch for {room_id}: {filename}")
        elif matches[0].get("status") != "rejected" or not (matches[0].get("test_run") or "").strip():
            errors.append(f"rejected family lacks disposition/evidence for {room_id}: {filename}")
    alternate_21015 = [row for row in rows if row.get("room_id") == "M-02" and "object_id=21015" in (row.get("source_url") or "")]
    if len(alternate_21015) != 1 or alternate_21015[0].get("status") != "rejected" or not (alternate_21015[0].get("test_run") or "").strip():
        errors.append("RevitCity 21015 rejection must remain linked to its inspection record")
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print(
        f"PASS: {len(INCOMING)} RevitCity candidates, "
        f"{len(MANUFACTURER_INCOMING)} manufacturer family with exact SHA256/provenance, "
        f"{len(REJECTED)} archived rejection, and 21015 disposition validated"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
