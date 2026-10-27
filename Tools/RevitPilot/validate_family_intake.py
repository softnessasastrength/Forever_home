"""Validate the quarantined RevitCity family intake before a Revit run."""
import csv
import sys
from pathlib import Path

EXPECTED = {
    "M-06": "Solid_Surface_Vanity_Counter_w_Faucet_22366.rfa",
    "M-02": "Island_Cabinet_or_Countertop_19967.rfa",
    "M-01": "Sony_Flat_LED_TV_face_based_17584.rfa",
}


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    incoming = root / "Revit" / "Family_Intake" / "Incoming"
    manifest = root / "Revit" / "Family_Intake" / "intake_manifest.csv"
    errors: list[str] = []
    for filename in EXPECTED.values():
        path = incoming / filename
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing or empty family: {filename}")
    rows = list(csv.DictReader(manifest.open(newline="", encoding="utf-8")))
    for room_id, filename in EXPECTED.items():
        # Multiple alternatives may be logged for one room (e.g. the kitchen
        # island). Link each quarantined source by its own filename rather
        # than assuming one row per room ID.
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
                errors.append(f"manifest state is not received or tested-unapproved for {room_id}: {filename}")
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print(f"PASS: {len(EXPECTED)} quarantined family files and manifest links validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
