"""Validate known family-intake candidates before a Revit run."""
import csv
import json
import sys
from hashlib import sha256
from pathlib import Path

INCOMING = {
    "M-06": "Solid_Surface_Vanity_Counter_w_Faucet_22366.rfa",
    "M-01": "Sony_Flat_LED_TV_face_based_17584.rfa",
}
MANUFACTURER_INCOMING = [
    {
        "room_id": "M-06",
        "filename": "american-standard-champion-pro-3195A101020-bowl.rfa",
        "sha256": "F301D2CB77F13269E21DC44FD6953946158034122BB3C10889FCBA9470846393",
        "status": "received",
        "test_run": "queued",
        "source_url": "https://lixilpro.com/products/toilets/Floor-Standing-Toilets/Champion-PRO-Chair-Height-Elongated-Bowl/White-%28020%29-3195A101020/?s=3195A101.020",
    },
    {
        "room_id": "M-06",
        "filename": "american-standard-evolution-0467004.020.rfa",
        "sha256": "39715206F24DE4B909E37324CE352BBA3AF348BCA259B7A9C0CE335ED2DDC3EA",
        "status": "research-candidate",
        "test_run": ".local/revit-pilot/family-intake/20261028T023252013Z/",
        "source_url": "https://www.americanstandard-us.com/products/22-inch-evolution-r-4-inch-centerset-pedestal-sink-top-and-leg-combination",
    },
]
QUARANTINED_RESEARCH = [
    {
        "sku": "American Standard Estate 0900800.020",
        "filename": "american-standard-estate-0900800.020.rfa",
        "sha256": "130B63661471753DD373DB322E723BA61E7EE70BC4C90D3DF6351030E954910B",
        "product_page_url": "https://lixilpro.com/products/bathroom-sinks/pedestal-sinks/Estate-8-Inch-Widespread-Pedestal-Sink-Top-and-Leg-Combination/White-%28020%29-0900800020/",
        "source_url": "https://lixil.cdn.celum.cloud/253508_Basin-Pedestal-American_Standard-Estate-0900_Series_original.rfa",
    },
    {
        "sku": "American Standard Cadet 0236411.020",
        "filename": "american-standard-cadet-0236411.020.rfa",
        "sha256": "AAB1320BD60E410919EED5A9DA8018D9883A409EE636C2A64D4FE8BED8A4B5D9",
        "product_page_url": "https://lixilpro.com/products/bathroom-sinks/pedestal-tops/Cadet-4-in-Centerset-Pedestal-Sink-Top-and-Leg-Combination/White-%28020%29-0236411020/?s=0236411.020",
        "source_url": "https://lixil.cdn.celum.cloud/173914_as_us_bath_cad_RFA__0236%20%283651%29_original.rfa",
    },
    {
        "sku": "TOTO Dartmouth LPT642",
        "filename": "toto-dartmouth-lpt642.rfa",
        "sha256": "43BCB5EC2BD2BD45D2EC1C43509A0B518AEC71F723FAFF460CDFDDAF09586AB0",
        "product_page_url": "https://www.totousa.com/dartmouth-pedestal-lavatory",
        "source_url": "https://www.totousa.com/filemanager_uploads/product_assets/REVITModels/BM-00070_LPT642.rfa",
    },
    {
        "sku": "TOTO Clayton LPT780",
        "filename": "toto-clayton-lpt780.rfa",
        "sha256": "16FEAB5E69583EE27533B7A12EC5A114DE632CA4CE139F70F582423FBF84B664",
        "product_page_url": "https://www.totousa.com/clayton-pedestal-lavatory",
        "source_url": "https://www.totousa.com/filemanager_uploads/product_assets/REVITModels/BM-00195_LPT780.rfa",
    },
]
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
    for candidate in MANUFACTURER_INCOMING:
        room_id = candidate["room_id"]
        filename = candidate["filename"]
        path = incoming / filename
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing or empty manufacturer family: {filename}")
            continue
        digest = sha256(path.read_bytes()).hexdigest().upper()
        if digest != candidate["sha256"]:
            errors.append(f"source hash mismatch for manufacturer family: {filename}")
        quarantine = root / ".local" / "revit-pilot" / "family-intake" / "candidates" / filename
        if not quarantine.is_file() or quarantine.stat().st_size == 0:
            errors.append(f"missing or empty quarantined manufacturer source: {filename}")
        else:
            quarantine_digest = sha256(quarantine.read_bytes()).hexdigest().upper()
            if quarantine_digest != candidate["sha256"]:
                errors.append(f"quarantined source hash mismatch for manufacturer family: {filename}")
            if quarantine_digest != digest:
                errors.append(f"incoming/quarantine bytes differ for manufacturer family: {filename}")
        matches = [row for row in rows if row.get("room_id") == room_id and filename in (row.get("notes") or "")]
        if len(matches) != 1:
            errors.append(f"manifest linkage mismatch for {room_id}: {filename}")
        else:
            row = matches[0]
            if row.get("status") != candidate["status"] or row.get("test_run") != candidate["test_run"]:
                errors.append(f"manufacturer family manifest disposition mismatch: {filename}")
            if candidate["sha256"] not in (row.get("notes") or ""):
                errors.append(f"manifest source hash mismatch for manufacturer family: {filename}")
            if row.get("source_url") != candidate["source_url"]:
                errors.append(f"manufacturer family source URL mismatch: {filename}")
    quarantine_dir = root / ".local" / "revit-pilot" / "family-intake" / "candidates"
    provenance_path = quarantine_dir / "m06-sink-candidate-provenance-20261028.json"
    try:
        provenance = json.loads(provenance_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        provenance = []
        errors.append(f"cannot read M-06 public-family provenance record: {error}")
    if not isinstance(provenance, list):
        provenance = []
        errors.append("M-06 public-family provenance record must be a JSON array")
    for candidate in QUARANTINED_RESEARCH:
        filename = candidate["filename"]
        path = quarantine_dir / filename
        if not path.is_file() or path.stat().st_size == 0:
            errors.append(f"missing or empty quarantined research family: {filename}")
            continue
        digest = sha256(path.read_bytes()).hexdigest().upper()
        if digest != candidate["sha256"]:
            errors.append(f"quarantined research family hash mismatch: {filename}")
        matches = [row for row in provenance if isinstance(row, dict) and row.get("filename") == filename]
        if len(matches) != 1:
            errors.append(f"provenance record linkage mismatch: {filename}")
        elif any(matches[0].get(key) != candidate[key] for key in ("sku", "sha256", "product_page_url", "source_url")):
            errors.append(f"pinned source URL/hash metadata mismatch: {filename}")
        elif matches[0].get("inspection_status") != "quarantined research candidate; not inspected or approved":
            errors.append(f"unexpected research candidate disposition: {filename}")
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
        f"{len(MANUFACTURER_INCOMING)} manufacturer families with exact SHA256/provenance, "
        f"{len(QUARANTINED_RESEARCH)} quarantined public research families with exact SHA256/provenance, "
        f"{len(REJECTED)} archived rejection, and 21015 disposition validated"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
